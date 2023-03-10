/****************************************************************************************
Name            : AH_MilestoneSummation_Cntrl_Test
Author          : Ria Chawla
Created Date    : 06/26/2018
Modified Date	: 07/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_MilestoneSummation_Cntrl
				: 
******************************************************************************************/
@isTest
public class AH_MilestoneSummation_Cntrl_Test 
{

    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // =======================================================================================================================================    
    @testSetup static void createTestData()  
    {
        
        // CREATE A TEST MILESTONE CUSTOM SETTING  
        AH_Milestone_Settings__c msCS = new AH_Milestone_Settings__c();
        msCS.Milestone_Amount__c = 0;
        msCS.Milestone_Name__c = 'eproposal activation';
        msCS.Milestone_Type__c = 'Billable Milestone';
        msCS.Project_Name__c = 'xyz';
        msCS.Project_Type__c = 'Customer Project';
        msCS.Target_Period__c = '2018';
        insert msCS; 
        
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
        
        // CREATE A TEST ACCOUNT  
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'AH_MilestoneSummation_Cntrl_Test Account';
        insert a1;
        
        // CREATE A TEST OPPORTUNITY
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a1.Id);
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HRM New Org Opportunity').getRecordTypeId();
        opp1.Name = 'AH_MilestoneSummation_Cntrl_Test Opportunity';
        insert opp1;
        
		// CREATE TEST (LEGACY) SOFTRAX LINE TO SATISFY VALIDATION RULE
        Softrax_Order_Line__c soft = NI_TestClassData.createStxOrderLines(1, opp1.Id);
        insert soft; 
        
        // CREATE A MILESTONE FOR THE PROJECT
        //pse__Milestone__c milestone = new pse__Milestone__c(Name='Assignment-Milestone Target Date Test', Target_Period__c = '2025');
        //milestone.pse__Project__c = proj.Id;
        //milestone.Milestone_Type__c = 'Billable Milestone';
        pse__Milestone__c ms = NI_TestClassData.createTestMilestoneNoALI('Assignment-Milestone Target Date Test', proj, false, false, 'Billable Milestone');
        ms.pse__Target_Date__c = date.newInstance(2025, 11, 28);
        ms.Target_Period__c = '2025';
        ms.pse__Milestone_Amount__c = 100;
        ms.Softrax_Order_Line_PSA__c = soft.Id;
        ms.Opportunity__c = opp1.Id;
        insert ms;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: CALL METHODS OF CONTROLLER TO SCHEDULE JOB AND THEN TO ABORT
    // =======================================================================================================================================      
    @isTest static void test1()
    {
        
        List<pse__Milestone__c> aggrList = new List<pse__Milestone__c>([SELECT Target_Period__c FROM pse__Milestone__c]);
        List<pse__Milestone__c> aggrListUpdate = new List<pse__Milestone__c>();
        
        for (pse__Milestone__c ml : aggrList)
        {
            ml.Target_Period__c = '2018';
            aggrListUpdate.add(ml);
        }
        
        update aggrListUpdate;
        
        Test.startTest();
        
        AH_MilestoneSummation_Cntrl controller = new AH_MilestoneSummation_Cntrl();
        controller.callSchedulableClass();
        controller.abortScheduledJob();
        
        Test.stopTest();
        
        CronTrigger cronJob = new CronTrigger();
        
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            system.debug(cronJob);
        }
        catch (Exception e)
        {
            //ASSERT EXCEPTION, JOB HAS BEEN ABORTED
            system.AssertEquals(e.getTypeName(), 'System.QueryException');
        }
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: SCHEDULE JOB
    // =======================================================================================================================================      
    @isTest static void test2()
    {
        
        CronTrigger cronJob = new CronTrigger();
        
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            system.debug(cronJob);
        }
        catch (Exception e)
        {
            // DO NOTHING
        }
        
        if (cronJob.Id != null)
        {
            system.abortJob(cronJob.Id);
        }
        
        Test.startTest();
        
        AH_MilestoneSummation_Cntrl controller = new AH_MilestoneSummation_Cntrl();
        controller.callSchedulableClass();
        
        Test.stopTest();
        
        CronTrigger cronJob2 = new CronTrigger();
        
        try
        {
            cronJob2 = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            system.Assert((cronJob2 != null), 'Job has been scheduled.');
        }
        catch (Exception e)
        {
            //DO NOTHING
        }
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: ABORT JOB EXCEPTION
    // =======================================================================================================================================      
    @isTest static void test3()
    {
        
        CronTrigger cronJob = new CronTrigger();
        
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            system.debug(cronJob);
        }
        catch (Exception e)
        {
            //DO NOTHING
        }
        
        if (cronJob.Id != null)
        {
            system.abortJob(cronJob.Id);
        }
        
        Test.startTest();
        
        PageReference pageRef = Page.AH_MilestoneSummation;
        
        // SET THE CURRENT PAGE
        Test.setCurrentPage(pageRef);
        
        AH_MilestoneSummation_Cntrl controller = new AH_MilestoneSummation_Cntrl();
        
        controller.abortScheduledJob(); 
        
        // GET THE LIST OF ApexPages.Message
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        Boolean messageFound = false;
        
        // LOOP OVER THE MESSAGES
        for (ApexPages.Message message : pageMessages) 
        {
            if (message.getDetail().contains('No jobs found.') && message.getSeverity() == ApexPages.Severity.ERROR) 
            {
                messageFound = true;        
            }
        }
        
        system.assert(messageFound);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 4: ERROR WHILE INSERTING MILESTONE SETTINGS
    // =======================================================================================================================================      
    @isTest static void test4()
    {
        
        Test.startTest();
        
        PageReference pageRef = Page.AH_MilestoneSummation;
        
        // SET THE CURRENT PAGE
        Test.setCurrentPage(pageRef);
        
        AH_MilestoneSummation_Cntrl controller = new AH_MilestoneSummation_Cntrl();
        controller.milestoneSettings.Project_Name__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        controller.callSchedulableClass();
        
        //GET THE LIST OF ApexPages.Message
        List<ApexPages.Message> pageMessages = ApexPages.getMessages();
        
        Boolean messageFound = false;
        
        for (ApexPages.Message message : pageMessages) 
        {
            if (message.getDetail().contains('Error encountered') && message.getSeverity() == ApexPages.Severity.ERROR)
            {
                messageFound = true;        
            }
        }
        
        system.assert(messageFound);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 5: EXCEPTION IN CONSTRUCTOR, NO JOB HAS BEEN SCHEDULED
    // =======================================================================================================================================      
    @isTest static void test5()
    {
        
        CronTrigger cronJob = new CronTrigger();
        
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Scrum Snapshot'];
            system.debug(cronJob);
        }
        catch (Exception e)
        {
            //DO NOTHING
        }
        
        if (cronJob.Id != null)
        {
            system.abortJob(cronJob.Id);
        }
        
        Test.startTest();
        
        AH_MilestoneSummation_Cntrl controller = new AH_MilestoneSummation_Cntrl();
        
        Test.stopTest();
        
    }
       
}