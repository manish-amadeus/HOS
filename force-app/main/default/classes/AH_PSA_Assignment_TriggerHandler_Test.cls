/****************************************************************************************
Name            : AH_PSA_Assignment_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 08/29/2018
Last Mod Date   : 06/17/2020
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : Written by CLS Partners. Updated to meet AH Standards
				:
                :
******************************************************************************************/
@isTest 
private class AH_PSA_Assignment_TriggerHandler_Test 
{

    @testSetup static void createTestData() 
    {
        
        system.debug(' START - AH_PSA_Assignment_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
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
        prj.pse__Start_Date__c = dt.addDays(-10); 
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
        
        pse__Assignment__c assignment = [SELECT Id, OwnerId, Owner.Name, Project_Manager__c, Project_Manager__r.Name FROM pse__Assignment__c WHERE Name = 'Test Assignment 2']; 

        pse__Project_Task__c projTask = new pse__Project_Task__c();
        projTask.Name = 'Test Project task';
        projTask.pse__Project__c = prj.Id;
        projTask.Location__c = 'India';
        //projTask.pse__End_Date_Time__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        projTask.pse__End_Date_Time__c = datetime.newInstance(dt.year(), dt.month(), dt.day(), 12, 30, 0);
        insert projTask;
        
        system.debug('cnt : '+cnt.id);
        system.debug('assignment : '+assignment.id);
        system.debug('projTask : '+projTask.id);
        
        Test.stopTest(); 
        
        pse__Project_Task_Assignment__c prkTaskAssignment = new pse__Project_Task_Assignment__c();
        prkTaskAssignment.pse__Resource__c =  cnt.id;
        prkTaskAssignment.pse__Assignment__c =  assignment.id;
        prkTaskAssignment.pse__Project_Task__c =  projTask.id;
        prkTaskAssignment.pse__Resource_Role__c =  'Contractor';
        insert prkTaskAssignment;
        
        pse__Project_Task_Assignment__c prkTaskAssignment1 = [SELECT id, Name,
                                               pse__Resource__c, pse__Assignment__c, pse__Project_Task__c, pse__Resource_Role__c  
                                                FROM pse__Project_Task_Assignment__c WHERE Id =: prkTaskAssignment.Id];
        
        system.debug('prkTaskAssignment 1 : '+prkTaskAssignment1);

        system.debug(' END - AH_PSA_Assignment_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: Test AH_PSA_Assignment_TriggerHandler.setAssignmentOwner()
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {  

        system.debug(' START - AH_PSA_Assignment_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Contact cntMgr = [SELECT Id, Name, pse__Salesforce_User__c, pse__Salesforce_User__r.Name FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];
        Contact cnt = [SELECT Id, Name, pse__Salesforce_User__c, pse__Salesforce_User__r.Name FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Resource'];
        pse__Assignment__c as1 = [SELECT Id, OwnerId, Owner.Name, Project_Manager__c, Project_Manager__r.Name FROM pse__Assignment__c WHERE Name = 'Test Assignment 1']; 
        pse__Assignment__c as2 = [SELECT Id, OwnerId, Owner.Name, Project_Manager__c, Project_Manager__r.Name FROM pse__Assignment__c WHERE Name = 'Test Assignment 2'];        
        
        
        Test.startTest(); 
        
        // ASSERT PROJECT MANAGER
        system.assertEquals(cntMgr.Id, as1.Project_Manager__c);
        // ASSERT RECORD OWNER
        system.assertEquals(cntMgr.pse__Salesforce_User__c, as1.OwnerId);
        // ASSERT PROJECT MANAGER
        system.assertEquals(cntMgr.Id, as2.Project_Manager__c);   
        // ASSERT RECORD OWNER
        system.assertEquals(cntMgr.pse__Salesforce_User__c, as2.OwnerId);
        
        //system.debug(' **** Assignment #1: OwnerId = ' + as1.OwnerId + ', OwnerName = ' + as1.Owner.Name  + ', ProjectManagerId = ' + as1.Project_Manager__c  + ', ProjectManagerName = ' + as1.Project_Manager__r.Name);         
        system.debug(' **** Resource Manager: ContactId = ' + cntMgr.Id + ', ContactName = ' + cntMgr.Name  + ', UserId = ' + cntMgr.pse__Salesforce_User__c  + ', UserName = ' + cntMgr.pse__Salesforce_User__r.Name);  
        system.debug(' **** Resource: ContactId = ' + cnt.Id + ', ContactName = ' + cnt.Name  + ', UserId = ' + cnt.pse__Salesforce_User__c  + ', UserName = ' + cnt.pse__Salesforce_User__r.Name);                 
        system.debug(' **** Assignment #2: OwnerId = ' + as2.OwnerId + ', OwnerName = ' + as2.Owner.Name  + ', ProjectManagerId = ' + as2.Project_Manager__c  + ', ProjectManagerName = ' + as2.Project_Manager__r.Name);         
        
        
        
        // TRY TO UPDATE THE Project_Manager__c
        as2.Project_Manager__c = cnt.Id;
        // TRY TO UPDATE THE OwnerId 
        as2.OwnerId = cnt.pse__Salesforce_User__c;
        update as2;
        
        //system.debug(' **** Assignment #1: OwnerId = ' + as1.OwnerId + ', OwnerName = ' + as1.Owner.Name  + ', ProjectManagerId = ' + as1.Project_Manager__c  + ', ProjectManagerName = ' + as1.Project_Manager__r.Name);         
        system.debug(' **** Assignment #2: OwnerId = ' + as2.OwnerId + ', OwnerName = ' + as2.Owner.Name  + ', ProjectManagerId = ' + as2.Project_Manager__c  + ', ProjectManagerName = ' + as2.Project_Manager__r.Name);         
        
        
        // ASSERT BEFORE TRIGGER REPLACEMENT FOR "FF PSA - Update PM Name on Assignments" PROCESS BUILDER WORKS
        pse__Assignment__c as2Assert = [SELECT Id, OwnerId, Owner.Name, Project_Manager__c, Project_Manager__r.Name FROM pse__Assignment__c WHERE Name = 'Test Assignment 2']; 
        system.assertEquals(cntMgr.Id, as2Assert.Project_Manager__c);
        
        // ENSURE THAT THE OwnerId WAS CHANGED BACK TO MANAGER ON AFTER UPDATE
        system.assertEquals(cntMgr.pse__Salesforce_User__c, as2Assert.OwnerId);
        
        Test.stopTest(); 
        
        system.debug(' END - AH_PSA_Assignment_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }
    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: testTrigger_AssignmentAIU_SetMilestoneTargetDate_SingleAssignment() 
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {  
        
        system.debug(' START - AH_PSA_Assignment_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.startTest(); 
        
        pse__Region__c region = [SELECT Id FROM pse__Region__c WHERE Name = 'psaTestRegion'];
        pse__Practice__c practice = [SELECT Id FROM pse__Practice__c WHERE Name = 'psaTestPractice'];
        Contact cnt = [SELECT Id FROM Contact WHERE LastName = 'Resource'];         
        
        // CREATE A TEST PSA SCHEDULE (From March 26-30, 2012)
        Date dt = Date.NewInstance(2012, 03, 26); 
        pse__Schedule__c schedule1 = NI_TestClassData.createTestSchedule(dt, dt.addDays(4));
        insert schedule1;     
        
        // Create a project
        pse__Proj__c tp = NI_TestClassData.createTestProject(1, 'Assignment/Milestone Date Test Project', region, practice, 'Draft', null);
        tp.Name = 'Assignment/Milestone Date Test Project';
        // tp.pse__Project_Manager__c = mgr.Id;
        NI_TriggerManager.is1stInsert_Project = true; 
        insert tp;
        
        // Create a milestone for the project. Initial Target Date will be 12/31/2025
        Date dtNewTargetDate = Date.newInstance(2012, 03, 30);
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('Assignment-Milestone Target Date Test', tp, true, true, 'Hourly Milestone');
        milestone.pse__Target_Date__c = dtNewTargetDate;
        NI_TriggerManager.is1stInsert_Milestone = true; 
        insert milestone;
        
        pse__Milestone__c msAssert1 = [SELECT pse__Target_Date__c FROM pse__Milestone__c WHERE Id =: milestone.Id];
        //system.assertEquals(dtNewTargetDate, msAssert1.pse__Target_Date__c);
        
        // Create a permission control that will allow us to staff the resource
        insert new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Resource__c = cnt.Id, pse__Staffing__c = true);
        insert new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Region__c = region.Id, pse__Staffing__c = true);
        
        // Create the assignment and associate it with the milestone and schedule created above
        pse__Assignment__c assignment = NI_TestClassData.createTestAssignment(cnt.Id, schedule1.Id, tp.Id); 
        assignment.Name = 'Target Date Assignment';
        assignment.pse__Is_Billable__c = true;
        assignment.pse__Bill_Rate__c = 85;
        assignment.pse__Milestone__c = milestone.Id;
        NI_TriggerManager.is1stInsert_Assignment = true; 
        insert assignment;
        
        pse__Milestone__c msAssert2 = [SELECT pse__Target_Date__c FROM pse__Milestone__c WHERE Id =: milestone.Id];
        
        system.debug(' **** stopTest - AH_PSA_Assignment_TriggerHandler_Test.TestClassData1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.stopTest(); 
        
        // Check the assignment end date
        pse__Assignment__c updatedAssignment = [SELECT pse__End_Date__c FROM pse__Assignment__c WHERE Id =: assignment.Id];
        system.assertEquals(Date.newInstance(2012, 03, 30), updatedAssignment.pse__End_Date__c);
        
        // Now check the Milestone. Its target date should be set to March 30, 2012
        pse__Milestone__c updatedMilestone = [SELECT pse__Target_Date__c FROM pse__Milestone__c WHERE Id =: milestone.Id];
        system.debug(' *** Milestone target date: ' + updatedMilestone.pse__Target_Date__c);
        
        // Now update the schedule to move it out an additional week
        // Although the schedule is updated, we need to update the assignment to trigger the target date update as would happen from the UI
        schedule1.pse__End_Date__c = Date.newInstance(2012, 04, 06);
        update schedule1;
        
        NI_TriggerManager.is1stUpdate_Assignment = true; 
        update assignment;
        
        // Check the Milestone to verify that its target date matches the new assignment end date
        updatedMilestone = [SELECT pse__Target_Date__c FROM pse__Milestone__c WHERE Id =: milestone.Id];
        system.debug('Milestone target date: ' + updatedMilestone.pse__Target_Date__c);
        
        delete assignment;
        
        //undelete assignment;
        
        system.debug(' END - AH_PSA_Assignment_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================================= 
    // == TEST METHOD 3: test Method To Update Project Task. ADDED BY CYBAGE ON 5/29/2020
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {  
        
        system.debug(' START - AH_PSA_Assignment_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());

        Test.startTest();
        
        //Contact cntMgr = [SELECT Id, Name, pse__Salesforce_User__c, pse__Salesforce_User__r.Name FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];
        Contact cnt = [SELECT Id, Name, pse__Salesforce_User__c, pse__Salesforce_User__r.Name FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Resource'];
        pse__Assignment__c assignment = [SELECT Id, OwnerId, Owner.Name, Project_Manager__c, Project_Manager__r.Name FROM pse__Assignment__c WHERE Name = 'Test Assignment 2'];        
        
		pse__Proj__c project = [SELECT Id, Name, pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__Proj__c WHERE Name = 'Expense Test Project'];
        
        // Create a milestone for the project
        Date dtNewTargetDate = Date.newInstance(2012, 03, 30);
        pse__Milestone__c milestone = NI_TestClassData.createTestMilestone('Assignment-Milestone Target Date Test', project, true, true, 'Hourly Milestone');
        milestone.pse__Target_Date__c = dtNewTargetDate;
        NI_TriggerManager.is1stInsert_Milestone = true; 
        insert milestone;       
        
        AH_PSA_Assignment_TriggerHandler.bIsTaskUpdate = false;
        
        // Check the assignment end date
        pse__Assignment__c updateAssignment = [SELECT id, Name,
                                               pse__Is_Billable__c, pse__Time_Credited__c, 
                                               pse__Location__c, pse__Milestone__c 
                                               FROM pse__Assignment__c WHERE Id =: assignment.Id];
        
        updateAssignment.Name = 'Target Date Assignment updated';
        updateAssignment.pse__Is_Billable__c = false;
        updateAssignment.pse__Time_Credited__c = true;
        updateAssignment.pse__Location__c = 'Alaska';
        updateAssignment.pse__Milestone__c = milestone.Id;
        update updateAssignment;
        
        pse__Assignment__c updatedAssignment = [SELECT id, Name, pse__Is_Billable__c, 
                                                pse__Time_Credited__c, pse__Location__c, pse__Milestone__c 
                                                FROM pse__Assignment__c WHERE Id =: assignment.Id];
        system.debug('updatedAssignment : '+updatedAssignment);
        
        pse__Project_Task__c projTaskupdted = [SELECT id, Name,
                                               Location__c, pse__Milestone__c, pse__Status__c, 
                                               Billable__c, Time_Credited__c 
                                               FROM pse__Project_Task__c ];//WHERE Id =: projTask.Id];
        
        system.debug('projTaskupdted : '+projTaskupdted);
        
        system.assertEquals(true, updatedAssignment.pse__Time_Credited__c, 'Time Credited field not updated');
        system.assertEquals(false, updatedAssignment.pse__Is_Billable__c, 'Billable field not updated');
        system.assertEquals('Alaska', updatedAssignment.pse__Location__c, 'Location field not updated');
        system.assertEquals(milestone.Id, updatedAssignment.pse__Milestone__c, 'Milestone field not updated');
        
        Test.stopTest(); 
                
        system.debug(' END - AH_PSA_Assignment_TriggerHandler_Test.test2() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }
    
}