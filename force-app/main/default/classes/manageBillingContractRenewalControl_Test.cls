/****************************************************************************************
Name            : manageBillingContractRenewalControl_Test
Author          : Sean Harris
Created Date    : 09/10/2018
Modified Date	: 09/12/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-029940
Description     : Test class for manageBillingContractRenewalController
				: 
CYBAGE TODO LIST:
 	1. Get 90% + coverage on manageBillingContractRenewalController with this class
	2. Create assertions that ensure that the VF page is loading data correctly.
	3. Create assertions to verify ApexPages.message text 


******************************************************************************************/
@isTest 
public class manageBillingContractRenewalControl_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.StartTest();
        
        Account a = NI_TestClassData.createTestAccount(1);
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
        insert prd01;
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2]);
        system.assertEquals(1, lstProduct2Asserts.size(), 'Failed to create test Product2 record in manageBillingContractRenewalControl_Test');
        
        // CREATE A TEST BILLING RECORD
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = a.Id;
        blgCnrct.Renewal_Increase_Cap_Percentage__c = 10;
        insert blgCnrct;
        List<Billing_Contract__c> lstBillingContractAsserts = new List<Billing_Contract__c>([SELECT Id FROM Billing_Contract__c]);
        system.assertEquals(1, lstBillingContractAsserts.size(), 'Failed to create test Billing_Contract__c record in manageBillingContractRenewalControl_Test');   
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // CREATE TEST RENEWAL PRICE BOOK
        Renewal_Pricebook__c pb = new Renewal_Pricebook__c();
        pb.Name = 'Test Price Book';
        insert pb;
        Renewal_Pricebook__c pb2 = new Renewal_Pricebook__c();
        pb2.Name = 'Test Price Book2';
        insert pb2;
        List<Renewal_Pricebook__c> lstRenewalPb = new List<Renewal_Pricebook__c>([SELECT Id FROM Renewal_Pricebook__c]);
        system.assertEquals(2, lstRenewalPb.size(), 'Failed to create test Price books record in manageBillingContractRenewalControl_Test');   
        
        // CREATE TEST RENEWAL PRICING ENTRY
        Renewal_Pricing_Entry__c rpe = new Renewal_Pricing_Entry__c();
        rpe.Start_Date__c = Date.today().addDays(-100);
        rpe.End_Date__c = Date.today().addDays(200);
        rpe.Renewal_Pricebook__c = pb.Id;
        rpe.Percent_Increase__c = 20;
        insert rpe;
        List<Renewal_Pricing_Entry__c> lstRPE = new List<Renewal_Pricing_Entry__c>([SELECT Id FROM Renewal_Pricing_Entry__c]);
        system.assertEquals(1, lstRPE.size(), 'Failed to create test Renewal_Pricing_Entry__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        List<Payment_Terms__c> lstPaymentTerms = new List<Payment_Terms__c>([SELECT Id FROM Payment_Terms__c]);
        system.assertEquals(1, lstPaymentTerms.size(), 'Failed to create test Payment_Terms__c record in manageBillingContractRenewalControl_Test');   
        
        // CREATE A TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI.Cancel_Line_Item__c = false; 
        actLI.Product__c = prd01.Id; 
        actLI.Contract_Start_Date__c = Date.Today(); // - 200; 
        actLI.Contract_End_Date__c = Date.Today() + 200; 
        actLI.Units__c = 1; 
        actLI.Status__c = 'Active';
        actLI.Payment_Terms__c = pt.Id;
        actLI.Contract_Amount__c = 1000;
        actLI.Renewal_Base_Price__c = 500;
        actLI.Auto_Renewal__c = true;
        actLI.Renewal_Processed__c = false;
        actLI.Renewal_Pricebook__c = pb.Id;
        actLI.Revenue_Category__c = 'Services';
        insert actLI;         
        
        Activity_Line_Item__c actLI_1 = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI_1.Cancel_Line_Item__c = false; 
        actLI_1.Product__c = prd01.Id; 
        actLI_1.Contract_Start_Date__c = Date.Today(); // - 200; 
        actLI_1.Contract_End_Date__c = Date.Today() + 10; 
        actLI_1.Units__c = 1; 
        actLI_1.Status__c = 'Active';
        actLI_1.Payment_Terms__c = pt.Id;
        actLI_1.Contract_Amount__c = 1000;
        actLI_1.Renewal_Base_Price__c = 500;
        actLI_1.Auto_Renewal__c = true;
        actLI_1.Renewal_Processed__c = false;
        actLI_1.Renewal_Pricebook__c = pb.Id;
        actLI_1.Revenue_Category__c = 'Services';
        actLI_1.No_Price_Increase_Through__c = Date.Today() + 200;
        insert actLI_1;
        
        List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c]);
        system.assertEquals(2, lstALIAsserts.size(), 'Failed to create test Activity_Line_Item__c record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        // INSERT CUSTOM SETTINGS
        AH_Schedule_Renewal__c renewalSettings = new AH_Schedule_Renewal__c();
        renewalSettings.Product_Line__c = 'Delphi Single Property';
        renewalSettings.Corp_Product_Group__c = 'Newmarket';
        renewalSettings.Revenue_Category__c = 'Services';
        renewalSettings.Product_SKU__c = String.ValueOf(prd01.Id);
        renewalSettings.Customer_Account__c = String.ValueOf(a.Id);
        renewalSettings.Excluded_Pricebooks__c = String.ValueOf(pb2.Id);
        insert renewalSettings;
        
        // CREATE TEST NI ADMIN ERROR LOG RECORD
        NI_Admin_Error_Log__c err = new NI_Admin_Error_Log__c();
        err.Apex_Class_Name__c = 'AH_ScheduleManageBillingContractRen';
        err.DML_Type__c  = 'Insert';
        err.Message__c = 'Error Type: System.QueryException, Cause: null, Line Number: 337, Error Message: unexpected token: \'<EOF>\'';
        err.Object_Name__c = 'Activity_Line_Item__c'; 
        insert err;
        List<NI_Admin_Error_Log__c> lstErrorLogs = new List<NI_Admin_Error_Log__c>([SELECT Id FROM NI_Admin_Error_Log__c]);
        system.assertEquals(1, lstErrorLogs.size(), 'Failed to create test NI_Admin_Error_Log__c in manageBillingContractRenewalControl_Test');   
        
        system.debug('Test Class Queries : '+ Limits.getQueries());
        
        Test.StopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void testManageBillingCntrctRenewalCtlr1()
    {   
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 prd = [SELECT Id FROM Product2 LIMIT 1];
        Renewal_Pricebook__c pb2 = [select ID, Name from Renewal_Pricebook__c where Name = 'Test Price Book2'];
        
        List<Activity_Line_Item__c> alis = new List<Activity_Line_Item__c>();
        
        for (Activity_Line_Item__c ali : [SELECT Id, Activation_Date__c, ACTION_Rebuild_Billing_Lines__c, Contract_Start_Date__c, Contract_End_Date__c FROM Activity_Line_Item__c])
        {
            ali.Activation_Date__c = Date.today();
            ali.Renewal_Date__c = Date.today();
            ali.Contract_Start_Date__c = Date.today().addMonths(-1);
            ali.Contract_End_Date__c = Date.today().addMonths(1);
            ali.Auto_Renewal__c = true;
            alis.add(ali);
        }
        
        update alis;
        
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.manageBillingContractRenewal; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', UserInfo.getUserId());   
         
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        manageBillingContractRenewalController ctrl = new manageBillingContractRenewalController();
        ctrl.dummyLine.Contract_Start_Date__c = Date.today().addYears(-1);
        ctrl.dummyLine.Contract_End_Date__c = Date.today().addYears(1);
        ctrl.dummyLine.Revenue_Category__c = 'Services';
        ctrl.dummyLine.Product__c = prd.Id;
        ctrl.dummyBC.Account__c = acc.Id;
        ctrl.rightPBs1.add(new SelectOption(pb2.Id, pb2.Name));
        
        ctrl.fetchData();
        
        system.assertEquals(2, ctrl.wrapperList.size(), 'Failed to fetch records on VF Page in manageBillingContractRenewalControl_Test class..');

        for (manageBillingContractRenewalController.aliWrapper al : ctrl.wrapperList)
        {
            al.check = true;
            al.percentIncrease = 50;
        }
        
        ctrl.reloadPriceIncrease();
        
        ApexPages.Message[] pageMessages1 = ApexPages.getMessages();
        system.assertEquals('Reload Successful!', pageMessages1[0].getSummary(), 'Failed to get the "Reload Successful!" Apex Page Message..');
        
        ctrl.processRenewal();
        
        ApexPages.Message[] pageMessages2 = ApexPages.getMessages();
        system.assertEquals('Renewal Successful!', pageMessages2[1].getSummary(), 'Failed to get the "Renewal Successful!" Apex Page Message..');
        
        Test.stopTest();       
    } 

    // ======================================================================================================================================= 
    // = TEST METHOD 2: Test Schedulable Class
    // =======================================================================================================================================   
    @isTest static void testManageBillingCntrctRenewalCtlr2() 
    {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 prd = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.StartTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.manageBillingContractRenewal; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', UserInfo.getUserId());   
         
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        manageBillingContractRenewalController renewalController = new manageBillingContractRenewalController();
        
        Boolean flag = false;
        CronJobDetail cronJob = new CronJobDetail();
        try{
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            system.debug('in try catch : ' +cronJob.Id);
            renewalController.abortScheduledJob();
            flag = true;
        }
        catch(Exception e){
            system.debug('Exception => '+e);
            flag = false;
        }
        
        AH_ScheduleManageBillingContractRen sh1 = new AH_ScheduleManageBillingContractRen();
        String sch = '0 0 23 * * ?';
        system.schedule('Schedule Renewal', sch, sh1);
        
        renewalController.actLine.Revenue_Category__c = 'Hosting and Support';
        renewalController.testBC.Account__c = acc.id;
        renewalController.actLine.Product__c = prd.Id;
        
        renewalController.callSchedulableClass();
        renewalController.abortScheduledJob();
        Test.stopTest();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        
        if (flag == true)
        {
            system.assertEquals('Job is already scheduled, please abort and reschedule!', pageMessages[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        	system.assertEquals('Job aborted successfully!', pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        else {
        	system.assertEquals('Job is already scheduled, please abort and reschedule!', pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
        	system.assertEquals('Job aborted successfully!', pageMessages[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
    }

	// ======================================================================================================================================= 
    // = TEST METHOD 3: TEST METHOD TO TEST JOB IS ABORTED
    // =======================================================================================================================================     
    @isTest 
    static void testAbortedJob()
    {
        Test.StartTest();
        
        Boolean flag = false;            
        try{
            CronJobDetail cronJob = new CronJobDetail();
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            flag = true;
        }
        catch(Exception e){
            system.debug('Exception => '+e+ ' Line Number => '+e.getLineNumber());
            flag = false;
        }
        
        manageBillingContractRenewalController renewalController = new manageBillingContractRenewalController();
        renewalController.abortScheduledJob();
        
        Test.stopTest();
        CronJobDetail cronJob = new CronJobDetail();
        try{
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  false;
            if(e.getMessage().contains('List has no rows')){
                expectedExceptionThrown = true;
            }
            else{
                expectedExceptionThrown = false;
            }
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        system.debug('flag : '+flag);
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages => '+pageMessages);
        if (flag == true)
        {
        	system.assertEquals('Job aborted successfully!', pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        else {
        	system.assertEquals('No jobs found.', pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4: TEST JOB SCHEDULED
    // =======================================================================================================================================     
    @isTest static void testJobAlreadyScheduled()
    {
        Test.StartTest();
        
        Boolean flag = false;            
        try{
            CronJobDetail cronJob = new CronJobDetail();
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            flag = true;
        }
        catch(Exception e){
            system.debug('Exception => '+e+ ' Line Number => '+e.getLineNumber());
            flag = false;
        }
        
        manageBillingContractRenewalController renewalController = new manageBillingContractRenewalController();
        renewalController.callSchedulableClass();
        
        CronJobDetail cronJob = new CronJobDetail();
        try
        {
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            system.assert(cronJob != null);
        }
        catch (Exception e)
        {}
        renewalController.callSchedulableClass();
        
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
        system.debug('pageMessages => '+pageMessages); 
        if (flag == true)
        {
            system.assertEquals('Job is already scheduled, please abort and reschedule!', 
                            pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        else {
            system.assertEquals('Schedule Renewal job scheduled for 12:00 AM daily to process renewals of those Activity Line Items that have Renewal date older than Today.<br/> Revenue_Category__c: Services<br/> Product / SKU: Embrace<br/> Corp Product Group: Newmarket<br/> Customer Account: Test1', 
                                pageMessages[0].getSummary(), 
                                'Failed to get the expected Apex Page Message..');
            system.assertEquals('Job is already scheduled, please abort and reschedule!', 
                                pageMessages[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        
        renewalController.abortScheduledJob();
        renewalController.callSchedulableClass();
        ApexPages.Message[] pageMessages1 = ApexPages.getMessages();
        system.debug('pageMessages1 =>>> '+pageMessages1);
        if (flag == true)
        {
            system.assertEquals('Job aborted successfully!', pageMessages1[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        else {
            system.assertEquals('Job is already scheduled, please abort and reschedule!', 
                                pageMessages1[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        
        Test.stopTest();
    }   
}