/****************************************************************************************
Name            : AH_Trust_to_Incident_AfterInsert Trigger
Author          : Shashikant Nikam
Created Date    : 01/17/2020
Last Mod Date   : 01/17/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : 
                :
                : 
******************************************************************************************/

trigger AH_Trust_to_Incident_AfterInsert on AH_Trust_to_Incident__c (after insert) 
{
    AH_Trust_to_Incident_TriggerHandler handler = new AH_Trust_to_Incident_TriggerHandler(); 
    handler.OnAfterInsert(Trigger.new);
}