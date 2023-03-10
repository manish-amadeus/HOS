/****************************************************************************************
Name            : AH_CxlCaseRuleProduct_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 05/09/2018
Last Mod Date   : 05/09/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Before Insert Trigger for the Cancellation_Case_Rule_Product__c Object
                : 
                : 
******************************************************************************************/
trigger AH_CxlCaseRuleProduct_BeforeInsert on Cancellation_Case_Rule_Product__c (before insert) 
{
    AH_CxlCaseRuleProduct_TriggerHandler handler = new AH_CxlCaseRuleProduct_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}