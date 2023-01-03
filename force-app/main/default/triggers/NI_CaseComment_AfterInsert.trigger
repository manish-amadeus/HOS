/****************************************************************************************
Name            : NI_CaseComment_AfterInsert Trigger
Author          : Swapnil Patil
Created Date    : 02/18/2016
Last Mod Date   : 02/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_CaseComment_AfterInsert on CaseComment (after insert) 
{
    
    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    {
        INTGR_WinSN_CaseComment_Handler WinSN = new INTGR_WinSN_CaseComment_Handler ();
        WinSN.OnAfterInsert(Trigger.new);                         
    }     
    
    NI_CaseComment_TriggerHandler handler = new NI_CaseComment_TriggerHandler();
    handler.OnAfterInsert(Trigger.new); 
    
}