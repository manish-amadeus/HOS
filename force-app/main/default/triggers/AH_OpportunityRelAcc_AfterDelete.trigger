/****************************************************************************************
Name            : AH_OpportunityRelAcc_AfterDelete
Author          : Ria Chawla
Created Date    : 04/23/2018
Last Mod Date   : 05/04/2018
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Call the After Delete Methods in the AH_OpportunityRelAcc_TriggerHandler Class
:
******************************************************************************************/
trigger AH_OpportunityRelAcc_AfterDelete on AH_Opportunity_Related_Account__c (after delete) {
    if (!NI_FUNCTIONS.bypassTriggerCode('AH OPPORTUNITY RELATED ACCOUNT'))
    {
        AH_OpportunityRelAcc_TriggerHandler handler = new AH_OpportunityRelAcc_TriggerHandler();
        handler.onAfterDelete(Trigger.old);
    }
    
}