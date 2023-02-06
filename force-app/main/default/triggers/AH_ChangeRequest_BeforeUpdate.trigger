/****************************************************************************************
Name            : AH_ChangeRequest_BeforeUpdate Trigger
Author          : Bhuleshwar Deshpande
Created Date    : 09/10/2018
Last Mod Date   : 11/09/2021
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Call the Before Update Methods in the AH_ChangeRequest_TriggerHandler Class
                : 11/10/2021 Updated API to v52
                :
******************************************************************************************/
trigger AH_ChangeRequest_BeforeUpdate on SFDC_CSP_Development_Request__c (before update) 
{
    AH_ChangeRequest_TriggerHandler handler = new AH_ChangeRequest_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new);
}