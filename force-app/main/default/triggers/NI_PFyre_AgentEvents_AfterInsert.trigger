/****************************************************************************************
Name            : NI_PFyre_AgentEvents_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 4/1/2013
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_PFyre_AgentEvents_AfterInsert on NI_PFyre_AgentEvents__c (after insert) 
{
    
    NI_PFyre_AgentEvents_TriggerHandler handler = new NI_PFyre_AgentEvents_TriggerHandler(true);
    handler.OnAfterInsert(Trigger.new);
    
}