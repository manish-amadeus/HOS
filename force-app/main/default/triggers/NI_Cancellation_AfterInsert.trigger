/****************************************************************************************
Name            : NI_Cancellation_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 08/28/2014
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-011308
Description     : Handles After Insert Trigger Logic for the NI Cancellation object
                : NICC-034374 added Trigger execution control switch
                : 
******************************************************************************************/
trigger NI_Cancellation_AfterInsert on NI_Cancellation__c (after insert) 
{
    if (NI_TriggerManager.is1stInsert_Cancellation)
    {
        NI_Cancellation_TriggerHandler handler = new NI_Cancellation_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);   
    }
}