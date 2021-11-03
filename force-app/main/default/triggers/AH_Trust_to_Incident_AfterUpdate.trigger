/****************************************************************************************
Name            : AH_Trust_to_Incident_AfterUpdate Trigger
Author          : Shashikant Nikam
Created Date    : 02/27/2020
Last Mod Date   : 02/27/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/

trigger AH_Trust_to_Incident_AfterUpdate on AH_Trust_to_Incident__c (after update) {
    
    AH_Trust_to_Incident_TriggerHandler handler = new AH_Trust_to_Incident_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}