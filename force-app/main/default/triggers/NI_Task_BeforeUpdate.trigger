/****************************************************************************************
Name            : NI_Task_BeforeUpdate Trigger
Author          : Ria Chawla
Created Date    : 08/30/2017
Last Mod Date   : 04/30/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Call the Before Update Methods in the NI_Task_TriggerHandler Class
                : 
                : 
******************************************************************************************/
trigger NI_Task_BeforeUpdate on Task (before update) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('TASK'))
    {
        NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler(); 
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    system.debug('** Task OnBeforeUpdate Limits.getQueries() : ' + Limits.getQueries());
}