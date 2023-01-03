/****************************************************************************************
Name            : AH_Trust_to_Incident_BeforeDelete Trigger
Author          : Shashikant Nikam
Created Date    : 02/25/2020
Last Mod Date   : 02/25/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/

trigger AH_Trust_to_Incident_BeforeDelete on AH_Trust_to_Incident__c (before delete) {

    AH_Trust_to_Incident_TriggerHandler handler = new AH_Trust_to_Incident_TriggerHandler(); 
    handler.OnBeforeDelete(Trigger.old);
}