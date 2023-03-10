/****************************************************************************************
Name            : AH_Rally_InsertIntoDB_Test 
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_InsertIntoDB
				: 
				: 
******************************************************************************************/
@isTest
public class AH_Rally_InsertIntoDB_Test 
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
        a.Name = 'AH_Rally_InsertIntoDB_Test Account';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        // CREATE TEST CASE RECORD
		Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_Rally_InsertIntoDB_Test Case# 1';
        c.User_Story_Id__c = 'US90582';
        c.Priority = '	4 - Low';
        c.Status = 'Escalate to L3';
        c.Type = 'Approvals';
        c.Origin = 'Fax';
        c.Number_of_Requests__c = 1;
        c.L3_Ticket_Summary__c = 'abc';
        c.L3_Steps_To_Reproduce__c = 'abc';
        c.Product_Family__c = 'Reservation Solutions';
        c.Product__c = 'iHotelier CRS';
        c.UserStory_Rally_Status__c = 'In Progress';
        c.Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/defect/14961076175.js';
        c.Module__c = '';
        insert c;
        
        // CREATE TEST CASE COMMENT RECORD
        CaseComment cc = NI_TestClassData.createTestCaseComment(1, c.Id);
        cc.CommentBody = 'AH_Rally_InsertIntoDB_Test CaseComment# 1'; 
        insert cc;
        
        // CREATE TEST ATTACHMENT RECORD
        Attachment attch = NI_TestClassData.createTestAttachment(c.Id);
        attch.Name = 'AH_Rally_InsertIntoDB_Test Attachment# 1';    
        insert attch;
        
        
/*
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
*/ 
        Test.stopTest();
  
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST AH_Rally_InsertIntoDB.getDefectId(String artifact)
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_InsertIntoDB_Test Case# 1'];
        String strCaseId = String.valueOf(c.Id);
        
        Test.startTest();
        
        // CALL METHOD
        String strArtifact = '';
		String strDefectId = AH_Rally_InsertIntoDB.getDefectId(strArtifact);
        
        // DO ASSERTIONS
        system.debug(' ::: AH_Rally_InsertIntoDB_Test.test1.strDefectId = ' + strDefectId);

        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: TEST AH_Rally_InsertIntoDB.UpdateSalesforceStatus(String RallyStatus, String CaseId)
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_InsertIntoDB_Test Case# 1'];

        Test.startTest();
        
        // CALL METHOD
        AH_Rally_InsertIntoDB.UpdateSalesforceStatus('ApexTest', c.Id);
        // DO ASSERTIONS
        List<Case> lstAssert = new List<Case>([SELECT Id, UserStory_Rally_Status__c FROM Case WHERE Id =: c.Id]);
        system.assertEquals(1, lstAssert.size());
        system.assertEquals('ApexTest', lstAssert[0].UserStory_Rally_Status__c);

        Test.stopTest();
        
    }     

    // ======================================================================================================================================= 
    // = TEST METHOD 3: TEST AH_Rally_InsertIntoDB.updateSfofUserStory(String Owner, String USproject, String UserStoryId, String RallyStatus, String Release, String CaseId, string MasterTicket, string SalesforcePriority)
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_InsertIntoDB_Test Case# 1'];
        String strCaseId = String.valueOf(c.Id);
        String strOwner = String.valueOf(UserInfo.getUserId());
        String strUSproject = 'ApexTestProject';
        String strUserStoryId = '1234567890ABCDE';
        String strRallyStatus = 'ApexTestStatus';
        String strRelease = 'ApexTestRelease';
        String strMasterTicket = 'ApexMasterTicket';
        String strSalesforcePriority = '3 - Medium';        
		
        Test.startTest();

        // CALL METHOD
        AH_Rally_InsertIntoDB.updateSfofUserStory(strOwner, strUSproject, strUserStoryId, strRallyStatus, strRelease, strCaseId, strMasterTicket, strSalesforcePriority);
        // DO ASSERTIONS
        List<Case> lstAssert = new List<Case>([SELECT Id, User_Story_Owner__c, User_Story_Project__c, User_Story_Id__c, UserStory_Rally_Status__c, User_Story_Release__c, Master_Ticket__c, Priority FROM Case WHERE Id =: c.Id]);
        system.assertEquals(1, lstAssert.size());
        system.assertEquals(String.valueOf(UserInfo.getUserId()), lstAssert[0].User_Story_Owner__c);
        system.assertEquals('ApexTestProject', lstAssert[0].User_Story_Project__c);
        system.assertEquals('1234567890ABCDE', lstAssert[0].User_Story_Id__c);     
        system.assertEquals('ApexTestStatus', lstAssert[0].UserStory_Rally_Status__c);
        system.assertEquals('ApexTestRelease', lstAssert[0].User_Story_Release__c);
        system.assertEquals('ApexMasterTicket', lstAssert[0].Master_Ticket__c);
        system.assertEquals('3 - Medium', lstAssert[0].Priority);                    

        Test.stopTest();
        
    }        

    // ======================================================================================================================================= 
    // = TEST METHOD 4: TEST AH_Rally_InsertIntoDB.insertIntoCAR(String string_def, String cID, String RallyattachemntId, String Salesforceattid)
    // 					TEST UpdateIntoCARBasedOnOperation(String defectId, String cID, String RallyattachemntId, String Salesforceattid)
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_InsertIntoDB_Test Case# 1'];
        Attachment attch = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_InsertIntoDB_Test Attachment# 1'];  
        String strDefectId = '1234567890DEFID';
        String strCaseId = String.valueOf(c.Id);
        String strRallyAttachmentId = '1234567890ATTID';
        String strSFAttachmentId = String.valueOf(attch.Id);
		String strCase15Id = strCaseId.left(15);
        
        Test.startTest();

        // CALL METHOD
        AH_Rally_InsertIntoDB.insertIntoCAR(strDefectId, strCaseId, strRallyAttachmentId, strSFAttachmentId);
        // DO ASSERTIONS
        List<Case_Attachment_Relation__c> lstAssert1 = new List<Case_Attachment_Relation__c>([SELECT Id, Case_Id__c, Defect_Id__c, Rally_Attachment_Id__c, Sf_Attachment_Id__c, Status__c, To_be_Send__c FROM Case_Attachment_Relation__c WHERE Case_Id__c =: c.Id]);
        system.assertEquals(1, lstAssert1.size());
        system.assertEquals(strCase15Id, lstAssert1[0].Case_Id__c);
        system.assertEquals('1234567890DEFID', lstAssert1[0].Defect_Id__c);     
        system.assertEquals('1234567890ATTID', lstAssert1[0].Rally_Attachment_Id__c);
        system.assertEquals(String.valueOf(attch.Id), lstAssert1[0].Sf_Attachment_Id__c);
        system.assertEquals('Sent', lstAssert1[0].Status__c);

        // MAKE UPDATE TO PREPARE FOR NEXT TEST
        lstAssert1[0].To_be_Send__c = true;
        database.update(lstAssert1);
        
        // CALL METHOD
        AH_Rally_InsertIntoDB.UpdateIntoCARBasedOnOperation(strDefectId, strCaseId, strRallyAttachmentId, strSFAttachmentId);
        // DO ASSERTIONS
        List<Case_Attachment_Relation__c> lstAssert2 = new List<Case_Attachment_Relation__c>([SELECT Id, Case_Id__c, Defect_Id__c, Rally_Attachment_Id__c, Sf_Attachment_Id__c, Status__c, To_be_Send__c FROM Case_Attachment_Relation__c WHERE Case_Id__c =: c.Id]);
        system.assertEquals(1, lstAssert2.size());
        system.assertEquals(strCase15Id, lstAssert2[0].Case_Id__c);
        system.assertEquals('1234567890DEFID', lstAssert2[0].Defect_Id__c);     
        system.assertEquals('1234567890ATTID', lstAssert2[0].Rally_Attachment_Id__c);
        system.assertEquals(String.valueOf(attch.Id), lstAssert2[0].Sf_Attachment_Id__c);
        system.assertEquals('Sent', lstAssert2[0].Status__c);
        system.assertEquals(false, lstAssert2[0].To_be_Send__c);

        Test.stopTest();
        
    } 

    // ======================================================================================================================================= 
    // = TEST METHOD 5: TEST insertDataInCaseComment(String caseId, String defectId, String commentId, String SalesforceCommentId)
    // 					TEST UpdateIntoCommentObject(String caseId, String defectId, String rallycommentId, String SalesforceCommentId)
    // ======================================================================================================================================= 
    @isTest static void test5() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_InsertIntoDB_Test Case# 1'];
        CaseComment cc = [SELECT Id FROM CaseComment WHERE CommentBody = 'AH_Rally_InsertIntoDB_Test CaseComment# 1']; 
 
        String strDefectId = '1234567890DEFID';
        String strCaseId = String.valueOf(c.Id);
        String strRallyCommentId = '1234567890CCMID';
        String strSFCaseCommentId = String.valueOf(cc.Id);
		String strCase15Id = strCaseId.left(15);
        
        Test.startTest();

        // CALL METHOD
        AH_Rally_InsertIntoDB.insertDataInCaseComment(strCaseId, strDefectId, strRallyCommentId, strSFCaseCommentId);
        // DO ASSERTIONS
        List<Case_Comment_Relation__c> lstAssert1 = new List<Case_Comment_Relation__c>([SELECT Id,  Name, Case_Id__c, Defect_Id__c, Rally_discussion_Id__c, Sf_Comment_Id__c, Status__c, To_be_Send__c FROM Case_Comment_Relation__c WHERE Case_Id__c =: c.Id]);
        system.assertEquals(1, lstAssert1.size());
        system.assertEquals(strCase15Id, lstAssert1[0].Case_Id__c);
        system.assertEquals('1234567890DEFID', lstAssert1[0].Defect_Id__c);     
        system.assertEquals('1234567890CCMID', lstAssert1[0].Rally_discussion_Id__c);
        system.assertEquals(String.valueOf(cc.Id), lstAssert1[0].Sf_Comment_Id__c);
        system.assertEquals('Sent', lstAssert1[0].Status__c);

        // MAKE UPDATE TO PREPARE FOR NEXT TEST
        lstAssert1[0].To_be_Send__c = true;
        database.update(lstAssert1);
        
        // CALL METHOD
        AH_Rally_InsertIntoDB.UpdateIntoCommentObject(strCaseId, strDefectId, strRallyCommentId, strSFCaseCommentId);
        // DO ASSERTIONS
        List<Case_Comment_Relation__c> lstAssert2 = new List<Case_Comment_Relation__c>([SELECT Id,  Name, Case_Id__c, Defect_Id__c, Rally_discussion_Id__c, Sf_Comment_Id__c, Status__c, To_be_Send__c FROM Case_Comment_Relation__c WHERE Case_Id__c =: c.Id]);
        system.assertEquals(1, lstAssert2.size());
        system.assertEquals(strCase15Id, lstAssert2[0].Case_Id__c);
        system.assertEquals('1234567890DEFID', lstAssert2[0].Defect_Id__c);     
        system.assertEquals('1234567890CCMID', lstAssert2[0].Rally_discussion_Id__c);
        system.assertEquals(String.valueOf(cc.Id), lstAssert2[0].Sf_Comment_Id__c);
        system.assertEquals('Sent', lstAssert2[0].Status__c);
        system.assertEquals(false, lstAssert2[0].To_be_Send__c);
        
        Test.stopTest();
        
    } 

    // ======================================================================================================================================= 
    // = TEST METHOD 6: COVER EXCEPTIONS
    // ======================================================================================================================================= 
    @isTest static void test6() 
    {
        // CALL METHOD
        AH_Rally_InsertIntoDB.UpdateIntoCARBasedOnOperation('', '', '', '');        
        // CALL METHOD
        AH_Rally_InsertIntoDB.UpdateIntoCommentObject('', '', '', '');        
    }
    
}