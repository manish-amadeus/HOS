/************************************************************************************************
Name            : NI_MTechSaaSLog_NoLogDelete Trigger
Author          : Stuart Emery
Created Date    : 10/20/2016
Last Mod Date   : 10/20/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Trigger for the MTech_SaaS_Log__c Object
                :
*************************************************************************************************/
trigger NI_MTechSaaSLog_NoLogDelete on MTech_SaaS_Log__c (before delete) {
    
    for (MTech_SaaS_Log__c ssub : Trigger.old) {

    ssub.Reason__c.addError('Deleting Subscription Log entries is not allowed');

    } 

}