/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_Case_SOQLDataProvider_Test
Author          : Princy Jain
Created Date    : 08/10/2018
Last Mod Date   : 08/10/2018
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for INTGR_Case_SOQLDataProvider
                :
****************************************************************************************/
@isTest
public class INTGR_Case_SOQLDataProvider_Test
{
    
    static testmethod void testSOQLCallouts()
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
        
        // CREATE TEST STANDARD ACCOUNT RECORD
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
        acc.Integration_User__c = userInfo.getUserId();
        insert acc;
        
        // CREATE TEST INTEGRATION FIELD MAPPING RECORD
        INTGR_Field_Mapping__c iFldMap = new INTGR_Field_Mapping__c();
        iFldMap.Integration_Account__c = acc.Id;        
       	iFldMap.Source_Object_API_Name__c = 'INTGR_Case__c';
        iFldMap.Source_Field__c = 'Subject__c';        
        iFldMap.Target_Object_API_Name__c = 'incident';
        iFldMap.Target_Field__c = 'short_description';
        insert iFldMap;
        
        // CREATE INBOUND DATA FOR Internal Cases
        system.runAs(u)
        {
            
            // CREATE INBOUND INTEGRATION CASE
            INTGR_Case__c caseObj2 = NI_TestClassData.createTestINTGR_Case(1, acc.id, null);
            caseObj2.Customer_Ticket_System_Id__c = 'INC000001';
            caseObj2.Customer_Ticket_Number__c = 'INC000001';
            caseObj2.Subject__c = 'PROSPECT - ' + caseObj2.Subject__c;
            // insert caseObj2;
            
        }
        
        // CREATE OUTBOUND CASE
        Case cs = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        cs.Integration_Account__c = acc.Id;
        cs.Acknowledged__c = system.now();
        cs.Rejected_Case__c = true;
        cs.INTGR_Customer_Ticket_System_Id__c = 'INC001';
        cs.Customer_Ticket_Number__c = 'INC001'; 
        cs.Work_Around_Available__c = false;
        cs.IsOperationalIssue__c = false;
        cs.Workaround_Provided_Date__c = null;
        cs.Workaround_Rejected_Date__c = null;        
        insert cs;
        
        Case cs2 = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        cs2.Integration_Account__c = null;
        cs2.Acknowledged__c = system.now();
        cs2.Rejected_Case__c = true;
        cs2.INTGR_Customer_Ticket_System_Id__c = 'INC002';
        cs2.Customer_Ticket_Number__c = 'INC002';
        cs2.Work_Around_Available__c = false;
        cs2.IsOperationalIssue__c = false;
        cs2.Workaround_Provided_Date__c = null;
        cs2.Workaround_Rejected_Date__c = null;
        insert cs2;        
          
        Map<Id, Case> idVsCaseObjMap = INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC(cs.Id);
        
        INTGR_IntegrationHelper.upsertIntegrationCase(idVsCaseObjMap, true, false, null);
        
        // CREATE OUTBOUND CASE COMMENT
        CaseComment comm = NI_TestClassData.createTestCaseComment (1, cs.Id);
        insert comm; 
        
        INTGR_Case__c caseObj = [SELECT Id, Customer_Ticket_System_Id__c, Customer_Ticket_Number__c FROM INTGR_Case__c WHERE CASE__c =: cs.Id][0];
        
        // CREATE TEST INTEGRATION CASE COMMENT
        INTGR_Case_Comment__c iCsCmt = new INTGR_Case_Comment__c();
        iCsCmt.CommentBody__c = 'hello world!';
        iCsCmt.INTGR_Case__c = caseObj.Id;
        insert iCsCmt;
        
        Set<Id> commSet = new Set<Id>();
        
        commSet.add(comm.Id);
        INTGR_Case_SOQLDataProvider.getAccountConnectionDetails(a1.Id);
        INTGR_Case_SOQLDataProvider obj = new INTGR_Case_SOQLDataProvider();
        
        boolean b1 = obj.isValidField('Description__C', 'INTGR_Case__c');
        system.assertEquals(true, b1);
        
        boolean b2 = obj.isValidField('Descrption__C', 'INTGR_Case__c');
        system.assertEquals(false, b2);
        
        obj.updateINTCaseSysIdAndIncidentNo('INC001', 'INC001', caseObj);
        
        Set<Id> setICase2 = new Set<Id>();
        setICase2.add(cs2.Id);
        Map<Id, String> m1 = obj.getCaseIdVsReqFormatMap(setICase2);
        
        INTGR_Case_SOQLDataProvider.getCaseCommIdVsReqFormatMap(commSet);
        INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId (a1.Id, 'INTGR_Case__c');
        INTGR_Case_SOQLDataProvider.getICdetails(idVsCaseObjMap.keySet());
        INTGR_Case_SOQLDataProvider.getCaseCommIdVsIntegrationAccDetails(iCsCmt.Id);
        
        Map<Id, INTGR_Account__c> accMap1 = INTGR_Case_SOQLDataProvider.getAllIntAccMap();
        Map<Id, INTGR_Account__c> accMap2 = obj.getIntAccIdVsAccMap();
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator()); 
        
    }
    
}