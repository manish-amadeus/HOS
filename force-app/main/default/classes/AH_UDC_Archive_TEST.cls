/***********************************************************************************************
  Name            : AH_UDC_Archive_TEST
  Author          : Sanjay Parmar
  Created Date    : 9-Sep-2022
  Last Mod Date   : 9-Sep-2022
  Last Mod By     : Sanjay Parmar
  Description     : Test class for AH_UDC_Archive
 ************************************************************************************************/
@isTest 
private class AH_UDC_Archive_TEST {
   @TestSetup
   private static void setup() { 
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    'swUDCSystemAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'swWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'swWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[2].Id);
      }

      AH_UDC_PropertyAccount__c objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert objProperty;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document', Date.newInstance(2022, 10, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook', 'Test Workbook Description', 'Central Sales');
      //Set workbook status to new to cover code of changing workbook status in-progress in the method serverConfirmProperty
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_NEW;
      insert objWorkbook;

      List<EntitySubscription> lstSubscriptions = new List<EntitySubscription>();
      //Follow NI Doc record
      lstSubscriptions.add(new EntitySubscription(SubscriberId = listUsers[0].Id,
                                                   ParentId = objNIDoc.Id));
      //Follow Workbook Sent record
      lstSubscriptions.add(new EntitySubscription(SubscriberId = listUsers[0].Id,
                                                   ParentId = objWorkbook.Id));
      insert lstSubscriptions;
   }

   @isTest
   private static void TestWithUDCSystemAdminUser() {
      Test.startTest();
      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id
                                                FROM AH_UDC_Workbook__c
                                                WHERE RecordTypeId =: workbookSentRecordTypeId
                                                AND Name = 'Test Workbook'];
      System.assert(lstWorkbooks.size() > 0, 'Workbook Sent record not found with name \'Test Workbook\'');

      List<User> lstUsers = [SELECT Id FROM User WHERE Email LIKE '%swUDCSystemAdmin%'];
      System.assert(lstUsers.size() > 0, 'Failed to retrieve UDC System Admin user');

      TestWithEditRights(lstWorkbooks[0], lstUsers[0]);
      Test.stopTest();
   }

   @isTest
   private static void TestWithWorkbookAdminUser() {
      Test.startTest();
      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id
                                                FROM AH_UDC_Workbook__c
                                                WHERE RecordTypeId =: workbookSentRecordTypeId
                                                AND Name = 'Test Workbook'];
      System.assert(lstWorkbooks.size() > 0, 'Workbook Sent record not found with name \'Test Workbook\'');
      
      List<User> lstUsers = [SELECT Id FROM User WHERE Email LIKE '%swWorkbookAdmin%'];
      System.assert(lstUsers.size() > 0, 'Failed to retrieve Workbook Admin user');
      TestWithoutEditRights(lstWorkbooks[0], lstUsers[0]);

      TestWithEditRights(lstWorkbooks[0], lstUsers[0]);
      Test.stopTest();
   }

   @isTest
   private static void TestWithWorkbookUser() {
      Test.startTest();
      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id
                                                FROM AH_UDC_Workbook__c
                                                WHERE RecordTypeId =: workbookSentRecordTypeId
                                                AND Name = 'Test Workbook'];
      System.assert(lstWorkbooks.size() > 0, 'Workbook Sent record not found with name \'Test Workbook\'');
      
      List<User> lstUsers = [SELECT Id FROM User WHERE Email LIKE '%swWorkbookUser%'];
      System.assert(lstUsers.size() > 0, 'Failed to retrieve Workbook User');
      TestWithoutEditRights(lstWorkbooks[0], lstUsers[0]);

      TestWithEditRights(lstWorkbooks[0], lstUsers[0]);
      Test.stopTest();
   }

   private static void TestWithoutEditRights(AH_UDC_Workbook__c objWorkbook, User objUser) {
      System.runAs(objUser) {
         ApexPages.StandardController sc = new ApexPages.standardController(objWorkbook);
         PageReference pageRef = Page.AH_UDC_Archive;
         pageRef.getParameters().put('id', objWorkbook.Id);

         Test.setCurrentPageReference(pageRef);
         AH_UDC_Archive objWorkbookArchive = new AH_UDC_Archive(sc);
         System.assertEquals(Label.AH_UDC_Archive_UserNotAllowedMessage, objWorkbookArchive.ArchiveNotAllowedMessage, 'Archive not allowed message did not match');
      }
   }

   private static void TestWithEditRights(AH_UDC_Workbook__c objWorkbook, User objUser) {
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = objWorkbook.Id;
      objWorkbookShare.UserOrGroupId = objUser.Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      System.runAs(objUser) {
         ApexPages.StandardController sc = new ApexPages.standardController(objWorkbook);
         PageReference pageRef = Page.AH_UDC_Archive;
         pageRef.getParameters().put('id', objWorkbook.Id);

         Test.setCurrentPageReference(pageRef);
         AH_UDC_Archive objWorkbookArchive = new AH_UDC_Archive(sc);
         System.assert(objWorkbookArchive.IsErrorOccurred != true, 'Error occurred in Archive Workbook page loading');
         System.assert(String.isBlank(objWorkbookArchive.ArchiveNotAllowedMessage), 'ArchiveNotAllowedMessage should be blank');
         System.assert(String.isNotBlank(String.valueOf(objWorkbookArchive.WorkbookId)), 'WorkbookId value should not be blank');
         System.assert(String.isNotBlank(String.valueOf(objWorkbookArchive.NIDocId)), 'NIDocId value should not be blank');

         objWorkbookArchive.ArchiveWorkbook();
         System.assert(objWorkbookArchive.IsErrorOccurred != true, 'Error occurred in ArchiveWorkbook method');
         
         Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, RelatedTo__c, Archive__c
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE RecordTypeId =: workbookSentRecordTypeId
                                                   AND Id = :objWorkbookArchive.WorkbookId];
         System.assert(lstWorkbooks.size() > 0, 'Workbook record not found with the Id ' + objWorkbookArchive.WorkbookId);
         System.assert(lstWorkbooks[0].Archive__c, 'Workbook record did not archive');

         integer intTotalSubscriptions = [SELECT COUNT()
                                          FROM EntitySubscription
                                          WHERE ParentId = :lstWorkbooks[0].Id
                                          OR ParentId = :lstWorkbooks[0].RelatedTo__c
                                          LIMIT 500];
         System.assertEquals(0, intTotalSubscriptions, 'All follow records should be deleted after workbook archive');

         objWorkbookArchive = new AH_UDC_Archive(sc);
         System.assertEquals(Label.AH_UDC_Archive_WorkbookAlreadyArchivedMessage, objWorkbookArchive.ArchiveNotAllowedMessage, 'Archive not allowed message did not match');

         objWorkbookArchive.ArchiveWorkbook();
         System.assertEquals(Label.AH_UDC_Archive_WorkbookAlreadyArchivedMessage, objWorkbookArchive.ArchiveNotAllowedMessage, 'Archive not allowed message did not match');
      }
   }

   @isTest
    private static void TestExceptionHandling() {
      Id workbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookSentRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT);
      
      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c
                                                WHERE RecordTypeId =: workbookSentRecordTypeId
                                                AND Name = 'Test Workbook'];
      System.assert(lstWorkbooks.size() > 0, 'Workbook Sent record not found with name \'Test Workbook\'');

      List<User> lstUsers = [SELECT Id FROM User WHERE Email LIKE '%swUDCSystemAdmin%'];
      System.assert(lstUsers.size() > 0, 'Failed to retrieve UDC System Admin user');

      //Test Workbook Archive with UDC System Admin user
      System.runAs(lstUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(lstWorkbooks[0]);
         PageReference pageRef = Page.AH_UDC_Archive;
         //pageRef.getParameters().put('id', lstWorkbooks[0].Id);

         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         AH_UDC_Archive objWorkbookArchive = new AH_UDC_Archive(sc);
         System.assert(objWorkbookArchive.IsErrorOccurred, 'IsErrorOccurred should be true as error occurred in Archive Workbook page loading');
         System.assert(objWorkbookArchive.HasPageLoadLogMessages, 'No log entries found in queue list');

         //Set LogFunctionalArea value to generate exception
         objWorkbookArchive.LogFunctionalArea = 'TestException';

         objWorkbookArchive.ServerLogMessages();
         System.assertNotEquals(true, objWorkbookArchive.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');
         Integer intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                              WHERE FunctionalArea__c = 'AH_UDC_Archive' AND Source__c = 'IsValidUserRequest'];
         System.assert(intCount > 0, 'Log message entry not found for the exception in constructor');

         System.assert(objWorkbookArchive.IsErrorOccurred, 'IsErrorOccurred should be true as error occurred in the method ServerLogMessages');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                     WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ServerLogMessages'];
         System.assert(intCount > 0, 'Log message entry not found for the exception in the method ServerLogMessages');

         objWorkbookArchive.IsErrorOccurred = false;
         objWorkbookArchive.ArchiveWorkbook();
         System.assert(objWorkbookArchive.IsErrorOccurred, 'IsErrorOccurred should be true as error occurred in the method ArchiveWorkbook');
         intCount = [SELECT COUNT() FROM AH_UDC_Log__c
                     WHERE FunctionalArea__c = 'TestException' AND Source__c = 'ArchiveWorkbook'];
         System.assert(intCount > 0, 'Log message entry not found for the exception in the method ArchiveWorkbook');
         Test.stopTest();
      }
   }
}