/****************************************************************************************
Name            : NI_ReqLineItem_TriggerHandlerTest Test Class
Author          : Stuart Emery
Created Date    : 6/7/2016
Last Mod Date   : 12/28/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018180
Description     : test Class for NI_RequisitionLineItem_TriggerHandler Class
: UPDATED 12/28/2017 PER NICC-025314
: 
******************************************************************************************/
@isTest
public class NI_ReqLineItem_TriggerHandler_Test {
    
    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        test.startTest();  
        
        system.debug(' *** NI_ReqLineItem_TriggerHandler_Test.createTestData() - START ***'); 
        
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
        
        system.debug(' ****** lstCS.size() ***** :' + lstCS.size());
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.SCMC__Requisition_Line_Item__c; 
        system.debug(' ****** cfrSchema ***** :' + cfrSchema);
        Map<String, Schema.RecordTypeInfo> ReqLineItemRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        system.debug(' ****** MAP - ReqLineItemRecordTypeInfo.size() ***** :' + ReqLineItemRecordTypeInfo.size());
        Id rtCapitalEquipment = ReqLineItemRecordTypeInfo.get('Capital Equipment').getRecordTypeId();
        system.debug(' ******RECORDTYPE ID ***  :' + rtCapitalEquipment);
        
        // CREATE A TEST USER FOR THE MANAGER OF THE MANAGER OF THE MANAGER OF THE REQUISITION OWNER
        User mgrThirdLevel = NI_TestClassData.createTestUser(1, 'NI Administrator');
        mgrThirdLevel.FirstName = 'Apex';
        mgrThirdLevel.LastName = 'Testuser';
        mgrThirdLevel.Purchase_Approval_Authority__c = 125000;
        insert mgrThirdLevel;
        system.debug('mgrThirdLevel.Id  ' + mgrThirdLevel.Id);
        
        // CREATE A TEST USER FOR THE MANAGER OF THE MANAGER OF THE REQUISITION OWNER
        User mgrSecondLevel = NI_TestClassData.createTestUser(2, 'NI Administrator');
        mgrSecondLevel.FirstName = 'Apex2';
        mgrSecondLevel.ManagerId = mgrThirdLevel.Id;
        mgrSecondLevel.LastName = 'Testuser2';
        mgrSecondLevel.Purchase_Approval_Authority__c = 20000;
        insert mgrSecondLevel;
        system.debug('mgrSecondLevel.Id  ' + mgrSecondLevel.Id);
        
        // CREATE A TEST USER FOR THE MANAGER OF THE REQUISITION OWNER
        User mgrFirstLevel = NI_TestClassData.createTestUser(3, 'NI Administrator');
        mgrFirstLevel.FirstName = 'Apex3';
        mgrFirstLevel.ManagerId = mgrSecondLevel.Id;
        mgrFirstLevel.LastName = 'Testusr3';
        mgrFirstLevel.Purchase_Approval_Authority__c = 5000;
        insert mgrFirstLevel;
        system.debug('mgrFirstLevel.Id  ' + mgrFirstLevel.Id);
        
        // CREATE A TEST USER FOR THIRD LEVEL SUPPLY REQUISITION OVERRIDE OF THE REQUISITION OWNER
        User overrideThirdLevel = NI_TestClassData.createTestUser(11, 'NI Administrator');
        overrideThirdLevel.FirstName = 'Third Level';
        overrideThirdLevel.LastName = 'Override Testuser';
        overrideThirdLevel.Purchase_Approval_Authority__c = 125000;
        insert overrideThirdLevel;
        system.debug('overrideThirdLevel.Id  ' + overrideThirdLevel.Id);
        
        // CREATE A TEST USER FOR THE SECOND LEVEL SUPPLY REQUISITION OVERRIDE OF THE REQUISITION OWNER
        User overrideSecondLevel = NI_TestClassData.createTestUser(12, 'NI Administrator');
        overrideSecondLevel.FirstName = 'Second Level';
        overrideSecondLevel.Supply_Req_Manager_Approval_Override__c = overrideThirdLevel.Id;
        overrideSecondLevel.LastName = 'Override Testuser2';
        overrideSecondLevel.Purchase_Approval_Authority__c = 20000;
        insert overrideSecondLevel;
        system.debug('overrideSecondLevel.Id  ' + overrideSecondLevel.Id);
        
        // CREATE A TEST USER FOR THE FIRST LEVEL SUPPLY REQUISITION OVERRIDE OF THE REQUISITION OWNER
        User overrideFirstLevel = NI_TestClassData.createTestUser(13, 'NI Administrator');
        overrideFirstLevel.FirstName = 'First Level';
        overrideFirstLevel.Supply_Req_Manager_Approval_Override__c = overrideSecondLevel.Id;
        overrideFirstLevel.LastName = 'Override Testuser3';
        overrideFirstLevel.Purchase_Approval_Authority__c = 5000;
        insert overrideFirstLevel;
        system.debug(' overrideFirstLevel.Id  ' + overrideFirstLevel.Id);
        
        // CREATE A TEST USER FOR THE REQUISITION OWNER
        User owner = NI_TestClassData.createTestUser(4, 'NI Administrator');
        owner.FirstName = 'Apex4';
        owner.ManagerId = mgrFirstLevel.Id;
        owner.LastName = 'Testuser4';
        insert owner;
        system.debug('owner.Id  ' + owner.Id);
        
        // CREATE A TEST USER FOR THE REQUISITION OWNER THAT HAS THE "Supply Req Manager Approval Override" FIELD POPULATED
        User uReqOwner = NI_TestClassData.createTestUser(14, 'NI Administrator');
        uReqOwner.FirstName = 'Apex14';
        uReqOwner.Supply_Req_Manager_Approval_Override__c = overrideFirstLevel.Id;
        uReqOwner.LastName = 'Testuser14';
        insert uReqOwner;
        system.debug('uReqOwner.Id  ' + uReqOwner.Id);
        
        //CREATE SCM CURRENCY
        try{NI_TestClassData.createSCMCurrency();}
        catch(Exception e){}
        
        //CREATE A TEST INVENTORY CONTROL POINT RECORD(ICP)
        SCMC__ICP__c testICP = NI_TestClassData.createICP('test ICP');
        insert testICP;
        system.debug('testICP.ID' + testICP.Id);
        
        //CREATE A TEST WAREHOUSE
        SCMC__Warehouse__c testWarehouse = NI_TestClassData.createWarehouse('test Warehouse', testICP.id);
        insert testWarehouse;
        system.debug('testWarehouse.ID' + testWarehouse.Id);
        
        // CREATE TEST ACCOUNT RECORD 
        Account testVendor = NI_TestClassData.createTestAccount(1);
        testVendor.Name = 'APEX TEST VENDOR'; 
        insert testVendor;
        system.debug('testVendor.ID' + testVendor.Id);
        
        //CREATE A TEST SUPPLIER SITE
        SCMC__Supplier_Site__c testSupplierSite = NI_TestClassData.createSupplierSite('test Site', testVendor.id);
        insert testSupplierSite;
        system.debug('testSupplierSite.ID' + testSupplierSite.Id);
        
        //test.stopTest();        
        
        //CREATE A TEST REQUISITION RECORD
        //SCMC__Requisition__c testRequisition = NI_TestClassData.createRequisition(testWarehouse.id, testSupplierSite.id);
        //insert testRequisition;
        
        //CREATE A TEST REQUISITION LINE ITEM
        //SCMC__Requisition_Line_Item__c testReqLineItem = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, testRequisition.id, rtCapitalEquipment);
        //insert testReqLineItem; 
        
        // CREATE 3 SCMC__Requisition_Line_Item__c TEST RECORDS 
        SCMC__Requisition__c req0 = NI_TestClassData.createRequisition(testWarehouse.Id, testSupplierSite.Id);
        req0.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 0';
        insert req0;
        system.debug('req0.ID' + req0.Id);
        
        SCMC__Requisition__c req1 = NI_TestClassData.createRequisition(testWarehouse.Id, testSupplierSite.Id);
        req1.Previous_Renewal__c = req0.Id;
        req1.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 1';
        insert req1;
        system.debug('req1.ID' + req1.Id);
        
        SCMC__Requisition__c req2 = NI_TestClassData.createRequisition(testWarehouse.Id, testSupplierSite.Id);
        req2.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 2';
        insert req2;        
        system.debug('req2.ID' + req2.Id);
        
        
        // GET SCMC__Requisition_Line_Item__c RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema2 = Schema.SObjectType.SCMC__Requisition_Line_Item__c; 
        Map<String, Schema.RecordTypeInfo> RequisitionLineItemRecordTypeInfo = cfrSchema2.getRecordTypeInfosByName(); 
        Id RecTypeId = RequisitionLineItemRecordTypeInfo.get('Non-Capital').getRecordTypeId();        
        
        system.debug('RequisitionLineItemRecordTypeInfo.SIze()' + RequisitionLineItemRecordTypeInfo.Size());
        system.debug('RecTypeId' + RecTypeId);
        
        // INSERT 5 SCMC__Requisition_Line_Item__c RECORDS 
        List<SCMC__Requisition_Line_Item__c> lstRLIs = new List<SCMC__Requisition_Line_Item__c>();
        
       /** SCMC__Requisition_Line_Item__c ril6 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req0.Id, RecTypeId);
        ril6.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril6.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril6.Department_Dimension_3__c = '603 - ONDEMAND OPERATIONS';        
        ril6.Budgeted__c = 'Yes';
        ril6.Contractor__c = 'No';     
        ril6.SCMC__Description__c = 'Licensing costs #6 May 2017';
        ril6.Item_Part_Number__c = 'Enrollment: #6';
        ril6.SCMC__Quantity__c = 3;
        ril6.Unit_Cost__c = 1000;
        lstRLIs.add(ril6);
        **/        
        
        
        SCMC__Requisition_Line_Item__c ril1 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req1.Id, RecTypeId);
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
        
        
        SCMC__Requisition_Line_Item__c ril2 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req1.Id, RecTypeId);
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
        
        
        SCMC__Requisition_Line_Item__c ril3 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req1.Id, RecTypeId);
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
        
        
        
        SCMC__Requisition_Line_Item__c ril4 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req1.Id, RecTypeId);
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
        
        
        SCMC__Requisition_Line_Item__c ril5 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req2.Id, RecTypeId);
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
        
        SCMC__Requisition_Line_Item__c ril6 = NI_TestClassData.createRequisitionLines(testWarehouse.Id, testSupplierSite.Id, req0.Id, RecTypeId);
        ril6.General_Ledger_Account_list__c = '63600000 - SOFTWARE LICENSE AND SUBSCRIPTIONS';
        ril6.Line_of_Business_Dimension_2__c = 'Newmarket Traditional';
        ril6.Department_Dimension_3__c = '603 - ONDEMAND OPERATIONS';        
        ril6.Budgeted__c = 'Yes';
        ril6.Contractor__c = 'No';     
        ril6.SCMC__Description__c = 'Licensing costs #6 May 2017';
        ril6.Item_Part_Number__c = 'Enrollment: #6';
        ril6.SCMC__Quantity__c = 3;
        ril6.Unit_Cost__c = 1000;
        lstRLIs.add(ril6);
                
        
        system.debug('lstRLIs.Size() : ' + lstRLIs.Size() );
        database.insert(lstRLIs);
        system.debug('lstRLIs.Size() : ' + lstRLIs.Size() );  
         test.stopTest();   
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: Insert Requisition and Requisition Line Items
    // ======================================================================================================================================= //
    @isTest static void ReqLineItemInsertTest()     
    {   
        
        test.startTest();  
        system.debug(' *** NI_ReqLineItem_TriggerHandler_Test.ReqLineItemTest1() - START ***');     
        User u = [SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE FirstName = 'Apex4' AND LastName = 'Testuser4'];
        
        system.debug('Owner Manager: ' + u.ManagerId);
        system.debug('Owner Manager Manager: ' + u.Manager.ManagerId);
        
        system.runAs(u)        
        {
            SCMC__Warehouse__c wh = [SELECT Id FROM SCMC__Warehouse__c];
            SCMC__Supplier_Site__c ss = [SELECT Id FROM SCMC__Supplier_Site__c];
            
            //CREATE A TEST REQUISITION RECORD
            SCMC__Requisition__c testRequisition = NI_TestClassData.createRequisition(wh.id, ss.id);
            testRequisition.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ A';
            insert testRequisition;
            
            Id reqlinetypeid = [Select id from recordtype where sobjecttype = 'SCMC__Requisition_Line_Item__c' and name = 'Description'].id;
            
            //CREATE A TEST REQUISITION LINE ITEM
            SCMC__Requisition_Line_Item__c testReqLineItem = NI_TestClassData.createRequisitionLines(wh.Id, ss.Id, testRequisition.id, reqlinetypeid);
            testReqLineItem.SCMC__Budget__c = 6000;
            testReqLineItem.SCMC__Quantity__c = 6;
            testReqLineItem.Unit_Cost__c = 1000;
            insert testReqLineItem;
        }
        
        SCMC__Requisition__c req2 = [SELECT Id, First_Level_Approver__c, Second_Level_Approver__c 
                                     FROM SCMC__Requisition__c
                                     WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ A'];  
        
        //ASSERT THAT THE APPROVER LEVEL FIELDS HAVE BEEN UPDATED WITH THE CORRECT VALUES
        system.assertEquals(u.ManagerId,req2.First_Level_Approver__c);
        system.assertEquals(u.Manager.ManagerId,req2.Second_Level_Approver__c);
        
        
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: Update Requisition Line Items
    // ======================================================================================================================================= //
    @isTest static void ReqLineItemUpdateTest()     
    {   
        
       
        
        system.debug(' *** NI_ReqLineItem_TriggerHandler_Test.ReqLineItemUpdateTest() - START ***');     
        User u = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE FirstName = 'Apex4' AND LastName = 'Testuser4'];
        
        system.runAs(u)        
        {
            
            SCMC__Warehouse__c wh = [SELECT Id FROM SCMC__Warehouse__c];
            SCMC__Supplier_Site__c ss = [SELECT Id FROM SCMC__Supplier_Site__c];
            
            //CREATE A TEST REQUISITION RECORD
            SCMC__Requisition__c testRequisition = NI_TestClassData.createRequisition(wh.id, ss.id);
            testRequisition.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ B';
            insert testRequisition;
            
            Id reqlinetypeid = [Select id from recordtype where sobjecttype = 'SCMC__Requisition_Line_Item__c' and name = 'Description'].id;
            
            //CREATE A TEST REQUISITION LINE ITEM
            SCMC__Requisition_Line_Item__c testReqLineItem = NI_TestClassData.createRequisitionLines(wh.Id, ss.Id, testRequisition.id, reqlinetypeid);
            testReqLineItem.SCMC__Budget__c = 6000;
            testReqLineItem.SCMC__Quantity__c = 6;
            testReqLineItem.Unit_Cost__c = 1000;
            testReqLineItem.SCMC__Description__c = 'APEX TEST RLI B';
            insert testReqLineItem;
            
        }
        
        SCMC__Requisition_Line_Item__c rl = [SELECT Id, SCMC__Quantity__c, SCMC__Budget__c, Unit_Cost__c 
                                             FROM SCMC__Requisition_Line_Item__c
                                             WHERE SCMC__Description__c = 'APEX TEST RLI B'];
         test.startTest();  
        //UPDATE THE REQUISITION LINE ITEM TO INVOKE THE LOGIC TO POPULATE THE THIRD LEVEL APPROVER ON THE REQUISITION
        rl.SCMC__Quantity__c = 30;
        rl.SCMC__Budget__c = 30000;
        update rl;
        
        SCMC__Requisition__c req2 = [SELECT Id, First_Level_Approver__c, Second_Level_Approver__c, Third_Level_Approver__c 
                                     FROM SCMC__Requisition__c
                                     WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ B'];        
        
        //ASSERT THAT THE APPROVER LEVEL FIELDS HAVE BEEN UPDATED WITH THE CORRECT VALUES
        system.assertEquals(u.ManagerId,req2.First_Level_Approver__c);
        system.assertEquals(u.Manager.ManagerId,req2.Second_Level_Approver__c);
        system.assertEquals(u.Manager.Manager.ManagerId,req2.Third_Level_Approver__c);
        
        //UPDATE THE REQUISITION LINE ITEM TO INVOKE THE LOGIC TO REMOVE THE SECOND LEVEL APPROVER AND THIRD LEVEL APPROVER
        rl.SCMC__Quantity__c = 1;
        rl.SCMC__Budget__c = 1000;
        update rl;
        
        SCMC__Requisition__c req3 = [SELECT Id, First_Level_Approver__c, Second_Level_Approver__c, Third_Level_Approver__c 
                                     FROM SCMC__Requisition__c
                                     WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ B'];        
        
        //ASSERT THAT THE APPROVER LEVEL FIELDS HAVE BEEN UPDATED WITH THE CORRECT VALUES
        system.assertEquals(u.ManagerId,req3.First_Level_Approver__c);
        system.assertEquals(null,req3.Second_Level_Approver__c);
        system.assertEquals(null,req3.Third_Level_Approver__c);
        
        test.stopTest();  
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 3: Delete Requisition Line Items
    // ======================================================================================================================================= //
    @isTest static void ReqLineItemDeleteTest()     
    {   
        
        
        system.debug(' *** NI_ReqLineItem_TriggerHandler_Test.ReqLineItemDeleteTest() - START ***');     
        User u = [SELECT Id, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId FROM User WHERE FirstName = 'Apex4' AND LastName = 'Testuser4'];
        
        system.runAs(u)        
        {
            SCMC__Warehouse__c wh = [SELECT Id FROM SCMC__Warehouse__c];
            SCMC__Supplier_Site__c ss = [SELECT Id FROM SCMC__Supplier_Site__c];
            
            //CREATE A TEST REQUISITION RECORD
            SCMC__Requisition__c testRequisition = NI_TestClassData.createRequisition(wh.id, ss.id);
            testRequisition.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ C';
            insert testRequisition;
            
            Id reqlinetypeid = [Select id from recordtype where sobjecttype = 'SCMC__Requisition_Line_Item__c' and name = 'Description'].id;
            
            //CREATE A TEST REQUISITION LINE ITEM
            SCMC__Requisition_Line_Item__c testReqLineItem = NI_TestClassData.createRequisitionLines(wh.Id, ss.Id, testRequisition.id, reqlinetypeid);
            testReqLineItem.SCMC__Budget__c = 5000;
            testReqLineItem.SCMC__Quantity__c = 5;
            testReqLineItem.Unit_Cost__c = 1000;
            insert testReqLineItem;
            
            //CREATE A TEST REQUISITION LINE ITEM
            SCMC__Requisition_Line_Item__c testReqLineItem2 = NI_TestClassData.createRequisitionLines(wh.Id, ss.Id, testRequisition.id, reqlinetypeid);
            testReqLineItem2.SCMC__Budget__c = 25000;
            testReqLineItem2.SCMC__Quantity__c = 5;
            testReqLineItem2.Unit_Cost__c = 5000;
            insert testReqLineItem2;
        }
        
        SCMC__Requisition__c req = [SELECT Id, First_Level_Approver__c, Second_Level_Approver__c, Third_Level_Approver__c 
                                    FROM SCMC__Requisition__c 
                                    WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ C'];  
        
        //ASSERT THAT THE APPROVER LEVEL FIELDS HAVE BEEN UPDATED WITH THE CORRECT VALUES
        system.assertEquals(u.ManagerId,req.First_Level_Approver__c);
        system.assertEquals(u.Manager.ManagerId,req.Second_Level_Approver__c);
        system.assertEquals(u.Manager.Manager.ManagerId,req.Third_Level_Approver__c);
        
        test.startTest();  
        SCMC__Requisition_Line_Item__c rl = [SELECT Id, SCMC__Quantity__c, SCMC__Budget__c, Unit_Cost__c 
                                             FROM SCMC__Requisition_Line_Item__c
                                             WHERE SCMC__Budget__c = 25000];
        
        //DELETE THE REQUISITION LINE ITEM TO INVOKE THE AFTER DELETE LOGIC
        delete rl;
        
        SCMC__Requisition__c req2 = [SELECT Id, First_Level_Approver__c, Second_Level_Approver__c, Third_Level_Approver__c 
                                     FROM SCMC__Requisition__c 
                                     WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ C']; 
        
        //ASSERT THAT THE APPROVER LEVEL FIELDS HAVE BEEN UPDATED WITH THE CORRECT VALUES
        system.assertEquals(u.ManagerId,req2.First_Level_Approver__c);
        system.assertEquals(null,req2.Second_Level_Approver__c);
        system.assertEquals(null,req2.Third_Level_Approver__c);
        
        test.stopTest();  
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 4: Insert Requisition and Requisition Line Items to Test for Supply_Req_Manager_Approval_Override__c 
    // ======================================================================================================================================= //
    @isTest static void ReqLineItemInsertSupplyReqMgrOverrideTest()     
    {   
        
        test.startTest();  
        system.debug(' *** NI_ReqLineItem_TriggerHandler_Test.ReqLineItemInsertSupplyReqMgrOverrideTest() - START ***');     
        User u = [SELECT Id, Supply_Req_Manager_Approval_Override__c, Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__c,
                  Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__c
                  FROM User WHERE FirstName = 'Apex14' AND LastName = 'Testuser14'];
        
        system.runAs(u)        
        {
            SCMC__Warehouse__c wh = [SELECT Id FROM SCMC__Warehouse__c];
            SCMC__Supplier_Site__c ss = [SELECT Id FROM SCMC__Supplier_Site__c];
            
            //CREATE A TEST REQUISITION RECORD
            SCMC__Requisition__c testRequisition = NI_TestClassData.createRequisition(wh.id, ss.id);
            testRequisition.SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ A';
            insert testRequisition;
            
            Id reqlinetypeid = [Select id from recordtype where sobjecttype = 'SCMC__Requisition_Line_Item__c' and name = 'Description'].id;
            
            //CREATE A TEST REQUISITION LINE ITEM
            SCMC__Requisition_Line_Item__c testReqLineItem = NI_TestClassData.createRequisitionLines(wh.Id, ss.Id, testRequisition.id, reqlinetypeid);
            testReqLineItem.SCMC__Budget__c = 60000;
            testReqLineItem.SCMC__Quantity__c = 6;
            testReqLineItem.Unit_Cost__c = 10000;
            insert testReqLineItem;
        }
        
        SCMC__Requisition__c req2 = [SELECT Id, First_Level_Approver__c, Second_Level_Approver__c, Third_Level_Approver__c 
                                     FROM SCMC__Requisition__c
                                     WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ A'];  
        
        //ASSERT THAT THE APPROVER LEVEL FIELDS HAVE BEEN UPDATED WITH THE CORRECT VALUES
        system.assertEquals(u.Supply_Req_Manager_Approval_Override__c,req2.First_Level_Approver__c);
        system.assertEquals(u.Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__c,req2.Second_Level_Approver__c);
        system.assertEquals(u.Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__r.Supply_Req_Manager_Approval_Override__c,req2.Third_Level_Approver__c);
        
        
        test.stopTest();  
        
    }
    
    
    // =============================================================================================================
    // 		TEST DATA CREATED
    // =============================================================================================================    
    @isTest static void testDataCreated1()
    {
        system.debug(' ******** INSIDE testDataCreated1 METHOD ********');
        SCMC__Requisition__c reqInvokeRollup = [SELECT Id, Requisition_Budget__c  
                                                FROM SCMC__Requisition__c
                                                WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 0'];  
        
        system.debug('reqInvokeRollup  :' + reqInvokeRollup );
        
        system.debug('reqInvokeRollup.Requisition_Budget__c  :' + reqInvokeRollup.Requisition_Budget__c );
        system.assertEquals(3000, reqInvokeRollup.Requisition_Budget__c, 'Unexpected rollup summary amount found');     
        
        SCMC__Requisition__c req = [SELECT Id, Name, Requisition_Budget__c, Is_Monthly_Renewal__c, Bypass_CEO_Approval__c, 
                                    Percentage_Increase_Agreed__c, Percentage_Increase_Offered__c, Previous_Renewal__c  
                                    FROM SCMC__Requisition__c 
                                    WHERE SCMC__Requisition_Name__c = 'APEX CLONE TEST REQ 1'];
        
        system.debug('req   :' + req );
        system.debug('req.Requisition_Budget__c :' + req.Requisition_Budget__c );
        system.debug('req.Is_Monthly_Renewal__c  :' + req.Is_Monthly_Renewal__c );
        system.debug('req.Bypass_CEO_Approval__c  :' + req.Bypass_CEO_Approval__c );
        system.debug('req.Percentage_Increase_Agreed__c   :' + req.Percentage_Increase_Agreed__c );
        system.debug('req.Percentage_Increase_Offered__c  :' + req.Percentage_Increase_Offered__c );
        
        
        system.assertEquals(4000, req.Requisition_Budget__c, 'Unexpected rollup summary amount found');        
        system.assertEquals(false, req.Is_Monthly_Renewal__c, 'Unexpected Monthly Renewal checkbox value on related Requistion.');
        system.assertEquals(false, req.Bypass_CEO_Approval__c, 'Unexpected Bypass CEO Approval checkbox value on related Requistion.');
        system.assertNotEquals(0.0, req.Percentage_Increase_Agreed__c, 'Unexpected Percentage Increase Agreed value on related Requistion.');
        system.assertNotEquals(0.0, req.Percentage_Increase_Offered__c, 'Unexpected Percentage Increase Offered checkbox value on related Requistion.');
        
        List<SCMC__Requisition_Line_Item__c> lstRLIsAsserts = new List<SCMC__Requisition_Line_Item__c>(
            [SELECT Id FROM SCMC__Requisition_Line_Item__c WHERE SCMC__Requisition__c =: req.Id]
        );
        
        system.debug(' *** lstRLIsAsserts.size()    :' + lstRLIsAsserts.size() );
        system.assertEquals(4, lstRLIsAsserts.size(), 'Unexpected count of Req Line Items created');        
        
    }    
    
}