/***********************************************************************************************
Name            : AH_Contact_After_Delete
Author          : Shashikant Nikam
Created Date    : 04/04/2018
Last Mod Date   : 04/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-027123
Description     : Call the After Delete Methods in the AH_Contact_Trigger_Handler Class
                :
                :
************************************************************************************************/
trigger AH_Contact_After_Delete on Contact (after delete) 
{
    AH_Contact_Trigger_Handler contactHandler = new AH_Contact_Trigger_Handler();
    contactHandler.OnAfterDelete(Trigger.old);
}