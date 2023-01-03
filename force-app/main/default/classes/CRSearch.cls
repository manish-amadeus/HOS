public class CRSearch 
{

    public Case c;
    public String sql {get;set;}  
    public String CRId {get;set;}  
    public String strCaseNumber {get;set;} 
    public String strCaseId {get;set;} 
    public SFDC_CSP_Development_Request__c CR { get; set; }
    public ApexPages.standardcontroller Controller {get;set;}
    public Integer drillDownCount {get;set;} 
    public Boolean bGoBack {get;set;} 
    public Boolean showAttachCaseButton {get; set;} 
    String strDesc = '';
    String strReso = '';

    public CRSearch(ApexPages.StandardController controller) 
    {
        this.CR = (SFDC_CSP_Development_Request__c)controller.getRecord(); 
        showAttachCaseButton = false;
        if (ApexPages.CurrentPage().getParameters().containsKey('caseid')) 
        {            
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, CaseNumber FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseId = c.Id;
                strCaseNumber = c.CaseNumber;  
                showAttachCaseButton = true;
            }
        }
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
 
            List<sObject> L = Database.query(sql + ' LIMIT 500');
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
        // ADDED "LIMIT 1000" THIS TO FIX THIS ERROR:
        // System.LimitException: Too many query rows: 50001 
        // Stack Trace: Class.CRSearch.getCRs: line 126, column 1 Class.CRSearchTestClass.myUnitTest: line 80, column 1
        return [SELECT Id, Name, Title__c FROM SFDC_CSP_Development_Request__c ORDER BY Title__c ASC LIMIT 1000];      
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

        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/CRDetails?id=' + CRId + '&caseid=' + strCaseId;
        //string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + CRId;
        PageReference solPage = new PageReference(strUrl);
        
        solPage.setRedirect(true);
        return solPage;        
        
    }
    

}