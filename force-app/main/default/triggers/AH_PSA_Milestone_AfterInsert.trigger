/****************************************************************************************
Name            : AH_PSA_Milestone_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 07/28/2014
Last Mod Date   : 03/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_PSA_Milestone_AfterInsert on pse__Milestone__c (after insert) 
{
    if (NI_TriggerManager.is1stInsert_Milestone)
    {    
        NI_PSA_Milestone_TriggerHandler handler = new NI_PSA_Milestone_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);
    }
}