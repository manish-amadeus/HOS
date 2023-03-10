/****************************************************************************************
Name            : AH_ClearFlagController_Test Test Class
Author          : Ria Chawla
Created Date    : 04/06/2018
Last Mod Date   : 04/06/2018
Last Mod By     : Ria Chawla
NICC Reference  : NICC-026092
Description     : test Class for AH_ClearFlagController Class
                : 
                : 
******************************************************************************************/
@isTest
public class AH_ClearFlagController_Test 
{
    
    @isTest static void testClearFlagCtrl1()
    {
        system.debug('Limits cpu 1'+Limits.getCpuTime());
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        system.debug('AH_ClearFlagsControllerTest.createTestData() - NUMBER OF QUERIES after NI_TestClassData.createTestWinaproachServiceNowSettings() = ' + limits.getQueries());
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        //CREATE OBJECT TO STORE RECORD TYPES OF ENABLED CASE RECORD TYPES
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        //CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_ClearFlagsControllerTest ACCOUNT';
        insert a;
        
        //CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        system.debug('Limits cpu 3'+Limits.getCpuTime());
        //CREATE TEST CASE
        Case cParent = NI_TestClassData.createTestCase(1, a.Id);
        cParent.Subject = 'AH_ClearFlagsControllerTest PARENT CASE';
        cParent.ContactId = cnt.Id;
        cParent.RecordTypeId = rtCaseId;
        cParent.AH_Enable_Case_Flag__c = true;
        cParent.Origin = 'Internal';
        insert cParent; 
        
        List<Case> listOfCases = new List<Case>();
        listOfCases.add(cParent);
        Test.startTest();
        // CREATE CUSTOM SETTING
		AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cParent);
        
        AH_SetFlagController setCtrl = new AH_SetFlagController(controller);
        setCtrl.setFlagNow();
        
        //FLAGGED DATE SHOULD BE SET
        Case cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertNotEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date set');
        
        ApexPages.StandardController controller2 = new ApexPages.StandardController(cParent);
        
        AH_ClearFlagController clearCtrl = new AH_ClearFlagController(controller2);
        clearCtrl.clearFlagNow();
        
        //FLAGGED DATE SHOULD BE CLEARED
        cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date cleared');
        Test.stopTest();
        system.debug('Limits cpu'+Limits.getCpuTime());
    }
    
    
    @isTest static void testClearFlagCtrl2()
    {
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        system.debug('AH_ClearFlagsControllerTest.createTestData() - NUMBER OF QUERIES after NI_TestClassData.createTestWinaproachServiceNowSettings() = ' + limits.getQueries());
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        //CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_ClearFlagsControllerTest ACCOUNT';
        insert a;
        
        //CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        //CREATE TEST CASE
        Case cParent = NI_TestClassData.createTestCase(1, a.Id);
        cParent.Subject = 'AH_ClearFlagsControllerTest PARENT CASE';
        cParent.ContactId = cnt.Id;
        cParent.RecordTypeId = rtCaseId;
        cParent.AH_Enable_Case_Flag__c = true;
        insert cParent; 
        
        List<Case> listOfCases = new List<Case>();
        listOfCases.add(cParent);
        
        // CREATE CUSTOM SETTING
		AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;
        Test.startTest();
        ApexPages.StandardController controller = new ApexPages.StandardController(cParent);
        
        AH_SetFlagController setCtrl = new AH_SetFlagController(controller);
        setCtrl.setFlagNow();
        
        //FLAGGED DATE SHOULD NOT BE SET SINCE CASE FLAGS IS NOT ENABLED FOR THIS CASE TYPE
        Case cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date not set');
     
        AH_ClearFlagController clearCtrl = new AH_ClearFlagController(controller);
        clearCtrl.clearFlagNow();
        
        //FLAGGED DATE SHOULD BE CLEAR
        cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date cleared');
        Test.stopTest();
    }
    
 @isTest static void testClearFlagCtrl3()
    {
        system.debug('Limits cpu 1'+Limits.getCpuTime());
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        system.debug('AH_ClearFlagsControllerTest.createTestData() - NUMBER OF QUERIES after NI_TestClassData.createTestWinaproachServiceNowSettings() = ' + limits.getQueries());
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        //CREATE OBJECT TO STORE RECORD TYPES OF ENABLED CASE RECORD TYPES
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        //CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_ClearFlagsControllerTest ACCOUNT';
        insert a;
        
        //CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        //CREATE TEST CASE
        Case cParent = NI_TestClassData.createTestCase(1, a.Id);
        cParent.Subject = 'AH_ClearFlagsControllerTest PARENT CASE';
        cParent.ContactId = cnt.Id;
        cParent.RecordTypeId = rtCaseId;
        //cParent.AH_Enable_Case_Flag__c = true;
        cParent.Origin = 'Internal';
        insert cParent; 
        
        List<Case> listOfCases = new List<Case>();
        listOfCases.add(cParent);
        Test.startTest();
        // CREATE CUSTOM SETTING
		AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cParent);
        
        AH_SetFlagController setCtrl = new AH_SetFlagController(controller);
        setCtrl.setFlagNow();
        
        //FLAGGED DATE SHOULD BE SET
        Case cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date not set');
        
        ApexPages.StandardController controller2 = new ApexPages.StandardController(cParent);
        
        AH_ClearFlagController clearCtrl = new AH_ClearFlagController(controller2);
        clearCtrl.clearFlagNow();
        
        //FLAGGED DATE SHOULD BE CLEARED
        cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date cleared');
        Test.stopTest();
    }
    
}