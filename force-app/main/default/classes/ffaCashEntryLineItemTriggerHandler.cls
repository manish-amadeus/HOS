/*******************************************************************************************
Name            : ffaCashEntryLine
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Contains logic to process ffa cash entry trigger functions
*******************************************************************************************/

public class ffaCashEntryLineItemTriggerHandler {
	public static void syncCSHandPINDimensions(List<c2g__codaCashEntryLineItem__c> cashLines){
		Set<Id> cashEntryIds = new Set<Id>();
		Map<String, Id> dimension2Map = new Map<String, Id>(); //key is the payment id + account id, value is dim 2 id
		Map<String, Id> dimension3Map = new Map<String, Id>(); //key is the payment id + account id, value is dim 3 id

		//Step 1: gather the cash entry Ids:
		for(c2g__codaCashEntryLineItem__c line : cashLines)
		{
			cashEntryIds.add(line.c2g__CashEntry__c);
		}

		//Step 2: Query the Cash Entry / Payment and related Payment Detail records.
		Map<Id, c2g__codaCashEntry__c> cashEntryMap = new Map<Id, c2g__codaCashEntry__c>([
			SELECT Id, c2g__PaymentNumber__c FROM c2g__codaCashEntry__c WHERE Id in :cashEntryIds]);

		List<c2g__codaPayment__c> paymentList = [
		SELECT
			id,
			(SELECT
			Id,
			c2g__Account__c,
			c2g__TransactionLineItem__r.c2g__Dimension2__c,
			c2g__TransactionLineItem__r.c2g__Dimension3__c,
			c2g__DocumentNumber__c
			FROM c2g__PaymentLineItems__r)
		FROM
			c2g__codaPayment__c
		WHERE id in (SELECT c2g__PaymentNumber__c FROM c2g__codaCashEntry__c WHERE Id in :cashEntryIds)];

		system.debug('****** ffaCashEntryLineItemTriggerHandler - paymentList = ' + paymentList);

		//step 3: populate the dimension maps:
		for(c2g__codaPayment__c payment : paymentList)
		{
			for(c2g__codaPaymentLineItem__c pli : payment.c2g__PaymentLineItems__r)
			{
				String key = payment.id + '|' + pli.c2g__Account__c;
				if(pli.c2g__TransactionLineItem__r.c2g__Dimension2__c != null){
					dimension2Map.put(key, pli.c2g__TransactionLineItem__r.c2g__Dimension2__c);
				}
				if(pli.c2g__TransactionLineItem__r.c2g__Dimension3__c != null){
					dimension3Map.put(key, pli.c2g__TransactionLineItem__r.c2g__Dimension3__c);
				}
			}
		}

		//step 4: Loop back through the cash entry line items and update:
		for(c2g__codaCashEntryLineItem__c line : cashLines)
		{
			line.ffcash__DeriveAccountDimensions__c = false;
			String key = '';
			if(cashEntryMap.containsKey(line.c2g__CashEntry__c) && cashEntryMap.get(line.c2g__CashEntry__c).c2g__PaymentNumber__c != null){
				key = cashEntryMap.get(line.c2g__CashEntry__c).c2g__PaymentNumber__c + '|' + line.c2g__Account__c;
			}
			if(dimension2Map.containsKey(key)){
				line.c2g__AccountDimension2__c = dimension2Map.get(key);
			}
			if(dimension3Map.containsKey(key)){
				line.c2g__AccountDimension3__c = dimension3Map.get(key);
			}
		}
	}
	public static void syncAnalysisFields(List<c2g__codaCashEntryLineItem__c> newTrigger){
		Set<Id>cashIds = new Set<Id>();
		for(c2g__codaCashEntryLineItem__c c : [SELECT Id, c2g__CashEntry__r.c2g__Transaction__c FROM c2g__codaCashEntryLineItem__c WHERE  Id in:newTrigger]){
			if(c.c2g__CashEntry__r.c2g__Transaction__c == null)
			cashIds.add(c.id);
		}

		Map<String,Id> dim2Map = new Map<String,Id>();
		Map<String,Id> dim3Map = new Map<String,Id>();
		Map<String,Id> companyMap = new Map<String,Id>();
		for(c2g__codaDimension2__c dim2 : [SELECT Id, Name FROM c2g__codaDimension2__c]){
			dim2Map.put(dim2.Name, dim2.id);
		}
		for(c2g__codaDimension3__c dim3 : [SELECT Id, Name FROM c2g__codaDimension3__c]){
			dim3Map.put(dim3.Name, dim3.id);
		}
		for(c2g__codaCompany__c company : [SELECT Id, Name FROM c2g__codaCompany__c]){
			companyMap.put(company.Name, company.id);
		}
		for(c2g__codaCashEntryLineItem__c cLine : newTrigger){
			if(cashIds.contains(cline.id)){
				cLine.c2g__AccountDimension2__c = dim2Map.containsKey(cLine.Dimension_2_Reference__c) ? dim2Map.get(cLine.Dimension_2_Reference__c) : null;
				cLine.c2g__AccountDimension3__c = dim3Map.containsKey(cLine.Dimension_3_Reference__c) ? dim3Map.get(cLine.Dimension_3_Reference__c) : null;
				cLine.Destination_Company__c = companyMap.containsKey(cLine.Destination_Company_Reference__c) ? companyMap.get(cLine.Destination_Company_Reference__c) : null;
			}
		}
	}
}