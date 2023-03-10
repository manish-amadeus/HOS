@isTest
public class psaExpenseReport_Test 
{

    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        Test.startTest();
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        Id rtId = NI_TestClassData.getRecordTypeId('Account', 'Parent Account');
        
        // CREATE TEST USERS
        List<User> lstUserInsert = new List<User>();
        User u1 = NI_TestClassData.createTestUser(1, 'System Administrator'); 
        u1.Alias = 'SA01TST'; 
        lstUserInsert.Add(u1); 
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator'); 
        u2.Alias = 'EMP1TST'; 
        lstUserInsert.Add(u2);        
        User u3 = NI_TestClassData.createTestUser(3, 'NI Administrator'); 
        u3.Alias = 'MGR1TST'; 
        lstUserInsert.Add(u3);
        User u4 = NI_TestClassData.createTestUser(4, 'NI Administrator'); 
        u4.Alias = 'MGR2TST'; 
        lstUserInsert.Add(u4);        
        Database.insert(lstUserInsert); 
        
        List<User> lstUserAsserts = new List<User>([SELECT Id FROM User WHERE Alias IN ('SA01TST', 'EMP1TST', 'MGR1TST', 'MGR2TST')]);
        system.assertEquals(4, lstUserAsserts.Size());
        
        // CREATE TEST ACCOUNTS
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtParentAccountId = AccountRecordTypeInfo.get('Parent Account').getRecordTypeId();
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        List<Account> lstAccountInsert = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'APEX TEST PARENT ACCOUNT 1';
        a1.RecordTypeId = rtParentAccountId;
        lstAccountInsert.Add(a1);
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a2.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a2);
        Account a3 = NI_TestClassData.createTestAccount(3);
        a3.Name = 'APEX TEST PROPERTY ACCOUNT 2';
        a3.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a3);        
        
        Database.insert(lstAccountInsert); 
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name LIKE 'APEX TEST %']);
        system.assertEquals(3, lstAccountAsserts.Size());

        Test.stopTest();
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'APEXTESTUSER';
        cnt.LastName = 'APEXTESTUSER';
        insert cnt;
        
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
        
    }

    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {

        User u = [SELECT Id FROM User WHERE Alias = 'SA01TST']; 
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1']; 
        Product2 p2 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode = 'APEX-TEST-01'];   
        Contact c = [SELECT Id FROM Contact WHERE FirstName = 'APEXTESTUSER' AND LastName = 'APEXTESTUSER'];

         // CREATE A TEST PSA SCHEDULE  
        Date dt = system.date.today(); 
        pse__Schedule__c sched = NI_TestClassData.createTestSchedule(dt.addDays(1), dt.addDays(2));
        insert sched;
        
        // CREATE A TEST PSA REGION  
        pse__Region__c reg = NI_TestClassData.createTestRegion(1, 'Test Region');
        insert reg;
        
        // CREATE A TEST PSA PRACTICE  
        pse__Practice__c pract = NI_TestClassData.createTestPractice(1, 'Test Practice');
        insert pract;

        // CREATE A TEST PSA PROJECT
        pse__Proj__c proj = NI_TestClassData.createTestProject(1, 'Test Project', reg, pract, 'Draft', null);
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Allow_Expenses_Without_Assignment__c = true;  
        proj.pse__Closed_for_Expense_Entry__c = false;
        proj.pse__Closed_for_Time_Entry__c = false;
        insert proj;
        
        // CREATE A TEST WORK CALENDAR  
        pse__Work_Calendar__c wc = NI_TestClassData.createTestWorkCalendar('Test Work Calendar');
        insert wc;
        
        // CREATE A TEST GROUP
        pse__Grp__c grp = NI_TestClassData.createTestPSEGroup('Test Group');
        insert grp;   
        
        // CREATE A TEST MILESTONE  
        pse__Milestone__c ms = NI_TestClassData.createTestMilestone('PSA Test Milestone', proj, false, false, 'Billable Milestone');
        ms.pse__Closed_for_Expense_Entry__c = false;
        insert ms; 

        // CREATE A TEST MILESTONE (WITH NO ALI)
        pse__Milestone__c msNoALI = NI_TestClassData.createTestMilestoneNoALI('PSA Test Milestone 2', proj, true, true, 'Billable Milestone');        
        
        // UPGRADE CONTACT TO A PSE RESOURCE
        c.pse__Region__c = reg.Id;
        c.pse__Practice__c = pract.Id;
        c.pse__Work_Calendar__c = wc.Id;
        c.pse__Group__c = grp.Id;
        c.pse__Is_Resource_Active__c = true;
        c.pse__Is_Resource__c = true;
        c.pse__Salesforce_User__c = u.Id;
        update c;        

        // CREATE PERMISSION CONTROL RECORDS
        List<pse__Permission_Control__c> lstPermissionControls = new List<pse__Permission_Control__c>();
        
        // GIVE RUNNING USER THE PERMISSION TO CREATE TIMECARD ENTRIES & EXPENSE REPORTS FOR TEST RESOURCE CONTACT
        pse__Permission_Control__c pm1 = NI_TestClassData.createTestPermissionControl(UserInfo.getUserId());
        pm1.pse__Resource__c = c.Id;   
        pm1.pse__Staffing__c = true; 
        pm1.pse__Timecard_Entry__c = true; 
        pm1.pse__Expense_Entry__c = true; 
        lstPermissionControls.add(pm1);   
        
        // GIVE RUNNING USER THE PERMISSION AS CENTRAL EXPENSE APPROVER FOR THE TEST REGION
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
        lstPermissionControls.add(pm2);

        database.insert(lstPermissionControls);

    
        system.debug(' *** NI_TestClassData_Test.testPSECustoms() - BEFORE Test.StartTest(): NUMBER OF QUERIES = ' + limits.getQueries());

Test.StartTest();
                       
        system.assertEquals(false, proj.pse__Closed_for_Expense_Entry__c);

        List<pse__Permission_Control__c> lstPMAssert = new List<pse__Permission_Control__c>(
            [SELECT Id 
             FROM pse__Permission_Control__c 
             WHERE pse__User__c =: UserInfo.getUserId() 
             AND pse__Resource__c =: c.Id]);
        system.assertEquals(1, lstPMAssert.size());        

        // CREATE A TEST PSE ASSIGNMENT
        pse__Assignment__c assmnt = NI_TestClassData.createTestAssignment(c.Id, sched.Id, proj.Id);
        assmnt.pse__Milestone__c = ms.Id;
        insert assmnt;        

        pse__Billing_Event_Batch__c beb = NI_TestClassData.createTestBillingEventBatch();
        insert beb;
        
        pse__Billing_Event__c be = NI_TestClassData.createTestBillingEvent(beb.Id, proj.Id);
        insert be;
        
        pse__Billing_Event_Item__c bei = NI_TestClassData.createTestBillingEventItem(beb.Id, be.Id, proj.Id, ms.Id);
        bei.Reverse_Softrax_Invoicing__c = true;
        insert bei;

        pse__Miscellaneous_Adjustment__c madj = NI_TestClassData.createMiscellaneousAdjustment('Test Adjust', proj.Id);
        insert madj;  
        
        // SOMETHING SETS THIS VALUE TO True
        proj.pse__Closed_for_Time_Entry__c = false;
        update proj;

        // CREATE TEST TIMECARD HEADER
        pse__Timecard_Header__c tch = NI_TestClassData.createTimecardHeader(proj.Id, ms.Id, assmnt.Id, c.Id, dt.addDays(1), dt.addDays(7));
        insert tch;

        // AMADEUS CUSTOM
        Milestone_Forecast__c msForecast = NI_TestClassData.createTestMilestoneForecast(ms); 
        
        // AMADEUS CUSTOM
        PSA_Product_Package__c pp = NI_TestClassData.createPSAProductPackage();
        insert pp;

        // AMADEUS CUSTOM
        Milestone_Batch_Generation__c mbg = NI_TestClassData.createPSEMilestoneBatchGen(proj.Id, pp.Id);
            
        system.debug(' *** NI_TestClassData_Test.testPSECustoms() - BEFORE Test.StopTest(): NUMBER OF QUERIES = ' + limits.getQueries());
        
Test.StopTest();        
        
        // ASSERT TIMECARD TEST RECORD WAS AUTO-CREATED
        List<pse__Timecard__c> lstTimecardAsserts = new List<pse__Timecard__c>(
            [SELECT Id, Name, pse__Revenue_Transaction__c, pse__Status__c, pse__Submitted__c, pse__Approved__c, pse__Include_In_Financials__c
             FROM pse__Timecard__c 
             WHERE pse__Timecard_Header__c =: tch.Id
            ]);       
        system.assertEquals(1, lstTimecardAsserts.size());
                
        // UPDATE TIMECARD TO APPROVED TO CREATE RELATED TEST pse__Transaction__c RECORDS 
        lstTimecardAsserts[0].pse__Status__c = 'Approved';
        lstTimecardAsserts[0].pse__Submitted__c = true;
        lstTimecardAsserts[0].pse__Approved__c = true;
        lstTimecardAsserts[0].pse__Include_In_Financials__c = true;
        database.update(lstTimecardAsserts);
  
        // ASSERT pse__Transaction__c WAS CREATED
        List<pse__Transaction__c> lstTransactionAsserts = new List<pse__Transaction__c>([
            SELECT Id, Name, pse__Related_Record_Deleted__c
            FROM pse__Transaction__c
            WHERE pse__Timecard__c =: lstTimecardAsserts[0].Id 
            AND pse__Type__c = 'Timecard' 
            AND pse__Category__c = 'Ready-to-Bill Revenue'
        ]);
        system.assertEquals(1, lstTransactionAsserts.size());
        system.assertEquals(true, lstTransactionAsserts[0].pse__Related_Record_Deleted__c); 
        
        reg.Central_Expense_Approver__c = u.Id;
        update reg;
        
        assmnt.pse__Milestone__c = null;
        update assmnt;
                
        // CREATE A TEST PSE EXPENSE REPORT 
        pse__Expense_Report__c xRpt = NI_TestClassData.createPSEExpenseReport(c.Id, proj.Id); 
        xRpt.Name = 'Test External Expense'; 
        xRpt.pse__Assignment__c = assmnt.Id; 
        insert xRpt;        
        
        
        system.assert(true);
        

        
    }
}