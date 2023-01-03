/****************************************************************************************
Name            : NI_PerfEval_Clone_Ext_Test Class
Author          : Stuart Emery
Created Date    : 11/1/2015
Last Mod Date   : 11/1/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Test Class for the NI_PerfEval_Clone_Ext
                :
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_PerfEval_Clone_Ext_Test {
    
    public static testMethod void testPerfEvalGoal() 
    {

        //CREATE A TEST NI DEPARTMENT RECORD =========================================  
        NI_Departments__c d = NI_TestClassData.createTestNI_Department(1);
        insert d;
        
        //CREATE A TEST NI LOCATION RECORD ===========================================  
        NI_Location__c l = NI_TestClassData.createTestNI_Location(1);
        insert l;
        
        // CREATE TEST MANAGER USER ===================================================
        User Manager = NI_TestClassData.createTestUser(1, 'NI Administrator'); 
        Manager.LastName = 'Manager';
        Manager.Alias = 'pepMgr';
        Manager.Email = 'prefevalManager@newmarketinc.com';
        Manager.Username = 'prefevalManager@newmarketinc.com';
        Manager.CommunityNickname = 'pepMgr12345';       
        insert Manager;
        
        // CREATE TEST COLLABORATING MANAGER USER ======================================
        User CoManager = NI_TestClassData.createTestUser(2, 'NI Administrator'); 
        CoManager.LastName = 'CoManager';
        CoManager.Alias = 'pepCoMgr';
        CoManager.Email = 'prefevalCoManager@newmarketinc.com';
        CoManager.Username = 'prefevalCoManager@newmarketinc.com';
        CoManager.CommunityNickname = 'pepCoMgr12345';           
        insert CoManager;             

        // CREATE TEST EMPLOYEE USER ===================================================
        User Employee = NI_TestClassData.createTestUser(3, 'NI Administrator'); 
        Employee.Manager = Manager;
        Employee.LastName = 'Employee';
        Employee.Alias = 'pepEmp';
        Employee.Email = 'prefevalEmployee@newmarketinc.com';
        Employee.Username = 'prefevalEmployee@newmarketinc.com';
        Employee.CommunityNickname = 'pepEmp12345';           
        insert Employee;

        NI_Employee_Performance_Evaluation__c perfEval = NI_TestClassData.createEmployee_Performance_Evaluation(Manager.Id, CoManager.Id);   
        
        perfEval.OwnerId = Employee.Id;
        perfEval.Employee_Name__c = Employee.Id;
        perfEval.Status__c = 'Employee Draft'; 
        perfEval.Time_in_Position__c = '300';
        insert perfEval;
        
        NI_PerfEval_Goals__c perfEvalGoal = NI_TestClassData.createPerfEvalGoals(perfEval.Id);       
        insert perfEvalGoal; 
        
        PageReference viewPage = Page.NI_PerfEval_Clone;
        viewPage.getParameters().put('evid', perfEval.id);
        Test.setCurrentPage(viewPage);
        ApexPages.StandardController apsc = new ApexPages.StandardController(perfEval);
        NI_PerfEval_Clone_Ext ctrl = new NI_PerfEval_Clone_Ext(apsc);
        
        ctrl.cloneWithGoals();
        
    }    

}