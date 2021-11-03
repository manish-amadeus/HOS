/****************************************************************************************
Name            : NI_CR_Engagement_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 04/08/2014 
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_CR_Engagement_BeforeUpdate on NI_Customer_Relations_Engagement__c (before update) 
{
    NI_CR_Engagement_TriggerHandler handler = new NI_CR_Engagement_TriggerHandler(true);
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);    
}