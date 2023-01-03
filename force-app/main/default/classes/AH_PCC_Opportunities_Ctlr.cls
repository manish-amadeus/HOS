/****************************************************************************************
Name            : AH_PCC_Opportunities_Ctlr
Author          : Sean Harris
Created Date    : 03/27/2019
Last Mod Date   : 10/10/2019
Last Mod By     : Stuart Emery
NICC Reference  : NICC-033935
Description     : Controller for the AH_PCC_Opportunities Visualforce page.
                : UPDATED 10/10/2019 PER NICC-037848           
******************************************************************************************/
public class AH_PCC_Opportunities_Ctlr 
{
    
    // LIMIT CONSTANTS ======================================= 
    private final Integer PRIVATE_SOQL_LIMIT_CONST = 10000;		// SETS OVERALL LIMIT TO SEARCH QUERY ISSUED
    private final Integer PRIVATE_RESULT_MAX_CONST = 1000;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN RESULTS
    private final Integer PRIVATE_INITIAL_MAX_CONST = 25;		// SETS NUMBER OF RECORDS THAT WILL BE LOADED IN FRESH PAGE
    
    // PUBLIC VARIABLES ======================================
    // COLLECTIONS
    public List<searchResult> lstSearchResults {get; set;} 
    public List<SelectOption> lstSearchFields {get; set;} 
    public List<SelectOption> lstStages {get; set;}     
    // STRINGS
    public String searchText {get; set;}
    public String searchResultMsg {get; set;} 
    public String sortByField {get; set;}    
    public String sortByDirection {get; set;}  
    public String selField {get; set;}
    public String selStage {get; set;} 
    public String closeDateStart {get; set;}  
    public String closeDateEnd {get; set;}   
    // NUMERICS
    public Integer iRecCount {get; set;}
    // BOOLEANS
    public Boolean checkAll {get; set;}
    public Boolean hasChatterGroup {get; set;}
    
    // PRIVATE VARIABLES ====================================
    private User runningUser {get; set;}
	private Boolean isPartnerUser {get; set;}  
    private Id gId; 
    
    
    public AH_PCC_Opportunities_Ctlr()
    {
        
        system.debug(' *** ENTERING AH_PCC_Opportunities_Ctlr() - CONSTRUCTOR');        
        
        // VARIABLE INITIALIZATIONS
		initVariables();
        
		// PICKLIST INITIALIZATIONS
        fillPicklists();
        
        // EXECUTE INITIAL LIMITED QUERY
        execSearch(sortByField + ' ' + sortByDirection, PRIVATE_INITIAL_MAX_CONST);
        
        system.debug(' *** EXITING AH_PCC_Opportunities_Ctlr() - CONSTRUCTOR');        
        
    }
    
    // ================================================================================================================================
    //  FUNCTIONS & METHODS ===========================================================================================================    
    // ================================================================================================================================

    private void initVariables()
    {
        searchText = ''; 
        sortByField = 'Opportunity.CloseDate';
        sortByDirection = 'DESC';
		isPartnerUser = false;
        selStage = 'ALL STAGES';
        hasChatterGroup = false;
        gId = null;
		isPartnerUser = false;
        closeDateStart = '';
        closeDateEnd = '';
        
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
      
        // BUILD DYNAMIC SOQL QUERY SEARCH STRING 
        string q = 'SELECT ';
        q += 'Id, ';
        q += 'Quantity, ';
        q += 'Opportunity.Id, ';
        q += 'Product2.ProductCode, ';
        q += 'Product2.Name, ';
        q += 'Opportunity.Account.AccountNumber, ';
        q += 'Opportunity.Account.Name, ';
        q += 'Opportunity.Account.Management_Company_Name__c, ';
        q += 'Opportunity.Opportunity_Number__c, ';
        q += 'Opportunity.Name, ';
        q += 'Opportunity.CloseDate, ';
        q += 'Opportunity.StageName, ';
        q += 'Opportunity.Owner.Name, ';
        q += 'Opportunity.AccountId, '; 
        q += 'Opportunity.Account.ShippingStreet, '; 
        q += 'Opportunity.Account.ShippingCity, '; 
        q += 'Opportunity.Account.ShippingState, '; 
        q += 'Opportunity.Account.ShippingPostalCode, '; 
        q += 'Opportunity.Account.ShippingCountry '; 
        q += 'FROM OpportunityLineItem ';
        q += 'WHERE OpportunityId != null ';
        q += 'AND (Order_of_Delivery__c = null OR Order_of_Delivery__c = 1) ';
        
        if (isPartnerUser)
        {
            q += 'AND Product2.Partner_Name__c = \'' + runningUser.AccountId + '\' ';
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
                q += 'AND (Product2.ProductCode LIKE \'%' + strKeyWord + '%\' ';
                q += 'OR Product2.Name LIKE \'%' + strKeyWord + '%\' '; 
                q += 'OR Opportunity.Account.AccountNumber LIKE \'%' + strKeyWord + '%\' '; 
                q += 'OR Opportunity.Account.Name LIKE \'%' + strKeyWord + '%\' '; 
                q += 'OR Opportunity.Account.Management_Company_Name__c LIKE \'%' + strKeyWord + '%\' ';  
                q += 'OR Opportunity.Name LIKE \'%' + strKeyWord + '%\' '; 
                q += 'OR Opportunity.Opportunity_Number__c LIKE \'%' + strKeyWord + '%\' ';   
                q += 'OR Opportunity.Owner.Name LIKE \'%' + strKeyWord + '%\') ';   
            }
  
        }

        // OPPORTUNITY STAGE
        if (selStage == 'ALL STAGES')
        {
            q += 'AND Opportunity.StageName IN (\'Closed Won\', \'Proposal Requested - 60%\', \'Validate and Select - 80%\') ';
        }
        if (selStage == 'Open Only')
        {
            q += 'AND Opportunity.StageName IN (\'Proposal Requested - 60%\', \'Validate and Select - 80%\') ';
        }
        if (selStage == 'Closed Only')
        {
            q += 'AND Opportunity.StageName = \'Closed Won\' ';
        }  

        if (closeDateStart != '')
        {
            // SOQL INJECTION PROTECTION
            String strDate1 = string.escapeSingleQuotes(closeDateStart); 

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
               
				q += 'AND Opportunity.CloseDate >= ' + strStart + ' ';
                 
            }
            catch (Exception ex) {}
                
        }
        
        if (closeDateEnd != '')
        {
            // SOQL INJECTION PROTECTION
            String strDate2 = string.escapeSingleQuotes(closeDateEnd);   
         
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
                 
				q += 'AND Opportunity.CloseDate <= ' + strEnd + ' '; //UPDATED 10/10/2019 PER NICC-037848
              
            }
            catch (Exception ex) {}        
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
            
            List<OpportunityLineItem> lstResults = Database.query(q);
            Integer iCounter = 0;
            String strOppPercent = '';
            
            if (!lstResults.isEmpty())
            {
                for (OpportunityLineItem rs : lstResults)
                {   
                    
                    strOppPercent = rs.Opportunity.StageName;
                    
                    if (strOppPercent.Contains('60'))
                    {
                        strOppPercent = '60%';
                    }
                    else
                    {
                        if (strOppPercent.Contains('80'))
                        {
                            strOppPercent = '80%';
                        } 
                        else
                        {
                            strOppPercent = '100%';
                        }
                    }
                    
					// PARSE PHYSICAL ADDRESS
                    String sStreet = '';
                    String sCity = '';
                    String sState = '';
                    String sZip = '';
                    String sCountry = '';
                    
                    if (rs.Opportunity.Account.ShippingStreet != null)
                    {
                        sStreet = rs.Opportunity.Account.ShippingStreet;
                    }
                    if (rs.Opportunity.Account.ShippingCity != null)
                    {
                        sCity = rs.Opportunity.Account.ShippingCity;
                    }
                    if (rs.Opportunity.Account.ShippingState != null)
                    {
                        sState = rs.Opportunity.Account.ShippingState;
                    }
                    if (rs.Opportunity.Account.ShippingPostalCode != null)
                    {
                        sZip = rs.Opportunity.Account.ShippingPostalCode;
                    }
                    if (rs.Opportunity.Account.ShippingCountry != null)
                    {
                        sCountry = rs.Opportunity.Account.ShippingCountry;
                    }
                    
                    physicalAddress pa = new physicalAddress(
                        rs.Opportunity.AccountId,  
                        sStreet, 
                        sCity, 
                        sState, 
                        sZip,
                        sCountry);
                    
                    searchResult x = new searchResult(
                        rs.Opportunity.Id, 
                        rs.Quantity, 
                        rs.Product2.ProductCode, 
                        rs.Product2.Name, 
                        rs.Opportunity.Account.AccountNumber, 
                        rs.Opportunity.Account.Name, 
                        rs.Opportunity.Account.Management_Company_Name__c, 
                        rs.Opportunity.Opportunity_Number__c, 
                        rs.Opportunity.Name, 
                        rs.Opportunity.CloseDate, 
                        strOppPercent, 
                        rs.Opportunity.Owner.Name, 
                        pa, 
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
            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'AH_PCC_Opportunities_Ctlr', 'Insert'); 
        } 
        
    }

    private void fillPicklists()
    {

        lstSearchFields = new List<SelectOption>();
        selField = 'ALL FIELDS';
        lstSearchFields.add(new SelectOption('ALL FIELDS', 'ALL FIELDS'));
        lstSearchFields.add(new SelectOption('Opportunity.Account.Name', 'Account Name'));
        lstSearchFields.add(new SelectOption('Opportunity.Account.AccountNumber', 'Account Number'));
        lstSearchFields.add(new SelectOption('Opportunity.Owner.Name', 'Sales Manager'));  
        lstSearchFields.add(new SelectOption('Opportunity.Opportunity_Number__c', 'Opportunity Number'));
        lstSearchFields.add(new SelectOption('Opportunity.Account.Management_Company_Name__c', 'Management Company'));
        lstSearchFields.add(new SelectOption('Product2.Name', 'Product Name'));
        lstSearchFields.add(new SelectOption('Product2.ProductCode', 'Product SKU'));
        
        lstStages = new List<SelectOption>();
        selStage = 'ALL STAGES';
        lstStages.add(new SelectOption('ALL STAGES', 'ALL STAGES'));
        lstStages.add(new SelectOption('Open Only', 'Open Only'));
        lstStages.add(new SelectOption('Closed Only', 'Closed Only'));

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
        String strFileName = 'OpportunityExport-';
        strFileName += String.valueOf(dt.Year()) + String.valueOf(dt.Month()) + String.valueOf(dt.Day()) + '-';
        strFileName += String.valueOf(dt.Hour()) + String.valueOf(dt.Minute()) + String.valueOf(dt.Second());
                
        // BUILD CSV HEADERS
        String strHeader = '';
        strHeader += 'Opportunity #,';
        strHeader += 'Quantity,';
        strHeader += 'Product Code,';
        strHeader += 'Product Name,';
        strHeader += 'Management Company,';        
        strHeader += 'Account #,';
        strHeader += 'Account Name,';
        strHeader += 'Probability,';
        strHeader += 'Close Date,';
        strHeader += 'Sales Manager,';
        strHeader += 'Street,';
        strHeader += 'City,';
        strHeader += 'State,';
        strHeader += 'Zipcode,';
        strHeader += 'Country';
        
        // BUILD CSV ROWS
        List<String> lst = new List<String>();
        
        for (searchResult sr : lstSearchResults)
        {
            String strBuilder = '';
            strBuilder += sr.OpportunityNumber + ',';
            strBuilder += sr.Quantity + ','; 
            strBuilder += sr.ProductCode + ','; 
            strBuilder += sr.ProductName.replace(',', '') + ','; 
            if (sr.MgtCompanyName != null)
            {
                strBuilder += sr.MgtCompanyName.replace(',', '') + ','; 
            }
            else
            {
                strBuilder += ','; 
            }
            strBuilder += sr.AccountNumber + ',';
            strBuilder += sr.AccountName.replace(',', '') + ',';             
            strBuilder += sr.OpportunityProbability + ','; 
            strBuilder += sr.OpportunityCloseDate + ','; 
            strBuilder += sr.SalesManager + ','; 
            strBuilder += sr.pAddress.ShippingStreet + ','; 
            strBuilder += sr.pAddress.ShippingCity + ',';  
            strBuilder += sr.pAddress.ShippingState + ',';  
            strBuilder += sr.pAddress.ShippingPostalCode + ','; 
            strBuilder += sr.pAddress.ShippingCountry; 
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
            f.Title = 'Opportunity Export for ' + runningUser.FirstName + ' ' + runningUser.LastName;
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
        public Id OpportunityId {get; set;}
        public String ProductCode {get; set;}
        public String ProductName {get; set;}
        public String AccountNumber {get; set;}
        public String AccountName {get; set;}
        public String MgtCompanyName {get; set;}
        public String OpportunityNumber {get; set;}
        public String OpportunityName {get; set;}
        public Date OpportunityCloseDate {get; set;}
        public String OpportunityProbability {get; set;}
        public String SalesManager {get; set;} 
        public Decimal Quantity {get; set;} 
        public physicalAddress pAddress {get; set;} 
        public Boolean isChecked {get; set;}

        public searchResult (Id p1, Decimal qty, String p2, String p3, String p4, String p5, String p6, String p7, String p8, Date p9, String p10, String p11, physicalAddress p12, Boolean isChecked)
        {
            this.OpportunityId = p1;
            this.Quantity = qty;
            this.ProductCode = p2;
            this.ProductName = p3;
            this.AccountNumber = p4;            
            this.AccountName = p5;
            this.MgtCompanyName = p6;
            this.OpportunityNumber = p7;
            this.OpportunityName = p8;
            this.OpportunityCloseDate = p9; 
            this.OpportunityProbability = p10;
            this.SalesManager = p11;
            this.pAddress = p12;
            this.isChecked = isChecked;
        }
        
    }  

    public class physicalAddress
    {  
        public Id accountId {get; set;}
    	public String ShippingStreet {get; set;}
        public String ShippingCity {get; set;} 
        public String ShippingState {get; set;}
        public String ShippingPostalCode {get; set;}
        public String ShippingCountry {get; set;}

        public physicalAddress(Id p1, String p2, String p3, String p4, String p5, String p6)
        {
            this.accountId = p1;
            this.ShippingStreet = p2;
            this.ShippingCity = p3;
            this.ShippingState = p4;
            this.ShippingPostalCode = p5;
            this.ShippingCountry = p6;
        }
    }

}