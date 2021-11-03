/****************************************************************************************
Name            : AH_ChangeRequest_BeforeInsert Trigger
Author          : Bhuleshwar Deshpande
Created Date    : 09/10/2018
Last Mod Date   : 09/10/2018
Last Mod By     : Bhuleshwar Deshpande  
NICC Reference  :
Description     : Call the Before Insert Methods in the AH_ChangeRequest_TriggerHandler Class
                :
                :
******************************************************************************************/
trigger AH_ChangeRequest_BeforeInsert on SFDC_CSP_Development_Request__c (before insert) {
    
    AH_ChangeRequest_TriggerHandler handler = new AH_ChangeRequest_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
    
}