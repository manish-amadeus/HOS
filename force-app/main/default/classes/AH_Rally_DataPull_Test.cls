/****************************************************************************************
Name            : AH_Rally_DataPull_Test (TC Org Name: LRPullDataRallyTest)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_DataPull
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_DataPull_Test 
{
 
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        Test.startTest();
        
        // CREATE WIN@PROACH CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();

		// CREATE TEST PRODUCT PROJECT MAPPING CUSTOM SETTING RECORD
        ProductMapping__c pro = new ProductMapping__c();
        pro.Name = 'Mapping0';
        pro.Product_Family__c = 'Reservation Solutions';
        pro.Affected_Component__c = '';
        pro.Product__c = 'DataBridge';
        pro.Project__c = 'L3 PMSConnect';
        insert pro;  
        
        // CREATE TEST COLA CUSTOM SETTING RECORD
        COLA_Settings__c cs = new COLA_Settings__c();
        cs.Name = 'STOMAutomation';
        cs.Allow_Product_Creation__c = true;
        cs.Project_Mapping_Row_Count__c = 100;
        insert cs;
      
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
        
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        AH_Rally_SendAttachment.ref_attachment_content = 'https://rally1.rallydev.com/slm/webservice/1.43/AttachmentCOntent/8000236560.js';
         
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_Rally_DataPull_Test Account';
        insert a;
        
        // CREATE TEST CASE RECORD
		Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_Rally_DataPull_Test Case# 1';
        c.Priority = 'Medium';
        c.Status = 'Escalate to L3';
        c.Type = 'Approvals';
        c.Origin = 'Fax';
        c.Number_of_Requests__c = 1;
        c.L3_Ticket_Summary__c = 'abc';
        c.L3_Steps_To_Reproduce__c = 'abc';
        c.Product_Family__c = 'Reservation Solutions';
        c.Product__c = 'DataBridge';
        c.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js';
        insert c;

        // CREATE TEST CASE COMMENT RECORD
        CaseComment cc = NI_TestClassData.createTestCaseComment(1, c.Id);
        insert cc;

        // CREATE TEST ATTACHMENT ON CASE
       	Attachment att = NI_TestClassData.createTestAttachment(c.Id);
        att.Name = 'AH_Rally_SendAttachment_Test';
        att.ContentType = 'application/pdf';
        insert att;

        // CREATE TEST CASE ATTACHMENT RELATION RECORD
        Case_Attachment_Relation__c attach = new Case_Attachment_Relation__c();
        attach.case_id__c = c.Id;
        attach.To_be_Send__c = true;
        attach.Sf_Attachment_Id__c = att.Id;
        insert attach;
        
        // CREATE TEST CASE COMMENT RELATION RECORD
        Case_Comment_Relation__c comment = new Case_Comment_Relation__c();
        comment.case_id__c = c.Id;
        comment.To_be_Send__c = true;
        comment.Sf_Comment_Id__c = cc.Id;
        insert comment;

        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1:  testCallOut
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {  
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        AH_Rally_DataPull.callout('', c.Id);
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2:  testLRupdateSfofUserStory
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {      
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        AH_Rally_DataPull.LRupdateSfofUserStory('Owner', 'USproject', 'UserStoryId', 'RallyStatus', 'Release', c.Id, 'xyz', 'low');
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3:  testInsertComment
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {      
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        List<Decimal> decL = new List<Decimal>();
        List<String> bodyL = new List<String>();
        decL.add(1);
        List<Case_Comment_Relation__c> caseCommentL = [SELECT Id, Rally_discussion_Id__c, Case_Id__c FROM Case_Comment_Relation__c LIMIT 1];
        bodyL.add(caseCommentL[0].Rally_discussion_Id__c);
        AH_Rally_DataPull.insertComment(decL, c.Id, bodyL);
        Test.stopTest();
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4:  testInsertAttachment public static String insertAttachment(List<String> attId, List<String> attName, List<String> attContent, String CaseID)
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {
        
        Case c = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1']; 
       	Attachment att = [SELECT Id, Name, ContentType FROM Attachment WHERE ParentId =: c.Id]; 
            
        Test.startTest();       
        
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        c.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/277043483136.js'; 
        update c; 
        
        List<String> lstAttachIds = new List<String>(); 
        lstAttachIds.add(att.Id); 
        List<String> lstAttachNames = new List<String>(); 
        lstAttachNames.add(att.Name); 
        List<String> lstAttachTypes = new List<String>(); 
        lstAttachTypes.add(att.ContentType); 

        AH_Rally_DataPull.insertAttachment(lstAttachIds, lstAttachNames, lstAttachTypes, c.Id); 
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5:  testInsertCommentForException
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {  
        Case c = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();    
        c.Rally_Artifact_Ref__c = 'hierarchicalrequirement/attachmentcontent/US123456.js';
        update c;     
        List<Decimal> cmm = new List<Decimal>{1,2};
        List<String> cmb = new List<String>{'1','2'};     
        AH_Rally_DataPull.insertComment(cmm, c.Id, cmb);
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6:  testCalloutForException
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {      
        Case c = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();     
        c.Rally_Artifact_Ref__c = '{[1,2]}';
        update c; 
        AH_Rally_DataPull.callout('', c.Id);
        Test.stopTest();
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7:  testLRupdateSfofUserStoryOne
    // ======================================================================================================================================= 
    @isTest static void test7() 
    { 
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();        
        Case_Comment_Relation__c ccr = [SELECT Id FROM Case_Comment_Relation__c WHERE Case_Id__c =: c.Id];
        Delete ccr;        
        AH_Rally_DataPull.LRupdateSfofUserStory('', '', '', '', '', c.Id, '', '');
        Test.stopTest();
    }

// MOVE THIS TO NEW TEST CLASS FOR TESTING NEW VERSION OF: LROwnThiscase    
    // ======================================================================================================================================= 
    // = TEST METHOD #:  testLROwnThiscase
    // ======================================================================================================================================= 
    @isTest static void testLROwnThiscase() 
    {      
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
//        LROwnThiscase.getcases(caseRec.Id);
        Test.stopTest();
    }
            
    
    
/*    
 
MOVED THESE TEST METHODS TO: AH_Rally_DataPush_Test
 
    // ======================================================================================================================================= 
    // = TEST METHOD 4:  testLRResubmitIceBox
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {      
        Case c = [SELECT Id, UserStory_Rally_Status__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        c.UserStory_Rally_Status__c = 'Ice Box';
        update c;
//        String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertEquals('Resubmit to rally is only Allowed if Rally Status is "Need More Information", "Verified" OR "Closed"', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5:  testLRResubmitVerified
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {      
        Case c = [SELECT Id, UserStory_Rally_Status__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();        
        c.UserStory_Rally_Status__c = 'Verified';
        update c;
//        String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertEquals('X', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6:  testLRResubmitClosed
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {      
        Case c = [SELECT Id, UserStory_Rally_Status__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        c.UserStory_Rally_Status__c = 'Closed';
        update c;
//        String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertEquals('Y', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7:  testLRResubmitInProgress
    // ======================================================================================================================================= 
    @isTest static void test7() 
    {      
        Case c = [SELECT Id, UserStory_Rally_Status__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        c.UserStory_Rally_Status__c = 'In Progress';
        update c;
//        String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertEquals('Resubmit to rally is only Allowed if Rally Status is "Need More Information", "Verified" OR "Closed"', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 8:  testLRResubmitIceBoxNegative
    // ======================================================================================================================================= 
    @isTest static void test8() 
    {      
        Case c = [SELECT Id, UserStory_Rally_Status__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        c.UserStory_Rally_Status__c = 'Ice Box';
        update c;
        //String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertNotEquals('Y', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 9:  testLRResubmitNoUserStory
    // ======================================================================================================================================= 
    @isTest static void test9() 
    {      
        Case c = [SELECT Id, UserStory_Rally_Status__c, Rally_Artifact_Ref__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        c.UserStory_Rally_Status__c = 'In Progress';
        c.Rally_Artifact_Ref__c = null;
        update c;
//        String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertEquals('Please create user story first', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 10:  testLRResubmitNoUserStoryNegative
    // ======================================================================================================================================= 
    @isTest static void test10() 
    {  
        Case c = [SELECT Id, UserStory_Rally_Status__c, Rally_Artifact_Ref__c FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
        c.UserStory_Rally_Status__c = 'In Progress';
        c.Rally_Artifact_Ref__c = null;
        update c;
//        String strRet = LRReSubmitToRally.LRReSubmit(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmit(c.Id);
        Test.stopTest();
        system.debug('strRet ' + strRet);
        system.assertNotEquals('Refresh', strRet);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 11:  testLRReSubmitSendCallout
    // ======================================================================================================================================= 
    @isTest static void test11() 
    {      
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_DataPull_Test Case# 1'];
        Test.startTest();
//        String strRet = LRReSubmitToRally.LRReSubmiteSendCallout(caseRec.Id);
        String strRet = AH_Rally_DataPush.LRReSubmiteSendCallout(c.Id);
        Test.stopTest();
        system.assertEquals('Refresh', strRet);
    }
*/
}