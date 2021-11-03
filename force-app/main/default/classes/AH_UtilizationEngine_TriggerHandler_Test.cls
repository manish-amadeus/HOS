/****************************************************************************************
Name            : AH_UtilizationEngine_TriggerHandler_Test
Author          : Sean Harris
Created Date    : 10/19/2018
Last Mod Date   : 10/19/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-034366
Description     : Test class for AH_UtilizationEngine_TriggerHandler
                :
                :
******************************************************************************************/
@isTest
public class AH_UtilizationEngine_TriggerHandler_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' ENTERING - AH_UtilizationEngine_TriggerHandler_Test.createTestData()');
        
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
        region.Name = 'Expense Test Region';  
        region.Central_Expense_Approver__c = regionApprover.Id;
        insert region;   
        
        pse__Region__c regionAssert = [SELECT Id, PSE__REGION_ID_CHAIN__C, PSE__REGION_NAME_CHAIN__C FROM pse__Region__c WHERE Name = 'Expense Test Region'];
        system.assertEquals(region.Id, regionAssert.PSE__REGION_ID_CHAIN__C);
        system.assertEquals(region.Name, regionAssert.PSE__REGION_NAME_CHAIN__C);
        
        // CREATE TEST PSA SCHEDULES  
    	pse__Schedule__c sched = NI_TestClassData.createTestSchedule(dt, dt);
        insert sched;
        
    	pse__Schedule__c sched2 = NI_TestClassData.createTestSchedule(dt, dt);
        insert sched2;
        
/*        
        pse__Schedule__c scheduleAssert = [SELECT Id, Name, pse__Start_Date__c, pse__End_Date__c, 
                                           pse__Sunday_Hours__c, pse__Monday_Hours__c, pse__Tuesday_Hours__c, pse__Wednesday_Hours__c, pse__Thursday_Hours__c, pse__Friday_Hours__c, pse__Saturday_Hours__c, 
                                           pse__Scheduled_Days__c, pse__Scheduled_Hours__c, pse__Week_Total_Hours__c
                                           FROM pse__Schedule__c];
        
		system.assertEquals(0, scheduleAssert.pse__Sunday_Hours__c);
        system.assertEquals(8, scheduleAssert.pse__Monday_Hours__c);
        system.assertEquals(8, scheduleAssert.pse__Tuesday_Hours__c);
        system.assertEquals(8, scheduleAssert.pse__Wednesday_Hours__c);
        system.assertEquals(8, scheduleAssert.pse__Thursday_Hours__c);
        system.assertEquals(8, scheduleAssert.pse__Friday_Hours__c);
        system.assertEquals(0, scheduleAssert.pse__Saturday_Hours__c);
        system.assertEquals(40, scheduleAssert.pse__Week_Total_Hours__c);
//        system.assert(scheduleAssert.pse__Scheduled_Days__c > 200);
//        system.assert(scheduleAssert.pse__Scheduled_Hours__c > 2000);
*/
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
/*        
        pc1.pse__Billing__c = true;
        pc1.pse__Expense_Entry__c = true;
        pc1.pse__Expense_Ops_Edit__c = true;
        pc1.pse__Forecast_Edit__c = true;
        pc1.pse__Forecast_View__c = true;
        pc1.pse__Invoicing__c = true;
        pc1.pse__Resource_Request_Entry__c = true;
        pc1.pse__Skills_And_Certifications_Entry__c = true;
        pc1.pse__Skills_And_Certifications_View__c = true;        
        pc1.pse__Timecard_Entry__c = true;
        pc1.pse__Timecard_Ops_Edit__c = true;
		pc1.pse__Edit_Task_Manager__c = true;
        pc1.pse__View_Task_Manager__c = true;
*/        
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
/*        
        pc2.pse__Billing__c = true; 
        pc2.pse__Expense_Entry__c = true; 
        pc2.pse__Expense_Ops_Edit__c = true; 
        pc2.pse__Forecast_Edit__c = true; 
        pc2.pse__Forecast_View__c = true; 
        pc2.pse__Invoicing__c = true; 
        pc2.pse__Resource_Request_Entry__c = true; 
        pc2.pse__Skills_And_Certifications_Entry__c = true; 
        pc2.pse__Skills_And_Certifications_View__c = true;         
        pc2.pse__Timecard_Entry__c = true; 
        pc2.pse__Timecard_Ops_Edit__c = true; 
		pc2.pse__Edit_Task_Manager__c = true; 
        pc2.pse__View_Task_Manager__c = true; 
*/        
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
//        prj.Customer_Project_Contact__c = cnt.Id; 
    	insert prj;

        /*
        // GRANT ACCESS TO RESOURCE MANAGER TO PROJECT
        pse__Permission_Control__c pc3 = NI_TestClassData.createTestPermissionControl(resrceMgr.Id);
        pc3.pse__Project__c = prj.Id;
        pc3.pse__Billing__c = true;
        pc3.pse__Expense_Entry__c = true;
        pc3.pse__Expense_Ops_Edit__c = true;
        pc3.pse__Forecast_Edit__c = true;
        pc3.pse__Forecast_View__c = true;
        pc3.pse__Invoicing__c = true;
        pc3.pse__Resource_Request_Entry__c = true;
        pc3.pse__Skills_And_Certifications_Entry__c = true;
        pc3.pse__Skills_And_Certifications_View__c = true;
        pc3.pse__Staffing__c = true;
        pc3.pse__Timecard_Entry__c = true;
        pc3.pse__Timecard_Ops_Edit__c = true;
		pc3.pse__Edit_Task_Manager__c = true;
        pc3.pse__View_Task_Manager__c = true;
        insert pc3;
*/        
        
        
/*        
        pse__Proj__c projectAssert = [SELECT Id, Name, 
                                      pse__Account__c,
                                      pse__Closed_for_Expense_Entry__c, 
                                      pse__Closed_for_Time_Entry__c, 
                                      pse__Project_Manager__c, 
                                      pse__Project_ID_Chain__c, 
                                      pse__Project_Name_Chain__c, 
                                      pse__Region__c, 
                                      pse__Stage__c, 
                                      pse__Start_Date__c, 
                                      pse__End_Date__c, 
                                      pse__Project_Status__c, 
                                      pse__Total_Assigned_Hours__c, 
                                      Customer_Project_Contact__c 
                                      FROM pse__Proj__c
                                      WHERE Name = 'Expense Test Project']; 
        
        system.assertEquals(a.Id, projectAssert.pse__Account__c); 
        system.assertEquals(false, projectAssert.pse__Closed_for_Expense_Entry__c); 
        system.assertEquals(false, projectAssert.pse__Closed_for_Time_Entry__c); 
        system.assertEquals(cnt.Id, projectAssert.pse__Project_Manager__c); 
        system.assertEquals(prj.Id, projectAssert.pse__Project_ID_Chain__c); 
        system.assertEquals('Expense Test Project', projectAssert.pse__Project_Name_Chain__c); 
        system.assertEquals(region.Id, projectAssert.pse__Region__c); 
        system.assertEquals('In Progress', projectAssert.pse__Stage__c); 
        system.assertEquals(dt.addDays(10), projectAssert.pse__Start_Date__c); 
        system.assertEquals(dt.addDays(20), projectAssert.pse__End_Date__c); 
        system.assertEquals('Green', projectAssert.pse__Project_Status__c); 
        //system.assert(projectAssert.pse__Total_Assigned_Hours__c > 2000); 
        system.assertEquals(cnt.Id, projectAssert.Customer_Project_Contact__c); 

        // CREATE A TEST ASSIGNMENT 
        pse__Assignment__c assmnt = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj.Id); 
        assmnt.Name = 'Test Assignment'; 
        assmnt.pse__Is_Billable__c = false; 
        assmnt.pse__Bill_Rate__c = 0; 
        assmnt.pse__Location__c = 'Arkansas'; 
        assmnt.pse__Role__c = 'IT'; 
        assmnt.pse__Status__c = 'Tentative'; 
        assmnt.Project_Manager__c = cntMgr.Id; 
        insert assmnt; 

        pse__Assignment__c assignmentAssert = [SELECT Id, Name,                                       
                                               pse__Location__c, 
                                               pse__Project__c, 
                                               pse__Resource__c, 
                                               pse__Role__c, 
                                               pse__Schedule__c, 
                                               pse__Scheduled_Days__c, 
                                               pse__Scheduled_Hours__c, 
                                               pse__Status__c, 
                                               Assignment_Region__c, 
                                               Project_Manager__c, 
                                               pse__Start_Date__c, 
                                               pse__End_Date__c 
                                               FROM pse__Assignment__c 
                                               WHERE Name = 'Test Assignment']; 
        
        system.assertEquals('Arkansas', assignmentAssert.pse__Location__c); 
        system.assertEquals(prj.Id, assignmentAssert.pse__Project__c); 
        system.assertEquals(cnt.Id, assignmentAssert.pse__Resource__c); 
        system.assertEquals('IT', assignmentAssert.pse__Role__c); 
        system.assertEquals(sched.Id, assignmentAssert.pse__Schedule__c); 
        system.assertNotEquals(0, assignmentAssert.pse__Scheduled_Days__c); 
        system.assertNotEquals(0, assignmentAssert.pse__Scheduled_Hours__c); 
        system.assertEquals('Tentative', assignmentAssert.pse__Status__c); 
        system.assertEquals(cnt.Id, assignmentAssert.Project_Manager__c); 
        system.assertEquals(dt.addDays(-182), assignmentAssert.pse__Start_Date__c); 
        system.assertEquals(dt.addDays(183), assignmentAssert.pse__End_Date__c); 
*/        

        system.runAs(resrceMgr)  
        {
            // CREATE A TEST ASSIGNMENT 
            pse__Assignment__c as1 = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj.Id); 
            as1.Name = 'Test Assignment'; 
            as1.pse__Is_Billable__c = false; 
            as1.pse__Bill_Rate__c = 0; 
            as1.pse__Location__c = 'Arkansas'; 
            as1.pse__Role__c = 'IT'; 
            as1.pse__Status__c = 'Tentative'; 
            as1.Project_Manager__c = cntMgr.Id; 
            insert as1; 
            
            pse__Assignment__c as2 = NI_TestClassData.createTestAssignment(cnt.Id, sched2.Id, prj.Id); 
            as2.Name = 'Test Assignment'; 
            as2.pse__Is_Billable__c = false; 
            as2.pse__Bill_Rate__c = 0; 
            as2.pse__Location__c = 'Arkansas'; 
            as2.pse__Role__c = 'IT'; 
            as2.pse__Status__c = 'Tentative'; 
            as2.Project_Manager__c = cntMgr.Id; 
            insert as2;         
        
            pse__Utilization_Engine__c ue1 = new pse__Utilization_Engine__c();        
            ue1.pse__Resource__c = cnt.Id;
            ue1.pse__Period__c = '2019';
            ue1.pse__data_1_1__c = '8.00,9.00,9.00,9.00,9.00,9.00';
            ue1.pse__data_1_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_5__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_6__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_12__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_13__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_19__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_20__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_26__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_27__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_1_31__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_2__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_3__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_9__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_10__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_16__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_17__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_23__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_24__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_2_29__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_1__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_2__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_8__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_9__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_15__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_16__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_22__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_23__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_29__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_30__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_3_31__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_5__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_6__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_12__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_13__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_19__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_20__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_26__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_27__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_4_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_3__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_4__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_10__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_11__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_17__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_18__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_24__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_25__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_5_31__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_1__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_7__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_8__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_14__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_15__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_21__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_22__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_28__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_29__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_6_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_5__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_6__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_12__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_13__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_19__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_20__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_26__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_27__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_7_31__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_2__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_3__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_9__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_10__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_16__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_17__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_23__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_24__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_30__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_8_31__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_6__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_7__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_13__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_14__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_20__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_21__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_27__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_28__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_9_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_4__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_5__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_11__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_12__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_18__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_19__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_25__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_26__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_10_31__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_1__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_2__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_6__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_7__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_8__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_9__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_13__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_14__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_15__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_16__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_20__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_21__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_22__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_23__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_27__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_28__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_29__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_11_30__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_1__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_2__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_3__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_4__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_5__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_6__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_7__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_8__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_9__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_10__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_11__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_12__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_13__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_14__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_15__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_16__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_17__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_18__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_19__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_20__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_21__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_22__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_23__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_24__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_25__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_26__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_27__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_28__c = '0.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_29__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_30__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            ue1.pse__data_12_31__c = '8.00,0.00,0.00,0.00,0.00,0.00';
            insert ue1;
            
        }
        
        Test.stopTest(); 
        
        system.debug('END - AH_UtilizationEngine_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void testUtilizationEngine1() 
    { 
/*        
        User resrceMgr = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrce = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];
        Contact cntMgr = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];    
        Contact cnt = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Resource'];        
        pse__Schedule__c sched = [SELECT Id FROM pse__Schedule__c];
        pse__Proj__c prj = [SELECT Id FROM pse__Proj__c];
        
        system.runAs(resrceMgr)  
        {
            // CREATE A TEST ASSIGNMENT 
            pse__Assignment__c assmnt = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj.Id); 
            assmnt.Name = 'Test Assignment'; 
            assmnt.pse__Is_Billable__c = false; 
            assmnt.pse__Bill_Rate__c = 0; 
            assmnt.pse__Location__c = 'Arkansas'; 
            assmnt.pse__Role__c = 'IT'; 
            assmnt.pse__Status__c = 'Tentative'; 
            assmnt.Project_Manager__c = cntMgr.Id; 
            insert assmnt; 
        }
*/
        
        List<pse__Utilization_Engine__c> lstUE = new List<pse__Utilization_Engine__c>(
             [SELECT Id, pse__Resource__c, pse__Resource__r.Name, pse__Period__c, 
              pse__data_1_1__c, pse__data_1_2__c, pse__data_1_3__c, pse__data_1_4__c, pse__data_1_5__c, pse__data_1_6__c, pse__data_1_7__c, pse__data_1_8__c, pse__data_1_9__c, pse__data_1_10__c, pse__data_1_11__c, pse__data_1_12__c, pse__data_1_13__c, pse__data_1_14__c, pse__data_1_15__c, pse__data_1_16__c, pse__data_1_17__c, pse__data_1_18__c, pse__data_1_19__c, pse__data_1_20__c, pse__data_1_21__c, pse__data_1_22__c, pse__data_1_23__c, pse__data_1_24__c, pse__data_1_25__c, pse__data_1_26__c, pse__data_1_27__c, pse__data_1_28__c, pse__data_1_29__c, pse__data_1_30__c, pse__data_1_31__c, 
              pse__data_2_1__c, pse__data_2_2__c, pse__data_2_3__c, pse__data_2_4__c, pse__data_2_5__c, pse__data_2_6__c, pse__data_2_7__c, pse__data_2_8__c, pse__data_2_9__c, pse__data_2_10__c, pse__data_2_11__c, pse__data_2_12__c, pse__data_2_13__c, pse__data_2_14__c, pse__data_2_15__c, pse__data_2_16__c, pse__data_2_17__c, pse__data_2_18__c, pse__data_2_19__c, pse__data_2_20__c, pse__data_2_21__c, pse__data_2_22__c, pse__data_2_23__c, pse__data_2_24__c, pse__data_2_25__c, pse__data_2_26__c, pse__data_2_27__c, pse__data_2_28__c, pse__data_2_29__c, 
              pse__data_3_1__c, pse__data_3_2__c, pse__data_3_3__c, pse__data_3_4__c, pse__data_3_5__c, pse__data_3_6__c, pse__data_3_7__c, pse__data_3_8__c, pse__data_3_9__c, pse__data_3_10__c, pse__data_3_11__c, pse__data_3_12__c, pse__data_3_13__c, pse__data_3_14__c, pse__data_3_15__c, pse__data_3_16__c, pse__data_3_17__c, pse__data_3_18__c, pse__data_3_19__c, pse__data_3_20__c, pse__data_3_21__c, pse__data_3_22__c, pse__data_3_23__c, pse__data_3_24__c, pse__data_3_25__c, pse__data_3_26__c, pse__data_3_27__c, pse__data_3_28__c, pse__data_3_29__c, pse__data_3_30__c, pse__data_3_31__c, 
              pse__data_4_1__c, pse__data_4_2__c, pse__data_4_3__c, pse__data_4_4__c, pse__data_4_5__c, pse__data_4_6__c, pse__data_4_7__c, pse__data_4_8__c, pse__data_4_9__c, pse__data_4_10__c, pse__data_4_11__c, pse__data_4_12__c, pse__data_4_13__c, pse__data_4_14__c, pse__data_4_15__c, pse__data_4_16__c, pse__data_4_17__c, pse__data_4_18__c, pse__data_4_19__c, pse__data_4_20__c, pse__data_4_21__c, pse__data_4_22__c, pse__data_4_23__c, pse__data_4_24__c, pse__data_4_25__c, pse__data_4_26__c, pse__data_4_27__c, pse__data_4_28__c, pse__data_4_29__c, pse__data_4_30__c, 
              pse__data_5_1__c, pse__data_5_2__c, pse__data_5_3__c, pse__data_5_4__c, pse__data_5_5__c, pse__data_5_6__c, pse__data_5_7__c, pse__data_5_8__c, pse__data_5_9__c, pse__data_5_10__c, pse__data_5_11__c, pse__data_5_12__c, pse__data_5_13__c, pse__data_5_14__c, pse__data_5_15__c, pse__data_5_16__c, pse__data_5_17__c, pse__data_5_18__c, pse__data_5_19__c, pse__data_5_20__c, pse__data_5_21__c, pse__data_5_22__c, pse__data_5_23__c, pse__data_5_24__c, pse__data_5_25__c, pse__data_5_26__c, pse__data_5_27__c, pse__data_5_28__c, pse__data_5_29__c, pse__data_5_30__c, pse__data_5_31__c, 
              pse__data_6_1__c, pse__data_6_2__c, pse__data_6_3__c, pse__data_6_4__c, pse__data_6_5__c, pse__data_6_6__c, pse__data_6_7__c, pse__data_6_8__c, pse__data_6_9__c, pse__data_6_10__c, pse__data_6_11__c, pse__data_6_12__c, pse__data_6_13__c, pse__data_6_14__c, pse__data_6_15__c, pse__data_6_16__c, pse__data_6_17__c, pse__data_6_18__c, pse__data_6_19__c, pse__data_6_20__c, pse__data_6_21__c, pse__data_6_22__c, pse__data_6_23__c, pse__data_6_24__c, pse__data_6_25__c, pse__data_6_26__c, pse__data_6_27__c, pse__data_6_28__c, pse__data_6_29__c, pse__data_6_30__c, 
              pse__data_7_1__c, pse__data_7_2__c, pse__data_7_3__c, pse__data_7_4__c, pse__data_7_5__c, pse__data_7_6__c, pse__data_7_7__c, pse__data_7_8__c, pse__data_7_9__c, pse__data_7_10__c, pse__data_7_11__c, pse__data_7_12__c, pse__data_7_13__c, pse__data_7_14__c, pse__data_7_15__c, pse__data_7_16__c, pse__data_7_17__c, pse__data_7_18__c, pse__data_7_19__c, pse__data_7_20__c, pse__data_7_21__c, pse__data_7_22__c, pse__data_7_23__c, pse__data_7_24__c, pse__data_7_25__c, pse__data_7_26__c, pse__data_7_27__c, pse__data_7_28__c, pse__data_7_29__c, pse__data_7_30__c, pse__data_7_31__c, 
              pse__data_8_1__c, pse__data_8_2__c, pse__data_8_3__c, pse__data_8_4__c, pse__data_8_5__c, pse__data_8_6__c, pse__data_8_7__c, pse__data_8_8__c, pse__data_8_9__c, pse__data_8_10__c, pse__data_8_11__c, pse__data_8_12__c, pse__data_8_13__c, pse__data_8_14__c, pse__data_8_15__c, pse__data_8_16__c, pse__data_8_17__c, pse__data_8_18__c, pse__data_8_19__c, pse__data_8_20__c, pse__data_8_21__c, pse__data_8_22__c, pse__data_8_23__c, pse__data_8_24__c, pse__data_8_25__c, pse__data_8_26__c, pse__data_8_27__c, pse__data_8_28__c, pse__data_8_29__c, pse__data_8_30__c, pse__data_8_31__c, 
              pse__data_9_1__c, pse__data_9_2__c, pse__data_9_3__c, pse__data_9_4__c, pse__data_9_5__c, pse__data_9_6__c, pse__data_9_7__c, pse__data_9_8__c, pse__data_9_9__c, pse__data_9_10__c, pse__data_9_11__c, pse__data_9_12__c, pse__data_9_13__c, pse__data_9_14__c, pse__data_9_15__c, pse__data_9_16__c, pse__data_9_17__c, pse__data_9_18__c, pse__data_9_19__c, pse__data_9_20__c, pse__data_9_21__c, pse__data_9_22__c, pse__data_9_23__c, pse__data_9_24__c, pse__data_9_25__c, pse__data_9_26__c, pse__data_9_27__c, pse__data_9_28__c, pse__data_9_29__c, pse__data_9_30__c, 
              pse__data_10_1__c, pse__data_10_2__c, pse__data_10_3__c, pse__data_10_4__c, pse__data_10_5__c, pse__data_10_6__c, pse__data_10_7__c, pse__data_10_8__c, pse__data_10_9__c, pse__data_10_10__c, pse__data_10_11__c, pse__data_10_12__c, pse__data_10_13__c, pse__data_10_14__c, pse__data_10_15__c, pse__data_10_16__c, pse__data_10_17__c, pse__data_10_18__c, pse__data_10_19__c, pse__data_10_20__c, pse__data_10_21__c, pse__data_10_22__c, pse__data_10_23__c, pse__data_10_24__c, pse__data_10_25__c, pse__data_10_26__c, pse__data_10_27__c, pse__data_10_28__c, pse__data_10_29__c, pse__data_10_30__c, pse__data_10_31__c, 
              pse__data_11_1__c, pse__data_11_2__c, pse__data_11_3__c, pse__data_11_4__c, pse__data_11_5__c, pse__data_11_6__c, pse__data_11_7__c, pse__data_11_8__c, pse__data_11_9__c, pse__data_11_10__c, pse__data_11_11__c, pse__data_11_12__c, pse__data_11_13__c, pse__data_11_14__c, pse__data_11_15__c, pse__data_11_16__c, pse__data_11_17__c, pse__data_11_18__c, pse__data_11_19__c, pse__data_11_20__c, pse__data_11_21__c, pse__data_11_22__c, pse__data_11_23__c, pse__data_11_24__c, pse__data_11_25__c, pse__data_11_26__c, pse__data_11_27__c, pse__data_11_28__c, pse__data_11_29__c, pse__data_11_30__c, 
              pse__data_12_1__c, pse__data_12_2__c, pse__data_12_3__c, pse__data_12_4__c, pse__data_12_5__c, pse__data_12_6__c, pse__data_12_7__c, pse__data_12_8__c, pse__data_12_9__c, pse__data_12_10__c, pse__data_12_11__c, pse__data_12_12__c, pse__data_12_13__c, pse__data_12_14__c, pse__data_12_15__c, pse__data_12_16__c, pse__data_12_17__c, pse__data_12_18__c, pse__data_12_19__c, pse__data_12_20__c, pse__data_12_21__c, pse__data_12_22__c, pse__data_12_23__c, pse__data_12_24__c, pse__data_12_25__c, pse__data_12_26__c, pse__data_12_27__c, pse__data_12_28__c, pse__data_12_29__c, pse__data_12_30__c, pse__data_12_31__c 
              FROM pse__Utilization_Engine__c
             ]);

//        for (pse__Utilization_Engine__c ue : lstUE)
//        {
//         	system.debug(' ue = ' + ue);   
//        }
        
        
        system.assertNotEquals(0, lstUE.size());
                
        
    }

}