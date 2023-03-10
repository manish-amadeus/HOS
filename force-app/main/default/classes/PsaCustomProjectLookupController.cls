public with sharing class PsaCustomProjectLookupController 
{    
    
    public ApexPages.StandardSetController milestoneStdSetCntrl {get; set;}
    public String projectName {get; set;}
    
    public List<pse__Milestone__c> milestones
    {
        get
        {
            if (milestoneStdSetCntrl != null)
            {
                return (List<pse__Milestone__c>) milestoneStdSetCntrl.getRecords();
            }
            else
            {
                return new List<pse__Milestone__c>();
            }      
        }
        set;
    }
    
    public PsaCustomProjectLookupController()
    {
        projectName = ApexPages.currentPage().getParameters().get('projectName');
        try
        {
            loadProjectsAndMilestones();
        }
        catch (Exception ex) {}
    }
    
    public void loadProjectsAndMilestones()
    {  
        List<pse__Milestone__c> lstMilestones = new List<pse__Milestone__c>();
        
        // MAP TO REFERENCE THE TT_Tasks_Milestone_Types__c CUSTOM SETTING  
        Map<String, NI_TT_Tasks_Milestone_Types__c> milestoneTypes = NI_TT_Tasks_Milestone_Types__c.getAll();
        
        // LIST TO HOLD THE MILESTONE TYPES USED IN THE TT TASK ASSIGNMENT  
        List<String> lstMilestoneTypes = new List<String>();
        lstMilestoneTypes.addAll(milestoneTypes.keySet());
        String queryString;
        String searchCriteria = ''; 

        if (projectName != null && projectName.length() > 0)
        {
            searchCriteria = '%' + projectName + '%';
            if (Test.IsRunningTest())
            { 
                queryString = 'SELECT Id, Name, pse__Project__r.Id, pse__Project__r.Name, Milestone_Type__c, pse__Target_Date__c, Managed_Property__r.Name, pse__Override_Project_Practice__r.Name ' +
                    'FROM pse__Milestone__c WHERE pse__Project__r.pse__Allow_Self_Staffing__c = true ' +
                    'AND pse__Project__r.pse__Closed_For_Time_Entry__c = false ' +
                    'AND pse__Closed_For_Time_Entry__c = false ' +
                    'AND Milestone_Type__c IN :lstMilestoneTypes ' + 
                    'AND pse__Project__r.Name like : searchCriteria ' +
                    'ORDER BY pse__Project__r.Name, Name LIMIT 100';
            }
            else
            {
                queryString = 'SELECT Id, Name, pse__Project__r.Id, pse__Project__r.Name, Milestone_Type__c, pse__Target_Date__c, Managed_Property__r.Name, pse__Override_Project_Practice__r.Name ' +
                    'FROM pse__Milestone__c WHERE pse__Project__r.pse__Allow_Self_Staffing__c = true ' +
                    'AND pse__Project__r.pse__Closed_For_Time_Entry__c = false ' +
                    'AND pse__Closed_For_Time_Entry__c = false ' + 
                    'AND Milestone_Type__c IN :lstMilestoneTypes ' + 
                    'AND pse__Project__r.Name like : searchCriteria ' +
                    'ORDER BY pse__Project__r.Name, Name';
            }
        } 
        else
        {
            if (Test.IsRunningTest())
            {
                queryString = 'SELECT Id, Name, pse__Project__r.Id, pse__Project__r.Name, Milestone_Type__c, pse__Target_Date__c, Managed_Property__r.Name, pse__Override_Project_Practice__r.Name ' +
                    'FROM pse__Milestone__c WHERE pse__Project__r.pse__Allow_Self_Staffing__c = true ' +
                    'AND pse__Project__r.pse__Closed_For_Time_Entry__c = false ' +
                    'AND pse__Closed_For_Time_Entry__c = false ' +   
                    'AND Milestone_Type__c IN :lstMilestoneTypes ' +    
                    'ORDER BY pse__Project__r.Name, Name LIMIT 100 ';
            }
            else
            {
                queryString = 'SELECT Id, Name, pse__Project__r.Id, pse__Project__r.Name, Milestone_Type__c, pse__Target_Date__c, Managed_Property__r.Name, pse__Override_Project_Practice__r.Name ' +
                    'FROM pse__Milestone__c WHERE pse__Project__r.pse__Allow_Self_Staffing__c = true ' +
                    'AND pse__Project__r.pse__Closed_For_Time_Entry__c = false ' +
                    'AND pse__Closed_For_Time_Entry__c = false ' +   
                    'AND Milestone_Type__c IN :lstMilestoneTypes ' + //ADDED PER SALESFORCE.COM CHANGE REQUEST: NICC-006354
                    'ORDER BY pse__Project__r.Name, Name LIMIT 100';              
            }
        } 
        
        try
        {
            milestoneStdSetCntrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
            milestoneStdSetCntrl.setPageSize(20);
        }
        catch (Exception e) {}
    }
    
    public PageReference go()
    {
        loadProjectsAndMilestones();
        return null;
    }
    
}