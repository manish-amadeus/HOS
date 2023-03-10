/****************************************************************************************
Name            : NI_ProjectTasks_AfterInsert
Author          : Prashant Wayal
Created Date    : 12/4/2015
Last Mod Date   : 12/22/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016293
Description     : 
                : 
******************************************************************************************/
trigger NI_ProjectTasks_AfterInsert on NI_Project_Backlog_Tasks__c(after Insert) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('NI PROJECT BACKLOG TASKS'))
    {
        NI_ProjectTasks_TriggerHandler handler = new NI_ProjectTasks_TriggerHandler(true);
        handler.OnAfterInsert(Trigger.new);
    }
}