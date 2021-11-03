/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_ServicenowIntegrationTest Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 08/2/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : Last Updated Per NICC-023347
Description     : Test class for the NI_ServicenowIntegration class

*************************************************************************************************/
@isTest
public class NI_ServicenowIntegrationTest 
{
     
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        system.debug(' *** ENTERING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
		ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default'); 
        SNSettings.Integration_Username__c = 'ihg_servicenowTEST@amadeus.com.winaproach';
        update SNSettings;        
            
        Winaproach_System_Affected__c systemAffected = new Winaproach_System_Affected__c();
        systemAffected.Name = 'Production';
        systemAffected.System_Category__c = 'P';
        insert systemAffected;        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PARENT ACCOUNT 1';
        insert a;

        Contact con = NI_TestClassData.createTestContact(1, a.Id);		
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        con.FirstName = 'Apex';
        con.LastName = 'Tester';
        insert con;
        
        User u = NI_TestClassData.createTestUser(1, 'IHG Integration Only - Standard'); 
        u.FirstName = 'Joe';
        u.LastName = 'SNUser';
        u.UserName = 'ihg_servicenowTEST@amadeus.com.winaproach';
        insert u;
        
        List<User> lstUserAsserts = new List<User>([SELECT Id 
                                                    FROM User 
                                                    WHERE FirstName = 'Joe' 
                                                    AND LastName = 'SNUser' 
                                                    AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach']);
        system.assertEquals(1, lstUserAsserts.Size());        
        
        ServiceNowIncidentSettings__c sn = [SELECT Id, Integration_Username__c, Integration_UserId__c FROM ServiceNowIncidentSettings__c WHERE Name = 'Default' LIMIT 1];
        sn.Integration_Username__c = u.UserName;
        sn.Integration_UserId__c = u.Id;
        update sn;        
        
        AccountShare acctShr = new AccountShare();
        
        acctShr.AccountId = a.Id;
        acctShr.AccountAccessLevel = 'Read';
        acctShr.CaseAccessLevel = 'Edit';
        acctShr.OpportunityAccessLevel = 'None';
        acctShr.RowCause = 'Manual';
        acctShr.UserOrGroupId = u.Id;
        
		insert acctShr;
        
        system.debug(' *** EXITING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }  

    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidents()
    {
               
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
               
        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;      

        List<Case> lstCases = new List<Case>();

        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        {
            cs.Subject = 'TestBK- ttest10'; 
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId(); 
            cs.Priority = '3'; 
            cs.Type = 'Inquiry';             
            cs.Customer_Severity__c = '1'; 
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT'; 
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT'; 
            cs.Status = 'New'; 
            cs.Winaproach_Logger__c = 'test';
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
            cs.Description = 'Test Description 1'; 
            insert cs; 
            lstCases.add(cs); 
        }   
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id); 
        List<Case> lstCaseUpdates = new List<Case>(); 
        
        updateCs.Id = cs.Id; 
        updateCs.subject = 'new subject'; 
        updateCs.Assignment_Group__c = 'MY-GLBL-Service Desk Level 3'; 
        updateCs.Status = 'Recovered'; 
        updateCs.Customer_Severity__c ='2'; 
        updateCs.Resolution_Summary__c = '1'; 
        updateCs.Resolution_Code__c = '1'; 
        updateCs.Description = 'Test Description 2'; 
        update updateCs; 
        lstCaseUpdates.add(updateCs); 
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case]);
        system.assertEquals(1, lstCaseAsserts.Size());
        
        Attachment attach = NI_TestClassData.createTestAttachment(a1.Id);
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = updateCs.id;
        insert attach;
        
        Test.startTest();  
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());
        
        Test.stopTest();
        
    }
  
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidentsCommentCase()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        
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
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
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
            cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
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
            lstCases.add(cs);
        }    
        
        Test.startTest();    
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtAmadeusParallelInvestigationId = TaskRecordTypeInfo.get('Amadeus Parallel Investigation').getRecordTypeId(); 
        
        Task t = NI_TestClassData.createTestTask(1, null, cs.Id, rtAmadeusParallelInvestigationId, 'Call', 'Not Started', 'Normal');
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
    // = TEST METHOD 3: 
    // =======================================================================================================================================    
    @isTest static void testUpdateIncidentsException()
    {
		
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Case cs;
        
        system.runAs(cUser) 
        {
            
            cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
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
            //cs.INTGR_Assigned_Recovery_Plan__c = 'Severity 3 Functional';
            insert cs;               
            lstCases.add(cs);
        } 
        
        
        //Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        List<Case> lstCaseUpdates = new List<Case>();
        updateCs.Id = cs.Id;
        updateCs.subject = 'new subject';
        updateCs.Assignment_Group__c = 'MY-GLBL-Service Desk Level 3';
        updateCs.Status = 'Recovered';
        updateCs.Customer_Severity__c ='2';
        updateCs.Resolution_Summary__c = '1';
        updateCs.Resolution_Code__c = '1';   
        updateCs.INTGR_Assigned_Recovery_Plan__c = 'Severity 3 Technical';
        update updateCs;

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidentsRejectedStatus()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];
        
        List<Case> lstCases = new List<Case>();
        Case cs;
        
        system.runAs(cUser) 
        {
            cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
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
            lstCases.add(cs);
        } 
        
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class,  new NI_ServicenowIntegrationTestMock());
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        List<Case> lstCaseUpdates = new List<Case>();
        updateCs.Id = cs.Id;
        updateCs.subject = 'new subject';
        updateCs.Assignment_Group__c = 'MY-GLBL-Service Desk Level 3';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c ='2';
        //updateCs.Resolution_Summary__c = '1';
        updateCs.Resolution_Code__c = '1';
        updateCs.Reject_Reason_Code__c = 'Change Required';     
        update updateCs;
        lstCaseUpdates.add(updateCs);
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 5: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidentsOpenStatus()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];
        
        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;
        
        List<Case> lstCases = new List<Case>();
        Case cs;
        
        system.runAs(cUser) 
        {
            cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
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
            lstCases.add(cs);
        }       
        
        Test.startTest();   

        //Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        List<Case> lstCaseUpdates = new List<Case>();
        updateCs.Id = cs.Id;
        updateCs.subject = 'new subject';
        updateCs.Assignment_Group__c = 'MY-GLBL-Service Desk Level 3';
        updateCs.Status = 'Open';
        updateCs.Customer_Severity__c ='2';
        updateCs.Resolution_Summary__c = '1';
        updateCs.Resolution_Code__c = '1';
        updateCs.Pending_Code__c ='Customer Question';       
        update updateCs;
        lstCaseUpdates.add(updateCs);

        Test.setMock(HttpCalloutMock.class,  new NI_ServicenowIntegrationTestMock());
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 6: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidentsParseAndLogResponse()
    {
		
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];
        
        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;
        
        List<Case> lstCases = new List<Case>();
        Case cs;
        
        system.runAs(cUser) 
        {
            cs = NI_TestClassData.createTestCase(1, a1.Id);
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
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
        }       

        String response = '<response><import_set>ISET0010058</import_set><staging_table>u_integ_amadeus_incidents</staging_table><result><display_value>INC0010117</display_value><sys_id>e4455cd5db0fe200ddd1b34ffe961966</sys_id><transform_map>Amadeus Incidents</transform_map><record_link>link</record_link><display_name>number</display_name><table>incident</table><status>updated</status></result></response>';
        String request = '<request><entry><u_number>INC0010116</u_number><u_correlation_display>001734547</u_correlation_display><u_problem_id>001734547</u_problem_id><u_correlation_id>50063000003XJr3AAG</u_correlation_id><u_short_description>Test Case1</u_short_description></entry></request>';
        String resHeader = 'Created';
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        String importsetendPoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
        servNowFun.parseAndLogResponse(response, cs.Id, servNowFun.importSetEndPoint, 'Update', 'Case', new List<Case>(), new List<NI_Integration_Log__c>(), request, resHeader, null, null);
        
        List<NI_Integration_Log__c> lstlogAsserts = new List<NI_Integration_Log__c>([SELECT Id FROM NI_Integration_Log__c]);
        system.assertEquals(0, lstlogAsserts.Size());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: 
    // =======================================================================================================================================     
    @isTest static void testServiceNowIntegrationLogMessage()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 

        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'New';
        cs.Winaproach_Logger__c = 'test1';
        cs.Description = 'Test description1';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Reject_Reason_Code__c = 'Change required';    
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';
        cs.Integration_Sync_Status__c = true;
        lstCases.add(cs);
        
        system.runAs(cUser) 
        {  
            insert lstCases; 
        }
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);

        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';            
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
        update updateCs;
        
        List<Case> lstUpdate = new List<Case>();
        lstUpdate.add(updateCs);
        
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        NI_WinaproachService niwin = new NI_WinaproachService('Create',lstCases);
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        String request = '<?xml version="1.0" encoding="UTF-8"?><request><entry><u_number>INC0010172</u_number><u_correlation_display>001535258</u_correlation_display><u_problem_id>001535258</u_problem_id><u_correlation_id>50017000000iBHXAA2</u_correlation_id><u_work_notes>Changed Case Severity FROM 3 to 4. Modified By Swapnil Patil (2017-03-24 13:57:23 GMT )</u_work_notes><u_priority>5</u_priority></entry></request>';
        String response = '<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response>';
        //String createResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><createResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><createReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-01 10:46:26 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;10763085&lt;/record_id&gt;&lt;external_record_id&gt;001534583&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type \'IR\'. Removed FROM message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
        //String unAuthResponse = '<html><head><title>401 Unauthorized</title></head><body><h1>Unauthorized</h1><p>This server could not verify that you are authorized to access the document requested.  Either you supplied the wrong credentials (e.g., bad password), or your browser doesn\'t understand how to supply the credentials required.</p></body></html>';
        
        //String taskResponse = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><updateResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><updateReturn xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-04-26 10:10:36 GMT&quot;&gt;  &lt;success&gt;    &lt;record_id&gt;10786919&lt;/record_id&gt;    &lt;external_record_id&gt;5001700000475ulAAA&lt;/external_record_id&gt;    &lt;parallel_investigation_list&gt;     &lt;parallel_investigation&gt;        &lt;investigation_id&gt;169227&lt;/investigation_id&gt;       &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;      &lt;/parallel_investigation&gt;      &lt;parallel_investigation&gt;       &lt;investigation_id&gt;169231&lt;/investigation_id&gt;        &lt;external_investigation_id&gt;00T17000008hVRREA2&lt;/external_investigation_id&gt;     &lt;/parallel_investigation&gt;    &lt;/parallel_investigation_list&gt;    &lt;comment&gt;Record updated successfully.&lt;/comment&gt;    &lt;comment&gt;FftForPiCorrection: S0E02:FFT Parallel investigation added: &lt;/comment&gt;  &lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>';
        //String faultString = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<?xml version="1.0" encoding="UTF-8"?><ticket_response version="1.0"  timestamp="2016-04-05 10:33:02 GMT">  <failure>    <record_id>10764497</record_id>   <external_record_id>001534593</external_record_id>    <comment>Duplicate Create recieved with extID:001534593 - Record:10764497already created earlier</comment>    <error_type>EAPR-CRE-DUPL</error_type>    <error_msg />    <resend>false</resend>  </failure></ticket_response>]]></faultstring>         <detail>            <ns1:hostnamexmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname>         </detail>      </soapenv:Fault>   </soapenv:Body></soapenv:Envelope>';
        //String taskRequest = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML>&lt;?xml version="1.0" encoding="UTF-8"?>&lt;ticket_exchange>&lt;update>&lt;record_type>incident&lt;/record_type>&lt;external_record_id>500170000048c6EAAQ&lt;/external_record_id>&lt;record_id>10812414&lt;/record_id>&lt;status>AC&lt;/status>&lt;assignee>&lt;group>MHDAIT&lt;/group>&lt;/assignee>&lt;parallel_investigation_list>&lt;parallel_investigation>&lt;external_investigation_id>00T17000008hkWlEAI&lt;/external_investigation_id>&lt;investigation_reason_code>SE&lt;/investigation_reason_code>&lt;investigation_added_by_group>MHDHOT&lt;/investigation_added_by_group>&lt;investigation_group>MHDHOT&lt;/investigation_group>&lt;investigation_comment>Comments&lt;/investigation_comment>&lt;/parallel_investigation>&lt;/parallel_investigation_list>&lt;/update>&lt;/ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
        
        List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
        lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Update',null,ServiceNowSettings.ImportSet_Endpoint__c,'ServiceNow', request));
        
        //insert lstnLog;
        system.assert(lstnLog.size() == 1);
        
        //niwin.parseAndLogResponse(response,String.valueOf(cs.Id),winSettings.Endpoint__c, 'Update', 'CaseComment', lstUpdate, lstnLog,request,null);
        //servNowFun.parseAndLogResponseBatch(lId,mapLogCaseIdsUpdate.get(lId),mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase,resInsertLogMsg, resUpdateLog, resFailedLog, resUpdateTask);
        //servNowFun.parseAndLogResponse(response,String.valueOf(cs.Id),ServiceNowSettings.ImportSet_Endpoint__c, 'Update', 'Case', lstUpdate, lstnLog,request, 'Unautherized');
        //servNowFun.parseAndLogResponse(response,String.valueOf(cs.Id),ServiceNowSettings.ImportSet_Endpoint__c, 'Update', 'Case', lstUpdate, lstnLog,request, 'Created');
        servNowFun.parseAndLogResponse(response,String.valueOf(cs.Id),ServiceNowSettings.ImportSet_Endpoint__c, 'Update', 'Case', lstUpdate, lstnLog,request, 'Unautherized', null, null);
        servNowFun.parseAndLogResponse(response,String.valueOf(cs.Id),ServiceNowSettings.ImportSet_Endpoint__c, 'Update', 'Case', lstUpdate, lstnLog,request, 'Created', null, null);
        
        List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
        List<Id> resUpdateLog = new List<Id>();
        List<Id> resFailedLog = new List<Id>(); 
        servNowFun.parseAndLogResponseBatch('a0w17000002W0R7','500170000040e4kAAA', request, response,'Created', lstUpdate, resInsertLogMsg, resUpdateLog, resFailedLog,null);
        servNowFun.parseAndLogResponseBatch('a0w17000002W0R7','500170000040e4kAAA', request, response,'Unautherized', lstUpdate, resInsertLogMsg, resUpdateLog, resFailedLog,null);
        servNowFun.parseAndLogResponseBatch('a0w17000002W0R7','500170000040e4kAAA', request, '','Unautherized', lstUpdate, resInsertLogMsg, resUpdateLog, resFailedLog,null);

    }

    // ======================================================================================================================================= 
    // = TEST METHOD 8: 
    // ======================================================================================================================================= 
    @isTest static void testServiceNowExceptionIntegrationLogMessage()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'New';
        cs.Winaproach_Logger__c = 'test1';
        cs.Description = 'Test description1';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Reject_Reason_Code__c = 'Change required';    
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';
        cs.Integration_Sync_Status__c = true;
        lstCases.add(cs);
        
        system.runAs(cUser) 
        {  
            insert lstCases; 
        }
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';            
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
        
        update updateCs;
        
        List<Case> lstUpdate = new List<Case>();
        lstUpdate.add(updateCs);
        
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        NI_WinaproachService niwin = new NI_WinaproachService('Create', lstCases);
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        String request = '<?xml version="1.0" encoding="UTF-8"?><request><entry><u_number>INC0010172</u_number><u_correlation_display>001535258</u_correlation_display><u_problem_id>001535258</u_problem_id><u_correlation_id>50017000000iBHXAA2</u_correlation_id><u_work_notes>Changed Case Severity FROM 3 to 4. Modified By Swapnil Patil (2017-03-24 13:57:23 GMT )</u_work_notes><u_priority>5</u_priority></entry></request>';
        String response = '<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response>';
        
        List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
        lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Update', null, ServiceNowSettings.ImportSet_Endpoint__c, 'ServiceNow', request));
        
        try
        {
            
            Test.startTest();
            
            insert lstnLog;
            NI_BatchServiceNowResend c = new NI_BatchServiceNowResend();                  
            Database.executeBatch(c);
            
            Test.stopTest();
            
        }
        catch(Exception e) 
        {
            system.debug('exception%%'+e.getMessage());
            system.debug('exception stack trace'+e.getStackTraceString());
        }

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 9: 
    // =======================================================================================================================================     
    @isTest static void testServiceNowBatchCoverage()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        Test.startTest();

        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'New';
        cs.Winaproach_Logger__c = 'test1';
        cs.Description = 'Test description1';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Reject_Reason_Code__c = 'Change required';    
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';
        cs.Integration_Sync_Status__c = true;
        lstCases.add(cs);
        
        system.runAs(cUser)
        {  
            insert lstCases; 
        }
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);

        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';            
        
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachServiceBatchMock());
        
        update updateCs;
        
        NI_BatchServiceNowResend c = new NI_BatchServiceNowResend();                  
        Database.executeBatch(c);
        
        Test.stopTest();

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 10: 
    // =======================================================================================================================================     
    @isTest static void testServiceNowBatchCoverageExecute()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'New';
        cs.Winaproach_Logger__c = 'test1';
        cs.Description = 'Test description1';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Reject_Reason_Code__c = 'Change required';    
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';
        cs.Integration_Sync_Status__c = true;
        lstCases.add(cs);
        
        system.runAs(cUser) 
        {  
            insert lstCases; 
        }
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';            

        update updateCs;
        
        List<Case> lstUpdate = new List<Case>();
        lstUpdate.add(updateCs);
        
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        NI_WinaproachService niwin = new NI_WinaproachService('Create',lstCases);
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        String request = '<?xml version="1.0" encoding="UTF-8"?><request><entry><u_number>INC0010172</u_number><u_correlation_display>001535258</u_correlation_display><u_problem_id>001535258</u_problem_id><u_correlation_id>50017000000iBHXAA2</u_correlation_id><u_work_notes>Changed Case Severity FROM 3 to 4. Modified By Swapnil Patil (2017-03-24 13:57:23 GMT )</u_work_notes><u_priority>5</u_priority></entry></request>';
        String response = '<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response>';

        List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
        lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Update','Attachment',ServiceNowSettings.ImportSet_Endpoint__c,'ServiceNow', request));
        insert lstnLog; 

        mapOfCaseIds.put(cs.Id, lstnLog[0].Id);
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c,Description__c, Retries_Performed__c 
             FROM NI_Integration_Log__c 
             WHERE case__c =: cs.Id]);   
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
        
        NI_BatchServiceNowResend c = new NI_BatchServiceNowResend();                  
        Database.executeBatch(c);
        
        Test.stopTest();

    }

    // ======================================================================================================================================= 
    // = TEST METHOD 11: 
    // ======================================================================================================================================= 
    @isTest static void testServiceNowExceptionResendFailed()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Id> mapOfCaseIds1 = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);

        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'New';
        cs.Winaproach_Logger__c = 'test1';
        cs.Description = 'Test description1';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Reject_Reason_Code__c = 'Change required';    
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';
        cs.Integration_Sync_Status__c = true;
        lstCases.add(cs);
        
        system.runAs(cUser) 
        {  
            insert lstCases; 
        }
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';            

        update updateCs;
        List<Case> lstUpdate = new List<Case>();
        lstUpdate.add(updateCs);
        
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        NI_WinaproachService niwin = new NI_WinaproachService('Create', lstCases);
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        String request = '<?xml version="1.0" encoding="UTF-8"?><request><entry><u_number>INC0010172</u_number><u_correlation_display>001535258</u_correlation_display><u_problem_id>001535258</u_problem_id><u_correlation_id>50017000000iBHXAA2</u_correlation_id><u_work_notes>Changed Case Severity FROM 3 to 4. Modified By Swapnil Patil (2017-03-24 13:57:23 GMT )</u_work_notes><u_priority>5</u_priority></entry></request>';
        String response = '<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response>';

        List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
        lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Update', null, ServiceNowSettings.ImportSet_Endpoint__c, 'ServiceNow', request));
        lstnLog.add(NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Insert', null, ServiceNowSettings.ImportSet_Endpoint__c, 'ServiceNow', request));

        try
        {
            
            insert lstnLog;
            mapOfCaseIds.put(cs.Id, lstnLog[0].Id);
            mapOfCaseIds1.put(cs.Id, lstnLog[1].Id);
            
            Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
                [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c 
                 FROM NI_Integration_Log__c 
                 WHERE case__c =: cs.Id]);
            
            NI_BatchServiceNowResend c = new NI_BatchServiceNowResend();                  

            //Database.executeBatch(c);
            Test.startTest();				
            Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1));  

            NI_ServicenowFunctions.resendRequestToServiceNowUpdate(mapOfCaseIds1,mapOfCaseIds, mapNiIntLog);

            Test.stopTest();
            
        }
        catch (Exception e) 
        {
            system.debug('Error Occured: ' + e.getMessage());
        }

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 12: 
    // =======================================================================================================================================     
    @isTest static void testServiceNowAttach_INS()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(); 
        List<Case> lstCases = new List<Case>(); 

        //NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();

        //CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest101';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test1';
            cs.Description = 'Test description1';
            cs.Cause_Id_Code__c = 'Application';
            cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            cs.Integration_Sync_Status__c = true;
            lstCases.add(cs); 
            //CASE INSERTED 
            insert lstCases; 
        }

        mapRetriesID.put(cs.Id, 1);
        
        //List<Case> lstUpdate = new List<Case>();

        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock(1));
        
        //ATTACHEMENT CREATED IN CASE CS
        Id testParentId=cs.Id;
        Attachment at=NI_TestClassData.createTestAttachment(testParentId);
        
        // ATTACHMENT INSERTs
        at.Name = 'TestDocument-1';
        insert at;
        
        Attachment at1=NI_TestClassData.createTestAttachment(testParentId);
        at1.Name = 'TestDocument-2';
        insert at1;
        
        //REQUEST CREATED
        String request = 'system.HttpRequest[Endpoint=https://ihgsndev.service-now.com/api/now/attachment/file?table_name=incident&table_sys_id=null&file_name=Unit Test Attachment, Method=POST]';
        
        //FAILED RESPONSE
        String response = '<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Record doesnt exist or ACL restricts the record retrieval</detail><message>No Record found</message></error><status>failure</status></response>';
        List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
        
        //ADDING INTEGRATION LOG FOR UPDATE FOR-ATTACHMENTINSERT
        NI_Integration_Log__c niLogObj = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Insert', 'Attachment', 'https://ihgsndev.service-now.com/api/now/attachment/file?table_name=incident&table_sys_id=abc&file_name=TestDocument-1', 'ServiceNow', request);
        niLogObj.Attachment_Id__c = at.Id;	
        lstnLog.add(niLogObj);
        insert lstnLog;
        
        mapNiIntLog.put(niLogObj.Id, niLogObj);
        mapOfCaseIds.put(niLogObj.Id, cs.Id);

        try
        {

            Test.startTest();

            NI_ServicenowFunctions.resendRequestToServiceNowUpdate(null, mapOfCaseIds, mapNiIntLog);
            
            Test.stopTest();
            
        }
        catch(Exception e)
        {
            system.debug('Error Occured: ' + e.getMessage());
        }
        
    }
   
    // ======================================================================================================================================= 
    // = TEST METHOD 13: 
    // =======================================================================================================================================     
    @isTest static void testServiceNowAttach_INS2()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 

        //CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser)
        { 
            cs.Subject = 'TestBK- ttest101';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test1';
            cs.Description = 'Test description1';
            cs.Cause_Id_Code__c = 'Application';
            cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            cs.Integration_Sync_Status__c = true;
            lstCases.add(cs); 
            //CASE INSERTED 
            insert lstCases; 
        }
        
        //REQUEST CREATED
        String request = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><update><incomingXML><?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>500170000048c6EAAQ</external_record_id><record_id>10812414</record_id><status>AC</status><assignee><group>MHDAIT</group></assignee><parallel_investigation_list><parallel_investigation><external_investigation_id>00T17000008hkWlEAI</external_investigation_id><investigation_reason_code>SE</investigation_reason_code><investigation_added_by_group>MHDHOT</investigation_added_by_group><investigation_group>MHDHOT</investigation_group><investigation_comment>Comments</investigation_comment></parallel_investigation></parallel_investigation_list></update></ticket_exchange></incomingXML></update></soapenv:Body></soapenv:Envelope>';
        
        //FAILED RESPONSE
        String response = '<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Record doesnt exist or ACL restricts the record retrieval</detail><message>No Record found</message></error><status>failure</status></response>';
        List<NI_Integration_Log__c> lstnLog = new List<NI_Integration_Log__c>();
        
        NI_Integration_Log__c niLogObj = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), response, 'Failed', 'Insert','Attachment','https://ihgsndev.service-now.com/api/now/attachment/file?table_name=incident&table_sys_id=abc&file_name=TestDocument-1','ServiceNow', request);
        lstnLog.add(niLogObj);
        
        try
        {

            Test.startTest();
            
            insert lstnLog;
            
            Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
            
            NI_BatchServiceNowResend c = new NI_BatchServiceNowResend();                  
            Database.executeBatch(c);	
            
            Test.stopTest();
            
        }
        catch (Exception e)
        {
            system.debug('Error Occurred: ' + e.getMessage());
        }
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 14: 
    // =======================================================================================================================================     
    @isTest static void testCreateIncidentsSN()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 

        //CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest101';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.Status = 'Recovered';
            cs.Winaproach_Logger__c = 'test1';
            cs.Description = 'Test description1';
            cs.Cause_Id_Code__c = 'Application';
            cs.Resolution_Code__c = 'Environment';
            cs.Resolution_Summary__c = 'Resolved';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            lstCases.add(cs); 
            //CASE INSERTED 	
        }
        
        mapRetriesID.put(cs.Id, 1);
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock(1)); 
        
        try
        { 
            
            Test.startTest();
            
            insert lstCases; 
            
            Test.stopTest();
            
        }
        catch (Exception e)
        {
            system.debug('Error Occurred: ' + e.getMessage());
        }
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 15: 
    // =======================================================================================================================================     
    @isTest static void testCreateCaseCommentSNException()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 

        // CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest101';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test1';
            cs.Description = 'Test description1';
            cs.Cause_Id_Code__c = 'Application';
            cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            cs.Customer_Ticket_Number__c = '12345';
            cs.Integration_Sync_Status__c = true;
            lstCases.add(cs); 
            //CASE INSERTED 	
        }
        
        mapRetriesID.put(cs.Id, 1);

        try
        {
            
            Test.startTest();
            
            insert lstCases; 
            
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;
            
            Test.stopTest();
            
        }
        catch (Exception e)
        {
            system.debug('Error Occurred: ' + e.getMessage());
        }
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 16: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidentsSN1()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
		Set<Id> case_ids = new Set<Id>();
        integer i = 1;
        
		// CREATING CASES
        Case cs1 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs2 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs3 = NI_TestClassData.createTestCase(1, a1.Id);

        mapRetriesID.put(cs1.Id, 1);
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock());         
        
        Test.startTest();
        
		system.runAs(cUser) 
        { 
            cs1.Subject = 'Test_' + i;
            cs1.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs1.Priority = '3';
            cs1.type = 'Inquiry';
            cs1.Customer_Severity__c = '1';
            cs1.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs1.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs1.Status = 'New';
            cs1.Winaproach_Logger__c = 'test' + i;
            cs1.Description = 'Test description' + i;
            cs1.Cause_Id_Code__c = 'Application';
            cs1.Reject_Reason_Code__c = '';    
            cs1.Winaproach_Logger_Phone_Number__c = '123456';
            cs1.Winaproach_Owner_Group__c = 'MHDHOT';
            cs1.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs1.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs1.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs1.Hotel_Code__c = '123';
            cs1.Origin = 'ServiceNow Integration';
            cs1.System_Affected__c = 'Disaster Recovery';
            cs1.Customer_Severity__c ='2';
            cs1.Resolution_Summary__c = '1';
            cs1.Resolution_Code__c = '1';
            cs1.Rejected_Case__c = false;
            cs1.Withdrawn_Case__c = false; 
           
            i++;
            
            cs2.Subject = 'Test_' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '3';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '1';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '123';
            cs2.Origin = 'ServiceNow Integration';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.Customer_Severity__c ='2';
            cs2.Resolution_Summary__c = '1';
            cs2.Resolution_Code__c = '1';
            cs2.Rejected_Case__c = false;
            cs2.Withdrawn_Case__c = false; 
            
            i++;
            
            cs3.Subject = 'Test_' + i;
            cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs3.Priority = '3';
            cs3.type = 'Inquiry';
            cs3.Customer_Severity__c = '1';
            cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs3.Status = 'New';
            cs3.Winaproach_Logger__c = 'test' + i;
            cs3.Description = 'Test description' + i;
            cs3.Cause_Id_Code__c = 'Application';
            cs3.Winaproach_Logger_Phone_Number__c = '1234563';
            cs3.Winaproach_Owner_Group__c = 'MHDHOT';
            cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs3.Hotel_Code__c = '123';
            cs3.Origin = 'ServiceNow Integration';
            cs3.System_Affected__c = 'Disaster Recovery';
            cs3.Customer_Severity__c ='2';
            cs3.Resolution_Summary__c = '1';
            cs3.Resolution_Code__c = '1';
            // NEEDED TO ADD THESE FIELD UPDATES TO COVER NEW LOGIC
            cs3.Rejected_Case__c = false;
            cs3.Withdrawn_Case__c = false;             
            cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            
            lstCases.add(cs1);
            lstCases.add(cs2);
            lstCases.add(cs3);
            
            insert lstCases; 
            
        }
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals(3, case_list.size());
            
            for (case c : case_list) 
            {
				system.debug(' **** AFTER INSERT - Subject = ' + c.Subject + ', Status = ' + c.Status);              
                case_ids.add(c.Id);
            }

            // SET ALL CASE STATUSES TO Acknowledged
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];
            cs_1.Status = 'Acknowledged';
            cs_1.Amadeus_External_System_Id__c = '110950';
            update_list_1.add(cs_1);
            
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[1];
            cs_2.Status = 'Acknowledged';
            cs_2.Amadeus_External_System_Id__c = '110951';
            update_list_1.add(cs_2);
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[2];
            cs_3.Status = 'Acknowledged';
            cs_3.Amadeus_External_System_Id__c = '110952';
            update_list_1.add(cs_3);
            
            update update_list_1;
            /***********************************
            for (case c : update_list_1) 
            {
				system.debug(' **** AFTER 1st UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);              
            }
            
            // ASSERT ALL CASE STATUSES WERE SET TO Acknowledged
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            system.assertEquals('Acknowledged', case_list_1[1].Status);
            system.assertEquals('Acknowledged', case_list_1[2].Status);
            
            List<Case> update_list_2 = new List<Case>();
            
            // SET ALL CASE STATUSES FROM Acknowledged TO OTHER STATUS
            Case cs_11 = new Case();
            cs_11.Id = (new List<Id>(case_ids))[0];
            cs_11.Amadeus_External_System_Id__c = '110950';
            cs_11.Status = 'Rejected PCP';
		    update_list_2.add(cs_11);
            
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[1];
            cs_22.Amadeus_External_System_Id__c = '110951';
			cs_22.Status = 'Open';
            update_list_2.add(cs_22);
            
            Case cs_33 = new Case();
            cs_33.Id = (new List<Id>(case_ids))[2];
            cs_33.Amadeus_External_System_Id__c = '110952';
			cs_33.Status = 'Recovered';
            update_list_2.add(cs_33);
            			
            update update_list_2;
            
            for (case c : update_list_2) 
            {
				system.debug(' **** AFTER 2nd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status); 
            }
            
            // ASSERT ALL CASE STATUSES WERE SET APPROPRIATELY
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Rejected PCP', case_list_2[0].Status);
            system.assertEquals('Open', case_list_2[1].Status);
            system.assertEquals('Recovered', case_list_2[2].Status);
			**********/
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
   		/***************
        List<Case> uptListSN = new List<Case>();
        
        // MAKE UPDATES AS THE INTEGRATION USER
        system.runAs(cUser) 
        { 
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];  
			system.debug(' **** cs_1.Id = ' + cs_1.Id);          
			cs_1.Status = 'Closed';
            cs_1.Amadeus_External_System_Id__c = '110950';
            uptListSN.add(cs_1);
            
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[1];
            system.debug(' **** cs_2.Id = ' + cs_2.Id);            
            cs_2.Status = 'Recovered';
            cs_2.Amadeus_External_System_Id__c = '110951';
            uptListSN.add(cs_2);
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[2];
			system.debug(' **** cs_3.Id = ' + cs_3.Id);             
            cs_3.Status = 'Closed';
            cs_3.Amadeus_External_System_Id__c = '110952';
            cs3.Withdrawn_Case__c = true; 
            uptListSN.add(cs_3);
            
            update uptListSN;
            
            for (case c : uptListSN) 
            {
				system.debug(' **** AFTER 3rd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);
            }
            
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Closed as rejected', case_list_3[0].Status);
            system.assertEquals('Open', case_list_3[1].Status);
           	system.assertEquals('Closed as recovered', case_list_3[2].Status);

            Case cs_22 = NI_TestClassData.createTestCase(1, a1.Id);
            cs_22.Id = (new List<Id>(case_ids))[1];
            cs_22.Status = 'Closed';
            cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            //List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            //system.assertEquals('Closed as withdrawn', case_list_4[1].Status);
            
        }
        ************/
        Test.StopTest();
        
    }
    
    //========================================================================================================================================
    // = TEST METHOD 17: 
    //========================================================================================================================================
    @isTest static void testUpdateIncidentsSN2()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
		Set<Id> case_ids = new Set<Id>();
        integer i = 1;
        
		// CREATING CASES
        Case cs1 = NI_TestClassData.createTestCase(1, a1.Id);
        
        mapRetriesID.put(cs1.Id, 1);
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock());         
        
        Test.startTest();
        
		system.runAs(cUser) 
        { 
            cs1.Subject = 'Test_' + i;
            cs1.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs1.Priority = '3';
            cs1.type = 'Inquiry';
            cs1.Customer_Severity__c = '1';
            cs1.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs1.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs1.Status = 'New';
            cs1.Winaproach_Logger__c = 'test' + i;
            cs1.Description = 'Test description' + i;
            cs1.Cause_Id_Code__c = 'Application';
            cs1.Reject_Reason_Code__c = '';    
            cs1.Winaproach_Logger_Phone_Number__c = '123456';
            cs1.Winaproach_Owner_Group__c = 'MHDHOT';
            cs1.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs1.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs1.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs1.Hotel_Code__c = '123';
            cs1.Origin = 'ServiceNow Integration';
            cs1.System_Affected__c = 'Disaster Recovery';
            cs1.Customer_Severity__c ='2';
            cs1.Resolution_Summary__c = '1';
            cs1.Resolution_Code__c = '1';
            cs1.Rejected_Case__c = false;
            cs1.Withdrawn_Case__c = false; 
           
            lstCases.add(cs1);
            
            insert lstCases; 
            
        }
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals(1, case_list.size());
            
            for (case c : case_list) 
            {
				system.debug(' **** AFTER INSERT - Subject = ' + c.Subject + ', Status = ' + c.Status);              
                case_ids.add(c.Id);
            }

            // SET ALL CASE STATUSES TO Acknowledged
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];
            cs_1.Status = 'Acknowledged';
            cs_1.Amadeus_External_System_Id__c = '110950';
            update_list_1.add(cs_1);
            
            
            update update_list_1;
            
            for (case c : update_list_1) 
            {
				system.debug(' **** AFTER 1st UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);              
            }
            
            // ASSERT ALL CASE STATUSES WERE SET TO Acknowledged
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            
            List<Case> update_list_2 = new List<Case>();
            
            // SET ALL CASE STATUSES FROM Acknowledged TO OTHER STATUS
            Case cs_11 = new Case();
            cs_11.Id = (new List<Id>(case_ids))[0];
            cs_11.Amadeus_External_System_Id__c = '110950';
            cs_11.Status = 'Rejected PCP';
		    update_list_2.add(cs_11);
            
            update update_list_2;
            
            for (case c : update_list_2) 
            {
				system.debug(' **** AFTER 2nd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status); 
            }
            
            // ASSERT ALL CASE STATUSES WERE SET APPROPRIATELY
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Rejected PCP', case_list_2[0].Status);
            
			
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
   		
        List<Case> uptListSN = new List<Case>();
        
        // MAKE UPDATES AS THE INTEGRATION USER
        system.runAs(cUser) 
        { 
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];  
			system.debug(' **** cs_1.Id = ' + cs_1.Id);          
			cs_1.Status = 'Closed';
            cs_1.Amadeus_External_System_Id__c = '110950';
            uptListSN.add(cs_1);
            
            update uptListSN;
            
            for (case c : uptListSN) 
            {
				system.debug(' **** AFTER 3rd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);
            }
            
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Closed as rejected', case_list_3[0].Status);
            

            Case cs_22 = NI_TestClassData.createTestCase(1, a1.Id);
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Status = 'Closed';
            cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            //List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            //system.assertEquals('Closed as withdrawn', case_list_4[1].Status);
            
        }
        
        Test.StopTest();
    }
     
    //========================================================================================================================================
    // = TEST METHOD 18: 
    //========================================================================================================================================
    @isTest static void testUpdateIncidentsSN3()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
		Set<Id> case_ids = new Set<Id>();
        integer i = 1;
        
		// CREATING CASES
        Case cs2 = NI_TestClassData.createTestCase(1, a1.Id);

        mapRetriesID.put(cs2.Id, 1);
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock());         
        
        Test.startTest();
        
		system.runAs(cUser) 
        { 
           
            cs2.Subject = 'Test_' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '3';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '1';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '123';
            cs2.Origin = 'ServiceNow Integration';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.Customer_Severity__c ='2';
            cs2.Resolution_Summary__c = '1';
            cs2.Resolution_Code__c = '1';
            cs2.Rejected_Case__c = false;
            cs2.Withdrawn_Case__c = false; 
           
            lstCases.add(cs2);
            
            insert lstCases; 
            
        }
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals(1, case_list.size());
            
            for (case c : case_list) 
            {
				system.debug(' **** AFTER INSERT - Subject = ' + c.Subject + ', Status = ' + c.Status);              
                case_ids.add(c.Id);
            }

            // SET ALL CASE STATUSES TO Acknowledged
           
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[0];
            cs_2.Status = 'Acknowledged';
            cs_2.Amadeus_External_System_Id__c = '110951';
            update_list_1.add(cs_2);
           
            update update_list_1;
            
            for (case c : update_list_1) 
            {
				system.debug(' **** AFTER 1st UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);              
            }
            
            // ASSERT ALL CASE STATUSES WERE SET TO Acknowledged
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            
            
            List<Case> update_list_2 = new List<Case>();
            
            // SET ALL CASE STATUSES FROM Acknowledged TO OTHER STATUS
           
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Amadeus_External_System_Id__c = '110951';
			cs_22.Status = 'Open';
            update_list_2.add(cs_22);
            	
            update update_list_2;
            
            for (case c : update_list_2) 
            {
				system.debug(' **** AFTER 2nd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status); 
            }
            
            // ASSERT ALL CASE STATUSES WERE SET APPROPRIATELY
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
           
            system.assertEquals('Open', case_list_2[0].Status);
			
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
   		
        List<Case> uptListSN = new List<Case>();
        
        // MAKE UPDATES AS THE INTEGRATION USER
        system.runAs(cUser) 
        { 
           
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[0];
            system.debug(' **** cs_2.Id = ' + cs_2.Id);            
            cs_2.Status = 'Recovered';
            cs_2.Amadeus_External_System_Id__c = '110951';
            uptListSN.add(cs_2);
            
            update uptListSN;
            
            for (case c : uptListSN) 
            {
				system.debug(' **** AFTER 3rd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);
            }
            
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Open', case_list_3[0].Status);

            Case cs_22 = NI_TestClassData.createTestCase(1, a1.Id);
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Status = 'Closed';
            cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Closed as withdrawn', case_list_4[0].Status);
            
        }
        
        Test.StopTest();
    }
    
    //========================================================================================================================================
    // = TEST METHOD 19: 
    //========================================================================================================================================
    @isTest static void testUpdateIncidentsSN4()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
		Set<Id> case_ids = new Set<Id>();
        integer i = 1;
        
		// CREATING CASES
        
        Case cs3 = NI_TestClassData.createTestCase(1, a1.Id);

        mapRetriesID.put(cs3.Id, 1);
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock());         
        
        Test.startTest();
        
		system.runAs(cUser) 
        { 
        
            cs3.Subject = 'Test_' + i;
            cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs3.Priority = '3';
            cs3.type = 'Inquiry';
            cs3.Customer_Severity__c = '1';
            cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs3.Status = 'New';
            cs3.Winaproach_Logger__c = 'test' + i;
            cs3.Description = 'Test description' + i;
            cs3.Cause_Id_Code__c = 'Application';
            cs3.Winaproach_Logger_Phone_Number__c = '1234563';
            cs3.Winaproach_Owner_Group__c = 'MHDHOT';
            cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs3.Hotel_Code__c = '123';
            cs3.Origin = 'ServiceNow Integration';
            cs3.System_Affected__c = 'Disaster Recovery';
            cs3.Customer_Severity__c ='2';
            cs3.Resolution_Summary__c = '1';
            cs3.Resolution_Code__c = '1';
            // NEEDED TO ADD THESE FIELD UPDATES TO COVER NEW LOGIC
            cs3.Rejected_Case__c = false;
            cs3.Withdrawn_Case__c = false;             
            cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            
            
            lstCases.add(cs3);
            
            insert lstCases; 
            
        }
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 1];
            system.assertEquals(1, case_list.size());
            
            for (case c : case_list) 
            {
				system.debug(' **** AFTER INSERT - Subject = ' + c.Subject + ', Status = ' + c.Status);              
                case_ids.add(c.Id);
            }

            // SET ALL CASE STATUSES TO Acknowledged
          
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[0];
            cs_3.Status = 'Acknowledged';
            cs_3.Amadeus_External_System_Id__c = '110952';
            update_list_1.add(cs_3);
         
            update update_list_1;
            
            for (case c : update_list_1) 
            {
				system.debug(' **** AFTER 1st UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);              
            }
            
            // ASSERT ALL CASE STATUSES WERE SET TO Acknowledged
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            
            List<Case> update_list_2 = new List<Case>();
            
            // SET ALL CASE STATUSES FROM Acknowledged TO OTHER STATUS

            Case cs_33 = new Case();
            cs_33.Id = (new List<Id>(case_ids))[0];
            cs_33.Amadeus_External_System_Id__c = '110952';
			cs_33.Status = 'Recovered';
            update_list_2.add(cs_33);
           		
            update update_list_2;
            
            for (case c : update_list_2) 
            {
				system.debug(' **** AFTER 2nd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status); 
            }
            
            // ASSERT ALL CASE STATUSES WERE SET APPROPRIATELY
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.assertEquals('Recovered', case_list_2[0].Status);
			
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
   		
        List<Case> uptListSN = new List<Case>();
        
        // MAKE UPDATES AS THE INTEGRATION USER
        system.runAs(cUser) 
        { 
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[0];
			system.debug(' **** cs_3.Id = ' + cs_3.Id);             
            cs_3.Status = 'Closed';
            cs_3.Amadeus_External_System_Id__c = '110952';
            cs3.Withdrawn_Case__c = true; 
            uptListSN.add(cs_3);
            
            update uptListSN;
            
            for (case c : uptListSN) 
            {
				system.debug(' **** AFTER 3rd UPDATE - Subject = ' + c.Subject + ', Status = ' + c.Status);
            }
            
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
           
           	system.assertEquals('Closed as recovered', case_list_3[0].Status);

            Case cs_22 = NI_TestClassData.createTestCase(1, a1.Id);
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Status = 'Closed';
            cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug('' + case_list_4);
            //system.assertEquals('Closed as withdrawn', case_list_4[0].Status);
            
        }
        
        Test.StopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 20: 
    // =======================================================================================================================================     
   
    @isTest static void testUpdateIncidentsSN5()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        Integer i = 1;
        
        //CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs2 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs3 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs4 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs5 = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest10' + i;
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            //cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test' + i;
            cs.Description = 'Test description' + i;
            cs.Cause_Id_Code__c = 'Application';
            //cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.Status = 'Recovered';
            cs.Customer_Severity__c ='2';
            cs.Resolution_Summary__c = '1';
            cs.Resolution_Code__c = '1';
            //cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Create_Ticket_in_Customer_System__c = false;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            
            i++;
            cs2.Subject = 'TestBK- ttest1' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '1';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '4';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            //cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '1231';
            cs2.Origin = 'Salesforce';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.INTGR_Create_Ticket_in_Customer_System__c = false;
            
            lstCases.add(cs);
            lstCases.add(cs2); 
        }
        
        i++;
        cs3.Subject = 'TestBK- ttest' + i;
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '1';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.Status = 'New';
        cs3.Reject_Reason_Code__c = 'Invalid';
        cs3.Rejected_Case__c = true;
        cs3.Winaproach_Logger__c = 'test' + i;
        cs3.Description = 'Test description' + i;
        cs3.Cause_Id_Code__c = 'Application';
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs3.Hotel_Code__c = '1231';
        cs3.Origin = 'Salesforce';
        cs3.System_Affected__c = 'Disaster Recovery';
        //cs3.INTGR_Create_Ticket_in_Customer_System__c = true;
        lstCases.add(cs3);

        i++;
        cs4.Subject = 'TestBK- ttest' + i;
        cs4.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs4.Priority = '1';
        cs4.type = 'Inquiry';
        cs4.Customer_Severity__c = '4';
        cs4.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs4.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs4.Status = 'New';
        cs4.Rejected_Case__c = True;
        cs4.Reject_Reason_Code__c = 'Change Required';
        cs4.Acknowledged__c = Datetime.now();
        cs4.Winaproach_Logger__c = 'test' + i;
        cs4.Description = 'Test description' + i;
        cs4.Cause_Id_Code__c = 'Application';
        cs4.Winaproach_Logger_Phone_Number__c = '123456';
        cs4.Winaproach_Owner_Group__c = 'MHDHOT';
        cs4.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs4.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs4.Hotel_Code__c = '1231';
        cs4.Origin = 'Salesforce';
        cs4.System_Affected__c = 'Disaster Recovery';
        lstCases.add(cs4); 
        
        i++;
        cs5.Subject = 'TestBK- ttest' + i;
        cs5.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs5.Priority = '1';
        cs5.type = 'Inquiry';
        cs5.Customer_Severity__c = '4';
        cs5.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs5.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs5.Status = 'New';
        cs5.Rejected_Case__c = false;
        cs5.Winaproach_Logger__c = 'test' + i;
        cs5.Description = 'Test description' + i;
        cs5.Cause_Id_Code__c = 'Application';
        cs5.Winaproach_Logger_Phone_Number__c = '123456';
        cs5.Winaproach_Owner_Group__c = 'MHDHOT';
        cs5.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs5.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs5.Hotel_Code__c = '1231';
        cs5.Origin = 'Salesforce';
        cs5.System_Affected__c = 'Disaster Recovery';
        lstCases.add(cs5);
  
        mapRetriesID.put(cs.Id, 1);
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock()); 
        
        Test.startTest();
        
        try
        { 
            
            insert lstCases; 
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;

			List<Case> ulist = new List<Case>();
            
            //CASE TO BE UPDATED
            Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
            updateCs.Id = cs.Id;
            updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
            updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
            updateCs.Winaproach_Logger__c = 'test2';
            updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
            updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
            updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
            updateCs.Description = 'Test description 2';
            updateCs.Status = 'Rejected';
            updateCs.INTGR_Recovery_Plan_Date_Time__c = Datetime.now();
            updateCs.Amadeus_External_System_Id__c = '11095094';
            updateCs.Cause_Id_Code__c = 'Application';
            updateCs.Resolution_Code__c = 'Environment';
            updateCs.Reject_Reason_Code__c = 'Functional Setting';            
            updateCs.INTGR_Create_Ticket_in_Customer_System__c = true;
            //Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
            //update updateCs;
			ulist.add(updateCs);
        
            cs5.Status = 'Open';
            ulist.add(cs5);
            
            update ulist;
            
        } 
        catch (Exception e)
        { 
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
        
        //RUN AS INTEGRATION USER
		system.runAs(cUser) 
        { 
            List<Case> update_list = new List<Case>();
			//CASE TO BE UPDATED
			cs2.Status = 'Acknowledged';
            cs2.Amadeus_External_System_Id__c = '110950941';
            update_list.add(cs2);
            
            cs3.Status = 'Recovered';
			cs3.Amadeus_External_System_Id__c = '110950921';
			update_list.add(cs3);

			cs4.Status = 'Acknowledged';
            cs4.Amadeus_External_System_Id__c = '1109501';
            update_list.add(cs4);

			cs5.Status = 'Recovered';
            cs5.Amadeus_External_System_Id__c = '110950';
            update_list.add(cs5);
            
            update update_list;
        }
        /************
        List<Case> up_list = new List<Case>();
        cs2.Status = 'Acknowledged';
        cs2.Amadeus_External_System_Id__c = '1109509411';
        up_list.add(cs2);
        
        cs4.Status = 'Recovered';
        cs4.Amadeus_External_System_Id__c = '1109501';
        up_list.add(cs4);
        update up_list;
        ****************/
        Test.stopTest();
        
    } 
    
    //=========================================================================================================================================
    // = TEST METHOD 21:
    //=========================================================================================================================================
     @isTest static void testUpdateIncidentsSN6()
    {

        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        Integer i = 1;
        
         Set<Id> case_ids = new Set<Id>();
        
        //CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs2 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs3 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs4 = NI_TestClassData.createTestCase(1, a1.Id);
        Case cs5 = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest10' + i;
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            //cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test' + i;
            cs.Description = 'Test description' + i;
            cs.Cause_Id_Code__c = 'Application';
            //cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.Status = 'Recovered';
            cs.Customer_Severity__c ='2';
            cs.Resolution_Summary__c = '1';
            cs.Resolution_Code__c = '1';
            //cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Create_Ticket_in_Customer_System__c = false;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            
            i++;
            cs2.Subject = 'TestBK- ttest1' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '1';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '4';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            //cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '1231';
            cs2.Origin = 'Salesforce';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.INTGR_Create_Ticket_in_Customer_System__c = false;
            
            lstCases.add(cs);
            lstCases.add(cs2); 
        }
        
        i++;
        cs3.Subject = 'TestBK- ttest' + i;
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '1';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.Status = 'New';
        cs3.Reject_Reason_Code__c = 'Invalid';
        cs3.Rejected_Case__c = true;
        cs3.Winaproach_Logger__c = 'test' + i;
        cs3.Description = 'Test description' + i;
        cs3.Cause_Id_Code__c = 'Application';
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs3.Hotel_Code__c = '1231';
        cs3.Origin = 'Salesforce';
        cs3.System_Affected__c = 'Disaster Recovery';
        //cs3.INTGR_Create_Ticket_in_Customer_System__c = true;
        lstCases.add(cs3);

        i++;
        cs4.Subject = 'TestBK- ttest' + i;
        cs4.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs4.Priority = '1';
        cs4.type = 'Inquiry';
        cs4.Customer_Severity__c = '4';
        cs4.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs4.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs4.Status = 'New';
        cs4.Rejected_Case__c = True;
        cs4.Reject_Reason_Code__c = 'Change Required';
        cs4.Acknowledged__c = Datetime.now();
        cs4.Winaproach_Logger__c = 'test' + i;
        cs4.Description = 'Test description' + i;
        cs4.Cause_Id_Code__c = 'Application';
        cs4.Winaproach_Logger_Phone_Number__c = '123456';
        cs4.Winaproach_Owner_Group__c = 'MHDHOT';
        cs4.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs4.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs4.Hotel_Code__c = '1231';
        cs4.Origin = 'Salesforce';
        cs4.System_Affected__c = 'Disaster Recovery';
        lstCases.add(cs4); 
        
        i++;
        cs5.Subject = 'TestBK- ttest' + i;
        cs5.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs5.Priority = '1';
        cs5.type = 'Inquiry';
        cs5.Customer_Severity__c = '4';
        cs5.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs5.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs5.Status = 'New';
        cs5.Rejected_Case__c = false;
        cs5.Winaproach_Logger__c = 'test' + i;
        cs5.Description = 'Test description' + i;
        cs5.Cause_Id_Code__c = 'Application';
        cs5.Winaproach_Logger_Phone_Number__c = '123456';
        cs5.Winaproach_Owner_Group__c = 'MHDHOT';
        cs5.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs5.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs5.Hotel_Code__c = '1231';
        cs5.Origin = 'Salesforce';
        cs5.System_Affected__c = 'Disaster Recovery';
        lstCases.add(cs5);
  
        mapRetriesID.put(cs.Id, 1);
        
        Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock()); 
        
        Test.startTest();
        
        try
        { 
            
            insert lstCases; 
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;

			List<Case> ulist = new List<Case>();
            
            //CASE TO BE UPDATED
            Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
            updateCs.Id = cs.Id;
            updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
            updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
            updateCs.Winaproach_Logger__c = 'test2';
            updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
            updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
            updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
            updateCs.Description = 'Test description 2';
            updateCs.Status = 'Rejected';
            updateCs.INTGR_Recovery_Plan_Date_Time__c = Datetime.now();
            updateCs.Amadeus_External_System_Id__c = '11095094';
            updateCs.Cause_Id_Code__c = 'Application';
            updateCs.Resolution_Code__c = 'Environment';
            updateCs.Reject_Reason_Code__c = 'Functional Setting';            
            updateCs.INTGR_Create_Ticket_in_Customer_System__c = true;
            //Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
            //update updateCs;
			ulist.add(updateCs);
        
            cs5.Status = 'Open';
            ulist.add(cs5);
            
            update ulist;
            
        } 
        catch (Exception e)
        { 
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
        
        //RUN AS INTEGRATION USER
		system.runAs(cUser) 
        { 
           
            
            List<Case> update_list_1 = new List<Case>();
            
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 2 ];
            system.debug('*********case_list.size()  :' + case_list.size());
            system.debug('*********case_list  :--' + case_list);
            
            for (case c : case_list) 
            {
                case_ids.add(c.Id);
            }
            
            system.debug(' **** case_ids : ' + case_ids);
           
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[0];
            cs_2.Status = 'Acknowledged';
            cs_2.Amadeus_External_System_Id__c = '110951';
            update_list_1.add(cs_2);
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[1];
            cs_3.Status = 'Recovered';
            cs_3.Amadeus_External_System_Id__c = '110952';
            update_list_1.add(cs_3);
            
            update update_list_1;
        }
        
        Test.stopTest();
        
    } 
    
    // ======================================================================================================================================= 
    // = TEST METHOD 22: 
    // =======================================================================================================================================     
    @isTest static void testUpdateIncidentsQueable()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();        
        List<Case> lstCases = new List<Case>(); 
        
        //CREATING CASE
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        { 
            
            cs.Subject = 'TestBK- ttest101';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            //cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test1';
            cs.Description = 'Test description1';
            cs.Cause_Id_Code__c = 'Application';
            //cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            
            cs.Status = 'Recovered';
            cs.Customer_Severity__c ='2';
            cs.Resolution_Summary__c = '1';
            cs.Resolution_Code__c = '1';
            //cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Create_Ticket_in_Customer_System__c = false;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            lstCases.add(cs); 

        }

        mapRetriesID.put(cs.Id, 1);
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock(1)); 
        
        try
        { 
            
            insert lstCases; 
            
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;
            
            //Test.startTest();
            
            NI_ServicenowIntegration.updateAttCaseCmtSN = true;
            
            // ATTACHMENT INSERT
            Id testParentId = cs.Id;
            Attachment at = NI_TestClassData.createTestAttachment(testParentId);
            at.Name = 'TestDocument-1';
            insert at;
            
            //CASE TO BE UPDATED
            Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
            
            updateCs.Id = cs.Id;
            updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
            updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
            updateCs.Winaproach_Logger__c = 'test2';
            updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
            updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
            updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
            updateCs.Description = 'Test description 2';
            updateCs.Status = 'Rejected';
            //updateCs.Customer_Severity__c ='3';
            updateCs.Amadeus_External_System_Id__c = '11095094';
            updateCs.Cause_Id_Code__c = 'Application';
            updateCs.Resolution_Code__c = 'Environment';
            updateCs.Reject_Reason_Code__c = 'Functional Setting';            
            updateCs.INTGR_Create_Ticket_in_Customer_System__c = true;
            updateCs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            updateCs.Customer_Ticket_Number__c = '12345';

            update updateCs;
            
            //Test.stopTest();
            
        }
        catch(Exception e)
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
        
    }

}