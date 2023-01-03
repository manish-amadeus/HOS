public with sharing class PsaTxAssignmentProjectLookupController 
{
    public ApexPages.StandardSetController projectStdSetCntrl { get; set; }
    public String projectName{get;set;}
    private List<String> validStages = new List<String> {'Draft at Risk', 'Draft', 'In Progress', 'On Hold'}; 
    
 	public List<pse__Proj__c> projects
  	{
		get
		{
    		if(projectStdSetCntrl != null)
    		{
      			return (List<pse__Proj__c>) projectStdSetCntrl.getRecords();
			}
			else
			{
				return new List<pse__Proj__c>();
    		}      
  		}
  		set;
  	}
  	
    public PsaTxAssignmentProjectLookupController()
    {
    	projectName = ApexPages.currentPage().getParameters().get('projectName');
		try
		{
			loadProjects();
        }
        catch(Exception ex)
        {
            System.debug('Error loading projects: ' + ex.getMessage());
        }
    }
       	
   	public void loadProjects()
   	{
   		String queryString;
        String searchCriteria = ''; 
       	if(projectName != null && projectName.length() > 0)
       	{
        	searchCriteria = '%'+projectName+'%';
        	
         	queryString = 
         	'SELECT Id, Name, pse__Region__r.Name, pse__Practice__r.Name, pse__Account__r.Name, Account_Number__c, ' +
         	' pse__Opportunity__r.Name, Opportunity_Number__c, pse__Stage__c ' +
         	'FROM pse__Proj__c WHERE pse__Is_Active__c = true AND pse__Is_Billable__c = true AND pse__Is_Template__c = false ' +
         	'AND pse__Stage__c in :validStages ' + 
         	'AND Name like : searchCriteria ' +
         	'ORDER BY pse__Region__r.Name, Name';
       	}
       	else
       	{
       		queryString = 
         	'SELECT Id, Name, pse__Region__r.Name, pse__Practice__r.Name, pse__Account__r.Name, Account_Number__c, ' +
         	' pse__Opportunity__r.Name, Opportunity_Number__c, pse__Stage__c ' +
         	'FROM pse__Proj__c WHERE pse__Is_Active__c = true AND pse__Is_Billable__c = true AND pse__Is_Template__c = false ' +
         	'AND pse__Stage__c in :validStages ' + 
         	'ORDER BY pse__Region__r.Name, Name';
        	
        	System.debug('*** QUERY: ' + queryString);
       	}
       
       	try
       	{
          	projectStdSetCntrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
          	projectStdSetCntrl.setPageSize(50);
        }
        catch (Exception e ) 
        {
        	System.debug(e.getMessage());
       	}
   	}
   
   	public PageReference go()
   	{
      	loadProjects();
      	return null;
   	}

}