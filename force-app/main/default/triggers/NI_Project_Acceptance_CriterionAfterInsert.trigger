/****************************************************************************************
Name            : NI_Project_Acceptance_CriterionAfterInsert Trigger
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Handles all after insert trigger logic 
                : 
******************************************************************************************/
trigger NI_Project_Acceptance_CriterionAfterInsert on NI_Project_Acceptance_Criterion__c (after insert) 
{
    if (!NI_FUNCTIONS.bypassTriggerCode('NI Project Acceptance Criteria'))
    { 
        NI_Project_Acceptance_TriggerHandler handler = new NI_Project_Acceptance_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);
        
    } 
}