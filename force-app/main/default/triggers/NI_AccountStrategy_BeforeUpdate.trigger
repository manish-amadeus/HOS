/****************************************************************************************
Name            : NI_AccountStrategy_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 10/29/2014
Last Mod Date   : 10/29/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_AccountStrategy_BeforeUpdate on SFDC_Strategy__c (before update) 
{
    NI_AccountStrategy_TriggerHandler handler = new NI_AccountStrategy_TriggerHandler(true);
    handler.OnBeforeUpdate(Trigger.new);    
}