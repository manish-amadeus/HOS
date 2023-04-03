/****************************************************************************************
Name            : AH_SF_SourceError_Test Test Class
Author          : Sean Harris
Created Date    : 06/03/2018
Last Mod Date   : 06/03/2018 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_SF_SourceError
                : 
******************************************************************************************/
@isTest
public class AH_SF_SourceError_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

		system.debug(' *** AH_SF_SourceError_Test.createTestData() - START ***'); 

        // CREATE TEST SALESFORCE SOURCE CONTROL RECORDS 
        List<AH_SFDC_Source_Control__c> lstSSCInserts = new List<AH_SFDC_Source_Control__c>();
        
        // APEX CLASS 
        AH_SFDC_Source_Control__c s1 = new AH_SFDC_Source_Control__c();
        s1.API_Name__c = 'NI_BatchServiceNowResend';
        s1.Salesforce_Source_Type__c = 'Apex Class';
        s1.CRC__c = 997391997;
        s1.Description__c = 'test class';
        s1.Label__c = 'NI_BatchServiceNowResend';
        s1.Salesforce_ID__c = '01p32000000VSoeAAG';
        s1.Syntax__c = 'if then else...';
        s1.Source_Last_Modified__c = system.now();
        s1.Source_Last_Modified_By__c = UserInfo.getUserId();
        lstSSCInserts.add(s1);

        // APEX TRIGGER  
        AH_SFDC_Source_Control__c s2 = new AH_SFDC_Source_Control__c();
        s2.API_Name__c = 'NI_OpportunityLineItem_BeforeInsertUpdate';
        s2.Salesforce_Source_Type__c = 'Apex Trigger';
        s2.CRC__c = 1626939573;
        s2.Description__c = 'test trigger';
        s2.Label__c = 'NI_OpportunityLineItem_BeforeInsertUpdate';
        s2.Salesforce_ID__c = '01q320000004VKgAAM';
        s2.Syntax__c = 'if then else...';
        s2.Source_Last_Modified__c = system.now();
        s2.Source_Last_Modified_By__c = UserInfo.getUserId(); 
        lstSSCInserts.add(s2);

        // PROCESS BUILDER 
        AH_SFDC_Source_Control__c s3 = new AH_SFDC_Source_Control__c();
        s3.API_Name__c = 'Case_Auto_Email_for_Amadeus_PMS_v3';
        s3.Salesforce_Source_Type__c = 'Process Builder';
        // s3.CRC__c = 0;
        s3.Description__c = 'test process builder';
        s3.Label__c = 'Case Auto Email for Amadeus PMS v3';
        s3.Salesforce_ID__c = '01p32000000VSoeAAG';
        // s3.Syntax__c = '';
        s3.Source_Last_Modified__c = system.now();
        s3.Source_Last_Modified_By__c = UserInfo.getUserId();        
		lstSSCInserts.add(s3);
        
        // APEX CLASS 
        AH_SFDC_Source_Control__c s4 = new AH_SFDC_Source_Control__c();
        s4.API_Name__c = 'AH_CreateServiceOrder';
        s4.Salesforce_Source_Type__c = 'Visualforce Page';
        s4.CRC__c = 997391997;
        s4.Description__c = 'test vf page';
        s4.Label__c = 'AH_CreateServiceOrder';
        s4.Salesforce_ID__c = '0660d000000XfLbAAK';
        s4.Syntax__c = '<apex></apex>';
        s4.Source_Last_Modified__c = system.now();
        s4.Source_Last_Modified_By__c = UserInfo.getUserId();
        lstSSCInserts.add(s4);
        
        database.insert(lstSSCInserts);
        
        // ASSERT THAT SSC RECORD WAS CREATED
        List<AH_SFDC_Source_Control__c> lstSSCAssert1s = new List<AH_SFDC_Source_Control__c>([SELECT Id FROM AH_SFDC_Source_Control__c]);
        system.assertEquals(4, lstSSCAssert1s.size());           
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: APEX CLASS ERROR EMAIL
    // =======================================================================================================================================     
    static testMethod void testAH_SF_SourceError1()
    {
        
        // CREATE NEW EMAIL PACKAGE & ENVELOPE
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // CREATE EMAIL SUBJECT & BODY
        string strSubj = 'FW: [EXT] Developer script exception from Amadeus Hospitality : \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' : Attempt to de-reference a null object';
        string strBody = '________________________________________ \n';        
        strBody += 'From: ApexApplication \n';        
        strBody += 'Sent: Tuesday, June 26, 2018 4:03:38 PM (UTC-05:00) Eastern Time (US & Canada) \n';
        strBody += 'To: Sean Harris \n';
        strBody += 'Subject: [EXT] Developer script exception from Amadeus Hospitality : \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' : Attempt to de-reference a null object \n\n';
        strBody += 'Apex script unhandled exception by user/organization: 005600000011GFW/00D300000006Ctn \n\n';
        strBody += 'Failed to process batch for class \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' \n\n';
        strBody += 'caused by: System.NullPointerException: Attempt to de-reference a null object \n\n';
        strBody += 'Class.NI_ServicenowFunctions.resendRequestToServiceNowUpdate: line 356, column 1 \n';
        strBody += 'Class.NI_BatchServiceNowResend.execute: line 57, column 1 \n'; 

        email.fromAddress = 'test@test.com';
        email.subject = strSubj;
		email.plainTextBody = strBody;
        
        AH_SF_SourceError es = new AH_SF_SourceError();
        
        Test.startTest();
        Messaging.InboundEmailResult result = es.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<AH_SFDC_Source_Errors__c> lstErrAsserts = new List<AH_SFDC_Source_Errors__c>(
            [SELECT Id, User__c, Description__c FROM AH_SFDC_Source_Errors__c
             WHERE Salesforce_Source_Type__c = 'Apex Class' 
             AND API_Name__c = 'NI_BatchServiceNowResend']);
        
        // ASSERT THAT ERROR RECORD WAS CREATED
        system.assertEquals(1, lstErrAsserts.size());
        
        // ASSERT USER ID WAS PARSED
        system.assertEquals('005600000011GFW', lstErrAsserts[0].User__c);
        
        // ASSERT THAT SUBJECT WAS TRIMMED
        system.assertEquals(lstErrAsserts[0].Description__c, 'Developer script exception from Amadeus Hospitality : \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' : Attempt to de-reference a null object');
 
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: APEX TRIGGER ERROR EMAIL
    // =======================================================================================================================================     
    static testMethod void testAH_SF_SourceError2()
    {
        
        // CREATE NEW EMAIL PACKAGE & ENVELOPE
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // CREATE EMAIL SUBJECT & BODY
        string strSubj = 'FW: [EXT] Developer script exception from Amadeus Hospitality : NI_OpportunityLineItem_BeforeInsertUpdate : NI_OpportunityLineItem_BeforeInsertUpdate:';
        string strBody = '________________________________________ \n';        
        strBody += 'From: ApexApplication \n';        
        strBody += 'Sent: Tuesday, June 26, 2018 4:03:38 PM (UTC-05:00) Eastern Time (US & Canada) \n';
        strBody += 'To: Sean Harris \n';
        strBody += 'Subject: [EXT] Developer script exception from Amadeus Hospitality : NI_OpportunityLineItem_BeforeInsertUpdate : NI_OpportunityLineItem_BeforeInsertUpdate: ';
        strBody += 'execution of BeforeInsert caused by: System.NullPointerException: Attempt to de-reference a null \n\n';
        strBody += 'Apex script unhandled trigger exception by user/organization: 005600000011GFW/00D300000006Ctn \n\n';
        strBody += 'NI_OpportunityLineItem_BeforeInsertUpdate: execution of BeforeInsert \n\n';
        strBody += 'caused by: System.NullPointerException: Attempt to de-reference a null object \n\n';
        strBody += 'Class.NI_OpportunityProduct_TriggerHandler.syncOrderOfDelivery: line 663, column 1 \n'; 
        strBody += 'Trigger.NI_OpportunityLineItem_BeforeInsertUpdate: line 11, column 1 \n';         
        
        
        email.fromAddress = 'test@test.com';
        email.subject = strSubj;
		email.plainTextBody = strBody;
        
        AH_SF_SourceError es = new AH_SF_SourceError();
        
        Test.startTest();
        Messaging.InboundEmailResult result = es.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<AH_SFDC_Source_Errors__c> lstErrAsserts = new List<AH_SFDC_Source_Errors__c>(
            [SELECT Id, User__c, Description__c FROM AH_SFDC_Source_Errors__c
             WHERE Salesforce_Source_Type__c = 'Apex Trigger' 
             AND API_Name__c = 'NI_OpportunityLineItem_BeforeInsertUpdate']);
        
        // ASSERT THAT ERROR RECORD WAS CREATED
        system.assertEquals(1, lstErrAsserts.size());
        
        // ASSERT USER ID WAS PARSED
        system.assertEquals('005600000011GFW', lstErrAsserts[0].User__c);
        
        // ASSERT THAT SUBJECT WAS TRIMMED
        system.assertEquals(lstErrAsserts[0].Description__c, 'Developer script exception from Amadeus Hospitality : NI_OpportunityLineItem_BeforeInsertUpdate : NI_OpportunityLineItem_BeforeInsertUpdate:');
 
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: PROCESS BUILDER ERROR EMAIL
    // =======================================================================================================================================     
    static testMethod void testAH_SF_SourceError3()
    {
        
        // CREATE NEW EMAIL PACKAGE & ENVELOPE
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // CREATE EMAIL SUBJECT & BODY 
        string strSubj = 'FW: [EXT] Error Occurred During Flow "Case_Auto_Email_for_Amadeus_PMS_v3": The flow failed to access the value for m...';
        string strBody = '________________________________________ \n';        
        strBody += 'From: FlowApplication \n';        
        strBody += 'Sent: Tuesday, June 26, 2018 4:03:38 PM (UTC-05:00) Eastern Time (US & Canada) \n';
        strBody += 'To: Sean Harris \n';
        strBody += 'Subject: [EXT] Error Occurred During Flow "Case_Auto_Email_for_Amadeus_PMS_v3": The flow failed to access the value for m... \n\n';
        strBody += 'Error element myDecision3 (FlowDecision). \n\n';
        strBody += 'The flow failed to access the value for myVariable_current.Asset.Product_Group__r.Name because it hasn\'t been set or assigned. \n\n';
        strBody += '________________________________ \n\n';      
        strBody += 'Flow Details \n';
        strBody += 'Flow Name: Case_Auto_Email_for_Amadeus_PMS_v3 \n';
        strBody += 'Type: Record Change Process \n';
        strBody += 'Version: 4 \n';
        strBody += 'Status: Active \n';
        strBody += 'Org: Amadeus Hospitality (00D300000006Ctn) \n\n';
        strBody += 'Flow Interview Details \n';
        strBody += 'Interview Label: Case_Auto_Email_for_Amadeus_PMS_v3-4_Case \n';
        strBody += 'Current User: Sean Harris (005600000011GFW) \n';
        strBody += 'Start time: 6/22/2018 9:15 AM \n';
        strBody += 'Duration: 0 seconds \n';    
    
        email.fromAddress = 'test@test.com';
        email.subject = strSubj;
		email.plainTextBody = strBody;
        
        AH_SF_SourceError es = new AH_SF_SourceError();
        
        Test.startTest();
        Messaging.InboundEmailResult result = es.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<AH_SFDC_Source_Errors__c> lstErrAsserts = new List<AH_SFDC_Source_Errors__c>(
            [SELECT Id, User__c, Description__c FROM AH_SFDC_Source_Errors__c
             WHERE Salesforce_Source_Type__c = 'Process Builder' 
             AND API_Name__c = 'Case_Auto_Email_for_Amadeus_PMS_v3']);
        
        // ASSERT THAT ERROR RECORD WAS CREATED
        system.assertEquals(1, lstErrAsserts.size());
        
        // ASSERT USER ID WAS PARSED
        system.assertEquals('005600000011GFW', lstErrAsserts[0].User__c);
        
        // ASSERT THAT SUBJECT WAS TRIMMED
        system.assertEquals(lstErrAsserts[0].Description__c, 'Error Occurred During Flow "Case_Auto_Email_for_Amadeus_PMS_v3": The flow failed to access the value for m...');
        
    }    

    // ======================================================================================================================================= 
    // = TEST METHOD 4: ERROR EMAIL FROM SANDBOX
    // =======================================================================================================================================     
    static testMethod void testAH_SF_SourceError4()
    {
       
        // CREATE NEW EMAIL PACKAGE & ENVELOPE
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // CREATE EMAIL SUBJECT & BODY
        string strSubj = 'FW: [EXT] Sandbox: Developer script exception from Amadeus Hospitality : \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' : Attempt to de-reference a null object';
        string strBody = '________________________________________ \n';        
        strBody += 'From: ApexApplication \n';        
        strBody += 'Sent: Tuesday, June 26, 2018 4:03:38 PM (UTC-05:00) Eastern Time (US & Canada) \n';
        strBody += 'To: Sean Harris \n';
        strBody += 'Subject: [EXT] Sandbox: Developer script exception from Amadeus Hospitality : \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' : Attempt to de-reference a null object \n\n';
        strBody += 'Apex script unhandled exception by user/organization: 005600000011GFW/00D300000006Ctn \n\n';
        strBody += 'Failed to process batch for class \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' \n\n';
        strBody += 'caused by: System.NullPointerException: Attempt to de-reference a null object \n\n';
        strBody += 'Class.NI_ServicenowFunctions.resendRequestToServiceNowUpdate: line 356, column 1 \n';
        strBody += 'Class.NI_BatchServiceNowResend.execute: line 57, column 1 \n'; 

        email.fromAddress = 'test@test.com';
        email.subject = strSubj;
		email.plainTextBody = strBody;
        
        AH_SF_SourceError es = new AH_SF_SourceError();
        
        Test.startTest();
        Messaging.InboundEmailResult result = es.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<AH_SFDC_Source_Errors__c> lstErrAsserts = new List<AH_SFDC_Source_Errors__c>([SELECT Id, Description__c FROM AH_SFDC_Source_Errors__c]);
        // ASSERT THAT ERROR RECORD WAS NOT CREATED
        system.assertEquals(0, lstErrAsserts.size()); 
 
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 5: INVALID EMAIL
    // =======================================================================================================================================     
    static testMethod void testAH_SF_SourceError5()
    {
        
        // CREATE NEW EMAIL PACKAGE & ENVELOPE
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // CREATE EMAIL SUBJECT & BODY
        string strSubj = 'Valentines Day Sale - Viagra Half off!';
        string strBody = 'Selling fast!'; 

        email.fromAddress = 'test@test.com';
        email.subject = strSubj;
		email.plainTextBody = strBody;
        
        AH_SF_SourceError es = new AH_SF_SourceError();
        
        Test.startTest();
        Messaging.InboundEmailResult result = es.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<AH_SFDC_Source_Errors__c> lstErrAsserts = new List<AH_SFDC_Source_Errors__c>([SELECT Id, Description__c FROM AH_SFDC_Source_Errors__c]);
        // ASSERT THAT ERROR RECORD WAS CREATED
        system.assertEquals(0, lstErrAsserts.size());
        // ASSERT THAT SUBJECT WAS TRIMMED
//        system.assertEquals(lstErrAsserts[0].Description__c, 'Developer script exception from Amadeus Hospitality : \'NI_BatchServiceNowResend\' for job id \'7070d00004L5i3H\' : Attempt to de-reference a null object');
 
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 6: VISUALFORCE ERROR EMAIL
    // =======================================================================================================================================     
    static testMethod void testAH_SF_SourceError6()
    {
        
        // CREATE NEW EMAIL PACKAGE & ENVELOPE
        Messaging.InboundEmail email  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // CREATE EMAIL SUBJECT & BODY       
        string strSubj = 'FW: [EXT] Developer script exception from Amadeus Hospitality :   AH_CreateServiceOrder : Insert failed. First exception on row 0; first   error: STRING_TOO_LONG, Company Name: data value too large:';
        string strBody = '________________________________________ \n';        
        strBody += 'From: ApexApplication \n';        
        strBody += 'Sent: Tuesday, June 26, 2018 4:03:38 PM (UTC-05:00) Eastern Time (US & Canada) \n';
        strBody += 'To: Sean Harris \n';
        strBody += 'Subject: [EXT] Developer script exception from Amadeus Hospitality :   AH_CreateServiceOrder : Insert failed. First exception on row 0; first   error: STRING_TOO_LONG, Company Name: data value too large: \n\n';
        strBody += 'Apex script unhandled exception by user/organization: 005600000011GFW/00D300000006Ctn \n\n';
        strBody += 'Visualforce Page: /apex/AH_CreateServiceOrder \n\n\n';
        strBody += 'caused by: System.DmlException: Insert failed. First exception on row 0; first error: STRING_TOO_LONG, Company Name: data value too large:  (max length=50): [CHANNEL_ORDERS__Customer_Company_Name__c] \n\n';
        strBody += 'Class.AH_CreateServiceOrder.bCreateServiceOrder: line 454, column 1 \n';
        strBody += 'Class.AH_CreateServiceOrder.CreateServiceOrder: line 335, column 1 \n';

        email.fromAddress = 'test@test.com';
        email.subject = strSubj;
		email.plainTextBody = strBody;
        
        AH_SF_SourceError es = new AH_SF_SourceError();
        
        Test.startTest();
        Messaging.InboundEmailResult result = es.handleInboundEmail(email, env);
        Test.stopTest();
        
        List<AH_SFDC_Source_Errors__c> lstErrAsserts = new List<AH_SFDC_Source_Errors__c>(
            [SELECT Id, User__c, Description__c FROM AH_SFDC_Source_Errors__c
             WHERE Salesforce_Source_Type__c = 'Visualforce Page' 
             AND API_Name__c = 'AH_CreateServiceOrder']);
        
        // ASSERT THAT ERROR RECORD WAS CREATED
        system.assertEquals(1, lstErrAsserts.size());
        
        // ASSERT USER ID WAS PARSED
        system.assertEquals('005600000011GFW', lstErrAsserts[0].User__c);
        
        // ASSERT THAT SUBJECT WAS TRIMMED
        system.assertEquals(lstErrAsserts[0].Description__c, 'Developer script exception from Amadeus Hospitality :   AH_CreateServiceOrder : Insert failed. First exception on row 0; first   error: STRING_TOO_LONG, Company Name: data value too large:');
        
    }
    
}