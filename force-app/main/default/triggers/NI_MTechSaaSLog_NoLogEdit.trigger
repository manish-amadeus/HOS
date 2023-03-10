/************************************************************************************************
Name            : NI_MTechSaaSLog_NoLogEdit Trigger
Author          : Stuart Emery
Created Date    : 10/20/2016
Last Mod Date   : 10/20/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Trigger for the MTech_SaaS_Log__c Object
                :
*************************************************************************************************/
trigger NI_MTechSaaSLog_NoLogEdit on MTech_SaaS_Log__c (before update) {
    
    for (MTech_SaaS_Log__c ssub : Trigger.new) {

    ssub.Reason__c.addError('Changing Subscription Log entries is not allowed');

    } 

}