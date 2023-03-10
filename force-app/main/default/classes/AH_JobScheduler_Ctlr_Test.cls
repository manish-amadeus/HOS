/************************************************************************************************
Name            : AH_JobScheduler_Ctlr_Test Class
Author          : Shashikant Nikam
Created Date    : 02/21/2020
Last Mod By     : Shashikant Nikam
Last Mod Date   : 05/11/2020
NICC Reference  : 
Description     : Test class for AH_JobScheduler_Ctlr class
                : 
                : 
************************************************************************************************/
@isTest
public class AH_JobScheduler_Ctlr_Test 
{
    
    @testSetup 
    static void createTestData()
    {
        Apex_Job_Scheduler_Setting__c jobSettings1 = new Apex_Job_Scheduler_Setting__c();
        jobSettings1.Context_Username__c = 'xyz@test.com';
        jobSettings1.Context_User_Password__c = 'Mypass@123';
        jobSettings1.Context_User_Security_Token__c = 'vokjkLXjiwbm3non2ZBHohSuK';
        //jobSettings1.Running_User_Profile_Name__c = 'System Administrator';
        Profile p = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        jobSettings1.Running_User_Profile_Name__c = p.Name;
        jobSettings1.Endpoint__c = 'https://ap4.salesforce.com/';
        jobSettings1.Schedulable_Classes__c = 'Class1,Class2,Class3';
        jobSettings1.Environment__c = 'Production';
        jobSettings1.User_Name__c = 'User 1';      
        insert jobSettings1;      
    }


    // ==========================================================================================================================================================
    // 			TEST METHODS
    // ==========================================================================================================================================================
    @isTest
    static void testSaveMethod1()
    {
        PageReference pr = Page.AH_JobScheduler;
        Test.setCurrentPage(pr);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
		AH_JobScheduler_Ctlr_Base pageBaseObj = new AH_JobScheduler_Ctlr_Base();
        pageBaseObj.getThis();
        cont.pageController = pageBaseObj;

        pageController.myComponentController = cont;
        
        // LOGIN 
        pageController.login(pageController.settingsObj.Context_Username__c, pageController.settingsObj.Context_User_Password__c, pageController.settingsObj.Context_User_Security_Token__c);
        pageController.jobName = 'Job_1';
        pageController.selectedClass = 'Class1';

        
        AH_CronBuilder_ctlr_Base cronBaseObj = new AH_CronBuilder_ctlr_Base(); 
        pageBaseObj.setComponentController(cronBaseObj);
        pageBaseObj.getMyComponentController();
        
        pageController.getMyComponentController();
        
        pageController.myComponentController.bSunday = true;
        pageController.myComponentController.bMonday = true;
        pageController.myComponentController.bTuesday = true;
        pageController.myComponentController.bWednesday = true;
        pageController.myComponentController.bThursday = true;
        pageController.myComponentController.bFriday = true;
        
        pageController.myComponentController.strSelStartTime = '0 45 3';
            
        pageController.scheduleJob();
            
        Apex_Job_Scheduler_Setting__c updatedSettingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];
        
        system.assertNotEquals(NULL, updatedSettingsObj.Schedulable_Classes_with_ID__c, 'Schedulable_Classes_with_ID__c is still NULL.');
        
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
        String message = String.valueOf(pageMessages[0]).toLowerCase();
        system.assertEquals(true, message.contains('job scheduled succesfully.'), 'Failed to schedule jobs on remote ORG.');
        
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testSaveMethod2()
    {
        PageReference pr = Page.AH_JobScheduler;
        Test.setCurrentPage(pr);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
		AH_JobScheduler_Ctlr_Base pageBaseObj = new AH_JobScheduler_Ctlr_Base();
        cont.pageController = pageBaseObj;

        pageController.myComponentController = cont;
        
        // LOGIN 
        pageController.login(pageController.settingsObj.Context_Username__c, pageController.settingsObj.Context_User_Password__c, pageController.settingsObj.Context_User_Security_Token__c);
        pageController.jobName = 'Job_1';
        pageController.selectedClass = 'Class1';

        AH_CronBuilder_ctlr_Base cronBaseObj = new AH_CronBuilder_ctlr_Base(); 
        pageBaseObj.setComponentController(cronBaseObj);
        pageBaseObj.getMyComponentController();
        
        pageController.getMyComponentController();
        
        // CHANGE TO MONTHLY MODE
        pageController.myComponentController.strSelFrequency = 'Monthly';
        pageController.myComponentController.changeFrequency();
        pageController.myComponentController.strSelStartTime = '0 45 3';

        // CHOOSE DAY
        pageController.myComponentController.strSelDay = '15';
        
        // ENTER DATE RANGE
        pageController.myComponentController.strStartDate = '1/1/2020';
        pageController.myComponentController.strEndDate = '12/31/2030';
        
        // ENTER A PREFERED START TIME
        pageController.myComponentController.strSelStartTime = '0 15 17';   
        
        pageController.scheduleJob();
            
        Apex_Job_Scheduler_Setting__c updatedSettingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];
        
        system.assertNotEquals(NULL, updatedSettingsObj.Schedulable_Classes_with_ID__c, 'Schedulable_Classes_with_ID__c is still NULL.');
        
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
        String message = String.valueOf(pageMessages[0]).toLowerCase();
        system.assertEquals(true, message.contains('job scheduled succesfully.'), 'Failed to schedule jobs on remote ORG.');
        
        
        Test.stopTest();
    }
    
        
    @isTest
    static void testSaveMethod3()
    {
        
        Apex_Job_Scheduler_Setting__c settingsObj = [select id, 
                                                           Name, 
                                                           Environment__c  
                                                           FROM Apex_Job_Scheduler_Setting__c];
                
        settingsObj.Environment__c = 'Sandbox';
        update settingsObj;
        
        PageReference pr = Page.AH_JobScheduler;
        Test.setCurrentPage(pr);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
		AH_JobScheduler_Ctlr_Base pageBaseObj = new AH_JobScheduler_Ctlr_Base();
        cont.pageController = pageBaseObj;

        pageController.myComponentController = cont;
        
        // LOGIN 
        pageController.login(pageController.settingsObj.Context_Username__c, pageController.settingsObj.Context_User_Password__c, pageController.settingsObj.Context_User_Security_Token__c);
        pageController.jobName = 'Job_1';
        pageController.selectedClass = 'Class1';

        AH_CronBuilder_ctlr_Base cronBaseObj = new AH_CronBuilder_ctlr_Base(); 
        pageBaseObj.setComponentController(cronBaseObj);
        pageBaseObj.getMyComponentController();
        
        pageController.getMyComponentController();
        
        // CHANGE TO MONTHLY MODE
        pageController.myComponentController.strSelFrequency = 'Monthly';
        pageController.myComponentController.changeDayMode2();
        pageController.myComponentController.strSelStartTime = '0 45 3';
        
        // CHOOSE DAY
        pageController.myComponentController.strSelNthDay = '6';
        pageController.myComponentController.strSelNthDay = '#3';
        
        // ENTER DATE RANGE
        pageController.myComponentController.strStartDate = '1/1/2020';
        pageController.myComponentController.strEndDate = '12/31/2030';
        
        // ENTER A PREFERED START TIME
        pageController.myComponentController.strSelStartTime = '0 15 17';   
        
        pageController.scheduleJob();
            
        Apex_Job_Scheduler_Setting__c updatedSettingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];

        system.assertNotEquals(NULL, updatedSettingsObj.Schedulable_Classes_with_ID__c, 'Schedulable_Classes_with_ID__c is still NULL.');
        
		ApexPages.Message[] pageMessages = ApexPages.getMessages();
        String message = String.valueOf(pageMessages[0]).toLowerCase();
        system.assertEquals(true, message.contains('job scheduled succesfully.'), 'Failed to schedule jobs on remote ORG.');
        
        pageController.myComponentController.changeDayMode1();
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testRefreshMethod()
    {
        Apex_Job_Scheduler_Setting__c settingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];
                
        settingsObj.Schedulable_Classes_with_ID__c = 'Class1=08e6C00000FvH1zQAF';
        update settingsObj;
        
        
        PageReference pr = Page.AH_JobScheduler;
        Test.setCurrentPage(pr);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
		AH_JobScheduler_Ctlr_Base pageBaseObj = new AH_JobScheduler_Ctlr_Base();
        cont.pageController = pageBaseObj;

        pageController.classNamesSet = new Set<String>(settingsObj.Schedulable_Classes__c.split(','));
        pageController.myComponentController = cont;
        
        pageController.refreshJobsList();
            
        Apex_Job_Scheduler_Setting__c updatedSettingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];

        Test.stopTest();
    }
    
    
    @isTest
    static void testDeleteJobMethod1()
    {
        Apex_Job_Scheduler_Setting__c settingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];
                
        settingsObj.Schedulable_Classes_with_ID__c = 'Class1=08e6C00000FvH1zQAF';
        update settingsObj;
                
        PageReference pr = Page.AH_JobScheduler;
        Test.setCurrentPage(pr);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
        pageController.classNamesSet = new Set<String>(settingsObj.Schedulable_Classes__c.split(','));
        pageController.myComponentController = cont;
        
        AH_JobScheduler_Ctlr.jobData jobData1 = new AH_JobScheduler_Ctlr.jobData();
        jobData1.ClassName = 'Class1' ;
        jobData1.CronJobDetailId= '08a6C00000FvIBBQA3';
        jobData1.JobName='Job_1';
        jobData1.JobType= ' Scheduled Apex';
        jobData1.NextFireTime= '2020-04-10T21:45:00.000Z';
        jobData1.check=true;
        jobData1.jobId= '08e6C00000FvH1zQAF';
        jobData1.runningUserName = 'Shashikant Nikam'; 
        jobData1.status=null;
        
        pageController.schldJobsData.add(jobData1);
        
		pageController.deleteJobs();
            
        Apex_Job_Scheduler_Setting__c updatedSettingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];

        system.assertEquals(NULL, updatedSettingsObj.Schedulable_Classes_with_ID__c, 'Schedulable_Classes_with_ID__c is not NULL.');
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        String message = String.valueOf(pageMessages[0]).toLowerCase();
        system.assertEquals(true, message.contains('jobs deleted succesfully.'), 'Failed to delete jobs.');
        
        Test.stopTest();
    }
 
    
    @isTest
    static void testDeleteJobMethod2()
    {
        Apex_Job_Scheduler_Setting__c settingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];
                
        
        PageReference pg = Page.AH_JobScheduler;
        Test.setCurrentPage(pg);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
        pageController.classNamesSet = new Set<String>(settingsObj.Schedulable_Classes__c.split(','));
        pageController.myComponentController = cont;
		
        AH_JobScheduler_Ctlr.jobData jobData1 = new AH_JobScheduler_Ctlr.jobData();
        pageController.schldJobsData.add(jobData1);
        
		pageController.deleteJobs();
            
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        String message = String.valueOf(pageMessages[0]).toLowerCase();
        system.assertEquals(true, message.contains('select atleast 1 job to delete.'));
        
        Test.stopTest();
    }
    
    
    // METHOD TO CHECK JOB DELETED BY OTHER USER 
    @isTest
    static void testDeleteJobMethod3()
    {
       Apex_Job_Scheduler_Setting__c settingsObj = [select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c];
                
        settingsObj.Schedulable_Classes_with_ID__c = 'Class2=08e6C00000FvH1zQFA';
        update settingsObj;
                
        Apex_Job_Scheduler_Setting__c jobSettings1 = new Apex_Job_Scheduler_Setting__c();
        jobSettings1.Context_Username__c = 'xyz@test.com';
        jobSettings1.Context_User_Password__c = 'Mypass@123';
        jobSettings1.Context_User_Security_Token__c = 'vokjkLXjiwbm3non2ZBHohSuK';
        jobSettings1.Running_User_Profile_Name__c = 'NI Finance';
        jobSettings1.Endpoint__c = 'https://ap4.salesforce.com/';
        jobSettings1.Schedulable_Classes__c = 'Class1,Class2,Class3';
        jobSettings1.Environment__c = 'Production';
        jobSettings1.User_Name__c = 'User 2';
        jobSettings1.Schedulable_Classes_with_ID__c = 'Class1=08e6C00000FvH1zQAF,Class3=08e6C00000FvH1zQAG';
        
        insert jobSettings1;
        
        PageReference pr = Page.AH_JobScheduler;
        Test.setCurrentPage(pr);
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new AH_JobScheduler_Mock());
        Test.startTest();

        AH_JobScheduler_Ctlr pageController= new AH_JobScheduler_Ctlr();
        
        AH_CronBuilder_ctlr cont = new AH_CronBuilder_ctlr();
        
        pageController.classNamesSet = new Set<String>(jobSettings1.Schedulable_Classes__c.split(','));
        pageController.myComponentController = cont;
        
        AH_JobScheduler_Ctlr.jobData jobData1 = new AH_JobScheduler_Ctlr.jobData();
        jobData1.ClassName = 'Class1' ;
        jobData1.CronJobDetailId= '08a6C00000FvIBBQA3';
        jobData1.JobName='Job_1';
        jobData1.JobType= ' Scheduled Apex';
        jobData1.NextFireTime= '2020-04-10T21:45:00.000Z';
        jobData1.check=true;
        jobData1.jobId= '08e6C00000FvH1zQAF';
        jobData1.runningUserName = 'User 2'; 
        jobData1.status=null;
        
        pageController.schldJobsData.add(jobData1);
        
        
        AH_JobScheduler_Ctlr.jobData jobData2 = new AH_JobScheduler_Ctlr.jobData();
        jobData2.ClassName = 'Class2' ;
        jobData2.CronJobDetailId= '08a6C00000FvIBBQA4';
        jobData2.JobName='Job_2';
        jobData2.JobType= ' Scheduled Apex';
        jobData2.NextFireTime= '2020-04-10T21:45:00.000Z';
        jobData2.check=true;
        jobData2.jobId= '08e6C00000FvH1zQFA';
        jobData2.runningUserName = 'User 1'; 
        jobData2.status=null;
        
        pageController.schldJobsData.add(jobData2);
        
        
		pageController.deleteJobs();
            
        List<Apex_Job_Scheduler_Setting__c> updatedSettingsObj = new List<Apex_Job_Scheduler_Setting__c>([select id, 
                                                           Name, 
                                                           Schedulable_Classes__c, 
                                                           Schedulable_Classes_with_ID__c 
                                                           FROM Apex_Job_Scheduler_Setting__c]);

        system.debug('updatedSettingsObj : '+updatedSettingsObj);
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        String message = String.valueOf(pageMessages[0]).toLowerCase();
        system.assertEquals(true, message.contains('jobs deleted succesfully.'), 'Failed to delete jobs.');
        
        Test.stopTest();
    }
    
}