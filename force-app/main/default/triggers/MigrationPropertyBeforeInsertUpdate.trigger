// This trigger: 
// 1. creates new MigrationCustomer records for Account records
// when a new or updated MigrationProperty record is attached to an Account
// and the Account doesn't have a MigrationCustomer record attached to it
//
// 2. creates migration portal auth keys for Contacts 
// associated with MigrationEndUser records' Accounts
// 
// 3. links MigrationProperty records to MigrationCustomer records, 
// Property Accounts and Parent Accounts

trigger MigrationPropertyBeforeInsertUpdate on MigrationProperty__c (before insert, before update) {
    Set<String> propertyids = new Set<String>();
    Set<String> subscriptionids = new Set<String>();
    Map<String, Account> subscriptionidtoaccount = new Map<String, Account>();
    Map<String, Account> propertyidtoaccount = new Map<String, Account>();
    Set<Id> accountIds = new Set<Id>();
    Set<Id> parentaccountIds = new Set<Id>();
    Map<Id,Account> accountidtoaccount = new Map<Id,Account>();
    
    // collect Account Ids, 
    // property IDs and subscription IDs
    for (MigrationProperty__c mp:trigger.new) {
        if (mp.DelphiNetId__c!=null&&mp.DelphiNetId__c.trim()!='')
            propertyids.add(mp.DelphiNetId__c);
        if (mp.DelphiNetSubscriptionID__c!=null&&mp.DelphiNetSubscriptionID__c.trim()!='')
            subscriptionids.add(mp.DelphiNetSubscriptionID__c);
        
        if (trigger.isInsert) {
            if (mp.DelphiNetStatus__c=='Active') {
                mp.selectedForMigration__c=true;
                mp.Active__c=true;
            }
            else if (mp.DelphiNetStatus__c=='Inactive'){
                mp.selectedForMigration__c=false;
                mp.Active__c=false;
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
    for (MigrationCustomer__c mc:[SELECT Id
            , Name
            , CustomerParentAccount__c
            FROM MigrationCustomer__c
            WHERE CustomerParentAccount__c IN :accountIds
            ORDER BY CreatedDate ASC
    ])
        accountsWithMigrationCustomersIds.put(mc.CustomerParentAccount__c, mc);
        
    // find Account Ids for which there aren't MigrationCustomer records yet, 
    // add new MigrationCustomer records to a map (Account Id as the key)
    // also attach MigrationProperty records to found Accounts by Delphi.Net
    // property ID
    Map<Id, MigrationCustomer__c> newMigrationCustomers = new Map<Id, MigrationCustomer__c>();
    for (MigrationProperty__c mp:trigger.new) {
        if (mp.DelphiNetSubscriptionID__c!=null&&subscriptionidtoaccount.containsKey(mp.DelphiNetSubscriptionID__c)) {
            Id parentaccountid=subscriptionidtoaccount.get(mp.DelphiNetSubscriptionID__c).Id;
            if (
                    (!accountsWithMigrationCustomersIds.containsKey(parentaccountid))
                    &&(!newMigrationCustomers.containsKey(parentaccountid))
            ) 
                newMigrationCustomers.put(parentaccountid
                        , new MigrationCustomer__c(
                            CustomerParentAccount__c=parentaccountid
                            , Name = accountidtoaccount.get(parentaccountid).Name
                        )
                );
        }
        if (mp.PropertyAccount__c==null&&mp.DelphiNetId__c!=null&&propertyidtoaccount.containsKey(mp.DelphiNetId__c)) {
            Account acc=propertyidtoaccount.get(mp.DelphiNetId__c);
            mp.PropertyAccount__c=acc.Id;
            mp.City__c = (acc.ShippingCity!=null)?acc.ShippingCity:acc.BillingCity;
            mp.State__c = (acc.ShippingState!=null)?acc.ShippingState:acc.BillingState;
            mp.StreetAddress__c = (acc.ShippingStreet!=null)?acc.ShippingStreet:acc.BillingStreet;
            mp.Zip__c = (acc.ShippingPostalCode!=null)?acc.ShippingPostalCode:acc.BillingPostalCode;
        }
    }
    // insert new MigrationCustomer records
    MigrationCustomer__c[] migrationCustomersToInsert = new MigrationCustomer__c[0];
    for (Id accid:newMigrationCustomers.keySet())
        migrationCustomersToInsert.add(newMigrationCustomers.get(accid));
    if (migrationCustomersToInsert.size()>0) 
        insert migrationCustomersToInsert;
    
    // attach MigrationProperty records to new or found MigrationCustomer records
    for (MigrationProperty__c mp:trigger.new) {
        if (mp.MigrationCustomer__c==null&&mp.DelphiNetSubscriptionID__c!=null&&subscriptionidtoaccount.containsKey(mp.DelphiNetSubscriptionID__c)) {
            Id parentaccountid=subscriptionidtoaccount.get(mp.DelphiNetSubscriptionID__c).Id;
            if (newMigrationCustomers.containsKey(parentaccountid))
                mp.MigrationCustomer__c=newMigrationCustomers.get(parentaccountid).Id;
            else if (accountsWithMigrationCustomersIds.containsKey(parentaccountid)) 
                mp.MigrationCustomer__c=accountsWithMigrationCustomersIds.get(parentaccountid).Id;
        }
    }
}