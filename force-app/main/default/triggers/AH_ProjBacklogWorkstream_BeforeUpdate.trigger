/****************************************************************************************
Name            : AH_ProjBacklogWorkstream_BeforeUpdate Trigger
Author          : Stuart Emery
Created Date    : 11/22/2020
Last Mod Date   : 11/22/2020
Last Mod By     : Stuart Emery
NICC Reference  : NICC-
Description     : Handles the before update logic of the 
                : AH_Project_Backlog_Workstreams__c object 
                :
                :
******************************************************************************************/

trigger AH_ProjBacklogWorkstream_BeforeUpdate on AH_Project_Backlog_Workstreams__c (before update) 

{
            AH_ProjBacklogWorkstream_TriggerHandler handler = new AH_ProjBacklogWorkstream_TriggerHandler();
            handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);

}