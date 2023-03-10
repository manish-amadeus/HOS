/***********************************************************************************************
Name            : AH_MedalliaInvitationsBatch_Schedule
Author          : Bhagwat Garkal
Created Date    : 07/13/2022
Last Mod Date   : 07/13/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Test class for AH_MedalliaInvitationsBatch_Schedule, AH_MedalliaInvitations_Batch   
                :
                :
************************************************************************************************/
@isTest 
public class AH_MedalliaInvitationsBatch_Test 
{
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData()
    {
        Support_Tier_Designation__c supportTier = new Support_Tier_Designation__c();
        supportTier.Support_Rep__c = Userinfo.getUserId();
        supportTier.Support_Rep_Role__c = 'Contractor';
        supportTier.Tier__c = 'Tier 1';
        supportTier.Inactive__c = false;
        supportTier.Region__c = 'Americas';
        supportTier.Team__c = 'Analysts';
        supportTier.Assigned_Product_Group__c = 'Amadeus PMS';
        supportTier.Trained_Products__c = 'Agency360';
        insert supportTier;
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST ACCOUNT 1';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        a.AccountNumber = '17050';
        a.BillingCountry = 'CA';
        a.BillingState = 'AB';
        a.Type = 'Customer';
        insert a;
        
        Contact contacts = NI_TestClassData.createTestContact(1, a.Id);
        //contacts.LastName='Test';
        contacts.Email='test@gmail.com';
        contacts.Spt_Survey_Opt_Out__c=false;
        insert contacts;
        
        Case cs = NI_TestClassData.createTestCase(1, a.Id);
        cs.Origin='Phone';
        cs.Status ='Working';
        cs.Priority ='3 - Medium';
        cs.Customer_Severity__c = '1 - System Down';
        cs.Type = 'Data Transfer';
        cs.Subject = 'Support_Selection_Criteria Subject';
        cs.Description = 'some test for medallia integration';
        cs.ContactId = contacts.Id; 
        cs.No_Survey__c = false; 
        cs.Survey_Invite_Sent__c = false;
        cs.Case_Reason__c = 'Data Fix';
        cs.Support_Tier_Designation__c = supportTier.Id;
        insert cs;

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
            User u2 = NI_TestClassData.createTestUser(3, 'AH PSA Management - Lightning'); 
            u2.Alias = 'MGR1TST'; 
            insert u2; 
            
            // CREATE TEST RESOURCE USER 
            User u3 = NI_TestClassData.createTestUser(4, 'AH PSA T&E - SF - Lightning'); 
            u3.Alias = 'RSC1TST'; 
            u3.ManagerId = u2.Id;
            insert u3;             
        }
        
        // GET TEST USERS CREATED BY FAKE ADMIN
        User regionApprover = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrceMgr = [SELECT Id FROM User WHERE Alias = 'RGA1TST'];
        User resrce = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];
        
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
        
        /* CREATE A TEST PSA PRACTICE  */
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
        pse__Proj__c prj = NI_TestClassData.createTestProject(1, 'Integrations', region, practice, 'Draft', null); 
        prj.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByName().get('Standard Project').getRecordTypeId(); 
        prj.Name = 'Expense Test Project'; 
        prj.pse__Closed_for_Expense_Entry__c = false; 
        prj.pse__Project_Manager__c = cntMgr.Id; 
        prj.pse__Start_Date__c = dt.addDays(10); 
        prj.pse__End_Date__c = dt.addDays(20); 
        prj.pse__Account__c = a.Id;
        prj.pse__Project_Type__c = 'Customer Project';
        insert prj;
        
        // CREATE TEST BILLABLE MILESTONES 
        pse__Milestone__c ms1 = NI_TestClassData.createTestMilestone('Milestone Test 1', prj, true, true, 'Billable Milestone');
        ms1.pse__Target_Date__c = dt;
        insert ms1;
        
        System.runAs(resrceMgr)  
        {
            // CREATE A TEST ASSIGNMENT 
            pse__Assignment__c as1 = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj.Id); 
            as1.Name = 'Test Assignment1'; 
            as1.pse__Is_Billable__c = false; 
            as1.pse__Bill_Rate__c = 0; 
            as1.pse__Location__c = 'Arkansas'; 
            as1.pse__Role__c = 'Integrations'; 
            as1.pse__Status__c = 'Scheduled'; 
            as1.Project_Manager__c = cntMgr.Id;
            //as1.pse__End_Date__c = System.Today();
            insert as1; 
            
            pse__Assignment__c as2 = NI_TestClassData.createTestAssignment(cnt.Id, sched2.Id, prj.Id); 
            as2.Name = 'Test Assignment'; 
            as2.pse__Is_Billable__c = false; 
            as2.pse__Bill_Rate__c = 0; 
            as2.pse__Location__c = 'Arkansas'; 
            as2.pse__Role__c = 'IT'; 
            as2.pse__Status__c = 'Scheduled'; 
            as2.Project_Manager__c = cntMgr.Id;
            //as2.pse__End_Date__c = System.Today();
            insert as2;
        }
        
        pse__Assignment__c ast = [select Id,Name from pse__Assignment__c where Name = 'Test Assignment' limit 1];
        
        Medallia_Service_Survey__c service = new Medallia_Service_Survey__c();
        service.Account_ID__c = a.Id;
        service.Account_Name__c = a.Name;
        service.Account_Name__c = a.AccountNumber;
        service.Assignment_End_Date__c = System.today();
        service.Assignment_ID__c = ast.Id;
        service.Assignment_Name__c = ast.Name;
        service.Assignment_Number__c = 'A-0000003';
        service.Assignment_Start_Date__c = System.today();
        service.Assignment_Status__c = 'Scheduled';
        service.Brand__c = 'Pullman';
        service.ContactAddress__c = '1225 sw 94 ave';
        service.ContactCity__c = 'Epping';
        service.ContactCountry__c = 'United States';
        service.ContactId__c = cnt.Id;
        service.Phone__c ='3057618765';
        service.ContactState__c ='NH';
        service.ContactZipCode__c = '03042';
        service.Email__c ='test@gmail.com';
        //service.End_Date__c = System.today();
        //FailReason__c
        service.FirstName__c = 'TestF';
        service.Franchisor__c = 'Accor Company';
        service.Group_Name__c ='RES';
        service.LastName__c = 'TestL';
        //Mgt_Company__c = 
        service.Milestone_ID__c = ms1.Id;
        service.Milestone_Name__c = 'Milestone Test 1';
        service.Milestone_Type__c = 'Billable Milestone';
        service.NumberOfRetries__c = 1.00;
        service.Opportunity_Number__c ='589655';
        service.Primary_Language__c = 'English';
        service.Process_Status__c = 'Not Processed Yet';
        //service.Destination__c = 'test';
        service.Project_ID__c = prj.Id;
        service.Project_Manager__c = resrceMgr.Id; 
        service.ProjectName__c = 'Project - Installer Survey';
        service.Region_Name__c = 'US';
        service.Resource_Name__c = 'some value';
        service.Resource_Practice__c = 'Insaller';
        //Retry__c
        service.Role__c = 'Installer';
        //SendtoMedalliaDate__c
        //service.Start_Date__c = System.today();
        //SurveySubType__c 
        service.SurveyType__c = 'Services - Installer Survey';
        service.Title__c = 'TestTitle';
        Insert service;
    }
    
    // ======================================================================================================================================= 
    //  TEST METHODS FOR AH_MedalliaInvitationsBatch_Schedule SCHEDULABLE CLASS 
    // ==========================================================================================================================
    @isTest static void testSchedulableClass()
    {
        Test.startTest();
        
        AH_MedalliaInvitationsBatch_Schedule sch2 = new AH_MedalliaInvitationsBatch_Schedule(); 	// Schedule apex class name
        String sch = '0 0 23 * * ?'; 													// schedule interval time
        system.schedule('TEST Batch', sch, sch2); 										// system method to schedule apex class
        
        // CHECK AH_MedalliaInvitationsBatch_Schedule CLASS SCHEDULED OR NOT
        List<CronJobDetail> lstcronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'TEST Batch'];
        system.assertEquals(1, lstcronJob.Size(), 'AH_MedalliaInvitationsBatch_Schedule Class has not scheduled.');
        
        // CHECK ASSIGNMENT RECORD CREATED OR NOT
        List<pse__Assignment__c> ast = [select Id,Name from pse__Assignment__c where Name = 'Test Assignment' limit 1];
        system.assertEquals(1, ast.Size(), 'Assignment Records Not Created');
        
        Test.StopTest();
    } 
    
}