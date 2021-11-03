/****************************************************************************************
Name            : NI_Account_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 04/03/2017
Last Mod Date   : 04/03/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-021729
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Account_AfterUpdate on Account (after update) 
{
    NI_Account_TriggerHandler handler = new NI_Account_TriggerHandler();
    handler.OnAfterUpdate(Trigger.NewMap, Trigger.OldMap);
}