/****************************************************************************************
Name            : AH_SubscriptionActivation_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 8/31/2017
Last Mod Date   : 8/31/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023777
Description     : Handles After Insert Trigger Logic for the Subscription Activation object
                : 
                : 
******************************************************************************************/
trigger AH_SubscriptionActivation_AfterInsert on Subscription_Activation__c (after insert) 
{
    AH_SubsActvn_TriggerHandler handler = new AH_SubsActvn_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
}