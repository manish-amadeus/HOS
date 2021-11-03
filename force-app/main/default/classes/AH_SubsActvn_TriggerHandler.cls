/************************************************************************************************
Name            : AH_SubsActvn_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 08/31/2017
Last Mod Date   : 04/04/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023777
Description     : Class that handles all trigger code for the Subscription_Activation__c Object
                : Updated 04/04/2021 per NICC-049463
                : Updated 06/26/2018 per NICC-028487
                : Updated on 09/26/2017 per NICC-024063
                : 
*************************************************************************************************/
public class AH_SubsActvn_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c ffaTriggers {get; set;}
    
    public AH_SubsActvn_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_SubsActvn_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();   
        
        system.debug(' *** EXITING AH_SubsActvn_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
                  
    }
    
    // ======================================================================================================================== 
    //  ENTRY METHODS 
    // ========================================================================================================================     
    public void OnBeforeInsert(List<Subscription_Activation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
    	
        if (!ffaTriggers.Bypass_Subscription_Activation__c)
        {
            Update_PartnerAccount(newTrigger);
            Update_CustomerContact(newTrigger);
            Update_NotesToPartners(newTrigger);
        }
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterInsert(List<Subscription_Activation__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!ffaTriggers.Bypass_Subscription_Activation__c)
        {
            // LIST TO HOLD THE SUBSCRIPTION ACTIVATION RECORDS WHERE THE PARTNER NAME HAS 
            List<Subscription_Activation__c> lstSubActivationsWithPartnerNames = new List<Subscription_Activation__c>();
            
            // LOOP THROUGH THE LIST OF UPDATED SUBSCRIPTION ACTIVATION RECORDS TO FIND THE RECORDS WHERE THE PARTNER NAME FIELD IS NOT NULL
            for (Subscription_Activation__c sa : newTrigger) 
            {             
                if (sa.Partner_Name__c != null) 
                {
                    lstSubActivationsWithPartnerNames.add(sa);
                }
                
            }
            
            if (lstSubActivationsWithPartnerNames.size() > 0)
            {     
                Partner_Community_User_Share(lstSubActivationsWithPartnerNames);
            }  
        }
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<Subscription_Activation__c> newTrigger, Map<Id, Subscription_Activation__c> oldMapTrigger)
    {    
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!ffaTriggers.Bypass_Subscription_Activation__c)
        {
            // LIST TO HOLD THE SUBSCRIPTION ACTIVATION RECORDS WHERE THE PARTNER NAME HAS CHANGED
            List<Subscription_Activation__c> lstPartnerNameChanges = new List<Subscription_Activation__c>();
            
            // LOOP THROUGH THE LIST OF UPDATED SUBSCRIPTION ACTIVATION RECORDS TO FIND THE RECORDS WHERE THE PARTNER NAME FIELD HAS BEEN UPDATED
            for (Subscription_Activation__c sa : newTrigger) 
            {
                Subscription_Activation__c oldSa = oldMapTrigger.get(sa.Id);            
                
                if ((sa.Partner_Name__c != null && sa.Partner_Name__c != oldSa.Partner_Name__c) || (sa.Partner_Name__c == null)) 
                {
                    lstPartnerNameChanges.add(sa);
                }
                
            }
            
            if (lstPartnerNameChanges.size() > 0)
            {     
                Partner_Community_User_Share(lstPartnerNameChanges);
            }
        }
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    } 
    
    
    // ======================================================================================================================== 
    //  HANDLER METHODS & FUNCTIONS 
    // ======================================================================================================================== 
    public void Update_PartnerAccount(List<Subscription_Activation__c> newTrigger)
    {
        
        // THIS METHOD UPDATES THE PARTNER ACCOUNT LOOKUP FIELD
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.Update_PartnerAccount() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // SET TO HOLD THE SUBSCRIPTION ACTIVATION IDs 
        Set<Id> setSubActivationIds = new Set<Id>();
        
        // SET TO HOLD THE VALUES FROM THE PRODUCT ID   
        Set<String> setOppProductIds = new Set<String>();  
        
        for (Subscription_Activation__c sa : newTrigger) 
        {
            setSubActivationIds.add(sa.Id);
            setOppProductIds.add(sa.Product_ID__c);
        }

        // MAP TO HOLD THE PRODUCT LOOKUP INFORMATION  
        Map<Id, OpportunityLineItem> mapOppLineItems = new Map<Id, OpportunityLineItem>([SELECT oli.Id, oli.PricebookEntry.Product2.Partner_Name__c 
                                                                                         FROM OpportunityLineItem oli
                                                                                         WHERE oli.Id IN : setOppProductIds]);

        for (Subscription_Activation__c subAct : newTrigger) 
        {
            if(mapOppLineItems.containsKey(subAct.Product_ID__c)) //ADDED 04/04/2021 PER NICC-049463
            {
            if (mapOppLineItems.get(subAct.Product_ID__c).PricebookEntry.Product2.Partner_Name__c != null)
            {
                subAct.Partner_Name__c = mapOppLineItems.get(subAct.Product_ID__c).PricebookEntry.Product2.Partner_Name__c;
            }    
        }
        }  
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.Update_PartnerAccount() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void Update_CustomerContact(List<Subscription_Activation__c> newTrigger)
    {
        
        // THIS METHOD UPDATES THE CUSTOMER CONTACT LOOKUP FIELD
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.Update_CustomerContact() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // SET TO HOLD THE OPPORTUNITY IDs 
        Set<Id> setOppIds = new Set<Id>();
        
        for (Subscription_Activation__c s : newTrigger)
        {
            setOppIds.add(s.Opportunity__c);   
        }
        
        // LIST TO HOLD THE CONTACTS RELATED TO THE OPPORTUNITY
        List<OpportunityContactRole> lstContactRoles = [SELECT Role, Contact.Id, OpportunityId 
                                                        FROM OpportunityContactRole 
                                                        WHERE OpportunityId IN : setOppIds
                                                        AND Role = 'Customer Project Contact'];
        
        if (lstContactRoles.size() > 0)
        {
            
            // MAP TO HOLD OPPORTUNITY ID AND CONTACT FROM THE CONTACT ROLE ON THE OPPORTUNITY RELATED TO THE SUBSCRIPTION ACTIVATION RECORD
            Map<Id, Id> mapOppContacts = new Map<Id, Id>();
            
            for (OpportunityContactRole c : lstContactRoles)
            {
                mapOppContacts.put(c.OpportunityId,c.Contact.Id);  
            }
            
            for (Subscription_Activation__c subAct : newTrigger) 
            {
                if (mapOppContacts.get(subAct.Opportunity__c) != null)
                {
                    subAct.Customer_Contact__c = mapOppContacts.get(subAct.Opportunity__c);
                }    
            }        
        }
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.Update_CustomerContact() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void Update_NotesToPartners(List<Subscription_Activation__c> newTrigger)
    {
        
        // THIS METHOD UPDATES THE NOTES TO PARTNERS FIELD
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.Update_NotesToPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // SET TO HOLD THE OPPORTUNITY IDs 
        Set<Id> setOppIds = new Set<Id>();
        
        for (Subscription_Activation__c s : newTrigger)
        {
            setOppIds.add(s.Opportunity__c);   
        }
        
        // MAP TO HOLD THE OPPORTUNITIES RELATED TO THE SUBSCRIPTION ACTIVATIONS
        Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>([SELECT Id, Notes_to_Partners__c FROM Opportunity WHERE Id IN : setOppIds]);
        
        if (mapOpps.size() > 0)
        {               
            for (Subscription_Activation__c subAct : newTrigger) 
            {
                if (mapOpps.get(subAct.Opportunity__c) != null)
                {
                    subAct.Notes_to_Partners__c = mapOpps.get(subAct.Opportunity__c).Notes_to_Partners__c;
                }    
            }        
        }
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.Update_NotesToPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }      
    
    public void Partner_Community_User_Share(List<Subscription_Activation__c> newTrigger)
    {      
        
        // PARTNER COMMUNITY USER SHARE
        
        system.debug(' *** ENTERING AH_Product_Migration_TriggerHandler.Partner_Community_User_Share() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // ADDED PER NICC-024063
        // LIST TO HOLD THE PROFILES FROM THE "AH Partner Community Record Share Detail" CUSTOM SETTING  
        List<AH_Partner_Community_Record_Share__c> lstCS = AH_Partner_Community_Record_Share__c.getAll().values();
        
        Set<Id> setProfileIds = new Set<Id>();
        
        if (lstCS.size() > 0)
        {     
            
            Set<String> setProfileNames = new Set<String>();

            for (AH_Partner_Community_Record_Share__c cs : lstCS)    
            {
                setProfileNames.add(cs.Name);
            }    
            
            List<Profile> lstProfiles = [SELECT Id, Name FROM Profile WHERE Name IN : setProfileNames];
            
            for (Profile p : lstProfiles)
            {
                setProfileIds.add(p.Id);   
            }
            
        }
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<Subscription_Activation__Share> lstSharesToRemove = new List<Subscription_Activation__Share>([
            SELECT Id 
            FROM Subscription_Activation__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Partner_Community_User_Share__c']);
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    system.debug(' **** SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    system.debug(' **** ' + err.getMessage());
                }
            }        
        }
        
        // CODE THAT INSERTS THE NEW SHARE RECORDS
        List<User> lsPartnerUsersToInsert = new List<User>();
        
        Set<Id> setPartnerAccountIds = new Set<Id>();
        
        for (Subscription_Activation__c sa : newTrigger)
        {
            if (sa.Partner_Name__c != null)
            {
                setPartnerAccountIds.add(sa.Partner_Name__c);
            }  
        }
        
        // LIST OF PARTNER USERS THAT NEED TO BE GRANTED ACCESS TO THE SUBSCRIPTION ACTIVATION RECORDS
        lsPartnerUsersToInsert = [SELECT Id, AccountId 
                                  FROM User 
                                  WHERE IsActive = true
                                  AND AccountId IN : setPartnerAccountIds
                                  AND ProfileId IN : setProfileIds];
        
        // LIST OF SHARES THAT NEED TO BE ADDED   
        List<Subscription_Activation__Share> lstSharesToInsert = new List<Subscription_Activation__Share>();
        
        for (Subscription_Activation__c sActivation : newTrigger)
        {
            for (User pUser : lsPartnerUsersToInsert)
            {
                if (sActivation.Partner_Name__c == pUser.AccountId)
                {
                    Subscription_Activation__Share saShare = new Subscription_Activation__Share();
                    saShare.ParentId = sActivation.Id;
                    saShare.UserOrGroupId = pUser.Id;
                    saShare.AccessLevel = 'Edit';
                    saShare.RowCause = Schema.Subscription_Activation__Share.RowCause.Partner_Community_User_Share__c;
                    lstSharesToInsert.add(saShare);
                }                
            }
        }
        
        // USE DATABASE DML METHOD TO ADD THE SHARES
        if (lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert,true);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    system.debug(' **** ' + err.getMessage());
                }
            }
        }
        
        system.debug(' *** EXITING AH_Product_Migration_TriggerHandler.Partner_Community_User_Share() - QUERIES ISSUED = ' + Limits.getQueries());
        
    } 

    
}