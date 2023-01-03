/****************************************************************************************
Name            : AH_BillingContractLineItem_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 06/03/2019
Last Mod Date   : 06/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_BillingContractLineItem_BeforeUpdate on Billing_Contract_Line_Item__c (before update) 
{
    AH_BillingContractLI_TriggerHandler handler = new AH_BillingContractLI_TriggerHandler();    
    handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
}