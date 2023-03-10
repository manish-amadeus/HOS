/****************************************************************************************
Name            : NI_CalculateTimeFrameScheduler_Test
Author          : Sunita Mittal
Created Date    : 11/26/2015
Last Mod Date   : 2/7/2016 
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for the NI_CalculateTimeFrameScheduler Class
: 
: 
******************************************************************************************/

@isTest
private class NI_CalculateTimeFrameScheduler_Test
{
      /**
    * @description Method to create the test NI_Project_Backlog__c record
    * @params projectName
    */
    public static NI_Project_Backlog__c createProjectBacklog(String projectName, String recordType,String status,Integer projLOE,String team){
        Ni_Project_Backlog__c project = new NI_Project_Backlog__c(Name = projectName, RecordTypeId = recordType,Request_Status__c = status,Project_Level_LOE__c  = projLOE,PRoject_Type__c = team);
        insert project;        
        return project;
    }
    
    /**
    * @description Method to create the NI_Project_Backlog_Tasks__c record
    * @params taskTitle
    */
    public static NI_Project_Backlog_Tasks__c createProjectTask(String taskName, Decimal estHrs, String projectPhase, String projectId, String sprintId,Integer hrs){
        NI_Project_Backlog_Tasks__c task = new NI_Project_Backlog_Tasks__c();
        task.Name = taskName;
        task.Assigned_To__c = UserInfo.getUserId();
        task.Details__c = 'This is test task created on '+DateTime.Now();
        task.Task_Estimate_hrs__c = estHrs;
        task.NI_Project_Backlog_Item__c = projectId;
        task.Project_Phase__c = projectPhase;
        task.Sprint__c = sprintId;
        task.Hours__c = hrs;
        try{
            insert task;
        }
        catch(Exception e)
        {
            system.debug('Error:'+e);
        }
        
        
        return task;
    }
       
    public static testMethod void testSchedule() 
    {
        //Insert Sprints
        List<NI_Sprint__c> sprintList = new List<NI_Sprint__c>();
        NI_Sprint__c sprint1 = new NI_Sprint__c( Name__c = 'Test Sprint1', Sprint_Start_Date__c = Date.Today().addDays(-2),
                                                Sprint_Completion_Date__c = Date.Today().addDays(14), Team__c = 'Business Systems',Available_Days__c = 30,Available_Hours__c = 240
                                               );       
        sprintList.add(sprint1);
        NI_Sprint__c sprint2 = new NI_Sprint__c( Name__c = 'Test Sprint2', Sprint_Start_Date__c = Date.Today().addDays(1),
                                                Sprint_Completion_Date__c = Date.Today().addDays(20), Team__c = 'Business Systems',Available_Days__c = 20,Available_Hours__c = 160);
        sprintList.add(sprint2);
        NI_Sprint__c sprint3 = new NI_Sprint__c( Name__c = 'Test Sprint2', Sprint_Start_Date__c = Date.Today().addDays(1),
                                                Sprint_Completion_Date__c = Date.Today().addDays(20), Team__c = 'Business Systems',Available_Days__c = 10,Available_Hours__c = 40);
        sprintList.add(sprint3);
        insert sprintList ;
        
        //Insert Projects
        NI_Project_Backlog__c  project1 = createProjectBacklog('TestProject1', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),'In Progress',30,'Business Systems');
        //project1.Total_Project_Tasks__c  = 1;
        //update project1;
        NI_Project_Backlog__c  project2 = createProjectBacklog('TestProject2', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),'Backlog Item',30,'Business Systems');
        NI_Project_Backlog__c  project3 = createProjectBacklog('TestProject3', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),'Backlog Item',30,'Business Systems');
        NI_Project_Backlog__c  project4 = createProjectBacklog('TestProject3', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),'New',30,'Business Systems');
        project4.Projected_Date__c = String.valueOf(Date.today());
        update project4;
        
        //Insert Tasks
        NI_Project_Backlog_Tasks__c  task1 = createProjectTask('test task1', 20, 'Development', project1.Id, sprintList[0].Id,1);
        NI_Project_Backlog_Tasks__c  task2 = createProjectTask('test task2', 20, 'Development', project2.Id, sprintList[1].Id,1);
        NI_Project_Backlog_Tasks__c  task3 = createProjectTask('test task3', 20, 'Development', project3.Id, sprintList[2].Id,1);
       
        //update task Actual hours to 0
        task3.Hours__c = 0;
        update task3;

        Project_Backlog_Record_Types__c recTypeWithTeam = new Project_Backlog_Record_Types__c();
        recTypeWithTeam.Name = 'IT Project';
        recTypeWithTeam.Teams__c = '--None--,Business Systems,Compliance,Help Desk,Network,Security';
        insert recTypeWithTeam;
        
        ApexPages.StandardController stdCtrl = new ApexPages.standardController(project4);
        NI_CalculateTimeFrameScheduler objCtrl = new NI_CalculateTimeFrameScheduler(stdCtrl);
        
         ApexPages.StandardController stdsetCtrl = new ApexPages.standardController(project4);
        NI_CalculateTimeFrameScheduler objCtrl2 = new NI_CalculateTimeFrameScheduler(stdsetCtrl);
        
        Test.startTest();
        NI_CalculateTimeFrameScheduler sh = new NI_CalculateTimeFrameScheduler(); 
        sh.selectedRecType = 'IT Project';
        sh.getAllRecTypes();
        sh.getTeams();
        String sch = '0 0 5 * * ?'; 
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', sch, sh);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
                    
        // Verify the expressions are the same
        System.assertEquals(sch , ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        system.debug(project1.Projected_Date__c);                  
        Test.stopTest();
        
        NI_Project_Backlog__c proj = [SELECT Projected_Date__c FROM NI_Project_Backlog__c WHERE Id =: project1.Id];
        System.assertEquals(Date.Today().addDays(3).Month()+'/'+ Date.Today().addDays(3).Year(), proj.Projected_Date__c);
    }  
    
    public static testMethod void testSchedule2(){
        //Insert Sprints
        List<NI_Sprint__c> sprintList = new List<NI_Sprint__c>();
        NI_Sprint__c sprint1 = new NI_Sprint__c( Name__c = 'Test Sprint1', Sprint_Start_Date__c = Date.Today().addDays(-2),
                                                Sprint_Completion_Date__c = Date.Today().addDays(14), Team__c = 'Business Systems',Available_Days__c = 30,Available_Hours__c = 240
                                               );       
        sprintList.add(sprint1);
        
        insert sprintList;
        
        NI_Project_Backlog__c  project1 = createProjectBacklog('TestProject1', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),'In Progress',30,'Business Systems');
        
         NI_CalculateTimeFrameScheduler obj = new NI_CalculateTimeFrameScheduler();
        obj.selectedRecType = 'IT Project';
        obj.selectedTeam = 'Business Systems';
        obj.doSubmit();
        obj.doCancel();
        Test.startTest();
        //Test.setCurrentPage(new PageReference('NI_UpdateProjectionsPage'));
        NI_CalculateTimeFrameScheduler.projectedDateCal();
        NI_CalculateTimeFrameScheduler.scheduleThis();
        Test.stopTest();
        //ApexPages.StandardSetController con = new ApexPages.StandardSetController();
         //NI_CalculateTimeFrameScheduler controller = new  NI_CalculateTimeFrameScheduler(new ApexPages.StandardSetController());
    } 
}