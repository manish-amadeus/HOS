/***********************************************************************************************
  Name            : AH_UDC_CustomLookupDialog
  Author          : Sanjay Parmar
  Created Date    : 21-Apr-2021
  Last Mod Date   : 23-Apr-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Apex class for Custom Lookup page
 ************************************************************************************************/
public with sharing class AH_UDC_CustomLookupDialog {
   public String LookupType { get; set; } //Ex. NI Documentation, Contact, Account...etc
   public String SearchText { get; set; }
   public String PageTitle { get; set; }
   public String LookupFormId { get; set; }
   public String RecordTypeId { get; set; }
   public String WorkbookId { get; set; }
   public String WorkbookStepId { get; set; }
   public String PrequisiteStepId { get; set; }
   public Decimal WorkbookStepSortOrder { get; set; }
   public String LookupFieldId { get; set; }
   public Boolean IsNIDocLookup { get; set; }
   public Boolean IsContactLookup { get; set; }
   public Boolean IsWorkbookStepLookup { get; set; }
   public Boolean IsErrorOccurred { get; set; }
   public String ValidationMessage { get; set; }
   public List<NIDocumentWrapper> NIDocRecordsList { get; set; }
   public List<ContactWrapper> ContactRecordsList { get; set; }
   public WorkbookStepWrapper StepDetails { get; set; }
   public List<WorkbookStepWrapper> WorkbookStepRecordsList { get; set; }
   @TestVisible private String LogFunctionalArea = 'AH_UDC_CustomLookupDialog'; //This is used for AH_UDC_Log Entries being written on this page
   //This is used to store AH_UDC_Log records that can't be written on the load of the controller
   public List<AH_UDC_log__c> PageLoadLogMessages { get; set; } { PageLoadLogMessages = new List<AH_UDC_Log__c> (); }
   //This is used client side to determine if AH_UDC_Log Messages need to be written from the Page Load
   public Boolean HasPageLoadLogMessages {
      get {
         AH_UDC_LogHelper.Debug('PageLoadLogMessages: ' + PageLoadLogMessages);
         return PageLoadLogMessages.size() > 0;
      }
   }

   public class NIDocumentWrapper {
      public Id Id { get; set; }
      public String DocumentNumber { get; set; }
      public String DocumentName { get; set; }
      public String UDCPropertyName { get; set; }
      public String AccountName { get; set; }
   }

   public class ContactWrapper {
      public Id Id { get; set; }
      public String Name { get; set; }
      public String Email { get; set; }
      public String AccountName { get; set; }
      public String HasExternalUser { get; set; }
   }

   public class WorkbookStepWrapper {
      public Id Id { get; set; }
      public String Name { get; set; }
      public String PreRequisiteStep { get; set; }
      public Decimal SortOrder { get; set; }
   }

   //Pagination variables
   public Integer PageNumber { get; set; }
   public Integer RecordsPerPage { get; set; }
   public Integer TotalRecords { get; set; }
   public Integer TotalRecordsAllowed { get; set; }
   public Integer TotalPages { get; set; }
   public List<SelectOption> PageNumbersList { get; set; } //List of page numbers to display in a drop down

   public AH_UDC_CustomLookupDialog(ApexPages.StandardController controller) {
      List<AH_UDC_WorkbookStep__c> lstStepDetails = null;
      List<UserRecordAccess> lstUserRecordAccess = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;
         IsErrorOccurred = false;
         IsNIDocLookup = false;
         IsContactLookup = false;
         IsWorkbookStepLookup = false;
         PageNumber = 0; //Default page number
         TotalRecords = 0;
         TotalPages = 0;
         TotalRecordsAllowed = AH_UDC_ConfigHelper.GetInteger('AH_UDC_CustomLookupMaxRecordsAllowed', 200);
         RecordsPerPage = AH_UDC_ConfigHelper.GetInteger('AH_UDC_CustomLookupRecordsPerPage', 25);

         if (RecordsPerPage != 25 && RecordsPerPage != 50 && RecordsPerPage != 100) {
            //Prevents other values other than 25, 50 and 100
            RecordsPerPage = RecordsPerPage > 100 ? 100 : (RecordsPerPage > 50 ? 50 : 25);            
         }

         //Initialise list to prevent null reference error
         NIDocRecordsList = new List<NIDocumentWrapper> ();
         ContactRecordsList = new List<ContactWrapper> ();
         WorkbookStepRecordsList = new List<WorkbookStepWrapper> ();

         LookupType = null;
         LookupFormId = null;
         LookupFieldId = null;
         WorkbookStepId = null;

         if (String.isNotBlank(ApexPages.currentPage().getParameters().get('lktp'))
             && String.isNotBlank(ApexPages.currentPage().getParameters().get('lkfm'))
             && String.isNotBlank(ApexPages.currentPage().getParameters().get('lknm'))) {

            LookupType = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('lktp'));
            LookupFormId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('lkfm'));
            LookupFieldId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('lknm'));

            SearchText = (ApexPages.currentPage().getParameters().get('lksrch') == null) ? null : String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('lksrch'));

            if (LookupType.equalsIgnoreCase(NI_Documentation__c.sObjectType.getDescribe().getKeyPrefix())) {
               IsNIDocLookup = true;
               PageTitle = 'NI Documentation';
               RecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
            } else if (LookupType.equalsIgnoreCase(Contact.sObjectType.getDescribe().getKeyPrefix())) {
               IsContactLookup = true;
               PageTitle = 'Contacts';
            } else {
               IsErrorOccurred = true;
               LogException('Constructor', 'Invalid LookupType Value : ' + LookupType + '. Expected values : ' + NI_Documentation__c.sObjectType.getDescribe().getKeyPrefix() + ' or ' + Contact.sObjectType.getDescribe().getKeyPrefix(), null);
               return;
            }
         }
         else if (String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
            WorkbookStepId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));            
            IsWorkbookStepLookup = true;
            PageTitle = 'Workbook Step';
            TotalRecordsAllowed = 10000; //Ignore maximum records limit for Prerequisite Step lookup page

            RecordTypeId = Schema.SObjectType.AH_UDC_Workbookstep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();            
            lstStepDetails = new List<AH_UDC_WorkbookStep__c> ([SELECT Workbook__c, Workbook__r.StepsinOrder__c, Prerequisite_Step__c, SortOrder__c FROM AH_UDC_WorkbookStep__c WHERE Id = :WorkbookStepId AND RecordTypeId = :RecordTypeId]);            
            if (lstStepDetails.size() == 0) {
               IsErrorOccurred = true;
               LogException('Constructor', 'Workbook Step record not found', null);
               return;
            }

            WorkbookId = lstStepDetails[0].Workbook__c;
            //Check if logged in user has modify access of the workbook or not
            lstUserRecordAccess = new List<UserRecordAccess> ([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE RecordId = :WorkbookId AND UserId = :UserInfo.getUserId()]);
            if (lstUserRecordAccess.size() > 0 && lstUserRecordAccess[0].HasEditAccess) {
               if (lstStepDetails[0].Workbook__r.StepsinOrder__c) {
                  //If StepsinOrder is True then display a message
                  ValidationMessage = Label.AH_UDC_WorkbookStepCustomLookupStepsInOrderMessage;
               } else {
                  PrequisiteStepId = lstStepDetails[0].Prerequisite_Step__c;
                  WorkbookStepSortOrder = lstStepDetails[0].SortOrder__c;
               }
            } else {
               //If user doesn't have modify rights for the workbook, then display error message
               ValidationMessage = Label.AH_UDC_NoRightsMessage;
            }
         } else {
            IsErrorOccurred = true;
            LogException('Constructor', 'Parameter Missing - LookupType, LookupFormId, LookupFieldId or WorkbookStepId', null);
         }

         if (!IsErrorOccurred && String.isBlank(ValidationMessage)) {
            FillDataTableGrid();
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('Constructor', strErrorMessage, ex);
      }
      finally {
         //Write any Queued Log Messages to controller property
         PageLoadLogMessages = AH_UDC_LogHelper.GetQueuedLogs();
      }
   }

   //Escape special characters from the search text
   public String EscapeSpecialCharacters(String strText) {
      String strNewText = null;
      try {
         strNewText = strText.replace('\\', '\\\\');
         strNewText = strNewText.replace('_', '\\_');
         strNewText = strNewText.replace('%', '\\%');
         strNewText = strNewText.replace('\'', '\\\'');
         AH_UDC_LogHelper.Debug('SearchText after replacing special characters -> ' + strNewText);
         return strNewText;
      }
      catch(Exception exc) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + exc.getMessage() + ' at Line Number ' + exc.getLineNumber();
         LogException('EscapeSpecialCharacters', strErrorMessage, exc);
         throw exc;
      }
   }

   //Search based on search text and fill result into grid
   public void FillDataTableGrid() {
      try {
         SetPaginationVariablesValue();

         Integer intOffSet = PageNumber * RecordsPerPage;
         Integer intLimit = RecordsPerPage;
         if (intOffSet + intLimit > TotalRecordsAllowed) {
            AH_UDC_LogHelper.Debug('TotalRecordsAllowed => ' + TotalRecordsAllowed);
            AH_UDC_LogHelper.Debug('intOffSet + intLimit => ' + (intOffSet + intLimit));

            //Do not allow total records more than specified in custom label
            intLimit = TotalRecordsAllowed - intOffSet;
            if (intLimit <= 0) {
               intLimit = TotalRecordsAllowed;
            }
            AH_UDC_LogHelper.Debug('New Limit => ' + intLimit);
         }

         if (IsNIDocLookup) {
            GetNIDocRecords(intLimit, intOffSet);
         }
         else if (IsContactLookup) {
            GetContactRecords(intLimit, intOffSet);
         }
         else if (IsWorkbookStepLookup) {
            if (String.isBlank(ValidationMessage)) { //If StepsInOrder is true then do not get records
               GetWorkbookStepRecords(intLimit, intOffSet);
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('FillDataTableGrid', strErrorMessage, ex);
      }
   }

   //Get NI Documentation records based on search text
   private void GetNIDocRecords(Integer intLimit, Integer intOffSet) {
      String strQuery = null, strObjectName = null, strSelectColumns = null, strDefaultFilter = null, strOrderByColumns = null;
      String[] arrFilterColumns = null;
      List<NI_Documentation__c> lstNIDocs = null;
      NIDocumentWrapper objNIDocWrapper = null;
      try {
         NIDocRecordsList = new List<NIDocumentWrapper> ();
         if (String.isNotBlank(SearchText)) {
            strObjectName = 'NI_Documentation__c';
            strSelectColumns = 'Id, Name, Document_Name__c, AH_UDC_PropertyAccount__r.PropertyName__c, Account__r.Name';
            arrFilterColumns = new String[] { 'Name', 'Document_Name__c', 'AH_UDC_PropertyAccount__r.PropertyName__c', 'Account__r.Name' };
            strDefaultFilter = 'RecordTypeId = \'' + RecordTypeId + '\'';
            strOrderByColumns = 'Document_Name__c';
            //Prepare query to get records from NI_Documentation__c object based on search text
            strQuery = GetSOQLQuery(false, strObjectName, strSelectColumns, arrFilterColumns, strDefaultFilter, strOrderByColumns, intLimit, intOffSet);
            if (String.isNotBlank(strQuery)) {
               lstNIDocs = Database.query(strQuery);
            }
         }
         else { //Get recently viewed records
            AH_UDC_LogHelper.Debug('Get NI Documentation Records from Recently Viewed Object');
            lstNIDocs = GetRecentlyViewedNIDocs(false, intLimit, intOffSet);
         }

         if (lstNIDocs != null && lstNIDocs.size() > 0) {
            for (NI_Documentation__c objNIDoc : lstNIDocs) {
               objNIDocWrapper = new NIDocumentWrapper();
               objNIDocWrapper.Id = objNIDoc.Id;
               objNIDocWrapper.DocumentNumber = objNIDoc.Name;
               objNIDocWrapper.DocumentName = objNIDoc.Document_Name__c;
               objNIDocWrapper.UDCPropertyName = objNIDoc.AH_UDC_PropertyAccount__r.PropertyName__c;
               objNIDocWrapper.AccountName = objNIDoc.Account__r.Name;
               NIDocRecordsList.add(objNIDocWrapper);
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetNIDocRecords', strErrorMessage, ex);
         throw ex;
      }
      finally {
         strQuery = null;
         strObjectName = null;
         strDefaultFilter = null;
         strOrderByColumns = null;
         arrFilterColumns = null;
         lstNIDocs = null;
         objNIDocWrapper = null;
      }
   }

   //Get recently viewed NI Documentation records
   private List<NI_Documentation__c> GetRecentlyViewedNIDocs(Boolean IsCountQuery, Integer intLimit, Integer intOffSet) {
      List<RecentlyViewed> lstRecentlyViewedRecords = null;
      List<Id> lstIds = null;
      try {
         if (IsCountQuery) {
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + NI_Documentation__c.sObjectType.getDescribe().getName() + '\' AND RecordTypeId = \'' + RecordTypeId + '\'');
            lstRecentlyViewedRecords = new List<RecentlyViewed> ([SELECT Id FROM RecentlyViewed WHERE Type = :NI_Documentation__c.sObjectType.getDescribe().getName() AND RecordTypeId = :RecordTypeId]);
         }
         else {
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + NI_Documentation__c.sObjectType.getDescribe().getName() + '\' AND RecordTypeId = \'' + RecordTypeId + '\' LIMIT ' + intLimit + ' OFFSET ' + intOffSet);
            lstRecentlyViewedRecords = new List<RecentlyViewed> ([SELECT Id FROM RecentlyViewed WHERE Type = :NI_Documentation__c.sObjectType.getDescribe().getName() AND RecordTypeId = :RecordTypeId ORDER BY LastViewedDate DESC NULLS LAST LIMIT :intLimit OFFSET :intOffSet]);
         }
         AH_UDC_LogHelper.Debug('lstRecentlyViewedRecords -> ' + lstRecentlyViewedRecords);
         if (lstRecentlyViewedRecords != null && lstRecentlyViewedRecords.size() > 0) {
            lstIds = new List<Id> ();
            for (RecentlyViewed obj : lstRecentlyViewedRecords) {
               lstIds.add(obj.Id);
            }
            AH_UDC_LogHelper.Debug('lstIds -> ' + lstIds);
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed NI Docs -> SELECT Id, Name, Document_Name__c, AH_UDC_PropertyAccount__r.PropertyName__c, Account__r.Name FROM NI_Documentation__c WHERE Id IN : lstIds ORDER BY LastViewedDate DESC NULLS LAST');
            return new List<NI_Documentation__c> ([SELECT Id, Name, Document_Name__c, AH_UDC_PropertyAccount__r.PropertyName__c, Account__r.Name FROM NI_Documentation__c WHERE Id IN :lstIds ORDER BY LastViewedDate DESC NULLS LAST]);
         }
         return new List<NI_Documentation__c> ();
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetRecentlyViewedNIDocs', strErrorMessage, ex);
         throw ex;
      }
      finally {
         lstRecentlyViewedRecords = null;
         lstIds = null;
      }
   }

   //Get Contact records based on search text
   private void GetContactRecords(Integer intLimit, Integer intOffSet) {
      String strQuery = null, strObjectName = null, strSelectColumns = null, strDefaultFilter = null, strOrderByColumns = null;
      String[] arrFilterColumns = null;
      List<Contact> lstContacts = null;
      List<User> lstUsers = null;
      ContactWrapper objContactWrapper = null;
      try {
         ContactRecordsList = new List<ContactWrapper> ();
         if (String.isNotBlank(SearchText)) {
            strObjectName = 'Contact';
            strSelectColumns = 'Id, Name, Email, Account.Name';
            arrFilterColumns = new String[] { 'Name', 'Email', 'Account.Name' };
            strDefaultFilter = 'Status__c = \'Active\'';
            strOrderByColumns = 'Name';
            //Prepare query to get records from Contact object based on search text
            strQuery = GetSOQLQuery(false, strObjectName, strSelectColumns, arrFilterColumns, strDefaultFilter, strOrderByColumns, intLimit, intOffSet);
            if (String.isNotBlank(strQuery)) {
               lstContacts = Database.query(strQuery);
            }
         }
         else { //Get recently viewed records
            AH_UDC_LogHelper.Debug('Get Contact Records from Recently Viewed Object');
            lstContacts = GetRecentlyViewedContacts(false, intLimit, intOffset);
         }

         if (lstContacts != null && lstContacts.size() > 0) {
            lstUsers = new List<User> ([SELECT ContactId, IsActive
                                       FROM User
                                       WHERE ContactId IN :lstContacts AND IsActive = true]);
            for (Contact objContact : lstContacts) {
               objContactWrapper = new ContactWrapper();
               objContactWrapper.Id = objContact.Id;
               objContactWrapper.Name = objContact.Name;
               objContactWrapper.Email = objContact.Email;
               objContactWrapper.AccountName = objContact.Account.Name;
               objContactWrapper.HasExternalUser = 'No';
               if (lstUsers != null && lstUsers.size() > 0) {
                  for (User objUser : lstUsers) {
                     if (objContact.Id == objUser.ContactId && objUser.IsActive) {
                        objContactWrapper.HasExternalUser = 'Yes';
                        break;
                     }
                  }
               }
               ContactRecordsList.add(objContactWrapper);
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetContactRecords', strErrorMessage, ex);
         throw ex;
      }
      finally {
         strQuery = null;
         strObjectName = null;
         strSelectColumns = null;
         strDefaultFilter = null;
         strOrderByColumns = null;
         arrFilterColumns = null;
         lstContacts = null;
         lstUsers = null;
         objContactWrapper = null;
      }
   }

   //Get recently viewed contact records
   private List<Contact> GetRecentlyViewedContacts(Boolean IsCountQuery, Integer intLimit, Integer intOffSet) {
      List<RecentlyViewed> lstRecentlyViewedRecords = null;
      List<Id> lstIds = null;
      try {
         AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + Contact.sObjectType.getDescribe().getName() + '\'');
         lstRecentlyViewedRecords = new List<RecentlyViewed> ([SELECT Id FROM RecentlyViewed WHERE Type = :Contact.sObjectType.getDescribe().getName() ORDER BY LastViewedDate DESC NULLS LAST]);
         AH_UDC_LogHelper.Debug('lstRecentlyViewedRecords -> ' + lstRecentlyViewedRecords);
         if (lstRecentlyViewedRecords != null && lstRecentlyViewedRecords.size() > 0) {
            lstIds = new List<Id> ();
            for (RecentlyViewed obj : lstRecentlyViewedRecords) {
               lstIds.add(obj.Id);
            }

            AH_UDC_LogHelper.Debug('lstIds -> ' + lstIds);
            if (IsCountQuery) {
               AH_UDC_LogHelper.Debug('Query to get Recently Viewed Contacts -> SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN : lstIds AND Status__c = \'Active\'');
               return new List<Contact> ([SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN :lstIds AND Status__c = 'Active']);
            }
            else {
               AH_UDC_LogHelper.Debug('Query to get Recently Viewed Contacts -> SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN : lstIds AND Status__c = \'Active\' ORDER BY LastViewedDate DESC NULLS LAST LIMIT ' + intLimit + ' OFFSET ' + intOffSet);
               return new List<Contact> ([SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN :lstIds AND Status__c = 'Active' ORDER BY LastViewedDate DESC NULLS LAST LIMIT :intLimit OFFSET :intOffSet]);
            }
         }
         return new List<Contact> ();
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetRecentlyViewedContacts', strErrorMessage, ex);
         throw ex;
      }
      finally {
         lstRecentlyViewedRecords = null;
         lstIds = null;
      }
   }

   //Get Workbook Step records based on search text
   private void GetWorkbookStepRecords(Integer intLimit, Integer intOffSet) {
      String strQuery = null, strObjectName = null, strSelectColumns = null, strDefaultFilter = null, strOrderByColumns = null;
      String[] arrFilterColumns = null;
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = null;
      WorkbookStepWrapper objWorkbookStepWrapper = null;
      try {
         WorkbookStepRecordsList = new List<WorkbookStepWrapper> ();

         strObjectName = 'AH_UDC_Workbookstep__c';
         strSelectColumns = 'Id, Name, Prerequisite_Step__r.Name, SortOrder__c';
         arrFilterColumns = new String[] { 'Name', 'Prerequisite_Step__r.Name' };
         strDefaultFilter = 'Enabled__c = true AND RecordTypeId = \'' + RecordTypeId + '\'';
         //Get step records based on workbookid and sort order less than current step's sort order
         strDefaultFilter += ' AND Workbook__c = \'' + WorkbookId + '\' AND SortOrder__c < ' + WorkbookStepSortOrder;
         strOrderByColumns = 'SortOrder__c';
         //Prepare query to get records from AH_UDC_Workbookstep__c object
         strQuery = GetSOQLQuery(false, strObjectName, strSelectColumns, arrFilterColumns, strDefaultFilter, strOrderByColumns, intLimit, intOffSet);

         if (String.isBlank(strQuery)) return;

         lstWorkbookSteps = Database.query(strQuery);
         if (lstWorkbookSteps != null && lstWorkbookSteps.size() > 0) {
            for (AH_UDC_Workbookstep__c objStep : lstWorkbookSteps) {
               objWorkbookStepWrapper = new WorkbookStepWrapper();
               objWorkbookStepWrapper.Id = objStep.Id;
               objWorkbookStepWrapper.Name = objStep.Name;
               objWorkbookStepWrapper.PreRequisiteStep = objStep.Prerequisite_Step__r.Name;
               objWorkbookStepWrapper.SortOrder = objStep.SortOrder__c;
               WorkbookStepRecordsList.add(objWorkbookStepWrapper);
            }
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetWorkbookStepRecords', strErrorMessage, ex);
         throw ex;
      }
   }

   //Returns filtered string based on search text provided
   private String GetFilterString(String[] arrColumns) {
      String strFilter = null;
      String[] arrSearchText = null;
      try {
         AH_UDC_LogHelper.Debug('SearchText => ' + SearchText);
         AH_UDC_LogHelper.Debug('arrColumns => ' + arrColumns);
         if (String.isBlank(SearchText) || arrColumns == null || arrColumns.size() == 0) {
            AH_UDC_LogHelper.Debug('strFilter (1) -> ' + strFilter);
            return strFilter;
         }

         arrSearchText = EscapeSpecialCharacters(SearchText.trim()).split(' ');
         if (arrSearchText == null || arrSearchText.size() == 0) {
            AH_UDC_LogHelper.Debug('strFilter (2) -> ' + strFilter);
            return strFilter;
         }

         strFilter = ' AND (';
         for (Integer i = 0; i<arrColumns.size(); i++) {
            strFilter += '('; //Start new block for filter
            for (Integer j = 0; j<arrSearchText.size(); j++) {
               if (String.isNotBlank(arrSearchText[j])) {
                  if (j > 0) {
                     strFilter += ' AND '; //Append AND block to search whole word
                  }
                  //Append AND block to search with whole word in specific column
                  strFilter += arrColumns[i] + ' LIKE \'%' + arrSearchText[j] + '%\'';
               }
            }
            if (i<arrColumns.size() - 1) {
               strFilter += ') OR '; //Start OR block to search the word in all specified column
            } else {
               strFilter += ')'; //Complete OR block if end of the search
            }
         }
         strFilter += ')'; //Complete AND block if all columns added in filter string

         AH_UDC_LogHelper.Debug('strFilter (3) -> ' + strFilter);
         return strFilter;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetFilterString', strErrorMessage, ex);
         throw ex;
      }
   }

   //Prepare and return SOQL query based on parameters
   private String GetSOQLQuery(Boolean isCountQuery, String strObjectName, String strSelectColumns, String[] arrFilterColumns,
                               String strDefaultFilter, String strOrderByColumns, Integer intLimit, Integer intOffSet) {
      String strQuery = null;
      try {
         if (isCountQuery) {
            strQuery = 'SELECT COUNT()';
         } else {
            strQuery = 'SELECT ' + strSelectColumns;
         }

         strQuery += ' FROM ' + strObjectName;
         strQuery += ' WHERE ' + strDefaultFilter;

         if (String.isNotBlank(SearchText)) {
            strQuery += GetFilterString(arrFilterColumns); //Add search text filter in the query
         }

         if (!isCountQuery) {
            if (String.isNotBlank(strOrderByColumns)) {
               strQuery += ' ORDER BY ' + strOrderByColumns;
            }
            strQuery += ' LIMIT ' + intLimit + ' OFFSET ' + intOffSet; //Pagination
         }
         AH_UDC_LogHelper.Debug('strQuery => ' + strQuery);

         return strQuery;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetSOQLQuery', strErrorMessage, ex);
         throw ex;
      }
   }

   //Update prerequisite step in AH_UDC_WorkbookStep__c object    
   public void SetPrerequisiteStep() {
      AH_UDC_WorkbookStep__c objStepDetails = null;
      String prerequisiteStepId = null;      
      try {
	    //TODO : Security related changes not implemented yet. Needs to check user access (security) and add check for valid PrerequisiteStepId for current workbook       
		   objStepDetails = new AH_UDC_WorkbookStep__c(Id = WorkbookStepId);         
		   if (String.isBlank(ApexPages.currentPage().getParameters().get('prerequisiteStepId'))) {
            //Remove Prerequisite step (Used when Remove Prerequisite button clicked)
            objStepDetails.Prerequisite_Step__c = null;
         }
		   else {
		      //Add Prerequisite step
            prerequisiteStepId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('prerequisiteStepId'));  
		      objStepDetails.Prerequisite_Step__c = prerequisiteStepId; 
         }     
         update objStepDetails;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SetPrerequisiteStep', strErrorMessage, ex);
      }
    }

   //----------------------------- Pagination Methods :: Start -----------------------------//

   //Set values of pagination variables
   private void SetPaginationVariablesValue() {
      String strQuery = null;
      try {
         TotalRecords = GetTotalRecordsCount();

         if (math.mod(TotalRecords, RecordsPerPage)> 0) {
            TotalPages = TotalRecords / RecordsPerPage;
         }
         else {
            TotalPages = (TotalRecords / RecordsPerPage) - 1;
         }

         PageNumbersList = new List<SelectOption> ();
         for (Integer i = 0; i <= TotalPages; i++) {
            PageNumbersList.add(new SelectOption(String.valueOf(i), String.valueOf(i + 1)));
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('SetPaginationVariablesValue', strErrorMessage, ex);
         throw ex;
      }
   }

   //Return total records count for pagination
   private Integer GetTotalRecordsCount() {
      String strQuery = null, strObjectName = null, strDefaultFilter = null;
      String[] arrFilterColumns = null;
      Integer intTotalRecords = 0;
      List<NI_Documentation__c> lstNIDocs = null;
      List<Contact> lstContacts = null;
      try {
         if (IsNIDocLookup) {
            if (String.isNotBlank(SearchText)) {
               strObjectName = 'NI_Documentation__c';
               arrFilterColumns = new String[] { 'Name', 'Document_Name__c', 'AH_UDC_PropertyAccount__r.PropertyName__c', 'Account__r.Name' };
               strDefaultFilter = 'RecordTypeId = \'' + RecordTypeId + '\'';
               //Prepare query to get total records count from NI_Documentation__c object
               strQuery = GetSOQLQuery(true, strObjectName, '', arrFilterColumns, strDefaultFilter, '', 0, 0);
            }
            else { //Get recently viewed records count
               AH_UDC_LogHelper.Debug('Get Total Records count from Recently Viewed Object');
               lstNIDocs = GetRecentlyViewedNIDocs(true, 0, 0);
               intTotalRecords = lstNIDocs != null ? lstNIDocs.size() : 0;
            }
         }
         else if (IsContactLookup) {
            if (String.isNotBlank(SearchText)) {
               strObjectName = 'Contact';
               arrFilterColumns = new String[] { 'Name', 'Email', 'Account.Name' };
               strDefaultFilter = 'Status__c = \'Active\'';
               //Prepare query to get total records count from Contact object
               strQuery = GetSOQLQuery(true, strObjectName, '', arrFilterColumns, strDefaultFilter, '', 0, 0);
            }
            else { //Get recently viewed records count
               AH_UDC_LogHelper.Debug('Get Total Records count from Recently Viewed Object');
               lstContacts = GetRecentlyViewedContacts(true, 0, 0);
               intTotalRecords = lstContacts != null ? lstContacts.size() : 0;
            }
         }
         else if (IsWorkbookStepLookup) {
            strObjectName = 'AH_UDC_Workbookstep__c';
            arrFilterColumns = new String[] { 'Name', 'Prerequisite_Step__r.Name' };
            strDefaultFilter = 'Enabled__c = true AND RecordTypeId = \'' + RecordTypeId + '\'';
            //Get step records based on workbookid and sort order less than current step's sort order
            strDefaultFilter += ' AND Workbook__c = \'' + WorkbookId + '\' AND SortOrder__c < ' + WorkbookStepSortOrder;
            //Prepare query to get total records count from AH_UDC_WorkbookStep__c object
            strQuery = GetSOQLQuery(true, strObjectName, '', arrFilterColumns, strDefaultFilter, '', 0, 0);
         }

         if (String.isNotBlank(strQuery)) {
            //Get total records from the object
            intTotalRecords = Integer.valueOf(Database.countQuery(strQuery));
         }

         AH_UDC_LogHelper.Debug('intTotalRecords => ' + intTotalRecords);
         AH_UDC_LogHelper.Debug('TotalRecordsAllowed => ' + TotalRecordsAllowed);
         if (intTotalRecords> TotalRecordsAllowed) {
            //Do not allow total records more than specified in config setting
            intTotalRecords = TotalRecordsAllowed;
            AH_UDC_LogHelper.Debug('New TotalRecords => ' + intTotalRecords);
         }
         return intTotalRecords;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetTotalRecordsCount', strErrorMessage, ex);
         throw ex;
      }
      finally {
         strQuery = null;
         strObjectName = null;
         strDefaultFilter = null;
         arrFilterColumns = null;
      }
   }

   //Pagination First button click
   public void Beginning() {
      PageNumber = 0;
      FillDataTableGrid();
   }

   //Pagination Previous button click
   public void Previous() {
      PageNumber--;
      FillDataTableGrid();
   }

   //Pagination Next button click
   public void Next() {
      PageNumber++;
      FillDataTableGrid();
   }

   //Pagination Last button click
   public void End() {
      PageNumber = TotalPages;
      FillDataTableGrid();
   }
   //----------------------------- Pagination Methods :: End -----------------------------//

   //Log exception and display error message to user
   private void LogException(String strMethodName, String strErrorMessage, Exception exc) {
      IsErrorOccurred = true;
      AH_UDC_SharedWithoutSharing.LogException(LogFunctionalArea, strMethodName, strErrorMessage, System.Label.AH_UDC_Common_Error_Message_Backend, exc);
   }

   //This method is used by a client side actionfunction to log AH_UDC_Log entries that couldn't be created by the page load due to SOQL DML retrictions
   public void ServerLogMessages() {
      AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages');
      try {
         if (PageLoadLogMessages != null && PageLoadLogMessages.size() > 0) {
            insert(PageLoadLogMessages);
         }
         PageLoadLogMessages = new List<AH_UDC_Log__c> ();

         //Generate error for test class execution to cover catch block
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1/0;
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug(LogFunctionalArea + '.ServerLogMessages - Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              LogFunctionalArea,
                              'ServerLogMessages',
                              'An exception occurred logging Page Load AH_UDC_Log entries',
                              exc, null, null);
      }
   }
}