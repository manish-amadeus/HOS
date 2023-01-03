/************************************************************************************************
                           !!! INTEGRATION TRIGGER - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_Case_BeforeUpdate Trigger
Author          : Princy Jain
Created Date    : 14/06/2018
Last Mod Date   : 14/06/2018
Last Mod By     : Princy Jain
NICC Reference  : 
Description     : 
                : 
************************************************************************************************/
trigger INTGR_Case_BeforeUpdate on INTGR_Case__c (before update) 
{    
    INTGR_Case_TriggerHandler handler = new INTGR_Case_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
}