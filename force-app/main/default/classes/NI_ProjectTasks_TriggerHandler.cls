/************************************************************************************************
Name            : NI_ProjectTasks_TriggerHandler Class
Author          : Prashant Wayal
Created Date    : 12/04/2015
Last Mod Date   : 12/22/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-016293
Description     : Handles the logic for the NI Project Backlog Task Triggers
                :
                :
*************************************************************************************************/
public class NI_ProjectTasks_TriggerHandler
{

    private boolean isExecuting = false;
   
    public NI_ProjectTasks_TriggerHandler(boolean isExecuting)
    {
        isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return isExecuting;}
    }

    public void OnBeforeInsert(List<NI_Project_Backlog_Tasks__c> newTrigger)
    {

    }
   
    public void OnBeforeUpdate(List<NI_Project_Backlog_Tasks__c> newTrigger)
    {
    }

    public void OnBeforeDelete(List<NI_Project_Backlog_Tasks__c> newTrigger)
    {
       
    }
   
    public void OnAfterInsert(List<NI_Project_Backlog_Tasks__c> newTrigger)
    { 
        Set<Id> setProjectIds = new Set<Id>(); 
        for (NI_Project_Backlog_Tasks__c s : newTrigger)
        {
            System.debug('*** task Parent *** '+s.NI_Project_Backlog_Item__c);
            setProjectIds.Add(s.NI_Project_Backlog_Item__c); 
        } 
        //Invoke method to rollup the project backlogs
        invokeProjectBacklogRollup(setProjectIds);      
    }
   
    public void OnAfterUpdate(List<NI_Project_Backlog_Tasks__c> newTrigger, Map<Id, NI_Project_Backlog_Tasks__c> oldMapTrigger)
    {      
        Set<Id> setProjectIds = new Set<Id>(); 
        for (NI_Project_Backlog_Tasks__c s : newTrigger)
        {
            System.debug('*** task Parent *** '+s.NI_Project_Backlog_Item__c);
            setProjectIds.Add(s.NI_Project_Backlog_Item__c); 
        } 
        //Invoke method to rollup the project backlogs
        invokeProjectBacklogRollup(setProjectIds);     
    }
       
    public void OnAfterDelete(List<NI_Project_Backlog_Tasks__c> newTrigger)
    {
             
        Set<Id> setProjectIds = new Set<Id>(); 
        for (NI_Project_Backlog_Tasks__c s : newTrigger)
        {
            System.debug('*** task Parent *** '+s.NI_Project_Backlog_Item__c);
            setProjectIds.Add(s.NI_Project_Backlog_Item__c); 
        } 
        //Invoke method to rollup the project backlogs
        invokeProjectBacklogRollup(setProjectIds);
    }
   
    public void OnAfterUnDelete(List<NI_Project_Backlog_Tasks__c> newTrigger)
    {
      
    }   
    
    
    // =================================================================================================
    //  FUNCTIONS
    // =================================================================================================
    @future
    public static void invokeProjectBacklogRollup(Set<Id> setProjectIds)
    {   
        
        Set<Id> setMasterProjectId = new Set<Id>(); 

        for (NI_Project_Backlog__c  ap : [SELECT Id, Master_Project__c, Master_Project__r.Name FROM NI_Project_Backlog__c WHERE Id IN : setProjectIds])
        {
            System.debug('*** task parent master *** '+ap.Master_Project__r.Name);
            if(ap.Master_Project__c != null){
                setMasterProjectId.Add(ap.Master_Project__c); 
            }
            else{
                setMasterProjectId.Add(ap.Id);
            }
        } 
        
        List<NI_Project_Backlog__c> lstProjects = new List<NI_Project_Backlog__c>();
        
        for (NI_Project_Backlog__c aps : [SELECT Id, Invoke_Rollups__c FROM NI_Project_Backlog__c WHERE Id IN : setMasterProjectId])
        {
            aps.Invoke_Rollups__c = true;
            lstProjects.Add(aps);
        }
        
        Database.Update(lstProjects);        
       
    }
    
}