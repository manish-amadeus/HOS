public class SolutionSearch 
{
    
    public String sql {get; set;}  
    public String solId {get; set;}  
    public Solution sol { get; set; }
    public ApexPages.standardcontroller Controller {get; set;}
    public Case c;
    public String strStatus {get; set;} 
    public String strCaseNumber {get; set;} 
    public String strCaseId {get; set;} 
    public Integer drillDownCount {get; set;} 
    public Boolean bGoBack {get; set;} 
    public Boolean showStatusFilter {get; set;} 
    public Boolean isDisabled {get; set;}
    
    String strDesc = '';
    String strReso = '';

    public SolutionSearch(ApexPages.StandardController controller) 
    {
        
        showStatusFilter = false;
        
        List<Profile> lstProfiles = [SELECT Id, Name FROM Profile WHERE Id =: userinfo.getProfileId() LIMIT 1];
		String pn = lstProfiles[0].Name;
        
        if ((pn == 'System Administrator') || (pn == 'AH Support Managers - Lightning'))
        {
            showStatusFilter = true;
        }
        
        if (ApexPages.CurrentPage().getParameters().containsKey('caseid'))
        { 
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, CaseNumber FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseId = c.Id;
                strCaseNumber = c.CaseNumber;                  
            }
        }
    }

    public List<SelectOption> getStatuses() 
    {
        
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fr = Solution.Status.getDescribe();        
        List<Schema.PicklistEntry> ple = fr.getPicklistValues();
        
        options.add(new SelectOption('Default', 'Default'));
        options.add(new SelectOption('All', 'All'));
        
        for(Schema.PicklistEntry f : ple)            
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }         
        return options;        
        
    } 

    public String getStatus() 
    {
        return strStatus;
    }

    public void setStatus(String s) 
    {
        this.strStatus = s;
    }

    public PageReference doSearch() 
    {
        
        isDisabled = true;
        
        if (drillDownCount == null)
        {
            bGoBack = false;
            drillDownCount = 0;
        }

        try
        {

            if ((sql == null) || (sql == ''))
            {

                if (!showStatusFilter)
                {
                    sql = 'SELECT Id, SolutionNumber, SolutionName, TimesUsed, Status FROM Solution WHERE (Status != \'Archived\') AND (Status != \'Duplicate\') AND (Status != \'Inactive\') AND '; 
                }
                else
                {
                    if (strStatus == 'Default')
                    {
                        sql = 'SELECT Id, SolutionNumber, SolutionName, TimesUsed, Status FROM Solution WHERE (Status != \'Archived\') AND (Status != \'Duplicate\') AND (Status != \'Inactive\') AND '; 
                    }
                    else
                    {
                        if (strStatus == 'All')
                        {
                            sql = 'SELECT Id, SolutionNumber, SolutionName, TimesUsed, Status FROM Solution WHERE (Status != \'xzxzxzxzxzxzxzxzxzxzx\') AND ';                    
                        }
                        else
                        {
                            sql = 'SELECT Id, SolutionNumber, SolutionName, TimesUsed, Status FROM Solution WHERE (Status = \'' + String.escapeSingleQuotes(strStatus) + '\') AND '; 
                        }                                                   
                    }                    
                }

                if (searchText.Substring(0, 1) == '!')
                {
                    sql += '(NOT SolutionName ';
                }
                else
                {
                    sql += '(SolutionName ';
                }

            }
            else
            {

                if (searchText.Substring(0, 1) == '!')
                {
                    sql += ' AND (NOT SolutionName ';
                }
                else
                {
                    sql += ' AND (SolutionName ';
                }

            }

            sql += 'LIKE \'%' + String.escapeSingleQuotes(searchText.Replace('!', '')) + '%\'';
            sql += ')';

            System.debug(sql);    
            List<sObject> L = Database.query(sql + ' LIMIT 500');
            results = L;    
            searchText = '';
            drillDownCount += 1;
            
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        
        return null; 
        
    }
    
    public PageReference goBack() 
    {
        
        bGoBack = true;
        
        try
        {

            if ((sql != null) && (sql != ''))
            {
                
                if (sql.contains(' AND '))
                {
                    if (drillDownCount > 0)
                    {
                        drillDownCount -= 1;
                    }                
                
                    if (bGoBack && (drillDownCount == 0))
                    {
                        sql = 'SELECT Id, SolutionNumber, SolutionName, TimesUsed, Status FROM Solution WHERE SolutionName = \'JAHDGETXNJDUIWEHD\'';
                        List<sObject> L = Database.query(sql);
                        results = L;    
                        searchText = null;
                        sql = null; 
                        isDisabled = false;
                    }
                    else
                    {
                        sql = sql.Substring(0, sql.LastIndexOf(' AND '));
                        List<sObject> L = Database.query(sql);
                        results = L;    
                        searchText = '';  
                        isDisabled = true;
                    }

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

//    public void invokeQueries()
//    {
//        RetrieveDesc();
//        RetrieveReso(); 
//    }
    
    public PageReference RetrieveDesc() 
    {
        Id id = System.currentPageReference().getParameters().get('id');
        try
        {
            strDesc = [SELECT Description__c FROM Solution WHERE Id=: id].Description__c;
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        return null;
    }

    public PageReference RetrieveReso() 
    {
        Id id = System.currentPageReference().getParameters().get('id');
        try
        {
            strReso = [SELECT SolutionNote FROM Solution WHERE Id=:id].SolutionNote;
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        return null;
    }

    public List<Solution> getSolutions()     
    {          
       return [SELECT Id, SolutionNumber, SolutionName, TimesUsed FROM Solution ORDER BY SolutionName ASC LIMIT 200];      
    } 
   
    public List<Solution> results 
    {
        get 
        {
            if (results == null) 
            {
                results = new List<Solution>();
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
    
        bGoBack = false;
        searchText = null;
        sql = null;
		isDisabled = false;
        
        try
        {
            List<sObject> L = Database.query('SELECT Id, SolutionNumber, SolutionName, TimesUsed, Status FROM Solution WHERE SolutionName = \'JAHDGETXNJDUIWEHD\'');
            results = L;    
            drillDownCount = 0;
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No records found'));
        }
        
        return null; 
        
    }

    public PageReference selectSol() 
    {

        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SolutionDetails?id=' + solId + '&caseid=' + strCaseId;
        PageReference solPage = new PageReference(strUrl);
        
        solPage.setRedirect(true);
        return solPage;        
        
    }
    
}