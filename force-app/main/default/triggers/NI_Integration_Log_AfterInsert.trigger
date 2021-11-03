/****************************************************************************************
Name            : NI_Integration_Log_AfterInsert Trigger
Author          : Swapnil Patil
Created Date    : 03/11/2016
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Integration_Log_AfterInsert on NI_Integration_Log__c (after insert) 
{  
    NI_Integration_Log_TriggerHandler handler = new NI_Integration_Log_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);  
}