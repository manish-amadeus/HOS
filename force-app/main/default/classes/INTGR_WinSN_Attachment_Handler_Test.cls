/****************************************************************************************
Name            : INTGR_WinSN_Attachment_Handler_Test Test Class
Author          : Cybage
Created Date    : 03/19/2018
Last Mod Date   : 03/19/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-026092 
Description     : Tests INTGR_WinSN_Attachment_Handler Class
				: 
******************************************************************************************/
@isTest
public class INTGR_WinSN_Attachment_Handler_Test
{

    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= //    
    @testSetup static void createTestData() 
    {

        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();

		// CREATE TEST ACCOUNT        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX NI_Attachment_TriggerHandler_Test'; 
        insert a;
        
        // CREATE TEST CONTACT
        Contact p = NI_TestClassData.createTestContact(1, a.Id); 
        p.FirstName = 'Apex';
        p.LastName = 'NI_Attachment_TriggerHandler_Test';
        insert p;
        
        // CREATE TEST FLAGS ENABLED CASE 
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'APEX NI_Attachment_TriggerHandler_Test';
        c.RecordTypeId = NI_TestClassData.getRecordTypeId('Case', 'Case');
        c.ContactId = p.Id;
        c.Origin = 'Phone';
        c.AH_Enable_Case_Flag__c = true;
        insert c;

        // CREATE NON-STANDARD USER FOR ATTACHMENT TESTS
        User u = NI_TestClassData.createTestUser(11122, 'AH Customer Community Plus Login User'); 
        u.Alias = '11122'; 
        u.Username = 'XXXXtestzzz_00' + String.valueOf(11122) + '@amadeushospitality.com.ahcc';
        u.ContactId = p.Id; 
        insert u; 
        
    }
    

    // ======================================================================================================================================= //
    // = TEST METHOD 1: TEST FOR INTGR_WinSN_Attachment_Handler
    // ======================================================================================================================================= //
    @isTest static void testAttachmentTriggerHandler1()
    {

        NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        serviceNowIntegration.isAttachment = false;
        
        User cUser = NI_TestClassData.createTestUser(3001, 'System Administrator'); 
        cUser.UserName = 'ihg_servicenowTEST3001@newmarketinc.com.winaproach1';
        insert cUser;
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST3001@newmarketinc.com.winaproach1']);
        system.assertEquals(1, lstUserAsserts.Size());
        
        List<Case> listOfCases = new List<Case>();

        ServiceNowIncidentSettings__c ServicenowUsr = [SELECT Id, Integration_Username__c FROM ServiceNowIncidentSettings__c WHERE name = 'Default' LIMIT 1];
        ServicenowUsr.Integration_Username__c = 'ihg_servicenowTEST3001@newmarketinc.com.winaproach1';
        ServicenowUsr.Integration_UserId__c = cUser.id;
        update ServicenowUsr;
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        Contact con = NI_TestClassData.createTestContact(1, a1.id);    
        insert con;
        
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        {
            cs = new Case();
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
            cs.Description = 'Test Description 1';
            insert cs;               
            listOfCases.add(cs);
        }   
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        List<Case> casesToUpdate = new List<Case>();
        updateCs.Id = cs.Id;
        updateCs.subject = 'new subject';
        updateCs.Assignment_Group__c = 'MY-GLBL-Service Desk Level 3';
        updateCs.Status = 'Recovered';
        updateCs.Customer_Severity__c ='2';
        updateCs.Resolution_Summary__c = '1';
        updateCs.Resolution_Code__c = '1';
        updateCs.Description = 'Test Description 2';
        update updateCs;
        casesToUpdate.add(updateCs);

        Attachment attach = NI_TestClassData.createTestAttachment(a1.Id);
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = updateCs.id;
        insert attach;
        
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class,  new NI_ServicenowIntegrationTestMock());
        Test.stopTest();
        
    }
    
}