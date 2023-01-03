/****************************************************************************************
Name            : AH_Rally_SendAttachment_Test
Author          : Sean Harris
Created Date    : 11/25/2020
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Test class for AH_Rally_SendAttachment
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_SendAttachment_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        Test.startTest();
                
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
        a.Name = 'AH_Rally_SendAttachment_Test Account';
        insert a;
        
        // CREATE 2 TEST CASE RECORDS
		Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_SendAttachment_Test Case# 1';
        cs1.User_Story_Id__c = 'US90582';
        cs1.Priority = 'Medium';
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

        // CREATE TEST ATTACHMENT ON CASE
       	Attachment att = NI_TestClassData.createTestAttachment(cs1.Id);
        att.Name = 'AH_Rally_SendAttachment_Test';
        insert att;
        
        // CREATE TEST CASE ATTACHMENT RELATION RECORD
        Case_Attachment_Relation__c attach = new Case_Attachment_Relation__c();
        attach.case_id__c = cs1.Id;
        attach.To_be_Send__c = true;
        attach.Sf_Attachment_Id__c = att.Id;
        insert attach;

        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1:  
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_SendAttachment_Test Case# 1'];
		Attachment att = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_SendAttachment_Test'];        

        Test.startTest();
        
        String s1 = AH_Rally_SendAttachment.getDefectId('AH_Rally_SendAttachment');
        system.debug(' ::: s1 = ' + s1);
        AH_Rally_SendAttachment.setValues(att.Id);

        system.debug(' ::: ref_attachment_content = ' + AH_Rally_SendAttachment.ref_attachment_content);
        system.debug(' ::: type = ' + AH_Rally_SendAttachment.type);        

        Test.stopTest();
        
        system.assert(true);
        
    }


    // ======================================================================================================================================= 
    // = TEST METHOD 2:  
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {   
		Attachment att = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_SendAttachment_Test']; 
        
        Test.startTest();
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}'; 
        string s2 = AH_Rally_SendAttachment.createJson_AttachmentContent(att.Id);
        system.debug(' ::: s2 = ' + s2);                
        Test.stopTest();
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3:  
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {    
        Attachment att = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_SendAttachment_Test']; 
        Test.startTest();
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}'; 
        AH_Rally_SendAttachment.setValues(att.Id);
        string s3 = AH_Rally_SendAttachment.createJson_Attachment();
        system.debug(' ::: s3 = ' + s3);                
        Test.stopTest();      
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4:  
    // ======================================================================================================================================= 
    @isTest static void test4() 
    { 
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_SendAttachment_Test Case# 1'];
		Attachment att = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_SendAttachment_Test'];        
        
        Test.startTest();
        String s4 = AH_Rally_SendAttachment.sendAttachment(att.Id, c.Id);
        system.debug(' ::: s4 = ' + s4);                
        Test.stopTest();        
    } 

    // ======================================================================================================================================= 
    // = TEST METHOD 5:  
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {  
		Attachment att = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_SendAttachment_Test'];        
        
        Test.startTest();
        String s5 = AH_Rally_SendAttachment.valuesofAttachment(att.Id);    
        system.debug(' ::: s5 = ' + s5);                
        Test.stopTest();        
    }  
/*
    // ======================================================================================================================================= 
    // = TEST METHOD 6:  
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {    
        Test.startTest();
                
        Test.stopTest();        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7:  
    // ======================================================================================================================================= 
    @isTest static void test7() 
    {    
        Test.startTest();
                
        Test.stopTest();        
    }    

    // ======================================================================================================================================= 
    // = TEST METHOD 8:  
    // ======================================================================================================================================= 
    @isTest static void test8() 
    {    
        Test.startTest();
                
        Test.stopTest();        
    }
*/    
}