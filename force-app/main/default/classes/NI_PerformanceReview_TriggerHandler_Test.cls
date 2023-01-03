/****************************************************************************************
Name            : NI_PerformanceReview_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 12/10/2014
Last Mod Date   : 10/31/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_PerformanceReview_TriggerHandler_Test
{
    
    public static testMethod void testPerformanceReview() 
    {
        
        NI_PerformanceReview_TriggerHandler handler = new NI_PerformanceReview_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;
        
        //CREATE A TEST NI DEPARTMENT RECORD  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        //CREATE A TEST NI LOCATION RECORD  
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;
        
        // CREATE TEST MANAGER LEVEL 4 HIERARCHY ===================================================
        User Manager4 = NI_TestClassData.createTestUser(12, 'NI Administrator'); 
        Manager4.LastName = 'Manager4';
        Manager4.Alias = 'pepMgr4';
        Manager4.Email = 'prefevalManager4@newmarketinc.com';
        Manager4.Username = 'prefevalManager4@newmarketinc.com';
        Manager4.CommunityNickname = 'pepMgr4';
        insert Manager4;
        
          // CREATE TEST MANAGER LEVEL 3 HIERARCHY ===================================================
        User Manager3 = NI_TestClassData.createTestUser(11, 'NI Administrator'); 
        Manager3.LastName = 'Manager3';
        Manager3.Alias = 'pepMgr3';
        Manager3.Email = 'prefevalManager3@newmarketinc.com';
        Manager3.Username = 'prefevalManager3@newmarketinc.com';
        Manager3.CommunityNickname = 'pepMgr3';
        Manager3.ManagerId = Manager4.Id;
        insert Manager3;
        
        // CREATE TEST MANAGER LEVEL 2 HIERARCHY ===================================================
        User Manager2 = NI_TestClassData.createTestUser(10, 'NI Administrator'); 
        Manager2.LastName = 'Manager10';
        Manager2.Alias = 'pepMgr10';
        Manager2.Email = 'prefevalManager10@newmarketinc.com';
        Manager2.Username = 'prefevalManager10@newmarketinc.com';
        Manager2.CommunityNickname = 'pepMgr10';
        Manager2.ManagerId = Manager3.Id;
        insert Manager2;

        // CREATE TEST MANAGER USER ===================================================
        User Manager = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
        Manager.LastName = 'Manager';
        Manager.Alias = 'pepMgr';
        Manager.Email = 'prefevalManager@newmarketinc.com';
        Manager.Username = 'prefevalManager@newmarketinc.com';
        Manager.CommunityNickname = 'pepMgr12345'; 
        Manager.ManagerId = Manager2.Id;
        insert Manager;
        
        // CREATE TEST COLLABORATING MANAGER USER ======================================
        User CoManager = NI_TestClassData.createTestUser(2, 'NI Administrator'); 
        CoManager.LastName = 'CoManager';
        CoManager.Alias = 'pepCoMgr';
        CoManager.Email = 'prefevalCoManager@newmarketinc.com';
        CoManager.Username = 'prefevalCoManager@newmarketinc.com';
        CoManager.CommunityNickname = 'pepCoMgr12345';           
        insert CoManager;
        
        // CREATE TEST COLLABORATING MANAGER 2 USER ======================================
        User CoManager2 = NI_TestClassData.createTestUser(20, 'NI Administrator'); 
        CoManager2.LastName = 'CoManager2';
        CoManager2.Alias = 'CoMgr2';
        CoManager2.Email = 'prefevalCoManager2@newmarketinc.com';
        CoManager2.Username = 'prefevalCoManager2@newmarketinc.com';
        CoManager2.CommunityNickname = 'pepCoMgr2';           
        insert CoManager2;
        
        // CREATE TEST COLLABORATING MANAGER 3 USER ======================================
        User CoManager3 = NI_TestClassData.createTestUser(21, 'NI Administrator'); 
        CoManager3.LastName = 'CoManager3';
        CoManager3.Alias = 'CoMgr3';
        CoManager3.Email = 'prefevalCoManager3@newmarketinc.com';
        CoManager3.Username = 'prefevalCoManager3@newmarketinc.com';
        CoManager3.CommunityNickname = 'pepCoMgr3';           
        insert CoManager3;

        // CREATE TEST EMPLOYEE USER ===================================================
        User Employee = NI_TestClassData.createTestUser(3, 'NI Administrator'); 
        Employee.ManagerId = Manager.Id;
        Employee.LastName = 'Employee';
        Employee.Alias = 'pepEmp';
        Employee.Email = 'prefevalEmployee@newmarketinc.com';
        Employee.Username = 'prefevalEmployee@newmarketinc.com';
        Employee.CommunityNickname = 'pepEmp12345';
        Employee.DepartmentCode__c = d.Name;
        Employee.NI_Location__c = l.Name;
        insert Employee;
        
        User EmployeeAlt = NI_TestClassData.createTestUser(4, 'NI Administrator'); 
        EmployeeAlt.Manager = Manager;
        EmployeeAlt.LastName = 'EmployeeAlt';
        EmployeeAlt.Alias = 'pepEAlt';
        EmployeeAlt.Email = 'prefevalEmployeeAlt@newmarketinc.com';
        EmployeeAlt.Username = 'prefevalEmployeeAlt@newmarketinc.com';
        EmployeeAlt.CommunityNickname = 'pepEmpAlt12345';
        EmployeeAlt.DepartmentCode__c = d.Name;
        EmployeeAlt.NI_Location__c = l.Name;
        insert EmployeeAlt;

        NI_Employee_Performance_Evaluation__c perfEval1 = NI_TestClassData.createEmployee_Performance_Evaluation(Manager.Id, CoManager.Id);   

        perfEval1.OwnerId = Employee.Id;
        perfEval1.Employee_Name__c = Employee.Id;
        perfEval1.Status__c = 'Employee Draft'; 
        perfEval1.Time_in_Position__c = '300';
        perfEval1.Collaborating_Manager_2__c = CoManager2.Id;
        perfEval1.Collaborating_Manager_3__c = CoManager3.Id;
        insert perfEval1;
         
        // INTENTIONALLY SWAP MANAGERS TO CREATE CONDITION
        perfEval1.Manager__c = CoManager.Id;
        perfEval1.Collaborating_Manager__c = Manager.Id;
        perfEval1.Employee_Name__c = EmployeeAlt.Id;
        update perfEval1;
        
        
/*        
        NI_Employee_Performance_Evaluation__c perfEval2 = NI_TestClassData.createEmployee_Performance_Evaluation(CoManager.Id, Manager.Id);   
        perfEval2.OwnerId = Employee.Id;
        perfEval2.Employee_Name__c = Employee.Name;
        perfEval2.Status__c = 'Employee Draft'; 
        perfEval2.Time_in_Position__c = '300';
        insert perfEval2;
        
        List<NI_Employee_Performance_Evaluation__c> newTrig = new List<NI_Employee_Performance_Evaluation__c>();
        Map<Id, NI_Employee_Performance_Evaluation__c> oldTrigMap = new Map<Id, NI_Employee_Performance_Evaluation__c>();
        
        newTrig.Add(perfEval1);
        newTrig.Add(perfEval2);
        oldTrigMap.Put(perfEval1.Id, perfEval1);
        oldTrigMap.Put(perfEval2.Id, perfEval2);

        
        NI_TriggerManager.isFirstTime = true;
        handler.OnAfterUpdate(newTrig, oldTrigMap);

        NI_TriggerManager.isFirstTime = true;
        handler.OnBeforeInsert(lstWHA);
        NI_TriggerManager.isFirstTime = true;
        handler.OnBeforeUpdate(lstWHA);
        NI_TriggerManager.isFirstTime = true;
        handler.OnBeforeDelete(lstWHA);
        NI_TriggerManager.isFirstTime = true;
        handler.OnAfterInsert(lstWHA);
*/
        
    }    
    
}