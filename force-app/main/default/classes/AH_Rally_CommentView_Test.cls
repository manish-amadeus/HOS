/****************************************************************************************
Name            : AH_Rally_CommentView_Test
Author          : Sean Harris
Created Date    : 11/25/2020
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_CommentView
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_CommentView_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        // CREATE WIN@PROACH CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        // CREATE TEST PRODUCT PROJECT (CUSTOM SETTING) RECORD
        ProductMapping__c pro = new ProductMapping__c();
        pro.Name = 'Mapping0';
        pro.Product_Family__c = 'Reservation Solutions';
        pro.Affected_Component__c = '';
        pro.Product__c = 'iHotelier CRS'; //'DataBridge';
        pro.Project__c = 'L3 PMSConnect';
        insert pro;
    
        COLA_Settings__c cs =  new COLA_Settings__c();
        cs.Name = 'STOMAutomation';
        cs.Allow_Product_Creation__c = true;
        cs.Project_Mapping_Row_Count__c = 100;
        insert cs; 
        
        Test.startTest();
        
        // CREATE TEST RALLY SETUP RECORD
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
        a.Name = 'AH_Rally_CommentView_Test Account';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        // CREATE 2 TEST CASE RECORDS
		Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_CommentView_Test Case# 1';
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
        cs1.Module__c = '';
        insert cs1;

		CaseComment cc = NI_TestClassData.createTestCaseComment(1, cs1.Id);
        insert cc;

        // CREATE TEST CASE COMMENT RELATION RECORD
        Case_Comment_Relation__c comment = new Case_Comment_Relation__c();
        comment.case_Id__c = cs1.Id;
        comment.To_be_Send__c = true;
        comment.Sf_Comment_Id__c = cc.Id;
        insert comment;

        // CREATE TEST DI INDEX RECORD  
        NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'APEX TEST');
        insert diIdx;
        
        // CREATE TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

		// CREATE TEST PRODUCT RECORD          
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        prd.DI_Index__c = diIdx.Id;
        insert prd;

        // CREATE TEST DI RECORD  
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd.Id); 
        di.Product_Group__c = pgp.Id; 
        insert di;

        // CREATE TEST SOLUTION RECORD  
        Solution sol = NI_TestClassData.createSolution(1); 
        sol.SolutionName = 'AH_Rally_CreateUserStory_Test Solution';
        insert sol;

        // ADD A SOLUTION TO CASE
        CaseSolution csSol = NI_TestClassData.createCaseSolution(cs1.Id, sol.Id);
        insert csSol;

        Solution_Count__c sc = new Solution_Count__c();
        sc.Case__c = cs1.Id;
        sc.Number_of_Solutions__c = 1;
        insert sc;           
 
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1:  
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CommentView_Test Case# 1'];
        
        // BUILD MOCK JSON RESPONSE AND PARSE
        AH_Rally_Library.str ='{"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","TotalResultCount":"202","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":{"LinkID":" '+c.id+'"},"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Results":[{"ObjectID": "7622744606","Text": "::","_rallyAPIMajor": "1","_rallyAPIMinor": "43","_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js","_objectVersion": "81","_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)","FormattedID": "US90582","DirectChildrenCount": 0,"LastUpdateDate": "2017-07-04T12:01:51.932Z","Owner": {"_rallyAPIMajor": "1","_rallyAPIMinor": "43","_ref": "https://rally1.rallydev.com/slm/webservice/1.43/user/58964592672.js","_objectVersion": "589","_refObjectName": "Arpit (L3)","_type": "User"},"Release": null,"Project": {"_rallyAPIMajor": "1","_rallyAPIMinor": "43","_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js","_refObjectName": "L3 Booking Engine 4.0","_type": "Project"},"L3KanbanStage": "Advance Investigation","RetentionRisk": null,"SalesforceCase": {"LinkID": "'+c.id+'","DisplayString": "04410226"},"SalesforcePriority": "High","TargetCompletionDate": "2017-07-04T12:01:51.932Z","_type": "HierarchicalRequirement"},{"_rallyAPIMajor": "1","_rallyAPIMinor": "43","_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js","_objectVersion": "81","_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)","FormattedID": "US90583","DirectChildrenCount": 0,"LastUpdateDate": "2017-07-04T12:01:51.932Z","Owner": null,"Release": null,"Project": {"_rallyAPIMajor": "1","_rallyAPIMinor": "43","_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js","_refObjectName": "L3 Booking Engine 4.0","_type": "Project"},"L3KanbanStage": null,"RetentionRisk": null,"SalesforceCase": {"LinkID": "'+c.id+'","DisplayString": "04410226"},"SalesforcePriority": null,"TargetCompletionDate": null,"_type": "HierarchicalRequirement"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js","_objectVersion":"7","_refObjectName":"Testing of batch_sf7","LastUpdateDate":"2013-11-08T06:41:42.749Z","Priority":"Critical","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/14311297540.js","_refObjectName":"L3_OTA","_type":"Project"},"Severity":"Crash/Data Loss","KanbanState":"Need More Information","_type":"Defect"}]}}';
        AH_Rally_CommentView ctrl = new AH_Rally_CommentView(); 
        
        Test.startTest();
        
        AH_Rally_CommentView.init(c.Id, '7622744606', UserInfo.getName()); 

        Map<String, String> mapTest = ctrl.getMap();
        system.debug(' ::: mapTest = ' + mapTest);   
        
        AH_Rally_CommentView.commenthistory = mapTest;
        
        AH_Rally_CommentView.commenthistory.clear();
        mapTest = ctrl.getMap();
        
        
        Test.stopTest();  
 
    }
    
}