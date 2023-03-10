/*******************************************************************************************
Name            : ffaReportingBalanceTrigger
Author          : CLD Partners
Created Date    : Mar 4, 2016
Description     : Trigger on Reporting Balance Object
*******************************************************************************************/

trigger ffaReportingBalanceTrigger on c2g__ReportingBalance__c (before insert, before update) {
	// Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaReportingBalanceTrigger__c == true)
    {
        System.Debug('************ ffaReportingBalanceTrigger trigger is disabled');
        return;
    }
    ffaReportingBalanceHandler.populateAmadeusMappings(trigger.new);
	
}