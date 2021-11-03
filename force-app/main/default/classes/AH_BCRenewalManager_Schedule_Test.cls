/****************************************************************************************
Name            : AH_BCRenewalManager_Schedule_Test
Author          : Ria Chawla
Created Date    : 4/2/18
Modified Date	: 9/13/18
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_BCRenewalManager_Schedule and AH_BCRenewalManager_Batch

******************************************************************************************/
@isTest 
public class AH_BCRenewalManager_Schedule_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.StartTest();
        
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;         

        // CREATE TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        insert o;   
        
        // CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         

        // CREATE TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        insert idx1; 

        // CREATE A TEST PRODUCT RECORD
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id;
        prd01.Duration_Months__c = 2;
        prd01.Billing_Renewal_Lead_Time_Days__c = 1;
        prd01.Corporate_Product_Group__c = 'MTech';
        insert prd01;

        // CREATE A TEST BILLING RECORD
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = a.Id;
        blgCnrct.Renewal_Increase_Cap_Percentage__c = 10;
        insert blgCnrct;

        // CREATE TEST RENEWAL PRICE BOOK
        Renewal_Pricebook__c pb = new Renewal_Pricebook__c();
        pb.Name = 'Test Price Book';
        insert pb;
        Renewal_Pricebook__c pb2 = new Renewal_Pricebook__c();
        pb2.Name = 'Test Price Book2';
        insert pb2;

        // CREATE TEST RENEWAL PRICING ENTRY
        Renewal_Pricing_Entry__c rpe = new Renewal_Pricing_Entry__c();
        rpe.Start_Date__c = Date.today().addDays(-100);
        rpe.End_Date__c = Date.today().addDays(200);
        rpe.Renewal_Pricebook__c = pb.Id;
        rpe.Percent_Increase__c = 20;
        insert rpe;

        // CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;

        // CREATE TEST ACTIVITY LINE ITEM RECORDS
        List<Activity_Line_Item__c> lstALI = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c ali1 = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        ali1.Cancel_Line_Item__c = false; 
        ali1.Product__c = prd01.Id; 
        ali1.Contract_Start_Date__c = Date.Today().addYears(-1); 
        ali1.Contract_End_Date__c = Date.Today();
        ali1.Units__c = 1; 
        ali1.Status__c = 'Active';
        ali1.Payment_Terms__c = pt.Id;
        ali1.Contract_Amount__c = 1000;
        ali1.Renewal_Base_Price__c = 500;
        ali1.Auto_Renewal__c = true;
        ali1.Renewal_Processed__c = false;
        ali1.Renewal_Pricebook__c = pb.Id;
        ali1.Revenue_Category__c = 'Services';
        //ali1.Renewal_Date__c = Date.Today().addDays(-100);
        lstALI.add(ali1);         
        
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        ali2.Cancel_Line_Item__c = false; 
        ali2.Product__c = prd01.Id; 
        ali2.Contract_Start_Date__c = Date.Today().addDays(-360); 
        ali2.Contract_End_Date__c = Date.Today().addDays(5); 
        ali2.Units__c = 1; 
        ali2.Status__c = 'Active';
        ali2.Payment_Terms__c = pt.Id;
        ali2.Contract_Amount__c = 1000;
        ali2.Renewal_Base_Price__c = 500;
        ali2.Auto_Renewal__c = true;
        ali2.Renewal_Processed__c = false;
        ali2.Renewal_Pricebook__c = pb.Id;
        ali2.Revenue_Category__c = 'Services';
        ali2.No_Price_Increase_Through__c = Date.Today() + 200;
        //ali2.Renewal_Date__c = Date.Today().addDays(-100);
        lstALI.add(ali2);  
        
        database.insert(lstALI);

        // INSERT CUSTOM SETTINGS
        AH_Schedule_Renewal__c renewalSettings = new AH_Schedule_Renewal__c();
        renewalSettings.Product_Line__c = 'Delphi Single Property';
        //renewalSettings.Corp_Product_Group__c = 'Newmarket';
        renewalSettings.Corp_Product_Group__c = 'MTech';
        renewalSettings.Revenue_Category__c = 'Services';
        renewalSettings.Product_SKU__c = String.ValueOf(prd01.Id);
        renewalSettings.Customer_Account__c = String.ValueOf(a.Id);
        renewalSettings.Excluded_Pricebooks__c = String.ValueOf(pb2.Id);
        insert renewalSettings;
        
        // CREATE TEST NI ADMIN ERROR LOG RECORD
        NI_Admin_Error_Log__c err = new NI_Admin_Error_Log__c();
        err.Apex_Class_Name__c = 'AH_BCRenewalManager_Schedule';
        err.DML_Type__c  = 'Insert'; 
        err.Message__c = 'Error Type: System.QueryException, Cause: null, Line Number: 337, Error Message: unexpected token: \'<EOF>\''; 
        err.Object_Name__c = 'Activity_Line_Item__c'; 
        insert err;

        Test.StopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: Test Schedulable Class without Abort
    // =======================================================================================================================================   
    @isTest static void test1() 
    {
        
        AH_Schedule_Renewal__c renewalSettings = AH_Schedule_Renewal__c.getOrgDefaults();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 prd = [SELECT Id FROM Product2 LIMIT 1];
        
        system.debug(' *^* renewalSettings = ' + renewalSettings);
        for (Activity_Line_Item__c lst : [SELECT Id, Renewal_Date__c, Renewal_Base_Price__c, Auto_Renewal__c, Status__c, Renewal_Processed__c, Revenue_Category__c, Product__c, 
                                          Billing_Contract__r.Account__c, Product__r.Product_Line__c, Product__r.Corporate_Product_Group__c, Renewal_Pricebook__c 
                                          FROM Activity_Line_Item__c])
        {
            system.debug(' *^* ALI = ' + lst);
        }
        
            
        Test.StartTest();
        
        List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>(
            [SELECT Id, Renewal_Date__c, Renewal_Base_Price__c, Auto_Renewal__c, Status__c, Renewal_Processed__c, Revenue_Category__c, Product__c, 
             Billing_Contract__r.Account__c, Product__r.Product_Line__c, Product__r.Corporate_Product_Group__c, Renewal_Pricebook__c 
             FROM Activity_Line_Item__c 
             WHERE Renewal_Date__c <=: Date.today().addDays(-1) 
             AND Renewal_Date__c >=: Date.today().addyears(-100) 
             AND Renewal_Base_Price__c != null 
             AND Auto_Renewal__c = true 
             AND Status__c != 'Cancelled' 
             AND Renewal_Processed__c = false  
             AND Revenue_Category__c =: renewalSettings.Revenue_Category__c   
             AND Product__c =: Id.valueOf(renewalSettings.Product_SKU__c)   
             AND Billing_Contract__r.Account__c =: Id.valueOf(renewalSettings.Customer_Account__c)   
             AND Product__r.Product_Line__c =: renewalSettings.Product_Line__c  
             AND Product__r.Corporate_Product_Group__c =: renewalSettings.Corp_Product_Group__c   
             AND Renewal_Pricebook__c NOT IN : renewalSettings.Excluded_Pricebooks__c.split(',')]);         
        
        system.assertNotEquals(0, lstALIAsserts.size());
        
        AH_BCRenewalManager_Cntr renewalController = new AH_BCRenewalManager_Cntr();
        
        Boolean flag = false;
        CronJobDetail cronJob = new CronJobDetail();
        
        try
        {
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            renewalController.abortScheduledJob();
            flag = true;
        }
        catch (Exception e)
        {
            system.debug('Exception = ' + e);
        }
        
        AH_BCRenewalManager_Schedule sh1 = new AH_BCRenewalManager_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Schedule Renewal', sch, sh1);
        
        Test.stopTest();
        
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: Test Schedulable Class - with Abort
    // =======================================================================================================================================   
    @isTest static void test2() 
    {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 prd = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.StartTest();
        
        AH_BCRenewalManager_Cntr renewalController = new AH_BCRenewalManager_Cntr();
        
        Boolean flag = false;
        CronJobDetail cronJob = new CronJobDetail();
        
        try
        {
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            renewalController.abortScheduledJob();
            flag = true;
        }
        catch (Exception e)
        {
            system.debug('Exception = ' + e);
        }
        
        AH_BCRenewalManager_Schedule sh1 = new AH_BCRenewalManager_Schedule();
        String sch = '0 0 23 * * ?';
        system.schedule('Schedule Renewal', sch, sh1);
        
        Test.stopTest();
        
        renewalController.callSchedulableClass();
        renewalController.abortScheduledJob();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();

        if (flag == true)
        {
            system.assertEquals('Job aborted successfully!', pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
            system.assertEquals('Job is already scheduled, please abort and reschedule!', pageMessages[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        else 
        {
        	system.assertEquals('Job is already scheduled, please abort and reschedule!', pageMessages[0].getSummary(), 'Failed to get the expected Apex Page Message..');
        	system.assertEquals('Job aborted successfully!', pageMessages[1].getSummary(), 'Failed to get the expected Apex Page Message..');
        }
        
    }    
    
}