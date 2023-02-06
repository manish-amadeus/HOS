/***********************************************************************************************
Name            : AH_MedalliaSurvey_Schedule_Test
Author          : Bhagwat Garkal
Created Date    : 06/28/2022
Last Mod Date   : 06/28/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Test class for AH_MedalliaSurvey_Schedule, AH_MedalliaSurvey_Batch  
                :
                :
************************************************************************************************/
@isTest
public class AH_MedalliaSurvey_Schedule_Test 
{
    
    // ======================================================================================================================================= 
    //  CREATE TEST DATA
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
        
        List<Medallia_Selection_Criteria__c> lstofCriteria = new List<Medallia_Selection_Criteria__c>();
        
        //CREATE TEST Medallia_Selection_Criteria__c Record  for Support
        Medallia_Selection_Criteria__c support = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Support Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Customer Support',
            Contact_Status__c='Active',
            Restricted_Emails__c='@travelclick.com',
            Criteria_Invisible_Logic__c='Have an owner associated with itHave an account associated with itHave a contact associated with itHave createdbyid with valid idContact associated with case has not been surveyed in the last 22 days and contact has to be active and contact has not bounced from previous surveys sent',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Active__c = true
        );
        
        lstofCriteria.add(support);
        
        //CREATE TEST Medallia_Selection_Criteria__c Record  for Solution Adoption
        Medallia_Selection_Criteria__c solutionAdoption = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Solution Adoption').getRecordTypeId(),
            Record_Type__c='Solution Adoption',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='Development Deployment',
            SurveyType__c='Solution Adoption',
            Contact_Status__c='Active',
            Restricted_Emails__c='@travelclick.com',
            Criteria_Invisible_Logic__c='Have an owner associated with itHave an account associated with itHave a contact associated with itHave createdbyid with valid idContact associated with case has not been surveyed in the last 22 days and contact has to be active and contact has not bounced from previous surveys sent',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Active__c = true
        );
        
        lstofCriteria.add(solutionAdoption);
        
        //CREATE TEST Medallia_Selection_Criteria__c Record  for Service
        Medallia_Selection_Criteria__c serviceInstaller = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Service Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Services - Installer Survey',
            Project_Type__c='Customer Project',
            Role__c = 'Integrations',
            Assignment_Status__c = 'Scheduled',
            Restricted_Emails__c = '@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com',
            Group__c = 'Property Management',
            Contact_Status__c='Active',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Number_of_Days__c = 3,
            Active__c = true
        );
        
        lstofCriteria.add(serviceInstaller);
        
        Medallia_Selection_Criteria__c consultantsSurvey = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Service Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Services - Consulting Survey',
            Project_Type__c='Customer Project',
            Role__c = 'Integrations',
            Assignment_Status__c = 'Scheduled',
            Restricted_Emails__c = '@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com',
            Group__c = 'Property Management',
            Contact_Status__c='Active',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Number_of_Days__c = 3,
            Active__c = true
        );
        
        lstofCriteria.add(consultantsSurvey);
        
        Medallia_Selection_Criteria__c trainingSurvey = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Service Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Services - Training Survey',
            Project_Type__c='Customer Project',
            Role__c = 'Integrations',
            Assignment_Status__c = 'Scheduled',
            Restricted_Emails__c = '@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com',
            Group__c = 'Property Management',
            Contact_Status__c='Active',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Number_of_Days__c = 3,
            Active__c = true
        );
        
        lstofCriteria.add(trainingSurvey);
        
        Medallia_Selection_Criteria__c pmSurvey = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Service Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Services - Project Manager',
            SurveySubType__c = 'No/Training',
            Project_Type__c='Customer Project',
            Role__c = 'Integrations',
            Assignment_Status__c = 'Scheduled',
            Restricted_Emails__c = '@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com',
            Group__c = 'Property Management',
            Contact_Status__c='Active',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Number_of_Days__c = 2,
            Active__c = true
        );
        
        lstofCriteria.add(pmSurvey);
        
        Medallia_Selection_Criteria__c pm2Survey = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Service Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Services - Project Manager',
            SurveySubType__c = 'W/Training',
            Project_Type__c='Customer Project',
            Role__c = 'Integrations',
            Assignment_Status__c = 'Scheduled',
            Restricted_Emails__c = '@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com',
            Group__c = 'Property Management',
            Contact_Status__c='Active',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Number_of_Days__c = 3,
            Active__c = true
        );
        
        lstofCriteria.add(pm2Survey);
        
        Medallia_Selection_Criteria__c pm3Survey = new Medallia_Selection_Criteria__c (
            RecordTypeId= Schema.SObjectType.Medallia_Selection_Criteria__c.getRecordTypeInfosByName().get('Service Selection Criteria').getRecordTypeId(),
            Record_Type__c='Close Case',
            Case_Origin__c='OnSite',
            Case_Status__c='Closed',
            Case_Type__c='Inquiry',
            Credit_Status__c='Declined',
            Support_Tier__c='Contractor',
            Case_Reason__c='User Management',
            SurveyType__c='Services - Project Manager',
            SurveySubType__c = 'Project',
            Project_Type__c='Customer Project',
            Role__c = 'Integrations',
            Assignment_Status__c = 'Scheduled',
            Restricted_Emails__c = '@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com',
            Group__c = 'Property Management',
            Contact_Status__c='Active',
            Interval__c= 0,
            Type__c='Customer',
            Last_Execution_time__c = System.now(),
            Number_of_Days__c = 3,
            Active__c = true
        );
        
        lstofCriteria.add(pm3Survey);
        
        insert lstofCriteria; 
        
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
        Date sdt = system.date.today().addDays(-10);
        Date edt = system.date.today().addDays(-3);
        pse__Schedule__c sched = NI_TestClassData.createTestSchedule(sdt, edt);
        insert sched;
        
        pse__Schedule__c sched2 = NI_TestClassData.createTestSchedule(sdt, edt);
        insert sched2;
        
        /* CREATE A TEST PSA PRACTICE  */
        pse__Practice__c practice = NI_TestClassData.createTestPractice(1, 'psaTestPractice');
        practice.Name = 'psaTestPractice';
        insert practice;
        
        // CREATE TEST WORK CALENDAR
        pse__Work_Calendar__c WorkCalendar = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
        insert WorkCalendar;    
        
        // CREATE TEST GROUP
        pse__Grp__c grp = NI_TestClassData.createTestPSEGroup('Property Management');
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
        
        // CREATE "RESOURCE" CONTACT 
        Contact con = NI_TestClassData.createTestContact(1, a.Id);        
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId(); 
        con.FirstName = 'TestResource';
        con.LastName = 'ConResource';
        con.pse__Region__c = region.Id;
        con.pse__Practice__c = practice.Id;
        con.pse__Work_Calendar__c = WorkCalendar.Id;
        con.pse__Group__c = grp.Id;
        //con.pse__Is_Resource_Active__c = true;
        //con.pse__Is_Resource__c = true;
        //con.pse__Salesforce_User__c = resrce.Id;
        insert con;
        
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
        prj.Customer_Project_Contact__c = con.Id;
        insert prj;
        
        // CREATE TEST BILLABLE MILESTONES 
        pse__Milestone__c ms1 = NI_TestClassData.createTestMilestone('Milestone Test 1', prj, true, true, 'Billable Milestone');
        ms1.pse__Target_Date__c = dt;
        insert ms1;
        System.runAs(resrceMgr)  
        {
            // CREATE A TEST ASSIGNMENT 
            pse__Assignment__c as1 = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, prj.Id); 
            as1.Name = 'Test Assignment'; 
            as1.pse__Is_Billable__c = false; 
            as1.pse__Bill_Rate__c = 0; 
            as1.pse__Location__c = 'Arkansas'; 
            as1.pse__Role__c = 'Integrations'; 
            as1.pse__Status__c = 'Scheduled'; 
            as1.Project_Manager__c = cntMgr.Id;
            as1.Contact_Name__c = con.Id;
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
            as2.Contact_Name__c = con.Id;
            //as2.pse__End_Date__c = System.Today();
            insert as2;
        }
    }
    
    // ======================================================================================================================================= 
    //  TEST METHODS FOR AH_MedalliaSurvey_Schedule SCHEDULABLE CLASS 
    // =======================================================================================================================================
    @isTest static void testSchedulableClass()
    {
        
        Test.startTest();
        
        AH_MedalliaSurvey_Schedule sch2 = new AH_MedalliaSurvey_Schedule(); 	// Schedule apex class name
        String sch = '0 0 23 * * ?'; 											// schedule interval time
        system.schedule('TEST Batch', sch, sch2); 								// system method to schedule apex class
        
        // CHECK AH_MedalliaSurvey_Schedule CLASS SCHEDULED OR NOT
        List<CronJobDetail> lstcronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'TEST Batch'];
        system.assertEquals(1, lstcronJob.Size(), 'AH_MedalliaSurvey_Schedule Class has not scheduled.');
        
        Test.StopTest();
        
    }
    
    // ======================================================================================================================================= 
    //  TEST METHODS FOR AH_MEDALLIASURVEY_BATCH CLASS METHODS
    // =======================================================================================================================================
    @isTest static void testBatchClass()
    {
        
        Test.startTest();
        List<Case> cslist = [select Id, Origin,AssetId,CaseNumber,ContactId,Case_Reason__c,Asset.Name,Status,Support_Tier_Designation__c,Support_Tier_Designation__r.Inactive__c,Account_Name__c,Contact.Name,
                             AccountId,Type,Account.Type,RecordType.Name,Contact.Spt_Survey_Opt_Out__c,Account.Spt_Survey_Opt_Out__c,No_Survey__c,Contact.Title,DI_Product_Group__c,
                             Contact.Salutation,Contact.FirstName,Contact.LastName,Account.Name,Account.Management_Company_Name__c,Account.Franchisor__c,Account.Brand__c,Contact.MailingAddress,
                             Contact.Phone,Contact.Email,OwnerId,Owner.Name,Subject,Deployment_Instance_History_Record__c,Reason,Priority,Customer_Severity__c,CreatedDate,
                             ClosedDate,Solution_Domain__c,SupportRegion__c,Contact.MailingStreet,Contact.MailingCity,Contact.MailingCountry,Contact.MailingState,Contact.MailingPostalCode,
                             Project__c,Project__r.pse__Group__c,Project__r.pse__Group__r.Name,Project__r.Survey_Sent__c,Solution_Adoption_Start_Date__c,Product_Group__c,Appointment_Booked_Email_Received__c,
                             Support_Tier__c,Support_Tier_Designation_Region__c,Case_Product_Line__c,Module__c,Component__c,Actual_time__c,Level_1_Tier__c FROM Case where 
                             Type = 'Data Transfer' limit 1];
        
        system.assertEquals(1, cslist.Size(), 'Case Record Not Created.');
     
        //AH_MedalliaSurvey_Batch  Ms = new AH_MedalliaSurvey_Batch('Service_Selection_Criteria','Services - Installer Survey',null);
        //Database.executeBatch(Ms,10);
        
        AH_MedalliaSurvey_Batch batch = new AH_MedalliaSurvey_Batch();
        
        // CHECK MEDALLIA_SUPPORT_SURVEY__C RECORD CREATED OR NOT
        List<Medallia_Support_Survey__c> supportSurveylist = new List<Medallia_Support_Survey__c>();
        supportSurveylist.add(batch.generateSupportSurvey(cslist[0],'Customer Support'));
        system.assertEquals(1, supportSurveylist.size(), 'Medallia Support Survey Not Generateed');
        batch.getExistingSupportSurveys(new Set<Id> {cslist[0].Id},null,null);
        batch.getExistingSupportSurveys(null,new Set<Id> {cslist[0].ContactId},22);
        
        // CHECK MEDALLIA_ADOPTION_SURVEY__C RECORD CREATED OR NOT
        List<Medallia_Adoption_Survey__c> adoptionSurveylist = new List<Medallia_Adoption_Survey__c>();
        adoptionSurveylist.add(batch.generateAdoptionSurvey(cslist[0],'Solution Adoption'));
        system.assertEquals(1, adoptionSurveylist.size(), 'Adoption Survey Not Generateed');
        batch.getExistingAdoptionSurveys(new Set<Id> {cslist[0].Id},null,null);
        batch.getExistingAdoptionSurveys(null,new Set<Id> {cslist[0].ContactId},22);
        
        
        List<pse__Assignment__c> asslist = [Select Id, Name,pse__Project__c,pse__Project__r.Name,pse__Project__r.Id,pse__Project__r.Customer_Project_Contact__r.Id,pse__Project__r.pse__Project_ID__c,pse__Milestone__c,pse__Milestone__r.Name,pse__Milestone__r.Milestone_Type__c,
                                            	pse__Milestone__r.Id,Resource_Practice_Name__c,pse__Project__r.Opportunity_Number__c,pse__Assignment_Number__c,Contact_Name__c,
                                            	Contact_Name__r.Id,Contact_Name__r.Name,Contact_Name__r.Title,Contact_Name__r.Salutation,Contact_Name__r.FirstName,Contact_Name__r.LastName,Contact_Name__r.Email,
                                                Contact_Name__r.MailingAddress,Contact_Name__r.MailingStreet,Contact_Name__r.MailingCity,Contact_Name__r.MailingCountry,Contact_Name__r.MailingState,Contact_Name__r.MailingPostalCode,
                                                Contact_Name__r.Phone,Contact_Name__r.Primary_Language__c, Contact_Name__r.AccountId, Contact_Name__r.Account.Name,Contact_Name__r.Account.AccountNumber,Contact_Name__r.Account.Spt_Survey_Opt_Out__c,
                                                Contact_Name__r.Account.Brand__c,Contact_Name__r.Account.Franchisor__c,pse__Project__r.pse__Region__c,pse__Project__r.pse__Region__r.Name,pse__Project__r.pse__Group__c,pse__Project__r.pse__Group__r.Name,
                                                pse__Start_Date__c,pse__End_Date__c ,pse__Resource__c,pse__Resource__r.Name,pse__Status__c,pse__Role__c,pse__Milestone__r.pse__Override_Project_Practice__c,pse__Milestone__r.pse__Override_Project_Practice__r.Name,
                                                pse__Project__r.Customer_Project_Contact__r.AccountId,pse__Project__r.Customer_Project_Contact__r.Account.Name,pse__Project__r.Customer_Project_Contact__r.Account.AccountNumber,pse__Project__r.Customer_Project_Contact__r.Account.Brand__c,
                                                pse__Project__r.Customer_Project_Contact__r.MailingAddress,pse__Project__r.Customer_Project_Contact__r.MailingCity,pse__Project__r.Customer_Project_Contact__r.MailingCountry,pse__Project__r.Customer_Project_Contact__r.Phone,
                                                pse__Project__r.Customer_Project_Contact__r.MailingState,pse__Project__r.Customer_Project_Contact__r.MailingPostalCode,pse__Project__r.Customer_Project_Contact__r.Email,pse__Project__r.Customer_Project_Contact__r.FirstName,
                                                pse__Project__r.Customer_Project_Contact__r.LastName,pse__Project__r.Customer_Project_Contact__r.Title,pse__Project__r.Customer_Project_Contact__r.Account.Franchisor__c,pse__Project__r.Customer_Project_Contact__r.Primary_Language__c,
                                                Project_Manager__c,Project_Manager__r.Name FROM pse__Assignment__c where Name = 'Test Assignment'];
        System.debug('asslist==>'+asslist);
        
        // CHECK MEDALLIA_SERVICE_SURVEY__C RECORD CREATED OR NOT
        List<Medallia_Service_Survey__c> serviceSurveylist = new List<Medallia_Service_Survey__c>();
        serviceSurveylist.add(batch.generateServiceSurvey(asslist[0],'Services - Installer Survey','Installer'));
        system.assertEquals(1, serviceSurveylist.size(), 'Medallia Service Survey Not Generateed');
        batch.getExistingServiceSurveys(new Set<Id> {asslist[0].Id},null,null);
        batch.getExistingServiceSurveys(null,new Set<Id> {asslist[0].Contact_Name__r.Id},22);
        batch.getRestrictedEmailDomain('@newmarketinc.com; @amadeus.com; @meetingMatrix.com; @m-tech.com;@accenture.com;@travelclick.com');
        batch.getTraningAssignments(New Set<Id> {asslist[0].pse__Project__r.Id});
        Test.StopTest();
        
    }

    
}