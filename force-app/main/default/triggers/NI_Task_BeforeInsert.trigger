/****************************************************************************************
Name            : NI_Task_BeforeInsert Trigger
Author          : Ria Chawla
Created Date    : 08/30/2017
Last Mod Date   : 04/30/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Call the Before Insert Methods in the NI_Task_TriggerHandler Class
                : 
                : 
******************************************************************************************/
trigger NI_Task_BeforeInsert on Task (before insert) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('TASK'))
    {
        NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler(); 
        handler.OnBeforeInsert(Trigger.new);
    }
    system.debug('** Task onBeforeInsert Limits.getQueries() : ' + Limits.getQueries());
}