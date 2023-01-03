/************************************************************************************************
Name            : NI_ICEUser_TriggerHandler Class
Author          : Sean Harris
Created Date    : 02/26/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_ICEUser__c Object
                : 
                : 
*************************************************************************************************/
public class NI_ICEUser_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NI_ICEUser_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<ICEUser__c> newTrigger)
    {
    
        // ASSOCIATE ALL USERS TO A SUBSCRIPTION ====================================================================================
        Set<Decimal> setSubIds = new Set<Decimal>();
    
        for (ICEUser__c iceUsrs : newTrigger) 
        {
            setSubIds.Add(iceUsrs.SubscriptionID__c);
        }
    
        for (ICESubscription__c subs : [SELECT Id, SubscriptionID__c FROM ICESubscription__c WHERE SubscriptionID__c IN : setSubIds])
        {
            for (ICEUser__c usrs : newTrigger)
            {
                if (usrs.SubscriptionID__c == subs.SubscriptionID__c)
                {
                    usrs.ICESubscriptionId__c = subs.Id;
                }
            }
        }
        
        // ASSOCIATE ALL USERS TO A PROPERTY ========================================================================================
        Set<Decimal> setPrpIds = new Set<Decimal>();
    
        for (ICEUser__c iceUsrs : newTrigger) 
        {
            setPrpIds.Add(iceUsrs.DefaultPropertyId__c);
        }
    
        for (ICEProperty__c prps : [SELECT Id, PropertyId__c FROM ICEProperty__c WHERE PropertyId__c IN : setPrpIds])
        {
            for (ICEUser__c usrs : newTrigger)
            {
                if (usrs.DefaultPropertyId__c == prps.PropertyId__c)
                {
                    usrs.ICEPropertyId__c = prps.Id;
                }
            }
        }
        
        // DEFAULT SelectedForMigration__c TO DELPHI.NET ACTIVE STATUS 
        for (ICEUser__c usrs : newTrigger)
        {
            usrs.SelectedForMigration__c = usrs.DelphiNetIsActive__c; 
        }
                             
    }
    
    public void OnBeforeUpdate(List<ICEUser__c> newTrigger)
    {
        
    }

    public void OnBeforeDelete(List<ICEUser__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<ICEUser__c> newTrigger)
    {

    }
    
    public void OnAfterUpdate(List<ICEUser__c> newTrigger)
    {      

    } 
        
    public void OnAfterDelete(List<ICEUser__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<ICEUser__c> newTrigger)
    {
        
    }    
    
}