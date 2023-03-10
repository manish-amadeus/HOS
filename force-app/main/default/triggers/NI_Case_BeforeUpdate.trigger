/****************************************************************************************
Name            : NI_Case_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 05/02/2014 
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Case_BeforeUpdate on Case (before update) 
{
    
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in emailLoopKiller trigger)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** NI_Case_BeforeUpdate WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML'); 
    }
    else
    {
        // INTEGRATION - DO NOT ALTER!!! 
        if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
        {
            INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
            WinSN.OnBeforeUpdate(Trigger.new, Trigger.oldMap); 
        }
        
        NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);        
    }
	
    system.debug(' ***** NI_Case_BeforeUpdate SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
    
}