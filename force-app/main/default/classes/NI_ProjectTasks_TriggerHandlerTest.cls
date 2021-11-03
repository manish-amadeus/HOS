/****************************************************************************************
Name            : NI_ProjectTasks_TriggerHandlerTest Class
Author          : Prashant Wayal
Created Date    : 12/1/2015
Last Mod Date   : 12/22/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016293
Description     : This is test class for NI_ProjectTasks_TriggerHandler class
: 
: 
******************************************************************************************/

@isTest
public with sharing class NI_ProjectTasks_TriggerHandlerTest{

    /**
    * @description Method to create the test NI_Project_Backlog__c record
    * @params projectName
    */
    public static NI_Project_Backlog__c createProjectBacklog(String projectName, String recordType){
        Ni_Project_Backlog__c project = new NI_Project_Backlog__c(Name = projectName, RecordTypeId = recordType);
        insert project;
        return project;
    }
    
    /**
    * @description Method to create the NI_Project_Backlog_Tasks__c record
    * @params taskTitle
    */
    public static NI_Project_Backlog_Tasks__c createProjectTask(String taskName, Decimal estHrs, String projectPhase, String projectId, String sprintId){
        NI_Project_Backlog_Tasks__c task = new NI_Project_Backlog_Tasks__c();
        task.Name = taskName;
        task.Assigned_To__c = UserInfo.getUserId();
        task.Details__c = 'This is test task created on '+DateTime.Now();
        task.Task_Estimate_hrs__c = estHrs;
        task.NI_Project_Backlog_Item__c = projectId;
        task.Project_Phase__c = projectPhase;
        task.Sprint__c = sprintId;
        
        insert task;
        
        return task;
    }
    
    /**
    * @description Method to create the Sprint record
    * @params sprintName
    */
    public static NI_Sprint__c createSprint(String sprintName){
        NI_Sprint__c sprint = new NI_Sprint__c( Name__c = sprintName, Sprint_Start_Date__c = Date.Today().addDays(2),
                                                Sprint_Completion_Date__c = Date.Today().addDays(14), Team__c = 'Business Systems'
                                               );
        insert sprint;
        return sprint;
    }
    
    public static NI_Sprint__c sprint{ get; set; }
    public static NI_Project_Backlog__c project{ get; set; }
    public static NI_Project_Backlog_Tasks__c task{ get; set; }
    
    /**
    * @description Method to create the test data
    * @params no params
    */
    public static void createTestData(){
        sprint = createSprint('Test Sprint 1');
        project = createProjectBacklog('Test Project', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'));
        task = createProjectTask('test task', 20, 'Development', project.Id, sprint.Id);
    }
    
    public static testMethod void testUpdateMasterProjectTask(){
        createTestData();
        Test.startTest();
        NI_Project_Backlog_Tasks__c upTask = task;
        upTask.Hours__c = 4;
        
        update upTask;
        Test.stopTest();
        
        NI_Project_Backlog__c proj = [select Id, Estimated_Hours__c, Total_Actual_Hours__c, Remaining_Hours__c from NI_Project_Backlog__c where Id =: project.Id];
        
        System.assertEquals(20, proj.Estimated_Hours__c);
        System.assertEquals(4, proj.Total_Actual_Hours__c);
        System.assertEquals(16, proj.Remaining_Hours__c);
        
    }
    
    public static testMethod void testChildProjectTask(){
        createTestData();
        Test.startTest();
        NI_Project_Backlog_Tasks__c upTask = task;
        upTask.Hours__c = 4;
        
        update upTask;
        
        NI_Project_Backlog__c childProject = createProjectBacklog('Child Project', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'));
        childProject.Master_Project__c = project.Id;
        
        update childProject;
        
        NI_Project_Backlog_Tasks__c childProjTask = createProjectTask('Child proj task', 15, 'Design', childProject.Id, sprint.Id);
        childProjTask.Hours__c = 10;
        
        update childProjTask;
        
        Test.stopTest();
        
        NI_Project_Backlog__c proj = [select Id, Estimated_Hours__c, Total_Actual_Hours__c, Remaining_Hours__c from NI_Project_Backlog__c where Id =: project.Id];
        
        System.assertEquals(35, proj.Estimated_Hours__c);
        System.assertEquals(14, proj.Total_Actual_Hours__c);
        System.assertEquals(21, proj.Remaining_Hours__c);
    }
    
    
    public static testMethod void testBulkChildProjectTaskUpdate(){
        System.debug('*** inside testBulkChildProjectTaskUpdate *** ');
        createTestData();
        
        NI_Project_Backlog__c childProject = createProjectBacklog('Child Project', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'));
        childProject.Master_Project__c = project.Id;
        
        update childProject;
        
        List<NI_Project_Backlog_Tasks__c> tasksList = new List<NI_Project_Backlog_Tasks__c>();
        
        NI_Project_Backlog_Tasks__c childProjTask = createProjectTask('Child proj task', 15, 'Design', childProject.Id, sprint.Id);
        childProjTask.Hours__c = 7;
        
        tasksList.add(childProjTask);
        
        NI_Project_Backlog_Tasks__c childProjTask1 = createProjectTask('Child proj task', 25, 'Development', childProject.Id, sprint.Id);
        childProjTask1.Hours__c = 10;
        
        tasksList.add(childProjTask1);
        
        NI_Project_Backlog_Tasks__c childProjTask2 = createProjectTask('Child proj task', 16, 'Support', childProject.Id, sprint.Id);
        childProjTask2.Hours__c = 6;
        
        tasksList.add(childProjTask2);
        
        NI_Project_Backlog_Tasks__c childProjTask3 = createProjectTask('Child proj task', 10, 'Validation', childProject.Id, sprint.Id);
        childProjTask3.Hours__c = 3;
        
        tasksList.add(childProjTask3);
        
        System.debug('*** before bulk update *** ');
        //Update all the tasks
        Test.startTest();
            update tasksList;
        Test.stopTest();
        System.debug('*** after bulk update *** ');
        
        NI_Project_Backlog__c proj = [select Id, Estimated_Hours__c, Total_Actual_Hours__c, Remaining_Hours__c, Design_Hours__c, Development_Hours__c, Support_Hours__c,
                                      Validation_Hours__c from NI_Project_Backlog__c where Id =: project.Id];
        
        System.assertEquals(86, proj.Estimated_Hours__c);
        System.assertEquals(26, proj.Total_Actual_Hours__c);
        System.assertEquals(60, proj.Remaining_Hours__c);
        System.assertEquals(7,  proj.Design_Hours__c);
        System.assertEquals(10, proj.Development_Hours__c);
        System.assertEquals(6,  proj.Support_Hours__c);
        System.assertEquals(3,  proj.Validation_Hours__c);
        
        
    }
    
    public static testMethod void testDeleteTask(){
        createTestData();
        
        Test.startTest();
        NI_Project_Backlog_Tasks__c upTask = task;
        upTask.Hours__c = 5;
        
        update upTask;
        
        NI_Project_Backlog__c childProject = createProjectBacklog('Child Project', NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'));
        childProject.Master_Project__c = project.Id;
        
        update childProject;
        
        NI_Project_Backlog_Tasks__c childProjTask = createProjectTask('Child proj task', 15, 'Design', childProject.Id, sprint.Id);
        childProjTask.Hours__c = 7;
        
        update childProjTask;
       
        delete childProjTask;
        
        Test.stopTest();
        
        NI_Project_Backlog__c proj2 = [select Id, Estimated_Hours__c, Total_Actual_Hours__c, Remaining_Hours__c, Design_Hours__c, Development_Hours__c, Support_Hours__c,
                                      Validation_Hours__c from NI_Project_Backlog__c where Id =: project.Id];
        
        System.assertEquals(20, proj2.Estimated_Hours__c);
        System.assertEquals(5, proj2.Total_Actual_Hours__c);
        System.assertEquals(15, proj2.Remaining_Hours__c);
        System.assertEquals(0,  proj2.Design_Hours__c);
        System.assertEquals(5,  proj2.Development_Hours__c);
        System.assertEquals(0,  proj2.Support_Hours__c);
        System.assertEquals(0,  proj2.Validation_Hours__c);
        
    }
    
    //Method to cover the trigger context methods  
    public static testMethod void testTriggerContextMethod()  
    {   
        NI_ProjectTasks_TriggerHandler handler = new NI_ProjectTasks_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext; 
        List<NI_Project_Backlog_Tasks__c> lst = new List<NI_Project_Backlog_Tasks__c>();
        Map<Id, NI_Project_Backlog_Tasks__c> mp = new Map<Id, NI_Project_Backlog_Tasks__c>();
        handler.OnBeforeInsert(lst);
        handler.OnBeforeUpdate(lst);
        handler.OnBeforeDelete(lst);        
        handler.OnAfterUpdate(lst, mp);        
        handler.OnAfterDelete(lst);
        handler.OnAfterUnDelete(lst);
    }    
}