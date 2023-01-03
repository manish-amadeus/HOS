/****************************************************************************************
Name            : AH_Finance_Request_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 09/17/2018
Last Mod Date   : 09/18/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Handles the after insert logic of the 
                : AH_Finance_Request__c object 
                :
                :
******************************************************************************************/
trigger AH_Finance_Request_BeforeInsert on AH_Finance_Request__c (before insert) 
{
    AH_Finance_Request_Trigger_Handler handler = new AH_Finance_Request_Trigger_Handler();
    handler.OnBeforeInsert(Trigger.new);
}