/****************************************************************************************
Name            : AH_ChangeRequest_BeforeInsert Trigger
Author          : Bhuleshwar Deshpande
Created Date    : 09/10/2018
Last Mod Date   : 11/09/2021
Last Mod By     : Sean Harris 
NICC Reference  :
Description     : Call the Before Insert Methods in the AH_ChangeRequest_TriggerHandler Class
                : 11/10/2021 Updated API to v52
                :
******************************************************************************************/
trigger AH_ChangeRequest_BeforeInsert on SFDC_CSP_Development_Request__c (before insert) 
{
    AH_ChangeRequest_TriggerHandler handler = new AH_ChangeRequest_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}