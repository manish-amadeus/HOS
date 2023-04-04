/****************************************************************************************
Name            : NI_Case_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 05/02/2014 
Last Mod Date   : 08/17/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Case_BeforeInsert on Case (before Insert) 
{
    
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in NI_Case_BeforeInsert.oooEmailLoopBlocker() method)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug('  NI_Case_BeforeInsert WAS BYPASSED ');        
        return;
    }
    
    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    {
        INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
        WinSN.OnBeforeInsert(Trigger.new); 
    }
    
    NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
    
    system.debug('  NI_Case_BeforeInsert SUMMARY: ');   
    system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
    
}