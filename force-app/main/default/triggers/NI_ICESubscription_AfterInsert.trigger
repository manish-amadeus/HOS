/****************************************************************************************
Name            : NI_ICE_Subscription_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 02/26/2014
Last Mod Date   :
Last Mod By     :
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_ICESubscription_AfterInsert on ICESubscription__c(After insert) 
{

    NI_ICESubscription_TriggerHandler handler = new NI_ICESubscription_TriggerHandler(true);
    handler.OnAfterInsert(Trigger.new);
    
}