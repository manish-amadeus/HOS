/****************************************************************************************
Name            : NI_ProjectBacklog_AfterUpdate
Author          : Prashant Wayal
Created Date    : 12/4/2015
Last Mod Date   : 12/22/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016293
Description     : 
                : 
******************************************************************************************/
trigger NI_ProjectBacklog_AfterUpdate on NI_Project_Backlog__c (after update) 
{
    
    if (!NI_FUNCTIONS.bypassTriggerCode('NI PROJECT BACKLOG'))
    {
        NI_ProjectBacklog_TriggerHandler handler = new NI_ProjectBacklog_TriggerHandler(true);
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}