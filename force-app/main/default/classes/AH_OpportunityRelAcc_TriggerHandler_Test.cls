/****************************************************************************************
Name            : AH_OpportunityRelAcc_TriggerHandler_Test
Author          : Ria Chawla
Created Date    : 05/02/2018
Last Mod Date   : 05/02/2018
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Test class for AH_OpportunityRelAcc_TriggerHandler class
:
******************************************************************************************/
@isTest
public class AH_OpportunityRelAcc_TriggerHandler_Test {
    
    // ======================================================================================================================================= //
    // CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        system.debug(' *** AH_Account_Product_TriggerHandler_Test.createTestData() - START ***'); 
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        
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
        Database.Insert(lstDI_Indx); 
        
        List<Product2> lstProds = new List<Product2>();
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');
        prd01.DI_Index__c = diIdx1.Id;
        prd01.Apttus_Config2__HasOptions__c = false;
        prd01.License_Type__c = 'Full';
        lstProds.add(prd01);          
        Database.Insert(lstProds);
        
        // CREATE PRICEBOOKENTRY RECORDS
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        // SUBSCRIPTION RECORD
        PricebookEntry pbe01 = NI_TestClassData.createTestPricebookEntry(pbkId, prd01.Id, 1000);
        lstPBEs.add(pbe01);
        Database.Insert(lstPBEs);
        
        
        test.startTest(); 
        // CREATE OPPORTUNITY RECORDS 
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!';
        opp1.RecordTypeId = rtLargeDealId;
        lstOppInserts.add(opp1);
        Database.Insert(lstOppInserts);
        
        // CREATE OPPORTUNITY LINE ITEMS
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        
        // SUBSCRIPTION RECORD
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe01.Id, 1);
        lstOLIs.add(oli01);  
        Database.insert(lstOLIs); 
        
        test.stopTest(); 
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: TEST AFTER DELETE METHOD
    // ======================================================================================================================================= //    
    @isTest static void oppRelatedAccTrigTest1() 
    {    
        test.startTest();
             
        //GET OPPORTUNITY        
        Opportunity opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c
                            FROM Opportunity WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        
        //GET PRODUCTS ASSOCIATED WITH THAT OPPORTUNITY
        List<OpportunityLineItem> lstOli = ([SELECT li.Id, li.Product2.Id FROM OpportunityLineItem li 
                                             WHERE li.OpportunityId =: opp2.Id ]); 
        
        //GET PRODUCT INFORMATION
        List<Product2> prdList = new List<Product2>();
        prdList = [SELECT Id, DI_Index__c FROM Product2 WHERE Id = :lstOli[0].Product2.Id];
        
        //INSERT A NEW AH_Opportunity_Related_Account__c RECORD
        AH_Opportunity_Related_Account__c oppRelatedAcc = new AH_Opportunity_Related_Account__c();
        oppRelatedAcc.Opportunity__c = opp2.Id;
        oppRelatedAcc.Account__c = opp2.AccountId;
        insert oppRelatedAcc;
        
        
        //INSERT RELATED OPPORTUNITY LINE ITEM
        List<AH_Account_Product__c> accProductList = new List<AH_Account_Product__c>();
        AH_Account_Product__c accPrd1 = new AH_Account_Product__c();
        accPrd1.Account__c = opp2.AccountId;
        accPrd1.Product__c = lstOli[0].Product2.Id;
        accPrd1.Quantity__c = 4;
        accPrd1.Opportunity__c = opp2.Id;
        accProductList.add(accPrd1);
        Database.insert(accProductList);
        
        // AH_Account_Product__c RECORDS ASSOCIATED TO THE AH_Opportunity_Related_Account__c RECORD WILL GET DELETED 
        accProductList = [SELECT Id FROM AH_Account_Product__c
                          WHERE Opportunity__c =:opp2.Id
                         AND Account__c = :opp2.AccountId];
        System.assertEquals(1, accProductList.size());
        
        //DELETE AH_Opportunity_Related_Account__c RECORD
        delete oppRelatedAcc;

        try{
            // AH_Account_Product__c RECORDS ASSOCIATED TO THE AH_Opportunity_Related_Account__c RECORD WILL GET DELETED 
            accProductList = [SELECT Id, Deployment_Instance__c FROM AH_Account_Product__c
                             WHERE Opportunity__c =:opp2.Id];
            System.assertEquals(0, accProductList.size());
        }   
        catch(Exception e){
            system.debug('e'+e.getMessage());
        }
        test.stopTest(); 
    }

}