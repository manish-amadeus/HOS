/****************************************************************************************
Name            : AH_Rally_AttachmentList_Ctlr_Test
Author          : Sean Harris
Created Date    : 11/25/2020
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test class for AH_Rally_AttachmentList_Ctlr
				: 
				: 
******************************************************************************************/ 
@isTest
public class AH_Rally_AttachmentList_Ctlr_Test 
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
        a.Name = 'AH_Rally_AttachmentList_Ctlr_Test Account';
        insert a;
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
        // CREATE 2 TEST CASE RECORDS
		Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_AttachmentList_Ctlr_Test Case# 1';
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
        
		Case cs2 = NI_TestClassData.createTestCase(1, a.Id);
        cs2.Subject = 'AH_Rally_AttachmentList_Ctlr_Test Case #2';
        cs2.User_Story_Id__c = 'US90583';
        cs2.Priority = 'Medium';
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

        // CREATE TEST ATTACHMENT ON CASE
       	Attachment att = NI_TestClassData.createTestAttachment(cs1.Id);
        att.Name = 'AH_Rally_AttachmentList_Ctlr_Test';
        insert att;
        
        // CREATE TEST CASE ATTACHMENT RELATION RECORD
        Case_Attachment_Relation__c attach = new Case_Attachment_Relation__c();
        attach.case_id__c = cs1.Id;
        attach.To_be_Send__c = true;
        attach.Sf_Attachment_Id__c = att.Id;
        insert attach;
        
        // CREATE TEST CASE COMMENT RELATION RECORD
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
    // = TEST METHOD 1:  
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    

        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_Rally_AttachmentList_Ctlr_Test Case# 1'];
        Attachment att = [SELECT Id FROM Attachment WHERE Name = 'AH_Rally_AttachmentList_Ctlr_Test'];
        
        // SET THE CURRENT VF PAGE
        PageReference pr1 = Page.AH_Rally_AttachmentList;
        Test.setCurrentPage(pr1);
        
        // ADD URL PARAMETERS
        pr1.getParameters().put('attachId', att.Id);
		pr1.getParameters().put('delAttachId', att.Id); 

        ApexPages.StandardController std = new ApexPages.StandardController(c);
        AH_Rally_AttachmentList_Ctlr ctrl = new AH_Rally_AttachmentList_Ctlr(std);  
        
        Test.startTest();
        
        ctrl.init1();
        
        PageReference pr2 = ctrl.createNewAttachment();

        PageReference pr3 = ctrl.viewAttachment();
        
        PageReference pr4 = ctrl.editAttachment();
        
        PageReference pr5 = ctrl.viewAllAttachments();

        ctrl.deleteAttachment();
        
        Test.stopTest();
        
    }
    
}