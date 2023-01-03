/**************************************************************************************************************************
Name            : NeighborhoodCaseCustomListView Class
Author          : Sean Harris
Created Date    : 12/14/2016
Last Mod Date   : 7/21/2017 PER NICC-023213
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the NI_NeighborhoodExcelExport & NeighborhoodCaseCustomListView Visualforce pages 
                : The Visualforce Pages are uded in the "Neighborhood" Community to replace the standard Cases Home Tab  
                : 
/**************************************************************************************************************************/
public without sharing class NeighborhoodCaseCustomListView 
{
    
    // RUNNING USER VARIABLES
    private User usr;    									// VARIABLE TO GET INFORMATION ABOUT THE CURRENT USER 
    public id usrContactId;									// CONTACTID OF THE CURRENT NEIGHBORHOOD USER  
    private id usrAccountId;    							// VARIABLE TO HOLD ACCOUNT ID OF THE CURRENT USER 
    private string usrUserType;    							// VARIABLE TO HOLD USERTYPE OF THE CURRENT USER 
    
    // CASE RESULT VARIABLES
    public Map<integer, Id> mapCaseIds = new Map<integer, Id>();	// SET FOR CASE IDS SHARED TO RUNNING USER THAT MEET SEARCH CRITERIA 
    private Set<Id> setRTypes = new Set<Id>();  			// SET TO HOLD THE CASE RECORD TYPE IDs  
    private Set<string> setOrigins = new Set<string>();  	// SET TO HOLD THE CASE ORIGINS  
    private Set<string> setCTypes = new Set<string>();     	// SET TO HOLD THE CASE TYPES  
    private integer SOQL_LIMIT = 50000;						// SOQL LIMIT     
    private List<Case> lstCases {get; set;}   				// LIST TO HOLD THE CASE RECORDS 
    
    // DATE VARIABLES
    public date dt = date.Today();							// VARIABLE TO HOLD THE CURRENT DATE  
    public datetime startDate {get; set;}					// CASE CREATED START DATE (DATETIME TYPE)
    public string displayStartDate {get; set;} 				// CASE CREATED START DATE 
    public datetime endDate {get; set;}     				// CASE CREATED END DATE (DATETIME TYPE)
    public string displayEndDate {get; set;}     			// CASE CREATED END DATE 
    public String localDt {get; set;}  						// VARIABLE TO HOLD THE CURRENT DATETIME BASED ON THE TIMEZONE OF THE CURRENT USER  
    public String caseNumber {get; set;}  
    
    // VARIABLES 
    public integer list_size {get; set;}					// SETS THE NUMBER OF ROWS PER PAGE 
    private integer counter {get; set;}						// TRACK THE SOQL OFFSET
    public integer total_size {get; set;}					// TOTAL NUMBER OF RECORDS  
    public boolean bClosedCase {get; set;} 					// SWITCH TO HIDE CLOSED DATE COLUMN ON OPEN CASE ONLY SEARCHES 
    public boolean isNewSearch {get; set;} 					// FLAG TO LET CODE KNOW WHEN TO REFRESH CASE ID MAP
    public string txtErrorMsg {get; set;}					// ERROR TEXT
    public String selectedValue {get; set;} 				// STRING TO HOLD THE VALUE OF THE SELECTED VIEW
    public String selectedRecVal {get; set;} 				// STRING TO HOLD THE VALUE OF THE SELECTED VIEW
    public boolean bExportToExcel {get; set;} 				// EXPORT TO EXCEL FEATURE SWITCH
    public boolean showSearchByNumber {get; set;} 			// TOGGLES BY DATE RANGE/CASE NUMBER SEARCH MODES  
    public List<SelectOption> searchModes {get; set;} 
    public String searchByMode {get; set;} 
    
    public NeighborhoodCaseCustomListView() 
    { 
        
        system.debug(' *** ENTERING CONSTRUCTOR - NeighborhoodCaseCustomListView.NeighborhoodCaseCustomListView()');  
        
        initVars();
        initCaseSearch();
        
        system.debug(' *** EXITING CONSTRUCTOR - NeighborhoodCaseCustomListView.NeighborhoodCaseCustomListView()');  
        
    }  
    
    private void initVars()
    {
        
        system.debug(' *** ENTERING NeighborhoodCaseCustomListView.initVars()');
        
        selectedValue = 'My Open Cases';
        lstCases = new List<Case>();
        isNewSearch = true;
        list_size = 25;
        counter = 0;
        total_size = 0;
        txtErrorMsg = '';
        selectedRecVal = '25';
        bExportToExcel = false;
        bClosedCase = true;
        
        readUserPreferences();
        
        usr = [SELECT Id, ContactId, AccountId, UserType FROM User WHERE Id = : UserInfo.getUserId()];  
        // usr = [SELECT Id, ContactId, AccountId, UserType FROM User WHERE Id = '005630000012PJWAA2'];
        
        usrUserType = usr.UserType;
        
        if (usr.ContactId != null)
        {          
            usrContactId = usr.ContactId; 
        }   
        
        if (usr.AccountId != null)
        {          
            usrAccountId = usr.AccountId; 
        } 
        
        // THIS SCENARIO SHOULD NOT HAPPEN        
        //        if ((usr.ContactId != null) && (usr.AccountId == null))
        //        {
        //            usrAccountId = [SELECT Id, AccountId FROM Contact WHERE Id =: usrContactId].AccountId;
        //        }
        
        //SET THE DEFAULT START DATE TO JANUARY 1 OF THE CURRENT YEAR  
        if (startDate == null)
        {
            startDate = DateTime.newInstance(dt.Year(), 1, 1, 0, 0, 0);
            displayStartDate = '01/01/' + String.valueOf(dt.year());
        }
        
        //SET THE DEFAULT END DATE TO END OF DAY TODAY      
        if (endDate == null)
        {
            endDate = DateTime.newInstance(dt.Year(), dt.Month(), dt.Day(), 23, 59, 59);
            displayEndDate = String.valueOf(date.today().format());
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
        
        //GET THE TIMEZONE FOR THE CURRENT USER  
        TimeZone tz = UserInfo.getTimeZone();
        
        //SET THE CURRENT DATETIME TO THE TIMEZONE OF THE CURRENT USER  
        localDt = DateTime.now().format('MM/dd/yyyy h:mm a, z',tz.toString());        
        
        // SEARCH BY MODE RADIO BUTTONS
        searchModes = new List<SelectOption>();
        searchModes.add(new SelectOption('Date Range', 'Date Range')); 
        searchModes.add(new SelectOption('Case Number', 'Case Number'));         
        searchByMode = 'Date Range';
        showSearchByNumber = false;
        
        system.debug(' *** EXITING NeighborhoodCaseCustomListView.initVars()');
        
    }
    
    
    
    // LIST THAT HOLDS THE VIEW OPTIONS
    public List<SelectOption> getViews()
    { 
        
        system.debug(' *** ENTERING NeighborhoodCaseCustomListView.getViews()');
        
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
        
        system.debug(' *** EXITING NeighborhoodCaseCustomListView.getViews()'); 
        
        return views;
        
    }    
    
    // SEARCH BY MODE RADIO BUTTON SELECTION 
    public void changeMode()
    {
        showSearchByNumber = false;
        caseNumber = null;
        if (searchByMode == 'Case Number')
        {
            showSearchByNumber = true;
        }
    }
    
    public PageReference initCaseSearch()
    {
        
        system.debug(' *** ENTERING NeighborhoodCaseCustomListView.initCaseSearch()');   
        
        saveUserPreferences();
        
        // this doesn't work yet        
        //        if (Date.parse(displayStartDate) > Date.parse(displayEndDate))
        //        {
        //            txtErrorMsg = 'Start Date is greater than End Date. Please correct and search again.';
        //        }
        
        list_size = integer.valueOf(selectedRecVal);
        txtErrorMsg = '';
        isNewSearch = true;
        doCaseSearch();
        
        system.debug(' *** EXITING NeighborhoodCaseCustomListView.initCaseSearch()'); 
        
        return null;
        
    }
    
    private void fillCaseIdMap(Id userId)
    {
        
        system.debug(' *** ENTERING NeighborhoodCaseCustomListView.fillCaseIdMap()');  
        
        system.debug('**** selectedValue = ' + selectedValue);
        
        lstCases.clear();
        string stringSOQL = '';
        if (isNewSearch)
        {
            
            mapCaseIds.clear();
            Integer iElement = 0;
            startDate = Date.parse(displayStartDate);
            endDate = Date.parse(displayEndDate);
            endDate = endDate.addDays(1);
            bClosedCase = true;
            
            system.debug(' **** setRTypes' + setRTypes);
            system.debug(' **** setOrigins' + setOrigins);
            system.debug(' **** setCTypes' + setCTypes);
            system.debug(' **** selectedValue = ' + selectedValue);
            system.debug(' **** startDate = ' + startDate + ' - endDate = ' + endDate);
            
            if (caseNumber != '' && caseNumber != null)
            { 
                stringSOQL = ' CaseNumber LIKE \'%' + caseNumber + '%\' ';
            }
            else
            {
                stringSOQL = ' CreatedDate >= : startDate AND CreatedDate <= :endDate ' ;
            }
            
            if (usrUserType == 'Standard')
            { 
                for (Case c : Database.Query('SELECT Id FROM Case' +
                                             ' WHERE ' + stringSOQL +
                                             ' AND RecordTypeId IN : setRTypes' + 
                                             ' AND Origin IN : setOrigins' +
                                             ' AND Type IN : setCTypes' +
                                             ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId =: userId)' + 
                                             ' ORDER BY CreatedDate DESC' +
                                             ' LIMIT : SOQL_LIMIT'))
                {
                    mapCaseIds.put(iElement, c.Id);
                    iElement += 1;
                }                
            }
            else
            {
                // MY CASES CONDITIONS =============================================================          
                if (selectedValue == 'My Open Cases')
                {   
                    bClosedCase = false;
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes' + 
                                                 ' AND Origin IN : setOrigins' +
                                                 ' AND Type IN : setCTypes' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId =: userId) ' + 
                                                 ' AND Status != \'Closed\'' +
                                                 ' AND Case.ContactId = : usrContactId' +                  
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                if (selectedValue == 'My Closed Cases')
                {
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes' +
                                                 ' AND Origin IN : setOrigins ' +
                                                 ' AND Type IN : setCTypes ' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId =: userId) ' +
                                                 ' AND Status = \'Closed\'' +
                                                 ' AND Case.ContactId =: usrContactId' +
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                if (selectedValue == 'All My Cases')
                {         
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes ' +
                                                 ' AND Origin IN : setOrigins ' +
                                                 ' AND Type IN : setCTypes ' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' +
                                                 ' AND Case.ContactId =: usrContactId' +
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                // MY PROPERY'S CONDITIONS ==========================================================          
                if (selectedValue == 'My Property\'s Open Cases')
                {   
                    bClosedCase = false;
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes ' +
                                                 ' AND Origin IN : setOrigins ' +
                                                 ' AND Type IN : setCTypes ' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' +
                                                 ' AND Status != \'Closed\'' +
                                                 ' AND Case.AccountId = : usrAccountId' +
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                if (selectedValue == 'My Property\'s Closed Cases')
                { 
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes' +
                                                 ' AND Origin IN : setOrigins' +        
                                                 ' AND Type IN : setCTypes' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' +
                                                 ' AND Status = \'Closed\'' +
                                                 ' AND Case.AccountId = : usrAccountId' +
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                        
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                if (selectedValue == 'All My Property\'s Cases')
                {         
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes' +
                                                 ' AND Origin IN : setOrigins' +
                                                 ' AND Type IN : setCTypes' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' +
                                                 ' AND Case.AccountId =: usrAccountId' +
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }  
                
                // ALL PROPERY'S CONDITIONS ==========================================================          
                if (selectedValue == 'All Properties\' Open Cases')
                { 
                    bClosedCase = false;
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes' +
                                                 ' AND Origin IN : setOrigins' +
                                                 ' AND Type IN : setCTypes' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' + 
                                                 ' AND Status != \'Closed\'' + 
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                if (selectedValue == 'All Properties\' Closed Cases')
                {         
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes' +
                                                 ' AND Origin IN : setOrigins' +
                                                 ' AND Type IN : setCTypes' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' +
                                                 ' AND Status = \'Closed\'' + 
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                        
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }
                
                if (selectedValue == 'All Properties\' Cases')
                {
                    for (Case c : Database.Query('SELECT Id FROM Case' +
                                                 ' WHERE ' + stringSOQL +
                                                 ' AND RecordTypeId IN : setRTypes ' +
                                                 ' AND Origin IN : setOrigins ' +
                                                 ' AND Type IN : setCTypes ' +
                                                 ' AND Id IN (SELECT CaseId FROM CaseShare WHERE UserOrGroupId = : userId)' +
                                                 ' ORDER BY CreatedDate DESC' +
                                                 ' LIMIT : SOQL_LIMIT'))
                    {
                        mapCaseIds.put(iElement, c.Id);
                        iElement += 1;
                    }
                }   
                
            }
            
            total_size = iElement;         
            isNewSearch = false;
            
        }
        
        system.debug(' **** mapCaseIds.Size() = ' + mapCaseIds.Size());        
        system.debug(' *** EXITING NeighborhoodCaseCustomListView.fillCaseIdMap()'); 
        
    }
    
    private void doCaseSearch()
    {
        
        system.debug(' *** ENTERING NeighborhoodCaseCustomListView.doCaseSearch()'); 
        
        fillCaseIdMap(usr.Id);
        
        string strSOQL = '';
        string strCaseIds;
        
        if (bExportToExcel)
        {
            strCaseIds = idSetToInString(caseRecordSet(mapCaseIds, mapCaseIds.size(), 0));
        }
        else
        {
            strCaseIds = idSetToInString(caseRecordSet(mapCaseIds, list_size, counter));
        }
        
        if (strCaseIds == '')
        {
            txtErrorMsg = 'No Cases Found';
            return;
        }
        
        system.debug(' **** sortExpression = ' + sortExpression + ',  sortDirection = ' + sortDirection); 
        
        strSOQL += 'SELECT Id, CaseNumber, Previous_CaseNumber__c, Account.Name, CreatedDate, Contact.Name, Status, Priority, ';
        strSOQL += 'Subject, Description, RealLastActivityDate__c, ClosedDate, Reason, Origin, Type, ';
        strSOQL += 'Customer_Severity__c, Resolution_Type__c, Owner.Name, Asset.Name, Account_Name__c, DI_Product_Group__c ';
        strSOQL += 'FROM Case ';
        strSOQL += 'WHERE Id IN (' + strCaseIds + ') '; 
        strSOQL += 'ORDER BY ' + sortExpression  + ' ' + sortDirection + ' '; 
        
        system.debug(' **** mapCaseIds.Size() = ' + mapCaseIds.Size());
        system.debug(' **** strSOQL = ' + strSOQL);
        
        lstCases = Database.query(strSOQL);
        
        saveUserPreferences();
        
        system.debug(' *** EXITING NeighborhoodCaseCustomListView.doCaseSearch()'); 
        
    }   
    
    private Set<Id> caseRecordSet(Map<Integer, Id> mapSource, Integer iLimit, Integer iOffest)
    {
        
        Set<Id> setRet = new Set<Id>();
        
        for (Integer j = (iLimit * iOffest); j < ((iLimit * iOffest) + iLimit); j++)
        {
            if (mapSource.containsKey(j))
            {
                setRet.Add(mapSource.get(j));
            }
        }
        
        return setRet;
        
    }
    
    public List<Case> getCases() 
    { 
        return lstCases;
    }
    
    // ===========================================
    // =  SORTING   ==============================
    // =========================================== 
    private String sortDirection = 'ASC'; 
    private String sortExp = 'CaseNumber'; 
    
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
        doCaseSearch();
        return null;
    }
    
    // ===========================================
    // =  NAVIGATION  ============================
    // ===========================================    
    public PageReference Beginning() 
    { 
        counter = 0;
        doCaseSearch();
        return null;
    }
    
    public PageReference Previous() 
    { 
        if (counter > 0)
        {
            counter -= 1;
        }
        doCaseSearch();
        return null;
    }
    
    public PageReference Next() 
    { 
        counter += 1; 
        doCaseSearch();
        return null;
    }
    
    public PageReference End() 
    { 
        counter = (total_size / list_size); 
        doCaseSearch();
        return null;
    }
    
    public Boolean getDisablePrevious() 
    { 
        if (counter > 0) return false; else return true;
    }
    
    public Boolean getDisableNext() 
    { 
        if (counter + list_size < total_size) return false; else return true;
    }
    
    public string getPageOfPages()
    {
        string sRetVal = 'Showing Page ';
        string sCurrentPage = '0';
        string sPageCount = '0';
        
        if (total_size > 0) 
        {
            sCurrentPage = string.valueOf(counter + 1);
            sPageCount = string.valueOf((total_size / list_size) + 1);
        }
        
        sRetVal += sCurrentPage + ' of ' + sPageCount;
        return sRetVal;
        
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
    
    /*
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
*/
    
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
    
    public PageReference NewCase() 
    {    
        PageReference pageRef = new PageReference('/500/e?retURL=%2Fapex/NeighborhoodCaseCustomListView?sfdc.tabName=01r60000000AHUl');
        return pageRef;
    }       
    
    // ===========================================
    // =  EXCEL EXPORT FUNCTIONS =================
    // ===========================================      
    public Boolean getDisableExport() 
    {
        if (total_size > 0) return false; else return true;
    }
    
    public PageReference export() 
    {
        return page.NI_NeighborhoodExcelExport;
    }    
    
    public List<Case> getCasesExcelExport() 
    { 
        bExportToExcel = true;
        doCaseSearch();
        return lstCases;
    }
    
}