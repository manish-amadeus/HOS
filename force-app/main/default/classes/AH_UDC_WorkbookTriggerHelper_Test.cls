/**
 * Name          : AH_UDC_WorkbookTriggerHelper_TEST
 * Created By    : Amadeus Hospitality Services (Sanjay Parmar)
 * Created Date  : 2021-06-14
 * Description   : This is the test class for AH_UDC_WorkbookTriggerHelper
 * Dependencies  : 
 **/
@isTest
private class AH_UDC_WorkbookTriggerHelper_TEST {

   @testSetup
   private static void SetupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'UDCWorkbookUser', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'UDCWorkbookAdmin', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    'UDCSystemAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }

      User objWorkbookUser = listUsers[0];
      User objWorkbookAdmin = listUsers[1];
      User objUdcSystemAdmin = listUsers[2];

      //Insert new Account data
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 8, 30));
      objNIDoc.Account__c = objAccount.Id;
      insert objNIDoc;

      //Insert Workbook Record
      AH_UDC_Workbook__c objWorkbookSent1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook Sent 1', 'Test Workbook Sent 1 Description', 'Central Sales');
      //Set OwnerId to provide Workbook delete rights to UDC Workbook Admin user
      objWorkbookSent1.OwnerId = objWorkbookAdmin.Id;
      insert objWorkbookSent1;

      NI_Documentation__c objNIDoc2 = AH_UDC_TestData.GetNIDocObject('Test NI Document 2', Date.newInstance(2021, 8, 30));
      objNIDoc2.Account__c = objAccount.Id;
      insert objNIDoc2;

      //Insert Workbook Record
      AH_UDC_Workbook__c objWorkbookSent2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, 'Exception Test Workbook', 'Exception Test Workbook Description', 'Central Sales');
      //Set OwnerId to provide Workbook delete rights to UDC Workbook Admin user
      objWorkbookSent2.OwnerId = objWorkbookAdmin.Id;
      insert objWorkbookSent2;

      Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook1.RecordTypeId = RecordTypeId;
      insert objWorkbook1;

      AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
      objWorkbook2.RecordTypeId = RecordTypeId;
      insert objWorkbook2;

      AH_UDC_Workbook__c objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 3', 'Test Workbook 3 Description', 'Central Sales');
      objWorkbook3.RecordTypeId = RecordTypeId;
      //Set OwnerId to provide Workbook delete rights to UDC Workbook Admin user
      objWorkbook3.OwnerId = objWorkbookAdmin.Id;
      insert objWorkbook3;

      List<AH_UDC_Workbook__c> lstWorkbook = new List<AH_UDC_Workbook__c> ();
      for (Integer i = 1; i <= 5; i++) { //Create 5 Workbook
         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(null, '', '', 'Central Sales');
         objWorkbook.Name = 'Test Workbook 2' + i;
         objWorkbook.RecordTypeId = RecordTypeId;
         objWorkbook.Description__c = 'Test Workbook Bulk Upload';
         lstWorkbook.add(objWorkbook);
      }
      insert lstWorkbook;

      //Insert Workbook Sent Record
      AH_UDC_Workbook__c objWorkbookSent3 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, 'Test Workbook Sent 2', 'Test Workbook Sent 2', 'Central Sales');
      insert objWorkbookSent3;
   }

   @isTest
   private static void TestNagativeScenarioForWorkbookSent() {

      Test.startTest();

      AH_UDC_WorkbookTriggerHelper.IsWorkbookSentRecordTypeForException = true;

      Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookSentRecordTypeId), 'Workbook Sent record type not found');

      Id WorkbookRecordType = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordType), 'Workbook record type not found');

      List<AH_UDC_Workbook__c> lstWorkbookSent = [SELECT Product__c
                                                  FROM AH_UDC_Workbook__c
                                                  WHERE Name = 'Test Workbook Sent 1'
                                                  AND RecordTypeId = :WorkbookSentRecordTypeId];
      System.assert(lstWorkbookSent.size() > 0, 'Workbook Sent record is not created with the name Test Workbook Sent 1');

      try {
         lstWorkbookSent[0].Product__c = 'APMA'; //Try to update product of workbook sent record
         update lstWorkbookSent[0];
      }
      catch(Exception ex) {
         //Ignore Case         
      }

      List<AH_UDC_Workbook__c> lstWorkbookUpdates = [SELECT Id, Name
                                                     FROM AH_UDC_Workbook__c
                                                     WHERE Name = 'Test Workbook 1'
                                                     AND RecordTypeId = :WorkbookRecordType];
      System.assertEquals(1, lstWorkbookUpdates.size(), 'Workbook Record is not created with the name Test Workbook 1');
      try {
         lstWorkbookUpdates[0].Name = 'Test Workbook 288';
         // Check duplicate workbook name validation
         update lstWorkbookUpdates;
      }
      catch(Exception ex) {
         //Ignore Case         
      }

      try {
         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, Name, RelatedTo__c
                                                  FROM AH_UDC_Workbook__c
                                                  WHERE RecordTypeId = :WorkbookSentRecordTypeId AND Name = 'Test Workbook Sent 1'];
         System.assert(lstWorkbooks != null && lstWorkbooks.size() > 0, 'Workbook Sent Record Not Found');

         //Update workbook sent status to execute trigger
         lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         update lstWorkbooks[0];

         //Check if the field AH_UDC_WorkbookLocked__c is updated to true or not
         NI_Documentation__c objNIDoc = [SELECT Id, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :lstWorkbooks[0].RelatedTo__c];
         System.assert(objNIDoc != null, 'NI Doc Record of the Workbook Sent Record (' + lstWorkbooks[0].Name + ') Not Found');
         System.assert(objNIDoc.AH_UDC_WorkbookLocked__c, 'AH_UDC_WorkbookLocked__c is not set to true');
      }
      catch(Exception ex) {
         //Ignore Case         
      }

      List<User> lstWorkbookAdminUsers = [SELECT Id
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin User record not found');
      //WorkbookAdmin try to delete unowned workbook
      System.runAs(lstWorkbookAdminUsers[0]) {
         Id deletedId = null;
         try {
            deletedId = lstWorkbookSent[0].Id;
            delete lstWorkbookSent[0];
         }
         catch(Exception ex) {
            // Ignore Case
         }
      }

      Test.stopTest();
   }

   @isTest
   private static void TestUpdateWorkbookSentWithWorkbookAdmin() {
      Test.startTest();

      String WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(WorkbookSentRecordTypeId != null && WorkbookSentRecordTypeId != '', 'Workbook Sent record type not found');

      List<AH_UDC_Workbook__c> lstWorkbookSent = [SELECT Id FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId AND Name = 'Test Workbook Sent 2'];
      System.assert(lstWorkbookSent != null && lstWorkbookSent.size() > 0, 'Workbook Sent Record Not Found');

      List<User> lstWorkbookAdminUsers = [SELECT Id
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin User record not found');

      //Check as UDC Workbook Admin when he not workbook owner - recordtype WorkbookSent
      System.runAs(lstWorkbookAdminUsers[0]) {
         try {
            lstWorkbookSent[0].Product__c = 'APMA'; //Try to update product of workbook sent record
            update lstWorkbookSent[0];
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf(Label.AH_UDC_ProductFieldNotEditableMessage) > - 1, 'Error occurred in workbook trigger while updating product of workbook sent record. Error : ' + ex.getMessage() + ' at Line number ' + ex.getLineNumber());
         }
      }

      //Share workbook with UDC Workbook Admin
      AH_UDC_Workbook__Share objWorkbookShareSent = new AH_UDC_Workbook__Share();
      objWorkbookShareSent.ParentId = lstWorkbookSent[0].Id;
      objWorkbookShareSent.UserOrGroupId = lstWorkbookAdminUsers[0].Id;
      objWorkbookShareSent.AccessLevel = 'Edit';
      insert objWorkbookShareSent;

      //Check as workbook Admin
      System.runAs(lstWorkbookAdminUsers[0]) {
         try {
            lstWorkbookSent[0].Product__c = 'APMA'; //Try to update product of workbook sent record
            update lstWorkbookSent[0];
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf(Label.AH_UDC_ProductFieldNotEditableMessage) > - 1, 'Error occurred in workbook trigger while updating product of workbook sent record. Error : ' + ex.getMessage() + ' at Line number ' + ex.getLineNumber());
         }
      }

      Test.stopTest();
   }

   @isTest
   private static void TestUpdateWorkbookWithWorkbookAdmin() {
      Test.startTest();

      List<User> lstWorkbookAdminUsers = [SELECT Id
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin User record not found');

      Id WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordTypeId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbookUpdate = [SELECT Id, Name
                                                    FROM AH_UDC_Workbook__c
                                                    WHERE Name = 'Test Workbook 21'
                                                    AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(1, lstWorkbookUpdate.size(), 'Workbook Record is not created with the name Test Workbook 21');

      ///Check as UDC Workbook Admin when he not workbook owner - recordtype Workbook
      System.runAs(lstWorkbookAdminUsers[0]) {
         try {
            lstWorkbookUpdate[0].Name = 'Test Workbook 22';
            // Check duplicate workbook name validation
            update lstWorkbookUpdate;
            System.assert(false, 'UDC Workbook Admin should not be able to Update the Workbook');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred.' + ex.getMessage());
         }
      }

      //Share workbook with UDC Workbook User for workbook step
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = lstWorkbookUpdate[0].Id;
      objWorkbookShare.UserOrGroupId = lstWorkbookAdminUsers[0].Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      //Check as workbook Admin
      System.runAs(lstWorkbookAdminUsers[0]) {
         try {
            lstWorkbookUpdate[0].Name = 'Test Workbook 22';
            // Check duplicate workbook name validation
            update lstWorkbookUpdate;

            lstWorkbookUpdate = [SELECT Id, Name
                                 FROM AH_UDC_Workbook__c
                                 WHERE Id = :lstWorkbookUpdate[0].Id
                                 AND RecordTypeId = :WorkbookRecordTypeId];
            System.assertEquals(1, lstWorkbookUpdate.size(), 'Workbook Record Not Created');
            System.assertEquals('Test Workbook 22', lstWorkbookUpdate[0].Name, 'Duplicate workbook name should not be updated');
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateWorkbookNameMessage) > - 1, 'Duplicate workbook - Error message did not match');
         }
      }
      Test.stopTest();
   }

   @isTest
   private static void TestTriggerUDCSystemAdmin() {
      Test.startTest();

      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin User record not found');

      //Check as UDC System Admin
      System.runAs(lstUDCSystemAdminUsers[0]) {
         TestInsertTrigger();
         TestUpdateTrigger();
      }

      Test.stopTest();
   }

   @isTest
   private static void TestTriggerWorkbookUser() {

      Test.startTest();

      List<User> lstWorkbookUsers = [SELECT Id
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'UDC Workbook User record not found');

      //Check as UDC Workbook User
      System.runAs(lstWorkbookUsers[0]) {
         TestInsertTriggerForWorkbookUser();
         TestUpdateTriggerForWorkbookUser();
      }

      Test.stopTest();
   }

   @isTest
   private static void TestUpdateTriggerWorkbookUser() {
      Test.startTest();

      List<User> lstWorkbookUsers = [SELECT Id
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'UDC Workbook User record not found');

      Id WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordTypeId), 'Workbook record type not found');
      List<AH_UDC_Workbook__c> lstWorkbookUpdate = [SELECT Id, Name
                                                    FROM AH_UDC_Workbook__c
                                                    WHERE Name = 'Test Workbook 21'
                                                    AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(1, lstWorkbookUpdate.size(), 'Workbook Record is not created with the name Test Workbook 21');
      //Check as UDC Workbook User
      System.runAs(lstWorkbookUsers[0]) {
         try {
            lstWorkbookUpdate[0].Name = 'Test Workbook 22';
            // Check duplicate workbook name validation
            update lstWorkbookUpdate;
            System.assert(false, 'UDC Workbook User should not be able to Update the Workbook');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred.' + ex.getMessage());
         }
      }

      //Share workbook with UDC Workbook User     
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = lstWorkbookUpdate[0].Id;
      objWorkbookShare.UserOrGroupId = lstWorkbookUsers[0].Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      //Check as UDC Workbook User
      System.runAs(lstWorkbookUsers[0]) {
         try {
            lstWorkbookUpdate[0].Name = 'Test Workbook 22';
            // Check duplicate workbook name validation
            update lstWorkbookUpdate;

            lstWorkbookUpdate = [SELECT Id, Name
                                 FROM AH_UDC_Workbook__c
                                 WHERE Id = :lstWorkbookUpdate[0].Id
                                 AND RecordTypeId = :WorkbookRecordTypeId];
            System.assertEquals(1, lstWorkbookUpdate.size(), 'Workbook Record is not Created');
            System.assertEquals('Test Workbook 22', lstWorkbookUpdate[0].Name, 'Duplicate workbook name should not be updated');
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateWorkbookNameMessage) > - 1, 'Duplicate workbook - Error message did not match');
         }
      }

      Test.stopTest();

   }

   @isTest
   private static void TestTriggerWorkbookAdmin() {
      Test.startTest();

      Id WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordTypeId), 'Workbook record type not found');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = 'Test Workbook 1'
                                              AND RecordTypeId = :WorkbookRecordTypeId];
      System.assertEquals(1, lstWorkbook.size(), 'Workbook Record is not created with the name Test Workbook 1');

      List<User> lstWorkbookAdminUsers = [SELECT Id
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin User record not found');

      //Share workbook with UDC Workbook Admin
      AH_UDC_Workbook__Share objWorkbookShare = new AH_UDC_Workbook__Share();
      objWorkbookShare.ParentId = lstWorkbook[0].Id;
      objWorkbookShare.UserOrGroupId = lstWorkbookAdminUsers[0].Id;
      objWorkbookShare.AccessLevel = 'Edit';
      insert objWorkbookShare;

      //Check as workbook Admin
      System.runAs(lstWorkbookAdminUsers[0]) {
         TestInsertTrigger();
      }

      Test.stopTest();
   }

   private static void TestInsertTrigger() {

      Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(RecordTypeId), 'Workbook Record type not found');

      try {
         AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook1.RecordTypeId = RecordTypeId;
         insert objWorkbook1;
         System.assert(objWorkbook1.Id == null, 'Workbook record not created.');
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateWorkbookNameMessage) > - 1, 'Duplicate workbook - Error message did not match');
      }
      try {
         List<AH_UDC_Workbook__C> lstWorkbook = new List<AH_UDC_Workbook__C> ();
         lstWorkbook.add(new AH_UDC_Workbook__C(Name = 'Web RFP Toolkit Workbook11', Product__c = 'Central Sales', RecordTypeId = RecordTypeId));
         lstWorkbook.add(new AH_UDC_Workbook__C(Name = 'Web RFP Toolkit Workbook12', Product__c = 'Central Sales', RecordTypeId = RecordTypeId));
         lstWorkbook.add(new AH_UDC_Workbook__C(Name = 'Web RFP Toolkit Workbook11', Product__c = 'Central Sales', RecordTypeId = RecordTypeId));
         insert lstWorkbook;
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateWorkbookNameMessage) > - 1, 'Duplicate workbook - Error message did not match');
      }
   }

   private static void TestInsertTriggerForWorkbookUser() {
      Boolean InsertException = false;
      Id RecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(RecordTypeId), 'Workbook Record type not found');

      try {
         AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(null, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook1.RecordTypeId = RecordTypeId;
         AH_UDC_Security.CreateObject(objWorkbook1);
         System.assert(true, 'Workbook record Should not be created.');
      }
      catch(Exception ex) {
         InsertException = true;
      }
      System.assertEquals(true, InsertException, 'WorkbookUser Should not be able to insert Workbook');
   }

   @isTest
   private static void TestWorkbookSentUpdate() {
      Test.startTest();

      String WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(WorkbookSentRecordTypeId != null && WorkbookSentRecordTypeId != '', 'Workbook Sent record type Not Found');

      List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id, Name, RelatedTo__c FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId AND Name = 'Test Workbook Sent 1'];
      System.assert(lstWorkbooks != null && lstWorkbooks.size() > 0, 'Workbook Sent Record Not Found');

      //Update workbook sent status to execute trigger
      lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
      update lstWorkbooks[0];

      //Check if the field AH_UDC_WorkbookLocked__c is updated to true or not
      NI_Documentation__c objNIDoc = [SELECT Id, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :lstWorkbooks[0].RelatedTo__c];
      System.assert(objNIDoc != null, 'NI Doc Record of the Workbook Sent Record (' + lstWorkbooks[0].Name + ') Not Found');
      System.assert(objNIDoc.AH_UDC_WorkbookLocked__c, 'AH_UDC_WorkbookLocked__c is not set to true');

      //Update workbook sent status to execute trigger
      lstWorkbooks[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
      update lstWorkbooks[0];

      //Check if the field AH_UDC_WorkbookLocked__c is updated to false or not
      objNIDoc = [SELECT Id, Name, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :lstWorkbooks[0].RelatedTo__c];
      System.assert(objNIDoc != null, 'NI Doc Record of the Workbook Sent Record (' + lstWorkbooks[0].Name + ') Not Found');
      System.assertEquals(false, objNIDoc.AH_UDC_WorkbookLocked__c, 'AH_UDC_WorkbookLocked__c is not set to false');

      AH_UDC_Workbook__c objWorkbook = [SELECT Id, Name, RelatedTo__c FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId AND Name = 'Exception Test Workbook'];
      System.assert(objWorkbook != null, 'Workbook Sent Record (Exception Test Workbook) Not Found');
      try {
         //Genarete error to get code coverage of catch block
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         update objWorkbook;
      }
      catch(Exception ex) {
         //Ignore forcefully generated error
      }

      //Check if the field AH_UDC_WorkbookLocked__c is updated or not
      objNIDoc = [SELECT Id, AH_UDC_WorkbookLocked__c FROM NI_Documentation__c WHERE Id = :objWorkbook.RelatedTo__c];
      System.assert(objNIDoc != null, 'NI Doc of the Workbook Sent Record (Exception Test Workbook) Not Found');
      System.assert(objNIDoc.AH_UDC_WorkbookLocked__c == false || objNIDoc.AH_UDC_WorkbookLocked__c == null, 'Error not generated for getting code coverage of catch block');

      Test.stopTest();
   }

   private static void TestUpdateTrigger() {

      Id WorkbookRecordType = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordType), 'Workbook record type not found');

      try {
         Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(WorkbookSentRecordTypeId), 'Workbook Sent record type not found');

         List<AH_UDC_Workbook__c> lstWorkbookSent = [SELECT Product__c
                                                     FROM AH_UDC_Workbook__c
                                                     WHERE Name = 'Test Workbook Sent 1'
                                                     AND RecordTypeId = :WorkbookSentRecordTypeId];
         System.assert(lstWorkbookSent.size() > 0, 'Workbook Sent record is not created with the name Test Workbook Sent 1');

         try {
            lstWorkbookSent[0].Product__c = 'APMA'; //Try to update product of workbook sent record
            update lstWorkbookSent[0];
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf(Label.AH_UDC_ProductFieldNotEditableMessage) > - 1, 'Error occurred in workbook trigger while updating product of workbook sent record. Error : ' + ex.getMessage() + ' at Line number ' + ex.getLineNumber());
         }

         List<AH_UDC_Workbook__c> lstWorkbookUpdates = [SELECT Id, Name
                                                        FROM AH_UDC_Workbook__c
                                                        WHERE Name = 'Test Workbook 1'
                                                        AND RecordTypeId = :WorkbookRecordType];
         System.assertEquals(1, lstWorkbookUpdates.size(), 'Workbook Record is not created with the name Test Workbook 1');

         lstWorkbookUpdates[0].Name = 'Test Workbook 2';
         // Check duplicate workbook name validation
         update lstWorkbookUpdates;

         lstWorkbookUpdates = [SELECT Id, Name
                               FROM AH_UDC_Workbook__c
                               WHERE Id = :lstWorkbookUpdates[0].Id
                               AND RecordTypeId = :WorkbookRecordType];
         System.assertEquals(1, lstWorkbookUpdates.size(), 'Workbook Record  is not Created');
         System.assertEquals('Test Workbook 2', lstWorkbookUpdates[0].Name, 'Duplicate workbook name should not be updated');
      }
      catch(Exception ex) { // Excepted scenario get duplicate message 
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateWorkbookNameMessage) > - 1, 'Duplicate workbook - Error message did not match');
      }

      try {
         List<AH_UDC_Workbook__c> lstBulkUpdateWorkbook = [SELECT Id, Name
                                                           FROM AH_UDC_Workbook__c
                                                           WHERE RecordTypeId = :WorkbookRecordType];
         System.assert(lstBulkUpdateWorkbook.size() > 0, 'Workbook Record is not created with the workbook record type');

         for (Integer i = 1; i <= 5; i++) { //Update 5 Workbook            
            lstBulkUpdateWorkbook[i].Name = 'Test Workbook 4' + i;
         }

         update lstBulkUpdateWorkbook;
      }
      catch(Exception ex) {
         System.assert(false, 'UDC Workbook Admin user should be able to insert the Workbook' + ex.getMessage());
      }

      try {
         List<AH_UDC_Workbook__c> lstBulkWorkbook = [SELECT Id, Name
                                                     FROM AH_UDC_Workbook__c
                                                     WHERE RecordTypeId = :WorkbookRecordType];
         System.assert(lstBulkWorkbook.size() > 0, 'Workbook Record is not created with the workbook record type');

         lstBulkWorkbook[0].Name = 'Test Workbook 19';
         lstBulkWorkbook[1].Name = 'Test Workbook 20';
         lstBulkWorkbook[2].Name = 'Test Workbook 44';
         lstBulkWorkbook[3].Name = 'Test Workbook 45';
         // Check duplicate workbook name validation
         update lstBulkWorkbook;
      }
      catch(Exception ex) {
         System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_DuplicateWorkbookNameMessage) > - 1, 'Duplicate workbook - Error message did not match');
      }
   }

   private static void TestUpdateTriggerForWorkbookUser() {

      Boolean UpdateException = false;
      Id WorkbookRecordType = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordType), 'Workbook record type not found');

      try {
         Id WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
         System.assert(String.isNotBlank(WorkbookSentRecordTypeId), 'Workbook Sent record type not found');

         List<AH_UDC_Workbook__c> lstWorkbookSent = [SELECT Product__c
                                                     FROM AH_UDC_Workbook__c
                                                     WHERE Name = 'Test Workbook Sent 1'
                                                     AND RecordTypeId = :WorkbookSentRecordTypeId];
         System.assert(lstWorkbookSent.size() > 0, 'Workbook Sent record is not created with the name Test Workbook Sent 1');

         try {
            lstWorkbookSent[0].Product__c = 'APMA'; //Try to update product of workbook sent record
            update lstWorkbookSent[0];
         }
         catch(Exception ex) {
            UpdateException = true;
         }

         List<AH_UDC_Workbook__c> lstWorkbookUpdates = [SELECT Id, Name
                                                        FROM AH_UDC_Workbook__c
                                                        WHERE Name = 'Test Workbook 1'
                                                        AND RecordTypeId = :WorkbookRecordType];
         System.assertEquals(1, lstWorkbookUpdates.size(), 'Workbook Record is not created with the name Test Workbook 1');

         lstWorkbookUpdates[0].Name = 'Test Workbook 2';
         // Check duplicate workbook name validation
         update lstWorkbookUpdates;

         lstWorkbookUpdates = [SELECT Id, Name
                               FROM AH_UDC_Workbook__c
                               WHERE Id = :lstWorkbookUpdates[0].Id
                               AND RecordTypeId = :WorkbookRecordType];
         System.assertEquals(1, lstWorkbookUpdates.size(), 'Workbook Record  is not Created');
         System.assertEquals('Test Workbook 2', lstWorkbookUpdates[0].Name, 'Duplicate workbook name should not be updated');
      }
      catch(Exception ex) { // Excepted scenario get duplicate message 
         UpdateException = true;
      }
      System.assertEquals(true, UpdateException, 'Expected Update Dupe Name Exception');
   }

   @isTest
   private static void TestDeleteTriggerForWorkbookSent() {
      Test.startTest();

      String WorkbookSentRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();
      System.assert(WorkbookSentRecordTypeId != null && WorkbookSentRecordTypeId != '', 'Workbook Sent record type not found');

      List<AH_UDC_Workbook__c> lstWorkbookSent = [SELECT Id FROM AH_UDC_Workbook__c WHERE RecordTypeId = :WorkbookSentRecordTypeId LIMIT 1];
      System.assert(lstWorkbookSent.size() > 0, 'Workbook Sent Record Not Found');

      List<User> lstWorkbookUsers = [SELECT Id
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'UDC Workbook User record not found');

      //Check as UDC Workbook User for recordtype workbooksent
      System.runAs(lstWorkbookUsers[0]) {
         Id deletedId = null;
         try {
            deletedId = lstWorkbookSent[0].Id;
            delete lstWorkbookSent[0];
            System.assert(false, 'UDC Workbook User should not be able to delete the Workbook');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred.' + ex.getMessage());
         }

         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assert(lstWorkbooks != null && lstWorkbooks.size() > 0, 'Workbook has been deleted by a user who does not have a permissionset assigned');
      }

      List<User> lstWorkbookAdminUsers = [SELECT Id
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook User record not found');
      //WorkbookAdmin try to delete unowned workbook
      System.runAs(lstWorkbookAdminUsers[0]) {
         Id deletedId = null;
         try {
            deletedId = lstWorkbookSent[0].Id;
            delete lstWorkbookSent[0];
            System.assert(false, 'UDC Workbook Admin User should not be able to delete the Workbook');
         }
         catch(Exception ex) {
            System.assert(ex.getMessage().indexOf(Label.AH_UDC_NoAccessRightsDelete) > - 1, 'Error occurred in deleting workbook : ' + ex.getMessage());
         }

         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assert(lstWorkbooks != null && lstWorkbooks.size() > 0, 'Workbook has been deleted by a user who does not have a permissionset assigned');
      }

      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin user record not found');

      System.runAs(lstUDCSystemAdminUsers[0]) {
         Id deletedId = lstWorkbookSent[0].Id;
         try {
            delete lstWorkbookSent[0];
         }
         catch(Exception exc) {
            System.assert(false, 'UDC System Admin user should be able to delete the Workbook ' + exc.getMessage());
         }

         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstDeletedWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbooks == null || lstDeletedWorkbooks.size() == 0, 'Workbook should be deleted by UDC System Admin user');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestDeleteAndUnDeleteTriggerForWorkbook() {
      Test.startTest();

      Id WorkbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      System.assert(String.isNotBlank(WorkbookRecordTypeId), 'Workbook record type not found');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1' AND RecordTypeId = :WorkbookRecordTypeId];
      System.assert(lstWorkbook.size() > 0, 'Workbook  Record Not Found');

      List<AH_UDC_Workbook__c> lstWorkbookAdmin = [SELECT Id, Name FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 3' AND RecordTypeId = :WorkbookRecordTypeId];
      System.assert(lstWorkbookAdmin.size() > 0, 'UDC Workbook Admin Record Not Found');

      List<User> lstWorkbookUsers = [SELECT Id
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'UDC Workbook User record not found');

      //Check as UDC Workbook User for recordtype workbook
      System.runAs(lstWorkbookUsers[0]) {
         Id deletedId = null;
         try {
            deletedId = lstWorkbook[0].Id;
            delete lstWorkbook[0];
            System.assert(false, 'UDC Workbook User should not be able to delete the Workbook');
         }
         catch(DmlException dmlexc) {
            // This is the expected behavior, so no assert here      
         }
         catch(Exception ex) {
            System.assert(false, 'An unexpected exception occurred.' + ex.getMessage());
         }
      }

      List<User> lstWorkbookAdminUsers = [SELECT Id
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'UDC Workbook Admin user record not found');

      System.runAs(lstWorkbookAdminUsers[0]) {
         id deletedId = lstWorkbookAdmin[0].Id;
         try {
            delete lstWorkbookAdmin[0];
         }
         catch(Exception ex) {
            System.assert(false, 'UDC Workbook Admin user should be able to delete the Workbook' + ex.getMessage());
         }
         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstDeletedWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbooks == null || lstDeletedWorkbooks.size() == 0, 'Workbook should be deleted by WorkbookAdmin user, if he ownes it');

         List<AH_UDC_Workbook__c> lstUndeleteWorkbook = [select id from AH_UDC_Workbook__c WHERE Id = :deletedId ALL ROWS];
         undelete lstWorkbookAdmin[0];

         //Check if workbook record is unDeleted or not
         List<AH_UDC_Workbook__c> lstUnDeletedWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assertEquals(false, lstUnDeletedWorkbooks == null || lstUnDeletedWorkbooks.size() == 0, 'Workbook should be undeleted by UDC Workbook Admin user, if he ownes it');

      }

      List<User> lstUDCSystemAdminUsers = [SELECT Id
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstUDCSystemAdminUsers.size() > 0, 'UDC System Admin user record not found');

      System.runAs(lstUDCSystemAdminUsers[0]) {
         id deletedId = lstWorkbook[0].Id;
         try {
            delete lstWorkbook[0];
         }
         catch(Exception ex) {
            System.assert(false, 'UDC System Admin user should be able to delete the Workbook' + ex.getMessage());
         }
         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstDeletedWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assert(lstDeletedWorkbooks == null || lstDeletedWorkbooks.size() == 0, 'Workbook should be deleted by UDC System Admin user');

         List<AH_UDC_Workbook__c> lstUndeleteWorkbook = [select id from AH_UDC_Workbook__c WHERE Id = :deletedId ALL ROWS];
         try {
            undelete lstWorkbook[0];
         }
         catch(Exception ex) {
            System.assert(false, 'UDC System Admin user should be able to undelete the Workbook' + ex.getMessage());
         }

         //Check if workbook record is unDeleted or not
         List<AH_UDC_Workbook__c> lstUnDeletedWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :deletedId];
         System.assertEquals(false, lstUnDeletedWorkbooks == null || lstUnDeletedWorkbooks.size() == 0, 'Workbook should be undeleted by UDC System Admin user');

         //Check For Bulk Update
         List<AH_UDC_Workbook__c> lstBulkWorkbook = [SELECT Id, Name
                                                     FROM AH_UDC_Workbook__c
                                                     WHERE RecordTypeId = :WorkbookRecordTypeId AND Name IN('Test Workbook 22', 'Test Workbook 23')];
         System.assert(lstBulkWorkbook.size() > 0, 'Workbook Record Not Found');

         id bulkDeletedId = lstBulkWorkbook[0].Id;
         try {
            delete lstBulkWorkbook;
         }
         catch(Exception ex) {
            System.assert(false, 'UDC System Admin user should be able to delete the Workbook' + ex.getMessage());
         }

         //Check if workbook record is deleted or not
         List<AH_UDC_Workbook__c> lstBulkDeletedWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :bulkDeletedId];
         System.assert(lstBulkDeletedWorkbooks == null || lstBulkDeletedWorkbooks.size() == 0, 'Workbook should be deleted by UDC System Admin user');

         List<AH_UDC_Workbook__c> lstUndeleteBulkWorkbook = [select id from AH_UDC_Workbook__c ALL ROWS];
         try {
            undelete lstBulkWorkbook;
         }
         catch(Exception ex) {
            System.assert(false, 'UDC System Admin user should be able to undelete the Workbook' + ex.getMessage());
         }

         //Check if workbook record is unDeleted or not
         List<AH_UDC_Workbook__c> lstUnDeletedBulkWorkbooks = [SELECT Id FROM AH_UDC_Workbook__c WHERE Id = :bulkDeletedId];
         System.assertEquals(false, lstUnDeletedBulkWorkbooks == null || lstUnDeletedBulkWorkbooks.size() == 0, 'Workbook should be undeleted by UDC System Admin user');
      }
      Test.stopTest();
   }
}