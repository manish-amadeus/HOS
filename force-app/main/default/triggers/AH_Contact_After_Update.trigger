/***********************************************************************************************
Name            : AH_Contact_After_Update
Author          : Shashikant Nikam
Created Date    : 04/04/2018
Last Mod Date   : 04/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-027123
Description     : Call the After Update Methods in the AH_Contact_Trigger_Handler Class
                :
                :
************************************************************************************************/
trigger AH_Contact_After_Update on Contact (after update) 
{
    AH_Contact_Trigger_Handler contactHandler = new AH_Contact_Trigger_Handler();
    contactHandler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}