/****************************************************************************************
Name            : NI_CancellationChildAccountsCtrlr_Test Class
Author          : Stuart Emery
Created Date    : 06/20/2014
Last Mod Date   : 06/20/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-008353
Description     : Test Class for the NI_CancellationChildAccountsController Class.
                :  
******************************************************************************************/
@isTest 
private class NI_CancellationChildAccountsCtrlr_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {        

        Test.startTest();
                
        //CREATE A TEST PARENT ACCOUNT  
        Account pa = NI_TestClassData.createTestAccount(1);
        pa.Name = 'Test Parent Account for NI_CancellationChildAccountsCtrlr_Test';
        insert pa;
        
        //CREATE A TEST CHILD ACCOUNT  
        Account ca = NI_TestClassData.createTestAccount(2);
        ca.Name = 'Test Child Account for NI_CancellationChildAccountsCtrlr_Test';
        ca.ParentId = pa.Id;
        insert ca;
        
        //CREATE A TEST CHILD ACCOUNT2  
        Account ca2 = NI_TestClassData.createTestAccount(2);
        ca2.Name = 'Test Sibling Account for NI_CancellationChildAccountsCtrlr_Test'; 
        ca2.ParentId = pa.Id;
        insert ca2;   
        
        //CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        // CREATE TEST DEPLOYMENT INSTANCE RECORDS     
        List<NI_DeploymentInstanceIndex__c> lstDeploymentInstanceIndex = new List<NI_DeploymentInstanceIndex__c>(); 
        
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx1); 
        
        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(2, 'APEX TEST INDEX'); 
        lstDeploymentInstanceIndex.add(idx2); 
        
        database.insert(lstDeploymentInstanceIndex);         
        
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
        
        //LIST OF DEPLOYMENT INSTANCE RECORDS TO INSERT
        List<Asset> lstDIsToInsert = new List<Asset>();  
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di1 = NI_TestClassData.createTestAsset(1, pa.Id, p1.Id);
        di1.Name = 'TEST1';
        di1.Status = 'Installed'; 
        di1.Product_Group__c = pgp.Id;
        lstDIsToInsert.add(di1);
        
        //CREATE A DEPLOYMENT INSTANCE RECORD
        Asset di2 = NI_TestClassData.createTestAsset(2, ca.Id, p1.Id);
        di2.Name = 'TEST1';
        di2.Status = 'Installed'; 
        di2.Product_Group__c = pgp.Id;
        lstDIsToInsert.add(di2);
        
        //CREATE A DEPLOYMENT INSTANCE RECORD FOR THE CHILD ACCOUNT2
        Asset di3 = NI_TestClassData.createTestAsset(3, ca2.Id, p1.Id);
        di3.Name = 'TEST3';
        di3.Status = 'Installed'; 
        di3.Product_Group__c = pgp.Id;
        lstDIsToInsert.add(di3);  

        Database.Insert(lstDIsToInsert);    

        //CREATE A TEST NI CANCELLATION RECORD
        Asset pAsset = [SELECT Id, Product2Id
                        FROM Asset
                        WHERE AccountId =: pa.Id];
        
        // CREATE TEST BILLING CONTRACT RECORD
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = pa.Id;
        insert bc;
        
        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id); 
        ali.Product__c = p1.Id;
        ali.Contract_Start_Date__c = Date.today() - 425;
        ali.Contract_End_Date__c = Date.today();
        ali.Renewal_Base_Price__c = 10;
        insert ali;        
        
        // CREATE TEST CANCELATION RECORDS
        
        List<NI_Cancellation__c> lstNICancellationInserts = new List<NI_Cancellation__c>();
        
        NI_Cancellation__c cxl1 = NI_TestClassData.createCancellation(pa.Id);
        cxl1.Account__c = pa.Id;
        cxl1.Product2__c = p1.Id;
        cxl1.Activity_Line_Item__c = ali.Id;
        cxl1.Deployment_Instance__c = di1.Id;
        cxl1.General_Reason__c = 'Affiliation Change';  
        cxl1.Amadeus_RSM__c = UserInfo.getUserId();
        cxl1.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl1.Renewal_Cancellation_Quantity__c = 1; 
        cxl1.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        lstNICancellationInserts.add(cxl1);    
        
        NI_Cancellation__c cxl2 = NI_TestClassData.createCancellation(ca.Id);
        cxl2.Account__c = ca.Id;
        cxl2.Product2__c = p1.Id;
        cxl2.Activity_Line_Item__c = ali.Id;
        cxl2.Deployment_Instance__c = di1.Id;
        cxl2.General_Reason__c = 'Affiliation Change';  
        cxl2.Amadeus_RSM__c = UserInfo.getUserId();
        cxl2.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl2.Renewal_Cancellation_Quantity__c = 1; 
        cxl2.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        lstNICancellationInserts.add(cxl2); 

        NI_Cancellation__c cxl3 = NI_TestClassData.createCancellation(ca2.Id);
        cxl3.Account__c = ca2.Id;
        cxl3.Product2__c = p1.Id;
        cxl3.Activity_Line_Item__c = ali.Id;
        cxl3.Deployment_Instance__c = di1.Id;
        cxl3.General_Reason__c = 'Affiliation Change'; 
        cxl3.Amadeus_RSM__c = UserInfo.getUserId();
        cxl3.Renewal_Cancellation_Requester__c = UserInfo.getUserId();
        cxl3.Renewal_Cancellation_Quantity__c = 1; 
        cxl3.Renewal_Cancellation_Request_DateTime__c = Date.today() + 91;
        lstNICancellationInserts.add(cxl3); 
        
        database.insert(lstNICancellationInserts);
        
        Test.stopTest();

    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: VISUALFORCE PAGE TESTING
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
        
        system.debug(' *** START NI_CancellationChildAccountsCtrlr_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<NI_Cancellation__c> lst = new List<NI_Cancellation__c>([SELECT Id FROM NI_Cancellation__c]);
        system.debug(' *^* # OF CXL RECORDS = ' + lst.size());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'Test Parent Account for NI_CancellationChildAccountsCtrlr_Test'];
        NI_Cancellation__c cxl = [SELECT Id, Activity_Line_Item__c FROM NI_Cancellation__c WHERE Account__c =: a.Id LIMIT 1];       
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
        PageReference pageRef = Page.NI_CancellationChildAccountsVF;
        Test.setCurrentPage(pageRef);
        system.currentPageReference().getParameters().put('id', cxl.Id);
        
        // INSTANTIATE CONTROLLER 
        ApexPages.StandardController stdCancellation = new ApexPages.StandardController(cxl);
        NI_CancellationChildAccountsController ctrl = new NI_CancellationChildAccountsController(stdCancellation);

		system.debug(' *^* ctrl.lstChildAccounts.size() = ' + ctrl.lstChildAccounts.size());
        
        // SET THE ISSELECTED ATTRIBUTE OF THE FIRST CHILD ACCOUNT RECORD TO TRUE
        ctrl.lstChildAccounts.get(0).isSelected = true;
        
        // CALL THE SAVE METHOD  
        ctrl.saveSelected();        
        
/*        
        // CALL THE GETALLDIS METHOD  
        ctrl.getChildAccounts();
        
        // SET THE ISSELECTED ATTRIBUTE OF THE FIRST CHILD ACCOUNT RECORD TO TRUE
        ctrl.lstChildAccounts.get(0).isSelected = true;
        
        // CALL THE SAVE METHOD  
        ctrl.saveSelected();
        

        // GET THE ASSET RECORD OF THE CHILD ACCOUNT 
        Asset cAsset = [SELECT Id,Product2Id
                        FROM Asset
                        WHERE AccountId =: ca.Id];
        
        // CREATE A LIST OF INSERTED CANCELLATIONS
        List<NI_Cancellation__c> lstInsertedCancellation = [SELECT Id, Deployment_Instance__c 
                                                            FROM NI_Cancellation__c
                                                            WHERE Deployment_Instance__c =: cAsset.Id];
        
        // VERIFY THERE IS ONE NEW CANCELLATION RECORD
        system.assertEquals(1,lstInsertedCancellation.size()); 
*/                
        
        
        Test.stopTest();

        system.debug(' *** END NI_CancellationAllAccountDIsCtrlrTest.test1() - QUERIES ISSUED = ' + Limits.getQueries());

    }
    
}