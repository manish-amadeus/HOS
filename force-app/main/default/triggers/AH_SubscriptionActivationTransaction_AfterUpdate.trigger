/****************************************************************************************
Name            : AH_SubscriptionActivationTransaction_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 04/15/2019
Last Mod Date   : 04/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Handles Before Insert Trigger Logic for the 
                : Subscription_Activation_Transaction__c object
                : 
                : 
******************************************************************************************/
trigger AH_SubscriptionActivationTransaction_AfterUpdate on Subscription_Activation_Transaction__c (after update) 
{
    AH_SubsActvnTrans_TriggerHandler handler = new AH_SubsActvnTrans_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}