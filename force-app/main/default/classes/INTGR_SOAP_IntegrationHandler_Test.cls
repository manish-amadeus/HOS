/************************************************************************************************
        !!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_SOAP_IntegrationHandler_Test 
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 01/15/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for INTGR_SOAP_IntegrationHandler
            : 
************************************************************************************************/
@isTest
public class INTGR_SOAP_IntegrationHandler_Test 
{  
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================     
    @testSetup static void setupData() 
    {
        
        Test.setMock(WebServiceMock.class, new INTGR_SOAP_MockResponseGenerator('abcd1234', 'INC001'));
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST INTGR_Case_TriggerHandler_Test';
        insert a;
        
        // CREATE TEST CUSTOMER USER ACCOUNT
        User u = NI_TestClassData.createTestUser(111, 'Case Integration Customers');
        u.Email = 'apexTester111@amadeuscustomer.com';
        u.Alias = '111user';
        insert u; 
        
        // CREATE TEST INTEGRATION ACCOUNT RECORD
        INTGR_Account__c acc = NI_TestClassData.createTestINTGR_Account(1, a.Id, u.Id);
        acc.Active__c = true;
        acc.Assignment_Group__c = 'Test Group';
        acc.Case_Origin__c = 'ServiceNow';
        acc.Logger_Desk_Agent_Name__c = 'ServiceNow';
        acc.Default_New_Case_Status__c = 'New';
        acc.Logger_Desk_Agent_Phone__c = '123456789';
        acc.Logger_Group__c = 'ServiceNow';
        acc.RequestFormat__c = 'SOAP';
        insert acc;
        
        
        
        // CREATE FIELD MAPPING FOR OBJECTS
        List<INTGR_Field_Mapping__c> fMappingList = NI_TestClassData.createTestINTGR_AccountMapping(8, acc.Id);
        
        if (fMappingList.size() > 0) 
        {
            
            fMappingList[1].Source_Field__c = 'Severity__c';
            fMappingList[1].Target_Field__c = 'priority';
            
            fMappingList[2].Source_Field__c = 'Status__c';
            fMappingList[2].Target_Field__c = 'incident_state';
            
            fMappingList[3].Source_Field__c = 'Subject__c';
            fMappingList[3].Target_Field__c = 'short_description';            
            
            fMappingList[4].Source_Field__c = 'Customer_Ticket_System_Id__c';
            fMappingList[4].Target_Field__c = 'sys_id';
            
            fMappingList[5].Source_Field__c = 'Customer_Ticket_System_Id__c';
            fMappingList[5].Target_Field__c = 'sys_id';
            fMappingList[5].Source_Object_API_Name__c  = 'INTGR_Case_Comment__c';
            
            fMappingList[6].Source_Field__c = 'CommentBody__c';
            fMappingList[6].Target_Field__c = 'work_notes';
            fMappingList[6].Source_Object_API_Name__c  = 'INTGR_Case_Comment__c';
            
            fMappingList[7].Source_Field__c = 'Customer_Name__c';
            fMappingList[7].Target_Field__c = 'caller_id';
            
        }
        
        insert fMappingList;
        system.debug(fMappingList);
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST FOR OUTGOING CASE RECORDs
    // =======================================================================================================================================      
    private static testMethod void incidentCalloutSOAPTest() 
    {
        
        Test.setMock(WebServiceMock.class, new INTGR_SOAP_MockResponseGenerator('abcd1234', 'INC001'));
        
        Account a = [SELECT Id FROM Account WHERE Name =: 'APEX TEST INTGR_Case_TriggerHandler_Test'][0];
        
        INTGR_Account__c intAcc = [Select Id From INTGR_Account__c Where Case_Origin__c = :'ServiceNow'];
        
        // CREATE OUTBOUND CASE
        Case cs = NI_TestClassData.createTestCaseIntegration(1, a.Id);
        cs.Acknowledged__c = system.now();
        cs.Rejected_Case__c = true;
        cs.Customer_Name__c = 'Test Customer';
        cs.Update_External_System__c = true;
        insert cs;
            
        system.debug('cs  :' + cs );
        
    INTGR_Case__c intCase = NI_TestClassData.createTestINTGR_Case(1,intAcc.Id,cs.ID);
        
        intCase.Severity__c = '1';
        intCase.Status__c = 'Open';
        intCase.Customer_Ticket_System_Id__c = 'Hello56463746338';
        intCase.Customer_Ticket_Number__c  = 'amd123456874456';
        intCase.Subject__c = 'Test Case';
        
        Insert intCase;
        
        
        Map<Id, Case> idVsCaseObjMap = new Map<Id, Case>();
        User u = [SELECT Id FROM User WHERE Alias = '111user'][0];
        
        Test.startTest();
        
        Case c = [SELECT Id, Description FROM Case WHERE createdById !=: u.Id ][0];
        
        system.debug('c  :' + c);
        idVsCaseObjMap = INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC(c.Id);
        system.debug('idVsCaseObjMap  :' + idVsCaseObjMap );
        INTGR_IntegrationHelper.upsertIntegrationCase(idVsCaseObjMap, true, false, null);
        
        c.Description = 'Update Description';
        update c;
        
        system.assertEquals('Update Description', c.Description);
        
        system.debug('c.Id  :' + c.Id);
        CaseComment comm = NI_TestClassData.createTestCaseComment(1, c.Id);
        insert comm;
        
        
        CaseComment comm1 = [SELECT Id, CommentBody FROM CaseComment WHERE ParentId =: c.Id];
        comm1.CommentBody = 'Update Comment';
        update comm1;
        
        system.debug('Update Comment  : ' + comm1.CommentBody);
        system.assertEquals('Update Comment', comm1.CommentBody);
        
        ContentVersion cv = NI_TestClassData.createContentVersion();
        cv.CaseId__c = cs.Id;
        insert cv;
       
        INTGR_Case__c caseObj = [SELECT Id, Customer_Ticket_System_Id__c, Customer_Ticket_Number__c FROM INTGR_Case__c WHERE CASE__c =: cs.Id ][0];
        
        INTGR_SOAP_IntegrationHandler obj = new INTGR_SOAP_IntegrationHandler();
        obj.parseSOAPResponse('INC001', 'INC001', caseObj);
       
        Test.stopTest();  
        
    }        
      
}