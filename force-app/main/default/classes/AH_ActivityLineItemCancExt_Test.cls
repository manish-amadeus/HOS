/****************************************************************************************
Name            : AH_ActivityLineItemCancExt_Test
Author          : Ria Chawla
Created Date    : 08/04/2017
Last Mod Date   : 06/20/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for the AH_ActivityLineItemCancExt
				: 
				: 
******************************************************************************************/
@isTest 
public class AH_ActivityLineItemCancExt_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {        

        Test.startTest();
        
        // CREATE TEST FFA RELATED DEPENDENCIES
        c2g__codaGeneralLedgerAccount__c testGLA = ffaTestUtilities.create_IS_GLA();
        c2g__codaCompany__c testCompany1 = ffaTestUtilities.createFFACompany('TEST COMPANY', true, 'USD');
        c2g__codaAccountingCurrency__c testcurr = [SELECT Id FROM c2g__codaAccountingCurrency__c WHERE c2g__ownerCompany__c =: testCompany1.Id LIMIT 1];
        c2g__codaDimension2__c testDimension2 = ffaTestUtilities.createTestDimension2();
        c2g__codaDimension3__c testDimension3 = ffaTestUtilities.createTestDimension3();

        // CREATE TEST ACCOUNT RECORD
        Account a = ffaTestUtilities.createAccount('Test Acc', testGLA.Id);
        a.Name = 'AH_ActivityLineItemCancExt_Test Account';
        a.Force_Month_End_Invoice_Date__c = true;
        update a;

        // CREATE TEST DEPLOYMENT INSTANCE RECORD
        NI_DeploymentInstanceIndex__c idx = new NI_DeploymentInstanceIndex__c();
        idx = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX');
        insert idx;

        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST 1');
        insert pgp;

        // CREATE TEST PRODUCT RECORD
        Product2 p1 = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-PROD2-01', 'Subscription'); 
        p1.DI_Index__c = idx.Id;
        p1.Product_Line_Global__c = 'Delphi.fdc';
        p1.Solution_Domain_Global__c = 'CRS';
        insert p1;

        // CREATE TEST BILLING CONTRACT RECORD
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        insert bc;

        // CREATE TEST ACTIVITY LINE ITEM RECORD
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);   
        ali.Renewal_Base_Price__c = 10;
        ali.Product__c = p1.Id;
        ali.Cancel_Line_Item__c = false; 
        ali.Contract_Start_Date__c = Date.Today() - 200; 
        ali.Contract_End_Date__c = Date.Today() + 200; 
        ali.Units__c = 1; 
        ali.Status__c = 'Active';
        ali.Contract_Amount__c = 1000;
        insert ali;              
        
        // CREATE TEST CANCELATION RECORD
        NI_Cancellation__c cxl = NI_TestClassData.createCancellation(a.Id);
        cxl.Account__c = a.Id;
        cxl.Product2__c = p1.Id;
        cxl.Activity_Line_Item__c = ali.Id;
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
   
        system.debug(' *** START AH_ActivityLineItemCancExt_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());

        Account a = [SELECT Id FROM Account WHERE Name = 'AH_ActivityLineItemCancExt_Test Account'];
        NI_Cancellation__c cxl = [SELECT Id FROM NI_Cancellation__c WHERE Account__c =: a.Id LIMIT 1];
        Billing_Contract__c bc = [SELECT Id FROM Billing_Contract__c WHERE Account__c =: a.Id LIMIT 1];
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Billing_Contract__c =: bc.Id LIMIT 1]; 
        
    
        test.startTest();


        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_ActivityLineItemsCancView;
        
        // ADD URL PARAM
        pageRef.getParameters().put('id', cxl.Id);        
        
        // SET TEST PAGE
        Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_ActivityLineItemCancExt ctrl = new AH_ActivityLineItemCancExt(new ApexPages.StandardController(cxl));            
        
        // ASSERT THAT THE ACTIVITY LINE ITEM WAS LOADED
        system.assertEquals(1, ctrl.lstActLineItems.size());
        
        // TEST CHECKING AND SAVING "Cancel Line Item" CHECKBOX WITH A FLAGGED FOR CANCELLATION REASON
        ctrl.EnableListEdit(); 
        ctrl.lstActLineItems.get(0).isSelected = true;
        ctrl.lstActLineItems.get(0).ali.Flagged_For_Cancellation_Reason__c = 'Upgrade /Migration';
        ctrl.saveSelected();   
        
        List<Activity_Line_Item__c> lstALI_AssertChecked = new List<Activity_Line_Item__c>([
            SELECT Id, Cancel_Line_Item__c FROM Activity_Line_Item__c WHERE Id =: ali.Id]);
        system.assertEquals(true, lstALI_AssertChecked.get(0).Cancel_Line_Item__c);
        
        // TEST UNCHECKING AND SAVING Cancel Line Item CHECKBOX
        ctrl.EnableListEdit(); 
        ctrl.lstActLineItems.get(0).isSelected = false;
        ctrl.saveSelected();      
        
        List<Activity_Line_Item__c> lstALI_AssertUnChecked = new List<Activity_Line_Item__c>([
            SELECT Id, Cancel_Line_Item__c FROM Activity_Line_Item__c WHERE Id =: ali.Id]);
        system.assertEquals(false, lstALI_AssertUnChecked.get(0).Cancel_Line_Item__c);
        
        // TEST CHECKING AND SAVING "Cancel Line Item" CHECKBOX WITHOUT A FLAGGED FOR CANCELLATION REASON
        ctrl.EnableListEdit(); 
        ctrl.lstActLineItems.get(0).isSelected = true;
        ctrl.saveSelected();         
        List<Activity_Line_Item__c> lstALI_AssertCheckedNoReason = new List<Activity_Line_Item__c>([
            SELECT Id, Cancel_Line_Item__c FROM Activity_Line_Item__c WHERE Id =: ali.Id]);
        system.assertEquals(false, lstALI_AssertCheckedNoReason.get(0).Cancel_Line_Item__c);        
        
        // TEST EDIT THEN CANCEL BUTTONS & VISIBLILTY BOOLEAN 
        ctrl.EnableListEdit(); 
        system.assertEquals(false, ctrl.bDisabled); 
        ctrl.disableListEdit();
        system.assertEquals(true, ctrl.bDisabled);
        
        // TEST POPULATING THE FLAGGED FOR CANCELLATION REASON PICKLIST 
        ctrl.getFlaggForCancellationReasonOptionList();
        
        // TEST THE PARTIAL PAGE UPDATE METHOD
        ctrl.changeSelected();

        test.stopTest();
        
        system.debug(' *** END AH_ActivityLineItemCancExt_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());

    }     
    
}