/**********************************************************
*************************************
Name 			: SLTC_OpportunityTeamMember_BeforeDelete
Author 			: Lamu Sreeharsha
Created Date 	: 4/18/2022
Last Mod Date 	:  4/25/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	: 
Description 	: Trigger used to call beforeDelete events.
***********************************************************
*************************************/

trigger SLTC_OpportunityTeamMember_BeforeDelete on OpportunityTeamMember (before delete) {
    if(trigger.isBefore){
        sltc_OppTeamMember_TriggerHandler handler = new sltc_OppTeamMember_TriggerHandler();
        handler.onBeforeDelete(Trigger.Old);
    }
}