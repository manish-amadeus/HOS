/*************************************************************************************************
Name            : AH_CRSearch_Ctlr Class
Author          : Sean Harris
Created Date    : 09/21/2021
Last Mod Date   : 09/21/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for AH_CRSearch VF Page
                : 
                : 
*************************************************************************************************/
public class AH_CRSearch_Ctlr 
{
 
    // LIMIT CONSTANTS ======================================= 
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 200;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 200;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstPublicStatuses {get; set;} 
	public Map<Integer, String> mapSearchHistory {get; set;} 
    
    // STRINGS
    public String strCRId {get; set;}  
    public String strCRNumber {get; set;}  
    public String strCRTitle {get; set;}  
    public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;}  
    public String selPublicStatus {get; set;}
    public String queryBuilderFINAL {get; set;}
    public String queryBuilderWHERE {get; set;}
    public String strCaseId {get; set;}  
    public String toastMsg {get; set;} 
    public String strAttachDetails {get; set;} 
    public String strCaseNumber {get; set;} 
//    public String strCaseSubject {get; set;} 
    
    // NUMERICS
    public Integer iRecCount {get; set;}
    
    // BOOLEANS
    public Boolean disableOptions {get; set;}
    public Boolean displayConfirm {get; set;}   
    public Boolean isSuccess {get; set;}   
    
    // PRIVATE VARIABLES ====================================
    private User runningUser;
	private Boolean isSpecialUser;     
    private String queryBuilderSELECT;
    private String queryBuilderORDER;
    private Integer drillDownCount;
    private Case c;

    
    public AH_CRSearch_Ctlr()
    {

        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();

        if (ApexPages.CurrentPage().getParameters().containsKey('caseid'))
        { 
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, CaseNumber, Number_of_Solutions__c, Subject FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseId = c.Id;
                strCaseNumber = c.CaseNumber;  
            }
        }        

    }
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================

    private void initVariables()
    {

        queryBuilderSELECT = '';
        queryBuilderWHERE = '';
        queryBuilderORDER = '';
        searchText = ''; 
        sortByField = 'Title__c';
        sortByDirection = 'ASC';        
        mapSearchHistory = new Map<Integer, String>();
        lstSearchResults = new List<searchResult>();        
		disableOptions = false;
        isSuccess = false;
        iRecCount = 0;  
        drillDownCount = 0;
        searchResultMsg = '0 records found';  
		displayConfirm = false;
        runningUser = [SELECT Id, ProfileId, IsActive, UserType, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];  
   
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
            queryBuilderSELECT += 'Name, '; 
            queryBuilderSELECT += 'Title__c, '; 
            queryBuilderSELECT += 'Public_Status__c, '; 
            queryBuilderSELECT += 'Public_Status_Description__c ';
            queryBuilderSELECT += 'FROM SFDC_CSP_Development_Request__c ';
            queryBuilderSELECT += 'WHERE Id != null ';
       
            // STATUS FILTER
            if (selPublicStatus != 'All')
            {
                queryBuilderSELECT += 'AND Public_Status__c = \'' + String.escapeSingleQuotes(selPublicStatus) + '\' ';
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
			String strTempWHERE = 'AND Title__c LIKE \'%' + strKeyWord + '%\' ';
            
            // CHANGE IF "NOT" LIKE SPECIFIED
            if (strKeyWord.startsWith('!'))
            { 
                strTempWHERE = 'AND (NOT Title__c LIKE \'%' + strKeyWord.replace('!', '') + '%\') ';
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
            List<SFDC_CSP_Development_Request__c> lstResults = Database.query(q);
            Integer iCounter = 0;
            iRecCount = 0;
            
            if (!lstResults.isEmpty())
            {
                
                for (SFDC_CSP_Development_Request__c rs : lstResults)
                {   
                    
                    searchResult x = new searchResult(                    
                        rs.Id, 
                        rs.Name, 
                        rs.Title__c, 
                        rs.Public_Status__c,
                        rs.Public_Status_Description__c 
                    );
                    
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
            NI_Error_Logger.WriteToLog(strDetails, 'CRSearch', 'AH_CRSearch_ctlr', 'Select'); 
        } 
        
    }

	private void fillPicklists()
    {
 
        // FILL SOLUTION STATUSES 
        lstPublicStatuses = new List<SelectOption>();
        selPublicStatus = 'All';
        Schema.DescribeFieldResult fr1 = SFDC_CSP_Development_Request__c.Public_Status__c.getDescribe();        
        List<Schema.PicklistEntry> ple1 = fr1.getPicklistValues();
        
        lstPublicStatuses.add(new SelectOption('All', 'All'));
        
        for (Schema.PicklistEntry f1 : ple1)            
        {
            lstPublicStatuses.add(new SelectOption(f1.getLabel(), f1.getValue()));
        }                  

    }
    
    public void doSearch() 
    {
        queryBuilderFINAL = soqlBuilder();
        system.debug('QUERY = ' + queryBuilderFINAL);
        execSearch(queryBuilderFINAL);
        searchText = '';             
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

    public void attachCR() 
    {
        
        try
        {
            string strSubject = strCRNumber + ': ' + c.Subject;
            c.Subject = strSubject;
            c.Change_Request__c = strCRId;
            update c;
            displayConfirm = false;
            toastMsg = 'CR was successfully attached to Case.';
            isSuccess = true;            
        }
        catch (Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
        
    } 
    
    public void showConfirmation() 
    {
        string strTitleCR = strCRTitle.left(60);
        if (strCRTitle.length() > 60)
        {
            strTitleCR += '...';
        }
        string strTitleCase = c.Subject.left(60);
        if (c.Subject.length() > 60)
        {
            strTitleCase += '...';
        }        
        strAttachDetails = 'Attach CR (' + strCRNumber + ': ' +  strTitleCR + ')<br/>TO<br/>CASE (' + c.CaseNumber + ': ' + strTitleCase + ')';
        isSuccess = false;
		displayConfirm = true;
    } 
    
    public void hideConfirmation() 
    {
        isSuccess = false;
		displayConfirm = false;
    } 
    
    public pageReference backToCase()
    {
        pageReference pr = new pageReference('/' + strCaseId);
        pr.setRedirect(true);
        return pr;
    }
    
    
    // ================================================================================================================================
	//  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class searchResult
    {    

        public Id crId {get; set;}
        public String crNumber {get; set;}
        public String crTitle {get; set;}
        public String crStatus {get; set;}
        public String crDescription {get; set;}

        public searchResult (Id p1, String p2, String p3, String p4, String p5)
        {
            this.crId = p1; 
            this.crNumber = p2; 
            this.crTitle = p3; 
            this.crStatus = p4; 
            this.crDescription = p5; 
        }
        
    }    
    
}