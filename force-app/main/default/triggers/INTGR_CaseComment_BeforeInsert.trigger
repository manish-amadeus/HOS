/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_CaseComment_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 03/20/2018
Last Mod Date   : 03/20/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_CaseComment_BeforeInsert on INTGR_Case_Comment__c (before insert)
{    
    INTGR_CaseComment_TriggerHandler handler = new INTGR_CaseComment_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}