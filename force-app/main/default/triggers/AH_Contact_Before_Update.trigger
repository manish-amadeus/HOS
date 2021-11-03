/***********************************************************************************************
Name            : AH_Contact_Before_Update
Author          : Sean Harris
Created Date    : 04/27/2019
Last Mod Date   : 04/27/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Call the Before Update Methods in the AH_Contact_Trigger_Handler Class
                :
                :
************************************************************************************************/
trigger AH_Contact_Before_Update on Contact (before update) 
{
    AH_Contact_Trigger_Handler contactHandler = new AH_Contact_Trigger_Handler();
    contactHandler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
}