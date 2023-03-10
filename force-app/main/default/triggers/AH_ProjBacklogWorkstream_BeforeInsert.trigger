/****************************************************************************************
Name            : AH_ProjBacklogWorkstream_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 11/22/2020
Last Mod Date   : 11/22/2020
Last Mod By     : Stuart Emery
NICC Reference  : NICC-
Description     : Handles the before insert logic of the 
                : AH_Project_Backlog_Workstreams__c object 
                :
                :
******************************************************************************************/
trigger AH_ProjBacklogWorkstream_BeforeInsert on AH_Project_Backlog_Workstreams__c (before insert) 
{
    AH_ProjBacklogWorkstream_TriggerHandler handler = new AH_ProjBacklogWorkstream_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}