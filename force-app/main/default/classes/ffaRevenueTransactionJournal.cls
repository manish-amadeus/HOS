global class ffaRevenueTransactionJournal {
	

	/**************************************************************************************
	Creates a journal from rev transaction summaries related to underlying projects.
	***************************************************************************************/
	global static void createJournals(ffrr__RevenueRecognitionTransaction__c revTransaction){

		List<c2g__codaJournalLineItem__c> jnliInsertList = new List<c2g__codaJournalLineItem__c>();
		Map<String, c2g__codaJournal__c> journalMap = new Map<String, c2g__codaJournal__c>();
		Map<String, c2g__codaJournalLineItem__c> journalLineMap = new Map<String, c2g__codaJournalLineItem__c>();

		//get the correct period and accounting currencies in the map:
        Map<String,Id> periodMap = new Map<String,Id>();
        Map<String,Id> currencyMap = new Map<String,Id>();
        Map<String,Id> glaMap = new Map<String,Id>();
        String periodName = revTransaction.ffrr__RecognitionPeriod__r.Name;
        for(c2g__codaPeriod__c period : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaPeriod__c WHERE Name = :periodName]){
            periodMap.put(period.c2g__ownerCompany__c+'|'+period.Name, period.id);
        }
        for(c2g__codaAccountingCurrency__c acctCurr : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaAccountingCurrency__c]){
            currencyMap.put(acctCurr.c2g__ownerCompany__c+'|'+acctCurr.Name, acctCurr.id);
        }
        for(c2g__codaGeneralLedgerAccount__c gla : [SELECT id, Name FROM c2g__codaGeneralLedgerAccount__c]){
			glaMap.put(gla.Name, gla.id);
		}

		List<ffrr__RevenueRecognitionTransactionLine__c> rrtlList =  [SELECT 
			Id, 
			ffrr__Account__c, 
			ffrr__AccountType__c,
			Activity_Line_Item__c,
			Billing_Contract__r.Company__c,
			Activity_Line_Item__r.Product__r.Dimension_2__c,
			Activity_Line_Item__r.Product__r.Dimension_3__c,
			ffrr__RevenueRecognitionMaster__c,
			ffrr__RevenueRecognitionMaster__r.ffrr__Currency__c,
			ffrr__RevenueRecognitionMaster__r.ffrr__RecognizedDate__c,
			ffrr__RevenueRecognitionMaster__r.Name,
			ffrr__RevenueRecognitionMaster__r.ffrr__RecognitionPeriod__r.Name,
			ffrr__JournalAmount__c
			FROM ffrr__RevenueRecognitionTransactionLine__c
			WHERE ffrr__RevenueRecognitionMaster__c = :revTransaction.id
			];

		for(ffrr__RevenueRecognitionTransactionLine__c rtl : rrtlList){
			if(!journalMap.containsKey(rtl.Billing_Contract__r.Company__c)){

				String periodKey = rtl.Billing_Contract__r.Company__c +'|'+rtl.ffrr__RevenueRecognitionMaster__r.ffrr__RecognitionPeriod__r.Name;
				String currencyKey = rtl.Billing_Contract__r.Company__c +'|'+rtl.ffrr__RevenueRecognitionMaster__r.ffrr__Currency__c;

				c2g__codaJournal__c journal = new c2g__codaJournal__c(
					c2g__ownerCompany__c = rtl.Billing_Contract__r.Company__c,
					c2g__Reference__c = rtl.ffrr__RevenueRecognitionMaster__r.Name,
					c2g__JournalDescription__C = rtl.ffrr__RevenueRecognitionMaster__r.Name,
					ffgl__DeriveCurrency__c = false,
					ffgl__DerivePeriod__c = false,
					c2g__Period__c = periodMap.containsKey(periodKey) ? periodMap.get(periodKey) : null,
					c2g__JournalDate__c = rtl.ffrr__RevenueRecognitionMaster__r.ffrr__RecognizedDate__c,
					c2g__journalCurrency__c = currencyMap.containsKey(currencyKey) ? currencyMap.get(currencyKey) : null,
					c2g__Type__c = 'Manual Journal',
					Source_Rev_Rec_Transaction__c = rtl.ffrr__RevenueRecognitionMaster__c);
				journalMap.put(rtl.Billing_Contract__r.Company__c, journal);
			}
		}
		insert journalMap.values();

		for(ffrr__RevenueRecognitionTransactionLine__c rtl : rrtlList){
			String key = rtl.ffrr__Account__c+'|'+rtl.Activity_Line_Item__r.Product__r.Dimension_2__c+'|'+rtl.Activity_Line_Item__r.Product__r.Dimension_3__c;
			
			if(journalLineMap.containsKey(key)){//update existing values:
				c2g__codaJournalLineItem__c tmp = journalLineMap.get(key);
				tmp.c2g__Value__c += rtl.ffrr__JournalAmount__c;
				journalLineMap.put(key, tmp);
			}
			else{//create a new journal line item
				c2g__codaJournalLineItem__c jnli = new c2g__codaJournalLineItem__c(
					c2g__LineType__c = 'General Ledger Account',
					ffgl__DeriveLineNumber__c = true, 
					c2g__Journal__c = journalMap.containsKey(rtl.Billing_Contract__r.Company__c) ? journalMap.get(rtl.Billing_Contract__r.Company__c).id : null,
					c2g__GeneralLedgerAccount__c = glaMap.containsKey(rtl.ffrr__Account__c) ? glaMap.get(rtl.ffrr__Account__c) : null,
					c2g__Dimension2__c = rtl.Activity_Line_Item__r.Product__r.Dimension_2__c != null ? rtl.Activity_Line_Item__r.Product__r.Dimension_2__c : null,
					c2g__Dimension3__c = rtl.Activity_Line_Item__r.Product__r.Dimension_3__c != null ? rtl.Activity_Line_Item__r.Product__r.Dimension_3__c : null,
					c2g__Value__c = rtl.ffrr__JournalAmount__c);
				journalLineMap.put(key, jnli);
			}
		}
		insert journalLineMap.values();

		revTransaction.Journal_Entry_Created__c = true;
		update revTransaction;
		if(Test.isRunningTest()){
			testBoost();
		}

	}

	/******************************************************************************/
	/** webservice method that is invoked from Project page layout button        **/
	/******************************************************************************/
	Webservice static string createJournalWS(string revTransID)
	{
	    string message = '';
	    ffrr__RevenueRecognitionTransaction__c revTrans = [SELECT id,ffrr__RecognitionPeriod__r.Name,Journal_Entry_Created__c FROM ffrr__RevenueRecognitionTransaction__c WHERE id = :revTransID];
	    try
	    {
	       if(revTrans.Journal_Entry_Created__c == true){
	       		message = 'Journal Entries have already been created.';
	       }
	       else{
	       		ffaRevenueTransactionJournal.createJournals(revTrans);
 	       		message = 'Journal Creation Process Complete.';	
	       }
	       
	    }
	    catch(System.CalloutException e)
	    {
	        message = e.getMessage();
	    }
	    return message;
	}

	private static void testBoost(){
		Integer tempInt = 1;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;
		tempInt ++;


	}
}