/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachServiceTest Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/18/2019 
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     : Test class for the NI_WinaproachService class
                : Updated on 10/5/2017 Per NICC-024188
*************************************************************************************************/
@isTest
public class NI_WinaproachServiceTest 
{
    
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        system.debug(' *** ENTERING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();

        Winaproach_System_Affected__c systemAffected = new Winaproach_System_Affected__c();
        systemAffected.Name = 'Production';
        systemAffected.System_Category__c = 'P';
        insert systemAffected;        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PARENT ACCOUNT 1';
        insert a;

        Contact con = NI_TestClassData.createTestContact(1, a.Id);		
        con.RecordTypeID = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        con.FirstName = 'Apex';
        con.LastName = 'Tester';
        insert con;
        
        system.debug(' *** EXITING NI_WinaproachServiceHelperTest.createTestData() - NUMBER OF QUERIES = ' + limits.getQueries());
        
    }    

    // ======================================================================================================================================= 
    // = TEST METHOD 1: Test Prepare Create Request Winaproach
    // ======================================================================================================================================= 
    @isTest static void test1()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        
        List<Case> lstCases = new List<Case>();	
        List<Id> lstIds = new List<Id>();
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.Priority = '3';
        //cs.type = 'Inquiry';
        cs.Customer_Severity__c = '1';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.Status = 'Open';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        //cs.Reject_Reason_Code__c = 'Change required';		
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       	
        insert cs;
        lstIds.add(cs.id);
        lstCases.add(cs);            
        
        Attachment attach = new Attachment();   	
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = cs.id;
        insert attach;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();		
        //t.RecordTypeID = '012170000008l5k';
        t.RecordTypeID = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Amadeus Parallel Investigation').getRecordTypeId();    
        t.Subject='Donni';
        //t.Status='Not Started';
        t.Status='New';
        t.Priority='Normal';
        t.WhatId = cs.id;
        t.Parallel_Investigation_Group__c = 'MHDHOT';
        t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
        t.Added_By_Group__c = 'MHDHOT'; //new
        t.Description = 'Comments';
        t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO'; //new
        t.Sub_Status__c = 'External Info';
        system.debug('Task : '+t);
        //t.TaskSubtype = 'Email';
        insert t;
        
        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id); 
        csComment.CommentBody = 'comments';
        insert csComment;                        
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: Test winAproach Update Request
    // ======================================================================================================================================= 
    @isTest static void test2()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        Test.startTest();
        
        NI_WinaproachService.crsCaseIncidentFlag = false;
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());  
               
        List<Case> lstCases = new List<Case>();	
        List<Id> lstIds = new List<Id>();

        Case cs2 = new Case();
        cs2.Subject = 'TestBK- ttest10';
        cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs2.Priority = '3';
        cs2.type = 'Inquiry';
        cs2.Customer_Severity__c = '4';
        cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs2.status = 'Open';
        cs2.Winaproach_Logger__c = 'test';
        cs2.Description = 'Test description';
        cs2.Cause_Id_Code__c = 'Configuration';
        cs2.Resolution_Code__c = 'Code Correction';
        cs2.Reject_Reason_Code__c = 'Change required';		
        cs2.Winaproach_Logger_Phone_Number__c = '123456';
        cs2.Winaproach_Owner_Group__c = 'MHDHOT';
        cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs2.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs2.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        cs2.Amadeus_External_System_Id__c = '11098269';
        lstCases.add(cs2);        
        
        Case cs3 = new Case();
        cs3.Subject = 'TestBK- ttest10';
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '3';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.status = 'Open';
        cs3.Winaproach_Logger__c = 'test';
        cs3.Description = 'Test description';
        cs3.Cause_Id_Code__c = 'Configuration';
        cs3.Resolution_Code__c = 'Code Correction';
        cs3.Reject_Reason_Code__c = 'Change required';		
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs3.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        cs3.Amadeus_External_System_Id__c = '11098269';              
        lstCases.add(cs3);    
        insert lstCases;

        NI_WinaproachService.crsCaseIncidentFlag = false;
        
        Case updateCs = new Case();
        updateCs.Id = cs3.Id;
        updateCs.ParentId = cs2.Id;
        update updateCs;
        
        Test.stopTest(); 
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3: Test winAproach Update Request
    // =======================================================================================================================================     
    @isTest static void test3()
    {

        Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        Test.startTest();
        
        NI_WinaproachService.crsCaseIncidentFlag = false;
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());  

        List<Case> lstCases = new List<Case>();	
        List<Id> lstIds = new List<Id>();

        Case cs2 = new Case();
        cs2.Subject = 'TestBK- ttest10';
        cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs2.Priority = '3';
        cs2.type = 'Inquiry';
        cs2.Customer_Severity__c = '4';
        cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs2.status = 'Open';
        cs2.Winaproach_Logger__c = 'test';
        cs2.Description = 'Test description';
        cs2.Cause_Id_Code__c = 'Configuration';
        cs2.Resolution_Code__c = 'Code Correction';
        cs2.Reject_Reason_Code__c = 'Change required';		
        cs2.Winaproach_Logger_Phone_Number__c = '123456';
        cs2.Winaproach_Owner_Group__c = 'MHDHOT';
        cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs2.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs2.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        cs2.Amadeus_External_System_Id__c = '11098269';
        lstCases.add(cs2);

        Case cs3 = new Case();
        cs3.Subject = 'TestBK- ttest10';
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '3';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.status = 'Open';
        cs3.Winaproach_Logger__c = 'test';
        cs3.Description = 'Test description';
        cs3.Cause_Id_Code__c = 'Configuration';
        cs3.Resolution_Code__c = 'Code Correction';
        cs3.Reject_Reason_Code__c = 'Change required';		
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs3.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        cs3.Amadeus_External_System_Id__c = '11098269';	              
        lstCases.add(cs3);
        insert lstCases;

        NI_WinaproachService.crsCaseIncidentFlag = false;
        
        Case updateCs = new Case();
        updateCs.Id = cs3.Id;
        updateCs.ParentId = cs2.Id;
        update updateCs;
        
        Test.stopTest(); 
        
    }
/*
    // ======================================================================================================================================= 
    // = TEST METHOD 4: Test winAproach Work Order Request
    // =======================================================================================================================================     
    @isTest static void test4() 
    {

        //Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        //Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];
        
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        
        List<Case> lstCase = new List<Case>();	
        
        Case cs = new Case();
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Work Order').getRecordTypeId();
        cs.Priority = '3';
        cs.type = 'Inquiry';
        cs.Customer_Severity__c = '4';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs.status = 'Assigned';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';		
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Origin = 'ServiceNow Integration';
        cs.Acknowledged__c = Datetime.now().addHours(-4);
        insert cs;
        
        Case csUpdate = new Case();
        csUpdate.id = cs.Id;
        csUpdate.Status = 'Open';
        csUpdate.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Work Order').getRecordTypeId();
        csUpdate.Description = 'Updated desc';
        csUpdate.Acknowledged__c = Datetime.now().addHours(5);
        csUpdate.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        csUpdate.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        csUpdate.Winaproach_Logger__c = 'test2';
        csUpdate.Winaproach_Logger_Phone_Number__c = '123456789';
        csUpdate.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        csUpdate.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        csUpdate.Description = 'Test description 2';
        csUpdate.Status = 'Open';
        csUpdate.Customer_Severity__c ='3';
        csUpdate.Amadeus_External_System_Id__c = '11095094';
        csUpdate.Cause_Id_Code__c = 'Application';
        csUpdate.Resolution_Code__c = 'Environment';
        csUpdate.Reject_Reason_Code__c = 'Functional Setting';
        csUpdate.Winaproach_Owner_Group__c = 'MHDAIT';
        update csUpdate;
        
        system.debug(cs.RecordTypeID);
        lstCase.add(cs);
        
        Attachment attach = new Attachment();   	
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = cs.id;
        insert attach;
        
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();		
        //t.RecordTypeID = '012170000008l5k';
        t.RecordTypeID = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get('Amadeus Parallel Investigation').getRecordTypeId();    
        t.Subject='Donni';
        t.Status='Not Started';
        t.Priority='Normal';
        t.WhatId = cs.id;
        t.Parallel_Investigation_Group__c = 'MHDHOT';
        t.Parallel_Investigation_Reason_Code__c = 'SMC Investigation Completed';
        t.Added_By_Group__c = 'MHDHOT'; //new
        t.Description = 'Comments';
        t.PI_Group_Long_Names__c = 'Service Reliability Engineers - OCHOOO'; //new
        t.Sub_Status__c = 'External Info';
        //t.TaskSubtype = 'Email';
        insert t;   

        CaseComment csComment = NI_TestClassData.createTestCaseComment(1, cs.Id);
        csComment.CommentBody = 'comments';
        insert csComment;         

        update csUpdate;
        
        Test.stopTest();
        
    }
*/
    // ======================================================================================================================================= 
    // = TEST METHOD 5: Test winAproach Parse And Log Exception
    // =======================================================================================================================================     
    @isTest static void test5() 
    {
        
        Test.startTest();
        
        List<Case> lstCase = new List<Case>();	
        
        Case cs = new Case();
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.type = 'Inquiry';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Status = 'Recovered';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';	
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       
        insert cs; 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachServiceBatchMock());
        
        Test.stopTest();
        
    }
/*
    // ======================================================================================================================================= 
    // = TEST METHOD 6: Test winAproach Update Exception Request
    // =======================================================================================================================================     
    @isTest static void test6()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

		List<Case> lstCases = new List<Case>();	        
        List<Id> lstIds = new List<Id>();

        Case cs2 = new Case();
        cs2.Subject = 'TestBK- ttest10';
        cs2.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs2.Priority = '3';
        cs2.type = 'Inquiry';
        cs2.Customer_Severity__c = '4';
        cs2.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs2.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs2.status = 'Open';
        cs2.Amadeus_External_System_Id__c = '165950567';
        cs2.Winaproach_Logger__c = 'test';
        cs2.Description = 'Test description';
        cs2.Cause_Id_Code__c = 'Configuration';
        cs2.Resolution_Code__c = 'Code Correction';
        cs2.Reject_Reason_Code__c = 'Change required';		
        cs2.Winaproach_Logger_Phone_Number__c = '123456';
        cs2.Winaproach_Owner_Group__c = 'MHDHOT';
        cs2.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs2.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs2.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';          
        // cs2.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"            
        insert cs2;	
        
        Case cs3 = new Case();
        cs3.Subject = 'TestBK- ttest10';
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '3';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.Amadeus_External_System_Id__c = '110950567';
        cs3.status = 'Open';
        cs3.Winaproach_Logger__c = 'test';
        cs3.Description = 'Test description';
        cs3.Cause_Id_Code__c = 'Configuration';
        cs3.Resolution_Code__c = 'Code Correction';
        cs3.Reject_Reason_Code__c = 'Change required';		
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs3.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        insert cs3;	              
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
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
        cs.Cause_Id_Code__c = 'Application';
        cs.Resolution_Code__c = 'Environment';
        cs.Reject_Reason_Code__c = 'Change required';		
        cs.Winaproach_Logger_Phone_Number__c = '123456';
        cs.Winaproach_Owner_Group__c = 'MHDHOT';
        cs.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);		
        cs.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';			
        cs.Hotel_Code__c = '123';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';  
        cs.ParentId = cs2.Id;			
        insert cs;                 	
        
        Case updateCs = new Case();
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2';
        updateCs.Status = 'New';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';
        updateCs.System_Affected__c = 'Production';    
        updateCs.ParentId = cs3.Id;        	
        update updateCs;
        
        lstIds.add(cs.Id);
        lstCases.add(cs);     
        
        Test.startTest(); 

        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock()); 
        
        Test.stopTest(); 
        
    }
*/
    // ======================================================================================================================================= 
    // = TEST METHOD 7: Test winaproach Create Request Fault
    // =======================================================================================================================================     
    @isTest static void test7()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachServiceFaultMock());
        
        List<Case> lstCases = new List<Case>();	
        List<Id> lstIds = new List<Id>();
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.type = 'Inquiry';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Status = 'Recovered';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       
        insert cs;
        
        lstIds.add(cs.Id);
        lstCases.add(cs); 
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 8: Test winaproach Create Request Error
    // =======================================================================================================================================     
    @isTest static void test8()
    {
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachErrorMock());
        
        List<Case> lstCases = new List<Case>();	
        List<Id> lstIds = new List<Id>();
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.type = 'Inquiry';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Status = 'Recovered';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';	
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       
        insert cs;
        
        lstIds.add(cs.id);
        lstCases.add(cs); 
        
        Test.stopTest();  
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 9: Test winaproach Urgency Mapping Excp
    // =======================================================================================================================================     
    @isTest static void test9()
    {
        
		Account acc = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        Test.startTest(); 
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachErrorMock());
        
        List<Case> lstCases = new List<Case>();	
        List<Id> lstIds = new List<Id>();
        
        Case cs  = new Case();
        cs.AccountId = acc.Id;
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.type = 'Inquiry';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Status = 'Recovered';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';	
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       
        insert cs;
        
        lstIds.add(cs.Id);
        lstCases.add(cs);  
        
        Test.stopTest();  
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 10: Test Create Exception
    // =======================================================================================================================================     
    @isTest static void test10()
    {
        
		Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'Apex' AND LastName = 'Tester'];

        List<Case> lstCases = new List<Case>();	

        Case cs = NI_TestClassData.createTestCase(1, a.Id);
        cs.Subject = 'TestBK- ttest10';
        cs.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs.type = 'Inquiry';
        cs.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs.Status = 'Recovered';
        cs.Winaproach_Logger__c = 'test';
        cs.Description = 'Test description';	
        cs.Origin = 'Win@proach Integration';
        cs.System_Affected__c = 'Disaster Recovery';       
        lstCases.add(cs); 

        Case cs3 = NI_TestClassData.createTestCase(2, a.Id);
        cs3.Subject = 'TestBK- ttest10';
        cs3.RecordTypeID = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CRS Incident').getRecordTypeId();
        cs3.Priority = '3';
        cs3.type = 'Inquiry';
        cs3.Customer_Severity__c = '4';
        cs3.Amadeus_ExternalSystemAssigneeGroup__c = 'MHDHOT';
        cs3.Amadeus_ExternalSystemLoggerGroup__c = 'MHDAIT';
        cs3.status = 'Open';
        cs3.Winaproach_Logger__c = 'test';
        cs3.Description = 'Test description';
        cs3.Cause_Id_Code__c = 'Configuration';
        cs3.Resolution_Code__c = 'Code Correction';
        cs3.Reject_Reason_Code__c = 'Change required';		
        cs3.Winaproach_Logger_Phone_Number__c = '123456';
        cs3.Winaproach_Owner_Group__c = 'MHDHOT';
        cs3.Incident_Start_Date_Time__c = Datetime.now().addHours(-5); 
        cs3.Resolved_Date_and_Time__c = Datetime.now().addHours(-1);
        cs3.Assignment_Group__c = 'VN-GLBL-GRS Amadeus Level 3';
        // cs3.Pending_Code__c = 'Customer Question'; 		    // Causes Error: "bad value for restricted picklist field: Customer Question" because beforeInsert sets Status to "New"
        cs3.Amadeus_External_System_Id__c = 'External Id';
        lstCases.add(cs3);            

        database.insert(lstCases);
        
        Case updateCs = NI_TestClassData.createTestCase(3, a.Id);
        updateCs.Id = cs.Id;
        updateCs.Amadeus_ExternalSystemLoggerGroup__c = 'MHDHOT';
        updateCs.Amadeus_ExternalSystemAssigneeGroup__c = 'Newmarket';
        updateCs.Winaproach_Logger__c = 'test2&&';
        updateCs.Winaproach_Logger_Phone_Number__c = '123456789';
        updateCs.Incident_Start_Date_Time__c = Datetime.now().addHours(-4);
        updateCs.Resolved_Date_and_Time__c = Datetime.now().addHours(-2);
        updateCs.Description = 'Test description 2&&';
        updateCs.Status = 'New';
        updateCs.Customer_Severity__c ='3';
        updateCs.Amadeus_External_System_Id__c = '11095094';
        updateCs.Cause_Id_Code__c = 'Application';
        updateCs.Resolution_Code__c = 'Environment';
        updateCs.Reject_Reason_Code__c = 'Functional Setting';
        updateCs.System_Affected__c = 'Production';    
        updateCs.ParentId = cs3.Id;        	
        update updateCs;
        
        
        List<Id> lstIds = new List<Id>();        
        lstIds.add(cs.Id);

        Test.startTest();  
        
        Test.setMock(HttpCalloutMock.class, new NI_WinaproachTestMock());
        
        NI_WinaproachService.sendRequestToWinaproach(lstIds);
        
        Test.stopTest();                         

    }  
   
}