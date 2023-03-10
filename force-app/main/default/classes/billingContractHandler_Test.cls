/****************************************************************************************
Name            : billingContractHandler_Test
Author          : Shashikant Nikam
Created Date    : 03/18/2019
Last Mod Date   : 09/08/2018 
Last Mod By     : Sean Harris
Description     : Test class for billingContractHandler
                : 
				: 
******************************************************************************************/
@isTest
public class billingContractHandler_Test 
{

    public static c2g__codaCompany__c testCompany1;
    static Opportunity testOpp1;
    static Product2 testSupportProduct; 

    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        testCompany1 = ffaTestUtilities.createFFACompany('TEST COMPANY 123', true, 'USD');
        c2g__codaCompany__c company = [select id, name, Legal_Entity_Name__c FROM c2g__codaCompany__c];
        
        // CREATE TEST USER
        List<User> lstUserInsert = new List<User>();
        User u = NI_TestClassData.createTestUser(1, 'NI Finance'); 
        u.Alias = 'FIN01TST'; 
        insert u;         
        
        c2g__codaAccountingCurrency__c curr = [select id, name from c2g__codaAccountingCurrency__c];
        system.debug('curr name : '+curr.name);
        
        Remittance_Info__c rem = NI_TestClassData.createRemittanceInfo('Rem Info 1');
        rem.FFA_Currency__c = curr.id;
        insert rem;
        
        system.runAs(u) 
        {
            company.Remittance_Info__c = rem.id;
            update company;
        }
        
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id accRTId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX billingContractRenewalHandler TEST';
        a.RecordTypeId = accRTId;
        a.Brand__c = 'Apex';
        insert a;
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE TEST OPPORTUNITY
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        // CREATE TEST PAYMENT TERMS
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        
        Payment_Terms__c pt2 = NI_TestClassData.createInvoicePaymentTerms();
        pt2.Name = 'Percent Installments';
        pt2.Invoice_Split_Method__c = 'Percent Breakdown';
        pt2.Billed_through_PSA__c = true;
        insert pt2; 

        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX billingContractRenewalHandler OPPORTUNITY';
        o.Amadeus_Legal_Entity__c = '';
        o.RecordTypeId = opptyRecTypeId;
        o.License_Program_Payment_Terms__c = pt.id;
        o.Services_Payment_Terms__c = pt.id;
        o.Subscription_Payment_Terms__c = pt.id;
        o.Hosting_and_Support_Payment_Terms__c = pt.id;
        insert o;       

        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS ==================================================================================
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
        // Sponsor Contact 
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(o.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);           
        
        insert lstOppContcRole;
        
system.debug(' *^* queries before Test.startTest() : '+Limits.getQueries());  
        
Test.startTest();
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        // CREATE TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');     
        insert diIdx1; 
        
        NI_DeploymentInstanceIndex__c diIdx10 = NI_TestClassData.createDI_Index(10, 'APEX TEST');     
        insert diIdx10; 

        PSA_Product_Package__c pkg = NI_TestClassData.createPSAProductPackage();
        insert pkg;

        // CREATE TEST PRODUCT RECORDS
        List<Product2> lstProds = new List<Product2>();
        
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');
        prd01.DI_Index__c = diIdx1.Id;
        prd01.Apttus_Config2__HasOptions__c = false;
        prd01.Duration_Months__c = 12;
        prd01.Revenue_Category__c = 'Services';
        lstProds.add(prd01);  
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Support');
        prd02.DI_Index__c = diIdx1.Id;
        prd02.Apttus_Config2__HasOptions__c = false;
        prd02.License_Type__c = 'Limited'; 
        prd02.Duration_Months__c = 12;
        lstProds.add(prd02);  
        
        Product2 prd03 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-03', 'Hosting');
        prd03.DI_Index__c = diIdx1.Id;
        prd03.Apttus_Config2__HasOptions__c = false;
        prd03.License_Type__c = 'Full';
        prd03.Unit__c = 'User';
        prd03.Duration_Months__c = 12;
        lstProds.add(prd03);
        
        Product2 p2_10 = NI_TestClassData.createProduct2(10, pgp.Id, 'ZZZ-HRM-001', 'Subscription'); 
        p2_10.DI_Index__c = diIdx10.Id;
        p2_10.DI_DefaultStatus__c = 'Purchased';
        p2_10.Revenue_Category__c = 'Software - Subscription';
        p2_10.Apttus_Config2__HasOptions__c = false;
        p2_10.Duration_Months__c = 12;
        p2_10.Product_Package__c = pkg.id;
        lstProds.add(p2_10);      
        
        Database.Insert(lstProds);
          
        // PRODUCT PACKAGE MILESTONE
        PSA_Product_Package_Milestone__c pkgMilestone = new PSA_Product_Package_Milestone__c();
        pkgMilestone.Product_Package__c = pkg.id;
        pkgMilestone.Product__c = p2_10.id;
        pkgMilestone.Percent__c = 5;
        pkgMilestone.Offset_Days__c = 40;
        pkgMilestone.Milestone_Name_Prefix__c = 'Test Milestone_Name_Prefix';
        pkgMilestone.Milestone_Type__c = 'Billable Milestone';
        insert pkgMilestone;
        
        VSOE_Pricing_Item__c vsoe = new VSOE_Pricing_Item__c();
        vsoe.Customer_Account__c = a.id;
        vsoe.Product__c = p2_10.id;
        insert vsoe;
        
        // CREATE TEST CUSTOM SETTINGS DATA FOR NI_ZZZ_HRM_Product__c ============================================================================================
        List<NI_ZZZ_HRM_Product__c> lstCustomSettings = new List<NI_ZZZ_HRM_Product__c>();        
        lstCustomSettings.Add(new NI_ZZZ_HRM_Product__c(Name='ZZZ-HRM-001', Product2Id__c = p2_10.Id, DI_DefaultStatus__c ='Purchased'));
        
        Database.Insert(lstCustomSettings);      
        
        // GET DISTINCT LIST OF FAMILIES
        Map<String, Product2> mapFamilies = new Map<String, Product2>();
        
        for (Product2 prd : [SELECT Family FROM Product2 WHERE IsActive = true AND Family != null])
        {
            if (!mapFamilies.containsKey(prd.Family))
            {
                mapFamilies.put(prd.Family, prd);
            }
        }
        
        // CREATE TEST ROLLUP AMOUNT CUSTOM SETTINGS
        List<NI_OpportunityCalculatedAmount__c> lstCustSets = NI_OpportunityCalculatedAmount__c.getAll().values();
        
        Set<String> setCustSetRecTypes = new Set<String>();
        
        for (NI_OpportunityCalculatedAmount__c lCS : lstCustSets)
        {
            setCustSetRecTypes.add(lCS.Opportunity_Record_Type_Name__c);                
        }
        
        List<NI_OpportunityCalculatedAmount__c> lstCS = new List<NI_OpportunityCalculatedAmount__c>();
        Integer iRecTypeCount = 0;
        
        // POPULATE CUSTOM SETTINGS
        for (Schema.RecordTypeInfo rt : OpportunityRecordTypeInfo.values())
        {
            if (!setCustSetRecTypes.contains(rt.getName())) // IF RECORD TYPE DOESN'T EXIST CREATE THE TEST DATA
            {
                iRecTypeCount++;             
                if ((rt.getName() == 'Large Deal Opportunity') || (rt.getName() == 'HRM New Org Opportunity') || (rt.getName() == 'Sales Order')) 
                {
                    for (Product2 f : mapFamilies.values()) 
                    {                       
                        NI_OpportunityCalculatedAmount__c cs = new NI_OpportunityCalculatedAmount__c();
                        String strFamily = f.Family; 
                        if (rt.getName().length() > 20)
                        {
                            cs.Name = rt.getName().Substring(0, 20) + ' : ' + strFamily;  // DID THIS TO AVOID EXCEEDING CHAR LENGTH
                        }   
                        else
                        {
                            cs.Name = rt.getName() + ' : ' + strFamily;
                        }
                        cs.Opportunity_Record_Type_Name__c = rt.getName();
                        cs.Product_Family__c = strFamily;
                        cs.Multiplier__c = 1;
                        if (rt.getName() == 'Large Deal Opportunity')
                        {
                            
                            if (strFamily == 'Hosting') 
                            {
                                cs.Multiplier__c = 0.5;
                            }
                            if (strFamily == 'Support') 
                            {
                                cs.Multiplier__c = 0;
                            }                         
                        }           
                        lstCS.Add(cs);
                    }
                }
            } 
        }
        
        if (lstCS.size() > 0)
        {
            Database.insert(lstCS);
        }  

        // CREATE PRICEBOOK TEST RECORD
        Id pbkId = Test.getStandardPricebookId(); 
        
        // CREATE PRICEBOOKENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        PricebookEntry pbe01 = NI_TestClassData.createTestPricebookEntry(pbkId, prd01.Id, 1000);
        lstPBEs.add(pbe01);    
        PricebookEntry pbe02 = NI_TestClassData.createTestPricebookEntry(pbkId, prd02.Id, 1000);
        lstPBEs.add(pbe02);   
        PricebookEntry pbe03 = NI_TestClassData.createTestPricebookEntry(pbkId, prd03.Id, 1000);
        lstPBEs.add(pbe03);    
        PricebookEntry pbe10 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_10.Id, 1000);
        lstPBEs.add(pbe10);  
        Database.Insert(lstPBEs);

        // CREATE OPPORTUNITY LINE ITEMS
        
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();        
        
        OpportunityLineItem oli10 = NI_TestClassData.createTestOpportunityLineItem(10, o.Id, pbe10.Id, 1);
        oli10.Order_of_Delivery__c = 4;
        oli10.Invoice_Terms__c = pt.id;
        oli10.Pro_Rated_Date__c	= Date.today();
        oli10.Pro_Rata_Billing__c = true;
        lstOLIs.add(oli10);
        
        Database.insert(lstOLIs); 
        
        // ASSERTION
        List<OpportunityLineItem> oliAssert = [SELECT Id, Name  
                                               FROM OpportunityLineItem
                                               WHERE OpportunityId =: o.Id
                                               AND Product2.Duration_Months__c != null
                                               AND Order_of_Delivery__c != null];
        system.debug('oliAssert : '+oliAssert);
        system.assertEquals(1, oliAssert.size());
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Status = 'Purchased';
        di.Product_Group__c = pgp.Id; 
        di.Build_Number__c = '56';
        insert di;      
        
        // CREATE SETTINGS RECORD (MANAGED)
        ffrr__Settings__c st = NI_TestClassData.createSettings();
        st.Name = 'APEX Activity Line Item';
        insert st;
        
        // CREATE TEMPLATE RECORD (MANAGED)
        ffrr__Template__c tp = NI_TestClassData.createffrrTemplate(st.Id);
        tp.Name = 'APEX TEST - Deliverable';
        insert tp; 

        // CREATE TEST PAYMENT TERM LINE ITEMS
        List<Payment_Term_Line_Item__c> lstPTLineItem = new List<Payment_Term_Line_Item__c>();
        
        Payment_Term_Line_Item__c ptLI1 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI1.Order__c = 1;
        ptLI1.Offset_Measure__c = 'Days';
        ptLI1.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI1);
        
        Payment_Term_Line_Item__c ptLI2 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI2.Order__c = 2;
        ptLI2.Offset_Measure__c = 'Months';
        ptLI2.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI2);
        
        Payment_Term_Line_Item__c ptLI3 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI3.Order__c = 3;
        ptLI3.Offset_Measure__c = 'Years';
        ptLI3.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI3);
        
        Payment_Term_Line_Item__c ptLI4 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt2.Id);
        ptLI4.Order__c = 4;
        ptLI4.Offset_Measure__c = 'Days';
        lstPTLineItem.add(ptLI4);
        
        database.insert(lstPTLineItem); 
        
        
        Apttus_Config2__PriceList__c priceList1 = new Apttus_Config2__PriceList__c();
        priceList1.Name = '2019';
        insert priceList1;
        
        Apttus_Config2__PriceList__c prlist1 = [select id, name from Apttus_Config2__PriceList__c];
        system.debug('prlist1 : '+prlist1);
        
        
        // ATTACH APPTUS AGREEMENTS TO OPPORTUNITY
        List<Apttus__APTS_Agreement__c> aggrList = new List<Apttus__APTS_Agreement__c>();
        //Apttus__APTS_Agreement__c aggr1 = NI_TestClassData.createTestApttusAgreement(1, a.Id, opp1.id, pbkId);
        Apttus__APTS_Agreement__c aggr1 = new Apttus__APTS_Agreement__c();
        aggr1.Name = 'Apttus Agreement Test 1'; 
        aggr1.Apttus__Account__c = a.Id;
        aggr1.Apttus__Related_Opportunity__c = o.Id;
        aggr1.APTS_Legal_Entity__c = 'Amadeus Hospitality Americas, Inc.';
        aggr1.CurrencyIsoCode = 'USD';
        aggr1.Apttus_CMConfig__PriceListId__c	= priceList1.id;
        aggrList.add(aggr1);
        
        insert aggrList;
        
        // ASSERT THAT PROCESS BUILDER CALLED "Update Legal Entity on Opportunity" WORKED 
//        Opportunity oAsrts = [SELECT Id, Amadeus_Legal_Entity__c FROM Opportunity WHERE Name = 'APEX billingContractRenewalHandler OPPORTUNITY'];
//        system.assertEquals(oAsrts.Amadeus_Legal_Entity__c, aggr1.APTS_Legal_Entity__c);        
        
        
system.debug(' *^* queries 1 : '+Limits.getQueries());
        
        // CREATE BILLING CONTRACT
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;        
        insert bc;
        
system.debug(' *^* queries 2 : '+Limits.getQueries());
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Billing_Contract__c = bc.Id;
        ali.Account__c = a.Id;
        ali.Billing_Renewal_Lead_Time_Days__c = 30;
        ali.Renewal_Base_Price__c = 1000;
        ali.Activation_Date__c = Date.today();
        ali.Contract_Start_Date__c = Date.today().addMonths(1);
        ali.Contract_End_Date__c = Date.today().addMonths(2);
        ali.Product__c = p2_10.Id;
        ali.Payment_Terms__c = pt.Id;
        ali.Opp_Product_ID__c = p2_10.Id;
        ali.Activation_Required__c = true;
        ali.ffrrtemplate__c = tp.Id;
        ali.ACTION_Rebuild_Billing_Lines__c = true;
        ali.Pro_Rated__c = false;
        ali.Revenue_Category__c = 'Support';
        ali.Auto_Renewal__c = true;
        ali.Contract_Amount__c = 1000; 
        ali.Units__c = 1;
        ali.Deployment_Instance__c = di.Id; 
        insert ali;   
        
Test.stopTest();     
        
system.debug(' *^* queries 3 : '+Limits.getQueries());
        
        List<Activity_Line_Item__c> aliAssert = new List<Activity_Line_Item__c>([SELECT Id, Contract_Start_Date__c, Contract_End_Date__c, 
                                                                                 Contract_Total_Amount__c FROM Activity_Line_Item__c 
                                                                                 WHERE Account__c =: a.Id]);        
        system.assertEquals(1, aliAssert.size());
        system.assertEquals(1000, aliAssert[0].Contract_Total_Amount__c);
        

    
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Asset di = [SELECT Id FROM Asset WHERE Build_Number__c = '56'];
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];    
        Account a = [SELECT Id, OwnerId, Brand__c FROM Account WHERE Name = 'APEX billingContractRenewalHandler TEST'];
        Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Account__c =: a.Id];  
        Activity_Line_Item__c ali = [SELECT Id, Units__c, Contract_Start_Date__c, Contract_End_Date__c FROM Activity_Line_Item__c WHERE Billing_Contract__c =: bc.Id];        
        
        Test.startTest();
        
        Billing_Contract_Line_Item__c bcli1 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        bcli1.Split_Order__c = 1;
        bcli1.Status__c = 'Active';
        bcli1.Pro_Rated__c = true;   
        bcli1.Invoiced__c = true;        
        insert bcli1; 
        
        Billing_Contract_Line_Item__c bcli = [SELECT Id, Line_Item_Description__c, Revenue_Category__c 
                                              FROM Billing_Contract_Line_Item__c 
                                              WHERE Split_Order__c = 1 
                                              AND Status__c = 'Active' 
                                              AND Pro_Rated__c = true];
        
        List<NI_Cancellation__c> lstCancellationInserts = new List<NI_Cancellation__c>();
        
        NI_Cancellation__c cxl1 = NI_TestClassData.createCancellation(a.Id);
        cxl1.Deployment_Instance__c = di.Id;
        cxl1.Effective_Date__c = Date.today() - 1;
        cxl1.Status__c = 'New';
        cxl1.General_Reason__c = 'Affiliation Change';
        cxl1.Activity_Line_Item__c = ali.Id;
        cxl1.Invoice_Number__c = 'APEX TEST CANCELLATION #1';
        cxl1.Product2__c = p2.Id;
        cxl1.Account_Owner__c = a.OwnerId;
        cxl1.Brand__c = a.Brand__c;
        cxl1.Cancellation_Notes__c = 'APEX TEST';
        cxl1.Product2__c = p2.Id;
        cxl1.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl1.Renewal_Cancellation_Quantity__c = 1; 
        cxl1.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl1.General_Reason__c = 'Affiliation Change';
        cxl1.Specific_User_Names__c = 'User1,User2';
        cxl1.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl1.Renewal_Cancellation_Requested__c = true;
        cxl1.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl1.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl1.Late_Cancellation__c = false;
        cxl1.Retention_Completed__c = false; 
        lstCancellationInserts.add(cxl1);
        database.insert(lstCancellationInserts);       
        
//        billingContractHandler.processCancellation(lstCancellationInserts);
//        billingContractHandler.processUserReduction(lstCancellationInserts);
        
        List<Activity_Line_Item__c> lstALIs = new List<Activity_Line_Item__c>([SELECT Id, Units__c FROM Activity_Line_Item__c]);
        billingContractHandler.returnActivityLineList(lstALIs);
        
        Date d1 = Date.today().addMonths(-1);
        Date d2 = Date.today().addMonths(12);
        Date d3 = Date.today().addMonths(1);
        
        Billing_Contract_Line_Item__c bcli2 = billingContractHandler.proRateInvoiceAmount_Billing(bcli, d1, d2, d3, 1000, ali);
        
        Test.stopTest();
    }
    
  	// ======================================================================================================================================= 
    // = TEST METHOD 2: WITHOUT SETTING OPPORTUNITY TO CLOSED WON, CREATE THE BILLING CONTRACT & SHOULD GET ERROR MESSAGE
    // ======================================================================================================================================= 
    @isTest static void test2()
    {
        
        Test.startTest();
        
        Opportunity testOpp1 = [SELECT Id, Name FROM Opportunity WHERE Name = 'APEX billingContractRenewalHandler OPPORTUNITY'];
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        system.debug('cntrlr.loadError : ' + cntrlr.loadError);
        if (cntrlr.loadError == false)
        {
            cntrlr.processLines(); 
        }
        
        List<Apexpages.Message>  msgList = ApexPages.getMessages();
        system.debug('msgList : '+msgList);
        
        String str = msgList[0].getDetail();
        str = str.toLowerCase();
        
        system.assertEquals(true, str.contains('the opportunity is not closed won'), 'Apex message not matching..');
        
        Test.stopTest();
    }

  	// ======================================================================================================================================= 
    // = TEST METHOD 3: METHOD TO TEST goToBC FUNCTION FROM createBillingContractController CLASS 
    // =======================================================================================================================================     
    @isTest static void test3()
    {
        
        Opportunity testOpp1 = [SELECT ID, NAME, AccountId, StageName, Order_Status__c FROM OPPORTUNITY 
                                WHERE NAME = 'APEX billingContractRenewalHandler OPPORTUNITY'];
        
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        
        // CLOSE THE OPPORTUNITY
        testOpp1.StageName = 'Closed Won';
        testOpp1.Order_Status__c = 'Integrated';
        update testOpp1;
        
        Test.startTest();
        
        Product2 pd2Lic = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-001'];
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        system.debug('cntrlr.loadError : '+cntrlr.loadError);
        
        PageReference pg2 = cntrlr.goToBC();
        
        Test.stopTest();
        
    }
    
  	// ======================================================================================================================================= 
    // = TEST METHOD 4: TEST TO CHECK IF BILLING CONTRACT IS CREATED SUCCESSFULLY
    // ======================================================================================================================================= 
    @isTest static void test4()
    {
        
        Opportunity testOpp1 = [SELECT ID, NAME, AccountId, StageName, Order_Status__c FROM OPPORTUNITY 
                                WHERE NAME = 'APEX billingContractRenewalHandler OPPORTUNITY'];
        
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        
        // CLOSE THE OPPORTUNITY
        testOpp1.StageName = 'Closed Won';
        testOpp1.Order_Status__c = 'Integrated';
        update testOpp1;
        
        Test.startTest();
        
        Product2 pd2Lic = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-001'];
        system.debug('pd2Lic.Id  :' + pd2Lic.Id );
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        system.debug('cntrlr.loadError : '+cntrlr.loadError);
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.id;
            cntrlr.processLines();
        }
        
        List<Apexpages.Message>  msgList = ApexPages.getMessages();
        
        system.assertEquals('Save Successful!', msgList[0].getDetail(), 'Message should be Save Successful!');
        
        Billing_Contract__c testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        PageReference testPgRef = cntrlr.backToOpp();
        
        Account testAccount1 = [select id, name from Account WHERE Name = 'APEX billingContractRenewalHandler TEST'];
        
        system.debug('testAccount1.Id   :' + testAccount1.Id );
        
        Contact c2 = NI_TestClassData.createTestContact(2, testAccount1.id);
        insert c2;
        
        testBillingContract1.Attn_to_Contact__c = c2.id;
        update testBillingContract1;
        
        system.debug('pd2Lic.Id  :' + pd2Lic.Id );
        List<OpportunityLineItem> oliAssert = [SELECT Id, Opportunity.AccountId, Product2Id  
                                               FROM OpportunityLineItem
                                               WHERE OpportunityId =: testOpp1.Id 
                                               AND Product2ID =: pd2Lic.Id ];

        Set<Id> accountidset = new Set<Id>();
        accountidset.add(testAccount1.id);
        system.debug('accountidset  :' + accountidset );
        
        Set<Id> productidset = new Set<Id>();
        productidset.add(pd2Lic.id);
        system.debug('productidset  :' + productidset );   
        Test.stopTest();
        Map<String, Asset> dimap = billingContractHandler.fetchDeploymentInstance(accountidset, productidset);
        system.debug('dimap : '+dimap);
        
        system.assertEquals(1, dimap.size(), 'dimap should not be null.');
        
        Id tmpId = billingContractHandler.applyDeploymentInstance(dimap, oliAssert[0]);
        
        system.debug('tmpId : '+tmpId);
        system.assertNotEquals(NULL, tmpId, 'tmpId should not be null.');
        
        delete testBillingContract1;
        
        
              
    }
    
  	// ======================================================================================================================================= 
    // = TEST METHOD 5: TEST METHOD FOR resetOppLinesWS METHOD OF
    // =======================================================================================================================================  
    @isTest static void test5()
    {
        
        Opportunity testOpp1 = [SELECT ID, NAME, AccountId, StageName, Order_Status__c FROM OPPORTUNITY 
                                WHERE NAME = 'APEX billingContractRenewalHandler OPPORTUNITY'];
        
        billingContractLineWrapper testWrapper = new billingContractLineWrapper();
        testWrapper.billingContractLineWrapper();
        
        // CLOSE THE OPPORTUNITY
        testOpp1.StageName = 'Closed Won';
        testOpp1.Order_Status__c = 'Integrated';
        update testOpp1;
        
        Test.startTest();
        
        Product2 pd2Lic = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-001'];
        
        ApexPages.currentPage().getParameters().put('id', testOpp1.id);
        createBillingContractController cntrlr = new createBillingContractController();
        PageReference pg = cntrlr.createBillingContract();
        
        system.debug('cntrlr.loadError : '+cntrlr.loadError);
        
        if (cntrlr.loadError == false)
        {
            cntrlr.billingContractId = cntrlr.bc.id;
            cntrlr.processLines();
        }
        
        Billing_Contract__c testBillingContract1 = cntrlr.bc;
        List<SelectOption> optionList = cntrlr.getBC_Options();
        
        String msg = billingContractHandler.resetOppLinesWS(testOpp1.id);
        
        system.assertEquals('SUCCESS', msg, 'Not returning SUCCESS message..');
        
        Test.stopTest();
        
    }
    
  	// ======================================================================================================================================= 
    // = TEST METHOD 6: test manage Activity Lines Controller 
    // =======================================================================================================================================  
    @isTest static void test6()
    {
        
        system.debug('Queries start : '+Limits.getQueries());
        
        testOpp1 = [SELECT ID, NAME, AccountId, StageName, Order_Status__c FROM OPPORTUNITY WHERE NAME = 'APEX billingContractRenewalHandler OPPORTUNITY'];
        
        system.debug('testOpp1 : '+testOpp1);
        system.debug('testSupportProduct : '+testSupportProduct);
        
        // CLOSE OPPORTUNITY
        testOpp1.StageName = 'Closed Won';
        testOpp1.Order_Status__c = 'Integrated';
        update testOpp1;
        
        Test.startTest();
        
        testSupportProduct = [SELECT Id, DI_DefaultStatus__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-001'];
        
        system.debug('queries end 1 : '+Limits.getQueries());
        
        Billing_Contract__c testBillingContract1 = [select ID, name from  Billing_Contract__c where Name =: 'Test Billing Contract 1' ];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingContract1);
        manageActivityLinesController aliController = new manageActivityLinesController(stdController);
        aliController.loadLineItems();
        
        for (manageActivityLinesController.activityLineModel line : aliController.activitylineItems)
        {
            line.check = true;
        }
        PageReference pg3 = aliController.proRateLines();
        
        system.debug('queries end 2 : '+Limits.getQueries());
        
        aliController.addRow();
        PageReference pg1 = aliController.saveLines();
        
        for (manageActivityLinesController.activityLineModel line : aliController.activitylineItems)
        {
            line.ali_object.Pro_Rated__c = true;
        }
          
        pg3 = aliController.proRateLines();
        
        Test.stopTest();
        
        for (manageActivityLinesController.activityLineModel line : aliController.activitylineItems)
        {
            line.ali_object.Contract_End_Date__c = null;
        }
        pg3 = aliController.proRateLines();
        
        aliController.deleteSelected();
        PageReference pg2 = aliController.backToBC();
        
    }
        
}