/****************************************************************************************
Name            : AH_PSA_Milestone_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 07/28/2014
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Milestone_AfterUpdate on pse__Milestone__c (after update) 
{
    if (NI_TriggerManager.is1stUpdate_Milestone)
    {        
        NI_PSA_Milestone_TriggerHandler handler = new NI_PSA_Milestone_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}