/****************************************************************************************
Name            : NI_Cancellation_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 06/10/2014
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Handles After Update Trigger Logic for the NI Cancellation object
                : NICC-034374 added Trigger execution control switch
                : 
******************************************************************************************/
trigger NI_Cancellation_AfterUpdate on NI_Cancellation__c (after update) 
{    
    if (NI_TriggerManager.is1stUpdate_Cancellation)
    {    
        NI_Cancellation_TriggerHandler handler = new NI_Cancellation_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);  
    }
}