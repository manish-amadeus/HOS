/*****************************************************************************************************
Name            : AH_Internal_IT_Request_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 2/17/2017
Last Mod Date   : 2/17/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Call the After Update Methods in the AH_Internal_IT_Request_Trigger_Handler Class
                : 
                : 
*****************************************************************************************************/
trigger AH_Internal_IT_Request_AfterUpdate on AH_Internal_IT_Request__c (after update){
  
    AH_Internal_IT_Request_Trigger_Handler handler = new AH_Internal_IT_Request_Trigger_Handler();
    handler.OnAfterUpdate(Trigger.new,Trigger.oldMap);
}