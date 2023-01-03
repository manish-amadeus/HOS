/****************************************************************************************
Name            : AH_BillingContract_BeforeDelete Trigger
Author          : Sean Harris
Created Date    : 03/26/2019
Last Mod Date   : 03/26/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_BillingContract_BeforeDelete on Billing_Contract__c (before delete) 
{
    
    AH_Billing_Contract_TriggerHandler handler = new AH_Billing_Contract_TriggerHandler();    
    handler.OnBeforeDelete(Trigger.old);

}