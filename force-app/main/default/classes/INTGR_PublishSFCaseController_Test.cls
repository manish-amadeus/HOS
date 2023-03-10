/****************************************************************************************
Name            : INTGR_PublishSFCaseController_Test
Author          : Princy Jain
Created Date    : 06/06/2018
Last Mod Date   : 08/26/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     :
                :
****************************************************************************************/
@isTest
public class INTGR_PublishSFCaseController_Test
{

	// =======================================================================================================================================
	// = CREATE TEST DATA
	// =======================================================================================================================================
	@testSetup static void createTestData()
	{

		// CREATE ALL LEGACY INTEGRATION CUSTOM SETTINGS
		NI_TestClassData.createTestWinaproachServiceNowSettings();

		// UPDATE ServiceNowIncidentSettings__c.AccountId__c WITH FAKE IHG ACCOUNT ID
		Account a = NI_TestClassData.createTestAccount(1);
		a.Name = 'INTGR_PublishSFCaseController_Test IHG TEST ACCOUNT';
		insert a;

		ServiceNowIncidentSettings__c sncs = [SELECT Id, AccountId__c FROM ServiceNowIncidentSettings__c WHERE Name = 'Default'];
		sncs.AccountId__c = a.Id;
		update sncs;

		User cUser = NI_TestClassData.createTestUser(111, 'System Administrator');
		cUser.Email = 'testuserZzzzzz' + 111 + '@salesforce.com';
		cUser.Alias = '111user';
		insert cUser;

		// CREATE NON-LEGACY ACCOUNT
		Account a1 = NI_TestClassData.createTestAccount(2);
		a1.Name = 'ACCOUNT WITH INTGR APEX TEST';
		insert a1;

		Account a2 = NI_TestClassData.createTestAccount(3);
		a2.Name = 'APEX TEST NO INTGR';
		insert a2;

		// CREATE INTEGRATION ACCOUNT
		INTGR_Account__c acc = NI_TestClassData.createTestINTGR_Account(1, a1.Id, cUser.Id);
		acc.Name = 'Big Richards Inn';
		acc.Active__c = true;
		acc.External_Integration_Name__c = 'SANDBOX';
		insert acc;

		// CREATE INTEGRATION FIELD MAPPING
		List<INTGR_Field_Mapping__c> fMapping = NI_TestClassData.createTestINTGR_AccountMapping(1, acc.Id);
		insert fMapping;

		Map<String, String> srcTargetFieldMap1 = new Map<String, String>();
		srcTargetFieldMap1.put('Description__c', 'Description');

		// INSERT TEST CASE RECORDS
		Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
		List<Case> lstCaseInserts = new List<Case>();

		Case cs1 = NI_TestClassData.createTestCase(1, a1.Id);
		cs1.Subject = 'APEX TEST - CASE WITH INTGR ACCOUNT';
		cs1.Integration_Account__c = acc.Id;
		cs1.RecordTypeId = RecordTypeIdCase;
		cs1.Customer_Name__c = 'Lou Saynus';
		lstCaseInserts.add(cs1);

		Case cs2 = NI_TestClassData.createTestCase(2, a2.Id);
		cs2.Subject = 'APEX TEST - CASE WITHOUT INTGR ACCOUNT';
		cs2.RecordTypeId = RecordTypeIdCase;
		lstCaseInserts.add(cs2);

		Case cs3 = NI_TestClassData.createTestCase(3, a.Id);
		cs3.Subject = 'APEX TEST - LEGACY INTEGRATION CASE';
		cs3.RecordTypeId = RecordTypeIdCase;
		cs3.Priority = '3';
		cs3.type = 'Inquiry';
		cs3.Customer_Severity__c = '1';
		cs3.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
		cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
		cs3.Status = 'Recovered';
		cs3.Winaproach_Logger__c = 'test';
		cs3.Description = 'Test description';
		cs3.Cause_Id_Code__c = 'Application';
		cs3.Resolution_Code__c = 'Environment';
		cs3.Resolution_Summary__c = 'Resolved';
		cs3.Reject_Reason_Code__c = 'Change required';
		cs3.Winaproach_Logger_Phone_Number__c = '123456';
		cs3.Winaproach_Owner_Group__c = 'MHDHOT';
		cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5);
		cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
		cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
		cs3.Hotel_Code__c = '123';
		cs3.Origin = 'Win@proach Integration';
		cs3.System_Affected__c = 'Disaster Recovery';
		lstCaseInserts.add(cs3);

		database.insert(lstCaseInserts);

		CaseComment cc = NI_TestClassData.createTestCaseComment(1, cs3.Id);
		insert cc;

        // CREATE A TEST FILE RECORD        
        ContentVersion cv = NI_TestClassData.createContentVersion();
        insert cv;
        
        ContentVersion cv2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id LIMIT 1];
        List<ContentDocument> lstCDocs = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);   
        
        ContentDocumentLink cl = NI_TestClassData.createContentDocumentLink(cv2.ContentDocumentId, cs3.Id);
        insert cl;		

	}

	// =======================================================================================================================================
	// = TEST METHOD 1: TEST CREATE INCIDENT (LEGACY)
	// =======================================================================================================================================
	static testmethod void test1()
	{

		Case cs = [SELECT Id, AccountId FROM Case WHERE Subject = 'APEX TEST - LEGACY INTEGRATION CASE'];

		// PAGE REFERENCE
		PageReference pageRef = Page.INTGR_PublishSFCase;

		// ADD URL PARAM
		pageRef.getParameters().put('id', cs.Id);

		// SET TEST PAGE
		Test.setCurrentPage(pageRef);

		// INSTANTIATE VISUALFORCE PAGE CONTROLLER
		INTGR_PublishSFCaseController ctrl = new INTGR_PublishSFCaseController();

		// ASSERT VARIABLES
		// system.assertEquals(cs.Id, ctrl.caseId);
		system.assertEquals('INTGR_PublishSFCaseController_Test IHG TEST ACCOUNT', ctrl.customerName);
		system.assertEquals('IHG', ctrl.extIntegrationName);
		system.assertEquals('ServiceNow', ctrl.extIntegrationSysName);
		system.assertEquals(true, ctrl.hasCustomerData);
		system.assertEquals(true, ctrl.isLegacy);

        // EMULATE USER PUSHING SUBMIT BUTTON 
		ctrl.doSubmit();
        
        // EMULATE USER PUSHING CANCEL BUTTON TO CHANGE SELECTIONS
        ctrl.hideDialog1();

        // EMULATE USER CHECKING ALL COMMENTS VIA MASTER CHECK
        ctrl.checkAllComments = true;
        ctrl.doCheckComments();
        
        // EMULATE USER CHECKING ALL FILES VIA MASTER CHECK
        ctrl.checkAllFiles = true;
        ctrl.doCheckFiles();

        // EMULATE USER PUSHING SUBMIT BUTTON 
		ctrl.doSubmit();
        
		Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock(0));

		Test.startTest();        

        // EMULATE USER PUSHING COMMIT BUTTON 
		ctrl.submitDialog1();
        
		Test.stopTest();

        ctrl.hideDialog2();
        
        ctrl.hideSuccess();
        
		// ASSERT THAT CASE WAS UPDATED CORRECTLY
		//Case csAsserts = [SELECT Id, INTGR_Create_Ticket_in_Customer_System__c, Update_External_System__c FROM Case WHERE Subject = 'APEX TEST - LEGACY INTEGRATION CASE'];
		//system.assertEquals(true, csAsserts.INTGR_Create_Ticket_in_Customer_System__c);
		//system.assertEquals(true, csAsserts.Update_External_System__c);

	}

	// =======================================================================================================================================
	// = TEST METHOD 2: TEST CREATE INCIDENT (NEXT)
	// =======================================================================================================================================
	static testmethod void test2()
	{

		Case cs = [SELECT Id, AccountId FROM Case WHERE Subject = 'APEX TEST - CASE WITH INTGR ACCOUNT'];

		// PAGE REFERENCE
		PageReference pageRef = Page.INTGR_PublishSFCase;

		// ADD URL PARAM
		pageRef.getParameters().put('id', cs.Id);

		// SET TEST PAGE
		Test.setCurrentPage(pageRef);

		// INSTANTIATE VISUALFORCE PAGE CONTROLLER
		INTGR_PublishSFCaseController ctrl = new INTGR_PublishSFCaseController();

		// ASSERT VARIABLES
		// system.assertEquals(cs.Id, ctrl.caseId);
		system.assertEquals('Big Richards Inn', ctrl.customerName);
		system.assertEquals('SANDBOX', ctrl.extIntegrationName);
		system.assertEquals('ServiceNow', ctrl.extIntegrationSysName);
		system.assertEquals(true, ctrl.hasCustomerData);
		system.assertEquals(false, ctrl.isLegacy);

		// ASSERT PAGE MESSAGE
		Boolean bFound = false;
		ApexPages.Message[] pgMsgs = ApexPages.getMessages();
		system.assertNotEquals(0, pgMsgs.size());

		for (ApexPages.Message msg : pgMsgs)
		{
			if (msg.getSummary() == Label.AH_IntegrationAccountExist && msg.getSeverity() == ApexPages.Severity.WARNING)
			{
				bFound = true;
			}
		}

		system.assert (bFound);

        // EMULATE USER PUSHING SUBMIT BUTTON 
		ctrl.doSubmit();
        
        // EMULATE USER PUSHING CANCEL BUTTON TO CHANGE SELECTIONS
        ctrl.hideDialog1();

        // EMULATE USER CHECKING ALL COMMENTS VIA MASTER CHECK
        ctrl.checkAllComments = true;
        ctrl.doCheckComments();
        
        // EMULATE USER CHECKING ALL FILES VIA MASTER CHECK
        ctrl.checkAllFiles = true;
        ctrl.doCheckFiles();

        // EMULATE USER PUSHING SUBMIT BUTTON 
		ctrl.doSubmit();
        
		Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());

		Test.startTest();        

        // EMULATE USER PUSHING COMMIT BUTTON 
		ctrl.submitDialog1();
        
		Test.stopTest();

        ctrl.hideDialog2();
        
        ctrl.hideSuccess();
        
        ctrl.doCancel();

	}

	// =======================================================================================================================================
	// = TEST METHOD 3: TEST CREATE INCIDENT (NEXT) W/O ASSOCIATED INTGR_Account__c RECORD
	// =======================================================================================================================================
	static testmethod void test3()
	{
		Test.startTest();

		Case cs = [SELECT Id, AccountId FROM Case WHERE Subject = 'APEX TEST - CASE WITHOUT INTGR ACCOUNT'];

		// PAGE REFERENCE
		PageReference pageRef = Page.INTGR_PublishSFCase;

		// ADD URL PARAM
		pageRef.getParameters().put('id', cs.Id);

		// SET TEST PAGE
		Test.setCurrentPage(pageRef);

		// INSTANTIATE VISUALFORCE PAGE CONTROLLER
		INTGR_PublishSFCaseController ctrl = new INTGR_PublishSFCaseController();

		// ASSERT VARIABLES
		system.assertEquals(false, ctrl.hasCustomerData);
		system.assertEquals(false, ctrl.isLegacy);

		// ASSERT PAGE MESSAGE
		Boolean bFound = false;
		ApexPages.Message[] pgMsgs = ApexPages.getMessages();
		system.assertNotEquals(0, pgMsgs.size());

		for (ApexPages.Message msg : pgMsgs)
		{
			if (msg.getSummary() == Label.AH_IntegrationAccountNotExist && msg.getSeverity() == ApexPages.Severity.ERROR)
			{
				bFound = true;
			}
		}

		system.assert (bFound);

		Test.stopTest();

	}

	// =======================================================================================================================================
	// = TEST METHOD 4: TEST REFRESH & CANCEL BUTTONS
	// =======================================================================================================================================
	static testmethod void test4()
	{

		Test.startTest();

		// GET TEST RECORDS
		Case cs = [SELECT Id, AccountId FROM Case WHERE Subject = 'APEX TEST - LEGACY INTEGRATION CASE'];

		// PAGE REFERENCE
		PageReference pageRef = Page.INTGR_PublishSFCase;

		// ADD URL PARAM
		pageRef.getParameters().put('id', cs.Id);

		// SET TEST PAGE
		Test.setCurrentPage(pageRef);

		// INSTANTIATE VISUALFORCE PAGE CONTROLLER
		INTGR_PublishSFCaseController ctrl = new INTGR_PublishSFCaseController();

        // ctrl.refreshPage();
		//ASSERTIONS HERE...
        // ctrl.cancel();
		//ASSERTIONS HERE...
		system.debug('pageRef = ' + pageRef);

		Test.stopTest();

	}

	// =======================================================================================================================================
	// = TEST METHOD 5: TEST OPENING VF PAGE WITH NO PARAM
	// =======================================================================================================================================
	static testmethod void test5()
	{

		Test.startTest();

		// PAGE REFERENCE
		PageReference pageRef = Page.INTGR_PublishSFCase;

		// SET TEST PAGE
		Test.setCurrentPage(pageRef);

		// INSTANTIATE VISUALFORCE PAGE CONTROLLER
		INTGR_PublishSFCaseController ctrl = new INTGR_PublishSFCaseController();

		// ASSERT THAT ERROR WAS THROWN
		Boolean bFound = false;
		ApexPages.Message[] pgMsgs = ApexPages.getMessages();
		system.assertNotEquals(0, pgMsgs.size());

		for (ApexPages.Message msg : pgMsgs)
		{
			if (msg.getSummary() == 'Case Id not found in URL parameter.' && msg.getSeverity() == ApexPages.Severity.ERROR)
			{
				bFound = true;
			}
		}

		system.assert (bFound);

		Test.stopTest();

	}

}