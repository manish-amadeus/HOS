/****************************************************************************************
Name            : NI_CR_Engagement_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 04/08/2014 
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_CR_Engagement_AfterUpdate on NI_Customer_Relations_Engagement__c (after update) 
{
    NI_CR_Engagement_TriggerHandler handler = new NI_CR_Engagement_TriggerHandler(true);
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);    
}