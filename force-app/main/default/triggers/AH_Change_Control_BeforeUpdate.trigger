/****************************************************************************************
Name            : AH_Change_Control_BeforeUpdate Trigger
Author          : Swapnil Patil
Created Date    : 04/10/2017
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/

trigger AH_Change_Control_BeforeUpdate  on NI_Change_Control__c (before update) {
// TRIGGER BYPASS CHECK ===========================
   if (NI_TriggerManager.bypass_NICC_Updates == false)
   { 
        NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler (true);
        handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap); 
   }
}