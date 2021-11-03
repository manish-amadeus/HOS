/****************************************************************************************
Name            : NI_InternalOppCommFormCtlr_TestClass
Author          : Stuart Emery
Created Date    : 8/29/2013
Last Mod Date   : 7/14/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-007986
Description     : Test Class for the NI_InternalOppCommFormController
				: 
******************************************************************************************/
@isTest (SeeAllData=true)
private class NI_InternalOppCommFormCtlr_TestClass 
{
    
    static testMethod void myUnitTest() 
    {
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
        update(pt);
        
        Opportunity o = new Opportunity();
        
        //PAGE REFERENCE
        PageReference pageRef = Page.NI_InternalOppCommForm;
        Test.setCurrentPage(pageRef);
        
        //CREATE A TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;

        // CREATE 2 TEST DI INDEXES ==================================================================================== 
        List<NI_DeploymentInstanceIndex__c> lstDeploymentInstanceIndex = new List<NI_DeploymentInstanceIndex__c>(); 
        
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx1); 
        
        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx2); 
        
        database.insert(lstDeploymentInstanceIndex); 
        
        //CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        //PRICEBOOK & ENTRY CREATION START ===========================================================================     
//        Pricebook2 pb2 = [SELECT id FROM Pricebook2 WHERE isStandard = true];   
        Id pricebookId = Test.getStandardPricebookId();

        List<Product2> lstProds = new List<Product2>();
        
        //CREATE A TEST PRODUCT RECORDS  
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id; 
        lstProds.add(prd01);
        
        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-DFDCQS-02-TEST', 'Subscription');
        prd02.DI_Index__c = idx2.Id;
        lstProds.add(prd02);        
        
        system.assertequals(2, lstProds.Size()); 
        
        Database.Insert(lstProds);
        
        System.assert(prd01.Family == 'Subscription');
        
        List<PricebookEntry> lstPBEs = new List<PricebookEntry>();
        
        //CREATE A TEST PRICEBOOK ENTRY RECORDS  
        PricebookEntry pbe01 = NI_TestClassData.createTestPricebookEntry(pricebookId, prd01.Id, 1000);
        lstPBEs.add(pbe01);
        
        PricebookEntry pbe02 = NI_TestClassData.createTestPricebookEntry(pricebookId, prd02.Id, 2000);
        lstPBEs.add(pbe02);
        
        System.assertEquals(2, lstPBEs.size());
        Database.Insert(lstPBEs);
        
        //System.Assert(pbe01.Product2.Name == 'Embrace');
        
        //System.Assert(pbe01.Product2.Family == 'Subscription');
        
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        
        //CREATE A TEST OPPORTUNITY RECORD
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        lstOppInserts.add(opp1);
        system.assertequals(lstOppInserts.size(),1);
        Database.Insert(lstOppInserts);
        
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();        
        
        //CREATE A TEST OPPORTUNITY LINE ITEM RECORD  
        OpportunityLineItem oli01 = NI_TestClassData.createTestOpportunityLineItem(1, opp1.Id, pbe01.Id, 1);
        //oli01.CurrencyISOCode = 'USD'; 
        lstOLIs.add(oli01);
        system.assertequals(lstOLIs.size(),1);
        
        OpportunityLineItem oli02 = NI_TestClassData.createTestOpportunityLineItem(2, opp1.Id, pbe02.Id, 1); 
        lstOLIs.add(oli02);
        
        Database.Insert(lstOLIs);                      
        
        Contact cntct = NI_TestClassData.createTestContact(1,a.Id);
        insert cntct;
        
        List<OpportunityContactRole> lstOppContcRole = new List<OpportunityContactRole>();
        
        //CREATE A BILL TO CONTACT RECORD
        OpportunityContactRole ocr1 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id,cntct.Id,'Bill To');
        lstOppContcRole.add(ocr1);
        
        //CREATE A SHIP TO CONTACT RECORD
        OpportunityContactRole ocr2 = NI_TestClassData.createTestOpportunityContactRole(opp1.Id,cntct.Id,'Ship To');
        lstOppContcRole.add(ocr2);
        system.assertequals(lstOppContcRole.size(),2);
        
        //INSERT CONTACT ROLE RECORDS
        Database.Insert(lstOppContcRole);
        
        //CREATE A TEST SOFTRAX ASSET RECORD
        //List< Softrax_Asset__c> lstStxAssetsToInsert = new List< Softrax_Asset__c>();  
        
// Converted to use NI_TestClassData 2/12/2015
        // Softrax_Asset__c sa = new Softrax_Asset__c(Account__c = a.Id);
        /*Softrax_Asset__c sa = NI_TestClassData.createSoftraxAsset(10, a.Id, prd01.ProductCode);  
        sa.Softrax_Status__c = 'A';
        sa.Cancel_Asset__c = true;
        sa.Description__c = 'TEST 1';
        lstStxAssetsToInsert.add(sa);
        
        //Softrax_Asset__c sa2 = new Softrax_Asset__c(Account__c = a.Id);
        Softrax_Asset__c sa2 = NI_TestClassData.createSoftraxAsset(11, a.Id, prd02.ProductCode);  
        sa2.Softrax_Status__c = 'A';
        sa2.Cancel_Asset__c = false;
        sa2.Description__c = 'TEST 2';
        lstStxAssetsToInsert.add(sa2);
        
        Database.insert( lstStxAssetsToInsert);
        
        system.assert(sa.Id != null);*/
        
        //INSTANTIATE CONTROLLER
        NI_InternalOppCommFormController ctrl = new NI_InternalOppCommFormController(new ApexPages.StandardController(opp1));              
        
    }
    
}