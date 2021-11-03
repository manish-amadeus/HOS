/****************************************************************************************
Name            : NI_DeploymentInstance_TriggHandler_Test Class
Author          : Stuart Emery
Created Date    : 2/19/2014
Last Mod Date   : 4/17/2014 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for the NI_DeploymentInstance_TriggerHandler Class 
                : 
                : 
******************************************************************************************/
@isTest 
public class NI_DeploymentInstance_TriggHandler_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA
    // =======================================================================================================================================    
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START NI_DeploymentInstance_TriggHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Test.startTest();
        
        // INSERT A TEST RECORD INTO THE NI_Insert_DI_History_Record__c CUSTOM SETTING 
        NI_Insert_DI_History_Record__c csFields = new NI_Insert_DI_History_Record__c();
        csFields.Name = 'NI Insert DI History Method';
        csFields.Enabled__c = true;
        insert csFields;        
        
        // CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(10);        
        a.Name = 'NI_DeploymentInstance_TriggHandler_Test Account';
        a.Type = 'Prospect';
        insert a;        
        
        // CREATE TEST CONTACT RECORD 
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        // CREATE TEST DI INDEX RECORDS 
        List<NI_DeploymentInstanceIndex__c> lstDIIndexes = new List<NI_DeploymentInstanceIndex__c>();
        
        NI_DeploymentInstanceIndex__c idx1 = new NI_DeploymentInstanceIndex__c();
        idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST 1');
        lstDIIndexes.add(idx1);
        
        NI_DeploymentInstanceIndex__c idx2 = new NI_DeploymentInstanceIndex__c();
        idx2 = NI_TestClassData.createDI_Index(1, 'APEX TEST 2');
        lstDIIndexes.add(idx2);
        
        NI_DeploymentInstanceIndex__c idx3 = new NI_DeploymentInstanceIndex__c();
        idx3 = NI_TestClassData.createDI_Index(1, 'APEX TEST 3');
        lstDIIndexes.add(idx3);
        
        database.insert(lstDIIndexes);
        
        // CREATE TEST PRODUCT GROUP RECORDS 
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST 1');
        insert pgp;
        
        // CREATE TEST VERSION RECORD 
        SFDC_CSP_Version__c vrs = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        vrs.Name = 'APEX v1.0';
        vrs.Product_Line_Global__c = 'Delphi';
        insert vrs;

        // CREATE TEST PRODUCT RECORDS
        List<Product2> lstProduct2Inserts = new List<Product2>();
        
        Product2 p1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-PROD2-01', 'Subscription'); 
        p1.DI_Index__c = idx1.Id;
        p1.Product_Line_Global__c = 'Delphi';
        lstProduct2Inserts.add(p1);

        Product2 p2 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-PROD2-02', 'Software');
        p2.Unit__c = 'User';
        p2.DI_Index__c = idx2.Id;
        p2.Product_Line_Global__c = 'Delphi';
        lstProduct2Inserts.add(p2);
        
        Product2 p3 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-PROD2-03', 'Subscription'); 
        p3.DI_Index__c = idx3.Id;
        p3.Product_Line_Global__c = 'Delphi';
        lstProduct2Inserts.add(p3); 
        
        database.insert(lstProduct2Inserts);

        // CREATE TEST DEPLOYMENT INSTANCE RECORDS
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, p1.Id);
        di1.Status = 'Purchased';        
        di1.Product_Group__c = pgp.Id;
        di1.Build_Number__c = 'NI_DeploymentInstance_TriggHandler_Test';
        insert di1;  

        // CREATE TEST OPPORTUNITY RECORDS 
		List<Opportunity> lstOpportunityInserts = new List<Opportunity>();
        
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = 'NI_DeploymentInstance_TriggHandler_Test Opportunity #1';
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Small Deal Opportunity').getRecordTypeId();
        lstOpportunityInserts.add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.Name = 'NI_DeploymentInstance_TriggHandler_Test Opportunity #2';
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Small Deal Opportunity').getRecordTypeId();
        lstOpportunityInserts.add(opp2);
        
        database.insert(lstOpportunityInserts);        

        // CREATE TEST PRICEBOOK ENTRY RECORD
        Id pbkId = Test.getStandardPricebookId(); 
        
        PricebookEntry pbe1 = NI_TestClassData.createTestPricebookEntry(pbkId, p1.Id, 1000);
        insert pbe1;         

        // CREATE TEST OPPORTUNITY CONTACT ROLE RECORDS 
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // Bill To contact 
        OpportunityContactRole ocr11 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr11);
        // Ship To contact
        OpportunityContactRole ocr12 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr12);         
        // Customer Project Contact 
        OpportunityContactRole ocr13 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr13);        
        // Decision Maker Contact 
        OpportunityContactRole ocr14 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr14);   
        // Sponsor Contact 
        OpportunityContactRole ocr15 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr15);    
        
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
        

        // CREATE TEST OPPORTUNITY LINE ITEM RECORDS  ===================================================================================== 
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe1.Id, 1);
        oli01.Quantity = 10;
        oli01.DeploymentInstance__c = di1.Id;
        lstOLIs.add(oli01);
        
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp2.Id, pbe1.Id, 1);
        oli02.Quantity = 7;
        oli02.DeploymentInstance__c = di1.Id;
        lstOLIs.add(oli02);    
        
        database.insert(lstOLIs);

        // CREATE TEST PRODUCT FAMILY UNITS
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit);
        
        AH_Products_Family_Unit__c prodFamUnit2 = new AH_Products_Family_Unit__c();
        prodFamUnit2.Name = 'Software';
        prodFamUnit2.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit2);
        
        database.insert(prodFamUnitList);
        
        test.StopTest(); 
        
        system.debug(' *** END NI_DeploymentInstance_TriggHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
	// =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        NI_DeploymentInstanceIndex__c testDiIndex = new NI_DeploymentInstanceIndex__c ();
        testDiIndex  = NI_TestClassData.createDI_Index(1, 'test DI index');
        insert testDiIndex;
        
        NI_DeploymentInstanceIndex__c testDiIndex2= new NI_DeploymentInstanceIndex__c ();
        testDiIndex2 = NI_TestClassData.createDI_Index(2, 'test DI index 2');
        insert testDiIndex2;
        
        //INSERT A TEST RECORD INTO THE NI_Insert_DI_History_Record__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_Insert_DI_History_Record__c csFields = new NI_Insert_DI_History_Record__c();
        csFields.Name = 'NI Insert DI History Method';
        csFields.Enabled__c = true;
        insert csFields;
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //CREATE VERSION RECORD  
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        vrs01.Product_Line_Global__c = 'AIP';
        insert vrs01;
        
        //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();

        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = testDiIndex2.Id;
        prd01.Product_Line_Global__c = 'AIP';
        lstProds.add(prd01);

        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        prd02.DI_Index__c = testDiIndex.Id;
        prd02.Product_Line_Global__c = 'Delphi';
        lstProds.add(prd02);
        
        Database.Insert(lstProds);        

        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Installed';
        asset1.Product_Group__c = pgp.Id;
        insert asset1;  
        
        //Create Asset record
        Asset asset2 = NI_TestClassData.createTestAsset(2, a.Id, prd02.Id);
        asset2.Status = 'Installed';
        asset2.Product_Group__c = pgp.Id;
        asset2.Version__c = vrs01.Id;
        asset2.Purchased_Product__c = prd02.Id;
        asset2.Purchase_Status__c = 'Purchased';
        insert asset2; 
        
        Test.startTest();
        
        //SET THIS SWITCH TO FALSE SO THE TRIGGER FIRES
        NI_TriggerManager.isBypassDIUpdate = false; 
        
        try
        {
            //UPDATE TEST DEPLOYMENT INSTANCE RECORD
            asset1.Purchased_Product__c = prd02.Id; 
            update asset1;
        }
        catch (Exception e)
        {
            system.debug('e.getMessage()'+e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('The selected Purchased Product is not valid for this Deployment Instance (DI Index mismatch).') ? true : false;
            system.AssertEquals(expectedExceptionThrown, true);
        }  
        
        try
        {
            asset2.Purchased_Version__c = vrs01.Id;
            update asset2;
        }
        catch (Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('The selected Purchased Version is not valid for this Deployment Instance (Product Line mismatch).') ? true : false;
            system.AssertEquals(expectedExceptionThrown, true);
        }   
        
        Test.stopTest();       
    }
    
	// =======================================================================================================================================
    // = TEST METHOD 2: 
    // =======================================================================================================================================    
    @isTest static void test2() 
    {
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        Test.startTest();
        
        NI_DeploymentInstanceIndex__c testDiIndex = new NI_DeploymentInstanceIndex__c ();
        testDiIndex  = NI_TestClassData.createDI_Index(1,'test DI index');
        insert testDiIndex;
        
        NI_DeploymentInstanceIndex__c testDiIndex2= new NI_DeploymentInstanceIndex__c ();
        testDiIndex2 = NI_TestClassData.createDI_Index(2, 'test DI index 2');
        insert testDiIndex2;
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();

        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = testDiIndex.id;
        lstProds.add(prd01);
  
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        prd02.DI_Index__c  = testDiIndex2.id;
        lstProds.add(prd02);
        
        Database.insert(lstProds);
        
        DI_Management__c diMagmt = new DI_Management__c();
        diMagmt.Core_DI_Index__c = testDiIndex.id;
        diMagmt.Peripheral_DI_Product__c = prd02.id;
        insert diMagmt;
        
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = pgp.Id;
        insert asset1; 

        List<Asset> assetList = new List<Asset>();
        assetList.add(asset1);
        
        Asset peripheralAsset = [SELECT Id, Core_DI__c, Product2Id FROM Asset WHERE Core_DI__c =: asset1.Id];
        NI_DeploymentInstance_TriggerHandler objTriggerHandler = new NI_DeploymentInstance_TriggerHandler(true);
        objTriggerHandler.OnBeforeDelete(assetList);
        
        list<NI_Deployment_Instance_History__c>  assetHistory = [SELECT Id FROM NI_Deployment_Instance_History__c WHERE Related_Deployment_Instance__c = :asset1.id OR Related_Deployment_Instance__c = :peripheralAsset.id];
        delete assetHistory;        

        test.stoptest();
        
        system.assertEquals(asset1.id ,peripheralAsset.Core_DI__c);
        
    }
   
	// =======================================================================================================================================
    // = TEST METHOD 3: CUSTOM HISTORY OBJECT TESTING (CREATED PRIOR TO HISTORY BEING ON ASSET OBJECT)
    // =======================================================================================================================================    
    @isTest static void test3() 
    {  

        Product2 p1 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-PROD2-01'];
        SFDC_CSP_Version__c vrs = [SELECT Id FROM SFDC_CSP_Version__c WHERE Name = 'APEX v1.0'];
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'APEX TEST 1'];

        Test.startTest();

        // CREATE TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);        
        a.Name = 'TEST METHOD 3 Account';
        insert a;  
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, p1.Id);
        di1.Status = 'Installed';
        di1.Purchase_Status__c = 'Purchased';
        di1.Purchased_Product__c = p1.Id;
        di1.Product_Group__c = pgp.Id;
        di1.Version__c = vrs.Id;
        insert di1; 

        List<NI_Deployment_Instance_History__c> lstHistoryAsserts1 = [SELECT Id, Related_Deployment_Instance__c 
                                                                      FROM NI_Deployment_Instance_History__c 
                                                                      WHERE Related_Deployment_Instance__c =: di1.Id];
        
system.debug(' *^* lstHistoryAsserts1.size() = ' + lstHistoryAsserts1.size());  
        
        //SET THIS SWITCH TO FALSE SO THE TRIGGER FIRES
        NI_DeploymentInstance_TriggerHandler.isBypassTrigger = false; 
        
        // UPDATE TEST DEPLOYMENT INSTANCE RECORD
        di1.Purchase_Status__c = 'Installed'; 
        update di1;
        
        Test.StopTest();
        
        // VERIFY THE STATUS WAS UPDATED. 
//        Asset updatedAsset = [SELECT Product2Id FROM Asset WHERE Build_Number__c = 'NI_DeploymentInstance_TriggHandler_Test']; 
//        system.assertEquals(prd01.Id, updatedAsset.Product2Id);
        
        
        // VERIFY THAT THE DEPLOYMENT INSTANCE HISTORY RECORD HAS BEEN CREATED FOR THE UPDATED DEPLOYMENT INSTANCE RECORD USING SYSTEM.ASSERT METHOD  
        List<NI_Deployment_Instance_History__c> lstHistoryAsserts2 = [SELECT Id, Related_Deployment_Instance__c 
                                                                      FROM NI_Deployment_Instance_History__c 
                                                                      WHERE Related_Deployment_Instance__c =: di1.Id];
        
        //system.Assert(dih[0].Related_Deployment_Instance__c == asset1.Id);
        
system.debug(' *^* lstHistoryAsserts2.size() = ' + lstHistoryAsserts2.size());  
                
    } 
      
	// =======================================================================================================================================
    // = TEST METHOD 4: 
    // =======================================================================================================================================    
    @isTest static void test4() 
    {  
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //INSERT A TEST RECORD INTO THE NI_Insert_DI_History_Record__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_Insert_DI_History_Record__c csFields = new NI_Insert_DI_History_Record__c();
        csFields.Name = 'NI Insert DI History Method';
        csFields.Enabled__c = true;
        insert csFields;
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();
        
        // CREATE TEST PRODUCT RECORD  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.Hosted__c = true;
        lstProds.add(prd01);
        
        // CREATE TEST PRODUCT RECORD  
        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        prd02.Hosted__c = true;
        lstProds.add(prd02);
        
        Product2 prd03 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-11-4-TEST', 'Subscription');
        lstProds.add(prd03);
        Database.Insert(lstProds);
        
        // CREATE VERSION RECORD  
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        //Create new version for product group
        SFDC_CSP_Version__c vrs02 = NI_TestClassData.createVersion('v1.', pgp.Id, 2);
        insert vrs02;
        
        // Create Asset record
        Asset asset2 = NI_TestClassData.createTestAsset(2, a.Id, prd02.Id);
        asset2.Status = 'Installed';
        asset2.Product_Group__c = pgp.Id;
        asset2.Version__c = vrs01.Id;
        asset2.Purchased_Product__c = prd02.Id;
        asset2.Purchased_Version__c = vrs01.Id;
        asset2.Purchase_Status__c = 'Purchased';
        insert asset2; 

        Test.startTest();
        
        // SET THIS SWITCH TO FALSE SO THE TRIGGER FIRES
        NI_DeploymentInstance_TriggerHandler.isBypassTrigger = false; 
        
        //Update the Asset Purchased status from 'Purchased' to 'Installed'
        asset2.Purchase_Status__c = 'Installed';
        update asset2;
        
        Test.StopTest();
        
        // Verify the product and version updated
        Asset updatedAsset2 = [SELECT Version__c, Product2Id from Asset where Id =: asset2.Id];
        
        system.assertEquals(prd02.Id, updatedAsset2.Product2Id);
        system.assertEquals(vrs01.Id, updatedAsset2.Version__c);
        
    }
    
	// =======================================================================================================================================
    // = TEST METHOD 5: 
    // =======================================================================================================================================    
    @isTest static void test5() 
    {
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //INSERT A TEST RECORD INTO THE NI_Insert_DI_History_Record__c CUSTOM SETTING. THE CUSTOM SETTING NEEDS TO EXIST  
        NI_Insert_DI_History_Record__c csFields = new NI_Insert_DI_History_Record__c();
        csFields.Name = 'NI Insert DI History Method';
        csFields.Enabled__c = true;
        insert csFields;
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();
        
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.Product_Line_Global__c = 'Delphi.fdc';
        prd01.Solution_Domain_Global__c = 'CRS';        
        lstProds.add(prd01);
        
        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        lstProds.add(prd02);
        
        Database.Insert(lstProds);
        
        //CREATE VERSION RECORD  
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;

        //Create new version for product group
        SFDC_CSP_Version__c vrs02 = NI_TestClassData.createVersion('v1.', pgp.Id, 2);
        insert vrs02;
        
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE A TEST USER
        User u = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u;      
        
        // CREATE A TEST ACCOUNT TEAM MEMBER
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = a.Id;
        atm.UserId = u.Id;
        atm.TeamMemberRole = 'NI Collector';
        insert atm;
        
        // CREATE A TEST OPPORTUNITY  
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        insert opp1;
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = pgp.Id;
        asset1.Version__c = vrs01.Id;
        Insert asset1; 
        
        // Create Asset record
        Asset asset2 = NI_TestClassData.createTestAsset(2, a.Id, prd02.Id);
        asset2.Name = 'Delphi.fdc';
        asset2.Status = 'Shipped';
        asset2.Product_Group__c = pgp.Id;
        asset2.Version__c = vrs01.Id;
        asset2.Purchased_Product__c = prd02.Id;
        asset2.Purchased_Version__c = vrs02.Id;
        asset2.Purchase_Status__c = 'Purchased';
        asset2.Core_DI__c = asset1.Id;
        asset2.Opportunity__c = opp1.Id;
        insert asset2; 

        Billing_Contract__c b1 = NI_TestClassData.createBillingContract(1);
        insert b1;
        
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c stx = NI_TestClassData.createActivityLineItem(b1.Id);   
        stx.Deployment_Instance__c = asset1.Id;
        stx.Status__c = 'Inactive';
        aliList.add(stx);
        
        Activity_Line_Item__c stx1 = NI_TestClassData.createActivityLineItem(b1.Id);   
        stx.Deployment_Instance__c = asset2.Id;
        stx1.Status__c = 'Inactive';
        stx1.Renewal_Base_Price__c = 10;
        stx1.Product__c = prd01.Id;
        stx1.Contract_Start_Date__c = Date.today() - 425;
        stx1.Contract_End_Date__c = Date.today();
        aliList.add(stx1);
        
        insert aliList;

        Test.startTest();
        
        List<NI_Cancellation__c> cancList = new List<NI_Cancellation__c>();
        
        NI_Cancellation__c cxl = NI_TestClassData.createCancellation(a.Id);
        cxl.Account__c = a.Id;
        cxl.Product2__c = prd01.Id;
		cxl.Activity_Line_Item__c = stx1.Id;
        cxl.Amadeus_RSM__c = UserInfo.getUserId();
        cxl.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl.Renewal_Cancellation_Quantity__c = 1; 
        cxl.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        insert cxl;
        
        //SET THIS SWITCH TO FALSE SO THE TRIGGER FIRES
        NI_TriggerManager.isBypassDIUpdate = false; 
        
        //UPDATE TEST DEPLOYMENT INSTANCE RECORD
        asset1.IsHostedDI__c = true; 
        asset1.Status = 'Inactive';
        Update asset1;
        
        Test.StopTest();
        
        //VERIFY THE STATUS WAS UPDATED. 
        Asset updatedAsset2 = [SELECT IsHostedDI__c from Asset where Id =: asset2.Id];
        system.assertEquals(true, updatedAsset2.IsHostedDI__c);
        
        Integer cnt = [SELECT Count() from NI_Cancellation__c where Status__c = 'Cancelled' and Deployment_Instance__c =: asset2.Id];
        
    }
    
	// =======================================================================================================================================
    // = TEST METHOD 6: 
    // =======================================================================================================================================    
    @isTest static void test6() 
    {
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //CREATE TEST ACCOUNT RECORD 
        Account a = NI_TestClassData.createTestAccount(1);  
        a.Name = 'jasjd asjgdhakkls hajsd';
        insert a;
        
        Account b = NI_TestClassData.createTestAccount(2);  
        b.Name = 'lkkhjhj yFAJaykkj';
        insert b;
        
        Account c = NI_TestClassData.createTestAccount(3);
        c.Name = 'ppojjasujdbjay hgjshkjask';
        insert c;
        
        Account d = NI_TestClassData.createTestAccount(4); 
        d.Name = 'qwewer jhakjhs oiuhlksas';
        insert d;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        List<Product2> lstProds = new List<Product2>();

        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        lstProds.add(prd01);
        
        Database.Insert(lstProds);
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Purchased';       
        asset1.Product_Group__c = pgp.Id;        
        Insert asset1;                 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset2 = NI_TestClassData.createTestAsset(2, b.Id, prd01.Id);
        asset2.Status = 'Purchased';
        asset2.Parent_DI__c = asset1.Id;       
        asset2.Product_Group__c = pgp.Id;       
        Insert asset2; 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset3 = NI_TestClassData.createTestAsset(3, c.Id, prd01.Id);
        asset3.Status = 'Purchased';        
        asset3.Product_Group__c = pgp.Id;
        Insert asset3;        
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset4 = NI_TestClassData.createTestAsset(4, d.Id, prd01.Id);
        asset4.Status = 'Purchased';
        asset4.Product_Group__c = pgp.Id;
        asset4.Parent_DI__c = asset3.Id;
        Insert asset4; 
        
        Test.startTest();
        
        asset1.Status = 'Inactive';
        update asset1;
        
        asset3.Status = 'Installed';
        update asset3;

        Test.stopTest();       
        
        Asset updatedAsset3 = [SELECT Status from Asset where Id =: asset2.Id];
        system.assertEquals('Inactive', updatedAsset3.Status);
        
        Asset updatedAsset2 = [SELECT Status from Asset where Id =: asset4.Id];
        system.assertEquals('Installed', updatedAsset2.Status);
        
    }
    
	// =======================================================================================================================================
    // = TEST METHOD 7: 
    // =======================================================================================================================================    
    @isTest static void test7() 
    {
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;

        Test.startTest();

        NI_DeploymentInstanceIndex__c testDiIndex = new NI_DeploymentInstanceIndex__c ();
        testDiIndex  = NI_TestClassData.createDI_Index(1,'test DI index');
        insert testDiIndex;
        
        NI_DeploymentInstanceIndex__c testDiIndex2= new NI_DeploymentInstanceIndex__c ();
        testDiIndex2 = NI_TestClassData.createDI_Index(2,'test DI index 2');
        insert testDiIndex2;
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Account b = NI_TestClassData.createTestAccount(2);
        insert b;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();

        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = testDiIndex.Id;
        lstProds.add(prd01);

        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        prd02.DI_Index__c  = testDiIndex.Id;
        lstProds.add(prd02);
        
        Database.Insert(lstProds);

        Asset asset1 = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        asset1.Status = 'Purchased';
        asset1.Product_Group__c = pgp.Id;
        Insert asset1; 
        
        Asset assetChild = NI_TestClassData.createTestAsset(1, b.Id, prd02.Id);
        assetChild.Status = 'Inactive';
        assetChild.Parent_DI__c = asset1.Id;
        assetChild.Product_Group__c = pgp.Id;
        Insert assetChild; 

        Asset parentasset = [SELECT Id, status FROM Asset WHERE Id =: asset1.Id];

        test.stoptest();
        
        system.assertEquals('Inactive' ,parentasset.status);
        
    }
     
	// =======================================================================================================================================
    // = TEST METHOD 8: 
    // =======================================================================================================================================    
    @isTest static void test8() 
    {
        
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //CREATE TEST ACCOUNT RECORD 
        Account acc1 = NI_TestClassData.createTestAccount(1);
        insert acc1;
        
        Account acc2 = NI_TestClassData.createTestAccount(2);
        insert acc2;
        
        //CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //LIST OF PRODUCTS TO INSERT  
        List<Product2> lstProds = new List<Product2>();

        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        lstProds.add(prd01);
        
        Product2 prd02 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-2-TEST', 'Subscription');
        lstProds.add(prd02);

        Product2 prd03 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-EMBP-10-3-TEST', 'Subscription');
        lstProds.add(prd03);
        
        Database.Insert(lstProds);
        
        // CREATE VERSION RECORD  
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;

        // Create new version for product group
        SFDC_CSP_Version__c vrs02 = NI_TestClassData.createVersion('v1.', pgp.Id, 2);
        insert vrs02;
        
        Test.startTest(); 
        
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORDS
        List<Asset> diList = new List<Asset>();
        
        Asset asset1 = NI_TestClassData.createTestAsset(1, acc1.Id, prd01.Id);
        asset1.Status = 'Shipped';
        asset1.Product_Group__c = pgp.Id;
        asset1.Version__c = vrs01.Id;
        diList.add(asset1);

        Asset asset2 = NI_TestClassData.createTestAsset(2, acc2.Id, prd02.Id);
        asset2.Name = 'Delphi.fdc';
        asset2.Status = 'Purchased';
        asset2.Product_Group__c = pgp.Id;
        asset2.Version__c = vrs01.Id;
        asset2.Purchased_Product__c = prd02.Id;
        asset2.Purchased_Version__c = vrs02.Id;
        asset2.Purchase_Status__c = 'Purchased';        
        diList.add(asset2);

        Asset asset3 = NI_TestClassData.createTestAsset(3, acc2.Id, prd03.Id);
        asset3.Name = 'Delphi.fdc1';
        asset3.Status = 'Purchased';
        asset3.Product_Group__c = pgp.Id;
        asset3.Version__c = vrs01.Id;
        asset3.Purchased_Product__c = prd02.Id;
        asset3.Purchased_Version__c = vrs02.Id;
        asset3.Purchase_Status__c = 'Purchased';        
        diList.add(asset3);

        Database.insert(diList);
        
        // After Delete
        NI_Deployment_Instance_History__c diHistory = [SELECT Id FROM NI_Deployment_Instance_History__c WHERE Related_Deployment_Instance__c =: asset1.Id]; 
        delete diHistory;
        delete asset1;
        
        //After Undelete
        NI_Deployment_Instance_History__c diHistory1 = [SELECT Id FROM NI_Deployment_Instance_History__c WHERE Related_Deployment_Instance__c =: asset3.Id]; 
        delete diHistory1;
        delete asset3;
        
        undelete asset3;
        
        Test.StopTest();
        
        //Verify that "Type" field on Account is updated.
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id,Type FROM Account WHERE Id IN (:acc1.Id, :acc2.Id)]);
        system.assertEquals('Customer', accMap.get(acc2.Id).Type);
        system.assertEquals('Prospect', accMap.get(acc1.Id).Type);
        
    }
       
	// =======================================================================================================================================
    // = TEST METHOD 9: 
    // =======================================================================================================================================    
    @isTest static void test9() 
    {
        
        // Create Test Delphi Data
        NI_DeploymentInstanceIndex__c diIndexDelphi = NI_TestClassData.createDI_Index(1, 'Delphi');
        insert diIndexDelphi;
          
        Product_Group__c prodGrpDelphi = NI_TestClassData.createProductGroup(1, 'Delphi');
        insert prodGrpDelphi;        

        SFDC_CSP_Version__c versionDelphi = NI_TestClassData.createVersion('V1Delphi', prodGrpDelphi.Id, 1);
        versionDelphi.Name = 'V1Delphi';
        versionDelphi.Product_Line_Global__c = 'Delphi';
        insert versionDelphi;        
        
        SFDC_CSP_Version__c versionDelphi1 = NI_TestClassData.createVersion('V2Delphi', prodGrpDelphi.Id, 1);
        versionDelphi1.Name = 'V2Delphi';
        versionDelphi1.Product_Line_Global__c = 'Delphi';
        insert versionDelphi1;             
        
        Product2 prodDelphi = NI_TestClassData.createProduct2(1, prodGrpDelphi.id, 'ZZZFULFILL-APEX-101', 'Subscription');
        insert prodDelphi;
        
        // Create Test MeetingMatrix Cluster
        NI_DeploymentInstanceIndex__c meetMatrixIndex = NI_TestClassData.createDI_Index(1, 'MeetingMatrix');
        insert meetMatrixIndex;

        Product_Group__c meetMatrixProdGrp = NI_TestClassData.createProductGroup(1, 'MeetingMatrix');
        insert meetMatrixProdGrp;           

        SFDC_CSP_Version__c meetMatrixVersion = NI_TestClassData.createVersion('MeetingMatrix Vertion 1.1', meetMatrixProdGrp.id, 1);
        meetMatrixVersion.Name = 'MeetingMatrix Vertion 1.1';
        meetMatrixVersion.Product_Line_Global__c = 'MeetingMatrix';
        insert meetMatrixVersion;   
        
        SFDC_CSP_Version__c meetMatrixVersion1 = NI_TestClassData.createVersion('MeetingMatrix Vertion 1.2', meetMatrixProdGrp.id, 1);
        meetMatrixVersion1.Name = 'MeetingMatrix Vertion 1.2';
        meetMatrixVersion1.Product_Line_Global__c = 'MeetingMatrix';
        insert meetMatrixVersion1;          
        
        // fetch all picklist value of product line 
        map<string,string> productLines = new map<string,string>();
        Schema.DescribeFieldResult fieldResult = Cluster__c.Product_Line_Global__c.getDescribe();
        List<Schema.PicklistEntry> prodLinesPicklist = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry pl : prodLinesPicklist)
        {
            productLines.put(pl.getValue(),pl.getValue());
        } 
            
        Product2 meetMatrixProd = NI_TestClassData.createProduct2(2, meetMatrixProdGrp.id, 'ZZZFULFILL-APEX-201', 'Subscription');
        insert meetMatrixProd;
        
        // Create test Cluster Records
        List<Cluster__c> clusterList = new List<Cluster__c>();
        Cluster__c currentCluster = new Cluster__c();
        currentCluster.Name = 'Cyb Cluster Test';
        currentCluster.Product_Line_Global__c = productLines.get('Delphi');
        currentCluster.Version_New__c = versionDelphi.Id;      
        currentCluster.Purchased_Version__c = versionDelphi.Id;              
        currentCluster.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'Delphi/Daylight');       
        clusterList.add(currentCluster);
        
        Cluster__c meetingMatrixclus1 = new Cluster__c();
        meetingMatrixclus1.Name = 'Cyb meetingMatrix Cluster Test1';
        meetingMatrixclus1.Product_Line_Global__c = productLines.get('MeetingMatrix');
        meetingMatrixclus1.Version_New__c = meetMatrixVersion.Id;        
        meetingMatrixclus1.Purchased_Version__c = meetMatrixVersion.Id;               
        meetingMatrixclus1.RecordTypeId = NI_TestClassData.getRecordTypeId('Cluster__c', 'MeetingMatrix Cluster');
        clusterList.add(meetingMatrixclus1);        
        insert clusterList;
        
        Test.startTest();
        
        //CREATE TEST ACCOUNT RECORD 
        Account acc = NI_TestClassData.createTestAccount(1);
        acc.Current_MPE_Cluster__c = currentCluster.Id;
        acc.Cluster__c = currentCluster.Id;
        acc.Current_meetingMatrix_MPE_Cluster__c = meetingMatrixclus1.Id;
        acc.Target_meetingMatrix_MPE_Cluster__c = meetingMatrixclus1.Id;        
        insert acc;
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD
        List<Asset> assetList = new List<Asset>();  
        Asset asset1 = NI_TestClassData.createTestAsset(1, acc.Id, prodDelphi.Id);
        asset1.Status = 'Purchased';
        asset1.Product_Group__c = prodGrpDelphi.Id;
        asset1.Version__c = versionDelphi.Id;
        asset1.isHostedDI__c = False;
        assetList.add(asset1); 
        
        //CREATE TEST DEPLOYMENT INSTANCE RECORD  
        Asset asset2 = NI_TestClassData.createTestAsset(2, acc.Id, meetMatrixProd.Id);
        asset2.Status = 'Purchased';
        asset2.Product_Group__c = meetMatrixProdGrp.Id;
        asset2.Version__c = meetMatrixVersion.Id;
        asset2.isHostedDI__c = False;
        assetList.add(asset2);
        insert assetList;
        
        try
        {    
            //Upadate the Asset's Version and IsHostedDI which is related to Cluster        
            assetList = new List<Asset>();
            asset1.Version__c = Null;                
            asset1.isHostedDI__c = true; 
            asset2.Version__c = Null;                
            asset2.isHostedDI__c = true;        
            assetList.add(asset1);
            assetList.add(asset2);
            update assetList; 
        }
        catch(Exception e)
        {
            Boolean versionErrorMessage = e.getMessage().contains('Cannot modify the Version on a DI that is related to a Cluster')?true:false;
            Boolean hostedErrorMessage = e.getMessage().contains('Cannot modify the Hosted checkbox on a DI that is related to a Cluster')?true:false;
            //Verify the Validation error message is fired
            system.assertEquals(true,versionErrorMessage);
            // system.assertEquals(true, hostedErrorMessage);
        } 
        
        Test.stopTest();
        
    }

	// =======================================================================================================================================
    // = TEST METHOD 10: 
    // =======================================================================================================================================    
    @isTest static void test10() 
    {
        
        //Account a = [SELECT Id FROM Account WHERE Name = 'NI_DeploymentInstance_TriggHandler_Test Account'];
        Product2 p1 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-PROD2-01']; 
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-PROD2-02']; 
        Product2 p3 = [SELECT Id FROM Product2 WHERE ProductCode = 'APEX-TEST-PROD2-03']; 

		Test.startTest();

        // CREATE TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);        
        a.Name = 'TEST METHOD 10 Account';
        insert a;  
        
        // CREATE TEST DEPLOYMENT INSTANCES 
        List<Asset> lstAssetInserts = new List<Asset>();
        
        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, p1.Id);
        di1.status = 'Purchased';
        di1.IsHostedDI__c = true;
        lstAssetInserts.add(di1);
        
        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, p2.Id);
        di2.Status = 'Installed';
        di2.IsHostedDI__c = true;
        lstAssetInserts.add(di2);
        
        Asset di3 = NI_TestClassData.createTestAsset(3, a.Id, p3.Id);
        di3.Core_DI__c = di1.Id;
        lstAssetInserts.add(di3);
        
        database.insert(lstAssetInserts);
        
        // CREATE TEST BILLING CONTRACT 
        Billing_Contract__c b2 = NI_TestClassData.createBillingContract(2);
        insert b2;
        
        // CREATE TEST ACTIVITY LINE ITEMS 
        List<Activity_Line_Item__c> lstActLineInserts = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c ali1 = NI_TestClassData.createActivityLineItem(b2.Id);
        ali1.Deployment_Instance__c = di2.Id;
        ali1.Status__c = 'Inactive';
        lstActLineInserts.add(ali1);
        
        Activity_Line_Item__c ali2 = NI_TestClassData.createActivityLineItem(b2.Id);
        ali2.Deployment_Instance__c = di2.Id;
        ali2.Status__c = 'Inactive';
        lstActLineInserts.add(ali2);
        
        database.insert(lstActLineInserts);
        
        Test.stopTest();
        
        Asset peridi = [SELECT Status, IsHostedDI__c, Core_DI__c FROM Asset WHERE Id =: di3.Id];
        peridi.Core_DI__c = di2.Id;
        update peridi;
        
        Asset coredi = [SELECT Status, IsHostedDI__c, Core_DI__c FROM Asset WHERE Id =: di2.Id];
        system.assertEquals(coredi.IsHostedDI__c, false);
        coredi.status = 'Inactive';
        update coredi;
        
    }
   
	// =======================================================================================================================================
    // = TEST METHOD 11: TEST ROLLUP OF Quantity_Ordered__c WHEN AN OPPORTUNITY Order Status IS TURNED
    // =======================================================================================================================================    
    @isTest static void test11() 
    { 
        
		Opportunity opp1 = [SELECT Id, StageName, Order_Status__c FROM Opportunity WHERE Name = 'NI_DeploymentInstance_TriggHandler_Test Opportunity #1'];
        Opportunity opp2 = [SELECT Id, StageName, Order_Status__c FROM Opportunity WHERE Name = 'NI_DeploymentInstance_TriggHandler_Test Opportunity #2'];
        Asset di1 = [SELECT Id FROM Asset WHERE Status = 'Purchased'];        

        Test.startTest();
        
        opp1.StageName = 'Closed Won';
        opp1.Order_Status__c = 'Definite';
        update opp1;
        
        di1.Quantity_Ordered__c = 10;
        update di1;
        
        Asset diTest1 = [SELECT Quantity_Ordered__c FROM Asset WHERE Id =: di1.Id];
        system.assertEquals(10, diTest1.Quantity_Ordered__c);
        
        opp1.Order_Status__c = 'Open';
        update opp1;
        
        di1.Quantity_Ordered__c = 0;
        update di1;
        
        Asset diTest2 = [SELECT Quantity_Ordered__c FROM Asset WHERE Id =: di1.Id];
        system.assertEquals(0, diTest2.Quantity_Ordered__c);
        
        opp1.Order_Status__c = 'Definite';
        update opp1;
        
        opp2.StageName = 'Closed Won';
        opp2.Order_Status__c = 'Definite';
        update opp2; 
        
        di1.Quantity_Ordered__c = 17;
        update di1;
        
        Asset diTest3 = [SELECT Quantity_Ordered__c FROM Asset WHERE Id =: di1.Id];
        system.assertEquals(17, diTest3.Quantity_Ordered__c); 
        
        // TEST Recalculate Quantity Ordered CHECKBOX FUNCTIONALITY
        di1.Quantity_Ordered__c = 100;
        update di1;
        
        Asset diTest4 = [SELECT Quantity_Ordered__c FROM Asset WHERE Id =: di1.Id];
        system.assertEquals(100, diTest4.Quantity_Ordered__c); 
        
        di1.Recalculate_Quantity_Ordered__c = true;
        update di1;
        
        Asset diTest5 = [SELECT Quantity_Ordered__c, Recalculate_Quantity_Ordered__c FROM Asset WHERE Id =: di1.Id];
        system.assertEquals(17, diTest5.Quantity_Ordered__c); 
        system.assertEquals(false, diTest5.Recalculate_Quantity_Ordered__c); 
        
        Test.stopTest();
        
    }

	// =======================================================================================================================================
    // = TEST METHOD 12: COVERAGE FOR TRIGGERHANDLER PLACEHOLDER EVENTS  
    // =======================================================================================================================================    
    @isTest static void test12() 
    {  
        NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext; 
        List<Asset> lst = new List<Asset>();
        Map<Id, Asset> mp = new Map<Id, Asset>();
        handler.OnBeforeInsert(lst);
        handler.OnBeforeUpdate(lst, mp);
        handler.OnBeforeDelete(lst);        
        handler.OnAfterUpdate(lst, mp);        
        handler.OnAfterDelete(lst);
        handler.OnAfterUnDelete(lst);
    }    
    
}