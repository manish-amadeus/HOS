/****************************************************************************************
Name            : NI_Case_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 05/02/2014
<<<<<<< HEAD
Last Mod Date   : 08/17/2021
=======
Last Mod Date   : 03/01/2022
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
******************************************************************************************/
trigger NI_Case_AfterInsert on Case (after insert) 
{
    
<<<<<<< HEAD
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in NI_Case_BeforeInsert.oooEmailLoopBlocker() method)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug('  NI_Case_AfterInsert WAS BYPASSED '); 
        return;
=======
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in emailLoopKiller trigger)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** NI_Case_AfterInsert WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML');
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
    }
    else
    {
<<<<<<< HEAD
        INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
        WinSN.OnAfterInsert(Trigger.new);                         
    }     
    
    NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
    handler.OnAfterInsert(Trigger.new); 
    
    system.debug('  NI_Case_AfterInsert SUMMARY: ');   
    system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
=======
        // INTEGRATION - DO NOT ALTER!!! 
        if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
        {
            INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
            WinSN.OnAfterInsert(Trigger.new);                         
        }     
        
        NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);         
    }

    
    system.debug(' ***** NI_Case_AfterInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
    
}