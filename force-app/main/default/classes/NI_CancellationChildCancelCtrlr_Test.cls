/****************************************************************************************
Name            : NI_CancellationChildCancelCtrlr_Test
Author          : Stuart Emery
Created Date    : 01/25/2015
Last Mod Date   : 06/24/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-008353
Description     : Test Class for NI_CancellationChildCancellationCtrlr
                :  
******************************************************************************************/
@isTest
Private class NI_CancellationChildCancelCtrlr_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    { 
        
        Test.startTest();
        
        //CREATE A TEST PARENT ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Test Parent Account for NI_CancellationChildCancelCtrlr_Test';
        insert a;
        
        //CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        insert idx1;
        
        // CREATE TEST PRODUCT RECORD
        Product2 p1 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        p1.DI_Index__c = idx1.Id; 
        p1.Solution_Domain_Global__c = 'CRS';
        insert p1;
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, p1.Id);
        di.Name = 'TEST1';
        di.Status = 'Installed'; 
        di.Product_Group__c = pgp.Id;
        insert di;
        
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
        
        // CREATE A TEST CANCELLATION RECORD
        NI_Cancellation__c cxl1 = NI_TestClassData.createCancellation(a.Id);
        cxl1.Account__c = a.Id;
        cxl1.Product2__c = p1.Id;
        cxl1.Activity_Line_Item__c = ali.Id;
        cxl1.Deployment_Instance__c = di.Id;
        cxl1.Status__c = 'Retained';
        cxl1.General_Reason__c = 'Affiliation Change';  
        cxl1.Amadeus_RSM__c = UserInfo.getUserId();
        cxl1.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl1.Renewal_Cancellation_Quantity__c = 1; 
        cxl1.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        insert cxl1;    
        
        Test.stopTest();
        
    }    
    
    // =======================================================================================================================================
    // = TEST METHOD 1: VISUALFORCE PAGE TESTING
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
        
        system.debug(' *** START NI_CancellationChildCancelCtrlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Parent Account for NI_CancellationChildCancelCtrlr_Test'];
        NI_Cancellation__c cxl = [SELECT Id, Activity_Line_Item__c FROM NI_Cancellation__c WHERE Account__c =: a.Id];       
        Product2 p1 = [SELECT Id FROM Product2 WHERE ProductCode = 'HRM-DFDCQS-01-TEST'];         
        Product_Group__c pgp = [SELECT Id FROM Product_Group__c WHERE Name = 'Apex Test Group'];
        Asset di = [SELECT Id FROM Asset WHERE AccountId =: a.Id];
        Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Account__c =: a.Id];
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Billing_Contract__c =: bc.Id AND Product__c =: p1.Id]; 
        
        
        Test.startTest();
        
        
        // CREATE A TEST CANCELLATION RECORD
        NI_Cancellation__c ccxl = NI_TestClassData.createCancellation(a.Id);
        ccxl.Master_Cancellation_Record__c = cxl.Id;
        ccxl.Account__c = a.Id;
        ccxl.Product2__c = p1.Id;
        ccxl.Activity_Line_Item__c = ali.Id;
        ccxl.Deployment_Instance__c = di.Id;
        ccxl.Status__c = 'Retained';
        ccxl.General_Reason__c = 'Affiliation Change';  
        ccxl.Amadeus_RSM__c = UserInfo.getUserId();
        ccxl.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        ccxl.Renewal_Cancellation_Quantity__c = 1; 
        ccxl.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        insert ccxl; 
        
        // PAGE REFERENCE
        PageReference pageRef = Page.NI_CancellationChildCancellationVF;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('id', cxl.id);
        
        // INSTANTIATE CONTROLLER 
        ApexPages.StandardController stdCancellation = new ApexPages.StandardController(cxl);
        NI_CancellationChildCancellationCtrlr ctrl = new NI_CancellationChildCancellationCtrlr(stdCancellation);
        
        // CALL THE GETALLDIS METHOD 
        ctrl.getChildCancellations();        
        
        // SET THE ISSELECTED ATTRIBUTE OF THE FIRST CHILD ACCOUNT RECORD TO TRUE
        ctrl.lstChildCancellations.get(0).isStatusSelected = true;        
        
        // CALL THE SAVE METHOD  
        ctrl.saveSelected();
        
        
        Test.stopTest(); 
        
        
        // CREATE A LIST OF INSERTED CANCELLATIONS
        List<NI_Cancellation__c> lstCxlAsserts = [SELECT Id, Master_Cancellation_Record__c 
                                                  FROM NI_Cancellation__c
                                                  WHERE Status__c = 'Retained'
                                                  AND Master_Cancellation_Record__c =: cxl.Id];
        
        //VERIFY THERE IS ONE NEW CANCELLATION RECORD
        system.assertEquals(1, lstCxlAsserts.size());
        
    }
    
}