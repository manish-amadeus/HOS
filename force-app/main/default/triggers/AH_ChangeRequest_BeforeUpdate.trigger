/****************************************************************************************
Name            : AH_ChangeRequest_BeforeUpdate Trigger
Author          : Bhuleshwar Deshpande
Created Date    : 09/10/2018
Last Mod Date   : 09/10/2018
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  :
Description     : Call the Before Update Methods in the AH_ChangeRequest_TriggerHandler Class
                :
                :
******************************************************************************************/
trigger AH_ChangeRequest_BeforeUpdate on SFDC_CSP_Development_Request__c (before update) {
    
    AH_ChangeRequest_TriggerHandler handler = new AH_ChangeRequest_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new);
}