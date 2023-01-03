/************************************************************************************************
Name            : AH_SubsActvnTrans_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 09/07/2017
Last Mod Date   : 04/08/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-023846
Description     : Class that handles all trigger code for the 
                : Subscription_Activation_Transaction__c Object
                : UPDATED 04/08/2019 per NICC-033935
                : 
*************************************************************************************************/
public class AH_SubsActvnTrans_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c ffaTriggers {get; set;}
    
    public AH_SubsActvnTrans_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_SubsActvnTrans_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();   
        
        system.debug(' *** EXITING AH_SubsActvnTrans_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================== 
    //  ENTRY METHODS 
    // ========================================================================================================================  
    public void OnBeforeInsert(List<Subscription_Activation_Transaction__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_SubsActvnTrans_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
    
        if (!ffaTriggers.Bypass_SubscriptionActivationTransaction__c)
        {
            Update_RelatedAccount(newTrigger);
            syncLiveDates2ProdMigrations(newTrigger, null);
        }
        
        system.debug(' *** EXITING AH_SubsActvnTrans_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<Subscription_Activation_Transaction__c> newTrigger, Map<Id, Subscription_Activation_Transaction__c> oldMapTrigger)
    { 
        
        system.debug(' *** ENTERING AH_SubsActvnTrans_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!ffaTriggers.Bypass_SubscriptionActivationTransaction__c)
        {
            syncLiveDates2ProdMigrations(newTrigger, oldMapTrigger);
        }
        
        system.debug(' *** EXITING AH_SubsActvnTrans_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================== 
    //  HANDLER METHODS & FUNCTIONS 
    // ========================================================================================================================     
    public void Update_RelatedAccount(List<Subscription_Activation_Transaction__c> newTrigger)
    {
        
        // THIS METHOD UPDATES THE RELATED ACCOUNT FIELD
        
        system.debug(' *** ENTERING AH_SubsActvnTrans_TriggerHandler.Update_RelatedAccount() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> setSubActivationIds = new Set<Id>();
        Set<Id> setRelatedAccountIds = new Set<Id>();
        
        for (Subscription_Activation_Transaction__c satNew : newTrigger)
        {
            setSubActivationIds.add(satNew.Subscription_Activation_No__c);
            setRelatedAccountIds.add(satNew.Related_Account__c);
        }
        
        //MAP TO HOLD THE FIELD VALUES OF THE SUBSCRIPTION ACTIVATION RECORDS RELATED TO SUBSCRIPTION ACTIVATION TRANSACTION RECORDS
        Map<Id, Subscription_Activation__c> mapSubscriptionActivation = new Map<Id, Subscription_Activation__c>(
            [SELECT Id, Account__c, Account__r.Name FROM Subscription_Activation__c WHERE Id IN : setSubActivationIds]);
        
        //MAP TO HOLD THE RELATED ACCOUNT OF THE SUBSCRIPTION ACTIVATION TRANSACTION RECORDS
        Map<Id, Account> mapRelatedAccounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: setRelatedAccountIds]);
        
        
/*        
        //IF THE SUBSCRIPTION ACTIVATION TRANSACTION RECORD BEING INSERTED HAS THE RELATED ACCOUNT FIELD POPULATED, THEN POPULATE THE RELATED ACCOUNT PARTNER UPDATE FIELD
        //WITH THE NAME OF THE RELATED ACCOUNT
        if (mapRelatedAccounts.size() > 0)
        {
            for (Subscription_Activation_Transaction__c s : newTrigger) 
            {              
                if (s.Related_Account__c != null && mapRelatedAccounts.get(s.Related_Account__c).Name != null && s.Related_Account_Partner_Updated__c == null)
                {
                    s.Related_Account_Partner_Updated__c = mapRelatedAccounts.get(s.Related_Account__c).Name;
                } 
            } 
        } 
*/        
        //IF THE TRANSACTION RECORD BEING INSERTED DOES NOT HAVE THE RELATED ACCOUNT FIELD POPULATED, USE THE ACCOUNT VALUE FROM THE RELATED SUBSCRIPTION ACTIVATION RECORD
        if (mapSubscriptionActivation.size() > 0)
        {
            for (Subscription_Activation_Transaction__c sat : newTrigger) 
            {
                if (mapSubscriptionActivation.get(sat.Subscription_Activation_No__c).Account__c != null && sat.Related_Account__c == null)
                {
                    System.debug('SUBSCRIPTION ACTIVATION TRANSACTION RELATED ACCOUNT: ' + sat.Subscription_Activation_No__r.Account__c);   
                    sat.Related_Account__c = mapSubscriptionActivation.get(sat.Subscription_Activation_No__c).Account__c;
//                    if (sat.Related_Account_Partner_Updated__c == null)
//                    {
//                        sat.Related_Account_Partner_Updated__c = mapSubscriptionActivation.get(sat.Subscription_Activation_No__c).Account__r.Name;
//                    }
                }
                
            }        
        }

        system.debug(' *** EXITING AH_SubsActvnTrans_TriggerHandler.Update_RelatedAccount() - QUERIES ISSUED = ' + Limits.getQueries());
                
    }      

    public void syncLiveDates2ProdMigrations(List<Subscription_Activation_Transaction__c> newTrigger, Map<Id, Subscription_Activation_Transaction__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_SubsActvnTrans_TriggerHandler.syncLiveDates2ProdMigrations() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setOpportunityIds = new Set<Id>();
        
        for (Subscription_Activation_Transaction__c sa : newTrigger)
        {
            if (sa.Date__c != null)
            {
                if (oldMapTrigger != null)
                {
                    Subscription_Activation_Transaction__c oldSA = oldMapTrigger.get(sa.Id);
                    if (sa.Date__c != oldSA.Date__c)
                    {
                        setAccountIds.add(sa.Related_Account__c);
                        setOpportunityIds.add(sa.Opportunity__c);
                    }                
                }
                else
                {
                    setAccountIds.add(sa.Related_Account__c);
                    setOpportunityIds.add(sa.Opportunity__c);                
                }                
            }
        }
        
        List<AH_Product_Migration__c> lstProdMigrationUpdates = new List<AH_Product_Migration__c>();
        
        for (AH_Product_Migration__c pm : [SELECT Id, Live_Date__c, Account__c, Opportunity__c, To_SKU__c   
                                           FROM AH_Product_Migration__c 
                                           WHERE Opportunity__c IN : setOpportunityIds AND Account__c IN : setAccountIds])
        {
            for (Subscription_Activation_Transaction__c sat : newTrigger)
            {   
                if ((pm.Account__c == sat.Related_Account__c) && (pm.Opportunity__c == sat.Opportunity__c) && (pm.To_SKU__c == sat.Product_Code__c))
                {
                    AH_Product_Migration__c tmpPM = new AH_Product_Migration__c();
                    tmpPM.Id = pm.Id;
                    tmpPM.Live_Date__c = sat.Date__c;
                    lstProdMigrationUpdates.add(tmpPM);
                }
            }
        }
        
        if (!lstProdMigrationUpdates.isEmpty())
        {
        	database.update(lstProdMigrationUpdates);    
        }

        system.debug(' *** EXITING AH_SubsActvnTrans_TriggerHandler.syncLiveDates2ProdMigrations() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}