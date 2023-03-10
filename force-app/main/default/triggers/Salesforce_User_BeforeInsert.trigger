/****************************************************************************************
Name            : Salesforce_User_BeforeInsert Trigger
Author          : Supriya Galinde
Created Date    : 2/16/2017
Last Mod Date   : 3/2/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Handles Before Insert Trigger Logic for the Salesforce_User__c object
                : 
                : 
******************************************************************************************/
trigger Salesforce_User_BeforeInsert on Salesforce_User__c (before insert) {
     Salesforce_User_TriggerHandler handler = new  Salesforce_User_TriggerHandler(true);

      handler.OnBeforeInsert(Trigger.new);
}