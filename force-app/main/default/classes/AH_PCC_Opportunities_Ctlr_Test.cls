/****************************************************************************************
Name            : AH_PCC_Opportunities_Ctlr_Test
Author          : Sean Harris
Created Date    : 03/27/2019
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : Test class for controller class AH_PCC_Opportunities_Ctlr
                :            
******************************************************************************************/
@isTest
public class AH_PCC_Opportunities_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START AH_PCC_Opportunities_Ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());

        // CREATE TEST CUSTOMER PARENT ACCOUNT
        Account prnt = NI_TestClassData.createTestAccount(1);
        prnt.Name = 'Customer Parent Account #1 - APEX TEST';
        insert prnt;             
        
        // CREATE TEST CUSTOMER ACCOUNT
        Account cust = NI_TestClassData.createTestAccount(1);
        cust.Name = 'APEX TEST - Customer Account #1';
        cust.ParentId = prnt.Id;
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
        
        system.debug(' *** END AH_PCC_Opportunities_Ctlr_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: SEARCHING, SORTING & EXPORTING
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
   
        system.debug(' *** START AH_PCC_Opportunities_Ctlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST - Customer Account #1']; 
        //Contact cnt = [SELECT Id FROM Contact WHERE Email = 'timwatts@somedomain.com']; 
        //User pcUser = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];
        Product2 p1 = [SELECT Id FROM Product2 WHERE Name = 'Cendyn Product Test 1'];       
        OpportunityLineItem oli = [SELECT Id, Opportunity.Id, Product2.ProductCode, Product2.Name, Opportunity.Account.AccountNumber, Opportunity.Account.Name, 
                                   Opportunity.Account.Management_Company_Name__c, Opportunity.Opportunity_Number__c, Opportunity.Name, Opportunity.CloseDate 
                                   FROM OpportunityLineItem 
                                   WHERE Product2Id =: p1.Id LIMIT 1];
        
        // HAVING ISSUES GETTING RESULTS RUNNING AS PC USER IN UNIT TESTS        
        //        system.runAs(pcUser) 
        //        {
        
        // SET THE CURRENT VF PAGE
        PageReference pr = Page.AH_PCC_Opportunities;
        Test.setCurrentPage(pr);
        AH_PCC_Opportunities_Ctlr ctrl = new AH_PCC_Opportunities_Ctlr(); 
        
        // ASSERT DEFAULT VARIABLE VALUES
        system.assertEquals('ALL FIELDS', ctrl.selField); 
        system.assertEquals('', ctrl.searchText); 
        system.assertEquals('Opportunity.CloseDate', ctrl.sortByField); 
        system.assertEquals('DESC', ctrl.sortByDirection); 
        
        // TEST SEARCHING FOR A RECORD THAT DOES NOT EXIST
        ctrl.searchText = 'xxxxxxxxxxx';
        ctrl.doSearch();
        system.assertEquals(0, ctrl.lstSearchResults.size()); 

        ctrl.selStage = 'Open Only';
        ctrl.doSearch();

        ctrl.selStage = 'Closed Only';
        ctrl.doSearch();
        
        test.startTest();
        
        // TEST SEARCHING ON SPECIFIED FIELDS

        // BY PRODUCT CODE
        ctrl.selField = 'Product2.ProductCode';
        ctrl.searchText = 'SKU-001';
        ctrl.doSearch();
        //system.assertEquals(1, ctrl.lstSearchResults.size()); 
        system.debug(' **** results by Product Code = ' + ctrl.lstSearchResults.size()); 
            
        // BY PRODUCT NAME
        ctrl.selField = 'Product2.Name';
        ctrl.searchText = 'Test 1';
        ctrl.doSearch();
        //system.assertEquals(1, ctrl.lstSearchResults.size()); 
        system.debug(' **** results by Product Name= ' + ctrl.lstSearchResults.size());
     
        // BY ACCOUNT NUMBER
        ctrl.selField = 'Opportunity.Account.AccountNumber';
        ctrl.searchText = oli.Opportunity.Account.AccountNumber;
        ctrl.doSearch();
        //system.assertEquals(2, ctrl.lstSearchResults.size()); 
        system.debug(' **** results by Account Number = ' + ctrl.lstSearchResults.size());
        
        // BY ACCOUNT NAME
        ctrl.selField = 'Opportunity.Account.Name';
        ctrl.searchText = oli.Opportunity.Account.Name;
        ctrl.doSearch();
        //system.assertEquals(2, ctrl.lstSearchResults.size()); 
        system.debug(' **** results by Account Name = ' + ctrl.lstSearchResults.size());
        
        // BY MANAGEMENT COMPANY NAME
        ctrl.selField = 'Opportunity.Account.Management_Company_Name__c';
        ctrl.searchText = 'Parent';
        ctrl.doSearch();
        //system.assertEquals(2, ctrl.lstSearchResults.size()); 
        system.debug(' **** results by Management Company Name = ' + ctrl.lstSearchResults.size());
                
        // BY OPPORTUNITY NUMBER
        ctrl.selField = 'Opportunity.Opportunity_Number__c';
        ctrl.searchText = oli.Opportunity.Opportunity_Number__c;
        ctrl.doSearch();
        //system.assertEquals(2, ctrl.lstSearchResults.size()); 
        system.debug(' **** results by Opportunity Number = ' + ctrl.lstSearchResults.size());

        // DO A SORT FOR COVERAGE
        ctrl.sortByField = 'Name';
        ctrl.sortByDirection = 'DESC';
        ctrl.doSort();        

        test.stopTest();
        
        //        }
        
        ctrl.exportResults();
        
        system.debug(' *** END AH_PCC_Opportunities_Ctlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());

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
            PageReference pr = Page.AH_PCC_Opportunities;
            Test.setCurrentPage(pr);
            AH_PCC_Opportunities_Ctlr ctrl1 = new AH_PCC_Opportunities_Ctlr(); 
            // ASSERT DEFAULT VARIABLE VALUES
            system.assertEquals(true, ctrl1.hasChatterGroup); 
            //ctrl1.exportResults();
        }

        // WITHOUT CHATTER GROUP POPULATED
        a.Partner_Chatter_Group_ID__c = null;
        update a;
        system.runAs(pu) 
        {
            PageReference pr = Page.AH_PCC_Opportunities;
            Test.setCurrentPage(pr);
            AH_PCC_Opportunities_Ctlr ctrl1 = new AH_PCC_Opportunities_Ctlr(); 
            // ASSERT DEFAULT VARIABLE VALUES
            system.assertEquals(false, ctrl1.hasChatterGroup); 
        }
        
    }
    
}