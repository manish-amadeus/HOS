/***********************************************************************************************
Name            : AH_Contact_Before_Insert
Author          : Sean Harris
Created Date    : 04/27/2019
Last Mod Date   : 04/27/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Call the Before Insert Methods in the AH_Contact_Trigger_Handler Class
                :
                :
************************************************************************************************/
trigger AH_Contact_Before_Insert on Contact (before insert) 
{
    AH_Contact_Trigger_Handler contactHandler = new AH_Contact_Trigger_Handler();
    contactHandler.OnBeforeInsert(Trigger.new);
}