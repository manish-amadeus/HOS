/************************************************************************************************
Name            : PsaTransferAssignmentController 
Author          : CLD Partners
Created Date    : 12/08/2011
Last Mod Date   : 03/22/2019
Last Mod By     : Sean Harris
NICC Reference  :
Description     : 

    IMPORTANT NOTE ABOUT THIS CLASS:
    THIS CLASS WAS CREATED BY CLD Partners BEFORE OUR "Amadeus Hospitality Salesforce Development Standards" (https://na61.salesforce.com/0690d000003QUBg)
    DOCUMENT EXISTED. THIS "COVER-ALL" TEST CLASS SHOULD NOT BE USED. IF A TEST CLASS DOES NOT EXIST, A NEW "CLASS SPECIFIC" TEST CLASS SHOULD BE 
    CREATED USING NI_TESTCLASSDATA AS THE TEST RECORD CREATOR. ANY CHANGE SETS USING THIS CLASS WILL BE REJECTED. THANK YOU.

*************************************************************************************************/
@isTest
private class psaTest_PSAPhase1VFControllers 
{
/*
    public static final String DEFAULT_PRACTICE_NAME = 'psaTestPractice';
    public static final String DEFAULT_REGION_NAME = 'psaTestRegion';
    public static final String DEFAULT_RESOURCE_NAME = 'PSA Test Resource';
    public static pse__Practice__c defaultPractice;
    public static pse__Region__c defaultRegion;
    public static Contact defaultResource;
    public static pse__Work_Calendar__c defaultWorkCalendar;
    
    public static final String MILESTONE_STATUS_DRAFT = 'Draft/Tentative';
    public static final String PROJECT_STAGE_DRAFT = 'Draft';
    public static final String MILESTONE_TYPE_BILLABLE = 'Billable Milestone';
*/    


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
            User u1 = NI_TestClassData.createTestUser(2, 'AH PSA Administrator - Lightning'); 
            u1.FirstName = 'Regional';
            u1.LastName = 'Admin';
            u1.Alias = 'RGA1TST'; 
            insert u1; 
            
            // CREATE TEST RESOURCE MANAGER USER 
            User u2 = NI_TestClassData.createTestUser(3, 'AH PSA Management - Lightning');  
            u2.FirstName = 'PSAResource';
            u2.LastName = 'Manager';
            u2.Alias = 'MGR1TST'; 
            insert u2; 
            
            // CREATE TEST RESOURCE USER 
            User u3 = NI_TestClassData.createTestUser(4, 'AH PSA T&E - SF - Lightning'); 
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
        
        // CREATE TEST BILLABLE MILESTONES 
        pse__Milestone__c ms1 = NI_TestClassData.createTestMilestone('Milestone Test 1', prj1, true, true, 'Billable Milestone');
        ms1.pse__Target_Date__c = dt;
        insert ms1;

        pse__Milestone__c ms2 = NI_TestClassData.createTestMilestone('Milestone Test 2', prj2, true, true, 'Billable Milestone');
        ms2.pse__Target_Date__c = dt;
        insert ms2;
        
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
            as2.Project_Manager__c = cnt.Id;        // Before Insert & Update should set this to cntMgr.Id
            insert as2;   

        }

        Test.stopTest(); 
        
        system.debug('END - AH_PSA_Assignment_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }    

    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================
/*
    @isTest static void testController_PsaCustomProjectLookup() 
    {
        Test.startTest();
        PageReference pageRef = Page.PsaCustomProjectLookup;
        Test.setCurrentPage(pageRef);
        
        system.debug(' **** Page ref = ' + pageRef);
        
        PsaCustomProjectLookupController controller = new PsaCustomProjectLookupController();
        controller.go();
        
        pageRef.getParameters().put('projectName', 'JL Test Project');
        controller = new PsaCustomProjectLookupController();
        controller.go();
        Test.stopTest();
    }
*/
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================    
    @isTest static void testController_PsaTxAssignmentProjectLookup() 
    {
        Test.startTest();
        PageReference pageRef = Page.PsaTxAssignmentProjectLookup;
        Test.setCurrentPage(pageRef);
        
        system.debug(' **** Page ref = ' + pageRef);
 
        PsaTxAssignmentProjectLookupController controller = new PsaTxAssignmentProjectLookupController();
        controller.go();
        
        pageRef.getParameters().put('projectName', 'JL Test Project');
        controller = new PsaTxAssignmentProjectLookupController();
        controller.go();
        
        // Get list of Projects
        List<pse__Proj__c> assigProjects = controller.projects;
        Test.stopTest();
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // =======================================================================================================================================    
    @isTest static void testController_PsaTxAssignmentResourceLookup() 
    { 
        Test.startTest();
        PageReference pageRef = Page.PsaTxAssignmentResourceLookup;
        Test.setCurrentPage(pageRef);
        
        system.debug(' **** Page ref = ' + pageRef);
        
        PsaTxAssignmentResourceLookupController controller = new PsaTxAssignmentResourceLookupController();
        controller.go();
        
        pageRef.getParameters().put('resourceName', 'Joe Smith');
        controller = new PsaTxAssignmentResourceLookupController();
        controller.go();
        Test.stopTest();
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 4: 
    // =======================================================================================================================================    
    @isTest static void testController_PsaMyAssignments() 
    {
        Test.startTest();
        PageReference pageRef = Page.PsaMyAssignments;
        Test.setCurrentPage(pageRef);
        
        system.debug(' **** Page ref = ' + pageRef);
 
        PsaMyAssignmentsController controller = new PsaMyAssignmentsController();
        controller.runSearch();
        Integer lastModDays = controller.getLastModDays();
        system.assert(lastModDays == 5);
        Integer swDays = controller.getStartWithinDays();
        system.assert(swDays == null);
        String sortDir = controller.sortDir;
        system.assert(sortDir.equals('asc'));
        controller.toggleSort();
        sortDir = controller.sortDir;
        system.assert(sortDir.equals('desc'));
        
        String sortField = controller.sortField;
        system.assert(sortField.equals('pse__Start_Date__c'));
        
        pageRef.getParameters().put('modDays', '10');
        pageRef.getParameters().put('startWithinDays', '20');
        controller = new PsaMyAssignmentsController();
        controller.runSearch();
        lastModDays = controller.getLastModDays();
        system.debug('Last Mod Days: ' + lastModDays);
        //system.assert(lastModDays == 10);
        //system.assert(controller.getStartWithinDays() == 20);
        
        controller.setLastModDays(15);
        controller.setStartWithinDays(9);
        controller.runSearch();
        
        Date maxLastMod = controller.getMaxLastModDate();
        system.debug('Max last mod: ' + maxLastMod);
        //system.assert(maxLastMod == Date.newInstance()-10);
        Test.stopTest();
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 5: 
    // =======================================================================================================================================     
    @isTest static void testController_PsaCustomSelfAssignment() 
    {
        
        User resourceUser = [SELECT Id FROM User WHERE Alias = 'RSC1TST']; 
        pse__Proj__c project = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 1'];
        //pse__Proj__c newProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 2'];
        pse__Milestone__c milestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 1'];
        //pse__Milestone__c newMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 2'];
        Contact resource = [SELECT Id, Name FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Resource'];
        //pse__Assignment__c origAssignment = [SELECT Id FROM pse__Assignment__c WHERE Name = 'Test Assignment 1'];
        
        // Create a user and a resource to run as
        //Profile prof = [SELECT Name FROM Profile Name = 'System Administrator'];
        //List<Profile> lst = new List<Profile>([SELECT Name FROM Profile WHERE Name = 'AH PSA Administrator - Lightning']);
        //if (!lst.isEmpty())
        //{
        //    prof = lst[0];
        //}
        
        //User resourceUser = new User(ADUserName__c = 'apex1', alias='UM', username='um@test.com', lastname='assigntest', firstname='resource', email='um@test.com', communitynickname='um', timezonesidkey='America/New_York', LocaleSidKey='en_US', ProfileId=prof.Id, LanguageLocaleKey='en_US', EmailEncodingKey='UTF-8');
        //insert resourceUser;
        //Contact resource = createTestResource(resourceUser, defaultRegion, defaultPractice);
        
        //pse__Proj__c project = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null);
        //project.pse__Allow_Self_Staffing__c = true;
        //update project;
        //pse__Milestone__c milestone = createTestMilestone('Orig Milestone', project, false, false, MILESTONE_TYPE_BILLABLE);
        
        // Start the test and initialize the controller
        test.startTest();
        
        system.runAs(resourceUser)
        {
            
            PageReference pageRef = Page.PsaCustomSelfAssignment;
            Test.setCurrentPage(pageRef);
            system.debug('Page ref: ' + pageRef);
            PsaCustomSelfAssignmentController controller = new PsaCustomSelfAssignmentController();
            
            // New assignment and schedule should have been initialized
            pse__Assignment__c newAssignment = controller.assignment;
            pse__Schedule__c newSchedule = controller.schedule;
            controller.assignment.pse__Project__c = project.Id;
            controller.assignment.pse__Milestone__c = milestone.Id;
            system.debug('*********** Controller Resource Name: ' + controller.resourceName);
            system.debug('*********** Assignment Resource Name: ' + resource.Name);
            //system.assert(controller.resourceName.equals(resource.Name));
            
            
            // Trip start > end validation
            controller.schedule.pse__Start_Date__c = Date.Today();
            controller.schedule.pse__End_Date__c = Date.Today() -1;
            PageReference toPage = controller.createAssignment();
            
            
            // Trip start > next week validation
            controller.schedule.pse__Start_Date__c = Date.Today() + 14;
            controller.schedule.pse__End_Date__c = Date.Today() + 18;
            toPage = controller.createAssignment();
            
            // Trip start < last week validation
            controller.schedule.pse__Start_Date__c = Date.Today().toStartOfWeek() -10;
            controller.schedule.pse__End_Date__c = Date.Today();
            toPage = controller.createAssignment();
            
            // Get it right
            controller.schedule.pse__Start_Date__c = Date.Today()-3;
            controller.schedule.pse__End_Date__c = Date.Today();
            toPage = controller.createAssignment();
            
        }
        
        test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 6: Tests a successful assignment transfer of the 'Replace-Resource' type, without deleting original and shifting by 4 days
    // ======================================================================================================================================= 
    @isTest static void testController_PsaTransferAssignment_RRP_ShiftAndNotes() 
    {
        
        User resourceUser = [SELECT Id FROM User WHERE Alias = 'RSC1TST']; 
        pse__Proj__c origProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 1'];
        //pse__Proj__c newProject = [SELECT Id FROM pse__Proj__c WHERE Name = 'Test Project 2'];
        pse__Milestone__c origMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 1'];
        //pse__Milestone__c newMilestone = [SELECT Id FROM pse__Milestone__c WHERE Name = 'Milestone Test 2'];
        Contact newResource = [SELECT Id FROM Contact WHERE FirstName = 'PSAResource' AND LastName = 'Resource'];
        pse__Assignment__c origAssignment = [SELECT Id FROM pse__Assignment__c WHERE Name = 'Test Assignment 1'];
        
        // Create original project with start-end 10/1/2018 - 10/26/2018
        //pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null);
        //pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        
        // Create original assignment with a single daily note and 2 scheduled days
        //pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource);
        //Id origAssignmentId = origAssignment.Id;
        
        pse__Assignment_Daily_Note__c adn = new pse__Assignment_Daily_Note__c();
        adn.pse__Assignment__c = origAssignment.Id;
        adn.pse__Date__c = system.date.today();
        adn.pse__Note__c = 'Daily Note 1';
        insert adn; 

        // Create a new resource to whom the assignment will be transferred
        //Contact newResource = createTestResource(u, defaultRegion, defaultPractice);
            
        // Initialize page and controller
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController controller = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        pse__Assignment__c newAssignment = controller.getNewAssignment();
        pse__Schedule__c newSchedule = controller.getNewSchedule();
        
        // Set transfer parameters
        controller.setTransferType('RR');
        controller.changeTransferType();
        controller.setIsCopySchedule(false);
        controller.setIsCloseOriginal(true);
        
        test.startTest();
        
        // Set new schedule dates. Make it same length - 3 days but shift it forward 4 days
        newSchedule.pse__Start_Date__c = Date.NewInstance(2018, 10, 5);
        newSchedule.pse__End_Date__c = Date.NewInstance(2018, 10, 9);
        newSchedule.pse__Scheduled_Days__c = 3;
        newSchedule.pse__Scheduled_Hours__c = 24;
        newAssignment.pse__Resource__c = newResource.Id;
        
        // Transfer the assignment
        controller.transferAssignment();
        Id newAssignmentId = controller.getNewAssignmentId();
        //system.assert(newAssignmentId != null); 

        // Check the dates on the new assignment
        //pse__Assignment__c updatedNewAssignment = [SELECT pse__Start_Date__c, pse__End_Date__c FROM pse__Assignment__c WHERE Id =: origAssignment.Id];
        //system.assert(newSchedule.pse__Start_Date__c == updatedNewAssignment.pse__Start_Date__c);
        //system.assert(newSchedule.pse__End_Date__c == updatedNewAssignment.pse__End_Date__c);
        
        // Make sure the assignment daily notes got transfered
        //Integer noteCount = [SELECT COUNT() FROM pse__Assignment_Daily_Note__c WHERE pse__Assignment__c =: origAssignment.Id];
        //system.assert(noteCount==1); 
        
        test.stopTest();
        
    }












    
    
/* MOVED NEXT 4 TEST METHODS TO: PsaTransferAssignmentController_Test    
    
    // #############################################################
    // Tests the getters/setters/static variables in PsaTransferAssignmentController
    // #############################################################
    static testMethod void testController_PsaTransferAssignment_GettersAndSetters() 
    {
        
        initDefaultRP();
        initDefaultResource();
        
        // Create a project with start-end 10/1/2018 - 10/26/2018
        pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource, Date.newInstance(2018, 10, 1), Date.newInstance(2028, 10, 3), 3, 24);
        pse__Proj__c newProject = createTestProject('New Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c newMilestone = createTestMilestone('New Milestone', newProject, false, false, MILESTONE_TYPE_BILLABLE);
        Contact newResource = createTestResource(null, defaultRegion, defaultPractice);
        
        // Initialize
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        system.debug('Page ref: ' + pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController controller = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        
        // Make sure original assignment is set
        pse__Assignment__c checkAssig = controller.getOrigAssignment();
        system.assert(checkAssig != null);
        
        // Make sure original project is set
        String origProjectName = controller.getOrigProjectName();
        system.assert(origProjectName.equals('Orig Project'));
        
        // Make sure new assignment and schedule have been initialized
        pse__Assignment__c newAssignment = controller.getNewAssignment();
        pse__Schedule__c newSchedule = controller.getNewSchedule();
        system.assert(newAssignment!=null);
        system.assert(newSchedule!=null);

        // Check transfer type options
        List<SelectOption> ttOptions = controller.getTransferTypeOptions();
        system.assert(ttOptions.size() == 2);
        
        // Check settings based on chosen transfer type
        // First the default, then manually set
        boolean isNewResourceRendered=false;
        boolean isNewProjectRendered=false;
        String transferType = controller.getTransferType();
        system.assert(transferType.equals('RTP'));
        controller.changeTransferType();
        isNewResourceRendered = controller.getIsNewResourceRendered();
        isNewProjectRendered = controller.getIsNewProjectRendered();
        system.assert(isNewResourceRendered == false);
        system.assert(isNewProjectRendered == true);
        
        // Change transfer type and verify settings
        controller.setTransferType('RRP');
        controller.changeTransferType();
        isNewResourceRendered = controller.getIsNewResourceRendered();
        isNewProjectRendered = controller.getIsNewProjectRendered();
        system.assert(isNewResourceRendered == true);
        system.assert(isNewProjectRendered == false);

        // Change transfer type back and verify settings
        controller.setTransferType('RTP');
        controller.changeTransferType();
        isNewResourceRendered = controller.getIsNewResourceRendered();
        isNewProjectRendered = controller.getIsNewProjectRendered();
        system.assert(isNewResourceRendered == false);
        system.assert(isNewProjectRendered == true);
        
        // Check other default settings
        boolean isCopySchedule = controller.getIsCopySchedule();
        controller.setIsCopySchedule(false);
        boolean isCloseOriginal = controller.getIsCloseOriginal();
        controller.setIsCloseOriginal(false);
        boolean transferComplete = controller.getTransferComplete();
        system.assert(transferComplete==false);

        // Check milestone options
        controller.refreshMilestoneOptions();
        List<SelectOption> milestoneOptions = controller.getMilestoneOptions();
        //system.assert(milestoneOptions.size() == 1);
    }
    
    // #############################################################
    // Tests the validations and cancel action in PsaTransferAssignmentController
    // #############################################################
    static testMethod void testController_PsaTransferAssignment_ValidationsAndCancel() 
    {
        
        initDefaultRP();
        initDefaultResource();
        
        // Create a project with start-end 10/1/2018 - 10/26/2018
        pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource, Date.newInstance(2018, 10, 1), Date.newInstance(2028, 10, 3), 3, 24);
        pse__Proj__c newProject = createTestProject('New Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c newMilestone = createTestMilestone('New Milestone', newProject, false, false, MILESTONE_TYPE_BILLABLE);
        Contact newResource = createTestResource(null, defaultRegion, defaultPractice);
        
        // Initialize page and controller
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController controller = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        
        // Initialize transfer parameters
        pse__Assignment__c newAssignment = controller.getNewAssignment();
        pse__Schedule__c newSchedule = controller.getNewSchedule();
        controller.setTransferType('RTP');
        controller.changeTransferType();
        controller.setIsCopySchedule(false);
        controller.setIsCloseOriginal(false);
        newAssignment.pse__Resource__c = newResource.Id;
        newAssignment.pse__Project__c = newProject.Id;
        
        test.startTest();
        
        // First, start/end date null for validation error
        newSchedule.pse__Start_Date__c = null;
        newSchedule.pse__End_Date__c = null;
        controller.transferAssignment();
        List<ApexPages.Message> msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0);
        system.debug('Number of messages: ' + msgs.size());
        boolean foundMsg=false;
        for(Integer msgIndex=0; msgIndex<msgs.size(); msgIndex++)
        {
            String msg=msgs[msgIndex].getSummary();
            system.debug('##### Validation message: ' + msg);
            if(msg.contains('A start and end date are required.')) foundMsg=true;
        }
        system.assert(foundMsg);
        
        // Next, start date after end date
        newSchedule.pse__Start_Date__c = Date.NewInstance(2018,10,02);
        newSchedule.pse__End_Date__c = Date.NewInstance(2018,10,01);
        //controller.newSchedule = newSchedule;
        controller.transferAssignment();
        msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0);
        system.debug('Number of messages: ' + msgs.size());
        foundMsg=false;
        for(Integer msgIndex=0; msgIndex<msgs.size(); msgIndex++)
        {
            String msg=msgs[msgIndex].getSummary();
            system.debug('##### Validation message: ' + msg);
            if(msg.contains('The start cannot be before the end date.')) foundMsg=true;
        }
        system.assert(foundMsg);
            
        // Next, start date in the past
        newSchedule.pse__Start_Date__c = system.today()-1;
        newSchedule.pse__End_Date__c = Date.NewInstance(2018,10,01);
        controller.transferAssignment();
        msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0);
        system.debug('Number of messages: ' + msgs.size());
        foundMsg=false;
        for(Integer msgIndex=0; msgIndex<msgs.size(); msgIndex++)
        {
            String msg=msgs[msgIndex].getSummary();
            system.debug('##### Validation message: ' + msg);
            if(msg.contains('The assignment start date cannot be in the past.')) foundMsg=true;
        }
        system.assert(foundMsg);
        
        // Put schedule start date before project start date
        newSchedule.pse__Start_Date__c = Date.NewInstance(2018,01,01);
        newSchedule.pse__End_Date__c = Date.NewInstance(2018,10,01);
        controller.transferAssignment();
        msgs = ApexPages.getMessages();
        system.assert(msgs.size() > 0);
        system.debug('Number of messages: ' + msgs.size());
        foundMsg=false;
        for(Integer msgIndex=0; msgIndex<msgs.size(); msgIndex++)
        {
            String msg=msgs[msgIndex].getSummary();
            system.debug('##### Validation message: ' + msg);
            if(msg.contains('The specified Assignment start date is before the chosen Project start date.')) foundMsg=true;
        }
        system.assert(foundMsg);        

        // Test the cancel
        controller.cancel();
        
        test.stopTest();
    }

    // #############################################################
    // Tests a successful assignment transfer of the 'Resource-to-Project' type
    // #############################################################
    static testMethod void testController_PsaTransferAssignment_RTP() 
    {
        
        initDefaultRP();
        initDefaultResource();
        
        // Create original project with start-end 10/1/2018 - 10/26/2018
        pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        
        // Create original assignment with a single daily note and 10 scheduled days
        pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource, Date.newInstance(2018, 10, 1), Date.newInstance(2028, 10, 12), 10, 80);
        pse__Assignment_Daily_Note__c adn = new pse__Assignment_Daily_Note__c(pse__Assignment__c=origAssignment.Id, pse__Date__c=Date.NewInstance(2018,10,01), pse__Note__c='Daily Note 1');
        insert adn; 
 
        // Create new project for transfer of assignment, with 2 milestones
        pse__Proj__c newProject = createTestProject('New Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c newMilestone = createTestMilestone('New Milestone', newProject, false, false, MILESTONE_TYPE_BILLABLE);
        pse__Milestone__c newMilestone2 = createTestMilestone('New Milestone 2', newProject, false, false, MILESTONE_TYPE_BILLABLE);
                
        // Initialize page and controller
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController controller = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        pse__Assignment__c newAssignment = controller.getNewAssignment();
        pse__Schedule__c newSchedule = controller.getNewSchedule();
        
        // Set transfer parameters
        controller.setTransferType('RTP');
        controller.changeTransferType();
        controller.setIsCopySchedule(false);
        controller.setIsCloseOriginal(false);
        
        // Verify one milestone on original project (plus --None-- opton)
        List<SelectOption> milestoneOptions = controller.getMilestoneOptions();
        system.debug('### Number of milestones from original project assignment: ' + milestoneOptions.size());
        system.assert(milestoneOptions.size() == 2);
        
        test.startTest();
        
        // Set new schedule dates. Make it longer than 5 days
        newSchedule.pse__Start_Date__c = Date.NewInstance(2018, 10, 1);
        newSchedule.pse__End_Date__c = Date.NewInstance(2018, 10, 12);
        newAssignment.pse__Project__c = newProject.Id;
        
        // Now that project has been set, check milestone list. There should be 2 + --None-- option.
        controller.refreshMilestoneOptions();
        milestoneOptions = controller.getMilestoneOptions();
        system.assert(milestoneOptions.size() == 3);
        
        // Transfer the assignment
        controller.transferAssignment();
        Id newAssignmentId = controller.getNewAssignmentId();
        system.assert(newAssignmentId != null); 
        
        pse__Assignment__c updatedNewAssignment = [SELECT pse__Start_Date__c, pse__End_Date__c FROM pse__Assignment__c WHERE Id = :newAssignmentId];
        system.assert(newSchedule.pse__Start_Date__c == updatedNewAssignment.pse__Start_Date__c);
        system.assert(newSchedule.pse__End_Date__c == updatedNewAssignment.pse__End_Date__c);

        test.stopTest();
    }
  
  
    // #############################################################
    // Tests a successful assignment transfer of the 'Replace-Resource' type
    // #############################################################
    static testMethod void testController_PsaTransferAssignment_RRP() 
    {
        
        initDefaultRP();
        initDefaultResource();
        
        // Create original project with start-end 10/1/2018 - 10/26/2018
        pse__Proj__c origProject = createTestProject('Orig Project', defaultRegion, defaultPractice, PROJECT_STAGE_DRAFT, null, Date.NewInstance(2018, 10, 01), Date.NewInstance(2018, 10, 26));
        pse__Milestone__c origMilestone = createTestMilestone('Orig Milestone', origProject, false, false, MILESTONE_TYPE_BILLABLE);
        
        // Create original assignment with a single daily note and 2 scheduled days
        pse__Assignment__c origAssignment = createTestAssignment(origProject, defaultResource, Date.newInstance(2018, 10, 1), Date.newInstance(2028, 10, 2), 2, 16);
        Id origAssignmentId = origAssignment.Id;
        pse__Assignment_Daily_Note__c adn = new pse__Assignment_Daily_Note__c(pse__Assignment__c=origAssignment.Id, pse__Date__c=Date.NewInstance(2018,10,01), pse__Note__c='Daily Note 1');
        insert adn; 
 
        // Create a new resource to whom the assignment will be transferred
        Contact newResource = createTestResource(null, defaultRegion, defaultPractice);
            
        // Initialize page and controller
        PageReference pageRef = Page.PsaTransferAssignment;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.Standardcontroller(origAssignment);
        PsaTransferAssignmentController controller = new PsaTransferAssignmentController(sc);
        pageRef.getParameters().put('Id', origAssignment.Id);
        pse__Assignment__c newAssignment = controller.getNewAssignment();
        pse__Schedule__c newSchedule = controller.getNewSchedule();
        
        // Set transfer parameters
        controller.setTransferType('RR');
        controller.changeTransferType();
        controller.setIsCopySchedule(false);
        controller.setIsCloseOriginal(true);
        
        test.startTest();
        
        // Set new schedule dates. Make it same length - 2 days but shift it forward 3 days
        newSchedule.pse__Start_Date__c = Date.NewInstance(2018, 10, 4);
        newSchedule.pse__End_Date__c = Date.NewInstance(2018, 10, 5);
        newSchedule.pse__Scheduled_Days__c = 2;
        newSchedule.pse__Scheduled_Hours__c = 16;
        newAssignment.pse__Resource__c = newResource.Id;
        
        // Transfer the assignment
        controller.transferAssignment();
        Id newAssignmentId = controller.getNewAssignmentId();
        system.assert(newAssignmentId != null); 
system.debug('newAssignmentId'+newAssignmentId);
        // Check the dates on the new assignment
        pse__Assignment__c updatedNewAssignment = [SELECT pse__Start_Date__c, pse__End_Date__c FROM pse__Assignment__c WHERE Id = :newAssignmentId];
        system.assert(newSchedule.pse__Start_Date__c == updatedNewAssignment.pse__Start_Date__c);
        system.assert(newSchedule.pse__End_Date__c == updatedNewAssignment.pse__End_Date__c);
        
        // Make sure the old assignment was deleted
        Integer delCount = [SELECT COUNT() FROM pse__Assignment__c WHERE Id = :origAssignmentId];
        system.assert(delCount==0);
        
        
        test.stopTest();
    }
    
*/


    
    
    












    
/*    
    // =============================================================================================
    // TEST DATA CREATION METHODS
    // =============================================================================================

    // Creates a test Region 
    private static pse__Region__c createTestRegion(String regionName)
    {
        //pse__Region__c testRegion = new pse__Region__c(Name=regionName);
        pse__Region__c testRegion = NI_TestClassData.createTestRegion(1, 'regionName');
        testRegion.Name = 'regionName';
        insert testRegion;
        return testRegion;
    }

    // Creates a test Practice 
    private static pse__Practice__c createTestPractice(String practiceName)
    {
        // pse__Practice__c testPractice = new pse__Practice__c(Name=practiceName);
        pse__Practice__c testPractice = NI_TestClassData.createTestPractice(1, 'practiceName');
        testPractice.Name = 'practiceName';
        insert testPractice;
        return testPractice;
    }

    // Creates a test Project 
    private static pse__Proj__c createTestProject(String projectName, pse__Region__c region, pse__Practice__c practice, String projectStage, Opportunity opp)
    {
        
        initDefaultRP();
        
//        pse__Proj__c testProject = new pse__Proj__c(  Name=projectName,
//                                        pse__Is_Active__c=true,
//                                        pse__Is_Billable__c=true,
//                                        pse__Allow_Timecards_Without_Assignment__c=true,
//                                        pse__Allow_Expenses_Without_Assignment__c=true);
//        testProject.pse__Region__c = region.Id;
//        testProject.pse__Practice__c = practice.Id;
//        testProject.pse__Stage__c = projectStage;
 
        pse__Proj__c testProject = NI_TestClassData.createTestProject(1, projectName, region, practice, projectStage, opp);

        testProject.pse__Is_Active__c = true;
        testProject.pse__Is_Billable__c = true;
        testProject.pse__Allow_Timecards_Without_Assignment__c = true;
        testProject.pse__Allow_Expenses_Without_Assignment__c = true;        
        testProject.pse__Project_Type__c = 'Customer Project';
        testProject.pse__Project_Status__c = 'Green';  //ADDED PER SALESFORCE.COM CHANGE REQUEST: NICC-008249
        
        if (opp != null)
        {
            testProject.pse__Opportunity__c = opp.Id;
        }
        
        insert testProject;
        return testProject;
        
    }
    
    // Creates a test opportunity
    private static Opportunity createTestOpportunity(id AccountId, String opptyName, String stage, String orderStatus)
    {
        initDefaultRP();
        //Opportunity testOpportunity = new Opportunity(Name=opptyName, StageName=stage, Order_Status__c=orderStatus,Amount=25000);
        Opportunity testOpportunity = NI_TestClassData.createTestOpportunity(1, AccountId);
        testOpportunity.CloseDate = date.newInstance(2011, 7, 11);
        insert testOpportunity;
        return testOpportunity;
    }

    // Creates a test account
    private static Account createTestAccount(String accountName, String accountNumber)
    {
        // Account testAccount = new Account(Name=accountName, AccountNumber=accountNumber, CurrencyIsoCode='USD', BillingCountry='US',BillingState='VA', BillingStreet='1 Main', BillingCity='Springfield',Type='Customer', BillingPostalCode='22102');
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();             
        Account testAccount = NI_TestClassData.createTestAccount(1);
        testAccount.Name = accountName;
        testAccount.AccountNumber = accountNumber;
        testAccount.RecordTypeId = rtId;
        insert testAccount;
        return testAccount;
    }
    
    // Creates a test Milestone
    private static pse__Milestone__c createTestMilestone(String milestoneName, pse__Proj__c project, boolean cfte, boolean cfee, String milestoneType)
    {
        //pse__Milestone__c testMilestone = new pse__Milestone__c(Name=milestoneName);
        //testMilestone.pse__Project__c = project.Id;
        //testMilestone.pse__Closed_for_Expense_Entry__c = cfee;
        //testMilestone.pse__Closed_for_Time_Entry__c = cfte;
        //testMilestone.Milestone_Type__c = milestoneType;
        pse__Milestone__c testMilestone = NI_TestClassData.createTestMilestone(milestoneName, project, cfte, cfee, milestoneType);
        testMilestone.pse__Target_Date__c = date.newInstance(2011,12,31);
        testMilestone.pse__Status__c = MILESTONE_STATUS_DRAFT;        
        insert testMilestone;
        return testMilestone;
    }
    
    // Creates a test Resource
    private static Contact createTestResource(User salesforceUser, pse__Region__c region, pse__Practice__c practice)
    {

        initDefaultWorkCalendar();

//        Contact testResource = new Contact(LastName=DEFAULT_RESOURCE_NAME, pse__Resource_Role__c='Systems Engineering',
//            pse__Is_Resource__c=true,pse__Is_Resource_Active__c=true, MailingStreet='222 Oak St', MailingCity='Arlington', 
//            MailingState='VA', MailingCountry='US', MailingPostalCode='22102');

        Account a = createTestAccount('TEST ACCOUNT', 'jasg7236');
        
        Contact testResource = NI_TestClassData.createTestContact(1, a.Id);
        testResource.LastName = DEFAULT_RESOURCE_NAME;
        testResource.pse__Resource_Role__c = 'Systems Engineering';
        testResource.pse__Is_Resource__c = true;
        testResource.pse__Is_Resource_Active__c = true;
        testResource.pse__Region__c = region.Id;
        testResource.pse__Practice__c = practice.Id;
        testResource.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        
        if (salesforceUser != null)
        {
            testResource.pse__Salesforce_User__c = salesforceUser.Id;
        }
        
        insert testResource;
        return testResource;
        
    }
    
    // Creates a test Assignment
    public static pse__Assignment__c createTestAssignment(pse__Proj__c proj, Contact resource)
    {
        
        // Create an initial assignment schedule, 30 days out
        //pse__Schedule__c schedule = new pse__Schedule__c();
        //schedule.pse__Start_Date__c = system.Today() + 30;
        //schedule.pse__End_Date__c = system.Today() + 34;
        Date d1 = system.Today() + 30;
        Date d2 = system.Today() + 34;
        pse__Schedule__c schedule = NI_TestClassData.createTestSchedule(d1, d2);
        schedule.pse__Monday_Hours__c = 8;
        schedule.pse__Tuesday_Hours__c = 8;
        schedule.pse__Wednesday_Hours__c = 8;
        schedule.pse__Thursday_Hours__c = 8;
        schedule.pse__Friday_Hours__c = 8;
        insert schedule;
        
        // Create a permission control that will allow us to staff the resource
        insert new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Resource__c = resource.Id, pse__Staffing__c = true);
        insert new pse__Permission_Control__c(pse__User__c = UserInfo.getUserId(), pse__Region__c = defaultRegion.Id, pse__Staffing__c = true);
        
        // Create the assignment and associate it with the project
        // pse__Assignment__c assignment = new pse__Assignment__c(Name='Test Assignment');
        // assignment.pse__Project__c = proj.Id;
        // assignment.pse__Resource__c = resource.Id;
        // assignment.pse__Schedule__c = schedule.Id;
        pse__Assignment__c assignment = NI_TestClassData.createTestAssignment(resource.Id, schedule.Id, proj.Id);
        assignment.pse__Is_Billable__c = true;
        assignment.pse__Bill_Rate__c = 85;
        
        insert assignment;        
        return assignment;
        
    }

    // Initializes an instance-level work calendar that can be reused
    private static void initDefaultWorkCalendar()
    {
        if(defaultWorkCalendar==null)
        {
            defaultWorkCalendar = new pse__Work_Calendar__c(Name='Test Work Calendar');
            insert defaultWorkCalendar;
        }
    }

    // Initializes instance-level Region and Pratice
    private static void initDefaultRP()
    {
        if(defaultRegion==null)
        {
            defaultRegion = createTestRegion(DEFAULT_REGION_NAME);
        }
        
        if(defaultPractice==null)
        {
            defaultPractice = createTestPractice(DEFAULT_PRACTICE_NAME);
        }
    }    

    // Initializes an instance-level Resource that can be reused
    private static Contact initDefaultResource()
    {
        
        initDefaultRP();
        initDefaultWorkCalendar();
        
        List<Contact> cList = [SELECT Id FROM Contact WHERE pse__Salesforce_User__c =: UserInfo.getUserId()];
        for (Contact c : cList)
        {
            c.pse__Salesforce_User__c = null;
        }
        
        if (!cList.isEmpty())
        {
            update cList;
        }        
        
//        defaultResource = new Contact(LastName=DEFAULT_RESOURCE_NAME, pse__Resource_Role__c='Systems Engineering',
//            pse__Is_Resource__c=true,pse__Is_Resource_Active__c=true, MailingStreet='222 Oak St', MailingCity='Arlington', 
//            MailingState='VA', MailingCountry='US', MailingPostalCode='22102', pse__Salesforce_User__c=UserInfo.getUserId());
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        Contact defaultResource = NI_TestClassData.createTestContact(1, a.Id);
        defaultResource.LastName = DEFAULT_RESOURCE_NAME;
        defaultResource.pse__Resource_Role__c = 'Systems Engineering';
        defaultResource.pse__Is_Resource__c = true;
        defaultResource.pse__Is_Resource_Active__c = true;
        defaultResource.pse__Region__c = defaultRegion.Id;
        defaultResource.pse__Practice__c = defaultPractice.Id;
        defaultResource.pse__Work_Calendar__c = defaultWorkCalendar.Id;
        defaultResource.pse__Salesforce_User__c = UserInfo.getUserId();

        insert defaultResource;

        return defaultResource;
        
    }
*/
 

   
}