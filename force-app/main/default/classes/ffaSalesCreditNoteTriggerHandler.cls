/*******************************************************************************************
Name            : ffaSalesInvoiceTriggerHandler
Author          : CLD Partners
Created Date    : Jul 15, 2016
Description     : Contains methods that interact with Sales Credit Notes
*******************************************************************************************/
public class ffaSalesCreditNoteTriggerHandler {

	//==================================================================================
	//		Method for defaulting fields from the Sales Invoice.
	//==================================================================================
	public static void defaultSINValues (List<c2g__codaCreditNote__c> newTrigger){
		Set<Id> sinIds = new Set<Id>();
		for(c2g__codaCreditNote__c cn : newTrigger){
			sinIds.add(cn.c2g__Invoice__c);
		}
		Map<Id,c2g__codaInvoice__c> sinMap = new Map<Id,c2g__codaInvoice__c>([
			SELECT id,
				Remittance_Info__c,
				Billing_Contract__c
			FROM c2g__codaInvoice__c
			WHERE id in :sinIds]);
		for(c2g__codaCreditNote__c cn : newTrigger){
			cn.Remittance_Info__c = sinMap.containsKey(cn.c2g__Invoice__c) && sinMap.get(cn.c2g__Invoice__c).Remittance_Info__c != null ? sinMap.get(cn.c2g__Invoice__c).Remittance_Info__c : cn.Remittance_Info__c;
			cn.Billing_Contract__c = sinMap.containsKey(cn.c2g__Invoice__c) && sinMap.get(cn.c2g__Invoice__c).Billing_Contract__c != null ? sinMap.get(cn.c2g__Invoice__c).Billing_Contract__c : cn.Billing_Contract__c;
		}
	}

}