/*******************************************************************************************
Name            : ffaPayableInvoiceTrigger
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Trigger on SIN to call various handler methods
*******************************************************************************************/

trigger ffaSalesCreditNoteTrigger on c2g__codaCreditNote__c (before insert) {

	// Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaSalesCreditNoteTrigger__c == true)
    {
        System.Debug('************ ffaSalesCreditNoteTrigger trigger is disabled');
        return;
    }
    
    ffaSalesCreditNoteTriggerHandler.defaultSINValues(Trigger.new);

}