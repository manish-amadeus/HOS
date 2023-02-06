/****************************************************************************************
Name            : NI_Task_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 12/01/2016
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage
NICC Reference  : 
Description     : Test class for NI_Task_TriggerHandler apex class.
                : 
                : 
******************************************************************************************/
@isTest 
public class NI_Task_TriggerHandler_Test
{
    
    // ======================================================================================================================================= //
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {    

        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtCaseId = CaseRecordTypeInfo.get('Case').getRecordTypeId();
        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        flagRecTypes.Name = 'Default';
        flagRecTypes.Enabled_Case_Type__c = String.valueof(rtCaseId);
        flagRecTypes.Enabled_Activity_Types__c = 'Email,Call';
        flagRecTypes.Clear_Case_Origins__c = 'Phone';
        insert flagRecTypes;
        
        
        system.debug('NI_Task_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES after NI_TestClassData.createTestWinaproachServiceNowSettings() = ' + limits.getQueries());

        // CREATE TEST ACCOUNT FOR TEST CASES
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;

        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        test.startTest();
        
        // CREATE 2 TEST CASES 
        List<Case> lstCaseInsert = new List<Case>();
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'TEST APEX TASK TRIGGER';
        c.RecordTypeId = rtCaseId;
        lstCaseInsert.Add(c);
        
        Case c2 = NI_TestClassData.createTestCase(2, a.Id);
        c2.Subject = 'TEST APEX TASK TRIGGER NUMBER FIELDS';
        lstCaseInsert.Add(c2);
        
        database.insert(lstCaseInsert);

        test.stopTest();
        
        AH_Task_Business_Hours__c taskBsHrs = new AH_Task_Business_Hours__c();
        taskBsHrs.Name = 'Professional Services Task';
        taskBsHrs.Business_Hours__c = 'S&C Contracts Tasks';
        insert taskBsHrs;

        // NI_TestClassData.createCaseFlagPrefernces();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;    
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case WHERE Subject LIKE 'TEST APEX TASK TRIGGER%']);
        system.assertEquals(2, lstCaseAsserts.Size());
        
        system.debug('END NI_Task_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());   
        
    }

    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //
    @isTest static void taskTriggerHandlerTest()
    {
        
        Case c = [SELECT Id, Number_of_Calls__c, Number_of_Emails_Sent__c FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER'];        
        Case c2 = [SELECT Id, Number_of_Calls__c, Number_of_Emails_Sent__c FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER NUMBER FIELDS'];
   
        c2.Number_of_Calls__c = null;
        c2.Number_of_Emails_Sent__c = null;
        update c2;

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rt = TaskRecordTypeInfo.get('NI Support').getRecordTypeId();
        
        Task tskCall = NI_TestClassData.createTestTask(1, null, c.Id, rt, 'Call', 'Completed', 'Low');
        Task tskEmail = NI_TestClassData.createTestTask(2, null, c.Id, rt, 'Outgoing Email', 'Completed', 'Low');

        Task tskCall2 = NI_TestClassData.createTestTask(3, null, c2.Id, rt, 'Call', 'Completed', 'Low');
        Task tskEmail2 = NI_TestClassData.createTestTask(4, null, c2.Id, rt, 'Outgoing Email', 'Completed', 'Low');
        
        test.startTest();
        
        // CREATE 4 TEST TASKS
        List<Task> lstTaskInsert = new List<Task>();
        lstTaskInsert.add(tskCall);
        lstTaskInsert.add(tskEmail);
        lstTaskInsert.add(tskCall2);
        lstTaskInsert.add(tskEmail2);   
        
        Database.insert(lstTaskInsert);        
        
        test.stopTest();
        
        // RUN ASSERTIONS ON FIELD VALUES 
        Case csAsserts = [SELECT Id, Number_of_Calls__c, Number_of_Emails_Sent__c FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER']; 
        system.assertEquals(1, csAsserts.Number_of_Calls__c, 'Number of Calls did not update on Case record.');
//        system.assertEquals(1, csAsserts.Number_of_Emails_Sent__c, 'Number of Emails Sent did not update on Case record.');                
        
        system.debug('END NI_Task_TriggerHandler_Test.taskTriggerHandlerTest() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: 
    // ======================================================================================================================================= //
    @isTest static void taskTriggerHandlerTest2()
    {
        BusinessHours bh = new BusinessHours();
        bh = [SELECT Id, Name, MondayStartTime, MondayEndTime FROM BusinessHours WHERE Name = 'SO - PMW/HSVP'];
        
        Case c = [SELECT Id, Number_of_Calls__c, Number_of_Emails_Sent__c FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER'];        
        Case c2 = [SELECT Id, Number_of_Calls__c, Number_of_Emails_Sent__c FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER NUMBER FIELDS'];
   
        c2.Number_of_Calls__c = null;
        c2.Number_of_Emails_Sent__c = null;
        update c2;

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rt = TaskRecordTypeInfo.get('Professional Services Task').getRecordTypeId();
        
        Task tskCall = NI_TestClassData.createTestTask(1, null, c.Id, rt, 'Call', 'Not Started', 'Low');
        //tskCall.ActivityDate = system.today();
        tskCall.Business_Hours__c = bh.Id;
        Task tskEmail = NI_TestClassData.createTestTask(2, null, c.Id, rt, 'Outgoing Email', 'On Hold', 'Low');
        //tskEmail.ActivityDate = system.today().addDays(5);
        tskEmail.Business_Hours__c = bh.Id;
        //Task tskCall2 = NI_TestClassData.createTestTask(3, null, c2.Id, rt, 'Call', 'Completed', 'Low');
        Task tskEmail2 = NI_TestClassData.createTestTask(4, null, c2.Id, rt, 'Outgoing Email', 'On Hold', 'Low');
        tskEmail2.Business_Hours__c = bh.Id;
        tskEmail2.Store_On_Hold_Task_Time__c = '2.20 days';
        
        test.startTest();
        
        // CREATE 4 TEST TASKS
        List<Task> lstTaskInsert = new List<Task>();
        lstTaskInsert.add(tskCall);
        lstTaskInsert.add(tskEmail);
        //lstTaskInsert.add(tskCall2);
        lstTaskInsert.add(tskEmail2);   
        
        Database.insert(lstTaskInsert); 
        
        List<Task> lstTaskUpdate = new List<Task>();
        tskCall.Status = 'On Hold';
        lstTaskUpdate.add(tskCall);
        tskEmail.Status = 'Completed';
        lstTaskUpdate.add(tskEmail);
        tskEmail2.Status = 'Completed';
        //lstTaskUpdate.add(tskEmail2);
        Database.update(lstTaskUpdate);
        
        tskEmail.Status = 'Not Started';
        update tskEmail;
        
        tskEmail.Status = 'On Hold';
        update tskEmail;
        
        tskEmail.Status = 'Completed';
        update tskEmail;
        test.stopTest();
        
        List<Task> tasksList = [SELECT Id, Subject, Total_Task_Time__c, On_Hold_Task_Time__c, On_Hold_Time__c 
                               FROM Task];
        system.assertEquals(3, tasksList.size());
        //system.debug('END NI_Task_TriggerHandler_Test.taskTriggerHandlerTest() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }
    
     // ======================================================================================================================================= //
    // = TEST METHOD 3: 
    // ======================================================================================================================================= //
    @isTest static void taskTriggerHandlerTest3()
    {
        NI_Task_TriggerHandler handler = new NI_Task_TriggerHandler();
        String timeOne = '2.00 hours';
        String timeTwo = '2.00 days';
        Long workingHours = 9;
        String operation = 'add';
        String resultOne = handler.addOrSubtractDaysOrHours(timeOne, timeTwo, workingHours, operation);
        system.assertEquals('2.22 days', resultOne);
        
        String resultTwo = handler.addOrSubtractDaysOrHours(timeTwo, timeOne, workingHours, operation);
        system.assertEquals('2.22 days', resultTwo);
    }
    
}