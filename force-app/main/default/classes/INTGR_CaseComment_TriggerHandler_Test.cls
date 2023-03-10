/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_CaseComment_TriggerHandler_Test
Author          : Princy Jain
Created Date    : 06/06/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
				:
****************************************************************************************/
@isTest
public class INTGR_CaseComment_TriggerHandler_Test
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================     
    @testSetup static void setupObjects() 
    {
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        WinaproachIncidentSettings__c ws = WinaproachIncidentSettings__c.getInstance('Default');
        ws.Integration_Username__c = UserInfo.getUserName();
        update ws;
        
        // CREATE TEST CUSTOMER USER ACCOUNT
        User u = NI_TestClassData.createTestUser(111, 'Case Integration Customers');
        u.Email = 'apexTester111@amadeuscustomer.com';
        u.Alias = '111user';
        insert u; 
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        // CREATE TEST INTEGRATION ACCOUNT RECORD
        INTGR_Account__c acc = NI_TestClassData.createTestINTGR_Account(1, a1.id, u.id);
        acc.Active__c = true;
        acc.Assignment_Group__c = 'Test Group' ;
        acc.Case_Origin__c = 'ServiceNow';
        acc.Logger_Desk_Agent_Name__c = 'ServiceNow';
        acc.Default_New_Case_Status__c = 'New';
        acc.Logger_Desk_Agent_Phone__c = '123456789';
        acc.Logger_Group__c = 'ServiceNow';
        acc.RequestFormat__c = 'JSON';
        insert acc;
        
        // CREATE INBOUND DATA FOR Internal Cases
        system.runAs(u)
        {
            
            // CREATE INBOUND INTEGRATION CASE
            INTGR_Case__c caseObj2 = NI_TestClassData.createTestINTGR_Case(1, acc.id, null);
            caseObj2.Customer_Ticket_System_Id__c = 'INC000001';
            caseObj2.Customer_Ticket_Number__c = 'INC000001';
            caseObj2.Subject__c = 'PROSPECT - ' + caseObj2.Subject__c;
            insert caseObj2;
            
        }
        
        // CREATE OUTBOUND CASE
        Case cs = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        cs.Integration_Account__c = acc.Id;
        cs.Acknowledged__c = system.now();
        cs.Rejected_Case__c = true;
        cs.INTGR_Customer_Ticket_System_Id__c = 'INC001';
        cs.Customer_Ticket_Number__c = 'INC001';
        cs.Update_External_System__c = true;
        insert cs;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1:
    // =======================================================================================================================================    
    static testmethod void intCaseCommentUpdateFromAPI()
    {
        
        User u = [SELECT Id FROM User WHERE Alias = '111user'][0];
        
        Test.startTest();
        
        system.runAs(u)
        {
            
            Id caseId = [SELECT Id FROM INTGR_Case__c WHERE createdById =: u.Id][0].Id;
            INTGR_Case_Comment__c caseComm = NI_TestClassData.createTestINTGR_CaseComm(caseId);
            insert caseComm;
            
            caseComm.CommentBody__c = 'update On Case Test';
            update caseComm;
            
            system.assertEquals('update On Case Test', caseComm.CommentBody__c);
            system.assertNotEquals(null, caseComm.INTGR_Case__c);
            
        }
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2:
    // =======================================================================================================================================    
    static testmethod void intCaseCommentUpdateFromSF() 
    {
        
        User u = [SELECT Id FROM User WHERE Alias = '111user'][0];
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        
        Test.startTest();
        
        Case c = [SELECT Id FROM Case WHERE CreatedById !=: u.Id][0];
        
        Map<Id, Case> idVsCaseObjMap = INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC(c.Id);
        
        INTGR_IntegrationHelper.upsertIntegrationCase(idVsCaseObjMap, true, false, null);
        
        // To check if Integration Case is created for SC
        Id intCaseId = [SELECT Id FROM INTGR_Case__c WHERE Case__c =: c.Id][0].Id;
        system.assertNotEquals(null, intCaseId);
        
        // CREATE OUTBOUND CASE COMMENT
        CaseComment comm = NI_TestClassData.createTestCaseComment(1, c.Id);
        insert comm; 
        
        comm.CommentBody = 'Update SF case';
        update comm;
        
        system.assertEquals('Update SF case', comm.CommentBody);
        
        // Assertion to check integration Case Comment
        Test.stopTest();
        
    }
    
}