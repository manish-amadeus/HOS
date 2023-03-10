/****************************************************************************************
Name            : AH_Manual_Credit_Lines_AfterDelete Trigger
Author          : Stuart Emery
Created Date    : 09/13/2018
Last Mod Date   : 09/18/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Handles the after delete logic of the 
                : AH_Manual_Credit_Lines__c object 
                :
                :
******************************************************************************************/
trigger AH_Manual_Credit_Lines_AfterDelete on AH_Manual_Credit_Lines__c (after delete) 
{
    AH_Manual_Credit_Lines_TriggerHandler handler = new AH_Manual_Credit_Lines_TriggerHandler();
    handler.OnAfterDelete(Trigger.old);
}