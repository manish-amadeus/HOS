@isTest
public class PsaCustomProjectLookupController_Test 
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
        prj1.Name = 'PsaCustomProjectLookupController_Test'; 
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
        
    }   

    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void testController_PsaCustomProjectLookup() 
    {
        
        Test.startTest();
        
        PageReference pageRef = Page.PsaCustomProjectLookup;
        Test.setCurrentPage(pageRef);
        
        PsaCustomProjectLookupController controller = new PsaCustomProjectLookupController();
        controller.go();
        
        pageRef.getParameters().put('projectName', 'PsaCustomProjectLookupController_Test');
        controller = new PsaCustomProjectLookupController();
        controller.go();
        List<pse__Milestone__c> lstMS = controller.milestones;
        
        Test.stopTest();
        
    }    
    
}