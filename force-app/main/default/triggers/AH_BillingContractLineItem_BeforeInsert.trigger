/****************************************************************************************
Name            : AH_BillingContractLineItem_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 06/03/2019
Last Mod Date   : 06/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_BillingContractLineItem_BeforeInsert on Billing_Contract_Line_Item__c (before insert) 
{
    AH_BillingContractLI_TriggerHandler handler = new AH_BillingContractLI_TriggerHandler();    
    handler.onBeforeInsert(Trigger.new);
}