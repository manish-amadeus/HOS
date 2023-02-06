public with sharing class PsaTxAssignmentResourceLookupController 
{

    public ApexPages.StandardSetController resourceStdSetCntrl { get; set; }
    public String resourceName{get;set;}
    
    public List<Contact> resources
    {
        get
        {
            if(resourceStdSetCntrl != null)
            {
                return (List<Contact>) resourceStdSetCntrl.getRecords();
            }
            else
            {
                return new List<Contact>();
            }      
        }
        set;
    }
    
    public PsaTxAssignmentResourceLookupController()
    {
        resourceName = ApexPages.currentPage().getParameters().get('resourceName');
        try
        {
            loadResources();
        }
        catch(Exception ex)
        {
            System.debug('Error loading resources: ' + ex.getMessage());
        }
    }
        
    public void loadResources()
    {
        String queryString;
        String searchCriteria = ''; 
        if(resourceName != null && resourceName.length() > 0)
        {
            searchCriteria = '%'+resourceName+'%';
            
            queryString = 
            'SELECT Id, Name, pse__Region__r.Name, pse__Practice__r.Name, pse__Resource_Role__c ' +
            'FROM Contact WHERE pse__Is_Resource__c = true AND pse__Is_Resource_Active__c = true ' +
            'AND Name like : searchCriteria ' +
            'ORDER BY Name';
        }
        else
        {
            queryString = 
            'SELECT Id, Name, pse__Region__r.Name, pse__Practice__r.Name, pse__Resource_Role__c ' +
            'FROM Contact WHERE pse__Is_Resource__c = true AND pse__Is_Resource_Active__c = true ' +
            'ORDER BY Name, pse__Region__r.Name, pse__Practice__r.Name';
        }
       
        try
        {
            System.debug('*** QUERY: ' + queryString);
            resourceStdSetCntrl = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
            resourceStdSetCntrl.setPageSize(50);
        }
        catch (Exception e ) 
        {
            System.debug(e.getMessage());
        }
    }
   
    public PageReference go()
    {
        loadResources();
        return null;
    }

}