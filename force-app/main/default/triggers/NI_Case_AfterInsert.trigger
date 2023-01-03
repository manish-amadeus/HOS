/****************************************************************************************
Name            : NI_Case_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 05/02/2014
Last Mod Date   : 02/26/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Case_AfterInsert on Case (after insert) 
{

    // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in emailLoopKiller trigger)
    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
system.debug('  NI_Case_AfterInsert WAS BYPASSED '); 
        return;
    }
    
    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    {
        INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
        WinSN.OnAfterInsert(Trigger.new);                         
    }     
    
    NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
    handler.OnAfterInsert(Trigger.new); 

system.debug('  NI_Case_AfterInsert SUMMARY: ');   
system.debug('  Limits.getQueries() = ' + Limits.getQueries()); 
               
}