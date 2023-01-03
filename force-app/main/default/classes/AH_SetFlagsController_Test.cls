/****************************************************************************************
Name            : AH_SetFlagsController_Test Test Class
Author          : Ria Chawla
Created Date    : 04/06/2018
Last Mod Date   : 04/06/2018
Last Mod By     : Ria Chawla
NICC Reference  : NICC-026092
Description     : test Class for AH_SetFlagsController Class
                : 
                : 
******************************************************************************************/
@isTest
public class AH_SetFlagsController_Test 
{
    
    @isTest static void testSetFlagsCtrl1()
    {
        
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
        
        //INSERT TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_ClearFlagsControllerTest ACCOUNT';
        insert a;
        
        //INSERT TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        
        //INSERT TEST CASE
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
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(listOfCases);
        controller.setSelected(listOfCases);
        
        AH_SetFlagsController setCtrl = new AH_SetFlagsController(controller);
        setCtrl.setFlagsNow();
        setCtrl.continueProcessing();
        
        //FLAGGED DATE SHOULD NOT BE NULL
        Case cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertNotEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date set');
        
    }
    
    @isTest static void testSetFlagsCtrl2()
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
        
        //INSERT TEST CASE
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
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(listOfCases);
        controller.setSelected(listOfCases);
        
        AH_SetFlagsController setCtrl = new AH_SetFlagsController(controller);
        setCtrl.setFlagsNow();
        
        //FLAGGED DATE SHOULD NOT BE SET SINCE RECORD TYPE IS NOT ENABLED FOR CASE FLAGS
        Case cs = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :cParent.Id LIMIT 1];
        System.assertEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date not set');
        
    }
    
}