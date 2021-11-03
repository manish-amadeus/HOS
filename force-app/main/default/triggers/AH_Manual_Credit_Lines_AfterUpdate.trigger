/****************************************************************************************
Name            : AH_Manual_Credit_Lines_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 09/13/2018
Last Mod Date   : 09/18/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Handles the after update logic of the 
                : AH_Manual_Credit_Lines__c object 
                :
                :
******************************************************************************************/
trigger AH_Manual_Credit_Lines_AfterUpdate on AH_Manual_Credit_Lines__c (after update) 
{
    AH_Manual_Credit_Lines_TriggerHandler handler = new AH_Manual_Credit_Lines_TriggerHandler();    
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}