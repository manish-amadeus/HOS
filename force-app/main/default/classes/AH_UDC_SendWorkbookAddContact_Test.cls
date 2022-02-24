/***********************************************************************************************
  Name            : AH_UDC_SendWorkbookAddContact_Test
  Author          : Tushar Gupta
  Created Date    : 03-Mar-2020
  Last Mod Date   : 03-Mar-2020
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     : Test class for Send workbook additional contact of UDC 
 ************************************************************************************************/
@isTest
private class AH_UDC_SendWorkbookAddContact_Test {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @isTest
   private static void AH_UDC_SendWorkbookAddContact_Test() {
      Boolean isException = false;
      Account objAccount = null;
      String errorMessage = '';
      try {
         objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
         insert objAccount;
      } catch(Exception exc) {
         System.assert(false, 'Could not create Account record for testing -> ' + errorMessage);
      }
      System.assertEquals(false, isException, 'Could not create Account record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Contact objContact = null;
      try {
         //Insert into Contact object
         objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH',
                                                       '75 New Hampshire Ave');
         objContact.Email = 'test@test.com';
         insert objContact;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Contact record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Contact objContactWithoutEmail = null;
      try {
         //Insert into Contact object
         objContactWithoutEmail = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 2', 'US', 'Portsmouth', '03801', 'NH',
                                                                   '75 New Hampshire Ave');
         insert objContactWithoutEmail;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create ContactWithoutEmail record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Contact objContactWithoutExternalUser = null;
      try {
         //Insert into Contact object
         objContactWithoutExternalUser = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 3', 'US', 'Portsmouth', '03801', 'NH',
                                                                          '75 New Hampshire Ave');
         objContactWithoutExternalUser.Email = 'test3@test.com';
         insert objContactWithoutExternalUser;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create ContactWithoutExternalUser record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Contact objContactWithWorkbookAssigned = null;
      try {
         //Insert into Contact object
         objContactWithWorkbookAssigned = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 4', 'US', 'Portsmouth', '03801', 'NH',
                                                                           '75 New Hampshire Ave');
         objContactWithWorkbookAssigned.Email = 'test3@test.com';
         insert objContactWithWorkbookAssigned;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create objContactWithWorkbookAssigned record for testing -> ' + errorMessage);

      //Get profile id to insert user
      Id profileId = [SELECT Id FROM profile WHERE name = 'AH Customer Community Plus Login User'].Id;
      System.assertEquals(true, profileId != null, 'Profile id is not valid');

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      User objUser = null;
      try {
         //Insert into user object
         objUser = AH_UDC_TestData.GetUserObject(objContact.Id, profileId, 'Test', 'User', 'Mr.', 'test@user.com', 'test@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         insert objUser;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create User record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      User objUser2 = null;
      try {
         //Insert into user object
         objUser2 = AH_UDC_TestData.GetUserObject(objContactWithoutEmail.Id, profileId, 'Test', 'User 2', 'Mr.', 'test2@user.com', 'test2@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         insert objUser2;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create User2 record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      User objUser3 = null;
      try {
         //Insert into user object
         objUser3 = AH_UDC_TestData.GetUserObject(objContactWithWorkbookAssigned.Id, profileId, 'Test', 'User 3', 'Mr.', 'test3@user.com', 'test3@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         insert objUser3;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create objUser3 record for testing -> ' + errorMessage);

      isException = false;
      AH_UDC_PropertyAccount__c objProperty = null;
      errorMessage = '';
      try {
         //Insert into Account object
         objProperty = AH_UDC_TestData.GetPropertyObject('UDC Test Account 2', 'Portsmouth', 'US',
                                                         '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
         objProperty.Account__c = objAccount.Id;
         objProperty.Phone__c = '00000000000';
         insert objProperty;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_PropertyAccount__c record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      NI_Documentation__c objNIDoc = null;
      try {
         //Insert new record into NI Documentation object for testing
         objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
         objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
         insert objNIDoc;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create NI_Documentation__c record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_Contact__c objUdcContact = null;
      try {
         objUdcContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContactWithWorkbookAssigned.Id, 'USD');
         insert objUdcContact;
      }
      catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_Contact__c record for testing -> ' + errorMessage);

      PageReference pageRef = Page.AH_UDC_SendWorkbookAddContact;
      pageRef.getParameters().put('nidocid', objNIDoc.Id);
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(objUdcContact);
      AH_UDC_SendWorkbookAddContact sbac = new AH_UDC_SendWorkbookAddContact(sController);
      System.assertEquals(true, String.isNotBlank(sbac.NiDocId), 'NI Doc Id not found');

      sbac.SelectedContactId = objContactWithoutExternalUser.Id;
      //Check the External user is exist or not
      sbac.CheckExternalUser();

      sbac.SelectedContactId = objContactWithoutEmail.Id;
      //Check if email address is exist or not
      sbac.CheckExternalUser();
      System.assertEquals(Label.AH_UDC_Send_Workbook_Additional_Contact_Email_Required_Message, sbac.ValidationMessage, 'Could not match validation message empty for contact without email');

      sbac.SelectedContactId = objContactWithWorkbookAssigned.Id;
      //Check if email address is exist or not
      sbac.CheckExternalUser();
      System.assertEquals(Label.AH_UDC_Additional_Contact_Duplicate_Contact_Error_Message, sbac.ValidationMessage, 'Could not match validation message empty for duplicate contact');

      sbac.SelectedContactId = objContact.Id;
      //Check with valid contact
      sbac.CheckExternalUser();
      System.assertEquals(true, String.isBlank(sbac.ValidationMessage), 'Not a valid contact provided');
      Integer extUserCount = 0;

      //sbac.SelectedContactId = objContactWithoutExternalUser.Id;

      //System.assertEquals(0, extUserCount, 'Contact have external user');

      //Create new UDC Contact
      sbac.SendWorkbookAdditionalContact();
      System.assertEquals(true, String.isNotBlank(sbac.InsertedUDCContactId), 'Could not send SendWorkbookAdditionalContact - InsertedUDCContactId is blank');

      Test.stopTest();
   }

   @isTest
   private static void NegativeTest() {
      Boolean isException = false;
      Account objAccount = null;
      String errorMessage = '';
      try {
         //Insert into Account object
         objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
         insert objAccount;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Account record for testing -> ' + errorMessage);

      isException = false;
      AH_UDC_PropertyAccount__c objProperty = null;
      errorMessage = '';
      try {
         //Insert into Account object
         objProperty = AH_UDC_TestData.GetPropertyObject('UDC Test Account 2', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
         objProperty.Account__c = objAccount.Id;
         objProperty.Phone__c = '00000000000';
         insert objProperty;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_PropertyAccount__c record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      System.debug('objProperty.Id' + objProperty.Id);
      NI_Documentation__c objNIDoc = null;
      try {
         //Insert new record into NI Documentation object for testing
         objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
         objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
         insert objNIDoc;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create NI_Documentation__c record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      Contact objContact = null;
      try {
         //Insert into Contact object
         objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
         insert objContact;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Contact record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_Contact__c objUdcContact = null;
      try {
         objUdcContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
         insert objUdcContact;
      }
      catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_Contact__c record for testing -> ' + errorMessage);

      //Get profile id to insert user
      Id profileId = [SELECT Id FROM profile WHERE name = 'AH Customer Community Plus Login User'].Id;
      System.assertEquals(true, profileId != null, 'Profile id is not valid');

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      User objUser = null;
      try {
         //Insert into user object
         objUser = AH_UDC_TestData.GetUserObject(objContact.Id, profileId, 'Test', 'User', 'Mr.', 'test@user.com', 'test@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         insert objUser;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create User record for testing -> ' + errorMessage);

      PageReference pageRef = Page.AH_UDC_SendWorkbookAddContact;
      Test.setCurrentPageReference(pageRef); //Execute page without NI Doc Id parameter to generate error
      Test.startTest();

      ApexPages.StandardController sController = new ApexPages.standardController(objUdcContact);
      AH_UDC_SendWorkbookAddContact sbac = new AH_UDC_SendWorkbookAddContact(sController);
      System.assertEquals(true, String.isBlank(sbac.NiDocId), 'NI Doc Id is not blank');

      //Execute method without NI Doc Id and SelectedContactId to generate error
      sbac.CheckExternalUser();
      System.assertEquals(true, sbac.IsErrorOccurred, 'Error not occurred in executing method CheckExternalUser');

      //Execute method without NI Doc Id to generate error
      sbac.SendWorkbookAdditionalContact();
      System.assertEquals(true, sbac.IsErrorOccurred, 'Error not occurred in executing method SendWorkbookAdditionalContact');

      sbac.SelectedContactId = objContact.Id;
      sbac.CreateCommunityUsers();
      System.assertEquals(false, sbac.IsUserCreated, 'External User has not been created');

      //Set name to generate error in LogException method
      sbac.LogFunctionalArea = 'TestException';
      System.assert(sbac.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(sbac.HasPageLoadLogMessages, 'No log entries found in queue list');

      sbac.ServerLogMessages();
      System.assertEquals(false, sbac.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');

      Test.stopTest();
   }

   @isTest
   private static void TestCommunityUser() {
      Boolean isException = false;
      Account objAccount = null;
      String errorMessage = '';
      try {
         //Insert into Account object
         objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2 For External User WB', 'Hospitality Companies', 'Portsmouth', 'US', '03801',
                                                       'NH', '75 New Hampshire Aven');
         insert objAccount;
         System.debug('Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getQueries());
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create Account record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }

      Contact objContactWithoutExternalUser = null;

      try {
         //Insert into Contact object
         objContactWithoutExternalUser = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact 3', 'US', 'Portsmouth', '03801', 'NH',
                                                                          '75 New Hampshire Ave');
         objContactWithoutExternalUser.Email = 'test3@test.com';
         insert objContactWithoutExternalUser;
         System.debug('2 : Total Number of SOQL Queries allowed in this apex code context: ' + Limits.getQueries());
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create ContactWithoutExternalUser record for testing -> ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }

      PageReference pageRef = Page.AH_UDC_SendWorkbookAddContact;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(objContactWithoutExternalUser);
      AH_UDC_SendWorkbookAddContact sbac = new AH_UDC_SendWorkbookAddContact(sController);
      // Create external user if contact does not have
      System.runAs(new User(Id = Userinfo.getUserId())) {
         sbac.SelectedContactName = objContactWithoutExternalUser.Name;
         sbac.SelectedContactId = objContactWithoutExternalUser.Id;
         sbac.CreateCommunityUsers();
         System.assertEquals(true, sbac.IsUserCreated, 'External User has not been created');
      }
      Test.stopTest();
   }
}