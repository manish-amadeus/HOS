/***********************************************************************************************
  Name            : AH_UDC_CustomLookupDialog_TEST
  Author          : Sanjay Parmar
  Created Date    : 26-Apr-2021
  Last Mod Date   : 26-Apr-2021
  Last Mod By     : Sanjay Parmar
  Description     : Test class for AH_UDC_CustomLookupDialog
 ************************************************************************************************/
@isTest
private class AH_UDC_CustomLookupDialog_TEST {
   public static final Integer TotalRecords = 7;
   public static final Integer RecordPerPage = 2;
   @testSetup
   private static void SetupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'cldWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'cldWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[1].Id);
      }
   }

   @isTest
   private static void TestCustomLookupWithException() {
      List<User> listUser = [Select Id From User Where Email like '%cldWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');
      User uWBA = listUser[0];

      Test.startTest();
      System.runAs(uWBA) {
         TestExceptionHandling();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestCustomLookupWithNIDocs() {
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      List<NI_Documentation__c> lstNIDocs = new List<NI_Documentation__c> ();
      for (Integer i = 1; i <= TotalRecords; i++) { //Create TotalRecords NI Doc records for pagination testing
         NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document ' + i, Date.newInstance(2021, 5, 30));
         objNIDoc.Account__c = objAccount.Id;
         lstNIDocs.add(objNIDoc);
      }
      //Insert TotalRecords into NI Documentation object for testing
      insert lstNIDocs;

      List<User> listUser = [Select Id From User Where Email like '%cldWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');
      User uWBA = listUser[0];

      Test.startTest();
      System.runAs(uWBA) {
         TestNIDocLookup();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestCustomLookupWithAccounts() {
      List<Account> lstAccounts = new List<Account> ();
      for (Integer i = 1; i <= TotalRecords; i++) { //Create 7 account records for pagination testing
         Account objAccount = AH_UDC_TestData.GetAccountObject('UDC ' + AH_UDC_Shared.generateGUID());
         lstAccounts.add(objAccount);
      }
      insert lstAccounts;

      List<User> listUser = [Select Id From User Where Email like '%cldWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');
      User uWBA = listUser[0];

      Test.startTest();
      System.runAs(uWBA) {
         TestAccountLookup();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestCustomLookupWithContacts() {
      List<User> listUser = [Select Id From User Where Email like '%cldWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');
      User uWBA = listUser[0];

      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      List<Contact> lstContacts = new List<Contact> ();
      for (Integer i = 1; i <= TotalRecords; i++) { //Create 50 contact records for pagination testing
         Contact objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, String.valueOf(i), String.valueOf(i), 'US', 'City' + String.valueOf(i), '03801', 'NH', String.valueOf(i));
         objContact.Email = 'contact' + i + '@test.com';
         objContact.Status__c = 'Active';
         lstContacts.add(objContact);
      }
      //Insert 50 contacts
      insert lstContacts;

      Test.startTest();
      System.runAs(uWBA) {
         TestContactLookup();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestCustomLookupWithProjects() {
      List<User> listUser = [Select Id From User Where Email like '%cldWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');
      User uWBA = listUser[0];

      pse__Region__c objRegion = new pse__Region__c(
                                                    Name = 'Amadeus Hospitality'
      );
      insert objRegion;

      Id recordTypeMasterProject = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_PROJECT_MASTER_PROJECT).getRecordTypeId();
      System.assert(String.isNotBlank(recordTypeMasterProject), 'RecordType Id ' + AH_UDC_Constants.RECORD_TYPE_PROJECT_MASTER_PROJECT + ' not found');

      Id recordTypeStandardProject = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT).getRecordTypeId();
      System.assert(String.isNotBlank(recordTypeStandardProject), 'RecordType Id ' + AH_UDC_Constants.RECORD_TYPE_PROJECT_STANDARD_PROJECT + ' not found');

      List<pse__Proj__c> lstProjects = new List<pse__Proj__c> ();
      for (Integer i = 1; i <= TotalRecords; i++) { //Create TotalRecords project records for pagination testing
         lstProjects.add(new pse__Proj__c(
                                          RecordTypeId = i< 4 ? recordTypeMasterProject : recordTypeStandardProject,
                                          Name = 'Test Project ' + i,
                                          pse__Region__c = objRegion.Id
         ));
      }
      insert lstProjects;

      Test.startTest();
      System.runAs(uWBA) {
         TestProjectLookup();
         TestProjectException();
      }
      Test.stopTest();
   }

   @isTest
   private static void TestCustomLookupWithSteps() {
      List<User> listUser = [Select Id From User Where Email like '%cldWorkbookAdmin%'];
      System.assertEquals(1, listUser.size(), 'Failed retrieving test Workbook Admin');
      User uWBA = listUser[0];

      String WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(WorkbookRecordTypeId != null && WorkbookRecordTypeId != '', 'RecordType not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(null, 'CustomLookupWorkbookWithSteps', 'Test CustomLookupWorkbook With Steps Description', 'Central Sales');
      objWorkbook.RecordTypeId = WorkbookRecordTypeId;
      insert objWorkbook;

      String WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookStepRecordTypeId), 'RecordType AH_UDC_WorkbookStep not found');

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 1; i <= TotalRecords; i++) { //Create TotalRecords Workbook Step records for pagination testing
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step ' + i);
         objWorkbookStep.URL__c = 'https://www.Amadeus.com/' + i;
         objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;
         objWorkbookStep.SortOrder__c = i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      insert lstWorkbookSteps;

      //Share workbook with Workbook Admin for workbook step lookup
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = objWorkbook.Id;
      objWorkbookShare.UserOrGroupId = uWBA.Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      Test.startTest();
      System.runAs(uWBA) {
         TestWorkbookStepLookup(false);
      }
      Test.stopTest();
   }

   private static void TestNIDocLookup() {
      String strNIDocKeyPrefix = NI_Documentation__c.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strNIDocKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(new NI_Documentation__c());
      AH_UDC_CustomLookupDialog objNIDocLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objNIDocLookup.IsErrorOccurred != true, 'TestNIDocLookup - Error occurred in page execution');
      System.assert(objNIDocLookup.IsNIDocLookup == true, 'Error occurred in page execution - IsNIDocLookup value is not set');
      System.assert(objNIDocLookup.NIDocRecordsList == null || objNIDocLookup.NIDocRecordsList.size() == 0, 'Error occurred in page execution - NI Doc list is not empty for recently viewed records');
      objNIDocLookup.RecordsPerPage = RecordPerPage;
      objNIDocLookup.SearchText = 'Test NI'; //Cover searchtext code
      objNIDocLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(RecordPerPage, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in search - NI Doc records count is not matched');

      //Pagination Next Click
      objNIDocLookup.Next();
      System.assertEquals(1, objNIDocLookup.PageNumber, 'Error occurred in executing Next method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in Next method - NI Doc records count is not matched');

      //Pagination Previous Click
      objNIDocLookup.Previous();
      System.assertEquals(0, objNIDocLookup.PageNumber, 'Error occurred in executing Previous method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in Previous Beginning method - NI Doc records count is not matched');

      //Pagination Last Click
      objNIDocLookup.End();
      System.assertEquals(objNIDocLookup.TotalPages, objNIDocLookup.PageNumber, 'Error occurred in executing End method - Page Number is not matched');
      System.assertEquals(1, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in End method - NI Doc records count is not matched');

      //Pagination First Click
      objNIDocLookup.Beginning();
      System.assertEquals(0, objNIDocLookup.PageNumber, 'Error occurred in executing Beginning method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in executing Beginning method - NI Doc records count is not matched');

      objNIDocLookup.RecordsPerPage = 100;
      objNIDocLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(TotalRecords, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in search - NI Doc records count is not matched');

      objNIDocLookup.TotalRecordsAllowed = 3; //Cover if condition of maximum records
      objNIDocLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(3, objNIDocLookup.NIDocRecordsList.size(), 'Error occurred in search - NI Doc records count is not matched with maximum allowed records');
   }

   private static void TestContactLookup() {
      String strContactKeyPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strContactKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(new Contact());
      AH_UDC_CustomLookupDialog objContactLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objContactLookup.IsErrorOccurred != true, 'TestContactLookup - Error occurred in page execution');
      System.assert(objContactLookup.IsContactLookup == true, 'Error occurred in page execution - IsContactLookup value is not set');
      System.assert(objContactLookup.ContactRecordsList == null || objContactLookup.ContactRecordsList.size() == 0, 'Error occurred in page execution - Contact list is not empty for recently viewed records');
      objContactLookup.RecordsPerPage = RecordPerPage;
      objContactLookup.SearchText = 'Test Contact'; //Cover searchtext code
      objContactLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(RecordPerPage, objContactLookup.ContactRecordsList.size(), 'Error occurred in search - Contact records count is not matched');

      //Pagination Next Click
      objContactLookup.Next();
      System.assertEquals(1, objContactLookup.PageNumber, 'Error occurred in executing Next method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objContactLookup.ContactRecordsList.size(), 'Error occurred in Next method - Contact records count is not matched');

      //Pagination Previous Click
      objContactLookup.Previous();
      System.assertEquals(0, objContactLookup.PageNumber, 'Error occurred in executing Previous method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objContactLookup.ContactRecordsList.size(), 'Error occurred in Previous Beginning method - Contact records count is not matched');

      //Pagination Last Click
      objContactLookup.End();
      System.assertEquals(objContactLookup.TotalPages, objContactLookup.PageNumber, 'Error occurred in executing End method - Page Number is not matched');
      System.assertEquals(1, objContactLookup.ContactRecordsList.size(), 'Error occurred in End method - Contact records count is not matched');

      //Pagination First Click
      objContactLookup.Beginning();
      System.assertEquals(0, objContactLookup.PageNumber, 'Error occurred in executing Beginning method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objContactLookup.ContactRecordsList.size(), 'Error occurred in executing Beginning method - Contact records count is not matched');

      objContactLookup.RecordsPerPage = 100;
      objContactLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(TotalRecords, objContactLookup.ContactRecordsList.size(), 'Error occurred in search - Contact records count is not matched');

      objContactLookup.TotalRecordsAllowed = 1; //Cover if condition of maximum records
      objContactLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(1, objContactLookup.ContactRecordsList.size(), 'Error occurred in search - Contact records count is not matched with maximum allowed records');
   }

   private static void TestAccountLookup() {
      String strContactKeyPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strContactKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(new Contact());
      AH_UDC_CustomLookupDialog objAccountLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objAccountLookup.IsErrorOccurred != true, 'TestAccountLookup - Error occurred in page execution');
      System.assert(objAccountLookup.IsAccountLookup == true, 'Error occurred in page execution - IsAccountLookup value is not set');
      System.assert(objAccountLookup.AccountRecordsList == null || objAccountLookup.AccountRecordsList.size() == 0, 'Error occurred in page execution - Account list is not empty for recently viewed records');
      objAccountLookup.RecordsPerPage = RecordPerPage;
      objAccountLookup.SearchText = 'UDC'; //Cover searchtext code
      objAccountLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(RecordPerPage, objAccountLookup.AccountRecordsList.size(), 'Error occurred in search - Contact records count is not matched');

      //Pagination Next Click
      objAccountLookup.Next();
      System.assertEquals(1, objAccountLookup.PageNumber, 'Error occurred in executing Next method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objAccountLookup.AccountRecordsList.size(), 'Error occurred in Next method - Account records count is not matched');

      //Pagination Previous Click
      objAccountLookup.Previous();
      System.assertEquals(0, objAccountLookup.PageNumber, 'Error occurred in executing Previous method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objAccountLookup.AccountRecordsList.size(), 'Error occurred in Previous Beginning method - Account records count is not matched');

      //Pagination Last Click
      objAccountLookup.End();
      System.assertEquals(objAccountLookup.TotalPages, objAccountLookup.PageNumber, 'Error occurred in executing End method - Page Number is not matched');
      System.assertEquals(1, objAccountLookup.AccountRecordsList.size(), 'Error occurred in End method - Account records count is not matched');

      //Pagination First Click
      objAccountLookup.Beginning();
      System.assertEquals(0, objAccountLookup.PageNumber, 'Error occurred in executing Beginning method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objAccountLookup.AccountRecordsList.size(), 'Error occurred in executing Beginning method - Account records count is not matched');

      objAccountLookup.RecordsPerPage = 100;
      objAccountLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(TotalRecords, objAccountLookup.AccountRecordsList.size(), 'Error occurred in search - Account records count is not matched');

      objAccountLookup.TotalRecordsAllowed = 1; //Cover if condition of maximum records
      objAccountLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(1, objAccountLookup.AccountRecordsList.size(), 'Error occurred in search - Account records count is not matched with maximum allowed records');
   }

   private static void TestProjectLookup() {
      String strProjectKeyPrefix = pse__Proj__c.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strProjectKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(new pse__Proj__c());
      AH_UDC_CustomLookupDialog objProjectLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objProjectLookup.IsErrorOccurred != true, 'TestProjectLookup - Error occurred in page execution');
      System.assert(objProjectLookup.IsProjectLookup == true, 'Error occurred in page execution - IsProjectLookup value is not set to true');
      System.assert(objProjectLookup.ProjectRecordsList == null || objProjectLookup.ProjectRecordsList.size() == 0, 'Error occurred in page execution - Project list is not empty for recently viewed records');
      objProjectLookup.TotalRecords = TotalRecords;
      objProjectLookup.RecordsPerPage = RecordPerPage;

      objProjectLookup.SearchText = 'Test Project'; //Cover searchtext code
      objProjectLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(RecordPerPage, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in search - Project records did not match');

      //Pagination Next Click
      objProjectLookup.Next();
      System.assertEquals(1, objProjectLookup.PageNumber, 'Error occurred in executing Next method - Page Number did not match');
      System.assertEquals(RecordPerPage, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in Next method - Project records count did not match');

      //Pagination Previous Click
      objProjectLookup.Previous();
      System.assertEquals(0, objProjectLookup.PageNumber, 'Error occurred in executing Previous method - Page Number did not match');
      System.assertEquals(RecordPerPage, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in Previous Beginning method - Project records count did not match');

      //Pagination Last Click
      objProjectLookup.End();
      System.assertEquals(objProjectLookup.TotalPages, objProjectLookup.PageNumber, 'Error occurred in executing End method - Page Number did not match');
      System.assertEquals(1, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in End method - Project records count did not match');

      //Pagination First Click
      objProjectLookup.Beginning();
      System.assertEquals(0, objProjectLookup.PageNumber, 'Error occurred in executing Beginning method - Page Number is not matched');
      System.assertEquals(RecordPerPage, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in executing Beginning method - Project records count is not matched');

      objProjectLookup.RecordsPerPage = 200;
      objProjectLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(TotalRecords, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in search - Project records count is not matched');

      objProjectLookup.TotalRecordsAllowed = 1; //Cover if condition of maximum records
      objProjectLookup.FillDataTableGrid(); //Get records based on search text
      System.assertEquals(1, objProjectLookup.ProjectRecordsList.size(), 'Error occurred in search - Project records count is not matched with maximum allowed records');
   }

   private static void TestWorkbookStepLookup(Boolean IsWorkbookUser) {
      String WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(WorkbookStepRecordTypeId != null && WorkbookStepRecordTypeId != '', 'RecordType not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Id
                                                       FROM AH_UDC_WorkbookStep__c
                                                       WHERE RecordTypeId = :WorkbookStepRecordTypeId
                                                       AND Enabled__c = true
                                                       ORDER BY SortOrder__c DESC];
      System.assertEquals(TotalRecords, lstWorkbookSteps.size(), 'Workbook Step records count not matched');

      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('id', lstWorkbookSteps[0].Id); //Pass workbook step id with sort order 51 to get 50 records
      pageRef.getParameters().put('prerequisiteStepId', lstWorkbookSteps[TotalRecords - 1].Id); //Set first step as a prerequisite step for TotalRecords step
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objWorkbookStepLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objWorkbookStepLookup.IsErrorOccurred != true, 'TestWorkbookStepLookup - Error occurred in page execution');
      System.assert(objWorkbookStepLookup.IsWorkbookStepLookup == true, 'Error occurred in page execution - IsWorkbookStepLookup value is not set');
      objWorkbookStepLookup.TotalRecords = TotalRecords;
      objWorkbookStepLookup.RecordsPerPage = RecordPerPage;
      objWorkbookStepLookup.FillDataTableGrid();
      if (IsWorkbookUser) {
         System.assertEquals(Label.AH_UDC_NoRightsMessage, objWorkbookStepLookup.ValidationMessage, 'Workbook user should not be allowed to access workbook step lookup');
      }
      else {
         System.assert(String.isBlank(objWorkbookStepLookup.ValidationMessage), 'Error occurred in page execution - ' + objWorkbookStepLookup.ValidationMessage);
         System.assertEquals(RecordPerPage, objWorkbookStepLookup.WorkbookStepRecordsList.size(), 'Error occurred in page execution - Workbook step records counts not matched');

         //Pagination Next Click
         objWorkbookStepLookup.Next();
         System.assertEquals(1, objWorkbookStepLookup.PageNumber, 'Error occurred in executing Next method - Page Number is not matched');
         System.assertEquals(RecordPerPage, objWorkbookStepLookup.WorkbookStepRecordsList.size(), 'Error occurred in Next method - Workbook Step records count is not matched');

         //Pagination Previous Click
         objWorkbookStepLookup.Previous();
         System.assertEquals(0, objWorkbookStepLookup.PageNumber, 'Error occurred in executing Previous method - Page Number is not matched');
         System.assertEquals(RecordPerPage, objWorkbookStepLookup.WorkbookStepRecordsList.size(), 'Error occurred in Previous Beginning method - Workbook Step records count is not matched');

         //Pagination Last Click
         objWorkbookStepLookup.End();
         System.assertEquals(objWorkbookStepLookup.TotalPages, objWorkbookStepLookup.PageNumber, 'Error occurred in executing End method - Page Number is not matched');
         System.assertEquals(RecordPerPage, objWorkbookStepLookup.WorkbookStepRecordsList.size(), 'Error occurred in End method - Workbook Step records count is not matched');

         //Pagination First Click
         objWorkbookStepLookup.Beginning();
         System.assertEquals(0, objWorkbookStepLookup.PageNumber, 'Error occurred in executing Beginning method - Page Number is not matched');
         System.assertEquals(RecordPerPage, objWorkbookStepLookup.WorkbookStepRecordsList.size(), 'Error occurred in executing Beginning method - Workbook Step records count is not matched');

         objWorkbookStepLookup.SearchText = 'Test Step'; //Cover searchtext code
         objWorkbookStepLookup.RecordsPerPage = 100;
         objWorkbookStepLookup.FillDataTableGrid(); //Get records based on search text
         System.assertEquals(TotalRecords - 1, objWorkbookStepLookup.WorkbookStepRecordsList.size(), 'Error occurred in search - Workbook step records count is not matched');

         objWorkbookStepLookup.SetPrerequisiteStep();
         System.assert(objWorkbookStepLookup.IsErrorOccurred != true, 'Error occurred in SetPrerequisiteStep method execution');

         List<AH_UDC_WorkbookStep__c> lstWorkbookSteps2 = [SELECT Id, Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Id = :lstWorkbookSteps[0].Id];
         System.assert(lstWorkbookSteps2.size()> 0, 'Workbook step record not found');
         System.assertEquals(lstWorkbookSteps[TotalRecords - 1].Id, lstWorkbookSteps2[0].Prerequisite_Step__c, 'Prerequisite Step Value Not Updated');
      }
   }

   private static void TestExceptionHandling() {
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      Test.setCurrentPageReference(pageRef);
      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objLookup.IsErrorOccurred == true, 'IsErrorOccurred should be true as an error occurred in the constructor while page loading');
      System.assert(objLookup.HasPageLoadLogMessages == true, 'PageLoadLogMessages is empty');

      //Set name to generate error in LogException method
      objLookup.LogFunctionalArea = 'TestException';
      objLookup.ServerLogMessages();
      System.assert(objLookup.HasPageLoadLogMessages == false, 'PageLoadLogMessages is not empty');
      objLookup.SetPrerequisiteStep();
      System.assert(objLookup.IsErrorOccurred == true, 'Error not occurred in the method SetPrerequisiteStep');

      objLookup.IsErrorOccurred = false;
      pageRef = Page.AH_UDC_CustomLookupDialog;
      //Check with the badstepId of the workbook 
      pageRef.getParameters().put('id', 'BadId');
      Test.setCurrentPageReference(pageRef);
      sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      objLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objLookup.IsErrorOccurred == true, 'IsErrorOccurred should be true as an error occurred in the constructor while page loading');
      System.assert(objLookup.HasPageLoadLogMessages == true, 'PageLoadLogMessages is empty');

      //cover else exception in constructor
      objLookup.IsErrorOccurred = false;
      pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', 'test'); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);
      sController = new ApexPages.standardController(new pse__Proj__c());
      objLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objLookup.IsErrorOccurred == true, 'TestProjectLookup - IsErrorOccurred should be true as an error occurred in the constructor while page loading');
      System.assert(objLookup.HasPageLoadLogMessages == true, 'PageLoadLogMessages is empty');

      //Generate exception on page load
      objLookup.IsErrorOccurred = false;
      AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestForceCustomLookupDialogPageLoadError', true);
      sController = new ApexPages.standardController(new pse__Proj__c());
      AH_UDC_CustomLookupDialog objProjectLookup = new AH_UDC_CustomLookupDialog(sController);
      System.assert(objProjectLookup.IsErrorOccurred == true, 'TestProjectLookup - IsErrorOccurred should be true as an error occurred in the constructor while page loading');
      System.assert(objLookup.HasPageLoadLogMessages == true, 'PageLoadLogMessages is empty');

   }

   private static void TestProjectException() {
      //cover project exception
      AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestForceProjectLookupDialogeError', true);
      String strProjectKeyPrefix = pse__Proj__c.sObjectType.getDescribe().getKeyPrefix();
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('lktp', strProjectKeyPrefix); //Pass lookup type as a parameter
      pageRef.getParameters().put('lkfm', 'TestFormId'); //Pass lookup form id as a parameter
      pageRef.getParameters().put('lknm', 'TestFieldId'); //Pass lookup field id as a parameter
      Test.setCurrentPageReference(pageRef);
      ApexPages.StandardController sController = new ApexPages.standardController(new pse__Proj__c());
      AH_UDC_CustomLookupDialog objProjectLookup = new AH_UDC_CustomLookupDialog(sController);
      objProjectLookup.SearchText = 'Test Project'; //Cover searchtext code
      objProjectLookup.FillDataTableGrid(); //Get records based on search text
      System.assert(objProjectLookup.IsErrorOccurred == true, 'TestProjectLookup - IsErrorOccurred should be true as an error occurred in GetProjectRecords');

      objProjectLookup.IsErrorOccurred = false;
      AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestForceProjectLookupDialogeError', false);
      objProjectLookup = new AH_UDC_CustomLookupDialog(sController);
      objProjectLookup.RecordsPerPage = 0; //Cover if condition of maximum records
      objProjectLookup.PageNumber = 1;
      objProjectLookup.TotalRecordsAllowed = 0;
      objProjectLookup.FillDataTableGrid(); //Get records based on search text
      System.assert(objProjectLookup.IsErrorOccurred == true, 'TestProjectLookup - IsErrorOccurred should be true as an error occurred in FillDataTableGrid');
   }
   @isTest
   public static void NegativeTesting() {
      List<User> listUser = [Select Id From User Where Email like '%cldWorkbook%' ORDER BY Email];
      System.assertEquals(2, listUser.size(), 'Failed retrieving test Workbook Admin and Workbook User');
      User uWBA = listUser[0];
      User uWBU = listUser[1];

      String WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(WorkbookRecordTypeId != null && WorkbookRecordTypeId != '', 'RecordType not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.RecordTypeId = WorkbookRecordTypeId;
      objWorkbook.StepsinOrder__c = true;
      insert objWorkbook;

      String WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookStepRecordTypeId), 'RecordType AH_UDC_WorkbookStep not found');

      AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
      objWorkbookStep.URL__c = 'https://www.Amadeus.com/';
      objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;
      objWorkbookStep.SortOrder__c = 0;
      insert objWorkbookStep;

      Test.startTest();
      System.runAs(uWBA) {
         PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
         //Check with the stepId of the workbook which is not shared with the user
         pageRef.getParameters().put('id', objWorkbookStep.Id);
         Test.setCurrentPageReference(pageRef);

         ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
         AH_UDC_CustomLookupDialog objWorkbookStepLookup = new AH_UDC_CustomLookupDialog(sController);
         System.assertEquals(Label.AH_UDC_NoRightsMessage, objWorkbookStepLookup.ValidationMessage, 'TestWorkbookStepLookup - User should not be able to access step of the workbook which is not shared with the user');
      }

      System.runAs(uWBU) {
         PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
         //Check with the stepId of the workbook which is not shared with the user
         pageRef.getParameters().put('id', objWorkbookStep.Id);
         Test.setCurrentPageReference(pageRef);

         ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
         AH_UDC_CustomLookupDialog objWorkbookStepLookup = new AH_UDC_CustomLookupDialog(sController);
         System.assertEquals(Label.AH_UDC_NoRightsMessage, objWorkbookStepLookup.ValidationMessage, 'TestWorkbookStepLookup - User should not be able to access step of the workbook which is not shared with the user');
      }

      //pass invalid prerequisiteid
      PageReference pageRef = Page.AH_UDC_CustomLookupDialog;
      pageRef.getParameters().put('id', objWorkbookStep.Id);
      pageRef.getParameters().put('prerequisiteStepId', 'badprerequisitid'); //Set wrong  step as a prerequisite step 
      Test.setCurrentPageReference(pageRef);
      ApexPages.StandardController sController = new ApexPages.standardController(new AH_UDC_WorkbookStep__c());
      AH_UDC_CustomLookupDialog objWorkbookStepLookup = new AH_UDC_CustomLookupDialog(sController);
      objWorkbookStepLookup.SetPrerequisiteStep();
      System.assert(objWorkbookStepLookup.IsErrorOccurred == true, 'PrerequisiteStep is not Valid');
      Test.stopTest();
   }
}