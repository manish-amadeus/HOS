/****************************************************************************************
Name            : AH_Manual_Credit_Lines_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 10/29/2018
Last Mod Date   : 10/29/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-031087
Description     : Handles the before insert logic of the 
                : AH_Manual_Credit_Lines__c object 
                :
                :
******************************************************************************************/
trigger AH_Manual_Credit_Lines_BeforeInsert on AH_Manual_Credit_Lines__c (before insert) {
    
    AH_Manual_Credit_Lines_TriggerHandler handler = new AH_Manual_Credit_Lines_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);

}