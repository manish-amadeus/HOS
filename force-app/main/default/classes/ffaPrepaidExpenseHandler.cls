/*******************************************************************************************
Name            : ffaPrepaidExpenseHandler
Author          : CLD Partners
Created Date    : Feb 23, 2016
Description     : Contains methods to build out prepaid expense relief journals in ffaUtilities
*******************************************************************************************/

global class ffaPrepaidExpenseHandler {
	
	@future
	public static void createPrepaidJournalsFuture(Set<Id> pinIds)
	{
		String returnMessage = createPrepaidJournals(pinIds);
	}

	public static String createPrepaidJournals(Set<Id> pinIds)
	{
		String returnMessage = '';
		Set<Id> companyIds = new Set<Id>();
		Map<String, Id> periodMap = new Map<String, Id>();
		Map<String, c2g__codaJournal__c> journalInsertMap = new Map<String, c2g__codaJournal__c>();
		List<c2g__codaJournalLineItem__c> journalLineInsertList = new List<c2g__codaJournalLineItem__c>();
		Integer totalJournalsCreated = 0;

		//Step 1: Query the PIN line items and setup some initial data / maps:
		List<c2g__codaPurchaseInvoiceExpenseLineItem__c> prepaidLineList = [
			SELECT Id,
				Prepaid_Start_Date__c,
				Prepaid_End_Date__c,
				Prepaid_Reverse_GLA__c,
				Prepaid_Reverse_Dim_3__c,
				c2g__GeneralLedgerAccount__c,
				c2g__NetValue__c,
				c2g__Dimension1__c,
				c2g__LineDescription__c,
				c2g__Dimension2__c,
				c2g__Dimension3__c,
				c2g__Dimension4__c,
				c2g__PurchaseInvoice__c,
				c2g__PurchaseInvoice__r.Name,
				c2g__PurchaseInvoice__r.c2g__ownerCompany__c,
				c2g__PurchaseInvoice__r.c2g__InvoiceCurrency__c,
				c2g__PurchaseInvoice__r.c2g__Account__r.name,
				c2g__PurchaseInvoice__r.c2g__Period__r.c2g__StartDate__c,
				Prepaid_Journals_Created__c
			FROM c2g__codaPurchaseInvoiceExpenseLineItem__c
			WHERE c2g__PurchaseInvoice__c in : pinIds
			AND Prepaid_Reverse_GLA__c != null 
			AND Prepaid_Start_Date__c != null
			AND Prepaid_End_Date__c != null
			AND Prepaid_Reverse_Dim_3__c != null
			AND Prepaid_Journals_Created__c = false];
		if(prepaidLineList.size() == 0)
		{
			returnMessage = 'No Payable Invoice Expense Lines were processed...ensure the prepaid details are filled out and prepaid journals do not already exist.';
			return returnMessage;
		}

		for(c2g__codaPurchaseInvoiceExpenseLineItem__c line : prepaidLineList)
		{
			companyIds.add(line.c2g__PurchaseInvoice__r.c2g__ownerCompany__c);
		}

		for(c2g__codaPeriod__c period : [SELECT Id, c2g__StartDate__c, c2g__ownerCompany__c FROM c2g__codaPeriod__c 
			WHERE c2g__ownerCompany__c in :companyIds AND c2g__Closed__c = false])
		{
			String key = period.c2g__ownerCompany__c + '|' + period.c2g__StartDate__c.format();
			periodMap.put(key, period.id);
		}

		//Step2: loop through each expense line and build out the necessary journals:
		for(c2g__codaPurchaseInvoiceExpenseLineItem__c line : prepaidLineList)
		{
			Integer jnlsCreated = 0;
			Integer jnlsToCreate = line.Prepaid_Start_Date__c.monthsBetween(line.Prepaid_End_Date__c);
			Integer jnlsToCreateDescription = jnlsToCreate +1;
			Integer totalDays = line.Prepaid_Start_Date__c.daysBetween(line.Prepaid_End_Date__c) + 1;
			system.debug('\n\n **** ffaPrepaidExpenseHandler - createPrepaidJournals - totalDays = '+ totalDays);
			Double totalDaysDouble = totalDays;
			Decimal totalAmountReleased = 0;
			Date jnlDate = line.Prepaid_Start_Date__c;
			Date pinPeriodStart = line.c2g__PurchaseInvoice__r.c2g__Period__r.c2g__StartDate__c;	

			while(jnlsCreated <= jnlsToCreate)
			{
				Integer daysinPeriod = Date.daysinMonth(jnlDate.year(), jnlDate.month());
				Integer allocationdays = daysinPeriod;
				if(jnlsCreated == 0)//if it's the first then calculate the starting 
				{
					allocationdays = daysinPeriod - line.Prepaid_Start_Date__c.day()+1;
				}
				if(jnlsCreated == jnlsToCreate)//if this is the last item then account for potential partial periods
				{
					allocationdays = line.Prepaid_End_Date__c.day() -1;
				}
				Double allocationdaysDouble = allocationdays;
				system.debug('\n\n **** ffaPrepaidExpenseHandler - createPrepaidJournals - allocationdays = '+ allocationdays);

				Decimal jnlAmount = ((allocationdaysDouble / totalDaysDouble) * line.c2g__NetValue__c).setScale(2); 
				totalAmountReleased += jnlAmount;

				if(jnlsCreated == jnlsToCreate)//if this is the last item then also account for rounding errors
				{
					if(totalAmountReleased != line.c2g__NetValue__c)
					{
						jnlAmount -= (totalAmountReleased - line.c2g__NetValue__c);
					}
				}

				Date periodStartDate = jnlDate < pinPeriodStart ? pinPeriodStart : jnlDate.toStartOfMonth();
				String periodKey = line.c2g__PurchaseInvoice__r.c2g__OwnerCompany__c + '|' + periodStartDate.format();
				jnlsCreated += 1;
				//totalJournalsCreated += 1;

				system.debug('\n\n **** ffaPrepaidExpenseHandler - createPrepaidJournals - jnlAmount = '+ jnlAmount);

				c2g__codaJournal__c jnl = new c2g__codaJournal__c(
					c2g__ownerCompany__c = line.c2g__PurchaseInvoice__r.c2g__ownerCompany__c,
					c2g__journalCurrency__c = line.c2g__PurchaseInvoice__r.c2g__InvoiceCurrency__c,
					c2g__journaldescription__c = 'Prepaid Expense Recognition for '+ line.c2g__PurchaseInvoice__r.Name,
					Source_Payable_Invoice__c = line.c2g__PurchaseInvoice__c,
					c2g__Reference__c = 'Prepaid from '+line.c2g__PurchaseInvoice__r.Name,
					c2g__journaldate__c = jnlDate < pinPeriodStart ? pinPeriodStart : jnlDate.toStartOfMonth(),
					c2g__Period__c = periodMap.containsKey(periodKey) ? periodMap.get(periodKey) : null,
					Prepaid_External_ID__c = line.c2g__PurchaseInvoice__c + '|' + jnlDate.format(),
					ffgl__DeriveCurrency__c = false);
				journalInsertMap.put(jnl.Prepaid_External_ID__c, jnl);

				c2g__codaJournalLineItem__c creditLine = new c2g__codaJournalLineItem__c(
					c2g__GeneralLedgerAccount__c = line.c2g__GeneralLedgerAccount__c,
					c2g__lineType__c = 'General Ledger Account',
					c2g__LineDescription__c = line.c2g__PurchaseInvoice__r.c2g__Account__r.name + ' - ' + line.c2g__LineDescription__c + ' - JNL ('+ jnlsCreated + ' of '+jnlsToCreateDescription + ')',
					c2g__Dimension1__c = line.c2g__Dimension1__c,
					c2g__Dimension2__c = line.c2g__Dimension2__c,
					c2g__Dimension3__c = line.c2g__Dimension3__c,
					c2g__Dimension4__c = line.c2g__Dimension4__c,
					c2g__Value__c = -jnlAmount, //negative
					Prepaid_External_ID__c = line.c2g__PurchaseInvoice__c + '|' + jnlDate.format());
				journalLineInsertList.add(creditLine);

				c2g__codaJournalLineItem__c debitLine = new c2g__codaJournalLineItem__c(
					c2g__GeneralLedgerAccount__c = line.Prepaid_Reverse_GLA__c,
					c2g__lineType__c = 'General Ledger Account',
					c2g__LineDescription__c = line.c2g__PurchaseInvoice__r.c2g__Account__r.name + ' - ' + line.c2g__LineDescription__c + ' - JNL ('+ jnlsCreated + ' of '+jnlsToCreateDescription + ')',
					c2g__Dimension1__c = line.c2g__Dimension1__c,
					c2g__Dimension2__c = line.c2g__Dimension2__c,
					c2g__Dimension3__c = line.Prepaid_Reverse_Dim_3__c,
					c2g__Dimension4__c = line.c2g__Dimension4__c,
					c2g__Value__c = jnlAmount, //positive
					Prepaid_External_ID__c = line.c2g__PurchaseInvoice__c + '|' + jnlDate.format());
				journalLineInsertList.add(debitline);

				//increment some key variables:
				jnlDate = jnlDate.addMonths(1);
			}
			line.Prepaid_Journals_Created__c = true;
		}//end loop through PIN lines

		//Step 3: Hammer update the JNLs and JNL Lines:
		try{
			insert journalInsertMap.values();
			update prepaidLineList;
		}
		 catch (Exception e){
		 	system.debug('\n\n **** ffaPrepaidExpenseHandler - createPrepaidJournals - ERROR INSERTING JNLs = '+ e.getMessage());
		 }

		for(c2g__codaJournalLineItem__c jnlLine : journalLineInsertList){
			if(journalInsertMap.containsKey(jnlLine.Prepaid_External_ID__c)){
				jnlLine.c2g__Journal__c = journalInsertMap.get(jnlLine.Prepaid_External_ID__c).id;
			}
		}
		try{
			insert journalLineInsertList;
			totalJournalsCreated = journalInsertMap.size();
			returnMessage = totalJournalsCreated + ' Journals were created sucessfully!';
		}
		 catch (Exception e){
		 	system.debug('\n\n **** ffaPrepaidExpenseHandler - createPrepaidJournals - ERROR INSERTING JNL LINES = '+ e.getMessage());
		 	returnMessage = 'Woops there was an error: '+ e.getMessage();
		 }
		 return returnMessage;
	}

	/******************************************************************************/
    /** webservice method that is invoked from PIN page layout button        **/
    /******************************************************************************/
    Webservice static string createPrepaidJournals_WS(string pinID)
    {
        string message = '';
        Set<Id> pinIds = new Set<Id>();
        pinIds.add(pinId);
        try{
           message = ffaPrepaidExpenseHandler.createPrepaidJournals(pinIds);
        }
        catch(System.CalloutException e){
            message = e.getMessage();
        }
        return message;
    }

}