/************************************************************************************************
Name            : NI_ICESubscription_TriggerHandler Class
Author          : Sean Harris
Created Date    : 02/26/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_ICESubscription__c Object
                : 
                : 
*************************************************************************************************/
public with sharing class NI_ICESubscription_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NI_ICESubscription_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<ICESubscription__c> newTrigger)
    {
       
    }
    
    public void OnBeforeUpdate(List<ICESubscription__c> newTrigger)
    {
        
    }

    public void OnBeforeDelete(List<ICESubscription__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<ICESubscription__c> newTrigger)
    {
    
        List<ICESubscription__c> lstUpdate = new List<ICESubscription__c>();
    
        for (ICESubscription__c iceSubs : [SELECT Id, MigrationPortalKey__c, ICE_Link__c FROM ICESubscription__c WHERE Id IN : newTrigger]) 
        {
            string strAuthKey = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.generateDigest('SHA-256', Blob.valueOf((String)iceSubs.Id + 'ni inc.'))), 'UTF-8');
            strAuthKey = strAuthKey.Replace(' ', '+');
            iceSubs.MigrationPortalKey__c = strAuthKey;
            //iceSubs.ICE_Link__c = 'https://c.cs17.visual.force.com/apex/NI_ICE_Home?authkey=' + strAuthKey;
            iceSubs.ICE_Link__c = 'http://newmarketinc.force.com/migrationportal/NI_ICE_Home?authkey=' + strAuthKey;
            lstUpdate.add(iceSubs);
        }
        
        Database.Update(lstUpdate);
        
    }
    
    public void OnAfterUpdate(List<ICESubscription__c> newTrigger)
    {      

    } 
        
    public void OnAfterDelete(List<ICESubscription__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<ICESubscription__c> newTrigger)
    {
        
    }    
    
}