/****************************************************************************************
Name            : AH_Account_Product_TriggerHandler_Test
Author          : Ria Chawla
Created Date    : 04/30/2018
Last Mod Date   : 11/22/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_Account_Product_TriggerHandler class
				: Updated per NICC-039872
				: 
******************************************************************************************/
@isTest
public class AH_Account_Product_TriggerHandler_Test 
{
    
    // ======================================================================================================================================= 
    // CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** AH_Account_Product_TriggerHandler_Test.createTestData() - START ***'); 
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        // CREATE ACCOUNT TEST RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        // CREATE PRODUCT GROUP TEST RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE PRICEBOOK TEST RECORD
        Id pbkId = Test.getStandardPricebookId();   
        
        // CREATE TEST DI INDEX RECORDS
        List<NI_DeploymentInstanceIndex__c> lstDI_Indx = new List<NI_DeploymentInstanceIndex__c>();
        NI_DeploymentInstanceIndex__c diIdx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        lstDI_Indx.add(diIdx1);
        NI_DeploymentInstanceIndex__c diIdx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST');
        lstDI_Indx.add(diIdx2);
        Database.Insert(lstDI_Indx); 
        
        List<Product2> lstProds = new List<Product2>();
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');
        prd01.DI_Index__c = diIdx1.Id;
        prd01.Apttus_Config2__HasOptions__c = false;
        prd01.License_Type__c = 'Full';
        lstProds.add(prd01);  
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-02', 'Support');
        prd02.DI_Index__c = diIdx2.Id;
        prd02.Apttus_Config2__HasOptions__c = false;
        prd02.License_Type__c = 'Limited';  
        prd02.Unit__c = 'User';
        lstProds.add(prd02);  
        
        Product2 prd03 = NI_TestClassData.createProduct2(3, pgp.Id, 'APEX-TEST-03', 'Hosting');
        prd03.Apttus_Config2__HasOptions__c = false;
        prd03.License_Type__c = 'Full';        
        lstProds.add(prd03);
        
        Product2 prd04 = NI_TestClassData.createProduct2(4, pgp.Id, 'APEX-TEST-04', 'Software');
        prd04.DI_Index__c = diIdx2.Id;
        prd04.Apttus_Config2__HasOptions__c = false;
        prd04.License_Type__c = 'Full';  
        prd04.Unit__c = 'User';
        lstProds.add(prd04);
        Database.Insert(lstProds);
        
        // CREATE PRICEBOOKENTRY RECORDS
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
        
        // SOFTWARE RECORD
        PricebookEntry pbe04 = NI_TestClassData.createTestPricebookEntry(pbkId, prd04.Id, 1000);
        lstPBEs.add(pbe04);   
        Database.Insert(lstPBEs);
        
        
        test.startTest(); 
        // CREATE OPPORTUNITY RECORDS 
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!';
        opp1.RecordTypeId = rtLargeDealId;
        lstOppInserts.add(opp1);
        
        Opportunity opp2 = NI_TestClassData.createTestOpportunity(2, a.Id); 
        opp2.Name = '!! APEX TEST WITH HRM NEW OPPORTUNITY RECORD TYPE !!';
        opp2.RecordTypeId = rtLargeDealId;
        //opp2.StageName = 'Closed Won';
        //opp2.Order_Status__c = 'Integrated';
        lstOppInserts.add(opp2);
        Database.Insert(lstOppInserts);
        
        // CREATE OPPORTUNITY LINE ITEMS
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
        // SOFTWARE RECORD
        OpportunityLineItem oli07 = NI_TestClassData.createTestOpportunityLineItem(4, opp1.Id, pbe04.Id, 1);
        lstOLIs.add(oli07);  
        // SUBSCRIPTION RECORD
        OpportunityLineItem oli04 = NI_TestClassData.createTestOpportunityLineItem(4, opp2.Id, pbe01.Id, 1);
        lstOLIs.add(oli04);
        // SUPPORT RECORD
        OpportunityLineItem oli05 = NI_TestClassData.createTestOpportunityLineItem(5, opp2.Id, pbe02.Id, 1);
        lstOLIs.add(oli05);        
        // HOSTING RECORD
        OpportunityLineItem oli06 = NI_TestClassData.createTestOpportunityLineItem(6, opp2.Id, pbe03.Id, 1);
        lstOLIs.add(oli06);         
        Database.insert(lstOLIs); 
        
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        // BILL TO CONTACT ROLE
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Bill To');
        lstOppContcRole.add(ocr1);
        // SHIP TO CONTACT ROLE
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Ship To');
        lstOppContcRole.add(ocr2);         
        // CUSTOMER PROJECT CONTACT CONTACT ROLE
        OpportunityContactRole ocr3 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Customer Project Contact');
        lstOppContcRole.add(ocr3);        
        // DECISION MAKER CONTACT ROLE 
        OpportunityContactRole ocr4 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Decision Maker');
        lstOppContcRole.add(ocr4);
        // SPONSOR CONTACT ROLE
        OpportunityContactRole ocr5 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id, c.Id, 'Sponsor');
        lstOppContcRole.add(ocr5);  
        
        Database.Insert(lstOppContcRole); 
        
        system.debug('    >>>>    QUERIES ISSUED = ' + Limits.getQueries() + ' Testmethod: AH_Account_Product_TriggerHandler_Test.createTestData');   
        system.debug(' *** AH_Account_Product_TriggerHandler_Test.createTestData() - END ***'); 
        test.stopTest(); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST AFTER INSERT AND AFTER UPDATE
    // =======================================================================================================================================     
    @isTest static void accProductTrigTest1()
    {    
        test.startTest();
        //INSERT CUSTOM SETTINGS TO CONSIDER PRODUCT'S FAMILY FOR QUANTITY CALCULATION
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit);
        
        AH_Products_Family_Unit__c prodFamUnit2 = new AH_Products_Family_Unit__c();
        prodFamUnit2.Name = 'Support';
        prodFamUnit2.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit2);
        insert prodFamUnitList;
        
        //GET OPPORTUNITY        
        Opportunity opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c
                            FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        
        //GET PRODUCTS ASSOCIATED WITH THAT OPPORTUNITY
        List<OpportunityLineItem> lstOli = ([SELECT li.Id, li.Product2.Id FROM OpportunityLineItem li 
                                             WHERE li.OpportunityId =: opp2.Id ]); 
        
        //GET PRODUCT INFORMATION
        List<Product2> prdList = new List<Product2>();
        prdList = [SELECT Id, DI_Index__c FROM Product2 WHERE Id = :lstOli[0].Product2.Id];
        
        //INSERT RELATED OPPORTUNITY LINE ITEM
        List<AH_Account_Product__c> accProductList = new List<AH_Account_Product__c>();
        AH_Account_Product__c accPrd1 = new AH_Account_Product__c();
        accPrd1.Account__c = opp2.AccountId;
        accPrd1.Product__c = lstOli[0].Product2.Id;
        accPrd1.Quantity__c = 4;
        accPrd1.Opportunity__c = opp2.Id;
        accProductList.add(accPrd1);
        Database.insert(accProductList);
        
        //UPDATE STAGE AND ORDER STATUS OF OPPPORTUNITY TO 'Closed Won' AND 'Integrated'
        opp2.StageName = 'Closed Won';
        opp2.Order_Status__c = 'Integrated';
        update opp2;
        
        Opportunity opp22 = [SELECT Id, Name, AccountId, StageName, Order_Status__c FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        system.debug('opp22 : '+opp22);
        
        //ORDER STATUS IS UPDATED ON OPPORTUNITY RECORD
        system.assertEquals('Integrated', opp22.Order_Status__c, 'Opprotunity status is not updated.');
        
        test.stopTest(); 
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: Test After Delete
    // =======================================================================================================================================     
    @isTest static void accProductTrigTest2() 
    {
        Product2 prod = [SELECT Id, DI_DefaultStatus__c, ProductCode FROM Product2 WHERE ProductCode = 'APEX-TEST-02' LIMIT 1];
        Product2 softwareProd = [SELECT Id, DI_DefaultStatus__c, ProductCode FROM Product2 WHERE ProductCode = 'APEX-TEST-04' LIMIT 1];
        
        test.startTest();
        //INSERT CUSTOM SETTINGS
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit);
        
        AH_Products_Family_Unit__c prodFamUnit2 = new AH_Products_Family_Unit__c();
        prodFamUnit2.Name = 'Support';
        prodFamUnit2.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit2);
        
        AH_Products_Family_Unit__c prodFamUnit3 = new AH_Products_Family_Unit__c();
        prodFamUnit3.Name = 'Software';
        prodFamUnit3.Product_Unit__c = 'User';
        prodFamUnitList.add(prodFamUnit3);
        insert prodFamUnitList;
        
        //GET OPPORTUNITY INFORMATION
        Opportunity opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c
                            FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        
        //GET OPPORTUNITY LINE ITEM INFORMATION
        List<OpportunityLineItem> lstOli = ([SELECT li.Id, li.Product2.Id, li.Product2.Name FROM OpportunityLineItem li 
                                             WHERE li.OpportunityId =: opp2.Id AND li.Product2.ProductCode = 'APEX-TEST-01' ]); 
        system.debug('lstOli'+lstOli);
        
        //GET OPPORTUNITY LINE ITEM INFORMATION
        List<OpportunityLineItem> lstOli2 = ([SELECT li.Id, li.Product2.Id, li.Product2.Name FROM OpportunityLineItem li 
                                              WHERE li.OpportunityId =: opp2.Id AND li.Product2.ProductCode = 'APEX-TEST-02' ]); 
        system.debug('lstOli'+lstOli2);
        
        List<AH_Account_Product__c> accProductList = new List<AH_Account_Product__c>();
        AH_Account_Product__c accPrd1 = new AH_Account_Product__c();
        accPrd1.Account__c = opp2.AccountId;
        accPrd1.Product__c = lstOli[0].Product2.Id;
        accPrd1.Quantity__c = 4;
        accPrd1.Opportunity__c = opp2.Id;
        accProductList.add(accPrd1);
        
        AH_Account_Product__c accPrd2 = new AH_Account_Product__c();
        accPrd2.Account__c = opp2.AccountId;
        accPrd2.Product__c = lstOli2[0].Product2.Id;
        accPrd2.Quantity__c = 2;
        accPrd2.Opportunity__c = opp2.Id;
        accProductList.add(accPrd2);
        
        AH_Account_Product__c accPrd3 = new AH_Account_Product__c();
        accPrd3.Account__c = opp2.AccountId;
        accPrd3.Product__c = prod.Id;
        accPrd3.Quantity__c = 2;
        accPrd3.Opportunity__c = opp2.Id;
        accProductList.add(accPrd3);
        
        AH_Account_Product__c accPrd4 = new AH_Account_Product__c();
        accPrd4.Account__c = opp2.AccountId;
        accPrd4.Product__c = softwareProd.Id;
        accPrd4.Quantity__c = 2;
        accPrd4.Opportunity__c = opp2.Id;
        accProductList.add(accPrd4);
        
        Database.insert(accProductList);
        
        //UPDATE OPPORTUNITY'S STAGE AND ORDER STATUS
        opp2.StageName = 'Closed Won';
        opp2.Order_Status__c = 'Integrated';
        update opp2;
        
        List<Asset> assetList = new List<Asset>();
        assetList = [SELECT Id, Quantity_Ordered__c,AccountId_DIIndexID__c FROM Asset WHERE Account.Id = :opp2.AccountId];
        accProductList = [SELECT Deployment_Instance__c FROM AH_Account_Product__c];
        
        //DELETE RECORD TO TEST AFTER DELETE TRIGGER IS EXECUTED
        delete accPrd2; 
        test.stopTest();
        
        //ASSERT QUANITY 
        assetList = [SELECT Id, Quantity_Ordered__c,AccountId_DIIndexID__c FROM Asset WHERE Account.Id = :opp2.AccountId];
        system.debug('assetList'+assetList);
        //CONSIDERING QUANTITIES OF accPrd1, accPrd3 AND accPrd4 (accPrd2 IS DELETED)
        //QUANTITIES OF OLI ARE ALSO ADDED WHOSE FAMILY IS PRESENT IN CUSTOM SETTING
        system.assertEquals(11, assetList[0].Quantity_Ordered__c+assetList[1].Quantity_Ordered__c);
        
    }
    
}