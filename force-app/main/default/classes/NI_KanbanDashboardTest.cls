/****************************************************************************************
Name            : NI_KanbanDashboardTest Class
Author          : Cybage
Created Date    : 03/17/2017
Last Mod Date   : 07/02/2019
Last Mod By     : Bhuleshwar Deshpande 
NICC Reference  : NICC-010386
Description     : Test Class for the AH_CreateServiceOrder Class      
                : 
                : 
******************************************************************************************/
@isTest
public class NI_KanbanDashboardTest
{
    
    @testSetup static void createKanBanTestData()
    {
        //Creating Record Type Info and Inserted
        RecordTypesInfo__c recordType1 = new RecordTypesInfo__c();
        recordType1.Name = 'IT Project' ;
        recordType1.Record_Type_Name__c = 'IT Project' ;
        insert recordType1;
        
        //Dashboard Project Backlog Status -> Custom Settings inserted 
        List<Dashboard_ProjectBacklogStatus__c> projectBacklogStatusList = new List<Dashboard_ProjectBacklogStatus__c>();
        Dashboard_ProjectBacklogStatus__c projBacklogStat1 = new Dashboard_ProjectBacklogStatus__c();
        projBacklogStat1.Name = 'IT Project';
        projBacklogStat1.Status__c = 'New,Backlog Item,In Progress,Blocked,Redirected,Completed,Rejected';
        
        projectBacklogStatusList.add(projBacklogStat1);
        insert projectBacklogStatusList;
        
        
        List<Dashboard_Task_Status__c> taskStatusList = new List<Dashboard_Task_Status__c>();
        
        //Creating Dashboard Task Status Custom Setting -> Business System 
        Dashboard_Task_Status__c taskStatus1 = new Dashboard_Task_Status__c();
        taskStatus1.Name = 'Business System';
        taskStatus1.Record_Type__c = 'IT Project';
        taskStatus1.Team__c = 'Business Systems';
        taskStatus1.Project_Phases__c = 'Discovery,Design,Development,Validation,Deployment,Support';
        
        taskStatusList.add(taskStatus1);
        
        //Creating Dashboard Task Status Custom Setting -> Security 
        Dashboard_Task_Status__c taskStatus2 = new Dashboard_Task_Status__c();
        taskStatus2.Name = 'Security';
        taskStatus2.Record_Type__c = 'IT Project';
        taskStatus2.Team__c = 'Security';
        taskStatus2.Project_Phases__c ='Discovery,Design,Development,Validation,Deployment,Support';
        
        taskStatusList.add(taskStatus2);
        
        //Inserting Dashboard Task Status List
        insert taskStatusList;
        
        system.debug('taskStatusList  : ' +taskStatusList.size());
        
        //Setting and inserting Dashboard Limits Custom Setting
        Dashboard_Limits__c limits=new Dashboard_Limits__c();
        limits.Name='IT Project - Business System';
        limits.Record_Type__c='IT Project';
        limits.Team__c='Business Systems';
        limits.Number_Of_Active_Projects__c=100;
        limits.Number_of_Unplanned_Backlogs__c=5;
        limits.In_Progress__c=5;
        limits.New__c=5;
        limits.Backlog_Item__c=5;
        limits.Blocked__c=5;
        limits.Redirected__c=5;
        limits.Completed__c=5;
        limits.Rejected__c=5;
        insert limits;
        
        //Sprint with Name -> FIRST SPRINT is Created and Inserted 
        NI_Sprint__c sprint1 = new NI_Sprint__c( Name__c = 'FIRST SPRINT', Sprint_Start_Date__c = Date.Today().addDays(2),
                                                Sprint_Completion_Date__c = Date.Today().addDays(14),
                                                Team__c = 'Business Systems'
                                               );
        insert sprint1;
        
        system.debug('sprint1  :' + sprint1);
        
        //Creating Project GG-001   
        Ni_Project_Backlog__c proj1 =  new NI_Project_Backlog__c
            (   
                Name = 'GG-001',
                RecordTypeId =  NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),
                Request_Status__c = 'In Progress',
                Project_Level_LOE__c  = 10,
                Project_Type__c = 'Business Systems',
                Unplanned__c=false,
                Urgency__c= 'Normal',
                Stakeholder__c='Department',
                Requirements_Definition__c='Concept Only',
                Invoke_Rollups__c=true,
                Child_Project_Estimated_LOE_hrs__c=5,
                Child_Project_Actual_LOE_hrs__c=5,
                Child_Project_Remaining_LOE_hrs__c=5,
                Child_Project_Task_Hours_Design__c=5,
                Child_Project_Task_Hours_Development__c=5,
                Child_Project_Task_Hours_Support__c=5,
                Child_Project_Task_Hours_Validation__c=5
            );   
        //Inserted Project-> GG-001 
        insert proj1; 
        
        //Creating Project GG-002   
        Ni_Project_Backlog__c proj2 =  new NI_Project_Backlog__c
            (   
                Name = 'GG-002',
                RecordTypeId =  NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),
                Request_Status__c = 'In Progress',
                Project_Level_LOE__c  = 10,
                Project_Type__c = 'Business Systems',
                Unplanned__c=false,
                Urgency__c= 'Normal',
                Stakeholder__c='Department',
                Requirements_Definition__c='Concept Only',
                Master_Project__c=proj1.id,
                Invoke_Rollups__c=false,
                Child_Project_Estimated_LOE_hrs__c=5,
                Child_Project_Actual_LOE_hrs__c=5,
                Child_Project_Remaining_LOE_hrs__c=5,
                Child_Project_Task_Hours_Design__c=5,
                Child_Project_Task_Hours_Development__c=5,
                Child_Project_Task_Hours_Support__c=5,
                Child_Project_Task_Hours_Validation__c=5
            );  
        //Inserted Project-> GG-002 
        insert proj2; 
        
        //Creating Project GG-003 ->No Tasks
        Ni_Project_Backlog__c proj3 =  new NI_Project_Backlog__c
            (   
                Name = 'GG-003',
                RecordTypeId =  NI_TestClassData.getRecordTypeId('NI_Project_Backlog__c', 'IT Project'),
                Request_Status__c = 'In Progress',
                Project_Level_LOE__c  = 10,
                Project_Type__c = 'Business Systems',
                Unplanned__c=false,
                Urgency__c= 'Normal',
                Stakeholder__c='Department',
                Requirements_Definition__c='Concept Only',
                Master_Project__c=proj1.id,
                Invoke_Rollups__c=false,
                Child_Project_Estimated_LOE_hrs__c=5,
                Child_Project_Actual_LOE_hrs__c=5,
                Child_Project_Remaining_LOE_hrs__c=5,
                Child_Project_Task_Hours_Design__c=5,
                Child_Project_Task_Hours_Development__c=5,
                Child_Project_Task_Hours_Support__c=5,
                Child_Project_Task_Hours_Validation__c=5
            );   
        //Project GG-003 Inserted 
        insert proj3; 
        
        //Creating Project Backlog Task - T-001 -> GG-001 (Parent Project)
        NI_Project_Backlog_Tasks__c task1 = new NI_Project_Backlog_Tasks__c();
        //task1.Task_ID__c='TID-001';
        task1.Task_ID__c= 'TID-001';
        task1.Name = 'T-001';
        task1.Assigned_To__c = UserInfo.getUserId();
        task1.Details__c = 'This is test task created on '+DateTime.Now();
        task1.Task_Estimate_hrs__c = 24;
        task1.NI_Project_Backlog_Item__c =  proj1.Id;
        task1.Project_Phase__c = 'Development';
        task1.Sprint__c = sprint1.Id;
        task1.Committed__c=true;
        task1.Hours__c=10;
        task1.Hours_Remaining__c=1;
        
        //Task - T-001 Inserted
        insert task1;
        
        system.debug('NI PROJECT TASK LIST 1 :' + task1);
        
        //Creating Project Backlog Task - T-002 -> GG-002 (Parent Project)
        NI_Project_Backlog_Tasks__c task2 = new NI_Project_Backlog_Tasks__c();
        task2.Task_ID__c='TID-002';
        task2.Name = 'T-002';
        task2.Assigned_To__c = UserInfo.getUserId();
        task2.Details__c = 'This is test task created on '+DateTime.Now();
        task2.Task_Estimate_hrs__c = 10;
        task2.NI_Project_Backlog_Item__c =  proj2.Id;
        task2.Project_Phase__c = 'Design';
        task2.Sprint__c = sprint1.Id;
        task2.Committed__c=true;
        task2.Hours__c=10;
        task2.Hours_Remaining__c=1;
        
        //Task - T-002 Inserted 
        insert task2;
        
        system.debug('NI PROJECT TASK LIST 2 :' + task2);
        
        //Inserting Profile -> System Administrator
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Dashboard_Display_Tasks_Profile__c prof = new Dashboard_Display_Tasks_Profile__c();
        prof.Name = 'System Administrator';
        prof.SetupOwnerId=profileId.Id;
        insert prof;
        
        //Created and Inserted User -> test_user  
        User test_user = new User(Alias = 'test', Email='test_user@testorg.com', 
                                  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', ProfileId = profileId.Id, ADUserName__c='helllll',
                                  TimeZoneSidKey='America/Los_Angeles', UserName='test_user@testorg.com');
        insert test_user;  
        
        
        //Created and Inserted Custom Setting -> Dashboard_Access__c 
        Dashboard_Access__c dash_Access1 =new Dashboard_Access__c();
        dash_Access1.Name='IT Project';
        dash_Access1.Record_Type__c='IT Project';
        dash_Access1.Profile__c='System Administrator';
        dash_Access1.Queue__c=null;  
        dash_Access1.Public_Group__c=null;
        dash_Access1.Permission_Set__c=null;
        
        insert dash_Access1;
    }
    
    
    
    //Test Method For verifyAccess Method 
    static testmethod void test_verifyAccess(){
        String recordType='IT Project';
        NI_KanbanDashboard.verifyAccess(recordType);
        
        
        Dashboard_Access__c dash_Access =[SELECT Public_Group__c,Profile__c,Queue__c,Permission_Set__c
                                          FROM Dashboard_Access__c
                                          WHERE Record_Type__c = :recordType Limit 1 ];
        
        //Updating DashBorad Access -> Public_Group__c
        dash_Access.Public_Group__c='Test_Public_Group';
        dash_Access.Profile__c=null;
        dash_Access.Queue__c=null;
        dash_Access.Permission_Set__c=null;
        update dash_Access;
        NI_KanbanDashboard.verifyAccess(recordType);
        
        //Updating DashBorad Access -> Permission_Set__c
        dash_Access.Public_Group__c=null;
        dash_Access.Permission_Set__c='Test_Permission_Set';
        dash_Access.Profile__c=null;
        dash_Access.Queue__c=null;
        update dash_Access;
        NI_KanbanDashboard.verifyAccess(recordType);
        
        //Updating DashBorad Access -> Queue__c
        dash_Access.Queue__c='Test_Queue';  
        dash_Access.Permission_Set__c=null;
        dash_Access.Public_Group__c=null;
        dash_Access.Name='IT Project';
        dash_Access.Record_Type__c='IT Project';
        dash_Access.Profile__c=null;
        update dash_Access;
        NI_KanbanDashboard.verifyAccess(recordType);
    }
    
    //Test Method For getDashboard Method 
    static testmethod void test_getDashboard(){
        String dashboardReturned = NI_KanbanDashboard.getDashboard('IT Project', '["Business Systems"]');
    }
    
    //Test Method For getRecordTypes Method   
    static testmethod void test_getRecordTypes(){
        List<RecordTypesInfo__c> recordTypesList =  NI_KanbanDashboard.getRecordTypes();
    } 
    
    //Test Method For getTeams Method    
    static testmethod void test_getTeams(){
        List<String> teamsList = NI_KanbanDashboard.getTeams();
        //(Business Systems, Finance, Help Desk, Marketing, Network, Security, second, third)
    }    
    
    //Test Method for Change Status to -> Blocked, unplannedFlag2 -> false ,interObject2->false
    static testmethod void test_changeStatus_tasks_1(){
        NI_Project_Backlog_Tasks__c task1=[Select id from NI_Project_Backlog_Tasks__c where Name='T-001'];
        //NI_Project_Backlog_Tasks__c task1=[Select id from NI_Project_Backlog_Tasks__c where Name='T-001)'];
        
        
        system.debug('NI PROJECT TASK LIST  :' + task1);
        Id strID1=task1.Id;
        String newStatus1='Blocked';
        Boolean unplannedFlag1=false; 
        Boolean interObject1=false;
        String reason='Test Reason';
        NI_KanbanDashboard.changeStatus(strID1,newStatus1,unplannedFlag1,interObject1,reason);
    } 
    
    
    //Test Method for Change Status to -> Redirected, unplannedFlag2 -> true ,interObject2->true
    static testmethod void test_changeStatus_tasks_2(){
        // NI_Project_Backlog_Tasks__c task2=[Select id from NI_Project_Backlog_Tasks__c where Name='GG-001 (Development)'];
        NI_Project_Backlog_Tasks__c task2=[Select id from NI_Project_Backlog_Tasks__c where Name='T-002'];
        
        system.debug('NI PROJECT TASK LIST  :' + task2);
        
        Id strID2=task2.Id;
        String newStatus2='Redirected';
        Boolean unplannedFlag2=true;
        Boolean interObject2=true;
        String reason='Test Reason';
        NI_KanbanDashboard.changeStatus(strID2,newStatus2,unplannedFlag2,interObject2,reason);
    }
    
    
    
    static testmethod void test_update(){
        Ni_Project_Backlog__c PB1=[Select id from Ni_Project_Backlog__c where Name='GG-001' LIMIT 1] ;
        PB1.Unplanned__c=true;
        update PB1;
    }
    
}