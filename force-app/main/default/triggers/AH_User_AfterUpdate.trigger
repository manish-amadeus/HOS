/****************************************************************************************
Name            : AH_User_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 03/30/2015
Last Mod Date   : 04/18/2020 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : After Update Trigger for the standard User Object
                : Updated to point to AH_User_TriggerHandler
                : 
******************************************************************************************/
trigger AH_User_AfterUpdate on User (after update) 
{
    AH_User_TriggerHandler handler = new AH_User_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}