/*******************************************************************************************
Name            : ffaRequisitionTrigger
Author          : CLD Partners
Created Date    : Mar 4, 2016
Description     : Trigger on Requisition SCM object
*******************************************************************************************/

trigger ffaRequisitionTrigger on SCMC__Requisition__c (before insert, before update) {
	// Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaRequisitionTrigger__c == true)
    {
        System.Debug('************ ffaRequisitionTrigger trigger is disabled');
        return;
    }

    ffaRequisitionHandler.setFirstLevelApprover(trigger.new);
    
}