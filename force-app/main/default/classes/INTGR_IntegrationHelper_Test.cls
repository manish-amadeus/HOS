/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_IntegrationHelper_Test Class
Author          : Princy Jain
Created Date    : 04/20/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test Class for INTGR_IntegrationHelper_Test Class
                : 
                : 
******************************************************************************************/
@isTest
public class INTGR_IntegrationHelper_Test
{
    
    public static Map<Id, NI_Integration_Log__c> mapNiIntegrationLog = new Map<Id, NI_Integration_Log__c>();
    public static Map<Id, Id> mapIntCaseCreate = new Map<Id, Id>();
    public static Map<Id, Id> mapIntCaseUpdate = new Map<Id, Id>();
    public static Map<Id, Id> mapIntCaseCommCreate = new Map<Id, Id>();
    public static Map<Id, Id> mapIntFilesCreate = new Map<Id, Id>();
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================      
    @testSetup static void setup() 
    {
        
        ServiceNowIncidentSettings__c setting = NI_TestClassData.createServiceNowIncidentSettings();
        insert setting;
        
        WinaproachIncidentSettings__c winSettings = NI_TestClassData.createWinaproachIncidentSettings();
        winSettings.Username__c = UserInfo.getUserName();
        insert winSettings;
        
        Winaproach_Incident_Case_Record_Type__c winCaseRC = NI_TestClassData.createIncidentCaseRecordType();
        insert winCaseRC;
        
        WinaproachIncidentStatusMapping__c winIncSetting = NI_TestClassData.createIncidentStatusMapping();
        insert winIncSetting;
        
        User cUser = NI_TestClassData.createTestUser(111, 'System Administrator');
        cUser.Email = 'testuserZzzzzz' + 111 + '@salesforce.com';
        cUser.Alias = '111user';
        insert cUser; 
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        insert a1;
        
        INTGR_Account__c acc = NI_TestClassData.createTestINTGR_Account(1, a1.Id, cUser.Id);
        acc.Active__c = true;
        insert acc;
        
        List<INTGR_Field_Mapping__c> fMapping = NI_TestClassData.createTestINTGR_AccountMapping(1, acc.Id);
        insert fMapping;
        
        Map<String, String> srcTargetFieldMap1 = new Map<String, String>();
        srcTargetFieldMap1.put('Description__c', 'Description');
        
        Case cs = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        cs.Integration_Account__c = acc.Id;
        insert cs;
        
        CaseComment comm = NI_TestClassData.createTestCaseComment (1, cs.Id);
        insert comm;
        
        INTGR_Case__c caseObj = NI_TestClassData.createTestINTGR_Case(1, acc.Id, cs.Id);
        insert caseObj ;
        
        caseObj.Customer_Ticket_System_Id__c = '11223344355';
        caseObj.Customer_Ticket_Number__c = 'INC001';
        update caseObj;
        
        INTGR_Case_Comment__c caseComm = NI_TestClassData.createTestINTGR_CaseComm(caseObj.Id);
        insert caseComm;
        
        ContentVersion cv1 = NI_TestClassData.createContentVersion();
        cv1.CaseId__c = cs.Id;
        insert cv1;
        
        List<NI_Integration_Log__c> logList = new List<NI_Integration_Log__c>();
        NI_Integration_Log__c log1 = INTGR_IntegrationHelper.createNIIntegraionLog(cs.Id, caseObj.Id, null, 'error Occured','Failed','insert', 'INTGR_Case__c', 'test.salesforce.com', 'ServiceNow', 'testbody');
        logList.add(log1);
        NI_Integration_Log__c log2 = INTGR_IntegrationHelper.createNIIntegraionLog(cs.Id, caseObj.Id, null, 'error Occured','Failed','update', 'INTGR_Case__c', 'test.salesforce.com', 'ServiceNow', 'testbody');
        logList.add(log2);
        NI_Integration_Log__c log3 = INTGR_IntegrationHelper.createNIIntegraionLog(cs.Id, caseObj.Id, caseComm.Id, 'error Occured','Failed','insert', 'INTGR_Case_Comment__c', 'test.salesforce.com', 'ServiceNow', 'testbody');
        logList.add(log3);
        NI_Integration_Log__c log4 = INTGR_IntegrationHelper.createNIIntegraionLog(cs.Id, caseObj.Id, null, 'error Occured','Failed','insert', 'ContentVersion', 'test.salesforce.com', 'ServiceNow', 'testbody');
        log4.Attachment_Id__c = cv1.Id;
        log4.Attachment_Name__c = cv1.Title;
        logList.add(log4);
        
        insert loglist;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1:
    // =======================================================================================================================================     
    static testMethod void caseInsertCallout()
    {
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        
        Test.startTest();
        
        Account a1 = [SELECT Id FROM Account LIMIT 1][0];
        
        Case cs1 = NI_TestClassData.createTestCaseIntegration(1, a1.Id);
        insert cs1;
        
        Map<Id, Case> idVsCaseObjMap = INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC(cs1.Id);
        INTGR_IntegrationHelper.upsertIntegrationCase(idVsCaseObjMap, true, false, null);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2:
    // =======================================================================================================================================     
    static testmethod void caseUpdateCallout() 
    {
        
        Test.startTest();
        
        Case caseObj = [SELECT Id, Description FROM Case LIMIT 1][0];
        caseObj.Description = 'update Description';
        update caseObj ;
        
        INTGR_Account__c acc = [SELECT Id, RequestFormat__c FROM INTGR_Account__c LIMIT 1][0];
        acc.RequestFormat__c = 'SOAP';
        update acc;
        
        Case caseObj1 = [SELECT Id, Description FROM Case LIMIT 1][0];
        caseObj1.Description  = 'update Description SOAP';
        update caseObj1 ;        
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3:
    // =======================================================================================================================================     
    static testmethod void caseCommentUpdateCallout() 
    {
        
        Test.startTest(); 
        
        CaseComment comm = [SELECT Id, CommentBody FROM CaseComment LIMIT 1][0];
        comm.CommentBody = 'Updating case comment.';
        update comm;
        
        INTGR_Account__c acc = [SELECT Id, RequestFormat__c FROM INTGR_Account__c LIMIT 1][0];
        acc.RequestFormat__c = 'SOAP';
        update acc;
        
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4:
    // =======================================================================================================================================     
    static testmethod void retryCallout() 
    {
        
        Test.startTest();
        
        for (NI_Integration_Log__c nlog : [SELECT Id, Case__c, Status__c, Transaction_Type__c, Integration_Name__c,
                                           Integration_Case__c, createdDate, Integration_Case_Comment__c, UpdateFor__c, 
                                           Retries_Performed__c, Do_Retries__c, XMLRequest__c, Web_Service_Endpoint__c, Attachment_Id__c 
                                           FROM NI_Integration_Log__c 
                                           WHERE status__c = 'Failed' 
                                           AND Integration_Name__c = 'ServiceNow' 
                                           AND Do_Retries__c = true LIMIT 6])
        {
            
            mapNiIntegrationLog.put(nlog.id, nlog);
            
            if (nlog.Transaction_Type__c.equalsIgnoreCase('Insert') && nlog.UpdateFor__c.equalsIgnoreCase('INTGR_Case__c')) 
            {
                mapIntCaseCreate.put(nlog.Integration_Case__c, nlog.id);
            }
            
            if (nlog.Transaction_Type__c.equalsIgnoreCase('Update') && nlog.UpdateFor__c.equalsIgnoreCase('INTGR_Case__c'))
            {
                mapIntCaseUpdate.put(nlog.Integration_Case__c, nlog.id);
            }
            
            if (nlog.UpdateFor__c.equalsIgnoreCase('INTGR_Case_Comment__c'))
            {
                mapIntCaseCommCreate.put(nlog.Integration_Case_Comment__c, nlog.id);
            }
            
            if (nlog.UpdateFor__c.equalsIgnoreCase('ContentVersion'))
            {
                mapIntFilesCreate.put(nlog.Attachment_Id__c, nlog.id);
            }
            
        }
        
        INTGR_IntegrationHelper.initiateResendFailedRecordsToSN(mapNiIntegrationLog, mapIntCaseCreate, mapIntCaseUpdate, mapIntCaseCommCreate, mapIntFilesCreate);
        Test.setMock(HttpCalloutMock.class, new INTGR_REST_MockResponseGenerator());
        
        Test.stopTest();
        
    }
    
}