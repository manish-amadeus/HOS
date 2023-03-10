/************************************************************************************************
                 !!! INTEGRATION CLASS - DO NOT ALTER !!!
*************************************************************************************************
Name            : INTGR_WinSN_CaseComment_Handler_Test
Integration     : Win@pproach / Service Now
Author          : Sean Harris
Created Date    : 02/08/2019
Last Mod Date   : 02/08/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for INTGR_WinSN_CaseComment_Handler
                : 
*************************************************************************************************/
@isTest
public class INTGR_WinSN_CaseComment_Handler_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA : Create Accounts, Contacts, Integration Accounts & Users, Legacy Win@aproach Custom Settings
    // =======================================================================================================================================      
    @testSetup static void createTestData()  
    {
        
        // CREATE TEST ACCOUNTS
        Account acc = NI_TestClassData.createTestAccount(1);
        acc.Name = 'INTGR_WinSN_CaseComment_Handler_Test LEGACY Account';
        insert acc;
        
        Account acc2 = NI_TestClassData.createTestAccount(2);
        acc2.Name = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Account';
        insert acc2;

        Contact con = NI_TestClassData.createTestContact(1, acc.id);		
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();		
        insert con;
        
        // CREATE TEST INTERGRATION USERS
        User waUser = NI_TestClassData.createTestUser(121, 'Winaproach Integration Only - Standard'); 
        waUser.UserName = 'winaproachTEST@newmarketinc.com.nextdev3';
        insert waUser;         
        
        User snUser = NI_TestClassData.createTestUser(122, 'IHG Integration Only - Standard'); 
        snUser.UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3';
        insert snUser;         
        
        User newUser = NI_TestClassData.createTestUser(123, 'Case Integration Customers'); 
        newUser.UserName = 'servicenowTEST@newmarketinc.com.nextdev3';
        insert newUser; 
 
        // CREATE TEST INTEGRATION ACCOUNT
        INTGR_Account__c iAcc = NI_TestClassData.createTestINTGR_Account(1, acc2.Id, newUser.Id);
        iAcc.Name = 'INTGR_WinSN_CaseComment_Handler_Test INTGR Account';
        insert iAcc;
        
        // CREATE TEST INTEGRATION ACCOUNT FIELD MAPPINGS
        List<INTGR_Field_Mapping__c> lstFMs = NI_TestClassData.createTestINTGR_AccountMapping(1, iAcc.Id);
        insert lstFMs;
        
        // SET THE NEW ACCOUNT ID CUSTOM SETTING FIELD TO TEST ACCOUNT ID
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        ServiceNowIncidentSettings__c sn = [SELECT Id, AccountId__c, Integration_UserId__c, Integration_Username__c 
                                            FROM ServiceNowIncidentSettings__c 
                                            WHERE name = 'Default' 
                                            LIMIT 1];
        
        sn.Integration_Username__c = 'ihg_servicenowTEST@newmarketinc.com.nextdev3';
        sn.Integration_UserId__c = snUser.id;
        sn.AccountId__c = acc.Id;
        update sn;  

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

        Test.startTest();        
        
        // CREATE STANDARD CASE
        Case c = NI_TestClassData.createTestCase(1, acc2.Id);
        c.Subject = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Standard Case 1';
        insert c;
        
        // CREATE NEXT INTEGRATION CASE
        INTGR_Case__c ic = NI_TestClassData.createTestINTGR_Case(1, iAcc.Id, null);
        ic.Case__c = c.Id;
        ic.Customer_Ticket_System_Id__c = '6df05258-9796-481a-8eae-eb3b9c230bd3';
        ic.Customer_Ticket_Number__c = 'INC000001';
        ic.Status__c = 'Open';
        ic.Severity__c = '3';
        ic.Assignment_Group__c = 'MHDHOT';
        ic.Hotel_Code__c = 'APEXTEST';
        ic.System_Affected__c = 'Production';
        ic.Affected_Service__c = 'CRS Administration Portal';
        ic.Subject__c = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Case 1';
        insert ic;        

        Test.stopTest(); 
        
        // ASSERT STANDARD CASE WAS CREATED
        INTGR_Case__c iCs = [SELECT Id, Case__c, Subject__c,  
                             Customer_Ticket_System_Id__c, Customer_Ticket_Number__c, Status__c, 
                             Severity__c, Assignment_Group__c, Hotel_Code__c, System_Affected__c, Affected_Service__c 
                             FROM INTGR_Case__c WHERE Subject__c = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Case 1'];
        
        system.assertNotEquals(null, iCs.Case__c);        

        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: LEGACY
    // =======================================================================================================================================       
    static testMethod void testWinaproachCaseComment()
    {

        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_CaseComment_Handler_Test LEGACY Account'];

        Test.startTest(); 
        
        //Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        
        List<Id> lstIds = new List<Id>();
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'Open';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       	
        insert cs;
        
        Attachment attach = new Attachment();   	
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = cs.id;
        insert attach;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();		
        t.RecordTypeID = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Amadeus Parallel Investigation').getRecordTypeId();    
        t.Subject = 'Donni';
        t.Status = 'New';
        t.Priority = 'Normal';
        t.WhatId = cs.id;
        t.Parallel_Investigation_Group__c = 'MHDHOT';
        t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
        t.Added_By_Group__c = 'MHDHOT'; 
        t.Description = 'Comments';
        t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO'; 
        t.Sub_Status__c = 'External Info';
        insert t;
        
        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id); 
        csComment.CommentBody = 'comments';
        insert csComment;                        
        
        csComment.CommentBody = 'comments update';
        update csComment; 
        
        Test.stopTest();

    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: LEGACY
    // =======================================================================================================================================     
    static testMethod void testServiceNowCaseComment()
    {
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: TEST AN "OUTGOING" NEXT CASE COMMENT FROM Winaproach Integration Only - Standard USER
    // =======================================================================================================================================       
    static testMethod void testWinaproachCaseCommentNEXT()
    {

        User u = [SELECT Id FROM User WHERE UserName = 'winaproachTEST@newmarketinc.com.nextdev3'];         
        Case c = [SELECT Id FROM Case WHERE Subject = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Standard Case 1'];
		INTGR_Case__c iCs = [SELECT Id FROM INTGR_Case__c WHERE Subject__c = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Case 1'];
        
        system.runAs(u)
        {                
            CaseComment cc = NI_TestClassData.createTestCaseComment(1, c.Id);
            cc.CommentBody = 'INTGR_WinSN_CaseComment_Handler_Test NEXT CaseComment 1';
            insert cc;
            
        }        
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: TEST AN "INCOMING" NEXT CASE COMMENT FROM Case Integration Customers USER
    // =======================================================================================================================================     
    static testMethod void testServiceNowCaseCommentNEXT()
    {
        
        User u = [SELECT Id FROM User WHERE UserName = 'servicenowTEST@newmarketinc.com.nextdev3'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Account'];
        INTGR_Account__c iAcc = [SELECT Id FROM INTGR_Account__c WHERE Name = 'INTGR_WinSN_CaseComment_Handler_Test INTGR Account'];
        
        system.runAs(u)
        {
            // CREATE INBOUND INTEGRATION CASE
            INTGR_Case__c c = NI_TestClassData.createTestINTGR_Case(1, iAcc.Id, null);
            c.Customer_Ticket_System_Id__c = '2b45c340-3473-4d57-98b9-5647b2de5a62';
            c.Customer_Ticket_Number__c = 'INC000002';
            c.Status__c = 'Open';
            c.Severity__c = '3';
            c.Assignment_Group__c = 'MHDHOT';
            c.Hotel_Code__c = 'APEXTEST';
            c.System_Affected__c = 'Production';
            c.Affected_Service__c = 'CRS Administration Portal';
            c.Subject__c = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Case 2';
            insert c;
Test.startTest();            
            INTGR_Case__c iCs = [SELECT Id, Case__c, Error_Message__c FROM INTGR_Case__c WHERE Subject__c = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Case 2'];
            system.assertEquals('Operation Successful.', iCs.Error_Message__c);
            
            INTGR_Case_Comment__c cc = NI_TestClassData.createTestINTGR_CaseComm(c.Id);
            insert cc;
Test.stopTest();            
        }
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, AccountId FROM Case WHERE Subject = 'INTGR_WinSN_CaseComment_Handler_Test NEXT Case 2']);
        system.debug(' **** lstCaseAsserts = ' + lstCaseAsserts);
        // ASSERT CORRECT ACCOUNT ID ON NEW CASE
        system.assertEquals(lstCaseAsserts.size(), 1);        
        // ASSERT CORRECT ACCOUNT ID ON NEW CASE
        system.assertEquals(lstCaseAsserts[0].AccountId, acc.Id); 
        
        Id csId = lstCaseAsserts[0].Id;
        
        List<CaseComment> lstCaseCommentAsserts = new List<CaseComment>([SELECT Id, ParentId, CommentBody FROM CaseComment]);
        system.debug(' **** lstCaseCommentAsserts = ' + lstCaseCommentAsserts);
        // ASSERT CORRECT ACCOUNT ID ON NEW CASE
        //system.assertEquals(lstCaseCommentAsserts.size(), 1);        
        // ASSERT CORRECT ACCOUNT ID ON NEW CASE
        //system.assertEquals(lstCaseCommentAsserts[0].ParentId, csId);         
        
        CaseComment newCC = NI_TestClassData.createTestCaseComment(1, csId);
        insert newCC;
        
        
    }
    
}