/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_CaseComment_AfterInsert Trigger
Author          : Princy Jain
Created Date    : 03/29/2018
Last Mod Date   : 03/29/2018
Last Mod By     : Princy Jain
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_CaseComment_AfterInsert on INTGR_Case_Comment__c (After insert)
{    
    INTGR_CaseComment_TriggerHandler handler = new INTGR_CaseComment_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
}