/****************************************************************************************
Name            : AH_Finance_Request_to_SIN_LI_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 10/26/2018
Last Mod Date   : 10/26/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-031087
Description     : Handles the before insert logic of the 
                : AH_Finance_Request_to_SIN_Line_Item__c object 
                :
                :
******************************************************************************************/
trigger AH_Finance_Request_to_SIN_LI_BeforeInsert on AH_Finance_Request_to_SIN_Line_Item__c (before insert) {
    
    AH_Finance_Req_to_SIN_LI_Trigger_Handler handler = new AH_Finance_Req_to_SIN_LI_Trigger_Handler();
    handler.OnBeforeInsert(Trigger.new);

}