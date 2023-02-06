/***********************************************************************************************
  Name            : AH_UDC_SendWorkbookAddContact_TEST
  Author          : Tushar Gupta
  Created Date    : 03-Mar-2020
  Last Mod Date   : 03-Mar-2020
  Last Mod By     : Tushar Gupta
  Description     : Test class for Send workbook additional contact of UDC 
 ************************************************************************************************/
@isTest
private class AH_UDC_SendWorkbookAddContact_TEST {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      Account objAccount = null;
      Contact objContact = null;
      Contact objContactWithoutEmail = null;
      Contact objContactWithoutExternalUser = null;
      Contact objContactWithWorkbookAssigned = null;
      User objUser = null;
      User objUser2 = null;
      User objUser3 = null;
      AH_UDC_PropertyAccount__c objProperty = null;
      NI_Documentation__c objNIDoc = null;
      AH_UDC_Contact__c objUdcContact = null;
      AH_UDC_Workbook__c objWorkbook = null;

      objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH',
                                                    '75 New Hampshire Ave');
      objContact.Email = 'test@test.com';
      insert objContact;

      objContactWithoutEmail = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 2', 'US', 'Portsmouth', '03801', 'NH',
                                                                '75 New Hampshire Ave');
      insert objContactWithoutEmail;

      //Insert into Contact object
      objContactWithoutExternalUser = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 3', 'US', 'Portsmouth', '03801', 'NH','75 New Hampshire Ave');
      objContactWithoutExternalUser.Email = 'test3@test.com';
      insert objContactWithoutExternalUser;

      //Insert into Contact object
      objContactWithWorkbookAssigned = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 4', 'US', 'Portsmouth', '03801', 'NH',
                                                                        '75 New Hampshire Ave');
      objContactWithWorkbookAssigned.Email = 'test4@test.com';
      insert objContactWithWorkbookAssigned;

      List<User> listUsers = new List<User> ();
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'GUID', objContact.Id, true));
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'GUID', objContactWithoutEmail.Id, true));
      //Build Community User with chatter
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER,
                                              'GUID', objContactWithWorkbookAssigned.Id, true));


      //Insert Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                              'AddContactWorkbookUser', null, false));
      //Insert Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                              'AddContactWorkbookAdmin', null, false));
      //Insert UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                              AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                              'AddContactUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_COMMUNITY_USER, listUsers[2].Id);
         // UDC Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[3].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[4].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[5].Id);
      }

      User objWorkbookAdminUser = listUsers[4];

      //Insert into Account object
      objProperty = AH_UDC_TestData.GetPropertyObject('UDC Test Account 2', 'Portsmouth', 'US','03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      objProperty.Account__c = objAccount.Id;
      objProperty.Phone__c = '00000000000';
      insert objProperty;

      //Insert new record into NI Documentation object for testing
      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      objUdcContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContactWithWorkbookAssigned.Id, 'USD');
      insert objUdcContact;

      //Insert Workbook Record
      objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      //Set OwnerId
      objWorkbook.OwnerId = objWorkbookAdminUser.Id;
      insert objWorkbook;
   }

   @isTest
   private static void TestWithWorkbookSysAdmin() {
      List<User> lstUser = [Select Id From User Where Email = 'TestAddContactUDCSysAdmin@amadeus.com'];
      System.assert(lstUser.size() > 0, 'UDC System Admin user is not created');

      List<NI_Documentation__c> lstNIdoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIdoc.size() > 0, 'Ni Documentation is not be found.');

      List<AH_UDC_Contact__c> lstUDCContact = [Select Id From AH_UDC_Contact__c Where Document__c = :lstNIdoc[0].Id];
      System.assert(lstUDCContact.size() > 0, 'UDC Contact is not found.');

      List<Contact> lstContact = [Select Id From Contact Where LastName = 'Contact'];
      System.assert(lstContact.size() > 0, 'Contact is not found.');

      List<Contact> lstContactWithoutEmail = [Select Id From Contact Where LastName = 'Contact 2'];
      System.assert(lstContactWithoutEmail.size() > 0, 'Contact without email is not found.');

      List<Contact> lstContactWithoutExternalUser = [Select Id From Contact Where LastName = 'Contact 3'];
      System.assert(lstContactWithoutExternalUser.size() > 0, 'Contact with external user is not found.');

      List<Contact> lstContactWithWorkbookAssigned = [Select Id From Contact Where LastName = 'Contact 4'];
      System.assert(lstContactWithWorkbookAssigned.size() > 0, 'Contact with workbook assign is not found.');

      Test.startTest();
      System.runAs(lstUser[0]) {
         ProcessExecution(lstNIdoc[0], lstUDCContact[0], lstContactWithoutExternalUser[0].Id, lstContactWithoutEmail[0].Id, lstContactWithWorkbookAssigned[0].Id, lstContact[0].Id, true);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestAsWorkbookAdmin() {
      List<User> lstUser = [Select Id From User Where Email = 'TestAddContactWorkbookAdmin@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook Admin user is not created');

      List<NI_Documentation__c> lstNIdoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIdoc.size() > 0, 'Ni Documentation is not be found.');


      List<AH_UDC_Contact__c> lstUDCContact = [Select Id From AH_UDC_Contact__c Where Document__c = :lstNIdoc[0].Id];
      System.assert(lstUDCContact.size() > 0, 'UDC Contact is not found.');

      List<Contact> lstContact = [Select Id From Contact Where LastName = 'Contact'];
      System.assert(lstContact.size() > 0, 'Contact is not found.');

      List<Contact> lstContactWithoutEmail = [Select Id From Contact Where LastName = 'Contact 2'];
      System.assert(lstContactWithoutEmail.size() > 0, 'Contact without email is not found.');

      List<Contact> lstContactWithoutExternalUser = [Select Id From Contact Where LastName = 'Contact 3'];
      System.assert(lstContactWithoutExternalUser.size() > 0, 'Contact with external user is not found.');

      List<Contact> lstContactWithWorkbookAssigned = [Select Id From Contact Where LastName = 'Contact 4'];
      System.assert(lstContactWithWorkbookAssigned.size() > 0, 'Contact with workbook assign is not found.');

      Test.startTest();
      System.runAs(lstUser[0]) {
         ProcessExecution(lstNIdoc[0], lstUDCContact[0], lstContactWithoutExternalUser[0].Id, lstContactWithoutEmail[0].Id, lstContactWithWorkbookAssigned[0].Id, lstContact[0].Id, false);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestAsWorkbookUser() {
      List<User> lstUser = [Select Id From User Where Email = 'TestAddContactWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook user is not created');

      List<NI_Documentation__c> lstNIdoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIdoc.size() > 0, 'Ni Documentation is not found.');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbook records is not found.');

      List<AH_UDC_Contact__c> lstUDCContact = [Select Id From AH_UDC_Contact__c Where Document__c = :lstNIdoc[0].Id];
      System.assert(lstUDCContact.size() > 0, 'UDC Contact is not found.');

      List<Contact> lstContact = [Select Id From Contact Where LastName = 'Contact'];
      System.assert(lstContact.size() > 0, 'Contact is not found.');

      List<Contact> lstContactWithoutEmail = [Select Id From Contact Where LastName = 'Contact 2'];
      System.assert(lstContactWithoutEmail.size() > 0, 'Contact without email is not found.');

      List<Contact> lstContactWithoutExternalUser = [Select Id From Contact Where LastName = 'Contact 3'];
      System.assert(lstContactWithoutExternalUser.size() > 0, 'Contact with external user is not found.');

      List<Contact> lstContactWithWorkbookAssigned = [Select Id From Contact Where LastName = 'Contact 4'];
      System.assert(lstContactWithWorkbookAssigned.size() > 0, 'Contact with workbook assign is not found.');

      Test.startTest();
      System.runAs(lstUser[0]) {
         ProcessExecution(lstNIdoc[0], lstUDCContact[0], lstContactWithoutExternalUser[0].Id, lstContactWithoutEmail[0].Id, lstContactWithWorkbookAssigned[0].Id, lstContact[0].Id, false);
      }
      Test.stopTest();
   }

   @isTest
   private static void NegativeTest() {
      List<User> lstUser = [Select Id From User Where Email = 'TestAddContactWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook user is not created');

      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name, OwnerId FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbook records is not found.');

      List<NI_Documentation__c> lstNIdoc = [Select Id From NI_Documentation__c Where Document_Name__c = 'Test NI Document 1'];
      System.assert(lstNIdoc.size() > 0, 'Ni Documentation is not be found.');

      List<AH_UDC_Contact__c> lstUDCContact = [Select Id From AH_UDC_Contact__c Where Document__c = :lstNIdoc[0].Id];
      System.assert(lstUDCContact.size() > 0, 'UDC Contact is not found.');

      List<Contact> lstContact = [Select Id From Contact Where LastName = 'Contact'];
      System.assert(lstContact.size() > 0, 'Contact is not found.');

      Test.startTest();
      System.runAs(lstUser[0]) {
         PageReference pageRef = Page.AH_UDC_SendWorkbookAddContact;
         Test.setCurrentPageReference(pageRef); //Execute page without NI Doc Id parameter to generate error
         ApexPages.StandardController sController = new ApexPages.standardController(lstUDCContact[0]);
         AH_UDC_SendWorkbookAddContact sbac = new AH_UDC_SendWorkbookAddContact(sController);
         System.assertEquals(true, String.isBlank(sbac.NiDocId), 'NI Doc Id is not blank');

         //Execute method without NI Doc Id and SelectedContactId to generate error
         sbac.CheckExternalUser();
         System.assertEquals(true, sbac.IsErrorOccurred, 'Error not occurred in executing method CheckExternalUser');
         sbac.IsErrorOccurred = false;

         //Execute method without NI Doc Id to generate error
         sbac.SendWorkbookAdditionalContact();
         System.assertEquals(true, sbac.IsErrorOccurred, 'Error not occurred in executing method SendWorkbookAdditionalContact');
         sbac.IsErrorOccurred = false;

         sbac.SelectedContactId = lstNIdoc[0].Id; //Passing wrong id for generating the exceptions
         sbac.CreateCommunityUsers();
         System.assertEquals(false, sbac.IsUserCreated, 'External User has not been created');

         //Set name to generate error in LogException method
         sbac.LogFunctionalArea = 'TestException';
         System.assert(sbac.HasPageLoadLogMessages, 'No log entries found in queue list');
         sbac.IsErrorOccurred = false;

         //Cover catch block of the method GetDefaultEmailTemplateDetails
         sbac.GetDefaultEmailTemplateDetails();
         System.assertEquals(true, sbac.IsErrorOccurred, 'Error not occurred in executing method GetDefaultEmailTemplateDetails');
         sbac.IsErrorOccurred = false;

         sbac.ServerLogMessages();
         System.assertEquals(false, sbac.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

         sbac.GetDefaultEmailTemplateDetails();
         System.assert(sbac.IsErrorOccurred, 'Exceptions are not occurred in method GetDefaultEmailTemplateDetails');
         sbac.IsErrorOccurred = false;

         sbac.CheckExternalUser();
         System.assert(sbac.IsErrorOccurred, 'Exceptions are not occurred in method CheckExternalUser');
         sbac.IsErrorOccurred = false;

         sbac.SendWorkbookAdditionalContact();
         System.assert(sbac.IsErrorOccurred, 'Exceptions are not occurred in method SendWorkbookAdditionalContact');
         sbac.IsErrorOccurred = false;

         sbac.CreateCommunityUsers();
         System.assert(sbac.IsErrorOccurred, 'Exceptions are not occurred in method CreateCommunityUsers');
      }
      Test.stopTest();
   }

   private static void ProcessExecution(NI_Documentation__c NiDoc, AH_UDC_Contact__c UDCContact, Id ContactWithoutExternalUserId, Id ContactWithoutEmailId, Id ContactWithWorkbookAssignedId, ID ContactId, Boolean IsSysAdmin) {
      PageReference pageRef = Page.AH_UDC_SendWorkbookAddContact;
      pageRef.getParameters().put('nidocid', NiDoc.Id);
      Test.setCurrentPageReference(pageRef);
      ApexPages.StandardController sController = new ApexPages.standardController(UDCContact);
      AH_UDC_SendWorkbookAddContact sbac = new AH_UDC_SendWorkbookAddContact(sController);
      System.assertEquals(true, String.isNotBlank(sbac.NiDocId), 'NI Doc Id is not found');

      sbac.SelectedContactId = ContactWithoutExternalUserId;
      //Check the External user is exist or not
      sbac.CheckExternalUser();

      sbac.SelectedContactId = ContactWithoutEmailId;
      //Check if email address is exist or not
      sbac.CheckExternalUser();
      System.assertEquals(Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message, sbac.ValidationMessage, 'did not match validation message empty for contact without email');

      sbac.SelectedContactId = ContactWithWorkbookAssignedId;
      //Check if email address is exist or not
      sbac.CheckExternalUser();
      System.assertEquals(Label.AH_UDC_Additional_Contact_Duplicate_Contact_Error_Message, sbac.ValidationMessage, 'did not match validation message empty for duplicate contact');

      sbac.SelectedContactId = ContactId;
      //Check with valid contact
      sbac.CheckExternalUser();
      System.assertEquals(true, String.isBlank(sbac.ValidationMessage), 'Not a valid contact provided');
      Integer extUserCount = 0;

      AH_UDC_MockResponseGenerator mock;
      mock = new AH_UDC_MockResponseGenerator(AH_UDC_MockResponseGenerator.ResponseType.CreateCommunityUser, 200);
      Test.setMock(HttpCalloutMock.class, mock);

      //Create new UDC Contact
      sbac.SendWorkbookAdditionalContact();
      System.assertEquals(true, String.isNotBlank(sbac.InsertedUDCContactId), 'Error is occurred while inserting UDCContact');
   }
}