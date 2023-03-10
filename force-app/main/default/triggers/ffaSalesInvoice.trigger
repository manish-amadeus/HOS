/*******************************************************************************************
Name            : ffaPayableInvoiceTrigger
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Trigger on SIN to call various handler methods
*******************************************************************************************/

trigger ffaSalesInvoice on c2g__codaInvoice__c (before insert, before update) {

	// Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaSalesInvoice__c == true)
    {
        System.Debug('************ ffaPayableInvoiceTrigger trigger is disabled');
        return;
    }
    if(Trigger.isInsert){
    	ffaSalesInvoiceTriggerHandler.moveInvoiceDate_MonthEnd(trigger.new);
    	ffaSalesInvoiceTriggerHandler.defaultHeaderValues(trigger.new);	
    }
    if(Trigger.isUpdate){
    	ffaSalesInvoiceTriggerHandler.handleEmailingInvoice(trigger.new, trigger.oldMap);
    }
    
    
}