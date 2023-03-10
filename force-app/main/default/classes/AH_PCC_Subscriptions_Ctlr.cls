/****************************************************************************************
Name            : AH_PCC_Subscriptions_Ctlr
Author          : Sean Harris
Created Date    : 03/27/2019
Last Mod Date   : 03/27/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : Controller for the AH_PCC_Subscriptions Visualforce page.
                :            
******************************************************************************************/
public class AH_PCC_Subscriptions_Ctlr 
{

    // LIMIT CONSTANTS =======================================  
    private final Integer PRIVATE_MAX_CHECKED_CONST = 10;		// SETS AMOUNT RECORDS TO ALLOW BULK UPDATED TO
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
    public String selectedMsg {get; set;}
    public String toastMsg {get; set;}
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;} 
    public String selField {get; set;}
    // NUMERICS
    public Integer iRecCount {get; set;}
    public Integer iCheckedCount {get; set;}
    // BOOLEANS
    public Boolean checkAll {get; set;}
    public Boolean displayDialog1 {get; set;}
    public Boolean showRedMsg {get; set;}
    public Boolean isSuccess {get; set;}
    public Boolean reachedCheckedLimit {get; set;}
    public Boolean isQuantity {get; set;}
    public Boolean isLiveDate {get; set;}
    public Boolean isAccount {get; set;}
    public Boolean hasChatterGroup {get; set;}

    // PRIVATE VARIABLES ====================================
    private User runningUser {get; set;}
	private Boolean isPartnerUser {get; set;} 
    private Id gId; 
    
    
    public AH_PCC_Subscriptions_Ctlr()
    {
        
        system.debug(' *** ENTERING AH_PCC_Subscriptions_Ctlr() - CONSTRUCTOR');        

        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();
        
        // EXECUTE INITIAL LIMITED QUERY
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_INITIAL_MAX_CONST);
        
        system.debug(' *** EXITING AH_PCC_Subscriptions_Ctlr() - CONSTRUCTOR');        
        
    }
    
    
    // ================================================================================================================================
	//  FUNCTIONS & METHODS     
    // ================================================================================================================================

    private void initVariables()
    {
        searchText = ''; 
        toastMsg = '';
        sortByField = 'CreatedDate';
        sortByDirection = 'ASC';
        iCheckedCount = 0;
        displayDialog1 = false;   
        isPartnerUser = false;
        isSuccess = false;
        reachedCheckedLimit = false;
        showRedMsg = false;
		hasChatterGroup = false;
        gId = null;
        isPartnerUser = false;
        
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
        
        // VARIABLE INITIALIZATIONS
        lstSearchResults = new List<searchResult>();
		iRecCount = 0;  
        searchResultMsg = '0 records found';
        checkAll = false;
        
        // BUILD DYNAMIC SOQL QUERY SEARCH STRING 
        string q = 'SELECT ';
        q += 'Id, '; 
        q += 'Name, '; 
        q += 'Status__c, '; 
        q += 'CreatedDate, ';
        q += 'Product_Code__c, '; 
        q += 'Product_Name__c, '; 
        q += 'Account__c, '; 
        q += 'Account_Number_Formula__c, '; 
        q += 'Account_Name_Formula__c, '; 
        q += 'Opportunity_Number_Formula__c, '; 
        q += 'Activity_Line_Item__c, ';
        q += 'Backlog_Quantity__c ';
        q += 'FROM Subscription_Activation__c ';
        q += 'WHERE Backlog_Quantity__c != 0 ';
		
        if (isPartnerUser)
        {
            q += 'AND Partner_Name__c = \'' + runningUser.AccountId + '\' ';
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
                q += 'OR Product_Code__c LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Product_Name__c LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Account_Number_Formula__c LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Account_Name_Formula__c LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Opportunity_Number_Formula__c LIKE \'%' + strKeyWord + '%\') ';   
            }
        }
        
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
         
            List<Subscription_Activation__c> lstResults = Database.query(q);
            Integer iCounter = 0;
            
            if (!lstResults.isEmpty())
            {
                for (Subscription_Activation__c rs : lstResults)
                {                   
                    searchResult x = new searchResult(
                        rs.Id, 
                        rs.Name, 
                        rs.Status__c, 
                        rs.CreatedDate, 
                        rs.Product_Code__c, 
                        rs.Product_Name__c, 
                        rs.Account__c, 
                        rs.Account_Number_Formula__c, 
                        rs.Account_Name_Formula__c, 
                        rs.Opportunity_Number_Formula__c, 
                        rs.Activity_Line_Item__c, 
                        rs.Backlog_Quantity__c, 
                        null,
                        null, 
                        null,
                        true,
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
            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'AH_PCC_Subscriptions_Ctlr', 'Insert'); 
        }       
     
    }

    private Boolean execSave()
    {

        Boolean isSuccess = true; 
		Boolean foundViolation = false; 
        isQuantity = false; 
        isLiveDate = false; 
        isAccount = false; 
        
        // FIELD VALIDATION (START) ===============================================================================================
        // QUANTITY
        for (searchResult sr : lstSelectedResults)
        { 
            sr.isValid = true;
            if (sr.QuantityEntered == 0 || sr.QuantityEntered == null)
            {
                foundViolation = true; 
                isQuantity = true;
                sr.isValid = false; 
            }
        }        
        
        if (foundViolation)
        {
            selectedMsg = 'Quantity has to be greater than 0 and may not be blank. Please correct and resubmit.';  
            return false; 
        }
        
        // LIVE DATE
        for (searchResult sr : lstSelectedResults)
        {   
            sr.isValid = true;
            if (sr.DateEntered == null || String.valueOf(sr.DateEntered) == '') 
            {
                foundViolation = true;
                isLiveDate = true; 
                sr.isValid = false;
            }
        }
        
        if (foundViolation)
        {
            selectedMsg = 'Live Date cannot be blank. Please correct and resubmit.';  
            return false;
        }
        
        // ACCOUNT NAME
        for (searchResult sr : lstSelectedResults)
        {
            sr.isValid = true;
            if (sr.AccountNameEntered == '' || sr.AccountNameEntered == null)
            {
                foundViolation = true;
                isAccount = true; 
                sr.isValid = false;                  
            }
        }
        
        if (foundViolation)
        {
            selectedMsg = 'For Account cannot be blank. Please correct and resubmit.'; 
            return false;
        }

        // FIELD VALIDATION ( END ) ===============================================================================================
                
        List<Subscription_Activation_Transaction__c> lstSATInserts = new List<Subscription_Activation_Transaction__c>();
        
        if (lstSelectedResults.size() > 0)
        {
            for (searchResult sr : lstSelectedResults)
            {              
                if (sr.isChecked)
                { 
                    Subscription_Activation_Transaction__c sat = new Subscription_Activation_Transaction__c();
                    sat.Date__c = Date.parse(sr.DateEntered);
                    sat.Quantity__c = sr.QuantityEntered;
                    sat.Related_Account_Partner_Updated__c = sr.AccountNameEntered;
                    sat.Subscription_Activation_No__c = sr.SubActId;
                    sat.Related_Account__c = sr.AccountId;
					lstSATInserts.add(sat); 
                }
            }
        }         

        try
        {
            database.insert(lstSATInserts);
            isSuccess = true;
        }
        catch (Exception ex)
        {
            selectedMsg = 'An error occurred while submitting these updates. Please try again and report to Amadeus Hospitality PartnerCentral administration if error persists.'; 
			String strDetails = 'Error occurred in execSave() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'AH_PCC_Subscriptions_Ctlr', 'Insert'); 
            isSuccess = false;
        }
        
        return isSuccess;
        
    }

    private void fillPicklists()
    {
        
    	lstSearchFields = new List<SelectOption>();
        selField = 'ALL FIELDS';
        lstSearchFields.add(new SelectOption('ALL FIELDS', 'ALL FIELDS'));
        lstSearchFields.add(new SelectOption('Name', 'Subcription #'));
        lstSearchFields.add(new SelectOption('Product_Code__c', 'Product Code'));
        lstSearchFields.add(new SelectOption('Product_Name__c', 'Product Name'));
        lstSearchFields.add(new SelectOption('Account_Number_Formula__c', 'Account Number'));
        lstSearchFields.add(new SelectOption('Account_Name_Formula__c', 'Account Name'));
        lstSearchFields.add(new SelectOption('Opportunity_Number_Formula__c', 'Opportunity Number'));

    }
    
    public void doSearch() 
    {
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_RESULT_MAX_CONST);
    }

    public void doChecks() 
    {
        if (lstSearchResults.size() > 0)
        {
            for (searchResult sr : lstSearchResults)
            {
                sr.isChecked = checkAll;
            }
        }
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
    
    // ================================================================================================================================
    //  DIALOG METHODS 
    // ================================================================================================================================
    public void showDialog1() 
    {
        
        // VARIABLE INITIALIZATIONS
        showRedMsg = false;
        lstSelectedResults = new List<searchResult>();
        selectedMsg = '';
        iCheckedCount = 0;
        isSuccess = false;
        reachedCheckedLimit = false;
        
        if (lstSearchResults.size() > 0)
        {
            for (searchResult sr : lstSearchResults)
            {
                if (sr.isChecked)
                {
        			sr.QuantityEntered = 1; 
        			sr.DateEntered = system.Date.today().format();
                    lstSelectedResults.add(sr);
                    iCheckedCount++;
                }
            }
        } 

        if (lstSelectedResults.size() == 1)
        {
            selectedMsg = ''; 
        }
        
        if (lstSelectedResults.isEmpty())
        {
            selectedMsg = 'Please select Subscription Activation record(s) in Search results before clicking Enter Live Date button.';
            showRedMsg = true;
        }
        
        if (iCheckedCount > PRIVATE_MAX_CHECKED_CONST)
        {
            selectedMsg = 'Due to platform restrictions you cannot process more that ' + String.valueOf(PRIVATE_MAX_CHECKED_CONST) + ' records at a time.';
            showRedMsg = true;  
            reachedCheckedLimit = true;
        }
        
        displayDialog1 = true; 
        
    }  
    
    public void hideDialog1() 
    {  
        displayDialog1 = false;  
        isSuccess = false;
        toastMsg = '';
    }       

    public void submitDialog1() 
    {      

        isSuccess = false;
        toastMsg = '';   
        showRedMsg = false;
        selectedMsg = '';
        
        Boolean bSuccessful = execSave(); 
        
        if (bSuccessful) 
        {
            toastMsg = 'Save was successful!';
            isSuccess = true;
            doSearch(); 
            displayDialog1 = false; 
        } 
        else
        {
            showRedMsg = true;
            displayDialog1 = true; 
        }
        
    }   
    
    public void hideSuccess() 
    {      
        showRedMsg = false;
        isSuccess = false;
        toastMsg = '';
    }  
    
    // EXPORT METHODS
    public pageReference exportResults()
    {        
        
        system.debug(' *^* exportResults');
        
        PageReference pr = null;
        Id fileId;
        
        // BUILD UNIQUE FILENAME
        DateTime dt = system.now();
        String strFileName = 'SubsActivationExport-';
        strFileName += String.valueOf(dt.Year()) + String.valueOf(dt.Month()) + String.valueOf(dt.Day()) + '-';
        strFileName += String.valueOf(dt.Hour()) + String.valueOf(dt.Minute()) + String.valueOf(dt.Second());
                
        // BUILD CSV HEADERS
        String strHeader = '';
        strHeader += 'Subscription #,';
        strHeader += 'Units,';
        strHeader += 'Product Code,';
        strHeader += 'Product Name,';
        strHeader += 'Status,';
        strHeader += 'Account #,';
        strHeader += 'Account Name,';
        strHeader += 'Opportunity #';
        
        // BUILD CSV ROWS
        List<String> lst = new List<String>();
        
        for (searchResult sr : lstSearchResults)
        {
            String strBuilder = '';
            strBuilder += sr.SubActName + ',';
            strBuilder += String.valueOf(sr.BacklogQuantity).replace(',', '') + ','; 
            strBuilder += sr.ProductCode + ','; 
            strBuilder += sr.ProductName.replace(',', '') + ','; 
            strBuilder += sr.SubActStatus + ','; 
            strBuilder += sr.AccountNumber + ',';
            strBuilder += sr.AccountName.replace(',', '') + ',';             
            strBuilder += sr.OpportunityNumber; 
            lst.add(strBuilder);
        }

        if (isPartnerUser)
        {
            
            // GET PARTNER'S COMMUNTY CHATTER GROUP ID 
            List<Account> lstAcc = new List<Account>([SELECT Id, Partner_Chatter_Group_ID__c 
                                                      FROM Account 
                                                      WHERE Partner_Chatter_Group_ID__c != null 
                                                      AND Id =: runningUser.AccountId]);
            
            if (lstAcc.isEmpty())
            {
                // RAISE A USER-FREINDLY ERROR HERE
                return pr;
            }
            
            Id gId = (Id)lstAcc[0].Partner_Chatter_Group_ID__c;
            
            // GET PARTNER CENTRAL COMMUNITY ID
            Id communityID = [SELECT Id FROM Network WHERE Name = 'PartnerCentral' LIMIT 1].Id;
            
            // CREATE CSV FILE
            fileId = AH_UTIL_FileHandler.createCSV_File(strFileName, strHeader, lst, gId, communityID);
            
            // CREATE NEW CHATTER POST
            FeedItem f = new FeedItem();
            // ASSIGN COLLABORATION GROUP THAT IS ON PARTNER ACCOUNT
            f.ParentId = gId;
            // ASSIGN POST TITLE
            f.Title = 'Subscription Activation Export for ' + runningUser.FirstName + ' ' + runningUser.LastName;
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
	//  WRAPPER CLASSES 
    // ================================================================================================================================
    public class searchResult
    {    

        public Id SubActId {get; set;}
        public String SubActName {get; set;}
        public String SubActStatus {get; set;}
        public Datetime SubActCreatedDate {get; set;}
        public String ProductCode {get; set;}
        public String ProductName {get; set;}
        public Id AccountId {get; set;}
        public String AccountNumber {get; set;}
        public String AccountName {get; set;}
        public String OpportunityNumber {get; set;} 
        public Id ActivityLineItemId {get; set;}
        public Decimal BacklogQuantity {get; set;}
        public Decimal QuantityEntered {get; set;}  
        public String DateEntered {get; set;}  
        public String AccountNameEntered {get; set;}
        public Boolean isValid {get; set;}
        public Boolean isChecked {get; set;}

        public searchResult (Id p1, String p2, String p3, Datetime p4, String p5, String p6, Id p7, String p8, String p9, String p10, 
                             Id p11, Decimal p12, Decimal p13, String p14, String p15, Boolean isValid, Boolean isChecked)
        {
            this.SubActId = p1; 
            this.SubActName = p2; 
            this.SubActStatus = p3; 
            this.SubActCreatedDate = p4; 
            this.ProductCode = p5; 
            this.ProductName = p6; 
            this.AccountId = p7; 
            this.AccountNumber = p8; 
            this.AccountName = p9; 
            this.OpportunityNumber = p10; 
            this.ActivityLineItemId = p11;
            this.BacklogQuantity = p12;
            this.QuantityEntered = p13;
            this.DateEntered = p14;
            this.AccountNameEntered = p15;
            this.isValid = isValid;
            this.isChecked = isChecked;
        }
        
    }    
    
}