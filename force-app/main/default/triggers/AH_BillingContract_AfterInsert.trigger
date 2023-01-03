/****************************************************************************************
Name            : AH_BillingContract_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 03/26/2019
Last Mod Date   : 03/26/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_BillingContract_AfterInsert on Billing_Contract__c (after insert) 
{
    
    AH_Billing_Contract_TriggerHandler handler = new AH_Billing_Contract_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
    
}