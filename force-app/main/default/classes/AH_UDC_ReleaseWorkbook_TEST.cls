/*
 * Name            : AH_UDC_ReleaseWorkbook_TEST.cls
 * Created Date    : 2022-11-14
 * Created By      : Rob.Stevens@Amadeus.com
 * Description     : Test class for AH_UDC_ReleaseWorkbook
 * Dependencies    : AH_UDC_ReleaseWorkbook
 */
@isTest
private class AH_UDC_ReleaseWorkbook_TEST {
   @TestSetup
   private static void setup() { 
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      Account objAccount = AH_UDC_TestData.GetAccountObject('Test Account');
      insert objAccount;

      Contact objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact1', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      objContact.Status__c = 'Active';
      objContact.Email = 'contact1@test.com';
      insert objContact;

      List<User> listUsers = new List<User> ();
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_ConfigHelper.GetString(AH_UDC_Constants.CONFIG_KEY_COMMUNITY_PROFILE_WITH_CHATTER, AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER),
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'CommunityUser', objContact.Id, true));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'swWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'swWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[2].Id);
      }

      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert objProperty;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document', Date.newInstance(2022, 10, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      objNIDoc.AH_UDC_PropertyConfirmation__c = true;
      objNIDoc.AH_UDC_PropertyConfirmationAccepted_Date__c = Date.today();
      insert objNIDoc;

      AH_UDC_Contact__c objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
      insert objUDCContact;

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook', 'Test Workbook Description', 'Central Sales');
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
      objWorkbook.Released__c = false;
      insert objWorkbook;

      AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook2', 'Test Workbook Description', 'Central Sales');
      objWorkbook2.SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
      objWorkbook2.Released__c = false;
      insert objWorkbook2;

      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      Id FileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FileUploadFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD);
      
      List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
      lstForms.add(new AH_UDC_Form__c(Name = 'Test Form 1',
                                       RecordTypeId = FormAssemblyFormRecordTypeId,
                                       FormAssemblyId__c = String.valueOf((Integer) Math.round(Math.random() * (9000000) + 1000000))));

      lstForms.add(new AH_UDC_Form__c(Name = 'Test Form 2',
                                       RecordTypeId = AmadeusFormRecordTypeId));

      lstForms.add(new AH_UDC_Form__c(Name = 'Test Form 3',
                                       RecordTypeId = FileUploadFormRecordTypeId));
      insert lstForms;

      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(WorkbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);
      
      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for(Integer i = 1; i <= 4; i++) {
         AH_UDC_WorkbookStep__c objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step ' + i);
         objWorkbookStep.SortOrder__c = i;
         objWorkbookStep.RecordTypeId = WorkbookStepRecordTypeId;
         if(i <= lstForms.size()) objWorkbookStep.Form__c = lstForms[i - 1].Id;
         else objWorkbookStep.URL__c = 'Test URL ' + i;
         lstWorkbookSteps.add(objWorkbookStep);
      }
      insert lstWorkbookSteps;
   }

   @isTest
   private static void TestReleaseWorkbook() {
      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id
                                                FROM AH_UDC_Workbook__c
                                                WHERE RecordTypeId =: workbookSentRecordTypeId
                                                AND Name = 'Test Workbook'];
      System.assert(lstWorkbooks.size() > 0, 'Workbook Sent record not found with name \'Test Workbook\'');

      List<User> lstUsers = [SELECT Id FROM User
                              WHERE Email LIKE '%swWorkbookUser%'
                              OR Email LIKE '%swWorkbookAdmin%'];
      System.assertEquals(2, lstUsers.size(), 'Users count did not match');

      Test.startTest();
      TestWithoutEditRights(lstWorkbooks[0], lstUsers[0]);

      TestWithEditRights(lstWorkbooks[0], lstUsers[1]);
      Test.stopTest();
   }

   private static void TestWithoutEditRights(AH_UDC_Workbook__c objWorkbook, User objUser) {
      ApexPages.StandardController sc;
      AH_UDC_ReleaseWorkbook objReleaseWorkbook;
      System.runAs(objUser) {
         sc = new ApexPages.standardController(objWorkbook);
         PageReference pageRef = Page.AH_UDC_ReleaseWorkbook;
         pageRef.getParameters().put('id', objWorkbook.Id);

         Test.setCurrentPageReference(pageRef);
         objReleaseWorkbook = new AH_UDC_ReleaseWorkbook(sc);
         System.assertEquals(Label.AH_UDC_ReleaseWorkbook_UserNotAllowedMessage, objReleaseWorkbook.ReleaseNotAllowedMessage, 'Workbook release not allowed message did not match');
      }
   }

   private static void TestWithEditRights(AH_UDC_Workbook__c objWorkbook, User objUser) {
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = objWorkbook.Id;
      objWorkbookShare.UserOrGroupId = objUser.Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      ApexPages.StandardController sc;
      AH_UDC_ReleaseWorkbook objReleaseWorkbook;
      System.runAs(objUser) {
         sc = new ApexPages.standardController(objWorkbook);
         PageReference pageRef = Page.AH_UDC_ReleaseWorkbook;
         pageRef.getParameters().put('id', objWorkbook.Id);

         Test.setCurrentPageReference(pageRef);
         objReleaseWorkbook = new AH_UDC_ReleaseWorkbook(sc);
         System.assert(objReleaseWorkbook.IsErrorOccurred != true, 'Error occurred in Release Workbook page loading');
         System.assert(String.isBlank(objReleaseWorkbook.ReleaseNotAllowedMessage), 'ReleaseNotAllowedMessage should be blank but instead is: ' + objReleaseWorkbook.ReleaseNotAllowedMessage);
         System.assert(String.isNotBlank(String.valueOf(objReleaseWorkbook.WorkbookId)), 'WorkbookId value should not be blank');

         objReleaseWorkbook.ReleaseWorkbook();
         System.assert(objReleaseWorkbook.IsErrorOccurred != true, 'Error occurred in ReleaseWorkbook method');
         
         Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, Released__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE RecordTypeId =: workbookSentRecordTypeId
                                                   AND Id = :objReleaseWorkbook.WorkbookId];
         System.assert(lstWorkbooks.size() > 0, 'Workbook record not found with the Id ' + objReleaseWorkbook.WorkbookId);
         System.assert(lstWorkbooks[0].Released__c, 'Workbook record did not release');

         objReleaseWorkbook = new AH_UDC_ReleaseWorkbook(sc);
         System.assertEquals(Label.AH_UDC_ReleaseWorkbook_AlreadyReleasedMessage, objReleaseWorkbook.ReleaseNotAllowedMessage, 'Archive not allowed message did not match');

         objReleaseWorkbook.ReleaseWorkbook();
         System.assertEquals(Label.AH_UDC_ReleaseWorkbook_AlreadyReleasedMessage, objReleaseWorkbook.ReleaseNotAllowedMessage, 'Archive not allowed message did not match');
      }
   }

   @isTest
   private static void TestExceptionHandling() {
      //Generate exception on page load
      AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestForceReleasePageLoadError', true);
      //Generate exception in SendToContacts method
      AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestForceReleaseWorkbookSendToContactsException', true);
      //Generate exception in ReleaseWorkbook method
      AH_UDC_ConfigHelper.SetValue('AH_UDC_UnitTestForceReleaseError', true);

      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c
                                                WHERE RecordTypeId =: workbookSentRecordTypeId
                                                AND Name = 'Test Workbook2'];
      System.assert(lstWorkbooks.size() > 0, 'Workbook Sent record not found with name \'Test Workbook2\'');

      List<User> lstUsers = [SELECT Id FROM User WHERE Email LIKE '%swWorkbookAdmin%'];
      System.assert(lstUsers.size() > 0, 'Failed to retrieve Workbook Admin user');

      ApexPages.StandardController sc;
      AH_UDC_ReleaseWorkbook objReleaseWorkbook;
      //Test Release Workbook with Workbook Admin user
      System.runAs(lstUsers[0]) {
         sc = new ApexPages.standardController(lstWorkbooks[0]);
         PageReference pageRef = Page.AH_UDC_ReleaseWorkbook;
         //pageRef.getParameters().put('id', lstWorkbooks[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         objReleaseWorkbook = new AH_UDC_ReleaseWorkbook(sc);
         System.assert(objReleaseWorkbook.IsErrorOccurred, 'IsErrorOccurred should be true as error occurred in Release Workbook page loading');
         System.assert(objReleaseWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

         //Set LogFunctionalArea value to generate exception
         objReleaseWorkbook.LogFunctionalArea = 'TestException';

         objReleaseWorkbook.ServerLogMessages();
         System.assertNotEquals(true, objReleaseWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');
         Integer intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                              WHERE FunctionalArea__c = 'AH_UDC_ReleaseWorkbook'
                              AND Source__c = 'Constructor'];
         System.assertEquals(1, intCount, 'Log message entry not found for the exception in constructor');

         System.assert(objReleaseWorkbook.IsErrorOccurred, 'IsErrorOccurred should be true as error occurred in ServerLogMessages method');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                     WHERE FunctionalArea__c = :objReleaseWorkbook.LogFunctionalArea
                     AND Source__c = 'ServerLogMessages'];
         System.assertEquals(1, intCount, 'Log message entry not found for the exception in ServerLogMessages method');

         objReleaseWorkbook.IsErrorOccurred = false;
         objReleaseWorkbook.ReleaseWorkbook();
         System.assert(objReleaseWorkbook.IsErrorOccurred, 'IsErrorOccurred should be true as error occurred in ReleaseWorkbook method');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                     WHERE FunctionalArea__c = :objReleaseWorkbook.LogFunctionalArea
                     AND Source__c = 'ReleaseWorkbook'];
         System.assertEquals(1, intCount, 'Log message entry not found for the exception in ReleaseWorkbook method');

         objReleaseWorkbook.IsErrorOccurred = false;
         Boolean IsUsersCreated = objReleaseWorkbook.SendToContacts();
         System.assertEquals(false, IsUsersCreated, 'IsUsersCreated should be false as error occurred in SendToContacts method');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                     WHERE FunctionalArea__c = :objReleaseWorkbook.LogFunctionalArea
                     AND Source__c = 'SendToContacts'];
         System.assertEquals(1, intCount, 'Log message entry not found for the exception in SendToContacts method');
         Test.stopTest();
      }
   }
}