/****************************************************************************************
Name            : NI_Account_BeforeDelete Trigger
Author          : Stuart Emery
Created Date    : 1/09/2014
Last Mod Date   : 1/15/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-009172
Description     : Originally created to prevent accounts that are integrated with Softrax
                : from being deleted
                : 
******************************************************************************************/
trigger NI_Account_BeforeDelete on Account (before delete) 
{
    NI_Account_TriggerHandler handler = new NI_Account_TriggerHandler();
    handler.OnBeforeDelete(Trigger.old);
}