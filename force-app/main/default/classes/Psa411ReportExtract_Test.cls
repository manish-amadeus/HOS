/************************************************************************************************
Name            : Psa411ReportExtract_Test
Author          : Sean Harris
Created Date    : 06/06/2022
Last Mod Date   : 06/06/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
*************************************************************************************************/
@isTest
public class Psa411ReportExtract_Test 
{    

    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        
        Test.StartTest();

        
        // CREATE A SYSTEM ADMIN USER TO INSERT THE TEST USER RECORDS TO AVOID MIXED_DML_OPERATION 
        User saUser = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        saUser.Alias = 'SA1TST'; 
        insert saUser;         
        
        system.runAs(saUser)
        {
            // CREATE TEST RESOURCE USER 
            User u = NI_TestClassData.createTestUser(4, 'AH PSA T&E - SF - Lightning'); 
            u.Alias = 'RSC1TST'; 
            insert u;             
        }

        // GET TEST USER CREATED BY FAKE ADMIN
        User resrce = [SELECT Id FROM User WHERE Alias = 'RSC1TST'];


        // CREATE TEST ACCOUNT RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;

        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;

        // GET RECORDTYPE ID
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema1.getRecordTypeInfosByName(); 
        Id opptyRecTypeId = OpportunityRecordTypeInfo.get('HRM New Org Opportunity').getRecordTypeId();
        
        Opportunity o = NI_TestClassData.createTestOpportunity(1, a.Id); 
        o.Name = 'APEX TEST OPPORTUNITY 1';
        o.RecordTypeId = opptyRecTypeId;
        insert o;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;
        
        Asset asset = NI_TestClassData.createTestAsset(1, a.Id, prd.Id);
        asset.Product_Group__c = pgp.Id;
        insert asset;
        
        PricebookEntry pbe = NI_TestClassData.createTestPricebookEntry(Test.getStandardPricebookId(), prd.Id, 1000);
        insert pbe;
        
        OpportunityLineItem oli = NI_TestClassData.createTestOpportunityLineItem(1, o.Id, pbe.Id, 1);  
        oli.Product2Id = prd.Id;
		insert oli;        
        
        // CREATE TEST CASE RECORD
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        insert c;

    
        Test.StopTest();

        
        // CREATE A TEST PSA SCHEDULE  
        Date dt = system.date.today();
        pse__Schedule__c sched = NI_TestClassData.createTestSchedule(dt.addDays(-2), dt.addDays(2));
        insert sched;
        
        // CREATE A TEST PSA REGION  
        pse__Region__c reg = NI_TestClassData.createTestRegion(1, 'Test Region');
        insert reg;

        // GRANT ACCESS TO RUNNING USER
        pse__Permission_Control__c pm2 = NI_TestClassData.createTestPermissionControl(UserInfo.getUserId());
        pm2.pse__Region__c = reg.Id;        
//        pm2.pse__Staffing__c = true; 
//        pm2.pse__Timecard_Entry__c = true; 
//        pm2.pse__Expense_Entry__c = true;
        pm2.pse__Billing__c = true;
        pm2.pse__Cascading_Permission__c = true;
        pm2.pse__Expense_Entry__c = true;
        pm2.pse__Expense_Ops_Edit__c = true;
        pm2.pse__Forecast_Edit__c = true;
        pm2.pse__Forecast_View__c = true;
        pm2.pse__Invoicing__c = true;
        pm2.pse__Edit_Task_Manager__c = true;
        pm2.pse__View_Task_Manager__c = true;
        pm2.pse__Compare_Project_Version__c = true;
        pm2.pse__Create_Project_Version__c = true;
        pm2.pse__Delete_Project_Version__c = true;
        pm2.pse__Resource_Request_Entry__c = true;
        pm2.pse__Skills_And_Certifications_Entry__c = true;
        pm2.pse__Skills_And_Certifications_View__c = true;
        pm2.pse__Staffing__c = true;
        pm2.pse__Team_Create__c = true;
        pm2.pse__Team_Edit__c = true;
        pm2.pse__Team_View__c = true;
        pm2.pse__Timecard_Entry__c = true;
        pm2.pse__Timecard_Ops_Edit__c = true;
        insert pm2;  
        
        // CREATE A TEST PSA PRACTICE  
        pse__Practice__c pract = NI_TestClassData.createTestPractice(1, 'Test Practice');
        insert pract;
        
        // CREATE A TEST WORK CALENDAR  
        pse__Work_Calendar__c wc = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
        insert wc;
        
        // CREATE A TEST GROUP
        pse__Grp__c grp = NI_TestClassData.createTestPSEGroup('Test Group');
        insert grp;   
        
        // CREATE A TEST PSA PROJECT
        pse__Proj__c proj = NI_TestClassData.createTestProject(1, 'Test Project', reg, pract, 'Draft', null);
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;  
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Closed_for_Time_Entry__c = false;
        insert proj;
        
        // CREATE A TEST MILESTONE  
        pse__Milestone__c ms = NI_TestClassData.createTestMilestone('PSA Test Milestone', proj, false, false, 'Billable Milestone');
        ms.pse__Closed_for_Expense_Entry__c = false;
        insert ms; 

        // CREATE TEST RESOURCE CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Resource').getRecordTypeId(); 
        cnt.FirstName = 'PSAResource';
        cnt.LastName = 'Resource';
        cnt.pse__Region__c = reg.Id;
        cnt.pse__Practice__c = pract.Id;
        cnt.pse__Work_Calendar__c = wc.Id;
        cnt.pse__Group__c = grp.Id;
    	cnt.pse__Is_Resource_Active__c = true;
    	cnt.pse__Is_Resource__c = true;
        cnt.pse__Salesforce_User__c = resrce.Id;
    	insert cnt; 
        
        // CREATE A TEST PSE ASSIGNMENT
        pse__Assignment__c assmnt = NI_TestClassData.createTestAssignment(cnt.Id, sched.Id, proj.Id);
        assmnt.pse__Milestone__c = ms.Id;
        assmnt.pse__Status__c = 'Scheduled';
        insert assmnt; 

        
    }

    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void testApex_Psa411ExtractScheduledApex() 
    {

        Opportunity o = [SELECT Id FROM Opportunity WHERE Name = 'APEX TEST OPPORTUNITY 1']; 
            
        Test.startTest(); 
        
        Psa411ReportExtract ctrl = new Psa411ReportExtract();
        
        ctrl.assignmentOpportunities.add(o.Id); 
        ctrl.runScheduledExtract();
        //ctrl.execute();
        
        Test.stopTest();    
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void testApex_Psa411ExtractTrigger() 
    {
        
        Date dt = system.date.today();
        Date dtAssgnStart = dt.addDays(-2);    
        Date dtAssgnEnd = dt.addDays(2);  
        
        List<pse__Assignment__c> lstAssignment = new List<pse__Assignment__c>(
            [SELECT Id FROM pse__Assignment__c
             WHERE pse__Status__c = 'Scheduled'
             AND pse__Start_Date__c =: dtAssgnStart
             AND pse__End_Date__c = : dtAssgnEnd]);         
        
        system.assertEquals(1, lstAssignment.size());
        
        Test.startTest();
        
        PSA_411_Report__c reportHeader = new PSA_411_Report__c();
        reportHeader.From_Date__c = dt;
        reportHeader.To_Date__c = dt;
        reportHeader.Run_As_Scheduled_Batch__c = false;
        insert reportHeader;
        
        Test.stopTest();
        
    }
    
}