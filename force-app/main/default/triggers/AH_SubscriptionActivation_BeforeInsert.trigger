/****************************************************************************************
Name            : AH_SubscriptionActivation_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 08/31/2017
Last Mod Date   : 08/31/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023777
Description     : Handles Before Insert Trigger Logic for the Subscription Activation object
                : 
                : 
******************************************************************************************/
trigger AH_SubscriptionActivation_BeforeInsert on Subscription_Activation__c (before insert) 
{
    AH_SubsActvn_TriggerHandler handler = new AH_SubsActvn_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}