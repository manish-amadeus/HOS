/****************************************************************************************
Name            : NI_Cancellation_AfterUndelete Trigger
Author          : Sean Harris
Created Date    : 01/19/2018
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-025668
Description     : Handles After Undelete Trigger Logic for the NI Cancellation object
                : 
                : 
******************************************************************************************/
trigger NI_Cancellation_AfterUndelete on NI_Cancellation__c (after undelete) 
{
    NI_Cancellation_TriggerHandler handler = new NI_Cancellation_TriggerHandler();
    handler.OnAfterUndelete(Trigger.new);
}