/***********************************************************************************************
Name            : NI_Task_AfterUpdate
Author          : Ria Chawla
Created Date    : 2/1/2018
Last Mod Date   : 04/30/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Call the After Update Methods in the NI_Task_TriggerHandler Class
                :
************************************************************************************************/
trigger NI_Task_AfterUpdate on Task (after update) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('TASK'))
    {
        NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler(); 
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    system.debug('** Task OnAfterUpdate Limits.getQueries() : ' + Limits.getQueries());
}