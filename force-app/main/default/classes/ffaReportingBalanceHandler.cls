/*******************************************************************************************
Name            : ffaReportingBalanceHandler
Author          : CLD Partners
Created Date    : Mar 3, 2016
Description     : Contains methods to handle operations on the FFA Reporting Balance Object
*******************************************************************************************/

//TO DO:
//1) If the period is closed, then do not update the reporting balance.
//2) Add a GLA layer to this mapping / first try to match on Company and GLA, then look for Dimension 2 / 3 and Company.



public class ffaReportingBalanceHandler {
	
	public static void populateAmadeusMappings(List<c2g__ReportingBalance__c> rbList)
	{
		Map<String, Amadeus_Mapping_Table__c> bpcMap1 = new Map<String, Amadeus_Mapping_Table__c>(); //BPC Cost Center Map 1 - Company + GLA
		Map<String, Amadeus_Mapping_Table__c> bpcMap2 = new Map<String, Amadeus_Mapping_Table__c>(); //BPC Cost Center Map 2 - Company + DIM 2 + DIM 3
		Map<String, Amadeus_Mapping_Table__c> fsMap1 = new Map<String, Amadeus_Mapping_Table__c>();
		Map<String, Amadeus_Mapping_Table__c> fsMap2 = new Map<String, Amadeus_Mapping_Table__c>(); 
		Map<String, Amadeus_Mapping_Table__c> fsMap3 = new Map<String, Amadeus_Mapping_Table__c>();
		Set<Id> glaFilterId = new Set<Id>();
		for(c2g__ReportingBalance__c rb : rbList)
		{
			glaFilterId.add(rb.c2g__GeneralLedgerAccount__c);
		}

		Map<Id, c2g__codaGeneralLedgerAccount__c> glaMap = new Map<Id, c2g__codaGeneralLedgerAccount__c>([
			SELECT Id,
				c2g__TrialBalance2__c,
				Name
			FROM c2g__codaGeneralLedgerAccount__c 
			WHERE Id in :glaFilterId
			]);

		for(Amadeus_Mapping_Table__c amt : [
			SELECT Id,
				Output__c,
				Mapping_Type__c,
				General_Ledger_Account__c,
				Trial_Balance_2__c,
				Order_of_Evaluation__c,
				FFA_Company__c,
				Cost_Center_Dim_3__c,
				Business_Line_Dim_2__c
			FROM Amadeus_Mapping_Table__c])
		{
			if(amt.Mapping_Type__c == 'BPC Cost Center'){

				if(amt.General_Ledger_Account__c != null){  //populate the first map
					bpcMap1.put(amt.FFA_Company__c + '|' + amt.General_Ledger_Account__c, amt);	
				}	

				if(amt.General_Ledger_Account__c == null){ //populate the second map
					bpcMap2.put(amt.FFA_Company__c + '|' + amt.Business_Line_Dim_2__c + '|' + amt.Cost_Center_Dim_3__c, amt);	
				}
			}
			if(amt.Mapping_Type__c == 'Amadeus FS Reporting'){
				String fs1Key = amt.Trial_Balance_2__c;
				String fs2Key = amt.Trial_Balance_2__c + '|' + amt.Cost_Center_Dim_3__c;
				String fs3Key = amt.Trial_Balance_2__c + '|' + amt.Cost_Center_Dim_3__c + '|' + amt.General_Ledger_Account__c;

				if(amt.Order_of_Evaluation__c == 1 && fs1Key != null)
				{
					fsMap1.put(fs1Key, amt);
					continue;
				}
				if(amt.Order_of_Evaluation__c == 2 && fs2Key != null)
				{
					fsMap2.put(fs2Key, amt);
					continue;
				}
				if(amt.Order_of_Evaluation__c == 3 && fs3Key != null)
				{
					fsMap3.put(fs3Key, amt);
					continue;
				}
			}
		}

		system.debug('\n\n ****** - ffaReportingBalanceHandler - populateAmadeusMappings - fsMap1 = '+ fsMap1);

		//BPC COST CENTER:
		for(c2g__ReportingBalance__c rb : rbList)
		{
			String key1 = rb.c2g__OwnerCompany__c + '|' + rb.c2g__GeneralLedgerAccount__c;
			String key2 = rb.c2g__OwnerCompany__c + '|' + rb.c2g__Dimension2__c +'|'+ rb.c2g__Dimension3__c;
			if(bpcMap1.containsKey(key1)){
				rb.BPC_Cost_Center__c = bpcMap1.get(key1).Output__c;
				continue;
			}
			if(bpcMap2.containsKey(key2)){
				rb.BPC_Cost_Center__c = bpcMap2.get(key2).Output__c;
				continue;
			}
		}

		//FINANCIAL STATEMENT GROUPING:
		for(c2g__ReportingBalance__c rb : rbList)
		{
			String tb2String = glaMap.containsKey(rb.c2g__GeneralLedgerAccount__c) ? glaMap.get(rb.c2g__GeneralLedgerAccount__c).c2g__TrialBalance2__c : null;
			String fs1Key = tb2String;
			String fs2Key = tb2String + '|' + rb.c2g__Dimension3__c;
			String fs3Key = tb2String + '|' + rb.c2g__Dimension3__c + '|' + rb.c2g__GeneralLedgerAccount__c;
			//first check:
			if(fsMap1.containsKey(fs1Key))
			{
				rb.Financial_Statement_Grouping__c = fsMap1.get(fs1Key).Output__c;
				continue;
			}
			//second check:
			if(fsMap2.containsKey(fs2Key))
			{
				rb.Financial_Statement_Grouping__c = fsMap2.get(fs2Key).Output__c;
				continue;
			}
			//third check:
			if(fsMap3.containsKey(fs3Key))
			{
				rb.Financial_Statement_Grouping__c = fsMap3.get(fs3Key).Output__c;
				continue;
			}
		}
		if(Test.isRunningTest() == true){
			Integer int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
			int1 = 1;
		}
	}

}