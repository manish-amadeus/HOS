/****************************************************************************************
Name            : AH_CC_SINViewer_ctlr
Author          : Sean Harris
Created Date    : 02/20/2020
Last Mod Date   : 02/20/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Controller for the AH_CC_SINViewer Visualforce page.
                :            
******************************************************************************************/
public with sharing class AH_CC_SINViewer_ctlr 
{

    // LIMIT CONSTANTS =======================================  
    //private final Integer PRIVATE_MAX_CHECKED_CONST = 10;		// SETS AMOUNT RECORDS TO ALLOW BULK UPDATED TO
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 1000;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 1000;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    private final Integer PRIVATE_INITIAL_MAX_CONST = 1000;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN FRESH PAGE
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstSearchFields {get; set;} 
    // STRINGS
    //public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    //public String toastMsg {get; set;}
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;} 
    public String selField {get; set;}
    // NUMERICS
    public Integer iRecCount {get; set;}
    public Integer iCheckedCount {get; set;}
    // BOOLEANS
    public Boolean reachedCheckedLimit {get; set;}
    public Boolean hasChatterGroup {get; set;}
    public Boolean bChatterEnabled {get; set;} 
    
    // PRIVATE VARIABLES ====================================
    private User runningUser {get; set;}   
    private Id usrId;
 	private Id gId; 
    
    public AH_CC_SINViewer_ctlr()
    {
        
        system.debug(' *** ENTERING AH_CC_SINViewer_ctlr() - CONSTRUCTOR');        

        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();
        
        // EXECUTE INITIAL LIMITED QUERY
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_INITIAL_MAX_CONST);
        
        system.debug(' *** EXITING AH_CC_SINViewer_ctlr() - CONSTRUCTOR');        
        
    }
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================
    private void initVariables()
    {

        sortByField = 'CreatedDate';
        sortByDirection = 'ASC';
        reachedCheckedLimit = false;
        hasChatterGroup = false;
		gId = null;
        bChatterEnabled = true;
        
        runningUser = [SELECT Id, AccountId, IsActive, UserType, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];  
        usrId = runningUser.Id;
        
        // DETERMINE OF RUNNING USER IS A CUSTOMER USER
        if ((runningUser.AccountId != null) && (runningUser.UserType != 'Standard'))
        {        
            Profile p = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
            String strProfileName = p.Name;
            if (strProfileName.containsIgnoreCase('chatter'))
            {
                bChatterEnabled = false;
            }
        }
        
    }

    private void execSearch(String sortByExpression, Integer iLimit)
    {
        
        lstSearchResults = new List<searchResult>();
		iRecCount = 0;  

        // BUILD DYNAMIC SOQL QUERY SEARCH STRING 
        string q = 'SELECT ';
        q += 'Id, '; 
        q += 'Name, '; 
        q += 'Account_Name_Community__c, '; 
        q += 'c2g__InvoiceDate__c, ';
		q += 'c2g__DueDate__c, ';
        q += 'c2g__InvoiceTotal__c ';
        q += 'FROM c2g__codaInvoice__c ';
        q += 'WHERE Name != null ';
        
        if (runningUser.AccountId != null)
        {
            q += 'AND c2g__Account__c = \'' + runningUser.AccountId + '\' ';
        }
            
/*        

        // USER OPEN SEARCH
        if (searchText != '')
        {

            // SOQL INJECTION PROTECTION
            String strKeyWord = string.escapeSingleQuotes(searchText);               
            
            if (selField != 'ALL FIELDS')
            {
            	q += 'AND ' + selField + ' LIKE \'%' + strKeyWord + '%\' ';
            }
            else
            { 
                q += 'AND (Name LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Product__r.ProductCode LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Product__r.Name LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Account__r.AccountNumber LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Account_Name__c LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Opportunity__r.Opportunity_Number__c LIKE \'%' + strKeyWord + '%\') ';   
            }
        }
*/         
		// ORDER BY 
        if (sortByExpression != null)
        {
            q += 'ORDER BY ' + sortByExpression + ' ';
        }

        q += 'LIMIT ' + String.valueOf(PRIVATE_SOQL_LIMIT_CONST) + ' ';
       
        system.debug(' **** QUERY = ' + q);
        
        // FILL A LIST OF WRAPPER CLASSES TO DISPLAY RECORDS TO USER
        try 
        {
            List<c2g__codaInvoice__c> lstResults = Database.query(q);
            Integer iCounter = 0;
            
            if (!lstResults.isEmpty())
            {        
                for (c2g__codaInvoice__c rs : lstResults)
                {           
                    searchResult x = new searchResult(
                        rs.Id, 
                        rs.Name, 
                        rs.Account_Name_Community__c, 
                        rs.c2g__InvoiceDate__c, 
                        rs.c2g__DueDate__c, 
                        rs.c2g__InvoiceTotal__c 
                    ); 
                    
                    iCounter += 1;
                    
                    if (iCounter <= iLimit)
                    {
                        lstSearchResults.add(x);
                    }
                    
                    iRecCount++;
                    
                }  
            }
  
                searchResultMsg = String.valueOf(iRecCount) + ' records found';
                
                if (iRecCount == 1)
                {
                    searchResultMsg = '1 record found';
                }
                
                if (iRecCount >= iLimit)
                {
                    searchResultMsg = 'Displaying ' + String.valueOf(iLimit) + ' of ' + String.valueOf(iRecCount) + ' records only';
                }
                

        }
        catch (Exception ex)
        {
            lstSearchResults.clear();
            searchResultMsg = 'An error occurred while performing search. Please try again and report to Amadeus Hospitality Customer Central administration if error persists.'; 
            String strDetails = 'Error occurred in execSearch() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
//            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'AH_CC_SINViewer_ctlr', 'Insert'); 
        } 
        
    }

    
	private void fillPicklists()
    {  
    	lstSearchFields = new List<SelectOption>();
        selField = 'ALL FIELDS';
/*          
        lstSearchFields.add(new SelectOption('ALL FIELDS', 'ALL FIELDS'));
        lstSearchFields.add(new SelectOption('Name', 'Activity #'));
        lstSearchFields.add(new SelectOption('Product__r.Revenue_Category__c', 'Category'));
        lstSearchFields.add(new SelectOption('Product__r.ProductCode', 'Product Code'));
        lstSearchFields.add(new SelectOption('Product__r.Name', 'Product Name'));
        lstSearchFields.add(new SelectOption('Account__r.AccountNumber', 'Account Number'));
        lstSearchFields.add(new SelectOption('Account_Name__c', 'Account Name'));
        lstSearchFields.add(new SelectOption('Opportunity__r.Opportunity_Number__c', 'Opportunity Number'));
*/
    }

/*    
    public void doSearch() 
    {
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_RESULT_MAX_CONST);
    }
*/
    
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
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_RESULT_MAX_CONST);
    }

    public pageReference exportResults()
    {        

        PageReference pr = null;
        Id fileId;
       
        // BUILD UNIQUE FILENAME
        DateTime dt = system.now();
        String strFileName = 'MyInvoicesExport-';
        strFileName += String.valueOf(dt.Year()) + String.valueOf(dt.Month()) + String.valueOf(dt.Day()) + '-';
        strFileName += String.valueOf(dt.Hour()) + String.valueOf(dt.Minute()) + String.valueOf(dt.Second());

        // BUILD CSV HEADERS
        String strHeader = '';
        strHeader += 'INVOICE NUMBER,';
        strHeader += 'ACCOUNT NAME,';
        strHeader += 'INVOICE DATE,';
        strHeader += 'DUE DATE,';
        strHeader += 'INVOICE TOTAL,';
		strHeader += 'LINK TO DETAILS (LOGIN REQUIRED)';
        
        // BUILD CSV ROWS
        List<String> lst = new List<String>();

        for (searchResult sr : lstSearchResults)
        {
            String strBuilder = '';
            strBuilder += sr.InvoiceNumber + ',';
            strBuilder += sr.AccountName.replace(',', '') + ',';          
            strBuilder += sr.InvoiceDate + ',';
            strBuilder += sr.DueDate + ',';              
            strBuilder += sr.InvoiceTotal + ',';  
            strBuilder += 'https://amadeus-community.force.com/customers/' + sr.InvoiceId; 
            lst.add(strBuilder);
        }

//        if (isCustomerUser)
//        {

            // GET PARTNER CENTRAL COMMUNITY ID
            Id communityID = [SELECT Id FROM Network WHERE Name = 'Customer Central' LIMIT 1].Id;
            
            // CREATE CSV FILE
            //fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, usrId, communityID);
            fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, usrId, null);
system.debug(' *^* fileId = ' + fileId);            
            // CREATE NEW CHATTER POST
            FeedItem f = new FeedItem();
            // ASSIGN TO RUNNING USER'S CHATTER FEED
            f.ParentId = runningUser.Id;
            // ASSIGN POST TITLE
            f.Title = 'Case Export for ' + runningUser.FirstName + ' ' + runningUser.LastName;
            // ASSIGN POST BODY
            String strBody = 'Please find requested export CSV attached: \n';
            f.Body = strBody;
            // ASSIGN COMMUNITY ID
            f.NetworkScope = communityID;       
            insert f;
system.debug(' *^* f.Id = ' + f.Id);               
            // ATTACH NEW CSV FILE TO CHATTER POST
            FeedAttachment fa = new FeedAttachment();
            fa.FeedEntityId = f.Id;
            fa.Type = 'Content';
            fa.RecordId = fileId;
            insert fa; 

//        }
//        else
//        {
//            fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, null, null);
//        }

        try
        {
            ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: fileId];
            pr = new PageReference(System.URL.getSalesforceBaseURL().toExternalForm() + '/customers/s/detail/' + String.valueOf(cv.ContentDocumentId));
            pr.setRedirect(true);   
        }
        catch (Exception ex)
        {
            system.debug(' *^* ERROR = ' + ex.getMessage());
        }
 
        return pr;
        
    }
    
        
    // ================================================================================================================================
	//  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class searchResult
    {    

        public Id InvoiceId {get; set;}
        public String InvoiceNumber {get; set;}
        public String AccountName {get; set;}
        public Date InvoiceDate {get; set;}
        public Date DueDate {get; set;}
        public Decimal InvoiceTotal {get; set;}

        public searchResult (Id p1, String p2, String p3, Date p4, Date p5, Decimal p6)
        {
            this.InvoiceId = p1; 
            this.InvoiceNumber = p2; 
            this.AccountName = p3; 
            this.InvoiceDate = p4; 
            this.DueDate = p5; 
            this.InvoiceTotal = p6; 
        }
        
    }    
    
}