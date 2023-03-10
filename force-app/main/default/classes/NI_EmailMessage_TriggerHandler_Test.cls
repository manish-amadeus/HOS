/****************************************************************************************
Name            : NI_EmailMessage_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 02/02/2017
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : NICC-020976
Description     : UPDATED 07/02/2020 PER NICC-044303 
                : 
                : 
******************************************************************************************/
@isTest
public class NI_EmailMessage_TriggerHandler_Test 
{


    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;   
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT 1';
        a.RecordTypeId = rtPropertyAccountId;
        insert a;     
        
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        cnt.Email = 'test@test.com';
        insert cnt; 

        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-XXX-01', 'Subscription');        
        insert prd;
        
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        di.Product_Group__c = pgp.Id;
        insert di;
        
        // CREATE TEST CASE
        
        List<Case> lstCases = new List<Case>();
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.AssetId = di.Id;
        c.AccountId = a.Id;
        c.ContactId = cnt.Id;
        c.Status = 'New';
        c.Subject = 'TEST E2CP APEX TEST CASE 1';
        //insert c;
		lstCases.add(c);
        
        Case c2 = NI_TestClassData.createTestCase(2, a.Id);
        c2.AssetId = di.Id;
        c2.AccountId = a.Id;
        c2.ContactId = cnt.Id;
        c2.Status = 'New';
        c2.Subject = 'TEST E2CP APEX TEST CASE 2';
        //insert c2;
        lstCases.add(c2);
        
        Database.insert(lstCases);
        
        // CREATE TEST EMAILMESSAGE RECORDS
        List<EmailMessage> lstEmailMessageInserts = new List<EmailMessage>();
        
        Case cs1 = [SELECT Id FROM Case WHERE Subject = 'TEST E2CP APEX TEST CASE 1'];
        Case cs2 = [SELECT Id FROM Case WHERE Subject = 'TEST E2CP APEX TEST CASE 2'];    
        
        EmailMessage em1 = NI_TestClassData.createTestEmailMessage(1, cs1.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'Apex Test Email', 'Apex Test Email Body', '1');
        em1.Incoming = true;
        lstEmailMessageInserts.add(em1);
        
        EmailMessage em2 = NI_TestClassData.createTestEmailMessage(2, cs2.Id, 'Joe Doe', 'jdoe@cybage.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'Apex Test Email', 'Apex Test Email Body', '1');
        em2.RelatedToId = cs2.Id;
        lstEmailMessageInserts.add(em2);
        
        database.insert(lstEmailMessageInserts);

    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================
    @isTest static void test1() 
    {  

        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Number_of_Emails_Sent__c FROM Case WHERE Subject = 'TEST E2CP APEX TEST CASE 1']);
        system.assertEquals(1, lstCaseAsserts.Size());

    }
    
}