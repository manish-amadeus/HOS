/****************************************************************************************
Name            : NI_ProjectBacklog_BeforeUpdate
Author          : Swapnil Patil
Created Date    : 01/08/2017
Last Mod Date   : 01/08/2017
Last Mod By     : 
NICC Reference  : 
Description     : 
                : 
******************************************************************************************/
trigger NI_ProjectBacklog_BeforeInsert on NI_Project_Backlog__c (before insert) {
    if (!NI_FUNCTIONS.bypassTriggerCode('NI PROJECT BACKLOG'))
    {
        NI_ProjectBacklog_TriggerHandler handler = new NI_ProjectBacklog_TriggerHandler(true);
        handler.OnBeforeInsert(Trigger.new ); 
    }
}