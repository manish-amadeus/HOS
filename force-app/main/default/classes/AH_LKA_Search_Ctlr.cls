/****************************************************************************************
Name            : AH_LKA_Search_Ctlr
Author          : Sean Harris
Created Date    : 01/08/2020
Last Mod Date   : 01/08/2020
Last Mod By     : Sean Harris 
NICC Reference  : 
Description     : Controller for the AH_LKA_Search Visualforce page.
                :            
******************************************************************************************/
public class AH_LKA_Search_Ctlr 
{

    // LIMIT CONSTANTS ======================================= 
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 200;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 200;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstArticleStatuses {get; set;} 
    public List<SelectOption> lstValidationStatuses {get; set;} 
    public List<SelectOption> lstSolutionDomains {get; set;} 
	public Map<Integer, String> mapSearchHistory {get; set;} 
    
    // STRINGS
    public String solId {get; set;}  
    public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;}  
    public String selArticleStatus {get; set;}
    public String selValidationStatus {get; set;}
    public String selSolutionDomain {get; set;}
    public String queryBuilderFINAL {get; set;}
    public String queryBuilderWHERE {get; set;}
    public String strConfirmAttachMsg {get; set;}  
    public String strCaseId {get; set;}  
    public String strCaseNumber {get; set;} 
    
    // NUMERICS
    public Integer iRecCount {get; set;}
    public Integer iRow {get; set;}  
    
    // BOOLEANS
    public Boolean disableOptions {get; set;}
    public Boolean bShowConfirmAttach {get; set;}
    
    // PRIVATE VARIABLES ====================================
    private User runningUser;
	private Boolean isSpecialUser;     
    private String queryBuilderSELECT;
    private String queryBuilderORDER;
    private Integer drillDownCount;
    private Case c;
    
    
    
    public AH_LKA_Search_Ctlr()
    {
        
        system.debug(' *** ENTERING AH_LKA_Search_Ctlr() - CONSTRUCTOR');        
        
        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();

        if (ApexPages.CurrentPage().getParameters().containsKey('caseid'))
        { 
            if ((ApexPages.CurrentPage().getParameters().get('caseid') != 'null') && (ApexPages.CurrentPage().getParameters().get('caseid') != null))
            {              
                c = [SELECT Id, Subject, CaseNumber, Number_of_Solutions__c FROM Case WHERE Id =: ApexPages.CurrentPage().getParameters().get('caseid')];
                strCaseId = c.Id;
                strCaseNumber = c.CaseNumber;  
            }
        }        
        
        system.debug(' *** EXITING AH_LKA_Search_Ctlr() - CONSTRUCTOR');        
        
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
        sortByField = 'Title';
        sortByDirection = 'ASC';        
        // COLLECTIONS
        mapSearchHistory = new Map<Integer, String>();
        lstSearchResults = new List<searchResult>();        
		disableOptions = false;
        bShowConfirmAttach = false;
        iRecCount = 0;  
        drillDownCount = 0;
        searchResultMsg = '0 records found';  
        isSpecialUser = false;
        strCaseId = '';
        strCaseNumber = ''; 
        selArticleStatus = 'All';
        selValidationStatus = 'All';
        selSolutionDomain = 'All';
        strConfirmAttachMsg = '';
        
        runningUser = [SELECT Id, ProfileId, IsActive, UserType, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];  

        for (Profile p : [SELECT Id FROM Profile WHERE Name IN ('System Administrator', 'AH Support Managers - Lightning', 'AH Business Systems')])
        {
            if (runningUser.ProfileId == p.Id)
            {
                isSpecialUser = true;
            }
        }

        
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
            queryBuilderSELECT += 'ArticleNumber, ';
            queryBuilderSELECT += 'ArticleCaseAttachCount, ';
            queryBuilderSELECT += 'KnowledgeArticleId, ';
//            queryBuilderSELECT += 'AssignedTo, ';
//            queryBuilderSELECT += 'Case_Origin__c, ';
//            queryBuilderSELECT += 'How_Do_I_Description__c, ';
//            queryBuilderSELECT += 'How_Do_I_Related_Articles__c, ';
//            queryBuilderSELECT += 'How_Do_I_Resolution__c, ';
//            queryBuilderSELECT += 'How_Do_I_Solution__c, ';
            queryBuilderSELECT += 'IsVisibleInApp, ';
            queryBuilderSELECT += 'IsVisibleInCsp, ';
//            queryBuilderSELECT += 'Owner, ';
            queryBuilderSELECT += 'PublishStatus, ';
            queryBuilderSELECT += 'Solution_Domain__c, ';
            queryBuilderSELECT += 'Solution_Number__c, ';
            queryBuilderSELECT += 'Summary, ';
//            queryBuilderSELECT += 'Technical_Document_Internal_Notes__c, ';
//            queryBuilderSELECT += 'Technical_Document_Related_Links__c, ';
//            queryBuilderSELECT += 'Technical_Document_ResolutionText__c, ';
            queryBuilderSELECT += 'Title, ';
            queryBuilderSELECT += 'UrlName, ';
            queryBuilderSELECT += 'ValidationStatus, ';
            queryBuilderSELECT += 'VersionNumber, ';
            queryBuilderSELECT += 'RecordType.Name '; 
            queryBuilderSELECT += 'FROM Lightning_Knowledge__kav ';
            queryBuilderSELECT += 'WHERE Id != null ';

            // ARTICLE STATUS FILTER
            if (selArticleStatus != 'All')
            {
                if (selArticleStatus == 'Default')
                {
                    queryBuilderSELECT += 'AND PublishStatus NOT IN (\'Archived\') '; 
                }
                else
                {
                    queryBuilderSELECT += 'AND PublishStatus = \'' + String.escapeSingleQuotes(selArticleStatus) + '\' ';
                }
            }
            
            // VALIDATION STATUS FILTER
            if (selValidationStatus != 'All')
            {
                queryBuilderSELECT += 'AND ValidationStatus = \'' + String.escapeSingleQuotes(selValidationStatus) + '\' ';
            }
           
            // BUSINESS DOMAIN FILTER
            if (selSolutionDomain != 'All')
            {
                queryBuilderSELECT += 'AND Solution_Domain__c = \'' + String.escapeSingleQuotes(selSolutionDomain) + '\' ';
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
			String strTempWHERE = 'AND Title LIKE \'%' + strKeyWord + '%\' ';
            // CHANGE IF "NOT" LIKE SPECIFIED
            if (strKeyWord.startsWith('!'))
            { 
                strTempWHERE = 'AND (NOT Title LIKE \'%' + strKeyWord.replace('!', '') + '%\') ';
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
            List<Lightning_Knowledge__kav> lstResults = Database.query(q);
            Integer iCounter = 0;
            iRecCount = 0;
          
            if (!lstResults.isEmpty())
            {
                for (Lightning_Knowledge__kav rs : lstResults)
                {   
                    
                    string strPubStatus = rs.PublishStatus;
                    
                    if (strPubStatus == 'Online')
                    {
                        strPubStatus = 'Published';
                    }
                    
                    searchResult x = new searchResult(                    
                        rs.Id, 
                        rs.KnowledgeArticleId, 
                        rs.ArticleNumber, 
                        rs.Title, 
                        rs.ValidationStatus, 
                        rs.Solution_Domain__c, 
                        strPubStatus, 
                        rs.ArticleCaseAttachCount, 
                        rs.VersionNumber, 
                        false,
                    	iCounter); 
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
            else
            {
                searchResultMsg = String.valueOf(iRecCount) + ' records found';
            }
            
        }
        catch (Exception ex)
        {
            lstSearchResults.clear();
            searchResultMsg = 'An error occurred while performing search. Please try again and report to Business Systems if error persists.'; 
            String strDetails = 'Error occurred in execSearch() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
            NI_Error_Logger.WriteToLog(strDetails, 'SolutionSearch', 'AH_LKA_Search_Ctlr', 'Select'); 
        } 
        
    }

	private void fillPicklists()
    {

        // FILL ARTICLE STATUSES 
        lstArticleStatuses = new List<SelectOption>();
        selArticleStatus = 'Default';
        Schema.DescribeFieldResult fr1 = Lightning_Knowledge__kav.PublishStatus.getDescribe();        
        List<Schema.PicklistEntry> ple1 = fr1.getPicklistValues();
        
        lstArticleStatuses.add(new SelectOption('Default', 'Default'));
        
        if (isSpecialUser)
        {
            lstArticleStatuses.add(new SelectOption('All', 'All'));
            
//            for (Schema.PicklistEntry f1 : ple1)            
//            {
//                lstArticleStatuses.add(new SelectOption(f1.getLabel(), f1.getValue()));
//            }                  
        	lstArticleStatuses.add(new SelectOption('Online', 'Published'));
            lstArticleStatuses.add(new SelectOption('Draft', 'Draft'));
            lstArticleStatuses.add(new SelectOption('Archived', 'Archived'));
        }        
        
        // FILL VALIDATION STATUSES 
        lstValidationStatuses = new List<SelectOption>();
        selValidationStatus = 'All';
        Schema.DescribeFieldResult fr2 = Lightning_Knowledge__kav.ValidationStatus.getDescribe();        
        List<Schema.PicklistEntry> ple2 = fr2.getPicklistValues();
        
//        lstValidationStatuses.add(new SelectOption('Default', 'Default'));
        
//        if (isSpecialUser)
//        {
            lstValidationStatuses.add(new SelectOption('All', 'All'));
            
            for (Schema.PicklistEntry f2 : ple2)
            {
                lstValidationStatuses.add(new SelectOption(f2.getLabel(), f2.getValue()));
            }                  
//        }
  
        // FILL SOLUTION DOMAINS
    	lstSolutionDomains = new List<SelectOption>();
        selSolutionDomain = runningUserBusinessDomain();
        Schema.DescribeFieldResult fr3 = Lightning_Knowledge__kav.Solution_Domain__c.getDescribe();        
        List<Schema.PicklistEntry> ple3 = fr3.getPicklistValues();
        
        lstSolutionDomains.add(new SelectOption('All', 'All'));
        
        for (Schema.PicklistEntry f3 : ple3)            
        {
            lstSolutionDomains.add(new SelectOption(f3.getLabel(), f3.getValue()));
        }         

    }
    
    public void doSearch() 
    {
        //if (searchText != '')
        //{
            queryBuilderFINAL = soqlBuilder();
            system.debug('QUERY = ' + queryBuilderFINAL);
            execSearch(queryBuilderFINAL);
            searchText = ''; 
        //}
    }

    public void goBack() 
    {
        system.debug('drillDownCount = ' + drillDownCount);
        if (drillDownCount > 0)
        {
            if (drillDownCount == 1)
            {
                // QUERY BUILDING VARIABLES
                queryBuilderSELECT = '';
                queryBuilderWHERE = '';
                queryBuilderORDER = '';
                searchText = '';        
                // COLLECTIONS
                mapSearchHistory = new Map<Integer, String>();
                lstSearchResults = new List<searchResult>();        
                disableOptions = false;
                iRecCount = 0;  
                drillDownCount = 0;
                searchResultMsg = '0 records found'; 
            }
            else
            {
                drillDownCount--;
                queryBuilderFINAL = soqlBuilder();
                system.debug('QUERY = ' + queryBuilderFINAL);
                execSearch(queryBuilderFINAL);
                searchText = '';                 
            }           
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

    public void showVerify() 
    {
		bShowConfirmAttach = true;
        strConfirmAttachMsg = '<b>ATTACH ARTICLE</b><br/>"' + lstSearchResults[iRow].ArticleNumber + ': ' +  lstSearchResults[iRow].ArticleName + '"<br/><b>TO CASE</b><br/>"' + c.CaseNumber + ': ' + c.Subject + '"?';
    } 
    
    public void hideVerify() 
    {
		bShowConfirmAttach = false;
        strConfirmAttachMsg = '';
    } 
    
    public PageReference doAttach()
    {
        
        PageReference pr;
        
        try
        {
            
            CaseArticle ca = new CaseArticle();
            ca.CaseId = (Id)strCaseId;
            ca.KnowledgeArticleId = lstSearchResults[iRow].KnowledgeArticleId;
            ca.ArticleLanguage = 'en_US';
            ca.ArticleVersionNumber = Integer.valueOf(lstSearchResults[iRow].VersionNumber);
            insert ca;
            
            string strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + strCaseId;
            pr = new PageReference(strUrl); 
            pr.setRedirect(true); 
            
        }
        catch (Exception e)
        {
            strConfirmAttachMsg = e.getMessage();
        }
        
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

        public Id ArticleId {get; set;}
        public Id KnowledgeArticleId {get; set;}
        public String ArticleNumber {get; set;}
        public String ArticleName {get; set;}
        public String ArticleStatus {get; set;}
        public String BusinessDomain {get; set;}
        public String PublishStatus {get; set;}
        public Integer CasesLinked {get; set;}
        public Decimal VersionNumber {get; set;}
        public Boolean isChecked {get; set;}
        public Integer iRowIndex {get; set;}

        public searchResult (Id p1, Id p2, String p3, String p4, String p5, String p6, String p7, Integer p8, Decimal p9, Boolean p10, Integer p11)
        {
            this.ArticleId = p1;
            this.KnowledgeArticleId = p2; 
            this.ArticleNumber = p3; 
            this.ArticleName = p4; 
            this.ArticleStatus = p5; 
            this.BusinessDomain = p6; 
            this.PublishStatus = p7; 
            this.CasesLinked = p8;  
            this.VersionNumber = p9;
            this.isChecked = p10;
            this.iRowIndex = p11;
        }
        
    }    
    
}