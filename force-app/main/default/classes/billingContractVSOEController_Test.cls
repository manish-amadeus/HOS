/****************************************************************************************
Name            : billingContractVSOEController_Test 
Author          : Shashikant Nikam
Created Date    : 05/22/2019
Last Mod Date   : 05/22/2019
Last Mod By     : Shashikant Nikam 
NICC Reference  : 
Description     : Test class for billingContractVSOEController class
                :
				:
******************************************************************************************/
@isTest 
public class billingContractVSOEController_Test 
{
    
    @testSetup
    static void createTestData()
    {
        
        Test.startTest();
        
        //Disable some triggers:
        NI_TriggerBypassSwitches__c custOne = new NI_TriggerBypassSwitches__c ();
        custOne.Name = 'Bypass Control Panel';
        custOne.BypassAccount_ON__c = true;
        upsert custOne;
        
        // Query Existing Setup Data
        Map<String, Id> revTemplateMap = new Map<String, Id>();
        for (ffrr__Template__c template : [Select name, id From ffrr__Template__c])
        {
            revTemplateMap.put(template.name, template.id);
        }
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        
        // TEST ACCOUNT
        Account testAccount1 = NI_TestClassData.createTestAccount(1);
        insert testAccount1;
        
        // TEST CONTACT
        List<Contact> cntList = new List<Contact>();
        Contact testContact1 = NI_TestClassData.createTestContact(1, testAccount1.id);
        Contact testContact2 = NI_TestClassData.createTestContact(2, testAccount1.id);
        cntList.add(testContact1);
        cntList.add(testContact2);
        insert cntList;
        
        // TEST ACCOUNT TEAM
        ffaTestUtilities.createAccountTeam(UserInfo.getUserId(), testAccount1.id, 'NI Collector');
        
        // TEST PRODUCT GROUP
        Product_Group__c testProductGroup_Salesforce = NI_TestClassData.createProductGroup(1, 'Salesforce');
        insert testProductGroup_Salesforce;
        
        List<Product2> productList = new List<Product2>();
        
        Product2 testServiceProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK1', 'Services', 'Services',12);
        testServiceProduct.pse__IsServicesProduct__c = true;
        update testServiceProduct;
        productList.add(testServiceProduct);
        
        Product2 testSupportProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK3', 'Support', 'Maintenance', 12);
        productList.add(testSupportProduct);
        
        Product2 testSubsciptionProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK4', 'Subscription', 'Software - Subscription', 12);
        productList.add(testSubsciptionProduct);
        
        Product2 testSoftwareProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK5', 'Software', 'Software - Perpetual', null);
        productList.add(testSoftwareProduct);
                
        testSubsciptionProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
        testServiceProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Deliverable') ? revTemplateMap.get('Activity - Deliverable') : null;
        
        PSA_Product_Package__c testProductPackage = ffaTestUtilities.createProductPackage('TEST-TST-BK1', 2, testServiceProduct.id);
        testServiceProduct.Product_Package__c = testProductPackage.id;
        update testServiceProduct;
        
        // TEST DEPLOYMENT INSTANCE
        Asset testDeploymentInstance = NI_TestClassData.createTestasset(1, testAccount1.id, testSubsciptionProduct.id);
        
        Payment_Terms__c testPmtTerms_PercentBreakDown = ffaTestUtilities.createTestPmtTerms(2, 'test1', 'Effective Date', 'Percent Breakdown', 1, 'Months', false);
        Payment_Terms__c testPmtTerms_EqualSplit = ffaTestUtilities.createTestPmtTerms(2, 'test2', 'Activation Date', 'Equal', 1, 'Years', false);
        Payment_Terms__c testPmtTerms_PSAbilled = ffaTestUtilities.createTestPmtTerms(2, 'test3', 'Activation Date', 'Equal', 1, 'Years', true);
        
        // TEST PRICE BOOK
        Pricebook2 testPricebook = NI_TestClassData.createTestPricebook('testpricebook');
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // TEST PRICE BOOK ENTRY
        List<PricebookEntry> PBEList = new List<PricebookEntry>();
        PricebookEntry servicePBE = NI_TestClassData.createTestPricebookEntry(stdPricebookId,testServiceProduct.id,1000);
        PricebookEntry supportPBE = NI_TestClassData.createTestPricebookEntry(stdPricebookId,testSupportProduct.id,1000);
        PricebookEntry ssubscriptionPBE = NI_TestClassData.createTestPricebookEntry(stdPricebookId,testSubsciptionProduct.id,1000);
        PricebookEntry softwarePBE = NI_TestClassData.createTestPricebookEntry(stdPricebookId,testSoftwareProduct.id,1000);
        PBEList.add(servicePBE);
        PBEList.add(supportPBE);
        PBEList.add(ssubscriptionPBE);
        PBEList.add(softwarePBE);
        
        insert PBEList;
        
        // TEST OPPORTUNITY
        Opportunity testOpp1 = new Opportunity();
        testOpp1.AccountId = testAccount1.id;
        testOpp1.Name = 'Apex Test Opportunity Name';
        testOpp1.StageName = 'Prospecting';
        testOpp1.Order_Status__c = 'Prospect';
        testOpp1.Amount = 25000;
        testOpp1.CloseDate = Date.Today().addDays(-1);
        testOpp1.Effective_Date__c = Date.Today().addDays(-1);
        testOpp1.Opportunity_Source__c = 'Support';
        testOpp1.Amadeus_Legal_Entity__c = 'Amadeus Hospitality Americas, Inc.';
        testOpp1.License_Program_Payment_Terms__c = testPmtTerms_PercentBreakDown.id;
        testOpp1.Hosting_and_Support_Payment_Terms__c = testPmtTerms_PercentBreakDown.id;
        testOpp1.Services_Payment_Terms__c = testPmtTerms_PercentBreakDown.id;
        testOpp1.Subscription_Payment_Terms__c = testPmtTerms_PercentBreakDown.id;
        testOpp1.Support_Payment_Terms__c = testPmtTerms_PercentBreakDown.id;
        insert testOpp1;
        
        // TEST OPPORTUNITY LINE ITEMS
        oliList.add(NI_TestClassData.createTestOpportunityLineItem(1, testOpp1.id, servicePBE.id, 2));
        oliList.add(NI_TestClassData.createTestOpportunityLineItem(1, testOpp1.id, supportPBE.id, 2));
        oliList.add(NI_TestClassData.createTestOpportunityLineItem(1, testOpp1.id, ssubscriptionPBE.id, 2));
        oliList.add(NI_TestClassData.createTestOpportunityLineItem(1, testOpp1.id, softwarePBE.id, 2));       
        insert oliList;
        
        Test.stopTest();
        
        // TEST AGREEMENT
        Apttus__APTS_Agreement__c testAgreement = ffaTestUtilities.createTestAgreement(testOpp1,productList);
        
        pse__Region__c testRegion = NI_TestClassData.createTestRegion(1, 'testRegion');
        insert testRegion;
        
        pse__Practice__c testPractice = NI_TestClassData.createTestPractice(1, 'testPractice');
        insert testPractice;
        
        pse__Proj__c testProject = NI_TestClassData.createTestProject(1, 'test project', testRegion, testPractice, 'In Progress', testOpp1);
        testProject.pse__Project_Manager__c = testContact1.id;
        insert testProject;
        
        pse__Proj__c testProject11 = [SELECT id, Name FROM pse__Proj__c];
        
        
        /*
        pse__Milestone__c testMilestone = NI_TestClassData.createTestMilestone('Billed milestone test', testProject, true, true, 'Billable Milestone');
        testMilestone.pse__Project__c = testProject.Id;
        testMilestone.pse__Closed_for_Expense_Entry__c = true;
        testMilestone.pse__Closed_for_Time_Entry__c = true;
        testMilestone.pse__Target_Date__c = date.newInstance(2011, 12, 31);
        testMilestone.pse__Status__c = 'Draft/Tentative';
        testMilestone.Milestone_Type__c = 'Billable Milestone';
        insert testMilestone;
        */
    } 
    
    
    // =============================================================================================================================== 
    // ====================================================== TEST METHODS =========================================================== 
    // =============================================================================================================================== 
    
    @isTest static void testbillingContractVSOEController()
    {
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        
        Test.startTest();
        
        List<Opportunity> oppList = new List<Opportunity>([select id, CloseDate, StageName, Probability, RecordTypeId FROM Opportunity]);
        List<Contact> cntList = new List<Contact>([select id FROM Contact WHERE LastName = 'Smith1']);
        
        ffaTestUtilities.createTestOpportunityContactRoles(oppList[0].id, cntList[0].id);
        oppList[0].CloseDate = date.today();
        oppList[0].StageName = 'Closed Won';
        oppList[0].Probability = 100;
        oppList[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
        update oppList[0];
        
        Opportunity testOpp1 = [select id, CloseDate, StageName, Probability, RecordTypeId FROM Opportunity WHERE Name = 'Apex Test Opportunity Name'];
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if(cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.id;
            cntrlr.processLines();
        }
        Billing_Contract__c testBillingContract1 = cntrlr.bc;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        billingContractVSOEController vsoeController = new billingContractVSOEController(stdController);
        PageReference pg2 = vsoeController.saveLines();
        PageReference pg3 = vsoeController.refresh();
        PageReference pg4 = vsoeController.finalizeVSOE();

        Test.stopTest();
    }
    
    
    @isTest static void testbillingContractVSOEController2()
    {
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        
        Test.startTest();
        
        List<Opportunity> oppList = new List<Opportunity>([select id, CloseDate, StageName, Probability, RecordTypeId FROM Opportunity]);
        List<Contact> cntList = new List<Contact>([select id FROM Contact WHERE LastName = 'Smith1']);
        
        ffaTestUtilities.createTestOpportunityContactRoles(oppList[0].id, cntList[0].id);
        oppList[0].CloseDate = date.today();
        oppList[0].StageName = 'Closed Won';
        oppList[0].Probability = 100;
        oppList[0].RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
        update oppList[0];
        
        Opportunity testOpp1 = [select id, CloseDate, StageName, Probability, RecordTypeId FROM Opportunity WHERE Name = 'Apex Test Opportunity Name'];
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if(cntrlr.loadError == false){
            cntrlr.billingContractId = cntrlr.bc.id;
            cntrlr.processLines();
        }
        Billing_Contract__c testBillingContract1 = cntrlr.bc;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        billingContractVSOEController vsoeController = new billingContractVSOEController(stdController);
		
        PageReference pg1 = vsoeController.createPCSLine();
        
        PageReference pg4 = vsoeController.backToBC();
        
        Test.stopTest();
    }
}