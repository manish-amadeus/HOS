/**************************************************************************************************************************
Name            : NI_Neighborhood_Case_ListView Class
Author          : Stuart Emery
Created Date    : 3/28/2014
Last Mod Date   : 4/6/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-009802
Description     : Controller for the NI_NeighborhoodExcelExport & NeighborhoodCaseCustomListView Visualforce pages 
                : The Visualforce Pages are uded in the "Neighborhood" Community to replace the standard Cases Home Tab  
                : 
/**************************************************************************************************************************/
public with sharing class NI_Neighborhood_Case_ListView 
{
    
    // DEBUG CONTACT USER ID
//    private final id idContactDebugID = '0036000001u8XNi';
    
    //TRACK THE SOQL OFFSET
    private integer counter=0;
    
    //SETS THE NUMBER OF ROWS PER PAGE 
    //private integer list_size = 25;
    public integer list_size {get; set;}
    
    //TOTAL NUMBER OF RECORDS  
    public integer total_size;
    
    //CONTACTID OF THE CURRENT NEIGHBORHOOD USER  
    public id usrContactId;
    
    //VARIABLE TO GET INFORMATION ABOUT THE CURRENT USER 
    User usr;
    
    //VARIABLE TO HOLD ACCOUNT ID OF THE CURRENT USER 
    Public id usrAccountId;
    
    //VARIABLE TO GET THE CURRENT NEIGHBORHOOD CONTACT 
    Contact contact;
    
    //VARIABLE TO HOLD THE CURRENT DATE  
    public Date dt = Date.TODAY();
    
    //PREVIOUS CALENDAR YEAR  
    public Integer prevYear = dt.year()-1;
    
    //VARIABLE TO HOLD THE CLOSED DATE 
    public boolean bClosedCase {get; set;}
    
    //BOOLEAN TO DETERMINE IF THE CURRENT USER IS A CUSTOMER COMMUNITY USER
    public boolean bInternalUser {get; set;}
    
    //LIST TO HOLD THE CASE RECORDS  
    public List<Case> lstCases {get; set;}
    
    //LIST TO HOLD THE CASE RECORDS TO EXPORT TO EXCEL  
    public List<Case> lstCasesExcelExport {get; set;}
    
    //STRING TO HOLD THE START DATE 
    public String startDate {get; set;}
    
    //STRING TO HOLD THE END DATE  
    public String endDate {get; set;}      
    
    //STRING TO HOLD THE VALUE OF THE SELECTED VIEW
    public String selectedValue {get; set; } {selectedValue = 'My Open Cases'; }
    
    //SET TO HOLD THE CASE RECORD TYPE IDs  
    public Set<Id> setRTypes = new Set<Id>();  
    
    //SET TO HOLD THE CASE ORIGINS  
    public Set<String> setOrigins = new Set<String>();  
    
    //SET TO HOLD THE CASE TYPES  
    public Set<String> setCTypes = new Set<String>();  
    
    //VARIABLE TO HOLD THE CURRENT DATETIME BASED ON THE TIMEZONE OF THE CURRENT USER   
    public String localDt {get; set;}  
    
    //SET FOR ALL CHILD ACCOUNT IDS
    public Set<Id> setChildren = new Set<Id>(); 
    
    //STRING TO HOLD THE VALUE OF THE SELECTED VIEW
    public String selectedRecVal {get; set; } {selectedRecVal = '25'; }

    private String sortDirection = 'ASC';

    private String sortExp = 'CaseNumber';
    
//    private boolean bFilterHasChanged;
    public String oldSelectedValue { get; set; }
    
    public string txtErrorMsg { get; set; }
    
    public boolean bExportToExcel { get; set; }
    
    
    
    public NI_Neighborhood_Case_ListView() 
    {

        bExportToExcel = false;
        
        //SET THE DEFAULT START DATE TO JANUARY 1 OF THE CURRENT YEAR  
        if (startDate == null)
        {
            startDate = '01/01/' + String.valueOf(dt.year());
        }
        
        //SET THE DEFAULT END DATE TO DECEMBER 31 OF THE CURRENT YEAR      
        if (endDate == null)
        {
            endDate = String.valueOf(date.today().format());
            //endDate = '12/31/' + String.valueOf(dt.year());
        }                        
        
//        // DETECT SANDBOX EXECUTION CONTEXT
//        if ((URL.getSalesforceBaseUrl().toExternalForm().Contains('https://cs')) || (URL.getSalesforceBaseUrl().toExternalForm().Contains('https://c.cs')))
//        {
//            usr = [SELECT Id, ContactId FROM User WHERE ContactId =: idContactDebugID];          
//        }    
//        else
//        {
        	usr = [SELECT Id, ContactId FROM User WHERE id =: UserInfo.getUserId()];               
//        }
        
        if (usr.ContactId == null)
        {          
            bInternalUser = true; 
        }
        
        //LIST TO HOLD THE VALUES FROM THE NI Neighborhood Case Record Types CUSTOM SETTING  
        List<NI_Neighborhood_Case_Record_Types__c> lstCS1 = NI_Neighborhood_Case_Record_Types__c.getAll().values();
        
        //LOOP THROUGH THE lstCS AND GET THE CASE RECORDTYPEIDs FOR THE RECORD TYPES THAT CAN BE DISPLAYED IN THE NEWMARKET NEIGHBORHOOD 
        for (NI_Neighborhood_Case_Record_Types__c crt1 : lstCS1)
        {
            setRTypes.add(NI_TestClassData.getRecordTypeId('Case', crt1.Name));
        }
        
        //LIST TO HOLD THE VALUES FROM THE NI Neighborhood Case Origins CUSTOM SETTING  
        List<NI_Neighborhood_Case_Origins__c> lstCS2 = NI_Neighborhood_Case_Origins__c.getAll().values();
        
        //LOOP THROUGH AND GET THE CASE ORIGINS THAT CAN BE DISPLAYED IN THE NEWMARKET NEIGHBORHOOD 
        for (NI_Neighborhood_Case_Origins__c crt2 : lstCS2)
        {
            setOrigins.add(crt2.Name);
        }
        
        //LIST TO HOLD THE VALUES FROM THE NI Neighborhood Case Types CUSTOM SETTING  
        List<NI_Neighborhood_Case_Types__c> lstCS3 = NI_Neighborhood_Case_Types__c.getAll().values();
        
        //LOOP THROUGH AND GET THE CASE TYPES THAT CAN BE DISPLAYED IN THE NEWMARKET NEIGHBORHOOD  
        for (NI_Neighborhood_Case_Types__c crt3 : lstCS3)
        {
            setCTypes.add(crt3.Name);
        }        
   
        //GET THE TIMEZONE FOR THE CURRENT USER  
        TimeZone tz = UserInfo.getTimeZone();
        
        //SET THE CURRENT DATETIME TO THE TIMEZONE OF THE CURRENT USER  
        localDt = DateTime.now().format('MM/dd/yyyy h:mm a, z',tz.toString());
        
        readUserPreferences();
                
        callMethods2();     
        
    }

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
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
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
        //if not column is selected 
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

    public PageReference sortData() 
    {
        string sortFullExp = sortExpression  + ' ' + sortDirection; 
        return null;
    }

    
    //LIST RECORD PER PAGE OPTION
    public List<SelectOption> getRecVals()
    { 
        
        List<SelectOption> vals = new List<SelectOption>();
        
        vals.add(new SelectOption('10', '10'));
        vals.add(new SelectOption('25', '25'));
        vals.add(new SelectOption('50', '50'));        
        vals.add(new SelectOption('100', '100'));
        vals.add(new SelectOption('200', '200'));

        return vals;
        
    }
    
    //LIST THAT HOLDS THE VIEW OPTIONS
    public List<SelectOption> getViews()
    { 
        
        List<SelectOption> views = new List<SelectOption>();
        
        views.add(new SelectOption('My Open Cases', 'My Open Cases'));
        views.add(new SelectOption('My Closed Cases', 'My Closed Cases'));
        views.add(new SelectOption('All My Cases', 'All My Cases'));
        
        views.add(new SelectOption('My Property\'s Open Cases', 'My Property\'s Open Cases'));
        views.add(new SelectOption('My Property\'s Closed Cases', 'My Property\'s Closed Cases'));
        views.add(new SelectOption('All My Property\'s Cases', 'All My Property\'s Cases'));
        
        views.add(new SelectOption('All Properties\' Open Cases', 'All Properties\' Open Cases'));
        views.add(new SelectOption('All Properties\' Closed Cases', 'All Properties\' Closed Cases'));
        views.add(new SelectOption('All Properties\' Cases', 'All Properties\' Cases'));
        
        return views;
        
    }
    
    public PageReference callMethods2()
    {

        // SET DEFAULT LIST SIZE IF NOT PRESENT
        if ((list_size == null) || (list_size == 0))
        {
            list_size = 25;
        }
        else
        {
            list_size = integer.ValueOf(selectedRecVal);
        }

        if (usr.ContactId == null)
        {
            internalUserMethod();
        }
      
        if (usr.ContactId != null)
        {
            callMethods();
        }
    
        oldSelectedValue = selectedValue;
        return null;  
        
    }
    
    public PageReference callMethods()
    {
        
        usrContactId = usr.ContactId;
        contact = [select AccountId from Contact where id = :usrContactId];
        usrAccountId = contact.AccountId;

        for (Account lst : [SELECT Id, Name FROM Account WHERE ParentId = : contact.AccountId])
        {
            setChildren.Add(lst.Id);
        }       
        
        setChildren.Add(contact.AccountId);
        
        getCases();
//        getCasesExcelExport();
        
        return null;
        
    }
    
    public PageReference internalUserMethod()
    {
        getInternalUserCases();        
        return null;
    }  

    public List<Case> getCasesExcelExport() 
    { 
        bExportToExcel = true;
        lstCasesExcelExport = getCases();
        return lstCasesExcelExport;
    }
    
    
    public List<Case> getCases() 
    { 
txtErrorMsg = '';  
        
        if (oldSelectedValue != selectedValue)
        {
            counter = 0;
        }
        
        if (startDate == null)
        //((startDate != null) && (sdt.Year() < prevYear)))
        {
            startDate = '01/01/' + String.valueOf(dt.year()); //SET THE DEFAULT START DATE TO JANUARY 1 OF THE CURRENT YEAR
        }
        
        if (endDate == null)
            //((endDate != null) && (edt.Year() < prevYear)))
        {
            endDate = '12/31/' + String.valueOf(dt.year()); //SET THE DEFAULT END DATE TO DECEMBER 31 OF THE CURRENT YEAR
        }                            
        
        if (selectedValue == null)
        {
            selectedValue = 'My Open Cases';        
        }
        
        string sortFullExp = (sortExpression  + ' ' + sortDirection);    
        
// MY CASES =============================================================        
        if (selectedValue == 'My Open Cases')
        {                  
            bClosedCase = false;
//txtErrorMsg = 'My Open Cases ======   ';
system.debug(queryBuilder(1, 1, sortFullExp, bExportToExcel));
			lstCases = Database.query(queryBuilder(1, 1, sortFullExp, bExportToExcel));            

            total_size = [select count() from Case 
                          WHERE Status != 'Closed'
                          AND Case.ContactId != null 
                          AND Case.ContactId =: usrContactId
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];           
        }        
        if (selectedValue == 'My Closed Cases')
        {
            bClosedCase = true;
//txtErrorMsg = 'My Closed Cases ======   ';
			lstCases = Database.query(queryBuilder(1, 2, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Status = 'Closed'
                          AND Case.ContactId != null 
                          AND Case.ContactId =: usrContactId
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];       
        }
        if (selectedValue == 'All My Cases')
        {                  
            bClosedCase = true;
//txtErrorMsg = 'All My Cases ======   ';            
            lstCases = Database.query(queryBuilder(1, 0, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Case.ContactId =: usrContactId
                          AND Case.ContactId != null
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];            
        }

        
// MY PROPERY'S ==========================================================       
        if (selectedValue == 'My Property\'s Open Cases')
        {                  
            bClosedCase = false;
//txtErrorMsg = 'My Property Open Cases ======   ';              
            lstCases = Database.query(queryBuilder(2, 1, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Status != 'Closed'
                          AND Case.AccountId != null 
                          AND Case.AccountId =: usrAccountId
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];             
        }           
        if (selectedValue == 'My Property\'s Closed Cases')
        {                  
            bClosedCase = true;
//txtErrorMsg = 'My Property Closed Cases ======   ';                
            lstCases = Database.query(queryBuilder(2, 2, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Status = 'Closed'
                          AND Case.AccountId != null 
                          AND Case.AccountId =: usrAccountId
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];             
        }            
        if (selectedValue == 'All My Property\'s Cases')
        {                  
            bClosedCase = true;
//txtErrorMsg = 'All Property Cases ======   ';              
            lstCases = Database.query(queryBuilder(2, 0, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Case.AccountId =: usrAccountId
                          AND Case.AccountId != null
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];           
        }        

        
// ALL PROPERY'S ========================================================= 
        if (selectedValue == 'All Properties\' Open Cases')
        {                  
            bClosedCase = false;
//txtErrorMsg = 'All My Property Open Cases ======   ';              
            lstCases = Database.query(queryBuilder(3, 1, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Status != 'Closed'
                          AND Case.AccountId IN : setChildren 
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];          
        }        
        if (selectedValue == 'All Properties\' Closed Cases')
        {                  
            bClosedCase = true;
//txtErrorMsg = 'All Property Closed Cases ======   ';              
            lstCases = Database.query(queryBuilder(3, 2, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Status = 'Closed'
                          AND Case.AccountId IN : setChildren 
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];            
        }   
        if (selectedValue == 'All Properties\' Cases')
        {                  
            bClosedCase = true;
//txtErrorMsg = 'All Property Cases ======   ';            
            lstCases = Database.query(queryBuilder(3, 0, sortFullExp, bExportToExcel)); 
            
            total_size = [select count() from Case 
                          WHERE Case.AccountId IN : setChildren 
                          AND CreatedDate >=: Date.parse(startDate)
                          AND CreatedDate <=: Date.parse(endDate)
                          AND RecordTypeId IN : setRTypes 
                          AND Origin IN : setOrigins        
                          AND Type IN : setCTypes];             
        }     
        
        saveUserPreferences();
        
        return lstCases;
        
    }    
    
    
    
        
    public List<Case> getInternalUserCases() 
    {               
        //ENSURE THAT NO CASE RECORDS ARE RETURNED FOR INTERNAL USERS  
        lstCases = [SELECT Id
                    FROM Case
                    WHERE CreatedDate = null
                    AND RecordTypeId IN : setRTypes 
                    AND Origin IN : setOrigins        
                    AND Type IN : setCTypes    
        			LIMIT 0];
        
        total_size = [select count() from Case 
                      WHERE CreatedDate = null
                      AND RecordTypeId IN : setRTypes 
                      AND Origin IN : setOrigins        
                      AND Type IN : setCTypes  
                      LIMIT 0];  
        
        return lstCases;
        
    }
        

    // ===========================================
	//  NAVIGATION FUNCTIONS =====================
	// ===========================================    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        return null;
    }
    
    public PageReference End() { //user clicked end
        counter = total_size - math.mod(total_size, list_size);
        return null;
    }
    
    public Boolean getDisablePrevious() { //this will disable the previous and beginning buttons
        if (counter > 0) return false; else return true;
    }
    
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public Integer getTotal_size() 
    {
        return total_size;
    }
    
    public Integer getPageNumber() 
    {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() 
    {
        if (math.mod(total_size, list_size) > 0) 
        {
            return total_size/list_size + 1;            
        } 
        else 
        {
            return (total_size/list_size);
        }
    }

    // ===========================================
	//  EXCEL EXPORT FUNCTIONS ===================
	// ===========================================      
    //DISABLE THE EXPORT TO EXCEL BUTTON IF THERE ARE NO RECORDS RETURNED 
    public Boolean getDisableExport() 
    {
        if (total_size > 0) return false; else return true;
    }
    
    public PageReference export() 
    {
        return page.NI_NeighborhoodExcelExport;
    }

                

    // ===========================================
	//  CASE FUNCTIONS ===========================
	// ===========================================         
    public PageReference NewCase() 
    {    
        PageReference pageRef = new PageReference('/500/e?retURL=%2Fapex/NeighborhoodCaseCustomListView?sfdc.tabName=01r60000000AHUl');
        return pageRef;
    }   
    
    private string queryBuilder(integer iFilter, integer iMode, string sSort, boolean isExcelExport)
    {
        string strSOQL = '';
        
       	strSOQL += 'SELECT Id, CaseNumber, Previous_CaseNumber__c, Account.Name, CreatedDate, Contact.Name, Status, Priority, ';
        strSOQL += 'Subject, Description, RealLastActivityDate__c, ClosedDate, Reason, Origin, Type, ';
        strSOQL += 'Customer_Severity__c, Resolution_Type__c, Owner.Name, Asset.Name, Account_Name__c, DI_Product_Group__c ';
        strSOQL += 'FROM Case ';
        strSOQL += 'WHERE IsDeleted = false ';
		strSOQL += 'AND Account.Type LIKE \'%CUSTOMER%\' ';
            
        // STATUS FILTER EVALUATION
		if (iMode == 1)	// OPEN CASES 
        {
            strSOQL += 'AND Status != \'Closed\' ';
        }
        if (iMode == 2) // CLOSED CASES 
        {
            strSOQL += 'AND Status = \'Closed\' ';
        }
        
        // CASES BY FILTER EVALUATION
		if (iFilter == 1) // MY CASES
        {
            strSOQL += 'AND Case.ContactId != null AND Case.ContactId = \'' + String.ValueOf(usrContactId) + '\' ';          
        }
        if (iFilter == 2) // MY PROPERTY'S
        {
            strSOQL += 'AND Case.AccountId != null AND Case.AccountId = \'' + String.ValueOf(usrAccountId) + '\' ';
        }        
        if (iFilter == 3) // ALL MY PROPERY'S
        {
            strSOQL += 'AND Case.AccountId IN (' + idSetToInString(setChildren) + ') ';
        }                   

        strSOQL += 'AND CreatedDate >= ' + String.ValueOf(Date.parse(startDate)) + 'T00:00:00Z '; 
        strSOQL += 'AND CreatedDate <= ' + String.ValueOf(Date.parse(endDate)) + 'T23:59:59Z '; 
        strSOQL += 'AND RecordTypeId IN (' + idSetToInString(setRTypes) + ') ';         
        strSOQL += 'AND Origin IN (' + SetToInString(setOrigins) + ') ';         
        strSOQL += 'AND Type IN (' + SetToInString(setCTypes) + ') ';         
        strSOQL += 'ORDER BY ' + sSort + ' '; 
        
        if (!isExcelExport)
        {
            strSOQL += 'LIMIT ' + String.ValueOf(list_size) + ' '; 
            strSOQL += 'OFFSET ' + String.ValueOf(counter) + ' ';             
        }
		
        // SOQL DEBUGGER TOOL. ADD THIS CODE TO PAGE TO EXPOSE QUERY: <apex:outputText style="color: #FF0000;" value="{!txtErrorMsg}" /> 
        txtErrorMsg += strSOQL + ' -- QUERY CHARACTER LENGTH = ' + string.valueOf(strSOQL.Length());
		system.debug(txtErrorMsg);
        
        if (strSOQL.Length() > 10000)
        {
            // THROW ERROR
        }
        
        return strSOQL;
        
    }

    // ===========================================
	//  UTILITY FUNCTIONS ========================
	// ===========================================        
    private string idSetToInString(Set<Id> s)
    {
        string strRetVal = '';
        for (Id x : s)
        {
			strRetVal += '\'' + String.ValueOf(x) + '\',';
        }
        if (strRetVal.Right(1) == ',')
        {
            strRetVal = strRetVal.substring(0, (strRetVal.Length() - 1));
        }
        return strRetVal;
    }

    private string SetToInString(Set<String> s)
    {
        string strRetVal = '';
        for (String x : s)
        {
			strRetVal += '\'' + x + '\',';
        }
        if (strRetVal.Right(1) == ',')
        {
            strRetVal = strRetVal.substring(0, (strRetVal.Length() - 1));
        }
        return strRetVal;
    }    
    
    // COOKIE SETTER
    private void saveUserPreferences() 
    {        
        Cookie recLimit = ApexPages.currentPage().getCookies().get('recLimit');
    
        if (recLimit == null) 
        {
            recLimit = new Cookie('recLimit', selectedRecVal, null, -1, false);
        } 
        else 
        {
            Integer count = Integer.valueOf(recLimit.getValue());
            recLimit = new Cookie('recLimit', selectedRecVal, null, -1, false);
        }
        ApexPages.currentPage().setCookies(new Cookie[]{recLimit});
    }
	
    // COOKIE GETTER
    private void readUserPreferences() 
    {
        Cookie recLimit = ApexPages.currentPage().getCookies().get('recLimit');
        if (recLimit != null) 
        {
            selectedRecVal = recLimit.getValue();
        }        
    }

    
    
}