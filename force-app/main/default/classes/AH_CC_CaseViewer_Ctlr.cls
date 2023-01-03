/****************************************************************************************
Name            : AH_CC_CaseViewer_Ctlr
Author          : Sean Harris
Created Date    : 10/01/2019
Last Mod Date   : 10/01/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the AH_CC_CaseViewer Visualforce page.
                :            
******************************************************************************************/
public class AH_CC_CaseViewer_Ctlr 
{

    // LIMIT CONSTANTS =======================================  
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 10000;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 1000;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    private final Integer PRIVATE_INITIAL_MAX_CONST = 25;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN FRESH PAGE
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<searchResult> lstSelectedResults {get; set;} 
    public List<SelectOption> lstSearchFields {get; set;} 
  
    // STRINGS
    public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;} 
    public String selField {get; set;}
    public String dtStartDate {get; set;}  
    public String dtEndDate {get; set;}      
    public String strStartDateLabel {get; set;} 
    public String strEndDateLabel {get; set;} 
    public String strSOQL {get; set;} 
       
    // NUMERICS
    public Integer iRecCount {get; set;}
    // BOOLEANS
    public Boolean bSearchCR {get; set;} 
    public Boolean bChatterEnabled {get; set;} 
    
    // PRIVATE VARIABLES ====================================
    private User runningUser {get; set;}
    private Set<Id> setRTypes = new Set<Id>();  			// SET TO HOLD THE CASE RECORD TYPE IDs 
    private Set<string> setOrigins = new Set<string>();  	// SET TO HOLD THE CASE ORIGINS 
    private Set<string> setCTypes = new Set<string>();     	// SET TO HOLD THE CASE TYPES 
	private Id usrId;										// 
    private Id usrContactId;								// CONTACTID OF THE CURRENT NEIGHBORHOOD USER 
    private Id usrAccountId;    							// VARIABLE TO HOLD ACCOUNT ID OF THE CURRENT USER 
    private String usrUserType;    							// VARIABLE TO HOLD USERTYPE OF THE CURRENT USER 
	private Boolean isCustomerUser {get; set;} 				// 

    
    public AH_CC_CaseViewer_Ctlr()
    {
        
        system.debug(' *** ENTERING AH_CC_CaseViewer_Ctlr() - CONSTRUCTOR');        

        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();
        
        // EXECUTE INITIAL LIMITED QUERY
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_INITIAL_MAX_CONST);
        
        system.debug(' *** EXITING AH_CC_CaseViewer_Ctlr() - CONSTRUCTOR');        
        
    }
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS     
    // ================================================================================================================================
    private void initVariables()
    {

        searchText = ''; 
        sortByField = 'Case.CreatedDate'; 
        sortByDirection = 'ASC';
        isCustomerUser = false;
        dtStartDate = '';
        dtEndDate = '';
        strStartDateLabel = 'Created Start Date:'; 
    	strEndDateLabel = 'Created End Date:'; 
        strSOQL = '';
        bSearchCR = false;
        bChatterEnabled = true;
        
        //runningUser = [SELECT Id, AccountId, IsActive, ContactId, UserType, FirstName, LastName FROM User WHERE Id = '0050d000003Zn8XAAS'];  
        runningUser = [SELECT Id, AccountId, IsActive, ContactId, UserType, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];  
        usrId = runningUser.Id;
        usrUserType = runningUser.UserType;
        
        if (runningUser.ContactId != null)
        {          
            usrContactId = runningUser.ContactId; 
        }   
        
        if (runningUser.AccountId != null)
        {          
            usrAccountId = runningUser.AccountId; 
        } 
        
        // DETERMINE OF RUNNING USER IS A CUSTOMER USER
        if ((runningUser.AccountId != null) && (runningUser.UserType != 'Standard'))
        {        
            isCustomerUser = true;
            Profile p = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
            String strProfileName = p.Name;
            if (strProfileName.containsIgnoreCase('chatter'))
            {
                bChatterEnabled = false;
            }
        }

        // LIST TO HOLD THE VALUES FROM THE NI Neighborhood Case Record Types CUSTOM SETTING  
        List<NI_Neighborhood_Case_Record_Types__c> lstCS1 = NI_Neighborhood_Case_Record_Types__c.getAll().values();
        
        // LOOP THROUGH THE lstCS AND GET THE CASE RECORDTYPEIDs FOR THE RECORD TYPES THAT CAN BE DISPLAYED IN THE NEWMARKET NEIGHBORHOOD 
        for (NI_Neighborhood_Case_Record_Types__c crt1 : lstCS1)
        {
            setRTypes.add(NI_TestClassData.getRecordTypeId('Case', crt1.Name));
        }
        
        // LIST TO HOLD THE VALUES FROM THE NI Neighborhood Case Origins CUSTOM SETTING  
        List<NI_Neighborhood_Case_Origins__c> lstCS2 = NI_Neighborhood_Case_Origins__c.getAll().values();
        
        // LOOP THROUGH AND GET THE CASE ORIGINS THAT CAN BE DISPLAYED IN THE NEWMARKET NEIGHBORHOOD 
        for (NI_Neighborhood_Case_Origins__c crt2 : lstCS2)
        {
            setOrigins.add(crt2.Name);
        }
        
        // LIST TO HOLD THE VALUES FROM THE NI Neighborhood Case Types CUSTOM SETTING  
        List<NI_Neighborhood_Case_Types__c> lstCS3 = NI_Neighborhood_Case_Types__c.getAll().values();
        
        // LOOP THROUGH AND GET THE CASE TYPES THAT CAN BE DISPLAYED IN THE NEWMARKET NEIGHBORHOOD  
        for (NI_Neighborhood_Case_Types__c crt3 : lstCS3)
        {
            setCTypes.add(crt3.Name);
        } 
        
    }
    
    private void fillPicklists()
    {
        
    	lstSearchFields = new List<SelectOption>();
        selField = 'My Open Cases';

        lstSearchFields.add(new SelectOption('My Open Cases', 'My Open Cases'));
        lstSearchFields.add(new SelectOption('My Closed Cases', 'My Closed Cases'));
        lstSearchFields.add(new SelectOption('All My Cases', 'All My Cases'));
        
        lstSearchFields.add(new SelectOption('My Property\'s Open Cases', 'My Property\'s Open Cases'));
        lstSearchFields.add(new SelectOption('My Property\'s Closed Cases', 'My Property\'s Closed Cases'));
        lstSearchFields.add(new SelectOption('All My Property\'s Cases', 'All My Property\'s Cases'));
        
        lstSearchFields.add(new SelectOption('All Properties\' Open Cases', 'All Properties\' Open Cases'));
        lstSearchFields.add(new SelectOption('All Properties\' Closed Cases', 'All Properties\' Closed Cases'));
        lstSearchFields.add(new SelectOption('All Properties\' Cases', 'All Properties\' Cases'));
        
        lstSearchFields.add(new SelectOption('Cases with CRs', 'Cases with CRs'));

    }

    private void execSearch(String sortByExpression, Integer iLimit)
    {
        
        // VARIABLE INITIALIZATIONS
        lstSearchResults = new List<searchResult>();
		iRecCount = 0;  
        searchResultMsg = '0 records found'; 
        strStartDateLabel = 'Created Start Date:'; 
    	strEndDateLabel = 'Created End Date:'; 
        bSearchCR = false;
        
        // BUILD DYNAMIC SOQL QUERY SEARCH STRING 

        string q = 'SELECT ';
        q += 'Case.Id, ';
        q += 'Case.CaseNumber, ';
        q += 'Case.Account.Name, ';
        q += 'Case.Contact.Name, ';
        q += 'Case.Subject, ';
        q += 'Case.Status, ';
        q += 'Case.Priority, ';
        q += 'Case.DI_Product_Group__c, ';
        q += 'Case.CreatedDate, ';
        q += 'Case.ClosedDate, ';
        q += 'Case.Change_Request__r.Name, ';
        q += 'Case.CR_Public_Status__c, ';
        q += 'Case.Change_Request__r.Public_Status_Description__c, ';
        q += 'Case.Change_Request__r.Title__c ';
        q += 'FROM CaseShare ';
        q += 'WHERE UserOrGroupId =: usrId ';   
        q += 'AND Case.RecordTypeId IN : setRTypes ';
        q += 'AND Case.Origin IN : setOrigins ';
        q += 'AND Case.Type IN : setCTypes ';
         
        
        // MY CASES CONDITIONS =============================================================          
        if (selField == 'My Open Cases')
        {   
            q += 'AND Case.Status != \'Closed\' ';
            q += 'AND Case.ContactId = : usrContactId ';
        }
        
        if (selField == 'My Closed Cases')
        {
            strStartDateLabel = 'Closed Start Date:'; 
            strEndDateLabel = 'Closed End Date:';             
            q += 'AND Case.Status = \'Closed\' ';
            q += 'AND Case.ContactId =: usrContactId ';
        }
        
        if (selField == 'All My Cases')
        {       
            q += 'AND Case.ContactId =: usrContactId ';
        }
        
        // MY PROPERY'S CONDITIONS ==========================================================          
        if (selField == 'My Property\'s Open Cases')
        {   
            q += 'AND Case.Status != \'Closed\' ';
            q += 'AND Case.AccountId = : usrAccountId ';                  
        }
        
        if (selField == 'My Property\'s Closed Cases')
        { 
            strStartDateLabel = 'Closed Start Date:'; 
            strEndDateLabel = 'Closed End Date:';                  
            q += 'AND Case.Status = \'Closed\' ';
            q += 'AND Case.AccountId = : usrAccountId '; 
        }
        
        if (selField == 'All My Property\'s Cases')
        {      
            q += 'AND Case.AccountId = : usrAccountId '; 
        }  
        
        // ALL PROPERY'S CONDITIONS ==========================================================          
        if (selField == 'All Properties\' Open Cases')
        { 
            q += 'AND Case.Status != \'Closed\' ';
        }
        
        if (selField == 'All Properties\' Closed Cases')
        {
            strStartDateLabel = 'Closed Start Date:'; 
            strEndDateLabel = 'Closed End Date:';                  
            q += 'AND Case.Status = \'Closed\' ';
        }
        
        // OTHER CONDITIONS ================================================================== 
        if (selField == 'Cases with CRs')
        {
            strStartDateLabel = 'Closed Start Date:'; 
            strEndDateLabel = 'Closed End Date:';    
            q += 'AND Case.Status IN (\'Closed\', \'Paused - Development Team Review\') ';
            q += 'AND Case.Change_Request__c != null ';
            bSearchCR = true;
        }        

        // CLOSED DATE BETWEEN ===============================================================
        if (dtStartDate != '')
        {
            // SOQL INJECTION PROTECTION
            String strDate1 = string.escapeSingleQuotes(dtStartDate); 

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
               
                if (strStartDateLabel == 'Closed Start Date:')
                {
                    q += 'AND Case.ClosedDate >= ' + strStart + 'T00:00:00.000Z ';
                }
                else
                {
                    q += 'AND Case.CreatedDate >= ' + strStart + 'T00:00:00.000Z ';
                }
				
                 
            }
            catch (Exception ex) {}
                
        }
        
        if (dtEndDate != '')
        {
            // SOQL INJECTION PROTECTION
            String strDate2 = string.escapeSingleQuotes(dtEndDate);   
         
            try
            {
                Date d2 = Date.parse(strDate2);
                d2 = d2.addDays(1);
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
                 
                if (strEndDateLabel == 'Closed End Date:')
                { 
                    q += 'AND Case.ClosedDate < ' + strEnd + 'T00:00:00.000Z ';
                }
                else
                {
                    q += 'AND Case.CreatedDate < ' + strEnd + 'T00:00:00.000Z ';
                }
				
            }
            catch (Exception ex) {}        
        }            

        if (searchText != '')
        {
            
            // SOQL INJECTION PROTECTION
            String strKeyWord = string.escapeSingleQuotes(searchText);     
            
            q += 'AND (Case.CaseNumber LIKE \'%' + strKeyWord + '%\' ';
            q += 'OR Case.Account.Name LIKE \'%' + strKeyWord + '%\' ';
            q += 'OR Case.Contact.Name LIKE \'%' + strKeyWord + '%\' ';
            q += 'OR Case.Status LIKE \'%' + strKeyWord + '%\' ';  
            q += 'OR Case.Priority LIKE \'%' + strKeyWord + '%\' ';  
            q += 'OR Case.DI_Product_Group__c LIKE \'%' + strKeyWord + '%\' ';  
            q += 'OR Case.Subject LIKE \'%' + strKeyWord + '%\') ';  
        }
        
		// ORDER BY 
        if (sortByExpression != null)
        {
            q += 'ORDER BY ' + sortByExpression + ' ';
        }

        q += 'LIMIT ' + String.valueOf(PRIVATE_SOQL_LIMIT_CONST) + ' ';
        
        system.debug(' **** QUERY = ' + q);
        
        strSOQL = q;
        
        Map<Id, String> mapDupeChecker = new Map<Id, String>();
        
        // FILL A LIST OF WRAPPER CLASSES TO DISPLAY RECORDS TO USER
        try 
        {
         
            List<CaseShare> lstResults = Database.query(q);
            Integer iCounter = 0;
            
            if (!lstResults.isEmpty())
            {
                for (CaseShare rs : lstResults)
                {                        
                    if (!mapDupeChecker.containsKey(rs.Case.Id))
                    {                        
                        searchResult x = new searchResult(
                            rs.Case.Id, 
                            rs.Case.CaseNumber,                         
                            rs.Case.Account.Name, 
                            rs.Case.Contact.Name, 
                            rs.Case.Subject, 
                            rs.Case.Status, 
                            rs.Case.Priority, 
                            rs.Case.DI_Product_Group__c, 
                            rs.Case.CreatedDate, 
                            rs.Case.ClosedDate,
                            rs.Case.Change_Request__r.Name, 
                            rs.Case.CR_Public_Status__c,
                            rs.Case.Change_Request__r.Public_Status_Description__c, 
                            rs.Case.Change_Request__r.Title__c                           
                        ); 
                        
                        iCounter += 1;
                        
                        if (iCounter <= iLimit)
                        {               
                            lstSearchResults.add(x);
                        }
                        
                        iRecCount++; 
                        
                        mapDupeChecker.put(rs.Case.Id, rs.Case.CaseNumber); 
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
        }
        catch (Exception ex)
        {
            lstSearchResults.clear();
            searchResultMsg = 'An error occurred while performing search. Please try again and report to Amadeus Hospitality CustomerCentral administration if error persists.'; 
			String strDetails = 'Error occurred in execSearch() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
//            NI_Error_Logger.WriteToLog(strDetails, 'CustomerCentral', 'AH_CC_CaseViewer_Ctlr', 'Insert'); 
        }       
     
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
	
    public pageReference exportResults()
    {        

        PageReference pr = null;
        Id fileId;
       
        // BUILD UNIQUE FILENAME
        DateTime dt = system.now();
        String strFileName = 'MyCaseExport-';
        strFileName += String.valueOf(dt.Year()) + String.valueOf(dt.Month()) + String.valueOf(dt.Day()) + '-';
        strFileName += String.valueOf(dt.Hour()) + String.valueOf(dt.Minute()) + String.valueOf(dt.Second());

        // BUILD CSV HEADERS
        String strHeader = '';
        strHeader += 'Case Number,';
        strHeader += 'Account Name,';
        strHeader += 'Contact Name,';
        strHeader += 'Case Subject,';
        strHeader += 'Status,';
        strHeader += 'Priority,';
        strHeader += 'Product Group,';
        strHeader += 'Created Date,';
        strHeader += 'Closed Date,';
        strHeader += 'Case Link';
        if (bSearchCR)
        { 
            strHeader += ',CR Number';
            strHeader += ',CR Title';
            strHeader += ',CR Status';
            strHeader += ',CR Status Description';
        }
        
        // BUILD CSV ROWS
        List<String> lst = new List<String>();

        for (searchResult sr : lstSearchResults)
        {
            String strBuilder = '';
            strBuilder += sr.CaseNumber + ',';
            strBuilder += sr.AccountName.replace(',', '') + ','; 
            if (sr.ContactName != null)
            {
                strBuilder += sr.ContactName.replace(',', '') + ','; 
            }
            else
            {
                strBuilder += 'No Contact Specified,';
            }           
            strBuilder += sr.Subject.replace(',', '') + ','; 
            strBuilder += sr.Status + ',';
            strBuilder += sr.Priority + ',';             
            strBuilder += sr.ProductGroup + ',';   
            strBuilder += sr.CreatedDate + ',';  
            strBuilder += sr.ClosedDate + ',';
            strBuilder += 'https://amadeus-community.force.com/customers/' + sr.CaseId; 
            if (bSearchCR)
            { 
                strBuilder += ',' + sr.CRNumber;             
                strBuilder += ',' + sr.CRTitle;   
                strBuilder += ',' + sr.CRStatus;  
                strBuilder += ',' + sr.CRLegendText;                
            }

            lst.add(strBuilder);
        }

//        if (isCustomerUser)
//        {

            // GET PARTNER CENTRAL COMMUNITY ID
            Id communityID = [SELECT Id FROM Network WHERE Name = 'Customer Central' LIMIT 1].Id;
            
            // CREATE CSV FILE
            //fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, usrId, communityID);
            fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, usrId, null);
            
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
	//  WRAPPER CLASSES 
    // ================================================================================================================================
    public class searchResult
    {    

        public Id CaseId {get; set;}
        public String CaseNumber {get; set;}
        public String AccountName {get; set;}        
        public String ContactName {get; set;}
        public String Subject {get; set;}
        public String Status {get; set;}
        public String Priority {get; set;}
        public String ProductGroup {get; set;}
        public Datetime CreatedDate {get; set;}
        public Datetime ClosedDate {get; set;}
        public String CRNumber {get; set;}
        public String CRStatus {get; set;}
        public String CRLegendText {get; set;}
        public String CRTitle {get; set;}                         

        public searchResult (Id i1, String s1, String s2, string s3, String s4, String s5, String s6, String s7, Datetime d1, Datetime d2, String s8, String s9, String s10, String s11)
        {
            this.CaseId = i1; 
            this.CaseNumber = s1;
            this.AccountName = s2;       
            this.ContactName = s3;
            this.Subject = s4;
            this.Status = s5;
            this.Priority = s6;
            this.ProductGroup = s7;
            this.CreatedDate = d1;
            this.ClosedDate = d2;
            this.CRNumber = s8;
        	this.CRStatus = s9;
            this.CRLegendText = s10;
            this.CRTitle = s11;
        }
        
    }    
    
}