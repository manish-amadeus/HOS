/************************************************************************************************
Name            : NI_ICEProperty_TriggerHandler Class
Author          : Sean Harris
Created Date    : 02/26/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_ICEProperty__c Object
                : 
                : 
*************************************************************************************************/
public class NI_ICEProperty_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NI_ICEProperty_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<ICEProperty__c> newTrigger)
    {
    
        Set<Decimal> setSubIds = new Set<Decimal>();
    
        for (ICEProperty__c icePrps : newTrigger) 
        {
            setSubIds.Add(icePrps.SubscriptionID__c);
        }
    
        for (ICESubscription__c subs : [SELECT Id, SubscriptionID__c FROM ICESubscription__c WHERE SubscriptionID__c IN : setSubIds])
        {
            for (ICEProperty__c prps : newTrigger)
            {
                if (prps.SubscriptionID__c == subs.SubscriptionID__c)
                {
                    prps.ICESubscriptionId__c = subs.Id;
                }
            }
        }
        
        // DEFAULT SelectedForMigration__c TO DELPHI.NET ACTIVE STATUS 
        for (ICEProperty__c prps : newTrigger)
        {
            prps.SelectedForMigration__c = prps.DelphiNetIsActive__c; 
        }
                    
    }
    
    public void OnBeforeUpdate(List<ICEProperty__c> newTrigger)
    {
        
    }

    public void OnBeforeDelete(List<ICEProperty__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<ICEProperty__c> newTrigger)
    {

    }
    
    public void OnAfterUpdate(List<ICEProperty__c> newTrigger)
    {      

    } 
        
    public void OnAfterDelete(List<ICEProperty__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<ICEProperty__c> newTrigger)
    {
        
    }    
    
}