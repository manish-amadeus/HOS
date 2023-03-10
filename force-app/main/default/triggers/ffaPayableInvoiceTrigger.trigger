/*******************************************************************************************
Name            : ffaPayableInvoiceTrigger
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Trigger on PIN to call the Prepaid Journal Logic
*******************************************************************************************/

trigger ffaPayableInvoiceTrigger on c2g__codaPurchaseInvoice__c (after update) {

	// Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaPayableInvoiceTrigger__c == true)
    {
        System.Debug('************ ffaPayableInvoiceTrigger trigger is disabled');
        return;
    }

    Set<Id> pinIds = new Set<Id>();
    for(c2g__codaPurchaseInvoice__c pin : Trigger.new)
    {
    	if(pin.c2g__InvoiceStatus__c == 'Complete' && Trigger.oldmap.get(pin.id).c2g__InvoiceStatus__c != 'Complete'){
    		pinIds.add(pin.id);	
    	}
    }
    if(!pinIds.isEmpty()){
    	ffaPrepaidExpenseHandler.createPrepaidJournalsFuture(pinIds);	 //call the future method to create prepaid journals
    }
    
}