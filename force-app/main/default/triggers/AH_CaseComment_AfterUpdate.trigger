/****************************************************************************************
Name            : AH_CaseComment_AfterUpdate Trigger
Author          : Princy Jain
Created Date    : 05/18/2016
Last Mod Date   : 02/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_CaseComment_AfterUpdate on CaseComment (after update) 
{

    // INTEGRATION - DO NOT ALTER!!! 
    if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
    {
        INTGR_WinSN_CaseComment_Handler WinSN = new INTGR_WinSN_CaseComment_Handler();
        WinSN.OnAfterUpdate(Trigger.new, Trigger.OldMap);                         
    }     

    //NI_CaseComment_TriggerHandler handler = new NI_CaseComment_TriggerHandler();
    //handler.OnAfterUpdate(Trigger.new, Trigger.OldMap);
        
}