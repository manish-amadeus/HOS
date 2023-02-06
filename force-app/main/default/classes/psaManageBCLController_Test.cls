/************************************************************************************************
Name            : psaManageBCLController_Test
Author          : Sean Harris
Created Date    : 06/06/2022
Last Mod Date   : 06/06/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for psaManageBCLController (Controller for "psaBillingContractLines" VF Page)
                : 
                : 
*************************************************************************************************/
@isTest
public class psaManageBCLController_Test 
{    
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        
        Test.startTest();          
        
        List<Account> lstAccounts = new List<Account>();
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Test Account 1';
        insert a;
        
        // CREATE TEST CONTACT RECORD
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Lou';
        cnt.LastName = 'Sanus';
        insert cnt;

        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();

        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = rt;
        insert o;   

        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         

        // CREATE A TEST DI INDEX RECORDS
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX 1'); 
        insert idx1; 
        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST INDEX 2'); 
        insert idx2; 

        // CREATE A TEST PRODUCT RECORDS
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id; 
        prd01.Product_Line_Global__c = 'Delphi.fdc'; 
        prd01.Solution_Domain_Global__c = 'Sales & Catering';
        insert prd01; 

        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HotSOS-01-TEST', 'Subscription');
        prd02.DI_Index__c = idx2.Id; 
        prd02.Product_Line_Global__c = 'HotSOS'; 
        prd02.Solution_Domain_Global__c = 'Service Optimization';
        insert prd02; 

        // CREATE A TEST ASSET RECORDS
        List<Asset> lstAssets = new List<Asset>();
        
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di1.Product_Group__c = pgp.Id;    
		lstAssets.add(di1);
        
        Asset di2 = NI_TestClassData.createTestAsset(1, a.Id, prd02.Id);
        di2.Product_Group__c = pgp.Id;       
        lstAssets.add(di2);
        
        database.insert(lstAssets);
        

        // CREATE A TEST BILLING RECORD FOR MULTIPROP ACCOUNT
        List<Billing_Contract__c> lstBCs = new List<Billing_Contract__c>();
        
        Billing_Contract__c blgCnrct1 = NI_TestClassData.createBillingContract(1);
        blgCnrct1.Name = 'APEX BC TEST #1';
        blgCnrct1.Account__c = a.Id;
        lstBCs.add(blgCnrct1);

        // CREATE A TEST BILLING RECORD FOR STANDALONE ACCOUNT
        Billing_Contract__c blgCnrct2 = NI_TestClassData.createBillingContract(2);
        blgCnrct2.Name = 'APEX BC TEST #2';
        blgCnrct2.Account__c = a.Id;   
        lstBCs.add(blgCnrct2);
        
        database.insert(lstBCs);        
        
        
        Test.stopTest();  

        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(blgCnrct1.Id);
        insert ali;
        
        Billing_Contract_Line_Item__c bli = NI_TestClassData.createBillingContract(blgCnrct1.Id, ali.Id);
		insert bli;
        
/*      
        // Disable some triggers:
        //NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        //triggerSwitch.BypassAccount_ON__c = true;
        //triggerSwitch.BypassOpportunity_ON__c = true;
        //triggerSwitch.Bypass_activityLineItemTrigger__c = true;
        //update triggerSwitch;
        

        // CREATE FF TEMPLATE MAP
        Map<String, Id> revTemplateMap = new Map<String, Id>();
        
        for (ffrr__Template__c template : [SELECT Id, Name FROM ffrr__Template__c])
        {
            revTemplateMap.put(template.name, template.Id);
        }
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Test Account 1';
        insert a;
        
        // CREATE TEST CONTACT RECORD
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Lou';
        cnt.LastName = 'Sanus';
        insert cnt;
        
        // CREATE TEST ACCOUNT TEAM MEMBER RECORD 
        AccountTeamMember tm = new AccountTeamMember();
        tm.AccountId = a.Id;
        tm.UserId = UserInfo.getUserId();
        tm.TeamMemberRole = 'NI Collector';
        insert tm;
        
        // CREATE TEST CONTACT RECORDS
        List<Contact> lstContacts = new List<Contact>();
        Contact testContact1 = NI_TestClassData.createTestContact(1, a.Id);
        lstContacts.Add(testContact1);
        Contact testContact2 = NI_TestClassData.createTestContact(2, a.Id);
		lstContacts.Add(testContact2);
        database.insert(lstContacts);

		// CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pg1 = NI_TestClassData.createProductGroup(1, 'Salesforce');
        insert pg1;
        
        // CREATE TEST PRODUCT2 RECORDS 
        List<Product2> lstProduct2 = new List<Product2>();
        
        Product2 prd1 = NI_TestClassData.createProduct2(1, pg1.Id, 'TEST-TST-BK1', 'Services'); 
        prd1.pse__IsServicesProduct__c = true;
        prd1.Revenue_Category__c = 'Maintenance';
        prd1.Duration_Months__c = 12;
        prd1.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Deliverable') ? revTemplateMap.get('Activity - Deliverable') : null;
		lstProduct2.add(prd1);
        
        Product2 prd2 = NI_TestClassData.createProduct2(1, pg1.Id, 'TEST-TST-BK3', 'Support'); 
        prd2.Revenue_Category__c = 'Services';
        prd2.Duration_Months__c = 12;
		lstProduct2.add(prd2);
               
        Product2 prd3 = NI_TestClassData.createProduct2(1, pg1.Id, 'TEST-TST-BK4', 'Subscription'); 
        prd3.Revenue_Category__c = 'Software - Subscription';
        prd3.Duration_Months__c = 12;
        prd3.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
		lstProduct2.add(prd3);
          
        Product2 prd4 = NI_TestClassData.createProduct2(1, pg1.Id, 'TEST-TST-BK5', 'Software'); 
        prd4.Revenue_Category__c = 'Software - Perpetual';
		lstProduct2.add(prd4);
          
		database.insert(lstProduct2);
        
        // CREATE TEST PRODUCT PACKAGE RECORD 
        PSA_Product_Package__c pp1 = NI_TestClassData.createPSAProductPackage();   // ffaTestUtilities.createProductPackage('TEST-TST-BK1', 2, testServiceProduct.Id);
        pp1.Name = 'TEST-TST-BK1';
        pp1.Package_SKU__c = 'TEST-TST-BK1';
        pp1.Description__c = 'TEST-TST-BK1';        
        insert pp1;
        
        // CREATE TEST PRODUCT PACKAGE MILESTONE RECORDS
        List<PSA_Product_Package_Milestone__c> lstProductPackageMilestone = new List<PSA_Product_Package_Milestone__c>();
        
        PSA_Product_Package_Milestone__c ppm1 = new PSA_Product_Package_Milestone__c();
        ppm1.Milestone_Name_Prefix__c = 'test';
        ppm1.Percent__c = 50;
        ppm1.Milestone_Type__c = 'Billable Milestone';
        ppm1.Product_Package__c = pp1.Id;
        ppm1.Offset_Days__c = 10;
        ppm1.Product__c = prd1.Id;
        lstProductPackageMilestone.add(ppm1);    

        PSA_Product_Package_Milestone__c ppm2 = new PSA_Product_Package_Milestone__c();
        ppm2.Milestone_Name_Prefix__c = 'test';
        ppm2.Percent__c = 50;
        ppm2.Milestone_Type__c = 'Billable Milestone';
        ppm2.Product_Package__c = pp1.Id;
        ppm2.Offset_Days__c = 10;
        ppm2.Product__c = prd1.Id;
        lstProductPackageMilestone.add(ppm2);          
        
        database.insert(lstProductPackageMilestone);
       
        // UPDATE TEST SERVICES PRODUCT2 WITH NEWLY CREATED TEST PRODUCT PACKAGE RECORD
        prd1.Product_Package__c = pp1.Id;
        update prd1;
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORD
        Asset di = NI_TestClassData.createTestasset(1, a.Id, prd3.Id);
        di.Product_Group__c = pg1.Id;
        insert di;

        // CREATE TEST PAYMENT TERMS RECORDS
        List<Payment_Terms__c> lstPaymentTerms = new List<Payment_Terms__c>();
        
        Payment_Terms__c pt1 = NI_TestClassData.createInvoicePaymentTerms();
        pt1.Name = 'test1';
        pt1.Offset_Date__c = 'Effective Date';
        pt1.Billed_Through_PSA__c = false;
        pt1.Aptus_Payment_Terms__c = 'Standard';
        pt1.Invoice_Split_Method__c = 'Percent Breakdown';       
		lstPaymentTerms.add(pt1);        
        
        Payment_Terms__c pt2 = NI_TestClassData.createInvoicePaymentTerms();
        pt2.Name = 'test2';
        pt2.Offset_Date__c = 'Activation Date';
        pt2.Billed_Through_PSA__c = false;
        pt2.Aptus_Payment_Terms__c = 'Standard';
        pt2.Invoice_Split_Method__c = 'Equal';       
		lstPaymentTerms.add(pt2);
        
        Payment_Terms__c pt3 = NI_TestClassData.createInvoicePaymentTerms();
        pt3.Name = 'test3';
        pt3.Offset_Date__c = 'Activation Date';
        pt3.Billed_Through_PSA__c = true;
        pt3.Aptus_Payment_Terms__c = 'Standard';
        pt3.Invoice_Split_Method__c = 'Equal';       
		lstPaymentTerms.add(pt3);
        
        database.insert(lstPaymentTerms);
        
        // CREATE TEST PAYMENT TERM LINE ITEM RECORDS
        List<Payment_Term_Line_Item__c> lstPayTermLines = new List<Payment_Term_Line_Item__c>();
        
        Payment_Term_Line_Item__c tli1 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt1.Id); 
        tli1.Order__c = 1;
        tli1.Offset_Measure__c = 'Months';
        tli1.Offset_Units__c = 1;
        tli1.Duration_Units__c = 1;
        tli1.Percent_of_Total__c = 50;
        lstPayTermLines.add(tli1);        

        Payment_Term_Line_Item__c tli2 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt1.Id);
        tli2.Order__c = 1;
        tli2.Offset_Measure__c = 'Months';
        tli2.Offset_Units__c = 1;
        tli2.Duration_Units__c = 1;
        tli2.Percent_of_Total__c = 50;
        lstPayTermLines.add(tli2);

        Payment_Term_Line_Item__c tli3 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt2.Id);
        tli3.Order__c = 1;
        tli3.Offset_Measure__c = 'Months';
        tli3.Offset_Units__c = 1;
        tli3.Duration_Units__c = 1;
        tli3.Percent_of_Total__c = 50;
        lstPayTermLines.add(tli3);        

        Payment_Term_Line_Item__c tli4 = new NI_TestClassData.createInvoicePaymentTermsLimeItem(pt2.Id);
        tli4.Order__c = 1;
        tli4.Offset_Measure__c = 'Months';
        tli4.Offset_Units__c = 1;
        tli4.Duration_Units__c = 1;
        tli4.Percent_of_Total__c = 50;
        lstPayTermLines.add(tli4);
        
        Payment_Term_Line_Item__c tli5 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt3.Id);
        tli5.Order__c = 1;
        tli5.Offset_Measure__c = 'Months';
        tli5.Offset_Units__c = 1;
        tli5.Duration_Units__c = 1;
        tli5.Percent_of_Total__c = 50;
        lstPayTermLines.add(tli5);        

        Payment_Term_Line_Item__c tli6 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt3.Id);
        tli6.Order__c = 1;
        tli6.Offset_Measure__c = 'Months';
        tli6.Offset_Units__c = 1;
        tli6.Duration_Units__c = 1;
        tli6.Percent_of_Total__c = 50;
        lstPayTermLines.add(tli6);   
        
        database.insert(lstPayTermLines);
 
        // GET STANDARD PRICEBOOK ID
        Id stdPricebookId = Test.getStandardPricebookId();

        // CREATE TEST PRICEBOOK ENTRY RECORDS
        List<PricebookEntry> lstPricebookEntries = new List<PricebookEntry>();
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(stdPricebookId, prd1.Id, 1000);
        lstPricebookEntries.add(pbe1);
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(stdPricebookId, prd2.Id, 1000);
        lstPricebookEntries.add(pbe2);
        PricebookEntry pbe3 = NI_TestClassData.createTestPricebookEntry(stdPricebookId, prd3.Id, 1000);
        lstPricebookEntries.add(pbe3);
        PricebookEntry pbe4 = NI_TestClassData.createTestPricebookEntry(stdPricebookId, prd4.Id, 1000);
        lstPricebookEntries.add(pbe4);
        
        database.insert(lstPricebookEntries);
       
        // CREATE TEST OPPORTUNITY RECORD
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id);

        opp1.Name = 'Apex Test Opportunity Name';
        opp1.StageName = 'Prospecting';
        opp1.Order_Status__c = 'Prospect';
        opp1.Amount = 25000;
        opp1.CloseDate = Date.Today().addDays(-1);
        opp1.Effective_Date__c = Date.Today().addDays(-1);
        opp1.Opportunity_Source__c = 'Support';     
        opp1.License_Program_Payment_Terms__c = pt1.Id;
        opp1.Hosting_and_Support_Payment_Terms__c = pt1.Id;
        opp1.Services_Payment_Terms__c = pt1.Id;
        opp1.Subscription_Payment_Terms__c = pt1.Id;
        opp1.Support_Payment_Terms__c = pt1.Id;    
        
        insert opp1;
        
		// CREATE TEST OPPORTUNITY LINE ITEM RECORDS              
        List<OpportunityLineItem> lstOpptyLineItems = new List<OpportunityLineItem>();

        lstOpptyLineItems.add(NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe1.Id, 2));
        lstOpptyLineItems.add(NI_TestClassData.createTestOpportunityLineItem(2, opp1.Id, pbe2.Id, 2));
        lstOpptyLineItems.add(NI_TestClassData.createTestOpportunityLineItem(3, opp1.Id, pbe3.Id, 2));
        lstOpptyLineItems.add(NI_TestClassData.createTestOpportunityLineItem(4, opp1.Id, pbe4.Id, 2));
        
        insert lstOpptyLineItems;
        
        //testAgreement = ffaTestUtilities.createTestAgreement(testOpp1, lstProduct2);
        
        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS  
        List<OpportunityContactRole> lstOpptyContactRoles = new List<OpportunityContactRole>();
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.OpportunityId = opp1.Id;
        ocr1.ContactId = cnt.Id;
        ocr1.Role = 'Decision Maker'; 
        lstOpptyContactRoles.add(ocr1);

        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.OpportunityId = opp1.Id;
        ocr2.ContactId = cnt.Id;
        ocr2.Role = 'Bill To';     
        lstOpptyContactRoles.add(ocr2); 

        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.OpportunityId = opp1.Id;
        ocr3.ContactId = cnt.Id;
        ocr3.Role = 'Ship To';     
        lstOpptyContactRoles.add(ocr3); 

        OpportunityContactRole ocr4 = new OpportunityContactRole();
        ocr4.OpportunityId = opp1.Id;
        ocr4.ContactId = cnt.Id;
        ocr4.Role = 'Customer Project Contact';     
        lstOpptyContactRoles.add(ocr4);

        database.insert(lstOpptyContactRoles);   
*/      

    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING 
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
        Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Name = 'APEX BC TEST #1'];
        
        Test.startTest();
        
        // PAGE REFERENCE        
        PageReference pageRef = Page.psaManageBillingContractLines; 
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', bc.Id);   
        
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        ApexPages.StandardController sc = new ApexPages.StandardController(bc);
        psaManageBCLController ctrl = new psaManageBCLController(sc); 
        
        
        ctrl.addRow();
        ctrl.saveLines();
        ctrl.cloneLines();
        ctrl.loadLineItems();
        ctrl.deleteSelected();
        ctrl.backToBC();
        
        Test.stopTest();
        
    }    

}