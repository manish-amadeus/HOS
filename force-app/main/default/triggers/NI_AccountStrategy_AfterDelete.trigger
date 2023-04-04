/****************************************************************************************
Name            : NI_AccountStrategy_AfterDelete Trigger
Author          : Sean Harris
Created Date    : 10/31/2014
Last Mod Date   : 10/31/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_AccountStrategy_AfterDelete on SFDC_Strategy__c (after delete) 
{
    NI_AccountStrategy_TriggerHandler handler = new NI_AccountStrategy_TriggerHandler(true);
    handler.OnAfterDelete(Trigger.old);    
}