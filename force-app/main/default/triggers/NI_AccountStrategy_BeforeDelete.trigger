/****************************************************************************************
Name            : NI_AccountStrategy_BeforeDelete Trigger
Author          : Sean Harris
Created Date    : 12/09/2014
Last Mod Date   : 12/09/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_AccountStrategy_BeforeDelete on SFDC_Strategy__c (before delete) 
{
    NI_AccountStrategy_TriggerHandler handler = new NI_AccountStrategy_TriggerHandler(true);
    handler.OnBeforeDelete(Trigger.new); 
}