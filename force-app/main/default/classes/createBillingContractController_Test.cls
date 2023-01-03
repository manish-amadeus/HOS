/****************************************************************************************
Name            : createBillingContractController_Test
Author          : Sean Harris
Created Date    : 06/10/2019 
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for createBillingContractController
				: Created this because CLD did not
******************************************************************************************/
@isTest
public class createBillingContractController_Test
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *^* START createBillingContractController_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest(); 
        
        
        // Disable some triggers:
        //NI_TriggerBypassSwitches__c triggerSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        //triggerSwitch.BypassAccount_ON__c = true;
        //triggerSwitch.BypassOpportunity_ON__c = true;
        //update triggerSwitch;
        
        FFA_Loading_Messages__c csLMgs = new FFA_Loading_Messages__c();
        csLMgs.Name = 'Fair Warning';
        csLMgs.Message__c = 'Do not eat yellow snow';
        insert csLMgs;
        
        // CREATE RENEWAL PRICEBOOKS =============================================================
        List<Renewal_Pricebook__c> lstRenewalPricebook = new List<Renewal_Pricebook__c>();
        
        Renewal_Pricebook__c rp1 = new Renewal_Pricebook__c();
        rp1.Name = 'ANN';
        rp1.Description__c = 'Annual support increase';
        rp1.Notes__c = 'This is only updated with the annual change.';
        rp1.Is_Default__c = true;
        lstRenewalPricebook.add(rp1);

        Renewal_Pricebook__c rp2 = new Renewal_Pricebook__c();
        rp2.Name = 'CPI';
        rp2.Description__c = 'Consumer Price Index';
        rp2.Notes__c = 'Updated Monthly';
        lstRenewalPricebook.add(rp2);
        
        database.insert(lstRenewalPricebook);
        
        // CREATE RENEWAL PRICEBOOK ENTRIES ======================================================
        List<Renewal_Pricing_Entry__c> lstRenewalPBEntries = new List<Renewal_Pricing_Entry__c>(); 
        
        Renewal_Pricing_Entry__c rpe1 = new Renewal_Pricing_Entry__c();
        rpe1.Start_Date__c = Date.today().addDays(-100);
        rpe1.End_Date__c = Date.today().addDays(100);
        rpe1.Renewal_Pricebook__c = rp1.Id;
        rpe1.Percent_Increase__c = 10;
        lstRenewalPBEntries.add(rpe1);        

        Renewal_Pricing_Entry__c rpe2 = new Renewal_Pricing_Entry__c(); 
        rpe2.Start_Date__c = Date.today().addDays(-100); 
        rpe2.End_Date__c = Date.today().addDays(100); 
        rpe2.Renewal_Pricebook__c = rp2.Id; 
        rpe2.Percent_Increase__c = 10; 
        lstRenewalPBEntries.add(rpe2); 
        
        database.insert(lstRenewalPBEntries);
        
        // Query Existing Setup Data =============================================================
        Map<String, Id> revTemplateMap = new Map<String, Id>();
        for (ffrr__Template__c template : [SELECT Id, Name FROM ffrr__Template__c])
        {
            revTemplateMap.put(template.Name, template.Id);
        }

        // CREATE TEST PAYMENT TERMS =============================================================
        List<Payment_Terms__c> lstPaymentTerms = new List<Payment_Terms__c>();
        
        Payment_Terms__c pt_PercentBreakDown = NI_TestClassData.createInvoicePaymentTerms(); 
        pt_PercentBreakDown.Name = 'test 1 month';
        pt_PercentBreakDown.Offset_Date__c = 'Effective Date';
        pt_PercentBreakDown.Billed_Through_PSA__c = false;
        pt_PercentBreakDown.Aptus_Payment_Terms__c = 'Standard';
        pt_PercentBreakDown.Invoice_Split_Method__c = 'Percent Breakdown';   
        lstPaymentTerms.add(pt_PercentBreakDown);
        
        Payment_Terms__c pt_EqualSplit = NI_TestClassData.createInvoicePaymentTerms(); 
        pt_EqualSplit.Name = 'test 2 year';
        pt_EqualSplit.Offset_Date__c = 'Activation Date';
        pt_EqualSplit.Billed_Through_PSA__c = false;
        pt_EqualSplit.Aptus_Payment_Terms__c = 'Standard';
        pt_EqualSplit.Invoice_Split_Method__c = 'Equal';   
        lstPaymentTerms.add(pt_EqualSplit);
        
        Payment_Terms__c pt_PSAbilled = NI_TestClassData.createInvoicePaymentTerms(); 
        pt_PSAbilled.Name = 'test 3 year';
        pt_PSAbilled.Offset_Date__c = 'Activation Date';
        pt_PSAbilled.Billed_Through_PSA__c = false;
        pt_PSAbilled.Aptus_Payment_Terms__c = 'Standard';
        pt_PSAbilled.Invoice_Split_Method__c = 'Equal';   
        lstPaymentTerms.add(pt_PSAbilled);        
        
        database.insert(lstPaymentTerms);


		// CREATE PAYMENT TERM LINE ITEMS ======================================================        
        List<Payment_Term_Line_Item__c> lstPaymentTermLines = new List<Payment_Term_Line_Item__c>();
        
        for (Payment_Terms__c ptrm : [SELECT Id, Name FROM Payment_Terms__c])
        {
            
            Payment_Term_Line_Item__c pmtLine = new Payment_Term_Line_Item__c();
            pmtLine.Payment_Terms__c = ptrm.Id;    
            pmtLine.Order__c = 1;
            pmtLine.Offset_Measure__c = 'Years';
            if (ptrm.Name == 'test 1 month')
            {
                pmtLine.Offset_Measure__c = 'Months';
            }
            pmtLine.Offset_Units__c = 1;
            pmtLine.Duration_Units__c = 1;
            pmtLine.Percent_of_Total__c = 50;
            lstPaymentTermLines.add(pmtLine);            

        }
        
 		database.insert(lstPaymentTermLines);        
        
        // CREATE TEST ACCOUNT =================================================================
        Account a1 = NI_TestClassData.createTestAccount(1);
        
        a1.name = 'createBillingContractController_Test Account';
        a1.Vendor_Type__c = 'Newmarket';
    	a1.BillingStreet = '10000 Sample St.';
        a1.BillingCity = 'Sample City';
        a1.BillingState = 'VA';
        a1.BillingPostalCode = '23238';
        a1.BillingCountry = 'US';
        a1.c2g__CODAAccountsReceivableControl__c = null;
        a1.c2g__CODAAccountsPayableControl__c = null;
        a1.c2g__CODAAccountTradingCurrency__c = 'USD';
        a1.c2g__CODABaseDate1__c = 'Invoice Date';
        a1.c2g__CODADaysOffset1__c = 30;
        a1.c2g__CODADescription1__c = 'net 30';
        a1.c2g__CODADiscount1__c = 0;
        a1.c2g__CODASalesTaxStatus__c = 'Exempt';
        a1.c2g__CODAExemptionCertificate__c = 'EXEMPT';
        a1.c2g__CODABankCity__c = '99';
        a1.c2g__CODABankCountry__c = '99';
        a1.c2g__CODABankName__c = '99';
        a1.c2g__CODABankSWIFTNumber__c = '99';
        a1.c2g__CODABankStreet__c = '99';
        a1.c2g__CODABankAccountName__c = '99';
        a1.c2g__CODABankAccountNumber__c = '99';
        a1.c2g__CODABankStateProvince__c = '99';
        a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor Account').getRecordTypeId();

        insert a1;
        
        // CREATE TEST CONTACT ======================================================================
        Contact c = NI_TestClassData.createTestContact(1, a1.Id);
        c.FirstName = 'APEXTESTUSER';
        c.LastName = 'APEXTESTUSER';
        insert c;
        
        // CREATE TEST ACCOUNT TEAM MEMBER RECORD ===================================================
        AccountTeamMember tm = new AccountTeamMember();
        tm.AccountId = a1.Id;
        tm.UserId = UserInfo.getUserId();
        tm.TeamMemberRole = 'NI Collector';
        insert tm;

        // CREATE PRODUCT GROUP TEST RECORD =========================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

        // CREATE TEST PRODUCT PACKAGE RECORD =======================================================
        PSA_Product_Package__c testProductPackage = NI_TestClassData.createPSAProductPackage();
        testProductPackage.Name = 'TEST-TST-BK1';
        testProductPackage.Package_SKU__c = 'TEST-TST-BK1';
        testProductPackage.Description__c = 'TEST-TST-BK1';
		insert testProductPackage;        
    
        // CREATE TEST PRODUCT RECORDS ==============================================================
        List<Product2> lstProducts = new List<Product2>();
        
        Product2 testServiceProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK1', 'Services');  
        testServiceProduct.Family = 'Services';
        testServiceProduct.Revenue_Category__c = 'Services';
        testServiceProduct.Duration_Months__c = 12; 
        testServiceProduct.pse__IsServicesProduct__c = true;
        testServiceProduct.Product_Package__c = testProductPackage.Id;
        testServiceProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Deliverable') ? revTemplateMap.get('Activity - Deliverable') : null;
        lstProducts.add(testServiceProduct);        

        Product2 testSupportProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK3', 'Support');  
        testSupportProduct.Revenue_Category__c = 'Maintenance';
        testSupportProduct.Duration_Months__c = 12; 
        lstProducts.add(testSupportProduct); 

        Product2 testSubscriptionProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK4', 'Subscription');  
        testSubscriptionProduct.Revenue_Category__c = 'Software - Subscription';
        testSubscriptionProduct.Duration_Months__c = 12; 
        testSubscriptionProduct.Revenue_Recognition_Template__c = revTemplateMap.containsKey('Activity - Equal Split') ? revTemplateMap.get('Activity - Equal Split') : null;
        lstProducts.add(testSubscriptionProduct); 

        Product2 testSoftwareProduct = NI_TestClassData.createProduct2(1, pgp.Id, 'TEST-TST-BK5', 'Software');  
        testSoftwareProduct.Revenue_Category__c = 'Software - Perpetual';
        testSoftwareProduct.Override_Invoice_Terms__c = lstPaymentTerms[0].Id;
        lstProducts.add(testSoftwareProduct); 

        database.insert(lstProducts);

        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'TEST-TST-BK1'];
        
        // CREATE TEST PRODUCT PACKAGE LINES ====================================================
        List<PSA_Product_Package_Milestone__c> lstPackageLines = new List<PSA_Product_Package_Milestone__c>();
        
        PSA_Product_Package_Milestone__c pkgLine1 = new PSA_Product_Package_Milestone__c();
        pkgLine1.Milestone_Name_Prefix__c = 'test';
        pkgLine1.Percent__c = 50;
        pkgLine1.Milestone_Type__c = 'Billable Milestone';
        pkgLine1.Product_Package__c = testProductPackage.id;
        pkgLine1.Offset_Days__c = 10;
        pkgLine1.Product__c = p2.Id;
        lstPackageLines.add(pkgLine1);
        
        PSA_Product_Package_Milestone__c pkgLine2 = new PSA_Product_Package_Milestone__c();
        pkgLine2.Milestone_Name_Prefix__c = 'test';
        pkgLine2.Percent__c = 50;
        pkgLine2.Milestone_Type__c = 'Billable Milestone';
        pkgLine2.Product_Package__c = testProductPackage.id;
        pkgLine2.Offset_Days__c = 10;
        pkgLine2.Product__c = p2.Id;
        lstPackageLines.add(pkgLine2);        
        
        database.insert(lstPackageLines);

//        testDeploymentInstance = ffaTestUtilities.createTestasset(1, a1.id, testSubscriptionProduct.id, testProductGroup_Salesforce.id);

        
        // CREATE TEST PRICEBOOK ENTRY RECORDS
        Id pbkId = Test.getStandardPricebookId();  
        
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();

        PricebookEntry pbeServiceProduct = NI_TestClassData.createTestPricebookEntry(pbkId, testServiceProduct.Id, 1000);
        lstPBEs.add(pbeServiceProduct);   
        PricebookEntry pbeSupportProduct = NI_TestClassData.createTestPricebookEntry(pbkId, testSupportProduct.Id, 1000);
        lstPBEs.add(pbeSupportProduct);  
        PricebookEntry pbeSubsciptionProduct = NI_TestClassData.createTestPricebookEntry(pbkId, testSubscriptionProduct.Id, 1000);
        lstPBEs.add(pbeSubsciptionProduct);  
        PricebookEntry pbeSoftwareProduct = NI_TestClassData.createTestPricebookEntry(pbkId, testSoftwareProduct.Id, 1000);
        lstPBEs.add(pbeSoftwareProduct);  

		database.insert(lstPBEs);
        
		// CREATE TEST OPPORTUNITY ==============================================================
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a1.Id); 
        
        o.Name = 'createBillingContractController_Test OPPORTUNITY';
        o.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        o.StageName = 'Prospecting';
        o.Order_Status__c = 'Prospect';
        o.Amount = 25000;
        o.CloseDate = Date.Today().addDays(-1);
        o.Effective_Date__c = Date.Today().addDays(-1);
        o.Opportunity_Source__c = 'Support'; 
        o.Services_Payment_Terms__c = lstPaymentTerms[0].Id;
        o.Support_Payment_Terms__c = lstPaymentTerms[1].Id;
        o.Subscription_Payment_Terms__c = lstPaymentTerms[2].Id;
        // o.License_Program_Payment_Terms__c = null;
        // o.HRM_Subscription_Invoice_Terms__c = null;
        // o.Hosting_and_Support_Payment_Terms__c = null;
        // o.HRM_Service_Invoice_Terms__c = null;
        
        insert o; 
        
system.debug(' *^* o = ' + o);        
        
		// CREATE TEST OPPORTUNITY LINE ITEMS ==================================================
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
             
        // Services
        OpportunityLineItem oli1 = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, lstPBEs[0].Id, 2);
        oli1.Invoice_Terms__c = lstPaymentTerms[0].Id;  
        //oli1.Pro_Rata_Billing__c = true;
        //oli1.Pro_Rated_Date__c = Date.today();
        lstOLIs.add(oli1);
        // Support
        OpportunityLineItem oli2 = NI_TestClassData.createTestOpportunityLineItem(2, o.Id, lstPBEs[1].Id, 2);
        oli2.Invoice_Terms__c = lstPaymentTerms[1].Id;    
        //oli2.Pro_Rata_Billing__c = true;
        //oli2.Pro_Rated_Date__c = Date.today();
        lstOLIs.add(oli2);
        // Subscription
        OpportunityLineItem oli3 = NI_TestClassData.createTestOpportunityLineItem(3, o.Id, lstPBEs[2].Id, 2);
        oli3.Invoice_Terms__c = lstPaymentTerms[2].Id;       
        //oli3.Pro_Rata_Billing__c = true;
        //oli3.Pro_Rated_Date__c = Date.today();
        lstOLIs.add(oli3);
        // Software
        OpportunityLineItem oli4 = NI_TestClassData.createTestOpportunityLineItem(4, o.Id, lstPBEs[3].Id, 2);
        //oli4.Invoice_Terms__c = lstPaymentTerms[0].Id;   
        lstOLIs.add(oli4);
        
        database.insert(lstOLIs);
        

//        testAgreement = ffaTestUtilities.createTestAgreement(testOpp1,productList);        
        
		// CREATE OPPORTUNITY CONTACT ROLES =========================================================        
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // Bill To contact
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);        
        // SPONSOR CONTACT ROLE
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);
        
        Database.Insert(lstOppContcRole);          
        
        Test.stopTest(); 
        
        system.debug(' *** END createBillingContractController_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================   
    @isTest static void test1() 
    {    
        
        system.debug(' *^* START createBillingContractController_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'createBillingContractController_Test OPPORTUNITY'];
        
        Test.startTest();
        
        // TEST OPENING THE VF PAGE FROM OPPORTUNITY
        PageReference pr = Page.createBillingContract;
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id', o.Id);
        ApexPages.currentPage().getParameters().put('debug', '1');
        
        createBillingContractController ctrl = new createBillingContractController(); 

        ctrl.processLines();

        PageReference pr3 = ctrl.backToOpp(); 
        
        PageReference pr4 = ctrl.goToBC();
        
        Test.stopTest();
        
        system.debug(' *^* END createBillingContractController_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================   
    @isTest static void test2() 
    {    
        
        system.debug(' *^* START createBillingContractController_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'createBillingContractController_Test OPPORTUNITY'];
        
        // TURN OPPORTUNITY CLOSED WON / DEFINITE
        o.StageName = 'Closed Won';
        o.Order_Status__c = 'Definite';
        update o;    
        
        Test.startTest();
        
        PageReference pr = Page.createBillingContract;
        Test.setCurrentPage(pr);
        ApexPages.currentPage().getParameters().put('id', o.Id); 
        ApexPages.currentPage().getParameters().put('debug', '1');
        
        createBillingContractController ctrl = new createBillingContractController(); 

        // TEST CLICKING "Process Line(s)" BUTTON WITHOUT A BILLING CONTRACT
        ctrl.processLines();        
        
        system.debug(' *^* ApexPages.getMessages() = ' + ApexPages.getMessages());

        // TEST CLICKING "Create Billing Contract Header" BUTTON ON VF PAGE
        PageReference pgRef = ctrl.createBillingContract();        
        
        // VERIFY BILLING CONTRACT WAS CREATED AND LINKED TO OPPORTUNITY 
        Opportunity oppAssert1 = [SELECT Id, Opportunity_Number__c, Billing_Contract__c, Order_Status__c  
                                  FROM Opportunity 
                                  WHERE Name = 'createBillingContractController_Test OPPORTUNITY'];
        
        String strBCName = 'BC - ' + oppAssert1.Opportunity_Number__c; 
        
        Billing_Contract__c bcAssert1 = [SELECT Id, Name FROM Billing_Contract__c WHERE Name =: strBCName];
        
        // ASSERT THAT BILLING CONTRACT WAS UPDATED ON OPPORTUNITY 
        system.assertEquals(bcAssert1.Id, oppAssert1.Billing_Contract__c); 
        // ASSERT THAT ORDER STATUS WAS UPDATED ON OPPORTUNITY 
        system.assertEquals('Integrated', oppAssert1.Order_Status__c);                     
        
        List<selectOption> lstSOs = ctrl.getBC_Options(); 
        // ASSERT BILLING CONTRACT NAME IS IN BILLING CONTRACT PICKLIST
        system.assertEquals(strBCName, lstSOs[1].getLabel()); 
        
        ctrl.processLines();

        Test.stopTest();
        
        system.debug(' *^* END createBillingContractController_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
}