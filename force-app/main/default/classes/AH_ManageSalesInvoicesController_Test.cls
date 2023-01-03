/****************************************************************************************** 
Name            : AH_ManageSalesInvoicesController_Test
Author          : Bhuleshwar Deshpande
Created Date    : 11/13/2018
Modified Date	: 01/30/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_ManageSalesInvoicesController class
				: 
				:
******************************************************************************************/
@isTest 
public class AH_ManageSalesInvoicesController_Test 
{

    public static c2g__codaCompany__c testCompany1;
    public static c2g__codaDimension2__c testDimension2;
    public static c2g__codaDimension3__c testDimension3;
    public static c2g__codaGeneralLedgerAccount__c testGLA;
    
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup 
    static void createTestData()
    {
        Test.StartTest();
        
        List<c2g__codaAccountingCurrency__c> testcurr1 =  new List<c2g__codaAccountingCurrency__c>([SELECT id, name from c2g__codaAccountingCurrency__c ]);
        system.debug('testcurr1 : '+testcurr1);
        
        // CREATE TEST COMPANY & ACCOUNTING CURRENCY
        testCompany1 = ffaTestUtilities.createFFACompany('TEST COMPANY 111', true, 'USD');
        c2g__codaAccountingCurrency__c testcurr = [SELECT id, name from c2g__codaAccountingCurrency__c where c2g__ownerCompany__c = :testCompany1.id limit 1];
        system.debug('\n\n ***** ffaUtilities_TEST - setupTestData - testCompany1' + testCompany1);
        system.assertNotEquals(NULL, testCompany1.id, 'Company is not created.');
        system.assertNotEquals(NULL, testcurr.id, 'Accounting Currency is not created.');

        // CREATE TEST DIMENSIONS 1 & 2
        testGLA = ffaTestUtilities.create_IS_GLA();
        testDimension2 = ffaTestUtilities.createTestDimension2();
        testDimension3 = ffaTestUtilities.createTestDimension3();
        system.assertNotEquals(NULL, testDimension2.id, 'Dimension 2 has not created.');
        system.assertNotEquals(NULL, testDimension3.id, 'Dimension 3 has not created.');

       	c2g__codaGeneralLedgerAccount__c recAcc = new c2g__codaGeneralLedgerAccount__c();
        recAcc.Name = 'Test Receivable Account 1';
        recAcc.c2g__ReportingCode__c = '200';
        recAcc.c2g__Type__c = 'Balance Sheet';
        insert recAcc;
        system.assertNotEquals(NULL, recAcc.id, 'Ledger Account has not created.');
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.c2g__CODAAccountTradingCurrency__c = testcurr.name;
        a.c2g__CODATaxCalculationMethod__c  = 'Net of Discount';
        a.c2g__CODAAccountsReceivableControl__c = recAcc.id;
        insert a;         
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.Size(), 'Failed to create test Account record in manageBillingContractRenewalControl_Test');         
        
        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = rt;
        o.Purchase_Order__c = '111';
        insert o;   
        List<Opportunity> lstOpportunityAsserts = new List<Opportunity>([SELECT Id FROM Opportunity]);
        system.assertEquals(1, lstOpportunityAsserts.size(), 'Failed to create test Opportunity record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         
        List<Product_Group__c> lstProductGroupAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]);
        system.assertEquals(1, lstProductGroupAsserts.size(), 'Failed to create test Product_Group__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        insert idx1; 
        List<NI_DeploymentInstanceIndex__c> lstDIIndexAsserts = new List<NI_DeploymentInstanceIndex__c>([SELECT Id FROM NI_DeploymentInstanceIndex__c]);
        system.assertEquals(1, lstDIIndexAsserts.size(), 'Failed to create test NI_DeploymentInstanceIndex__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST PRODUCT RECORD
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id;
        prd01.Duration_Months__c = 2;
        prd01.c2g__CODASalesRevenueAccount__c = testGLA.id;
        prd01.Dimension_2__c = testDimension2.id;
        prd01.Dimension_3__c = testDimension3.id;
        insert prd01;
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2]);
        system.assertEquals(1, lstProduct2Asserts.size(), 'Failed to create test Product2 record in manageBillingContractRenewalControl_Test');
        
        // CREATE TEST REMITTANCE INFO RECORD
        Remittance_Info__c r = ffaTestUtilities.create_Remittance_Info('Test Remittance');
		system.assertNotEquals(NULL, r.id, 'Failed to create Remittacne Info record.');
        
        // CREATE TEST CONTACT
        Contact con = NI_TestClassData.createTestContact(1, a.id);
        insert con;
        system.assertNotEquals(NULL, con.id, 'Failed to create Contact record.');

		// CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        List<Payment_Terms__c> lstPaymentTerms = new List<Payment_Terms__c>([SELECT Id FROM Payment_Terms__c]);
        system.assertEquals(1, lstPaymentTerms.size(), 'Failed to create test Payment_Terms__c record in manageBillingContractRenewalControl_Test');   
        
        
        // TEST BILLING CONTRACTS
        List<Billing_Contract__c> bcList = new List<Billing_Contract__c>();
        for (Integer i = 1; i<= 45; i++)
        {
            Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(i);
            blgCnrct.Name = 'SN Test '+i;
            blgCnrct.Account__c =  a.Id;
            blgCnrct.Renewal_Increase_Cap_Percentage__c = 5;
            blgCnrct.Opportunity__c = o.id;
            blgCnrct.Remittance_Info__c =  r.id;
            blgCnrct.Accounting_Currency__c = testcurr.id;
            blgCnrct.Company__c = testCompany1.id;
            blgCnrct.Bill_To_Contact__c = con.id;
            bcList.add(blgCnrct);
        }
        insert bcList;
        
        system.debug('bcList size : '+bcList.size());
        List<Billing_Contract__c> lstBillingContractAsserts = new List<Billing_Contract__c>([SELECT Id FROM Billing_Contract__c]);
        system.assertEquals(45, lstBillingContractAsserts.size(), 'Failed to create test Billing_Contract__c record in manageBillingContractRenewalControl_Test');
        //system.debug('lstBillingContractAsserts : '+lstBillingContractAsserts);
        
		// TEST ACTIVITY LINE ITEMS    
        List<Activity_Line_Item__c> actList = new List<Activity_Line_Item__c>();
        for (Integer i = 1; i <= 45; i++)
        {    
            Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(bcList[i-1].Id);
            actLI.Cancel_Line_Item__c = false; 
            actLI.Product__c = prd01.Id; 
            actLI.Opportunity__c = o.id;  
            actLI.Payment_Terms__c = pt.Id;
            actLI.Contract_Start_Date__c = Date.Today()-100;  
            actLI.Contract_End_Date__c = Date.Today() + 200; 
            actLI.Units__c = 1; 
            actLI.Status__c = 'Active';
            actLI.Origin__c = 'Renewal';
            actLI.Contract_Amount__c = 1000;
            actLI.Renewal_Base_Price__c = 500;
            actLI.Auto_Renewal__c = false;
            actLI.Renewal_Processed__c = false;
            actLI.Revenue_Category__c = 'Services';
            actList.add( actLI);
        }
        insert actList;
        List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c]);
		system.debug('ALI size : '+lstALIAsserts.size());
        system.assertEquals(45, lstALIAsserts.size(), 'Failed to create test Activity_Line_Item__c record.');  
        
        // TEST BILLING CONTRACT LINE ITEMS
        List<Billing_Contract_Line_Item__c> lstBCLIs = new List<Billing_Contract_Line_Item__c>();
        for (Integer i = 1; i <= 45; i++)
        {      
            Billing_Contract_Line_Item__c blci1 = NI_TestClassData.createBillingContract(bcList[i-1].ID, actList[i-1].Id);
            blci1.Split_Order__c = 1;
            blci1.Status__c = 'Active';
            blci1.Activation_Required__c = false;
            blci1.Pro_Rated__c = false;
            blci1.Revenue_Category__c = 'Support';
            blci1.Ready_to_Invoice__c = true;
            blci1.Total_Amount__c = 500;
            //blci1.Exclude_Automated_Invoicing__c = false; 
            blci1.Invoiced__c = false;
            blci1.Opportunity__c = o.id;
            blci1.Product__c = prd01.id;
            blci1.Invoice_Date__c = Date.today() - 1;   
            lstBCLIs.add(blci1);
        }
        insert lstBCLIs;
        List<Billing_Contract_Line_Item__c> bcliList = new List<Billing_Contract_Line_Item__c>();
        bcliList = [ SELECT ID FROM Billing_Contract_Line_Item__c ];
        system.debug('BCLI size : '+bcliList.size());
        system.assertEquals(45, bcliList.size(), 'Failed to create test Billing_Contract_Line_Item__c record.');  

        
        Test.StopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHODS 
    // =======================================================================================================================================
    @isTest static void testAH_ManageSalesInvoicesController1()
    {   
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_ManageSalesInvoices; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', UserInfo.getUserId());   
        
        // SET TEST PAGE
        Test.setCurrentPage(pageRef);
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_ManageSalesInvoicesController ctrl = new AH_ManageSalesInvoicesController();
        
        List<Billing_Contract__c> bcList = [select ID, Name,Account__c, Company__c from Billing_Contract__c where Name = 'SN Test 1' ];
        List<Billing_Contract_Line_Item__c> bcliList = [select ID, Name, Billing_Contract__c from Billing_Contract_Line_Item__c where Billing_Contract__c =: bcList[0].id ];
        ctrl.dummyBCLI = bcliList[0];
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        
        ctrl.fetchData();
        system.assertEquals(1, ctrl.wrapList.size(), 'Failed to retrieve records on Load Data button..');
        
        ctrl.createInvoices();  

        List<c2g__codaInvoice__c> sinList = new List<c2g__codaInvoice__c>([select id, name from c2g__codaInvoice__c]);
        
        system.debug('sinList.size() : '+sinList.size());
        system.debug('sinList in test class : '+sinList);
        
        system.assertEquals(1, sinList.size(), 'Sales Invoices count mismatch');
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages : '+pageMessages);
        String message = String.valueOf(pageMessages[1]);
        message = message.toLowerCase();
        system.assertEquals(true, message.contains('successfully created sales invoices'), 'Sales Invoices not created');
        
        ctrl.postInvoices();
        
        ctrl.refreshInvoices(); 
        
        ctrl.next();
        
        ctrl.reset();
        
        Test.stopTest();
    } 
    

    @isTest static void testAH_ManageSalesInvoicesController2()
    {   
        Test.startTest();

        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_ManageSalesInvoices; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', UserInfo.getUserId());   
         
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_ManageSalesInvoicesController ctrl = new AH_ManageSalesInvoicesController();
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        
        List<Billing_Contract__c> lstBillingContracts = new List<Billing_Contract__c>([SELECT Id, Remittance_Info__c, Accounting_Currency__c FROM Billing_Contract__c]);
        lstBillingContracts[0].Remittance_Info__c = null;
        update lstBillingContracts;

        List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id, Payment_Terms__c FROM Activity_Line_Item__c]);
		lstALIAsserts[0].Payment_Terms__c = NULL;
		update lstALIAsserts;

        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id, Dimension_2__c, Dimension_3__c FROM Product2]);
        lstProduct2Asserts[0].Dimension_2__c = NULL;
        lstProduct2Asserts[0].Dimension_3__c = NULL;
        update lstProduct2Asserts;
        
        ctrl.fetchData();

        ctrl.createInvoices();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages : '+pageMessages);
        
        String error0 = String.valueOf(pageMessages[1]);
        String error1 = String.valueOf(pageMessages[2]);
        String error2 = String.valueOf(pageMessages[3]);
        String error3 = String.valueOf(pageMessages[4]);
        
        system.assertEquals(true, error0.contains('Invoice Term should be present on Activity Line Item'), 'Not throwing error of Invoice Term.');
        system.assertEquals(true, error1.contains('Remittance Info should be present on Billing Contract'), 'Not throwing error of Remittance Info.');
        system.assertEquals(true, error2.contains('Attention: Dimension 2 is required on all Sales Invoices.'), 'Not throwing error of Dimension 2.');
        system.assertEquals(true, error3.contains('Attention: Dimension 3 is required on all Sales Invoices.'), 'Not throwing error of Dimension 3.');
        
        Test.stopTest();
    } 
    
    @isTest static void testAH_ManageSalesInvoicesController3()
    {   
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_ManageSalesInvoices; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', UserInfo.getUserId());   
         
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_ManageSalesInvoicesController ctrl = new AH_ManageSalesInvoicesController();

        List<Billing_Contract__c> bcList = [select ID, Name,Account__c, Company__c from Billing_Contract__c where Name = 'SN Test 1' ];
        List<Billing_Contract_Line_Item__c> bcliList = [select ID, Name, Billing_Contract__c from Billing_Contract_Line_Item__c where Billing_Contract__c =: bcList[0].id ];
        ctrl.dummyBCLI = bcliList[0];
       
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        
        List<Billing_Contract__c> lstBillingContracts = new List<Billing_Contract__c>([SELECT Id, Remittance_Info__c, Accounting_Currency__c FROM Billing_Contract__c]);
        lstBillingContracts[0].Accounting_Currency__c = null;
        update lstBillingContracts;

        ctrl.fetchData();
        
        ctrl.createInvoices();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages : '+pageMessages);
        String message = String.valueOf(pageMessages[1]);
        
        boolean isErrorFound = false;
        for (ApexPages.Message m : pageMessages)
        {
            String msg = String.valueOf(m);
            msg = msg.toLowerCase();
			system.debug('message : '+msg);
            
            if (msg.contains('invoice currency field: you must enter a value.'))
            {
                isErrorFound = true;
            }
        }
        system.assertEquals(true, isErrorFound, 'Not throwing error on Accounting Currency.');
        
        Test.stopTest();
    }
    
	
    @isTest static void testAH_ManageSalesInvoicesController4()
    {   
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_ManageSalesInvoices; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', UserInfo.getUserId());   
        
        // SET TEST PAGE
        Test.setCurrentPage(pageRef);
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_ManageSalesInvoicesController ctrl = new AH_ManageSalesInvoicesController();
                
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        
        ctrl.fetchData();
        
        system.debug('ctrl.wrapList.size() : '+ctrl.wrapList.size());
        system.assertEquals(30, ctrl.wrapList.size(), 'Failed to retrieve records on Load Data button..');
        
        ctrl.next();
        ctrl.previous();
        ctrl.reset();
        
        Test.stopTest();
    } 
    
    
    // TEST SCHEDULABLE CLASS  
    @isTest static void testSchedulableClass(){
        
        Test.startTest();
        
        String query = 'SELECT ID, Name,'+ 
                            ' Billing_Contract__c, Invoiced__c, '+
                            ' Billing_Contract__r.Name from Billing_Contract_Line_Item__c';
        
		List<Billing_Contract_Line_Item__c> bcliList = Database.query(query);
        for (Billing_Contract_Line_Item__c bcli : bcliList )
        {
            if (bcli.Billing_Contract__r.Name != 'SN Test 1')
            {
                bcli.Invoiced__c = true;
            }
        }
        
        database.update(bcliList);
        
        AH_Schedule_SalesInvoices sch2 = new AH_Schedule_SalesInvoices(); //Schedule apex class name
        String sch = '0 0 23 * * ?'; //schedule interval time
        system.schedule('TEST Schedule Invoices', sch, sch2); //system method to schedule apex class
        
        try {
            CronJobDetail cronJob = new CronJobDetail();
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'TEST Schedule Invoices'];
            system.debug('cronJob : ' +cronJob.Id);
            system.assertNotEquals(NULL, cronJob.Id, 'AH_Schedule_SalesInvoices Class has not scheduled.');
        }
        catch(Exception e)
        {
            system.debug('Exception while scheduling job in test class : '+e);
        }
        Test.StopTest();
    }
}