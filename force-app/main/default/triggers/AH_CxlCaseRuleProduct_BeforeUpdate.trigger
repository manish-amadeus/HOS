/****************************************************************************************
Name            : AH_CxlCaseRuleProduct_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 05/09/2018
Last Mod Date   : 05/09/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Before Update Trigger for the Cancellation_Case_Rule_Product__c Object
                : 
                : 
******************************************************************************************/
trigger AH_CxlCaseRuleProduct_BeforeUpdate on Cancellation_Case_Rule_Product__c (before update) 
{
    AH_CxlCaseRuleProduct_TriggerHandler handler = new AH_CxlCaseRuleProduct_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new);
}