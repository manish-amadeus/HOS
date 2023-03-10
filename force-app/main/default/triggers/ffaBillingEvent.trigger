/****************************************************************************************
Name            : ffaBillingEvent
Author          : CLD
Created Date    : May 24, 2016
Description     : Contains necessary functions for invoicing from FFA
******************************************************************************************/
trigger ffaBillingEvent on pse__Billing_Event__c (after insert) {

	//=======================================================================
    // Updates for Invoicing Out of FFA
    //  1) Populate the Collector
	//  2) Populate the Remittance Info Lookup Field
	//=======================================================================
	List<pse__Billing_Event__c> beToUpdate = [SELECT id,
	 	pse__Project__r.pse__Account__c, 
	 	pse__Project__r.pse__Account__r.Remittance_Info__c,
	 	pse__Project__r.pse__Region__r.ffpsai__OwnerCompany__r.Remittance_Info__c,
	 	collector__c, 
	 	remittance_info__c 
	 	FROM pse__Billing_Event__c WHERE id in :trigger.new];
	Set<Id> accountIds = new Set<Id>();
	for(pse__Billing_Event__c be : beToUpdate){
		accountIds.add(be.pse__Project__r.pse__Account__c);
	}	
    Map<Id,Id> collectorMap = billingContractHandler.getAccountTeam(accountIds);
    
    //loop through and update values:
    for(pse__Billing_Event__c be : beToUpdate){
    	be.remittance_info__c = be.pse__Project__r.pse__Region__r.ffpsai__OwnerCompany__r.Remittance_Info__c != null ? be.pse__Project__r.pse__Region__r.ffpsai__OwnerCompany__r.Remittance_Info__c : null;
    	be.remittance_info__c = be.pse__Project__r.pse__Account__r.Remittance_Info__c != null ? be.pse__Project__r.pse__Account__r.Remittance_Info__c : be.remittance_info__c;
    	be.collector__c = collectorMap.containsKey(be.pse__Project__r.pse__Account__c) ? collectorMap.get(be.pse__Project__r.pse__Account__c) : null;
    }
    update beToUpdate;
}