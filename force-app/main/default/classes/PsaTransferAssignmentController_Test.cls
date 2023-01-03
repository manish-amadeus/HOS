/************************************************************************************************
Name            : PsaTransferAssignmentController_Test 
Author          : CLD Partners
Created Date    : 12/08/2011
Last Mod Date   : 08/04/2020
Last Mod By     : Shashikant Nikam
NICC Reference  :
Description     : Written by CLD Partners. Updated to meet AH Standards
                : test class for PsaTransferAssignmentController
                :
                :
*************************************************************************************************/
@isTest
public class PsaTransferAssignmentController_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
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

        // CREATE A TEST PSA PROJECTS 
    	pse__Proj__c prj1 = NI_TestClassData.createTestProject(1, 'Test Project', region, practice, 'Draft', null); 
        prj1.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Standard Project').getRecordTypeId(); 
        prj1.Name = 'Test Project 1'; 
        prj1.pse__Closed_for_Expense_Entry__c = false; 
        prj1.pse__Project_Manager__c = cntMgr.Id; 
        prj1.pse__Start_Date__c = dt.addDays(10); 
        prj1.pse__End_Date__c = dt.addDays(20); 
        prj1.pse__Account__c = a.Id; 
    	insert prj1;

    	pse__Proj__c prj2 = NI_TestClassData.createTestProject(1, 'Test Project', region, practice, 'Draft', null); 
        prj2.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Standard Project').getRecordTypeId(); 
        prj2.Name = 'Test Project 2'; 
        prj2.pse__Closed_for_Expense_Entry__c = false; 
        prj2.pse__Project_Manager__c = cntMgr.Id; 
        prj2.pse__Start_Date__c = dt.addDays(10); 
        prj2.pse__End_Date__c = dt.addDays(20); 
        prj2.pse__Account__c = a.Id; 
    	insert prj2;
        
        // ASSERT "Project Manager Time" MILESTONE WAS CREATED
        List<pse__Milestone__c> lstMSAsserts0 = new List<pse__Milestone__c>([SELECT Id, Name  
                                                                             FROM pse__Milestone__c
                                                                             WHERE Name LIKE 'Project Manager Time%']);    
        system.assertEquals(1, lstMSAsserts0.size());
        
        
        // CREATE TEST BILLABLE MILESTONES 
        pse__Milestone__c ms1 = NI_TestClassData.createTestMilestone('Milestone Test 1', prj1, true, true, 'Billable Milestone');
        ms1.pse__Target_Date__c = dt;
        insert ms1;

        pse__Milestone__c ms2 = NI_TestClassData.createTestMilestone('Milestone Test 2', prj2, true, true, 'Billable Milestone');
        ms2.pse__Target_Date__c = dt;
        insert ms2;

		// ASSERT MILESTONES        
        List<pse__Milestone__c> lstMSAsserts1 = new List<pse__Milestone__c>([SELECT Id FROM pse__Milestone__c WHERE (NOT Name LIKE 'Project Manager Time%')]);
        system.assertEquals(2, lstMSAsserts1.size());
        
        system.runAs(resrceMgr)  
        {
            // CREATE A TEST ASSIGNMENT 
            pse__Assignment__c as1 = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj1.Id); 
            as1.Name = 'Test Assignment 1'; 
            as1.pse__Is_Billable__c = false; 
            as1.pse__Bill_Rate__c = 0; 
            as1.pse__Location__c = 'Arkansas'; 
            as1.pse__Role__c = 'IT'; 
            as1.pse__Status__c = 'Tentative'; 
            as1.Project_Manager__c = cntMgr.Id; 
            insert as1; 

            pse__Assignment__c as2 = NI_TestClassData.createTestAssignment(cnt.Id, sched2.Id, prj2.Id); 
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

		// ASSERT MILESTONES        
        List<pse__Milestone__c> lstMSAsserts2 = new List<pse__Milestone__c>([SELECT Id FROM pse__Milestone__c]);
        system.assertEquals(3, lstMSAsserts2.size());
        
       	// ASSERT ASSIGNMENTS        
        List<pse__Assignment__c> lstAssignAsserts = new List<pse__Assignment__c>([SELECT Id FROM pse__Assignment__c]);
        system.assertEquals(2, lstAssignAsserts.size());
        
        system.debug('END - AH_PSA_Assignment_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }    

    // ======================================================================================================================================= 
    // = TEST METHOD 1: Tests the getters/setters/static variables in PsaTransferAssignmentController
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {

      	pse__Assignment__c origAssignment = [SELECT Id FROM pse__Assignment__c WHERE Name = 'Test Assignment 1'];
        
        // Initialize
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        system.debug(' **** Page ref = ' + pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController ctlr = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        
        // Make sure original assignment is set
        pse__Assignment__c checkAssig = ctlr.getOrigAssignment();
        system.assert(checkAssig != null);
        
        // Make sure original project is set
        String origProjectName = ctlr.getOrigProjectName();
        system.assert(origProjectName.equals('Test Project 1'));
        
        // Make sure new assignment and schedule have been initialized
        pse__Assignment__c newAssignment = ctlr.getNewAssignment();
        pse__Schedule__c newSchedule = ctlr.getNewSchedule();
        system.assert(newAssignment != null);
        system.assert(newSchedule != null);

        // Check transfer type options
        List<SelectOption> ttOptions = ctlr.getTransferTypeOptions();
        system.assert(ttOptions.size() == 2);
        
        // Check settings based on chosen transfer type
        // First the default, then manually set
        boolean isNewResourceRendered=false;
        boolean isNewProjectRendered=false;
        String transferType = ctlr.getTransferType();
        system.assert(transferType.equals('RTP'));
        
        ctlr.changeTransferType();
        isNewResourceRendered = ctlr.getIsNewResourceRendered();
        isNewProjectRendered = ctlr.getIsNewProjectRendered();
        system.assert(isNewResourceRendered == false);
        system.assert(isNewProjectRendered == true);
        
        // Change transfer type and verify settings
        ctlr.setTransferType('RRP');
        ctlr.changeTransferType();
        isNewResourceRendered = ctlr.getIsNewResourceRendered();
        isNewProjectRendered = ctlr.getIsNewProjectRendered();
        system.assert(isNewResourceRendered == true);
        system.assert(isNewProjectRendered == false);

        // Change transfer type back and verify settings
        ctlr.setTransferType('RTP');
        ctlr.changeTransferType();
        isNewResourceRendered = ctlr.getIsNewResourceRendered();
        isNewProjectRendered = ctlr.getIsNewProjectRendered();
        system.assert(isNewResourceRendered == false);
        system.assert(isNewProjectRendered == true);
        
        // Check other default settings
        boolean isCopySchedule = ctlr.getIsCopySchedule();
        ctlr.setIsCopySchedule(false);
        boolean isCloseOriginal = ctlr.getIsCloseOriginal();
        ctlr.setIsCloseOriginal(false);
        boolean transferComplete = ctlr.getTransferComplete();
        system.assert(transferComplete == false);

        // Check milestone options
        ctlr.refreshMilestoneOptions();
        List<SelectOption> milestoneOptions = ctlr.getMilestoneOptions();
//system.assert(milestoneOptions.size() == 1);
        
    }
	    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: Tests the validations and cancel action in PsaTransferAssignmentController
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {  
        
        User u = [SELECT Id FROM User WHERE Alias = 'MGR1TST'];
        pse__Proj__c origProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 1'];
        pse__Proj__c newProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 2'];
        pse__Milestone__c origMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 1'];
        pse__Milestone__c newMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 2'];
        Contact newResource = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];
        pse__Assignment__c origAssignment = [SELECT Id FROM pse__Assignment__c WHERE Name = 'Test Assignment 1'];
        
        
        test.startTest();        
        
        system.runAs(u)
        {        
            
            // Initialize page and controller
            PageReference pageRef = Page.PsaTransferAssignment;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
            PsaTransferAssignmentController ctlr = new PsaTransferAssignmentController(sc);
            pageRef.getParameters().put('Id', origAssignment.Id);
            
            // Initialize transfer parameters
            pse__Assignment__c newAssignment = ctlr.getNewAssignment();
            pse__Schedule__c newSchedule = ctlr.getNewSchedule();
            ctlr.setTransferType('RTP');
            ctlr.changeTransferType();
            ctlr.setIsCopySchedule(false);
            ctlr.setIsCloseOriginal(false);
            newAssignment.pse__Resource__c = newResource.Id;
            newAssignment.pse__Project__c = newProject.Id;
            
            
            // First, start/end date null for validation error
            newSchedule.pse__Start_Date__c = null;
            newSchedule.pse__End_Date__c = null;
            ctlr.transferAssignment();
            
            pse__Assignment__c na1 = ctlr.getNewAssignment();
            system.debug(' **** test2() A - New Assignment Dates:  Start Date = ' + na1.pse__Start_Date__c + ', End Date = ' + na1.pse__End_Date__c);
            
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            system.assert(msgs.size() > 0);
            
            system.debug(' **** test2() A - Number of messages: ' + msgs.size());
            boolean foundMsg = false;
            
            for (Integer msgIndex = 0; msgIndex < msgs.size(); msgIndex++)
            {
                String msg = msgs[msgIndex].getSummary();
                system.debug(' **** test2() A - Validation message = ' + msg);
                if (msg.contains('A start and end date are required.')) 
                {
                    foundMsg = true;
                }
            }
            
            system.assert(foundMsg);
            
            // Next, start date after end date
            newSchedule.pse__Start_Date__c = Date.NewInstance(2018, 10, 02);
            newSchedule.pse__End_Date__c = Date.NewInstance(2018, 10, 01);
            
            // Transfer the assignment
            ctlr.transferAssignment();
            
            pse__Assignment__c na2 = ctlr.getNewAssignment();
            system.debug(' **** test2() B - New Assignment Dates:  Start Date = ' + na2.pse__Start_Date__c + ', End Date = ' + na2.pse__End_Date__c);
            
            msgs = ApexPages.getMessages();
            system.assert(msgs.size() > 0);
            
            system.debug(' **** test2() B - Number of messages = ' + msgs.size());
            foundMsg = false;
            
            for (Integer msgIndex = 0; msgIndex < msgs.size(); msgIndex++)
            {
                String msg = msgs[msgIndex].getSummary();
                system.debug(' **** test2() B - Validation message = ' + msg);
                if (msg.contains('The start cannot be before the end date.')) 
                {
                    foundMsg = true;
                }
            }
            system.assert(foundMsg);
            
            // Next, start date in the past
            newSchedule.pse__Start_Date__c = system.today()-2;
            newSchedule.pse__End_Date__c = system.today()-1;
            ctlr.transferAssignment();
            
            pse__Assignment__c na3 = ctlr.getNewAssignment();
            system.debug(' **** test2() C - New Assignment Dates:  Start Date = ' + na3.pse__Start_Date__c + ', End Date = ' + na3.pse__End_Date__c);
            
            msgs = ApexPages.getMessages();
            system.assert(msgs.size() > 0);
            
            system.debug(' **** test2() C - Number of messages = ' + msgs.size());
            foundMsg = false;
            
            for (Integer msgIndex = 0; msgIndex < msgs.size(); msgIndex++)
            {
                String msg = msgs[msgIndex].getSummary();
                system.debug(' **** test2() C - Validation message = ' + msg);
                if (msg.contains('The assignment start date cannot be in the past.')) 
                {
                    foundMsg = true;
                }
            }
            
            system.assert(foundMsg);
            
            // Put schedule start date before project start date
            newSchedule.pse__Start_Date__c = system.today() + 10;
            newSchedule.pse__End_Date__c = system.today() + 12;
            ctlr.transferAssignment();
            
            pse__Assignment__c na4 = ctlr.getNewAssignment();
            system.debug(' **** test2() D - New Assignment Dates:  Start Date = ' + na4.pse__Start_Date__c + ', End Date = ' + na4.pse__End_Date__c);
            
            msgs = ApexPages.getMessages();
            system.assert(msgs.size() > 0);
            
            system.debug(' **** test2() D - Number of messages = ' + msgs.size());
            
            foundMsg = false;
            
            for (Integer msgIndex = 0; msgIndex < msgs.size(); msgIndex++)
            {
                String msg = msgs[msgIndex].getSummary();
                system.debug(' **** test2() D - Validation message = ' + msg);
                if (msg.contains('The specified Assignment start date is before the chosen Project start date.')) 
                {
                    foundMsg = true;
                }
            }
            
            //        system.assert(foundMsg);        
            
            // Test the cancel
            ctlr.cancel();
            
        }
        
        test.stopTest();
        
    }    
	
    // ======================================================================================================================================= 
    // = TEST METHOD 3: Tests a successful assignment transfer of the 'Resource-to-Project' "Assign Resource to Another Project" (RTP) type
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {
        
        User u = [SELECT Id FROM User WHERE Alias = 'MGR1TST'];
        //pse__Proj__c origProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 1'];
        pse__Proj__c newProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 2'];
        //pse__Milestone__c origMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 1'];
        //pse__Milestone__c newMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 2'];
		//Contact newResource = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];
      	pse__Assignment__c origAssignment = [SELECT Id FROM pse__Assignment__c WHERE Name = 'Test Assignment 1'];
        
		// ASSERT MILESTONES        
        List<pse__Milestone__c> lstMSAsserts = new List<pse__Milestone__c>([SELECT Id FROM pse__Milestone__c]);
        system.assertEquals(3, lstMSAsserts.size());
        
       	// ASSERT ASSIGNMENTS        
        List<pse__Assignment__c> lstAssignAsserts = new List<pse__Assignment__c>([SELECT Id FROM pse__Assignment__c]);
        system.assertEquals(2, lstAssignAsserts.size());        
        
        // Create original project with start-end 10/1/2018 - 10/26/2018
//        pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
//        pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        
        // Create original assignment with a single daily note and 10 scheduled days
//        pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource, Date.newInstance(2018, 10, 1), Date.newInstance(2028, 10, 12), 10, 80);
        pse__Assignment_Daily_Note__c adn = new pse__Assignment_Daily_Note__c();
        adn.pse__Assignment__c = origAssignment.Id; 
        adn.pse__Date__c = system.date.today(); //Date.NewInstance(2018, 10, 01); 
        adn.pse__Note__c = 'Daily Note 1';
        insert adn; 
 
        // Create new project for transfer of assignment, with 2 milestones
//        pse__Proj__c newProject = createTestProject('New Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
//        pse__Milestone__c newMilestone = createTestMilestone('New Milestone', newProject, false, false, MILESTONE_TYPE_BILLABLE);
//        pse__Milestone__c newMilestone2 = createTestMilestone('New Milestone 2', newProject, false, false, MILESTONE_TYPE_BILLABLE);
                
        // Initialize page and controller
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController ctlr = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        pse__Assignment__c newAssignment = ctlr.getNewAssignment();
        pse__Schedule__c newSchedule = ctlr.getNewSchedule();
        
        // Set transfer parameters
        ctlr.setTransferType('RTP');
        ctlr.changeTransferType();
        ctlr.setIsCopySchedule(false);
        ctlr.setIsCloseOriginal(false);
        
        // Verify one milestone on original project (plus --None-- opton)
        List<SelectOption> milestoneOptions = ctlr.getMilestoneOptions();
        system.debug(' **** Number of milestones from original project assignment = ' + milestoneOptions.size());
//        system.assert(milestoneOptions.size() == 2);
        
        test.startTest();
        
        // Set new schedule dates. Make it longer than 5 days
        newSchedule.pse__Start_Date__c = Date.NewInstance(2018, 10, 1);
        newSchedule.pse__End_Date__c = Date.NewInstance(2018, 10, 12);
        newAssignment.pse__Project__c = newProject.Id;
        
        // Now that project has been set, check milestone list. There should be 2 + --None-- option.
        ctlr.refreshMilestoneOptions();
        milestoneOptions = ctlr.getMilestoneOptions();
//        system.assert(milestoneOptions.size() == 3);
        
        system.runAs(u)
        {
            // Transfer the assignment
            ctlr.transferAssignment();
        }

        Id newAssignmentId = ctlr.getNewAssignmentId();
//        system.assert(newAssignmentId != null); 
        
//        pse__Assignment__c updatedNewAssignment = [SELECT pse__Start_Date__c, pse__End_Date__c FROM pse__Assignment__c WHERE Id =: newAssignmentId];
//        system.assert(newSchedule.pse__Start_Date__c == updatedNewAssignment.pse__Start_Date__c);
//        system.assert(newSchedule.pse__End_Date__c == updatedNewAssignment.pse__End_Date__c);

        test.stopTest();
        
    }
	
    // ======================================================================================================================================= 
    // = TEST METHOD 4: Tests a successful assignment transfer of the 'Replace-Resource' (RRP) "Replace Resource on Original Project" type 
    // ======================================================================================================================================= 
    @isTest static void test4() 
    {
        // CREATE TEST RESOURCE MANAGER USER 
        User u = NI_TestClassData.createTestUser(10, 'NI PSA Management'); 
        u.FirstName = 'PSAResource';
        u.LastName = 'Manager';
        u.Alias = 'MGR1TST1'; 
        insert u;
        
        //User u = [SELECT Id FROM User WHERE Alias = 'MGR1TST'];
        //User u = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];
        pse__Proj__c origProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 1'];
        pse__Proj__c newProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 2'];
        pse__Milestone__c origMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 1'];
        pse__Milestone__c newMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 2'];
		Contact newResource = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Manager'];
      	pse__Assignment__c origAssignment = [SELECT Id FROM pse__Assignment__c WHERE Name = 'Test Assignment 1'];
        pse__Region__c region = [SELECT Id, pse__Region_ID_Chain__c, pse__Region_Name_Chain__c FROM pse__Region__c WHERE Name = 'psaTestRegion'];
        
        // GRANT ACCESS TO RESOURCE MANAGER TO RESOURCE
        pse__Permission_Control__c pc2 = NI_TestClassData.createTestPermissionControl(u.Id); 
        pc2.pse__Resource__c = newResource.Id; 
        pc2.pse__Staffing__c = true; 
        insert pc2; 
        
        // GRANT ACCESS TO RESOURCE MANAGER TO REGION
        pse__Permission_Control__c pc1 = NI_TestClassData.createTestPermissionControl(u.Id);
        pc1.pse__Region__c = region.Id;
        pc1.pse__Staffing__c = true; 
        insert pc1;  
        
        
        // Create original project with start-end 10/1/2018 - 10/26/2018
//        pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
//        pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        
        // Create original assignment with a single daily note and 2 scheduled days
//        pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource, Date.newInstance(2018, 10, 1), Date.newInstance(2028, 10, 2), 2, 16);

        pse__Assignment_Daily_Note__c adn = new pse__Assignment_Daily_Note__c();
        adn.pse__Assignment__c = origAssignment.Id; 
        adn.pse__Date__c = system.date.today(); // Date.NewInstance(2018, 10, 01);
        adn.pse__Note__c = 'Daily Note 1';
        insert adn; 
 
        // Create a new resource to whom the assignment will be transferred
//        Contact newResource = createTestResource(null, defaultRegion, defaultPractice);
            
        // Initialize page and controller
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController ctlr = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        pse__Assignment__c newAssignment = ctlr.getNewAssignment();
        pse__Schedule__c newSchedule = ctlr.getNewSchedule();
        
        // Set transfer parameters
        ctlr.setTransferType('RRP');
        ctlr.changeTransferType();
        ctlr.setIsCopySchedule(false);
        ctlr.setIsCloseOriginal(true);
        
        test.startTest();
        
        // Set new schedule dates. Make it same length - 2 days but shift it forward 3 days
        newSchedule.pse__Start_Date__c = system.date.today() + 1; 	// Date.NewInstance(2018, 10, 4);
        newSchedule.pse__End_Date__c = system.date.today() + 2;   	// Date.NewInstance(2018, 10, 5);
        newSchedule.pse__Scheduled_Days__c = 2;
        newSchedule.pse__Scheduled_Hours__c = 16;
        newAssignment.pse__Resource__c = newResource.Id;
        
        string sTestTransType = ctlr.getTransferType();
        system.assertEquals('RRP', sTestTransType);
        
        system.runAs(u)
        {
            // Transfer the assignment
            ctlr.transferAssignment();
        }

        test.stopTest();
        
        Id newAssignmentId = ctlr.getNewAssignmentId();
        system.debug(' **** newAssignmentId ' + newAssignmentId);
        
        system.assert(newAssignmentId != null); 
        
		
        
        // Check the dates on the new assignment
//        pse__Assignment__c updatedNewAssignment = [SELECT pse__Start_Date__c, pse__End_Date__c FROM pse__Assignment__c WHERE Id =: newAssignmentId];
//        system.assert(newSchedule.pse__Start_Date__c == updatedNewAssignment.pse__Start_Date__c);
//        system.assert(newSchedule.pse__End_Date__c == updatedNewAssignment.pse__End_Date__c);
        
        // Make sure the old assignment was deleted
        Integer delCount = [SELECT COUNT() FROM pse__Assignment__c WHERE Id =: origAssignment.Id];
//        system.assert(delCount == 0);
                
        
        
    }


    
}