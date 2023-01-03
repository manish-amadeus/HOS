/****************************************************************************************
Name            : NI_Cancellation_BeforeUpdate Trigger
Author          : Stuart Emery
Created Date    : 06/10/2014
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Handles Before Update Trigger Logic for the NI Cancellation object
                : 
                : 
******************************************************************************************/
trigger NI_Cancellation_BeforeUpdate on NI_Cancellation__c (before update) 
{
    NI_Cancellation_TriggerHandler handler = new NI_Cancellation_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
}