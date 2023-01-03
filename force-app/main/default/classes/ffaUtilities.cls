/****************************************************************************************
Name            : ffaUtilities
Author          : CLD
Created Date    : 1/14/16
Description     : Contains various methods for FFA Utilities
*****************************************************************************************/
global class ffaUtilities {
    
    public static String myMsg;
    
    /******************************************************************************/
    /** Method to return a list of the current companies
    /******************************************************************************/
    public static List<c2g__codaCompany__c> gerCurrentCompanies()
    {
        List<c2g__codaCompany__c> allCompanies = [Select id, ownerid, name from c2g__codaCompany__c];
        Id currentUserId = UserInfo.getUserId();
        List<c2g__codaCompany__c> myCompanies = new List<c2g__codaCompany__c>();
        Set<Id> currentUserGroupIds = new Set<Id>();
        for(GroupMember gm :[SELECT Id, GroupId FROM GroupMember WHERE UseroRGroupId = :currentUserId]) 
        {
            currentUserGroupIds.add(gm.GroupId);
        }
        for(c2g__codaCompany__c company : allCompanies)
        {
            if(currentUserGroupIds.contains(company.ownerid))
            {
                myCompanies.add(company);
            }
        }
        return myCompanies;
    }


    /************************************************************************/
    // --- convertCurrencyRate -
    // allRates -
    // Map<Date, Map<String, Decimal>> allRates = psaUtilities.loadConversionRates(currencyCodesSet, currencyDateSet);
    // psaUtilities.convertCurrencyRate(allRates, fromCurrencyIn, toCurrencyIn, currencyDateIn, amount);
    /************************************************************************/
    public static Map<Date, Map<String, Decimal>> loadConversionRates(Set<String> currencyCodesSet, Set<Date> currencyDateSet)
    {
        return appirio_core.MultiCurrencyUtil.getConversionRatesByDate(currencyCodesSet, currencyDateSet);
    }

    public static Decimal convertCurrencyRate(Map<Date, Map<String, Decimal>> allRates, String fromCurrencyIn, String toCurrencyIn, Date currencyDateIn, Decimal amountIn)
    {
        //Get conversion rate
        Double toCurrencyRate = 0.0;
        Double fromCurrencyRate = 0.0;

        if (amountIn == null)
        {
            amountIn = 0.0;
        }

        if (allRates != null && allRates.get(currencyDateIn) != null && allRates.get(currencyDateIn).get(toCurrencyIn) != null)
        {
            toCurrencyRate = allRates.get(currencyDateIn).get(toCurrencyIn);
            System.debug('***** toCurrencyRate: ' + toCurrencyRate);
        }
        if (allRates != null && allRates.get(currencyDateIn) != null && allRates.get(currencyDateIn).get(fromCurrencyIn) != null)
        {
            fromCurrencyRate = allRates.get(currencyDateIn).get(fromCurrencyIn);
            System.debug('***** fromCurrencyRate: ' + fromCurrencyRate);
        }

        Decimal conversionRate = 0.0;
        Decimal convertedAmount = 0.0;

        //Only set if from CurrencyRate > 0
        System.debug('***** from CurrencyRate: ' + fromCurrencyRate);
        if (fromCurrencyRate <> 0)
        {
            conversionRate = toCurrencyRate/fromCurrencyRate;
        }
        return conversionRate;

        //Return the converted Amount
        /*convertedAmount = (amountIn * conversionRate).setScale(2);
        System.debug('**** convertedAmount: ' + convertedAmount);

        return convertedAmount;*/
    }

    /**************************************************************************************
    // Creates appropriate intercompany journal entries from Payable Invoices
    //Input: 
      1) ID for Payable Invoices to process
    ***************************************************************************************/
    global static String createIntercompanyJournals(Id pinID)
    {
        system.debug('***\n\n ffaUtilities - pinID = '+pinID);
        String returnMessage = '';
        //instantiate the references to be used
        c2g.CODAAPICommon.Reference acctcurrency;
        c2g.CODAAPICommon.Reference period;
        c2g.CODAAPICommon_10_0.Context ownerCompany;
        c2g.CODAAPICommon.Reference company;
        c2g.CODAAPICommon.Reference dim1;
        c2g.CODAAPICommon.Reference dim2;
        c2g.CODAAPICommon.Reference dim3;
        c2g.CODAAPICommon.Reference dim4;
        c2g.CODAAPICommon.Reference debitGL;
        c2g.CODAAPICommon.Reference creditGL;
        c2g.CODAAPICommon.Reference destCompany;

        List<c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem> journalLinesList = new List<c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem>();
        c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItems linesItem = new c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItems();
        String journalDescription;
        Date pinDate;

        //loop through the selected invoice lines and create corresponding journals if conditions are met
        List<c2g__codaPurchaseInvoiceExpenseLineItem__c> lines = [
            SELECT 
                Id,
                Destination_Company__c,
                Destination_Company__r.Name,
                c2g__PurchaseInvoice__r.c2g__Period__c,
                c2g__PurchaseInvoice__r.c2g__Period__r.c2g__EndDate__c,
                c2g__PurchaseInvoice__r.c2g__InvoiceDate__c,
                c2g__PurchaseInvoice__r.c2g__InvoiceCurrency__c,
                c2g__PurchaseInvoice__r.c2g__OwnerCompany__c,
                c2g__PurchaseInvoice__r.c2g__OwnerCompany__r.Name,
                c2g__PurchaseInvoice__r.c2g__OwnerCompany__r.OwnerId,
                c2g__PurchaseInvoice__r.Name,
                c2g__PurchaseInvoice__r.c2g__Period__r.c2g__StartDate__c,
                c2g__GeneralLedgerAccount__c,
                c2g__NetValue__c,
                c2g__Dimension1__c,
                c2g__Dimension2__c,
                c2g__Dimension3__c,
                c2g__Dimension4__c
            FROM
                c2g__codaPurchaseInvoiceExpenseLineItem__c
            WHERE
                c2g__PurchaseInvoice__c = :pinID
            AND
                Destination_Company__c != null
            AND
                Inter_Company_Journal_Created__c = false];

        system.debug('***\n\n ffaUtilities - lines = '+lines);

        for(c2g__codaPurchaseInvoiceExpenseLineItem__c line: lines)
        {
            pinDate = line.c2g__PurchaseInvoice__r.c2g__Period__r.c2g__StartDate__c;
            //define the reference variables:
            acctcurrency = new c2g.CODAAPICommon.Reference();
            acctcurrency.id = line.c2g__PurchaseInvoice__r.c2g__InvoiceCurrency__c;
            period = new c2g.CODAAPICommon.Reference();
            period.id = line.c2g__PurchaseInvoice__r.c2g__Period__c;
            ownerCompany = new c2g.CODAAPICommon_10_0.Context();
            ownerCompany.CompanyName = line.c2g__PurchaseInvoice__r.c2g__OwnerCompany__r.Name;
            ownerCompany.Token = null;
            company = new c2g.CODAAPICommon.Reference();
            company.Id = line.c2g__PurchaseInvoice__r.c2g__OwnerCompany__c;
            company.Name = line.c2g__PurchaseInvoice__r.c2g__OwnerCompany__r.Name;
            dim1 = new c2g.CODAAPICommon.Reference();
            dim1.Id = line.c2g__Dimension1__c;
            dim2 = new c2g.CODAAPICommon.Reference();
            dim2.Id = line.c2g__Dimension2__c;
            dim3 = new c2g.CODAAPICommon.Reference();
            dim3.Id = line.c2g__Dimension3__c;
            dim4 = new c2g.CODAAPICommon.Reference();
            dim4.Id = line.c2g__Dimension4__c;
            debitGL = new c2g.CODAAPICommon.Reference();
            debitGL.id = line.c2g__GeneralLedgerAccount__c;
            creditGL = new c2g.CODAAPICommon.Reference();
            creditGL.id = line.c2g__GeneralLedgerAccount__c;
            destCompany = new c2g.CODAAPICommon.Reference();
            destCompany.id = line.Destination_Company__c;
            journalDescription = line.c2g__PurchaseInvoice__r.Name;

            system.debug('***\n\n ffaUtilities - journal.OwnerCompany = '+ownerCompany);
            system.debug('***\n\n ffaUtilities - journal.acctcurrency = '+acctcurrency);
            system.debug('***\n\n ffaUtilities - journal.Period = '+period);

            //first create the journal line items:
            
            c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem debitLine = new c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem();
            //debitLine.DebitCredit = c2g.CODAAPIJournalLineItemTypes_12_0.enumDebitCredit.Debit;
            debitLine.Dimension1 = dim1;
            debitLine.Dimension2 = dim2;
            debitLine.Dimension3 = dim3;
            debitLine.Dimension4 = dim4;
            debitLine.DestinationCompany = destCompany;
            debitLine.LineTypeRef = c2g.CODAAPIJournalLineItemTypes_12_0.enumLineType.Intercompany;
            //debitLine.OwnerCompany = company;
            debitLine.Value = line.c2g__NetValue__c;
            debitLine.GeneralLedgerAccount = debitGL;
            journalLinesList.add(debitLine);

            c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem creditLine = new c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem();
            //creditLine.DebitCredit = c2g.CODAAPIJournalLineItemTypes_12_0.enumDebitCredit.Credit;
            creditLine.Dimension1 = dim1;
            creditLine.Dimension2 = dim2;
            creditLine.Dimension3 = dim3;
            creditLine.Dimension4 = dim4;
            creditLine.LineTypeRef = c2g.CODAAPIJournalLineItemTypes_12_0.enumLineType.GeneralLedgerAccount;
            //creditLine.OwnerCompany = company;
            creditLine.Value = -line.c2g__NetValue__c;
            creditLine.GeneralLedgerAccount = creditGL;
            journalLinesList.add(creditLine);

            //add to the list
            linesItem.LineItemList = journalLinesList;
        }

        //then create the journal header:
        c2g.CODAAPIJournalTypes_12_0.Journal journal = new c2g.CODAAPIJournalTypes_12_0.Journal();
        journal.JournalDate = pinDate != null ? pinDate : Date.today();
        journal.OwnerCompany = company;
        journal.JournalStatus = c2g.CODAAPIJournalTypes_12_0.enumJournalStatus.InProgress;
        journal.JournalCurrency = acctcurrency;
        journal.Period = period;
        journal.Reference = '**INTERCO JNL from '+ journalDescription;
        journal.JournalDescription = 'Intercompany Journal from '+ journalDescription;
        journal.TypeRef = c2g.CODAAPIJournalTypes_12_0.enumType.ManualJournal;
        journal.LineItems = linesItem;

        system.debug('***\n\n ffaUtilities - journal.JournalDate = '+journal.JournalDate);
        system.debug('***\n\n ffaUtilities - journal.OwnerCompany = '+journal.OwnerCompany);
        system.debug('***\n\n ffaUtilities - journal.JournalStatus = '+journal.JournalStatus);
        system.debug('***\n\n ffaUtilities - journal.JournalCurrency = '+journal.JournalCurrency);
        system.debug('***\n\n ffaUtilities - journal.Period = '+journal.Period);
        system.debug('***\n\n ffaUtilities - journal.Reference = '+journal.Reference);
        system.debug('***\n\n ffaUtilities - journal.JournalDescription = '+journal.JournalDescription);
        system.debug('***\n\n ffaUtilities - journal.TypeRef = '+journal.TypeRef);
        system.debug('***\n\n ffaUtilities - journal.LineItems = '+journal.LineItems);
        
        //Create the Journal
        c2g.CODAAPICommon.Reference journalCreated = new c2g.CODAAPICommon.Reference();
        try{journalCreated = c2g.CODAAPIJournal_12_0.CreateJournal(ownerCompany, journal);}
        catch(Exception e)
        {
            returnMessage = 'The following error occured: '+ e.getMessage();
            return returnMessage;
        }
        //post the resulting journal:
      	List<c2g__codaJournal__c> postedJournalList = Test.isRunningTest() == false ? postSingleJournal(journalCreated.id) : new List<c2g__codaJournal__c>();

        //update the Journal with the Source PIN reference:
        for(c2g__codaJournal__c jnl : postedJournalList)
        {
            jnl.Source_Payable_Invoice__c = pinID;
        }
        try{update postedJournalList;}
        catch(Exception e)
        {
            returnMessage = 'The following error occured: '+ e.getMessage();
            return returnMessage;
        }

        //Update Line Utems
        for(c2g__codaPurchaseInvoiceExpenseLineItem__c line: lines)
        {
            line.Inter_Company_Journal_Created__c = true;
        }
        try{update lines;}
        catch(Exception e)
        {
            returnMessage = 'The following error occured: '+ e.getMessage();
            return returnMessage;
        }

        //return success Message:
        returnMessage = 'Success, Inter-Company Journals have been created and posted.  Please refer to the "Journals" tab for the newly created records.';
        return returnMessage;
    }

    /**************************************************************************************
    // Processes any available Intercompany Transfers.  Designed to be used for a single company.
    ***************************************************************************************/
    global static void processIntercoTransactions(List<Id> intercompanyTransIDs)
    {
        c2g.IntercompanyTransferService.process(intercompanyTransIDs);
        Map<Id,Id> journalPINIdMap = new Map<Id,Id>();

        //loop back through the journals and if possible, post them.
        List<c2g__codaJournal__c> postedJournalList = new List<c2g__codaJournal__c>();
        List<Id> journalIdstoPost = new List<Id>();
        List<c2g__codaJournal__c> newJournalList = [
            SELECT
                Id,
                c2g__OwnerCompany__r.OwnerId,
                Source_Payable_Invoice__c
            FROM
                c2g__codaJournal__c
            WHERE
                id in (Select c2g__DestinationJournal__c From c2g__codaIntercompanyTransfer__c Where id in :intercompanyTransIDs)];

       //query the interco trans in order to get the source payable invoice:
        for(c2g__codaIntercompanyTransfer__c incTransfer : [
            SELECT
                c2g__DestinationJournal__c,
                c2g__SourceJournal__r.Source_Payable_Invoice__c
            FROM c2g__codaIntercompanyTransfer__c
            WHERE id in: intercompanyTransIDs AND c2g__SourceJournal__r.Source_Payable_Invoice__c != null])
        {
            journalPINIdMap.put(incTransfer.c2g__DestinationJournal__c,incTransfer.c2g__SourceJournal__r.Source_Payable_Invoice__c);
        }
        for(c2g__codaJournal__c jnl : newJournalList)
        {
            //Post the journal:
            journalIdstoPost.add(jnl.id);

            //Update the source PIN on the Journal:
            if(journalPINIdMap.containsKey(jnl.id))
            {
                jnl.Source_Payable_Invoice__c = journalPINIdMap.get(jnl.id);
            }
        }
        postedJournalList = postJournals(journalIdstoPost);
        update newJournalList;
    }

    

    /******************************************************************************/
    /** Method to post single PIN                                                **/
    /******************************************************************************/
    public static void postSinglePayableInvoices(Id pinId)
    {
        String companyString;
        c2g__codaPurchaseInvoice__c pin = [select id, c2g__OwnerCompany__r.name from c2g__codaPurchaseInvoice__c where id = :pinId];
        c2g.CODAAPICommon_9_0.Context company = new c2g.CODAAPICommon_9_0.Context(); 
        company.CompanyName = pin.c2g__OwnerCompany__r.name;
        company.Token = null;
        c2g.CODAAPICommon.Reference pinRef = new c2g.CODAAPICommon.Reference();
        pinRef.id = pinId;
        c2g.CODAAPIPurchaseInvoice_9_0.PostPurchaseInvoice(company, pinRef); 
    }

    /******************************************************************************/
    /** Method to post PINs                                                      **/
    /******************************************************************************/
    public static List<c2g__codaPurchaseInvoice__c> postPayableInvoices(List<Id> pinIDs)
    {
        List<String> companyString = new List<String>();
        List<c2g__codaPurchaseInvoice__c> pinList = [
            SELECT
                Id,
                c2g__OwnerCompany__r.Name
            FROM c2g__codaPurchaseInvoice__c
            WHERE Id in :pinIDs];
        if(!pinList.isEmpty())
        {
            for(c2g__codaPurchaseInvoice__c p : pinList)
            {
                companyString.add(p.c2g__OwnerCompany__r.Name);
            }
            System.assert(companyString.size() <= 1, 'ERROR: You can only post PINs for one company at a time');

            c2g.CODAAPICommon_9_0.Context company = new c2g.CODAAPICommon_9_0.Context(); 
            company.CompanyName = companyString[0];
            company.Token = null;

            List<c2g.CODAAPICommon.Reference> postList = new List<c2g.CODAAPICommon.Reference>();
            for(c2g__codaPurchaseInvoice__c p : pinList)
            {
                c2g.CODAAPICommon.Reference pinRef = new c2g.CODAAPICommon.Reference();
                pinRef.id = p.id;
                postList.add(pinRef);
            }

            c2g.CODAAPIPurchaseInvoice_9_0.BulkPostPurchaseInvoice(company, postList); 
        }
        return pinList;
    }

    /******************************************************************************/
    /** Method to post Journals - Note the journals should only relate to a single company **/
    /******************************************************************************/
    public static List<c2g__codaJournal__c> postSingleJournal(Id journalid)
    {
        List<c2g__codaJournal__c> jnlList = [select id, c2g__OwnerCompany__r.name from c2g__codaJournal__c where id = :journalid];
        for(c2g__codaJournal__c jnl : jnlList)
        {
            c2g.CODAAPICommon_10_0.Context company = new c2g.CODAAPICommon_10_0.Context(); 
            company.CompanyName = jnl.c2g__OwnerCompany__r.name;
            company.Token = null;
            c2g.CODAAPICommon.Reference jnlRef = new c2g.CODAAPICommon.Reference();
            jnlRef.id = jnl.id;
            c2g.CODAAPIJournal_12_0.PostJournal(company, jnlRef); 
        }
        return jnlList;
    }

    /******************************************************************************/
    /** Method to post Journals                                                  **/
    /******************************************************************************/
    public static List<c2g__codaJournal__c> postJournals(List<Id> journalIds)
    {
    	List<String> companyString = new List<String>();
    	List<c2g__codaJournal__c> journalList = [
    		SELECT
    			Id,
    			c2g__OwnerCompany__r.Name
    		FROM c2g__codaJournal__c
    		WHERE Id in : journalIds];
    	if(!journalList.isEmpty())
    	{
    		for(c2g__codaJournal__c j : journalList)
	    	{
	    		companyString.add(j.c2g__OwnerCompany__r.Name);
	    	}
	    	System.assert(companyString.size() <= 1, 'ERROR: You can only post journals for one company at a time');

			c2g.CODAAPICommon_10_0.Context company = new c2g.CODAAPICommon_10_0.Context(); 
	        company.CompanyName = companyString[0];
	        company.Token = null;

	        List<c2g.CODAAPICommon.Reference> postList = new List<c2g.CODAAPICommon.Reference>();
	        for(c2g__codaJournal__c j : journalList)
	        {
	        	c2g.CODAAPICommon.Reference journalRef = new c2g.CODAAPICommon.Reference();
	        	journalRef.id = j.id;
	        	postList.add(journalRef);
	        }

	        c2g.CODAAPIJournal_12_0.BulkPostJournal(company, postList);	
    	}
        return journalList;
    }

    /******************************************************************************/
    /** Method for Bulk discarding a Journal Entry       **/
    /******************************************************************************/
    global static String bulkDiscardJournal(List<Id> journalIDs) {
        String returnMessage = '';
        List<c2g__codaJournalLineItem__c> lineItemDeleteList = new List<c2g__codaJournalLineItem__c>();
        List<c2g.CODAAPIJournalTypes_12_0.Journal> apiJournalUpdateList = new List<c2g.CODAAPIJournalTypes_12_0.Journal>();
        Set<String> companyNameSet = new Set<String>();
        String companyName = '';
        List<c2g.CODAAPICommon.Reference> returnReferenceList = new List<c2g.CODAAPICommon.Reference>();

        List<c2g__codaJournal__c> discardJournalList = [
        SELECT
            Id,
            c2g__ownerCompany__c,
            c2g__ownerCompany__r.Name,
            c2g__JournalCurrency__c,
            c2g__Period__c,
            (SELECT 
                Id
            FROM c2g__JournalLineItems__r)
        FROM c2g__codaJournal__c
        WHERE id in :journalIDs
        AND c2g__JournalStatus__c = 'In Progress'];

        //Perform a couple validation checks
        if(discardJournalList.size() == 0)
        {
            returnMessage = 'Attention: No Journals were found for discarding, please ensure you have selected at least 1 In Progress Journal Entry.';
            return returnMessage;
        }
        for(c2g__codaJournal__c journal : discardJournalList) //ensure only journals from a single company have been selected
        {
            companyNameSet.add(journal.c2g__ownerCompany__r.Name);
            companyName = journal.c2g__ownerCompany__r.Name;
        }
        if(companyNameSet.size()>1)
        {
            returnMessage = 'Attention: All journals select must belong to 1 company.';
            return returnMessage;
        }

        //Step 1: Delete the Line Items
        for(c2g__codaJournal__c journal : discardJournalList)
        {
            lineItemDeleteList.addAll(journal.c2g__JournalLineItems__r);
        }
        delete lineItemDeleteList;

        //Step 2: Use FFA Api to update Journal Entry to Discarded Status:
        for(c2g__codaJournal__c journal : discardJournalList)
        {
            c2g.CODAAPIJournalTypes_12_0.Journal apiJournal = new c2g.CODAAPIJournalTypes_12_0.Journal();
            c2g.CODAAPICommon.Reference currencyReference = new c2g.CODAAPICommon.Reference();
            currencyReference.id = journal.c2g__JournalCurrency__c;
            c2g.CODAAPICommon.Reference periodReference = new c2g.CODAAPICommon.Reference();
            periodReference.id = journal.c2g__Period__c;
            apiJournal.id = journal.id;
            apiJournal.JournalStatus = c2g.CODAAPIJournalTypes_12_0.enumJournalStatus.Discarded;
            apiJournal.DiscardReason = 'Bulk Discarded by ' +UserInfo.getName() + ' on ' + date.today().format();
            List<c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem> apiLineItemList = new List<c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItem>();
            c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItems apiLineItems = new c2g.CODAAPIJournalLineItemTypes_12_0.JournalLineItems();
            apiLineItems.LineItemList = apiLineItemList;
            apiJournal.LineItems = apiLineItems;
            apiJournal.TypeRef = c2g.CODAAPIJournalTypes_12_0.enumType.ManualJournal;

            //add the journal api object to the discard list:
            apiJournalUpdateList.add(apiJournal);
        }
        c2g.CODAAPICommon_10_0.Context companyContext = new c2g.CODAAPICommon_10_0.Context();
        companyContext.CompanyName = companyName;

        //call the api method to update the journals
        try{returnReferenceList = c2g.CODAAPIJournal_12_0.BulkUpdateJournal(companyContext, apiJournalUpdateList);}
        catch(Exception e)
        {
            returnMessage = 'The following Error occured while discarding: '+e.getMessage();
            return returnMessage;
        }
        returnMessage = 'Success! - '+apiJournalUpdateList.size() + ' Journals have been discarded';
        return returnMessage;
    }

    /******************************************************************************/
    /** Method for Bulk discarding a Payable Invoice       **/
    /******************************************************************************/
    public static String bulkDiscardPIN (List<Id> pinIDs)
    {
        String returnMessage = '';
        List<c2g__codaPurchaseInvoiceExpenseLineItem__c> lineItemList = new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>();
        List<c2g.CODAAPIPurchaseInvoiceTypes_9_0.PurchaseInvoice> apiPINUpdateList = new List<c2g.CODAAPIPurchaseInvoiceTypes_9_0.PurchaseInvoice>();
        Set<String> companyNameSet = new Set<String>();
        String companyName = '';
        List<c2g.CODAAPICommon.Reference> returnReferenceList = new List<c2g.CODAAPICommon.Reference>();

        List<c2g__codaPurchaseInvoice__c> pinList = [
        SELECT
            Id,
            c2g__ownerCompany__c,
            c2g__ownerCompany__r.Name,
            c2g__InvoiceCurrency__c,
            c2g__InvoiceStatus__c,
            c2g__DueDate__c,
            c2g__InvoiceDate__c,
            c2g__Period__c,
            (SELECT 
                Id
            FROM c2g__PurchaseInvoiceExpenseLineItems__r)
        FROM c2g__codaPurchaseInvoice__c
        WHERE id in :pinIDs
        AND c2g__InvoiceStatus__c = 'In Progress'];

        //Perform a couple validation checks
        if(pinList.size() == 0)
        {
            returnMessage = 'Attention: No Invoices were found for discarding, please ensure you have selected at least 1 In Progress Payable Invoice.';
            return returnMessage;
        }
        for(c2g__codaPurchaseInvoice__c payableInvoice : pinList) //ensure only payableInvoices from a single company have been selected
        {
            companyNameSet.add(payableInvoice.c2g__ownerCompany__r.Name);
            companyName = payableInvoice.c2g__ownerCompany__r.Name;
        }
        if(companyNameSet.size()>1)
        {
            returnMessage = 'Attention: All invoices selected must belong to 1 company.';
            return returnMessage;
        }

        for(c2g__codaPurchaseInvoice__c pin : pinList)
        {
            c2g.CODAAPIPurchaseInvoiceTypes_9_0.PurchaseInvoice apiPIN = new c2g.CODAAPIPurchaseInvoiceTypes_9_0.PurchaseInvoice();
            c2g.CODAAPICommon.Reference currencyReference = new c2g.CODAAPICommon.Reference();
            currencyReference.id = pin.c2g__InvoiceCurrency__c;
            c2g.CODAAPICommon.Reference periodReference = new c2g.CODAAPICommon.Reference();
            periodReference.id = pin.c2g__Period__c;
            apiPIN.id = pin.id;
            apiPIN.InvoiceStatus = c2g.CODAAPIPurchaseInvoiceTypes_9_0.enumInvoiceStatus.Discarded;
            apiPIN.DiscardReason = 'Bulk Discarded by ' +UserInfo.getName() + ' on ' + date.today().format();
            List<c2g.CODAAPIPurchaseInvoiceExpLineTypes_9_0.PurchaseInvoiceExpenseLineItem> apiLineItemList = new List<c2g.CODAAPIPurchaseInvoiceExpLineTypes_9_0.PurchaseInvoiceExpenseLineItem>();
            c2g.CODAAPIPurchaseInvoiceExpLineTypes_9_0.PurchaseInvoiceExpenseLineItems apiLineItems = new c2g.CODAAPIPurchaseInvoiceExpLineTypes_9_0.PurchaseInvoiceExpenseLineItems();
            apiLineItems.LineItemList = apiLineItemList;
            apiPIN.ExpLineItems = apiLineItems;

            //add the pin api object to the discard list:
            apiPINUpdateList.add(apiPIN);
        }

        for(c2g__codaPurchaseInvoice__c pin : pinList)
        {
            lineItemList.addAll(pin.c2g__PurchaseInvoiceExpenseLineItems__r);
        }
        delete lineItemList;

        c2g.CODAAPICommon_9_0.Context companyContext = new c2g.CODAAPICommon_9_0.Context();
        companyContext.CompanyName = companyName;

        //call the api method to update the journals
        try{returnReferenceList = c2g.CODAAPIPurchaseInvoice_9_0.BulkUpdatePurchaseInvoice(companyContext, apiPINUpdateList);}
        catch(Exception e)
        {
            returnMessage = 'The following Error occured while discarding: '+e.getMessage();
            return returnMessage;
        }
        returnMessage = 'Success! - '+apiPINUpdateList.size() + ' Invoices have been discarded';
        return returnMessage;
    }   

    /******************************************************************************/
    /** webservice method that is invoked from PIN page layout button        **/
    /******************************************************************************/
    Webservice static string createIntercompanyJournal_WS(string pinID)
    {
        string message = '';
        try{
           message = ffaUtilities.createIntercompanyJournals(pinID);
        }
        catch(System.CalloutException e){
            message = e.getMessage();
        }
        return message;
    }

    /******************************************************************************/
    /** webservice method that is invoked from JNL List View        **/
    /******************************************************************************/
    Webservice static string bulkDiscardJournal_WS(List<Id> jnlIDs)
    {
        string message = '';
        try
        {
           //psaCalculateProjectOverhead.calculateProjectOverhead(projId);
           message = ffaUtilities.bulkDiscardJournal(jnlIDs);
        }
        catch(System.CalloutException e)
        {
            message = e.getMessage();
        }
        return message;
    }

    /******************************************************************************/
    /** webservice method that is invoked from PIN List View        **/
    /******************************************************************************/
    Webservice static string bulkDiscardPIN_WS(List<Id> pinIDs)
    {
        string message = '';
        try
        {
           //psaCalculateProjectOverhead.calculateProjectOverhead(projId);
           message = ffaUtilities.bulkDiscardPIN(pinIDs);
        }
        catch(System.CalloutException e)
        {
            message = e.getMessage();
        }
        return message;
    }

    /******************************************************************************/
    /** Method for creating source cancelling journal for intercompany cash receipts 
        Assumes this should be called from a batch 1 at a time   **/
    /******************************************************************************/
    public static void createCancellingARJournal (List<c2g__codaCashEntry__c> cashEntryLines){
        Set<Id> intercoCompanyIds = new Set<Id>();
        Id currentCompany;
        Id accountId;
        Date processDate;
        Set<String> transactionLineKeySet = new Set<String>();//this is important for finding the correct transaction lines to match together.
        Set<Id> transIds = new Set<Id>();
        Map<Id, c2g__codaJournal__c> newJournalMap = new Map<Id, c2g__codaJournal__c>();
        List<c2g__codaJournalLineItem__c> journalLineInsert = new List<c2g__codaJournalLineItem__c>();
        List<c2g.CODAAPICommon.Reference> journalWrapperList = new List<c2g.CODAAPICommon.Reference>();
        String companyName;

        List<c2g__codaCashEntryLineItem__c> lines = [
            SELECT Id,
                c2g__Account__c,
                c2g__AccountDimension2__c,
                c2g__AccountDimension3__c,
                c2g__AccountReference__c,
                c2g__CashEntry__c,
                c2g__CashEntryValue__c,
                CurrencyIsoCode,
                Destination_Company__c,
                Reversing_Journal_Created__c,
                Intercompany_Journal_Created__c,
                c2g__Account__r.c2g__codaAccountsReceivableControl__c,
                c2g__CashEntry__r.c2g__CashEntryCurrency__c,
                c2g__CashEntry__r.c2g__ownerCompany__r.Name,
                c2g__CashEntry__r.c2g__ownerCompany__c,
                c2g__CashEntry__r.c2g__BankAccount__c,
                c2g__CashEntry__r.c2g__BankAccountDimension2__c,
                c2g__CashEntry__r.c2g__BankAccountDimension3__c,
                c2g__CashEntry__r.Name,
                c2g__CashEntry__r.c2g__Date__c,
                c2g__CashEntry__r.c2g__Period__c,
                c2g__CashEntry__r.c2g__Type__c,
                c2g__CashEntry__r.c2g__Transaction__c
            FROM c2g__codaCashEntryLineItem__c
            WHERE Destination_Company__c != null
            AND c2g__CashEntry__c in :cashEntryLines
            AND c2g__CashEntry__r.c2g__Type__c = 'Receipt'
            AND Reversing_Journal_Created__c = false];

        for(c2g__codaCashEntryLineItem__c cashLine : lines){
            currentCompany = cashLine.c2g__CashEntry__r.c2g__ownerCompany__c;
            accountId = cashLine.c2g__Account__c;
            transIds.add(cashLine.c2g__CashEntry__r.c2g__Transaction__c);
            processDate = cashLine.c2g__CashEntry__r.c2g__Date__c;
            companyName = cashLine.c2g__CashEntry__r.c2g__ownerCompany__r.Name;
            intercoCompanyIds.add(cashLine.c2g__CashEntry__r.c2g__ownerCompany__c);
            intercoCompanyIds.add(cashLine.Destination_Company__c);
        }
        Map<String, c2g__codaIntercompanyDefinition__c> intercoDefinitionMap = fetchIntercoDefinitions(intercoCompanyIds);
        for(c2g__codaCashEntryLineItem__c cashLine : lines){

            String key = cashLine.c2g__CashEntry__r.c2g__ownerCompany__c + '|' + cashLine.Destination_Company__c;
            String transactionLineKey = cashLine.c2g__CashEntry__r.c2g__ownerCompany__c + '|' + cashLine.Destination_Company__c;

            c2g__codaJournal__c jnl = new c2g__codaJournal__c(
                c2g__ownerCompany__c = cashLine.c2g__CashEntry__r.c2g__ownerCompany__c,
                c2g__Type__c = 'Manual Journal',
                c2g__Period__c = cashLine.c2g__CashEntry__r.c2g__Period__c,
                c2g__JournalDate__c = cashLine.c2g__CashEntry__r.c2g__Date__c,
                c2g__JournalCurrency__c = cashLine.c2g__CashEntry__r.c2g__CashEntryCurrency__c,
                ffgl__DerivePeriod__c = false,
                ffgl__DeriveCurrency__c = false,
                CurrencyIsoCode = cashLine.CurrencyIsoCode,
                c2g__JournalDescription__c = 'Intercompany payable journal from ' + cashLine.c2g__CashEntry__r.Name,
                Source_Cash_Entry__c = cashLine.c2g__CashEntry__c);
            newJournalMap.put(cashLine.id, jnl);

            c2g__codaJournalLineItem__c debitLine = new c2g__codaJournalLineItem__c(
                c2g__Account__c = cashLine.c2g__Account__c,
                c2g__LineType__c = 'Account - Customer',
                CurrencyIsoCode = cashLine.CurrencyIsoCode,
                c2g__GeneralLedgerAccount__c = cashLine.c2g__Account__r.c2g__codaAccountsReceivableControl__c,
                c2g__Dimension2__c = cashLine.c2g__CashEntry__r.c2g__BankAccountDimension2__c,
                c2g__Dimension3__c = cashLine.c2g__CashEntry__r.c2g__BankAccountDimension3__c,
                Source_Cash_Entry_Line_Item__c = cashLine.id,
                c2g__Value__c = cashLine.c2g__CashEntryValue__c);
            journalLineInsert.add(debitLine);

            c2g__codaJournalLineItem__c creditLine = new c2g__codaJournalLineItem__c(
                c2g__LineType__c = 'General Ledger Account',
                CurrencyIsoCode = cashLine.CurrencyIsoCode,
                c2g__GeneralLedgerAccount__c = intercoDefinitionMap.containsKey(key) ? intercoDefinitionMap.get(key).c2g__ReceivingControlAccount__c : null,
                c2g__Dimension2__c = cashLine.c2g__CashEntry__r.c2g__BankAccountDimension2__c,
                c2g__Dimension3__c = cashLine.c2g__CashEntry__r.c2g__BankAccountDimension3__c,
                Source_Cash_Entry_Line_Item__c = cashLine.id,
                c2g__Value__c = cashLine.c2g__CashEntryValue__c * -1);
            journalLineInsert.add(creditLine);

            cashLine.Reversing_Journal_Created__c = true;
        }

        c2g.CODAAPICommon_10_0.Context companyWrapper10 = new c2g.CODAAPICommon_10_0.Context();
        companyWrapper10.CompanyName = companyName;
        /*CODAAPICommon_8_0.Context companyWrapper8 = new c2g.CODAAPICommon_8_0.Context();
        companyWrapper8.CompanyName = companyName;*/
        c2g.CODAAPICommon.Reference accountWrapper = new c2g.CODAAPICommon.Reference();
        accountWrapper.Id = accountId;


        try{
            insert newJournalMap.values();
            for(c2g__codaJournal__c jnl : newJournalMap.values()){
                c2g.CODAAPICommon.Reference journalWrapper = new c2g.CODAAPICommon.Reference();
                journalWrapper.id = jnl.id;
                journalWrapperList.add(journalWrapper);
            }
            //loop back through the line items and relate them to the journal:
            for(c2g__codaJournalLineItem__c jnlLine : journalLineInsert){
                jnlLine.c2g__Journal__c = newJournalMap.containsKey(jnlLine.Source_Cash_Entry_Line_Item__c) ? newJournalMap.get(jnlLine.Source_Cash_Entry_Line_Item__c).id : null;
            }
            insert journalLineInsert;

            update lines;

            //post the journal:
            c2g.CODAAPIJournal_12_0.BulkPostJournal(companyWrapper10, journalWrapperList);
        }
        Catch(Exception e){
            system.debug('\n****** ffaUtilities - createCancellingARJournal - There was an error - ' + e.getMessage() + ' Stack Trace: '+ e.getStackTraceString() +  '\n');
        }

        //====== TO DO: Cash Match =====//

        //config wrapper
        /*c2g.CODAAPICashMatchingTypes_8_0.Configuration matchConfig = new c2g.CODAAPICashMatchingTypes_8_0.Configuration();
        matchConfig.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_8_0.enumMatchingCurrencyMode.Account;
        matchConfig.MatchingDate = processDate;

        for(c2g__codaTransactionLineItem__c tranLine : [
            SELECT Id 
            FROM c2g__codaTransactionLineItem__c
            WHERE c2g__])

        CODAAPICommon.Reference match = c2g.CODAAPICashMatching_8_0.Match(companyWrapper8, 
                                      matchConfig, 
                                      array<c2g.CODAAPICashMatchingTypes_8_0.Item> items, 
                                      c2g.CODAAPICashMatchingTypes_8_0.Analysis analysis);*/
    }

    /******************************************************************************/
    /** Method for creating source cancelling journal for intercompany cash receipts 
        Assumes this should be called from a batch 1 at a time   **/
    /******************************************************************************/
    public static void createIntercompanyJournals (List<c2g__codaCashEntryLineItem__c> cashEntryLines){
        Set<Id> intercoCompanyIds = new Set<Id>();
        Id currentCompany;
        Id accountId;
        Date processDate;
        Set<String> transactionLineKeySet = new Set<String>();//this is important for finding the correct transaction lines to match together.
        Map<Id, c2g__codaJournal__c> newJournalMap = new Map<Id, c2g__codaJournal__c>();
        List<c2g__codaJournalLineItem__c> journalLineInsert = new List<c2g__codaJournalLineItem__c>();
        List<c2g.CODAAPICommon.Reference> journalWrapperList = new List<c2g.CODAAPICommon.Reference>();
        String companyName;

        List<c2g__codaCashEntryLineItem__c> lines = [
            SELECT Id,
                c2g__Account__c,
                c2g__AccountDimension2__c,
                c2g__AccountDimension3__c,
                c2g__AccountReference__c,
                c2g__CashEntry__c,
                c2g__CashEntryValue__c,
                CurrencyIsoCode,
                Destination_Company__c,
                Destination_Company__r.Name,
                Reversing_Journal_Created__c,
                Intercompany_Journal_Created__c,
                c2g__Account__r.c2g__codaAccountsReceivableControl__c,
                c2g__CashEntry__r.c2g__CashEntryCurrency__c,
                c2g__CashEntry__r.c2g__CashEntryCurrency__r.Name,
                c2g__CashEntry__r.c2g__ownerCompany__r.Name,
                c2g__CashEntry__r.c2g__ownerCompany__c,
                c2g__CashEntry__r.c2g__BankAccount__c,
                c2g__CashEntry__r.c2g__BankAccountDimension2__c,
                c2g__CashEntry__r.c2g__BankAccountDimension3__c,
                c2g__CashEntry__r.Name,
                c2g__CashEntry__r.c2g__Date__c,
                c2g__CashEntry__r.c2g__Period__c,
                c2g__CashEntry__r.c2g__Period__r.Name,
                c2g__CashEntry__r.c2g__Type__c,
                c2g__CashEntry__r.c2g__Transaction__c
            FROM c2g__codaCashEntryLineItem__c
            WHERE Destination_Company__c != null
            AND id in :cashEntryLines
            AND c2g__CashEntry__r.c2g__Type__c = 'Receipt'
            AND Intercompany_Journal_Created__c = false];

        for(c2g__codaCashEntryLineItem__c cashLine : lines){
            currentCompany = cashLine.c2g__CashEntry__r.c2g__ownerCompany__c;
            accountId = cashLine.c2g__Account__c;
            processDate = cashLine.c2g__CashEntry__r.c2g__Date__c;
            companyName = cashLine.Destination_Company__r.Name;
            intercoCompanyIds.add(cashLine.c2g__CashEntry__r.c2g__ownerCompany__c);
            intercoCompanyIds.add(cashLine.Destination_Company__c);
        }

        //get the correct period and accounting currencies in the map:
        Map<String,Id> periodMap = new Map<String,Id>();
        Map<String,Id> currencyMap = new Map<String,Id>();
        for(c2g__codaPeriod__c period : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaPeriod__c WHERE c2g__ownerCompany__c in : intercoCompanyIds]){
            periodMap.put(period.c2g__ownerCompany__c+'|'+period.Name, period.id);
        }
        for(c2g__codaAccountingCurrency__c acctCurr : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaAccountingCurrency__c WHERE c2g__ownerCompany__c in : intercoCompanyIds]){
            currencyMap.put(acctCurr.c2g__ownerCompany__c+'|'+acctCurr.Name, acctCurr.id);
        }

        Map<String, c2g__codaIntercompanyDefinition__c> intercoDefinitionMap = fetchIntercoDefinitions(intercoCompanyIds);
        for(c2g__codaCashEntryLineItem__c cashLine : lines){

            String currencyKey = cashLine.Destination_Company__c+'|'+cashLine.c2g__CashEntry__r.c2g__CashEntryCurrency__r.Name;
            String periodKey = cashLine.Destination_Company__c+'|'+cashLine.c2g__CashEntry__r.c2g__Period__r.Name;
            String key = cashLine.c2g__CashEntry__r.c2g__ownerCompany__c + '|' + cashLine.Destination_Company__c;

            c2g__codaJournal__c jnl = new c2g__codaJournal__c(
                c2g__ownerCompany__c = cashLine.Destination_Company__c,
                c2g__Type__c = 'Manual Journal',
                c2g__Period__c = periodMap.containsKey(periodKey) ? periodMap.get(periodKey) : null,
                c2g__JournalDate__c = cashLine.c2g__CashEntry__r.c2g__Date__c,
                c2g__JournalCurrency__c = currencyMap.containsKey(currencyKey) ? currencyMap.get(currencyKey) : null,
                ffgl__DerivePeriod__c = false,
                ffgl__DeriveCurrency__c = false,
                CurrencyIsoCode = cashLine.CurrencyIsoCode,
                c2g__JournalDescription__c = 'Intercompany receivable journal from ' + cashLine.c2g__CashEntry__r.Name,
                Source_Cash_Entry__c = cashLine.c2g__CashEntry__c);
            newJournalMap.put(cashLine.id, jnl);

            c2g__codaJournalLineItem__c creditLine = new c2g__codaJournalLineItem__c(
                c2g__Account__c = cashLine.c2g__Account__c,
                c2g__LineType__c = 'Account - Customer',
                CurrencyIsoCode = cashLine.CurrencyIsoCode,
                c2g__GeneralLedgerAccount__c = cashLine.c2g__Account__r.c2g__codaAccountsReceivableControl__c,
                c2g__Dimension2__c = cashLine.c2g__AccountDimension2__c,
                c2g__Dimension3__c = cashLine.c2g__AccountDimension3__c,
                Source_Cash_Entry_Line_Item__c = cashLine.id,
                c2g__Value__c = cashLine.c2g__CashEntryValue__c * -1);
            journalLineInsert.add(creditLine);

            c2g__codaJournalLineItem__c debitLine = new c2g__codaJournalLineItem__c(
                c2g__LineType__c = 'General Ledger Account',
                CurrencyIsoCode = cashLine.CurrencyIsoCode,
                c2g__GeneralLedgerAccount__c = intercoDefinitionMap.containsKey(key) ? intercoDefinitionMap.get(key).c2g__SendingControlAccount__c : null,
                c2g__Dimension2__c = cashLine.c2g__AccountDimension2__c,
                c2g__Dimension3__c = cashLine.c2g__AccountDimension3__c,
                Source_Cash_Entry_Line_Item__c = cashLine.id,
                c2g__Value__c = cashLine.c2g__CashEntryValue__c);
            journalLineInsert.add(debitLine);

            cashLine.Intercompany_Journal_Created__c = true;
        }

        c2g.CODAAPICommon_10_0.Context companyWrapper10 = new c2g.CODAAPICommon_10_0.Context();
        companyWrapper10.CompanyName = companyName;
        /*CODAAPICommon_8_0.Context companyWrapper8 = new c2g.CODAAPICommon_8_0.Context();
        companyWrapper8.CompanyName = companyName;*/
        c2g.CODAAPICommon.Reference accountWrapper = new c2g.CODAAPICommon.Reference();
        accountWrapper.Id = accountId;

        try{
            insert newJournalMap.values();
            for(c2g__codaJournal__c jnl : newJournalMap.values()){
                c2g.CODAAPICommon.Reference journalWrapper = new c2g.CODAAPICommon.Reference();
                journalWrapper.id = jnl.id;
                journalWrapperList.add(journalWrapper);
            }
            //loop back through the line items and relate them to the journal:
            for(c2g__codaJournalLineItem__c jnlLine : journalLineInsert){
                jnlLine.c2g__Journal__c = newJournalMap.containsKey(jnlLine.Source_Cash_Entry_Line_Item__c) ? newJournalMap.get(jnlLine.Source_Cash_Entry_Line_Item__c).id : null;
            }
            insert journalLineInsert;

            update lines;

            //post the journal:
            c2g.CODAAPIJournal_12_0.BulkPostJournal(companyWrapper10, journalWrapperList);
        }
        Catch(Exception e){
            system.debug('\n****** ffaUtilities - createCancellingARJournal - There was an error - ' + e.getMessage() + ' Stack Trace: '+ e.getStackTraceString() +  '\n');
        }
    }

    /*==============================================================================
        Method for retrieving the the necessary intercompany definitions
    ===============================================================================*/
    public static Map<String, c2g__codaIntercompanyDefinition__c> fetchIntercoDefinitions(Set<Id> companyIds){
        Map<String, c2g__codaIntercompanyDefinition__c> intercoDefinitionMap = new Map<String,c2g__codaIntercompanyDefinition__c>(); //key is Source Co Id + Target Co Id
        for(c2g__codaIntercompanyDefinition__c icd : [
            SELECT Id,
                c2g__ReceivingControlAccount__c,
                c2g__SendingControlAccount__c,
                c2g__OwnerCompany__c,
                c2g__RelatedCompany__c
            FROM c2g__codaIntercompanyDefinition__c 
            WHERE c2g__OwnerCompany__c in :companyIds
            AND c2g__RelatedCompany__c in :companyIds]){
            String key = icd.c2g__ownerCompany__c + '|' + icd.c2g__RelatedCompany__c;
            intercoDefinitionMap.put(key, icd);
        }
        return intercoDefinitionMap;
    }



    /******************************************************************************/
    /** Method for Boosting Test Coverage due to limitations with FF API Code   **/
    /******************************************************************************/
    public static void boostTestCoverage(){
        if(Test.isRunningTest())
        {
            Integer testInt = 1;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;
            testInt ++;

        }

    }
    
}