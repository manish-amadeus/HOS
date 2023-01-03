/************************************************************************************************
Name            : NI_PSA_Milestone_TriggerHandler_Test Class
Author          : Stuart Emery
Created Date    : 07/29/2014
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-010968
Description     : Test Class for the NI_PSA_Milestone_TriggerHandler Class
                :
                : 
*************************************************************************************************/ 
@isTest 
private class NI_PSA_Milestone_TriggerHandler_Test 
{

    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {

        system.debug(' ENTERING - NI_PSA_Milestone_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
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
            u1.Alias = 'RGA1TST'; 
            insert u1; 
            
            // CREATE TEST RESOURCE MANAGER USER 
            User u2 = NI_TestClassData.createTestUser(3, 'NI PSA Management'); 
            u2.Alias = 'MGR1TST'; 
            insert u2; 
            
            // CREATE TEST RESOURCE USER 
            User u3 = NI_TestClassData.createTestUser(4, 'NI PSA T&E - Salesforce'); 
            u3.Alias = 'RSC1TST'; 
            u3.ManagerId = u2.Id;
            insert u3;             
        }

        // GET TEST USERS CREATED BY FAKE ADMIN
        User regionApprover = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrceMgr = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrce = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];
        
        
		// CREATE A TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PSA EXPENSE REPORT ACCOUNT';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;        

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
        prj.Name = 'Expense Test Project'; 
        prj.pse__Closed_for_Expense_Entry__c = false; 
        prj.pse__Project_Manager__c = cntMgr.Id; 
        prj.pse__Start_Date__c = dt.addDays(10); 
        prj.pse__End_Date__c = dt.addDays(20); 
        prj.pse__Account__c = a.Id; 
    	insert prj;

        pse__Proj__c prjAsserts = [SELECT Id, pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__Proj__c WHERE Name = 'Expense Test Project'];
        system.debug(' *** prjAsserts.pse__Project_Manager__r.pse__Salesforce_User__c = ' + prjAsserts.pse__Project_Manager__r.pse__Salesforce_User__c);
        
        system.runAs(resrceMgr)  
        {
            // CREATE A TEST ASSIGNMENT 
            pse__Assignment__c as1 = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj.Id); 
            as1.Name = 'Test Assignment 1'; 
            as1.pse__Is_Billable__c = false; 
            as1.pse__Bill_Rate__c = 0; 
            as1.pse__Location__c = 'Arkansas'; 
            as1.pse__Role__c = 'IT'; 
            as1.pse__Status__c = 'Tentative'; 
            as1.Project_Manager__c = cntMgr.Id; 
            insert as1; 
            
            pse__Assignment__c as2 = NI_TestClassData.createTestAssignment(cnt.Id, sched2.Id, prj.Id); 
            as2.Name = 'Test Assignment 2'; 
            as2.pse__Is_Billable__c = false; 
            as2.pse__Bill_Rate__c = 0; 
            as2.pse__Location__c = 'Arkansas'; 
            as2.pse__Role__c = 'IT'; 
            as2.pse__Status__c = 'Tentative'; 
            as2.OwnerId = resrce.Id;
            as2.Project_Manager__c = cnt.Id; 		// Before Insert & Update should set this to cntMgr.Id
            insert as2;             
        }

        Test.stopTest(); 
        
        system.debug(' END - NI_PSA_Milestone_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
                
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: DELETE & UNDELETE COVERAGE & UNIT TESTING 
    // =======================================================================================================================================     
    @isTest static void test1() 
    {    
        
        system.debug(' START - NI_PSA_Milestone_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'psaTestRegion'];
        pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'psaTestPractice'];
        //Contact cnt = [SELECT Id FROM Contact WHERE LastName = 'Resource'];         
                
        // CREATE A TEST PSA SCHEDULE (From March 26-30, 2012) 
        Date dt = Date.NewInstance(2012, 03, 26); 
    	pse__Schedule__c schedule1 = NI_TestClassData.createTestSchedule(dt, dt.addDays(4));
    	insert schedule1;     
        
        // Create a project
        pse__Proj__c tp = NI_TestClassData.createTestProject(1, 'Assignment/Milestone Date Test Project', region, practice, 'Draft', null);
        tp.Name = 'Assignment/Milestone Date Test Project';
//        tp.pse__Project_Manager__c = mgr.Id;
        insert tp;

        // Create a milestone for the project. 
        Date dtNewTargetDate = Date.newInstance(2012, 03, 30);
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('Assignmant-Milestone Target Date Test', tp, true, true, 'Hourly Milestone');
        milestone.pse__Target_Date__c = dtNewTargetDate;
        insert milestone;

        system.debug(' *^* milestone.Billable_Assignment_Count__c = ' + milestone.Billable_Assignment_Count__c);
        system.debug(' *^* milestone.Activity_Line_Item__c = ' + milestone.Activity_Line_Item__c);
        
        milestone.Name = 'Assignment-Milestone Target Date Test';
        update milestone;

        Test.startTest();
        
        delete milestone;
        
        undelete milestone;
        
        Test.stopTest();
        
        system.debug(' END - NI_PSA_Milestone_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
         
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================     
    @isTest static void test2() 
    {    
        
        system.debug(' START - NI_PSA_Milestone_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'psaTestRegion'];
        pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'psaTestPractice'];
        //Contact cnt = [SELECT Id FROM Contact WHERE LastName = 'Resource'];         
                
        // CREATE A TEST PSA SCHEDULE (From March 26-30, 2012) 
        Date dt = Date.NewInstance(2012, 03, 26); 
    	pse__Schedule__c schedule1 = NI_TestClassData.createTestSchedule(dt, dt.addDays(4));
    	insert schedule1;     
        
        // Create a project
        pse__Proj__c tp = NI_TestClassData.createTestProject(1, 'Assignment/Milestone Date Test Project', region, practice, 'Draft', null);
        tp.Name = 'Assignment/Milestone Date Test Project';
//        tp.pse__Project_Manager__c = mgr.Id;
        insert tp;
    
    
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
		insert blgCnrct;

		Activity_Line_Item__c ali = NI_TestClassData.createActivityLineItem(blgCnrct.Id);        
        insert ali;
        
        // Create a milestone for the project. Initial Target Date will be 12/31/2025
        Date dtDefault = Date.newInstance(2025, 12, 31); 
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('Assignmant-Milestone Target Date Test', tp, true, true, 'Hourly Milestone');
        milestone.pse__Target_Date__c = dtDefault;
        milestone.pse__Admin_Global_Edit__c = true;              
        milestone.pse__Target_Date__c = dtDefault;
        milestone.Billable_Assignment_Count__c = 0;    
        milestone.Activity_Line_Item__c = ali.Id;
        insert milestone;

        system.debug(' *^* milestone.Billable_Assignment_Count__c = ' + milestone.Billable_Assignment_Count__c);
        system.debug(' *^* milestone.Activity_Line_Item__c = ' + milestone.Activity_Line_Item__c);

        Test.startTest();        
                
        milestone.Name = 'Assignment-Milestone Target Date Test';
        milestone.Milestone_Type__c = 'Billable Milestone';
        milestone.pse__Approved__c = true;
        update milestone;

        Test.stopTest();
        
        system.debug(' END - NI_PSA_Milestone_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
         
    }      
    
    
    
    
    
/*    

    @isTest static void TestClassData1() 
    {  
        
//        pse__Milestone__c milestone = [SELECT Id, pse__Status__c FROM pse__Milestone__c WHERE Name = 'PSA Test Milestone'];
//        system.assertEquals('Approved', milestone.pse__Status__c);
        Softrax_Order_Line__c sol = [SELECT Id FROM Softrax_Order_Line__c WHERE Softrax_Order_Sequence_Number__c = 4];
        pse__Proj__c tp = [SELECT Id FROM pse__Proj__c WHERE Name = 'Assignment/Milestone Date Test Project'];
        
        system.debug(' *** BEFORE Milestone Record INSERT - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        //CREATE A TEST PSA MILESTONE RECORD       
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        milestone.Softrax_Order_Line_PSA__c = sol.Id;
        milestone.pse__Actual_Date__c = Date.newInstance(2011, 10, 25);
        milestone.pse__Target_Date__c = Date.newInstance(2011, 11, 25);
        milestone.pse__Status__c = 'Approved';
        milestone.pse__Approved__c = true;
        milestone.pse__Include_In_Financials__c = true;
        milestone.pse__Billable_Amount_In_Financials__c = 1000;
        milestone.pse__Milestone_Amount__c = 1000;
        insert milestone;        
        
        system.debug(' *** AFTER Milestone Record INSERT - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.startTest();   
        
        //DELETE THE MILESTONE        
        delete milestone;
        
        //UN-DELETE THE MILESTONE
        undelete milestone;
        
        Test.stopTest();
  
    }
*/
  
/*    
    //SINGLE INSERT TEST METHOD  
    static testMethod void singleInsertTest()
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
        //        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
        //        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
        //        update(pt);
        
        //CREATE A TEST ACCOUNT RECORD  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE RECORD TYPE ID FOR A SMALL DEAL OPPORTUNITY  
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE A TEST OPPORTUNITY RECORD  
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        insert opp1;
        
        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol = NI_TestClassData.createStxOrderLines(1,opp1.Id);
        insert sol;
        
        //CREATE A TEST PSA REGION RECORD  
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
        
        //CREATE A TEST PSA PRACTICE RECORD  
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;  
        
        //CREATE A TEST PSA PROJECT RECORD
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        tp.pse__Opportunity__c = opp1.Id;
        insert tp;
        
        //CREATE A TEST PSA MILESTONE RECORD
        Test.startTest();
        
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        milestone.Softrax_Order_Line_PSA__c = sol.Id;
        milestone.pse__Milestone_Amount__c = 1000;
        insert milestone;
        
        //CREATE A TEST PSA MILESTONE RECORD  
        pse__Milestone__c milestone2 = NI_TestClassData.createTestMilestone('PSA Test Milestone2', tp, false, false, 'Billable Milestone');
        milestone2.Softrax_Order_Line_PSA__c = sol.Id;
        milestone2.pse__Milestone_Amount__c = 1000;
        insert milestone2;
        
        Test.stopTest();
        
        //QUERY THE SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c updatedSol = [SELECT Id, Milestone_Totals__c,Billed_Milestone_Total__c
                                            FROM Softrax_Order_Line__c
                                            WHERE Id = :sol.Id];
        
        System.assertEquals(2000,updatedSol.Milestone_Totals__c); //ASSERT THAT THE MILESTONE TOTALS FIELD EQUALS 2000
        System.assertEquals(0,updatedSol.Billed_Milestone_Total__c); //ASSERT THAT THE BILLED MILESTONE TOTAL FIELD EQUALS 0
        
    }
    
    //=====================================================================================================================================
    //SINGLE UPDATE TEST METHOD  
    static testMethod void singleUpdateTest()
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
//        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
//        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
//        update(pt);
        
        //CREATE A TEST ACCOUNT RECORD  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE RECORD TYPE ID FOR A SMALL DEAL OPPORTUNITY  
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE A TEST OPPORTUNITY RECORD  
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        insert opp1;
        
        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol = NI_TestClassData.createStxOrderLines(1,opp1.Id);
        sol.Softrax_Order_Sequence_Number__c=4;
        insert sol;
        
        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol2 = NI_TestClassData.createStxOrderLines(1,opp1.Id);
        insert sol2;  
        
        //CREATE A TEST PSA REGION RECORD  
        pse__Region__c defaultRegion = NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
        
        //CREATE A TEST PSA PRACTICE RECORD  
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;
        
        //CREATE A DEFAULT WORK CALENDAR TO USE FOR THE DEFAULT RESOURCE
        pse__Work_Calendar__c defaultWC = new pse__Work_Calendar__c();
        defaultWC.Name='Test Work Calendar';
        insert defaultWC;
        
        //CREATE A TEST USER FOR THE TEST PSA RESOURCE CONTACT RECORD  
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
        insert u;
        
        //CREATE A TEST PSA RESOURCE
        Contact c = NI_TestClassData.createTestContact(1,a.Id);
        c.pse__Resource_Role__c='Systems Engineering';
        c.pse__Is_Resource__c=true;
        c.pse__Is_Resource_Active__c=true;
        c.pse__Salesforce_User__c=u.Id;    
        c.pse__Region__c = defaultRegion.Id;
        c.pse__Practice__c = defaultPractice.Id;
        c.pse__Work_Calendar__c=defaultWC.Id;
        insert c;
        
        //CREATE A PERMISSION CONTROL THAT WILL ALLOW US TO FLAG A MILESTONE AS BILLED
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.pse__User__c=u.Id;
        pc.pse__Staffing__c=true;
        pc.pse__Billing__c=true;
        pc.pse__Invoicing__c=true;
        pc.pse__Region__c=defaultRegion.Id;
        pc.pse__Cascading_Permission__c=true;
        insert pc;
        
        //CREATE A TEST PSA PROJECT RECORD
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        tp.pse__Opportunity__c = opp1.Id;
        insert tp;
        
        //CREATE A TEST PSA MILESTONE RECORD       
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        milestone.Softrax_Order_Line_PSA__c = sol.Id;
        milestone.pse__Actual_Date__c = Date.newInstance(2011, 10, 25);
        milestone.pse__Target_Date__c = Date.newInstance(2011, 11, 25);
        milestone.pse__Status__c = 'Approved';
        milestone.pse__Approved__c = true;
        milestone.pse__Include_In_Financials__c = true;
        milestone.pse__Billable_Amount_In_Financials__c = 1000;
        milestone.pse__Milestone_Amount__c = 1000;
        insert milestone;
        
        //CREATE A TEST PSA MILESTONE RECORD  
        pse__Milestone__c milestone2 = NI_TestClassData.createTestMilestone('PSA Test Milestone2', tp, false, false, 'Billable Milestone');
        milestone2.Softrax_Order_Line_PSA__c = sol.Id;
        milestone2.pse__Milestone_Amount__c = 1000;
        insert milestone2;

        //CHANGE MILESTONE AMOUNT FOR ONE OF THE MILESTONE RECORDS
        
        Test.startTest();
        
        System.runAs(u)
        {     
            //milestone.Softrax_Order_Line_PSA__c = sol.Id;
            milestone.pse__Milestone_Amount__c = 1500;
            milestone.pse__Billed__c = true;
            milestone.pse__Approved__c = true;
            milestone.pse__Include_In_Financials__c = true;
            update milestone;
        }
        Test.stopTest();
        
        //QUERY THE SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c updatedSol = [SELECT Id, Milestone_Totals__c,Billed_Milestone_Total__c
                                            FROM Softrax_Order_Line__c
                                            WHERE Id = :sol.Id];
        
        System.assertEquals(2500,updatedSol.Milestone_Totals__c); //ASSERT THAT THE MILESTONE TOTALS FIELD EQUALS 2500
        System.assertEquals(1500,updatedSol.Billed_Milestone_Total__c); //ASSERT THAT THE BILLED MILESTONE TOTAL FIELD EQUALS 1500  
        
    }
    
    //=====================================================================================================================================
    //SINGLE UPDATE TEST METHOD - UPDATE SOFTRAX ORDER LINE FIELD  
    static testMethod void singleUpdateTest2()
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
//        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
//        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
//        update(pt);
        
        //CREATE A TEST ACCOUNT RECORD  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE RECORD TYPE ID FOR A SMALL DEAL OPPORTUNITY  
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE A TEST OPPORTUNITY RECORD  
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        insert opp1;
        
        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol = NI_TestClassData.createStxOrderLines(1,opp1.Id);
        sol.Softrax_Order_Sequence_Number__c=4;
        insert sol; 
        
        //CREATE A TEST PSA REGION RECORD  
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
        
        //CREATE A TEST PSA PRACTICE RECORD  
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;
        
        //CREATE A TEST PSA PROJECT RECORD
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        tp.pse__Opportunity__c = opp1.Id;
        insert tp;
        
        //CREATE A TEST PSA MILESTONE RECORD  
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone2', tp, false, false, 'Billable Milestone');
        milestone.pse__Milestone_Amount__c = 1000;
        insert milestone;  
        
        //UPDATE THE MILESTONE WITH THE SOFTRAX ORDER LINE
        Test.startTest();
        milestone.Softrax_Order_Line_PSA__c = sol.Id;
        update milestone;
        Test.stopTest();
        
        //QUERY THE SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c updatedSol = [SELECT Id, Milestone_Totals__c,Billed_Milestone_Total__c
                                            FROM Softrax_Order_Line__c
                                            WHERE Id = :sol.Id];
        
        System.assertEquals(1000,updatedSol.Milestone_Totals__c); //ASSERT THAT THE MILESTONE TOTALS FIELD EQUALS 1000  
        
    }    
    
    //=====================================================================================================================================
    //SINGLE DELETE TEST METHOD  
    static testMethod void singleDeleteTest()
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
//        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
//        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
//        update(pt);
        
        //CREATE A TEST ACCOUNT RECORD  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE RECORD TYPE ID FOR A SMALL DEAL OPPORTUNITY  
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE A TEST OPPORTUNITY RECORD  
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        insert opp1;
        
        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol = NI_TestClassData.createStxOrderLines(1,opp1.Id);
        sol.Softrax_Order_Sequence_Number__c=4;
        insert sol; 
        
        //CREATE A TEST PSA REGION RECORD  
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
        
        //CREATE A TEST PSA PRACTICE RECORD  
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;
        
        //CREATE A TEST PSA PROJECT RECORD
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        tp.pse__Opportunity__c = opp1.Id;
        insert tp;
        
        //CREATE A TEST PSA MILESTONE RECORD
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        milestone.Softrax_Order_Line_PSA__c = sol.Id;
        milestone.pse__Milestone_Amount__c = 1000;
        insert milestone;
        
        //DELETE THE MILESTONE        
        Test.startTest();
        delete milestone;
        Test.stopTest();
        
        //QUERY THE SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c updatedSol = [SELECT Id, Milestone_Totals__c,Billed_Milestone_Total__c
                                            FROM Softrax_Order_Line__c
                                            WHERE Id = :sol.Id];
        
        System.assertEquals(0,updatedSol.Milestone_Totals__c); //ASSERT THAT THE MILESTONE TOTALS FIELD EQUALS 0              
    }
    
    //=============================================================================================================================    
    //SINGLE UN-DELETE TEST METHOD  
    static testMethod void singleUnDeleteTest()
    {    
        //ADDED PER FINANCIALFORCE SUPPORT TO PREVENT WEB SERVICES CALL OUT MESSAGE WHEN RUNNING TEST CLASSES THAT INVOLVE THE CONTACT OBJECT  
//        pse__Triggers__c pt = [SELECT Id, pse__Resource_Geolocation_Trigger_Disabled__c FROM pse__Triggers__c]; 
//        pt.pse__Resource_Geolocation_Trigger_Disabled__c = true;
//        update(pt);
        
        //CREATE A TEST ACCOUNT RECORD  
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE RECORD TYPE ID FOR A SMALL DEAL OPPORTUNITY  
        Id rtInit = NI_TestClassData.getRecordTypeId('Opportunity', 'Small Deal Opportunity');
        
        //CREATE A TEST OPPORTUNITY RECORD  
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.RecordTypeId = rtInit;
        insert opp1;
        
        //CREATE A TEST SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c sol = NI_TestClassData.createStxOrderLines(1,opp1.Id);
        sol.Softrax_Order_Sequence_Number__c=4;
        insert sol; 
        
        //CREATE A TEST PSA REGION RECORD  
        pse__Region__c defaultRegion =  NI_TestClassData.createTestRegion(1, 'psaTestRegion');
        insert defaultRegion; 
        
        //CREATE A TEST PSA PRACTICE RECORD  
        pse__Practice__c defaultPractice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        insert defaultPractice;
        
        //CREATE A TEST PSA PROJECT RECORD
        pse__Proj__c tp = NI_TestClassData.createTestProject(1,'Assignment/Milestone Date Test Project', defaultRegion, defaultPractice, 'Draft', null);
        tp.pse__Opportunity__c = opp1.Id;
        insert tp;
        
        //CREATE A TEST PSA MILESTONE RECORD
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('PSA Test Milestone', tp, false, false, 'Billable Milestone');
        milestone.Softrax_Order_Line_PSA__c = sol.Id;
        milestone.pse__Milestone_Amount__c = 1000;
        insert milestone;
        
        //DELETE THE MILESTONE        
        delete milestone;
        
        //QUERY THE SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c updatedSol = [SELECT Id, Milestone_Totals__c,Billed_Milestone_Total__c
                                            FROM Softrax_Order_Line__c
                                            WHERE Id = :sol.Id];
        
        System.assertEquals(0,updatedSol.Milestone_Totals__c); //ASSERT THAT THE MILESTONE TOTALS FIELD EQUALS 0
        
        //UN-DELETE THE MILESTONE
        Test.startTest();        
        undelete milestone;
        Test.stopTest();
        
        //QUERY THE SOFTRAX ORDER LINE RECORD  
        Softrax_Order_Line__c updatedSol2 = [SELECT Id, Milestone_Totals__c,Billed_Milestone_Total__c
                                             FROM Softrax_Order_Line__c
                                             WHERE Id = :sol.Id];
        
        System.assertEquals(1000,updatedSol2.Milestone_Totals__c); //ASSERT THAT THE MILESTONE TOTALS FIELD EQUALS 1000
        
    }                
*/
    
}