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
   public Boolean IsNIDocLookup { get; set; } { IsNIDocLookup = false; }
   public Boolean IsAccountLookup { get; set; } { IsAccountLookup = false; }
   public Boolean IsContactLookup { get; set; } { IsContactLookup = false; }
   public Boolean IsProjectLookup { get; set; } { IsProjectLookup = false; }
   public Boolean IsWorkbookStepLookup { get; set; } { IsWorkbookStepLookup = false; }
   public Boolean IsErrorOccurred { get; set; } { IsErrorOccurred = false; }
   public String ValidationMessage { get; set; }
   public List<NIDocumentWrapper> NIDocRecordsList { get; set; }
   public List<AccountWrapper> AccountRecordsList { get; set; }
   public List<ContactWrapper> ContactRecordsList { get; set; }
   public List<pse__Proj__c> ProjectRecordsList { get; set; }
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

   public class AccountWrapper {
      public Id Id { get; set; }
      public String Name { get; set; }
      public String AccountNumber { get; set; }
      public String ShippingStreet { get; set; }
      public String ShippingCity { get; set; }
      public String Phone { get; set; }
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
   public Integer PageNumber { get; set; } { PageNumber = 0; }
   public Integer RecordsPerPage { get; set; }
   public Integer TotalRecords { get; set; } { TotalRecords = 0; }
   public Integer TotalRecordsAllowed { get; set; }
   public Integer TotalPages { get; set; } { TotalPages = 0; }
   public List<SelectOption> PageNumbersList { get; set; } //List of page numbers to display in a drop down

   public AH_UDC_CustomLookupDialog(ApexPages.StandardController controller) {
      List<AH_UDC_WorkbookStep__c> lstStepDetails = null;
      List<UserRecordAccess> lstUserRecordAccess = null;
      try {
         //This is a controller load, DML is not allowed so Queue logs
         AH_UDC_LogHelper.QueueLogs = true;

         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceCustomLookupDialogPageLoadError', FALSE, true))
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Custom Lookup Dialog Page Load'));
         }

         TotalRecordsAllowed = AH_UDC_ConfigHelper.GetInteger('AH_UDC_CustomLookupMaxRecordsAllowed', 200);
         RecordsPerPage = AH_UDC_ConfigHelper.GetInteger('AH_UDC_CustomLookupRecordsPerPage', 25);
         AH_UDC_LogHelper.Debug('TotalRecordsAllowed => ' + TotalRecordsAllowed);
         if (RecordsPerPage != 25 && RecordsPerPage != 50 && RecordsPerPage != 100) {
            //Prevents other values other than 25, 50 and 100
            RecordsPerPage = RecordsPerPage > 100 ? 100 : (RecordsPerPage > 50 ? 50 : 25);
         }
         AH_UDC_LogHelper.Debug('RecordsPerPage => ' + RecordsPerPage);

         //Initialise list to prevent null reference error
         NIDocRecordsList = new List<NIDocumentWrapper> ();
         AccountRecordsList = new List<AccountWrapper> ();
         ContactRecordsList = new List<ContactWrapper> ();
         ProjectRecordsList = new List<pse__Proj__c> ();
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

            SearchText = ApexPages.currentPage().getParameters().get('lksrch');
            if (LookupType.equalsIgnoreCase(NI_Documentation__c.sObjectType.getDescribe().getKeyPrefix())) {
               IsNIDocLookup = true;
               PageTitle = 'NI Documentation';
               RecordTypeId = Schema.SObjectType.NI_Documentation__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
            } else if (LookupType.equalsIgnoreCase(Account.sObjectType.getDescribe().getKeyPrefix())) {
               IsAccountLookup = true;
               PageTitle = 'Account';
            } else if (LookupType.equalsIgnoreCase(Contact.sObjectType.getDescribe().getKeyPrefix())) {
               IsContactLookup = true;
               PageTitle = 'Contacts';
            } else if (LookupType.equalsIgnoreCase(pse__Proj__c.sObjectType.getDescribe().getKeyPrefix())) {
               IsProjectLookup = true;
               PageTitle = 'Projects';
            } else {
               IsErrorOccurred = true;
               LogException('Constructor', 'Invalid LookupType Value : ' + LookupType + '. Expected values : ' + NI_Documentation__c.sObjectType.getDescribe().getKeyPrefix() + ' or ' + Contact.sObjectType.getDescribe().getKeyPrefix(), null);
               return;
            }
         }
         else if (String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
            WorkbookStepId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
            AH_UDC_LogHelper.Debug('WorkbookStepId => ' + WorkbookStepId);
            IsWorkbookStepLookup = true;
            PageTitle = 'Workbook Step';
            TotalRecordsAllowed = 10000; //Ignore maximum records limit for Prerequisite Step lookup page

            RecordTypeId = Schema.SObjectType.AH_UDC_Workbookstep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
            lstStepDetails = [SELECT Workbook__c, Workbook__r.StepsinOrder__c, Prerequisite_Step__c, SortOrder__c
                              FROM AH_UDC_WorkbookStep__c
                              WHERE Id = :WorkbookStepId
                              AND RecordTypeId = :RecordTypeId];
            AH_UDC_LogHelper.Debug('lstStepDetails => ' + lstStepDetails);
            if (lstStepDetails.size() == 0) {
               IsErrorOccurred = true;
               LogException('Constructor', 'Workbook Step record not found', null);
               return;
            }

            WorkbookId = lstStepDetails[0].Workbook__c;

            AH_UDC_LogHelper.Debug('WorkbookId => ' + WorkbookId);
            //Check if logged in user has modify access of the workbook and is either UDC System Admin or UDC Workbook Admin (WB User's can't modify Workbooks)
            if (AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(WorkbookId) == false) //This is a workbook (not WB Sent) so there is no NI doc
            {
               ValidationMessage = Label.AH_UDC_NoRightsMessage;
               return;
            }
            if (lstStepDetails[0].Workbook__r.StepsinOrder__c) {
               //If StepsinOrder is True then display a message
               ValidationMessage = Label.AH_UDC_WorkbookStepCustomLookupStepsInOrderMessage;
               return;
            }

            PrequisiteStepId = lstStepDetails[0].Prerequisite_Step__c;
            WorkbookStepSortOrder = lstStepDetails[0].SortOrder__c;
         } else {
            LogException('Constructor', 'Parameter Missing - LookupType, LookupFormId, LookupFieldId or WorkbookStepId', null);
            return;
         }

         AH_UDC_LogHelper.Debug('IsErrorOccurred => ' + IsErrorOccurred);
         AH_UDC_LogHelper.Debug('ValidationMessage => ' + ValidationMessage);
         if (String.isBlank(ValidationMessage)) {
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
         AH_UDC_LogHelper.clearQueuedLogs();
         AH_UDC_LogHelper.QueueLogs = false;
      }
   }

   //Escape special characters from the search text.  This will not escape single quotes
   //because we need to do that before calling this function using escapeSingleQuotes()
   //to satisfy checkmarx
   public String EscapeSpecialCharacters(String strText) {
      String strNewText = null;
      try {
         strNewText = strText.replace('_', '\\_');
         strNewText = strNewText.replace('%', '\\%');
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
         else if (IsAccountLookup) {
            GetAccountRecords(intLimit, intOffSet);
         }
         else if (IsContactLookup) {
            GetContactRecords(intLimit, intOffSet);
         }
         else if (IsProjectLookup) {
            GetProjectRecords(intLimit, intOffSet);
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
   }

   //Get recently viewed NI Documentation records
   private List<NI_Documentation__c> GetRecentlyViewedNIDocs(Boolean IsCountQuery, Integer intLimit, Integer intOffSet) {
      List<RecentlyViewed> lstRecentlyViewedRecords = null;
      List<Id> lstIds = null;
      try {
         if (IsCountQuery) {
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + NI_Documentation__c.sObjectType.getDescribe().getName() + '\' AND RecordTypeId = \'' + RecordTypeId + '\'');
            lstRecentlyViewedRecords = [SELECT Id FROM RecentlyViewed WHERE Type = :NI_Documentation__c.sObjectType.getDescribe().getName() AND RecordTypeId = :RecordTypeId];
         }
         else {
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + NI_Documentation__c.sObjectType.getDescribe().getName() + '\' AND RecordTypeId = \'' + RecordTypeId + '\' LIMIT ' + intLimit + ' OFFSET ' + intOffSet);
            lstRecentlyViewedRecords = [SELECT Id FROM RecentlyViewed WHERE Type = :NI_Documentation__c.sObjectType.getDescribe().getName() AND RecordTypeId = :RecordTypeId ORDER BY LastViewedDate DESC NULLS LAST LIMIT :intLimit OFFSET :intOffSet];
         }
         AH_UDC_LogHelper.Debug('lstRecentlyViewedRecords -> ' + lstRecentlyViewedRecords);
         if (lstRecentlyViewedRecords != null && lstRecentlyViewedRecords.size() > 0) {
            lstIds = new List<Id> ();
            for (RecentlyViewed obj : lstRecentlyViewedRecords) {
               lstIds.add(obj.Id);
            }
            AH_UDC_LogHelper.Debug('lstIds -> ' + lstIds);
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed NI Docs -> SELECT Id, Name, Document_Name__c, AH_UDC_PropertyAccount__r.PropertyName__c, Account__r.Name FROM NI_Documentation__c WHERE Id IN : lstIds ORDER BY LastViewedDate DESC NULLS LAST');
            return[SELECT Id, Name, Document_Name__c, AH_UDC_PropertyAccount__r.PropertyName__c, Account__r.Name FROM NI_Documentation__c WHERE Id IN : lstIds ORDER BY LastViewedDate DESC NULLS LAST];
         }
         return new List<NI_Documentation__c> ();
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetRecentlyViewedNIDocs', strErrorMessage, ex);
         throw ex;
      }
   }

   //Get Account records based on search text
   private Boolean GetAccountRecords(Integer intLimit, Integer intOffSet) {
      String strQuery = null, strObjectName = null, strSelectColumns = null, strDefaultFilter = null, strOrderByColumns = null;
      String[] arrFilterColumns = null;
      List<Account> lstAccounts = null;
      List<User> lstUsers = null;
      AccountWrapper objAccountWrapper = null;
      try {
         AccountRecordsList = new List<AccountWrapper> ();
         if (String.isNotBlank(SearchText)) {
            strObjectName = 'Account';
            strSelectColumns = 'Name, AccountNumber, ShippingStreet, ShippingCity, Phone';
            arrFilterColumns = new String[] { 'Name', 'ShippingStreet', 'ShippingCity' };
            strDefaultFilter = '';
            strOrderByColumns = 'Name';
            //Prepare query to get records from Account object
            strQuery = GetSOQLQuery(false, strObjectName, strSelectColumns, arrFilterColumns, strDefaultFilter, strOrderByColumns, intLimit, intOffSet);
            if (String.isNotBlank(strQuery)) {
               AH_UDC_LogHelper.debug('GetAccountRecords Query: ' + strQuery);
               lstAccounts = Database.query(strQuery);
            }
         }
         else { //Get recently viewed records
            AH_UDC_LogHelper.Debug('Get Account Records from Recently Viewed Object');
            lstAccounts = GetRecentlyViewedAccounts(false, intLimit, intOffset);
         }

         if (lstAccounts != null && lstAccounts.size() > 0) {
            // Build the list of Accounts that will be used to populate the grid on the search page
            for (Account acct : lstAccounts) {
               objAccountWrapper = new AccountWrapper();
               objAccountWrapper.Id = acct.Id;
               objAccountWrapper.Name = acct.Name;
               objAccountWrapper.AccountNumber = acct.AccountNumber;
               objAccountWrapper.ShippingStreet = acct.ShippingStreet;
               objAccountWrapper.ShippingCity = acct.ShippingCity;
               objAccountWrapper.Phone = acct.Phone;

               AccountRecordsList.add(objAccountWrapper);
            }
         }
         return true;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetAccountRecords', strErrorMessage, ex);
         return false;
      }
   }

   //Get Contact records based on search text
   private Boolean GetContactRecords(Integer intLimit, Integer intOffSet) {
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
            lstUsers = [SELECT ContactId, IsActive
                        FROM User
                        WHERE ContactId IN :lstContacts AND IsActive = true];
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

         return true;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetContactRecords', strErrorMessage, ex);
         return false;
      }
   }

   //Get Contact records based on search text
   private Boolean GetProjectRecords(Integer intLimit, Integer intOffSet) {
      List<pse__Proj__c> lstProjects = null;
      try {
         //Unit Test Force Exception
         if (AH_UDC_ConfigHelper.GetBoolean('AH_UDC_UnitTestForceProjectLookupDialogeError', FALSE, true))
         {
            throw(new AH_UDC_Shared.UDCException(AH_UDC_Constants.UNIT_TEST_EXCEPTION_PREFIX + 'Project Lookup Dialoge'));
         }
         ProjectRecordsList = new List<pse__Proj__c> ();
         if (String.isNotBlank(SearchText)) {
            String strObjectName = 'pse__Proj__c';
            String strSelectColumns = 'Id, Name, pse__Project_Manager__r.Name, pse__Project_Status__c';
            String[] arrFilterColumns = new String[] { 'Name' };
            String strOrderByColumns = 'Name';
            //Prepare query to get records from pse__Proj__c object based on search text
            //Featching all projects here without using limit and offset because pagination will be performed after checking project access rights
            String strQuery = GetSOQLQuery(false, strObjectName, strSelectColumns, arrFilterColumns, '', strOrderByColumns, intLimit, intOffSet);
            if (String.isNotBlank(strQuery)) {
               ProjectRecordsList = Database.query(strQuery);
            }
         }
         else { //Get recently viewed records
            AH_UDC_LogHelper.Debug('Get Project Records from Recently Viewed Object');
            ProjectRecordsList = GetRecentlyViewedProjects(false, intLimit, intOffSet);
         }
         AH_UDC_LogHelper.Debug('GetProjectRecords() => intOffSet: ' + intOffSet);
         AH_UDC_LogHelper.Debug('GetProjectRecords() => intLimit: ' + intLimit);
         AH_UDC_LogHelper.Debug('GetProjectRecords() => ProjectRecordsList.size(): ' + ProjectRecordsList.size());
         return true;
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetProjectRecords', strErrorMessage, ex);
         return false;
      }
   }

   //Get recently viewed Account records
   private List<Account> GetRecentlyViewedAccounts(Boolean IsCountQuery, Integer intLimit, Integer intOffSet) {
      List<RecentlyViewed> lstRecentlyViewedRecords = null;
      Set<Id> lstIds = null;
      try {
         AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + Account.sObjectType.getDescribe().getName() + '\'');
         lstRecentlyViewedRecords = [SELECT Id FROM RecentlyViewed WHERE Type = :Account.sObjectType.getDescribe().getName() ORDER BY LastViewedDate DESC NULLS LAST];
         AH_UDC_LogHelper.Debug('lstRecentlyViewedRecords -> ' + lstRecentlyViewedRecords);
         if (lstRecentlyViewedRecords != null && lstRecentlyViewedRecords.size() > 0) {
            lstIds = new Set<Id> ();
            for (RecentlyViewed obj : lstRecentlyViewedRecords)
            lstIds.add(obj.Id);

            AH_UDC_LogHelper.Debug('lstIds -> ' + lstIds);
            if (IsCountQuery) {
               AH_UDC_LogHelper.Debug('Query to get Recently Viewed Accounts -> SELECT Id, Name, AccountNumber, ShippingStreet, ShippingCity, Phone FROM Account WHERE Id IN : lstIds');
               return[SELECT Id, Name, AccountNumber, ShippingStreet, ShippingCity, Phone FROM Account WHERE Id IN : lstIds];
            }
            else {
               AH_UDC_LogHelper.Debug('Query to get Recently Viewed Accounts -> SELECT Id, Name, AccountNumber, ShippingStreet, ShippingCity, Phone FROM Account WHERE Id IN : lstIds ORDER BY LastViewedDate DESC NULLS LAST LIMIT ' + intLimit + ' OFFSET ' + intOffSet);
               return[SELECT Id, Name, AccountNumber, ShippingStreet, ShippingCity, Phone FROM Account WHERE Id IN : lstIds ORDER BY LastViewedDate DESC NULLS LAST LIMIT : intLimit OFFSET : intOffSet];
            }
         }
         return new List<Account> ();
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetRecentlyViewedAccounts', strErrorMessage, ex);
         throw ex;
      }
   }

   //Get recently viewed contact records
   private List<Contact> GetRecentlyViewedContacts(Boolean IsCountQuery, Integer intLimit, Integer intOffSet) {
      List<RecentlyViewed> lstRecentlyViewedRecords = null;
      List<Id> lstIds = null;
      try {
         AH_UDC_LogHelper.Debug('Query to get Recently Viewed Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + Contact.sObjectType.getDescribe().getName() + '\'');
         lstRecentlyViewedRecords = [SELECT Id FROM RecentlyViewed WHERE Type = :Contact.sObjectType.getDescribe().getName() ORDER BY LastViewedDate DESC NULLS LAST];
         AH_UDC_LogHelper.Debug('lstRecentlyViewedRecords -> ' + lstRecentlyViewedRecords);
         if (lstRecentlyViewedRecords != null && lstRecentlyViewedRecords.size() > 0) {
            lstIds = new List<Id> ();
            for (RecentlyViewed obj : lstRecentlyViewedRecords) {
               lstIds.add(obj.Id);
            }

            AH_UDC_LogHelper.Debug('lstIds -> ' + lstIds);
            if (IsCountQuery) {
               AH_UDC_LogHelper.Debug('Query to get Recently Viewed Contacts -> SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN : lstIds AND Status__c = \'Active\'');
               return[SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN : lstIds AND Status__c = 'Active'];
            }
            else {
               AH_UDC_LogHelper.Debug('Query to get Recently Viewed Contacts -> SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN : lstIds AND Status__c = \'Active\' ORDER BY LastViewedDate DESC NULLS LAST LIMIT ' + intLimit + ' OFFSET ' + intOffSet);
               return[SELECT Id, Name, Email, Account.Name FROM Contact WHERE Id IN : lstIds AND Status__c = 'Active' ORDER BY LastViewedDate DESC NULLS LAST LIMIT : intLimit OFFSET : intOffSet];
            }
         }
         return new List<Contact> ();
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetRecentlyViewedContacts', strErrorMessage, ex);
         throw ex;
      }
   }

   //Get recently viewed project records
   private List<pse__Proj__c> GetRecentlyViewedProjects(Boolean IsCountQuery, Integer intLimit, Integer intOffSet) {
      try {
         AH_UDC_LogHelper.Debug('Query to get Recently Viewed Project Records -> SELECT Id FROM RecentlyViewed WHERE Type = \'' + pse__Proj__c.sObjectType.getDescribe().getName() + '\'');
         List<RecentlyViewed> lstRecentlyViewedRecords = [SELECT Id
                                                          FROM RecentlyViewed
                                                          WHERE Type = :pse__Proj__c.sObjectType.getDescribe().getName()
                                                          ORDER BY LastViewedDate DESC NULLS LAST];
         AH_UDC_LogHelper.Debug('GetRecentlyViewedProjects() => lstRecentlyViewedRecords: ' + lstRecentlyViewedRecords);
         if (lstRecentlyViewedRecords.size() == 0)
         return new List<pse__Proj__c> ();

         List<Id> lstIds = new List<Id> ();
         for (RecentlyViewed obj : lstRecentlyViewedRecords) {
            lstIds.add(obj.Id);
         }

         AH_UDC_LogHelper.Debug('GetRecentlyViewedProjects() => lstIds: ' + lstIds);
         if (IsCountQuery) {
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed Projects -> SELECT Id, Name, pse__Project_Manager__r.Name, pse__Project_Status__c FROM pse__Proj__c WHERE Id IN : lstIds');
            return[SELECT Id, Name, pse__Project_Manager__r.Name, pse__Project_Status__c
            FROM pse__Proj__c
            WHERE Id IN : lstIds];
         }
         else {
            AH_UDC_LogHelper.Debug('Query to get Recently Viewed Projects -> SELECT Id, Name, pse__Project_Manager__r.Name, pse__Project_Status__c FROM pse__Proj__c WHERE Id IN : lstIds LIMIT ' + intLimit + ' OFFSET ' + intOffSet);
            return[SELECT Id, Name, pse__Project_Manager__r.Name, pse__Project_Status__c
            FROM pse__Proj__c
            WHERE Id IN : lstIds
            ORDER BY LastViewedDate DESC NULLS LAST LIMIT : intLimit OFFSET : intOffSet];
         }
      }
      catch(Exception ex) {
         String strErrorMessage = 'An exception occurred for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') : ' + ex.getMessage() + ' at Line Number ' + ex.getLineNumber();
         LogException('GetRecentlyViewedProjects', strErrorMessage, ex);
         throw ex;
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

         String temp = EscapeSpecialCharacters(SearchText.trim());
         //Escape single must be done after all characters escaped
         //Otherwise it will replace single quote with \\\\' and that will not retrieve correct records
         temp = String.escapeSingleQuotes(temp);
         arrSearchText = temp.split(' ');
         if (arrSearchText == null || arrSearchText.size() == 0) {
            AH_UDC_LogHelper.Debug('strFilter (2) -> ' + strFilter);
            return strFilter;
         }

         strFilter = '(';
         for (Integer i = 0; i < arrColumns.size(); i++) {
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
            if (i < arrColumns.size() - 1) {
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
         if (String.isNotBlank(strDefaultFilter)) {
            strQuery += ' WHERE ' + strDefaultFilter;
         }

         if (String.isNotBlank(SearchText)) {
            String strFilter = GetFilterString(arrFilterColumns);
            if (String.isNotBlank(strFilter)) {
               //If default filter is blank then construct WHERE block and append search filters
               //otherwise append search filters after default filter with AND block
               strQuery += String.isNotBlank(strDefaultFilter) ? ' AND ' : ' WHERE ';
               strQuery += strFilter; //Add search text filter in the query
            }
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
         objStepDetails = new AH_UDC_WorkbookStep__c(Id = WorkbookStepId);
         if (String.isBlank(ApexPages.currentPage().getParameters().get('prerequisiteStepId'))) {
            //Remove Prerequisite step set to null when Remove Prerequisite button clicked
            objStepDetails.Prerequisite_Step__c = null;
         }
         else {
            //To set Prerequisite step check for valid prerequisitestep for workbook
            prerequisiteStepId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('prerequisiteStepId'));
            Integer totalWorkbookStep = [SELECT COUNT() FROM AH_UDC_WorkbookStep__c
                                         WHERE Workbook__c = :WorkbookId
                                         AND Id = :prerequisiteStepId
                                         AND RecordTypeId = :RecordTypeId];
            if (totalWorkbookStep == 0)
            {
               LogException('SetPrerequisiteStep', 'Someone is trying to fetch data with invalid PrerequisiteStepId', null);
               return;
            }
            objStepDetails.Prerequisite_Step__c = prerequisiteStepId;
         }
         AH_UDC_SystemContext.updateObject(objStepDetails); //WB User and WB Admin don't have access to update the PreReq. field so this must be done with system context
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

         AH_UDC_LogHelper.Debug('SetPaginationVariablesValue() => TotalRecords: ' + TotalRecords);
         AH_UDC_LogHelper.Debug('SetPaginationVariablesValue() => RecordsPerPage: ' + RecordsPerPage);
         if (math.mod(TotalRecords, RecordsPerPage)> 0) {
            TotalPages = TotalRecords / RecordsPerPage;
         }
         else {
            TotalPages = (TotalRecords / RecordsPerPage) - 1;
         }
         AH_UDC_LogHelper.Debug('SetPaginationVariablesValue() => TotalPages: ' + TotalPages);

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
      List<Account> lstAccounts = null;
      List<Contact> lstContacts = null;
      List<pse__Proj__c> lstProjects = null;
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
         else if (IsAccountLookup) {
            if (String.isNotBlank(SearchText)) {
               strObjectName = 'Account';
               arrFilterColumns = new String[] { 'Name', 'AccountNumber', 'ShippingStreet', 'ShippingCity', 'Phone' };
               strDefaultFilter = '';
               //Prepare query to get total records count from Contact object
               strQuery = GetSOQLQuery(true, strObjectName, '', arrFilterColumns, strDefaultFilter, '', 0, 0);
            }
            else {
               lstAccounts = null;
               intTotalRecords = 0;
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
         else if (IsProjectLookup) {
            if (String.isNotBlank(SearchText)) {
               strObjectName = 'pse__Proj__c';
               arrFilterColumns = new String[] { 'Name' };
               //Prepare query to get total records count from pse__Proj__c object
               strQuery = GetSOQLQuery(true, strObjectName, '', arrFilterColumns, '', '', 0, 0);
            }
            else { //Get recently viewed records count
               AH_UDC_LogHelper.Debug('Get Total Records count from Recently Viewed Object');
               lstProjects = GetRecentlyViewedProjects(true, 0, 0);
               intTotalRecords = lstProjects != null ? lstProjects.size() : 0;
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
         if (Test.isRunningTest() && LogFunctionalArea == 'TestException') Integer a = 1 / 0;
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