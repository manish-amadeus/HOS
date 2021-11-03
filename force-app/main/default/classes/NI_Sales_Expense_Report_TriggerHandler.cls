/************************************************************************************************
Name            : NI_Sales_Expense_Report_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 7/8/2013
Last Mod Date   : 7/8/2013
Last Mod By     : Stuart Emery
NICC Reference  : NICC-007473
Description     : Class that handles all trigger code for the Expense_Report__c Object
                : 
                : 
*************************************************************************************************/
public class NI_Sales_Expense_Report_TriggerHandler 
{

    private boolean m_isExecuting = false;

    public NI_Sales_Expense_Report_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

   // public void OnBeforeInsert(List<Expense_Report__c> newTrigger)
   // {
   // }
    
   // public void OnBeforeUpdate(List<Expense_Report__c> newTrigger, Map<Id,Expense_Report__c> oldMapTrigger)
   // {        
   // }

   // public void OnBeforeDelete(List<Expense_Report__c> newTrigger)
   // {        
   // }
    
   // public void OnAfterInsert(List<Expense_Report__c> newTrigger)
   // {
   // }
    
    public void OnAfterUpdate(List<Expense_Report__c> newTrigger, Map<Id,Expense_Report__c> oldMapTrigger)
    {
        
        // CREATE LIST TO HOLD ALL RECORDS WHERE THE FINAL APPROVER DOESN'T MATCH THE OLD FINAL APPROVER
        List<Expense_Report__c> lstFinalApproverShare = new List<Expense_Report__c>(); 
        for (Expense_Report__c er : newTrigger) 
        {
            Expense_Report__c oldEr = oldMapTrigger.get(er.Id);
            
            if (er.Final_Approver__c != oldEr.Final_Approver__c)
            {
                lstFinalApproverShare.add(er);
            }
        }      
        
        // CALL THE FINAL APPROVER APEX SHARING METHOD
        Change_FinalApprover_Share(lstFinalApproverShare); 
        
    } 
        
   // public void OnAfterDelete(List<Expense_Report__c> newTrigger)
   // {        
   // }
    
   // public void OnAfterUnDelete(List<Expense_Report__c> newTrigger)
   // {        
   // }    
    

    // SHARING FUNCTIONS =====================================================================

    public void Change_FinalApprover_Share(List<Expense_Report__c> newTrigger)
    {          

        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<Expense_Report__Share> lstRemoveShares = new List<Expense_Report__Share>([
            SELECT id
            FROM Expense_Report__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Final_Approver__c'
        ]); 
        
        // BULK REMOVE SHARE RECORDS
        List<Database.DeleteResult> ddr = Database.delete(lstRemoveShares, false);        
        
        
        // FOR MULTI APPROVER DEV EXPENSE REPORTS - FILL SET WITH DISTINCT OWNER IDS FOR LATER QUERY ON USER TO GET DEPT CODES
        Set<Id> setOwnerIds = new Set<Id>();
        for (Expense_Report__c ex1 : newTrigger)
        {
            setOwnerIds.Add(ex1.OwnerId);
        }
        
        // FILL MAP WITH OWNER/USER RECORDS
        Map<Id, User> mapUser2DeptCode = new Map<Id, User>(); 
        for (User u1 : [SELECT Id, DepartmentCode__c FROM User WHERE Id IN : setOwnerIds])
        {
            mapUser2DeptCode.Put(u1.Id, u1);
        }
        
        // GET CUSTOM SETTING VALUE THAT CONTAINS THE STRING OF DEV DEPT CODES
        NIExpenseReportDevDepartments__c d = NIExpenseReportDevDepartments__c.getValues('Dev Dept Codes');
		string strDevDeptCodes = d.Comma_Delimited_Dev_Dept_Codes__c;
        
        // LIST OF SHARES THAT NEED TO BE ADDED   
        List<Expense_Report__Share> lstShares = new List<Expense_Report__Share>();
        
        for (Expense_Report__c er : newTrigger)
        {
			// IF THE FINAL APPROVER IS NOT THE OWNER (NO NEED TO SHARE)
            if (er.Final_Approver__c != er.OwnerId)
            {
                Expense_Report__Share erShare = new Expense_Report__Share();
                erShare.ParentId = er.Id;
                erShare.UserOrGroupId = er.Final_Approver__c;
                erShare.AccessLevel = 'read';
                erShare.RowCause = Schema.Expense_Report__Share.RowCause.Final_Approver__c;
                lstShares.add(erShare);
            } 

            // IF THE OWNER'S DEPARTMENT CODE IS A DEV RELATED ONE SPECIFIED IN CUSTOM SETTING, 
            // APEX SHARE ALL USERS THAT BELONG TO THE "Expense Report - Dev Exec Approver" PUBLIC GROUP
            if (strDevDeptCodes.contains(mapUser2DeptCode.get(er.OwnerId).DepartmentCode__c))
            {
                for (GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN (SELECT g.Id FROM Group g WHERE g.DeveloperName = 'Expense_Report_Dev_Exec_Approver')])
                {
                    Expense_Report__Share erExecShare = new Expense_Report__Share();
                    erExecShare.ParentId = er.Id;
                    erExecShare.UserOrGroupId = gm.UserOrGroupId;
                    erExecShare.AccessLevel = 'read';
                    erExecShare.RowCause = Schema.Expense_Report__Share.RowCause.Final_Approver__c;
                    lstShares.add(erExecShare);                         
                }
                
            }                
 
        }
        
        // BULK UPDATE SHARE RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstShares, false); 
              
    }     
    
}