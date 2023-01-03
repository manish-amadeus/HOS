/************************************************************************************************
Name            : NI_MTechSaasSubscription_NoDelete Trigger
Author          : Stuart Emery
Created Date    : 10/20/2016
Last Mod Date   : 10/20/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Trigger for the MTech_Saas_Subscription__c Object
                :
*************************************************************************************************/
trigger NI_MTechSaasSubscription_NoDelete on MTech_SaaS_Subscription__c (before delete) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('MTECH SaaS'))
    { 
        for (MTech_SaaS_Subscription__c ssub : Trigger.old) 
        {    
        	ssub.Modification_Reason__c.addError('Deleting Subscriptions is not allowed');    
        } 
    }
}