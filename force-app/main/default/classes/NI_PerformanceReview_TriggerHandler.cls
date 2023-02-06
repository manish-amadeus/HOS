/************************************************************************************************
Name            : NI_PerformanceReview_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 9/17/2014
Last Mod Date   : 10/31/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Employee_Performance_Evaluation__c Object
:
: 
*************************************************************************************************/
public class NI_PerformanceReview_TriggerHandler
{
    
    private boolean m_isExecuting = false;
    
    
    public NI_PerformanceReview_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }
    
    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    
    public void OnBeforeInsert(List<NI_Employee_Performance_Evaluation__c> newTrigger)
    {
        //CALL THE SET PERFORMANCE EVALUATION YEAR METHOD  
        Set_PerformanceEvalYear(newTrigger);
        
        //CALL THE METHOD TO SET THE DEPARTMENT CODE AND FINANCE LOCATION FIELDS
        Set_DepCode_LocationFields(newTrigger);
    }
    
    public void OnAfterInsert(List<NI_Employee_Performance_Evaluation__c> newTrigger)
    {
        //CALL THE EMPLOYEE APEX SHARING METHOD
        Change_Employee_Share(newTrigger);
        
        //CALL THE MANAGER NAME APEX SHARING METHOD  
        Change_Manager_Share(newTrigger);         
    }
      
    public void OnBeforeUpdate(List<NI_Employee_Performance_Evaluation__c> newTrigger, Map<Id,NI_Employee_Performance_Evaluation__c> oldMapTrigger)
    {  
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW EMPLOYEE NAME DOESN'T MATCH THE OLD EMPLOYEE NAME
        List<NI_Employee_Performance_Evaluation__c> lstEmployeeChange = new List<NI_Employee_Performance_Evaluation__c>();  
        
        for (NI_Employee_Performance_Evaluation__c pe : newTrigger) 
        {
            NI_Employee_Performance_Evaluation__c oldPE = oldMapTrigger.get(pe.Id);
            
            if (pe.Employee_Name__c != oldPE.Employee_Name__c)
            {
                lstEmployeeChange.add(pe);
            }  
        }      
                 
        //CALL THE METHOD TO SET THE DEPARTMENT CODE AND FINANCE LOCATION FIELDS
         if (lstEmployeeChange.size() > 0)
         {
             Set_DepCode_LocationFields(lstEmployeeChange);
         }    
    }  
    
    public void OnAfterUpdate(List<NI_Employee_Performance_Evaluation__c> newTrigger, Map<Id,NI_Employee_Performance_Evaluation__c> oldMapTrigger)
    {
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW FINAL APPROVER DOESN'T MATCH THE OLD FINAL APPROVER
        List<NI_Employee_Performance_Evaluation__c> lstManagerShare = new List<NI_Employee_Performance_Evaluation__c>();
        
        //CREATE  LIST TO HOLD ALL RECORDS WHERE THE NEW EMPLOYEE NAME DOESN'T MATCH THE OLD EMPLOYEE NAME
        List<NI_Employee_Performance_Evaluation__c> lstEmployeeNameShare = new List<NI_Employee_Performance_Evaluation__c>();  
        
        for (NI_Employee_Performance_Evaluation__c pe : newTrigger) 
        {
            NI_Employee_Performance_Evaluation__c oldPE = oldMapTrigger.get(pe.Id);
            
            if ((pe.Manager__c != oldPE.Manager__c) || (pe.Collaborating_Manager__c != oldPE.Collaborating_Manager__c))
            {
                lstManagerShare.add(pe);
            }
            
            if (pe.Employee_Name__c != oldPE.Employee_Name__c)
            {
                lstEmployeeNameShare.add(pe);
            }  
        }      
        
        //CALL THE FINAL APPROVER APEX SHARING METHOD
        if (lstManagerShare.size() > 0)
        {  
            Change_Manager_Share(lstManagerShare);
        }  
        
        //CALL THE EMPLOYEE NAME APEX SHARING METHOD
        if (lstEmployeeNameShare.size() > 0)
        {  
            Change_Employee_Share(lstEmployeeNameShare);
        }                  
    }  
    
    
    // ================================================================================================
    //  APEX SHARING METHODS
    // ================================================================================================
    
    // EMPLOYEE NAME SHARE
    public void Change_Employee_Share(List<NI_Employee_Performance_Evaluation__c> newTrigger)
    {          
        
        //LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Employee_Performance_Evaluation__Share> lstSharesToRemove = new List<NI_Employee_Performance_Evaluation__Share>([
            SELECT id 
            FROM NI_Employee_Performance_Evaluation__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Employee__c']); 
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug(' ***** SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        //LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Employee_Performance_Evaluation__Share> lstSharesToInsert = new List<NI_Employee_Performance_Evaluation__Share>();
        
        for (NI_Employee_Performance_Evaluation__c pe : newTrigger)
        {
            if ((pe.Employee_Name__c != pe.OwnerId) && (pe.Employee_Name__c != null))
            {
                NI_Employee_Performance_Evaluation__Share peShare = new NI_Employee_Performance_Evaluation__Share();
                peShare.ParentId = pe.Id;
                peShare.UserOrGroupId = pe.Employee_Name__c;
                peShare.AccessLevel = 'Edit';
                peShare.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Employee__c;
                lstSharesToInsert.add(peShare);
            } 
            
        }
        
        // USE DATABASE DML METHOD TO ADD THE SHARES
        if (lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert, true);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
        
    }
    
    //======================================================================================================================
    // FINAL APPROVER SHARE  
    public void Change_Manager_Share(List<NI_Employee_Performance_Evaluation__c> newTrigger)
    {          
        
        List<NI_Employee_Performance_Evaluation__c> lstPerfEvals = 
            [SELECT Id, OwnerId, Manager__r.ManagerId,
             Manager__r.Manager.ManagerId, 
             Manager__r.Manager.Manager.ManagerId,
             Collaborating_Manager__c,Collaborating_Manager_2__c,
             Collaborating_Manager_3__c 
             FROM NI_Employee_Performance_Evaluation__c
             WHERE Id IN : newTrigger];
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Employee_Performance_Evaluation__Share> lstSharesToRemove = new List<NI_Employee_Performance_Evaluation__Share>([
            SELECT Id
            FROM NI_Employee_Performance_Evaluation__Share
            WHERE ParentId IN : newTrigger 
            AND (RowCause = 'Manager__c' OR RowCause = 'Manager_Hierarchy_Share__c')]); 
        
        // BULK REMOVE SHARE RECORDS
        if (lstSharesToRemove.size() > 0)
        {
            Database.DeleteResult[] drList = Database.delete(lstSharesToRemove, false);
            for (Database.DeleteResult dr : drList) 
            {
                if (dr.isSuccess()) 
                {
                    System.debug(' ***** SUCCESSFULLY DELETED SHARE RECORD ID: ' + dr.getId());
                }
                else 
                {
                    Database.Error err = dr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }        
        }
        
        // LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Employee_Performance_Evaluation__Share> lstSharesToInsert = new List<NI_Employee_Performance_Evaluation__Share>();
        
        for (NI_Employee_Performance_Evaluation__c pe : lstPerfEvals)
        {
            
            if ((pe.Manager__c != pe.OwnerId) && (pe.Manager__c != null))
            {
                NI_Employee_Performance_Evaluation__Share peMgrShare = new NI_Employee_Performance_Evaluation__Share();
                peMgrShare.ParentId = pe.Id;
                peMgrShare.UserOrGroupId = pe.Manager__c;
                peMgrShare.AccessLevel = 'Edit';
                peMgrShare.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Manager__c;
                lstSharesToInsert.add(peMgrShare);
            }
            
            // MANAGER OF MANAGER
            if (pe.Manager__r.ManagerId != null)
            {
                NI_Employee_Performance_Evaluation__Share peMgr2Share = new NI_Employee_Performance_Evaluation__Share();
                peMgr2Share.ParentId = pe.Id;
                peMgr2Share.UserOrGroupId = pe.Manager__r.ManagerId;
                peMgr2Share.AccessLevel = 'Read';
                peMgr2Share.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Manager_Hierarchy_Share__c;
                lstSharesToInsert.add(peMgr2Share);
            }
            
            // MANAGER OF THE MANAGER OF THE MANAGER
            if (pe.Manager__r.Manager.ManagerId != null)
            {
                NI_Employee_Performance_Evaluation__Share peMgr3Share = new NI_Employee_Performance_Evaluation__Share();
                peMgr3Share.ParentId = pe.Id;
                peMgr3Share.UserOrGroupId = pe.Manager__r.Manager.ManagerId;
                peMgr3Share.AccessLevel = 'Read';
                peMgr3Share.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Manager_Hierarchy_Share__c;
                lstSharesToInsert.add(peMgr3Share);
            }
            
            // MANAGER OF THE MANAGER OF THE MANAGER OF THE MANAGER
            if (pe.Manager__r.Manager.Manager.ManagerId != null)
            {
                NI_Employee_Performance_Evaluation__Share peMgr4Share = new NI_Employee_Performance_Evaluation__Share();
                peMgr4Share.ParentId = pe.Id;
                peMgr4Share.UserOrGroupId = pe.Manager__r.Manager.Manager.ManagerId;
                peMgr4Share.AccessLevel = 'Read';
                peMgr4Share.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Manager_Hierarchy_Share__c;
                lstSharesToInsert.add(peMgr4Share);
            }            
            
            // COLLABORATING MANAGER 1 SHARE
            if ((pe.Collaborating_Manager__c != pe.OwnerId) && (pe.Collaborating_Manager__c != null))
            {
                NI_Employee_Performance_Evaluation__Share peCoShare = new NI_Employee_Performance_Evaluation__Share();
                peCoShare.ParentId = pe.Id;
                peCoShare.UserOrGroupId = pe.Collaborating_Manager__c;
                peCoShare.AccessLevel = 'Edit';
                peCoShare.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Collaborating_Manager__c;
                lstSharesToInsert.add(peCoShare);
            }
            
            // COLLABORATING MANAGER 2 SHARE
            if ((pe.Collaborating_Manager_2__c != pe.OwnerId) && (pe.Collaborating_Manager_2__c != null))
            {
                NI_Employee_Performance_Evaluation__Share peCoShare = new NI_Employee_Performance_Evaluation__Share();
                peCoShare.ParentId = pe.Id;
                peCoShare.UserOrGroupId = pe.Collaborating_Manager_2__c;
                peCoShare.AccessLevel = 'Edit';
                peCoShare.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Collaborating_Manager__c;
                lstSharesToInsert.add(peCoShare);
            }
            
            // COLLABORATING MANAGER 3 SHARE
            if ((pe.Collaborating_Manager_2__c != pe.OwnerId) && (pe.Collaborating_Manager_3__c != null))
            {
                NI_Employee_Performance_Evaluation__Share peCoShare = new NI_Employee_Performance_Evaluation__Share();
                peCoShare.ParentId = pe.Id;
                peCoShare.UserOrGroupId = pe.Collaborating_Manager_3__c;
                peCoShare.AccessLevel = 'Edit';
                peCoShare.RowCause = Schema.NI_Employee_Performance_Evaluation__Share.RowCause.Collaborating_Manager__c;
                lstSharesToInsert.add(peCoShare);
            }
            
        }

for (NI_Employee_Performance_Evaluation__Share x : lstSharesToInsert)
{
    system.debug(' ***** NI_Employee_Performance_Evaluation__Share = ' + x);
}
        
        // USE DATABASE DML METHOD TO ADD THE SHARES
        if (lstSharesToInsert.size() > 0)
        {
            Database.SaveResult[] results = Database.insert(lstSharesToInsert, true);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
        
    }
    //=========================================================================================================================          
    //THIS METHOD UPDATES THE PERFORMANCE EVALUATION YEAR
    //=========================================================================================================================
    public void Set_PerformanceEvalYear(List<NI_Employee_Performance_Evaluation__c> newTrigger)
    {   
        
        // GET TODAY'S DATE
        Date currDate = Date.today();
        
        for (NI_Employee_Performance_Evaluation__c pe : newTrigger)
        {
            // IF THE CURRENT MONTH IS NOVEMBER OR DECEMBER THEN SET THE PERFOMANCE EVALUATION YEAR TO THE CURRENT YEAR
            if ((currDate.Month() == 11) || (currDate.Month() == 12))
            {
                pe.Performance_Evaluation_Year__c = String.valueOf(currDate.Year());  
            }
            else //OTHERWISE SET THE PERFORMANCE EVALUATION YEAR TO THE PREVIOUS YEAR
            {
                pe.Performance_Evaluation_Year__c = String.valueOf(currDate.Year() - 1);  
            }
        }  
        
    }
    
	//=========================================================================================================================          
    //THIS METHOD UPDATES THE DEPARTMENT CODE AND FINANCE LOCATION FIELDS BASED ON THE USER RECORD
    //=========================================================================================================================
    public void Set_DepCode_LocationFields(List<NI_Employee_Performance_Evaluation__c> newTrigger)
    {   
        
        Set<Id> setEmployeeId = new Set<Id>();
        
        for (NI_Employee_Performance_Evaluation__c perfEval : newTrigger)
        {
            setEmployeeId.add(perfEval.Employee_Name__c);  
        }
        
        Map<Id, User> mapEmployees = new Map<Id, User>([SELECT Id, DepartmentCode__c, NI_Location__c
                                                        FROM User
                                                        WHERE Id IN: setEmployeeId]);
        
        System.debug(' ***** MAPEMPLOYEES: ' + mapEmployees.size());
        
        
        for (NI_Employee_Performance_Evaluation__c pe : newTrigger)
        { 
            if ((mapEmployees.get(pe.Employee_Name__c).DepartmentCode__c != null) && (bUserDepartment(mapEmployees.get(pe.Employee_Name__c).DepartmentCode__c) == true))    
            {
                pe.Department_Code__c = getUserdepartment(mapEmployees.get(pe.Employee_Name__c).DepartmentCode__c).Id;
                System.debug(' ***** PERFORMANCE EVAL DEPARTMENT CODE: ' + getUserdepartment(mapEmployees.get(pe.Employee_Name__c).DepartmentCode__c).Id);
            }
            else
            {
                pe.Department_Code__c = null;  
            }  
            if ((mapEmployees.get(pe.Employee_Name__c).NI_Location__c != null) && (bUserLocation(mapEmployees.get(pe.Employee_Name__c).NI_Location__c) == true))
            {
                pe.NI_Location__c = getUserLocation(mapEmployees.get(pe.Employee_Name__c).NI_Location__c).Id;
                System.debug(' ***** PERFORMANCE EVAL LOCATION: ' + getUserLocation(mapEmployees.get(pe.Employee_Name__c).NI_Location__c).Id);
            }
            else
            {
                pe.NI_Location__c = null;
            }
        }  
    }
    
    public boolean bUserDepartment(String depCode)
    {
        List<NI_Departments__c> lstDepartments = [SELECT Id FROM NI_Departments__c WHERE Name =: depCode];
        if (lstDepartments.size()>0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    
    public static NI_Departments__c getUserdepartment(String depCode) 
    {
        NI_Departments__c d = [SELECT Id, Name FROM NI_Departments__c WHERE Name =: depCode];
        return d;     
    }
    
    public boolean bUserLocation(String location)
    {
        List<NI_Location__c> lstLocations = [SELECT Id FROM NI_Location__c WHERE Name =: location];
        if (lstLocations.size() > 0)
        {
            Return true; 
        }
        else
        {
            Return false;  
        }  
    }
    
    public static NI_Location__c getUserLocation(String location) 
    {
        NI_Location__c l = [SELECT Id, Name FROM NI_Location__c WHERE Name =: location];
        return l;     
    }    
    
}