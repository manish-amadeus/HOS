/****************************************************************************************
Name            : AH_User_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 04/18/2020 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : After Insert Trigger for the standard User Object
                : Updated to point to AH_User_TriggerHandler
                : 
******************************************************************************************/
trigger AH_User_AfterInsert on User (after insert) 
{
    AH_User_TriggerHandler handler = new AH_User_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
}