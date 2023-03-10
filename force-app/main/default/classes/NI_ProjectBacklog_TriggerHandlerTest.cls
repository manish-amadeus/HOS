/****************************************************************************************
Name            : NI_ProjectBacklog_TriggerHandlerTest Class
Author          : Prashant Wayal
Created Date    : 12/9/2015
Last Mod Date   : 5/9/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016293
Description     : Updated 05/09/2021 per NICC-048128
                : This is test class for NI_ProjectBacklog_TriggerHandler class
                : 
                : 
******************************************************************************************/
@isTest
public with sharing class NI_ProjectBacklog_TriggerHandlerTest
{

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
    
    public static testMethod void testDeleteChildProject(){
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
       
        delete childProject;
        
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
    
    public static testMethod void testAutoCreateNIProjectTasks()  
    {
        Auto_Create_NI_Project_Tasks_Settings__c autoTask = new Auto_Create_NI_Project_Tasks_Settings__c();
        autoTask.Assigned_To__c = 'test User'; 
 		autoTask.Assigned_To_User_ID__c = '00530000000xjfh';
        autoTask.Active__c = true;
        autoTask.name = 'Development Phase';        
        autoTask.Phase__c = 'Development'; 
 		autoTask.Project_Record_Type__c = 'IT Project'; 
 		autoTask.Task_Record_Type__c = 'IT Project Task'; 
 		autoTask.Team__c = 'Business Systems';
        insert autoTask;
        
        NI_Project_Backlog__c projAutocreateTask = new NI_Project_Backlog__c();
        projAutocreateTask.Name = 'Test Project';
        projAutocreateTask.Project_Type__c = 'Business Systems';
        projAutocreateTask.Project_Level_LOE__c = 20;
        insert projAutocreateTask;
    }
    
    //Clone task test 
    public static testMethod void testProjectBacklogCloneMethod()  
    {
        NI_TestClassData.createTestWinaproachServiceNowSettings();
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
         User testUser = new User(Alias = 'newUser', Email='newuser@testorg.com', 
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
         LocaleSidKey='en_US', ProfileId = p.Id, 
         TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        
        // Create Project backlog records
        NI_Project_Backlog__c projBacklog = new NI_Project_Backlog__c();
        projBacklog.Name = 'Clone Project';
        insert projBacklog;
        
        Attachment attachProject=new Attachment();     
        attachProject.Name='Unit Test project Attachment';
        Blob bodyProjectBlob=Blob.valueOf('Unit Test project Attachment Body');
        attachProject.body=bodyProjectBlob;
        attachProject.parentId=projBacklog.id;
        insert attachProject;
        
        Note attachProjectNote=new Note();     
        attachProjectNote.Title='Unit Test project Note';
       
        attachProjectNote.body='Unit Test project Note Body';
        attachProjectNote.parentId=projBacklog.id;
        insert attachProjectNote;

        //create Project backlog task records
        NI_Project_Backlog_Tasks__c taskItems = new NI_Project_Backlog_Tasks__c();  

        taskItems.Task_Estimate_hrs__c = 0.00;
        taskItems.NI_Project_Backlog_Item__c = projBacklog.id;
        taskItems.Assigned_To__c = testUser.Id;
        taskItems.Due_Date__c = date.today();
        
        insert taskItems;
        
        Attachment attachTask=new Attachment();     
        attachTask.Name='Unit Test taskAttachment';
        Blob bodyTaskBlob=Blob.valueOf('Unit Test TaskAttachment Body');
        attachTask.body=bodyTaskBlob;
        attachTask.parentId=taskItems.id;
        insert attachTask;
        
        Note attachTaskNote=new Note();     
        attachTaskNote.Title='Unit Test project Note';
       
        attachTaskNote.body='Unit Test project Note Body';
        attachTaskNote.parentId=taskItems.id;
        insert attachTaskNote;

        NI_Project_Backlog__c projBacklogClone = new NI_Project_Backlog__c();
        projBacklogClone.Name = 'Clone Project Test';
        projBacklogClone.Custom_Record_Id__c = String.valueOf(projBacklog.id);
        insert projBacklogClone;
    }
    
    
    
    //Method to cover the trigger context methods  
    public static testMethod void testTriggerContextMethod()  
    {   
        NI_ProjectBacklog_TriggerHandler handler = new NI_ProjectBacklog_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext; 
        List<NI_Project_Backlog__c> lst = new List<NI_Project_Backlog__c>();
        Map<Id, NI_Project_Backlog__c> mp = new Map<Id, NI_Project_Backlog__c>();
        handler.OnBeforeInsert(lst);
        handler.OnBeforeUpdate(lst,mp);
        handler.OnBeforeDelete(lst);        
        handler.OnAfterUpdate(lst, mp);        
        handler.OnAfterDelete(lst);
        handler.OnAfterUnDelete(lst);
        handler.OnAfterInsert(lst);
    }  
    
    
      public static testMethod void testUpdateProjectUnplanned(){
        createTestData();
        Test.startTest();
          NI_Project_Backlog__c upProject = project;
        //NI_Project_Backlog_Tasks__c upTask = task;
        //upTask.Hours__c = 4;
        upProject.Unplanned__c = true;
        upProject.Request_Status__c = 'In Progress';
          upProject.Project_Type__c = 'Business Systems';
        update upProject;
        Test.stopTest();
        
        NI_Project_Backlog__c proj = [select Id, Estimated_Hours__c, Total_Actual_Hours__c, Remaining_Hours__c from NI_Project_Backlog__c where Id =: project.Id];
        system.debug('proj'+proj);
        //System.assertEquals(20, proj.Estimated_Hours__c);
        //System.assertEquals(4, proj.Total_Actual_Hours__c);
        //System.assertEquals(16, proj.Remaining_Hours__c);
        
    }
    
     // =======================================================================================================================================
    // = TEST METHOD 10: UNIT TESTING FOR BEFORE INSERT METHOD TO SET THE MARGIN % FOR INTERNAL PROJECTS
    // =======================================================================================================================================
    @isTest static void testMarginPercentageOnInsert() 
    {
     	 //GET SOLUTION DOMAIN NAME PICKLIST VALUES FROM SOLUTION DOMAIN ATTRIBUTES OBJECT
         String strSolutionDomain1 = SObjectType.AH_Solution_Domain_Attributes__c.Fields.Solution_Domain__c.PicklistValues[0].getValue();
        
        //GET THE ID OF THE INTERNAL PROJECT RECORD TYPE
        Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Internal Project').getRecordTypeId();
        
        // CREATE TEST SOLUTION DOMAIN ATTRIBUTES RECORD.  SET THE NAME TO THE VALUE FROM THE SOLUTION DOMAIN PICKLIST FIELD    
        AH_Solution_Domain_Attributes__c sda1 = NI_TestClassData.createSolutionDomainAttributes();
        sda1.Name = strSolutionDomain1;
        sda1.Margin__c = 0.1;
        sda1.Active__c = true;
        sda1.Solution_Domain__c = strSolutionDomain1; 
        insert sda1;
        
        // CREATE TEST PROJECT BACKLOG RECORDS     
        Integer i = 1;
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(i);
        pb1.RecordTypeId = rt1;
        pb1.Solution_Domain__c = strSolutionDomain1;
        insert pb1;
        
        
        //GET THE TEST SOLUTION DOMAIN ATTRIBUTE RECORD
        AH_Solution_Domain_Attributes__c insertedSda = [SELECT Id, Name, Solution_Domain__c, Margin__c 
                                                        FROM AH_Solution_Domain_Attributes__c Limit 1];
     
      Test.startTest();  
        
        
        //ASSERT THAT THE PROJECT BACKLOG MARGIN EQUALS THE SOLUTION DOMAIN ATTRIBUTE MARGIN
        NI_Project_Backlog__c insertedPb = [SELECT Id, Solution_Domain__c, Margin__c FROM NI_Project_Backlog__c
                                                  WHERE Solution_Domain__c =: insertedSda.Solution_Domain__c LIMIT 1];
        system.assertEquals(insertedPb.Margin__c,insertedSda.Margin__c);
        
        Test.stopTest();
    }
    
    
     // =======================================================================================================================================
    // = TEST METHOD 11: UNIT TESTING FOR BEFORE UPDATE METHOD TO SET THE MARGIN % FOR INTERNAL PROJECTS
    // =======================================================================================================================================
    @isTest static void testMarginPercentageOnUpdate() 
    {
     	 //GET SOLUTION DOMAIN NAME PICKLIST VALUES FROM SOLUTION DOMAIN ATTRIBUTES OBJECT
         String strSolutionDomain1 = SObjectType.AH_Solution_Domain_Attributes__c.Fields.Solution_Domain__c.PicklistValues[0].getValue();
         String strSolutionDomain2 = SObjectType.AH_Solution_Domain_Attributes__c.Fields.Solution_Domain__c.PicklistValues[1].getValue();
        
        //GET THE ID OF THE INTERNAL PROJECT RECORD TYPE
        Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Internal Project').getRecordTypeId();
        
        // CREATE TEST SOLUTION DOMAIN ATTRIBUTES RECORDS.  SET THE NAME TO THE VALUE FROM THE SOLUTION DOMAIN PICKLIST FIELD    
        AH_Solution_Domain_Attributes__c sda1 = NI_TestClassData.createSolutionDomainAttributes();
        sda1.Name = strSolutionDomain1;
        sda1.Margin__c = 0.1;
        sda1.Active__c = true;
        sda1.Solution_Domain__c = strSolutionDomain1; 
        insert sda1;
        
        AH_Solution_Domain_Attributes__c sda2 = NI_TestClassData.createSolutionDomainAttributes();
        sda2.Name = strSolutionDomain2;
        sda2.Margin__c = 0.75;
        sda2.Active__c = true;
        sda2.Solution_Domain__c = strSolutionDomain2; 
        insert sda2;
        
        // CREATE TEST PROJECT BACKLOG RECORD    
        Integer i = 1;
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(i);
        pb1.RecordTypeId = rt1;
        pb1.Solution_Domain__c = strSolutionDomain1;
        insert pb1;
         
        //GET THE TEST SOLUTION DOMAIN ATTRIBUTE RECORD
        AH_Solution_Domain_Attributes__c insertedSda = [SELECT Id, Name, Solution_Domain__c, Margin__c 
                                                        FROM AH_Solution_Domain_Attributes__c 
                                                        WHERE Name =: strSolutionDomain2 Limit 1];
     
      Test.startTest(); 
        
        //CHANGE THE SOLUTION DOMAIN ON THE PROJECT BACKLOG RECORD
        pb1.Solution_Domain__c = strSolutionDomain2;
        update pb1;
           
        //ASSERT THAT THE PROJECT BACKLOG MARGIN EQUALS THE SOLUTION DOMAIN ATTRIBUTE MARGIN
        NI_Project_Backlog__c updatedPb = [SELECT Id, Solution_Domain__c, Margin__c FROM NI_Project_Backlog__c
                                                  WHERE Solution_Domain__c =: insertedSda.Solution_Domain__c LIMIT 1];
        
        system.assertEquals(updatedPb.Margin__c,insertedSda.Margin__c);
        
        Test.stopTest();
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 12: UNIT TESTING FOR BEFORE INSERT METHOD TO SET THE MARGIN % FOR INTERNAL PROJECTS 
    //   WHEN THE Bypass AH_Project_Backlog Margin Calc CUSTOM SETTING IS SET TO TRUE
    // =======================================================================================================================================
    @isTest static void testMarginPercentageOnInsertByPassTrigger() 
    {
     	
        //CREATE A TEST NI Trigger Bypass Switches CUSTOM SETTING RECORD
        //AND SET THE Bypass AH_Project_Backlog Margin Calc TO TRUE.
        //THIS WILL CAUSE THE Update_Margin METHOD OF THE NI_ProjectBacklog_TriggerHandler TO NOT FIRE.
        NI_TriggerBypassSwitches__c cs = new NI_TriggerBypassSwitches__c();
        cs.Name = 'Apex Test Bypass Switch';
        cs.Bypass_AH_Project_Backlog_Margin_Calc__c = true;
        insert cs;
        
        //GET SOLUTION DOMAIN NAME PICKLIST VALUES FROM SOLUTION DOMAIN ATTRIBUTES OBJECT
         String strSolutionDomain1 = SObjectType.AH_Solution_Domain_Attributes__c.Fields.Solution_Domain__c.PicklistValues[0].getValue();
        
        //GET THE ID OF THE INTERNAL PROJECT RECORD TYPE
        Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Internal Project').getRecordTypeId();
        
        // CREATE TEST SOLUTION DOMAIN ATTRIBUTES RECORD.  SET THE NAME TO THE VALUE FROM THE SOLUTION DOMAIN PICKLIST FIELD    
        AH_Solution_Domain_Attributes__c sda1 = NI_TestClassData.createSolutionDomainAttributes();
        sda1.Name = strSolutionDomain1;
        sda1.Margin__c = 0.1;
        sda1.Active__c = true;
        sda1.Solution_Domain__c = strSolutionDomain1; 
        insert sda1;
        
        // CREATE TEST PROJECT BACKLOG RECORDS     
        Integer i = 1;
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(i);
        pb1.RecordTypeId = rt1;
        pb1.Solution_Domain__c = strSolutionDomain1;
        insert pb1;
        
        
        //GET THE TEST SOLUTION DOMAIN ATTRIBUTE RECORD
        AH_Solution_Domain_Attributes__c insertedSda = [SELECT Id, Name, Solution_Domain__c, Margin__c 
                                                        FROM AH_Solution_Domain_Attributes__c Limit 1];
     
      Test.startTest();  
        
        
        //ASSERT THAT THE PROJECT BACKLOG MARGIN DOES NOT EQUALS THE SOLUTION DOMAIN ATTRIBUTE MARGIN
        NI_Project_Backlog__c insertedPb = [SELECT Id, Solution_Domain__c, Margin__c FROM NI_Project_Backlog__c
                                                  WHERE Id =: pb1.Id LIMIT 1];
        system.assertNotEquals(insertedSda.Margin__c, insertedPb.Margin__c);
        
        
        Test.stopTest();
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 13: UNIT TESTING FOR BEFORE UPDATE METHOD TO SET THE MARGIN % FOR INTERNAL PROJECTS 
    //   WHEN THE Bypass AH_Project_Backlog Margin Calc CUSTOM SETTING IS SET TO TRUE
    // =======================================================================================================================================
    @isTest static void testMarginPercentageOnUpdateByPassTrigger() 
    {
     	
        //CREATE A TEST NI Trigger Bypass Switches CUSTOM SETTING RECORD
        //AND SET THE Bypass AH_Project_Backlog Margin Calc TO TRUE.
        //THIS WILL CAUSE THE Update_Margin METHOD OF THE NI_ProjectBacklog_TriggerHandler TO NOT FIRE.
        NI_TriggerBypassSwitches__c cs = new NI_TriggerBypassSwitches__c();
        cs.Name = 'Apex Test Bypass Switch';
        cs.Bypass_AH_Project_Backlog_Margin_Calc__c = true;
        insert cs;
        
         //GET SOLUTION DOMAIN NAME PICKLIST VALUES FROM SOLUTION DOMAIN ATTRIBUTES OBJECT
         String strSolutionDomain1 = SObjectType.AH_Solution_Domain_Attributes__c.Fields.Solution_Domain__c.PicklistValues[0].getValue();
         String strSolutionDomain2 = SObjectType.AH_Solution_Domain_Attributes__c.Fields.Solution_Domain__c.PicklistValues[1].getValue();
        
        //GET THE ID OF THE INTERNAL PROJECT RECORD TYPE
        Id rt1 = Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get('Internal Project').getRecordTypeId();
        
        // CREATE TEST SOLUTION DOMAIN ATTRIBUTES RECORDS.  SET THE NAME TO THE VALUE FROM THE SOLUTION DOMAIN PICKLIST FIELD    
        AH_Solution_Domain_Attributes__c sda1 = NI_TestClassData.createSolutionDomainAttributes();
        sda1.Name = strSolutionDomain1;
        sda1.Margin__c = 0.1;
        sda1.Active__c = true;
        sda1.Solution_Domain__c = strSolutionDomain1; 
        insert sda1;
        
        AH_Solution_Domain_Attributes__c sda2 = NI_TestClassData.createSolutionDomainAttributes();
        sda2.Name = strSolutionDomain2;
        sda2.Margin__c = 0.75;
        sda2.Active__c = true;
        sda2.Solution_Domain__c = strSolutionDomain2; 
        insert sda2;
        
        // CREATE TEST PROJECT BACKLOG RECORD    
        Integer i = 1;
        NI_Project_Backlog__c pb1 = NI_TestClassData.createTestProjectBacklog(i);
        pb1.RecordTypeId = rt1;
        pb1.Solution_Domain__c = strSolutionDomain1;
        insert pb1;
         
        //GET THE TEST SOLUTION DOMAIN ATTRIBUTE RECORD
        AH_Solution_Domain_Attributes__c insertedSda = [SELECT Id, Name, Solution_Domain__c, Margin__c 
                                                        FROM AH_Solution_Domain_Attributes__c 
                                                        WHERE Name =: strSolutionDomain2 Limit 1];
        
     
      Test.startTest();  
        
        
       //CHANGE THE SOLUTION DOMAIN ON THE PROJECT BACKLOG RECORD
        pb1.Solution_Domain__c = strSolutionDomain2;
        update pb1;
           
        //ASSERT THAT THE PROJECT BACKLOG MARGIN EQUALS THE SOLUTION DOMAIN ATTRIBUTE MARGIN
        NI_Project_Backlog__c updatedPb = [SELECT Id, Solution_Domain__c, Margin__c FROM NI_Project_Backlog__c
                                                  WHERE Solution_Domain__c =: insertedSda.Solution_Domain__c LIMIT 1];
        
        system.assertNotEquals(insertedSda.Margin__c,updatedPb.Margin__c);
        
        Test.stopTest();
    }
  
}