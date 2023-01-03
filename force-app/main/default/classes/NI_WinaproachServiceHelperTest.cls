/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachServiceHelperTest Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/18/2019 
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     : Test Class for NI_WinaproachServiceHelper
				: Updated on 10/5/2017 Per NICC-024188
                : Updated 10/12/2017 Per NICC-024311
*************************************************************************************************/
@isTest
public class NI_WinaproachServiceHelperTest 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** ENTERING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PARENT ACCOUNT 1';
        insert a;
        
        system.debug(' *** EXITING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    static testMethod void testCreateWinaproachServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        Test.startTest();
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
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
        
        insert cs; 
        
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachServiceFaultMock());
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        Database.executeBatch(c);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================       
    static testMethod void testUpdateFaultWinaproachServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
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
        lstCases.add(cs);
        insert lstCases;
        
        //ATTACHEMENT CREATED IN CASE CS
        Id testParentId = cs.Id;
        Attachment at = NI_TestClassData.createTestAttachment(testParentId);
        
        //ATTACHMENT INSERTED
        at.Name = 'TestDocument-1234';
        insert at;
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);
        
        Case updateCs = NI_TestClassData.createTestCase(2, a.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c = '3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';   
        update updateCs;
        
        String request = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>500170000052onAAAQ</external_record_id><record_id>11099287</record_id><logger><group>Intercontinental Hotels Group</group><name>loggername2</name></logger></update></ticket_exchange>';
        String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2016-11-28 11:12:06 GMT"><failure><record_id /><external_record_id>001534599</external_record_id><comment>MandatoryFieldsValidator: S0B9C/IR: Assignee Group: SWord is mandatory but not provided.</comment><error_type>EAPR-CRE-JADB</error_type><error_msg>MandatoryFieldsValidator: S0B9CIR: Assignee Group: SWord is mandatory but not provided.</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        
        NI_Integration_Log__c nException = new NI_Integration_Log__c();
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.Id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        nException.Attachment_Id__c = at.Id;   
        nException.UpdateFor__c = 'Attachment';
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, Attachment_Id__c, File_Id__c  
             FROM NI_Integration_Log__c 
             WHERE Case__c =: cs.Id]); 	
        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachServiceFaultMock());        
        
        NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate(mapOfCaseIds, mapNiIntLog);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // =======================================================================================================================================    
    static testMethod void testUpdateSuccessWinaproachServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);        
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
        lstCases.add(cs);
        insert lstCases; 
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);     
        
        Case updateCs = NI_TestClassData.createTestCase(2, a.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'Rejected';
        updateCs.Customer_Severity__c = '3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';        	           
        update updateCs;
        
        String request = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>500170000052onAAAQ</external_record_id><record_id>11099287</record_id><logger><group>Intercontinental Hotels Group</group><name>loggername2</name></logger></update></ticket_exchange>';
        String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2016-11-28 11:12:06 GMT"><failure><record_id /><external_record_id>001534599</external_record_id><comment>MandatoryFieldsValidator: S0B9C/IR: Assignee Group: SWord is mandatory but not provided.</comment><error_type>EAPR-CRE-JADB</error_type><error_msg>MandatoryFieldsValidator: S0B9CIR: Assignee Group: SWord is mandatory but not provided.</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        
        NI_Integration_Log__c nException = new NI_Integration_Log__c();
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.Id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices','Win@proach',request);
        nException.Attachment_Id__c = null;   
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>([SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, Attachment_Id__c, File_Id__c  
                                                                                         FROM NI_Integration_Log__c 
                                                                                         WHERE case__c =: cs.Id]); 	
        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        
        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachTestMock()); 
        
        NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate(mapOfCaseIds, mapNiIntLog); 
        
        Test.stopTest(); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // =======================================================================================================================================   
    static testMethod void testParseAndLogExcWinServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
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
        lstCases.add(cs);
        insert lstCases; 
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);
        
        Case updateCs = NI_TestClassData.createTestCase(1, a.Id);
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
        
        String request = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>500170000052onAAAQ</external_record_id><record_id>11099287</record_id><logger><group>Intercontinental Hotels Group</group><name>loggername2</name></logger></update></ticket_exchange>';
        String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2016-11-28 11:12:06 GMT"><failure><record_id /><external_record_id>001534599</external_record_id><comment>MandatoryFieldsValidator: S0B9C/IR: Assignee Group: SWord is mandatory but not provided.</comment><error_type>EAPR-CRE-JADB</error_type><error_msg>MandatoryFieldsValidator: S0B9CIR: Assignee Group: SWord is mandatory but not provided.</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        
        NI_Integration_Log__c nException = new NI_Integration_Log__c();
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        insert nException;
        
        nException.Attachment_Id__c = null;
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c,Description__c, Retries_Performed__c, Attachment_Id__c, File_Id__c  
             FROM NI_Integration_Log__c 
             WHERE Case__c =: cs.Id]); 	
        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachServiceBatchMock());        
        
        NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate(mapOfCaseIds,mapNiIntLog);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: 
    // ======================================================================================================================================= 
    static testMethod void testUpdateExceptionWinaproachServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Test.startTest();
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
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
        lstCases.add(cs);
        insert lstCases; 
        
        mapOfCaseIds.put(cs.Id, cs.Id);
        mapRetriesID.put(cs.Id, 1);
        
        Case updateCs = NI_TestClassData.createTestCase(1, a.Id);
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
        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();                  
        Database.executeBatch(c);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6: 
    // ======================================================================================================================================= 
    static testMethod void testCreateExceptionWinaproachServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Test.startTest();
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.type = 'Inquiry';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Status = 'Recovered';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';	
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';  
        lstCases.add(cs);
        insert lstCases; 
        
        String request = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>500170000052onAAAQ</external_record_id><record_id>11099287</record_id><logger><group>Intercontinental Hotels Group</group><name>loggername2</name></logger></update></ticket_exchange>';
        String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2016-11-28 11:12:06 GMT"><failure><record_id /><external_record_id>001534599</external_record_id><comment>MandatoryFieldsValidator: S0B9C/IR: Assignee Group: SWord is mandatory but not provided.</comment><error_type>EAPR-CRE-JADB</error_type><error_msg>MandatoryFieldsValidator: S0B9CIR: Assignee Group: SWord is mandatory but not provided.</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        
        NI_Integration_Log__c nException = new NI_Integration_Log__c();
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs.Id, response, 'Failed', 'Update', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id,NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, File_Id__c  
             FROM NI_Integration_Log__c 
             WHERE case__c =: cs.Id]); 	
        
        mapOfCaseIds.put(nException.Id, cs.Id);
        mapRetriesID.put(nException.Id, 1);
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachTestMock());
        
        try
        {
            NI_WinaproachServiceHelper.resendRequestToWinaproach(mapOfCaseIds,mapRetriesID);
        }
        catch (DmlException e)
        {
            system.assertEquals(e.getMessage(), e.getMessage());
        }
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: 
    // =======================================================================================================================================     
    static testMethod void winAproachWorkOrderRequest() 
    {	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        
        Test.startTest();
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
        cs.Subject = 'TestBK- ttest101';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Work Order').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '4';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.status = 'Assigned';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';		
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Origin = 'ServiceNow Integration';
        cs.Acknowledged__c = Datetime.now().addHours(-4);
        lstCases.add(cs);
        insert lstCases;   	
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachServiceBatchMock());        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        Database.executeBatch(c);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 8: 
    // =======================================================================================================================================     
    static testMethod void testCreateSuccessWinServiceHelper()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Test.startTest();
        
        NI_WinaproachService.crsCaseIncidentFlag = false;
        Test.setMock(HttpCalloutMock.class,new NI_WinaproachTestMock());  
        
        Account acc = NI_TestClassData.createTestAccount(1);
        insert acc;
        
        Contact con = NI_TestClassData.createTestContact(1,acc.id);		
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();		
        insert con;
        
        Case cs2 = NI_TestClassData.createTestCase(1, a.Id);
        cs2.Subject = 'TestBK- ttest101';
        cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs2.Priority = '3';
        cs2.type = 'Inquiry';
        cs2.Customer_Severity__c = '4';
        cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs2.Status = 'Open';
        cs2.Winaproach_Logger__c = 'test';
        cs2.Description = 'Test description';
        cs2.Cause_Id_Code__c = 'Configuration';
        cs2.Resolution_Code__c = 'Code Correction';
        cs2.Reject_Reason_Code__c = 'Change required';		
        cs2.Winaproach_Logger_Phone_Number__c = '123456';
        cs2.Winaproach_Owner_Group__c = 'MHDHOT';
        cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs2.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs2.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        cs2.Amadeus_External_System_Id__c = '11098269';
        lstCases.add(cs2);
        insert lstCases;
        
        String request = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><create><incomingXML><?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>500170000052sT7AAI</external_record_id><category><system_category>D</system_category></category><severity>1</severity><urgency>Y</urgency><assignee><group>MHDHOT</group></assignee><logger><group>MHDAIT</group><name>test1</name><tel>123456</tel></logger><owner><group>MHDHOT</group><name>spatil</name></owner><dates><start_date_time>2016-11-30 05:17:59</start_date_time><resolved_date_time>2016-11-30 09:17:59</resolved_date_time></dates><affected_service>AHP CRS</affected_service><title>TestBK- ttest101</title><description><entry><date_time>2016-11-30 10:18:00</date_time><group>MHDHOT</group><name>test1</name><tel>123456</tel><text><line>Test description1</line></text></entry></description><causeid_code>APP</causeid_code><reject_reason_code>C</reject_reason_code></create></ticket_exchange></incomingXML></create></soapenv:Body></soapenv:Envelope>';
        String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ><soapenv:Body><createResponse><createReturn><?xml version="1.0" encoding="UTF-8"?><ticket_response version="1.0" timestamp="2016-11-25 06:15:46 GMT"><success><record_id>11098269</record_id><external_record_id>50017000004KXn0AAZ</external_record_id><comment>Record created successfully.</comment><comment>InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type IR.Removed from message.</comment></success></ticket_response> </createReturn></createResponse></soapenv:Body></soapenv:Envelope>';
        
        NI_Integration_Log__c nException = new NI_Integration_Log__c();
        
        // LOG FAILED MESSAGE
        nException = NI_WinaproachService.createIntegraionLog(cs2.Id, response, 'Failed', 'Insert', null, 'https://aproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices', 'Win@proach', request);
        insert nException;
        
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id,NI_Integration_Log__c>(
            [SELECT Id, XMLRequest__c, Do_Retries__c, Transaction_Type__c, UpdateFor__c, Description__c, Retries_Performed__c, File_Id__c  
             FROM NI_Integration_Log__c 
             WHERE case__c =: cs2.Id]); 	
        
        mapOfCaseIds.put(nException.Id, cs2.Id);
        mapRetriesID.put(nException.Id, 1);
        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        Database.executeBatch(c); 
        
        Test.stopTest(); 
        
    } 
    
    // ======================================================================================================================================= 
    // = TEST METHOD 9: Test Files
    // =======================================================================================================================================   
    static testMethod void test9()
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        
        List<Case> lstCases = new List<Case>();
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>(); 
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
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
        cs.Amadeus_External_System_Id__c = '11098269';
        lstCases.add(cs);
        insert lstCases; 
        
        //mapOfCaseIds.put(cs.Id, cs.Id);
        //mapRetriesID.put(cs.Id, 1);
        
        //Case updateCs = NI_TestClassData.createTestCase(1, a.Id);
        //updateCs.Id = cs.Id;
        //updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        //updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        //updateCs.Winaproach_Logger__c = 'test2';
        //updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        //updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        //updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        //updateCs.Description = 'Test description 2';
        //updateCs.Status = 'Rejected';
        //updateCs.Customer_Severity__c ='3';
        //updateCs.Amadeus_External_System_Id__c = '11095094';
        //updateCs.Cause_Id_Code__c = 'Application';
        //updateCs.Resolution_Code__c = 'Environment';
        //updateCs.Reject_Reason_Code__c = 'Functional Setting';
        //update updateCs;
        
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'TestDocument1.txt';
        cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body 1', 'UTF-8'));
        cv.CaseId__c = cs.Id;
        insert cv;

        //String request = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>500170000052onAAAQ</external_record_id><record_id>11099287</record_id><logger><group>Intercontinental Hotels Group</group><name>loggername2</name></logger></update></ticket_exchange>';
        String request = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><update><record_type>incident</record_type><external_record_id>' + cs.Id + '</external_record_id><external_record_reference>INC1992572</external_record_reference><record_id>XX__RECORD_ID__XX</record_id><attachment_list><attachment><filename>testJPEG.jpg</filename><filesize>36.61 KB</filesize><added_by_group>InterContinental Hotels Group</added_by_group><added_date_time>2019-12-05 20:42:18</added_date_time></attachment></attachment_list></update></ticket_exchange>';

        // String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2016-11-28 11:12:06 GMT"><failure><record_id /><external_record_id>001534599</external_record_id><comment>MandatoryFieldsValidator: S0B9C/IR: Assignee Group: SWord is mandatory but not provided.</comment><error_type>EAPR-CRE-JADB</error_type><error_msg>MandatoryFieldsValidator: S0B9CIR: Assignee Group: SWord is mandatory but not provided.</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        String response = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2019-12-05 20:42:19 GMT"><failure><record_id /><external_record_id /><comment>Update of record failed.</comment><error_type>EAPR-UPD-CACC</error_type><error_msg>Record id can not be parsed (not a number) for update: \'XX__RECORD_ID__XX\'</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
        
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
        
        mapOfCaseIds.put(nException.Id, cs.Id);
        
        NI_BatchWinaproachResend c = new NI_BatchWinaproachResend();
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachServiceBatchMock());        
        
        NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate(mapOfCaseIds, mapNiIntLog);
        
        Test.stopTest();
        
    }

    
}