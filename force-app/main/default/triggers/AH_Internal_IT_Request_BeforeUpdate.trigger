/*****************************************************************************************************
Name            : AH_Internal_IT_Request_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 3/28/2017
Last Mod Date   : 3/28/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Call the Before Update Methods in the AH_Internal_IT_Request_Trigger_Handler Class
                : 
                : 
*****************************************************************************************************/
trigger AH_Internal_IT_Request_BeforeUpdate on AH_Internal_IT_Request__c (before update) {
    
    AH_Internal_IT_Request_Trigger_Handler handler = new AH_Internal_IT_Request_Trigger_Handler();
    handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);

}