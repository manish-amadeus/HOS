/****************************************************************************************
Name            : AH_Finance_Request_to_SIN_LI_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 09/12/2018
Last Mod Date   : 09/18/2018
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Handles the after update logic of the 
                : AH_Finance_Request_to_SIN_Line_Item__c object 
                :
                :
******************************************************************************************/
trigger AH_Finance_Request_to_SIN_LI_AfterUpdate on AH_Finance_Request_to_SIN_Line_Item__c (after update) 
{
    AH_Finance_Req_to_SIN_LI_Trigger_Handler handler = new AH_Finance_Req_to_SIN_LI_Trigger_Handler();    
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}