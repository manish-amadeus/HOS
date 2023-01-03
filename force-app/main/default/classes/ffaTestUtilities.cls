/**************************************************************************************
// Name               : ffaTestUtilities
// Date               : 1/15.16
// Description        : Contains all utility methods for CLD ffa test code
// Author             : CLD Partners
// Last Modified By   : Stuart Emery
// Last Modified Date : 03/08/2018
//                     Updated 03/13/2018 PER NICC-026472
***************************************************************************************/

@isTest
public class ffaTestUtilities {
	
	/**************************************************************************
	** Create Test Company and periods
	**************************************************************************/	
	public static c2g__codaCompany__c createFFACompany(String companyName, Boolean setAsCurrent, String homeCurrencyIso) {
        // Setup Company and User association within runAs to avoid mixed DML restriction
        Group companyGroup = null;
        GroupMember gm = null;
        c2g__codaCompany__c company;
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            // Create Company
            company = new c2g__codaCompany__c();
            company.Name = companyName;
            company.RecordTypeId = Schema.SObjectType.c2g__codaCompany__c.RecordTypeInfosByName.get('VAT').RecordTypeId;
            insert company;
            // Create Company Queue
            c2g.CODACompanyWebService.createQueue(company.Id, 'USD', company.Name);
            // Activate the Company
            c2g.CODAYearWebService.calculatePeriods(null); // Workaround to bug in company API's, safe to remain once fixed
            c2g.CODACompanyWebService.activateCompany(company.Id, 'USD', company.Name);        
            // Assign the User to the Company
            c2g__codaUserCompany__c userCompany = new c2g__codaUserCompany__c();
            userCompany.c2g__Company__c = company.Id;
            userCompany.c2g__User__c = UserInfo.getUserId();
            insert userCompany;      
            String queueName = 'FF ' + company.Name;
            system.debug('\n\n ***** ffaTestUtilities - createFFACompany - queueName' + queueName);
            companyGroup = [select Id from Group where Name = :queueName And Type = 'Queue'];  
            // Assign the User to the Company Queue
            gm = new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = UserInfo.getUserId());
            insert gm;
            // Assert user logged into the company
    		System.assertEquals(companyName, c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0]);
        }
        // Create Year and Periods
        c2g__codaYear__c yr = new c2g__codaYear__c();
        yr.Name = String.valueOf(Date.today().year());
        yr.OwnerId = companyGroup.Id;
        yr.c2g__NumberOfPeriods__c = 12;
        yr.c2g__OwnerCompany__c = company.id;
        yr.c2g__AutomaticPeriodList__c = true;
        yr.c2g__StartDate__c = Date.valueOf(Date.today().year() + '-01-01 00:00:00');
        yr.c2g__EndDate__c = Date.valueOf(Date.today().year() + '-12-31 00:00:00');
        yr.c2g__PeriodCalculationBasis__c = 'Month End';
        insert yr;
        c2g.CODAYearWebService.calculatePeriods(yr.Id);
        // Create Accounting Currency?
        if(UserInfo.isMultiCurrencyOrganization()) {
            c2g__codaAccountingCurrency__c testCurrency = new c2g__codaAccountingCurrency__c();
            testCurrency.Name = homeCurrencyIso;
            testCurrency.CurrencyIsoCode = homeCurrencyIso;
            testCurrency.c2g__DecimalPlaces__c = 2;
            testCurrency.c2g__Home__c = true;
            testCurrency.c2g__Dual__c = true;
            insert testCurrency;                    
        }
        return company;
   }

   /**************************************************************************
    ** Create Test Company and periods
    **************************************************************************/ 
    public static c2g__codaAccountingCurrency__c createFFACurrency(String isoCode, Boolean isHome, Boolean isDual)
    {
        c2g__codaAccountingCurrency__c testCurrency;
        if(UserInfo.isMultiCurrencyOrganization()) {
            testCurrency = new c2g__codaAccountingCurrency__c();
            testCurrency.Name = isoCode;
            testCurrency.CurrencyIsoCode = isoCode;
            testCurrency.c2g__DecimalPlaces__c = 6;
            testCurrency.c2g__Home__c = isHome;
            testCurrency.c2g__Dual__c = isDual;
            insert testCurrency;                    
        }
        return testCurrency;
    }

    /**************************************************************************
	** Clear all current companies
	**************************************************************************/	
	public static void clearCurrentCompany(Id userId) {				
		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
			List<GroupMember> currentCompanies = [SELECT Id FROM GroupMember WHERE UseroRGroupId = :userId];
			system.debug('\n\n ***** clearCurrentCompany - currentCompanies before delete' + currentCompanies);
			if(!currentCompanies.isEmpty()){
				Delete currentCompanies;
			}
		}
	}

	/**************************************************************************
	** Set current company
	**************************************************************************/	
	public static void setCurrentCompany(Id userId, Id companyId) {
		clearCurrentCompany(userId);
		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]){
			Id groupId = [select ownerid from c2g__codaCompany__c where id = :companyId].ownerid;
			insert new GroupMember(GroupId = groupId, UseroRGroupId = userId);
		}
	}

	/**************************************************************************
	** Clear all current companies
	**************************************************************************/	
	public static void createIntercoDefinition(Id glaId, Id relatedCompanyId) {
		c2g__codaIntercompanyDefinition__c intercoDef = new c2g__codaIntercompanyDefinition__c(
			c2g__ReceivingControlAccount__c = glaId,
			c2g__SendingControlAccount__c = glaId,
			c2g__RelatedCompany__c = relatedCompanyId);
		insert intercoDef;
	}

	// --> Dimension 1   
	public static c2g__codaDimension1__c createTestDimension1()
	{
		c2g__codaDimension1__c dim1 = new c2g__codaDimension1__c(
			Name = 'TEST',
			c2g__ReportingCode__c = 'TEST'
			);
		insert dim1;
		return dim1;
    }
    // --> Dimension 2
    public static c2g__codaDimension2__c createTestDimension2()
	{
		c2g__codaDimension2__c dim2 = new c2g__codaDimension2__c(
			Name = 'TEST',
			c2g__ReportingCode__c = 'TEST'
			);
		insert dim2;
		return dim2;
    }
    // --> Dimension 3
    public static c2g__codaDimension3__c createTestDimension3()
	{
		c2g__codaDimension3__c dim3 = new c2g__codaDimension3__c(
			Name = 'TEST',
			c2g__ReportingCode__c = 'TEST'
			);
		insert dim3;
		return dim3;
    }
    // --> Dimension 4
    public static c2g__codaDimension4__c createTestDimension4()
	{
		c2g__codaDimension4__c dim4 = new c2g__codaDimension4__c(
			Name = 'TEST',
			c2g__ReportingCode__c = 'TEST'
			);
		insert dim4;
		return dim4;
    }

    // --> GLA Accounts 
    public static c2g__codaGeneralLedgerAccount__c create_BS_GLA()
    {
    	c2g__codaGeneralLedgerAccount__c bs_acct = new c2g__codaGeneralLedgerAccount__c
        (
            Name = '2000 - Accounts Payable',
            c2g__ReportingCode__c = '10000000',
            c2g__Type__c = 'Balance Sheet'
        );
        insert bs_acct;
        return bs_acct;
    }
    // --> GLA Accounts 
    public static c2g__codaGeneralLedgerAccount__c create_BS_GLA(String glaName)
    {
    	c2g__codaGeneralLedgerAccount__c bs_acct = new c2g__codaGeneralLedgerAccount__c
        (
            Name = glaName,
            c2g__ReportingCode__c = '10000000',
            c2g__Type__c = 'Balance Sheet'
        );
        insert bs_acct;
        return bs_acct;
    }

    // --> GLA Accounts:
    public static c2g__codaGeneralLedgerAccount__c create_IS_GLA()
    {
    	c2g__codaGeneralLedgerAccount__c is_acct = new c2g__codaGeneralLedgerAccount__c
        (
            Name = 'Income Statement Account',
            c2g__ReportingCode__c = '400000000',
            c2g__Type__c = 'Income Statement'
        );
        insert is_acct;
        return is_acct;
    }
     // --> GLA Accounts:
    public static c2g__codaGeneralLedgerAccount__c create_IS_GLA(String glaName)
    {
    	c2g__codaGeneralLedgerAccount__c is_acct = new c2g__codaGeneralLedgerAccount__c
        (
            Name = glaName,
            c2g__ReportingCode__c = '400000000',
            c2g__Type__c = 'Income Statement'
        );
        insert is_acct;
        return is_acct;
    }
    
    // --> Remittance Info:
    public static Remittance_Info__c create_Remittance_Info(String rName)
    {
    	Remittance_Info__c ri = new Remittance_Info__c
        (
          Name = rName
        );
        insert ri;
        return ri;
    }

    // --> Sales Invoice:
    public static c2g__codaInvoice__c createSIN(Account account, Date invoice_date, Id productID, Decimal amount)
    {
    	c2g__codaInvoice__c sin = new c2g__codaInvoice__c(
    		c2g__Account__c = account.id,
    		c2g__InvoiceDate__c = invoice_date,
    		c2g__DeriveDueDate__c = TRUE,
    		c2g__DeriveCurrency__c = TRUE,
    		c2g__DerivePeriod__c = TRUE);
    	insert sin;
    	createSIN_Line(productId, amount, sin);
        return sin;
    }

		public static void createSIN_Line(Id productId, Decimal amount, c2g__codaInvoice__c sin)
		{
			c2g__codaInvoiceLineItem__c line = new c2g__codaInvoiceLineItem__c(
				c2g__Invoice__c = sin.id,
				c2g__Product__c = productId,
				c2g__UnitPrice__c = amount,
				c2g__LineNumber__c = 1,
	            c2g__DeriveUnitPriceFromProduct__c = FALSE);
			insert line;
		}
	// --> Sales Invoice:
	public static c2g__codaInvoice__c createSIN_with_Dimensions(Account account, Date invoice_date, Id productID, Decimal amount, Id dim1, Id dim2, Id dim3)
    {
    	c2g__codaInvoice__c sin = new c2g__codaInvoice__c(
    		c2g__Account__c = account.id,
    		c2g__InvoiceDate__c = invoice_date,
    		c2g__DeriveDueDate__c = TRUE,
    		c2g__DeriveCurrency__c = TRUE,
    		c2g__DerivePeriod__c = TRUE,
    		c2g__Dimension1__c = dim1,
			c2g__Dimension2__c = dim2,
			c2g__Dimension3__c = dim3
    		);
    	insert sin;
    	createSIN_Line_with_Dimensions(productId, amount, sin, dim1, dim2, dim3);
        return sin;
    }

		public static void createSIN_Line_with_Dimensions(Id productId, Decimal amount, c2g__codaInvoice__c sin, Id dim1, Id dim2, Id dim3)
		{
			c2g__codaInvoiceLineItem__c line = new c2g__codaInvoiceLineItem__c(
				c2g__Invoice__c = sin.id,
				c2g__Product__c = productId,
				c2g__UnitPrice__c = amount,
				c2g__LineNumber__c = 1,
				c2g__Dimension1__c = dim1,
				c2g__Dimension2__c = dim2,
				c2g__Dimension3__c = dim3,
	            c2g__DeriveUnitPriceFromProduct__c = FALSE);
			insert line;
		}

	// --> Sales Credit Note:
	public static c2g__codaCreditNote__c createSCN(Account account, Date invoice_date, Id productID, Decimal amount, Id invoiceID)
    {
    	c2g__codaCreditNote__c scn = new c2g__codaCreditNote__c(
    		c2g__Account__c = account.id,
    		c2g__Invoice__c = (invoiceID != null ? invoiceID : null),
    		c2g__InvoiceDate__c = invoice_date,
    		c2g__DeriveDueDate__c = TRUE,
    		c2g__DeriveCurrency__c = TRUE,
    		c2g__DerivePeriod__c = TRUE);
    	insert scn;
    	createSCN_Line(productId, amount, scn);
        return scn;
    }

		public static void createSCN_Line(Id productId, Decimal amount, c2g__codaCreditNote__c scn)
		{
			c2g__codaCreditNoteLineItem__c line = new c2g__codaCreditNoteLineItem__c(
				c2g__CreditNote__c = scn.id,
				c2g__Product__c = productId,
				c2g__UnitPrice__c = amount,
				c2g__LineNumber__c = 1,
	            c2g__DeriveUnitPriceFromProduct__c = FALSE);
			insert line;
		}

	// --> Sales Credit Note:
	public static c2g__codaCreditNote__c createSCN_with_Dimension(Account account, Date invoice_date, Id productID, Decimal amount, Id invoiceID, Id dim1, Id dim2, Id dim3)
    {
    	c2g__codaCreditNote__c scn = new c2g__codaCreditNote__c(
    		c2g__Account__c = account.id,
    		c2g__Invoice__c = (invoiceID != null ? invoiceID : null),
    		c2g__InvoiceDate__c = invoice_date,
    		c2g__DeriveDueDate__c = TRUE,
    		c2g__DeriveCurrency__c = TRUE,
    		c2g__Dimension1__c = dim1,
			c2g__Dimension2__c = dim2,
			c2g__Dimension3__c = dim3,
    		c2g__DerivePeriod__c = TRUE,
            c2g__CreditNoteReason__c = 'User Reduction');
    	insert scn;
    	createSCN_Line_with_Dimension(productId, amount, scn, dim1, dim2, dim3);
        return scn;
    }

		public static void createSCN_Line_with_Dimension(Id productId, Decimal amount, c2g__codaCreditNote__c scn, Id dim1, Id dim2, Id dim3)
		{
			c2g__codaCreditNoteLineItem__c line = new c2g__codaCreditNoteLineItem__c(
				c2g__CreditNote__c = scn.id,
				c2g__Product__c = productId,
				c2g__UnitPrice__c = amount,
				c2g__Dimension1__c = dim1,
				c2g__LineNumber__c = 1,
				c2g__Dimension2__c = dim2,
				c2g__Dimension3__c = dim3,
	            c2g__DeriveUnitPriceFromProduct__c = FALSE);
			insert line;
		}

	// --> Payable Invoice:
	public static c2g__codaPurchaseInvoice__c createPIN(Account account, Date invoice_date, Id glaID, Decimal amount)
    {
    	c2g__codaPurchaseInvoice__c pin = new c2g__codaPurchaseInvoice__c(
    		c2g__Account__c = account.id,
    		c2g__InvoiceDate__c = invoice_date,
    		ffap__DeriveDueDate__c = TRUE,
    		ffap__DeriveCurrency__c = TRUE,
    		ffap__DerivePeriod__c = TRUE,
    		c2g__AccountInvoiceNumber__c = 'TEST');
    	insert pin;
    	createPIN_Line(glaID, amount, pin);
        return pin;
    }

		public static void createPIN_Line(Id glaID, Decimal amount, c2g__codaPurchaseInvoice__c pin)
		{
			c2g__codaPurchaseInvoiceExpenseLineItem__c line = new c2g__codaPurchaseInvoiceExpenseLineItem__c(
				c2g__PurchaseInvoice__c = pin.id,
				c2g__GeneralLedgerAccount__c = glaID,
				c2g__NetValue__c = amount,
				ffap__SetGLAToDefault__c = FALSE);
			insert line;
		}

	// --> Payable Invoice:
	public static c2g__codaPurchaseInvoice__c createPIN_withDestinationCo(Account account, Date invoice_date, Id glaID, Decimal amount, Id destinationCo, Id dimension1, Id dimension2, Id dimension3 , Id dimension4)
    {
    	c2g__codaPurchaseInvoice__c pin = new c2g__codaPurchaseInvoice__c(
    		c2g__Account__c = account.id,
    		c2g__InvoiceDate__c = invoice_date,
    		ffap__DeriveDueDate__c = TRUE,
    		ffap__DeriveCurrency__c = TRUE,
    		ffap__DerivePeriod__c = TRUE,
            c2g__Dimension1__c = dimension1 != null ? dimension1 : null,
            c2g__Dimension2__c = dimension2 != null ? dimension2 : null,
            c2g__Dimension3__c = dimension3 != null ? dimension3 : null,
            c2g__Dimension4__c = dimension4 != null ? dimension4 : null,
    		c2g__AccountInvoiceNumber__c = 'TEST');
    	insert pin;
    	createPIN_Line(glaID, amount, pin, destinationCo, dimension1, dimension2, dimension3, dimension4);
        return pin;
    }

		public static void createPIN_Line(Id glaID, Decimal amount, c2g__codaPurchaseInvoice__c pin, Id destinationCo, Id dimension1, Id dimension2, Id dimension3 , Id dimension4)
		{
			c2g__codaPurchaseInvoiceExpenseLineItem__c line = new c2g__codaPurchaseInvoiceExpenseLineItem__c(
				c2g__PurchaseInvoice__c = pin.id,
				c2g__GeneralLedgerAccount__c = glaID,
                c2g__Dimension1__c = dimension1 != null ? dimension1 : null,
                c2g__Dimension2__c = dimension2 != null ? dimension2 : null,
                c2g__Dimension3__c = dimension3 != null ? dimension3 : null,
                c2g__Dimension4__c = dimension4 != null ? dimension4 : null,
				Destination_Company__c = destinationCo,
				Inter_Company_Journal_Created__c = false,
				c2g__NetValue__c = amount,
				ffap__SetGLAToDefault__c = FALSE);
			insert line;
			system.assertNotEquals(line.Destination_Company__c, null);
		}



	// --> Payable Credit Note:
	public static c2g__codaPurchaseCreditNote__c createPCN(Account account, Date invoice_date, Id glaID, Decimal amount, Id dim1ID)
    {
    	c2g__codaPurchaseCreditNote__c pcn = new c2g__codaPurchaseCreditNote__c(
    		c2g__Account__c = account.id,
    		c2g__InvoiceDate__c = invoice_date,
    		ffap__DeriveDueDate__c = TRUE,
    		ffap__DeriveCurrency__c = TRUE,
    		ffap__DerivePeriod__c = TRUE,
    		c2g__CreditNoteReason__c = 'TEST',
    		c2g__AccountCreditNoteNumber__c = 'TEST123');
    	insert pcn;
    	createPCN_Line(glaID, amount, pcn, dim1ID);
        return pcn;
    }

		public static void createPCN_Line(Id glaID, Decimal amount, c2g__codaPurchaseCreditNote__c pcn, Id dim1ID)
		{
			c2g__codaPurchaseCreditNoteExpLineItem__c line = new c2g__codaPurchaseCreditNoteExpLineItem__c(
				c2g__PurchaseCreditNote__c = pcn.id,
				c2g__GeneralLedgerAccount__c = glaID,
				c2g__NetValue__c = amount,
				c2g__Dimension1__c = dim1ID,
				ffap__SetGLAToDefault__c = FALSE);
			insert line;
		}

	// --> Journals:
	public static c2g__codaJournal__c createJNL(Date invoice_date, Id glaID, Decimal amount, Id dimension1, Id dimension2, Id dimension3 , Id dimension4)
    {
    	c2g__codaJournal__c jnl = new c2g__codaJournal__c(
    		c2g__journalDate__c = Date.today(),
    		ffgl__DeriveCurrency__c = TRUE,
    		ffgl__DerivePeriod__c = TRUE,
    		c2g__Type__c = 'Manual Journal');
    	insert jnl;
    	createJNL_Lines(glaID, amount, jnl, dimension1, dimension2, dimension3, dimension4);
        return jnl;
    }

		public static void createJNL_Lines(Id glaID, Decimal amount, c2g__codaJournal__c jnl, Id dimension1, Id dimension2, Id dimension3 , Id dimension4)
		{
			c2g__codaJournalLineItem__c line1 = new c2g__codaJournalLineItem__c(
				c2g__Journal__c = jnl.id,
				c2g__GeneralLedgerAccount__c = glaID,
				c2g__Value__c = amount,
                c2g__Dimension1__c = dimension1 != null ? dimension1 : null,
                c2g__Dimension2__c = dimension2 != null ? dimension2 : null,
                c2g__Dimension3__c = dimension3 != null ? dimension3 : null,
                c2g__Dimension4__c = dimension4 != null ? dimension4 : null,
				c2g__LineType__c = 'General Ledger Account');
			insert line1;
			c2g__codaJournalLineItem__c line2 = new c2g__codaJournalLineItem__c(
				c2g__Journal__c = jnl.id,
				c2g__GeneralLedgerAccount__c = glaID,
				c2g__Value__c = -amount,
                c2g__Dimension1__c = dimension1 != null ? dimension1 : null,
                c2g__Dimension2__c = dimension2 != null ? dimension2 : null,
                c2g__Dimension3__c = dimension3 != null ? dimension3 : null,
                c2g__Dimension4__c = dimension4 != null ? dimension4 : null,
				c2g__LineType__c = 'General Ledger Account');
			insert line2;
		}
	// --> Journals:
	public static c2g__codaJournal__c createJNL_Intercompany(Date invoice_date, Id glaID, Decimal amount, Id destinationCo, Id dimension1, Id dimension2, Id dimension3 , Id dimension4)
    {
    	c2g__codaJournal__c jnl = new c2g__codaJournal__c(
    		c2g__journalDate__c = Date.today(),
    		ffgl__DeriveCurrency__c = TRUE,
    		ffgl__DerivePeriod__c = TRUE,
    		c2g__Type__c = 'Manual Journal');
    	insert jnl;
    	createJNL_Lines(glaID, amount, jnl, destinationCo, dimension1, dimension2, dimension3, dimension4);
        return jnl;
    }

		public static void createJNL_Lines(Id glaID, Decimal amount, c2g__codaJournal__c jnl, Id destinationCo, Id dimension1, Id dimension2, Id dimension3 , Id dimension4)
		{
			c2g__codaJournalLineItem__c line1 = new c2g__codaJournalLineItem__c(
				c2g__Journal__c = jnl.id,
				c2g__GeneralLedgerAccount__c = glaID,
				c2g__Value__c = amount,
                c2g__Dimension1__c = dimension1 != null ? dimension1 : null,
                c2g__Dimension2__c = dimension2 != null ? dimension2 : null,
                c2g__Dimension3__c = dimension3 != null ? dimension3 : null,
                c2g__Dimension4__c = dimension4 != null ? dimension4 : null,
				c2g__LineType__c = 'General Ledger Account');
			insert line1;
			c2g__codaJournalLineItem__c line2 = new c2g__codaJournalLineItem__c(
				c2g__Journal__c = jnl.id,
				c2g__GeneralLedgerAccount__c = glaID,
				c2g__Value__c = -amount,
                c2g__Dimension1__c = dimension1 != null ? dimension1 : null,
                c2g__Dimension2__c = dimension2 != null ? dimension2 : null,
                c2g__Dimension3__c = dimension3 != null ? dimension3 : null,
                c2g__Dimension4__c = dimension4 != null ? dimension4 : null,
				c2g__DestinationCompany__c = destinationCo,
				c2g__LineType__c = 'Intercompany');
			insert line2;
		}

    // --> Cash Entry:
    public static c2g__codaCashEntry__c createCSHreceipt(Account account, Id bankaccountId, Decimal amount)
    {
        c2g__codaCashEntry__c csh = new c2g__codaCashEntry__c(
            c2g__Type__c = 'Receipt',
            c2g__BankAccount__c = bankaccountId,
            c2g__BankAccountValue__c = amount,
            c2g__NetValue__c = amount,
            c2g__Value__c = amount,
            c2g__LineCharges__c = 0,
            c2g__Date__c = date.today());
        insert csh;
        createcsh_Line(account.id, amount, csh);
        return csh;
    }

        public static void createCSH_Line(Id accountId, Decimal amount, c2g__codaCashEntry__c csh)
        {
            c2g__codaCashEntryLineItem__c line = new c2g__codaCashEntryLineItem__c(
                c2g__CashEntry__c = csh.id,
                c2g__CashEntryValue__c = amount,
                c2g__Account__c = accountId);
            insert line;
        }

    //===========================================================================================================================
    // NEWMARKET SPECIFIC STRUCTURE
    //===========================================================================================================================
    public static Payment_Terms__c createTestPmtTerms(Integer numofInvoices, String termsName, String offsetDate, String splitMethod, Integer offsetUnits, String offsetMeasure, Boolean psaBilled){
        Payment_Terms__c pmtTerms = new Payment_Terms__c(
            Name = termsName,
            Offset_Date__c = offsetDate,
            Billed_Through_PSA__c = psaBilled,
            Aptus_Payment_Terms__c = 'Standard',
            Invoice_Split_Method__c = splitMethod);
        insert pmtTerms;
        List<Payment_Term_Line_Item__c> pmtLines = new List<Payment_Term_Line_Item__c>();
        Integer linesCreated = 0;
        while(linesCreated < numofInvoices){
            Payment_Term_Line_Item__c pmtLine = new Payment_Term_Line_Item__c(
                Order__c = 1,
                Offset_Measure__c = offsetMeasure,
                Offset_Units__c = offsetUnits,
                Duration_Units__c = offsetUnits,
                Payment_Terms__c = pmtTerms.id,
                Percent_of_Total__c = 100 / numofInvoices);
            pmtLines.add(pmtLine);
            linesCreated ++;
        }
        insert pmtLines;
        return pmtTerms;
    }

    // --> Account
    public static Account createAccount(String name, Id gla_id) 
    {
    	Id vendorRecordType = [Select id from recordtype where sobjecttype = 'Account' and name = 'Vendor Account'].id;

        Account account  = new Account();
        account.name = name;
        account.Vendor_Type__c = 'Newmarket';
    	account.BillingStreet = '10000 Sample St.';
        account.BillingCity = 'Sample City';
        account.BillingState = 'VA';
        account.BillingPostalCode = '23238';
        account.BillingCountry = 'US';
        account.c2g__CODAAccountsReceivableControl__c = (gla_id != null ? gla_id : null);
        account.c2g__CODAAccountsPayableControl__c = (gla_id != null ? gla_id : null);
        account.c2g__CODAAccountTradingCurrency__c = 'USD';
        account.c2g__CODABaseDate1__c = 'Invoice Date';
        account.c2g__CODADaysOffset1__c = 30;
        account.c2g__CODADescription1__c = 'net 30';
        account.c2g__CODADiscount1__c = 0;
        account.c2g__CODASalesTaxStatus__c = 'Exempt';
        account.c2g__CODAExemptionCertificate__c = 'EXEMPT';
        account.c2g__CODABankCity__c = '99';
        account.c2g__CODABankCountry__c = '99';
        account.c2g__CODABankName__c = '99';
        account.c2g__CODABankSWIFTNumber__c = '99';
        account.c2g__CODABankStreet__c = '99';
        account.c2g__CODABankAccountName__c = '99';
        account.c2g__CODABankAccountNumber__c = '99';
        account.c2g__CODABankStateProvince__c = '99';
        account.RecordTypeId = vendorRecordType;

        insert account;
        return account;
    }

    public static void createAccountTeam(Id usrId, Id acctId, String role){
        AccountTeamMember tm = new AccountTeamMember(
            AccountId = acctId,
            UserId = usrId,
            TeamMemberRole = role);
        insert tm;
    }

    public static Product2 createProduct2(Integer iRecordNumber, Id ProductGroupId, String strSKU, String strFamily, String revCat, Integer durationMonths) 
    {
        Product2 p2 = new Product2();
        p2.Product_Group__c = ProductGroupId;
        p2.Product_Line__c = 'Delphi Single Property';
        p2.Revenue_Category__c = revCat;
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.ProductCode = strSKU;
        p2.Description = 'APEX Test Class';
        p2.Family = strFamily;
        p2.Name = 'Embrace';
        p2.Duration_Months__c = durationMonths != null ? durationMonths : null;
        // ADDED 7/16/2014
        p2.Line__c = 'Delphi';
        p2.Edition__c = 'Enterprise';
        p2.Classification__c = 'TEST DATA';
        p2.Support_Classification__c = 'Gold';
        p2.Interface_Classification__c = 'PMS';
        // ADDED 9/30/2014 
        p2.Corporate_Product_Group__c = 'Newmarket';
        insert p2;
        return p2;
    }

    public static PSA_Product_Package__c createProductPackage (String sku, Integer numberOfSplits, Id productId){
        PSA_Product_Package__c pkg = new PSA_Product_Package__c(
            Name = sku,
            Package_SKU__c = sku,
            Description__c = sku);
        insert pkg;
        List<PSA_Product_Package_Milestone__c> pkgLineInsertList = new List<PSA_Product_Package_Milestone__c>();
        Integer linesCreated = 0;
        while(linesCreated < numberOfSplits){
            PSA_Product_Package_Milestone__c pkgLine = new PSA_Product_Package_Milestone__c(
                Milestone_Name_Prefix__c = 'test',
                Percent__c = 100 / numberOfSplits,
                Milestone_Type__c = 'Billable Milestone',
                Product_Package__c = pkg.id,
                Offset_Days__c = 10,
                Product__c = productId);
            pkgLineInsertList.add(pkgLine);
            linesCreated ++;
        }
        insert pkgLineInsertList;
        return pkg;
    }

    // --> Contact
    public static Contact createTestContact (String firstname, String email)
    {
        Contact c = new Contact(
            email = email,
            lastName = 'TEST',
            firstname = firstname,
            MailingStreet = '10000 Sample St.',
            MailingCity = 'Sample City',
            MailingState = 'VA',
            MailingPostalCode = '23238',
            MailingCountry = 'US');
        insert c;
        return c;
    }

    public static void createTestOpportunityContactRoles(Id testOpportunityId, Id testContactId)     // Id testUserId, 
    {
        List<OpportunityContactRole> rolesToInsert = new List<OpportunityContactRole>();
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId = testOpportunityId;
        ocr1.ContactId = testContactId;
        ocr1.Role = 'Decision Maker';     
        rolesToInsert.add(ocr1);

        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.OpportunityId = testOpportunityId;
        ocr2.ContactId = testContactId;
        ocr2.Role = 'Bill To';     
        rolesToInsert.add(ocr2);

        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.OpportunityId = testOpportunityId;
        ocr3.ContactId = testContactId;
        ocr3.Role = 'Ship To';     
        rolesToInsert.add(ocr3);

        OpportunityContactRole ocr4 = new OpportunityContactRole();
        ocr4.OpportunityId = testOpportunityId;
        ocr4.ContactId = testContactId;
        ocr4.Role = 'Customer Project Contact';     
        rolesToInsert.add(ocr4);

        insert rolesToInsert;            
    }  



    /*************************************************************
    * Creates a Project with parameters provided for:
    * - Name
    * - Region
    * - Practice
    * - Project Stage
    * - Opportunity (optional)
    * Automatically sets the project to Active, Billable,
    * Allow timecards and expenses without assignment 
    **************************************************************/
    public static pse__Proj__c createTestProject(Integer iRecordNumber, String projectName, pse__Region__c region, pse__Practice__c practice, String projectStage, Opportunity opp, Id projectManager)
    {
       pse__Proj__c testProject = new pse__Proj__c(Name=projectName + iRecordNumber,
                                        pse__Is_Active__c=true,
                                        pse__Is_Billable__c=true,
                                        pse__Allow_Timecards_Without_Assignment__c=true,
                                        pse__Allow_Expenses_Without_Assignment__c=true);
        
        testProject.pse__Region__c = region.Id;
        testProject.pse__Practice__c = practice.Id;
        testProject.pse__Stage__c = projectStage;
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Project_Manager__c = projectManager;
        testProject.pse__Account__c = opp.AccountId != null ? opp.AccountId : null;
        testProject.pse__Project_Status__c = 'Green';  //ADDED PER SALESFORCE.COM CHANGE REQUEST: NICC-008249
        if(opp != null)
        {
            testProject.pse__Opportunity__c = opp.Id;
        }
        insert testProject;
        return testProject;
    }

    //===========================================================================================================================================================
    //CREATE A TEST REGION
    public static pse__Region__c createTestRegion(Integer iRecordNumber, String regionName)
    {
        pse__Region__c testRegion = new pse__Region__c(Name=regionName + iRecordNumber);
        insert testRegion;
        return testRegion;
    }
    
    //========================================================================================================================================================
    //CREATE A TEST PRACTICE
    public static pse__Practice__c createTestPractice(Integer iRecordNumber, String practiceName)
    {
        pse__Practice__c testPractice = new pse__Practice__c(Name=practiceName + iRecordNumber);
        insert testPractice;
        return testPractice;
    }

    // --> Opportunity
    public static Opportunity initTestOpportunity(Integer iRecordNumber, Id testAccountId, Id lpPaymentTerms, Id servicePaymentTerms, Id supportPaymentTerms, Id subsPaymentTerms, Id hostingSupportPaymentTerms)
    {
        Opportunity o = new Opportunity();
        o.AccountId = testAccountId;
        o.Name = 'Apex Test Opportunity Name';
        o.StageName = 'Prospecting';
        o.Order_Status__c = 'Prospect';
        o.Amount = 25000;
        o.CloseDate = Date.Today().addDays(-1);
        o.Effective_Date__c = Date.Today().addDays(-1);
        // ADDED 9/30/2014 
        o.Opportunity_Source__c = 'Support';
        o.License_Program_Payment_Terms__c = lpPaymentTerms != null ? lpPaymentTerms :null;
        o.Hosting_and_Support_Payment_Terms__c = hostingSupportPaymentTerms != null ? hostingSupportPaymentTerms :null;
        o.Services_Payment_Terms__c = servicePaymentTerms != null ? servicePaymentTerms :null;
        o.Subscription_Payment_Terms__c = subsPaymentTerms != null ? subsPaymentTerms :null;
        o.Support_Payment_Terms__c = supportPaymentTerms != null ? supportPaymentTerms :null;
        return o;        
    }

    /* 
    *  Returns a valid mock Pricebook2.
    */    
    public static Pricebook2 createTestPricebook(String testPricebookName) 
    {    
        Pricebook2 pb2 = new Pricebook2();
        pb2.Name = testPricebookName;   
        pb2.Description = 'Apex Test Pricebook';
        pb2.IsActive = true;
        insert pb2;  
        return pb2;     
    }

    /* Returns a valid mock Asset (Deployment Instance).
    *  Update to pass all validation rules and field requirements.
    *  iRecountNumber: an integer to make each mock Asset unique. 
    */
    public static Asset createTestasset(Integer iRecordNumber, Id testAccountId, Id testProduct2Id, Id productGroupId)
    {
        Asset asset = new Asset();
        asset.Name = 'Apex Test Asset' + iRecordNumber;        
        asset.AccountId = testAccountId;
        asset.Product2Id = testProduct2Id;
        asset.Product_Group__c = productGroupId;
        insert asset;
        return asset;     
    }
    
    /* 
    *  Returns a valid mock PricebookEntry.
    */    
    public static PricebookEntry createTestPricebookEntry(Id testPricebook2Id, Id testProduct2Id, Decimal testUnitPrice) {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = testPricebook2Id;  
        pbe.Product2Id = testProduct2Id;
        pbe.UnitPrice = testUnitPrice;
        pbe.UseStandardPrice = false;
        pbe.IsActive = true;
        insert pbe;
        return pbe;
    }      

    /* 
    *  Returns a valid mock Opportunity Line Item.
    */    
    public static OpportunityLineItem initTestOpportunityLineItem(Integer iRecordNumber, Id testOpportunityId, Id testPricebookEntryId, Integer testQuantity){
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = testOpportunityId;
        oli.Description = 'Apex Test Line Item ' + iRecordNumber;
        oli.PricebookEntryId = testPricebookEntryId;
        oli.Quantity = testQuantity;  
        oli.TotalPrice = 1000;          
        return oli;
    }

    public static Apttus__APTS_Agreement__c createTestAgreement (Opportunity opp, List<Product2> productList){
        Apttus__APTS_Agreement__c objAPTSAgreement = new Apttus__APTS_Agreement__c();
        objAPTSAgreement.Name = 'Test Agreement';
        objAPTSAgreement.Apttus__Related_Opportunity__c = opp.id;
        objAPTSAgreement.CurrencyIsoCode = 'USD';
        //objAPTSAgreement.APTS_Legal_Entity__c = 'Newmarket International, Ltd.';
        objAPTSAgreement.APTS_Legal_Entity__c = 'Amadeus Hospitality Americas, Inc.';
        /*objAPTSAgreement.APTS_Licensed_Program__c = 'Standard';
        objAPTSAgreement.APTS_Services__c = 'Standard';
        objAPTSAgreement.APTS_Hosting_and_Support__c = 'Standard';
        objAPTSAgreement.APTS_Subscription__c = 'Standard';
        objAPTSAgreement.APTS_Support__c = 'Standard';
        objAPTSAgreement.APTS_HRM_Apps_Subscription_Term__c = 'Standard';
        objAPTSAgreement.HRM_Apps_Services_Terms__c = 'Standard';*/
        insert objAPTSAgreement;
        
        List<Apttus__AgreementLineItem__c> agreementLineInsertList = new List<Apttus__AgreementLineItem__c>();
        for(Product2 prod : productList){
            Apttus__AgreementLineItem__c objAgLineItem = new Apttus__AgreementLineItem__c();          
            objAgLineItem.Apttus__AgreementId__c = objAPTSAgreement.id;
            objAgLineItem.Apttus_CMConfig__ItemSequence__c = 1;
            objAgLineItem.Apttus_CMConfig__LineNumber__c = 1;
            objAgLineItem.Apttus__ProductId__c = prod.id;
            agreementLineInsertList.add(objAgLineItem);
        }
        insert agreementLineInsertList;
        return objAPTSAgreement;
    }

    public static void disableNonFFaTriggers(){
        NI_TriggerBypassSwitches__c switchesToUpdate;
        NI_TriggerBypassSwitches__c existingSwitches = NI_TriggerBypassSwitches__c.getOrgDefaults();
        if(existingSwitches == null){
            switchesToUpdate = new NI_TriggerBypassSwitches__c(
                BypassAccount_ON__c = true,
                BypassApttusAgreement_ON__c = true,
                BypassAsset_ON__c = true,
                BypassCase_ON__c = true,
                BypassNICCArtifact_ON__c = true,
                BypassNICREngagement_ON__c = true,
                BypassNICancellation_ON__c = true,
                BypassNIChangeControl_ON__c = true,
                BypassNICustomDetailToService_ON__c = true,
                BypassNICustomizationDetail_ON__c = true,
                BypassNICustomizationService_ON__c = true,
                BypassNIEmployeePerfEval_ON__c = true,
                BypassNIICEProperty_ON__c = true,
                BypassNIICESubscription_ON__c = true,
                BypassNIMilestoneForecast_ON__c = true,
                BypassNIOrgDetails_ON__c = true,
                BypassNIPFyreAgentEvents_ON__c = true,
                BypassNISalesExpenseReport_ON__c = true,
                BypassNIServiceOrder_ON__c = true,
                BypassNWSIServer_ON__c = true,
                BypassNWSLocation_ON__c = true,
                BypassOpportunityAcctPlansStrats__c = true,
                BypassOpportunityContactRoleChecks__c = true,
                BypassOpportunityHRMProductCreate__c = true,
                BypassOpportunityProduct_ON__c = true,
                BypassOpportunityReleaseDateUpdate__c = true,
                BypassOpportunityRollupAmount__c = true,
                BypassOpportunity_ON__c = true,
                BypassProduct2_ON__c = true,
                BypassProductRelease_ON__c = true,
                Bypass_AIP_GDS_Monthly_Revenue__c = true,
                Bypass_AIP_Transaction__c = true,
                Bypass_IT_Hardware_Asset_ON__c = true,
                Bypass_NI_Customer_Agreement__c = true,
                Bypass_NI_Invoice_Detail__c = true,
                Bypass_NI_Invoice__c = true,
                Bypass_NI_Job_Requisition__c = true,
                Bypass_NI_License_Audit_ON__c = true,
                Bypass_NI_Pager_Bonus_ON__c = true,
                Bypass_NI_Project_Backlog_ON__c = true,
                Bypass_NI_Project_Backlog_Task_ON__c = true,
                Bypass_PSA_Milestone__c = true,
                Bypass_Softrax_Asset__c = true,
                Bypass_TopicAssignment_ON__c = true,
                Bypass_User_ON__c = true,
                Bypass_activityLineItemTrigger__c = false,
                Bypass_billingContract__c = false,
                Bypass_ffaCashEntryLine__c = false,
                Bypass_ffaCashEntryTrigger__c = false,
                Bypass_ffaPOLineItemTrigger__c = false,
                Bypass_ffaPayableInvoiceTrigger__c = false,
                Bypass_ffaPaymentTrigger__c = false,
                Bypass_ffaReportingBalanceTrigger__c = false,
                Bypass_ffaRequisitionLineItemTrigger__c = false,
                Bypass_ffaRequisitionTrigger__c = false,
                Bypass_ffaSaleInvoiceLineItemTrigger__c = false,
                Bypass_ffaSalesCreditNoteTrigger__c = false,
                Bypass_ffaSalesInvoice__c = false,
                MasterSwitch_ON__c = true);
        }   
        else{
            switchesToUpdate = existingSwitches;
            switchesToUpdate.BypassAccount_ON__c = true;
                switchesToUpdate.BypassApttusAgreement_ON__c = true;
                switchesToUpdate.BypassAsset_ON__c = true;
                switchesToUpdate.BypassCase_ON__c = true;
                switchesToUpdate.BypassNICCArtifact_ON__c = true;
                switchesToUpdate.BypassNICREngagement_ON__c = true;
                switchesToUpdate.BypassNICancellation_ON__c = true;
                switchesToUpdate.BypassNIChangeControl_ON__c = true;
                switchesToUpdate.BypassNICustomDetailToService_ON__c = true;
                switchesToUpdate.BypassNICustomizationDetail_ON__c = true;
                switchesToUpdate.BypassNICustomizationService_ON__c = true;
                switchesToUpdate.BypassNIEmployeePerfEval_ON__c = true;
                switchesToUpdate.BypassNIICEProperty_ON__c = true;
                switchesToUpdate.BypassNIICESubscription_ON__c = true;
                switchesToUpdate.BypassNIMilestoneForecast_ON__c = true;
                switchesToUpdate.BypassNIOrgDetails_ON__c = true;
                switchesToUpdate.BypassNIPFyreAgentEvents_ON__c = true;
                switchesToUpdate.BypassNISalesExpenseReport_ON__c = true;
                switchesToUpdate.BypassNIServiceOrder_ON__c = true;
                switchesToUpdate.BypassNWSIServer_ON__c = true;
                switchesToUpdate.BypassNWSLocation_ON__c = true;
                switchesToUpdate.BypassOpportunityAcctPlansStrats__c = true;
                switchesToUpdate.BypassOpportunityContactRoleChecks__c = true;
                switchesToUpdate.BypassOpportunityHRMProductCreate__c = true;
                switchesToUpdate.BypassOpportunityProduct_ON__c = true;
                switchesToUpdate.BypassOpportunityReleaseDateUpdate__c = true;
                switchesToUpdate.BypassOpportunityRollupAmount__c = true;
                switchesToUpdate.BypassOpportunity_ON__c = true;
                switchesToUpdate.BypassProduct2_ON__c = true;
                switchesToUpdate.BypassProductRelease_ON__c = true;
                switchesToUpdate.Bypass_AIP_GDS_Monthly_Revenue__c = true;
                switchesToUpdate.Bypass_AIP_Transaction__c = true;
                switchesToUpdate.Bypass_IT_Hardware_Asset_ON__c = true;
                switchesToUpdate.Bypass_NI_Customer_Agreement__c = true;
                switchesToUpdate.Bypass_NI_Invoice_Detail__c = true;
                switchesToUpdate.Bypass_NI_Invoice__c = true;
                switchesToUpdate.Bypass_NI_Job_Requisition__c = true;
                switchesToUpdate.Bypass_NI_License_Audit_ON__c = true;
                switchesToUpdate.Bypass_NI_Pager_Bonus_ON__c = true;
                switchesToUpdate.Bypass_NI_Project_Backlog_ON__c = true;
                switchesToUpdate.Bypass_NI_Project_Backlog_Task_ON__c = true;
                switchesToUpdate.Bypass_PSA_Milestone__c = true;
                switchesToUpdate.Bypass_Softrax_Asset__c = true;
                switchesToUpdate.Bypass_TopicAssignment_ON__c = true;
                switchesToUpdate.Bypass_User_ON__c = true;
                switchesToUpdate.Bypass_activityLineItemTrigger__c = false;
                switchesToUpdate.Bypass_billingContract__c = false;
                switchesToUpdate.Bypass_ffaCashEntryLine__c = false;
                switchesToUpdate.Bypass_ffaCashEntryTrigger__c = false;
                switchesToUpdate.Bypass_ffaPOLineItemTrigger__c = false;
                switchesToUpdate.Bypass_ffaPayableInvoiceTrigger__c = false;
                switchesToUpdate.Bypass_ffaPaymentTrigger__c = false;
                switchesToUpdate.Bypass_ffaReportingBalanceTrigger__c = false;
                switchesToUpdate.Bypass_ffaRequisitionLineItemTrigger__c = false;
                switchesToUpdate.Bypass_ffaRequisitionTrigger__c = false;
                switchesToUpdate.Bypass_ffaSaleInvoiceLineItemTrigger__c = false;
                switchesToUpdate.Bypass_ffaSalesCreditNoteTrigger__c = false;
                switchesToUpdate.Bypass_ffaSalesInvoice__c = false;
                switchesToUpdate.MasterSwitch_ON__c = true;
        }
        upsert switchesToUpdate;
    }

}