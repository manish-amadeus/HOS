/****************************************************************************************
Name            : AH_Change_Control_BeforeInsert Trigger
Author          : Swapnil Patil
Created Date    : 04/10/2017
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/

trigger  AH_Change_Control_BeforeInsert on NI_Change_Control__c (before Insert) {

 NI_Change_Control_TriggerHandler handler = new NI_Change_Control_TriggerHandler (true);
        handler.OnBeforeInsert(Trigger.new); 
}