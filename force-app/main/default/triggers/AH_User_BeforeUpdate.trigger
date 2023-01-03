/****************************************************************************************
Name            : AH_User_BeforeUpdate Trigger
Author          : Archita Shrotriya
Created Date    : 07/21/2017
Last Mod Date   : 04/18/2020 
Last Mod By     : Sean Harris
NICC Reference  : Sprint-00077
Description     : 
                : Updated to point to AH_User_TriggerHandler
                : 
******************************************************************************************/
trigger AH_User_BeforeUpdate on User (before update)
{
    AH_User_TriggerHandler handler = new AH_User_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.New, Trigger.oldMap);
}