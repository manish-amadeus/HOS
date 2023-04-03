/****************************************************************************************
Name            : AH_RequistionCloneWithLineItems_Test
Author          : Sean Harris
Created Date    : 05/11/2017
Last Mod Date   : 05/30/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for AH_RequistionCloneWithLineItems which is a controller for 
				: AH_RequistionCloneWithLineItems VF Page.
Unit Testing
============
Asserts that Req Line Items have expected counts (loaded to page & cloned) and that 
the cloned Supply Req have expected values for the following fields:
Previous_Renewal__c, Is_Monthly_Renewal__c, Bypass_CEO_Approval__c, Percentage_Increase_Agreed__c,
Percentage_Increase_Offered__c, Requisition_Budget__c 
Asserts that button clicks send user to expected URLs.
******************************************************************************************/
@isTest
public class AH_RequistionCloneWithLineItems_Test 
{

    // =============================================================================================================
    // 		CREATE TEST DATA 
    // =============================================================================================================
    @testSetup static void createTestData() 
    {
        
        // CREATE CUSTOM SETTINGS
        List<RequisitionLineItemCloneSettings__c> lstCS = new List<RequisitionLineItemCloneSettings__c>();
        lstCS.add(new RequisitionLineItemCloneSettings__c(
            Name = 'DIM COMBO TEST 1', 
            General_Ledger_Account__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS',
            Line_of_Business__c = 'Newmarket Traditional', 
            Department__c = '603 - ONDEMAND OPERATIONS', 
            Percentage_Increase_Threshold__c = 10.0));
        lstCS.add(new RequisitionLineItemCloneSettings__c(
            Name = 'DIM COMBO TEST 2', 
            General_Ledger_Account__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS',
            Line_of_Business__c = 'Newmarket Traditional', 
            Department__c = '602 - ONDEMAND SUBSCRIPTIONS', 
            Percentage_Increase_Threshold__c = 10.0));        
        database.insert(lstCS); 
        
        // CREATE TEST USER
        List<User> lstUserInsert = new List<User>();
        User u1 = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        u1.Alias = 'SA01TST'; 
        lstUserInsert.add(u1);
        Database.insert(lstUserInsert); 
        
        // CREATE REQUISITE TEST RECORDS FOR CREATING TEST SCMC__Requisition_Line_Item__c RECORDS 
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;         
		List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account]);
        system.assertEquals(1, lstAccountAsserts.Size(), 'Failed to create test Account record in AH_ActivityLineItemOpptyExt_Test.testActivityLineItemOpptyExt()');         

        NI_TestClassData.createSCMCurrency();
        SCMC__ICP__c v1 = NI_TestClassData.createICP('APEX TEST ICP');
        insert v1;
        
        SCMC__Warehouse__c v2 = NI_TestClassData.createWarehouse('APEX TEST WAREHOUSE', v1.Id);
        insert v2;
        
        SCMC__Supplier_Site__c v3 = NI_TestClassData.createSupplierSite('APEX TEST SUPPLIER SITE', a.Id);
        insert v3;
        
        // CREATE 2 SCMC__Requisition_Line_Item__c TEST RECORDS 
        SCMC__Requisition__c req1 = NI_TestClassData.createRequisition(v2.Id, v3.Id);
        req1.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 1';
        insert req1;

        SCMC__Requisition__c req2 = NI_TestClassData.createRequisition(v2.Id, v3.Id);
        req2.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 2';
        insert req2;        
                
Test.startTest();        
        
        // GET SCMC__Requisition_Line_Item__c RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.SCMC__Requisition_Line_Item__c; 
        Map<String, Schema.RecordTypeInfo> RequisitionLineItemRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id RecTypeId = RequisitionLineItemRecordTypeInfo.get('Non-Capital').getRecordTypeId();        
        
        // INSERT 5 SCMC__Requisition_Line_Item__c RECORDS 
        List<SCMC__Requisition_Line_Item__c> lstRLIs = new List<SCMC__Requisition_Line_Item__c>();
        
        SCMC__Requisition_Line_Item__c ril1 = NI_TestClassData.createRequisitionLines(v2.Id, v3.Id, req1.Id, RecTypeId);
        ril1.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril1.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril1.Department_Dimension_3__c = '603 - ONDEMAND OPERATIONS';        
        ril1.Budgeted__c = 'Yes';
        ril1.Contractor__c = 'No';     
        ril1.SCMC__Description__c = 'Licensing costs #1 May 2017';
        ril1.Item_Part_Number__c = 'Enrollment: #1';
        ril1.SCMC__Quantity__c = 1;
        ril1.Unit_Cost__c = 1000;        
        lstRLIs.add(ril1);

        SCMC__Requisition_Line_Item__c ril2 = NI_TestClassData.createRequisitionLines(v2.Id, v3.Id, req1.Id, RecTypeId);
        ril2.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril2.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril2.Department_Dimension_3__c = '603 - ONDEMAND OPERATIONS';        
        ril2.Budgeted__c = 'Yes';
        ril2.Contractor__c = 'No';     
        ril2.SCMC__Description__c = 'Licensing costs #2 May 2017';
        ril2.Item_Part_Number__c = 'Enrollment: #2';
        ril2.SCMC__Quantity__c = 1;
        ril2.Unit_Cost__c = 1000;        
        lstRLIs.add(ril2);        

        SCMC__Requisition_Line_Item__c ril3 = NI_TestClassData.createRequisitionLines(v2.Id, v3.Id, req1.Id, RecTypeId);
        ril3.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril3.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril3.Department_Dimension_3__c = '603 - ONDEMAND OPERATIONS';        
        ril3.Budgeted__c = 'Yes';
        ril3.Contractor__c = 'No';     
        ril3.SCMC__Description__c = 'Licensing costs #3 May 2017';
        ril3.Item_Part_Number__c = 'Enrollment: #3';
        ril3.SCMC__Quantity__c = 1;
        ril3.Unit_Cost__c = 1000;        
        lstRLIs.add(ril3);   

        SCMC__Requisition_Line_Item__c ril4 = NI_TestClassData.createRequisitionLines(v2.Id, v3.Id, req1.Id, RecTypeId);
        ril4.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril4.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril4.Department_Dimension_3__c = '603 - ONDEMAND OPERATIONS';        
        ril4.Budgeted__c = 'Yes';
        ril4.Contractor__c = 'No';     
        ril4.SCMC__Description__c = 'Licensing costs #4 May 2017';
        ril4.Item_Part_Number__c = 'Enrollment: #4';
        ril4.SCMC__Quantity__c = 1;
        ril4.Unit_Cost__c = 1000;        
        lstRLIs.add(ril4);

        SCMC__Requisition_Line_Item__c ril5 = NI_TestClassData.createRequisitionLines(v2.Id, v3.Id, req2.Id, RecTypeId);
        ril5.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril5.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril5.Department_Dimension_3__c = '602 - ONDEMAND SUBSCRIPTIONS';        
        ril5.Budgeted__c = 'Yes';
        ril5.Contractor__c = 'No';     
        ril5.SCMC__Description__c = 'Licensing costs #5 May 2017';
        ril5.Item_Part_Number__c = 'Enrollment: #5';
        ril5.SCMC__Quantity__c = 1;
        ril5.Unit_Cost__c = 1000;        
        lstRLIs.add(ril5);
        
        database.insert(lstRLIs);

        List<AH_Requisition_Fields_to_Clone__c> fieldsToCloneList = new List<AH_Requisition_Fields_to_Clone__c>();
        AH_Requisition_Fields_to_Clone__c custSett1 = new AH_Requisition_Fields_to_Clone__c();
        custSett1.Name = 'Company';
        custSett1.Requisition_Field_API_Name__c = 'Company__c';
        fieldsToCloneList.add(custSett1);
        Database.insert(fieldsToCloneList);
Test.stopTest();
        
    }

    // =============================================================================================================
    // 		TEST DATA CREATED
    // =============================================================================================================    
    @isTest static void testDataCreated1()
    {

        Test.startTest();
    	User u = [SELECT Id FROM User WHERE Alias = 'SA01TST'];
        SCMC__Requisition__c req = [SELECT Id, Name, Requisition_Budget__c FROM SCMC__Requisition__c WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 1'];
		
		system.assertEquals(4000, req.Requisition_Budget__c, 'Unexpected rollup summary amount found');
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_RequistionCloneWithLineItems;

        // ADD URL PARAM
        pageRef.getParameters().put('id', req.Id);
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef);       
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_RequistionCloneWithLineItems ctrl = new AH_RequistionCloneWithLineItems(new ApexPages.StandardController(req));            

        ctrl.loadItems();
        
        // ASSERT THAT THE ACTIVITY LINE ITEM WAS LOADED
        system.assertEquals(4, ctrl.lstReqLineItems.size(), 'Unexpected count of Req Line Items loaded into VF page found');

        PageReference prAfterClone = ctrl.doClone();
        Id newId = ctrl.newReq.Id;        
		system.assertEquals('/' + newId, prAfterClone.getUrl());
        
        SCMC__Requisition__c newReqisistion = [SELECT Id, Name, Requisition_Budget__c, Percentage_Increase_Agreed__c, Percentage_Increase_Offered__c, 
                                               Previous_Renewal__c, Is_Monthly_Renewal__c, Bypass_CEO_Approval__c  
                                               FROM SCMC__Requisition__c WHERE Id =: newId];
        
        system.assertEquals(req.Id, newReqisistion.Previous_Renewal__c, 'Cloned Requistion is has mismatched Previous Renewal lookup.');
        system.assertEquals(true, newReqisistion.Is_Monthly_Renewal__c, 'Unexpected Monthly Renewal checkbox value on cloned Requistion.');
        system.assertEquals(true, newReqisistion.Bypass_CEO_Approval__c, 'Unexpected Bypass CEO Approval checkbox value on cloned Requistion.');
        system.assertEquals(0.0, newReqisistion.Percentage_Increase_Agreed__c, 'Unexpected Percentage Increase Agreed value on cloned Requistion.');
        system.assertEquals(0.0, newReqisistion.Percentage_Increase_Offered__c, 'Unexpected Percentage Increase Offered checkbox value on cloned Requistion.');
        
        List<SCMC__Requisition_Line_Item__c> lstRLIsAsserts = new List<SCMC__Requisition_Line_Item__c>(
            [SELECT Id FROM SCMC__Requisition_Line_Item__c WHERE SCMC__Requisition__c =: newId]
        );
        system.assertEquals(4, lstRLIsAsserts.size(), 'Unexpected count of Req Line Items cloned');
        
        Test.stoptest();
    }

    // =============================================================================================================
    // 		TEST DATA CREATED
    // =============================================================================================================    
    @isTest static void testDataCreated2()
    {
 		Test.startTest();
    	User u = [SELECT Id FROM User WHERE Alias = 'SA01TST'];
        SCMC__Requisition__c req = [SELECT Id, Name, Requisition_Budget__c FROM SCMC__Requisition__c WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 2'];
		
		system.assertEquals(1000, req.Requisition_Budget__c, 'Unexpected rollup summary amount found');
        
        // =============================================================================================================
        // 		VISUALFORCE PAGE TESTING
        // =============================================================================================================
                
        // PAGE REFERENCE        
        PageReference pageRef = Page.AH_RequistionCloneWithLineItems;

        // ADD URL PARAM
        pageRef.getParameters().put('id', req.Id);
        
        // SET TEST PAGE
		Test.setCurrentPage(pageRef);       
        system.assertEquals('/apex/ah_requistionclonewithlineitems?id=' + req.Id, pageRef.getUrl());
        
        // INSTANTIATE VISUALFORCE PAGE CONTROLLER
        AH_RequistionCloneWithLineItems ctrl = new AH_RequistionCloneWithLineItems(new ApexPages.StandardController(req));            

        ctrl.loadItems();
        
        // ASSERT THAT THE ACTIVITY LINE ITEM WAS LOADED
        system.assertEquals(1, ctrl.lstReqLineItems.size(), 'Unexpected Req Line Items loaded into VF page found');

        PageReference prAfterClone = ctrl.doClone();
        Id newId = ctrl.newReq.Id;        
		system.assertEquals('/' + newId, prAfterClone.getUrl());

        Test.setCurrentPage(pageRef);

        PageReference prAfterCancel = ctrl.cancelClone();       
		system.assertEquals('/' + req.Id, prAfterCancel.getUrl());
		
        Test.stopTest();
    }    

}