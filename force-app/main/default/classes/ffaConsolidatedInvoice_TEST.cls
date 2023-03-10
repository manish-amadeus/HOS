/*******************************************************************************************
Name            : ffaConsolidatedInvoice_TEST
Author          : CLD Partners
Created Date    : May 11, 2016
Description     : Provides tests for Invoice and Statement Controllers
*******************************************************************************************/

@isTest(seealldata = true)
public class ffaConsolidatedInvoice_TEST {
    public static c2g__codaCompany__c testCompany1;
    public static c2g__codaCompany__c testCompany2;
    public static Account testAccount;
    public static Product2 testServiceProduct;
    public static c2g__codaJournal__c testJournal;
    public static c2g__codaGeneralLedgerAccount__c testGLA;
    public static c2g__codaBankAccount__c testBankAccount;
    public static c2g__codaInvoice__c testInvoice;
    public static c2g__codaCreditNote__c testCreditNote;
    public static c2g__codaDimension2__c testDimension2;
    public static Product_Group__c testProductGroup_Salesforce;
    public static c2g__codaDimension3__c testDimension3;

    private static void setupTestData()
    {
        // BECAUSE THIS TEST CLASS CREATES ATTACHMENTS, WE NEED TO CREATE WIN@PROACH CUSTOMSETTINGS FOR NI_Attachment_TriggerHandler CLASS
        List<Winaproach_Incident_Case_Record_Type__c> lstCSCheck = new List<Winaproach_Incident_Case_Record_Type__c>([SELECT Id FROM Winaproach_Incident_Case_Record_Type__c]);
        if (lstCSCheck.isEmpty())
        {
            Winaproach_Incident_Case_Record_Type__c winAppCS1 = NI_TestClassData.createIncidentCaseRecordType();
            insert winAppCS1;
            WinaproachIncidentSettings__c winAppCS2 = NI_TestClassData.createWinaproachIncidentSettings();
            insert winAppCS2;
            ServiceNowIncidentSettings__c winAppCS3 = NI_TestClassData.createServiceNowIncidentSettings();
            insert winAppCS3;            
        }
        
        Test.startTest();
        testGLA = create_IS_GLA();
        testCompany1 = createFFACompany('TEST COMPANY', true, 'USD');
        c2g__codaAccountingCurrency__c testcurr = [SELECT id from c2g__codaAccountingCurrency__c where c2g__ownerCompany__c = :testCompany1.id limit 1];
        system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany1' + testCompany1);
        testAccount = createAccount('TEST Account', testGLA.id);
        testAccount.Force_Month_End_Invoice_Date__c = true;
        update testAccount;
        testDimension2 = createTestDimension2();
        testDimension3 = createTestDimension3();
        testProductGroup_Salesforce = NI_TestClassData.createProductGroup(1, 'Salesforce');
        insert testProductGroup_Salesforce;
        testServiceProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK1', 'Services', 'Services',null);
        testServiceProduct.c2g__CODASalesRevenueAccount__c = testGLA.id;
        update testServiceProduct;
        Test.stopTest();

    }

    private static void createTestInvoice()
    {
        testInvoice = ffaTestUtilities.createSIN_with_Dimensions(testAccount, date.today(), testServiceProduct.id, 1000, null, testDimension2.id, testDimension3.id);
    }

    @isTest static void testCopnsolidatedInvoiceController(){
        setupTestData();
        createTestInvoice();
        	//post invoice:
        	c2g.CODAAPICommon_10_0.Context compWrapper = new c2g.CODAAPICommon_10_0.Context();
            compWrapper.CompanyName = 'TEST COMPANY';
            c2g.CODAAPICommon.Reference invoiceWrapper = new c2g.CODAAPICommon.Reference();
            invoiceWrapper.id = testInvoice.id;
            c2g.CODAAPISalesInvoice_10_0.PostInvoice(compWrapper, invoiceWrapper);
            Test.setCurrentPageReference(new PageReference('Page.ffaConsolidateInvoices')); 
			System.currentPageReference().getParameters().put('id', testAccount.id);

            ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
            ffaConsolidateInvoicesController invController = new ffaConsolidateInvoicesController(stdController);
            invController.accountLookup.Account__c = testAccount.id;
            invController.addInvoices();
            for(ffaConsolidateInvoicesController.invoiceWrapper iw : invController.invoiceWrapperList){
            	iw.isInvoiceChecked = true;
            }

            invController.consolidate();
            invController.cancel();
            //invController.clearCheckboxes();


            Consolidated_Invoice__c ci = [SELECT Id FROM Consolidated_Invoice__c WHERE Account__c = :testAccount.id];
            Test.setCurrentPageReference(new PageReference('Page.ffaConsolidatedInvoicePDF')); 
			System.currentPageReference().getParameters().put('id', ci.id);
            ApexPages.currentPage().getParameters().put('id', ci.id);
			ffaConsolidatedInvoicePDFController cntrlr = new ffaConsolidatedInvoicePDFController();
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

    /**************************************************************************
    ** Create Test Company and periods
    **************************************************************************/ 
    public static c2g__codaCompany__c createFFACompany(String companyName, Boolean setAsCurrent, String homeCurrencyIso) {
        
        // BECAUSE THIS TEST CLASS CREATES ATTACHMENTS, WE NEED TO CREATE WIN@PROACH CUSTOMSETTINGS FOR NI_Attachment_TriggerHandler CLASS
        List<Winaproach_Incident_Case_Record_Type__c> lstCSCheck = new List<Winaproach_Incident_Case_Record_Type__c>([SELECT Id FROM Winaproach_Incident_Case_Record_Type__c]);
        if (lstCSCheck.isEmpty())
        {
            Winaproach_Incident_Case_Record_Type__c winAppCS1 = NI_TestClassData.createIncidentCaseRecordType();
            insert winAppCS1;
            WinaproachIncidentSettings__c winAppCS2 = NI_TestClassData.createWinaproachIncidentSettings();
            insert winAppCS2;
            ServiceNowIncidentSettings__c winAppCS3 = NI_TestClassData.createServiceNowIncidentSettings();
            insert winAppCS3;            
        }
        
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

    // --> Dimension 2
    public static c2g__codaDimension2__c createTestDimension2()
    {
        c2g__codaDimension2__c dim2 = new c2g__codaDimension2__c(
            Name = 'TEST123',
            c2g__ReportingCode__c = 'TEST123'
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
}