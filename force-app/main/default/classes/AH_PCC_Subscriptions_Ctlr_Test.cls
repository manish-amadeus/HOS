/****************************************************************************************
Name            : AH_PCC_Subscriptions_Ctlr_Test
Author          : Sean Harris
Created Date    : 03/27/2019
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : Test class for controller class AH_PCC_Subscriptions_Ctlr
                :            
******************************************************************************************/
@isTest
public class AH_PCC_Subscriptions_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START AH_PCC_Subscriptions_Ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());

        // CREATE TEST CUSTOMER ACCOUNT
        Account cust = NI_TestClassData.createTestAccount(1);
        cust.Name = 'APEX TEST - Customer Account #1';
        insert cust;        
        
        // CREATE TEST PARTNER ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Cendyn';
        a.Partner_Chatter_Group_ID__c = Label.PartnerCentral_Chatter_Group_Id_for_Test_Classes;
        insert a;

        // CREATE TEST PARTNER CONTACT
        Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
        cntct.FirstName = 'Timothy';
        cntct.LastName = 'Watts';
        cntct.Email = 'timwatts@somedomain.com';
        insert cntct;        
        
        // CREATE TEST PARTNER USER
        Profile pro = [SELECT Id, UserType FROM Profile WHERE Name = 'AH PartnerCentral User'];        
        system.assertEquals('PowerPartner', pro.UserType);
        
        User pu = NI_TestClassData.createTestUser(2, 'AH PartnerCentral User');
        pu.ContactId = cntct.Id;
        pu.Partner_Permissions__c = 'Cendyn';
        pu.Partner_Terms_Accepted__c = 'True';
        insert pu;
        
        // ASSERT THAT THE ACCOUNT GETS CHANGED TO A PARTNER AFTER CONTACT IS ENABLED AS A PARTNER USER
        Account accAssert = [SELECT Id, IsPartner FROM Account WHERE Id =: a.Id];
        system.assertEquals(true, accAssert.IsPartner);
        
        // CREATE TEST PARTNER OPPORTUNITY
        Opportunity opp = NI_TestClassData.createTestOpportunity(1, cust.Id); 
        opp.Name = 'APEX TEST - PartnerCentral Opportunity #1';
        opp.StageName = 'Validate and Select - 80%';
        insert opp;
                
        // CREATE TEST PARTNER OPPORTUNITY CONTACT ROLE RECORDS 
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // BILL TO
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // SHIP TO
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // CUSTOMER PROJECT CONTACT
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // DECISION MAKER
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);            
        // SPONSOR 
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(opp.Id, cntct.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);
        
        database.Insert(lstOppContcRole); 
        
        // SHARE TEST OPPORTUNITY RECORD TO PARTNER USER
        OpportunityShare osh = new OpportunityShare(OpportunityAccessLevel = 'Read', OpportunityId = opp.Id, RowCause = 'Manual', UserOrGroupId = pu.Id);
        insert osh;
        
        // ASSERT THAT THE PARTNER HAS ACCESS TO NEW OPPTY
        List<OpportunityShare> oppShareAssert = new List<OpportunityShare>
            ([SELECT OpportunityAccessLevel 
              FROM OpportunityShare
              WHERE UserOrGroupId =: pu.Id
              AND OpportunityId =: opp.Id]);
        system.assertEquals(false, oppShareAssert.isEmpty());
        
        // CREATE TEST DI INDEX
        NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'APEX TEST PARTNER');
        insert diIdx;
        
        // CREATE TEST PRODUCT GROUP
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn');
        pg.IsActive__c = true;
        pg.IsCoreProduct__c = true;        
        insert pg;
        
        // CREATE TEST PRODUCT RELATED TO PARTNER ACCOUNT
        Product2 p1 = NI_TestClassData.createProduct2(1, pg.Id, 'Cendyn-SKU-001', 'Cendyn');
        p1.Partner_Name__c = a.Id;
        p1.DI_Index__c = diIdx.Id;
        p1.Product_Line__c = 'Cendyn Test';
        p1.Revenue_Category__c = 'Subscription';
        p1.Corporate_Product_Group__c = 'Newmarket';
        p1.Unit__c = 'Subscription';
        p1.IsActive = true;
        p1.Description = 'APEX Test Class';
        p1.Family = 'Cendyn';
        p1.Name = 'Cendyn Product Test 1';
        p1.Revenue_Category__c = 'Subscription';        
        insert p1;
        
        // CREATE TEST PRODUCT -NOT- RELATED TO PARTNER ACCOUNT
        Product2 p2 = NI_TestClassData.createProduct2(1, pg.Id, 'Cendyn-SKU-002', 'Cendyn');
        // p2.Partner_Name__c = a.Id;
        p1.DI_Index__c = diIdx.Id;
        p2.Product_Line__c = 'Cendyn Test';
        p2.Revenue_Category__c = 'Subscription';
        p2.Corporate_Product_Group__c = 'Newmarket';
        p2.Unit__c = 'Subscription';
        p2.IsActive = true;
        p2.Description = 'APEX Test Class';
        p2.Family = 'Cendyn';
        p2.Name = 'Cendyn Product Test 2';
        p2.Revenue_Category__c = 'Subscription';        
        insert p2;        
        
        // CREATE 2 PRICEBOOKENTRIES
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p1.Id, 1000);        
        insert pbe1;
        PricebookEntry pbe2 = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), p2.Id, 1000);        
        insert pbe2;   

        // CREATE 4 TEST OPPORTUNITYLINEITEM RECORDS (2 SEARCHABLE, 2 HIDDEN)
        List<OpportunityLineItem> lstOpportunityLineItemInserts = new List<OpportunityLineItem>();
        
        for (integer j = 1; j < 3; j++)
        {
            OpportunityLineItem oli1 = new OpportunityLineItem();
            oli1 = NI_TestClassData.createTestOpportunityLineItem(j, opp.Id, pbe1.Id, 10);         
            lstOpportunityLineItemInserts.add(oli1);
        }
        
        for (integer j = 1; j < 3; j++)
        {
            OpportunityLineItem oli2 = new OpportunityLineItem();
            oli2 = NI_TestClassData.createTestOpportunityLineItem(j, opp.Id, pbe2.Id, 10);         
            lstOpportunityLineItemInserts.add(oli2);
        }      
        
        database.insert(lstOpportunityLineItemInserts); 
        
        // ASSERT 4 TEST OPPORTUNITYLINEITEM RECORDS WERE CREATED
        List<OpportunityLineItem> lstOpptyLineItemCheck = new List<OpportunityLineItem>([SELECT Id FROM OpportunityLineItem]);         
        system.assertEquals(4, lstOpptyLineItemCheck.size()); 
        
        // CLOSE THE OPPORTUNITY RECORD
//        opp.Order_Status__c = 'Integrated';
//        opp.StageName = 'Closed Won';
//        update opp;


        system.debug(' *** START StartTest() - AH_PCC_Subscriptions_Ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
        test.StartTest();   

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
        
        Payment_Terms__c payTrms = [SELECT Id FROM Payment_Terms__c WHERE Name = '4 Installments'];
        String oliId1 = [SELECT Id FROM OpportunityLineItem WHERE PricebookEntryId =: pbe1.Id LIMIT 1].Id;        
        String oliId2 = [SELECT Id FROM OpportunityLineItem WHERE PricebookEntryId =: pbe2.Id LIMIT 1].Id;
        
        // CREATE TEST BILLING CONTRACT
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = cust.Id;
		insert bc;

        // CREATE TEST ACTIVITY LINE ITEM RECORDS
		// 	VISIBLE TO PARTNER
        Activity_Line_Item__c ali1 = NI_TestClassData.createActivityLineItem(bc.Id); 
        ali1.Opportunity__c = opp.Id; 
        ali1.Opp_Product_ID__c = oliId1; 
        ali1.Product__c = p1.Id; 
		ali1.Payment_Terms__c = payTrms.Id; 
        ali1.Activation_Date__c = Date.today(); 
        ali1.Contract_Start_Date__c = Date.today(); 
        ali1.Contract_End_Date__c = Date.today().addMonths(12); 
        ali1.Activation_Required__c = true; 
        ali1.ffrrtemplate__c = tp.Id; 
        ali1.Contract_Amount__c = 1000; 
        ali1.Units__c = 1; 
        insert ali1; 
		// 	HIDDEN FROM PARTNER
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(bc.Id);
        ali2.Opportunity__c = opp.Id; 
        ali2.Opp_Product_ID__c = oliId2; 
        ali2.Product__c = p2.Id; 
		ali2.Payment_Terms__c = payTrms.Id; 
        ali2.Activation_Date__c = Date.today(); 
        ali2.Contract_Start_Date__c = Date.today(); 
        ali2.Contract_End_Date__c = Date.today().addMonths(12); 
        ali2.Activation_Required__c = true; 
        ali2.ffrrtemplate__c = tp.Id; 
        ali2.Contract_Amount__c = 1000; 
        ali2.Units__c = 1; 
        insert ali2;         
        
        // CREATE TEST SUBSCRIPTION ACTIVATION RECORDS
        List<Subscription_Activation__c> lstSAInserts = new List<Subscription_Activation__c>();
        // 	VISIBLE TO PARTNER
        Subscription_Activation__c sa1 = NI_TestClassData.createSubscriptionActivation();
        sa1.Partner_Name__c = a.Id;
        sa1.Activity_Line_Item__c = ali1.Id;
        sa1.Opportunity__c = opp.Id;
        sa1.Product_ID__c = oliId1;
        sa1.Account__c = cust.Id;
        sa1.Contracted_Quantity__c = 2;
        sa1.Product_Code__c = p1.ProductCode;
        sa1.Product_Name__c = p1.Name; 
        lstSAInserts.add(sa1); 
        // 	HIDDEN FROM PARTNER
        Subscription_Activation__c sa2 = NI_TestClassData.createSubscriptionActivation();
        // sa2.Partner_Name__c = a.Id;
        sa2.Activity_Line_Item__c = ali2.Id;
        sa2.Opportunity__c = opp.Id;
        sa2.Product_ID__c = oliId2;
        sa2.Account__c = cust.Id;
        sa2.Contracted_Quantity__c = 2;
        sa2.Product_Code__c = p2.ProductCode;
        sa2.Product_Name__c = p2.Name;         
        lstSAInserts.add(sa2);                 
            
        database.insert(lstSAInserts);
        
        system.debug(' *** END StartTest() - AH_PCC_Subscriptions_Ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
        test.StopTest(); 
        
        system.debug(' *** END AH_PCC_Subscriptions_Ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: SEARCHING, SORTING & EXPORTING
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
   
        system.debug(' *** START AH_PCC_Subscriptions_Ctlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'Cendyn'];
        //Contact cnt = [SELECT Id FROM Contact WHERE Email = 'timwatts@somedomain.com']; 
        //User pcUser = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];
        Subscription_Activation__c sa = [SELECT Id, Name, Account_Number_Formula__c, Account_Name_Formula__c, Opportunity_Number_Formula__c 
                                         FROM Subscription_Activation__c 
                                         WHERE Partner_Name__c =: a.Id];
        
        // HAVING ISSUES GETTING RESULTS RUNNING AS PC USER IN UNIT TESTS        
        //        system.runAs(pcUser) 
        //        {
        
        // SET THE CURRENT VF PAGE
        PageReference pr = Page.AH_PCC_Subscriptions;
        Test.setCurrentPage(pr);
        AH_PCC_Subscriptions_Ctlr ctrl = new AH_PCC_Subscriptions_Ctlr(); 
        
        // ASSERT DEFAULT VARIABLE VALUES
        system.assertEquals('ALL FIELDS', ctrl.selField); 
        system.assertEquals('', ctrl.searchText);  
        system.assertEquals(false, ctrl.displayDialog1); 
        system.assertEquals('CreatedDate', ctrl.sortByField); 
        system.assertEquals('ASC', ctrl.sortByDirection); 
        
        test.startTest();
        
        // TEST SEARCHING FOR A RECORD THAT DOES NOT EXIST
        ctrl.searchText = 'xxxxxxxxxxx';
        ctrl.doSearch();
        system.assertEquals(0, ctrl.lstSearchResults.size()); 
        
        // TEST SEARCHING ON SPECIFIED FIELDS
        // BY NAME
        ctrl.selField = 'Name';
        ctrl.searchText = sa.Name;
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size()); 
        //system.debug(' **** results by Name = ' + ctrl.lstSearchResults.size());
        // BY PRODUCT CODE
        ctrl.selField = 'Product_Code__c';
        ctrl.searchText = 'SKU-001';
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size()); 
        //system.debug(' **** results by Product Code = ' + ctrl.lstSearchResults.size()); 
        // BY PRODUCT NAME
        ctrl.selField = 'Product_Name__c';
        ctrl.searchText = 'Test 1';
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size()); 
        //system.debug(' **** results by Product Name= ' + ctrl.lstSearchResults.size());
        // BY ACCOUNT NUMBER
        ctrl.selField = 'Account_Number_Formula__c';
        ctrl.searchText = sa.Account_Number_Formula__c;
        ctrl.doSearch();
        system.assertEquals(2, ctrl.lstSearchResults.size()); 
        //system.debug(' **** results by Account Number = ' + ctrl.lstSearchResults.size());
        // BY ACCOUNT NAME
        ctrl.selField = 'Account_Name_Formula__c';
        ctrl.searchText = sa.Account_Name_Formula__c;
        ctrl.doSearch();
        system.assertEquals(2, ctrl.lstSearchResults.size()); 
        //system.debug(' **** results by Account Name = ' + ctrl.lstSearchResults.size());
        // BY OPPORTUNITY NUMBER
        ctrl.selField = 'Opportunity_Number_Formula__c';
        ctrl.searchText = sa.Opportunity_Number_Formula__c;
        ctrl.doSearch();
        system.assertEquals(2, ctrl.lstSearchResults.size()); 
        //system.debug(' **** results by Opportunity Number = ' + ctrl.lstSearchResults.size());

        // DO A SORT FOR COVERAGE
        ctrl.sortByField = 'Name';
        ctrl.sortByDirection = 'ASC';
        ctrl.doSort();        

        //        }
        
        test.stopTest();
        
        ctrl.exportResults();
        
        system.debug(' *** END AH_PCC_Subscriptions_Ctlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());

    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: ENTERING LIVE DATE
    // =======================================================================================================================================    
    @isTest static void test2() 
    {
   
        system.debug(' *** START AH_PCC_Subscriptions_Ctlr_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'Cendyn'];
        Subscription_Activation__c sa = [SELECT Id, Name, Account_Number_Formula__c, Account_Name_Formula__c, Opportunity_Number_Formula__c 
                                         FROM Subscription_Activation__c 
                                         WHERE Partner_Name__c =: a.Id];
        
        // HAVING ISSUES GETTING RESULTS RUNNING AS PC USER IN UNIT TESTS        
        //        system.runAs(pcUser) 
        //        {
        
        // SET THE CURRENT VF PAGE
        PageReference pr = Page.AH_PCC_Subscriptions;
        Test.setCurrentPage(pr);
        AH_PCC_Subscriptions_Ctlr ctrl = new AH_PCC_Subscriptions_Ctlr(); 
        
        // ASSERT DEFAULT VARIABLE VALUES
        system.assertEquals('ALL FIELDS', ctrl.selField); 
        system.assertEquals('', ctrl.searchText);  
        system.assertEquals(false, ctrl.displayDialog1); 
        system.assertEquals('CreatedDate', ctrl.sortByField); 
        system.assertEquals('ASC', ctrl.sortByDirection); 
        system.assertEquals('2 records found', ctrl.searchResultMsg); 
        system.assertEquals(false, ctrl.checkAll); 
        system.assertEquals(false, ctrl.showRedMsg); 
        
        // HAVING ISSUES GETTING RESULTS RUNNING AS PC USER IN UNIT TESTS        
        //        system.runAs(pcUser) 
        //        {
                
        system.assertEquals(2, ctrl.lstSearchResults.size()); 
        
        test.startTest();
        
        // TEST MASTER CHECKBOX
        // 	CHECK ALL
        ctrl.checkAll = true;
        ctrl.doChecks();
        for (AH_PCC_Subscriptions_Ctlr.searchResult sr1 : ctrl.lstSearchResults)
        {
            system.assertEquals(true, sr1.isChecked);
        } 
        
        // 	UNCHECK ALL
        ctrl.checkAll = false;
        ctrl.doChecks();
        for (AH_PCC_Subscriptions_Ctlr.searchResult sr2 : ctrl.lstSearchResults)
        {
            system.assertEquals(false, sr2.isChecked);
        }     
        
        // CHECK TOP ITEM THEN CLICK ENTER LIVE DATE BUTTON 
        ctrl.lstSearchResults[0].isChecked = true;
		ctrl.showDialog1();     

        system.assertEquals(1, ctrl.lstSelectedResults.size());
        
        ctrl.hideSuccess();
        
        // SUBMIT AND ASSERT ERRORS
        ctrl.lstSelectedResults[0].QuantityEntered = null;
        ctrl.submitDialog1(); 
        system.assertEquals('Quantity has to be greater than 0 and may not be blank. Please correct and resubmit.', ctrl.selectedMsg);
        system.assertEquals(true, ctrl.isQuantity);
        system.assertEquals(false, ctrl.isLiveDate);
        system.assertEquals(false, ctrl.isAccount);
        system.assertEquals(false, ctrl.lstSelectedResults[0].isValid);

        ctrl.lstSelectedResults[0].QuantityEntered = 1;   
        ctrl.lstSelectedResults[0].DateEntered = null;
        ctrl.submitDialog1(); 
        system.assertEquals('Live Date cannot be blank. Please correct and resubmit.', ctrl.selectedMsg);
        system.assertEquals(false, ctrl.isQuantity);
        system.assertEquals(true, ctrl.isLiveDate);
        system.assertEquals(false, ctrl.isAccount);
        system.assertEquals(false, ctrl.lstSelectedResults[0].isValid);        
        
        ctrl.lstSelectedResults[0].DateEntered = system.Date.today().format();
        ctrl.lstSelectedResults[0].AccountNameEntered = null;
        ctrl.submitDialog1(); 
        system.assertEquals('For Account cannot be blank. Please correct and resubmit.', ctrl.selectedMsg);
        system.assertEquals(false, ctrl.isQuantity);
        system.assertEquals(false, ctrl.isLiveDate);
        system.assertEquals(true, ctrl.isAccount);
        system.assertEquals(false, ctrl.lstSelectedResults[0].isValid);             
        
        ctrl.lstSelectedResults[0].AccountNameEntered = 'HOTEL SIX';
        ctrl.submitDialog1(); 
        system.assertEquals('Save was successful!', ctrl.toastMsg);
        system.assertEquals(true, ctrl.isSuccess);
        system.assertEquals(false, ctrl.displayDialog1); 
        
        // ASSERT TRANSACTION WAS CREATED
        List<Subscription_Activation_Transaction__c> lstSATs = new  List<Subscription_Activation_Transaction__c>(
            [SELECT Id FROM Subscription_Activation_Transaction__c]);
        system.assertEquals(1, lstSATs.size());        
        
        test.StopTest();
        
        //        }
               
        system.debug(' *** END AH_PCC_Subscriptions_Ctlr_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());

    }

    // =======================================================================================================================================
    // = TEST METHOD 3: DOWNLOAD ICON VISIBILITY TESTING
    // =======================================================================================================================================    
    @isTest static void test3() 
    {
        
        Account a = [SELECT Id, Name, Partner_Chatter_Group_ID__c, isPartner FROM Account WHERE Name = 'Cendyn'];
        User pu = [SELECT Id, FirstName, LastName, Email, AccountId, ContactId   
                   FROM User 
                   WHERE Partner_Permissions__c = 'Cendyn' 
                   AND Partner_Terms_Accepted__c = 'True' 
                   AND AccountId =: a.Id 
                   LIMIT 1];
       
        // WITH CHATTER GROUP POPULATED
        system.runAs(pu) 
        {
            PageReference pr = Page.AH_PCC_Subscriptions;
            Test.setCurrentPage(pr);
            AH_PCC_Subscriptions_Ctlr ctrl1 = new AH_PCC_Subscriptions_Ctlr(); 
            // ASSERT DEFAULT VARIABLE VALUES
            system.assertEquals(true, ctrl1.hasChatterGroup); 
            //ctrl1.exportResults();
        }

        // WITHOUT CHATTER GROUP POPULATED
        a.Partner_Chatter_Group_ID__c = null;
        update a;
        system.runAs(pu) 
        {
            PageReference pr = Page.AH_PCC_Subscriptions;
            Test.setCurrentPage(pr);
            AH_PCC_Subscriptions_Ctlr ctrl1 = new AH_PCC_Subscriptions_Ctlr(); 
            // ASSERT DEFAULT VARIABLE VALUES
            system.assertEquals(false, ctrl1.hasChatterGroup); 
        }
        
    }
    
}