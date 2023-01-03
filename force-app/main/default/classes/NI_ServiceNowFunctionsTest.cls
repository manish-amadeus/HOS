/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_ServiceNowFunctionsTest Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/23/2019 
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     : Test class for the NI_ServiceNowFunctions class
                : 
*************************************************************************************************/
@isTest
public class NI_ServiceNowFunctionsTest 
{     

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        system.debug(' *** ENTERING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();

        Account aIHG = NI_TestClassData.createTestAccount(1);
        aIHG.Name = 'APEX IHG TEST ACCOUNT';
        insert aIHG;
        
		ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default'); 
        SNSettings.Integration_Username__c = 'ihg_servicenowTEST@amadeus.com.winaproach';
        SNSettings.AccountId__c = aIHG.Id;
        update SNSettings; 
            
        Winaproach_System_Affected__c systemAffected = new Winaproach_System_Affected__c();
        systemAffected.Name = 'Production';
        systemAffected.System_Category__c = 'P';
        insert systemAffected;        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PARENT ACCOUNT 1';
        insert a;

        //Contact con = NI_TestClassData.createTestContact(1, a.Id);		
        //con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        //con.FirstName = 'Apex';
        //con.LastName = 'Tester';
        //insert con;

        //User u = NI_TestClassData.createTestUser(1, 'System Administrator');
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
    @isTest static void testParseAndLogResponse()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        //Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];
        
        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;
        
        /*
        User cUser = NI_TestClassData.createTestUser(130, 'System Administrator'); 
        cUser.UserName = 'ihg_servicenowTEST30@newmarketinc.com.winaproach1';
        insert cUser;
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST30@newmarketinc.com.winaproach1']);
        system.assertEquals(1, lstUserAsserts.Size());
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        ServiceNowIncidentSettings__c ServicenowUsr = [SELECT Id, Integration_Username__c FROM ServiceNowIncidentSettings__c WHERE name = 'Default' LIMIT 1];
        ServicenowUsr.Integration_Username__c = 'ihg_servicenowTEST30@newmarketinc.com.winaproach1';
        ServicenowUsr.Integration_UserId__c = cUser.Id;
        update ServicenowUsr;
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        Contact con = NI_TestClassData.createTestContact(1, a1.Id);    
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();    
        insert con;
        */
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

        String request = '<request><entry><u_number>INC0010116</u_number><u_correlation_display>001734547</u_correlation_display><u_problem_id>001734547</u_problem_id><u_correlation_id>50063000003XJr3AAG</u_correlation_id><u_short_description>Test Case1</u_short_description></entry></request>';
        String response = '<response><import_set>ISET0010058</import_set><staging_table>u_integ_amadeus_incidents</staging_table><result><display_value>INC0010117</display_value><sys_id>e4455cd5db0fe200ddd1b34ffe961966</sys_id><transform_map>Amadeus Incidents</transform_map><record_link>link</record_link><display_name>number</display_name><table>incident</table><status>inserted</status></result></response>';
        
        String resHeader = 'Created';
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        String importsetendPoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
        servNowFun.parseAndLogResponse(response, cs.Id, servNowFun.importSetEndPoint, 'Insert', 'Case', new List<Case>(), new List<NI_Integration_Log__c>(), request, resHeader, null, null);
        
        List<NI_Integration_Log__c> lstlogAsserts = new List<NI_Integration_Log__c>([SELECT Id FROM NI_Integration_Log__c ]);
        system.assertEquals(0, lstlogAsserts.Size());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================     
    @isTest static void testParseAndLogResponseBatch()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        //Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];
        
        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;
        
        /*
        User cUser = NI_TestClassData.createTestUser(131, 'System Administrator'); 
        cUser.UserName = 'ihg_servicenowTEST31@newmarketinc.com.winaproach1';
        insert cUser;
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST31@newmarketinc.com.winaproach1']);
        system.assertEquals(1, lstUserAsserts.Size());
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        ServiceNowIncidentSettings__c ServicenowUsr = [SELECT Id, Integration_Username__c FROM ServiceNowIncidentSettings__c WHERE name = 'Default' LIMIT 1];
        ServicenowUsr.Integration_Username__c = 'ihg_servicenowTEST31@newmarketinc.com.winaproach1';
        ServicenowUsr.Integration_UserId__c = cUser.Id;
        update ServicenowUsr;
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        Contact con = NI_TestClassData.createTestContact(1, a1.Id);    
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();    
        insert con;
        */
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
        
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        
        String request = '<request><entry><u_number>INC0010116</u_number><u_correlation_display>001734547</u_correlation_display><u_problem_id>001734547</u_problem_id><u_correlation_id>50063000003XJr3AAG</u_correlation_id><u_short_description>Test Case1</u_short_description></entry></request>';
        String response = '<response><import_set>ISET0010058</import_set><staging_table>u_integ_amadeus_incidents</staging_table><result><display_value>INC0010117</display_value><sys_id>e4455cd5db0fe200ddd1b34ffe961966</sys_id><transform_map>Amadeus Incidents</transform_map><record_link>link</record_link><display_name>number</display_name><table>incident</table><status>inserted</status></result></response>';
        
        
        // LOG FAILED MESSAGE
        NI_Integration_Log__c niLog = new NI_Integration_Log__c();
        niLog = NI_WinaproachService.createIntegraionLog(cs.Id, response, 'Success', 'Insert', null, servNowFun.importSetEndPoint, 'ServiceNow', request);
        niLog.Attachment_Id__c = null;   
        niLog.UpdateFor__c = 'Attachment';
        insert niLog;
        
        String resHeader = 'Created';
        String importsetendPoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
        servNowFun.parseAndLogResponseBatch(niLog.Id, cs.Id, request, response, resHeader, new List<Case>(), new List<NI_Integration_Log_Message__c>(), new List<Id>(), new List<Id>(), null);
 
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3: Attachments
    // =======================================================================================================================================     
    @isTest static void test3()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        
        Case cs;
        Attachment attach;
        
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
            
            attach = NI_TestClassData.createTestAttachment(a1.Id);
            attach.Name = 'Unit Test Attachment';
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = cs.Id;
            insert attach;

        } 

        String request = '<request><entry><u_number>INC0010116</u_number><u_correlation_display>001734547</u_correlation_display><u_problem_id>001734547</u_problem_id><u_correlation_id>50063000003XJr3AAG</u_correlation_id><u_short_description>Test Case1</u_short_description></entry></request>';
        String response = '<response><import_set>ISET0010058</import_set><staging_table>u_integ_amadeus_incidents</staging_table><result><display_value>INC0010117</display_value><sys_id>e4455cd5db0fe200ddd1b34ffe961966</sys_id><transform_map>Amadeus Incidents</transform_map><record_link>link</record_link><display_name>number</display_name><table>incident</table><status>inserted</status></result></response>';

        NI_Integration_Log__c nException = new NI_Integration_Log__c(); 
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        nException.Attachment_Id__c = attach.Id;
        nException.Attachment_Name__c = 'TestDocument1.txt';
        nException.UpdateFor__c = 'Attachment';
        nException.Case__c = cs.Id;
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, Attachment_Id__c, File_Id__c 
             FROM NI_Integration_Log__c 
             WHERE Case__c =: cs.Id]); 	
        
        mapOfCaseIds.put(nException.Id, cs.Id);
        
        String resHeader = 'Created';
        String importsetendPoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
 
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        servNowFun.parseAndLogResponseBatch(nException.Id, cs.Id, request, response, resHeader, new List<Case>(), new List<NI_Integration_Log_Message__c>(), new List<Id>(), new List<Id>(), null);

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());    
        
        NI_ServicenowFunctions.resendRequestToServiceNowUpdate(mapOfCaseIds, mapOfCaseIds, mapNiIntLog);
        //servNowFun.Servicenow_Post_Request(request);
        
        Test.stopTest();            
   
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4: Attachments
    // =======================================================================================================================================     
    @isTest static void test4()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        Case cs;
        Attachment attach;
        Set<Id> setAttachIds = new Set<Id>();
        
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
            
            attach = NI_TestClassData.createTestAttachment(a1.Id);
            attach.Name = 'Unit Test Attachment';
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = cs.Id;
            insert attach;

            setAttachIds.add(attach.Id); 
            
        } 

        String request = '<request><entry><u_number>INC0010116</u_number><u_correlation_display>001734547</u_correlation_display><u_problem_id>001734547</u_problem_id><u_correlation_id>50063000003XJr3AAG</u_correlation_id><u_short_description>Test Case1</u_short_description></entry></request>';
        String response = '<response><import_set>ISET0010058</import_set><staging_table>u_integ_amadeus_incidents</staging_table><result><display_value>INC0010117</display_value><sys_id>e4455cd5db0fe200ddd1b34ffe961966</sys_id><transform_map>Amadeus Incidents</transform_map><record_link>link</record_link><display_name>number</display_name><table>incident</table><status>inserted</status></result></response>';

        NI_Integration_Log__c nException = new NI_Integration_Log__c(); 
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        nException.Attachment_Id__c = attach.Id;
        nException.Attachment_Name__c = 'TestDocument1.txt';
        nException.UpdateFor__c = 'Attachment';
        nException.Case__c = cs.Id;
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, Attachment_Id__c, File_Id__c 
             FROM NI_Integration_Log__c 
             WHERE Case__c =: cs.Id]); 	

        String resHeader = 'Created';
        String importsetendPoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
 
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        servNowFun.parseAndLogResponseBatch(nException.Id, cs.Id, request, response, resHeader, new List<Case>(), new List<NI_Integration_Log_Message__c>(), new List<Id>(), new List<Id>(), null);

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());    
        
		NI_ServicenowFunctions.attachment_Callout(setAttachIds);
        
        Test.stopTest();            
   
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: Files
    // =======================================================================================================================================     
    @isTest static void test5()
    {
        
        User cUser = [SELECT Id, UserName FROM User WHERE FirstName = 'Joe' AND LastName = 'SNUser' AND UserName = 'ihg_servicenowTEST@amadeus.com.winaproach'];
        Account a1 = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;

        //Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        
        Case cs;
        ContentVersion cv;
		ContentVersion cv2;
        Set<Id> setDocIds = new Set<Id>();
       
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
            
            cv = new ContentVersion();
            cv.PathOnClient = 'TestDocument1.txt';
            cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body 1', 'UTF-8'));
            cv.CaseId__c = cs.Id;
            insert cv;
            
            cv2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
            
            setDocIds.add(cv2.ContentDocumentId); 
            
        } 

        String request = '<request><entry><u_number>INC0010116</u_number><u_correlation_display>001734547</u_correlation_display><u_problem_id>001734547</u_problem_id><u_correlation_id>50063000003XJr3AAG</u_correlation_id><u_short_description>Test Case1</u_short_description></entry></request>';
        String response = '<response><import_set>ISET0010058</import_set><staging_table>u_integ_amadeus_incidents</staging_table><result><display_value>INC0010117</display_value><sys_id>e4455cd5db0fe200ddd1b34ffe961966</sys_id><transform_map>Amadeus Incidents</transform_map><record_link>link</record_link><display_name>number</display_name><table>incident</table><status>inserted</status></result></response>';

        NI_Integration_Log__c nException = new NI_Integration_Log__c(); 
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        nException.File_Id__c = cv.Id;
        nException.File_Name__c = 'TestDocument1.txt';
        nException.UpdateFor__c = 'File';
        nException.Case__c = cs.Id;
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, Attachment_Id__c, File_Id__c 
             FROM NI_Integration_Log__c 
             WHERE Case__c =: cs.Id]); 	
        
        //mapOfCaseIds.put(nException.Id, cs.Id);
        
        String resHeader = 'Created';
        String importsetendPoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
 
        NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        servNowFun.parseAndLogResponseBatch(nException.Id, cs.Id, request, response, resHeader, new List<Case>(), new List<NI_Integration_Log_Message__c>(), new List<Id>(), new List<Id>(), null);

        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());    
        
        //NI_ServicenowFunctions.resendRequestToServiceNowUpdate(mapOfCaseIds, mapOfCaseIds, mapNiIntLog);
        //servNowFun.Servicenow_Post_Request(request);
        
        NI_ServicenowFunctions.fileCallout(setDocIds);
        
        Test.stopTest();            
   
    }
    
}