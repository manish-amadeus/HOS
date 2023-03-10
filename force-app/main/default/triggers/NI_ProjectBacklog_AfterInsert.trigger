/****************************************************************************************
Name            : NI_ProjectBacklog_AfterInsert
Author          : Prashant Wayal
Created Date    : 01/05/2016
Last Mod Date   : 02/07/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016753
Description     : 
                : 
******************************************************************************************/
trigger NI_ProjectBacklog_AfterInsert on NI_Project_Backlog__c (after Insert) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('NI PROJECT BACKLOG'))
    {
        NI_ProjectBacklog_TriggerHandler handler = new NI_ProjectBacklog_TriggerHandler(true);
        handler.OnAfterInsert(Trigger.new);
    }
}