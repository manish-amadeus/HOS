/****************************************************************************************
Name            : AH_Rally_SendFiles_Test (TC Org Name: LRSendFilesByApexTest)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Test class for AH_Rally_SendFiles
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_SendFiles_Test 
{

    
/*    
    public Static List<ContentDocument> documents;
    public Static Case  cas;
    public Static AH_Rally_Setup__c obj;
    
    static { 
        
        AH_Rally_SendFiles.type = '268599044344.js';
        AH_Rally_Library.str ='{"Subscription": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js", "_objectVersion": "557", "_refObjectName": "TravelClick", "CreationDate": "2012-02-01T16:44:39.467Z", "_CreatedAt": "Feb 1, 2012", "ObjectID": 5339961586, "ExpirationDate": null, "MaximumCustomUserFields": -1, "MaximumProjects": -1, "Modules": "Integration Hub,Rally Portfolio Manager,HP Integration,IBM Integration,Rally Idea Manager,Rally Quality Manager,Rally Support Manager,Rally Time Tracker,SSO,IP Restriction,Extension Whitelist", "Name": "TravelClick", "PasswordExpirationDays": 0, "PreviousPasswordCount": 0, "ProjectHierarchyEnabled": true, "RevisionHistory": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/revisionhistory/5339961587.js", "_type": "RevisionHistory"}, "SessionTimeoutSeconds": 36000, "SSOUserExceptions": [], "StoryHierarchyEnabled": true, "StoryHierarchyType": "Unlimited", "SubscriptionID": 7347, "SubscriptionType": "Unlimited", "Workspaces": [{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js", "_refObjectName": "TestBed", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/5556735000.js", "_refObjectName": "Closed Project", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/6692415259.js", "_refObjectName": "Travelclick", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js", "_refObjectName": "Jira", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/12709885227.js", "_refObjectName": "Configuration Management", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/31804861528.js", "_refObjectName": "Web Solutions", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/15955469984.js", "_refObjectName": "GV360 Migration Test Workspace", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/264050980080.js", "_refObjectName": "2018 RESERVATIONS COMPLETED PROJECTS", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/58440811269.js", "_refObjectName": "GMS", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/58440452450.js", "_refObjectName": "GMS", "_type": "Workspace"}], "ZuulID": "c59e29ac8be349698cbf82868361e346", "Errors": [], "Warnings": ["Please update your client to use the latest version of the API. You can find the latest version at https://rally1.rallydev.com/slm/doc/webservice/index.jsp?version=v2.0. No new projects should use this version of the API as it will be removed in the future."]}}';
        Datetime myDT = Datetime.now();
        Datetime dt = myDT.addDays(-30);
        obj = new AH_Rally_Setup__c(username__c = 'test', password__c='123',workspace__c='TestBed',rallyUrl__c = 'https://rally1.rallydev.com', API_Version__c = 1.43,Schedular_Last_Run__c=dt, Exception_Notification_Email__c = 'yogeshmat@cybage.com');
        insert obj; 
    }
    
    static testMethod void getDefectIdTest() 
    { 
        String testArtifact = AH_Rally_SendFiles.getDefectId('testArtifact');
    }
    
    static testMethod void setValuesOfFilesTest() 
    {   
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        
        insert contentVersion;    
        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('*************' + documents);
        AH_Rally_SendFiles.setValuesOfFiles(documents[0].Id);
        AH_Rally_SendFiles.valuesofAttachmentFiles(documents[0].Id);
        
        cas = new Case(Status ='New', Priority = 'Medium', Origin = 'Email');
        insert cas;
        AH_Rally_SendFiles.sendAttachmentFiles(documents[0].Id,cas.Id);
        
        AH_Rally_SendFiles.insertIntoFileCAR(AH_Rally_SendFiles.getDefectId('268599044344.js'),cas.Id,documents[0].Id,documents[0].Id);
        
    }
*/

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
        a.Name = 'AH_Rally_SendFiles_Test Account';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        // CREATE 2 TEST CASE RECORDS
		Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_SendFiles_Test Case# 1';
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
        sol.SolutionName = 'AH_Rally_SendFiles_Test Solution';
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
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_SendFiles_Test Case# 1'];

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
            Description = 'Cute little Penguins'
        );
        insert contentVersion;  
        
        List<ContentDocument> lstContentDocuments = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);

        AH_Rally_SendFiles.type = '268599044344.js';
        AH_Rally_Library.str ='{"Subscription": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js", "_objectVersion": "557", "_refObjectName": "TravelClick", "CreationDate": "2012-02-01T16:44:39.467Z", "_CreatedAt": "Feb 1, 2012", "ObjectID": 5339961586, "ExpirationDate": null, "MaximumCustomUserFields": -1, "MaximumProjects": -1, "Modules": "Integration Hub,Rally Portfolio Manager,HP Integration,IBM Integration,Rally Idea Manager,Rally Quality Manager,Rally Support Manager,Rally Time Tracker,SSO,IP Restriction,Extension Whitelist", "Name": "TravelClick", "PasswordExpirationDays": 0, "PreviousPasswordCount": 0, "ProjectHierarchyEnabled": true, "RevisionHistory": {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/revisionhistory/5339961587.js", "_type": "RevisionHistory"}, "SessionTimeoutSeconds": 36000, "SSOUserExceptions": [], "StoryHierarchyEnabled": true, "StoryHierarchyType": "Unlimited", "SubscriptionID": 7347, "SubscriptionType": "Unlimited", "Workspaces": [{"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js", "_refObjectName": "TestBed", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/5556735000.js", "_refObjectName": "Closed Project", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/6692415259.js", "_refObjectName": "Travelclick", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js", "_refObjectName": "Jira", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/12709885227.js", "_refObjectName": "Configuration Management", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/31804861528.js", "_refObjectName": "Web Solutions", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/15955469984.js", "_refObjectName": "GV360 Migration Test Workspace", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/264050980080.js", "_refObjectName": "2018 RESERVATIONS COMPLETED PROJECTS", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/58440811269.js", "_refObjectName": "GMS", "_type": "Workspace"}, {"_rallyAPIMajor": "1", "_rallyAPIMinor": "43", "_ref": "https://rally1.rallydev.com/slm/webservice/1.43/workspace/58440452450.js", "_refObjectName": "GMS", "_type": "Workspace"}], "ZuulID": "c59e29ac8be349698cbf82868361e346", "Errors": [], "Warnings": ["Please update your client to use the latest version of the API. You can find the latest version at https://rally1.rallydev.com/slm/doc/webservice/index.jsp?version=v2.0. No new projects should use this version of the API as it will be removed in the future."]}}';

        Test.startTest();

        String testArtifact = AH_Rally_SendFiles.getDefectId('testArtifact');
        AH_Rally_SendFiles.setValuesOfFiles(lstContentDocuments[0].Id);
        AH_Rally_SendFiles.valuesofAttachmentFiles(lstContentDocuments[0].Id);
        AH_Rally_SendFiles.sendAttachmentFiles(lstContentDocuments[0].Id, c.Id);
        AH_Rally_SendFiles.insertIntoFileCAR(AH_Rally_SendFiles.getDefectId('268599044344.js'), c.Id, lstContentDocuments[0].Id, lstContentDocuments[0].Id);

        Test.stopTest();

    }




    
}