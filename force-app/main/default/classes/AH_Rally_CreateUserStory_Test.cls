/****************************************************************************************
Name            : AH_Rally_CreateUserStory_Test (TC Org Name: CreateUserStoryInRallyTestClass) 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_CreateUserStory
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_CreateUserStory_Test 
{
    
    static List<String> caseFieldsCs = new List<String>{'Subject','Status','Priority','Customer_Severity__c','Competitor_1_BID__c','Competitor_2_BID__c',
        'Competitor_3_BID__c','Competitor_4_BID__c','Competitor_5_BID__c','Demand_Property_ID__c','Demand_Property_ID_1__c','Demand_Property_ID_2__c',
        'Demand_Property_ID_3__c','Demand_Property_ID_4__c','Demand_Property_ID_5__c','Property_Mapping__c','Property_Mapping_1__c','Property_Mapping_2__c',
        'Property_Mapping_3__c','Management_Company__c', 'Property_Mapping_4__c','Property_Mapping_5__c', 'Competitor_1__r.Name', 'Competitor_2__r.Name', 'Competitor_3__r.Name', 'Competitor_4__r.Name', 'Competitor_5__r.Name'};
                
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
        
        Test.startTest();
        
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_Rally_CreateUserStory_Test Account';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        // CREATE 2 TEST CASE RECORDS
		Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_CreateUserStory_Test Case #1';
        cs1.User_Story_Id__c = 'US90582';
        cs1.Priority = 'Medium';
        cs1.Status = 'Escalate to L3';
        cs1.Type = 'Approvals';
        cs1.Origin = 'Fax';
        cs1.Number_of_Requests__c = 1;
        cs1.L3_Ticket_Summary__c = 'abc';
        cs1.L3_Steps_To_Reproduce__c = 'abc';
        cs1.Product_Family__c = 'Reservation Solutions';
        cs1.Case_Product_Line__c = 'iHotelier CRS'; 
        cs1.UserStory_Rally_Status__c = 'In Progress';
        cs1.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js';
        cs1.Affected_Component__c = '';
        insert cs1;
        
		Case cs2 = NI_TestClassData.createTestCase(1, a.Id);
        cs2.Subject = 'AH_Rally_CreateUserStory_Test Case #2';
        cs2.User_Story_Id__c = 'US90583';
        cs2.Priority = 'Medium';
        cs2.Status = 'Escalate to L3';
        cs2.Type = 'Approvals';
        cs2.Origin = 'Fax';
        cs2.Number_of_Requests__c = 1;
        cs2.L3_Ticket_Summary__c = 'abc';
        cs2.L3_Steps_To_Reproduce__c = 'abc';
        cs2.Product_Family__c = 'Reservation Solutions';
        cs2.Case_Product_Line__c = 'iHotelier CRS';
        cs2.UserStory_Rally_Status__c = 'In Progress';
        cs2.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js';
		insert cs2;

        // CREATE 2 TEST CASE ATTACHMENT RELATION RECORD
        Case_Attachment_Relation__c attach = new Case_Attachment_Relation__c();
        attach.case_id__c = cs1.Id;
        attach.To_be_Send__c = true;
        attach.Sf_Attachment_Id__c = '123456789123456789';
        insert attach;
        
        // CREATE 2 TEST CASE COMMENT RELATION RECORD
        Case_Comment_Relation__c comment = new Case_Comment_Relation__c();
        comment.case_Id__c = cs1.Id;
        comment.To_be_Send__c = true;
        comment.Sf_Comment_Id__c = '123456789123456789';
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
    // = TEST METHOD 1: testUserStory
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Case ca = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #1'];
        case ca1 = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #2'];
        string cdata = ca.Id;
        string cid = cdata.left(15);
        string cdata1 = ca.Id;
        string cid1 = cdata.left(15);    
        
        Test.startTest();
        
        AH_Rally_Library.updateValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', ca.Id, caseFieldsCs);
        AH_Rally_Library.str ='{"Workspaces":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","TotalResultCount":"202","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":{"LinkID":"'+ca.id+'"},"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Results":[{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js", "_objectVersion": "81", "_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)", "FormattedID": "US90582", "DirectChildrenCount": 0, "LastUpdateDate": "2017-07-04T12:01:51.932Z", "Owner": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/user/58964592672.js", "_objectVersion": "589", "_refObjectName": "Arpit (L3)", "_type": "User"}, "Release": null, "Project": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js", "_refObjectName": "L3 Booking Engine 4.0", "_type": "Project"}, "L3KanbanStage": "Advance Investigation", "RetentionRisk": null, "SalesforceCase": {"LinkID": "'+cid+'", "DisplayString": "04410226"}, "SalesforcePriority": "High", "TargetCompletionDate": "2017-07-04T12:01:51.932Z", "_type": "HierarchicalRequirement"},{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/106200572164.js", "_objectVersion": "81", "_refObjectName": "Booking Engine 4.0. - Email Engine Tags (variable)", "FormattedID": "US90583", "DirectChildrenCount": 0, "LastUpdateDate": "2017-07-04T12:01:51.932Z", "Owner": null, "Release": null, "Project": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/project/55984441715.js", "_refObjectName": "L3 Booking Engine 4.0", "_type": "Project"}, "L3KanbanStage": null, "RetentionRisk": null, "SalesforceCase": {"LinkID": "'+cid1+'", "DisplayString": "04410226"}, "SalesforcePriority": null, "TargetCompletionDate": null, "_type": "HierarchicalRequirement"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js","_objectVersion":"7","_refObjectName":"Testing of batch_sf7","LastUpdateDate":"2013-11-08T06:41:42.749Z","Priority":"Critical","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/14311297540.js","_refObjectName":"L3_OTA","_type":"Project"},"Severity":"Crash/Data Loss","KanbanState":"Need More Information","_type":"Defect"}]}}';
                
        AH_Rally_CreateUserStory.createUserStory(ca.Id);
        ProductMapping__c pro1 = [SELECT Id, Name FROM ProductMapping__c WHERE Name = 'Mapping0'];
        pro1.Product__c = 'test';
        pro1.Affected_Component__c = 'Test';
        pro1.Project__c = '';
        update pro1;
       
        AH_Rally_CreateUserStory.proName = null;
        AH_Rally_CreateUserStory.createUserStory(ca.Id);
        AH_Rally_UserStoryDetails usd = new AH_Rally_UserStoryDetails();
        
// DO WE NEED?       
// CaseProductWithProject cpp = new CaseProductWithProject(c, 'abc', 'abc');
        
        Test.stopTest();
        
    }
   
    // ======================================================================================================================================= 
    // = TEST METHOD 2: Insertindatabase
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {      
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #1'];
        
        Test.startTest();
        
        AH_Rally_InsertIntoDB.updateSfofUserStory('Owner', 'USproject', 'UserStoryId', 'RallyStatus', 'Release', c.Id, 'xyz', 'low');
        AH_Rally_InsertIntoDB.insertIntoCAR('12345678', c.Id, '123456789123456789', '123456789123456789');
        AH_Rally_InsertIntoDB.UpdateIntoCARBasedOnOperation('12345678', c.Id, '123456789123456789', '123456789123456789');
        AH_Rally_InsertIntoDB.UpdateIntoCommentObject('12345678', c.Id, '123456789123456789', '123456789123456789');
        AH_Rally_InsertIntoDB.insertDataInCaseComment(c.Id, '12345678', '123456789123456789', '123456789123456789');
        
        Test.stopTest();
        
    }

// DO WE NEED?    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: proMapping
    // ======================================================================================================================================= 
//    @isTest static void test3() 
//    {           
//        ProductMapping obj = new ProductMapping();
//        obj.cancelMapping();
//        obj.getItems();
//        obj.saveMapping();
//    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: callException
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {               
        AH_Rally_Exception my = new AH_Rally_Exception();
        my.getCustomMessage();
    }
    
    // ====================================================================================================================================== 
    // = TEST METHOD 5: TestSendAttachmentByApex
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #1'];
        
        Test.startTest();
        
        Attachment attachTest = new Attachment();
        attachTest.Parentid = c.Id;
        attachTest.Body = Blob.valueOf('hello Test');
        attachTest.name = 'Testing';
        attachTest.ContentType = 'text';
        insert attachTest;
        
        AH_Rally_SendAttachment.sendAttachment(attachTest.Id, c.Id);
        AH_Rally_SendAttachment.valuesofAttachment(attachTest.Id);
    
        Test.stopTest();
        
    }
    
    // ====================================================================================================================================== 
    // = TEST METHOD 6: TestCaseCommentofSalesforce
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {      
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #1'];
        
        Test.startTest();
                
        CaseComment com = new CaseComment();
        com.Parentid = c.id;
        com.CommentBody = 'Testing case comment';
        insert com;
        
// DO WE NEED?
// CaseCommentofSalesforce.insertCaseComment(c.id, com.id);

        Test.stopTest();
                
    }
    
    // ====================================================================================================================================== 
    // = TEST METHOD 7: TestCaseofTrigger
    // ======================================================================================================================================= 
    @isTest static void test7() 
    {     
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #1'];
        
        Test.startTest();
               
        c.Priority = 'Blocker';
        update c;

        Test.stopTest();
             
    }
    
    // ====================================================================================================================================== 
    // = TEST METHOD 8: TestCloseUserStory
    // ======================================================================================================================================= 
    @isTest static void test8() 
    { 
        
        Case c = [SELECT Id, ContactId, Status, Push_Back__c, Has_No_DI__c FROM Case WHERE Subject = 'AH_Rally_CreateUserStory_Test Case #1'];
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER'];        
        
        Test.startTest();

        c.ContactId = cnt.Id;
        c.Status = 'Closed';
        c.Push_Back__c = 'No';
        c.Has_No_DI__c = true;
        update c;

        Test.stopTest();
                   
    }

}