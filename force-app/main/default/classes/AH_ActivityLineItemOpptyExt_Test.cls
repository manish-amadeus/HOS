/****************************************************************************************
Name            : AH_ActivityLineItemOpptyExt_Test
Author          : Sean Harris
Created Date    : 05/11/2017
Last Mod Date   : 08/15/2019
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for the AH_ActivityLineItemOpptyExt
				: 08/14/2019 - Updated from API Version 39 to 46 Per NICC-036683
				: 
******************************************************************************************/
@isTest 
private class AH_ActivityLineItemOpptyExt_Test 
{
    
    static testMethod void testActivityLineItemOpptyExt() 
    {
		
        // =============================================================================================================
        // 		TEST DATA CREATION 
        // =============================================================================================================
        
        Test.startTest();
        
        // CREATE A TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;         
		List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.Size(), 'Failed to create test Account record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');         

        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();

        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = rt;
        insert o;   
        List<Opportunity> lstOpportunityAsserts = new List<Opportunity>([SELECT Id FROM Opportunity]);
        system.assertEquals(1, lstOpportunityAsserts.size(), 'Failed to create test Opportunity record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         
        List<Product_Group__c> lstProductGroupAsserts = new List<Product_Group__c>([SELECT Id FROM Product_Group__c]);
        system.assertEquals(1, lstProductGroupAsserts.size(), 'Failed to create test Product_Group__c record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        insert idx1; 
        List<NI_DeploymentInstanceIndex__c> lstDIIndexAsserts = new List<NI_DeploymentInstanceIndex__c>([SELECT Id FROM NI_DeploymentInstanceIndex__c]);
        system.assertEquals(1, lstDIIndexAsserts.size(), 'Failed to create test NI_DeploymentInstanceIndex__c record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        // CREATE A TEST PRODUCT RECORD
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-DFDCQS-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id;      
        insert prd01;         
        List<Product2> lstProduct2Asserts = new List<Product2>([SELECT Id FROM Product2]);
        system.assertEquals(1, lstProduct2Asserts.size(), 'Failed to create test Product2 record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        // CREATE A TEST BILLING RECORD
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = a.Id;
		insert blgCnrct;         
        List<Billing_Contract__c> lstBillingContractAsserts = new List<Billing_Contract__c>([SELECT Id FROM Billing_Contract__c]);
        system.assertEquals(1, lstBillingContractAsserts.size(), 'Failed to create test Billing_Contract__c record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        // CREATE A TEST ACTIVITY LINE ITEM RECORD
		Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI.Cancel_Line_Item__c = false; 
        actLI.Product__c = prd01.Id; 
        actLI.Contract_Start_Date__c = Date.Today() - 200; 
        actLI.Contract_End_Date__c = Date.Today() + 200; 
        actLI.Units__c = 1; 
        actLI.Status__c = 'Active';
        actLI.Contract_Amount__c = 1000;
        insert actLI;         
        List<Activity_Line_Item__c> lstALIAsserts = new List<Activity_Line_Item__c>([SELECT Id FROM Activity_Line_Item__c]);
        system.assertEquals(1, lstALIAsserts.size(), 'Failed to create test Activity_Line_Item__c record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');   
        
        Test.stopTest();

        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_ActivityLineItemsOpptyView;

        // ADD URL PARAM
        pageRef.getParameters().put('id', o.Id);        
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef); 
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_ActivityLineItemOpptyExt ctrl = new AH_ActivityLineItemOpptyExt(new ApexPages.StandardController(o));            

        // ASSERT THAT THE ACTIVITY LINE ITEM WAS LOADED
        system.assertEquals(1, ctrl.lstActLineItems.size());
            
        // TEST CHECKING AND SAVING "Cancel Line Item" CHECKBOX WITH A FLAGGED FOR CANCELLATION REASON
        ctrl.EnableListEdit(); 
        ctrl.lstActLineItems.get(0).isSelected = true;
        ctrl.lstActLineItems.get(0).ali.Flagged_For_Cancellation_Reason__c = 'Upgrade /Migration';
        ctrl.saveSelected();         
        List<Activity_Line_Item__c> lstALI_AssertChecked = new List<Activity_Line_Item__c>([
            SELECT Id, Cancel_Line_Item__c FROM Activity_Line_Item__c WHERE Id =: actLI.Id]);
        system.assertEquals(true, lstALI_AssertChecked.get(0).Cancel_Line_Item__c);
        
        // TEST UNCHECKING AND SAVING Cancel Line Item CHECKBOX
        ctrl.EnableListEdit(); 
        ctrl.lstActLineItems.get(0).isSelected = false;
        ctrl.saveSelected();         
        List<Activity_Line_Item__c> lstALI_AssertUnChecked = new List<Activity_Line_Item__c>([
            SELECT Id, Cancel_Line_Item__c FROM Activity_Line_Item__c WHERE Id =: actLI.Id]);
        system.assertEquals(false, lstALI_AssertUnChecked.get(0).Cancel_Line_Item__c);

           // TEST CHECKING AND SAVING "Cancel Line Item" CHECKBOX WITHOUT A FLAGGED FOR CANCELLATION REASON
        ctrl.EnableListEdit(); 
        ctrl.lstActLineItems.get(0).isSelected = true;
        ctrl.saveSelected();         
        List<Activity_Line_Item__c> lstALI_AssertCheckedNoReason = new List<Activity_Line_Item__c>([
            SELECT Id, Cancel_Line_Item__c FROM Activity_Line_Item__c WHERE Id =: actLI.Id]);
        system.assertEquals(false, lstALI_AssertCheckedNoReason.get(0).Cancel_Line_Item__c);        
        
        // TEST EDIT THEN CANCEL BUTTONS & VISIBLILTY BOOLEAN 
        ctrl.EnableListEdit(); 
        system.assertEquals(false, ctrl.bDisabled); 
        ctrl.disableListEdit();
        system.assertEquals(true, ctrl.bDisabled);
        
        // TEST POPULATING THE FLAGGED FOR CANCELLATION REASON PICKLIST 
        ctrl.getFlaggForCancellationReasonOptionList();
        
        //TEST THE PARTIAL PAGE UPDATE METHOD
        ctrl.changeSelected();
            
    }
    
}