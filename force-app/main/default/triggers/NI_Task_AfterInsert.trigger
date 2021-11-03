/****************************************************************************************
Name            : NI_Task_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 11/30/2016
Last Mod Date   : 07/23/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Call the After Insert Methods in the NI_Task_TriggerHandler Class
                : 
                : 
******************************************************************************************/
trigger NI_Task_AfterInsert on Task (after insert) 
{
    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    { 
        INTGR_WinSN_Task_Handler WinSN = new INTGR_WinSN_Task_Handler();
        WinSN.OnAfterInsert(Trigger.new); 
    }
    
    if (!NI_FUNCTIONS.bypassTriggerCode('TASK'))
    {
        try 
        {
        	NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler(); 
        	handler.OnAfterInsert(Trigger.new);
        }
        catch(Exception e)
        {
            system.debug('Exception found : '+e);
        }
    }
    system.debug('** Task OnAfterInsert Limits.getQueries() : ' + Limits.getQueries());
}