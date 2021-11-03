/****************************************************************************************
Name            : INTGR_WinSN_Task_Handler_Test Class
Author          : Sean Harris
Created Date    : 05/11/2017
Last Mod Date   : 05/11/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for INTGR_WinSN_Task_Handler apex class.
                : 
                : 
******************************************************************************************/
@isTest 
public class INTGR_WinSN_Task_Handler_Test 
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
        Id rtCaseId = CaseRecordTypeInfo.get('CRS Incident').getRecordTypeId();

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

        database.insert(lstCaseInsert);

        test.stopTest();

        List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case WHERE Subject LIKE 'TEST APEX TASK TRIGGER%']);
        system.assertEquals(1, lstCaseAsserts.Size());

    }

    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //
    @isTest static void taskTriggerHandlerTest1()
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER'];        

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = TaskRecordTypeInfo.get('Amadeus Parallel Investigation').getRecordTypeId();
		
        Task tsk = NI_TestClassData.createTestTask(1, null, c.Id, rt, 'Call', 'Completed', 'Low');
        tsk.TaskSubtype = 'Email';
		insert tsk;        

    }   
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: 
    // ======================================================================================================================================= //
    @isTest static void taskTriggerHandlerTest2()
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'TEST APEX TASK TRIGGER'];        

        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task; 
        Map<String, Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = TaskRecordTypeInfo.get('Amadeus Parallel Investigation').getRecordTypeId();
		
        Task tsk = NI_TestClassData.createTestTask(1, null, c.Id, rt, 'Call', 'Completed', 'Low');
		insert tsk;        

    }  
    
}