/************************************************************************************************
        !!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_WinSN_Case_Handler_Test Class
Author          : Sean Harris
Created Date    : 05/03/2018
Last Mod Date   : 01/16/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for INTGR_WinSN_Case_Handler
        : 
        : 
*************************************************************************************************/
@isTest
public class INTGR_WinSN_Case_Handler_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================      
    @testSetup static void setup() 
    {
        
        // CREATE TEST ACCOUNT
        Account acc = NI_TestClassData.createTestAccount(1);
        acc.Name = 'INTGR_WinSN_Case_Handler_Test Account';
        insert acc;
        
        Contact con = NI_TestClassData.createTestContact(1, acc.id);    
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();    
        insert con;
        
        User waUser = NI_TestClassData.createTestUser(121, 'Winaproach Integration Only - Standard'); 
        waUser.UserName = 'winaproachTEST@newmarketinc.com.nextdev3';
        insert waUser;         
        
        User snUser = NI_TestClassData.createTestUser(122, 'IHG Integration Only - Standard'); 
        snUser.UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3';
        insert snUser;         
        
        User newUser = NI_TestClassData.createTestUser(123, 'Case Integration Customers'); 
        newUser.UserName = 'servicenowTEST@newmarketinc.com.nextdev3';
        insert newUser; 
        
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
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1:
    // =======================================================================================================================================       
    static testMethod void testWinaproachCase()
    {

        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account'];

        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        
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
        
        system.debug('Case created...');
        
        Attachment attach = new Attachment();     
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = cs.id;
        insert attach;
        system.debug('attachment created...');
                
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
        system.debug('Task created...');
        
        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id); 
        csComment.CommentBody = 'comments';
        insert csComment;    
        system.debug('comment created...');
        
        
        Test.stopTest();
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2:
    // =======================================================================================================================================     
    static testMethod void testServiceNowCase()
    {
        
        Account a1 = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account'];
    User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3'];
        
        //NI_ServicenowIntegration serviceNowIntegration = new NI_ServicenowIntegration();
        //serviceNowIntegration.isAttachment = false;
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3']);
        system.assertEquals(1, lstUserAsserts.Size());
        
        List<Case> listOfCases = new List<Case>();
        
        //Account a1 = NI_TestClassData.createTestAccount(1);
        //insert a1;
        
        //Contact con = NI_TestClassData.createTestContact(1, a1.id);    
        //insert con;
        
        Case cs = NI_TestClassData.createTestCase(1, a1.Id);
        
        system.runAs(cUser) 
        {
            cs = new Case();
            cs.Subject = 'TestBK- ttest10';
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test';
            cs.Description = 'Test description';  
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Amadeus_External_System_Id__c = '10762030';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Customer_Ticket_Number__c = 'INC0010116';
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'ServiceNow Integration';
            cs.Integration_Sync_Status__c = true;
            cs.Description = 'Test Description 1';
            insert cs;               
            listOfCases.add(cs);
        }   
        
        Case updateCs = NI_TestClassData.createTestCase(1, a1.Id);
        
        List<Case> casesToUpdate = new List<Case>();
        updateCs.Id = cs.Id;
        updateCs.subject = 'new subject';
        updateCs.Assignment_Group__c = 'MY-GLBL-Service Desk Level 3';
        updateCs.Status = 'Recovered';
        updateCs.Customer_Severity__c ='2';
        updateCs.Resolution_Summary__c = '1';
        updateCs.Resolution_Code__c = '1';
        updateCs.Description = 'Test Description 2';
        update updateCs;
        casesToUpdate.add(updateCs);
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id FROM Case]);
        system.assertEquals(1, lstCaseAsserts.Size());
        
        //Attachment attach=new Attachment(); 
        Attachment attach = NI_TestClassData.createTestAttachment(a1.Id);
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = updateCs.id;
        insert attach;
        
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());
        Test.stopTest();
        
    }
    
    //======================================================================================================================================= 
    // = TEST METHOD 3:
    // =======================================================================================================================================     
    static testMethod void testUpdateIncidentsSN1()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account' ];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3' ];
        
        system.debug('TEST ACCOUNT RECORD :--' + acc);
        system.debug('TEST USER RECORD :--' + cUser);
        
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();    

        //GETTING CUSTOM SETTING VALUES
        //ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        //NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        integer i = 1;
        
        //CREATING CASE
        Case cs1 = new Case();
        Case cs2 = new Case();
        Case cs3 = new Case();
        
        List<Case> listOfCase = new List<Case>();  
        Set<Id> case_ids = new Set<Id>();
        
        mapRetriesID.put(cs1.Id, 1);
        system.debug('mapRetriesID  :' + mapRetriesID);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());         
        system.debug('**********setMock METHOD CALL YES:--' );
        Test.startTest();
        
        system.runAs(cUser) 
        { 
            
            cs1.Subject = 'Test_' + i;
            cs1.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs1.Priority = '3';
            cs1.type = 'Inquiry';
            cs1.Customer_Severity__c = '1';
            cs1.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs1.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs1.Status = 'New';
            cs1.Winaproach_Logger__c = 'test' + i;
            cs1.Description = 'Test description' + i;
            cs1.Cause_Id_Code__c = 'Application';
            cs1.Reject_Reason_Code__c = '';    
            cs1.Winaproach_Logger_Phone_Number__c = '123456';
            cs1.Winaproach_Owner_Group__c = 'MHDHOT';
            cs1.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs1.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs1.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs1.Hotel_Code__c = '123';
            cs1.Origin = 'ServiceNow Integration';
            cs1.System_Affected__c = 'Disaster Recovery';
            cs1.Customer_Severity__c = '2';
            cs1.Resolution_Summary__c = '1';
            cs1.Resolution_Code__c = '1';
            //cs1.INTGR_Create_Ticket_in_Customer_System__c = false;
            
            i++;
            
            cs2.Subject = 'Test_' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '3';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '1';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '123';
            cs2.Origin = 'ServiceNow Integration';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.Customer_Severity__c = '2';
            cs2.Resolution_Summary__c = '1';
            cs2.Resolution_Code__c = '1';
            
            i++;
            cs3.Subject = 'Test_' + i;
            cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs3.Priority = '3';
            cs3.type = 'Inquiry';
            cs3.Customer_Severity__c = '1';
            cs3.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs3.Status = 'New';
            cs3.Winaproach_Logger__c = 'test' + i;
            cs3.Description = 'Test description' + i;
            cs3.Cause_Id_Code__c = 'Application';
            cs3.Winaproach_Logger_Phone_Number__c = '1234563';
            cs3.Winaproach_Owner_Group__c = 'MHDHOT';
            cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs3.Hotel_Code__c = '123';
            cs3.Origin = 'ServiceNow Integration';
            cs3.System_Affected__c = 'Disaster Recovery';
            cs3.Customer_Severity__c = '2';
            cs3.Resolution_Summary__c = '1';
            cs3.Resolution_Code__c = '1';
            
            listOfCase.add(cs1);
            listOfCase.add(cs2);
            listOfCase.add(cs3);
            insert listOfCase; 
            
            //system.debug(' CASE ADDED LIST  listOfCase :--' + listOfCase );  
          
        }
        system.debug('listOfCase.Size() :--' + listOfCase.Size());
        
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug('*********case_list.size()  :' + case_list.size());
            system.debug('*********case_list  :--' + case_list);
            system.assertEquals(3, case_list.size());
            
            for (case c : case_list) 
            {
                case_ids.add(c.Id);
            }
            
            system.debug(' **** case_ids : ' + case_ids);
            //*********** SPLIT METHOD FOR SN3**********
            
            // SETTING ALL CASE STATUSES TO Acknowledged
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];
            cs_1.Status = 'Acknowledged';
            cs_1.Amadeus_External_System_Id__c = '110950';
            update_list_1.add(cs_1);
            
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[1];
            cs_2.Status = 'Acknowledged';
            cs_2.Amadeus_External_System_Id__c = '110951';
            update_list_1.add(cs_2);
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[2];
            cs_3.Status = 'Acknowledged';
            cs_3.Amadeus_External_System_Id__c = '110952';
            update_list_1.add(cs_3);
            
            update update_list_1;
            
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 1 : ' + case_list_1);
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            system.assertEquals('Acknowledged', case_list_1[1].Status);
            system.assertEquals('Acknowledged', case_list_1[2].Status);
            
            List<Case> update_list_2 = new List<Case>();
            
            Case cs_11 = new Case();
            cs_11.Id = (new List<Id>(case_ids))[0];
            //cs_11.Amadeus_External_System_Id__c = '110950';
            cs_11.Status = 'Rejected PCP';
            update_list_2.add(cs_11);
            
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[1];
            //cs_22.Amadeus_External_System_Id__c = '110951';
            cs_22.Status = 'Open';
            update_list_2.add(cs_22);
            
            Case cs_33 = new Case();
            cs_33.Id = (new list<Id>(case_ids))[2];
            //cs_33.Amadeus_External_System_Id__c = '110952';
            cs_33.Status = 'Recovered';
            update_list_2.add(cs_33);
            
            update update_list_2;
            
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 2 : ' + case_list_2); //
            system.assertEquals('Rejected PCP', case_list_2[0].Status);
            system.assertEquals('Open', case_list_2[1].Status);
            system.assertEquals('Recovered', case_list_2[2].Status);
            
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
        
        /*List<Case> uptListSN = new List<Case>();
        
        system.runAs(cUser) 
        { 
            
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];
            cs_1.Status = 'Closed';              // FORMERLY 'Rejected PCP'
            //cs_1.Amadeus_External_System_Id__c = '110950';
            uptListSN.add(cs_1);
            
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[1];
            cs_2.Status = 'Recovered';             // FORMERLY 'Open'
            //cs_2.Amadeus_External_System_Id__c = '110951';
            uptListSN.add(cs_2);
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[2];
            cs_3.Status = 'Closed';              // FORMERLY 'Recovered'
            //cs_3.Amadeus_External_System_Id__c = '110952';
            uptListSN.add(cs_3);
            
            update uptListSN;
            
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 3 : ' + case_list_3);//
            system.assertEquals('Closed as rejected', case_list_3[0].Status);
            system.assertEquals('Open', case_list_3[1].Status);
            system.assertEquals('Closed as recovered', case_list_3[2].Status);
            
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[1];
            cs_22.Status = 'Closed';
            //cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list_4 : ' + case_list_4); //
            system.assertEquals('Closed as withdrawn', case_list_4[1].Status);
        }**/
        
        Test.StopTest();
        
    }
    
    //====================================================================================================================
    // = TEST METHOD 4:
    //====================================================================================================================
   
     static testMethod void testUpdateIncidentsSN2()
    {
        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account' ];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3' ];
        
        system.debug('TEST ACCOUNT RECORD :--' + acc);
        system.debug('TEST USER RECORD :--' + cUser);
        
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();    

        //GETTING CUSTOM SETTING VALUES
        //ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        //NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        integer i = 1;
        
        //CREATING CASE
        //Case cs1 = new Case();
        Case cs2 = new Case();
       // Case cs3 = new Case();
        
        List<Case> listOfCase = new List<Case>();  
        Set<Id> case_ids = new Set<Id>();
        
        mapRetriesID.put(cs2.Id, 1);
        system.debug('mapRetriesID  :' + mapRetriesID);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());         
        system.debug('**********setMock METHOD CALL YES:--' );
        
        Test.startTest();
        
        system.runAs(cUser) 
        { 
          
            cs2.Subject = 'Test_' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '3';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '1';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '123';
            cs2.Origin = 'ServiceNow Integration';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.Customer_Severity__c = '2';
            cs2.Resolution_Summary__c = '1';
            cs2.Resolution_Code__c = '1';
          
            listOfCase.add(cs2);
            insert listOfCase; 
            
            system.debug(' CASE ADDED LIST  listOfCase :--' + listOfCase );  
          
        }
        system.debug('listOfCase.Size() :--' + listOfCase.Size());
        
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 1];
            system.debug('*********case_list.size()  :' + case_list.size());
            system.debug('*********case_list  :--' + case_list);
            system.assertEquals(1, case_list.size());
            
            for (case c : case_list) 
            {
                case_ids.add(c.Id);
            }
            
            system.debug(' **** case_ids : ' + case_ids);
            //*********** SPLIT METHOD FOR SN3**********
            
            // SETTING ALL CASE STATUSES TO Acknowledged
          
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[0];
            cs_2.Status = 'Acknowledged';
            cs_2.Amadeus_External_System_Id__c = '110951';
            update_list_1.add(cs_2);
          
            update update_list_1;
            
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 1 : ' + case_list_1);
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            
            
            List<Case> update_list_2 = new List<Case>();
          
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[0];
            //cs_22.Amadeus_External_System_Id__c = '110951';
            cs_22.Status = 'Open';
            update_list_2.add(cs_22);
         
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 2 : ' + case_list_2); //
            //system.assertEquals('Rejected PCP', case_list_2[0].Status);
            //system.assertEquals('Open', case_list_2[0].Status);
            //system.assertEquals('Recovered', case_list_2[2].Status);
            
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
       
        List<Case> uptListSN = new List<Case>();
        
        system.runAs(cUser) 
        { 
         
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[0];
            cs_2.Status = 'Recovered';             // FORMERLY 'Open'
            //cs_2.Amadeus_External_System_Id__c = '110951';
            uptListSN.add(cs_2);
           
            update uptListSN;
            
            system.debug('****uptListSN  :' + uptListSN );
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 3 : ' + case_list_3);//
            //system.assertEquals('Closed as rejected', case_list_3[0].Status);
            //system.assertEquals('Closed ', case_list_3[0].Status);
            //system.assertEquals('Open', case_list_3[1].Status);
            system.assertEquals('Recovered', case_list_3[0].Status);
            
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Status = 'Closed';
            //cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list_4 : ' + case_list_4); //
//            system.assertEquals('Closed as recovered', case_list_4[0].Status);
            
            
        }
        
        Test.StopTest();
        
    }
   
    //=======================================================================================================================
    // = TEST METHOD 5:
    //=======================================================================================================================
    
    static testMethod void testUpdateIncidentsSN3()
    {
         Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account' ];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3' ];
        
        system.debug('TEST ACCOUNT RECORD :--' + acc);
        system.debug('TEST USER RECORD :--' + cUser);
        
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();    

        //GETTING CUSTOM SETTING VALUES
        //ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        //NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        integer i = 1;
        
        //CREATING CASE
        //Case cs1 = new Case();
        //Case cs2 = new Case();
        Case cs3 = new Case();
        
        List<Case> listOfCase = new List<Case>();  
        Set<Id> case_ids = new Set<Id>();
        
        mapRetriesID.put(cs3.Id, 1);
        system.debug('mapRetriesID  :' + mapRetriesID);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());         
        system.debug('**********setMock METHOD CALL YES:--' );
        
        Test.startTest();
        
        system.runAs(cUser) 
        { 
            
            cs3.Subject = 'Test_' + i;
            cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs3.Priority = '3';
            cs3.type = 'Inquiry';
            cs3.Customer_Severity__c = '1';
            cs3.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs3.Status = 'New';
            cs3.Winaproach_Logger__c = 'test' + i;
            cs3.Description = 'Test description' + i;
            cs3.Cause_Id_Code__c = 'Application';
            cs3.Winaproach_Logger_Phone_Number__c = '1234563';
            cs3.Winaproach_Owner_Group__c = 'MHDHOT';
            cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs3.Hotel_Code__c = '123';
            cs3.Origin = 'ServiceNow Integration';
            cs3.System_Affected__c = 'Disaster Recovery';
            cs3.Customer_Severity__c = '2';
            cs3.Resolution_Summary__c = '1';
            cs3.Resolution_Code__c = '1';
            
            
            listOfCase.add(cs3);
            insert listOfCase; 
            
        }
        system.debug('listOfCase.Size() :--' + listOfCase.Size());
        
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 1];
            system.debug('*********case_list.size()  :' + case_list.size());
            system.debug('*********case_list  :--' + case_list);
            system.assertEquals(1, case_list.size());
            
            for (case c : case_list) 
            {
                case_ids.add(c.Id);
            }
            
            system.debug(' **** case_ids : ' + case_ids);
            //*********** SPLIT METHOD FOR SN3**********
            
            // SETTING ALL CASE STATUSES TO Acknowledged
           
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[0];
            cs_3.Status = 'Acknowledged';
            cs_3.Amadeus_External_System_Id__c = '110952';
            update_list_1.add(cs_3);
            
            update update_list_1;
            
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 1 : ' + case_list_1);
            system.assertEquals('Acknowledged', case_list_1[0].Status);
                        
            List<Case> update_list_2 = new List<Case>();
          
            Case cs_33 = new Case();
            cs_33.Id = (new list<Id>(case_ids))[0];
            //cs_33.Amadeus_External_System_Id__c = '110952';
            cs_33.Status = 'Recovered';
            update_list_2.add(cs_33);
            
            update update_list_2;
            
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 2 : ' + case_list_2); //
            //system.assertEquals('Rejected PCP', case_list_2[0].Status);
            //system.assertEquals('Open', case_list_2[1].Status);
            //system.assertEquals('Recovered', case_list_2[2].Status);
            
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
       
        List<Case> uptListSN = new List<Case>();
        
        system.runAs(cUser) 
        { 
          
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[0];
            cs_3.Status = 'Closed';              
            //cs_3.Amadeus_External_System_Id__c = '110952';
            uptListSN.add(cs_3);
            
            update uptListSN;
            
            system.debug('****uptListSN  :' + uptListSN );
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 3 : ' + case_list_3);//
            //system.assertEquals('Closed as rejected', case_list_3[0].Status);
            //system.assertEquals('Closed ', case_list_3[0].Status);
            //system.assertEquals('Open', case_list_3[1].Status);
            //system.assertEquals('Closed as recovered', case_list_3[2].Status);
              
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Status = 'Closed';
            //cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list_4 : ' + case_list_4); //
            //system.assertEquals('Closed as withdrawn', case_list_4[0].Status);
            
        }
              
        Test.StopTest();
    }
    
    //CREATE SN5 METHOD
    //========================================================================================================================================
    // = TEST METHOD 6:
    //========================================================================================================================================
    static testMethod void testUpdateIncidentsSN4()
    {
         
        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account' ];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3' ];
        
        system.debug('TEST ACCOUNT RECORD :--' + acc);
        system.debug('TEST USER RECORD :--' + cUser);
        
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();    

        //GETTING CUSTOM SETTING VALUES
        //ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        //NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
        integer i = 1;
        
        //CREATING CASE
        Case cs1 = new Case();
        Case cs2 = new Case();
        Case cs3 = new Case();
        
        List<Case> listOfCase = new List<Case>();  
        Set<Id> case_ids = new Set<Id>();
        
        mapRetriesID.put(cs1.Id, 1);
        system.debug('mapRetriesID  :' + mapRetriesID);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock());         
        system.debug('**********setMock METHOD CALL YES:--' );
        Test.startTest();
        
        system.runAs(cUser) 
        { 
            
            cs1.Subject = 'Test_' + i;
            cs1.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs1.Priority = '3';
            cs1.type = 'Inquiry';
            cs1.Customer_Severity__c = '1';
            cs1.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs1.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs1.Status = 'New';
            cs1.Winaproach_Logger__c = 'test' + i;
            cs1.Description = 'Test description' + i;
            cs1.Cause_Id_Code__c = 'Application';
            cs1.Reject_Reason_Code__c = '';    
            cs1.Winaproach_Logger_Phone_Number__c = '123456';
            cs1.Winaproach_Owner_Group__c = 'MHDHOT';
            cs1.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs1.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs1.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs1.Hotel_Code__c = '123';
            cs1.Origin = 'ServiceNow Integration';
            cs1.System_Affected__c = 'Disaster Recovery';
            cs1.Customer_Severity__c = '2';
            cs1.Resolution_Summary__c = '1';
            cs1.Resolution_Code__c = '1';
            //cs1.INTGR_Create_Ticket_in_Customer_System__c = false;
            

            
            listOfCase.add(cs1);
            
            insert listOfCase; 
            
            //system.debug(' CASE ADDED LIST  listOfCase :--' + listOfCase );  
          
        }
        system.debug('listOfCase.Size() :--' + listOfCase.Size());
        
        
        try 
        { 
            
            List<Case> update_list_1 = new List<Case>();
            
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 1];
            system.debug('*********case_list.size()  :' + case_list.size());
            system.debug('*********case_list  :--' + case_list);
            system.assertEquals(1, case_list.size());
            
            for (case c : case_list) 
            {
                case_ids.add(c.Id);
            }
            
            system.debug(' **** case_ids : ' + case_ids);
            //*********** SPLIT METHOD FOR SN3**********
            
            // SETTING ALL CASE STATUSES TO Acknowledged
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];
            cs_1.Status = 'Acknowledged';
            cs_1.Amadeus_External_System_Id__c = '110950';
            update_list_1.add(cs_1);
            
            update update_list_1;
            
            List<Case> case_list_1 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 1];
            system.debug(' **** case_list 1 : ' + case_list_1);
            system.assertEquals('Acknowledged', case_list_1[0].Status);
            
            
            List<Case> update_list_2 = new List<Case>();
            
            Case cs_11 = new Case();
            cs_11.Id = (new List<Id>(case_ids))[0];
            //cs_11.Amadeus_External_System_Id__c = '110950';
            cs_11.Status = 'Rejected PCP';
            update_list_2.add(cs_11);
            
            update update_list_2;
            
            List<Case> case_list_2 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 2 : ' + case_list_2); //
            system.assertEquals('Rejected PCP', case_list_2[0].Status);
            
            
        }
        catch (Exception e) 
        {
            system.debug('Exception at Line : ' + e.getLineNumber() + ' => ' + e);
        }
        
        List<Case> uptListSN = new List<Case>();
        
        system.runAs(cUser) 
        { 
            
            Case cs_1 = new Case();
            cs_1.Id = (new List<Id>(case_ids))[0];
            cs_1.Status = 'Closed';              // FORMERLY 'Rejected PCP'
            //cs_1.Amadeus_External_System_Id__c = '110950';
            uptListSN.add(cs_1);
          
            update uptListSN;
            
            List<Case> case_list_3 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list 3 : ' + case_list_3);//
            system.assertEquals('Closed as rejected', case_list_3[0].Status);
            
                
            Case cs_22 = new Case();
            cs_22.Id = (new List<Id>(case_ids))[0];
            cs_22.Status = 'Closed';
            //cs_22.Amadeus_External_System_Id__c = '110951';
            update cs_22;
            
            List<Case> case_list_4 = [SELECT Id, Subject, Status FROM Case ORDER BY Subject];
            system.debug(' **** case_list_4 : ' + case_list_4); //
            //ystem.assertEquals('Closed as withdrawn', case_list_4[1].Status);
        }
        
        Test.StopTest(); 
        
    }
   
    // ======================================================================================================================================= 
    // = TEST METHOD 7:
    // =======================================================================================================================================     
    static testMethod void testUpdateIncidentsSN5()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account' ];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3'];
        
        system.debug('****acc :' + acc);
        system.debug('****cUser :' + cUser );
        
        List<Case> listOfCase = new List<Case>();  
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer>  mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new  Map<Id, NI_Integration_Log__c>();     

        integer i = 1;
        
        //CREATING CASE
        Case cs = new Case();
        Case cs2 = new Case();
        Case cs3 = new Case();
        Case cs4 = new Case();
        Case cs5 = new Case();
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest10' + i;
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            //cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test' + i;
            cs.Description = 'Test description' + i;
            cs.Cause_Id_Code__c = 'Application';
            //cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.Status = 'Recovered';
            cs.Customer_Severity__c = '2';
            cs.Resolution_Summary__c = '1';
            cs.Resolution_Code__c = '1';
            //cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Create_Ticket_in_Customer_System__c = false;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            
            i++;
            cs2.Subject = 'TestBK- ttest1' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '1';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '4';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            //cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '1231';
            cs2.Origin = 'Salesforce';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.INTGR_Create_Ticket_in_Customer_System__c = false;
            
            listOfCase.add(cs);
            listOfCase.add(cs2); 
            
            system.debug('********listOfCase :' + listOfCase);
        }
        
        i++;
        cs3.Subject = 'TestBK- ttest' + i;
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '1';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.Status = 'New';
        cs3.Reject_Reason_Code__c = 'Invalid';
        cs3.Rejected_Case__c = true;
        cs3.Winaproach_Logger__c = 'test' + i;
        cs3.Description = 'Test description' + i;
        cs3.Cause_Id_Code__c = 'Application';
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs3.Hotel_Code__c = '1231';
        cs3.Origin = 'Salesforce';
        cs3.System_Affected__c = 'Disaster Recovery';
        //cs3.INTGR_Create_Ticket_in_Customer_System__c = true;
        listOfCase.add(cs3);
        
        system.debug('********listOfCase :' + listOfCase);

        i++;
        cs4.Subject = 'TestBK- ttest' + i;
        cs4.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs4.Priority = '1';
        cs4.type = 'Inquiry';
        cs4.Customer_Severity__c = '4';
        cs4.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs4.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs4.Status = 'New';
        cs4.Rejected_Case__c = True;
        cs4.Reject_Reason_Code__c = 'Change Required';
        cs4.Acknowledged__c = Datetime.now();
        cs4.Winaproach_Logger__c = 'test' + i;
        cs4.Description = 'Test description' + i;
        cs4.Cause_Id_Code__c = 'Application';
        cs4.Winaproach_Logger_Phone_Number__c = '123456';
        cs4.Winaproach_Owner_Group__c = 'MHDHOT';
        cs4.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs4.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs4.Hotel_Code__c = '1231';
        cs4.Origin = 'Salesforce';
        cs4.System_Affected__c = 'Disaster Recovery';
        listOfCase.add(cs4); 
        
        system.debug('********listOfCase :' + listOfCase);

        i++;
        cs5.Subject = 'TestBK- ttest' + i;
        cs5.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs5.Priority = '1';
        cs5.type = 'Inquiry';
        cs5.Customer_Severity__c = '4';
        cs5.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
        cs5.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs5.Status = 'New';
        cs5.Rejected_Case__c = false;
        cs5.Winaproach_Logger__c = 'test' + i;
        cs5.Description = 'Test description' + i;
        cs5.Cause_Id_Code__c = 'Application';
        cs5.Winaproach_Logger_Phone_Number__c = '123456';
        cs5.Winaproach_Owner_Group__c = 'MHDHOT';
        cs5.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs5.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs5.Hotel_Code__c = '1231';
        cs5.Origin = 'Salesforce';
        cs5.System_Affected__c = 'Disaster Recovery';
        listOfCase.add(cs5);
        
        system.debug('********listOfCase :' + listOfCase);

        mapRetriesID.put(cs.Id, 1);
        system.debug('*****mapRetriesID :' + mapRetriesID);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock()); 
        
        system.debug('***TEST .SET MOCK CALL YESS---:');
        Test.startTest();
        
        try
        { 
            insert listOfCase; 
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;
            
            List<Case> ulist = new List<Case>();
            
            //CASE TO BE UPDATED
            Case updateCs = new Case();
            updateCs.Id = cs.Id;
            updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
            updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
            updateCs.Winaproach_Logger__c = 'test2';
            updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
            updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
            updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
            updateCs.Description = 'Test description 2';
            updateCs.Status = 'Rejected';
            updateCs.INTGR_Recovery_Plan_Date_Time__c = Datetime.now();
            updateCs.Amadeus_External_System_Id__c = '11095094';
            updateCs.Cause_Id_Code__c = 'Application';
            updateCs.Resolution_Code__c = 'Environment';
            updateCs.Reject_Reason_Code__c = 'Functional Setting';            
            updateCs.INTGR_Create_Ticket_in_Customer_System__c = true;
            //Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
            //update updateCs;
            ulist.add(updateCs);
            cs5.Status = 'Open';
            ulist.add(cs5);
            system.debug('ulist : ' + ulist );
            update ulist;
            
            
        } 
        catch (Exception e)
        { 
        }
        
        //RUN AS INTEGRATION USER
        system.runAs(cUser) 
        { 
            List<Case> update_list = new List<Case>();
            
            //CASE TO BE UPDATED
            cs2.Status = 'Acknowledged';
            cs2.Amadeus_External_System_Id__c = '110950941';
            update_list.add(cs2);
            
            cs3.Status = 'Recovered';
            cs3.Amadeus_External_System_Id__c = '110950921';
            update_list.add(cs3);
            
            cs4.Status = 'Acknowledged';
            cs4.Amadeus_External_System_Id__c = '1109501';
            update_list.add(cs4);
            
            cs5.Status = 'Recovered';
            cs5.Amadeus_External_System_Id__c = '110950';
            update_list.add(cs5);
            
            system.debug('update_list :' + update_list);
            update update_list;
            system.debug(' ******update_list is Updated.' );
            
        }
        
       
        Test.stopTest();
        
    } 
    
     //========================================================================================================================================
     // = TEST METHOD 8:
    //========================================================================================================================================
   
    static testMethod void testUpdateIncidentsSN6()
    {
         Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account' ];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3'];
        
        system.debug('****acc :' + acc);
        system.debug('****cUser :' + cUser );
        
        List<Case> listOfCase = new List<Case>();  
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer>  mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new  Map<Id, NI_Integration_Log__c>();     

        integer i = 1;
        
        Set<Id> case_ids = new Set<Id>();
        
        //CREATING CASE
        Case cs = new Case();
        Case cs2 = new Case();
        Case cs3 = new Case();
        Case cs4 = new Case();
        Case cs5 = new Case();
        
        system.runAs(cUser) 
        { 
            cs.Subject = 'TestBK- ttest10' + i;
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            //cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test' + i;
            cs.Description = 'Test description' + i;
            cs.Cause_Id_Code__c = 'Application';
            //cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            cs.Status = 'Recovered';
            cs.Customer_Severity__c = '2';
            cs.Resolution_Summary__c = '1';
            cs.Resolution_Code__c = '1';
            //cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Create_Ticket_in_Customer_System__c = false;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            
            listOfCase.add(cs);
            
            
            i++;
            cs2.Subject = 'TestBK- ttest1' + i;
            cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs2.Priority = '1';
            cs2.type = 'Inquiry';
            cs2.Customer_Severity__c = '4';
            cs2.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
            cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            cs2.Status = 'New';
            cs2.Winaproach_Logger__c = 'test' + i;
            cs2.Description = 'Test description' + i;
            cs2.Cause_Id_Code__c = 'Application';
            cs2.Winaproach_Logger_Phone_Number__c = '123456';
            cs2.Winaproach_Owner_Group__c = 'MHDHOT';
            cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            //cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs2.Hotel_Code__c = '1231';
            cs2.Origin = 'Salesforce';
            cs2.System_Affected__c = 'Disaster Recovery';
            cs2.INTGR_Create_Ticket_in_Customer_System__c = false;
            
            
            //listOfCase.add(cs2); 
            
            system.debug('********listOfCase :' + listOfCase);
        }
        
        i++;
        cs3.Subject = 'TestBK- ttest' + i;
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '1';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.Status = 'New';
        cs3.Reject_Reason_Code__c = 'Invalid';
        cs3.Rejected_Case__c = true;
        cs3.Winaproach_Logger__c = 'test' + i;
        cs3.Description = 'Test description' + i;
        cs3.Cause_Id_Code__c = 'Application';
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs3.Hotel_Code__c = '1231';
        cs3.Origin = 'Salesforce';
        cs3.System_Affected__c = 'Disaster Recovery';
        //cs3.INTGR_Create_Ticket_in_Customer_System__c = true;
        listOfCase.add(cs3);
        
        system.debug('********listOfCase :' + listOfCase);

        i++;
        cs4.Subject = 'TestBK- ttest' + i;
        cs4.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs4.Priority = '1';
        cs4.type = 'Inquiry';
        cs4.Customer_Severity__c = '4';
        cs4.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs4.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs4.Status = 'New';
        cs4.Rejected_Case__c = True;
        cs4.Reject_Reason_Code__c = 'Change Required';
        cs4.Acknowledged__c = Datetime.now();
        cs4.Winaproach_Logger__c = 'test' + i;
        cs4.Description = 'Test description' + i;
        cs4.Cause_Id_Code__c = 'Application';
        cs4.Winaproach_Logger_Phone_Number__c = '123456';
        cs4.Winaproach_Owner_Group__c = 'MHDHOT';
        cs4.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs4.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs4.Hotel_Code__c = '1231';
        cs4.Origin = 'Salesforce';
        cs4.System_Affected__c = 'Disaster Recovery';
        listOfCase.add(cs4); 
        
        system.debug('********listOfCase :' + listOfCase);

        i++;
        cs5.Subject = 'TestBK- ttest' + i;
        cs5.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs5.Priority = '1';
        cs5.type = 'Inquiry';
        cs5.Customer_Severity__c = '4';
        cs5.Amadeus_ExternalSystemAssigneeGroup__c  = 'MHDHOT';
        cs5.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs5.Status = 'New';
        cs5.Rejected_Case__c = false;
        cs5.Winaproach_Logger__c = 'test' + i;
        cs5.Description = 'Test description' + i;
        cs5.Cause_Id_Code__c = 'Application';
        cs5.Winaproach_Logger_Phone_Number__c = '123456';
        cs5.Winaproach_Owner_Group__c = 'MHDHOT';
        cs5.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs5.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs5.Hotel_Code__c = '1231';
        cs5.Origin = 'Salesforce';
        cs5.System_Affected__c = 'Disaster Recovery';
     
        listOfCase.add(cs5);
        
        system.debug('********listOfCase :' + listOfCase);

        mapRetriesID.put(cs.Id, 1);
        system.debug('*****mapRetriesID :' + mapRetriesID);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock()); 
        
        system.debug('***TEST .SET MOCK CALL YESS---:');
        Test.startTest();
        
         try
        { 
            insert listOfCase; 
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;
            
            List<Case> ulist = new List<Case>();
            
            //CASE TO BE UPDATED
            Case updateCs = new Case();
            updateCs.Id = cs.Id;
            updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
            updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
            updateCs.Winaproach_Logger__c = 'test2';
            updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
            updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
            updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
            updateCs.Description = 'Test description 2';
            updateCs.Status = 'Rejected';
            updateCs.INTGR_Recovery_Plan_Date_Time__c = Datetime.now();
            updateCs.Amadeus_External_System_Id__c = '11095094';
            updateCs.Cause_Id_Code__c = 'Application';
            updateCs.Resolution_Code__c = 'Environment';
            updateCs.Reject_Reason_Code__c = 'Functional Setting';            
            updateCs.INTGR_Create_Ticket_in_Customer_System__c = true;
            //Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
            //update updateCs;
            ulist.add(updateCs);
            cs5.Status = 'Open';
            ulist.add(cs5);
            system.debug('ulist : ' + ulist );
            update ulist;
            
          
            
        } 
        catch (Exception e)
        { 
        }
        
        //RUN AS INTEGRATION USER
        system.runAs(cUser) 
        { 
            
              
            List<Case> update_list_1 = new List<Case>();
            
            List<Case> case_list = [SELECT Id, Subject, Status FROM Case ORDER BY Subject LIMIT 2 ];
            system.debug('*********case_list.size()  :' + case_list.size());
            system.debug('*********case_list  :--' + case_list);
            
            for (case c : case_list) 
            {
                case_ids.add(c.Id);
            }
            
            system.debug(' **** case_ids : ' + case_ids);
            //*********** SPLIT METHOD FOR SN3**********
            
            
            Case cs_2 = new Case();
            cs_2.Id = (new List<Id>(case_ids))[0];
            cs_2.Status = 'Acknowledged';
            cs_2.Amadeus_External_System_Id__c = '110951';
            update_list_1.add(cs_2);
            
            Case cs_3 = new Case();
            cs_3.Id = (new List<Id>(case_ids))[1];
            cs_3.Status = 'Recovered';
            cs_3.Amadeus_External_System_Id__c = '110952';
            update_list_1.add(cs_3);
            
            update update_list_1;
              
        }
        
        Test.stopTest();
        
    }

    
    // ======================================================================================================================================= 
    // = TEST METHOD 5:
    // =======================================================================================================================================     
    static testMethod void testUpdateIncidentsQueable()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'INTGR_WinSN_Case_Handler_Test Account'];
        User cUser = [SELECT Id FROM User WHERE UserName = 'ihg_servicenowTEST@newmarketinc.com.nextdev3'];
        
        List<Case> listOfCase = new List<Case>(); 
        Map<Id, Id> mapOfCaseIds = new Map<Id, Id>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        Map<Id, NI_Integration_Log__c> mapNiIntLog = new Map<Id, NI_Integration_Log__c>();     

        integer i = 1;
        
        //CREATING CASE
        Case cs = new Case();
        
        system.runAs(cUser) 
        { 
            
            cs.Subject = 'TestBK- ttest10' + i;
            cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
            cs.Priority = '3';
            cs.type = 'Inquiry';
            cs.Customer_Severity__c = '1';
            cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
            cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
            //cs.Status = 'New';
            cs.Winaproach_Logger__c = 'test' + i;
            cs.Description = 'Test description' + i;
            cs.Cause_Id_Code__c = 'Application';
            //cs.Resolution_Code__c = 'Environment';
            cs.Reject_Reason_Code__c = 'Change required';    
            cs.Winaproach_Logger_Phone_Number__c = '123456';
            cs.Winaproach_Owner_Group__c = 'MHDHOT';
            cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
            cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
            cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
            cs.Hotel_Code__c = '123';
            cs.Origin = 'Win@proach Integration';
            cs.System_Affected__c = 'Disaster Recovery';
            
            cs.Status = 'Recovered';
            cs.Customer_Severity__c ='2';
            cs.Resolution_Summary__c = '1';
            cs.Resolution_Code__c = '1';
            //cs.INTGR_Create_Ticket_in_Customer_System__c = true;
            cs.INTGR_Create_Ticket_in_Customer_System__c = false;
            //cs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            //cs.Integration_Sync_Status__c = true;
            listOfCase.add(cs); 
            //CASE INSERTED   
        }

        mapRetriesID.put(cs.Id, 1);
        Test.setMock(HttpCalloutMock.class, new NI_ServicenowIntegrationTestMock(1)); 
        
        try
        { 
            
            insert listOfCase; 
            CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
            csComment.CommentBody = 'test comments';
            insert csComment;
            Test.startTest();
            NI_ServicenowIntegration.updateAttCaseCmtSN = true;
            
            Id testParentId = cs.Id;
            Attachment at = NI_TestClassData.createTestAttachment(testParentId);
            
            //ATTACHMENT INSERTED
            at.Name = 'TestDocument-1';
            insert at;
            
            //CASE TO BE UPDATED
            Case updateCs = new Case();
            
            updateCs.Id = cs.Id;
            updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
            updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
            updateCs.Winaproach_Logger__c = 'test2';
            updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
            updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
            updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
            updateCs.Description = 'Test description 2';
            updateCs.Status = 'Rejected';
            //updateCs.Customer_Severity__c ='3';
            updateCs.Amadeus_External_System_Id__c = '11095094';
            updateCs.Cause_Id_Code__c = 'Application';
            updateCs.Resolution_Code__c = 'Environment';
            updateCs.Reject_Reason_Code__c = 'Functional Setting';            
            updateCs.INTGR_Create_Ticket_in_Customer_System__c = true;
            updateCs.INTGR_Customer_Ticket_System_Id__c = 'abc';
            updateCs.Customer_Ticket_Number__c = '12345';
            //Test.setMock(HttpCalloutMock.class,new NI_ServicenowIntegrationTestMock(1)); 
            update updateCs;
        }
        catch(Exception e)
        {
            
        }
        
    }    
    
}