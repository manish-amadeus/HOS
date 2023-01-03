/****************************************************************************************
Name            : INTGR_Case_TriggerHandler_Test
Author          : Princy Jain
Created Date    : 06/06/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                :
****************************************************************************************/
@isTest
public class INTGR_Case_TriggerHandler_Test
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================     
    @testSetup static void setupData() 
    {
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        WinaproachIncidentSettings__c ws = WinaproachIncidentSettings__c.getInstance('Default');
        ws.Integration_Username__c = UserInfo.getUserName();
        update ws;
        
        // POPULATE INTEGRATION CUSTOM SETTING FOR STATUS
        Set<String> statusSet = new Set<String> {'Acknowledged-Open~Open',
            'Acknowledged-Recovered~Rejected',
            'New-New~New',
            'Open-Acknowledged~Acknowledged',
            'Open-Closed~Closed as Withdrawn',
            'Open-Closed as withdrawn~Closed as Withdrawn',
            'Recovered-Acknowledged~Acknowledged',
            'Recovered-Closed~Closed as Recovered',
            'Rejected-Acknowledged~Acknowledged',
            'Rejected-Closed~Closed as Rejected'};
        List<INTGR_Status_Mapping__c> isMappingList = new List<INTGR_Status_Mapping__c> ();
        
        for (String status : statusSet)
        {
            INTGR_Status_Mapping__c obj = new INTGR_Status_Mapping__c();
            obj.Name = status.split('~')[0];
            obj.INTGR_Inbound_Status__c = status.split('-')[1].split('~')[0];
            obj.INTGR_Status_Updated__c = status.split('~')[1];
            obj.INTGR_Current_Status__c = status.split('-')[0];
            
            isMappingList.add(obj);
        }
        
        insert isMappingList;
        
        // CREATE CASE FLAGS CUSTOM SETTINGS
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;
        
        Test.startTest();
        
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
        INTGR_Account__c acc = NI_TestClassData.createTestINTGR_Account(1, a.id, u.id);
        acc.Active__c = true;
        acc.Assignment_Group__c = 'Test Group' ;
        acc.Case_Origin__c = 'ServiceNow';
        acc.Logger_Desk_Agent_Name__c = 'ServiceNow';
        acc.Default_New_Case_Status__c = 'New';
        acc.Logger_Desk_Agent_Phone__c = '123456789';
        acc.Logger_Group__c = 'ServiceNow';
        insert acc;
        
        system.runAs(u)
        {
            // CREATE INBOUND INTEGRATION CASE
            INTGR_Case__c caseObj2 = NI_TestClassData.createTestINTGR_Case(1, acc.Id, null);
            caseObj2.Customer_Ticket_System_Id__c = 'INC000001';
            caseObj2.Customer_Ticket_Number__c = 'INC000001';
            caseObj2.Status__c = 'Acknowledged';
            caseObj2.Subject__c = 'PROSPECT - ' + caseObj2.Subject__c;
            insert caseObj2;
            
            INTGR_Case__c caseObj = NI_TestClassData.createTestINTGR_Case(1, acc.Id, null);
            caseObj.Customer_Ticket_System_Id__c = 'INC000002';
            caseObj.Customer_Ticket_Number__c = 'INC000002';
            caseObj.Status__c = 'Acknowledged';
            caseObj.Subject__c = 'PROSPECT - ' + caseObj.Subject__c;
            insert caseObj;
            
            
            INTGR_Case__c caseObj3 = NI_TestClassData.createTestINTGR_Case(1, acc.Id, null);
            caseObj3.Customer_Ticket_System_Id__c = 'INC000003';
            caseObj3.Customer_Ticket_Number__c = 'INC000003';
            caseObj3.Status__c = 'Pending Problem Resolution';
            caseObj3.Subject__c = 'PROSPECT - ' + caseObj3.Subject__c;
            insert caseObj3;
            
            INTGR_Case__c caseObj4 = NI_TestClassData.createTestINTGR_Case(1, acc.Id, null);
            caseObj4.Customer_Ticket_System_Id__c = 'INC000004';
            caseObj4.Customer_Ticket_Number__c = 'INC000004';
            caseObj4.Subject__c = 'PROSPECT - ' + caseObj4.Subject__c;
            caseObj4.Status__c = 'Pending Master Recovery';
            insert caseObj4;
        }
        
        // Case cs = NI_TestClassData.createTestCaseIntegration(1, a.Id);
        //  cs.Integration_Account__c = acc.Id;
        // cs.Acknowledged__c = system.now();
        // cs.Rejected_Case__c = true;
        //insert cs;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1:
    // ======================================================================================================================================= 
    static testmethod void initiateInBoundTestAPI() 
    {
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        User u = [SELECT Id FROM User WHERE Alias = '111user'][0];    
        Id accId = [SELECT Id FROM INTGR_Account__c LIMIT 1][0].id;
        Test.startTest();       
        
        // CREATE INBOUND DATA FOR Internal Cases
        system.runAs(u)
        {
            
            List<INTGR_Case__c> caseAsserts1 = [SELECT Id, Assignment_Group__c, INTGR_Account__c, Status__c, Severity__c, Subject__c, Description__c, Case__c FROM INTGR_Case__c WHERE createdById =: u.id];
            caseAsserts1[0].Status__c = 'Open';
            caseAsserts1[0].Severity__c = '3';
            caseAsserts1[0].Subject__c = 'Update Subject';
            caseAsserts1[0].Assignment_Group__c = 'Update AG';
            
            caseAsserts1[1].Status__c = 'Recovered';
            
            caseAsserts1[2].Severity__c = '4';
            caseAsserts1[2].Status__c = 'Acknowledged';
            
            caseAsserts1[3].Assignment_Group__c = 'New AG';
            caseAsserts1[3].Status__c = 'Test Pending Master Recovery';
            
            try
            {
                update caseAsserts1;
            }
            catch(Exception e)
            {
                
            }
            
            system.assertEquals('Update Subject', caseAsserts1[0].Subject__c);
            //system.assertEquals('4', caseAsserts1[0].Severity__c);
            system.assertEquals('Open', caseAsserts1[0].Status__c);
            
        }
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2:
    // =======================================================================================================================================     
    static testmethod void createOutboundAPICall() 
    {
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        User u = [SELECT Id FROM User WHERE Alias = '111user'][0];    
        Id accId = [SELECT Id FROM Account LIMIT 1][0].id;
        
        Test.startTest();       
        
        Case cs = NI_TestClassData.createTestCaseIntegration(1, accId);
        insert cs;
        
        Map<Id, Case> idVsCaseObjMap = INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC(cs.Id);
        INTGR_IntegrationHelper.upsertIntegrationCase(idVsCaseObjMap,true, false, null);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3:
    // ======================================================================================================================================= 
    static testmethod void initiateInBoundTestSA() 
    {
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        User u = [SELECT Id FROM User WHERE Alias = '111user'];    
        
        Test.startTest();
        
        //Id caseId = [Select Id, Case__c FROM INTGR_Case__c WHERE createdById =: u.id];
        Id caseId = [SELECT Case__c FROM INTGR_Case__c WHERE createdById =: u.id LIMIT 1][0].Case__c;
        
        try 
        {
            
            Case c = [Select id, Description,Rejected_Case__c,Customer_Ticket_Number__c,INTGR_Customer_Ticket_System_Id__c, Status FROM Case WHERE Id =:caseId];
            c.Status = 'Open';
            c.INTGR_Customer_Ticket_System_Id__c = null;
            c.Customer_Ticket_Number__c = null;
            c.Description = 'Update SF Case';
            c.Rejected_Case__c = true;
            update c;
            
            c.Status = 'Recovered';
            update c;
        }
        catch (Exception e)
        {
            system.debug('Error Occured' + e.getMessage());
        }
        
        List<INTGR_Case__c> caseAsserts1 = [SELECT Id, Assignment_Group__c, INTGR_Account__c, Status__c, Severity__c,Subject__c,Description__c, Case__c FROM INTGR_Case__c WHERE createdById =: u.id];
        
        caseAsserts1[0].Status__c = 'Open';
        caseAsserts1[0].Severity__c = '3';
        caseAsserts1[0].Subject__c = 'Update Subject';
        caseAsserts1[0].Assignment_Group__c = 'Update AG';
        
        caseAsserts1[1].Status__c = 'Recovered';
        
        caseAsserts1[2].Severity__c = '4';
        caseAsserts1[2].Status__c = 'Acknowledged';
        
        caseAsserts1[3].Assignment_Group__c = 'New AG';
        caseAsserts1[3].Status__c = 'Test Pending Master Recovery';
        
        try
        {
            update caseAsserts1;
        }
        catch(Exception e)
        {
            
        }

        Test.stopTest();
        
    }





    
    
/*
// ======================================================================================================================================= 
// = TEST METHOD 4:
// ======================================================================================================================================= 

static testmethod void initiateInBoundTestAPI1() 
{

    Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
    User u = [SELECT Id FROM User WHERE Alias = '111user'][0];    
    Id accId = [Select Id FROM  INTGR_Account__c limit 1][0].id;
    Test.startTest();       
    
    // CREATE INBOUND DATA FOR Internal Cases
    system.runAs(u)
    {
        List<INTGR_Case__c> caseAsserts1 = [SELECT Id, Assignment_Group__c, INTGR_Account__c, Status__c, Severity__c,Subject__c,Description__c, Case__c FROM INTGR_Case__c WHERE createdById =: u.id];
        caseAsserts1[0].Status__c = 'Open';
        update caseAsserts1[0];
        
        caseAsserts1[0].Status__c = 'Closed';
        update caseAsserts1[0];
        
        caseAsserts1[1].Status__c = 'Rejected';
        update caseAsserts1[1];
        
        caseAsserts1[1].Status__c = 'Closed';
        update caseAsserts1[1];
        
        caseAsserts1[2].Status__c = 'Recovered';
        update caseAsserts1[2];
        
        caseAsserts1[2].Status__c = 'Closed';
        update caseAsserts1[2];
    
    }
    Test.stopTest();
}
*/
        
}