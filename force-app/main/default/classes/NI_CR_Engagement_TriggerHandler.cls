/************************************************************************************************
Name            : NI_CR_Engagement_TriggerHandler Class
Author          : Sean Harris
Created Date    : 04/08/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Customer_Relations_Engagement__c Object
                : 
                : 
*************************************************************************************************/
public with sharing class NI_CR_Engagement_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NI_CR_Engagement_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('NI CR ENGAGEMENT'))
        {
            processDI(newTrigger, null); 
        }
    }
    
    public void OnBeforeUpdate(List<NI_Customer_Relations_Engagement__c> newTrigger, Map<Id, NI_Customer_Relations_Engagement__c> oldMapTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('NI CR ENGAGEMENT'))
        {            
            processDI(newTrigger, oldMapTrigger); 
        }        
    }

    public void OnBeforeDelete(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        if (!NI_FUNCTIONS.bypassTriggerCode('NI CR ENGAGEMENT'))
        {
            updateOpenCustomerRelationsEngagement(newTrigger); 
            updateOpenCREngagement_Contact(newTrigger); 
        }
    }
    
    public void OnAfterUpdate(List<NI_Customer_Relations_Engagement__c> newTrigger, Map<Id, NI_Customer_Relations_Engagement__c> oldMapTrigger)
    { 
        if (!NI_FUNCTIONS.bypassTriggerCode('NI CR ENGAGEMENT'))
        {        
            updateChangedAccounts(newTrigger, oldMapTrigger); 
            updateOpenCustomerRelationsEngagement(newTrigger); 
            updateChangedContact(newTrigger, oldMapTrigger); 
            updateOpenCREngagement_Contact(newTrigger); 
        }
    } 
        
    public void OnAfterDelete(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        
    }

    // =================================================================================================== //
    // HANDLER FUNCTIONS                                                                                   //
    // =================================================================================================== //
    
    // ACCOUNT RELATED FUNCTIONS ===========================================================================
    private void updateOpenCustomerRelationsEngagement(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        // SET OF RELATED ACCOUNT IDS
        Set<Id> setAccts = new Set<Id>();
        // POPULATE SET OF RELATED ACCOUNT IDS
        for (NI_Customer_Relations_Engagement__c cre : newTrigger)
        {
            setAccts.Add(cre.Account__c);
        }
        // FILL LIST OF RELATED ACCOUNTS
        List<Account> lstAccts = new List<Account>([SELECT Id, Open_Customer_Relations_Engagement__c FROM Account WHERE Id IN : setAccts]);
        
        // LOOP THOUGH EACH CRE RECORD THEN RELATED ACCOUNTS TO EVALUATE IF THE ACCOUNT Open_Customer_Relations_Engagement__c NEEDS TO BE CHECKED
        for (NI_Customer_Relations_Engagement__c e : newTrigger)
        {
            for (Account a : lstAccts)
            {
                if (e.Account__c == a.Id)
                {
                    if (e.Status__c.startsWith('Closed'))
                    {
                        a.Open_Customer_Relations_Engagement__c = false;
                    }
                    else
                    {
                        a.Open_Customer_Relations_Engagement__c = true;
                    }
                }
            }
        }
        // UPDATE ACCOUNTS 
        Database.update(lstAccts); 
    }

    private void updateChangedAccounts(List<NI_Customer_Relations_Engagement__c> newTrigger, Map<Id, NI_Customer_Relations_Engagement__c> oldMapTrigger)
    {
        // SET OF RELATED ACCOUNT IDS
        Set<Id> setAccts = new Set<Id>();
        // POPULATE SET OF RELATED ACCOUNT IDS
        for (NI_Customer_Relations_Engagement__c cre : newTrigger)
        {
            NI_Customer_Relations_Engagement__c oldCRE = oldMapTrigger.get(cre.Id);            
            if (cre.Account__c != oldCRE.Account__c)
            {
                system.debug('================= NO MATCH =========================   ' + cre.Account__c + ',   ' + oldCRE.Account__c);
                setAccts.Add(oldCRE.Account__c);
            }            
        }
        // LIST OF ACCOUNTS TO UPDATE
        List<Account> lstAccts = new List<Account>();
        // LOOP THOUGH EACH ACCOUNT AND UNCHECK Open_Customer_Relations_Engagement__c 
        for (Account a : [SELECT Id, Open_Customer_Relations_Engagement__c FROM Account WHERE Id IN : setAccts])
        {
            //system.debug('=================   ' + a.Open_Customer_Relations_Engagement__c);
            a.Open_Customer_Relations_Engagement__c = false;
            lstAccts.Add(a);
        }
        // UPDATE ACCOUNTS 
        Database.SaveResult[] srList = Database.update(lstAccts, false); 
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) 
        {
            if (sr.isSuccess()) 
            {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated record.  ID: ' + sr.getId());
            }
            else 
            {
                // Operation failed, so get all errors                
                for (Database.Error err : sr.getErrors()) 
                {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }        
        
    }

    // CONTACT RELATED FUNCTIONS ===========================================================================
    private void updateOpenCREngagement_Contact(List<NI_Customer_Relations_Engagement__c> newTrigger)
    {
        // SET OF RELATED ACCOUNT IDS
        Set<Id> setCncts = new Set<Id>();
        // POPULATE SET OF RELATED ACCOUNT IDS
        for (NI_Customer_Relations_Engagement__c cre : newTrigger)
        {
            setCncts.Add(cre.Engagement_Contact__c);
        }
        // FILL LIST OF RELATED ACCOUNTS
        List<Contact> lstCncts = new List<Contact>([SELECT Id, Open_Customer_Relations_Engagement__c FROM Contact WHERE Id IN : setCncts]);
        
        // LOOP THOUGH EACH CRE RECORD THEN RELATED ACCOUNTS TO EVALUATE IF THE ACCOUNT Open_Customer_Relations_Engagement__c NEEDS TO BE CHECKED
        for (NI_Customer_Relations_Engagement__c e : newTrigger)
        {
            for (Contact c : lstCncts)
            {
                if (e.Engagement_Contact__c == c.Id)
                {
                    if (e.Status__c.startsWith('Closed'))
                    {
                        c.Open_Customer_Relations_Engagement__c = false;
                    }
                    else
                    {
                        c.Open_Customer_Relations_Engagement__c = true;
                    }
                }
            }
        }
        // UPDATE ACCOUNTS 
        Database.update(lstCncts); 
    }

    private void updateChangedContact(List<NI_Customer_Relations_Engagement__c> newTrigger, Map<Id, NI_Customer_Relations_Engagement__c> oldMapTrigger)
    {
        // SET OF RELATED ACCOUNT IDS
        Set<Id> setCncts = new Set<Id>();
        // POPULATE SET OF RELATED ACCOUNT IDS
        for (NI_Customer_Relations_Engagement__c cre : newTrigger)
        {
            NI_Customer_Relations_Engagement__c oldCRE = oldMapTrigger.get(cre.Id);            
            if (cre.Engagement_Contact__c != oldCRE.Engagement_Contact__c)
            {
                setCncts.Add(oldCRE.Engagement_Contact__c);
            }            
        }
        // LIST OF ACCOUNTS TO UPDATE
        List<Contact> lstCncts = new List<Contact>();
        // LOOP THOUGH EACH ACCOUNT AND UNCHECK Open_Customer_Relations_Engagement__c 
        for (Contact c : [SELECT Id, Open_Customer_Relations_Engagement__c FROM Contact WHERE Id IN : setCncts])
        {
            c.Open_Customer_Relations_Engagement__c = false;
            lstCncts.Add(c);
        }
        // UPDATE ACCOUNTS 
        Database.SaveResult[] srList = Database.update(lstCncts, false); 
        
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) 
        {
            if (sr.isSuccess()) 
            {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated record.  ID: ' + sr.getId());
            }
            else 
            {
                // Operation failed, so get all errors                
                for (Database.Error err : sr.getErrors()) 
                {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }        
        
    }
    
    // DEPLOYMENT INSTANCE RELATED FUNCTIONS ===============================================================================================
    private void processDI(List<NI_Customer_Relations_Engagement__c> newTrigger, Map<Id, NI_Customer_Relations_Engagement__c> oldMapTrigger)
    {
        
        // SET OF RELATED ACCOUNT IDS
        Set<Id> setDIs = new Set<Id>();
      
        // POPULATE SET OF RELATED ACCOUNT IDS
        for (NI_Customer_Relations_Engagement__c cre : newTrigger)
        {           
            if (oldMapTrigger != null)
            {                 
                NI_Customer_Relations_Engagement__c oldCRE = oldMapTrigger.get(cre.Id); 
                
                if (cre.Asset__c != oldCRE.Asset__c)
                {
                    if (cre.Asset__c != null)
                    {
                        setDIs.Add(cre.Asset__c);
                    }
                }
            }
            else
            {
                // THIS CONDITION IS MET WHEN Null oldMapTrigger VALUE IS PASSED FOR INSERTED CRE RECORDS
                setDIs.Add(cre.Asset__c);           
            }
        }
      
        if (setDIs.Size() != 0)
        {
            Map<Id, Id> mapDHIs = NI_FUNCTIONS.getLatestDIHistoryIDMap(setDIs);    
            for (NI_Customer_Relations_Engagement__c x : newTrigger)
            {           
                if (mapDHIs.get(x.Asset__c) != null)
                {    
                    x.Deployment_Instance_History_Record__c = mapDHIs.get(x.Asset__c);
                }
            }
        }
    }
    
}