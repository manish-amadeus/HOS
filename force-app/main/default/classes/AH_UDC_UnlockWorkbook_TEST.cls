/***********************************************************************************************
  Name            : AH_UDC_UnlockWorkbook_TEST
  Author          : Ravi Shah
  Created Date    : 05-Mar-2021
  Last Mod Date   : 
  Last Mod By     : 
  User Story ID   : 590658
  Description     : 
 
 ************************************************************************************************/
@isTest
public class AH_UDC_UnlockWorkbook_TEST {

   private static final String TEST_NI_DOC_NAME = 'Test NI Document 1';
   private static final String TEST_WORKBOOK_NAME = 'Test Workbook 1';

   private static final String TEST_NI_DOC_NAME2 = 'Test NI Document 2';
   private static final String TEST_WORKBOOK_NAME2 = 'Test Workbook 2';

   private static final String TEST_NI_DOC_NAME3 = 'Test NI Document 3';
   private static final String TEST_WORKBOOK_NAME3 = 'Test Workbook 3';

   private static final String TEST_NI_DOC_NAME4 = 'Test NI Document 4';
   private static final String TEST_WORKBOOK_NAME4 = 'Test Workbook 4';

   @TestSetup
   private static void setup() {
      //Prevent error : System.LimitException: Too many SOQL queries: 101
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
         //AH_UDC_TestData.InsertWithRetries(listUsers);
         insert listUsers;

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }

      User objWorkbookUser = listUsers[0];
      User objWorkbookAdmin = listUsers[1];
      User objUdcSystemAdmin = listUsers[2];

      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      Id recordTypeID = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_SENT).getRecordTypeId();

      System.runAs(objWorkbookUser) {
         // Create NI Doc record for testing with workbook user 
         NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME, Date.newInstance(2021, 3, 31));
         insert objNIDoc;

         // Create Workbook Record         
         AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_WORKBOOK_NAME, 'Test Workbook 1 Description', product);
         objWorkbook.RelatedTo__c = objNIDoc.Id;
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         objWorkbook.Enabled__c = true;
         objWorkbook.RecordTypeId = recordTypeID;
         insert objWorkbook;

         // Create NI Doc record for testing with UDC System Admin 
         NI_Documentation__c objNIDoc2 = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME3, Date.newInstance(2021, 3, 31));
         insert objNIDoc2;

         // Create Workbook Record         
         AH_UDC_Workbook__c objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc2.Id, TEST_WORKBOOK_NAME3, 'Test Workbook 2 Description', product);
         objWorkbook2.RelatedTo__c = objNIDoc2.Id;
         objWorkbook2.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         objWorkbook2.Enabled__c = true;
         objWorkbook2.RecordTypeId = recordTypeID;
         objWorkbook2.OwnerId = objWorkbookUser.Id;
         insert objWorkbook2;

      }
      System.runAs(objWorkbookAdmin) {

         // Create NI Doc record for testing with workbook Admin 
         NI_Documentation__c objNIDoc1 = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME2, Date.newInstance(2021, 3, 31));
         insert objNIDoc1;

         // Create Workbook Record         
         AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc1.Id, TEST_WORKBOOK_NAME2, 'Test Workbook 2 Description', product);
         objWorkbook1.RelatedTo__c = objNIDoc1.Id;
         objWorkbook1.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         objWorkbook1.Enabled__c = true;
         objWorkbook1.RecordTypeId = recordTypeID;
         insert objWorkbook1;

         // Create NI Doc record for testing with UDC System Admin 
         NI_Documentation__c objNIDoc3 = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME4, Date.newInstance(2021, 3, 31));
         insert objNIDoc3;

         // Create Workbook Record         
         AH_UDC_Workbook__c objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(objNIDoc3.Id, TEST_WORKBOOK_NAME4, 'Test Workbook 2 Description', product);
         objWorkbook3.RelatedTo__c = objNIDoc3.Id;
         objWorkbook3.SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
         objWorkbook3.Enabled__c = true;
         objWorkbook3.RecordTypeId = recordTypeID;
         insert objWorkbook3;
      }
   }

   @isTest
   private static void TestUnlockWorkbookAsWorkbookUser() {
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');
      List<User> lstWorkbookUsers = [SELECT Id, Username
                                     FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'
                                     AND IsActive = true];
      System.assert(lstWorkbookUsers.size() > 0, 'Workbook User record not found');

      Test.startTest();
      System.runAs(lstWorkbookUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstNIDocument[0].Id);
         Test.setCurrentPageReference(pageRef);
         AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched');

         //Test for workbook
         //Permission to unlock the workbook is based on having Edit Access to the NI Document or workbook
         Boolean isWorkbookAccess = AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstNIDocument[0].Id)
         || AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstWorkbook[0].Id);
         system.assertEquals(true, isWorkbookAccess, 'Workbook user does not have Edit access on workbook.');

         objUnlockWorkbook.UnlockWorkbook();
         system.assertEquals(true, objUnlockWorkbook.IsErrorOccurred != true, 'There is an error in Unlock Workbook method.');

         //Workbook Record
         lstWorkbook[0] = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         lstWorkbook[0].RelatedTo__c = lstNIDocument[0].Id;
         lstWorkbook[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
         lstWorkbook[0].Enabled__c = true;
         insert lstWorkbook[0];

         objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         objUnlockWorkbook.IsErrorOccurred = true;
         objUnlockWorkbook.UnlockWorkbook();
         System.assert(objUnlockWorkbook.IsErrorOccurred, 'UnlockWorkbook - Error in Unlockworkbook function');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestUnlockWorkbookAsWorkbookAdminUserOfInProgressWorkbook() {
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME4];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME4];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      List<User> lstWorkbookAdminUsers = [SELECT Id, Username
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'Workbook Admin user record not found');

      Test.startTest();
      System.runAs(lstWorkbookAdminUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstNIDocument[0].Id);
         Test.setCurrentPageReference(pageRef);

         AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched');

         objUnlockWorkbook.UnlockWorkbook();
         system.assertEquals(true, objUnlockWorkbook.IsErrorOccurred != true, 'There is an error in Unlock Workbook method.');

      }
      Test.stopTest();
   }

   @isTest
   private static void TestUnlockWorkbookAsWorkbookAdminUser() {
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME2];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME2];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');


      List<User> lstWorkbookAdminUsers = [SELECT Id, Username
                                          FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'
                                          AND IsActive = true];
      System.assert(lstWorkbookAdminUsers.size() > 0, 'Workbook Admin user record not found');
      Test.startTest();
      System.runAs(lstWorkbookAdminUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstNIDocument[0].Id);
         Test.setCurrentPageReference(pageRef);

         AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched');

         objUnlockWorkbook.UnlockWorkbook();
         system.assertEquals(true, objUnlockWorkbook.IsErrorOccurred != true, 'There is an error in Unlock Workbook method.');

         //Workbook Record
         lstWorkbook[0] = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         lstWorkbook[0].RelatedTo__c = lstNIDocument[0].Id;
         lstWorkbook[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
         lstWorkbook[0].Enabled__c = true;
         insert lstWorkbook[0];

         objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         objUnlockWorkbook.IsErrorOccurred = true;
         objUnlockWorkbook.UnlockWorkbook();
         System.assert(objUnlockWorkbook.IsErrorOccurred, 'UnlockWorkbook - Error in Unlockworkbook function');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestUnlockWorkbookAsWorkbookSystemAdmin() {
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME3];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME3];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      List<User> lstWorkbookSystemAdmin = [SELECT Id, Username
                                           FROM User
                                           WHERE Username = 'TestUDCSystemAdmin@amadeus.com'
                                           AND IsActive = true];
      System.assert(lstWorkbookSystemAdmin.size() > 0, 'Workbook system Admin record not found');
      Test.startTest();
      System.runAs(lstWorkbookSystemAdmin[0]) {

         ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstNIDocument[0].Id);
         Test.setCurrentPageReference(pageRef);


         AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched');
         system.assertEquals(true, objUnlockWorkbook.IsErrorOccurred != true, 'There is an error loading the unlock workbook controller.');

         objUnlockWorkbook.UnlockWorkbook();
         system.assertEquals(true, objUnlockWorkbook.IsErrorOccurred != true, 'There is an error in Unlock Workbook method.');

         //Workbook Record
         lstWorkbook[0] = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         lstWorkbook[0].RelatedTo__c = lstNIDocument[0].Id;
         lstWorkbook[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
         lstWorkbook[0].Enabled__c = true;
         insert lstWorkbook[0];

         objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         objUnlockWorkbook.IsErrorOccurred = true;
         objUnlockWorkbook.UnlockWorkbook();
         System.assert(objUnlockWorkbook.IsErrorOccurred, 'UnlockWorkbook - Error in Unlockworkbook function');
      }
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_UnlockWorkbook_Negative_Test() {
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');
      ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);

      PageReference pageRef = Page.AH_UDC_UnlockWorkbook;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();

      AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
      objUnlockWorkbook.NiDocId = null;
      objUnlockWorkbook.UnlockWorkbook();
      System.assertEquals(true, objUnlockWorkbook.IsErrorOccurred, 'UnlockWorkbook - Error NI Doc Id is null');

      AH_UDC_UnlockWorkbook objUnlockWorkbookError = new AH_UDC_UnlockWorkbook(sc);
      objUnlockWorkbookError.NiDocId = 'aAp290000004NS';
      objUnlockWorkbookError.UnlockWorkbook();
      System.assertEquals(true, objUnlockWorkbookError.IsErrorOccurred, 'UnlockWorkbook - Error NI Doc Id is invalid');

      //Set name to generate error in LogException method
      objUnlockWorkbook.LogFunctionalArea = 'TestException';
      System.assert(objUnlockWorkbook.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(objUnlockWorkbook.HasPageLoadLogMessages, 'No log entries found in queue list');

      objUnlockWorkbook.ServerLogMessages();
      System.assertEquals(false, objUnlockWorkbook.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      Test.stopTest();
   }

   @isTest
   private static void TestUnlockWorkbookWithSharingNIDoc() {
      List<User> lstWorkbookUsers = [SELECT Id FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'];
      System.assertEquals(true, lstWorkbookUsers[0] != null, 'Workbook user record not found');

      List<User> lstWorkbookAdminUsers = [SELECT Id FROM User
                                          WHERE Username = 'TestUDCWorkbookAdmin@amadeus.com'];
      System.assertEquals(true, lstWorkbookAdminUsers[0] != null, 'Workbook Admin user record not found');

      List<User> lstWorkbookSystemAdminUsers = [SELECT Id FROM User
                                                WHERE Username = 'TestUDCSystemAdmin@amadeus.com'];
      System.assertEquals(true, lstWorkbookSystemAdminUsers[0] != null, 'Workbook system Admin user record not found');

      //sharing ni doc created by workbook admin with workbook user      
      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME2];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found for workbook user.');

      //Share NI Doc with UDC Workbook user
      NI_Documentation__Share objNiDocShare = new NI_Documentation__Share();
      objNiDocShare.ParentId = lstNIDocument[0].Id;
      objNiDocShare.UserOrGroupId = lstWorkbookUsers[0].Id;
      objNiDocShare.AccessLevel = 'Edit';
      insert objNiDocShare;

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME2];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found for workbook user.');
      if (lstWorkbook.size() > 0) {
         lstWorkbook[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         update lstWorkbook;
      }
      //End workbbok User

      //sharing ni doc created by workbook System admin with workbook Admin user      
      List<NI_Documentation__c> lstNIDocumentWA = [SELECT Id, Name
                                                   FROM NI_Documentation__c
                                                   WHERE Document_Name__c = :TEST_NI_DOC_NAME3];
      System.assert(lstNIDocumentWA.size() > 0, 'Ni Document records could not be found for workbook Admin user.');

      //Share NI Doc with UDC Workbook user
      NI_Documentation__Share objNiDocShareWA = new NI_Documentation__Share();
      objNiDocShareWA.ParentId = lstNIDocumentWA[0].Id;
      objNiDocShareWA.UserOrGroupId = lstWorkbookAdminUsers[0].Id;
      objNiDocShareWA.AccessLevel = 'Edit';
      insert objNiDocShareWA;

      List<AH_UDC_Workbook__c> lstWorkbookWA = [SELECT Id, Name
                                                FROM AH_UDC_Workbook__c
                                                WHERE Name = :TEST_WORKBOOK_NAME3];
      System.assert(lstWorkbookWA.size() > 0, 'Workbook records could not be found for workbook Admin user.');

      if (lstWorkbookWA.size() > 0) {
         lstWorkbookWA[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         update lstWorkbookWA;
      }
      //End workbbok Admin User


      Test.startTest();
      System.runAs(lstWorkbookUsers[0]) {
         ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
         PageReference pageRef = Page.AH_UDC_SendWorkbook;
         pageRef.getParameters().put('id', lstNIDocument[0].Id);
         Test.setCurrentPageReference(pageRef);
         AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
         system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched for workbook user');

         //Test for workbook
         //Permission to unlock the workbook is based on having Edit Access to the NI Document or workbook
         Boolean isWorkbookAccess = AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstNIDocument[0].Id)
         || AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstWorkbook[0].Id);
         system.assertEquals(true, isWorkbookAccess, 'Workbook user does not have Edit access on workbook for workbook user.');

         objUnlockWorkbook.UnlockWorkbook();
         system.assertEquals(true, objUnlockWorkbook.IsErrorOccurred != true, 'There is an error in Unlock Workbook method for workbook user.');
      }

      System.runAs(lstWorkbookAdminUsers[0]) {
         ApexPages.StandardController scWA = new ApexPages.standardController(lstNIDocumentWA[0]);
         PageReference pageRefWA = Page.AH_UDC_SendWorkbook;
         pageRefWA.getParameters().put('id', lstNIDocumentWA[0].Id);
         Test.setCurrentPageReference(pageRefWA);
         AH_UDC_UnlockWorkbook objUnlockWorkbookWA = new AH_UDC_UnlockWorkbook(scWA);
         system.assertEquals(true, String.valueOf(lstNIDocumentWA[0].Id) == objUnlockWorkbookWA.NiDocId, 'NIDocId could not Matched for workbook Admin user');

         //Test for workbook
         //Permission to unlock the workbook is based on having Edit Access to the NI Document or workbook
         Boolean isWorkbookAccessWA = AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstNIDocumentWA[0].Id)
         || AH_UDC_SharedWithoutSharing.CheckRecordEditAccessForUser(lstWorkbookWA[0].Id);
         system.assertEquals(true, isWorkbookAccessWA, 'Workbook Admin user does not have Edit access on workbook for workbook Admin user.');

         objUnlockWorkbookWA.UnlockWorkbook();
         system.assertEquals(true, objUnlockWorkbookWA.IsErrorOccurred != true, 'There is an error in Unlock Workbook method for workbook Admin user.');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestUnlockWorkbookWithoutSharingtoWorkbookUser() {
      //Using ni doc created by workbook admin with workbook user

      List<User> lstWorkbookUsers = [SELECT Id FROM User
                                     WHERE Username = 'TestUDCWorkbookUser@amadeus.com'];
      System.assertEquals(true, lstWorkbookUsers[0] != null, 'Workbook  user record not found');


      List<NI_Documentation__c> lstNIDocument = [SELECT Id, Name
                                                 FROM NI_Documentation__c
                                                 WHERE Document_Name__c = :TEST_NI_DOC_NAME2];
      System.assert(lstNIDocument.size() > 0, 'Ni Document records could not be found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                              FROM AH_UDC_Workbook__c
                                              WHERE Name = :TEST_WORKBOOK_NAME2];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      if (lstWorkbook.size() > 0) {
         lstWorkbook[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         update lstWorkbook;
      }


      Test.startTest();
      System.runAs(lstWorkbookUsers[0]) {
         try {
            ApexPages.StandardController sc = new ApexPages.standardController(lstNIDocument[0]);
            PageReference pageRef = Page.AH_UDC_SendWorkbook;
            pageRef.getParameters().put('id', lstNIDocument[0].Id);
            Test.setCurrentPageReference(pageRef);
            AH_UDC_UnlockWorkbook objUnlockWorkbook = new AH_UDC_UnlockWorkbook(sc);
            system.assertEquals(true, String.valueOf(lstNIDocument[0].Id) == objUnlockWorkbook.NiDocId, 'NIDocId could not Matched');

            objUnlockWorkbook.UnlockWorkbook();
            System.assert(true, 'Workbook User should not be able to Unlock workbook');
         }
         catch(exception ex)
         {
            System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_UserAccessErrorMessage) > - 1, 'Workbook User should not be able to Unlock workbook');
            AH_UDC_LogHelper.Debug('Error while Unlocking workbook  ' + ex.getMessage());

         }
      }
      Test.stopTest();
   }
}