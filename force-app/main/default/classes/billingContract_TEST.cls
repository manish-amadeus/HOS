/**************************************************************************************
Name            : billingContract_TEST
Author          : CLD Partners
Created Date    : 01/15/2016
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     : MainTestClass for Billing Contract Functionality
                :
                :
				
 	IMPORTANT NOTE ABOUT THIS CLASS:
	THIS CLASS WAS CREATED BY CLD Partners BEFORE OUR "Amadeus Hospitality Salesforce Development Standards":
		https://amadeus-hospitality.quip.com/3ANaASOf32nb/Amadeus-Hospitality-Apex-Development-Standards-in-Salesforce
	DOCUMENT EXISTED. THIS "COVER-ALL" TEST CLASS SHOULD NOT BE USED. IF A TEST CLASS DOES NOT EXIST, A NEW "CLASS SPECIFIC" TEST CLASS SHOULD BE 
 	CREATED USING NI_TESTCLASSDATA AS THE TEST RECORD CREATOR. ANY CHANGE SETS USING THIS CLASS WILL BE REJECTED. THANK YOU.
				
***************************************************************************************/
@isTest (seealldata=true)
public class billingContract_TEST 
{
    
    public static Account testAccount1;
    public static Contact testContact1;
    public static Contact testContact2;
    public static Opportunity testOpp1;
    public static Product_Group__c testProductGroup_Delphi;
    public static Product_Group__c testProductGroup_Salesforce;
    public static Product2 testServiceProduct;
    public static Product2 testSupportProduct;
    public static Product2 testSubsciptionProduct;
    public static Product2 testSoftwareProduct;
    public static Asset testDeploymentInstance;
    public static Payment_Terms__c testPmtTerms_PercentBreakDown;
    public static Payment_Terms__c testPmtTerms_EqualSplit;
    public static Payment_Terms__c testPmtTerms_PSAbilled;
    public static Billing_Contract__c testBillingContract1;
    public static Apttus__APTS_Agreement__c testAgreement;
    public static PSA_Product_Package__c testProductPackage;
    public static pse__Region__c testRegion;
    public static pse__Practice__c testPractice;
    public static pse__Proj__c testProject;
    public static Map<String, Id> revTemplateMap;
    public static List<OpportunityLineItem> oliList;
    
    public static final String DEFAULT_PRACTICE_NAME = 'psaTestPractice';
    public static final String DEFAULT_REGION_NAME = 'psaTestRegion';
    public static final String DEFAULT_RESOURCE_NAME = 'PSA Test Resource';
    public static pse__Practice__c defaultPractice;
    public static pse__Region__c defaultRegion;
    public static Contact defaultResource;
    public static pse__Work_Calendar__c defaultWorkCalendar;
    
    public static final String PROJECT_STAGE_DRAFTATRISK = 'Draft at Risk';
    public static final String PROJECT_STAGE_DRAFT = 'Draft';
    public static final String PROJECT_STAGE_INPROGRESS = 'In Progress';
    public static final String PROJECT_STAGE_ONHOLD = 'On Hold';
    public static final String PROJECT_STAGE_CANCELED = 'Canceled';
    public static final String PROJECT_STAGE_CLOSING = 'Project Closing';
    public static final String PROJECT_STAGE_COMPLETED = 'Completed';
    
    public static final String PROJECT_TYPE_CUSTOMER = 'Customer Project';
    
    public static final String MILESTONE_STATUS_DRAFT = 'Draft/Tentative';
    public static final String MILESTONE_STATUS_OPEN = 'Open';
    public static final String MILESTONE_STATUS_SUBMITTED = 'Submitted';
    public static final String MILESTONE_STATUS_APPROVED = 'Approved';
    public static final String MILESTONE_STATUS_ESCALATE = 'Escalate to Sales';
    public static final String MILESTONE_STATUS_CANCELED = 'Canceled';
    
    public static final String MILESTONE_TYPE_BILLABLE = 'Billable Milestone';
    public static final String MILESTONE_TYPE_COMPLIMENTARY = 'Complimentary';
    public static final String MILESTONE_TYPE_GOODWILL = 'Goodwill';
    public static final String MILESTONE_TYPE_HOURLY = 'Hourly Milestone';
    public static final String MILESTONE_TYPE_INCLUSIVE = 'Inclusive Milestone';
    public static final String MILESTONE_TYPE_EXPENSEREPORT = 'Expense Report';
    
    public static void setupTestData1()
    {
        
        //Disable some triggers:
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        //triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        
        //====== Query Existing Setup Data
        revTemplateMap = new Map<String, Id>();
        for (ffrr__Template__c template : [Select name, id From ffrr__Template__c])
        {
            revTemplateMap.put(template.name, template.Id);
        }
        //====== 
        oliList = new List<OpportunityLineItem>();
        
        testAccount1 = ffaTestUtilities.createAccount('Test Account 1', null);
        testContact1 = ffaTestUtilities.createTestContact('TEST', 'test@test.com');
        testContact2 = ffaTestUtilities.createTestContact('TEST2', 'test@test2.com');
        ffaTestUtilities.createAccountTeam(UserInfo.getUserId(), testAccount1.id, 'NI Collector');
        
        testProductGroup_Salesforce = NI_TestClassData.createProductGroup(1, 'Salesforce');
        insert testProductGroup_Salesforce;
        
        List<Product2> productList = new List<Product2>();
        testServiceProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK1', 'Services', 'Services',12);
        testServiceProduct.pse__IsServicesProduct__c = true;
        update testServiceProduct;
        testSupportProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK3', 'Support', 'Maintenance', 12);
        testSubsciptionProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK4', 'Subscription', 'Software - Subscription', 12);
        testSoftwareProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.id, 'TEST-TST-BK5', 'Software', 'Software - Perpetual', null);
        productList.add(testServiceProduct);
        productList.add(testSupportProduct);
        productList.add(testSubsciptionProduct);
        productList.add(testSoftwareProduct);
        
        testSubsciptionProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
        testServiceProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Deliverable') ? revTemplateMap.get('Activity - Deliverable') : null;
        
        testProductPackage = ffaTestUtilities.createProductPackage('TEST-TST-BK1', 2, testServiceProduct.Id);
        testServiceProduct.Product_Package__c = testProductPackage.Id;
        update testServiceProduct;
        
        testDeploymentInstance = ffaTestUtilities.createTestasset(1, testAccount1.id, testSubsciptionProduct.id, testProductGroup_Salesforce.Id);
        
        testPmtTerms_PercentBreakDown = ffaTestUtilities.createTestPmtTerms(2, 'test1', 'Effective Date', 'Percent Breakdown', 1, 'Months', false);
        testPmtTerms_EqualSplit = ffaTestUtilities.createTestPmtTerms(2, 'test2', 'Activation Date', 'Equal', 1, 'Years', false);
        testPmtTerms_PSAbilled = ffaTestUtilities.createTestPmtTerms(2, 'test3', 'Activation Date', 'Equal', 1, 'Years', true);
        
        Pricebook2 testPricebook = ffatestUtilities.createTestPricebook('testpricebook');
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry servicePBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId,testServiceProduct.id,1000);
        PricebookEntry supportPBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId,testSupportProduct.id,1000);
        PricebookEntry ssubscriptionPBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId,testSubsciptionProduct.id,1000);
        PricebookEntry softwarePBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId,testSoftwareProduct.id,1000);
        
        
        testOpp1 = ffaTestUtilities.initTestOpportunity(1, testAccount1.id, testPmtTerms_PercentBreakDown.id,testPmtTerms_PercentBreakDown.id,testPmtTerms_PercentBreakDown.id,testPmtTerms_PercentBreakDown.id,testPmtTerms_PercentBreakDown.Id);
        insert testOpp1;
        
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.id, servicePBE.id, 2));
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.id, supportPBE.id, 2));
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.id, ssubscriptionPBE.id, 2));
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.id, softwarePBE.id, 2));
        insert oliList;
        
        testAgreement = ffaTestUtilities.createTestAgreement(testOpp1,productList);
        
    }
    
    public static void createPSAStructure()
    {
        testRegion = ffaTestUtilities.createTestRegion(1, 'testRegion');
        testPractice = ffaTestUtilities.createTestPractice(1, 'testPractice');
        testProject = ffaTestUtilities.createTestProject(1, 'test project', testRegion, testPractice, 'In Progress', testOpp1, testContact1.Id);
    }
    
    public static void closeOpp(Opportunity opp, Contact roleContact)
    {
        ffaTestUtilities.createTestOpportunityContactRoles(opp.id, roleContact.Id);
        opp.CloseDate = date.today();
        opp.StageName = 'Closed Won';
        opp.Probability = 100;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
        update opp;
    }
    
    @isTest static void testCreateBillingContractController_notValid()
    {
        setupTestData1();
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false)
        {
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        Test.stopTest();
    }
    
    @isTest static void testAgreementTrigger()
    {
        setupTestData1();
        Test.startTest();
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        closeOpp(testopp1, testContact1);
        testAgreement.APTS_Licensed_Program__c = 'NonStandard';
        testAgreement.APTS_Services__c = 'NonStandard';
        testAgreement.APTS_Hosting_and_Support__c = 'NonStandard';
        testAgreement.APTS_Subscription__c = 'NonStandard';
        testAgreement.APTS_Support__c = 'NonStandard';
        testAgreement.APTS_HRM_Apps_Subscription_Term__c = 'NonStandard';
        testAgreement.HRM_Apps_Services_Terms__c = 'NonStandard';
        update testAgreement;
        testAgreement.APTS_Licensed_Program__c = 'Standard';
        testAgreement.APTS_Services__c = 'Standard';
        testAgreement.APTS_Hosting_and_Support__c = 'Standard';
        testAgreement.APTS_Subscription__c = 'Standard';
        testAgreement.APTS_Support__c = 'Standard';
        testAgreement.APTS_HRM_Apps_Subscription_Term__c = 'Standard';
        testAgreement.HRM_Apps_Services_Terms__c = 'Standard';
        update testAgreement;
        Test.stopTest();
    }
    
    @isTest static void testCreateBillingContractController()
    {
        
        setupTestData1();
        
        Test.startTest();
        
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        
        testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        PageReference testPgRef = cntrlr.backToOpp();
        
        testBillingContract1.Attn_to_Contact__c = testContact2.Id;
        update testBillingContract1;
        
        Set<Id> accountidset = new Set<Id>();
        accountidset.add(testAccount1.Id);
        Set<Id> productidset = new Set<Id>();
        productidset.add(testSupportProduct.Id);
        Map<String, Asset> dimap = billingContractHandler.fetchDeploymentInstance(accountidset, productidset);
        Id tmpId = billingContractHandler.applyDeploymentInstance(dimap, oliList[0]);
        
        delete testBillingContract1;
        
        Test.stopTest();
        
    }
    
    @isTest static void testActivityLineTriggerHandler()
    {
        
        ffaTestUtilities.disableNonFFaTriggers();
        setupTestData1();
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        closeOpp(testopp1, testContact1);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        
        testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        PageReference testPgRef = cntrlr.backToOpp();
        
        NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
        ffaTriggers.Bypass_billingContract__c = true;
        update ffaTriggers;
        
        testBillingContract1.Attn_to_Contact__c = testContact2.Id;
        update testBillingContract1;
        
        
        List<Activity_Line_Item__c> alis = new List<Activity_Line_Item__c>();

        for (Activity_Line_Item__c ali : [SELECT id, Activation_Date__c,ACTION_Rebuild_Billing_Lines__c, Contract_Start_Date__c, Contract_End_Date__c 
                                          FROM Activity_Line_Item__c 
                                          WHERE Billing_Contract__c =: testBillingContract1.Id])
        {
            ali.Activation_Date__c = Date.today();
            //ali.Contract_Start_Date__c = Date.today().addMonths(-1);
            //ali.Contract_End_Date__c = Date.today().addMonths(1);
            ali.Contract_Start_Date__c = Date.today().addMonths(1);
            ali.Contract_End_Date__c = Date.today().addMonths(2);
            ali.ACTION_Rebuild_Billing_Lines__c = true;
            ali.ffrrtemplate__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
            alis.add(ali);
        }
        
        update alis;
        
        Test.stopTest();
        
    }
    
    @isTest static void testpsaManageBCLController()
    {
        setupTestData1();
        Test.startTest();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        psaManageBCLController bclController = new psaManageBCLController(stdController);
        for(psaManageBCLController.billingLineModel line : bclController.openlineItems){
            line.check = true;
        }
        bclController.cloneLines();
        bclController.addRow();
        PageReference pg1 = bclController.saveLines();
        bclController.deleteSelected();
        PageReference pg2 = bclController.backToBC();
        Test.stopTest();
    }
    
    @isTest static void testbillingContractRenewal()
    {
        ffaTestUtilities.disableNonFFaTriggers();
        NI_TriggerBypassSwitches__c existingSwitches = NI_TriggerBypassSwitches__c.getOrgDefaults();
        existingSwitches.Bypass_activityLineItemTrigger__c = true;
        update existingSwitches;
        setupTestData1();
        
        closeOpp(testopp1, testContact1);
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        
        NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
        ffaTriggers.Bypass_activityLineItemTrigger__c = true;
        update ffaTriggers;
        
        List<SelectOption> optionList = cntrlr.getBC_Options();
        
        List<Activity_Line_Item__c> alis = new List<Activity_Line_Item__c>();
        //Update a bc line to invoiced = true
        for(Activity_Line_Item__c ali : [Select id, Activation_Date__c,ACTION_Rebuild_Billing_Lines__c, Contract_Start_Date__c, Contract_End_Date__c from Activity_Line_Item__c where Billing_Contract__c = :testBillingContract1.Id]){
            ali.Activation_Date__c = Date.today();
            ali.Renewal_Date__c = Date.today();
            ali.Contract_Start_Date__c = Date.today().addMonths(-1);
            ali.Contract_End_Date__c = Date.today().addMonths(1);
            ali.Product__c = testSubsciptionProduct.Id;
            ali.Auto_Renewal__c = true;
            ali.ffrrtemplate__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
            alis.add(ali);
        }
        update alis;
        
        //test Controller:
        manageBillingContractRenewalController renewalController = new manageBillingContractRenewalController();
        renewalController.dummyLine.Contract_Start_Date__c = Date.today().addYears(-1);
        renewalController.dummyLine.Contract_End_Date__c = Date.today().addYears(1);
        renewalController.dummyBC.Account__c = testAccount1.Id;
        renewalController.fetchData();
        renewalController.reloadPriceIncrease();
        renewalController.processRenewal();
        for(manageBillingContractRenewalController.aliWrapper a : renewalController.wrapperList){
            a.check = true;
        }
        renewalController.reloadPriceIncrease();
        renewalController.processRenewal();
        Test.stopTest();
        
    }
    
    @isTest static void testbillingContractCreditController()
    {
        setupTestData1();
        
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        
        Test.startTest();
        
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        
        List<Billing_Contract_Line_Item__c> invoicedUpdate = new List<Billing_Contract_Line_Item__c>();
        //Update a bc line to invoiced = true
        for(Billing_Contract_Line_Item__c bli : [Select id, invoiced__c from Billing_Contract_Line_Item__c where Billing_Contract__c = :testBillingContract1.Id])
        {
            bli.invoiced__c = true;
            invoicedUpdate.add(bli);
        }
        update invoicedUpdate;
        
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        billingContractCreditController creditController = new billingContractCreditController(stdController);
        
        for (billingContractCreditController.bliWrapper line : creditController.wrapperList)
        {
            line.check = true;
            line.dummy_bliObject.Unit_Price__c = line.dummy_bliObject.Unit_Price__c*-1;
        }
        
        creditController.processCredit();      
        for(billingContractCreditController.bliWrapper line : creditController.wrapperList)
        {
            line.check = true;
            line.dummy_bliObject.Unit_Price__c = line.dummy_bliObject.Unit_Price__c*-1;
        }
        creditController.processCredit();
        PageReference pg2 = creditController.backToBC();
        Test.stopTest();
    }
    
    @isTest static void testbillingContractVSOEController()
    {
        
        setupTestData1();
        
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        
        Test.startTest();
        
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        billingContractVSOEController vsoeController = new billingContractVSOEController(stdController);
        PageReference pg2 = vsoeController.saveLines();
        PageReference pg3 = vsoeController.refresh();
        PageReference pg4 = vsoeController.finalizeVSOE();
        Test.stopTest();
    }
    
    @isTest static void testbillingContractVSOEController2()
    {
        setupTestData1();
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        Test.startTest();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false){
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        billingContractVSOEController vsoeController = new billingContractVSOEController(stdController);
        //PageReference pg2 = vsoeController.saveLines();
        PageReference pg1 = vsoeController.createPCSLine();
        //PageReference pg3 = vsoeController.finalizeVSOE();
        PageReference pg4 = vsoeController.backToBC();
        Test.stopTest();
    }
    
    @isTest static void testcreateMSfromActivityLinesController()
    {
        setupTestData1();
        ffaTestUtilities.disableNonFFaTriggers();
        
        createPSAStructure();
        closeOpp(testopp1, testContact1);
        Test.startTest();
        NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
        ffaTriggers.Bypass_activityLineItemTrigger__c = true;
        ffaTriggers.Bypass_billingContract__c = true;
        update ffaTriggers;
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false){
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        createMSfromActivityLinesController msController = new createMSfromActivityLinesController(stdController);
        List<selectOption> optionlist = msController.getProj_Options();
        msController.projectID = testProject.Id;
        PageReference pg3 = msController.openCreateProjPage();
        PageReference pg4 = msController.backToBC();
        for(createMSfromActivityLinesController.activityLineModel a : msController.activitylineItems)
        {
            a.check = true;
        }
        
        
        msController.createPSAMilestone();
        Test.stopTest();
    }
    
    @isTest static void testbillingContractMaintenanceSchedule()
    {
        setupTestData1();
        Test.startTest();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        
        testBillingContract1 = cntrlr.bc;
        List<Billing_Contract_Line_Item__c> invoicedUpdate = new List<Billing_Contract_Line_Item__c>();
        for(Billing_Contract_Line_Item__c bli : [Select id, invoiced__c, Invoice_Date__c from Billing_Contract_Line_Item__c where Billing_Contract__c = :testBillingContract1.Id]){
            bli.invoiced__c = false;
            bli.Invoice_Date__c = Date.today().addMonths(-1);
            invoicedUpdate.add(bli);
        }
        update invoicedUpdate;
        //test Controller:
        String CRON_EXP = '0 0 * * * ?'; 
        billingContractMaintenanceSchedule sch = new billingContractMaintenanceSchedule(); 
        system.schedule('test job', CRON_EXP, sch);
        Test.stopTest();
    }
    
    @isTest static void testbillingContractSplitLinesController()
    {
        setupTestData1();
        NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        triggerSwitch.BypassAccount_ON__c = true;
        triggerSwitch.BypassOpportunity_ON__c = true;
        triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        update triggerSwitch;
        Test.startTest();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        billingContractSplitLinesController aliController = new billingContractSplitLinesController(stdController);
        
        for(billingContractSplitLinesController.activityLineModel line : aliController.activitylineItems){
            line.splitQuantity = 1;
            line.check = true;
        }
        PageReference pg1 = aliController.splitLines();
        PageReference pg2 = aliController.backToBC();
        
        Test.stopTest();
    }
    
    @isTest static void testmanageActivityLinesController()
    {
        setupTestData1();
        Test.startTest();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        
        NI_TriggerBypassSwitches__c ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults();
        ffaTriggers.Bypass_activityLineItemTrigger__c = true;
        update ffaTriggers;
        
        List<SelectOption> optionList = cntrlr.getBC_Options();
        
        List<Activity_Line_Item__c> alis = new List<Activity_Line_Item__c>();
        //Update a bc line to invoiced = true
        for(Activity_Line_Item__c ali : [Select id, Activation_Date__c,ACTION_Rebuild_Billing_Lines__c, Contract_Start_Date__c, Contract_End_Date__c from Activity_Line_Item__c where Billing_Contract__c = :testBillingContract1.Id])
        {
            ali.Activation_Date__c = Date.today();
            //ali.Contract_Start_Date__c = Date.today().addMonths(-1);
            //ali.Contract_End_Date__c = Date.today().addMonths(1);
            ali.Contract_Start_Date__c = Date.today().addMonths(1);
            ali.Contract_End_Date__c = Date.today().addMonths(2);
            ali.Product__c = testSupportProduct.Id;
            ali.Pro_Rated__c = false;
            ali.Revenue_Category__c = 'Support';
            ali.Auto_Renewal__c = true;
            ali.ffrrtemplate__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
            alis.add(ali);
        }
        update alis;
        
        //test Controller:
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        manageActivityLinesController aliController = new manageActivityLinesController(stdController);
        aliController.loadLineItems();
        
        for(manageActivityLinesController.activityLineModel line : aliController.activitylineItems){
            line.check = true;
        }
        PageReference pg3 = aliController.proRateLines();
        aliController.addRow();
        PageReference pg1 = aliController.saveLines();
        
        for(manageActivityLinesController.activityLineModel line : aliController.activitylineItems){
            line.ali_object.Pro_Rated__c = true;
        }
        pg3 = aliController.proRateLines();
        for(manageActivityLinesController.activityLineModel line : aliController.activitylineItems){
            line.ali_object.Contract_End_Date__c = null;
        }
        pg3 = aliController.proRateLines();
        
        aliController.deleteSelected();
        PageReference pg2 = aliController.backToBC();
        
        Test.stopTest();
    }

    @isTest static void testResetOpportunitLines()
    {
        setupTestData1();
        Test.startTest();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        
        //test Controller:
        billingContractHandler.resetOppLinesWS(testOpp1.Id);
        Test.stopTest();
    }
    
    // =====================================================================
    // TEST DATA CREATION METHODS
    // =====================================================================
    
    // Creates a Region with the name provided
    private static pse__Region__c createTestRegion(String regionName)
    {
        //pse__Region__c testRegion2 = new pse__Region__c(Name = regionName);
        pse__Region__c testRegion2 = NI_TestClassData.createTestRegion(1, regionName);
        testRegion2.Name = regionName;
        insert testRegion2;
        return testRegion2;
    }
    
    // Creates a Practice with the name provided
    private static pse__Practice__c createTestPractice(String practiceName)
    {
        //pse__Practice__c testPractice2 = new pse__Practice__c(Name=practiceName);
        pse__Practice__c testPractice2 = NI_TestClassData.createTestPractice(1, practiceName);
        testPractice2.Name = practiceName;
        insert testPractice2;
        return testPractice2;
    }

    private static pse__Proj__c createTestProject(String projectName, pse__Region__c region, pse__Practice__c practice, String projectStage, Opportunity opp)
    {
        
        initDefaultRP();

        pse__Proj__c testProject2 = NI_TestClassData.createTestProject(1, projectName, region, practice, projectStage, opp);
        testProject2.Name = projectName;
        testProject2.pse__Is_Active__c = true;
        testProject2.pse__Is_Billable__c = true;
        testProject2.pse__Allow_Timecards_Without_Assignment__c = true;
        testProject2.pse__Allow_Expenses_Without_Assignment__c = true;        
        testProject2.pse__Region__c = region.Id;
        testProject2.pse__Practice__c = practice.Id;
        testProject2.pse__Stage__c = projectStage;
        testProject2.pse__Project_Type__c = PROJECT_TYPE_CUSTOMER;
        testProject2.pse__Project_Status__c = 'Green';  			// ADDED PER NICC-008249
        
        if (opp != null)
        {
            testProject2.pse__Opportunity__c = opp.Id;
        }
        
        insert testProject2;
        return testProject2;
        
    }
    
    // Creates a test opportunity
    private static Opportunity createTestOpportunity(String opptyName, String stage, String orderStatus)
    {
        initDefaultRP();
        //Opportunity testOpportunity = new Opportunity(Name=opptyName, StageName=stage, Order_Status__c=orderStatus,Amount=25000);
        Opportunity testOpportunity = NI_TestClassData.createTestOpportunity(1, null); 
        testOpportunity.Name = opptyName; 
        testOpportunity.StageName = stage;
        testOpportunity.Order_Status__c = orderStatus;
        testOpportunity.Amount = 25000;
        testOpportunity.CloseDate = date.newInstance(2011, 7, 11);
        insert testOpportunity;
        return testOpportunity;
    }
    
    // Creates a test account
    private static Account createTestAccount(String accountName, String accountNumber)
    {
        //Account testAccount = new Account(Name=accountName, AccountNumber=accountNumber, CurrencyIsoCode='USD', BillingCountry='US',BillingState='VA', BillingStreet='1 Main', BillingCity='Springfield',Type='Customer', BillingPostalCode='22102');
        Account testAccount = NI_TestClassData.createTestAccount(1);
        testAccount.Name = accountName;
        testAccount.AccountNumber = accountNumber;
        testAccount.CurrencyIsoCode = 'USD';
        testAccount.BillingCountry = 'US';
        testAccount.BillingState = 'VA';
        testAccount.BillingStreet = '1 Main';
        testAccount.BillingCity = 'Springfield';
        testAccount.Type = 'Customer';
        testAccount.BillingPostalCode = '22102';
        insert testAccount;
        return testAccount;
    }
    
    // Creates a test Milestone
    private static pse__Milestone__c createTestMilestone(String milestoneName, pse__Proj__c project, boolean cfte, boolean cfee, String milestoneType)
    {
        pse__Milestone__c testMilestone = NI_TestClassData.createTestMilestone(milestoneName, project, cfte, cfee, milestoneType);
        testMilestone.pse__Project__c = project.Id;
        testMilestone.pse__Closed_for_Expense_Entry__c = cfee;
        testMilestone.pse__Closed_for_Time_Entry__c = cfte;
        testMilestone.pse__Target_Date__c = date.newInstance(2011, 12, 31);
        testMilestone.pse__Status__c = MILESTONE_STATUS_DRAFT;
        testMilestone.Milestone_Type__c = milestoneType;
        insert testMilestone;
        return testMilestone;
    }
    
    // Creates a test Resource
    private static Contact createTestResource(User salesforceUser, pse__Region__c region, pse__Practice__c practice)
    {
        
        initDefaultWorkCalendar();

        Contact testResource = NI_TestClassData.createTestContact(1, null);
        testResource.LastName = DEFAULT_RESOURCE_NAME;
        testResource.pse__Resource_Role__c = 'Systems Engineering';
        testResource.pse__Is_Resource__c = true;
        testResource.pse__Is_Resource_Active__c = true;
        testResource.MailingStreet = '222 Oak St';
        testResource.MailingCity = 'Arlington';
        testResource.MailingState = 'VA';
        testResource.MailingCountry = 'US';
        testResource.MailingPostalCode = '22102';

        testResource.pse__Region__c = region.Id;
        testResource.pse__Practice__c = practice.Id;
        testResource.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        
        if (salesforceUser != null)
        {
            testResource.pse__Salesforce_User__c = salesforceUser.Id;
        }
        
        insert testResource;
        return testResource;
    }
    
    // Creates a test Assignment
    public static pse__Assignment__c createTestAssignment(pse__Proj__c proj, Contact resource)
    {
        
        // Create an initial assignment schedule, 30 days out
        Date dtStart = system.Today() + 30;
        Date dtEnd = system.Today() + 34;
        pse__Schedule__c schedule = NI_TestClassData.createTestSchedule(dtStart, dtEnd);
        schedule.pse__Monday_Hours__c = 8;
        schedule.pse__Tuesday_Hours__c = 8;
        schedule.pse__Wednesday_Hours__c = 8;
        schedule.pse__Thursday_Hours__c = 8;
        schedule.pse__Friday_Hours__c = 8;
        insert schedule;
        
        // Create a permission control that will allow us to staff the resource
        insert new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Resource__c = resource.Id, pse__Staffing__c = true);
        insert new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Region__c = defaultRegion.Id, pse__Staffing__c = true);
        
        // Create the assignment and associate it with the project
        pse__Assignment__c assignment = NI_TestClassData.createTestAssignment(resource.Id, schedule.Id, proj.Id);
        assignment.pse__Is_Billable__c = true;
        assignment.pse__Bill_Rate__c = 85;
        
        insert assignment;        
        return assignment;
        
    }
    
    // Initializes an instance-level work calendar that can be reused
    private static void initDefaultWorkCalendar()
    {
        if (defaultWorkCalendar == null)
        {
            defaultWorkCalendar = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
            insert defaultWorkCalendar;
        }
    }
    
    // Initializes instance-level Region and Pratice
    private static void initDefaultRP()
    {
        if (defaultRegion == null)
        {
            defaultRegion = createTestRegion(DEFAULT_REGION_NAME);
        }
        if (defaultPractice == null)
        {
            defaultPractice = createTestPractice(DEFAULT_PRACTICE_NAME);
        }
    }
    
    // Initializes an instance-level Resource that can be reused
    private static Contact initDefaultResource()
    {
        
        initDefaultRP();
        initDefaultWorkCalendar();
        
        List<Contact> cList = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c =: UserInfo.getUserId()];
        for (Contact c : cList)
        {
            c.pse__Salesforce_User__c = null;
        }
        
        if (!cList.isEmpty())
        {
            update cList;
        }

        Contact defaultResource = NI_TestClassData.createTestContact(1, null);

        defaultResource.LastName = DEFAULT_RESOURCE_NAME;
        defaultResource.pse__Resource_Role__c = 'Systems Engineering';
        defaultResource.pse__Is_Resource__c = true;
        defaultResource.pse__Is_Resource_Active__c = true;
        defaultResource.MailingStreet = '222 Oak St';
        defaultResource.MailingCity = 'Arlington';
        defaultResource.MailingState = 'VA';
        defaultResource.MailingCountry = 'US';
        defaultResource.MailingPostalCode = '22102';            
        defaultResource.pse__Salesforce_User__c = UserInfo.getUserId();
        defaultResource.pse__Region__c = defaultRegion.Id;
        defaultResource.pse__Practice__c = defaultPractice.Id;
        defaultResource.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        
        insert defaultResource;
        return defaultResource;
        
    }
    
}