/****************************************************************************************
Name            : AH_PCC_Cancellations_Ctlr
Author          : Sean Harris
Created Date    : 03/27/2019
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : Controller for the AH_PCC_Cancellations Visualforce page.
                :            
******************************************************************************************/
public class AH_PCC_Cancellations_Ctlr 
{

    // LIMIT CONSTANTS ======================================= 
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 10000;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 1000;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    private final Integer PRIVATE_INITIAL_MAX_CONST = 25;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN FRESH PAGE
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstSearchFields {get; set;} 
    // STRINGS
    public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;}  
    public String selField {get; set;}
    public String renewDateStart {get; set;}  
    public String renewDateEnd {get; set;}       
    // NUMERICS
    public Integer iRecCount {get; set;}
    // BOOLEANS
    public Boolean checkAll {get; set;}
    public Boolean hasChatterGroup {get; set;}
    
    // PRIVATE VARIABLES ====================================
    private User runningUser {get; set;}
	private Boolean isPartnerUser {get; set;}     
    private Id gId; 
    

    public AH_PCC_Cancellations_Ctlr()
    {
        
        system.debug(' *** ENTERING AH_PCC_Cancellations_Ctlr() - CONSTRUCTOR');        
        
        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();
        
        // EXECUTE INITIAL LIMITED QUERY
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_INITIAL_MAX_CONST);
        
        system.debug(' *** EXITING AH_PCC_Cancellations_Ctlr() - CONSTRUCTOR');        
        
    }
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================

    private void initVariables()
    {
        
        searchText = ''; 
        sortByField = 'CreatedDate';
        sortByDirection = 'DESC';
        hasChatterGroup = false;
        gId = null;
        isPartnerUser = false;
        renewDateStart = ''; 
        renewDateEnd = ''; 
        
        runningUser = [SELECT Id, AccountId, IsActive, UserType, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];  
        
        // DETERMINE OF RUNNING USER IS A PARTNER USER
        if ((runningUser.AccountId != null) && (runningUser.UserType != 'Standard'))
        {        
            isPartnerUser = true;

            // GET PARTNER'S COMMUNTY CHATTER GROUP ID 
            List<Account> lstAcc = new List<Account>([SELECT Id, Partner_Chatter_Group_ID__c 
                                                      FROM Account 
                                                      WHERE Partner_Chatter_Group_ID__c != null 
                                                      AND Id =: runningUser.AccountId]);
            
            if (!lstAcc.isEmpty())
            {
				gId = (Id)lstAcc[0].Partner_Chatter_Group_ID__c; 
            }

        }
        
        if (isPartnerUser && gId != null)
        {
            hasChatterGroup = true;
        }
        
        if (!isPartnerUser)
        {
            hasChatterGroup = true;
        }                        
        
    }
    
    private void execSearch(String sortByExpression, Integer iLimit)
    {
        
        lstSearchResults = new List<searchResult>();
        iRecCount = 0;  
        searchResultMsg = '0 records found';
        checkAll = false;
        Date d = Date.today().AddDays(-210); 
        
        // BUILD DYNAMIC SOQL QUERY SEARCH STRING 
        string q = 'SELECT ';
        q += 'Id, '; 
        q += 'Name, '; 
        q += 'Status__c, '; 
        q += 'CreatedDate, ';
        q += 'Product2__r.ProductCode, '; 
        q += 'Product2__r.Name, '; 
        q += 'Account_Number__c, '; 
        q += 'Account__r.Name, '; 
        q += 'Opportunity__c, '; 
        q += 'Opportunity_Number__c, '; 
        q += 'Cancel_Renewal_By_Date__c, ';
        q += 'Renewal_Cancellation_Quantity__c, ';
        q += 'Late_Cancellation__c ';
        q += 'FROM NI_Cancellation__c ';
        q += 'WHERE Cancel_Renewal_By_Date__c != null '; 
        //q += 'AND Late_Cancellation__c = false ';
        //q += 'AND Status__c = \'Pending Retention\' ';

        if ((runningUser.AccountId != null) && (runningUser.UserType != 'Standard'))
        {
            q += 'AND Product2__r.Partner_Name__c = \'' + runningUser.AccountId + '\' ';
        }        
        
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
                q += 'OR Product2__r.ProductCode LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Product2__r.Name LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Account_Number__c LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Account__r.Name LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Opportunity_Number__c LIKE \'%' + strKeyWord + '%\') ';   
            }
        }
        
        if (renewDateStart != '')
        {
            // SOQL INJECTION PROTECTION
            String strDate1 = string.escapeSingleQuotes(renewDateStart); 

            try
            {
                Date d1 = Date.parse(strDate1);
                string d1Month = String.valueOf(d1.month());
                if (d1Month.length() == 1)
                {
                    d1Month = '0' + d1Month;
                }
                string d1Day = String.valueOf(d1.day());
                if (d1Day.length() == 1)
                {
                    d1Day = '0' + d1Day;
                }               
                String strStart = String.valueOf(d1.year()) + '-' + d1Month + '-' + d1Day;
               
				q += 'AND Cancel_Renewal_By_Date__c >= ' + strStart + ' ';
                 
            }
            catch (Exception ex) {}
                
        }
        
        if (renewDateEnd != '')
        {
            // SOQL INJECTION PROTECTION
            String strDate2 = string.escapeSingleQuotes(renewDateEnd);   
         
            try
            {
                Date d2 = Date.parse(strDate2);
                string d2Month = String.valueOf(d2.month());
                if (d2Month.length() == 1)
                {
                    d2Month = '0' + d2Month;
                }
                string d2Day = String.valueOf(d2.day());
                if (d2Day.length() == 1)
                {
                    d2Day = '0' + d2Day;
                }               
                String strEnd = String.valueOf(d2.year()) + '-' + d2Month + '-' + d2Day;
                 
				q += 'AND Cancel_Renewal_By_Date__c <= ' + strEnd + ' ';
              
            }
            catch (Exception ex) {}        
        }  
        
//        if ((renewDateStart == '') && (renewDateEnd == ''))
//        {
//            q += 'AND Cancel_Renewal_By_Date__c >= TODAY ';
//        }        

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
            
            List<NI_Cancellation__c> lstResults = Database.query(q);
            Integer iCounter = 0;
            
            if (!lstResults.isEmpty())
            {
                for (NI_Cancellation__c rs : lstResults)
                {   
                    searchResult x = new searchResult(                    
                        rs.Id, 
                        rs.Name, 
                        rs.Status__c, 
                        rs.CreatedDate, 
                        rs.Product2__r.ProductCode, 
                        rs.Product2__r.Name, 
                        rs.Account_Number__c, 
                        rs.Account__r.Name, 
                        rs.Opportunity_Number__c, 
                        rs.Cancel_Renewal_By_Date__c, 
                        String.valueOf(rs.Renewal_Cancellation_Quantity__c), 
                        rs.Late_Cancellation__c, 
                        false); 
                    iCounter += 1;
                    if (iCounter <= iLimit)
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
                
                if (iRecCount >= iLimit)
                {
                    searchResultMsg = 'Displaying ' + String.valueOf(iLimit) + ' of ' + String.valueOf(iRecCount) + ' records only';
                }
                
            }
        }
        catch (Exception ex)
        {
            lstSearchResults.clear();
            searchResultMsg = 'An error occurred while performing search. Please try again and report to Amadeus Hospitality PartnerCentral administration if error persists.'; 
            String strDetails = 'Error occurred in execSearch() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'AH_PCC_Cancellations_Ctlr', 'Insert'); 
        } 
        
    }

	private void fillPicklists()
    {
        
    	lstSearchFields = new List<SelectOption>();
        selField = 'ALL FIELDS';
        lstSearchFields.add(new SelectOption('ALL FIELDS', 'ALL FIELDS'));
        lstSearchFields.add(new SelectOption('Status__c', 'Status'));
        lstSearchFields.add(new SelectOption('Name', 'Cancellation #'));
        lstSearchFields.add(new SelectOption('Product2__r.ProductCode', 'Product Code'));
        lstSearchFields.add(new SelectOption('Product2__r.Name', 'Product Name'));
        lstSearchFields.add(new SelectOption('Account_Number__c', 'Account Number'));
        lstSearchFields.add(new SelectOption('Account__r.Name', 'Account Name'));
        lstSearchFields.add(new SelectOption('Opportunity_Number__c', 'Opportunity Number'));

    }
    
    public void doSearch() 
    {
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_RESULT_MAX_CONST);
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
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_RESULT_MAX_CONST);
    }
    
    // EXPORT METHODS
    public pageReference exportResults()
    {        
        
        system.debug(' *^* exportResults');
        
        PageReference pr = null;
        Id fileId;
        
        // BUILD UNIQUE FILENAME
        DateTime dt = system.now();
        String strFileName = 'CancellationExport-';
        strFileName += String.valueOf(dt.Year()) + String.valueOf(dt.Month()) + String.valueOf(dt.Day()) + '-';
        strFileName += String.valueOf(dt.Hour()) + String.valueOf(dt.Minute()) + String.valueOf(dt.Second());
                
        // BUILD CSV HEADERS
        String strHeader = '';
        strHeader += 'Cancellation #,';
        strHeader += 'Quantity__c,';
        strHeader += 'Product Code,';
        strHeader += 'Product Name,';
        strHeader += 'Status,';
        strHeader += 'Account #,';
        strHeader += 'Account Name,';
        strHeader += 'Opportunity #,';
		strHeader += 'Renew Date';
        
        // BUILD CSV ROWS
        List<String> lst = new List<String>();
        
        for (searchResult sr : lstSearchResults)
        {
            String strBuilder = '';
            strBuilder += sr.CancellationName + ',';
            strBuilder += sr.CancellationQty + ','; 
            strBuilder += sr.ProductCode + ','; 
            strBuilder += sr.ProductName.replace(',', '') + ','; 
            strBuilder += sr.CancellationStatus + ','; 
            strBuilder += sr.AccountNumber + ',';
            strBuilder += sr.AccountName.replace(',', '') + ',';             
            strBuilder += sr.OpportunityNumber + ',';
            strBuilder += sr.CancelRenewalByDate;
            lst.add(strBuilder);
        }

        if (isPartnerUser)
        {
            
            // GET PARTNER'S COMMUNTY CHATTER GROUP ID 
//            List<Account> lstAcc = new List<Account>([SELECT Id, Partner_Chatter_Group_ID__c 
//                                                      FROM Account 
//                                                      WHERE Partner_Chatter_Group_ID__c != null 
//                                                      AND Id =: runningUser.AccountId]);
            
//            if (lstAcc.isEmpty())
//            {
                // RAISE A USER-FREINDLY ERROR HERE
//                return pr;
//            }
            
//            Id gId = (Id)lstAcc[0].Partner_Chatter_Group_ID__c;
            
            // GET PARTNER CENTRAL COMMUNITY ID
            Id communityID = [SELECT Id FROM Network WHERE Name = 'PartnerCentral' LIMIT 1].Id;
            
            // CREATE CSV FILE
            fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, gId, communityID);
            
            // CREATE NEW CHATTER POST
            FeedItem f = new FeedItem();
            // ASSIGN COLLABORATION GROUP THAT IS ON PARTNER ACCOUNT
            f.ParentId = gId;
            // ASSIGN POST TITLE
            f.Title = 'Cancellation Export for ' + runningUser.FirstName + ' ' + runningUser.LastName;
            // ASSIGN POST BODY
            String strBody = 'Please find requested export CSV attached: \n';
            f.Body = strBody;
            // ASSIGN COMMUNITY ID
            f.NetworkScope = communityID; 
            insert f;
            
            // ATTACH NEW CSV FILE TO CHATTER POST
            FeedAttachment fa = new FeedAttachment();
            fa.FeedEntityId = f.Id;
            fa.Type = 'Content';
            fa.RecordId = fileId;
            insert fa; 

        }
        else
        {
            fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, null, null);
        }

        system.debug(' *^* fileId = ' + fileId);
        
        try
        {
            ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: fileId];
            system.debug(' *^* cv = ' + cv);
            pr = new PageReference(System.URL.getSalesforceBaseURL().toExternalForm() + '/partnercentral/s/contentdocument/' + String.valueOf(cv.ContentDocumentId));
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

        public Id CancellationId {get; set;}
        public String CancellationName {get; set;}
        public String CancellationStatus {get; set;}
        public Datetime CancellationCreatedDate {get; set;}
        public String ProductCode {get; set;}
        public String ProductName {get; set;}
        public String AccountNumber {get; set;}
        public String AccountName {get; set;}
        public String OpportunityNumber {get; set;} 
        public Date CancelRenewalByDate {get; set;} 
        public String CancellationQty {get; set;} 
        public Boolean isLate {get; set;}
        public Boolean isChecked {get; set;}

        public searchResult (Id p1, String p2, String p3, Datetime p4, String p5, String p6, String p7, String p8, String p9, Date p10, String p11, Boolean isLate, Boolean isChecked)
        {
            this.CancellationId = p1; 
            this.CancellationName = p2; 
            this.CancellationStatus = p3; 
            this.CancellationCreatedDate = p4; 
            this.ProductCode = p5; 
            this.ProductName = p6; 
            this.AccountNumber = p7; 
            this.AccountName = p8; 
            this.OpportunityNumber = p9; 
            this.CancelRenewalByDate = p10;
            this.CancellationQty = p11;
			this.isLate = isLate;
            this.isChecked = isChecked;
        }
        
    }    
    
}