/****************************************************************************************
Name            : AH_PSA_Milestone_AfterUnDelete Trigger
Author          : Stuart Emery
Created Date    : 07/28/2014
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Milestone_AfterUnDelete on pse__Milestone__c (after undelete) 
{
    NI_PSA_Milestone_TriggerHandler handler = new NI_PSA_Milestone_TriggerHandler();
    handler.OnAfterUnDelete(Trigger.new);
}