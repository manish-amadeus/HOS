/****************************************************************************************
Name            : AH_SubscriptionActivation_AfterUpdate After Update Trigger
Author          : Stuart Emery
Created Date    : 8/31/2017
Last Mod Date   : 8/31/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-023777
Description     : After Update Trigger for the Subscription Activation Object
                : 
                : 
******************************************************************************************/
trigger AH_SubscriptionActivation_AfterUpdate on Subscription_Activation__c (after update) 
{
    AH_SubsActvn_TriggerHandler handler = new AH_SubsActvn_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}