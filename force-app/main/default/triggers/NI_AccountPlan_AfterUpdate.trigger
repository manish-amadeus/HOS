/****************************************************************************************
Name            : NI_AccountPlan_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 10/31/2014
Last Mod Date   : 10/31/2014
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_AccountPlan_AfterUpdate on SFDC_Acct_Plan__c (after update) 
{
    NI_AccountPlan_TriggerHandler handler = new NI_AccountPlan_TriggerHandler(true);
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);    
}