/*******************************************************************************************
Name            : ffaCashEntryTrigger_TEST
Author          : CLD Partners
Created Date    : Feb 11, 2016
Description     : Provides tests for Cash Entry Trigger Handler
*******************************************************************************************/
@isTest(seealldata = true)
public class ffaPrepaidExpenseHandler_TEST 
{
    public static c2g__codaCompany__c testCompany1;
    public static c2g__codaCompany__c testCompany2;
    public static Account testAccount;
    public static c2g__codaJournal__c testJournal;
    public static c2g__codaGeneralLedgerAccount__c testGLA;
    public static c2g__codaBankAccount__c testBankAccount;
    public static c2g__codaPurchaseInvoice__c testPIN;
    public static c2g__codaDimension2__c testDimension2;
    public static c2g__codaDimension3__c testDimension3;

    private static void setupTestData()
    {
        testGLA = create_IS_GLA();
        testCompany1 = createFFACompany('TEST COMPANY', true, 'USD');
        c2g__codaAccountingCurrency__c testcurr = [SELECT id from c2g__codaAccountingCurrency__c where c2g__ownerCompany__c = :testCompany1.id limit 1];
     //   system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany1' + testCompany1);
        testAccount = createAccount('TEST Account', testGLA.id);
        testDimension2 = createTestDimension2();
        testDimension3 = createTestDimension3();
    }

    @isTest static void testPrepaidPIN()
    {    
        setupTestData();
        test.startTest();
        testPIN = createPIN(testAccount, Date.today(), testGLA.id, 1000, Date.today(), Date.today().addMonths(3));
        postPIN();
        test.stopTest();
    }

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
           // system.debug('\n\n ***** ffaTestUtilities - createFFACompany - queueName' + queueName);
            companyGroup = [select Id from Group where Name = :queueName And Type = 'Queue'];  
            // Assign the User to the Company Queue
            gm = new GroupMember( GroupId = companyGroup.Id, UseroRGroupId = UserInfo.getUserId());
            insert gm;
            // Assert user logged into the company
           // System.assertEquals(companyName, c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0]);
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

    // --> GLA Accounts:
    public static c2g__codaGeneralLedgerAccount__c create_IS_GLA()
    {
   //  System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]){
         c2g__codaGeneralLedgerAccount__c is_acct = new c2g__codaGeneralLedgerAccount__c
        (
            Name = 'Income Statement Account',
            c2g__ReportingCode__c = '400000000',
            c2g__Type__c = 'Income Statement'
        );
        insert is_acct;
        return is_acct;
      //}
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
        account.c2g__CODABankCity__c = '99';
        account.c2g__CODABankCountry__c = '99';
        account.c2g__CODABankName__c = '99';
        account.c2g__CODABankSWIFTNumber__c = '99';
        account.c2g__CODABankStreet__c = '99';
        account.c2g__CODABankAccountName__c = '99';
        account.c2g__CODABankAccountNumber__c = '99';
        account.c2g__CODABankStateProvince__c = '99';
        account.c2g__CODAExemptionCertificate__c = 'EXEMPT';
        account.RecordTypeId = vendorRecordType;

        insert account;
        return account;
    }

    // --> Payable Invoice:
    public static c2g__codaPurchaseInvoice__c createPIN(Account account, Date invoice_date, Id glaID, Decimal amount, Date prepaidStart, Date prepaidEnd)
    {
        c2g__codaPurchaseInvoice__c pin = new c2g__codaPurchaseInvoice__c(
            c2g__Account__c = account.id,
            c2g__InvoiceDate__c = invoice_date,
            c2g__Dimension2__c = testDimension2.id,
            c2g__Dimension3__c = testDimension3.id,
            ffap__DeriveDueDate__c = TRUE,
            ffap__DeriveCurrency__c = TRUE,
            ffap__DerivePeriod__c = TRUE,
            c2g__AccountInvoiceNumber__c = 'TEST');
        insert pin;
            createPIN_Line(glaID, amount, pin, prepaidStart, prepaidEnd);
        return pin;
    }
    public static void createPIN_Line(Id glaID, Decimal amount, c2g__codaPurchaseInvoice__c pin, Date prepaidStart, Date prepaidEnd)
    {
        system.debug('inside createpin');
          NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
        c2g__codaPurchaseInvoiceExpenseLineItem__c line = new c2g__codaPurchaseInvoiceExpenseLineItem__c(
            c2g__PurchaseInvoice__c = pin.id,
            c2g__GeneralLedgerAccount__c = glaID,
            c2g__NetValue__c = amount,
            c2g__Dimension2__c = testDimension2.id,
            c2g__Dimension3__c = testDimension3.id,
            Prepaid_Start_Date__c = prepaidStart,
            Prepaid_End_Date__c = prepaidEnd,
            Prepaid_Reverse_Dim_3__c = testDimension3.id,
            Prepaid_Reverse_GLA__c = glaID,
            Prepaid_Journals_Created__c = false,
            ffap__SetGLAToDefault__c = FALSE);
        ffaTriggers.Bypass_ffaPayableInvoiceTrigger__c = False;
        update ffaTriggers;
        insert line;        
         system.debug('inserted' + line.id);
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

    
    public static void postPIN()
    {
        c2g.CODAAPICommon_9_0.Context companyContext = new c2g.CODAAPICommon_9_0.Context();
        companyContext.CompanyName = testCompany1.Name;
        c2g.CODAAPICommon.Reference pinRef = new c2g.CODAAPICommon.Reference();
        pinRef.id = testPin.id;
        c2g.CODAAPIPurchaseInvoice_9_0.PostPurchaseInvoice(companyContext, pinRef);
    }
    
}