/************************************************************************************************
Name            : NI_PFyre_AgentEvents_TriggerHandler Class
Author          : Sean Harris
Created Date    : 4/1/2013
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_PFyre_AgentEvents__c Object
                : 
                : 
*************************************************************************************************/
public with sharing class NI_PFyre_AgentEvents_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NI_PFyre_AgentEvents_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<NI_PFyre_AgentEvents__c> newTrigger)
    {

    }
    
    public void OnBeforeUpdate(List<NI_PFyre_AgentEvents__c> newTrigger)
    {
        
    }

    public void OnBeforeDelete(List<NI_PFyre_AgentEvents__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<NI_PFyre_AgentEvents__c> newTrigger)
    {
       
        Set<String> setAgentIds = new Set<String>();
        Map<String, Id> mapUser2Agent = new Map<String, Id>();
        List<NI_PFyre_AgentEvents__c> lstUpdate = new List<NI_PFyre_AgentEvents__c>();
        
        // GET A UNIQUE LIST OF AGENT IDS
        for (NI_PFyre_AgentEvents__c evnts : newTrigger)
        {
           setAgentIds.add(evnts.FKAgent__c); 
        }
     
        for (User u : [SELECT Id, PrairieFyreUserId__c FROM User WHERE PrairieFyreUserId__c IN : setAgentIds])
        {
            mapUser2Agent.put(u.PrairieFyreUserId__c, u.Id); 
        }
         
        for (NI_PFyre_AgentEvents__c e : [SELECT FKAgent__c FROM NI_PFyre_AgentEvents__c WHERE Id IN : newTrigger])
        {
            e.Saleforce_User__c = mapUser2Agent.get(e.FKAgent__c);
            lstUpdate.add(e);
        }

        Database.Update(lstUpdate);        

    }
    
    public void OnAfterUpdate(List<NI_PFyre_AgentEvents__c> newTrigger)
    {      

    } 
        
    public void OnAfterDelete(List<NI_PFyre_AgentEvents__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<NI_PFyre_AgentEvents__c> newTrigger)
    {
        
    }    
    
}