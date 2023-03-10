/****************************************************************************************
Name            : NI_CancellationAllAccountDIsCtrlrTest Class
Author          : Stuart Emery
Created Date    : 06/20/2014
Last Mod Date   : 06/20/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-008353
Description     : Test Class for the NI_CancellationAllAccountDIsController Class.
                :  
******************************************************************************************/
@isTest
private class NI_CancellationAllAccountDIsCtrlrTest 
{
    
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {        

        Test.startTest();
                
        // CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_CancellationAllAccountDIsCtrlrTest Account';
        insert a;
        
        // CREATE 2 TEST DI INDEXES ====================================================================================        
        List<NI_DeploymentInstanceIndex__c> lstDeploymentInstanceIndex = new List<NI_DeploymentInstanceIndex__c>(); 
        
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx1); 
        
        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx2); 
        
        database.insert(lstDeploymentInstanceIndex); 
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST PRODUCT RECORDS
        List<Product2> lstProductsToInsert = new List<Product2>();

        Product2 p1 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        p1.DI_Index__c = idx1.Id; 
        p1.Solution_Domain_Global__c = 'CRS';
        lstProductsToInsert.add(p1);

        Product2 p2 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-DFDCQS-02-TEST', 'Subscription');
        p2.DI_Index__c = idx2.Id; 
        p2.Solution_Domain_Global__c = 'CRS';
        lstProductsToInsert.add(p2); 

        Database.Insert(lstProductsToInsert);  
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORDS
        List<Asset> lstDIsToInsert = new List<Asset>();  

        Asset di1 = NI_TestClassData.createTestAsset(1, a.Id, p1.Id);
        di1.Name = 'TEST1';
        di1.Status = 'Installed'; 
        di1.Product_Group__c = pgp.Id;
        lstDIsToInsert.add(di1);

        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, p2.Id);
        di2.Name = 'TEST2';
        di2.Status = 'Installed'; 
        di2.Product_Group__c = pgp.Id;
        lstDIsToInsert.add(di2);  
        
        Database.Insert(lstDIsToInsert);    

        // CREATE TEST BILLING CONTRACT RECORD
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id); 
        ali.Product__c = p1.Id;
        ali.Contract_Start_Date__c = Date.today() - 425;
        ali.Contract_End_Date__c = Date.today();
        ali.Renewal_Base_Price__c = 10;
        insert ali;        
        
        // CREATE TEST CANCELATION RECORD
        NI_Cancellation__c cxl = NI_TestClassData.createCancellation(a.Id);
        cxl.Account__c = a.Id;
        cxl.Product2__c = p1.Id;
        cxl.Activity_Line_Item__c = ali.Id;
        cxl.Deployment_Instance__c = di1.Id;
        cxl.General_Reason__c = 'Affiliation Change';  
        cxl.Amadeus_RSM__c = UserInfo.getUserId();
        cxl.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl.Renewal_Cancellation_Quantity__c = 1; 
        cxl.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        insert cxl;        

        Test.stopTest(); 

    }

    // =======================================================================================================================================
    // = TEST METHOD 1: VISUALFORCE PAGE TESTING
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
   
        system.debug(' *** START NI_CancellationAllAccountDIsCtrlrTest.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'NI_CancellationAllAccountDIsCtrlrTest Account'];
        NI_Cancellation__c cxl = [SELECT Id, Activity_Line_Item__c FROM NI_Cancellation__c WHERE Account__c =: a.Id LIMIT 1];       
        Product2 p2 = [SELECT Id FROM Product2 WHERE ProductCode = 'HRM-DFDCQS-02-TEST']; 
        
        
        Test.startTest(); 

        // PAGE REFERENCE
        PageReference pageRef = Page.NI_CancellationAllAccountDIsVF;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('id', cxl.Id);
        
        // INSTANTIATE CONTROLLER 
        ApexPages.StandardController stdCancellation = new ApexPages.StandardController(cxl);
        NI_CancellationAllAccountDIsController ctrl = new NI_CancellationAllAccountDIsController(stdCancellation);
        
        // CALL THE GETALLDIS METHOD  
        ctrl.getAllDIs();
        
        // SET THE ISSELECTED ATTRIBUTE OF THE FIRST DI TO TRUE
        ctrl.lstAllDIs.get(0).isSelected = true;
        
        // CALL THE SAVE METHOD  
        ctrl.saveSelected();

        // GET THE SECOND ASSET RECORD 
        //Asset a4 = [SELECT Id, Product2Id FROM Asset WHERE Product2Id =: p2.Id LIMIT 1];
        
        // CREATE A LIST OF INSERTED CANCELLATIONS
        List<NI_Cancellation__c> lstInsertedCancellation = [SELECT Id FROM NI_Cancellation__c];
        
        // VERIFY THERE IS ONE NEW CANCELLATION RECORD
        system.assertEquals(1, lstInsertedCancellation.size());  

        
        Test.stopTest();
        
        
        system.debug(' *** END NI_CancellationAllAccountDIsCtrlrTest.test1() - QUERIES ISSUED = ' + Limits.getQueries());

    }     
    
}