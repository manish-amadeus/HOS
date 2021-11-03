/****************************************************************************************
Name            : NI_CR_Engagement_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 07/23/2014 
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_CR_Engagement_BeforeInsert on NI_Customer_Relations_Engagement__c (before insert) 
{
    NI_CR_Engagement_TriggerHandler handler = new NI_CR_Engagement_TriggerHandler(true);
    handler.OnBeforeInsert(Trigger.new);    
}