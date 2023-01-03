/****************************************************************************************
Name            : NI_Cancellation_AfterDelete Trigger
Author          : Sean Harris
Created Date    : 01/19/2018
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-025668
Description     : Handles After Delete Trigger Logic for the NI Cancellation object
                : 
                : 
******************************************************************************************/
trigger NI_Cancellation_AfterDelete on NI_Cancellation__c (after delete) 
{
    NI_Cancellation_TriggerHandler handler = new NI_Cancellation_TriggerHandler();
    handler.OnAfterDelete(Trigger.old);  
}