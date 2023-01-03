/****************************************************************************************
Name            : AH_SubscriptionActivationTransaction_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 9/7/2017
Last Mod Date   : 9/7/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023846
Description     : Handles Before Insert Trigger Logic for the 
                : Subscription_Activation_Transaction__c object
                : 
                : 
******************************************************************************************/
trigger AH_SubscriptionActivationTransaction_BeforeInsert on Subscription_Activation_Transaction__c (before insert) 
{
    AH_SubsActvnTrans_TriggerHandler handler = new AH_SubsActvnTrans_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}