/****************************************************************************************
Name            : NI_Opportunity_TrigHndlr_Test Test Class
Author          : Sean Harris
Created Date    : 7/9/2013
Last Mod Date   : 7/9/2013
Last Mod By     : Stuart Emery
NICC Reference  : NICC-007473
Description     : test Class for NI_Sales_Expense_Report_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
private class NI_Sales_Expense_Report_TrigHndlr_Test 
{
    
    static testMethod void myUnitTest() 
    {    
        
        NI_Sales_Expense_Report_TriggerHandler handler = new NI_Sales_Expense_Report_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;

        // CREATE CUSTOM SETTING TEST DATA 
        NIExpenseReportDevDepartments__c csFields = new NIExpenseReportDevDepartments__c();
        csFields.Name = 'Dev Dept Codes';
        csFields.Comma_Delimited_Dev_Dept_Codes__c = '711,712,718,719,720,721,722,723,724,728,729';       
        insert csFields;        
        
        // CREATE A MANAGER USER
		User m = NI_TestClassData.createTestUser(75, 'NI Administrator');
        m.DepartmentCode__c = '130';
        m.NI_Location__c = '010';        
        insert m;   
        
        // CREATE A TEST USER FOR FINAL APPROVER
        User u = NI_TestClassData.createTestUser(85, 'NI Administrator');
        u.DepartmentCode__c = '720';
        u.NI_Location__c = '010'; 
        u.ManagerId = m.Id;
        insert u;                
        
        // CREATE A SALES EXPENSE REPORT RECORD AS A DEV USER      
        system.runAs(u)
        {
            
            Expense_Report__c er = NI_TestClassData.createTestSalesExpenseReport(1);
            insert er;
            
            // UPDATE FINAL APPROVER TO CAUSE THE AFTER TRIGGERS TO FIRE
            er.Final_Approver__c = u.Id;
            test.StartTest();
            update er;  
            test.StopTest();
            
        }
        
    }
    
    // TEST FOR BULK UPDATES
    public static testMethod void testBulkUpdates() 
    {

        // CREATE CUSTOM SETTING TEST DATA 
        NIExpenseReportDevDepartments__c csFields = new NIExpenseReportDevDepartments__c();
        csFields.Name = 'Dev Dept Codes';
        csFields.Comma_Delimited_Dev_Dept_Codes__c = '711,712,718,719,720,721,722,723,724,728,729';       
        insert csFields;    
        
        // CREATE A MANAGER USER
		User m = NI_TestClassData.createTestUser(300, 'NI Administrator');
        m.DepartmentCode__c = '130';
        m.NI_Location__c = '010';        
        insert m;     

        // CREATE A TEST USER FOR FINAL APPROVER
		User f = NI_TestClassData.createTestUser(400, 'NI Administrator');
        f.DepartmentCode__c = '130';
        f.NI_Location__c = '010';        
        insert f;   
        
        // CREATE A TEST USER FOR RECORD OWNER
        User u = NI_TestClassData.createTestUser(500, 'NI Administrator');
        u.DepartmentCode__c = '130';
        u.NI_Location__c = '010';   
        u.ManagerId = m.Id;
        insert u;                          

        // DML LISTS
        List<Expense_Report__c> lstExpenseReportsToInsert = new List<Expense_Report__c>();
        List<Expense_Report__c> lstExpenseReportsToUpdate = new List<Expense_Report__c>();

        system.runAs(u)
        {
            // CREATE 200 EXPENSE REPORTS TO BULK TEST INSERT
            for (Integer j = 1; j < 25; j++)
            {
                Expense_Report__c er = NI_TestClassData.createTestSalesExpenseReport(j);
                lstExpenseReportsToInsert.add(er);
            }

            Database.Insert(lstExpenseReportsToInsert);
            
            // UPDATE THE FINAL APPROVER FOR THE INSERTED SALES EXPENSE REPORTS  
            for (Expense_Report__c e : lstExpenseReportsToInsert)
            {
                e.Final_Approver__c = f.Id;
                lstExpenseReportsToUpdate.add(e);
            }  
            
            Database.Update(lstExpenseReportsToUpdate);
            
        }
        
    }   

}