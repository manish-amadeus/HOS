/****************************************************************************************
Name            : NI_CaseComment_TriggerHandler_Test Test Class
Author          : Cybage
Created Date    : 03/19/2018
Last Mod Date   : 01/17/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for NI_CaseComment_TriggerHandler apex class.
				: 
******************************************************************************************/
@isTest
public class NI_CaseComment_TriggerHandler_Test 
{


    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        User cUser = NI_TestClassData.createTestUser(2005, 'System Administrator'); 
        cUser.UserName = 'NICaseCommentTriggerHandlerTest@amadeus.com.sbfull';
        insert cUser;
        
        User newUser = NI_TestClassData.createTestUser(123, 'Case Integration Customers'); 
        newUser.UserName = 'servicenowTEST@newmarketinc.com.nextdev3';
        insert newUser;  
        
        User snUser = NI_TestClassData.createTestUser(122, 'System Administrator'); 
        snUser.UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3';
        insert snUser;  
        
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Excluded_Users__c = '00560000000yI7j';
        caseFlagSetting.Set_On_Customer_Comment__c = true;
        upsert caseFlagSetting;   
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        Account a = NI_TestClassData.createTestAccount(5);
        a.Name = 'TEST ACCOUNT NI_CaseComment_TriggerHandler_Test';
        a.RecordTypeId = rtPropertyAccountId;
        insert a;     

        // CREATE TEST ACCOUNT
        Account acc = NI_TestClassData.createTestAccount(1);
        acc.Name = 'INTGR_WinSN_Case_Handler_Test Account';
        insert acc;
        
        Contact cnt = NI_TestClassData.createTestContact(5, a.Id);
        cnt.FirstName = 'APEXTESTUSERONE';
        cnt.LastName = 'APEXTESTUSERONE';
        cnt.Email = 'test1@test.com';
        insert cnt; 
        
        Contact cnt2 = NI_TestClassData.createTestContact(6, a.Id);
        cnt2.FirstName = 'APEXTESTUSERTWO';
        cnt2.LastName = 'APEXTESTUSERTWO';
        cnt2.Email = 'test2@test.com';
        insert cnt2; 
        
        // SET THE NEW ACCOUNT ID CUSTOM SETTING FIELD TO TEST ACCOUNT ID
        ServiceNowIncidentSettings__c sn = [SELECT Id, AccountId__c, Integration_UserId__c, Integration_Username__c 
                                            FROM ServiceNowIncidentSettings__c 
                                            WHERE name = 'Default' 
                                            LIMIT 1];
        
        sn.Integration_Username__c = 'ihg_servicenowTEST@newmarketinc.com.nextdev3';
        sn.Integration_UserId__c = snUser.id;
        sn.AccountId__c = acc.Id;
        update sn;           

        User thisUser = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
 		
		Id ProfileID = [SELECT Id, UserType FROM Profile WHERE UserType = 'PowerCustomerSuccess' LIMIT 1].Id;
 		Id roleId = [SELECT Id, Name FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1][0].Id;
        
        system.runAs(thisUser)
        {
            User nUser = NI_TestClassData.createTestUser(205, 'AH Customer Community Plus Login User'); 
            nUser.UserName = 'testNeighborhoodUser2005@amadeus.com.sbfull.ahcc';
            nUser.ContactId = cnt2.Id;
            nUser.profileid = ProfileID;
            //nUser.UserRoleId  = roleId;
            insert nUser;
        }
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(5, 'APEX PG TEST');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(5, pgp.Id, 'APEX-TEST-XXX-02', 'Subscription');        
        insert prd;
        
        Asset di = NI_TestClassData.createTestAsset(5, a.Id, prd.Id);
        di.Product_Group__c = pgp.Id;
        insert di;
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.AssetId = di.Id;
        c.AccountId = a.Id;
        c.ContactId = c.Id;
        c.Status = 'New';
        c.Subject = 'TEST CASE NI_CaseComment_TriggerHandler_Test';
        c.Integration_Sync_Status__c = true;
        insert c;  
        
        //Id userId = [SELECT Id FROM User WHERE createdbyId =: thisUser.Id][0].Id;
        User u5 = [SELECT Id, IsActive FROM User WHERE UserName = 'testNeighborhoodUser2005@amadeus.com.sbfull.ahcc'];
        system.assertEquals(true, u5.IsActive);
        
        CaseShare cs = new CaseShare(CaseAccessLevel = 'Edit', CaseId = c.Id, UserOrGroupId = u5.Id);
        insert cs; 
        
        Test.startTest();
        
        // CREATE TEST CUSTOMER USER ACCOUNT
        User u1 = NI_TestClassData.createTestUser(111, 'Case Integration Customers');
        u1.Email = 'apexTester111@amadeuscustomer.com';
        u1.Alias = 'apiUser';
        insert u1; 
        
        INTGR_Account__c acc2 = NI_TestClassData.createTestINTGR_Account(1, a.Id, u1.Id);
        acc2.Active__c = true;
        insert acc2;
        
        List<INTGR_Field_Mapping__c> fMapping = NI_TestClassData.createTestINTGR_AccountMapping(1, acc2.Id);
        insert fMapping;
        
        Map<String, String> srcTargetFieldMap1 = new Map<String, String>();
        srcTargetFieldMap1.put('Description__c', 'Description');
        
        Case cs3 = NI_TestClassData.createTestCaseIntegration(1, a.Id);
        cs3.Integration_Account__c = acc2.Id;
        // cs3.Integration_Sync_Status__c = true;
        // cs3.Update_External_System__c = true;
        insert cs3;
        
        CaseComment comm = NI_TestClassData.createTestCaseComment(1, cs3.Id);
        insert comm;
        
        INTGR_Case__c caseObj = NI_TestClassData.createTestINTGR_Case(1, acc2.Id, cs3.Id);
        // insert caseObj;
        
        Test.stopTest(); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void testUpdateIncidentsCommentCase()
    {
        
        User cUser = [SELECT Id FROM User WHERE UserName = 'NICaseCommentTriggerHandlerTest@amadeus.com.sbfull'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'TEST ACCOUNT NI_CaseComment_TriggerHandler_Test'];
        List<Case> listOfCases = new List<Case>();
        
        ServiceNowIncidentSettings__c ServicenowUsr = [SELECT id, Integration_Username__c FROM ServiceNowIncidentSettings__c WHERE name = 'Default' LIMIT 1];
        ServicenowUsr.Integration_Username__c = 'ihg_servicenowTEST2@newmarketinc.com.winaproach1';
        ServicenowUsr.Integration_UserId__c = cUser.id;
        update ServicenowUsr;

        Case cs;
        Case cs2; 
        
        system.runAs(cUser) 
        {
            
            cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';  
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Amadeus_External_System_Id__c = '10762030';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Customer_Ticket_Number__c = 'INC0010116';
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'ServiceNow Integration';
            cs.Integration_Sync_Status__c = true;
            insert cs;
            
            cs2 = NI_TestClassData.createTestCase(1, a1.Id);
            cs2.Subject = 'TestBK- ttest10';
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '3';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '1';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test';
            cs2.Description = 'Test description';    
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Amadeus_External_System_Id__c = '10762030';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs2.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs2.Customer_Ticket_Number__c = 'INC0010116';
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '123';
            cs2.Origin = 'ServiceNow Integration';
            cs2.Integration_Sync_Status__c = true;
            insert cs2;
            listOfCases.add(cs);
            
        }    
        
        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtAmadeusParallelInvestigationId = TaskRecordTypeInfo.get('Amadeus Parallel Investigation').getRecordTypeId(); 
        
        Task t = NI_TestClassData.createTestTask(1, null, cs.id, rtAmadeusParallelInvestigationId, 'Call', 'Not Started', 'Normal');
        t.OwnerId = UserInfo.getUserId();    
        t.Subject = 'Donni2';
        t.Parallel_Investigation_Group__c = 'MHDHOT';
        t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
        t.Added_By_Group__c = 'MHDHOT';
        t.Description = 'Comments2';
        t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO';       
        t.TaskSubtype = 'Email';
        insert t; 
        
        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
        csComment.CommentBody = 'comments';
        insert csComment;        
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void testCaseCommentTriggerHandler2()
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'TEST CASE NI_CaseComment_TriggerHandler_Test'];
        
        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, c.Id);
        csComment.CommentBody = 'comments';
        csComment.IsPublished = true;
        insert csComment;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // ======================================================================================================================================= 
    @isTest static void testCaseCommentTriggerHandler3()
    {
        
        User cUser = [SELECT Id FROM User WHERE UserName = 'NICaseCommentTriggerHandlerTest@amadeus.com.sbfull'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'TEST CASE NI_CaseComment_TriggerHandler_Test'];
        
        system.runAs(cUser)
        {
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, c.Id);
            csComment.CommentBody = 'comments';
            csComment.IsPublished = true;
            insert csComment;
        }
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // ======================================================================================================================================= 
    @isTest static void testCaseCommentTriggerHandler4()
    {
        
        User nUser = [SELECT Id FROM User WHERE UserName = 'testNeighborhoodUser2005@amadeus.com.sbfull.ahcc'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'TEST CASE NI_CaseComment_TriggerHandler_Test'];

        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Excluded_Users__c = '00530000000xbQE';
        upsert caseFlagSetting; 
        
        system.runAs(nUser)
        {
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, c.Id);
            csComment.CommentBody = 'comments';
            csComment.IsPublished = true;
            insert csComment;
        }    
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 5: 
    // ======================================================================================================================================= 
    @isTest static void testCaseCommentTriggerHandler5()
    {
        
        User nUser = [SELECT Id FROM User WHERE UserName = 'NICaseCommentTriggerHandlerTest@amadeus.com.sbfull'];
        
        Test.startTest();
        
        system.runAs(nUser)
        {
            CaseComment comm = [SELECT Id, CommentBody FROM CaseComment LIMIT 1][0];
            comm.CommentBody = 'Updating case comment.';
            update comm;
            system.assertEquals('Updating case comment.', comm.CommentBody);
            Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        }
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 6: 
    // =======================================================================================================================================     
    static testmethod void intCaseCommentUpdateFromAPI() 
    {
        
        User u = [SELECT Id FROM User WHERE Alias = 'apiUser'][0];
        Account a = [SELECT Id FROM Account LIMIT 1];
        INTGR_Account__c acc = [SELECT Id FROM INTGR_Account__c LIMIT 1];

        Test.startTest();
        
        system.runAs(u)
        {
            
            Case cs4 = NI_TestClassData.createTestCaseIntegration(1, a.Id);
            cs4.Update_External_System__c = true;
            
           	INTGR_Case__c caseObj1 = NI_TestClassData.createTestINTGR_Case(1, acc.id, null);
            caseObj1.Customer_Ticket_Number__c = 'INC001';
            caseObj1.Customer_Ticket_System_Id__c = 'INC0001';
            insert caseObj1;

        	INTGR_Case__c cases = [SELECT Id, Case__c FROM INTGR_Case__c WHERE createdById =: u.Id];

            // Temp Fix needs to be removed post deployment in nextdev1 - 29/11/2018
            if (cases != null && cases.Case__c != null)
            {
	            Case c = [SELECT Id, Update_External_System__c FROM Case WHERE Id =: cases.Case__c];
	            c.Update_External_System__c = true;
	            update c;
            }
            
	        INTGR_Case_Comment__c caseComm = NI_TestClassData.createTestINTGR_CaseComm(cases.Id);
        	insert caseComm;
        	
	        caseComm.CommentBody__c = 'update On Case Test';
	        update caseComm;

	        system.assertEquals('update On Case Test', caseComm.CommentBody__c);
            system.assertNotEquals (null, caseComm.INTGR_Case__c);
	       
        }
        
        Test.stopTest();
         
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 7: 
    // =======================================================================================================================================     
    static testmethod void intCaseCommentCreateFromAdmin() 
    {
        
        Test.startTest();
        
        Account a = [SELECT Id FROM Account LIMIT 1];
        INTGR_Account__c acc = [SELECT Id FROM INTGR_Account__c LIMIT 1];
        
        Case cs4 = NI_TestClassData.createTestCaseIntegration(1, a.Id);

        cs4.Update_External_System__c  = true;
        cs4.INTGR_Customer_Ticket_System_Id__c = 'INC001';
        cs4.Customer_Ticket_Number__c = 'INC0001';
        insert cs4;
        
        INTGR_Case__c caseObj1 = NI_TestClassData.createTestINTGR_Case(1, acc.id, cs4.Id);
        caseObj1.Customer_Ticket_Number__c = 'INC001';
        caseObj1.Customer_Ticket_System_Id__c = 'INC0001';
        insert caseObj1;
        
        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs4.Id);
        csComment.CommentBody = 'Standard comments ';
        insert csComment;
        
        csComment.CommentBody = 'Standard comments update ';
        update csComment;
        
        Test.stopTest();
        
    }
        
}