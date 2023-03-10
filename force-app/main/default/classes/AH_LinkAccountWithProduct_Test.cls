/****************************************************************************************
Name            : AH_LinkAccountWithProduct_Test
Author          : Ria Chawla
Created Date    : 04/30/2018
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_LinkAccountWithProduct_Ext
				: Updated per NICC-039872
				: 
******************************************************************************************/
@isTest
public class AH_LinkAccountWithProduct_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START AH_LinkAccountWithProduct_Test.createTestData()'); 
        
        
        // GET STANDARD PRICEBOOK ID
        Id pbkId = Test.getStandardPricebookId();   
        
        
        test.startTest();    
        
        
        // CREATE TEST PRODUCT FAMILY UNIT CUSTOM SETTINGS ========================================================================
        List<AH_Products_Family_Unit__c> lstCS = new List<AH_Products_Family_Unit__c>();
        
        AH_Products_Family_Unit__c cs1 = new AH_Products_Family_Unit__c();
        cs1.Name = 'Subscription';
        lstCS.add(cs1);
        
        AH_Products_Family_Unit__c cs2 = new AH_Products_Family_Unit__c();
        cs2.Name = 'Support';
        cs2.Product_Unit__c = 'User';
        lstCS.add(cs2);
        
        database.insert(lstCS);        
        
        // CREATE TEST ACCOUNT RECORD =============================================================================================
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_LinkAccountWithProduct_Test ACCOUNT';
        a.Legal_Entity_Name__c = 'Legal Account Entity';
        insert a;
        
        // CREATE TEST CONTACT RECORD =============================================================================================
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE TEST PRODUCT GROUP RECORD =======================================================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'AH_LinkAccountWithProduct_Test');
        insert pgp;
        
        // CREATE TEST DI INDEX RECORDS ===========================================================================================
        List<NI_DeploymentInstanceIndex__c> lstDI_Indx = new List<NI_DeploymentInstanceIndex__c>();
        
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        lstDI_Indx.add(diIdx1);
        NI_DeploymentInstanceIndex__c diIdx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST');
        lstDI_Indx.add(diIdx2);
        
        Database.Insert(lstDI_Indx); 
        
        // CREATE TEST PRODUCT RECORDS ============================================================================================
        List<Product2> lstProds = new List<Product2>();
        
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');
        prd01.DI_Index__c = diIdx1.Id;
        prd01.Apttus_Config2__HasOptions__c = false;
        prd01.License_Type__c = 'Full';
        //prd01.DI_DefaultStatus__c = 'Installed';
        lstProds.add(prd01);  
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Subscription');
        prd02.DI_Index__c = diIdx2.Id;
        prd02.Apttus_Config2__HasOptions__c = false;
        prd02.License_Type__c = 'Limited';  
        //prd02.DI_DefaultStatus__c = 'Installed';
        lstProds.add(prd02);
        
        Product2 prd03 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-03', 'Subscription');
        prd03.Apttus_Config2__HasOptions__c = false;
        prd03.License_Type__c = 'Full';      
        lstProds.add(prd03);
        
        Database.Insert(lstProds);
        
        // CREATE TEST PRICEBOOKENTRY RECORDS =======================================================================================
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        // SUBSCRIPTION RECORD
        PricebookEntry pbe01 = NI_TestClassData.createTestPricebookEntry(pbkId, prd01.Id, 1000);
        lstPBEs.add(pbe01);
        // SUPPORT RECORD
        PricebookEntry pbe02 = NI_TestClassData.createTestPricebookEntry(pbkId, prd02.Id, 1000);
        lstPBEs.add(pbe02);  
        // HOSTING RECORD
        PricebookEntry pbe03 = NI_TestClassData.createTestPricebookEntry(pbkId, prd03.Id, 1000);
        lstPBEs.add(pbe03);   
        
        Database.Insert(lstPBEs);
        
        // CREATE TEST OPPORTUNITY RECORDS ==========================================================================================
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity';
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Large Deal Opportunity').getRecordTypeId();
        lstOppInserts.add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.Name = 'AH_LinkAccountWithProduct_Test - HRM New Org Opportunity';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        lstOppInserts.add(opp2);
        
        Database.Insert(lstOppInserts);
        
        // CREATE OPPORTUNITY LINE ITEMS ============================================================================================
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        // SUBSCRIPTION RECORD
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe01.Id, 1);
        lstOLIs.add(oli01);
        // SUPPORT RECORD
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp1.Id, pbe02.Id, 1);
        lstOLIs.add(oli02);        
        // HOSTING RECORD
        OpportunityLineItem oli03 = NI_TestClassData.createTestOpportunityLineItem(3, opp1.Id, pbe03.Id, 1);
        lstOLIs.add(oli03);    
        // SUBSCRIPTION RECORD
        OpportunityLineItem oli04 = NI_TestClassData.createTestOpportunityLineItem(4, opp2.Id, pbe01.Id, 1000);
        lstOLIs.add(oli04);
        // SUPPORT RECORD
        OpportunityLineItem oli05 = NI_TestClassData.createTestOpportunityLineItem(5, opp2.Id, pbe02.Id, 1000);
        lstOLIs.add(oli05);        
        // HOSTING RECORD
        OpportunityLineItem oli06 = NI_TestClassData.createTestOpportunityLineItem(6, opp2.Id, pbe03.Id, 1000);
        lstOLIs.add(oli06);      
        
        Database.insert(lstOLIs); 
        
        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS =============================================================================
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
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);  
        
        
        
        // Bill To contact
        OpportunityContactRole ocr21 = NI_TestClassData.createTestOpportunityContactRole(opp2.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr21);
        // Ship To contact
        OpportunityContactRole ocr22 = NI_TestClassData.createTestOpportunityContactRole(opp2.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr22);         
        // Customer Project Contact 
        OpportunityContactRole ocr23 = NI_TestClassData.createTestOpportunityContactRole(opp2.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr23);        
        // Decision Maker Contact 
        OpportunityContactRole ocr24 = NI_TestClassData.createTestOpportunityContactRole(opp2.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr24);   
        // Sponsor Contact 
        OpportunityContactRole ocr25 = NI_TestClassData.createTestOpportunityContactRole(opp2.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr25); 
        
        Database.Insert(lstOppContcRole); 
        
        system.debug(' *** AH_LinkAccountWithProduct_Test.createTestData() - QUERIES ISSUED IN STARTTEST = ' + Limits.getQueries());   
        
        test.stopTest();         
        
        system.debug(' *** END AH_LinkAccountWithProduct_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());         
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST AFTER INSERT AND AFTER UPDATE
    // =======================================================================================================================================    
    @isTest static void linkAccountWithProduct1() 
    {    
        
        system.debug(' *** START AH_LinkAccountWithProduct_Test.linkAccountWithProduct1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TEST RECORDS        
        Opportunity o = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];
        OpportunityLineItem oli = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId =: o.Id LIMIT 1]; 
        
        
        Test.startTest();
        
        
        // CREATE TEST OPPORTUNITY RELATED ACCOUNT =====================================================
        AH_Opportunity_Related_Account__c oppRelatedAcc = new AH_Opportunity_Related_Account__c();
        oppRelatedAcc.Opportunity__c = o.Id;
        oppRelatedAcc.Account__c = o.AccountId;
        insert oppRelatedAcc;
        
        // CREATE TEST RELATED OPPORTUNITY LINE ITEM ===================================================
        List<AH_Account_Product__c> lstAccountProducts = new List<AH_Account_Product__c>();
        
        AH_Account_Product__c accPrd1 = new AH_Account_Product__c();
        accPrd1.Account__c = o.AccountId;
        accPrd1.Product__c = oli.Product2Id;
        accPrd1.Quantity__c = 1;
        accPrd1.Opportunity__c = o.Id;
        lstAccountProducts.add(accPrd1);
        
        Database.insert(lstAccountProducts);
        
        // CREATE OPPORTUNITY LIST
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        
        // CREATE CONTROLLERS FOR VF PAGE TESTING
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(o);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(oppList);
        
        // INSTANTIATE VISUALFORCE PAGE
        PageReference PageRef = Page.AH_LinkAccountWithProduct;
        Test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('id', o.Id);     
        // TEST FOR retURL PARSE OF ID
        ApexPages.currentPage().getParameters().put('retURL', '/' + o.Id + '%3FsrPos%3D0%26srKp%3D006');
        
        AH_LinkAccountWithProduct_Ext ctrl = new AH_LinkAccountWithProduct_Ext(stdSetCtrl);
        
        system.assertEquals(String.valueOf(o.Id).substring(0, 15), ctrl.retURL.substringAfter('/').substring(0, 15));
        system.assertEquals(o.Id, ctrl.opportunityId);
        
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
            wrapObj.prodQuan = 1.0;
        }
        
        // TODO: CYBAGE TO ADD UNIT TESTING FOR THE FOLLOWING
        ctrl.calculateAvailableQuantity();
        ctrl.doSave();
        ctrl.doRefresh();
        ctrl.returnBack();
        ctrl.refreshPage();
        ctrl.refreshProducts();
        ctrl.next();
        ctrl.previous();
        ctrl.getHasNext();   
        ctrl.getHasPrevious();        
        
        test.stopTest();         
        
        system.debug(' *** END AH_LinkAccountWithProduct_Test.linkAccountWithProduct1() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: ADDED ON 02/07/2019 by Bhulshwar. Rewritten 06/13/2019 - sharris
    // =======================================================================================================================================    
    @isTest static void linkAccountWithProduct2() 
    {
        
        system.debug(' *** START AH_LinkAccountWithProduct_Test.linkAccountWithProduct2() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Id rtSalesOrderId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId(); 
        
        // GET TEST RECORDS        
        Opportunity o = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];  
        OpportunityLineItem oli = [SELECT Id, Product2Id, Opportunity_Stage__c, DeploymentInstance__c FROM OpportunityLineItem WHERE OpportunityId =: o.Id LIMIT 1]; 
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_LinkAccountWithProduct_Test ACCOUNT'];    
        
        // CREATE TEST BILLING CONTRACT RECORD ===============================================================
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD =============================================================
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Account__c = a.Id;
        ali.Product__c = oli.Product2Id;
        ali.Opportunity__c = o.Id;
        insert ali;
        
        // WHEN OPPORTUNITY STAGE WILL GET CLOSE WON AND STATUS WOULD BE INTEGRATED.
        o.StageName = 'Closed Won';
        o.Order_Status__c = 'Integrated';
        update o;        
        
        o.RecordTypeId = rtSalesOrderId;
        update o;
        
        // ASSERT ROLLUPS HAVE ACCURATE VALUES (AFTER OPPORTUNITY RECORD TYPE CHANGES)
        Opportunity oppAssert1 = [SELECT Id, StageName, RecordTypeId, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];  
        system.assertEquals(oppAssert1.StageName, 'Closed Won');
        system.assertEquals(oppAssert1.Order_Status__c, 'Integrated');
        system.assertEquals(rtSalesOrderId, oppAssert1.RecordTypeId);
        
        // CREATE TEST ACCOUNT =========================================================================
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'Sync Test Account';        
        a2.Legal_Entity_Name__c = 'Legal Sync Entity';
        Database.insert(a2);          
        
        // CREATE TEST OPPORTUNITY RELATED ACCOUNT =====================================================
        AH_Opportunity_Related_Account__c ora = new AH_Opportunity_Related_Account__c();
        ora.Account__c = a2.Id;
        ora.Opportunity__c = o.Id;
        insert ora;
        
        // CREATE TEST RELATED OPPORTUNITY LINE ITEM ===================================================
        AH_Account_Product__c ap1 = new AH_Account_Product__c();
        
        ap1.Account__c = a2.Id;
        ap1.Opportunity__c = o.Id;
        ap1.Product__c = oli.Product2Id;
        ap1.Quantity__c = 10;
        
        insert ap1;
        
        
        Test.startTest(); 
        
        
        // CREATE OPPORTUNITY LIST
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        
        // CREATE CONTROLLERS FOR VF PAGE TESTING
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(o);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(oppList);
        
        // SET PAGE REFERENCE TO REDIRECT ON THE AH_LinkAccountWithProduct VF PAGE
        PageReference PageRef = Page.AH_LinkAccountWithProduct;
        Test.setCurrentPage(PageRef);
        
        // SET CURRENT OPPORTUNITY ID TO STANDARD CONTROLLER. 
        ApexPages.currentPage().getParameters().put('id', o.Id);   
        
        // CREATE OBJECT OF EXTENTION CLASS TO ACCESS WRAPPER CLASS WITH EXISTING STANDARD CONTROLLER PARAMETER.
        AH_LinkAccountWithProduct_Ext ctrl = new AH_LinkAccountWithProduct_Ext(stdSetCtrl);
        
        AH_Account_Product__c acToProd = [SELECT Id, Account__c, Product__c FROM AH_Account_Product__c WHERE Id =: ap1.Id];
        
        // system.assertEquals(acToProd, 2, 'Related Opportunity Line Item has More Than 2 Record.');
        
        // LOOP ON EXTENTION'S WRAPPER CLASS TO SET BOOLEAN VARIABLE TRUE AND ASSIGN PRODUCT QUANTITY VALUES.
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
            wrapObj.prodQuan = 1.0;
            wrapObj.accId = acToProd.Account__c;
            wrapObj.prodId = acToProd.Product__c;
        }
        
        ctrl.refreshProducts();
        ctrl.calculateAvailableQuantity();
        ctrl.doSave();
        ctrl.refreshPage();
        ctrl.syncAccountProducts();
        
        //ASSERT EQUALS STATEMENT AFTER SYNC.
        //system.Assert(message.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        
        for (Apexpages.Message msg : msgs)
        {
            if (msg.getDetail().contains('Account to Product synchronization has been done successfully. Please click Return button to get back to Opportunity Record Detail Page.')) 
            {
                b = true;
            }
        }
        
        system.assert(b);
        
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
        }
        
        ctrl.deleteProductLinking();
        
        //ASSERT EQUALS STATEMENT AFTER DELETE.
        ApexPages.Message[] messages = ApexPages.getMessages();
        system.debug('messages : '+messages);
        system.assertEquals(3, messages.size());
        
        system.assertEquals('No records selected to save.', messages[0].getDetail());
        system.assertEquals('Account to Product synchronization has been done successfully. Please click Return button to get back to Opportunity Record Detail Page.', messages[1].getDetail());
        system.assertEquals('Assigned Quantity and DI to ALI Linking has been Removed successfully.',messages[2].getDetail());
        
        
        Test.stopTest();
        
        system.debug(' *** END AH_LinkAccountWithProduct_Test.linkAccountWithProduct2() - QUERIES ISSUED = ' + Limits.getQueries());
    }       
    
    
    
    // ADDED BY SHASHIKANT ON 11/15/2019
    @isTest static void linkAccountWithProduct3() 
    {
        
        Opportunity opp2 = [select ID, Name from Opportunity Where Name = 'AH_LinkAccountWithProduct_Test - HRM New Org Opportunity'];
        
        Test.startTest();
        
        // CREATE TEST ACCOUNT =========================================================================
        List<Account> aList = new List<Account>();        
        for(Integer i = 3; i<= 53; i++)
        {
            Account aa = NI_TestClassData.createTestAccount(i);
            aa.Name = 'Related Test Account '+i;
            aa.Legal_Entity_Name__c = 'Legal Sync Entity';
            aList.add(aa);
        }
        
        Database.insert(aList);
        
        List<Account> aList2 = new List<Account>([select ID, Name from Account where Name like 'Related Test Account%']);
        
        List<AH_Opportunity_Related_Account__c> oraList = new List<AH_Opportunity_Related_Account__c>();
        for(Account a : aList2 )
        {
            // CREATE TEST OPPORTUNITY RELATED ACCOUNT 
            AH_Opportunity_Related_Account__c ora = new AH_Opportunity_Related_Account__c();
            ora.Account__c = a.Id;
            ora.Opportunity__c = opp2.Id;
            oraList.add(ora);
        }
        
        Database.insert(oraList);
        
        
        OpportunityLineItem oli = [select id, name, Product2Id from OpportunityLineItem where Description = 'Apex Test Line Item 4'];
        
        List<AH_Account_Product__c> apList = new List<AH_Account_Product__c>();
        for(Account a : aList2 )
        {
            // CREATE TEST RELATED OPPORTUNITY LINE ITEM 
            AH_Account_Product__c ap1 = new AH_Account_Product__c();
            ap1.Account__c = a.Id;
            ap1.Opportunity__c = opp2.Id;
            ap1.Product__c = oli.Product2Id;
            //ap1.Quantity__c = 1;
            apList.add(ap1);
        }
        //Database.insert(apList);
        
        // CREATE OPPORTUNITY LIST
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(opp2);
        
        // CREATE CONTROLLERS FOR VF PAGE TESTING
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp2);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(oppList);
        
        // SET PAGE REFERENCE TO REDIRECT ON THE AH_LinkAccountWithProduct VF PAGE
        PageReference PageRef = Page.AH_LinkAccountWithProduct;
        Test.setCurrentPage(PageRef);
        
        // SET CURRENT OPPORTUNITY ID TO STANDARD CONTROLLER. 
        ApexPages.currentPage().getParameters().put('id', opp2.Id);   
        
        // CREATE OBJECT OF EXTENTION CLASS TO ACCESS WRAPPER CLASS WITH EXISTING STANDARD CONTROLLER PARAMETER.
        AH_LinkAccountWithProduct_Ext ctrl = new AH_LinkAccountWithProduct_Ext(stdSetCtrl);
        ctrl.paginationSize = 25;
        
        ctrl.refreshList(opp2.Id, 'Init');
        
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
            //wrapObj.prodQuan = 1.0;
        }
        
        ctrl.CheckAll = true;
        ctrl.globalQuanVal = '1';
        ctrl.applyToAllProp();
        ctrl.doSave();
        
        system.debug('totalPages : '+ctrl.totalPages);
        
        //ASSERT EQUALS STATEMENT
        ApexPages.Message[] messages = ApexPages.getMessages();
        system.debug('messages : '+messages);
        system.assertEquals('Saved successfully. Please click Refresh button to get updated quantities.', messages[0].getDetail());
        
        ctrl.next();
        
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
            //wrapObj.prodQuan = 1.0;
        }
        
        ctrl.CheckAll = true;
        ctrl.globalQuanVal = '1';
        ctrl.applyToAllProp();
        ctrl.CheckAllPassProp = true;
        ctrl.checkPassiveProperties();
        
        ctrl.previous();
        
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: ADDED ON 11/19/2019 by Shashikant. 
    // =======================================================================================================================================    
    @isTest static void linkAccountWithProduct4() 
    {
        
        system.debug(' *** START AH_LinkAccountWithProduct_Test.linkAccountWithProduct2() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Id rtSalesOrderId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId(); 
        
        // GET TEST RECORDS        
        Opportunity o = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];  
        OpportunityLineItem oli = [SELECT Id, Product2Id, Opportunity_Stage__c, DeploymentInstance__c FROM OpportunityLineItem WHERE Description =: 'Apex Test Line Item 4']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_LinkAccountWithProduct_Test ACCOUNT'];    
        
        // CREATE TEST BILLING CONTRACT RECORD 
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD =============================================================
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Account__c = a.Id;
        ali.Product__c = oli.Product2Id;
        ali.Opportunity__c = o.Id;
        insert ali;
        
        Test.startTest(); 
        
        // WHEN OPPORTUNITY STAGE WILL GET CLOSE WON AND STATUS WOULD BE INTEGRATED.
        o.StageName = 'Closed Won';
        o.Order_Status__c = 'Integrated';
        update o;        
        
        o.RecordTypeId = rtSalesOrderId;
        update o;
        
        // ASSERT ROLLUPS HAVE ACCURATE VALUES (AFTER OPPORTUNITY RECORD TYPE CHANGES)
        Opportunity oppAssert1 = [SELECT Id, StageName, RecordTypeId, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];  
        system.assertEquals(oppAssert1.StageName, 'Closed Won');
        system.assertEquals(oppAssert1.Order_Status__c, 'Integrated');
        system.assertEquals(rtSalesOrderId, oppAssert1.RecordTypeId);
        
        // CREATE TEST ACCOUNT 
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'Sync Test Account';        
        a2.Legal_Entity_Name__c = 'Legal Sync Entity';
        Database.insert(a2);          
        
        // CREATE TEST OPPORTUNITY RELATED ACCOUNT 
        AH_Opportunity_Related_Account__c ora = new AH_Opportunity_Related_Account__c();
        ora.Account__c = a2.Id;
        ora.Opportunity__c = o.Id;
        insert ora;
        
        // CREATE TEST RELATED OPPORTUNITY LINE ITEM 
        AH_Account_Product__c ap1 = new AH_Account_Product__c();
        
        ap1.Account__c = a2.Id;
        ap1.Opportunity__c = o.Id;
        ap1.Product__c = oli.Product2Id;
        ap1.Quantity__c = 10;
        
        insert ap1;
        
        // CREATE OPPORTUNITY LIST
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        
        // CREATE CONTROLLERS FOR VF PAGE TESTING
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(o);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(oppList);
        
        // SET PAGE REFERENCE TO REDIRECT ON THE AH_LinkAccountWithProduct VF PAGE
        PageReference PageRef = Page.AH_LinkAccountWithProduct;
        Test.setCurrentPage(PageRef);
        
        // SET CURRENT OPPORTUNITY ID TO STANDARD CONTROLLER. 
        ApexPages.currentPage().getParameters().put('id', o.Id);   
        
        // CREATE OBJECT OF EXTENTION CLASS TO ACCESS WRAPPER CLASS WITH EXISTING STANDARD CONTROLLER PARAMETER.
        AH_LinkAccountWithProduct_Ext ctrl = new AH_LinkAccountWithProduct_Ext(stdSetCtrl);
        
        AH_Account_Product__c acToProd = [SELECT Id, Account__c, Product__c FROM AH_Account_Product__c WHERE Id =: ap1.Id];
        
        system.debug('acToProd : '+acToProd);
        
        // system.assertEquals(acToProd, 2, 'Related Opportunity Line Item has More Than 2 Record.');
        
        // LOOP ON EXTENTION'S WRAPPER CLASS TO SET BOOLEAN VARIABLE TRUE AND ASSIGN PRODUCT QUANTITY VALUES.
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
            wrapObj.prodQuan = 1.0;
            wrapObj.accId = acToProd.Account__c;
            wrapObj.prodId = acToProd.Product__c;
        }
        
        ctrl.refreshProducts();
        ctrl.syncAccountProducts();
        
        AH_Account_Product__c acToProd1 = [SELECT Id, Account__c, Product__c, Opportunity__c, Deployment_Instance__c FROM AH_Account_Product__c WHERE Id =: ap1.Id];
        system.debug('acToProd1 : '+acToProd1);
        
        OpportunityLineItem oli2 = [SELECT Id, Product2Id, Opportunity_Stage__c, DeploymentInstance__c FROM OpportunityLineItem WHERE Description =: 'Apex Test Line Item 5']; 
        
        // CREATE TEST BILLING CONTRACT RECORD 
        Billing_Contract__c bc2 = NI_TestClassData.createBillingContract(2);
        bc2.Account__c = a.Id;
        bc2.Opportunity__c = o.Id;
        insert bc2;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD 
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(bc2.Id);
        ali2.Account__c = a.Id;
        ali2.Product__c = oli2.Product2Id;
        ali2.Opportunity__c = o.Id;
        insert ali2;
        
        Test.stopTest();
        
        //ASSERT EQUALS STATEMENT AFTER DELETE.
        ApexPages.Message[] messages = ApexPages.getMessages();
        system.debug('messages : '+messages);
        system.assertEquals('Account to Product synchronization has been done successfully. Please click Return button to get back to Opportunity Record Detail Page.', messages[0].getDetail(), 'Message mismatch.');
        
        List<AH_Account_Product__c> acPrList = new List<AH_Account_Product__c>([select id, Account__c, Product__c, Opportunity__c, Deployment_Instance__c FROM  
                                                                                AH_Account_Product__c WHERE 
                                                                                Account__c =: a2.Id 
                                                                                AND Product__c =: oli.Product2Id 
                                                                                AND Opportunity__c =: o.id                                                                            
                                                                               ]);
        
        //system.debug('acPrList : '+acPrList);
        
        system.assertNotEquals(NULL, acPrList[0].Deployment_Instance__c, 'Deployment Instance should not be NULL.');
        
        system.debug(' *** END AH_LinkAccountWithProduct_Test.linkAccountWithProduct4() - QUERIES ISSUED = ' + Limits.getQueries());
    }   
    
    
    @isTest static void linkAccountWithProduct5() 
    {
        List<Product2> prodList = new List<Product2>([select ID, Name from Product2 where ProductCode =: 'APEX-TEST-01' OR ProductCode =: 'APEX-TEST-02']);
        
        List<Product2> prodList1 = new List<Product2>();
        for(Product2 p : prodList)
        {
            p.DI_DefaultStatus__c = 'Installed';
            prodList1.add(p);
        }
        Database.update(prodList1);
        
        
        system.debug(' *** START AH_LinkAccountWithProduct_Test.linkAccountWithProduct2() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Id rtSalesOrderId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Order').getRecordTypeId(); 
        
        // GET TEST RECORDS        
        Opportunity o = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];  
        OpportunityLineItem oli = [SELECT Id, Product2Id, Opportunity_Stage__c, DeploymentInstance__c FROM OpportunityLineItem WHERE Description =: 'Apex Test Line Item 4']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_LinkAccountWithProduct_Test ACCOUNT'];    
        
        // CREATE TEST BILLING CONTRACT RECORD ===============================================================
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Opportunity__c = o.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD =============================================================
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Account__c = a.Id;
        ali.Product__c = oli.Product2Id;
        ali.Opportunity__c = o.Id;
        insert ali;
        
        // WHEN OPPORTUNITY STAGE WILL GET CLOSE WON AND STATUS WOULD BE INTEGRATED.
        o.StageName = 'Closed Won';
        o.Order_Status__c = 'Integrated';
        update o;        
        
        o.RecordTypeId = rtSalesOrderId;
        update o;
        
        // ASSERT ROLLUPS HAVE ACCURATE VALUES (AFTER OPPORTUNITY RECORD TYPE CHANGES)
        Opportunity oppAssert1 = [SELECT Id, StageName, RecordTypeId, Order_Status__c FROM Opportunity WHERE Name = 'AH_LinkAccountWithProduct_Test - Large Deal Opportunity'];  
        system.assertEquals(oppAssert1.StageName, 'Closed Won');
        system.assertEquals(oppAssert1.Order_Status__c, 'Integrated');
        system.assertEquals(rtSalesOrderId, oppAssert1.RecordTypeId);
        
        // CREATE TEST ACCOUNT =========================================================================
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'Sync Test Account';        
        a2.Legal_Entity_Name__c = 'Legal Sync Entity';
        Database.insert(a2);          
        
        // CREATE TEST OPPORTUNITY RELATED ACCOUNT =====================================================
        AH_Opportunity_Related_Account__c ora = new AH_Opportunity_Related_Account__c();
        ora.Account__c = a2.Id;
        ora.Opportunity__c = o.Id;
        insert ora;
        
        // CREATE TEST RELATED OPPORTUNITY LINE ITEM ===================================================
        AH_Account_Product__c ap1 = new AH_Account_Product__c();
        
        ap1.Account__c = a2.Id;
        ap1.Opportunity__c = o.Id;
        ap1.Product__c = oli.Product2Id;
        ap1.Quantity__c = 10;
        
        insert ap1;
        
        
        Test.startTest(); 
        
        
        // CREATE OPPORTUNITY LIST
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        
        // CREATE CONTROLLERS FOR VF PAGE TESTING
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(o);
        ApexPages.StandardSetController stdSetCtrl = new ApexPages.StandardSetController(oppList);
        
        // SET PAGE REFERENCE TO REDIRECT ON THE AH_LinkAccountWithProduct VF PAGE
        PageReference PageRef = Page.AH_LinkAccountWithProduct;
        Test.setCurrentPage(PageRef);
        
        // SET CURRENT OPPORTUNITY ID TO STANDARD CONTROLLER. 
        ApexPages.currentPage().getParameters().put('id', o.Id);   
        
        // CREATE OBJECT OF EXTENTION CLASS TO ACCESS WRAPPER CLASS WITH EXISTING STANDARD CONTROLLER PARAMETER.
        AH_LinkAccountWithProduct_Ext ctrl = new AH_LinkAccountWithProduct_Ext(stdSetCtrl);
        
        AH_Account_Product__c acToProd = [SELECT Id, Account__c, Product__c FROM AH_Account_Product__c WHERE Id =: ap1.Id];
        
        // system.assertEquals(acToProd, 2, 'Related Opportunity Line Item has More Than 2 Record.');
        
        // LOOP ON EXTENTION'S WRAPPER CLASS TO SET BOOLEAN VARIABLE TRUE AND ASSIGN PRODUCT QUANTITY VALUES.
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
            wrapObj.prodQuan = 1.0;
            wrapObj.accId = acToProd.Account__c;
            wrapObj.prodId = acToProd.Product__c;
        }
        
        ctrl.refreshProducts();
        ctrl.calculateAvailableQuantity();
        ctrl.doSave();
        ctrl.refreshPage();
        ctrl.syncAccountProducts();
        
        AH_Account_Product__c acToProd1 = [SELECT Id, Account__c, Product__c, Opportunity__c, Deployment_Instance__c FROM AH_Account_Product__c WHERE Id =: ap1.Id];
        system.debug('acToProd1 : '+acToProd1);
        
        OpportunityLineItem oli2 = [SELECT Id, Product2Id, Opportunity_Stage__c, DeploymentInstance__c FROM OpportunityLineItem WHERE Description =: 'Apex Test Line Item 5']; 
        
        // CREATE TEST BILLING CONTRACT RECORD 
        Billing_Contract__c bc2 = NI_TestClassData.createBillingContract(2);
        bc2.Account__c = a.Id;
        bc2.Opportunity__c = o.Id;
        insert bc2;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD 
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(bc2.Id);
        ali2.Account__c = a.Id;
        ali2.Product__c = oli2.Product2Id;
        ali2.Opportunity__c = o.Id;
        insert ali2;
        
        
        //ASSERT EQUALS STATEMENT AFTER SYNC.
        //system.Assert(message.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        
        for (Apexpages.Message msg : msgs)
        {
            if (msg.getDetail().contains('Account to Product synchronization has been done successfully. Please click Return button to get back to Opportunity Record Detail Page.')) 
            {
                b = true;
            }
        }
        
        system.assert(b);
        
        for (AH_LinkAccountWithProduct_Ext.AccProdWrapper wrapObj : ctrl.accProdWrapList)
        {
            wrapObj.isSelected = true;
        }
        
        ctrl.deleteProductLinking();
        
        //ASSERT EQUALS STATEMENT AFTER DELETE.
        ApexPages.Message[] messages = ApexPages.getMessages();
        system.debug('messages : '+messages);
        system.assertEquals(3, messages.size());
        system.assertEquals('No records selected to save.', messages[0].getDetail());
        system.assertEquals('Account to Product synchronization has been done successfully. Please click Return button to get back to Opportunity Record Detail Page.', messages[1].getDetail());
        system.assertEquals('Assigned Quantity and DI to ALI Linking has been Removed successfully.',messages[2].getDetail());
        
        Test.stopTest();
        
        system.debug(' *** END AH_LinkAccountWithProduct_Test.linkAccountWithProduct2() - QUERIES ISSUED = ' + Limits.getQueries());
    }    
    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6: 
    // =======================================================================================================================================    
    @isTest static void linkAccountWithProduct6()
    {
        
        test.starttest();
        
        List<Account> aList = new List<Account>([select id, Name from Account]);
        system.debug('aList : '+aList);
        
        Account a7 = NI_TestClassData.createTestAccount(7);
        a7.Name = 'TEST ACCOUNT NUMBER 7'; 
        insert a7;
        
        // CREATE TEST CONTACT RECORD =============================================================================================
        Contact c = NI_TestClassData.createTestContact(1, a7.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtHRMAMOId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId(); 
        
        
        
        Opportunity opp7 = NI_TestClassData.createTestOpportunity(7, a7.Id); 
        opp7.RecordTypeId = rtHRMAMOId;
        opp7.Name = 'APEX TEST - HRM OPPORTUNITY DI';
        Database.Insert(opp7);
        
        List<OpportunityContactRole> lstOppContcRole1 = new List<OpportunityContactRole>();
        
        // Bill To contact
        OpportunityContactRole ocr14 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Bill To');
        lstOppContcRole1.add(ocr14);
        // Ship To contact
        OpportunityContactRole ocr15 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Ship To');
        lstOppContcRole1.add(ocr15);         
        // Customer Project Contact 
        OpportunityContactRole ocr16 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole1.add(ocr16);        
        // Decision Maker Contact 
        OpportunityContactRole ocr17 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Decision Maker');
        lstOppContcRole1.add(ocr17);    
        // SPONSOR CONTACT ROLE
        OpportunityContactRole ocr27 = NI_TestClassData.createTestOpportunityContactRole(opp7.Id, c.Id, 'Sponsor');
        lstOppContcRole1.add(ocr27);
        
        Database.Insert(lstOppContcRole1); 
        
        
        NI_DeploymentInstanceIndex__c diIdx11 = NI_TestClassData.createDI_Index(11, 'APEX TEST');
        insert diIdx11;
        NI_DeploymentInstanceIndex__c diIdx12 = NI_TestClassData.createDI_Index(12, 'APEX TEST');
        insert diIdx12;
        
        
        // CREATE TEST PRODUCT GROUP RECORD =======================================================================================
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'AH_LinkAccountWithProduct_Test');
        insert pgp;
        
        
        List<Product2> lstProds1 = new List<Product2>();
        
        Product2 p2_11 = NI_TestClassData.createProduct2(11, pgp.Id, 'ZZZ-HRM-002 DI', 'Subscription'); 
        p2_11.DI_Index__c = diIdx11.Id;
        p2_11.DI_DefaultStatus__c = 'Installed';
        p2_11.DI_Priority__c = 200;
        p2_11.Unit__c = 'User';
        p2_11.Family = 'Software';
        p2_11.Apttus_Config2__HasOptions__c = false;
        lstProds1.add(p2_11); 
        
        Product2 p2_12 = NI_TestClassData.createProduct2(12, pgp.Id, 'ZZZ-HRM-002 DI 2', 'Subscription'); 
        p2_12.DI_Index__c = diIdx11.Id;
        p2_12.DI_DefaultStatus__c = 'Purchased';
        p2_12.Unit__c = 'User';
        p2_12.Family = 'Subscription';
        p2_12.License_Type__c = 'Limited';
        p2_12.Apttus_Config2__HasOptions__c = false;
        lstProds1.add(p2_12);         
        
        Product2 p2_13 = NI_TestClassData.createProduct2(13, pgp.Id, 'ZZZ-HRM-002 DI 3', 'Subscription'); 
        p2_13.DI_Index__c = diIdx11.Id;
        p2_13.DI_DefaultStatus__c = 'Installed';
        p2_13.DI_Priority__c = 300;
        p2_13.Unit__c = 'User';
        p2_13.Family = 'Subscription';
        p2_13.License_Type__c = 'Limited';
        p2_13.Apttus_Config2__HasOptions__c = false;
        lstProds1.add(p2_13); 
        
        Product2 p2_14 = NI_TestClassData.createProduct2(14, pgp.Id, 'ZZZ-HRM-002 DI 4', 'Subscription'); 
        p2_14.DI_Index__c = diIdx11.Id;
        p2_14.DI_DefaultStatus__c = 'Purchased';
        p2_14.Unit__c = 'User';
        p2_14.Family = 'Subscription';
        p2_14.License_Type__c = 'Full';
        p2_14.Apttus_Config2__HasOptions__c = false;
        lstProds1.add(p2_14); 
        
        Product2 p2_15 = NI_TestClassData.createProduct2(15, pgp.Id, 'ZZZ-HRM-002 DI 5', 'Subscription'); 
        p2_15.DI_Index__c = diIdx12.Id;
        p2_15.DI_DefaultStatus__c = 'Purchased';
        p2_15.Unit__c = 'User';
        p2_15.Family = 'Subscription';
        p2_15.License_Type__c = 'Full';
        p2_15.Apttus_Config2__HasOptions__c = false;
        lstProds1.add(p2_15); 
        
        Product2 p2_16 = NI_TestClassData.createProduct2(16, pgp.Id, 'ZZZ-HRM-002 DI 6', 'Subscription'); 
        p2_16.DI_Index__c = diIdx12.Id;
        p2_16.Unit__c = 'User';
        p2_16.Family = 'Subscription';
        p2_16.License_Type__c = 'Full';
        p2_16.Apttus_Config2__HasOptions__c = false;
        lstProds1.add(p2_16); 
        Database.Insert(lstProds1); 
        
        
        List<PricebookEntry> lstPBEs1 = new List<PricebookEntry>();
        
        Id pbkId1 = Test.getStandardPricebookId();
        
        PricebookEntry pbe11 = NI_TestClassData.createTestPricebookEntry(pbkId1, p2_11.Id, 1);
        lstPBEs1.add(pbe11); 
        
        PricebookEntry pbe13 = NI_TestClassData.createTestPricebookEntry(pbkId1, p2_13.Id, 1);
        lstPBEs1.add(pbe13); 
        
        PricebookEntry pbe14 = NI_TestClassData.createTestPricebookEntry(pbkId1, p2_14.Id, 1);
        lstPBEs1.add(pbe14);
        
        PricebookEntry pbe15 = NI_TestClassData.createTestPricebookEntry(pbkId1, p2_15.Id, 1);
        lstPBEs1.add(pbe15);
        
        Database.Insert(lstPBEs1);   
        
        
        List<OpportunityLineItem> lstOLIs1 = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli15 = NI_TestClassData.createTestOpportunityLineItem(15, opp7.Id, pbe11.Id, 1);
        lstOLIs1.add(oli15);
        
        OpportunityLineItem oli16 = NI_TestClassData.createTestOpportunityLineItem(16, opp7.Id, pbe13.Id, 1);
        lstOLIs1.add(oli16);
        
        OpportunityLineItem oli17 = NI_TestClassData.createTestOpportunityLineItem(17, opp7.Id, pbe14.Id, 1);
        lstOLIs1.add(oli17);
        
        OpportunityLineItem oli18 = NI_TestClassData.createTestOpportunityLineItem(18, opp7.Id, pbe15.Id, 1);
        lstOLIs1.add(oli18);
        
        Database.Insert(lstOLIs1);
        
        
        Product2 p211 = [SELECT Id, DI_DefaultStatus__c, DI_Index__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-002 DI' LIMIT 1];
        Product2 p212 = [SELECT Id, DI_DefaultStatus__c, DI_Index__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-002 DI 2' LIMIT 1];
        Product2 p216 = [SELECT Id, DI_DefaultStatus__c, DI_Index__c FROM Product2 WHERE ProductCode = 'ZZZ-HRM-002 DI 6' LIMIT 1];
        
        Opportunity opp71 = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = 'APEX TEST - HRM OPPORTUNITY DI'];
        
        // SET OPPORTUNITY FIELDS THAT TRIGGER CREATION OF THE SALESFORCE LICENSES AND ZZZ-HRM-001 DIs
        list<asset> assetToadd = new list<asset>();
        Asset asset = NI_TestClassData.createTestAsset(10, opp71.AccountId, p212.Id);
        asset.status = 'Installed';
        assetToadd.add(asset);
        
        Asset asset2 = NI_TestClassData.createTestAsset(12, opp71.AccountId, p216.Id);
        asset2.status = 'Inactive';
        assetToadd.add(asset2);
        
        database.insert(assetToadd);
        
        opp71.StageName = 'Closed Won';
        opp71.Order_Status__c = 'Integrated';
        update opp71;
        
        test.stoptest();
        
        OpportunityLineItem op7Oli =  [SELECT Id, Name, DeploymentInstance__c FROM OpportunityLineItem WHERE OpportunityId =: opp71.Id AND ProductCode = 'ZZZ-HRM-002 DI'];
        update op7Oli;
        
        Asset asset2Status = [SELECT Status FROM Asset WHERE Id =: asset2.Id];
        system.assertEquals(op7Oli.DeploymentInstance__c, asset.Id, 'Oppline item is linked to existing DI');
        system.assertEquals('Purchased', asset2Status.Status, 'Asset status is updated to Purchased if Product status is not Inactive');
        
    } 
    
}