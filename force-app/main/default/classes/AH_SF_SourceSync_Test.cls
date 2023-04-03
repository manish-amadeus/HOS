/************************************************************************************************************************
Name            : AH_SF_SourceSync_Test Class
Author          : Sean Harris
Created Date    : 06/04/2018
Last Mod Date   : 06/04/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description		: Tests AH_SF_SourceSync
     			: 
*************************************************************************************************************************/
@isTest
public class AH_SF_SourceSync_Test 
{

    
    static testMethod void testAH_SF_SourceSync1()
    {
     
        // CREATE TEST SALESFORCE SOURCE CONTROL RECORDS 
        List<AH_SFDC_Source_Control__c> lstSSCInserts = new List<AH_SFDC_Source_Control__c>();
        
        // APEX CLASS 
        AH_SFDC_Source_Control__c s1 = new AH_SFDC_Source_Control__c();
        s1.API_Name__c = 'AcceptanceCriteriaController';
        s1.Salesforce_Source_Type__c = 'Apex Class';
        s1.CRC__c = 1626939573;
        s1.Description__c = '';
        s1.Label__c = 'AcceptanceCriteriaController';
        s1.Salesforce_ID__c = '01p32000000VGB6AAO';
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
        AH_SFDC_Source_Control__c s3a = new AH_SFDC_Source_Control__c();
        s3a.API_Name__c = 'Case_Auto_Email_for_Amadeus_PMS_v3';
        s3a.Salesforce_Source_Type__c = 'Process Builder';
        s3a.Description__c = 'Sends automated emails in Dutch, German, French & English';
        s3a.Label__c = 'Case Auto Email for Amadeus PMS v3';
        s3a.Salesforce_ID__c = '301320000000IxHAAU';
        s3a.Source_Last_Modified__c = system.now();
        s3a.Source_Last_Modified_By__c = UserInfo.getUserId();
		lstSSCInserts.add(s3a);

        AH_SFDC_Source_Control__c s3b = new AH_SFDC_Source_Control__c();
        s3b.API_Name__c = 'Dummy_Process_Builder';
        s3b.Salesforce_Source_Type__c = 'Process Builder';
        s3b.Description__c = 'Dummy PB';
        s3b.Label__c = 'Dummy Process Builder';
        s3b.Salesforce_ID__c = '301320000000GayAAU';
        s3b.Source_Last_Modified__c = system.now();
        s3b.Source_Last_Modified_By__c = UserInfo.getUserId();
		lstSSCInserts.add(s3b);
        
        // VALIDATION RULE
        AH_SFDC_Source_Control__c s4a = new AH_SFDC_Source_Control__c();
        s4a.API_Name__c = 'Asset.Account_May_Not_Be_Changed';
        s4a.Salesforce_Source_Type__c = 'Validation Rule';
        s4a.Label__c = 'Account May Not Be Changed';
        s4a.Salesforce_ID__c = '03d600000008pRyAAI';
        s4a.Source_Last_Modified__c = system.now();
        s4a.Source_Last_Modified_By__c = UserInfo.getUserId();
		lstSSCInserts.add(s4a);

        AH_SFDC_Source_Control__c s4b = new AH_SFDC_Source_Control__c();
        s4b.API_Name__c = 'Asset.DummyVR';
        s4b.Salesforce_Source_Type__c = 'Validation Rule';
        s4b.Label__c = 'Dummy VR';
        s4b.Salesforce_ID__c = '03d600000008GayAAI';
        s4b.Source_Last_Modified__c = system.now();
        s4b.Source_Last_Modified_By__c = UserInfo.getUserId();
		lstSSCInserts.add(s4b);
        
        // VISUALFORCE PAGE
        AH_SFDC_Source_Control__c s5 = new AH_SFDC_Source_Control__c();
        s5.API_Name__c = 'AH_Admin_CodeSearch';
        s5.Salesforce_Source_Type__c = 'Visualforce Page';
        s5.Description__c = '';
        s5.Label__c = 'AH_Admin_CodeSearch';
        s5.Salesforce_ID__c = '0660d000000XfhmAAC';
        s5.Syntax__c = '<apex:page controller="AH_Admin_CodeSearch"></apex:page>';
        s5.Source_Last_Modified__c = system.now();
        s5.Source_Last_Modified_By__c = UserInfo.getUserId(); 
        lstSSCInserts.add(s5);

        // VISUALFORCE COMPONENT
        AH_SFDC_Source_Control__c s6 = new AH_SFDC_Source_Control__c();
        s6.API_Name__c = 'ffaInvoice';
        s6.Salesforce_Source_Type__c = 'Visualforce Component';
        s6.Description__c = '';
        s6.Label__c = 'ffaInvoice';
        s6.Salesforce_ID__c = '099320000004HtVAAU';
        s6.Syntax__c = '<apex:component></apex:component>';
        s6.Source_Last_Modified__c = system.now();
        s6.Source_Last_Modified_By__c = UserInfo.getUserId(); 
        lstSSCInserts.add(s6);
        
        database.insert(lstSSCInserts);

        List<AH_SFDC_Source_Control__c> lstSSCAssert1 = new List<AH_SFDC_Source_Control__c>([SELECT Id FROM AH_SFDC_Source_Control__c]);
        system.assertEquals(8, lstSSCAssert1.size());              
        
//        Test.setMock(HttpCalloutMock.class, new AH_SF_SourceSync_Mock());
        Test.startTest();
        
        AH_SF_SourceSync ss = new AH_SF_SourceSync();
        ss.invokeSync(); 
         
        Test.stopTest();
        
        List<AH_SFDC_Source_Control__c> lstSSCAssert2 = new List<AH_SFDC_Source_Control__c>([SELECT Id FROM AH_SFDC_Source_Control__c]);
        system.assertNotEquals(0, lstSSCAssert2.size()); 
       
        List<AH_SFDC_Source_Version__c> lstVersions = new List<AH_SFDC_Source_Version__c>([SELECT Id FROM AH_SFDC_Source_Version__c]);
        // SHOULD BE 2 BECAUSE OF THE TEST AH_SFDC_Source_Control__c APEX CLASS & TRIGGER RECORDS INSERTED
        system.assertEquals(3, lstVersions.size()); 

    }

    static testMethod void testAH_SF_SourceSync2()
    {
        Test.setMock(HttpCalloutMock.class, new AH_SF_SourceSync_MockPB());
        Test.startTest();
        
        AH_SF_SourceSync ss = new AH_SF_SourceSync();
        ss.initVars();
        ss.processProcBuilders();        
        ss.commitRecords();
        
        Test.stopTest();  
        
        List<AH_SFDC_Source_Control__c> lstSSCAsserts = new List<AH_SFDC_Source_Control__c>([SELECT Id FROM AH_SFDC_Source_Control__c WHERE Salesforce_Source_Type__c = 'Process Builder']);
        system.assertEquals(1, lstSSCAsserts.size());  
        
//        List<AH_SFDC_Source_Version__c> lstVersions = new List<AH_SFDC_Source_Version__c>([SELECT Id FROM AH_SFDC_Source_Version__c WHERE Salesforce_Source_Type__c = 'Process Builder']);
        // SHOULD BE 1 BECAUSE OF THE TEST AH_SFDC_Source_Control__c PROCESS BUILDER RECORD INSERTED
//        system.assertEquals(1, lstVersions.size());           
        
    }

    static testMethod void testAH_SF_SourceSync3()
    {
        Test.setMock(HttpCalloutMock.class, new AH_SF_SourceSync_MockVR());
        Test.startTest();
        
        AH_SF_SourceSync ss = new AH_SF_SourceSync();
        ss.initVars();
        ss.processValidationRules();        
        ss.commitRecords(); 
         
        Test.stopTest();  
        
        List<AH_SFDC_Source_Control__c> lstSSCAsserts = new List<AH_SFDC_Source_Control__c>([SELECT Id FROM AH_SFDC_Source_Control__c WHERE Salesforce_Source_Type__c = 'Validation Rule']);
        system.assertEquals(1, lstSSCAsserts.size()); 
        
//        List<AH_SFDC_Source_Version__c> lstVersions = new List<AH_SFDC_Source_Version__c>([SELECT Id FROM AH_SFDC_Source_Version__c WHERE Salesforce_Source_Type__c = 'Validation Rule']);
        // SHOULD BE 1 BECAUSE OF THE TEST AH_SFDC_Source_Control__c PROCESS BUILDER RECORD INSERTED
//        system.assertEquals(1, lstVersions.size()); 
        
    }
    
}