/****************************************************************************************
Name            : AH_Trust_AfterUpdate Trigger
Author          : Shashikant Nikam
Created Date    : 01/14/2019
Last Mod Date   : 01/14/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/

trigger AH_Trust_AfterUpdate on NI_Trust__c (after update) {

    AH_Trust_TriggerHandler handler = new AH_Trust_TriggerHandler(); 
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}