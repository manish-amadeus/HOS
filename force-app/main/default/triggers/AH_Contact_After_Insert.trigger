/***********************************************************************************************
Name            : AH_Contact_After_Insert
Author          : Shashikant Nikam
Created Date    : 04/04/2018
Last Mod Date   : 04/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-027123
Description     : Call the After Insert Methods in the AH_Contact_Trigger_Handler Class
                :
                :
************************************************************************************************/
trigger AH_Contact_After_Insert on Contact (after insert) 
{
    AH_Contact_Trigger_Handler contactHandler = new AH_Contact_Trigger_Handler();
    contactHandler.OnAfterInsert(Trigger.new);
}