/****************************************************************************************
Name            : NI_Case_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 05/02/2014 
Last Mod Date   : 08/17/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Case_BeforeUpdate on Case (before update) 
{
    
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in NI_Case_BeforeInsert.oooEmailLoopBlocker() method)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug('  NI_Case_BeforeUpdate WAS BYPASSED '); 
        return;
    }
    
    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    {
        INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
        WinSN.OnBeforeUpdate(Trigger.new, Trigger.oldMap); 
    }
    
    NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    
    system.debug('  NI_Case_BeforeUpdate SUMMARY: ');   
    system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
    
}