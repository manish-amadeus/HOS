/****************************************************************************************
Name            : AH_Internal_IT_Request_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 2/17/2017
Last Mod Date   : 2/17/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Call the Before Insert Methods in the AH_Internal_IT_Request_Trigger_Handler Class
                : 
                : 
******************************************************************************************/
trigger AH_Internal_IT_Request_AfterInsert on AH_Internal_IT_Request__c (after insert) {
    
    AH_Internal_IT_Request_Trigger_Handler handler = new AH_Internal_IT_Request_Trigger_Handler();
    handler.OnAfterInsert(Trigger.new);

}