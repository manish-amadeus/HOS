/****************************************************************************************
Name            : AH_Rally_Library_Test (TC Org Name: RallyLibraryTest)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test Class for AH_Rally_Library
				: 
******************************************************************************************/
@isTest
public class AH_Rally_Library_Test 
{

    static List<String> caseFieldsCs = new List<String>{'Subject','Status','Priority','Customer_Severity__c','Competitor_1_BID__c','Competitor_2_BID__c',
        'Competitor_3_BID__c','Competitor_4_BID__c','Competitor_5_BID__c','Demand_Property_ID__c','Demand_Property_ID_1__c','Demand_Property_ID_2__c',
        'Demand_Property_ID_3__c','Demand_Property_ID_4__c','Demand_Property_ID_5__c','Property_Mapping__c','Property_Mapping_1__c','Property_Mapping_2__c',
        'Property_Mapping_3__c','Management_Company__c', 'Property_Mapping_4__c','Property_Mapping_5__c', 'Competitor_1__r.Name', 'Competitor_2__r.Name', 'Competitor_3__r.Name', 'Competitor_4__r.Name', 'Competitor_5__r.Name'};
                
	static List<String> caseFields = new List<String>{'Subject','Status','Priority','Customer_Severity__c','Competitor_1_BID__c','Competitor_2_BID__c',
		'Competitor_3_BID__c','Competitor_4_BID__c','Competitor_5_BID__c','Demand_Property_ID__c','Demand_Property_ID_1__c','Demand_Property_ID_2__c',
        'Demand_Property_ID_3__c','Demand_Property_ID_4__c','Demand_Property_ID_5__c','Property_Mapping__c','Property_Mapping_1__c','Property_Mapping_2__c',
        'Property_Mapping_3__c','Property_Mapping_4__c','Property_Mapping_5__c'};    
    
    
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
        a.Name = 'AH_Rally_Library_Test Account';
        insert a;
        
        // CREATE TEST CASE RECORD
		Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_Rally_Library_Test Case';
	
		c.Competitor_1_BID__c = 'Competitor 1 BID';    
		c.Competitor_2_BID__c = 'Competitor 2 BID';
		c.Competitor_3_BID__c = 'Competitor 3 BID';    
		c.Competitor_4_BID__c = 'Competitor 4 BID';    
		c.Competitor_5_BID__c = 'Competitor 5 BID';
		c.Demand_Property_ID__c = 'Demand Property 1';     
		c.Demand_Property_ID_1__c = 'Demand Property Id 1';  
		c.Demand_Property_ID_2__c = 'Demand Property Id 2';
		c.Demand_Property_ID_3__c = 'Demand Property Id 3';  
		c.Demand_Property_ID_4__c = 'Demand Property Id 4';  
		c.Demand_Property_ID_5__c = 'Demand Property Id 5';
		c.Property_Mapping__c = 'Property Mapping';    
        c.Property_Mapping_1__c = 'Property Mapping 1';    
        c.Property_Mapping_2__c = 'Property Mapping 2';
        c.Property_Mapping_3__c = 'Property Mapping 3';    
        c.Property_Mapping_4__c = 'Property Mapping 4';    
        c.Property_Mapping_5__c = 'Property Mapping 5';
        c.Competitor_1__c = a.Id;
        c.Competitor_2__c = a.Id;
        c.Competitor_3__c = a.Id;
        c.Competitor_4__c = a.Id;
        c.Competitor_5__c = a.Id;
        
        c.Rally_Artifact_Ref__c = '12345678';
        
        insert c;

        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: testUpdateValuesInRally
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_Library_Test Case'];
        
        Test.startTest();

        AH_Rally_Library.updateValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', c.Id, caseFieldsCs);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: testUpdateValuesInRallyDuplicate
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {
        
        Case c = [SELECT Id, Status FROM Case WHERE Subject = 'AH_Rally_Library_Test Case'];
        
        Test.startTest();

        c.Status = 'Duplicate';
        update c;
        
        AH_Rally_Library.updateValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', c.Id, caseFieldsCs);
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3: testUpdateValuesInRallySPAM
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {
        
        Case c = [SELECT Id, Status FROM Case WHERE Subject = 'AH_Rally_Library_Test Case'];
        
        Test.startTest();

        c.Status = 'SPAM';
        update c;
        
        AH_Rally_Library.updateValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', c.Id, caseFieldsCs);
        
        Test.stopTest();
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: testUpdateValuesInRallyPrdMappingnew
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'AH_Rally_Library_Test Account'];

        // CREATE NEW TEST CASE RECORD
		Case c2 = NI_TestClassData.createTestCase(1, a.Id);
      
        c2.Competitor_1_BID__c = 'Competitor 1 BID';
        c2.Competitor_2_BID__c = 'Competitor 2 BID';        
        c2.Competitor_3_BID__c = 'Competitor 3 BID';
        c2.Competitor_4_BID__c = 'Competitor 4 BID';
        c2.Competitor_5_BID__c = 'Competitor 5 BID';
        c2.Demand_Property_ID__c = 'Demand Property 1';
        c2.Demand_Property_ID_1__c = 'Demand Property Id 1';
        c2.Demand_Property_ID_2__c = 'Demand Property Id 2';        
        c2.Demand_Property_ID_3__c = 'Demand Property Id 3';
        c2.Demand_Property_ID_4__c = 'Demand Property Id 4';
        c2.Demand_Property_ID_5__c = 'Demand Property Id 5';
        c2.Property_Mapping__c = 'Property Mapping';
        c2.Property_Mapping_1__c = 'Property Mapping 1';
        c2.Property_Mapping_2__c = 'Property Mapping 2';        
        c2.Property_Mapping_3__c = 'Property Mapping 3';
        c2.Property_Mapping_4__c = 'Property Mapping 4';
        c2.Property_Mapping_5__c = 'Property Mapping 5';
        insert c2;
        
        Test.startTest();

        AH_Rally_Library.updateValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', c2.Id, caseFieldsCs);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: testUpdateValuesInRallyNullValues
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {
        
        Case c = [SELECT Id, Status FROM Case WHERE Subject = 'AH_Rally_Library_Test Case'];
        
        Test.startTest();

        c.Competitor_1_BID__c = null;
        c.Competitor_2_BID__c = null;
        c.Competitor_3_BID__c = null;
        c.Competitor_4_BID__c = null;
        c.Competitor_5_BID__c = null;
        c.Demand_Property_ID__c = null;
        c.Demand_Property_ID_1__c = null;
        c.Demand_Property_ID_2__c = null;
        c.Demand_Property_ID_3__c = null;
        c.Demand_Property_ID_4__c = null;
        c.Demand_Property_ID_5__c = null;
        c.Property_Mapping__c = null;
        c.Property_Mapping_1__c = null;
        c.Property_Mapping_2__c = null;
        c.Property_Mapping_3__c = null;
        c.Property_Mapping_4__c = null;
        c.Property_Mapping_5__c = null;
        c.Competitor_1__c = null;
        c.Competitor_2__c = null;
        c.Competitor_3__c = null;
        c.Competitor_4__c = null;
        c.Competitor_5__c = null;
        update c;
        
        AH_Rally_Library.updateValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', c.Id, caseFieldsCs);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 6: testUpdateAccountValuesInRally
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {
        
        Case c = [SELECT Id, Status FROM Case WHERE Subject = 'AH_Rally_Library_Test Case'];
        
        Test.startTest();

        AH_Rally_Library.updateAccountValuesInRally('https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/15398734225.js', c.Id, caseFields);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 7: testWorkspaceUrl
    // ======================================================================================================================================= 
    @isTest static void test7() 
    {
        Test.startTest();
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        AH_Rally_Library.projectList();
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 8: testGetMapping
    // ======================================================================================================================================= 
    @isTest static void test8() 
    {
        Test.startTest();
        AH_Rally_Library.getMapping();
        Test.stopTest();
    }
    
 	// ======================================================================================================================================= 
    // = TEST METHOD 9:  test insertCaseComment
    // ======================================================================================================================================= 
    @isTest static void test9()
    {
        
        Case c = [SELECT Id, Status FROM Case WHERE Subject = 'AH_Rally_Library_Test Case'];
        CaseComment com = NI_TestClassData.createTestCaseComment(1, c.Id);
        com.CommentBody = 'Testing case comment';
        insert com;
        
        Test.startTest();
        
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        AH_Rally_Library.insertCaseComment(c.Id, com.Id);
        
        Test.stopTest();
        
    }
   
}