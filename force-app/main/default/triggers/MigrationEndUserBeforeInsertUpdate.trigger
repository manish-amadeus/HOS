// This trigger: 
// 1. creates new MigrationCustomer records for Account records
// when a new or updated MigrationEndUser record is attached to an Account
// and the Account doesn't have a MigrationCustomer record attached to it
//
// 2. creates migration portal auth keys for Contacts 
// associated with MigrationEndUser records' Accounts
// 
// 3. attaches MigrationEndUser records to Migration Customer
// and MigrationProperty records found by Delphi.Net
// property ID and subscription ID

trigger MigrationEndUserBeforeInsertUpdate on MigrationEndUser__c (before insert, before update) {
    
    
    Set<Id> accountIds = new Set<Id>();
    Set<Id> parentaccountIds = new Set<Id>();
    Set<String> subscriptionids = new Set<String>();
    Set<String> propertyids = new Set<String>();
    Map<String, Account> subscriptionidtoaccount = new Map<String, Account>();
    Map<String, Account> propertyidtoaccount = new Map<String, Account>();
    Map<Id,Account> accountidtoaccount = new Map<Id,Account>();
    Set<Id> migrationCustomerIDs = new Set<Id>();
    
    // collect Account Ids, 
    // property IDs and subscription IDs
    for (Integer i=0;i<trigger.new.size();i++) {
        MigrationEndUser__c meu=trigger.new[i];
        if (meu.migrationCustomer__c!=null)
            migrationCustomerIDs.add(meu.migrationCustomer__c);
        if (meu.MigrationCustomerParentAccount__c!=null) {
            accountIds.add(meu.MigrationCustomerParentAccount__c);
            parentaccountIds.add(meu.MigrationCustomerParentAccount__c);
        }
        if (meu.PropertyAccount__c!=null)
            accountIds.add(meu.PropertyAccount__c);
        if (meu.SubscriptionID__c!=null)
            subscriptionids.add(meu.SubscriptionID__c);
        if (meu.PropertyID__c!=null)
            propertyids.add(meu.PropertyID__c);  
        if (trigger.isInsert) {
            if (meu.DelphiNetStatus__c=='Active') {
                meu.selectedForMigration__c=true;
                meu.Active__c=true;
            }
            else if (meu.DelphiNetStatus__c=='Inactive'){
                meu.selectedForMigration__c=false;
                meu.Active__c=false;
            }
        }
    }
    // find Accounts by ID, Subscription ID or Property (location) ID
    for (Account acc: [SELECT
        Id
        , Name
        , ShippingCity
        , ShippingState
        , ShippingStreet
        , ShippingPostalCode
        , BillingCity
        , BillingState
        , BillingStreet
        , BillingPostalCode
        , Delphi_Net_subscription_id__c
        , Delphi_Net_location_id__c
        FROM Account
        WHERE Id IN :accountIds
        OR Delphi_Net_subscription_id__c IN :subscriptionids
        OR Delphi_Net_location_id__c IN :propertyids
        
    ]) {
        if (acc.Delphi_Net_subscription_id__c!=null&&(acc.Delphi_Net_location_id__c==null||acc.Delphi_Net_location_id__c.trim()=='')) {
            subscriptionidtoaccount.put(acc.Delphi_Net_subscription_id__c, acc);
        } else if (acc.Delphi_Net_subscription_id__c!=null&&!subscriptionidtoaccount.containsKey(acc.Delphi_Net_subscription_id__c)) {
            subscriptionidtoaccount.put(acc.Delphi_Net_subscription_id__c, acc);
        }
        if (subscriptionids.contains(acc.Delphi_Net_subscription_id__c))
                parentaccountIds.add(acc.Id);
        if (acc.Delphi_Net_location_id__c!=null)
            propertyidtoaccount.put(acc.Delphi_Net_location_id__c,acc);
        accountidtoaccount.put(acc.Id, acc);
        accountIds.add(acc.Id);
    }
    
    // find Contact records which don't have migration portal auth keys
    Contact[] contacts = new Contact[0];
    for (Contact c:[SELECT Id
        FROM Contact
        WHERE AccountId IN :parentaccountIds
        AND MigrationPortalKey__c=null
    ]) {
        // create migration portal auth keys
        c.MigrationPortalKey__c=EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256',Blob.valueOf((String)c.Id+'ni inc.'))),'UTF-8');
        contacts.add(c);
    }
    // update contacts
    if (contacts.size()>0)
        update contacts;
    
    // find existing MigrationCustomer records associated with found Accounts
    Map<Id, MigrationCustomer__c> accountsWithMigrationCustomersIds = new Map<Id, MigrationCustomer__c>();
    Map<String, MigrationCustomer__c> migrationCustomers = new Map<String, MigrationCustomer__c>();
    Map<Id, MigrationCustomer__c> idToMigrationCustomer = new Map<Id, MigrationCustomer__c>();
    for (MigrationCustomer__c mc:[SELECT Id
            , Name
            , CustomerParentAccount__c
            , ReviewPropertiesAndUsersCompleted__c
            FROM MigrationCustomer__c
            WHERE CustomerParentAccount__c IN :accountIds
            OR Id IN :migrationCustomerIDs
            ORDER BY CreatedDate ASC
    ]) {
        accountsWithMigrationCustomersIds.put(mc.CustomerParentAccount__c, mc);
        idToMigrationCustomer.put(mc.Id, mc);
    }
    
    // find existing MigrationProperty records associated with found Accounts
    // also find MigrationProperty records for the list of property IDs
    Map<Id, MigrationProperty__c> accountsWithMigrationPropertiesIds = new Map<Id, MigrationProperty__c>();
    Map<String, MigrationProperty__c> migrationProperties = new Map<String, MigrationProperty__c>();
    for (MigrationProperty__c mprop:[SELECT Id
            , Name
            , PropertyAccount__c
            , DelphiNetId__c
            FROM MigrationProperty__c 
            WHERE PropertyAccount__c IN :accountIds
            OR DelphiNetId__c IN :propertyids
            ORDER BY CreatedDate ASC
    ]) {
        accountsWithMigrationPropertiesIds.put(mprop.PropertyAccount__c, mprop);
        migrationProperties.put(mprop.DelphiNetId__c, mprop);
    }
    
    // find Account Ids for which there aren't MigrationCustomer records yet, 
    // add new MigrationCustomer records to a map (Account Id as the key)
    // find Account Ids for which there aren't MigrationProperties records yet, 
    // add new MigrationProperty records to a map (Account Id as the key)
    Map<Id, MigrationProperty__c> newMigrationProperties = new Map<Id, MigrationProperty__c>();
    Map<Id, MigrationCustomer__c> newMigrationCustomers = new Map<Id, MigrationCustomer__c>();
    Map<Id, Id> propertyaccountidtoparentaccountid = new Map<Id, Id>();
    for (Integer i=0;i<trigger.new.size();i++) {
        MigrationEndUser__c meu=trigger.new[i];
        
        if (meu.SubscriptionID__c!=null&&subscriptionidtoaccount.containsKey(meu.SubscriptionID__c)) 
            meu.MigrationCustomerParentAccount__c=subscriptionidtoaccount.get(meu.SubscriptionID__c).Id;
        if (meu.PropertyID__c!=null)
            if (migrationProperties.containsKey(meu.PropertyID__c)) {
                meu.MigrationProperty__c=migrationProperties.get(meu.PropertyID__c).Id;
                meu.PropertyAccount__c=migrationProperties.get(meu.PropertyID__c).PropertyAccount__c;
            } else if (propertyidtoaccount.containsKey(meu.PropertyID__c))
                meu.PropertyAccount__c=propertyidtoaccount.get(meu.PropertyID__c).Id;
        if (meu.MigrationCustomerParentAccount__c!=null)
            if (
                    (!accountsWithMigrationCustomersIds.containsKey(meu.MigrationCustomerParentAccount__c))
                    &&(!newMigrationCustomers.containsKey(meu.MigrationCustomerParentAccount__c))
            ) 
                newMigrationCustomers.put(meu.MigrationCustomerParentAccount__c
                        , new MigrationCustomer__c(
                            CustomerParentAccount__c=meu.MigrationCustomerParentAccount__c
                            , Name = accountidtoaccount.get(meu.MigrationCustomerParentAccount__c).Name
                        )
                );
        if (meu.PropertyAccount__c!=null&&meu.MigrationCustomerParentAccount__c!=null)
            if (
                    (!accountsWithMigrationPropertiesIds.containsKey(meu.PropertyAccount__c))
                    &&(!newMigrationProperties.containsKey(meu.PropertyAccount__c))
                    &&(meu.MigrationProperty__c==null)
            ) {
                String delphipropertyid = (accountidtoaccount.get(meu.PropertyAccount__c).Delphi_Net_location_id__c!=null)
                            ? accountidtoaccount.get(meu.PropertyAccount__c).Delphi_Net_location_id__c
                            : meu.PropertyId__c;
                Account acc = accountidtoaccount.get(meu.PropertyAccount__c);
                newMigrationProperties.put(meu.PropertyAccount__c
                    , new MigrationProperty__c(
                            PropertyAccount__c=meu.PropertyAccount__c
                            , Name = acc.Name
                            , DelphiNetId__c = delphipropertyid
                            , City__c = (acc.ShippingCity!=null)?acc.ShippingCity:acc.BillingCity
                            , State__c = (acc.ShippingState!=null)?acc.ShippingState:acc.BillingState
                            , StreetAddress__c = (acc.ShippingStreet!=null)?acc.ShippingStreet:acc.BillingStreet
                            , Zip__c = (acc.ShippingPostalCode!=null)?acc.ShippingPostalCode:acc.BillingPostalCode
                    )
                );
                propertyaccountidtoparentaccountid.put(meu.PropertyAccount__c, meu.MigrationCustomerParentAccount__c);
            }
    }
    
    // insert new MigrationCustomer records
    MigrationCustomer__c[] migrationCustomersToInsert = new MigrationCustomer__c[0];
    for (Id accid:newMigrationCustomers.keySet())
        migrationCustomersToInsert.add(newMigrationCustomers.get(accid));
        
    if (migrationCustomersToInsert.size()>0) 
        insert migrationCustomersToInsert;
    
    //insert new MigrationProperty records
    MigrationProperty__c[] migrationPropertiesToInsert = new MigrationProperty__c[0];
    for (Id accid:newMigrationProperties.keySet()) {
        Id parentaccid = propertyaccountidtoparentaccountid.get(accid);
        Id migrationcustomerid;
        if (parentaccid!=null) {
            if (newMigrationCustomers.containsKey(parentaccid))
                migrationcustomerid=newMigrationCustomers.get(parentaccid).Id;
            else if (accountsWithMigrationCustomersIds.containsKey(parentaccid))
                migrationcustomerid=accountsWithMigrationCustomersIds.get(parentaccid).Id;
        }
        newMigrationProperties.get(accid).MigrationCustomer__c=migrationcustomerid;
        migrationPropertiesToInsert.add(newMigrationProperties.get(accid));
    }
        
    insert migrationPropertiesToInsert;
    
    for (Integer i=0;i<trigger.new.size();i++) {
        MigrationEndUser__c meu=trigger.new[i];
        
        if (meu.MigrationCustomerParentAccount__c!=null)
            if (newMigrationCustomers.containsKey(meu.MigrationCustomerParentAccount__c))
                meu.MigrationCustomer__c=newMigrationCustomers.get(meu.MigrationCustomerParentAccount__c).Id;
            else if (accountsWithMigrationCustomersIds.containsKey(meu.MigrationCustomerParentAccount__c))
                meu.MigrationCustomer__c=accountsWithMigrationCustomersIds.get(meu.MigrationCustomerParentAccount__c).Id;
        if (meu.PropertyAccount__c!=null)
            if (newMigrationProperties.containsKey(meu.PropertyAccount__c))
                meu.MigrationProperty__c=newMigrationProperties.get(meu.PropertyAccount__c).Id;
            else if (accountsWithMigrationPropertiesIds.containsKey(meu.PropertyAccount__c))
                meu.MigrationProperty__c=accountsWithMigrationPropertiesIds.get(meu.PropertyAccount__c).Id;
        if (meu.MigrationCustomer__c!=null && idToMigrationCustomer.containsKey(meu.MigrationCustomer__c)) {
            meu.ReviewUsersStepCompleted__c = idToMigrationCustomer.get(meu.MigrationCustomer__c).ReviewPropertiesAndUsersCompleted__c;
        } else meu.ReviewUsersStepCompleted__c=false;
    }
}