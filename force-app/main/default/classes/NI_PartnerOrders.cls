/****************************************************************************************
Name            : NI_PartnerOrders Class
Author          : Suzanne LeDuc
Created Date    : 08/07/2017
Last Mod Date   : 04/13/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-023514
Description     : Controller for the NI_PartnerOrder Visualforce page.
                : 
******************************************************************************************/
public class NI_PartnerOrders 
{

    // PUBLIC VARIABLES 
    public List<readOnlyResults> lineItemResults {get; set;} 
    public String searchText {get; set;}
    public User partnerUser {get; set;}
    public String countWarning {get; set;} 
    public Date dtClosedDateStart {get; set;}
    public Integer iRecCount {get; set;}
    
    // PRIVATE VARIABLES 
    private final Integer PRIVATE_LIMIT_CONST = 200;		// SETS SOQL QUERY LIMIT
    private Boolean isNotParterUser; 
    private String sortDirection;
    private String sortExp; 
    
    
    // CONSTRUCTOR
    public NI_PartnerOrders() 
    {
        
system.debug(' **** ENTERING NI_PartnerOrders CONSTRUCTOR');        
        
        searchText = '';
        sortDirection = 'DESC';
        sortExp = 'op.Opportunity.CloseDate'; 
        isNotParterUser = false;
        
        // GET USER DETAILS
        partnerUser = [SELECT Id, AccountId, IsActive, UserType, FirstName, LastName   
                       FROM User 
                       WHERE Id =: UserInfo.getUserId()];

        // IF THE USER IS NOT ACTIVE RETURN
        if (partnerUser.IsActive == false)
        {
            return;
        }
        
        // IF AN INTERNAL USER IS VISITING THE PAGE SET isNotParterUser TO TRUE
        if ((partnerUser.AccountId == null) && (partnerUser.UserType == 'Standard'))
        {
            isNotParterUser = true;
        }

        // SET DEFAULT MIN OPPORTUNITY CLOSE DATE
        Date dtToday = date.today(); 				// GET THE CURRENT DATE OF THE RUNNING USER
        Integer intOppMonths = 12; 					// SET A DEFAULT VALUE IF THERE IS NO VALUE SET IN THE CUSTOM SETTING
        Integer intOppMonthsNegative;        
        intOppMonthsNegative = intOppMonths * -1;  	// CONVERT THE INTEGER TO A NEGATIVE NUMBER TO SET THE NUMBER OF MONTHS TO GO BACK
        dtClosedDateStart = dtToday.AddMonths(intOppMonthsNegative);          
        
        // POPULATE LINE ITEM GRID ON FIRST PAGE LOAD
        lineItemResults = new List<readOnlyResults>();
        queryLineItems(sortExp + ' ' + sortDirection, PRIVATE_LIMIT_CONST);         
        
    }
        
    
    // SORTING & NAVIGATION ==========================================================================================================
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
            {
                sortDirection = (sortDirection == 'ASC') ? 'DESC' : 'ASC';
            }               
            else
            {
                sortDirection = 'ASC';
            }                
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        // if not column is selected 
        if (sortExpression == null || sortExpression == '')
        {
            return 'ASC';
        }  
        else
        {
            return sortDirection;
        }            
    }
    
    public void setSortDirection(String value)
    {  
        sortDirection = value;
    }

    
	// FUNCTIONS =====================================================================================================================     
    public PageReference runSearch() 
    {
        queryLineItems('op.Opportunity.Account.Name, op.Opportunity.Name', PRIVATE_LIMIT_CONST);
        return null;
    }
    
    public PageReference ViewData() 
    {

        // build the full sort expression
        string sortFullExp = sortExpression  + ' ' + sortDirection;
       
        // query the database based on the sort expression
        queryLineItems(sortFullExp, PRIVATE_LIMIT_CONST);

        return null;
        
    }

    private void queryLineItems(String sortOrder, Integer iLimit)
    {
        
        lineItemResults = new List<readOnlyResults>();
        iRecCount = 0;
        countWarning = '';

        string strSOQL = 'SELECT op.Id, op.Quantity, op.UnitPrice, op.TotalPrice, op.ServiceDate, op.Projected_Go_Live__c, op.LOD_Licensed_Property__c, ';
        strSOQL += 'op.PricebookEntry.Name, op.Product2.Name, op.OpportunityId, op.PricebookEntry.ProductCode, op.Release_Date__c, op.Deferred__c, ';
        strSOQL += 'op.PricebookEntry.Product2.Family, op.CurrencyIsoCode,op.Discount__c, op.Family__c, op.LineType__c, op.ListPrice, op.PricebookEntryId, ';
        strSOQL += 'op.PriceBookEntry.UnitPrice, op.PriceBookEntry.Pricebook2.Name, op.PricebookEntry.Product2.Unit__c, op.LOD_Start_Date__c, op.Opportunity.Name, ';
        strSOQL += 'op.Opportunity.Id, op.Opportunity.Opportunity_Number__c, op.Opportunity.Account.Name, op.Opportunity.Account.AccountNumber, ';
        strSOQL += 'op.Opportunity.CloseDate, op.Product2.Line__c ';
        strSOQL += 'FROM OpportunityLineItem op ';
        strSOQL += 'WHERE op.Opportunity.CloseDate >= ' + String.valueOf(dtClosedDateStart) + ' '; 
        strSOQL += 'AND op.Opportunity.StageName IN (\'Closed Won\', \'Proposal Requested - 60%\', \'Validate and Select - 80%\') ';
        
        // WHEN NOT AN INTERNAL USER FILTER ON THIS FIELD ON PRODUCT
        if (isNotParterUser == false)
        {
            strSOQL += 'AND Product2.Partner_Name__c = \'' + partnerUser.AccountId + '\' ';
        }
        
        strSOQL += 'AND op.Quantity > 0 '; 
        strSOQL += 'AND op.Opportunity.Account.Name != null '; 
        strSOQL += 'AND (op.Order_of_Delivery__c = null OR op.Order_of_Delivery__c = 1) '; 
        
        if (searchText != '')
        {
            String strKeyWord = string.escapeSingleQuotes(searchText);
            strSOQL += 'AND (op.Product2.Name LIKE \'%' + strKeyWord + '%\' ';
            strSOQL += 'OR op.Opportunity.Opportunity_Number__c LIKE \'%' + strKeyWord + '%\' ';  
            strSOQL += 'OR op.Opportunity.Account.Name LIKE \'%' + strKeyWord + '%\') ';  
        }
        
        if (sortOrder != null)
        {
            strSOQL += 'ORDER BY ' + sortOrder + ' ';
        }

        if (iLimit > 0)
        {
            strSOQL += 'LIMIT ' + String.valueOf(iLimit);
        } 

        List<OpportunityLineItem> lstResults = Database.query(strSOQL);
        
        if (!lstResults.isEmpty())
        {
            for (OpportunityLineItem i : lstResults)
            {   
                readOnlyResults x = new readOnlyResults(
                    i.Opportunity.Id, 
                    i.Opportunity.Account.Name, 
                    i.Product2.Name, 
                    i.Opportunity.Account.AccountNumber, 
                    i.Opportunity.Opportunity_Number__c, 
                    i.Opportunity.CloseDate);
                lineItemResults.add(x);
                iRecCount++;
            }
            
            if (iRecCount >= iLimit)
            {
                countWarning = 'Displaying top ' + String.valueOf(iLimit) + ' records only.';
            }
                
        }
   
    }
    

    public class readOnlyResults
    {    
    
        public String OpportunityId {get; set;}
        public String AccountName {get; set;}
        public String ProductName {get; set;}
        public String AccountNumber {get; set;}
        public String OpportunityNumber {get; set;}
        public Date OpportunityCloseDate {get; set;}
        
        public readOnlyResults (String OpportunityId, String AccountName, String ProductName, String AccountNumber, String OpportunityNumber, Date OpportunityCloseDate)
        {
            this.OpportunityId = OpportunityId;
            this.AccountName = AccountName;
            this.ProductName = ProductName;
            this.AccountNumber = AccountNumber;
            this.OpportunityNumber = OpportunityNumber;
            this.OpportunityCloseDate = OpportunityCloseDate;            
        }
        
    }
    
}