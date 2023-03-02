/****************************************************************************************
Name            : NI_Case_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 05/02/2014 
<<<<<<< HEAD
<<<<<<< HEAD
Last Mod Date   : 08/17/2021
=======
Last Mod Date   : 03/01/2022
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
Last Mod Date   : 03/01/2022
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Case_AfterUpdate on Case (after update) 
{
    
    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in NI_Case_BeforeInsert.oooEmailLoopBlocker() method)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
<<<<<<< HEAD
<<<<<<< HEAD
        system.debug('  NI_Case_AfterUpdate WAS BYPASSED '); 
        return;
=======
        system.debug(' ***** NI_Case_BeforeUpdate WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML'); 
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
        system.debug(' ***** NI_Case_BeforeUpdate WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML'); 
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
    }
    else
    {
        // INTEGRATION - DO NOT ALTER!!! 
        if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
        {
            INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
            WinSN.OnAfterUpdate(Trigger.new, Trigger.oldMap); 
        }
        
        NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);         
    }
    
<<<<<<< HEAD
<<<<<<< HEAD
    NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap); 
    
    system.debug('  NI_Case_AfterUpdate SUMMARY: ');   
    system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
=======
    system.debug(' ***** NI_Case_AfterUpdate SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
=======
    system.debug(' ***** NI_Case_AfterUpdate SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
    
}