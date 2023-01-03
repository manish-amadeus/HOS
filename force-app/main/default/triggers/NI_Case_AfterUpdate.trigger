/****************************************************************************************
Name            : NI_Case_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 05/02/2014 
Last Mod Date   : 02/26/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Case_AfterUpdate on Case (after update) 
{
    
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in emailLoopKiller trigger)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
system.debug('  NI_Case_AfterUpdate WAS BYPASSED '); 
        return;
    }
    
    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    {
        INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
        WinSN.OnAfterUpdate(Trigger.new, Trigger.oldMap); 
    }
    
    NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap); 

system.debug('  NI_Case_AfterUpdate SUMMARY: ');   
system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
    
}