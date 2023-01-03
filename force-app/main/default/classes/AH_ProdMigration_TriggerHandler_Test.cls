/************************************************************************************************
Name            : AH_ProdMigration_TriggerHandler_Test 
Author          : Sean Harris
Created Date    : 04/16/2019
Last Mod Date   : 08/20/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034281
Description     : Class that tests AH_ProdMigration_TriggerHandler 
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_ProdMigration_TriggerHandler_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START - AH_ProdMigration_TriggerHandler_Test.createTestData()');

        Test.startTest();    

        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PRODUCT MIGRATION #1';
        insert a;           

        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c;
        
        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        insert o;           
        
        // CREATE A TEST OPPORTUNITY CONTACT ROLE
        OpportunityContactRole ocr = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Decision Maker');
        insert ocr;      
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         

        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX 1'); 
        insert idx1; 

        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX 2'); 
        insert idx2; 

        // CREATE A TEST PRODUCT RECORDS
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-CXL-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id; 
        prd01.Product_Line_Global__c = 'Delphi.fdc'; 
        prd01.Solution_Domain_Global__c = 'Sales & Catering';
        prd01.Name = 'APEX TEST PRODUCT #1';
        insert prd01;         

        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-CXL-02-TEST', 'Subscription');
        prd02.Name = 'APEX TEST PRODUCT #2';
        prd02.DI_Index__c = idx2.Id;  
        prd02.Product_Line_Global__c = 'HotSOS'; 
        prd02.Solution_Domain_Global__c = 'Service Optimization';
        insert prd02;    

		// CREATE TEST DI RECORD
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Product_Group__c = pgp.Id;
        insert di;
        
        Date dt = system.date.today();
        
        AH_Product_Migration__c pm = new AH_Product_Migration__c();
		pm.Account__c = a.Id;
        pm.Opportunity__c = o.Id;
        pm.From_Product__c = prd01.Id;
        pm.To_Product__c = prd02.Id;
		pm.Cut_Off_Date__c = dt.addDays(30);
		pm.Live_Date__c = dt.addDays(90);
		insert pm;

        Schema.DescribeSObjectResult schm = Schema.SObjectType.AH_Product_Migration_Line_Item__c; 
        Map<String, Schema.RecordTypeInfo> rtInfo = schm.getRecordTypeInfosByName(); 
        Id rtDIId = rtInfo.get('Deployment Instance').getRecordTypeId();  
        
        AH_Product_Migration_Line_Item__c pmli = new AH_Product_Migration_Line_Item__c();
        pmli.Product_Migration__c = pm.Id;
        pmli.Asset__c = di.Id;
        pmli.RecordTypeId = rtDIId;
        insert pmli;
        
        Solution sol = NI_TestClassData.createSolution(1); 
        insert sol;
 
        // CREATE A BILLING CONTACT RECORD FOR FOLLOWING ALI RECORD CREATION
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = a.Id;
		insert blgCnrct;

        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI.Account__c = a.Id;
        actLI.Product__c = prd01.Id; 
        actLI.Renewal_Date__c = system.date.today().addDays(-20);
        actLI.Auto_Renewal__c = true;
        insert actLI;        

        Schema.DescribeSObjectResult schm2 = Schema.SObjectType.AH_Product_Migration_Line_Item__c; 
        Map<String, Schema.RecordTypeInfo> rtInfo2 = schm2.getRecordTypeInfosByName(); 
        Id rtALIId = rtInfo2.get('Activity Line Item').getRecordTypeId();  
        
        AH_Product_Migration_Line_Item__c pmli2 = new AH_Product_Migration_Line_Item__c();
        pmli2.Product_Migration__c = pm.Id;
        pmli2.Activity_Line_Item__c = actLI.Id;
        pmli2.RecordTypeId = rtALIId;
        insert pmli2;
        
        Test.stopTest(); 
        
        system.debug(' ***  END  - AH_ProdMigration_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {  
        
        system.debug(' *** START - AH_ProdMigration_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PRODUCT MIGRATION #1'];
        Product2 p2 = [SELECT Id FROM Product2 WHERE Name = 'APEX TEST PRODUCT #2'];
		AH_Product_Migration__c pm = [SELECT Id, Create_Migration_Case__c FROM AH_Product_Migration__c WHERE Account__c =: a.Id]; 

        // CREATE CANCELATION CASE RULE
        Cancellation_Case_Rule__c ccr = new Cancellation_Case_Rule__c();
        
        ccr.Assignment_Queue__c = 'Q-Subscription Management';
        ccr.Cancellation_Status__c = 'Cancelled';
        ccr.Case_Description__c	= 'APEX TEST <<DI Name>>';
        ccr.Case_Subject__c = 'APEX TEST <<DI Name>>';
        ccr.Inactive__c = false;
        
        insert ccr;
        
        // CREATE CANCELLATION CASE RULE PRODUCT
        Cancellation_Case_Rule_Product__c ccrp = new Cancellation_Case_Rule_Product__c();
        ccrp.Cancellation_Case_Rule__c = ccr.Id;
        ccrp.Product__c = p2.Id;
        insert ccrp;        
        
        
        Test.startTest();

        // TEST CHECKING THE CASE CREATION CHECKBOX
        pm.Create_Migration_Case__c = true;
        pm.Cut_Off_Date__c = system.date.today();
        update pm;
        
        Test.stopTest(); 

        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, OwnerId FROM Case WHERE AccountId =: a.Id]);
        system.assertEquals(1, lstCaseAsserts.size());
        //system.assertEquals('APEX TEST Delphi.fdc Enterprise PMS - TEST DATA', lstCaseAsserts[0].Subject);
        //system.assertEquals('00G60000001DCUiEAO', (Id)lstCaseAsserts[0].OwnerId);
                
        system.debug(' ***  END  - AH_ProdMigration_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {  
        
        system.debug(' *** START - AH_ProdMigration_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PRODUCT MIGRATION #1'];
        Product2 p2 = [SELECT Id FROM Product2 WHERE Name = 'APEX TEST PRODUCT #1'];
		AH_Product_Migration__c pm = [SELECT Id, Create_Migration_Case__c FROM AH_Product_Migration__c WHERE Account__c =: a.Id]; 

        // CREATE CANCELATION CASE RULE
        Cancellation_Case_Rule__c ccr = new Cancellation_Case_Rule__c();
        
        ccr.Assignment_Queue__c = 'Q-Subscription Management';
        ccr.Cancellation_Status__c = 'Cancelled';
        ccr.Case_Description__c	= 'APEX TEST <<DI Name>>';
        ccr.Case_Subject__c = 'APEX TEST <<DI Name>>';
        ccr.Inactive__c = false;
        
        insert ccr;
        
        // CREATE CANCELLATION CASE RULE PRODUCT
        Cancellation_Case_Rule_Product__c ccrp = new Cancellation_Case_Rule_Product__c();
        ccrp.Cancellation_Case_Rule__c = ccr.Id;
        ccrp.Product__c = p2.Id;
        insert ccrp;        
        
        
        Test.StartTest();

        // TEST CHECKING THE CASE CREATION CHECKBOX
        pm.Create_Migration_Case__c = true;
        update pm;
        
        Test.stopTest(); 

        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, OwnerId FROM Case WHERE AccountId =: a.Id AND ContactId != null]);
        system.assertEquals(1, lstCaseAsserts.size());
        //system.assertEquals('APEX TEST Delphi.fdc Enterprise PMS - TEST DATA', lstCaseAsserts[0].Subject);
        //system.assertEquals('00G60000001DCUiEAO', (Id)lstCaseAsserts[0].OwnerId);
                
        system.debug(' ***  END  - AH_ProdMigration_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }


}