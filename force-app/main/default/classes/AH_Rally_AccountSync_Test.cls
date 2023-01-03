/****************************************************************************************
Name            : AH_Rally_AccountSync_Test (TC Org Name: RallySFAccountTest)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Test Class for AH_Rally_AccountSync
                : 
                : 
******************************************************************************************/ 
@isTest
public class AH_Rally_AccountSync_Test 
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
        rsm.Story_Field_Map__c = '{"Description":{"fldValue":"None","literalValue":""},"KanbanState":{"custom":1,"fldValue":"None","literalValue":""},"L3KanbanStage":{"custom":1,"fldValue":"Default","literalValue":"Advance Investigation"},"Moscow":{"custom":1,"fldValue":"None","literalValue":""},"Name":{"fldValue":"Subject","literalValue":""},"Owner":{"fldValue":"owner_name__c","literalValue":""},"Package":{"fldValue":"None","literalValue":""},"Rank":{"fldValue":"None","literalValue":""},"ReadyDeprecated":{"custom":1,"fldValue":"None","literalValue":""},"SalesforcePriority":{"custom":1,"fldValue":"Customer_Severity__c","literalValue":""},"StoryType":{"custom":1,"fldValue":"Default","literalValue":"L3/Salesforce"}}';
        insert rsm;  
        
        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_Rally_AccountSync_Test Account';  
        insert a;
        
        // CREATE TEST CASE RECORD
        Case cs1 = NI_TestClassData.createTestCase(1, a.Id);
        cs1.Subject = 'AH_Rally_AccountSync_Test Case# 1';
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
    	
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: testBatch
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {    
        
        case cs = [SELECT Id, Rally_Artifact_Ref__c FROM Case WHERE Subject = 'AH_Rally_AccountSync_Test Case# 1']; 
        Set<Id> caseIds = new Set<Id>(); 
        caseIds.add(cs.Id); 
        
        AH_Rally_AccountSync b1 = new AH_Rally_AccountSync(caseIds); 
        List<Case> caseList = new List<Case>(); 
        caseList.add(cs); 
        caseList[0].Rally_Artifact_Ref__c = 'https://rally1.rallydev.com/slm/webservice/1.43/workspace/6692415259.js';
        
        Test.startTest(); 
        
        upsert caseList; 
        List<Case> caseList1 = [SELECT Id, Rally_Artifact_Ref__c, Account.Region__c FROM Case]; 
        Id batchId = Database.executeBatch(b1); 
        
        Test.stopTest(); 
        
    }

}