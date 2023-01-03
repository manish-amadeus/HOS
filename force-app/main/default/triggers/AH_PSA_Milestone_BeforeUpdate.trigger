/****************************************************************************************
Name            : AH_PSA_Milestone_BeforeUpdate Trigger
Author          : Stuart Emery
Created Date    : 07/28/2014
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Milestone_BeforeUpdate on pse__Milestone__c (before update) 
{
    if (NI_TriggerManager.is1stUpdate_Milestone)
    {    
        NI_PSA_Milestone_TriggerHandler handler = new NI_PSA_Milestone_TriggerHandler();
        handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}