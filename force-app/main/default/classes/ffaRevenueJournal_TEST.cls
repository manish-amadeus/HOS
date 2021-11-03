/****************************************************************************************
Name            : ffaRevenueJournal_TEST
Author          : CLD Partners
Created Date    : 07/11/2016
Last Mod Date   : 04/23/2019
Last Mod By     : Sean Harris 
NICC Reference  : 
Description     : Tests for Rev Journal Creation
                : UPGRADED - NICC-034313 - Rewrote to use modern test data creation methods
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class ffaRevenueJournal_TEST 
{

   
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        system.debug(' *** START ffaRevenueJournal_TEST.createTestData()');     
        
        Test.startTest();    

        // CREATE TEST REV REC SETTINGS
        ffrr__Settings__c ffrrS = NI_TestClassData.createSettings();
        insert ffrrS;
        
        // CREATE TEST REV REC TEMPLATES
        List<ffrr__Template__c> lstTemplates = new List<ffrr__Template__c>();
        
        ffrr__Template__c t1 = NI_TestClassData.createffrrTemplate(ffrrS.Id);
        t1.Name = 'Activity - Percent Complete';
        t1.ffrr__CalculationType__c = 'Not Applicable';
        t1.ffrr__RevenueBasis__c = 'Total Revenue';
        t1.ffrr__RevenueSource__c = 'Activity_Line_Item__c';
        t1.ffrr__Settings__c = ffrrS.Id;
        t1.ffrr__RevRecType__c = '% Complete';
//        lstTemplates.add(t1);    
        
        ffrr__Template__c t2 = NI_TestClassData.createffrrTemplate(ffrrS.Id);
        t2.Name = 'Activity - Deliverable';
        t2.ffrr__CalculationType__c = 'Not Applicable';
        t2.ffrr__RevenueBasis__c = 'Total Revenue';
        t2.ffrr__RevenueSource__c = 'Activity_Line_Item__c';
        t2.ffrr__Settings__c = ffrrS.Id;
        t2.ffrr__RevRecType__c = 'Deliverable';
        lstTemplates.add(t2); 
        
        ffrr__Template__c t3 = NI_TestClassData.createffrrTemplate(ffrrS.Id);
        t3.Name = 'Activity - Equal Split';
        t3.ffrr__CalculationType__c = 'Days';
        t3.ffrr__RevenueBasis__c = 'Total Revenue';
        t3.ffrr__RevenueSource__c = 'Activity_Line_Item__c';
        t3.ffrr__Settings__c = ffrrS.Id;
        t3.ffrr__RevRecType__c = 'Equal Split';
        lstTemplates.add(t3); 

        database.insert(lstTemplates);        
        
        // FILL MAP OF TEST REV REC TEMPLATES
        Map<String, Id> revTemplateMap = new Map<String, Id>();
        
        for (ffrr__Template__c template : [SELECT Name, Id FROM ffrr__Template__c])
        {
            revTemplateMap.put(template.Name, template.Id);
        }
        
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId(); 
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Test Account 1';
        a.RecordTypeId = rtId;
        a.c2g__CODAAccountsReceivableControl__c = null;
        a.c2g__CODAAccountsPayableControl__c = null;
        a.c2g__CODAAccountTradingCurrency__c = 'USD';
        a.c2g__CODABaseDate1__c = 'Invoice Date';
        a.c2g__CODADaysOffset1__c = 30;
        a.c2g__CODADescription1__c = 'net 30';
        a.c2g__CODADiscount1__c = 0;
        a.c2g__CODASalesTaxStatus__c = 'Exempt';
        a.c2g__CODAExemptionCertificate__c = 'EXEMPT';
        a.c2g__CODABankCity__c = '99';
        a.c2g__CODABankCountry__c = '99';
        a.c2g__CODABankName__c = '99';
        a.c2g__CODABankSWIFTNumber__c = '99';
        a.c2g__CODABankStreet__c = '99';
        a.c2g__CODABankAccountName__c = '99';
        a.c2g__CODABankAccountNumber__c = '99';
        a.c2g__CODABankStateProvince__c = '99';         
        insert a;        

        // CREATE TEST CONTACTS
        Contact cnt1 = NI_TestClassData.createTestContact(1, a.Id);
        cnt1.FirstName = 'APEXTESTUSER';
        cnt1.LastName = 'APEXTESTUSER';
        cnt1.Email = 'test@test1.com';
        insert cnt1;
        
        Contact cnt2 = NI_TestClassData.createTestContact(2, a.Id);
        cnt2.FirstName = 'APEXTESTUSER';
        cnt2.LastName = 'APEXTESTUSER';
        cnt2.Email = 'test@test2.com';
        insert cnt2;        

        // CREATE TEST ACCOUNT TEAM MEMBER RECORD
        AccountTeamMember tm = new AccountTeamMember();
        tm.AccountId = a.Id;
        tm.UserId = UserInfo.getUserId();
        tm.TeamMemberRole = 'NI Collector';
        insert tm;

        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Salesforce');
        insert pgp;
        
        // CREATE TEST PRODUCT RECORDS
        List<Product2> lstProduct2s = new List<Product2>();

        Product2 testServiceProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK1', 'Services');  
        testServiceProduct.Revenue_Category__c = 'Services';
        testServiceProduct.Duration_Months__c = null;
        testServiceProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Deliverable') ? revTemplateMap.get('Activity - Deliverable') : null;
        lstProduct2s.add(testServiceProduct);
        
        Product2 testSupportProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK3', 'Support'); 
        testSupportProduct.Revenue_Category__c = 'Maintenance';
        testSupportProduct.Duration_Months__c = 12;        
        lstProduct2s.add(testSupportProduct);
        
        Product2 testSubscriptionProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK4', 'Subscription'); 
        testSubscriptionProduct.Revenue_Category__c = 'Software - Subscription';
        testSubscriptionProduct.Duration_Months__c = 12;
        testSubscriptionProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
        lstProduct2s.add(testSubscriptionProduct);
        
        Product2 testSoftwareProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK5', 'Software'); 
        testSoftwareProduct.Revenue_Category__c = 'Software - Perpetual';
        testSoftwareProduct.Duration_Months__c = null; 
        lstProduct2s.add(testSoftwareProduct);

        database.insert(lstProduct2s);
        
        // CREATE TEST PRODUCT PACKAGE
        PSA_Product_Package__c pkg = new PSA_Product_Package__c();
        pkg.Name = 'TEST-TST-BK1';
        pkg.Package_SKU__c = 'TEST-TST-BK1';
        pkg.Description__c = 'TEST-TST-BK1';
        insert pkg;
        
        // CREATE TEST PRODUCT PACKAGE MILESTONES 
        List<PSA_Product_Package_Milestone__c> lstPackageLines = new List<PSA_Product_Package_Milestone__c>();

        PSA_Product_Package_Milestone__c pl1 = new PSA_Product_Package_Milestone__c();
        pl1.Milestone_Name_Prefix__c = 'test';
        pl1.Percent__c = 50;
        pl1.Milestone_Type__c = 'Billable Milestone';
        pl1.Product_Package__c = pkg.Id;
        pl1.Offset_Days__c = 10;
        pl1.Product__c = testServiceProduct.Id;
        lstPackageLines.add(pl1);

        PSA_Product_Package_Milestone__c pl2 = new PSA_Product_Package_Milestone__c();
        pl2.Milestone_Name_Prefix__c = 'test';
        pl2.Percent__c = 60;
        pl2.Milestone_Type__c = 'Billable Milestone';
        pl2.Product_Package__c = pkg.Id;
        pl2.Offset_Days__c = 10;
        pl2.Product__c = testServiceProduct.Id;
        lstPackageLines.add(pl2);
        
        database.insert(lstPackageLines);

        // UPDATE A PRODUCT WITH PACKAGE
        testServiceProduct.Product_Package__c = pkg.Id;
        update testServiceProduct;
        
//        testDeploymentInstance = ffaTestUtilities.createTestasset(1, testAccount1.Id, testSubscriptionProduct.Id, testProductGroup_Salesforce.Id);
  
        Asset testDeploymentInstance = NI_TestClassData.createTestAsset(1, a.Id, testSubscriptionProduct.Id);
        testDeploymentInstance.Product_Group__c = pgp.Id;
        insert testDeploymentInstance;        

        // CREATE TEST PAYMENT TERM RECORDS
        Payment_Terms__c pt1 = NI_TestClassData.createInvoicePaymentTerms();
        pt1.Name = 'test1';
        pt1.Offset_Date__c = 'Effective Date';
        pt1.Billed_Through_PSA__c = false;
        pt1.Aptus_Payment_Terms__c = 'Standard';
        pt1.Invoice_Split_Method__c = 'Percent Breakdown'; 
        insert pt1;

        Payment_Terms__c pt2 = NI_TestClassData.createInvoicePaymentTerms();
        pt2.Name = 'test2';
        pt2.Offset_Date__c = 'Activation Date';
        pt2.Billed_Through_PSA__c = false;
        pt2.Aptus_Payment_Terms__c = 'Standard';
        pt2.Invoice_Split_Method__c = 'Equal';        
        insert pt2;

        Payment_Terms__c pt3 = NI_TestClassData.createInvoicePaymentTerms();
        pt3.Name = 'test3';
        pt3.Offset_Date__c = 'Activation Date';
        pt3.Billed_Through_PSA__c = true;
        pt3.Aptus_Payment_Terms__c = 'Standard';
        pt3.Invoice_Split_Method__c = 'Equal';        
        insert pt3;

        // CREATE TEST PAYMENT TERMS LINE ITEM RECORDS
        List<Payment_Term_Line_Item__c> lstPayTermLines = new List<Payment_Term_Line_Item__c>();
        
        Payment_Term_Line_Item__c ptl1 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt1.Id); 
        ptl1.Order__c = 1;
        ptl1.Offset_Measure__c = 'Months';
        ptl1.Offset_Units__c = 1;
        ptl1.Duration_Units__c = 1;
        ptl1.Percent_of_Total__c = 50; 
        lstPayTermLines.add(ptl1);
        
        Payment_Term_Line_Item__c ptl2 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt2.Id); 
        ptl2.Order__c = 1;
        ptl2.Offset_Measure__c = 'Years';
        ptl2.Offset_Units__c = 1;
        ptl2.Duration_Units__c = 1;
        ptl2.Percent_of_Total__c = 50;
        lstPayTermLines.add(ptl2);
        
        Payment_Term_Line_Item__c ptl3 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt3.Id); 
        ptl3.Order__c = 1;
        ptl3.Offset_Measure__c = 'Years';
        ptl3.Offset_Units__c = 1;
        ptl3.Duration_Units__c = 1;
        ptl3.Percent_of_Total__c = 50; 
        lstPayTermLines.add(ptl3); 
        
        database.insert(lstPayTermLines);
        
//createTestPmtTerms(Integer numofInvoices, String termsName, String offsetDate, String splitMethod, Integer offsetUnits, String offsetMeasure, Boolean psaBilled){             
//        testPmtTerms_PercentBreakDown = ffaTestUtilities.createTestPmtTerms(2, 'test1', 'Effective Date', 'Percent Breakdown', 1, 'Months', false);
//        testPmtTerms_EqualSplit = ffaTestUtilities.createTestPmtTerms(2, 'test2', 'Activation Date', 'Equal', 1, 'Years', false);
//        testPmtTerms_PSAbilled = ffaTestUtilities.createTestPmtTerms(2, 'test3', 'Activation Date', 'Equal', 1, 'Years', true);
        

//        Pricebook2 testPricebook = ffatestUtilities.createTestPricebook('testpricebook');

//        List<PricebookEntry> lstPricebookEntries = new List<PricebookEntry>();
        PricebookEntry servicePBE = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), testServiceProduct.Id, 1000);
        insert servicePBE;
//        lstPricebookEntries.add(servicePBE);
        PricebookEntry supportPBE = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), testSupportProduct.Id, 1000);
        insert supportPBE;
//        lstPricebookEntries.add(supportPBE);
        PricebookEntry subscriptionPBE = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), testSubscriptionProduct.Id, 1000);
        insert subscriptionPBE;
//        lstPricebookEntries.add(subscriptionPBE);
        PricebookEntry softwarePBE = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), testSoftwareProduct.Id, 1000);
        insert softwarePBE;
//		lstPricebookEntries.add(subscriptionPBE);
//        database.insert(lstPricebookEntries)
        
//        testOpp1 = ffaTestUtilities.initTestOpportunity(1, testAccount1.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id);
//        insert testOpp1;

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName(); 
        Id rtOppId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
            
        // CREATE TEST OPPORTUNITY RECORD
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX TEST OPPORTUNITY 1';
        o.RecordTypeId = rtOppId;
        insert o; 

        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS 
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // Bill To contact
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(o.Id, cnt1.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(o.Id, cnt2.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(o.Id, cnt1.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(o.Id, cnt2.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);  
        // Sponsor Contact 
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(o.Id, cnt1.Id, 'Sponsor');
        lstOppContcRole.add(ocr5); 
        
        Database.Insert(lstOppContcRole); 
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
//        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, servicePBE.Id, 2));
//        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, supportPBE.Id, 2));
//        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, ssubscriptionPBE.Id, 2));
//        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, softwarePBE.Id, 2));
        OpportunityLineItem oli1 = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, servicePBE.Id, 2);
        oliList.add(oli1);
        OpportunityLineItem oli2 = NI_TestClassData.createTestOpportunityLineItem(2, o.Id, supportPBE.Id, 2);
        oliList.add(oli2);
        OpportunityLineItem oli3 = NI_TestClassData.createTestOpportunityLineItem(3, o.Id, subscriptionPBE.Id, 2);
        oliList.add(oli3);
        OpportunityLineItem oli4 = NI_TestClassData.createTestOpportunityLineItem(4, o.Id, softwarePBE.Id, 2);
        oliList.add(oli4);
        insert oliList;
        
//        testAgreement = ffaTestUtilities.createTestAgreement(testOpp1, productList);
        
        Test.stopTest(); 
        
        system.debug(' ***  END  ffaRevenueJournal_TEST.createTestData() Limits.getQueries() = ' + Limits.getQueries()); 
        
    }
    
     
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING 
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
        system.debug(' *** START ffaRevenueJournal_TEST.test1()');  
        
        Opportunity o = [SELECT Id, CloseDate, StageName, Probability, RecordTypeId FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1'];
        Contact cnt2 = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER' AND Email = 'test@test2.com'];
        ffrr__Template__c tp = [SELECT Id, ffrr__RevRecType__c FROM ffrr__Template__c WHERE Name = 'Activity - Equal Split'];
        Payment_Terms__c pt = [SELECT Id FROM Payment_Terms__c WHERE Name = 'test1'];
		Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST-TST-BK4'];   
        Date dt = system.date.today();    
        
        
        
        Test.startTest(); 

        // WHY?
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();

        // CLOSE AN OPPORTUNITY
        o.CloseDate = date.today();
        o.StageName = 'Closed Won';
        o.Probability = 100;
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
        update o;        
        
        // TEST createBillingContract VF PAGE
        ApexPages.currentPage().getParameters().put('id', o.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.Id;
            cntrlr.processLines();
        }
        
        Billing_Contract__c testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        PageReference testPgRef = cntrlr.backToOpp();
        
        testBillingContract1.Attn_to_Contact__c = cnt2.Id;
        update testBillingContract1;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(testBillingContract1.Id);
        ali.Activation_Date__c = Date.today();
        ali.Contract_Start_Date__c = Date.today().addMonths(1);
        ali.Contract_End_Date__c = Date.today().addMonths(2);
        ali.Product__c = p2.Id;
        ali.Payment_Terms__c = pt.Id;
        ali.Opp_Product_ID__c = p2.Id;
        ali.Activation_Required__c = true;
        ali.ffrrtemplate__c = tp.Id;
        ali.Contract_Amount__c = 1000; 
        ali.Units__c = 1;
        //ali.Deployment_Instance__c = di.Id;         
        insert ali;
        
        // TEST REBUILD BILLING LINE ITEMS
        // Update a bc line to invoiced = true
        ali.ACTION_Rebuild_Billing_Lines__c = true;
        update ali;
        
        //============START REV REC TESTING================
        
        ffrr__RecognitionYear__c ry = NI_TestClassData.createRecognitionYear(dt);
        insert ry;

/*
  
		RESEARCH NEEDED: 
		FOLLOWING ERROR IS RAISED WHEN TRYING TO INSERT ffrr__RecognitionPeriod__c RECORDS:

		System.DmlException: Insert failed. First exception on row 0; 
		first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot create recognition periods in this way. 
					 Click Create Periods on the recognition year record to create the correct number of recognition periods.
        
        
        
		ffrr__RecognitionPeriod__c rp = NI_TestClassData.createRecognitionPeriod(dt, ry.Id);
		insert rp;
        
        List<ffrr__RecognitionPeriod__c> lstRPAsserts = new List<ffrr__RecognitionPeriod__c>([SELECT Id FROM ffrr__RecognitionPeriod__c]);
        system.assertEquals(1, lstRPAsserts.size());
        
        // THIS PULLS IN THE BUDGET TEMPLATE
        Id aliTemplateId = [SELECT Id FROM ffrr__Template__c WHERE Name = 'Activity - Equal Split'].Id;


        // THIS PULLS THE RECOGNITION PERIOD 
        ffrr__RecognitionPeriod__c period = [SELECT Id, Name 
                                             FROM ffrr__RecognitionPeriod__c 
                                             WHERE ffrr__StartDate__c <=: dt 
                                             AND ffrr__EndDate__c >=: dt
                                             LIMIT 1];
        
        // THIS BUILDS THE TRANSACTION
        ffrr.TransactionService.HeaderDetails headerDetails = new ffrr.TransactionService.HeaderDetails();
        headerDetails.description = 'My Transaction';
        headerDetails.currencyName = 'USD';
        headerDetails.recognitionDate = Date.today();
        headerDetails.lineAction = ffrr.TransactionService.LineAction.IGNORE;
        headerDetails.lineDetailsMap = new Map<Id, ffrr.TransactionService.LineDataToSave>();
        
        // YOU NEED TO SET THE GROUP NAME TO THE TOP LEVEL OF THE REV REC CHAIN (MOST LIKELY ALWAYS PROJECT)
        headerDetails.groupName = 'Billing_Contract__c';
        
        // PERIOD NAME AND ID GO HERE THAT YOU RETRIEVED ABOVE
        headerDetails.Period = period.Name;
        headerDetails.PeriodID = period.Id;
        
        // THIS INDICATES WHETHER YOU WANT THE TRANS MARKED AS COMMITTED OR NOT
        headerDetails.commitTransaction = true;
        
        ffrr.TransactionService.LineDataToSave sampleLineData1 = new ffrr.TransactionService.LineDataToSave();

        // HERE IS THE KEY AREA: PUT IN ALL OF THE IDS IN THE RECORDIDLIST. FOR EXAMPLE, SINCE OUR REV REC IS ONLY 2 LEVELS DEEP,
        // WE ONLY PUT IN PROJECT ID AND BUDGET ID. IF YOU WERE USING TIMECARDS FOR EXAMPLE, YOU WOULD ADD THE TIMECARD ID
        sampleLineData1.recordIdList = new List<Id>{testBillingContract1.Id, testAli.Id};
            
        // THIS IS THE TEMPLATE ID
        sampleLineData1.templateId = aliTemplateId;
        
        // AND THIS IS THE AMOUNT TO RECOGNIZE
        sampleLineData1.toRecognizeThisPeriod = 1;
        
        // ADD THEM INTO THE LINE DETAILS MAP
        headerDetails.lineDetailsMap.put(testBillingContract1.Id, sampleLineData1);

        // Call the save method that will start an asynchronous process to create the InProgress RR Transaction.
        List<ffrr.TransactionService.HeaderDetails> hh = new List<ffrr.TransactionService.HeaderDetails>();
        hh.add(headerDetails);

        // AND SAVE IT. YOU DON'T HAVE TO USE BULKSAVE, BUT I WAS AT THE END OF MY ROPE AND TRYING EVERYTHING!
        ffrr.TransactionService.SaveResult result = ffrr.TransactionService.bulkSave( hh );
        String transId = result.transactions[0] != null ? result.transactions[0] : '';

        // now test the journal creation with the created rev trans:
        ffaRevenueTransactionJournal.createJournalWS(transId);

*/
        
        Test.stopTest();
        
        system.debug(' *** END ffaRevenueJournal_TEST.test1() Limits.getQueries() = ' + Limits.getQueries()); 
        
    } 
    
       
/* 
      
    ===========================================================================
		OLD CODE ==============================================================
	===========================================================================

    public static Account testAccount1;
    public static Contact testContact1;
    public static Contact testContact2;
    public static Opportunity testOpp1;
    //public static Product_Group__c testProductGroup_Delphi;
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
    //public static pse__Region__c testRegion;
    //public static pse__Practice__c testPractice;
    //public static pse__Proj__c testProject;
    public static Map<String, Id> revTemplateMap;
    public static List<OpportunityLineItem> oliList;
    
    public static void setupTestData1()
    {

        revTemplateMap = new Map<String, Id>();
        
        for (ffrr__Template__c template : [SELECT Name, Id FROM ffrr__Template__c])
        {
            revTemplateMap.put(template.Name, template.Id);
        }
        
        oliList = new List<OpportunityLineItem>();
        
        testAccount1 = ffaTestUtilities.createAccount('Test Account 1', null);
        testContact1 = ffaTestUtilities.createTestContact('TEST', 'test@test.com');
        testContact2 = ffaTestUtilities.createTestContact('TEST2', 'test@test2.com');
        ffaTestUtilities.createAccountTeam(UserInfo.getUserId(), testAccount1.Id, 'NI Collector');
        
        testProductGroup_Salesforce = NI_TestClassData.createProductGroup(1, 'Salesforce');
        insert testProductGroup_Salesforce;
        
        List<Product2> productList = new List<Product2>();
        testServiceProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.Id, 'TEST-TST-BK1', 'Services', 'Services',null);
        testSupportProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.Id, 'TEST-TST-BK3', 'Support', 'Maintenance', 12);
        testSubsciptionProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.Id, 'TEST-TST-BK4', 'Subscription', 'Software - Subscription', 12);
        testSoftwareProduct = ffaTestUtilities.createProduct2(1, testProductGroup_Salesforce.Id, 'TEST-TST-BK5', 'Software', 'Software - Perpetual', null);
        productList.add(testServiceProduct);
        productList.add(testSupportProduct);
        productList.add(testSubsciptionProduct);
        productList.add(testSoftwareProduct);
        
        testSubsciptionProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
        testServiceProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Deliverable') ? revTemplateMap.get('Activity - Deliverable') : null;
        
        testProductPackage = ffaTestUtilities.createProductPackage('TEST-TST-BK1', 2, testServiceProduct.Id);
        testServiceProduct.Product_Package__c = testProductPackage.Id;
        update testServiceProduct;
        
        testDeploymentInstance = ffaTestUtilities.createTestasset(1, testAccount1.Id, testSubsciptionProduct.Id, testProductGroup_Salesforce.Id);
        
        testPmtTerms_PercentBreakDown = ffaTestUtilities.createTestPmtTerms(2, 'test1', 'Effective Date', 'Percent Breakdown', 1, 'Months', false);
        testPmtTerms_EqualSplit = ffaTestUtilities.createTestPmtTerms(2, 'test2', 'Activation Date', 'Equal', 1, 'Years', false);
        testPmtTerms_PSAbilled = ffaTestUtilities.createTestPmtTerms(2, 'test3', 'Activation Date', 'Equal', 1, 'Years', true);
        
        Pricebook2 testPricebook = ffatestUtilities.createTestPricebook('testpricebook');
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry servicePBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId, testServiceProduct.Id, 1000);
        PricebookEntry supportPBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId, testSupportProduct.Id, 1000);
        PricebookEntry ssubscriptionPBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId, testSubsciptionProduct.Id, 1000);
        PricebookEntry softwarePBE = ffatestUtilities.createTestPricebookEntry(stdPricebookId, testSoftwareProduct.Id, 1000);
        
        testOpp1 = ffaTestUtilities.initTestOpportunity(1, testAccount1.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id, testPmtTerms_PercentBreakDown.Id);
        insert testOpp1;
        
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, servicePBE.Id, 2));
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, supportPBE.Id, 2));
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, ssubscriptionPBE.Id, 2));
        oliList.add(ffaTestUtilities.initTestOpportunityLineItem(1, testOpp1.Id, softwarePBE.Id, 2));
        insert oliList;
        
        testAgreement = ffaTestUtilities.createTestAgreement(testOpp1,productList);
        
    }
    
    public static void closeOpp(Opportunity opp, Contact roleContact)
    {
        ffaTestUtilities.createTestOpportunityContactRoles(opp.Id, roleContact.Id);
        opp.CloseDate = date.today();
        opp.StageName = 'Closed Won';
        opp.Probability = 100;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId();
        update opp;
    }
    
    @isTest public static void testRevJournalCreation()
    {
        
        //setup data:
        setupTestData1();
        
        Test.startTest();
        
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        closeOpp(testopp1, testContact1);
        ApexPages.currentPage().getParameters().put('id', testOpp1.Id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        if (createBillingContractController.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.billingContract.Id;
            cntrlr.processLines();
        }
        
        testBillingContract1 = cntrlr.billingContract;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        PageReference testPgRef = cntrlr.backToOpp();
        
        testBillingContract1.Attn_to_Contact__c = testContact2.Id;
        update testBillingContract1;
        
        Activity_Line_Item__c testAli = new Activity_Line_Item__c();
        
        //Update a bc line to invoiced = true
        for (Activity_Line_Item__c ali : [SELECT Id, Activation_Date__c, ACTION_Rebuild_Billing_Lines__c, Contract_Start_Date__c, Contract_End_Date__c 
                                          FROM Activity_Line_Item__c 
                                          WHERE Billing_Contract__c = :testBillingContract1.Id LIMIT 1])
        {
            ali.Activation_Date__c = Date.today();
            ali.Contract_Start_Date__c = Date.today().addMonths(-1);
            ali.Contract_End_Date__c = Date.today().addMonths(1);
            ali.ACTION_Rebuild_Billing_Lines__c = true;
            ali.ffrrtemplate__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
            testAli = ali;
        }
        
        update testAli;
        
        
        //============START REV REC TESTING================
        
        
        //THIS PULLS IN THE BUDGET TEMPLATE
        Id aliTemplateId = [SELECT Id FROM ffrr__Template__c WHERE Name = 'Activity - Equal Split'].Id;
        
        //THIS PULLS THE RECOGNITION PERIOD 
        ffrr__RecognitionPeriod__c period = [SELECT Id, Name 
                                             FROM ffrr__RecognitionPeriod__c 
                                             WHERE ffrr__StartDate__c <=: Date.today() 
                                             AND ffrr__EndDate__c >=: Date.today() 
                                             LIMIT 1];
        
        //THIS BUILDS THE TRANSACTION
        ffrr.TransactionService.HeaderDetails headerDetails = new ffrr.TransactionService.HeaderDetails();
        headerDetails.description = 'My Transaction';
        headerDetails.currencyName = 'USD';
        headerDetails.recognitionDate = Date.today();
        headerDetails.lineAction = ffrr.TransactionService.LineAction.IGNORE;
        headerDetails.lineDetailsMap = new Map<Id, ffrr.TransactionService.LineDataToSave>();
        
        // YOU NEED TO SET THE GROUP NAME TO THE TOP LEVEL OF THE REV REC CHAIN (MOST LIKELY ALWAYS PROJECT)
        headerDetails.groupName = 'Billing_Contract__c';
        
        // PERIOD NAME AND ID GO HERE THAT YOU RETRIEVED ABOVE
        headerDetails.Period = period.Name;
        headerDetails.PeriodID = period.Id;
        
        // THIS INDICATES WHETHER YOU WANT THE TRANS MARKED AS COMMITTED OR NOT
        headerDetails.commitTransaction = true;
        
        ffrr.TransactionService.LineDataToSave sampleLineData1 = new ffrr.TransactionService.LineDataToSave();

        // HERE IS THE KEY AREA: PUT IN ALL OF THE IDS IN THE RECORDIDLIST. FOR EXAMPLE, SINCE OUR REV REC IS ONLY 2 LEVELS DEEP,
        // WE ONLY PUT IN PROJECT ID AND BUDGET ID. IF YOU WERE USING TIMECARDS FOR EXAMPLE, YOU WOULD ADD THE TIMECARD ID
        sampleLineData1.recordIdList = new List<Id>{testBillingContract1.Id, testAli.Id};
            
        // THIS IS THE TEMPLATE ID
        sampleLineData1.templateId = aliTemplateId;
        
        // AND THIS IS THE AMOUNT TO RECOGNIZE
        sampleLineData1.toRecognizeThisPeriod = 1;
        
        //ADD THEM INTO THE LINE DETAILS MAP
        headerDetails.lineDetailsMap.put(testBillingContract1.Id, sampleLineData1);
        // Call the save method that will start an asynchronous process
        // to create the InProgress RR Transaction.
        
        List<ffrr.TransactionService.HeaderDetails> hh = new List<ffrr.TransactionService.HeaderDetails>();
        hh.add(headerDetails);
        //AND SAVE IT. YOU DON'T HAVE TO USE BULKSAVE, BUT I WAS AT THE END OF MY ROPE AND TRYING EVERYTHING!
        ffrr.TransactionService.SaveResult result = ffrr.TransactionService.bulkSave( hh );
        String transId = result.transactions[0] != null ? result.transactions[0] : '';
        
        
        //now test the journal creation with the created rev trans:
        ffaRevenueTransactionJournal.createJournalWS(transId);
       
        Test.stopTest();
        
    }

*/ 
    
}