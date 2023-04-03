/****************************************************************************************
Name            : AH_Rally_BulkUpdateFetchSchedule_Test (TC Org Name: ScheduleBulkUpdateRallyFetchTest)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_BulkUpdateFetchSchedule & AH_Rally_BulkUpdateFetch
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_BulkUpdateFetchSchedule_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        // CREATE WIN@PROACH CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();

        // CREATE RALLY SETUP RECORD
		AH_Rally_Setup__c rsm = new AH_Rally_Setup__c(); 
		rsm.API_Version__c = '1.43';
		rsm.Exception_Notification_Email__c = 'abc@abc.com';
		rsm.password__c = '12345';
		rsm.rallyUrl__c = 'https://rally1.rallydev.com';
		rsm.username__c = 'travelclick';
		rsm.workspace__c = 'jira';
		rsm.Schedular_Last_Run__c = DATETIME.now();
		rsm.Story_Field_Map__c = '{"Description":{"fldValue":"None","literalValue":""},"KanbanState":{"custom":1,"fldValue":"None","literalValue":""},"L3KanbanStage":{"custom":1,"fldValue":"Default","literalValue":"Advance Investigation"},"Moscow":{"custom":1,"fldValue":"None","literalValue":""},"Name":{"fldValue":"Subject","literalValue":""},"Owner":{"fldValue":"None","literalValue":""},"Package":{"fldValue":"None","literalValue":""},"Rank":{"fldValue":"None","literalValue":""},"ReadyDeprecated":{"custom":1,"fldValue":"None","literalValue":""},"SalesforcePriority":{"custom":1,"fldValue":"Priority","literalValue":""},"StoryType":{"custom":1,"fldValue":"Default","literalValue":"L3/Salesforce"}}';
        insert rsm;  
        
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_Rally_CaseSync_Test Account';
        insert a;
        
        // CREATE 2 TEST CASE RECORDS
		Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_Library_Test Case# 1';
        cs1.User_Story_Id__c = 'US90582';
        cs1.Subject = 'TestCase';
        cs1.Customer_Severity__c = '4 - Procedural';
        cs1.Status = 'Escalate to L3';
        cs1.Type = 'Approvals';
        cs1.Origin = 'Fax';
        cs1.Number_of_Requests__c = 1;
        cs1.L3_Ticket_Summary__c = 'abc';
        cs1.L3_Steps_To_Reproduce__c = 'abc';
        cs1.Product_Family__c = 'Reservation Solutions';
        cs1.Product__c = 'iHotelier CRS';
        cs1.UserStory_Rally_Status__c = 'In Progress';
        cs1.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js';
        insert cs1;
        
		Case cs2 = NI_TestClassData.createTestCase(1, a.Id);
        cs2.Subject = 'AH_Rally_Library_Test Case #2';
        cs2.User_Story_Id__c = 'US90583';
        cs2.Subject = 'TestCase';
        cs2.Customer_Severity__c = '4 - Procedural';
        cs2.Status = 'Escalate to L3';
        cs2.Type = 'Approvals';
        cs2.Origin = 'Fax';
        cs2.Number_of_Requests__c = 1;
        cs2.L3_Ticket_Summary__c = 'abc';
        cs2.L3_Steps_To_Reproduce__c = 'abc';
        cs2.Product_Family__c = 'Reservation Solutions';
        cs2.Product__c = 'iHotelier CRS';
        cs2.UserStory_Rally_Status__c = 'In Progress';
        cs2.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js';
		insert cs2;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: testschedule
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {           
        
        case ca = [SELECT Id FROM Case WHERE User_Story_Id__c = 'US90582' LIMIT 1];
        case ca1 = [SELECT Id FROM Case WHERE User_Story_Id__c = 'US90583' LIMIT 1];
        string cdata = ca.Id;
        string cid = cdata.left(15);
        string cdata1 = ca.Id;
        string cid1 = cdata.left(15);

        AH_Rally_Library.str ='{"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","TotalResultCount":"202","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":{"LinkID":"'+ca.id+'"},"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Results":[{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js", "_objectVersion": "81", "_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)", "FormattedID": "US90582", "DirectChildrenCount": 0, "LastUpdateDate": "2017-07-04T12:01:51.932Z", "Owner": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/user/58964592672.js", "_objectVersion": "589", "_refObjectName": "Arpit (L3)", "_type": "User"}, "Release": null, "Project": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js", "_refObjectName": "L3 Booking Engine 4.0", "_type": "Project"}, "L3KanbanStage": "Advance Investigation", "RetentionRisk": null, "SalesforceCase": {"LinkID": "'+cid+'", "DisplayString": "04410226"}, "SalesforcePriority": "High", "TargetCompletionDate": "2017-07-04T12:01:51.932Z", "_type": "HierarchicalRequirement"},{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js", "_objectVersion": "81", "_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)", "FormattedID": "US90583", "DirectChildrenCount": 0, "LastUpdateDate": "2017-07-04T12:01:51.932Z", "Owner": null, "Release": null, "Project": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js", "_refObjectName": "L3 Booking Engine 4.0", "_type": "Project"}, "L3KanbanStage": null, "RetentionRisk": null, "SalesforceCase": {"LinkID": "'+cid1+'", "DisplayString": "04410226"}, "SalesforcePriority": null, "TargetCompletionDate": null, "_type": "HierarchicalRequirement"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js","_objectVersion":"7","_refObjectName":"Testing of batch_sf7","LastUpdateDate":"2013-11-08T06:41:42.749Z","Priority":"Critical","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/14311297540.js","_refObjectName":"L3_OTA","_type":"Project"},"Severity":"Crash/Data Loss","KanbanState":"Need More Information","_type":"Defect"}]}}';
                
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new AH_Rally_BulkUpdateFetchSchedule());

        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: to cover exception to send email
    // ======================================================================================================================================= 
    @isTest static void test2() 
    { 
        
        AH_Rally_Setup__c rsm = [SELECT Case_Id__c, Rally_Exception_Count__c FROM AH_Rally_Setup__c LIMIT 1];
        rsm.Rally_Exception_Count__c = 3;
        update rsm;
        
        Test.startTest();
        
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testBasicScheduledApex', CRON_EXP, new AH_Rally_BulkUpdateFetchSchedule());
        
        Test.stopTest(); 
    } 
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: to cover duplicate case email
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {
        Test.startTest();
        
        set<String> caseStoryIDs = new set<String>{'case1,US11111', 'case2,US222222'};
        AH_Rally_BulkUpdateFetch.sendEmailToUser(caseStoryIDs); 
        
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {

        case ca = [SELECT Id FROM Case WHERE User_Story_Id__c = 'US90582' LIMIT 1];
        case ca1 = [SELECT Id FROM Case WHERE User_Story_Id__c = 'US90583' LIMIT 1];
        string cdata = ca.Id;
        string cid = cdata.left(15);
        string cdata1 = ca.Id;
        string cid1 = cdata.left(15);
        
        Test.startTest();
 
        AH_Rally_Library.str ='{"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","TotalResultCount":"202","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":{"LinkID":"'+ca.id+'"},"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Results":[{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js", "_objectVersion": "81", "_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)", "FormattedID": "US90582", "DirectChildrenCount": 0, "LastUpdateDate": "2017-07-04T12:01:51.932Z", "Owner": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/user/58964592672.js", "_objectVersion": "589", "_refObjectName": "Arpit (L3)", "_type": "User"}, "Release": null, "Project": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js", "_refObjectName": "L3 Booking Engine 4.0", "_type": "Project"}, "L3KanbanStage": "Advance Investigation", "RetentionRisk": null, "SalesforceCase": {"LinkID": "'+cid+'", "DisplayString": "04410226"}, "SalesforcePriority": "High", "TargetCompletionDate": "2017-07-04T12:01:51.932Z", "_type": "HierarchicalRequirement"},{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js", "_objectVersion": "81", "_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)", "FormattedID": "US90583", "DirectChildrenCount": 0, "LastUpdateDate": "2017-07-04T12:01:51.932Z", "Owner": null, "Release": null, "Project": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js", "_refObjectName": "L3 Booking Engine 4.0", "_type": "Project"}, "L3KanbanStage": null, "RetentionRisk": null, "SalesforceCase": {"LinkID": "'+cid1+'", "DisplayString": "04410226"}, "SalesforcePriority": null, "TargetCompletionDate": null, "_type": "HierarchicalRequirement"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js","_objectVersion":"7","_refObjectName":"Testing of batch_sf7","LastUpdateDate":"2013-11-08T06:41:42.749Z","Priority":"Critical","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/14311297540.js","_refObjectName":"L3_OTA","_type":"Project"},"Severity":"Crash/Data Loss","KanbanState":"Need More Information","_type":"Defect"}]}}';       
    
        AH_Rally_BulkUpdateFetch buf = new AH_Rally_BulkUpdateFetch();          
        
        AH_Rally_UserStoryDetails usd = new AH_Rally_UserStoryDetails();
		usd.SalesforceCase = new AH_Rally_UserStoryDetails.SalesforceCaseId(); 
        usd.SalesforceCase.LinkID = ca.Id; 
        usd.SalesforceCase.DisplayString = 'Test DisplayString';

		buf.defectList.add(usd);

        AH_Rally_BulkUpdateFetch.CaseofSalesforce.add(ca.Id);
        AH_Rally_BulkUpdateFetch.CaseofSalesforce.add(ca1.Id);
        
        buf.bulkUpdateRallyField(); 
        
        Test.stopTest(); 
        
    }    
    
    
}