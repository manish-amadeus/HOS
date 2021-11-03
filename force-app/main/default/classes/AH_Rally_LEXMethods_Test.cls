/****************************************************************************************
Name            : AH_Rally_LEXMethods
Author          : Sean Harris
Created Date    : 11/25/2020
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Class with @auraEnabled methods used by Lightning Components
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_LEXMethods_Test 
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
        a.Name = 'AH_Rally_LEXMethods_Test Account';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        // CREATE 2 TEST CASE RECORDS
        Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_LEXMethods_Test Case# 1';
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

        // CREATE TEST ATTACHMENT ON CASE
       	Attachment att = NI_TestClassData.createTestAttachment(cs1.Id);
        att.Name = 'AH_Rally_LEXMethods_Test';
        insert att;
        
        // CREATE TEST CASE ATTACHMENT RELATION RECORD
        Case_Attachment_Relation__c attach = new Case_Attachment_Relation__c();
        attach.case_id__c = cs1.Id;
        attach.To_be_Send__c = true;
        attach.Sf_Attachment_Id__c = att.Id;
        insert attach;
        
        CaseComment cc = NI_TestClassData.createTestCaseComment(1, cs1.Id);
        insert cc;
        
        // CREATE TEST CASE COMMENT RELATION RECORD
        Case_Comment_Relation__c comment = new Case_Comment_Relation__c();
        comment.case_Id__c = cs1.Id;
        comment.To_be_Send__c = true;
        comment.Sf_Comment_Id__c = cc.Id;
        insert comment;

        // CREATE TEST CONTENT VERSION RECORD
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Penguins';
        cv.PathOnClient = 'Penguins.jpg';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        insert cv;  
        
        List<ContentDocument> lstCDs = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);
        
        // CREATE TEST CONTENT DOCUMENT LINK RECORD
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = cs1.Id;
        cdl.ContentDocumentId = lstCDs[0].Id;
        cdl.shareType = 'V';
        insert cdl;         
        
        Test.stopTest();
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1:  
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_LEXMethods_Test Case# 1'];
		Attachment att = [SELECT Id, Body, ContentType, Description, Name, BodyLength FROM Attachment WHERE Name = 'AH_Rally_LEXMethods_Test'];        
		CaseComment cc = [SELECT Id FROM CaseComment WHERE ParentId =: c.Id];
        String strBody = EncodingUtil.base64Encode(att.Body);
        String strDefectId = AH_Rally_SendFiles.getDefectId('testArtifact');
        
        Test.startTest();                
        
        AH_Rally_Library.str = '{"Workspaces":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/5339961604.js","_refObjectName":"TestBed","_type":"Workspace"}],"Workspace":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/workspace/7622744606.js","_objectVersion":"13","_refObjectName":"Jira","CreationDate":"2012-08-23T21:17:43.829Z","_CreatedAt":"Aug 24, 2012","ObjectID":7622744606,"Subscription":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/subscription/5339961586.js","_refObjectName":"TravelClick","_type":"Subscription"},"Description":"","Name":"Jira","Notes":"","Owner":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/user/5402778943.js","_refObjectName":"Raj S","_type":"User"},"Environment":"Production","FixedInBuild":null,"FoundInBuild":null,"InProgressDate":null,"Iteration":null,"OpenedDate":null,"Package":null,"PlanEstimate":null,"Priority":"None","Recycled":false,"Release":null,"ReleaseNote":false,"Requirement":null,"Resolution":"None","SalesforceCaseID":null,"SalesforceCaseNumber":null,"ScheduleState":"Backlog","Severity":"None","State":"Submitted","SubmittedBy":null,"TargetBuild":null,"TargetDate":null,"TaskActualTotal":0.0,"TaskEstimateTotal":0.0,"TaskRemainingTotal":0.0,"TaskStatus":"NONE","VerifiedInBuild":null,"AffectedComponent":null,"AffectedCustomers":"","BEKanBanState":null,"BID":null,"BusinessDivision":null,"BusinessLocation":null,"BusinessLocationTest":"","BusinessName":null,"BusinessNameTest":"","CaseOwner":"Prateek Gupta","CaseOwnerEmail":null,"CustomerName":null,"CustomerURLtoSite":null,"iHotelierLicenseID":null,"iHotelierLicenseIDTest":"","JiraID":null,"JiraLink":null,"KanbanState":null,"Language":null,"NumberofCases":0,"Product":null,"ProductFamily":null,"ProductTest":"","RallyL3LinkedDefect":null,"ReadyDeprecated":null,"ReportingType":null,"ReportingTypeTest":"","Projects":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/8000236560.js","_refObjectName":"L3_Ihotelier","_type":"Project"},{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/9026848903.js","_refObjectName":"iHotelier Dev Team","_type":"Project"}],"Object":[{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/hierarchicalrequirement/7999255971.js","_objectVersion":"2","_refObjectName":"test for converting to a story","LastUpdateDate":"2012-09-25T03:03:16.804Z","Release":null,"Project":{"_rallyAPIMajor":"1","_rallyAPIMinor":"43","_ref":"https://rally1.rallydev.com/slm/webservice/1.43/project/7622744697.js","_refObjectName":"Reservations","_type":"Project"},"KanbanState":null,"_type":"HierarchicalRequirement"}]}}';
        
        JSONGenerator gen = JSON.createGenerator(true);   
        gen.writeStartObject();
        gen.writeFieldName('AttachmentContent');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');  
        gen.writeFieldName('Workspace');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');    
        gen.writeStringField('_ref', AH_Rally_Library.workspaceUrl()); 
        gen.writeStringField('_refObjectName', AH_Rally_Library.getWorkspaceName()); 
        gen.writeStringField('_type', 'Workspace'); 
        gen.writeEndObject(); 
        gen.writeStringField('Content', strBody);
        gen.writeStringField('_type', 'AttachmentContent');
        gen.writeEndObject();           
        gen.writeEndObject(); 
        String strJSON = gen.getAsString();             

        Map<String, sObject> mapTest1 = AH_Rally_LEXMethods.returnCaseRecs(c.Id);
        system.debug(' ::: mapTest1 = ' + mapTest1);
        
        List<String> lstTest1 = AH_Rally_LEXMethods.returnAttachments(c.Id);
        system.debug(' ::: lstTest1 = ' + lstTest1);
        List<String> lstTest2 = AH_Rally_LEXMethods.returnComments(c.Id);
        system.debug(' ::: lstTest1 = ' + lstTest1);
        
        String strTest1 = AH_Rally_LEXMethods.returnWorkspaceURL();
        system.debug(' ::: strTest1 = ' + strTest1);
        String strTest2 = AH_Rally_LEXMethods.resultofUserStory(c.Id);
        system.debug(' ::: strTest2 = ' + strTest2);
        String strTest3 = AH_Rally_LEXMethods.callout('GET', 'https://rally1.rallydev.com/slm/webservice/1.43/attachmentcontent/create.js', strJSON);
        system.debug(' ::: strTest3 = ' + strTest3);
        String strTest4 = AH_Rally_LEXMethods.sendAttachmentMethod(att.Id);
        system.debug(' ::: strTest4 = ' + strTest4);
        
        AH_Rally_LEXMethods.updateComments(c.Id, strDefectId, '1234567890', cc.Id);
        AH_Rally_LEXMethods.callUpdateIntoCARBasedOnOperation(strDefectId, '', '1234567890', att.Id);
        AH_Rally_LEXMethods.makeUserLREFalse();
        
//        public static String getContentDocs(Id recId)
//        public static void deleteFiles(Id recId)
//        public static String sendAttachment(Id recId, Id caseId)

        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: getContentDocsTest
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {          
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_LEXMethods_Test Case# 1'];
        String res = AH_Rally_LEXMethods.getContentDocs(c.Id);        
        System.assertNotEquals(null, res);  
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: deleteFilesTest
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {    
        List<ContentDocument> lstCDs = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);
        AH_Rally_LEXMethods.deleteFiles(lstCDs[0].Id); 
        Integer cd = [SELECT COUNT() FROM ContentDocument WHERE Id =: lstCDs[0].Id];
        System.assertEquals(0, cd);
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: sendAttachmentTest
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {    
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_LEXMethods_Test Case# 1'];
        List<ContentDocument> lstCDs = new List<ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument]);
        AH_Rally_LEXMethods.sendAttachment(lstCDs[0].Id, c.Id);      
        Integer rrs = [SELECT COUNT() FROM AH_Rally_Setup__c WHERE Username__c = 'travelclick'];
        System.assertEquals(1, rrs);
    }    
    
    
}