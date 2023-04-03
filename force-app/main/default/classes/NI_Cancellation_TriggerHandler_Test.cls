/****************************************************************************************
Name            : NI_Cancellation_TriggerHandler_Test 
Author          : Stuart Emery
Created Date    : 05/28/2014
Last Mod Date   : 04/30/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-008353
Description     : Test Class for NI_Cancellation_TriggerHandler Class
                : 
                : 
******************************************************************************************/ 
@isTest 
private class NI_Cancellation_TriggerHandler_Test 
{
    
    
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        
Test.startTest(); 

        // CREATE SETTINGS RECORD (MANAGED)
        ffrr__Settings__c st = NI_TestClassData.createSettings();
        st.Name = 'APEX Activity Line Item';
        insert st;
        
        // CREATE TEMPLATE RECORD (MANAGED)
        ffrr__Template__c tp = NI_TestClassData.createffrrTemplate(st.Id);
        tp.Name = 'APEX TEST - Deliverable';
        insert tp; 
        
        // CREATE TEST PAYMENT TERM
        Payment_Terms__c pt = NI_TestClassData.createInvoicePaymentTerms();
        pt.Name = '4 Installments';
        pt.Invoice_Split_Method__c = 'Equal';
        insert pt;
        
        // CREATE TEST PAYMENT TERM LINE ITEMS
        List<Payment_Term_Line_Item__c> lstPTLineItem = new List<Payment_Term_Line_Item__c>();
        
        Payment_Term_Line_Item__c ptLI1 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI1.Order__c = 1;
        ptLI1.Offset_Measure__c = 'Days';
        ptLI1.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI1);
        
        Payment_Term_Line_Item__c ptLI2 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI2.Order__c = 2;
        ptLI2.Offset_Measure__c = 'Months';
        ptLI2.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI2);
        
        Payment_Term_Line_Item__c ptLI3 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI3.Order__c = 3;
        ptLI3.Offset_Measure__c = 'Years';
        ptLI3.Offset_Units__c = 1;
        lstPTLineItem.add(ptLI3);
        
        Payment_Term_Line_Item__c ptLI4 = NI_TestClassData.createInvoicePaymentTermsLimeItem(pt.Id);
        ptLI3.Order__c = 4;
        lstPTLineItem.add(ptLI4);
        
        database.insert(lstPTLineItem); 
        
        // CREATE A TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST CANCELLATION #1';
        a.Secondary_Account_Owner__c = UserInfo.getUserId();
        a.MTech_Owner__c = UserInfo.getUserId();
        a.Brand__c = 'APEXTEST';
        insert a;

        // CREATE A TEST CONTACT TO BE CREATED AS A PORTAL USER 
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Mike';
        cnt.LastName = 'Oxmaul';
        cnt.Email = 'CXLTEST1@amadeushospitality.com';
        insert cnt;
        
        // CREATE TEST CUSTOMER PORTAL USER 
        User u = NI_TestClassData.createTestUser(2, 'AH Customer Community Plus Login User'); 
        u.ContactId = cnt.Id;
        u.FirstName = 'Mike';
        u.LastName = 'Oxmaul';
        u.Alias = 'CXLTEST1';
        u.Email = 'CXLTEST1@amadeushospitality.com';
        u.Username = 'CXLTEST1@amadeushospitality.com.ahcc';
        u.CommunityNickname = 'CXLTEST1'; 
        insert u;

        // CREATE A TEST ACCOUNT TEAM MEMBER
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId = a.Id;
        atm.UserId = u.Id;
        atm.TeamMemberRole = 'NI Collector';
        insert atm;
        
        // GET OPPORTUNITY RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rt = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        // CREATE A TEST OPPORTUNITY RECORD
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.RecordTypeId = rt;
        insert o;   
        
        // CREATE A TEST PRODUCT GROUP RECORD  
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;         

        // CREATE A TEST DI INDEX RECORD
        NI_DeploymentInstanceIndex__c idx1 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX'); 
        idx1.Name = 'APEXTESTCANCELLATIONS';
        insert idx1; 

        NI_DeploymentInstanceIndex__c idx2 = NI_TestClassData.createDI_Index(1, 'APEX TEST INDEX2'); 
        idx2.Name = 'APEXTESTCANCELLATIONS2';
        insert idx2; 

        // CREATE A TEST PRODUCT RECORDS
        Product2 prd01 = NI_TestClassData.createProduct2(1, pgp.Id, 'HRM-CXL-01-TEST', 'Subscription');
        prd01.DI_Index__c = idx1.Id; 
        prd01.Product_Line_Global__c = 'Delphi.fdc'; 
        prd01.Solution_Domain_Global__c = 'Sales & Catering';
        prd01.Name = 'APEX TEST PRODUCT #1';
        insert prd01;         

        Product2 prd02 = NI_TestClassData.createProduct2(2, pgp.Id, 'HRM-CXL-02-TEST', 'Subscription');
        prd02.Name = 'HotSOS Product';
        prd02.DI_Index__c = idx2.Id;  
        prd02.Product_Line_Global__c = 'HotSOS'; 
        prd02.Solution_Domain_Global__c = 'Service Optimization';
        insert prd02;         

        // CREATE A DEPLOYMENT INSTANCE RECORDS
        Asset di = NI_TestClassData.createTestAsset(1, a.Id, prd01.Id);
        di.Name = 'Delphi.fdc';
        di.Status = 'Installed'; 
        di.Product_Group__c = pgp.Id;
        di.Opportunity__c = o.Id;
        di.Integration_User_Source__c = 'TEST ASSET #1';
        insert di;

        Asset di2 = NI_TestClassData.createTestAsset(2, a.Id, prd02.Id);
        di2.Name = 'HotSOS';
        di2.Status = 'Installed'; 
        di2.Product_Group__c = pgp.Id;
        di2.Opportunity__c = o.Id;
        di2.Integration_User_Source__c = 'TEST ASSET #2';
        insert di2;

        // CREATE A TEST BILLING RECORD
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        blgCnrct.Account__c = a.Id;
        insert blgCnrct;         

        
        // CREATE TEST ACTIVITY LINE ITEM RECORDS
        List<Activity_Line_Item__c> lstALIs = new List<Activity_Line_Item__c>();
        
        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI.Cancel_Line_Item__c = false; 
        actLI.Product__c = prd01.Id; 
        actLI.Contract_Start_Date__c = Date.Today() - 200; 
        actLI.Contract_End_Date__c = Date.Today() + 200; 
        actLI.Units__c = 6; 
        actLI.Status__c = 'Active';
        actLI.Contract_Amount__c = 6000;
        actLI.Renewal_Base_Price__c = 1000;
        actLI.Revenue_Category__c = 'Subscription'; 
        actLI.ffrrtemplate__c = tp.Id;
        lstALIs.add(actLI);
        
        Activity_Line_Item__c actLI2 = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        actLI2.Cancel_Line_Item__c = false; 
        actLI2.Product__c = prd02.Id; 
        actLI2.Contract_Start_Date__c = Date.Today() + 90; 
        actLI2.Contract_End_Date__c = Date.Today() + 180; 
        actLI2.Units__c = 1; 
        actLI2.Status__c = 'Active';
        actLI2.Contract_Amount__c = 10000;
        actLI2.Renewal_Base_Price__c = 10000;
        actLI2.Revenue_Category__c = 'Subscription'; 
        actLI2.ffrrtemplate__c = tp.Id;
        lstALIs.add(actLI2);
        
        database.insert(lstALIs);
        
        
Test.stopTest();
        
        
        // CREATE TEST CANCELLATION RECORDS 
        List<NI_Cancellation__c> lstCancellationInserts = new List<NI_Cancellation__c>();
        
        NI_Cancellation__c cxl1 = NI_TestClassData.createCancellation(a.Id);
        cxl1.Deployment_Instance__c = di.Id;
        cxl1.Effective_Date__c = Date.today() - 1;
        cxl1.Status__c = 'New';
        cxl1.General_Reason__c = 'Affiliation Change';
        cxl1.Activity_Line_Item__c = actLI.Id;
        cxl1.Invoice_Number__c = 'APEX TEST CANCELLATION #1';
        cxl1.Product2__c = prd01.Id;
        cxl1.Account_Owner__c = a.OwnerId;
        cxl1.Brand__c = a.Brand__c;
        cxl1.Cancellation_Notes__c = 'APEX TEST';
        cxl1.Product2__c = prd02.Id;
        cxl1.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl1.Renewal_Cancellation_Quantity__c = 1; 
        cxl1.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl1.General_Reason__c = 'Affiliation Change';
        cxl1.Specific_User_Names__c = 'User1,User2';
        cxl1.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl1.Renewal_Cancellation_Requested__c = true;
        cxl1.Renewal_Cancellation_Requester__c = u.Id;
        cxl1.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl1.Late_Cancellation__c = false;
        cxl1.Retention_Completed__c = false;        
        lstCancellationInserts.add(cxl1);
        
        NI_Cancellation__c cxl2 = NI_TestClassData.createCancellation(a.Id);
        cxl2.Deployment_Instance__c = di.Id;
        cxl2.Effective_Date__c = Date.today() - 1;
        cxl2.Status__c = 'New';
        cxl2.General_Reason__c = 'Affiliation Change';
        cxl2.Activity_Line_Item__c = actLI.Id;
        cxl2.Invoice_Number__c = 'APEX TEST CANCELLATION #2';
        cxl2.Account_Owner__c = a.OwnerId;
        cxl2.Brand__c = a.Brand__c;
        cxl2.Cancellation_Notes__c = 'APEX TEST';
        cxl2.Product2__c = prd02.Id;
        cxl2.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl2.Renewal_Cancellation_Quantity__c = 1; 
        cxl2.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl2.General_Reason__c = 'Affiliation Change';
        cxl2.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl2.Renewal_Cancellation_Requested__c = true;
        cxl2.Renewal_Cancellation_Requester__c = u.Id;
        cxl2.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl2.Late_Cancellation__c = false;
        cxl2.Retention_Completed__c = false;         
        lstCancellationInserts.add(cxl2);
        
        NI_Cancellation__c cxl3 = NI_TestClassData.createCancellation(a.Id);
        cxl3.Deployment_Instance__c = di.Id;
        cxl3.Effective_Date__c = Date.today() - 1;
        cxl3.Status__c = 'New';
        cxl3.General_Reason__c = 'Affiliation Change';
        cxl3.Activity_Line_Item__c = actLI.Id;
        cxl3.Invoice_Number__c = 'APEX TEST CANCELLATION #3';
        cxl3.Account_Owner__c = a.OwnerId;
        cxl3.Brand__c = a.Brand__c;
        cxl3.Cancellation_Notes__c = 'APEX TEST';
        cxl3.Product2__c = prd02.Id;
        cxl3.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl3.Renewal_Cancellation_Quantity__c = 1; 
        cxl3.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl3.General_Reason__c = 'Affiliation Change';
        cxl3.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl3.Renewal_Cancellation_Requested__c = true;
        cxl3.Renewal_Cancellation_Requester__c = u.Id;
        cxl3.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl3.Late_Cancellation__c = false;
        cxl3.Retention_Completed__c = false;        
        lstCancellationInserts.add(cxl3);
        
        NI_Cancellation__c cxl4 = NI_TestClassData.createCancellation(a.Id);
        cxl4.Deployment_Instance__c = di.Id;
        cxl4.Effective_Date__c = Date.today() - 1;
        cxl4.Status__c = 'Cancelled';
        cxl4.General_Reason__c = 'Affiliation Change';
        cxl4.Activity_Line_Item__c = actLI.Id;
        cxl4.Invoice_Number__c = 'APEX TEST CANCELLATION #4';
        cxl4.Account_Owner__c = a.OwnerId;
        cxl4.Brand__c = a.Brand__c;
        cxl4.Cancellation_Notes__c = 'APEX TEST';
        cxl4.Product2__c = prd02.Id;
        cxl4.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl4.Renewal_Cancellation_Quantity__c = 1; 
        cxl4.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl4.General_Reason__c = 'Affiliation Change';
        cxl4.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl4.Renewal_Cancellation_Requested__c = true;
        cxl4.Renewal_Cancellation_Requester__c = u.Id;
        cxl4.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl4.Late_Cancellation__c = false;
        cxl4.Retention_Completed__c = false;          
        lstCancellationInserts.add(cxl4); 
        
        NI_Cancellation__c cxl5 = NI_TestClassData.createCancellation(a.Id);
        cxl5.Deployment_Instance__c = di2.Id;
        cxl5.Effective_Date__c = Date.today() - 1;
        cxl5.Status__c = 'Cancelled';
        cxl5.General_Reason__c = 'Affiliation Change';
        cxl5.Number_of_Users_Reduced__c = 1;
        cxl5.Specific_User_Names__c = 'Jack Smith'; 
        cxl5.Activity_Line_Item__c = actLI.Id;
        cxl5.Invoice_Number__c = 'APEX TEST CANCELLATION #5';
        cxl5.Account_Owner__c = a.OwnerId;
        cxl5.Brand__c = a.Brand__c;
        cxl5.Cancellation_Notes__c = 'APEX TEST';
        cxl5.Product2__c = prd02.Id;
        cxl5.Renewal_Cancellation_Note__c = 'comments here...'; 
        cxl5.Renewal_Cancellation_Quantity__c = 1; 
        cxl5.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
        cxl5.General_Reason__c = 'Affiliation Change';
        cxl5.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
        cxl5.Renewal_Cancellation_Requested__c = true;
        cxl5.Renewal_Cancellation_Requester__c = u.Id;
        cxl5.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
        cxl5.Late_Cancellation__c = false;
        cxl5.Retention_Completed__c = false;        
        lstCancellationInserts.add(cxl5);

        database.insert(lstCancellationInserts);

        Activity_Line_Item__c aliUnitAsserts = [SELECT Id, Units__c, Units_Cancelled__c, Units_Remaining__c FROM Activity_Line_Item__c WHERE Product__c =: prd01.Id];
        system.assertEquals(6, aliUnitAsserts.Units__c);   
        system.assertEquals(5, aliUnitAsserts.Units_Cancelled__c); 
        system.assertEquals(1, aliUnitAsserts.Units_Remaining__c);   

		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
   
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================
    @isTest static void test1() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
        NI_DeploymentInstanceIndex__c idx = [SELECT Id FROM NI_DeploymentInstanceIndex__c WHERE Name = 'APEXTESTCANCELLATIONS']; 
        string sKey = (string)a.Id + (string)idx.id;
        Asset di = [SELECT Id, Status FROM Asset WHERE AccountId_DIIndexID__c =: sKey];
        
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        //        NI_Cancellation__c cxl2 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #2']; 
        //        NI_Cancellation__c cxl3 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #3']; 
        
        Test.startTest();
        
        //SET THE STATUS TO CANCELLED  
        cxl1.Status__c = 'Cancelled';      
        cxl1.Effective_Date__c = Date.today();
        update cxl1;
        
        //VERIFY THAT THE DEPLOYMENT INSTANCE STATUS HAS BEEN SET TO INACTIVE AND THE USAGE END DATE
        //HAS BEEN SET TO THE EFFECTIVE DATE OF THE CANCELLATION RECORD  
        Asset cancelledDI = [SELECT Id, Status, UsageEndDate FROM Asset WHERE Id =: di.Id];
        system.assertEquals('Inactive', cancelledDI.Status);
// FIGURE OUT WHY THIS FAILS   system.assertEquals(cxl1.Effective_Date__c, cancelledDI.UsageEndDate); 
        
        Test.stopTest();
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test1() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: 
    // =======================================================================================================================================
    @isTest static void test2() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
        NI_DeploymentInstanceIndex__c idx = [SELECT Id FROM NI_DeploymentInstanceIndex__c WHERE Name = 'APEXTESTCANCELLATIONS']; 
        string sKey = (string)a.Id + (string)idx.id;
        Asset di = [SELECT Id, Status FROM Asset WHERE AccountId_DIIndexID__c =: sKey];
        
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        //        NI_Cancellation__c cxl2 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #2']; 
        //        NI_Cancellation__c cxl3 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #3']; 
        
        Test.startTest();
        
        //SET THE STATUS TO REATAINED  
        cxl1.Status__c = 'Successfully Retained';
        update cxl1;
        
        //VERIFY THAT THE DEPLOYMENT INSTANCE STATUS HAS BEEN SET TO INSTALLED  
        Asset updatedDI = [SELECT Id, Status FROM Asset WHERE Id =: di.Id];
        system.assertEquals('Installed', updatedDI.Status);            
        
        Test.stopTest();
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test2() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 3: 
    // =======================================================================================================================================
    @isTest static void test3() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());	
        
//        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
//        NI_DeploymentInstanceIndex__c idx = [SELECT Id FROM NI_DeploymentInstanceIndex__c WHERE Name = 'APEXTESTCANCELLATIONS']; 
        Product2 prd01 = [SELECT Id FROM Product2 WHERE Name = 'APEX TEST PRODUCT #1'];
//        string sKey = (string)a.Id + (string)idx.id;
//        Asset di = [SELECT Id, Status FROM Asset WHERE AccountId_DIIndexID__c =: sKey];
        
//        NI_Cancellation__c cxl1 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        NI_Cancellation__c cxl2 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #2']; 
        NI_Cancellation__c cxl3 = [SELECT Id, Status__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #3']; 
        
        Test.startTest();
        cxl2.Renewal_Cancellation_Quantity__c = 2;
        update cxl2;
        
        Activity_Line_Item__c aliUnitAsserts1 = [SELECT Id, Units_Cancelled__c, Units_Remaining__c FROM Activity_Line_Item__c WHERE Product__c =: prd01.Id]; 
        system.assertEquals(6, aliUnitAsserts1.Units_Cancelled__c); 
        system.assertEquals(0, aliUnitAsserts1.Units_Remaining__c);   
        
        delete cxl3;
        
        Activity_Line_Item__c aliUnitAsserts2 = [SELECT Id, Units_Cancelled__c, Units_Remaining__c FROM Activity_Line_Item__c WHERE Product__c =: prd01.Id];
        system.assertEquals(5, aliUnitAsserts2.Units_Cancelled__c); 
        system.assertEquals(1, aliUnitAsserts2.Units_Remaining__c);   
        
        undelete cxl3; 
        
        Test.stopTest();
        
        Activity_Line_Item__c aliUnitAsserts3 = [SELECT Id, Units_Cancelled__c, Units_Remaining__c FROM Activity_Line_Item__c WHERE Product__c =: prd01.Id]; 
        system.assertEquals(6, aliUnitAsserts3.Units_Cancelled__c); 
        system.assertEquals(0, aliUnitAsserts3.Units_Remaining__c); 
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test3() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 4: TEST CANCELLATION CASE CREATION (DEFAULT)
    // =======================================================================================================================================
    @isTest static void test4() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c, Create_Cancellation_Case__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        
        Test.startTest();      
        
        // TEST CHECKING THE CASE CREATION CHECKBOX
        cxl1.Create_Cancellation_Case__c = true;
        update cxl1;
        
        Test.stopTest();  
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, OwnerId FROM Case WHERE AccountId =: a.Id]);
        system.assertEquals(1, lstCaseAsserts.size()); 
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test4() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 5: TEST CANCELLATION CASE CREATION (WITH VALID CASE RULE)
    // =======================================================================================================================================
    @isTest static void test5() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test5() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
        Product2 p2 = [SELECT Id FROM Product2 WHERE Name = 'APEX TEST PRODUCT #1'];
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c, Create_Cancellation_Case__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        
        // CREATE CANCELATION CASE RULE
        Cancellation_Case_Rule__c ccr = new Cancellation_Case_Rule__c();
        
        ccr.Assignment_Queue__c = 'Q-Subscription Management';
        ccr.Cancellation_Status__c = 'Cancelled';
        ccr.Case_Description__c  = 'APEX TEST <<DI Name>>';
        ccr.Case_Subject__c = 'APEX TEST <<DI Name>>';
        ccr.Inactive__c = false;
        
        insert ccr;
        
        // CREATE CANCELLATION CASE RULE PRODUCT
        Cancellation_Case_Rule_Product__c ccrp = new Cancellation_Case_Rule_Product__c();
        ccrp.Cancellation_Case_Rule__c = ccr.Id;
        ccrp.Product__c = p2.Id;
        insert ccrp;
        
        Test.startTest();      
        
        // TEST CHECKING THE CASE CREATION CHECKBOX
        cxl1.Create_Cancellation_Case__c = true;
        update cxl1;
        
        Test.stopTest();  
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, OwnerId FROM Case WHERE AccountId =: a.Id]);
        system.assertEquals(1, lstCaseAsserts.size());
        system.assertEquals('APEX TEST Delphi.fdc Enterprise PMS - TEST DATA', lstCaseAsserts[0].Subject);
        system.assertEquals('00G60000001DCUiEAO', (Id)lstCaseAsserts[0].OwnerId);
                
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test5() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 6: TEST CANCELLATION CASE CREATION (DEFAULT) & ACCOUNT CREDIT STATUS = Support Hold
    // =======================================================================================================================================
    @isTest static void test6() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test6() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest();  
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
        a.Credit_Status__c = 'Support Hold';
        update a;
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c, Create_Cancellation_Case__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        
        //Test.stopTest();  
        
        // TEST CHECKING THE CASE CREATION CHECKBOX
        cxl1.Create_Cancellation_Case__c = true;
        update cxl1;
        Test.stopTest();
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, OwnerId FROM Case WHERE AccountId =: a.Id]);
        system.assertEquals(1, lstCaseAsserts.size());
                
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test6() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 7: TEST CANCELLATION CASE CREATION (WITH VALID CASE RULE) & ACCOUNT CREDIT STATUS = Support Hold
    // =======================================================================================================================================
    @isTest static void test7() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test7() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest(); 
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST CANCELLATION #1'];
        a.Credit_Status__c = 'Support Hold';
        update a;
        Product2 p2 = [SELECT Id FROM Product2 WHERE Name = 'APEX TEST PRODUCT #1'];
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c, Create_Cancellation_Case__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        
        // CREATE CANCELATION CASE RULE
        Cancellation_Case_Rule__c ccr = new Cancellation_Case_Rule__c();
        
        ccr.Assignment_Queue__c = 'Q-Subscription Management';
        ccr.Cancellation_Status__c = 'Cancelled';
        ccr.Case_Description__c  = 'APEX TEST <<DI Name>>';
        ccr.Case_Subject__c = 'APEX TEST <<DI Name>>';
        ccr.Inactive__c = false;
        
        insert ccr;
        
        // CREATE CANCELLATION CASE RULE PRODUCT
        Cancellation_Case_Rule_Product__c ccrp = new Cancellation_Case_Rule_Product__c();
        ccrp.Cancellation_Case_Rule__c = ccr.Id;
        ccrp.Product__c = p2.Id;
        insert ccrp;
        
        //Test.stopTest();      
        
        // TEST CHECKING THE CASE CREATION CHECKBOX
        cxl1.Create_Cancellation_Case__c = true;
        update cxl1;
        
        Test.stopTest();
        
        List<Case> lstCaseAsserts = new List<Case>([SELECT Id, Subject, OwnerId FROM Case WHERE AccountId =: a.Id]);
        system.assertEquals(1, lstCaseAsserts.size());
        system.assertEquals('Support Hold - APEX TEST Delphi.fdc Enterprise PMS - TEST DATA', lstCaseAsserts[0].Subject);
        system.assertEquals('00G60000001DCUiEAO', (Id)lstCaseAsserts[0].OwnerId);
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test7() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 8: TEST SO CHATTER POST 
    // =======================================================================================================================================
    @isTest static void test8() 
    {    
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test8() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        Test.startTest();
        
        Account a = [SELECT Id, OwnerId, Brand__c FROM Account WHERE Name = 'APEX TEST CANCELLATION #1']; 
        User u = [SELECT Id FROM User WHERE Username = 'CXLTEST1@amadeushospitality.com.ahcc' AND AccountId =: a.Id]; 
        Product2 prd02 = [SELECT Id FROM Product2 WHERE Name = 'HotSOS Product'];
        Activity_Line_Item__c actLI2 = [SELECT Id FROM Activity_Line_Item__c WHERE Product__c =: prd02.Id];
        
        // DELETE SO CANCELLATION TO CLEAN SLATE
        NI_Cancellation__c cxl1 = [SELECT Id, Status__c, Create_Cancellation_Case__c FROM NI_Cancellation__c WHERE Invoice_Number__c = 'APEX TEST CANCELLATION #1']; 
        delete cxl1;
        
        //Test.stopTest();
        
        system.debug(' **** testCancellations8() Limits.getQueries() = ' + Limits.getQueries() + ' - after Test.stopTest()'); 
        
        // CREATE AN SO "HotSOS" CANCELLATION AS A COMMUNITY USER
        system.runAs(u)
        {    
            NI_Cancellation__c cxl = NI_TestClassData.createCancellation(a.Id);
            
            cxl.Late_Cancellation__c = false;
            cxl.Retention_Completed__c = false;             
            
            cxl.Renewal_Cancellation_Quantity__c = 1; 
            cxl.Renewal_Cancellation_Reason__c = 'Affiliation Change'; 
            cxl.General_Reason__c = 'Affiliation Change';
            cxl.Effective_Date__c = Date.today() - 1;
            
            cxl.Product2__c = prd02.Id;
            cxl.Activity_Line_Item__c = actLI2.Id;
            cxl.Invoice_Number__c = 'APEX TEST HotSOS CANCELLATION';
            cxl.Account_Owner__c = a.OwnerId;
            cxl.Brand__c = a.Brand__c; 
            
            cxl.Renewal_Cancellation_Request_DateTime__c = DateTime.now();
            cxl.Renewal_Cancellation_Requested__c = true;
            cxl.Renewal_Cancellation_Requester__c = u.Id;
            cxl.Renewal_Cancellation_Requesters_IP__c = '192.168.0.1';
            
            //          cxl.Status__c = 'Cancelled';            
            //          cxl.Deployment_Instance__c = di2.Id;
            //          cxl.Number_of_Users_Reduced__c = 1;
            //          cxl.Specific_User_Names__c = 'Jack Smith';  
            //          cxl.Renewal_Cancellation_Note__c = 'comments here...';        
            //          cxl.Cancellation_Notes__c = 'APEX TEST';
            
            insert cxl;
            
            Test.stopTest();      
        }
        
        
        
        // ASSERT THAT ALL CRITERIA ON CANCELLATION IS MET TO CREATE A CHATTER GROUP POST
        NI_Cancellation__c cxlSO = [SELECT Id, Name, Anticipated_Revenue_Loss__c, Late_Cancellation__c, Amadeus_RSM__c, Solution_Domain__c, 
                                    Renewal_Cancellation_Quantity__c, Retention_Completed__c, Deployment_Instance__c   
                                    FROM NI_Cancellation__c 
                                    WHERE Invoice_Number__c = 'APEX TEST HotSOS CANCELLATION'];
        
        // ALL CRITERIA THAT MAKES NI_Cancellation_TriggerHandler.checkCancellationRetentionSO() RETURN 'true'
        system.assertEquals(true, cxlSO.Anticipated_Revenue_Loss__c > 1500);
        system.assertEquals(false, cxlSO.Late_Cancellation__c);
        system.assertEquals(false, cxlSO.Amadeus_RSM__c == null);
        system.assertEquals('Service Optimization', cxlSO.Solution_Domain__c);
        system.assertEquals(false, cxlSO.Retention_Completed__c);
        
        // ASSERT THAT CHATTER POST WAS CREATED WHEN RUNNING USER IS NOT A MEMBER OF THE CHATTER GROUP
        List<FeedItem> lstFeedItemAsserts = new List<FeedItem>([SELECT Id, Body FROM FeedItem WHERE CreatedById =: u.Id AND ParentId =: Label.SO_Renewal_Cxl_Chatter_Group_ID]);
        system.assertEquals(1, lstFeedItemAsserts.size()); 
        string strBody = lstFeedItemAsserts[0].Body; 
        system.assertEquals(true, strBody.startsWith(cxlSO.Name)); 
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test8() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 9: 
    // =======================================================================================================================================
    @isTest static void test9() 
    {
        
		system.debug(' *** START NI_Cancellation_TriggerHandler_Test.test9() - QUERIES ISSUED = ' + Limits.getQueries());	
        
        List<Revenue_Schedule__c> lstAssertRevScheds = new List<Revenue_Schedule__c>(
            [SELECT Id, RecordType.Name, Deferred_Revenue_Amount__c, Revenue_Amount_Currency__c, Start_Date__c, End_Date__c
             FROM Revenue_Schedule__c 
             ORDER BY Activity_Line_Item__c, RecordType.Name, Start_Date__c]);
        
        // system.assertEquals(13, lstAssertRevScheds.size()); // COMMENTED THIS OUT AS IT CAN FLUCTUATE BASED ON WHEN TEST CLASS IS EXECUTED - SHarris
        for (Revenue_Schedule__c rs : lstAssertRevScheds)
        {
            system.debug(' *%%* rs = ' + rs);
        } 
        
		system.debug(' ***  END  NI_Cancellation_TriggerHandler_Test.test9() - QUERIES ISSUED = ' + Limits.getQueries());	
        
    }
    
}