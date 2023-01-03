/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_Case_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 03/02/2018
Last Mod Date   : 03/02/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_Case_BeforeInsert on INTGR_Case__c (before insert) 
{    
    INTGR_Case_TriggerHandler handler = new INTGR_Case_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}