/****************************************************************************************
Name            : NI_PerfEval_Ext_Test Class
Author          : Sean Harris
Created Date    : 12/10/2014
Last Mod Date   : 1/20/2016
Last Mod By     : Stuart Emery
NICC Reference  : Recent Updates Per NICC-015837
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_PerfEval_Ext_Test
{
    
    public static testMethod void testPerfEvalAsEmployee() 
    {
        
        system.assertEquals(1, 1, 'system.assertEquals(1, 1)');
        system.assertNotEquals(0, 1, 'system.assertNotEquals(1, 1)');
        
        // CREATE TEST CUSTOM SETTINGS DATA FOR Performance_Evaluations_Assessments__c ============================================================================================
        List<Performance_Evaluations_Assessments__c> lstCustomSettings = new List<Performance_Evaluations_Assessments__c>();
        
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Innovation 1', Category__c ='Innovation',Description__c ='Maintains and uses cutting edge technical and/or business knowledge',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Innovation 2', Category__c ='Innovation',Description__c ='Is committed to process improvement',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Innovation 3', Category__c ='Innovation',Description__c ='Develops innovative solutions',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Innovation 4', Category__c ='Innovation',Description__c ='Uses knowledge, common sense, and creativity in solving problems and to continually improve process',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 1', Category__c ='Management Skills',Description__c ='Identifies and removes obstacles',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 2', Category__c ='Management Skills',Description__c ='Is committed to the professional development of team members',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 3', Category__c ='Management Skills',Description__c ='Is flexible and easy to work with',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 4', Category__c ='Management Skills',Description__c ='Understands and communicates enthusiasm about Newmarket International\'s vision and goals',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 5', Category__c ='Management Skills',Description__c ='Provides frequent and valuable feedback; lets people know when they have done a good job',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 6', Category__c ='Management Skills',Description__c ='Sets clear roles, responsibilities and expectations, and holds employees accountable',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 7', Category__c ='Management Skills',Description__c ='Appropriately delegates tasks to others and gives people latitude to manage their own responsibilities.',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Management Skills 8', Category__c ='Management Skills',Description__c ='Is emotionally consistent and even-keeled; remains calm in the face of adversity',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 1', Category__c ='Ownership',Description__c ='Assumes responsibility and accountability for successfully completing assignments or tasks',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 2', Category__c ='Ownership',Description__c ='Has the skills and knowledge necessary for the role',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 3', Category__c ='Ownership',Description__c ='Is focused on the overall success of the company',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 4', Category__c ='Ownership',Description__c ='Is punctual, maintains attendance, and attends meetings on time',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 5', Category__c ='Ownership',Description__c ='Maintains effectiveness when experiencing changes in tasks, processes, requirements, or the environment',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 6', Category__c ='Ownership',Description__c ='Sets high standards of performance for self and others',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Ownership 7', Category__c ='Ownership',Description__c ='Gets things done; moves ideas to action and honors commitments',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 1', Category__c ='Relationships',Description__c ='Is able to influence and gain cooperation from others',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 2', Category__c ='Relationships',Description__c ='Is approachable, supports co-workers, and is available when needed',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 3', Category__c ='Relationships',Description__c ='Listens to others and objectively considers others ideas and opinions',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 4', Category__c ='Relationships',Description__c ='Communicates openly and clearly',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 5', Category__c ='Relationships',Description__c ='Effectively uses conflict resolution and negotiation skills',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 6', Category__c ='Relationships',Description__c ='Treats people with dignity, respect, and fairness',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Relationships 7', Category__c ='Relationships',Description__c ='Is open to receive feedback and critique without defensiveness',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Service 1', Category__c ='Service',Description__c ='Produces quality work',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Service 2', Category__c ='Service',Description__c ='Actively seeks information to understand customers’ needs',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Service 3', Category__c ='Service',Description__c ='Builds solid professional relationships with customers',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Service 4', Category__c ='Service',Description__c ='Focuses on customer satisfaction and maintains high standards of service',Active__c=true));
        lstCustomSettings.Add(new Performance_Evaluations_Assessments__c(Name='Service 5', Category__c ='Service',Description__c ='Shares information with customers and colleagues to build understanding of customer issues, and works towards resolution',Active__c=true));
        
        Database.Insert(lstCustomSettings);
        
        // ASSERT THAT CUSTOM SETTINGS DATA FOR Performance_Evaluations_Assessments__c WAS INSERTED ===========================================================================
        List<Performance_Evaluations_Assessments__c> lstPerformance_Evaluations_Assessments = new List<Performance_Evaluations_Assessments__c>(
            [SELECT Id FROM Performance_Evaluations_Assessments__c]
        );
        System.assertEquals(31, lstPerformance_Evaluations_Assessments.Size(), 'All test Custom Settings records did not get created!');
        
        
        //CREATE A TEST NI DEPARTMENT RECORD  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        //CREATE A TEST NI LOCATION RECORD  
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;
        
        // CREATE TEST MANAGER USER ===================================================
        User Manager = NI_TestClassData.createTestUser(1, 'NI Support Managers'); 
        Manager.LastName = 'Manager';
        Manager.Alias = 'xpepMgr';
        Manager.Email = 'Manager_prefeval@newmarketinc.com';
        Manager.Username = 'Manager_prefeval@newmarketinc.com';
        Manager.CommunityNickname = 'pepMgr12345';    
        Manager.Title = 'The Manager Figure';
        insert Manager;
        
        // CREATE TEST COLLABORATING MANAGER USER ======================================
        User CoManager = NI_TestClassData.createTestUser(2, 'NI Support Managers'); 
        CoManager.LastName = 'CoManager';
        CoManager.Alias = 'xpepCMgr';
        CoManager.Email = 'CoManager_prefeval@newmarketinc.com';
        CoManager.Username = 'CoManager_prefeval@newmarketinc.com';
        CoManager.CommunityNickname = 'pepCoMgr12345';  
        CoManager.Title = 'The Collabrative Manager Figure';
        insert CoManager;
        
        // CREATE TEST COLLABORATING MANAGER 2 USER ======================================
        User CoManager2 = NI_TestClassData.createTestUser(20, 'NI Support Managers'); 
        CoManager2.LastName = 'CoManager2';
        CoManager2.Alias = 'xpepCMg2';
        CoManager2.Email = 'CoManager2_prefeval@newmarketinc.com';
        CoManager2.Username = 'CoManager2_prefeval@newmarketinc.com';
        CoManager2.CommunityNickname = 'pepCoMgr2';  
        CoManager2.Title = 'The Collabrative Manager Figure';
        insert CoManager2;
        
        // CREATE TEST COLLABORATING MANAGER 2 USER ======================================
        User CoManager3 = NI_TestClassData.createTestUser(21, 'NI Support Managers'); 
        CoManager3.LastName = 'CoManager3';
        CoManager3.Alias = 'xpepCMg3';
        CoManager3.Email = 'CoManager3_prefeval@newmarketinc.com';
        CoManager3.Username = 'CoManager3_prefeval@newmarketinc.com';
        CoManager3.CommunityNickname = 'pepCoMgr3';  
        CoManager3.Title = 'The Collabrative Manager Figure';
        insert CoManager3;
        
        // CREATE TEST EMPLOYEE USER ===================================================
        User Employee = NI_TestClassData.createTestUser(3, 'NI Support CSR'); 
        Employee.ManagerId = Manager.Id;
        Employee.LastName = 'Employee';
        Employee.Alias = 'xpepEmp';
        Employee.Email = 'Employee_prefeval@newmarketinc.com';
        Employee.Username = 'Employee_prefeval@newmarketinc.com';
        Employee.CommunityNickname = 'pepEmp12345';    
        Employee.Title = 'The Employee Figure';
        Employee.Department = 'Support';
        insert Employee;
        
        // ASSERT TEST USERS WERE CREATED PROPERLY
        List<User> lstUserAsserts = new List<User>([SELECT Id, ManagerId, Title FROM User WHERE Alias LIKE 'xpep%']);
        System.assertEquals(5, lstUserAsserts.Size(), 'Test Users were not created!');
        
        // DECLARE VARIABLES THAT NEED SCOPE OUTSIDE OF System.runAs BLOCKS
        NI_PerfEval_Ext ctrl;
        NI_Employee_Performance_Evaluation__c perfEval;
        Id perfEvalId;
        PageReference newPrefEvalPage;
        PageReference viewPrefEvalPage;
        PageReference editPrefEvalPage;
        
        List<RecordType> lstRecordTypes = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Employee_Performance_Evaluation__c' AND isActive = true];
        // ASSERT RECORD TYPES WERE FOUND
        System.assertEquals(3, lstRecordTypes.Size(), '3 NI_Employee_Performance_Evaluation__c RecordTypes not found!');
        
        Id rtEmployeeStage;
        Id rtManagerStage;
        Id rtFinalStage;
        // ASSIGN RECORD TYPE ID VARIABLES
        for (RecordType rt : lstRecordTypes)
        {
            if (rt.Name == 'Employee Stage')
            {
                rtEmployeeStage = rt.Id;
            }
            if (rt.Name == 'Manager Stage')
            {
                rtManagerStage = rt.Id;
            }
            if (rt.Name == 'Final Stage')
            {
                rtFinalStage = rt.Id;
            }
        }
        
        // TEST AS THE EMPLOYEE
        System.runAs(Employee)
        {        
            
            //            User u = [SELECT Id, Name, Department, Title, ManagerId FROM User WHERE Id =: UserInfo.getUserId()];
            //            System.debug('EMPLOYEE RUNAS FIELDS: ' + u);
            
            // CREATE AN Employee_Performance_Evaluation IN 'Employee Draft' STAGE 
            perfEval = NI_TestClassData.createEmployee_Performance_Evaluation(Manager.Id, CoManager.Id);
            
            Date dtToday = Date.today();
            string strYear = String.ValueOf(dtToday.year());
            perfEval.Performance_Evaluation_Year__c = strYear; 
            perfEval.Employee_Name__c = UserInfo.getUserId();
            perfEval.Time_in_Position__c = '1 Year Test';
            perfEval.RecordTypeId = rtEmployeeStage;
            perfEval.Status__c = 'Employee Draft';
            perfEval.Collaborating_Manager_2__c = CoManager2.Id;
            perfEval.Collaborating_Manager_3__c = CoManager3.Id;    
            
            insert perfEval;
            perfEvalId = perfEval.Id;
            
            system.debug(' ===================== Initial perfEval Insert (start) ==================== ');
            system.debug('Time_in_Position__c = ' + perfEval.Time_in_Position__c);
            system.debug('OwnerId = ' + perfEval.OwnerId);
            system.debug('Employee_Name__c = ' + perfEval.Employee_Name__c);
            system.debug('RecordTypeId = ' + perfEval.RecordTypeId);
            system.debug('Manager__c = ' + perfEval.Manager__c);
            system.debug('Collaborating_Manager__c = ' + perfEval.Collaborating_Manager__c);
            system.debug('Title__c = ' + perfEval.Title__c);
            system.debug('Department__c = ' + perfEval.Department__c);  
            system.debug('Status__c = ' + perfEval.Status__c);
            system.debug('Collaborating_Manager_2__c = ' + perfEval.Collaborating_Manager_2__c);
            system.debug('Collaborating_Manager_3__c = ' + perfEval.Collaborating_Manager_3__c);
            system.debug('Status__c = ' + perfEval.Status__c);
            system.debug(' ===================== Initial perfEval Insert (end) ====================== ');       
            
            // ASSERT NI_Employee_Performance_Evaluation__c WAS CREATED
            List<NI_Employee_Performance_Evaluation__c> lstperfEvalAsserts1 = new List<NI_Employee_Performance_Evaluation__c>(
                [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, Title__c, Department__c, Status__c
                 FROM NI_Employee_Performance_Evaluation__c 
                 WHERE Id =: perfEvalId             
                 
                 AND Time_in_Position__c = '1 Year Test'
                 AND OwnerId =: Employee.Id
                 AND Employee_Name__c =: Employee.Id
                 AND RecordTypeId =: rtEmployeeStage
                 AND Manager__c =: Manager.Id
                 AND Collaborating_Manager__c =: CoManager.Id
                 AND Title__c = 'The Employee Figure'
                 AND Department__c = 'Support'
                ]
            );
            
            if (lstperfEvalAsserts1.Size() > 0)
            {
                system.debug(' ===================== lstperfEvalAsserts1 Fields (start) ==================== ');
                system.debug('Time_in_Position__c = ' + lstperfEvalAsserts1[0].Time_in_Position__c);
                system.debug('OwnerId = ' + lstperfEvalAsserts1[0].OwnerId);
                system.debug('Employee_Name__c = ' + lstperfEvalAsserts1[0].Employee_Name__c);
                system.debug('RecordTypeId = ' + lstperfEvalAsserts1[0].RecordTypeId);
                system.debug('Manager__c = ' + lstperfEvalAsserts1[0].Manager__c);
                system.debug('Collaborating_Manager__c = ' + lstperfEvalAsserts1[0].Collaborating_Manager__c);
                system.debug('Title__c = ' + lstperfEvalAsserts1[0].Title__c);
                system.debug('Department__c = ' + lstperfEvalAsserts1[0].Department__c);  
                system.debug('Status__c = ' + lstperfEvalAsserts1[0].Status__c);
                system.debug(' ===================== lstperfEvalAsserts1 Fields (End) ====================== ');       
            }            
            
            System.assertEquals(1, lstperfEvalAsserts1.Size(), 'Employee_Performance_Evaluation__c was not created properly!');
            
            // CREATE ALL ASSOCIATED ASSESMENT RECORDS 
            List<Performance_Evaluations_Assessments__c> lstCS = Performance_Evaluations_Assessments__c.getall().values();
            List<NI_PE_Assessment__c> lstAssessmentsToInsert = new List<NI_PE_Assessment__c>();
            
            for (Performance_Evaluations_Assessments__c p : lstCS)
            {
                NI_PE_Assessment__c a = NI_TestClassData.createPerfEvalAssessment(perfEvalId);
                a.Category__c = p.Category__c;        
                a.Description__c = p.Description__c;
                a.Self_Appraisal_Rating__c = 'Exceeds Expectations';
                a.Manager_Rating__c = 'Exceeds Expectations';
                lstAssessmentsToInsert.add(a); 
            }    
            
            Database.insert(lstAssessmentsToInsert);
            
            // ASSERT Performance_Evaluations_Assessments__c WERE CREATED
            List<NI_PE_Assessment__c> lstAssessmentsAsserts = new List<NI_PE_Assessment__c>(
                [SELECT Id FROM NI_PE_Assessment__c WHERE NI_Employee_Performance_Evaluation__c = : perfEval.Id]
            );
            System.assertEquals(lstAssessmentsAsserts.Size(), 31, 'Performance_Evaluations_Assessments__c were not created!');
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval));              
            
            // NAVIGATE TO VIEW PAGE
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval.id);
            Test.setCurrentPage(viewPrefEvalPage);   
            
            System.assertEquals(true, ctrl.bIsEmployee, 'bIsEmployee should be true!');
            System.assertEquals(false, ctrl.bIsManager, 'bIsManager should be false!');
            System.assertEquals(true, ctrl.isEmployeeDraft(perfEval), 'isEmployeeDraft should be true!');
            
            // NAVIGATE TO EDIT PAGE
            editPrefEvalPage = ctrl.editEval();  
            editPrefEvalPage.getParameters().put('id', perfEval.id);
            Test.setCurrentPage(editPrefEvalPage);  
            
            System.assertEquals(true, ctrl.bIsEmployee, 'bIsEmployee should be true!');
            System.assertEquals(false, ctrl.bIsManager, 'bIsManager should be false!');
            
            ctrl.cancelEditEval(); 
            
            // CREATE A EVAL GOAL RECORD 
            ctrl.newGoal(); 
            NI_PerfEval_Goals__c perfEvalGoal = NI_TestClassData.createPerfEvalGoals(perfEval.Id);       
            insert perfEvalGoal; 
            ctrl.goalId = perfEvalGoal.Id;
            ctrl.selectGoal(); 
            
            // CREATE A CAREER PATH RECORD
            ctrl.newPath();
            NI_Career_Path__c perfEvalPath = NI_TestClassData.createPerfEvalCareerPath(perfEval.Id);     
            insert perfEvalPath;
            ctrl.pathId = perfEvalPath.Id;
            ctrl.selectPath(); 
            
            viewPrefEvalPage = ctrl.sendToManager();
            viewPrefEvalPage.getParameters().put('id', perfEvalId); 
            Test.setCurrentPage(viewPrefEvalPage);   
            
            List<NI_Employee_Performance_Evaluation__c> lstperfEvalAsserts2 = new List<NI_Employee_Performance_Evaluation__c>(
                [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, Title__c, Department__c, Status__c
                 FROM NI_Employee_Performance_Evaluation__c 
                 WHERE Id =: perfEvalId 
                 
                 AND Time_in_Position__c = '1 Year Test'
                 AND OwnerId =: Employee.Id
                 AND Employee_Name__c =: Employee.Id                 
                 AND Manager__c =: Manager.Id
                 AND Collaborating_Manager__c =: CoManager.Id
                 AND Title__c = 'The Employee Figure'
                 AND Department__c = 'Support'
                 
                 AND RecordTypeId =: rtManagerStage
                 AND Status__c = 'Manager Draft'
                ]
            );
            
            System.assertEquals(1, lstperfEvalAsserts2.Size(), 'Employee_Performance_Evaluation__c was not updated properly! Stage and record type did not change after sendtomanager()');            
            //			System.assertEquals(false, ctrl.bIsEmployee, 'bIsEmployee should be false after sendToManager()!');
            //			System.assertEquals(true, ctrl.bIsManager, 'bIsManager should be true after sendToManager()!');
            //			
            //						 
            //						 
            //						 
            // INSTANTIATE EXTENSION CONTROLLER
            //ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval)); 
            //						 // NAVIGATE TO VIEW PAGE
            //viewPrefEvalPage = Page.NI_PerfEval_View;
            //viewPrefEvalPage.getParameters().put('id', perfEval.id);
            //Test.setCurrentPage(viewPrefEvalPage);
            
            ctrl.initComponentVisibilty();
            
            ctrl.cancelEditEval();
            
            // NAVIGATE TO VIEW PAGE
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', lstperfEvalAsserts2[0].id);
            Test.setCurrentPage(viewPrefEvalPage);
            
            System.assertEquals(true, ctrl.bIsEmployee, 'bIsEmployee should be true!');
            System.assertEquals('Manager Draft', lstperfEvalAsserts2[0].Status__c, 'Manager Draft');
            //System.assertEquals(true, ctrl.isManagerDraft(perfEval), 'isManagerDraft should be true!');
            
            
        }
        
        test.startTest();  
        // TEST MANAGER RETURNING TO EMPLOYEE
        System.runAs(Manager)
        {
            
            viewPrefEvalPage = ctrl.returnToEmployee();
            viewPrefEvalPage.getParameters().put('id', perfEvalId); 
            Test.setCurrentPage(viewPrefEvalPage);  
            
            List<NI_Employee_Performance_Evaluation__c> lstperfEvalAsserts3 = new List<NI_Employee_Performance_Evaluation__c>(
                [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, Title__c, Department__c, Status__c
                 FROM NI_Employee_Performance_Evaluation__c 
                 WHERE Id =: perfEvalId 
                 
                 //                 AND Time_in_Position__c = '1 Year Test'
                 //                 AND OwnerId =: Employee.Id
                 //                 AND Employee_Name__c =: Employee.Id                 
                 //                 AND Manager__c =: Manager.Id
                 //                 AND Collaborating_Manager__c =: CoManager.Id
                 //                 AND Title__c = 'The Employee Figure'
                 //                 AND Department__c = 'Support'
                 
                 AND RecordTypeId =: rtEmployeeStage
                 AND Status__c = 'Employee Draft'
                ]
            );
            
            
            if (lstperfEvalAsserts3.Size() > 0)
            {
                system.debug(' ===================== lstperfEvalAsserts3 Fields (start) ==================== ');
                system.debug('Time_in_Position__c = ' + lstperfEvalAsserts3[0].Time_in_Position__c);
                system.debug('OwnerId = ' + lstperfEvalAsserts3[0].OwnerId);
                system.debug('Employee_Name__c = ' + lstperfEvalAsserts3[0].Employee_Name__c);
                system.debug('RecordTypeId = ' + lstperfEvalAsserts3[0].RecordTypeId);
                system.debug('Manager__c = ' + lstperfEvalAsserts3[0].Manager__c);
                system.debug('Collaborating_Manager__c = ' + lstperfEvalAsserts3[0].Collaborating_Manager__c);
                system.debug('Title__c = ' + lstperfEvalAsserts3[0].Title__c);
                system.debug('Department__c = ' + lstperfEvalAsserts3[0].Department__c);  
                system.debug('Status__c = ' + lstperfEvalAsserts3[0].Status__c);
                system.debug(' ===================== lstperfEvalAsserts3 Fields (End) ====================== ');       
            }
            
            
            System.assertEquals(1, lstperfEvalAsserts3.Size(), 'Employee_Performance_Evaluation__c was not updated properly! Stage and record type did not change after returnToEmployee()');            
            //			System.assertEquals(true, ctrl.bIsEmployee, 'bIsEmployee should be true after returnToEmployee()!');
            //          System.assertEquals(false, ctrl.bIsManager, 'bIsManager should be false after returnToEmployee()!');		
            
        }
        
        //=====================================================================================================================================================================        
        System.runAs(Employee)
        {
            viewPrefEvalPage = ctrl.sendToManager(); 
            viewPrefEvalPage.getParameters().put('id', perfEvalId); 
            Test.setCurrentPage(viewPrefEvalPage); 
            
            List<NI_Employee_Performance_Evaluation__c> lstperfEvalAsserts4 = new List<NI_Employee_Performance_Evaluation__c>(
                [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, Title__c, Department__c, Status__c
                 FROM NI_Employee_Performance_Evaluation__c 
                 WHERE Id =: perfEvalId 
                 
                 AND Time_in_Position__c = '1 Year Test'
                 AND OwnerId =: Employee.Id
                 AND Employee_Name__c =: Employee.Id                 
                 AND Manager__c =: Manager.Id
                 AND Collaborating_Manager__c =: CoManager.Id
                 AND Title__c = 'The Employee Figure'
                 AND Department__c = 'Support'
                 
                 AND RecordTypeId =: rtManagerStage
                 AND Status__c = 'Manager Draft'
                ]
            );
            
            System.assertEquals(1, lstperfEvalAsserts4.Size(), 'Employee_Performance_Evaluation__c was not updated properly! Stage and record type did not change after sendtomanager()');            
            //			System.assertEquals(false, ctrl.bIsEmployee, 'bIsEmployee should be false after sendToManager()!');
            //          System.assertEquals(true, ctrl.bIsManager, 'bIsManager should be true after sendToManager()!');		
        }
        //==============================================================================================================================================================================================================================        
        // IF EMPLOYEE IS VIEWING AND IS MANGAGER DRAFT ===========
        System.runAs(Employee)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval1 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'Manager Draft'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval1));
            ctrl.bIsEmployee = true;
            ctrl.isManagerDraft(perfEval1);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval1.id);
            Test.setCurrentPage(viewPrefEvalPage);  		 
            
        }
        //=====================================================================================================================================================================================
        
        // IF MANAGER IS VIEWING AND IS MANGAGER DRAFT ===========
        System.runAs(Manager)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval2 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'Manager Draft'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval2));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval2);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval2.id);
            Test.setCurrentPage(viewPrefEvalPage); 
            
            //SET STATUS TO 'In Review'
            perfEval2.Status__c = 'In Review';
            update perfEval2;
            
        }
        
        //==============================================================================================================================================================================================================================        
        // IF EMPLOYEE IS VIEWING AND IS IN REVIEW ===========
        System.runAs(Employee)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval3 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'In Review'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval3));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval3);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval3.id);
            Test.setCurrentPage(viewPrefEvalPage);
            
        }
        
        //==============================================================================================================================================================================================================================        
        // IF MANAGER IS VIEWING AND IS IN REVIEW ===========
        System.runAs(Manager)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval4 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'In Review'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval4));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval3);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval4.id);
            Test.setCurrentPage(viewPrefEvalPage);
            
            //SET STATUS TO 'Pending Approval'
            perfEval4.Status__c = 'Pending Approval';
            update perfEval4;
            
        }
        
        //==============================================================================================================================================================================================================================        
        // IF EMPLOYEE IS VIEWING AND IS PENDING APPROVAL ===========
        System.runAs(Employee)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval5 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'Pending Approval'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval5));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval3);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval5.id);
            Test.setCurrentPage(viewPrefEvalPage);
            
        }
        
        //==============================================================================================================================================================================================================================        
        // IF MANAGER IS VIEWING AND IS PENDING APPROVAL ===========
        System.runAs(Manager)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval6 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'Pending Approval'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval6));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval3);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval6.id);
            Test.setCurrentPage(viewPrefEvalPage);
            
            //SET STATUS TO 'Evaluation Complete'
            perfEval6.Status__c = 'Evaluation Complete';
            update perfEval6;
            
        }
        //==============================================================================================================================================================================================================================        
        // IF EMPLOYEE IS VIEWING AND EVALUATION COMPLETE ===========
        System.runAs(Employee)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval7 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'Evaluation Complete'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval7));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval3);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval7.id);
            Test.setCurrentPage(viewPrefEvalPage);
            
        }
        
        //==============================================================================================================================================================================================================================        
        // IF MANAGER IS VIEWING AND EVALUATION COMPLETE ===========
        System.runAs(Manager)
        {
            
            NI_Employee_Performance_Evaluation__c perfEval8 = [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, 
                                                               Collaborating_Manager_2__c, Collaborating_Manager_3__c, Title__c, Department__c, Status__c
                                                               FROM NI_Employee_Performance_Evaluation__c 
                                                               WHERE Status__c = 'Evaluation Complete'];
            
            // INSTANTIATE EXTENSION CONTROLLER
            ctrl = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval8));
            ctrl.bIsEmployee = true;
            //ctrl.isManagerDraft(perfEval3);
            ctrl.initComponentVisibilty();
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval8.id);
            Test.setCurrentPage(viewPrefEvalPage);
            
            //SET STATUS TO 'Pending Approval'
            //perfEval4.Status__c = 'Pending Approval';
            //update perfEval2;
            
            
        }
        
        test.stopTest();        
        
        //=================================================================================================================================================================        
        // ADMIN VIP PASS =========================================
        System.runAs(Employee)
        {
            //ctrl.bIsAdministrator = true;
            //ctrl.initComponentVisibilty();    
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval.id);
            Test.setCurrentPage(viewPrefEvalPage);
        }
        
        
        System.runAs(Manager)
        {
            
            viewPrefEvalPage = ctrl.reviewWithEmployee(); 
            viewPrefEvalPage.getParameters().put('id', perfEvalId); 
            Test.setCurrentPage(viewPrefEvalPage); 
            
            List<NI_Employee_Performance_Evaluation__c> lstperfEvalAsserts5 = new List<NI_Employee_Performance_Evaluation__c>(
                [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, Title__c, Department__c, Status__c
                 FROM NI_Employee_Performance_Evaluation__c 
                 WHERE Id =: perfEvalId 
                 
                 //                 AND Time_in_Position__c = '1 Year Test'
                 //                 AND OwnerId =: Employee.Id
                 //                 AND Employee_Name__c =: Employee.Id                 
                 //                 AND Manager__c =: Manager.Id
                 //                 AND Collaborating_Manager__c =: CoManager.Id
                 //                 AND Title__c = 'The Employee Figure'
                 //                 AND Department__c = 'Support'
                 
                 AND RecordTypeId =: rtFinalStage
                 AND Status__c = 'In Review'
                ]
            );
            
            System.assertEquals(1, lstperfEvalAsserts5.Size(), 'Employee_Performance_Evaluation__c was not updated properly! Stage and record type did not change after sendtomanager()');            
            //			System.assertEquals(false, ctrl.bIsEmployee, 'bIsEmployee should be false after sendToManager()!');
            //          System.assertEquals(true, ctrl.bIsManager, 'bIsManager should be true after sendToManager()!');		
            
            // TEST SUBMITTING FOR APPROVAL            
            viewPrefEvalPage = ctrl.employeeSignoff(); 
            viewPrefEvalPage.getParameters().put('id', perfEvalId); 
            Test.setCurrentPage(viewPrefEvalPage); 
            
        }
        
        //SET THE STATUS TO EVALUATION COMPLETE
        perfEval.Status__c = 'Evaluation Complete';
        update perfEval;
        
        System.runAs(Employee)
        {
            
            viewPrefEvalPage = Page.NI_PerfEval_View;
            viewPrefEvalPage.getParameters().put('id', perfEval.id);
            Test.setCurrentPage(viewPrefEvalPage);  		 
            
        }    
        
        
        // CREATE NEW INSTANCE OF EXTENSION CONTROLLER TO FIRE CONSTRUCTOR CODE FOR CREATE AND DELETE TESTING
        NI_PerfEval_Ext ctrl2 = new NI_PerfEval_Ext(new ApexPages.StandardController(perfEval));  
        
        // TEST ADMIN        
        editPrefEvalPage = Page.NI_PerfEval_Edit;
        editPrefEvalPage.getParameters().put('id', perfEvalId); 
        editPrefEvalPage.getParameters().put('admin', 'nihr14'); 
        Test.setCurrentPage(editPrefEvalPage); 
        editPrefEvalPage = ctrl2.editEval();
        Test.setCurrentPage(editPrefEvalPage); 
        
        // TEST CREATE
        editPrefEvalPage = ctrl2.createEval();
        editPrefEvalPage.getParameters().put('id', perfEvalId); 
        Test.setCurrentPage(editPrefEvalPage); 
        
        // TEST DELETE 
        ctrl2.deleteEval(); 
        
        List<NI_Employee_Performance_Evaluation__c> lstperfEvalAsserts5 = new List<NI_Employee_Performance_Evaluation__c>(
            [SELECT Id, Time_in_Position__c, OwnerId, Employee_Name__c, RecordTypeId, Manager__c, Collaborating_Manager__c, Title__c, Department__c, Status__c
             FROM NI_Employee_Performance_Evaluation__c 
             WHERE Id =: perfEvalId]
        );
        
        System.assertEquals(0, lstperfEvalAsserts5.Size(), 'Employee_Performance_Evaluation__c was not deleted after deleteEval()');            
        
        
    }
    
    
}