/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : NI_Integration_Log_TriggerHandlerTest 
Author          : Sean Harris
Created Date    : 05/03/2018
Last Mod Date   : 01/17/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for NI_Integration_Log_TriggerHandler
				: 
				: 
*************************************************************************************************/
@isTest
private class NI_Integration_Log_TriggerHandlerTest 
{

    // ======================================================================================================================================= 
    // = TEST METHOD 1: LEGACY WIN@PROACH INTEGRATION LOG (INSERT)
    // =======================================================================================================================================     
    static testMethod void test1() 
    {    
        
        // CREATE TEST INTEGRATION USERS
        // WIN@PRCH 
        User waUser = NI_TestClassData.createTestUser(1, 'Winaproach Integration Only - Standard'); 
        waUser.FirstName = 'Winaproach';
        waUser.LastName = 'Useraccount';
        waUser.CommunityNickname = 'apex0001';
        waUser.UserName = 'winaproachTEST@newmarketinc.com.apextestx';
        insert waUser;    
        
        // IHG CUSTOMER
        User snUser = NI_TestClassData.createTestUser(2, 'IHG Integration Only - Standard'); 
        snUser.FirstName = 'InterContinental';
        snUser.LastName = 'Useraccount'; 
        snUser.CommunityNickname = 'apex0002';
        snUser.UserName = 'ihg_servicenowTEST@newmarketinc.com.apextestx';
        insert snUser;              
        
        // CREATE TEST IHG ACCOUNT & CONTACT
        Account accIHG = NI_TestClassData.createTestAccount(1);
        accIHG.Name = 'NI_Integration_Log_TriggerHandlerTest IHG Account';
        insert accIHG; 
        
        Contact cntIHG = NI_TestClassData.createTestContact(1, accIHG.Id);		
        cntIHG.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        cntIHG.FirstName = 'InterContinental';
        cntIHG.LastName = 'Contact';
        insert cntIHG;    
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        WinaproachIncidentSettings__c ws = WinaproachIncidentSettings__c.getInstance('Default');
        ws.Integration_Username__c = 'winaproachTEST@newmarketinc.com.apextestx';
        update ws;
        
        ServiceNowIncidentSettings__c sn = [SELECT Id, AccountId__c, Integration_UserId__c, Integration_Username__c 
                                            FROM ServiceNowIncidentSettings__c 
                                            WHERE name = 'Default' 
                                            LIMIT 1];
        
        sn.Integration_Username__c = 'ihg_servicenowTEST@newmarketinc.com.apextestx';
        sn.Integration_UserId__c = snUser.Id;
        sn.AccountId__c = accIHG.Id;
        update sn;         

        Case c = NI_TestClassData.createTestCase(1, accIHG.Id);
        c.AccountId = null;
        c.Subject = 'APEX TEST testIntegrationLogTH IHG';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        c.type = 'Inquiry';
        c.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        c.Status = 'Recovered';
        c.Winaproach_Logger__c = 'test';
        c.Description = 'Test description';	
        c.Origin = 'Win@proach Integration';
        c.System_Affected__c = 'Disaster Recovery'; 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        insert c;            
        
        String sCaseId = string.valueOf(c.Id);
        
        NI_Integration_Log__c il1 = new NI_Integration_Log__c();
        il1.Case__c = c.Id;
        il1.Do_Retries__c = true;
        il1.Integration_Name__c = 'Win@proach';
        il1.Log_Date__c = Datetime.now();
        il1.Retries_Performed__c = 0;
        il1.Status__c = 'Failed';
        il1.Transaction_Type__c = 'Insert';
        il1.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il1.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il1.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il1;   
        
        NI_Integration_Log__c il2 = new NI_Integration_Log__c();
        il2.Case__c = c.Id;
        il2.Do_Retries__c = true;
        il2.Integration_Name__c = 'Win@proach';
        il2.Log_Date__c = Datetime.now();
        il2.Retries_Performed__c = 0;
        il2.Status__c = 'Failed';
        il2.Transaction_Type__c = 'Update';
        il2.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il2.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il2.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il2;   
        
        
	    Test.startTest(); 

        // ASSERT THAT THERE ARE INTEGRATION LOG RECORDS THAT MEET CRITERIA FOR NI_BatchWinaproachResend CLASS QUERY
        List<NI_Integration_Log__c> lstILogAsserts = new List<NI_Integration_Log__c>(
            [SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, 
             Retries_Performed__c, Do_Retries__c, XMLRequest__c, Attachment_Id__c ,File_Id__c 
             FROM NI_Integration_Log__c 
             WHERE Status__c = 'Failed' 
             AND Integration_Name__c = 'Win@proach' 
             AND Integration_Case__c = null 
             AND Do_Retries__c = true 
             AND Retries_Performed__c < 5]); 

        system.assertEquals(2, lstILogAsserts.size());
        
        // ABORT ANY EXISTING TEST JOBS
//        for (CronTrigger ct : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN ('ResendJob', 'Resend_Message')])
//        {
//            system.abortJob(ct.Id);
//        }        
        
        NI_BatchWinaproachResend x = new NI_BatchWinaproachResend(); 

        Id batchprocessid = Database.executeBatch(x); 
        system.debug('batchprocessid = ' + batchprocessid);
        system.assertNotEquals(null, batchprocessid);

        Test.stopTest(); 

    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: LEGACY SERVICE NOW INTEGRATION LOG (INSERT)
    // ======================================================================================================================================= 
    static testMethod void test2() 
    {    
        
        // CREATE TEST INTEGRATION USERS
        // WIN@PRCH 
        User waUser = NI_TestClassData.createTestUser(1, 'Winaproach Integration Only - Standard'); 
        waUser.FirstName = 'Winaproach';
        waUser.LastName = 'Useraccount';
        waUser.CommunityNickname = 'apex0001';
        waUser.UserName = 'winaproachTEST@newmarketinc.com.apextestx';
        insert waUser;    
        
        // IHG CUSTOMER
        User snUser = NI_TestClassData.createTestUser(2, 'IHG Integration Only - Standard'); 
        snUser.FirstName = 'InterContinental';
        snUser.LastName = 'Useraccount'; 
        snUser.CommunityNickname = 'apex0002';
        snUser.UserName = 'ihg_servicenowTEST@newmarketinc.com.apextestx';
        insert snUser;              
        
        // CREATE TEST IHG ACCOUNT & CONTACT
        Account accIHG = NI_TestClassData.createTestAccount(1);
        accIHG.Name = 'NI_Integration_Log_TriggerHandlerTest IHG Account';
        insert accIHG; 
        
        Contact cntIHG = NI_TestClassData.createTestContact(1, accIHG.Id);		
        cntIHG.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        cntIHG.FirstName = 'InterContinental';
        cntIHG.LastName = 'Contact';
        insert cntIHG;    
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        WinaproachIncidentSettings__c ws = WinaproachIncidentSettings__c.getInstance('Default');
        ws.Integration_Username__c = 'winaproachTEST@newmarketinc.com.apextestx';
        update ws;
        
        ServiceNowIncidentSettings__c sn = [SELECT Id, AccountId__c, Integration_UserId__c, Integration_Username__c 
                                            FROM ServiceNowIncidentSettings__c 
                                            WHERE name = 'Default' 
                                            LIMIT 1];
        
        sn.Integration_Username__c = 'ihg_servicenowTEST@newmarketinc.com.apextestx';
        sn.Integration_UserId__c = snUser.Id;
        sn.AccountId__c = accIHG.Id;
        update sn;         

        Case c = NI_TestClassData.createTestCase(1, accIHG.Id);
        c.AccountId = null;
        c.Subject = 'APEX TEST testIntegrationLogTH IHG';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        c.type = 'Inquiry';
        c.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        c.Status = 'Recovered';
        c.Winaproach_Logger__c = 'test';
        c.Description = 'Test description';	
        c.Origin = 'Win@proach Integration';
        c.System_Affected__c = 'Disaster Recovery'; 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        insert c;            
        
        String sCaseId = string.valueOf(c.Id);
        
        NI_Integration_Log__c il1 = new NI_Integration_Log__c();
        il1.Case__c = c.Id;
        il1.Do_Retries__c = true;
        il1.Integration_Name__c = 'ServiceNow';
        il1.Log_Date__c = Datetime.now();
        il1.Retries_Performed__c = 0;
        il1.Status__c = 'Failed';
        il1.Transaction_Type__c = 'Insert';
        il1.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il1.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il1.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il1;   
        
        NI_Integration_Log__c il2 = new NI_Integration_Log__c();
        il2.Case__c = c.Id;
        il2.Do_Retries__c = true;
        il2.Integration_Name__c = 'ServiceNow';
        il2.Log_Date__c = Datetime.now();
        il2.Retries_Performed__c = 0;
        il2.Status__c = 'Failed';
        il2.Transaction_Type__c = 'Update';
        il2.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il2.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il2.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il2;   

        
	    Test.startTest(); 

        // ASSERT THAT THERE ARE INTEGRATION LOG RECORDS THAT MEET CRITERIA FOR NI_BatchServiceNowResend CLASS QUERY
        List<NI_Integration_Log__c> lstILogAsserts = new List<NI_Integration_Log__c>(
            [SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, 
             Retries_Performed__c, Do_Retries__c, XMLRequest__c, Attachment_Id__c  
             FROM NI_Integration_Log__c 
             WHERE Status__c = 'Failed' 
             AND Integration_Name__c = 'ServiceNow' 
             AND Integration_Case__c = null 
             AND Do_Retries__c = true 
             AND Retries_Performed__c < 5]); 

        system.assertEquals(2, lstILogAsserts.size());

        // ABORT ANY EXISTING TEST JOBS
//        for (CronTrigger ct : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name IN ('ResendJobServiceNow', 'Resend_ServiceNowMessage')])
//        {
//            system.abortJob(ct.Id);
//        }
        
        NI_BatchServiceNowResend x = new NI_BatchServiceNowResend(); 

        Id batchprocessid = Database.executeBatch(x); 
        system.debug('batchprocessid = ' + batchprocessid);
        system.assertNotEquals(null, batchprocessid);
         
        Test.stopTest(); 

    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3: NEXT WIN@PROACH INTEGRATION LOG
    // ======================================================================================================================================= 
    static testMethod void test3() 
    {    
        
        // CREATE TEST INTEGRATION USERS
        // WIN@PRCH 
        User waUser = NI_TestClassData.createTestUser(1, 'Winaproach Integration Only - Standard'); 
        waUser.FirstName = 'Winaproach';
        waUser.LastName = 'Useraccount';
        waUser.CommunityNickname = 'apex0001';
        waUser.UserName = 'winaproachTEST@newmarketinc.com.apextestx';
        insert waUser;    
        
        // NEXT CUSTOMER
        User newUser = NI_TestClassData.createTestUser(3, 'Case Integration Customers'); 
        newUser.FirstName = 'Next';
        newUser.LastName = 'Useraccount';    
        newUser.CommunityNickname = 'apex0003';
        newUser.UserName = 'servicenowTEST@newmarketinc.com.apextestx';
        insert newUser;            
        
        // CREATE TEST IHG ACCOUNT & CONTACT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Integration_Log_TriggerHandlerTest NEXT Account';
        insert a; 
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);		
        cnt.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        cnt.FirstName = 'Next';
        cnt.LastName = 'User';
        insert cnt;    

        // CREATE TEST INTEGRATION ACCOUNT RECORD
        INTGR_Account__c iAcc = NI_TestClassData.createTestINTGR_Account(1, a.Id, newUser.Id);
        iAcc.Active__c = true;
        iAcc.Assignment_Group__c = 'Test Group';
        iAcc.Case_Origin__c = 'ServiceNow';
        iAcc.Logger_Desk_Agent_Name__c = 'ServiceNow';
        iAcc.Default_New_Case_Status__c = 'New';
        iAcc.Logger_Desk_Agent_Phone__c = '123456789';
        iAcc.Logger_Group__c = 'ServiceNow';
        iAcc.Resend_Failed_Message_Interval_in_Min__c = 1;
        iAcc.Max_Count_To_Resend_Failed_Message__c = 5;
        insert iAcc;
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        WinaproachIncidentSettings__c ws = WinaproachIncidentSettings__c.getInstance('Default');
        ws.Integration_Username__c = 'winaproachTEST@newmarketinc.com.apextestx';
        update ws;  

        // CREATE TEST NEXT CASE
        INTGR_Case__c ics = NI_TestClassData.createTestINTGR_Case(1, iAcc.Id, null);
        ics.Customer_Ticket_System_Id__c = 'INC000001';
        ics.Customer_Ticket_Number__c = 'INC000001';
        ics.Status__c = 'Acknowledged';
        ics.Subject__c = 'APEX TEST testIntegrationLogTH NEXT';
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        insert ics;             
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        //c.AccountId = null;		// ADDED DUE TO PERMISSIONS
        c.Subject = 'APEX TEST testIntegrationLogTH IHG';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        c.type = 'Inquiry';
        c.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        c.Status = 'Recovered';
        c.Winaproach_Logger__c = 'test';
        c.Description = 'Test description';	
        c.Origin = 'Win@proach Integration';
        c.System_Affected__c = 'Disaster Recovery'; 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        insert c;            
        
        String sCaseId = string.valueOf(c.Id);
        
        NI_Integration_Log__c il1 = new NI_Integration_Log__c();
        il1.Case__c = c.Id;
        il1.Do_Retries__c = true;
        il1.Integration_Case__c = ics.Id;
        il1.Integration_Name__c = 'Win@proach';
        il1.Log_Date__c = Datetime.now();
        il1.Retries_Performed__c = 0;
        il1.Status__c = 'Failed';
        il1.Transaction_Type__c = 'Insert';
        il1.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il1.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il1.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il1;           

        
        NI_Integration_Log__c il2 = new NI_Integration_Log__c();
        il2.Case__c = c.Id;
        il2.Do_Retries__c = true;
        il2.Integration_Case__c = ics.Id;
        il2.Integration_Name__c = 'Win@proach';
        il2.Log_Date__c = Datetime.now();
        il2.Retries_Performed__c = 0;
        il2.Status__c = 'Failed';
        il2.Transaction_Type__c = 'Update';
        il2.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il2.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il2.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il2;           
        
	    Test.startTest(); 

        // ASSERT THAT THERE ARE INTEGRATION LOG RECORDS THAT MEET CRITERIA FOR INTGR_ResendWinaproach CLASS QUERY
        List<NI_Integration_Log__c> lstILogAsserts = new List<NI_Integration_Log__c>(
            [SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, 
             Retries_Performed__c, Do_Retries__c, XMLRequest__c, Attachment_Id__c  
             FROM NI_Integration_Log__c 
             WHERE Status__c = 'Failed' 
             AND Integration_Name__c = 'Win@proach' 
             AND Integration_Case__r.INTGR_Account__c =: iAcc.Id 
             AND Do_Retries__c = true 
             AND Retries_Performed__c < 5]); 

        system.assertEquals(2, lstILogAsserts.size());
        
        // ABORT ANY EXISTING TEST JOBS
//        for (CronTrigger ct : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'INTGR_%'])
//        {
//            system.abortJob(ct.Id);
//        }
        
        Integer iResendInterval = Integer.valueOf(iAcc.Resend_Failed_Message_Interval_in_Min__c);
        
        INTGR_ResendWinaproach x = new INTGR_ResendWinaproach('INTGR_Resend_WINAPRCH_', iAcc.Id, iResendInterval); 

        Id batchprocessid = Database.executeBatch(x); 
        system.debug('batchprocessid = ' + batchprocessid);
        system.assertNotEquals(null, batchprocessid);
        
        Test.stopTest(); 

    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4: NEXT SERVICE NOW INTEGRATION LOG
    // ======================================================================================================================================= 
    static testmethod void test4() 
    {
        
        // CREATE TEST INTEGRATION USERS
        // WIN@PRCH 
        User waUser = NI_TestClassData.createTestUser(1, 'Winaproach Integration Only - Standard'); 
        waUser.FirstName = 'Winaproach';
        waUser.LastName = 'Useraccount';
        waUser.CommunityNickname = 'apex0001';
        waUser.UserName = 'winaproachTEST@newmarketinc.com.apextestx';
        insert waUser;    
        
        // NEXT CUSTOMER
        User newUser = NI_TestClassData.createTestUser(3, 'Case Integration Customers'); 
        newUser.FirstName = 'Next';
        newUser.LastName = 'Useraccount';    
        newUser.CommunityNickname = 'apex0003';
        newUser.UserName = 'servicenowTEST@newmarketinc.com.apextestx';
        insert newUser;            
        
        // CREATE TEST IHG ACCOUNT & CONTACT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Integration_Log_TriggerHandlerTest NEXT Account';
        insert a; 
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);		
        cnt.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        cnt.FirstName = 'Next';
        cnt.LastName = 'User';
        insert cnt;    

        // CREATE TEST INTEGRATION ACCOUNT RECORD
        INTGR_Account__c iAcc = NI_TestClassData.createTestINTGR_Account(1, a.Id, newUser.Id);
        iAcc.Active__c = true;
        iAcc.Assignment_Group__c = 'Test Group';
        iAcc.Case_Origin__c = 'ServiceNow';
        iAcc.Logger_Desk_Agent_Name__c = 'ServiceNow';
        iAcc.Default_New_Case_Status__c = 'New';
        iAcc.Logger_Desk_Agent_Phone__c = '123456789';
        iAcc.Logger_Group__c = 'ServiceNow';
        iAcc.Resend_Failed_Message_Interval_in_Min__c = 1;
        iAcc.Max_Count_To_Resend_Failed_Message__c = 5;
        insert iAcc;
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        WinaproachIncidentSettings__c ws = WinaproachIncidentSettings__c.getInstance('Default');
        ws.Integration_Username__c = 'winaproachTEST@newmarketinc.com.apextestx';
        update ws;  

        // CREATE TEST NEXT CASE
        INTGR_Case__c ics = NI_TestClassData.createTestINTGR_Case(1, iAcc.Id, null);
        ics.Customer_Ticket_System_Id__c = 'INC000001';
        ics.Customer_Ticket_Number__c = 'INC000001';
        ics.Status__c = 'Acknowledged';
        ics.Subject__c = 'APEX TEST testIntegrationLogTH NEXT';
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        insert ics;             
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        //c.AccountId = null;		// ADDED DUE TO PERMISSIONS
        c.Subject = 'APEX TEST testIntegrationLogTH IHG';
        c.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        c.type = 'Inquiry';
        c.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        c.Status = 'Recovered';
        c.Winaproach_Logger__c = 'test';
        c.Description = 'Test description';	
        c.Origin = 'Win@proach Integration';
        c.System_Affected__c = 'Disaster Recovery'; 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        insert c;            
        
        String sCaseId = string.valueOf(c.Id);
        
        NI_Integration_Log__c il1 = new NI_Integration_Log__c();
        il1.Case__c = c.Id;
        il1.Do_Retries__c = true;
        il1.Integration_Case__c = ics.Id;
        il1.Integration_Name__c = 'ServiceNow';
        il1.Log_Date__c = Datetime.now();
        il1.Retries_Performed__c = 0;
        il1.Status__c = 'Failed';
        il1.Transaction_Type__c = 'Insert';
        il1.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il1.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il1.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il1;           
        
        NI_Integration_Log__c il2 = new NI_Integration_Log__c();
        il2.Case__c = c.Id;
        il2.Do_Retries__c = true;
        il2.Integration_Case__c = ics.Id;
        il2.Integration_Name__c = 'ServiceNow';
        il2.Log_Date__c = Datetime.now();
        il2.Retries_Performed__c = 0;
        il2.Status__c = 'Failed';
        il2.Transaction_Type__c = 'Update';
        il2.Web_Service_Endpoint__c = 'https://aproach.amadeus.net/aproach/webserviceDEV/services/CustomersWebServices';
        il2.XMLRequest__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        il2.Description__c = '<?xml version="1.0" encoding="UTF-8"?><ticket_exchange><create><record_type>incident</record_type><external_record_id>' + sCaseId + '</external_record_id><category><system_category>P</system_category></category><severity>3</severity><urgency>N</urgency><Status>AA</Status><assignee><group>MHDHOT</group></assignee><logger><group>Intercontinental Hotels Group</group><name>loggername</name></logger><owner><group>MHDHOT</group><name>spatil</name><tel>7654321</tel></owner><dates><start_date_time>2017-02-23 05:13:00</start_date_time></dates><affected_service>AHP CRS</affected_service><title>Test subject2</title><description><entry><date_time>2017-02-23 06:37:55</date_time><group>MHDHOT</group><name>loggername</name><text><line>test desc2</line></text></entry></description></create></ticket_exchange>';
        insert il2;              
        
	    Test.startTest(); 

        // ASSERT THAT THERE ARE INTEGRATION LOG RECORDS THAT MEET CRITERIA FOR INTGR_ResendServiceNow CLASS QUERY
        List<NI_Integration_Log__c> lstILogAsserts = new List<NI_Integration_Log__c>(
            [SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c, UpdateFor__c, 
             Retries_Performed__c, Do_Retries__c, XMLRequest__c, Attachment_Id__c  
             FROM NI_Integration_Log__c 
             WHERE Status__c = 'Failed' 
             AND Integration_Name__c = 'ServiceNow' 
             AND Integration_Case__r.INTGR_Account__c =: iAcc.Id 
             AND Do_Retries__c = true 
             AND Retries_Performed__c < 5]); 

        system.assertEquals(2, lstILogAsserts.size());
        
        // ABORT ANY EXISTING TEST JOBS
//        for (CronTrigger ct : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'INTGR_%'])
//        {
//            system.abortJob(ct.Id);
//        }
        
        Integer iMaxResendTimes = Integer.valueOf(iAcc.Resend_Failed_Message_Interval_in_Min__c);
        Integer iResendInterval = Integer.valueOf(iAcc.Resend_Failed_Message_Interval_in_Min__c);
        
        INTGR_ResendServiceNow x = new INTGR_ResendServiceNow('INTGR_Resend_SVCNOW_', iAcc.Id, iMaxResendTimes, iResendInterval); 

        Id batchprocessid = Database.executeBatch(x); 
        system.debug('batchprocessid = ' + batchprocessid);
        system.assertNotEquals(null, batchprocessid);

        Test.stopTest();       
            
    }
    
}