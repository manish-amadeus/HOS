/****************************************************************************************
Name            : AH_SolutionSearch_Ctlr
Author          : Sean Harris
Created Date    : 04/10/2019
Last Mod Date   : 04/10/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034157
Description     : Controller for the AH_SolutionSearch Visualforce page.
                :            
******************************************************************************************/
public class AH_SolutionSearch_Ctlr 
{

    // LIMIT CONSTANTS ======================================= 
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 200;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 200;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstSolutionStatuses {get; set;} 
    public List<SelectOption> lstBusinessDomains {get; set;} 
	public Map<Integer, String> mapSearchHistory {get; set;} 
    
    // STRINGS
    public String solId {get; set;}  
    public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;}  
    public String selSolutionStatus {get; set;}
    public String selBusinessDomain {get; set;}
    public String queryBuilderFINAL {get; set;}
    public String queryBuilderWHERE {get; set;}
    public String strCaseId {get; set;}  
    
    // NUMERICS
    public Integer iRecCount {get; set;}
    
    // BOOLEANS
    public Boolean isSystemsEngineering {get; set;}
    public Boolean disableOptions {get; set;}
    
    // PRIVATE VARIABLES ====================================
    private User runningUser;
	private Boolean isSpecialUser;     
    private String queryBuilderSELECT;
    private String queryBuilderORDER;
    private Integer drillDownCount;
    private Case c;
    private String strCaseNumber {get; set;} 
    
    
    public AH_SolutionSearch_Ctlr()
    {
        
        system.debug(' *** ENTERING AH_SolutionSearch_Ctlr() - CONSTRUCTOR');        
        
        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();

        if (ApexPages.CurrentPage().getParameters().containsKey('caseid'))
        { 
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, CaseNumber, Number_of_Solutions__c FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseId = c.Id;
                strCaseNumber = c.CaseNumber;  
            }
        }        
        
        system.debug(' *** EXITING AH_SolutionSearch_Ctlr() - CONSTRUCTOR');        
        
    }
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================

    private void initVariables()
    {

        // QUERY BUILDING VARIABLES
        queryBuilderSELECT = '';
        queryBuilderWHERE = '';
        queryBuilderORDER = '';
        searchText = ''; 
        sortByField = 'SolutionName';
        sortByDirection = 'ASC';        
        // COLLECTIONS
        mapSearchHistory = new Map<Integer, String>();
        lstSearchResults = new List<searchResult>();        
		disableOptions = false;
        isSystemsEngineering = false;
        iRecCount = 0;  
        drillDownCount = 0;
        searchResultMsg = '0 records found';  
        //isSpecialUser = false;
        isSpecialUser = true;
        strCaseId = '';
        strCaseNumber = ''; 
        
        runningUser = [SELECT Id, ProfileId, IsActive, UserType, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];  
        
        
/*
        for (Profile p : [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'NI Support Managers', 'AH Support Managers - Lightning', 'AH Business Systems')])
        {
            if (runningUser.ProfileId == p.Id)
            {
                isSpecialUser = true;
            }
        }
*/
        
    }

    private String soqlBuilder()
    {
        
        String strQuery = '';
        
        // BUILD SELECT PART ON FIRST SEARCH ONLY
        if (drillDownCount == 0)
        {

            // BUILD DYNAMIC SOQL QUERY SEARCH STRING 
            queryBuilderSELECT = 'SELECT ';
            queryBuilderSELECT += 'Id, '; 
            queryBuilderSELECT += 'Business_Domain__c, '; 
            queryBuilderSELECT += 'SolutionNumber, '; 
            queryBuilderSELECT += 'SolutionName, ';
            queryBuilderSELECT += 'TimesUsed, '; 
            queryBuilderSELECT += 'Status '; 
            queryBuilderSELECT += 'FROM Solution ';
            queryBuilderSELECT += 'WHERE Id != null ';
            
            // STATUS FILTER
            if (selSolutionStatus != 'All')
            {
                if (selSolutionStatus == 'Default')
                {
                    queryBuilderSELECT += 'AND Status NOT IN (\'Archived\', \'Duplicate\', \'Inactive\') '; 
                }
                else
                {
                    queryBuilderSELECT += 'AND Status = \'' + String.escapeSingleQuotes(selSolutionStatus) + '\' ';
                }
            }
            
            // BUSINESS DOMAIN FILTER
            if (selBusinessDomain != 'All')
            {
                queryBuilderSELECT += 'AND Business_Domain__c = \'' + String.escapeSingleQuotes(selBusinessDomain) + '\' ';
            }
            
            // SYSTEMS ENGINEERING FILTER
            if (isSystemsEngineering)
            {
                queryBuilderSELECT += 'AND Solution_Category__c = \'Systems Engineering\' ';
            }
            
        }
        
        // USER KEYWORD SEARCH
        if (searchText != '')
        {
            // INCREMENT DRILLDOWN COUNTER
            drillDownCount++; 
            disableOptions = false;
            if (drillDownCount > 0)
            {
                disableOptions = true;
            }
            // SOQL INJECTION PROTECTION
            String strKeyWord = string.escapeSingleQuotes(searchText);               
			String strTempWHERE = 'AND SolutionName LIKE \'%' + strKeyWord + '%\' ';
            // CHANGE IF "NOT" LIKE SPECIFIED
            if (strKeyWord.startsWith('!'))
            { 
                strTempWHERE = 'AND (NOT SolutionName LIKE \'%' + strKeyWord.replace('!', '') + '%\') ';
            }	
			// ADD CRITERIA TO SEARCH HISTORY
			mapSearchHistory.put(drillDownCount, strTempWHERE);
        }
       
        queryBuilderWHERE = '';
        
        for (Integer i = 1; (i <= drillDownCount); i++)
        {
            queryBuilderWHERE += mapSearchHistory.get(i);
        }
       
        // ORDER BY 
        queryBuilderORDER = 'ORDER BY ' + sortByField + ' ' + sortByDirection + ' ';
        queryBuilderORDER += 'LIMIT ' + String.valueOf(PRIVATE_SOQL_LIMIT_CONST) + ' ';    
        
        strQuery = (queryBuilderSELECT + queryBuilderWHERE + queryBuilderORDER);
        
        return strQuery;
        
    }
    
    private void execSearch(String q)
    {

        // FILL A LIST OF WRAPPER CLASSES TO DISPLAY RECORDS TO USER
        try 
        {        
            
            lstSearchResults = new List<searchResult>();
            List<Solution> lstResults = Database.query(q);
            Integer iCounter = 0;
            iRecCount = 0;
            
            if (!lstResults.isEmpty())
            {
                for (Solution rs : lstResults)
                {   
                    searchResult x = new searchResult(                    
                        rs.Id, 
                        rs.SolutionNumber, 
                        rs.SolutionName.replace(rs.SolutionNumber + ' - ', ''), 
                        rs.Status, 
                        rs.Business_Domain__c, 
                        rs.TimesUsed, 
                        false); 
                    iCounter += 1;
                    if (iCounter <= PRIVATE_RESULT_MAX_CONST)
                    {
                        lstSearchResults.add(x);
                    }
                    iRecCount++;
                }
                
                searchResultMsg = String.valueOf(iRecCount) + ' records found';
                
                if (iRecCount == 1)
                {
                    searchResultMsg = '1 record found';
                }
                
                if (iRecCount >= PRIVATE_RESULT_MAX_CONST)
                {
                    searchResultMsg = 'Displaying ' + String.valueOf(PRIVATE_RESULT_MAX_CONST) + ' of ' + String.valueOf(iRecCount) + ' records only';
                }
                
            }
            
        }
        catch (Exception ex)
        {
            lstSearchResults.clear();
            searchResultMsg = 'An error occurred while performing search. Please try again and report to Business Systems if error persists.'; 
            String strDetails = 'Error occurred in execSearch() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
            NI_Error_Logger.WriteToLog(strDetails, 'SolutionSearch', 'AH_SolutionSearch_Ctlr', 'Select'); 
        } 
        
    }

	private void fillPicklists()
    {
 
        // FILL SOLUTION STATUSES 
        lstSolutionStatuses = new List<SelectOption>();
        selSolutionStatus = 'Default';
        Schema.DescribeFieldResult fr1 = Solution.Status.getDescribe();        
        List<Schema.PicklistEntry> ple1 = fr1.getPicklistValues();
        
        lstSolutionStatuses.add(new SelectOption('Default', 'Default'));
        
        if (isSpecialUser)
        {
            lstSolutionStatuses.add(new SelectOption('All', 'All'));
            
            for (Schema.PicklistEntry f1 : ple1)            
            {
                lstSolutionStatuses.add(new SelectOption(f1.getLabel(), f1.getValue()));
            }                  
        }
  
        // FILL BUSINESS DOMAINS
    	lstBusinessDomains = new List<SelectOption>();
        selBusinessDomain = runningUserBusinessDomain();
        Schema.DescribeFieldResult fr2 = Solution.Business_Domain__c.getDescribe();        
        List<Schema.PicklistEntry> ple2 = fr2.getPicklistValues();
        
        lstBusinessDomains.add(new SelectOption('All', 'All'));
        
        for (Schema.PicklistEntry f2 : ple2)            
        {
            lstBusinessDomains.add(new SelectOption(f2.getLabel(), f2.getValue()));
        }         

    }
    
    public void doSearch() 
    {
        //if (searchText != '')
       // {
            queryBuilderFINAL = soqlBuilder();
            system.debug('QUERY = ' + queryBuilderFINAL);
            execSearch(queryBuilderFINAL);
            searchText = '';             
        //}
    }

    public void goBack() 
    {
        if (drillDownCount > 0)
        {
            drillDownCount--;            
            queryBuilderFINAL = soqlBuilder();
            system.debug('QUERY = ' + queryBuilderFINAL);
            execSearch(queryBuilderFINAL);
            searchText = ''; 
        }
    }    

    public void newSearch() 
    {
        initVariables();
    }

    public void doSort() 
    {
        if (sortByDirection == 'ASC')
        {
            sortByDirection = 'DESC';
        }
        else
        {
            sortByDirection = 'ASC';
        }
        doSearch();
    }
    
    public void toggleSystemEngineering()
    {
        if (isSystemsEngineering)
        {
            isSystemsEngineering = false;
        }
        else 
        {
			isSystemsEngineering = true;       
        }
    } 
    
    public PageReference selectSol() 
    {
        string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/AH_SolutionDetails?id=' + solId;
        if (strCaseId != '')
        {
            strUrl += '&caseid=' + strCaseId; 
        }
        PageReference pr = new PageReference(strUrl); 
        pr.setRedirect(true); 
        return pr; 
    } 
    
    private String runningUserBusinessDomain()
    {
        
        String strBD = 'All';
        
        Map<String, String> mapBDs = new Map<String, String>();
        mapBDs.put('Sales & Catering', 'S&C');
        mapBDs.put('Service Optimization', 'SO');
        mapBDs.put('CRS', 'CRS');
        mapBDs.put('PMS', 'PMS');
        
        for (Support_Tier_Designation__c std : [SELECT Id, Business_Domain__c 
                                                FROM Support_Tier_Designation__c 
                                                WHERE Inactive__c = false 
                                                AND Support_Rep__c =: runningUser.Id
                                                LIMIT 1])
        {         
            if (mapBDs.containsKey(std.Business_Domain__c))
            {
                strBD = mapBDs.get(std.Business_Domain__c);                
            }            
        }
        
        return strBD;
        
    }
    
    // ================================================================================================================================
	//  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class searchResult
    {    

        public Id SolutionId {get; set;}
        public String SolutionNumber {get; set;}
        public String SolutionName {get; set;}
        public String SolutionStatus {get; set;}
        public String BusinessDomain {get; set;}
        public Integer CasesLinked {get; set;}
        public Boolean isChecked {get; set;}

        public searchResult (Id p1, String p2, String p3, String p4, String p5, Integer p6, Boolean isChecked)
        {
            this.SolutionId = p1; 
            this.SolutionNumber = p2; 
            this.SolutionName = p3; 
            this.SolutionStatus = p4; 
            this.BusinessDomain = p5; 
            this.CasesLinked = p6;  
            this.isChecked = isChecked;
        }
        
    }    
    
}