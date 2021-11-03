/****************************************************************************************
Name            : AH_CaseHistoryTracking_TrigHndlr_Test Test Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 07/27/2018
Last Mod By     : Cybage Developer - Shashikant Nikam
NICC Reference  : NICC-026092
Description     : Test Class for AH_CaseHistoryTracking_TriggerHandler apex class.
                :
*****************************************************************************************/
@isTest
public class AH_CaseHistoryTracking_TrigHndlr_Test 
{

    // =============================================================================================================
    // 		CREATE TEST DATA 
    // =============================================================================================================    
    @testSetup 
    static void createTestData() 
    {
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        //GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // CASE FLAGS CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Clear_On_Case_Origin__c = true;
        upsert caseFlagSetting;
        
        // CREATE OBJECT TO STORE RECORD TYPES OF ENABLED CASE RECORD TYPES, ACTIVITY TYPES, CASE ORIGINS
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call,Outgoing Email,Other';
        flagRecTypes.Clear_Case_Origins__c = 'Cancellation';
        insert flagRecTypes;
        
        // INSERT TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'NI_Case_TriggerHandlerTest ACCOUNT';
        insert a;
        Account a1 = [select id, name from Account where id =: a.id];
        system.assertEquals('NI_Case_TriggerHandlerTest ACCOUNT', a1.Name, 'Mismatch found in Account Name');
        
        // INSERT TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'King';
        insert cnt;
        Contact c1 = [select id, FirstName from Contact where id =: cnt.id];
        system.assertEquals('Jack', c1.FirstName, 'Contact FirstName mismatch');
        
    }
    
    static testmethod void testBulkRecords()
    {
        
        Test.startTest();
        
        // CREATE CASE FLAG CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Clear_On_Case_Origin__c = true;
        upsert caseFlagSetting;
        
        // RETRIEVE ACCOUNT & CONTACT
        Account a = [select id from Account where Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [select id from Contact where FirstName = 'Jack'];
        
        // GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // RETRIEVE STANDARD BUSINESS HOURS
        BusinessHours bs = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        Set<Id> histIds = new Set<Id>();
        
        // INSERT TEST CASE
        Case c = NI_TestClassData.createTestCase(2, a.Id);
        c.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE 2';
        c.ContactId = cnt.Id;
        c.Origin = 'Reseller';
        c.Has_No_DI__c = TRUE;
        c.Status = 'New'; 
        c.Type = 'Inquiry';
        c.Customer_Severity__c = '2 - Major';
        c.Priority = '3 - Medium';
        c.RecordTypeId = rtCaseId;
        c.AH_Enable_Case_Flag__c = true;
        c.BusinessHoursId = bs.Id;
        insert c;
        
        Test.stopTest();
        
        Case cs = [select id, Subject, Status, Origin, Customer_Severity__c, Type, Priority,
                    AH_Case_Flagged_Date__c, BusinessHoursId from Case where id =: c.id];
        system.debug('cs : '+cs);
        system.assertEquals(cs.id, c.id, 'Case not found..');        

		List<AH_Case_Flags_History_Tracking__c> historyTrackList = new List<AH_Case_Flags_History_Tracking__c>();
        
        for (Integer i = 0; i < 1000; i++) 
        {
            
            AH_Case_Flags_History_Tracking__c hisTrackObj = new AH_Case_Flags_History_Tracking__c();
            hisTrackObj.Action__c = 'User Action or Non-Flags Automation';
            hisTrackObj.Business_Hours__c = c.BusinessHoursId;
            hisTrackObj.Case__c = c.Id;
            hisTrackObj.Case_Status__c = c.Status;
            hisTrackObj.Event__c = 'Case Owner Changed';
            hisTrackObj.Owner__c = c.OwnerId;
            hisTrackObj.End_Date_Time__c = DateTime.now();
            hisTrackObj.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
            hisTrackObj.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
            hisTrackObj.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
            hisTrackObj.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
            hisTrackObj.Start__c = DateTime.now().addHours(-3);
            hisTrackObj.End_Date_Time__c = DateTime.now().addHours(-2);
            hisTrackObj.Hours_in_Age_1__c = 0.20;
            hisTrackObj.Hours_in_Age_2__c = 1.00;
            hisTrackObj.Hours_in_Age_3__c = 1.00; 
            hisTrackObj.Flag_Set__c = true;

            historyTrackList.add(hisTrackObj);
        }
        
        insert(historyTrackList);
        
        List<AH_Case_Flags_History_Tracking__c> historyTrackList1 = new List<AH_Case_Flags_History_Tracking__c>();
        historyTrackList1 = [SELECT Id, Action__c FROM AH_Case_Flags_History_Tracking__c];
        system.assertEquals(1001, historyTrackList1.size(), 'Records count mismatch..');
        system.debug('Records Size : '+historyTrackList1.size());
        
        for (AH_Case_Flags_History_Tracking__c h : historyTrackList1)
        {
            histIds.add(h.id);
        }
        
        // CLEAR FLAG BUTTON SHOULD CREATE HISTORY TRACKING RECORD
        ApexPages.StandardController clrController = new ApexPages.StandardController(c);
        AH_ClearFlagController clr = new AH_ClearFlagController(clrController);
        clr.clearFlagNow();
        AH_Case_Flags_History_Tracking__c histTrackRec0 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, Event__c,  
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id NOT IN : histIds];
        system.debug('M2 - histTrackRec0 : '+histTrackRec0);
        system.assertEquals('Clear Flag Button', histTrackRec0.Action__c, 'Action__c is not matching');
        
       // Test.stopTest(); 
        
    }
    
    static testmethod void testmethod1()
    {
        
        Test.startTest();
        
        // CREATE CASE FLAG CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Clear_On_Case_Origin__c = true;
        upsert caseFlagSetting;
        
        // RETRIEVE ACCOUNT & CONTACT
        Account a = [SELECT id FROM Account WHERE Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [SELECT id FROM Contact WHERE FirstName = 'Jack'];
        
        // GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // RETRIEVE STANDARD BUSINESS HOURS
        BusinessHours bs = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        SET<ID> histIds = new SET<ID>();
        
        // INSERT TEST CASE
        Case c2 = NI_TestClassData.createTestCase(2, a.Id);
        c2.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE 2';
        c2.ContactId = cnt.Id;
        c2.Origin = 'Reseller';
        c2.Has_No_DI__c = TRUE;
        c2.Status = 'New'; 
        c2.Type = 'Inquiry';
        c2.Customer_Severity__c = '2 - Major';
        c2.Priority = '3 - Medium';
        c2.RecordTypeId = rtCaseId;
        c2.AH_Enable_Case_Flag__c = true;
        c2.BusinessHoursId = bs.Id;
        insert c2;
        Case cs2 = [select id, Subject, Status, Origin, Customer_Severity__c, Type, Priority,
                    AH_Case_Flagged_Date__c, BusinessHoursId from Case where id =: c2.id];
        system.debug('cs2 : '+cs2);
        system.assertEquals(cs2.id, c2.id, 'Case not found..');
        
        AH_Case_Flags_History_Tracking__c histTrackRec3 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, Event__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id NOT IN : histIds];
        system.debug('M1 - histTrackRec3 : ' + histTrackRec3);
        system.assertEquals('Case Created', histTrackRec3.Action__c, 'Action__c not matching..');
        system.assertEquals('Flag Set', histTrackRec3.Event__c, 'Event__c not matching..');
        histIds.add(histTrackRec3.id);        
        
        NI_Case_TriggerHandler.createHisTrack = true;
        
		// CHANGE CASE STATUS TO TRACK IN HISTORY TRACKING
        cs2.Status = 'Working';
        update cs2;
        
        AH_Case_Flags_History_Tracking__c histTrackRec2 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, Event__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id NOT IN : histIds];
        system.debug('M1 - histTrackRec2 : '+histTrackRec2);
        system.assertEquals('Case Status Changed', histTrackRec2.Event__c, 'Event__c not matching..');
        system.assertEquals('User Action or Non-Flags Automation', histTrackRec2.Action__c, 'Action__c not matching..');
        histIds.add(histTrackRec2.id);
        
        NI_Case_TriggerHandler.createHisTrack = true;
        
        // CHANGE CASE ORIGIN TO CLEAR THE FLAG
        Case cs3 = [select id, Subject, Status, Origin, Customer_Severity__c, Type, Priority,
                    AH_Case_Flagged_Date__c from Case where id =: cs2.id];
        system.debug('cs3 : '+cs3);
        cs3.Origin = 'Cancellation';
        update cs3;
        Case cs4 = [select id, Subject, Status, Origin, Customer_Severity__c, Type, Priority,
                    AH_Case_Flagged_Date__c from Case where id =: cs3.id];
        system.debug('cs4 : '+cs4);        
        
        AH_Case_Flags_History_Tracking__c histTrackRec1 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, Event__c, 
                                                           Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                                           Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id NOT IN : histIds];
        system.debug('M1 - histTrackRec1 : '+histTrackRec1);
        system.assertEquals('Flag Cleared', histTrackRec1.Event__c, 'Event__c not matching..');
        system.assertEquals('Case Origin', histTrackRec1.Action__c, 'Action__c not matching..');
        
        Test.stopTest();
    }
    
    static testMethod void testInsertHistoryTrackingRecord()
    {
        
        Test.startTest();
        
        // RETRIEVE ACCOUNT & CONTACT
        Account a = [select id from Account where Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [select id from Contact where FirstName = 'Jack'];
        
        // GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // RETRIEVE STANDARD BUSINESS HOURS
        BusinessHours bs = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        // INSERT TEST CASE
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE';
        c.ContactId = cnt.Id;
        c.Has_No_DI__c = TRUE;
        c.RecordTypeId = rtCaseId;
        c.AH_Enable_Case_Flag__c = true;
        c.BusinessHoursId = bs.Id;
        insert c;
        Case cs = [select id, Subject from Case where id =: c.id];
        system.assertEquals(cs.id, c.id, 'Case not found..');
        
        // SET FLAG ON CASE
        ApexPages.StandardController controller = new ApexPages.StandardController(c);
        AH_SetFlagController setCtrl = new AH_SetFlagController(controller);
        setCtrl.setFlagNow();
        
        // FLAGGED DATE SHOULD BE SET
        Case cs_1 = [SELECT Id, AH_Case_Flagged_Date__c FROM Case WHERE Id = :c.Id LIMIT 1];
        System.assertNotEquals(null, cs_1.AH_Case_Flagged_Date__c, 'Flagged Date not set');
        
        AH_Case_Flags_History_Tracking__c histTrackRec1 = [SELECT Id, Action__c, Hours_Elapsed__c, Hours_in_Age_1__c 
                                                           FROM AH_Case_Flags_History_Tracking__c];
        system.debug('histTrackRec1 : '+histTrackRec1);
        system.assertEquals('Set Flag Button', histTrackRec1.Action__c, 'Action not matching..');
        system.assertNotEquals(null, histTrackRec1.Hours_Elapsed__c, 'Hours_Elapsed__c is not set');
        system.assertNotEquals(null, histTrackRec1.Hours_in_Age_1__c, 'Hours_in_Age_1__c is not set');

		// GET TASK RECORD TYPE
        Schema.DescribeSObjectResult tskSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = tskSchema.getRecordTypeInfosByName(); 
        Id rtTaskId = TaskRecordTypeInfo.get('NI Contracts Task').getRecordTypeId();
        
        // ADD TASK TO CLEAR THE FLAG
        Task task = new Task();
        task.WhatId = cs_1.id;
        task.RecordTypeId = rtTaskId;
        task.Subject = 'Other';
        task.priority= 'Low';
        task.status = 'Completed';
        task.description = 'Test Task to Unset the Case Flag';
        insert task;
       
        AH_Case_Flags_History_Tracking__c histTrackRec2 = [SELECT Id, Action__c, Hours_Elapsed__c, Hours_in_Age_1__c, Event__c 
                                                           FROM AH_Case_Flags_History_Tracking__c where Action__c = 'Task Completed'];
        system.debug('histTrackRec2 : '+histTrackRec2);
        system.assertEquals('Task Completed', histTrackRec2.Action__c, 'Task Completed Action is not found');
        system.assertEquals('Flag Cleared', histTrackRec2.Event__c, 'Event Flag Cleared is not found');
        
        Test.stopTest();
    }
    
    static testMethod void testInsertHistoryTrackingRecord4()
    {   
        Test.startTest();
        
        // CREATE CASE FLAG CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Clear_On_Case_Origin__c = true;
        upsert caseFlagSetting;
        
        // GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // RETRIEVE ACCOUNT & CONTACT
        Account a = [select id from Account where Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [select id from Contact where FirstName = 'Jack'];
        
        // RETRIEVE BUSINESS HOURS
        BusinessHours bs = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        // INSERT TEST CASE
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE';
        c.ContactId = cnt.Id;
        c.RecordTypeId = rtCaseId;
        c.AH_Enable_Case_Flag__c = true;
        c.BusinessHoursId = bs.Id;
        insert c;
        
        // INSERT HISTORY TRACKING RECORDS
        List<AH_Case_Flags_History_Tracking__c> historyTrackList = new List<AH_Case_Flags_History_Tracking__c>();
       
        AH_Case_Flags_History_Tracking__c hisTrackObj = new AH_Case_Flags_History_Tracking__c();
        hisTrackObj.Action__c = 'Set Flag Button';
        hisTrackObj.Business_Hours__c = c.BusinessHoursId;
        hisTrackObj.Case__c = c.Id;
        hisTrackObj.Case_Status__c = c.Status;
        hisTrackObj.Event__c = 'Flag Set';
        hisTrackObj.Owner__c = c.OwnerId;
        hisTrackObj.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
        hisTrackObj.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
        hisTrackObj.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
        hisTrackObj.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
        hisTrackObj.Start__c = DateTime.now().addHours(-5);
        hisTrackObj.End_Date_Time__c = DateTime.now().addHours(-4);
        hisTrackObj.Flag_Set__c = true;
        hisTrackObj.Hours_in_Age_1__c = 0.25;
        hisTrackObj.Hours_in_Age_2__c = 1.00;
        hisTrackObj.Hours_in_Age_3__c = 1.00;
        insert hisTrackObj;
        
        AH_Case_Flags_History_Tracking__c histTrackRec1 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_4__c,Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id =: hisTrackObj.id];
        system.debug('M4 - histTrackRec1 : '+histTrackRec1);
        system.assertNotEquals(NULL, histTrackRec1.Hours_in_Age_4__c, 'Hours_in_Age_4__c is not set');
        system.assertNotEquals(NULL, histTrackRec1.Hours_Elapsed__c, 'Hours_Elapsed__c is not set');
        system.assertNotEquals(NULL, histTrackRec1.Business_Hours_Elapsed__c, 'Business_Hours_Elapsed__c is not set');
        
        AH_Case_Flags_History_Tracking__c hisTrackObj3 = new AH_Case_Flags_History_Tracking__c();
        hisTrackObj3.Action__c = 'User Action or Non-Flags Automation';
        hisTrackObj3.Business_Hours__c = c.BusinessHoursId;
        hisTrackObj3.Case__c = c.Id;
        hisTrackObj3.Case_Status__c = c.Status;
        hisTrackObj3.Event__c = 'Case Owner Changed';
        hisTrackObj3.Owner__c = c.OwnerId;
        hisTrackObj3.End_Date_Time__c = DateTime.now();
        hisTrackObj3.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
        hisTrackObj3.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
        hisTrackObj3.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
        hisTrackObj3.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
        hisTrackObj3.Start__c = DateTime.now().addHours(-3);
        hisTrackObj3.End_Date_Time__c = DateTime.now().addHours(-2);
        hisTrackObj3.Hours_in_Age_1__c = 0.20;
        hisTrackObj3.Hours_in_Age_2__c = 1.00;
        hisTrackObj3.Hours_in_Age_3__c = 1.00;
        hisTrackObj3.Flag_Set__c = true;
        insert hisTrackObj3;
        
        AH_Case_Flags_History_Tracking__c histTrackRec2 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_4__c,Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id =: hisTrackObj3.id];
        system.debug('M4 - histTrackRec2 : '+histTrackRec2);
        system.assertNotEquals(NULL, histTrackRec2.Hours_Elapsed__c, 'Hours_Elapsed__c is not set');
        
        AH_Case_Flags_History_Tracking__c hisTrackObj2 = new AH_Case_Flags_History_Tracking__c();
        hisTrackObj2.Action__c = 'User Action or Non-Flags Automation';
        hisTrackObj2.Business_Hours__c = c.BusinessHoursId;
        hisTrackObj2.Case__c = c.Id;
        hisTrackObj2.Case_Status__c = c.Status;
        hisTrackObj2.Event__c = 'Case Owner Changed';
        hisTrackObj2.Owner__c = c.OwnerId;
        hisTrackObj2.End_Date_Time__c = DateTime.now();
        hisTrackObj2.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
        hisTrackObj2.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
        hisTrackObj2.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
        hisTrackObj2.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
        hisTrackObj2.Start__c = DateTime.now().addHours(-1);
        hisTrackObj2.Flag_Set__c = true;
        insert hisTrackObj2;
        
        AH_Case_Flags_History_Tracking__c histTrackRec3 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id =: hisTrackObj2.id];
        system.debug('M4 - histTrackRec3 : '+histTrackRec3);
        system.assertEquals(0.00, histTrackRec3.Hours_in_Age_1__c, 'Error in Hours_in_Age_1__c');
		system.assertNotEquals(NULL, histTrackRec3.Hours_Elapsed__c, 'Hours_Elapsed__c is not set');
        
        AH_Case_Flags_History_Tracking__c hisTrackObj4 = new AH_Case_Flags_History_Tracking__c();
        hisTrackObj4.Action__c = 'Set Flag Button';
        hisTrackObj4.Business_Hours__c = c.BusinessHoursId;
        hisTrackObj4.Case__c = c.Id;
        hisTrackObj4.Case_Status__c = c.Status;
        hisTrackObj4.Event__c = 'Flag Set';
        hisTrackObj4.Owner__c = c.OwnerId;
        hisTrackObj4.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
        hisTrackObj4.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
        hisTrackObj4.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
        hisTrackObj4.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
        insert hisTrackObj4;
        
        AH_Case_Flags_History_Tracking__c histTrackRec4 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id =: hisTrackObj4.id];
        system.debug('M4 - histTrackRec4 : '+histTrackRec4);
        system.assertNotEquals(NULL, histTrackRec4.Hours_in_Age_1__c, 'Hours_in_Age_1__c is not set');
        system.assertNotEquals(NULL, histTrackRec4.Hours_Elapsed__c, 'Hours_Elapsed__c is not set');
        
        Test.stopTest();
    }
    
    static testMethod void testInsertHistTrackingRecord3()
    {
        Test.startTest();
        
        // RETRIEVE ACCOUNT & CONTACT 
        Account a = [select id from Account where Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [select id from Contact where FirstName = 'Jack'];
        
        // GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // RETRIEVE STANDARD BUSINESS HOURS
        BusinessHours bs = [SELECT Id FROM BusinessHours WHERE Name = 'Default'];
        
        // INSERT TEST CASE
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE';
        c.ContactId = cnt.Id;
        c.Has_No_DI__c = TRUE;
        c.RecordTypeId = rtCaseId;
        c.AH_Enable_Case_Flag__c = true;
        c.BusinessHoursId = bs.Id;
        insert c;
        Case cs_1 = [select id from Case where id =: c.id];
        system.assertEquals(cs_1.id, c.id, 'Case not found..');
        
        SET<ID> histIds = new SET<ID>();
        
        // SET FLAG ON CASE USING BUTTON
        ApexPages.StandardController controller = new ApexPages.StandardController(c);
        AH_SetFlagController setCtrl = new AH_SetFlagController(controller);
        setCtrl.setFlagNow();
        
        AH_Case_Flags_History_Tracking__c histTrackRec5 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c]; //where id NOT IN : histIds];
        system.debug('M3 - histTrackRec5 : '+histTrackRec5);
        system.assertNotEquals(NULL, histTrackRec5.Hours_in_Age_1__c, 'Hours_in_Age_1__c is not set');
        system.assertEquals('Set Flag Button', histTrackRec5.Action__c, 'Action__c is wrong');
        
        histIds.add(histTrackRec5.id);

        // ADD CASE COMMENT TO CLEAR THE FLAG
        CaseComment com = new CaseComment();
        com.ParentId = c.id;
        com.CommentBody= 'Adding case comment to remove case flag..';
        com.IsPublished = TRUE;
        insert com;
        
        AH_Case_Flags_History_Tracking__c histTrackRec4 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, Event__c,  
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id NOT IN : histIds];
        system.debug('M3 - histTrackRec4 : '+histTrackRec4);
        system.assertNotEquals(NULL, histTrackRec4.Hours_in_Age_1__c, 'Hours_in_Age_1__c is not set');
        system.assertEquals('Internal Comment Added', histTrackRec4.Action__c, 'Action__c is wrong');
		system.assertEquals('Flag Cleared', histTrackRec4.Event__c, 'Event__c is not set');

 		Test.stopTest();
        
    }
    
    static testMethod void testInsertHistoryTrackingRecord2()
    {
        
        Test.startTest();
        
        SET<ID> histIds = new SET<ID>();
        
        // CASE FLAGS CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        caseFlagSetting.Clear_On_Case_Origin__c = true;
        upsert caseFlagSetting;
        
        // GET RECORDTYPE OF CASE
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        // RETRIEVE ACCOUNT & CONTACT 
        Account a = [select id from Account where Name = 'NI_Case_TriggerHandlerTest ACCOUNT'];
        Contact cnt = [select id from Contact where FirstName = 'Jack'];
        
        // INSERT TEST CASE
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'NI_Case_TriggerHandlerTest PARENT CASE';
        c.ContactId = cnt.Id;
        c.RecordTypeId = rtCaseId;
        c.AH_Enable_Case_Flag__c = true;
        insert c;
        Case cs_1 = [select id from Case where id =: c.id];
        system.assertEquals(cs_1.id, c.id, 'Case not found..');
        
        // SET FLAG
        ApexPages.StandardController controller = new ApexPages.StandardController(c);
        AH_SetFlagController setCtrl = new AH_SetFlagController(controller);
        setCtrl.setFlagNow();

        // FLAGGED DATE SHOULD BE SET
        Case cs = [select id, AH_Case_Flagged_Date__c, Subject from Case where id =: c.id];
        System.assertNotEquals(null, cs.AH_Case_Flagged_Date__c, 'Flagged Date is not set');

        // CREATE PREVIOUS HISTORY TRACKING RECORDS
        AH_Case_Flags_History_Tracking__c hisTrackObj = new AH_Case_Flags_History_Tracking__c();
        hisTrackObj.Action__c = 'User Action or Non-Flags Automation';
        hisTrackObj.Business_Hours__c = c.BusinessHoursId;
        hisTrackObj.Case__c = c.Id;
        hisTrackObj.Case_Status__c = c.Status;
        hisTrackObj.Event__c = 'Case Owner Changed';
        hisTrackObj.Owner__c = c.OwnerId;
        hisTrackObj.End_Date_Time__c = DateTime.now();
        hisTrackObj.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
        hisTrackObj.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
        hisTrackObj.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
        hisTrackObj.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
        hisTrackObj.Start__c = DateTime.now().addHours(-9);
        hisTrackObj.End_Date_Time__c = DateTime.now().addHours(-2);
        hisTrackObj.Flag_Set__c = true;
        hisTrackObj.Hours_in_Age_1__c = 1.50;
        hisTrackObj.Hours_in_Age_2__c = 1.00;
        hisTrackObj.Hours_in_Age_3__c = 1.00;
        insert hisTrackObj;
    
        AH_Case_Flags_History_Tracking__c histTrackRec1 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id =: hisTrackObj.id];
        system.debug('M2 - histTrackRec1 : '+histTrackRec1);
        system.assertNotEquals(NULL, histTrackRec1.Hours_in_Age_4__c, 'Hours_in_Age_4__c is not set');
        system.assertNotEquals(NULL, histTrackRec1.Hours_Elapsed__c, 'Hours_Elapsed__c is not set');
        system.assertNotEquals(NULL, histTrackRec1.Business_Hours_Elapsed__c, 'Business_Hours_Elapsed__c is not set');
       
        
        AH_Case_Flags_History_Tracking__c hisTrackObj3 = new AH_Case_Flags_History_Tracking__c();
        hisTrackObj3.Action__c = 'User Action or Non-Flags Automation';
        hisTrackObj3.Business_Hours__c = c.BusinessHoursId;
        hisTrackObj3.Case__c = c.Id;
        hisTrackObj3.Case_Status__c = c.Status;
        hisTrackObj3.Event__c = 'Case Owner Changed';
        hisTrackObj3.Owner__c = c.OwnerId;  
        hisTrackObj3.End_Date_Time__c = DateTime.now();
        hisTrackObj3.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
        hisTrackObj3.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
        hisTrackObj3.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
        hisTrackObj3.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
        hisTrackObj3.Start__c = DateTime.now().addHours(-7);
        hisTrackObj3.End_Date_Time__c = DateTime.now().addHours(-2);
        hisTrackObj3.Flag_Set__c = true;
        insert hisTrackObj3;
        
        AH_Case_Flags_History_Tracking__c histTrackRec2 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, 
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id =: hisTrackObj3.id];
        system.debug('M2 - histTrackRec2 : '+histTrackRec2);
        system.assertNotEquals(NULL, histTrackRec2.Hours_in_Age_1__c, 'Error in Hours_in_Age_1__c');
        system.assertNotEquals(NULL, histTrackRec2.Hours_in_Age_2__c, 'Error in Hours_in_Age_2__c');
        system.assertNotEquals(NULL, histTrackRec2.Hours_in_Age_3__c, 'Error in Hours_in_Age_3__c');
        system.assertNotEquals(NULL, histTrackRec2.Hours_in_Age_4__c, 'Error in Hours_in_Age_4__c');
        
        List<AH_Case_Flags_History_Tracking__c> historyTrackList = new List<AH_Case_Flags_History_Tracking__c>();
        historyTrackList = [SELECT Id, Action__c FROM  AH_Case_Flags_History_Tracking__c];
        system.assertEquals(3, historyTrackList.size(), 'History tracking records count mismacth ..');

        for (AH_Case_Flags_History_Tracking__c lst : historyTrackList){
            histIds.add(lst.id);
        }
        
        // CLEAR FLAG BUTTON SHOULD CREATE HISTORY TRACKING RECORD
        ApexPages.StandardController clrController = new ApexPages.StandardController(cs_1);
        AH_ClearFlagController clr = new AH_ClearFlagController(clrController);
        clr.clearFlagNow();
        AH_Case_Flags_History_Tracking__c histTrackRec0 = [SELECT Id, Action__c, Hours_Elapsed__c, Business_Hours_Elapsed__c, Event__c,  
                                              Hours_in_Age_1__c, Hours_in_Age_2__c, Hours_in_Age_3__c, Hours_in_Age_4__c,
                                              Flag_Level__c, Flag_Level_BH__c FROM AH_Case_Flags_History_Tracking__c where id NOT IN : histIds];
        system.debug('M2 - histTrackRec0 : '+histTrackRec0);
        system.assertEquals('Clear Flag Button', histTrackRec0.Action__c, 'Action__c is not matching');
        system.assertEquals('Flag Cleared', histTrackRec0.Event__c, 'Event__c is not matching');
        
        Test.stopTest();
        
    }
    
}