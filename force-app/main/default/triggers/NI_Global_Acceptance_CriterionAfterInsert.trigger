/****************************************************************************************
Name            : NI_Global_Acceptance_CriterionAfterInsert Trigger
Author          : Supriya Galinde
Created Date    : 3/20/2017
Last Mod Date   : 4/6/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Handles all after insert trigger logic 
                : 
******************************************************************************************/
trigger NI_Global_Acceptance_CriterionAfterInsert on NI_Global_Acceptance_Criterion__c (after insert) 
{
	 if (!NI_FUNCTIONS.bypassTriggerCode('NI Global Acceptance Criteria'))
        {
            system.debug('triggerAfterInsert');
          NI_Global_Acceptance_TriggerHandler handler = new NI_Global_Acceptance_TriggerHandler();
          handler.OnAfterInsert(Trigger.new);
        } 
}