/****************************************************************************************
Name            : AH_Trust_to_Incident_BeforeUpdate Trigger
Author          : Shashikant Nikam
Created Date    : 02/25/2020
Last Mod Date   : 02/25/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/

trigger AH_Trust_to_Incident_BeforeUpdate on AH_Trust_to_Incident__c (before update) {

    AH_Trust_to_Incident_TriggerHandler handler = new AH_Trust_to_Incident_TriggerHandler(); 
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
}