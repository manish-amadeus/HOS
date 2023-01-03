/************************************************************************************************
Name            : AH_PSA_Project_TriggerHandler_Test Class
Author          : CLD Partners
Created Date    : 10/28/2011
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
*************************************************************************************************/
@isTest 
public class AH_PSA_Project_TriggerHandler_Test 
{
    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        system.debug(' START - AH_PSA_Project_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Date dt = system.date.today();

        Test.StartTest();
        
        // CREATE A SYSTEM ADMIN USER TO INSERT THE TEST USER RECORDS TO AVOID MIXED_DML_OPERATION 
        User saUser = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        saUser.Alias = 'SA1TST'; 
        insert saUser;         
        
        system.runAs(saUser)
        {
            // CREATE TEST REGIONAL APPROVER USER
            User u1 = NI_TestClassData.createTestUser(2, 'NI PSA Administrator'); 
            u1.FirstName = 'Regional';
            u1.LastName = 'Admin';
            u1.Alias = 'RGA1TST'; 
            insert u1; 
            
            // CREATE TEST RESOURCE MANAGER USER 
            User u2 = NI_TestClassData.createTestUser(3, 'NI PSA Management'); 
            u2.FirstName = 'PSAResource';
            u2.LastName = 'Manager';
            u2.Alias = 'MGR1TST'; 
            insert u2; 
            
            // CREATE TEST RESOURCE USER 
            User u3 = NI_TestClassData.createTestUser(4, 'NI PSA T&E - Salesforce'); 
            u3.FirstName = 'PSAResource';
            u3.LastName = 'Resource';
            u3.Alias = 'RSC1TST'; 
            u3.ManagerId = u2.Id;
            insert u3;             
        }

        // GET TEST USERS CREATED BY FAKE ADMIN
        User regionApprover = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrceMgr = [SELECT Id FROM User WHERE Alias = 'MGR1TST'];
        User resrce = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];
        
        
		// CREATE A TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PSA ACCOUNT';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;        

        // CREATE A TEST CONTACT
        Contact cust = NI_TestClassData.createTestContact(1, a.Id);
        cust.LastName = 'Smith';
        insert cust;
        
        // GET A TEST OPPORTUNITY
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX TEST OPPORTUNITY 1';
        o.RecordTypeId = opptyRecTypeId;
        insert o;        

        // GET A TEST OPPORTUNITY CONTACT ROLE
        OpportunityContactRole ocr = NI_TestClassData.createTestOpportunityContactRole(o.Id, cust.Id, 'Customer Project Contact');
        insert ocr; 
        
        // CREATE A TEST PSA REGION  
        pse__Region__c region = NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        region.Name = 'psaTestRegion';  
        region.Central_Expense_Approver__c = regionApprover.Id;
        insert region;   
        
        pse__Region__c regionAssert = [SELECT Id, pse__Region_ID_Chain__c, pse__Region_Name_Chain__c FROM pse__Region__c WHERE Name = 'psaTestRegion'];
        system.assertEquals(region.Id, regionAssert.pse__Region_ID_Chain__c);
        system.assertEquals(region.Name, regionAssert.pse__Region_Name_Chain__c);
              
        
        // CREATE TEST PSA SCHEDULES  
    	pse__Schedule__c sched = NI_TestClassData.createTestSchedule(dt, dt);
        insert sched;
        
    	pse__Schedule__c sched2 = NI_TestClassData.createTestSchedule(dt, dt);
        insert sched2;
        
        // CREATE A TEST PSA PRACTICE  
    	pse__Practice__c practice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        practice.Name = 'psaTestPractice';
    	insert practice;

        // CREATE TEST WORK CALENDAR
        pse__Work_Calendar__c WorkCalendar = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
        insert WorkCalendar;    
        
        // CREATE TEST GROUP
        pse__Grp__c grp = NI_TestClassData.createTestPSEGroup('Test Group');
        insert grp;   

        // CREATE "RESOURCE MANAGER" CONTACT 
        Contact cntMgr = NI_TestClassData.createTestContact(1, a.Id);        
        cntMgr.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId(); 
        cntMgr.FirstName = 'PSAResource';
        cntMgr.LastName = 'Manager';
        cntMgr.pse__Region__c = region.Id;
        cntMgr.pse__Practice__c = practice.Id;
        cntMgr.pse__Work_Calendar__c = WorkCalendar.Id;
        cntMgr.pse__Group__c = grp.Id;
    	cntMgr.pse__Is_Resource_Active__c = true;
    	cntMgr.pse__Is_Resource__c = true;
        cntMgr.pse__Salesforce_User__c = resrceMgr.Id;
    	insert cntMgr; 
        
        // GRANT ACCESS TO RESOURCE MANAGER TO REGION
        pse__Permission_Control__c pc1 = NI_TestClassData.createTestPermissionControl(resrceMgr.Id);
        pc1.pse__Region__c = region.Id;
        pc1.pse__Staffing__c = true; 
        insert pc1;         
        
        // CREATE "RESOURCE" CONTACT 
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);        
        cnt.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId(); 
        cnt.FirstName = 'PSAResource';
        cnt.LastName = 'Resource';
        cnt.pse__Region__c = region.Id;
        cnt.pse__Practice__c = practice.Id;
        cnt.pse__Work_Calendar__c = WorkCalendar.Id;
        cnt.pse__Group__c = grp.Id;
    	cnt.pse__Is_Resource_Active__c = true;
    	cnt.pse__Is_Resource__c = true;
        cnt.pse__Salesforce_User__c = resrce.Id;
    	insert cnt; 

        // GRANT ACCESS TO RESOURCE MANAGER TO RESOURCE
        pse__Permission_Control__c pc2 = NI_TestClassData.createTestPermissionControl(resrceMgr.Id); 
        pc2.pse__Resource__c = cnt.Id; 
        pc2.pse__Staffing__c = true; 
        insert pc2; 

        // CREATE A TEST PSA PROJECT 
    	pse__Proj__c prj = NI_TestClassData.createTestProject(1, 'Test Project', region, practice, 'Draft', null); 
        prj.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Standard Project').getRecordTypeId(); 
        prj.Name = 'Test Project'; 
        prj.pse__Closed_for_Expense_Entry__c = false; 
        prj.pse__Project_Manager__c = cntMgr.Id; 
        prj.pse__Start_Date__c = dt.addDays(10); 
        prj.pse__End_Date__c = dt.addDays(20); 
        prj.pse__Account__c = a.Id; 
        prj.pse__Opportunity__c = o.Id;
    	insert prj;

        pse__Proj__c prjAsserts = [SELECT Id, pse__Project_Manager__c, pse__Project_Manager__r.pse__Salesforce_User__c, 
                                   pse__Is_Billable__c, pse__Stage__c, Customer_Project_Contact__c, pse__Billed__c    
                                   FROM pse__Proj__c 
                                   WHERE Name = 'Test Project'];
        
        system.assertEquals('Draft', prjAsserts.pse__Stage__c); 
        system.assertEquals(true, prjAsserts.pse__Is_Billable__c);        
        system.assertEquals(cntMgr.Id, prjAsserts.pse__Project_Manager__c); 
        system.assertEquals(resrceMgr.Id, prjAsserts.pse__Project_Manager__r.pse__Salesforce_User__c); 
        system.assertEquals(cust.Id, prjAsserts.Customer_Project_Contact__c);		// FORMALLY TEST FOR testTrigger_ProjectBI_SetCustomerProjectContact
        system.assertEquals(0, prjAsserts.pse__Billed__c);
        
        // CREATE TEST BILLING CONTRACT 
        Billing_Contract__c bc = NI_TestClassData.createBillingContract(1);
        bc.Account__c = a.Id;
        bc.Name = 'APEX TEST 1';
        insert bc;

        // CREATE TEST ACTIVITY LINE ITEM 
        Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(bc.Id);
        ali.Account__c = a.Id;
        insert ali;         

        Test.stopTest(); 
        
        system.debug(' END - AH_PSA_Project_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: FORMALLY TEST FOR testTrigger_ProjectAU_OpenMilestones()
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {  
        
        system.debug(' START - AH_PSA_Project_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Contact pmResource = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PSA ACCOUNT'];
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Account__c =: a.Id];
        pse__Proj__c tp = [SELECT Id, Name, pse__Closed_for_Expense_Entry__c, pse__Stage__c, pse__Project_Manager__c, pse__Is_Billable__c,                     
                           RecordTypeId, pse__Start_Date__c, pse__End_Date__c, pse__Account__c, pse__Opportunity__c 
                           FROM pse__Proj__c 
                           WHERE Name = 'Test Project'];
        
        Test.StartTest();        

        // Assign different types of milestones each in Draft status  
        List<pse__Milestone__c> lstMilestoneInserts = new List<pse__Milestone__c>();
        
        pse__Milestone__c tm1 = NI_TestClassData.createTestMilestoneNoALI('Test Open Billable Milestone', tp, true, true, 'Billable Milestone');
        tm1.Activity_Line_Item__c = ali.Id;
        lstMilestoneInserts.add(tm1);          
        
        pse__Milestone__c tm2 = NI_TestClassData.createTestMilestoneNoALI('Test Open Complimentary Milestone', tp, true, true, 'Complimentary');
        tm2.Activity_Line_Item__c = ali.Id;
        lstMilestoneInserts.add(tm2);
        
        pse__Milestone__c tm3 = NI_TestClassData.createTestMilestoneNoALI('Test Open Goodwill Milestone', tp, true, true, 'Goodwill');
        lstMilestoneInserts.add(tm3);
        
        pse__Milestone__c tm4 = NI_TestClassData.createTestMilestoneNoALI('Test Open Inclusive Milestone', tp, true, true, 'Inclusive Milestone');
		lstMilestoneInserts.add(tm4);

        pse__Milestone__c tm5 = NI_TestClassData.createTestMilestoneNoALI('Test Open Hourly Milestone', tp, true, true, 'Hourly Milestone');
    	lstMilestoneInserts.add(tm5);
        
        database.insert(lstMilestoneInserts);
        
        // UPDATE PROJECT
        tp.pse__Project_Manager__c = pmResource.Id;
        tp.pse__Stage__c = 'In Progress';

        // Added by Stu Emery on 10/22/2012 per NICC-005564
        tp.pse__Start_Date__c = system.today();
        // Added by Stu Emery on 8/29/2013 per NICC-007914
        tp.pse__End_Date__c = system.today() + 30;

        NI_TriggerManager.is1stUpdate_Project = true;
        update tp;
        
        pse__Proj__c tpAssert = [SELECT Id, pse__Stage__c, pse__Project_Manager__c, pse__Is_Billable__c FROM pse__Proj__c WHERE Name = 'Test Project']; 
        system.assertEquals('In Progress', tpAssert.pse__Stage__c);
        system.assertEquals(pmResource.Id, tpAssert.pse__Project_Manager__c);
		system.assertEquals(true, tpAssert.pse__Is_Billable__c);

        // Check the milestone statuses to make sure they got set appropriately
        for (pse__Milestone__c ms : [SELECT Id, Name, pse__Status__c, Milestone_Type__c 
                                     FROM pse__Milestone__c 
                                     WHERE pse__Project__c =: tp.Id
                                     AND (NOT Name LIKE 'Project Manager Time%')])
        {
            if (ms.Milestone_Type__c == 'Billable Milestone')
            {
               system.assertEquals('Open', ms.pse__Status__c); 
            }
            else if (ms.Milestone_Type__c == 'Complimentary')
            {
                system.assertEquals('Open', ms.pse__Status__c); 
            }
            else if (ms.Milestone_Type__c == 'Goodwill')
            {
                system.assertEquals('Open', ms.pse__Status__c);
            }
            else if (ms.Milestone_Type__c == 'Inclusive Milestone')
            {
               system.assertEquals('Open', ms.pse__Status__c);
            }
            // REMOVED PER MARY DUGDALE
            //else if (ms.Milestone_Type__c == 'Hourly Milestone')
            //{
            //    system.assertEquals('Draft/Tentative', ms.pse__Status__c);                
            //}
        }
        
        Test.stopTest();
        
        system.debug(' END - AH_PSA_Project_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 2: FORMALLY TEST FOR testTrigger_ProjectBU_ValidateNoBillingEventsToCancel
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {  
        
        system.debug(' START - AH_PSA_Project_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Date dt = system.date.today();
        
        pse__Region__c r = [SELECT Id FROM pse__Region__c WHERE Name = 'psaTestRegion']; 
        pse__Practice__c p = [SELECT Id FROM pse__Practice__c WHERE Name = 'psaTestPractice'];  
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PSA ACCOUNT'];
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Account__c =: a.Id];
        pse__Proj__c tp1 = [SELECT Id, Name, pse__Closed_for_Expense_Entry__c, pse__Stage__c, pse__Project_Manager__c, pse__Is_Billable__c, pse__Billed__c,                     
                           RecordTypeId, pse__Start_Date__c, pse__End_Date__c, pse__Account__c, pse__Opportunity__c, pse__Region__c, pse__Practice__c  
                           FROM pse__Proj__c 
                           WHERE Name = 'Test Project'];               

        Test.StartTest(); 
        
//        system.assertNotEquals(0, tp1.pse__Billed__c);
        
        // First create a project with no related billing events and make sure it can get set to Canceled
        tp1.pse__Stage__c = 'Canceled';
        
//Billing events already exist this project. It may not be set to Canceled status.        
        
        
        NI_TriggerManager.is1stUpdate_Project = true;
        update tp1;
        
        pse__Proj__c updatedProject = [SELECT pse__Stage__c FROM pse__Proj__c WHERE Id =: tp1.Id];
        system.assertEquals('Canceled', updatedProject.pse__Stage__c);
        
        // Next create a project an approved Milestone having a billing event, to make sure it can't get cancelled
        // public static pse__Proj__c createTestProject(Integer iRecordNumber, String projectName, pse__Region__c region, pse__Practice__c practice, String projectStage, Opportunity opp)
    	pse__Proj__c tp2 = NI_TestClassData.createTestProject(1, 'Test Project 2', r, p, 'Draft', null); 
        tp2.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Standard Project').getRecordTypeId(); 
        tp2.Name = 'Test Project 2'; 
        tp2.pse__Closed_for_Expense_Entry__c = false; 
        //tp2.pse__Project_Manager__c = cntMgr.Id; 
        tp2.pse__Start_Date__c = dt.addDays(10); 
        tp2.pse__End_Date__c = dt.addDays(20); 
        tp2.pse__Account__c = a.Id; 
        tp2.pse__Is_Billable__c = true;
        tp2.pse__Billed__c = 1000;
        
        NI_TriggerManager.is1stInsert_Project = true;
    	insert tp2;        
        
        pse__Proj__c tp2Assert = [SELECT Id, Name, pse__Is_Billable__c, pse__Billed__c, pse__Stage__c                      
                                  FROM pse__Proj__c 
                                  WHERE Id =: tp2.Id]; 
        system.assertEquals('Draft', tp2Assert.pse__Stage__c);
        system.assertEquals(true, tp2Assert.pse__Is_Billable__c);
        system.assertEquals(1000, tp2Assert.pse__Billed__c);
        
        pse__Milestone__c tm = NI_TestClassData.createTestMilestoneNoALI('Test Open Billable Milestone', tp2, true, true, 'Billable Milestone');
        tm.Activity_Line_Item__c = ali.Id;
		insert tm;  
        
        tm.pse__Actual_Date__c = Date.newInstance(2011, 11, 25);
        tm.pse__Status__c = 'Approved';
        tm.pse__Approved__c = true;
        tm.pse__Include_In_Financials__c = true;
        tm.pse__Billable_Amount_In_Financials__c = 1200;
        update tm;
 
        // Create a billing event for the milestone

        // pse__Billing_Event_Batch__c beb = new pse__Billing_Event_Batch__c();
        pse__Billing_Event_Batch__c beb = NI_TestClassData.createTestBillingEventBatch();
        insert beb;
        
        // pse__Billing_Event__c be = new pse__Billing_Event__c(pse__Billing_Event_Batch__c=beb.Id, pse__Project__c = tp2.Id);
        pse__Billing_Event__c be = NI_TestClassData.createTestBillingEvent(beb.Id, tp2.Id);
        insert be;        
 
        //pse__Billing_Event_Item__c bei = new pse__Billing_Event_Item__c(pse__Billing_Event_Batch__c=beb.Id, pse__Billing_Event__c=be.Id, pse__Project__c=tp2.Id, pse__Category__c='Milestone', pse__Object_Id__c=tm.Id);
        pse__Billing_Event_Item__c bei = NI_TestClassData.createTestBillingEventItem(beb.Id, be.Id, tp2.Id, tm.Id);
        bei.pse__Category__c = 'Milestone';
        insert bei;

        
        // Try to cancel the project
        boolean errorOccurred = false;
        
        try
        {       
            tp2.pse__Stage__c = 'Canceled';
            NI_TriggerManager.is1stUpdate_Project = true;
            update tp2;
        }
        catch (Exception e)
        {
            errorOccurred = true;
        }
        
        system.assert(errorOccurred);
        
        pse__Proj__c updatedProject2 = [SELECT pse__Stage__c FROM pse__Proj__c WHERE Id =: tp2.Id];
        
        system.assertEquals('Draft', updatedProject2.pse__Stage__c); 
        
        Test.stopTest();
        
        system.debug(' END - AH_PSA_Project_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3: Tests and asserts changes to Project Stage and how Milestone fields are updated
    // ======================================================================================================================================= 
    @isTest static void test3() 
    { 
        
        system.debug(' START - AH_PSA_Project_TriggerHandler_Test.test3() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PSA ACCOUNT'];
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Account__c =: a.Id];
        pse__Proj__c tp1 = [SELECT Id, Name, pse__Closed_for_Expense_Entry__c, pse__Stage__c, pse__Project_Manager__c, pse__Is_Billable__c, pse__Billed__c,                     
                           RecordTypeId, pse__Start_Date__c, pse__End_Date__c, pse__Account__c, pse__Opportunity__c, pse__Region__c, pse__Practice__c  
                           FROM pse__Proj__c 
                           WHERE Name = 'Test Project']; 
        
        Test.startTest();
        
        pse__Milestone__c tm = NI_TestClassData.createTestMilestoneNoALI('Apex Test Milestone 1', tp1, true, true, 'Billable Milestone');
        tm.Activity_Line_Item__c = ali.Id;
		insert tm;  
        
        // SET PROJECT STAGE TO 'Draft at Risk' AND ASSERT MILESTONE WAS UPDATED CORRECTLY
        tp1.pse__Stage__c = 'Draft at Risk';
        tp1.pse__Start_Date__c = system.today();
        tp1.pse__End_Date__c = system.today() + 30;
        
        // IN TESTS THESE SWITCHS NEED TO BE TURNED ON 
        NI_TriggerManager.is1stUpdate_Project = true;
        NI_TriggerManager.is1stUpdate_Milestone = true;
        update tp1; 

        pse__Milestone__c tmAssert1 = [SELECT Id, pse__Status__c, pse__Actual_Date__c, pse__Audit_Notes__c,  
                                       pse__Closed_for_Time_Entry__c, pse__Closed_for_Expense_Entry__c 
                                       FROM pse__Milestone__c 
                                       WHERE Id =: tm.Id];
        
        system.assertEquals('Draft/Tentative', tmAssert1.pse__Status__c);
        system.assertEquals(null, tmAssert1.pse__Actual_Date__c); 
        system.assertEquals('Added Actual Date', tmAssert1.pse__Audit_Notes__c);         
        system.assertEquals(true, tmAssert1.pse__Closed_for_Time_Entry__c); 
        system.assertEquals(true, tmAssert1.pse__Closed_for_Expense_Entry__c); 
/*
		system.debug(' ASSERT #1 ================ ');        
        system.debug('   tmAssert1.pse__Status__c = ' + tmAssert1.pse__Status__c);
        system.debug('   tmAssert1.pse__Actual_Date__c = ' + tmAssert1.pse__Actual_Date__c);
        system.debug('   tmAssert1.pse__Audit_Notes__c = ' + tmAssert1.pse__Audit_Notes__c);
        system.debug('   tmAssert1.pse__Closed_for_Time_Entry__c = ' + tmAssert1.pse__Closed_for_Time_Entry__c);
        system.debug('   tmAssert1.pse__Closed_for_Expense_Entry__c = ' + tmAssert1.pse__Closed_for_Expense_Entry__c);
*/        
        // SET PROJECT STAGE TO 'Project Closing' AND ASSERT MILESTONE WAS UPDATED CORRECTLY
        tp1.pse__Stage__c = 'Project Closing'; 
        tp1.pse__Start_Date__c = system.today() - 2; 
        tp1.pse__End_Date__c = system.today() - 1; 
        tp1.Contracted_Subscription_Total__c = 0;
        //tp1.Subscription_Complete__c = 1;
       	tp1.Milestone_Count__c = 0; 
        tp1.Backlog_Milestone_Total__c = 0;
        //tp1.Milestone_Complete__c = 1;
            
        // IN TESTS THESE SWITCHS NEED TO BE TURNED ON 
        NI_TriggerManager.is1stUpdate_Project = true; 
        NI_TriggerManager.is1stUpdate_Milestone = true; 
        update tp1; 

        pse__Milestone__c tmAssert2 = [SELECT Id, pse__Status__c, pse__Actual_Date__c, pse__Audit_Notes__c,  
                                       pse__Closed_for_Time_Entry__c, pse__Closed_for_Expense_Entry__c 
                                       FROM pse__Milestone__c 
                                       WHERE Id =: tm.Id]; 
        
//        system.assertEquals('Open', tmAssert2.pse__Status__c); 
        system.assertEquals('Draft/Tentative', tmAssert2.pse__Status__c); 
        system.assertEquals(null, tmAssert2.pse__Actual_Date__c); 
        system.assertEquals('Added Actual Date', tmAssert2.pse__Audit_Notes__c); 
//        system.assertEquals(false, tmAssert2.pse__Closed_for_Time_Entry__c); 
//        system.assertEquals(false, tmAssert2.pse__Closed_for_Expense_Entry__c); 
        system.assertEquals(true, tmAssert2.pse__Closed_for_Time_Entry__c); 
        system.assertEquals(true, tmAssert2.pse__Closed_for_Expense_Entry__c); 
/*        
		system.debug(' ASSERT #2 ================ ');        
        system.debug('   tmAssert2.pse__Status__c = ' + tmAssert2.pse__Status__c);
        system.debug('   tmAssert2.pse__Actual_Date__c = ' + tmAssert2.pse__Actual_Date__c);
        system.debug('   tmAssert2.pse__Audit_Notes__c = ' + tmAssert2.pse__Audit_Notes__c);
        system.debug('   tmAssert2.pse__Closed_for_Time_Entry__c = ' + tmAssert2.pse__Closed_for_Time_Entry__c);
        system.debug('   tmAssert2.pse__Closed_for_Expense_Entry__c = ' + tmAssert2.pse__Closed_for_Expense_Entry__c);
*/        
        // SET PROJECT STAGE TO 'On Hold' AND ASSERT MILESTONE WAS UPDATED CORRECTLY
        tp1.pse__Stage__c = 'On Hold'; 
        tp1.pse__Start_Date__c = system.today(); 
        tp1.pse__End_Date__c = system.today() + 30; 
        
        // IN TESTS THESE SWITCHS NEED TO BE TURNED ON 
        NI_TriggerManager.is1stUpdate_Project = true; 
        NI_TriggerManager.is1stUpdate_Milestone = true; 
        update tp1; 

        pse__Milestone__c tmAssert3 = [SELECT Id, pse__Status__c, pse__Actual_Date__c, pse__Audit_Notes__c,  
                                       pse__Closed_for_Time_Entry__c, pse__Closed_for_Expense_Entry__c 
                                       FROM pse__Milestone__c 
                                       WHERE Id =: tm.Id]; 
        
        system.assertEquals('Draft/Tentative', tmAssert3.pse__Status__c); 
        system.assertEquals(null, tmAssert3.pse__Actual_Date__c); 
        system.assertEquals('Added Actual Date', tmAssert3.pse__Audit_Notes__c); 
        system.assertEquals(false, tmAssert3.pse__Closed_for_Time_Entry__c); 
        system.assertEquals(false, tmAssert3.pse__Closed_for_Expense_Entry__c);
/*        
		system.debug(' ASSERT #3 ================ ');        
        system.debug('   tmAssert3.pse__Status__c = ' + tmAssert3.pse__Status__c);
        system.debug('   tmAssert3.pse__Actual_Date__c = ' + tmAssert3.pse__Actual_Date__c);
        system.debug('   tmAssert3.pse__Audit_Notes__c = ' + tmAssert3.pse__Audit_Notes__c);
        system.debug('   tmAssert3.pse__Closed_for_Time_Entry__c = ' + tmAssert3.pse__Closed_for_Time_Entry__c);
        system.debug('   tmAssert3.pse__Closed_for_Expense_Entry__c = ' + tmAssert3.pse__Closed_for_Expense_Entry__c);
*/        
        // MAKE AN UPDATE TO MILESTONE TO SET UP FOLLOWING UNIT TEST
        tmAssert3.Milestone_Type__c = 'Inclusive Milestone';
        tmAssert3.pse__Approver__c = null;
        NI_TriggerManager.is1stUpdate_Milestone = true; 
        update tmAssert3; 

        
        // SET PROJECT STAGE TO 'Completed' AND ASSERT MILESTONE WAS UPDATED CORRECTLY
        tp1.pse__Stage__c = 'Completed'; 
        tp1.pse__Start_Date__c = system.today() - 30; 
        tp1.pse__End_Date__c = system.today(); 
        
        // IN TESTS THESE SWITCHS NEED TO BE TURNED ON 
        NI_TriggerManager.is1stUpdate_Project = true; 
        NI_TriggerManager.is1stUpdate_Milestone = true; 
        update tp1; 

        pse__Milestone__c tmAssert4 = [SELECT Id, pse__Status__c, pse__Actual_Date__c, pse__Audit_Notes__c,  
                                       pse__Closed_for_Time_Entry__c, pse__Closed_for_Expense_Entry__c, Milestone_Type__c  
                                       FROM pse__Milestone__c 
                                       WHERE Id =: tm.Id]; 
       
        system.assertEquals('Inclusive Milestone', tmAssert4.Milestone_Type__c);
        system.assertEquals('Approved', tmAssert4.pse__Status__c); 
        system.assertEquals(tp1.pse__End_Date__c, tmAssert4.pse__Actual_Date__c); 
        system.assertEquals('Added Actual Date', tmAssert4.pse__Audit_Notes__c); 
        system.assertEquals(true, tmAssert4.pse__Closed_for_Time_Entry__c); 
        system.assertEquals(true, tmAssert4.pse__Closed_for_Expense_Entry__c);            
/*
		system.debug(' ASSERT #4 ================ ');  
        system.debug('   tmAssert4.Milestone_Type__c = ' + tmAssert4.Milestone_Type__c);
        system.debug('   tmAssert4.pse__Status__c = ' + tmAssert4.pse__Status__c);
        system.debug('   tmAssert4.pse__Actual_Date__c = ' + tmAssert4.pse__Actual_Date__c);
        system.debug('   tmAssert4.pse__Audit_Notes__c = ' + tmAssert4.pse__Audit_Notes__c);
        system.debug('   tmAssert4.pse__Closed_for_Time_Entry__c = ' + tmAssert4.pse__Closed_for_Time_Entry__c);
        system.debug('   tmAssert4.pse__Closed_for_Expense_Entry__c = ' + tmAssert4.pse__Closed_for_Expense_Entry__c);
*/        
        Test.stopTest();

        system.debug(' END - AH_PSA_Project_TriggerHandler_Test.test3() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4: Tests updateMilestoneTypes() FUNCTION ADDED FOR NICC-043944
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {
        
        system.debug(' START - AH_PSA_Project_TriggerHandler_Test.test4() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PSA ACCOUNT'];
        Activity_Line_Item__c ali = [SELECT Id FROM Activity_Line_Item__c WHERE Account__c =: a.Id];
        pse__Proj__c tp1 = [SELECT Id, Name, Cancellation_Approval_Status__c FROM pse__Proj__c WHERE Name = 'Test Project']; 
        
        Test.startTest();
        
        // CREATE A MILESTONE
        pse__Milestone__c tm = NI_TestClassData.createTestMilestoneNoALI('Apex Test Milestone 4', tp1, true, true, 'Billable Milestone');
        tm.Activity_Line_Item__c = ali.Id;
		insert tm; 

        pse__Milestone__c tm2 = [SELECT Id, Name, Milestone_Type__c, Milestone_Type_Previous__c FROM pse__Milestone__c WHERE Name = 'Apex Test Milestone 4']; 
		tm2.Milestone_Type__c = 'Change Order Requested';
        tm2.Milestone_Type_Previous__c = 'Billable Milestone';
        NI_TriggerManager.is1stUpdate_Project = true;
        update tm2;		

        // UPDATE Cancellation_Approval_Status__c TO EMULATE APPROVAL
        tp1.Cancellation_Approval_Status__c = 'Submitted';
        update tp1;        
        
        // UPDATE Cancellation_Approval_Status__c TO EMULATE APPROVAL RECALL
        tp1.Cancellation_Approval_Status__c = 'Not Submitted';
        NI_TriggerManager.is1stUpdate_Project = true;
        update tp1;
        
        // ASSERT THAT MILESTONE Milestone_Type__c WAS CHANGED BACK AFTER RECALL
//        pse__Milestone__c tmAssert1 = [SELECT Id, Name, Milestone_Type__c, Milestone_Type_Previous__c FROM pse__Milestone__c WHERE Name = 'Apex Test Milestone 4'];
//        system.assertEquals('Billable Milestone', tmAssert1.Milestone_Type__c);    
        
        Test.stopTest();

        system.debug(' END - AH_PSA_Project_TriggerHandler_Test.test4() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        
    }
}