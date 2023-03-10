/****************************************************************************************
Name            : AH_ActivityLineItem_TriggerHandler_Test
Author          : Sean Harris
Created Date    : 08/13/2018
Last Mod Date   : 04/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for AH_ActivityLineItem_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest 
private class AH_ActivityLineItem_TriggerHandler_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START AH_ActivityLineItem_TriggerHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());  
        
        Test.startTest();
        
        // CREATE TEST ACCOUNTS
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();  
        
        Id rtParentAccountId = AccountRecordTypeInfo.get('Parent Account').getRecordTypeId();
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();    
        
        List<Account> lstAccountInsert = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'APEX TEST PARENT ACCOUNT 1';
        a1.RecordTypeId = rtParentAccountId;
        lstAccountInsert.Add(a1);
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a2.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a2);
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'APEX TEST PROPERTY ACCOUNT 2';
        a3.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a3);        
        
        Database.insert(lstAccountInsert); 
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name LIKE 'APEX TEST %']);
        system.assertEquals(3, lstAccountAsserts.Size());
        
        
        // CREATE TEST PRODUCT RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;        
        
        Product2 p2 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription'); 
        p2.Product_Line__c = 'Delphi Single Property';
        p2.Revenue_Category__c = 'Services';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.Description = 'APEX Test Class';
        p2.Name = 'Embrace';
        p2.Duration_Months__c = 12;
        p2.Line__c = 'Delphi';
        p2.Edition__c = 'Enterprise';
        p2.Classification__c = 'TEST DATA';
        p2.Support_Classification__c = 'Gold';
        p2.Interface_Classification__c = 'PMS';
        p2.Corporate_Product_Group__c = 'Newmarket';        
        insert p2;        

        // CREATE SETTINGS RECORD (MANAGED)
        ffrr__Settings__c st = NI_TestClassData.createSettings();
        st.Name = 'APEX Activity Line Item';
        insert st;
        
        // CREATE TEMPLATE RECORD (MANAGED)
        ffrr__Template__c tp = NI_TestClassData.createffrrTemplate(st.Id);
        tp.Name = 'APEX TEST - Deliverable';
        insert tp; 
        
        // CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        
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
        
        Payment_Term_Line_Item__c ptLI4 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI3.Order__c = 4;
        lstPTLineItem.add(ptLI4);
        
        database.insert(lstPTLineItem); 

        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE TO USE AS THE RUNAS USER
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        u.FirstName = 'Ari';
        u.LastName = 'Yolas';
        insert u;    
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TESTER ACCOUNT'; 
        insert a;
        system.debug('a.id : '+a.id);
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Lou';
        c.LastName = 'Sass';        
        insert c; 

        // INSERT A TEST RECORD INTO THE HRM_AppsDI_Insert_Products__c CUSTOM SETTING  
        List<HRM_AppsDI_Insert_Products__c> lstHRMApps = new List<HRM_AppsDI_Insert_Products__c>(); 
        
        HRM_AppsDI_Insert_Products__c csHRM1 = new HRM_AppsDI_Insert_Products__c();
        csHRM1.Name = 'APEX-TEST-01';
        lstHRMApps.add(csHRM1);
        HRM_AppsDI_Insert_Products__c csHRM2 = new HRM_AppsDI_Insert_Products__c();
        csHRM2.Name = 'APEX-TEST-02';
        lstHRMApps.add(csHRM2);
        HRM_AppsDI_Insert_Products__c csHRM3 = new HRM_AppsDI_Insert_Products__c();
        csHRM3.Name = 'APEX-TEST-03';
        lstHRMApps.add(csHRM3);
        HRM_AppsDI_Insert_Products__c csHRM4 = new HRM_AppsDI_Insert_Products__c();
        csHRM4.Name = 'APEX-TEST-04';
        lstHRMApps.add(csHRM4);
        
        Database.Insert(lstHRMApps);    
        
        
        // CREATE TEST DI INDEX RECORDS
        List<NI_DeploymentInstanceIndex__c> lstDI_Indx = new List<NI_DeploymentInstanceIndex__c>();
        
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        lstDI_Indx.add(diIdx1);
        NI_DeploymentInstanceIndex__c diIdx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST');
        lstDI_Indx.add(diIdx2);
        NI_DeploymentInstanceIndex__c diIdx3 = NI_TestClassData.createDI_Index(3, 'APEX TEST');
        lstDI_Indx.add(diIdx3);
        NI_DeploymentInstanceIndex__c diIdx4 = NI_TestClassData.createDI_Index(4, 'APEX TEST');
        lstDI_Indx.add(diIdx4);
        NI_DeploymentInstanceIndex__c diIdx10 = NI_TestClassData.createDI_Index(10, 'APEX TEST');
        lstDI_Indx.add(diIdx10);
        
        Database.Insert(lstDI_Indx); 
        
        // CREATE TEST PRODUCT RECORDS 
        List<Product2> lstProds = new List<Product2>();
        
        Product2 p2_1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-011', 'Support');
        p2_1.DI_Index__c = diIdx1.Id;
        p2_1.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_1);
        
        Product2 p2_2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-021', 'Subscription');
        p2_2.DI_Index__c = diIdx2.Id;
        p2_2.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_2);
        
        Product2 p2_3 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-031', 'Software');
        p2_3.DI_Index__c = diIdx3.Id;
        p2_3.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_3);
        
        Product2 p2_4 = NI_TestClassData.createProduct2(4, pgp.Id, 'APEX-TEST-041', 'Services');
        p2_4.DI_Index__c = diIdx4.Id;
        p2_4.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_4);
        
        Product2 p2_10 = NI_TestClassData.createProduct2(10, pgp.Id, 'ZZZ-HRM-0011', 'Subscription'); 
        p2_10.DI_Index__c = diIdx10.Id;
        p2_10.DI_DefaultStatus__c = 'Purchased';
        p2_10.Apttus_Config2__HasOptions__c = false;
        lstProds.add(p2_10);   
        
        Database.Insert(lstProds); 
        
        Set<String> prIdSet = new Set<String>();
        
        List<Product2> pr_list = [select ID, Name from Product2]; // where Id in: prIdSet];
        system.debug('pr_list : '+pr_list);
        
        system.debug('p2_1.Id : '+p2_1.Id);
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, p2_1.Id);
        asset1.Status = 'Purchased';
        asset1.Product_Group__c = pgp.Id; 
        asset1.Build_Number__c = '55';
        insert asset1; 
        
        // CREATE TEST CUSTOM SETTINGS DATA FOR NI_ZZZ_HRM_Product__c 
        List<NI_ZZZ_HRM_Product__c> lstCustomSettings = new List<NI_ZZZ_HRM_Product__c>();        
        lstCustomSettings.Add(new NI_ZZZ_HRM_Product__c(Name='ZZZ-HRM-0011', Product2Id__c = p2_10.Id, DI_DefaultStatus__c ='Purchased'));
        
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

        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName(); 
        Id rtSmallDealId = OpportunityRecordTypeInfo.get('Small Deal Opportunity').getRecordTypeId(); 

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
        
        
        // CREATE TEST PRICEBOOK ENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(pbkId, p2_1.Id, 1000);
        lstPBEs.add(pbe1); 
        
        Database.Insert(lstPBEs);   
        
        // CREATE TEST OPPORTUNITY RECORDS
        List<Opportunity> lstOpptys = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id);
        //opp1.StageName = 'Closed Won';
        opp1.RecordTypeId = rtSmallDealId;
        opp1.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1';
        lstOpptys.add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.RecordTypeId = rtSmallDealId;   
        opp2.Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 2';
        lstOpptys.add(opp2);
        
        Database.Insert(lstOpptys);
        
        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS 
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // Bill To contact
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // Ship To contact
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // Customer Project Contact 
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // Decision Maker Contact 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);  
        // Sponsor Contact 
        OpportunityContactRole ocr20 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr20);           
        
        Database.Insert(lstOppContcRole); 
        
        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS  
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        // Support Product
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe1.Id, 1);
        lstOLIs.add(oli01);
        
        // Support Product
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp2.Id, pbe1.Id, 1);
        lstOLIs.add(oli02);
        
        Database.Insert(lstOLIs);
        
        // CREATE TEST NI DI REFERENCE RECORDS
        List<NI_DI_Reference__c> lstDiRefToInsert = new List<NI_DI_Reference__c>();
        
        NI_DI_Reference__c nidi1 = NI_TestClassData.createTestNI_DI_Reference(1, pgp.Id, p2_1.Id);
        nidi1.HRM_Apps_Value__c = 'Delphi.fdc TEST';
        nidi1.Deployment_Instance_Name__c = 'Delphi.fdc TEST';  
        nidi1.Active__c = true;
        lstDiRefToInsert.add(nidi1);
        
        NI_DI_Reference__c nidi2 = NI_TestClassData.createTestNI_DI_Reference(2, pgp.Id, p2_2.Id);
        nidi2.HRM_Apps_Value__c = 'Guest & Social Relations TEST';
        nidi2.Deployment_Instance_Name__c = 'Guest & Social Relations TEST'; 
        nidi2.Active__c = true;
        lstDiRefToInsert.add(nidi2);
        
        NI_DI_Reference__c nidi3 = NI_TestClassData.createTestNI_DI_Reference(3, pgp.Id, p2_3.Id);
        nidi3.HRM_Apps_Value__c = 'Loyalty Management TEST';
        nidi3.Deployment_Instance_Name__c = 'Loyalty Management TEST';  
        nidi3.Active__c = true;
        lstDiRefToInsert.add(nidi3);
        
        NI_DI_Reference__c nidi4 = NI_TestClassData.createTestNI_DI_Reference(4, pgp.Id, p2_4.Id);
        nidi4.HRM_Apps_Value__c = 'Multi-Channel Marketing TEST';
        nidi4.Deployment_Instance_Name__c = 'Multi-Channel Marketing TEST'; 
        nidi4.Active__c = false;
        lstDiRefToInsert.add(nidi4);        
        
        Database.insert(lstDiRefToInsert); 

        // CREATE BILLING CONTRACT LIST TO STORE MAIN AND RELATED ACCOUNTS BILLING CONTRACT RECORDS.
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(10);
        bc.Account__c = a.Id;
        bc.Opportunity__c = opp1.Id;
        insert bc;
                
        Test.stopTest();

        system.debug(' ***  END  AH_ActivityLineItem_TriggerHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());  
        
    }
       
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        system.debug(' *** START AH_ActivityLineItem_TriggerHandler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());   

Test.startTest();
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEST']; 
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];         
        ffrr__Template__c tp = [SELECT Id FROM ffrr__Template__c WHERE Name = 'APEX TEST - Deliverable'];
        Payment_Terms__c pt = [SELECT Id FROM Payment_Terms__c WHERE Name = '4 Installments'];
        //Payment_Term_Line_Item__c ptLI1 = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Days']; 
        //Payment_Term_Line_Item__c ptLI2 = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Months']; 
        //Payment_Term_Line_Item__c ptLI3 = [SELECT Id FROM Payment_Term_Line_Item__c WHERE Offset_Measure__c = 'Years']; 
        List<Payment_Term_Line_Item__c> lstPTLIs = new List<Payment_Term_Line_Item__c>([SELECT Id 
                                                                                        FROM Payment_Term_Line_Item__c 
                                                                                        WHERE Offset_Measure__c IN ('Days', 'Months', 'Years') 
                                                                                        ORDER BY Offset_Measure__c ASC]); 
        Asset di = [SELECT Id FROM Asset WHERE Build_Number__c = '55'];
        
        // GET RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        // CREATE TEST OPPORTUNITY RECORD
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX TEST OPPORTUNITY 1';
        o.RecordTypeId = opptyRecTypeId;
        insert o;

        // CREATE TEST OPPORTUNITY LINE ITEM RECORD
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000);
        insert pbe;
        
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, pbe.Id, 1);
        insert oli;

//        Test.startTest();
        
        // CREATE TEST BILLING CONTRACT RECORD
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
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
        ali.Deployment_Instance__c = di.Id; 
        insert ali;
        
Test.stopTest();
        
        List<Billing_Contract_Line_Item__c> lstBCLIs = new List<Billing_Contract_Line_Item__c>();
        Billing_Contract_Line_Item__c blci1 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci1.Split_Order__c = 1;
        blci1.Status__c = 'Active';
        blci1.Pro_Rated__c = true;
        lstBCLIs.add(blci1);
        
        Billing_Contract_Line_Item__c blci2 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci2.Split_Order__c = 1;
        blci2.Status__c = 'Active';
        blci2.Activation_Required__c = true;
        blci2.Payment_Term_Line_Item__c = lstPTLIs[0].Id; // ptLI1.Id;
        blci2.Pro_Rated__c = false;
        blci2.Revenue_Category__c = 'Support';
        lstBCLIs.add(blci2);
        
        Billing_Contract_Line_Item__c blci3 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci3.Split_Order__c = 1;
        blci3.Status__c = 'Active';
        blci3.Activation_Required__c = true;
        blci3.Payment_Term_Line_Item__c = lstPTLIs[1].Id; // ptLI2.Id;
        blci3.Pro_Rated__c = false;
        blci3.Revenue_Category__c = 'Hosting and Support';
        lstBCLIs.add(blci3);
        
        Billing_Contract_Line_Item__c blci4 = NI_TestClassData.createBillingContract(bc.Id, ali.Id);
        blci4.Split_Order__c = 1;
        blci4.Status__c = 'Active';
        blci4.Activation_Required__c = true;
        blci4.Payment_Term_Line_Item__c = lstPTLIs[2].Id; // ptLI3.Id;
        blci4.Pro_Rated__c = false;
        blci4.Revenue_Category__c = 'Subscription'; 
        lstBCLIs.add(blci4);
         
        database.insert(lstBCLIs);

        ali.Activation_Required__c = true;
        ali.Activation_Date__c = Date.today().addDays(35);     
        update ali;
        
        ali.ACTION_Rebuild_Billing_Lines__c = true;
        update ali;

        ali.Status__c = 'Cancelled';
        update ali;

        delete ali;
        
        List<Revenue_Schedule__c> lstRevSchedAssert = new List<Revenue_Schedule__c>([SELECT Id FROM Revenue_Schedule__c]);
        system.debug(' **** lstRevSchedAssert.size() = ' + lstRevSchedAssert.size());      
        
        system.debug(' ***  END  AH_ActivityLineItem_TriggerHandler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());   
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void test2()
    {
        
        system.debug(' *** START AH_ActivityLineItem_TriggerHandler_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());   
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Asset di = [SELECT Id FROM Asset WHERE Build_Number__c = '55'];
        
        Test.startTest();
        
        // CREATE A TEST BILLING RECORD
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(2233);
        blgCnrct.Account__c = a.Id;
        insert blgCnrct;         
        
        Renewal_Pricebook__c pb = new Renewal_Pricebook__c();
        pb.Name = 'Test Price Book';
        insert pb;
        
        Renewal_Pricing_Entry__c rpe = new Renewal_Pricing_Entry__c();
        rpe.Start_Date__c = Date.today().addDays(-100);
        rpe.End_Date__c = Date.today().addDays(100);
        rpe.Renewal_Pricebook__c = pb.Id;
        rpe.Percent_Increase__c = 10;
        insert rpe;
        
        // CREATE A TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI.Cancel_Line_Item__c = false; 
        actLI.Contract_Start_Date__c = Date.today().addMonths(1);
        actLI.Contract_End_Date__c = Date.today().addMonths(2);
        actLI.Renewal_Date__c = Date.today().addDays(5);
        actLI.Units__c = 1; 
        actLI.Status__c = 'Active';
        actLI.Contract_Amount__c = 1000;
        actLI.Renewal_Base_Price__c = 500;
        actLI.Auto_Renewal__c = true;
        actLI.Renewal_Processed__c = false;
        actLI.Renewal_Pricebook__c = pb.Id;
        actLI.Revenue_Category__c = 'Subscription';
        actLI.Pro_Rated__c = false;
        actLI.Deployment_Instance__c = di.Id;        
        insert actLI;      
 
        Test.stopTest();
        
        system.debug(' ***  END  AH_ActivityLineItem_TriggerHandler_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());   
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 3: 
    // ======================================================================================================================================= 
    @isTest static void test3()
    {
        
        system.debug(' *** START AH_ActivityLineItem_TriggerHandler_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());   
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        Opportunity opp1 = [SELECT Id, StageName, Order_Status__c FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-011' AND Family = 'Support']; 
        Account a2 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        
        Test.startTest();

        // INSERT AH_RELATED_ACCOUNT AND RELATED_OPPORTUNITY_LINEITEM.
        AH_Opportunity_Related_Account__c  AH_Opp_Relacc = new AH_Opportunity_Related_Account__c ();
        AH_Opp_Relacc.Account__c= a2.ID;
        AH_Opp_Relacc.Opportunity__c= opp1.Id;
        insert AH_Opp_Relacc;
        
        AH_Account_Product__c  Related_Opp_Lineitem = new AH_Account_Product__c ();
        Related_Opp_Lineitem.Account__c= a2.ID;
        Related_Opp_Lineitem.Opportunity__c= opp1.Id;
        Related_Opp_Lineitem.Product__c= p2.id;
        Related_Opp_Lineitem.Quantity__c= 10 ;
        insert Related_Opp_Lineitem;
        
        // SET OPPORTUNITY TO CLOSED WON & INTEGRATED
        opp1.StageName = 'Closed Won';
        opp1.Order_Status__c = 'Integrated';
        update opp1;        
 
        List<Billing_Contract__c> bli_list = [SELECT Id, Name FROM Billing_Contract__c WHERE Opportunity__c =: opp1.Id];
        
        Set<Id> aliSet = new Set<Id>(); 
        
        // CREATE NEW ACTIVITY LINE ITEMS
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        Activity_Line_Item__c  Actli = NI_TestClassData.createActivityLineItem(bli_list[0].Id);
        Actli.Account__c = a.Id;
        Actli.Product__c = p2.Id;
        Actli.Opportunity__c = opp1.Id;
        aliList.add(Actli);
        
        Activity_Line_Item__c Actli2 = NI_TestClassData.createActivityLineItem(bli_list[0].Id);
        Actli2.Account__c = a.ID;
        Actli2.Product__c = p2.Id;
        Actli2.Opportunity__c = opp1.Id;
        aliList.add(Actli2);
        
        insert aliList;
        aliSet.add(Actli.Id);
        aliSet.add(Actli2.Id);
        
        Actli2.Auto_Renewal__c = true;
        update Actli2;
        Test.stopTest();
        
        List<DI_to_Activity_Line_Item__c> All_DItoALI = new List<DI_to_Activity_Line_Item__c>(
            [SELECT Id, Activity_Line_Item__c, Deployment_Instance__c 
             FROM DI_to_Activity_Line_Item__c 
             WHERE Activity_Line_Item__c IN : aliSet]);
        
        system.debug(' **** All_DItoALI : ' + All_DItoALI);
        system.debug(' All_DItoALI.size    +'   + All_DItoALI.size() );
        system.assertEquals(4, All_DItoALI.size(), 'Error in count of DI_to_Activity_Line_Item__c records..');
        
        //Test.stopTest();
        
        system.debug(' ***  END  AH_ActivityLineItem_TriggerHandler_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());   
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 4: TEST REBUILDING OF REVENUE SCHEDULES
    // ======================================================================================================================================= 
    @isTest static void test4()
    {
        
        system.debug(' *** START AH_ActivityLineItem_TriggerHandler_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());   
        
        Date dt = Date.today();
        Date dtTmp = Date.today();
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST - SMALL DEAL OPPORTUNITY 1'];
        //OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId =: o.Id];
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'ZZZ-HRM-0011']; 
        Payment_Terms__c pt = [SELECT Id FROM Payment_Terms__c WHERE Name = '4 Installments' AND Invoice_Split_Method__c = 'Equal'];
        ffrr__Template__c tp = [SELECT Id FROM ffrr__Template__c WHERE Name = 'APEX TEST - Deliverable'];
        
        
        
        // CREATE TEST BILLING CONTRACT RECORD
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(10101);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);

        ali.ffrrtemplate__c = tp.Id;
        ali.Payment_Terms__c = pt.Id; 
        ali.Opportunity__c = o.Id;
        ali.Product__c = p2.Id;
        ali.Opp_Product_ID__c = p2.Id;         
        
        ali.Contract_Start_Date__c = dt;
        dtTmp = dt.addYears(1);
        ali.Contract_End_Date__c = dtTmp.addDays(1); 
        ali.Activation_Date__c = dt.addDays(1);
        
        ali.Contract_Amount__c = 1000; 
        ali.Units__c = 1;
        //ali.Activation_Required__c = true;
        ali.Delivery_Offset_Months__c = 12;
        
system.debug(' *%* test (before insert) Contract_Start_Date__c = ' + ali.Contract_Start_Date__c + ', Contract_End_Date__c = ' + ali.Contract_End_Date__c  + ', Activation_Date__c = ' + ali.Activation_Date__c); 
Test.startTest();
        insert ali; 
Test.stopTest();        
        Activity_Line_Item__c ali2 = [SELECT Id, Contract_Start_Date__c, Contract_End_Date__c, Activation_Date__c FROM Activity_Line_Item__c WHERE Id =: ali.Id];
        
system.debug(' *%* test (after insert) Contract_Start_Date__c = ' + ali2.Contract_Start_Date__c + ', Contract_End_Date__c = ' + ali2.Contract_End_Date__c  + ', Activation_Date__c = ' + ali2.Activation_Date__c); 
                
        ali2.Contract_Start_Date__c = dt.addMonths(1);
        dtTmp = dt.addMonths(13);
        ali2.Contract_End_Date__c = dtTmp.addDays(1); 
        ali2.Activation_Date__c = dt.addMonths(1); 

system.debug(' *%* test (before update) Contract_Start_Date__c = ' + ali2.Contract_Start_Date__c + ', Contract_End_Date__c = ' + ali2.Contract_End_Date__c  + ', Activation_Date__c = ' + ali2.Activation_Date__c); 
        
        update ali2;
        
        Activity_Line_Item__c ali3 = [SELECT Id, Contract_Start_Date__c, Contract_End_Date__c, Activation_Date__c FROM Activity_Line_Item__c WHERE Id =: ali2.Id];
        
system.debug(' *%* test (after update) Contract_Start_Date__c = ' + ali3.Contract_Start_Date__c + ', Contract_End_Date__c = ' + ali3.Contract_End_Date__c  + ', Activation_Date__c = ' + ali3.Activation_Date__c); 
        
        
       
        system.debug(' ***  END  AH_ActivityLineItem_TriggerHandler_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());   
        
    }    
    
}