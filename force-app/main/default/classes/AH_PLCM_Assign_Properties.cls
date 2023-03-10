public class AH_PLCM_Assign_Properties {
    public List<AH_PLCM_Migration_Property__c> lstProperties { get; set; }
    public String NIDocId { get; set; }
    public String NIDocNo { get; set; }
    public String NIDocName { get; set; }
    public String ProjectName { get; set; }
    public String PortalStatus { get; set; }
    public Integer PageNumber { get; set; }
    public Integer RecordsPerPage { get; set; }
    public String DatabaseName { get; set; }
    public String PropertyName { get; set; }
    public String SortColumn { get; set; }
    public String SortDirection { get; set; }
    public String FilterString { get; set; }
    public Integer TotalRecords { get; set; }

    public Integer TotalPages {
        get {
            try {
                if(math.mod(TotalRecords, RecordsPerPage) > 0) {
                    return TotalRecords / RecordsPerPage;
                }
                else {
                    return (TotalRecords / RecordsPerPage) - 1;
                }
            }
            catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
                throw ex;
            }
        }
    }

    public List<SelectOption> lstPageNumbers { 
        get {
            List<SelectOption> lst = null;
            try {
                lst = new List<SelectOption>();
                for(Integer i = 0; i <= TotalPages; i++) {
                    lst.add(new SelectOption(String.valueOf(i), String.valueOf(i + 1)));
                }
                return lst;
            }
            catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
                return new List<SelectOption>();
            }
            finally {
                lst = null;
            }
        }
    }

    public AH_PLCM_Assign_Properties(ApexPages.StandardController controller) {
        NI_Documentation__c objNIDoc = null;
        String strQuery = null;
        try {
            RecordsPerPage = 25;
            TotalRecords = 0;
            PageNumber = 0;
            FilterString = ' WHERE IsActive__c = true AND IsFlagged_for_Migration__c = false';
            SortColumn = 'Database_Name__c';
            SortDirection = 'ASC';
            
            //Get all properties first time
            GetProperties();
            FindTotalRecords();
            
            NIDocId = String.valueOf(ApexPages.currentPage().getParameters().get('Id'));
            strQuery = 'SELECT Id, Name, Document_Name__c, Project__r.Name, AH_PLCM_Portal_Progress__c FROM NI_Documentation__c WHERE Id = \'' + NIDocId + '\'';
            System.debug('Get NI DOC Details => strQuery => ' + strQuery);
            objNIDoc = Database.query(strQuery);
            if(objNIDoc != null) {
                NIDocNo = objNIDoc.Name;
                NIDocName = objNIDoc.Document_Name__c;
                ProjectName = objNIDoc.Project__r.Name;
                PortalStatus = objNIDoc.AH_PLCM_Portal_Progress__c;
                if(PortalStatus == null) {
                    PortalStatus = '';
                }
            }
        }
        catch(Exception ex) {
            PortalStatus = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
        finally {
            objNIDoc = null;
            strQuery = null;
        }
    }

    //Used only on click of Search button
    public PageReference SearchProperties() {
        PageNumber = 0;
        FilterString = GetFilterString();
        GetProperties();
        FindTotalRecords();
        return null;
    }

    //Used for Sorting and Pagination
    public PageReference FillPropertiesList() {
        PageNumber = 0;
        GetProperties();
        return null;
    }

    //Get properties list based on filter
    public void GetProperties() {
        String strQuery = null, strSorting = null;
        try {
            Integer intOffSet = PageNumber * RecordsPerPage;            
            strSorting = SortColumn + ' ' + SortDirection;
            
            if(SortColumn == 'NI_Doc_Record__r.Name' && SortDirection == 'ASC') {
                strSorting = strSorting + ' NULLS LAST';
            }
            strQuery = 'SELECT Id, Name, Site_Name__c, Property_State__c, Property_City__c, Database_Name__c, NI_Doc_Record__c, NI_Doc_Record__r.Name, Property_Address__c, Property_Zip_Code__c, IsFlagged_for_Migration__c FROM AH_PLCM_Migration_Property__c' + FilterString + ' ORDER BY ' + strSorting + ', Name ASC LIMIT :RecordsPerPage OFFSET :intOffSet';
            System.debug('Get Properties => strQuery => ' + strQuery);
            lstProperties = Database.query(strQuery);
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            lstProperties = new List<AH_PLCM_Migration_Property__c>();
        }
        finally {
            //Release unused memory
            strQuery = null;
            strSorting = null;
        }
    }

    //Get total counts based on filter
    public void FindTotalRecords() {
        String strQuery = null;
        try {
            strQuery = 'SELECT COUNT() FROM AH_PLCM_Migration_Property__c' + FilterString;
            System.debug('Get Total Count => strQuery => ' + strQuery);
            TotalRecords = Integer.valueOf(Database.countQuery(strQuery));
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            throw ex;
        }
        finally {
            //Release unused memory
            strQuery = null;
        }
    }
    
    //Get filter string based on selected filters
    public String GetFilterString() {
        string strFilter = null;
        try {
            if(PageNumber == null) {
                PageNumber = 0;
            }

            strFilter = ' WHERE IsActive__c = true AND IsFlagged_for_Migration__c = false';
            if(PropertyName != null && PropertyName.trim() != '') { //Filter based on Property Name
                String strPropertyName = RemoveSpecialCharacters(PropertyName.trim());
                strFilter = strFilter + ' AND Name LIKE \'%' + strPropertyName + '%\'';                           
            }
            
            if(DatabaseName != null && DatabaseName.trim() != '') { //Filter based on Database Name
                String strDatabaseName = RemoveSpecialCharacters(DatabaseName.trim());
                strFilter = strFilter + ' AND Database_Name__c LIKE \'%' + strDatabaseName + '%\'';
            }
            return strFilter;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            throw ex;
        }
        finally {
            strFilter = null;
        }
    }

    public PageReference AssignProperties() {
        try {
            update lstProperties;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Data has been saved successfully!'));
            GetProperties();
            return null;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            return null;
        }
    }

    public void Beginning() {  
        PageNumber = 0;
        GetProperties();
    }  
      
    public void Previous() {  
        PageNumber--;
        GetProperties();
    }  
      
    public void Next() {  
        PageNumber++;
        GetProperties();
    }   
  
    public void End() {  
        PageNumber = TotalPages;
        GetProperties();
    }

    public PageReference ChangePageNumber() {
        GetProperties();
        return null;
    }
    
    public String RemoveSpecialCharacters(String str) {
        String newStr = str.replace('_', '\\_');
        newStr = newStr.replace('\\', '\\\\');
        newStr = newStr.replace('%', '\\%');
        newStr = newStr.replace('\'', '\\\'');
        return newStr;
    }
}