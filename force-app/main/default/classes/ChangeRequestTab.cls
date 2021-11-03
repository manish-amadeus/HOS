public with sharing class ChangeRequestTab 
{

    public String sql {get;set;}  
    public String CRId {get;set;}  
    public SFDC_CSP_Development_Request__c CR { get; set; }
    public ApexPages.standardcontroller Controller {get;set;}
    public Integer drillDownCount {get;set;} 
    public Boolean bGoBack {get;set;} 
    
    String strDesc = '';
    String strReso = '';
    
    public ChangeRequestTab() {

    }
    
    public ChangeRequestTab(ApexPages.StandardController controller) 
    {

    }
    
    public PageReference doSearch() 
    {
        
        try
        {

            if ((sql == null) || (sql == ''))
            {

                sql = 'SELECT Id, Name, Title__c FROM SFDC_CSP_Development_Request__c WHERE ';

                if (searchText.Substring(0, 1) == '!')
                {
                    sql += '(NOT Title__c ';
                }
                else
                {
                    sql += '(Title__c ';
                }

            }
            else
            {

                if (searchText.Substring(0, 1) == '!')
                {
                    sql += ' AND (NOT Title__c ';
                }
                else
                {
                    sql += ' AND (Title__c ';
                }

            }

            sql += 'LIKE \'%' + String.escapeSingleQuotes(searchText.Replace('!', '')) + '%\'';
            sql += ')';
 
            List<sObject> L = Database.query(sql);
            results = L;    
            searchText = '';
       
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        
        return null; 
        
    }
    
    public PageReference goBack() 
    {

        try
        {

            if ((sql != null) && (sql != ''))
            {
                
                if (sql.contains(' AND '))
                {
                    sql = sql.Substring(0, sql.LastIndexOf(' AND ')); 
                    List<sObject> L = Database.query(sql);
                    results = L;    
                    searchText = '';                    
                }
                
            }    
       
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        
        return null; 
        
    }

    public String getDescText() 
    {
        return strDesc ;
    }

    public String getResoText() 
    {
        return strReso ;
    }
    
    public PageReference RetrieveDesc() 
    {
        try
        {
            Id id = System.currentPageReference().getParameters().get('id');
            strDesc = [SELECT Description__c FROM SFDC_CSP_Development_Request__c WHERE Id=: id].Description__c;
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        return null;
    }

    public List<SFDC_CSP_Development_Request__c> getCRs()     
    {          
       return [SELECT Id, Name, Title__c FROM SFDC_CSP_Development_Request__c ORDER BY Title__c ASC];      
    } 
   
    public List<SFDC_CSP_Development_Request__c> results 
    {
        get 
        {
            if (results == null) 
            {
                results = new List<SFDC_CSP_Development_Request__c>();
            }    
            return results;
        }
        set;    
    }   
   
    public String searchText 
    {
        get;
        set 
        {
            searchText = value;
        }
    }

    public String newSearch()
    {
    
        searchText = null;
        sql = null;

        List<sObject> L = Database.query('SELECT Id, Name, Title__c FROM SFDC_CSP_Development_Request__c WHERE Title__c = \'JAHDGETXNJDUIWEHD\'');
        results = L;    
        
        return null; 
        
    }

    public PageReference selectCRId() 
    {

        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + CRId;
        PageReference solPage = new PageReference(strUrl);
        
        solPage.setRedirect(true);
        return solPage;        
        
    }

}