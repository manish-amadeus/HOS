/****************************************************************************************
Name            : AH_CaseActivities_Test Class
Author          : Sean Harris
Created Date    : 03/23/2012
Last Mod Date   : 04/17/2020
Last Mod By     : Sean Harris 
NICC Reference  : 
Description     : Test class for AH_CaseActivities Controller
                : 
******************************************************************************************/
@isTest 
private class AH_CaseActivities_Test 
{
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
       
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        // ACCOUNT OBJECT
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;       
        
        //CONTACT OBJECT
        Contact ct = NI_TestClassData.createTestContact(1, a.Id);
        insert ct;
        
        // CASE OBJECT
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_CaseActivities_Test';
        c.ContactId = ct.Id;
        insert c;
        
        // CASE COMMENTS OBJECT
        List<CaseComment> lstCaseComment = new List<CaseComment>();
        
        CaseComment cc1 = NI_TestClassData.createTestCaseComment(1, c.Id);
        cc1.CommentBody = 'Test CommentBody';
        lstCaseComment.Add(cc1); 
        
        CaseComment cc2 = NI_TestClassData.createTestCaseComment(2, c.Id);
        cc2.CommentBody = '';
        lstCaseComment.Add(cc2); 
        
        database.insert(lstCaseComment); 
        
        Test.startTest(); 
        
        // CASE EMAIL OBJECTS
        List<EmailMessage> lstEmailMessage = new List<EmailMessage>(); 

        EmailMessage e1 = NI_TestClassData.createTestEmailMessage(1, c.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'CaseActivitiesTestClass Test Email #1', 'CaseActivitiesTestClass Test Email #1 --------Original Message---------- Hello world!', '0');
        lstEmailMessage.Add(e1);
        EmailMessage e2 = NI_TestClassData.createTestEmailMessage(2, c.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'CaseActivitiesTestClass Test Email #2', 'CaseActivitiesTestClass Test Email #2', '1');
        lstEmailMessage.Add(e2);
        EmailMessage e3 = NI_TestClassData.createTestEmailMessage(3, c.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'CaseActivitiesTestClass Test Email #3', 'CaseActivitiesTestClass Test Email #3', '2');
        lstEmailMessage.Add(e3);
        EmailMessage e4 = NI_TestClassData.createTestEmailMessage(4, c.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'AH_CaseActivities_Test', 'AH_CaseActivities_Test', '3');
        lstEmailMessage.Add(e4);
        
        database.insert(lstEmailMessage); 
        
        // CASE TASKS OBJECT
        List<Task> lstTasks = new List<Task>();
        Id rt = NI_TestClassData.getRecordTypeId('Task', 'NI Support');
        
        Task tsk1 = NI_TestClassData.createTestTask(1, ct.Id, c.Id, rt, 'Call', 'Completed', 'Normal - 2 Days');
        tsk1.Description = 'Test Description';
        tsk1.Subject = 'Test Description';
        lstTasks.Add(tsk1);
        
        Task tsk2 = NI_TestClassData.createTestTask(2, ct.Id, c.Id, rt, 'Call', 'Completed', 'Normal - 2 Days');
        tsk2.Subject = 'Test Description';
        lstTasks.Add(tsk2);
        
        database.insert(lstTasks);         

        Test.stopTest();
        
    }
  
 
    // =======================================================================================================================================
    // = TEST METHOD 1: UNIT TESTING FOR CANCELLATION CREATION
    // =======================================================================================================================================
    @isTest static void test1() 
    {    
    
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_CaseActivities_Test'];
        
        EmailMessage e1 = [SELECT Id, ToAddress, TextBody, Subject, Status, ParentId, FromName, FromAddress, CreatedDate, CreatedById, CcAddress, BccAddress                            
                           FROM EmailMessage 
                           WHERE Subject = 'Apex Test Email # 4']; 
       
        List<DA_EmailMessage__b> lstEMs = new List<DA_EmailMessage__b>();
        
        DA_EmailMessage__b arcEm = new DA_EmailMessage__b();

        arcEm.S_ParentId_Indexed__c = c.Id;
        arcEm.S_Id_Indexed__c = e1.Id;
        
        arcEm.S_Id__c = e1.Id;
        arcEm.S_ToAddress__c = e1.ToAddress;
        arcEm.S_TextBody__c = e1.TextBody;
        arcEm.S_Subject__c = e1.Subject;
        arcEm.S_Status__c = e1.Status;
        arcEm.S_ParentId__c = e1.ParentId;
        arcEm.S_FromName__c = e1.FromName;
        arcEm.S_FromAddress__c = e1.FromAddress;
        arcEm.S_CreatedDate__c = e1.CreatedDate;
        arcEm.S_CreatedById__c = e1.CreatedById;
        arcEm.S_CcAddress__c = e1.CcAddress;
        arcEm.S_BccAddress__c = e1.BccAddress;
        //database.insertImmediate(arcEm);         
        lstEMs.add(arcEm);

        // PAGE REFERENCE
        PageReference pageRef = Page.AH_CaseActivities;
        Test.setCurrentPage(pageRef);
        
        // ADD URL PARAMS
        pageRef.getParameters().put('id', c.Id);
        
        // CONTROLLER 
        AH_CaseActivities ctrl = new AH_CaseActivities();
        
        Test.startTest(); 
//        ctrl.insertTestBigObjectRecords(lstEMs);
        Test.stopTest();
        
        List<String> r = ctrl.lstAllActivities;     
          
    }
    
}