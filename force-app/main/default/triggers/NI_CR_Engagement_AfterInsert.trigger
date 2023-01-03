/****************************************************************************************
Name            : NI_CR_Engagement_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 04/08/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_CR_Engagement_AfterInsert on NI_Customer_Relations_Engagement__c (after insert) 
{
    NI_CR_Engagement_TriggerHandler handler = new NI_CR_Engagement_TriggerHandler(true);
    handler.OnAfterInsert(Trigger.new);    
}