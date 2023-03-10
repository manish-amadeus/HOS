/*******************************************************************************************
Name            : ffaPOLineItemTrigger
Author          : CLD Partners
Created Date    : Mar 4, 2016
Description     : Trigger on PO Line Item SCM object
*******************************************************************************************/

trigger ffaPOLineItemTrigger on SCMC__Purchase_Order_Line_Item__c (before insert, after insert, after update) {
	// Check to see if trigger is enabled before continuing
    NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if(ffaTriggers.Bypass_ffaPOLineItemTrigger__c == true)
    {
        System.Debug('************ ffaPOLineItemTrigger trigger is disabled');
        return;
    }

    if(Trigger.isBefore){
    	ffaRequisitionHandler.setPODefaultValues(trigger.new);	
    }
    if(Trigger.isAfter){
    	ffaRequisitionHandler.setPOHeaderDefaultValues(trigger.new);	
    }
}