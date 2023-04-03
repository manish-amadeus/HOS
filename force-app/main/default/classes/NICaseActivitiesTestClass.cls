/****************************************************************************************
Name            : NICaseActivitiesTestClass Class
Author          : Sean Harris
Created Date    : 03/23/2012
Last Mod Date   :
Last Mod By     :
NICC Reference  : NICC-004515 - https://c.na4.visual.force.com/apex/ni_change_control_tabbed_layout?id=a0s60000003o35HAAQ
Description     : test Class for CaseActivities Class
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
private class NICaseActivitiesTestClass 
{

    static testMethod void myUnitTest() 
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
        EmailMessage e4 = NI_TestClassData.createTestEmailMessage(4, c.Id, 'Joe Doe', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'jdoe@newsoft.com', 'CaseActivitiesTestClass Test Email #4', 'CaseActivitiesTestClass Test Email #4', '3');
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
        
        // PAGE REFERENCE
        PageReference pageRef = Page.NICaseActivities;
        Test.setCurrentPage(pageRef);
        
        // ADD URL PARAMS
        pageRef.getParameters().put('id', c.Id);
        
        // CONTROLLER 
        NICaseActivities ctrl = new NICaseActivities(new ApexPages.StandardController(c));
        
		string strDesc = ctrl.getDescription;
        List<String> r = ctrl.results;     

    }
    
}