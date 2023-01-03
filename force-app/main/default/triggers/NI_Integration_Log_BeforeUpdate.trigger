/****************************************************************************************
Name            : NI_Integration_Log_BeforeUpdate Trigger
Author          : Swapnil Patil
Created Date    : 03/23/2017
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Integration_Log_BeforeUpdate on NI_Integration_Log__c (before update) 
{
    NI_Integration_Log_TriggerHandler handler = new NI_Integration_Log_TriggerHandler();
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);  
}