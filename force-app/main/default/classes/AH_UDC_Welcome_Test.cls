/***********************************************************************************************
  Name            : AH_UDC_Welcome_Test
  Author          : Umang Ankleshwaria
  Created Date    : 05-Jan-2021
  Last Mod Date   : 5-Feb-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Test class for Welcome page of UDC
  Change History  :
  1. 590045 - Refactoring Code - Changed by Sanjay Parmar on 4-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 22-Feb-2021
 ************************************************************************************************/

@isTest
private class AH_UDC_Welcome_Test {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      //Get profile id to insert user
      Profile oProfile = [select id from profile where name = :AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER];
      System.assertNotEquals(null, oProfile, 'Failed to retrieve the specified Profile: ' + AH_UDC_Constants.PROFILE_DEFAULT_NAME_COMMUNITY_PLUS_LOGIN_WITH_CHATTER);

      Account objAccount = null;
      Contact objContact = null;
      User objUser = null;
      NI_Documentation__c objNIDoc = null;
      AH_UDC_Contact__c objUDCContact = null;
      AH_UDC_Workbook__c objWorkbook = null;
      AH_UDC_Workbook__c objWorkbook1 = null;
      AH_UDC_Workbook__c objWorkbook2 = null;
      AH_UDC_Workbook__c objWorkbook3 = null;

      //Insert into Account object
      objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account 2', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
      insert objAccount;

      //Insert into Contact object
      objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact;

      //Insert into user object
      objUser = AH_UDC_TestData.GetUserObject(objContact.Id, oProfile.Id, 'Test', 'User', 'Mr.', 'test@user.com', 'test@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
      insert objUser;

      //Insert new record into NI Documentation object for testing
      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_ChatterWorkbookAccessed__c = false;
      objNIDoc.AH_UDC_ChatterWorkbookCompleted__c = false;
      insert objNIDoc;

      System.runAs(objUser) {

         objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
         objUDCContact.TermsandConditionsAccepted__c = true;
         insert objUDCContact;

         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 0', 'Test Workbook 0 Description', 'Central Sales');
         objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         insert objWorkbook;

         objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
         objWorkbook1.SentStatus__c = AH_UDC_Constants.SENT_STATUS_IN_PROGRESS;
         insert objWorkbook1;

         objWorkbook2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         objWorkbook2.SentStatus__c = 'New';
         insert objWorkbook2;

         objWorkbook3 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 3', 'Test Workbook 3 Description', 'Central Sales');
         objWorkbook3.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         insert objWorkbook3;
      }
   }

   @isTest
   public static void AH_UDC_Welcome_Test() {

      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id From AH_UDC_Workbook__c Where Name = :'Test Workbook 0'];
      System.assert(lstWorkbook.size() > 0, 'workbooks could not be found.');
      List<User> lstUser = [Select Id, ContactId From User Where Email = :'test@user.com'];
      System.assert(lstUser.size() > 0, 'User could not be found.');
      System.runAs(lstUser[0]) {

         PageReference pageRef = Page.AH_UDC_Welcome;
         pageRef.getParameters().put('WorkbookId', lstWorkbook[0].Id);
         Test.setCurrentPageReference(pageRef);

         Test.startTest();
         AH_UDC_Welcome objWelcome = new AH_UDC_Welcome();
         System.assertEquals(true, (objWelcome.WorkbookList != null), 'Error occurred in welcome page execution');

         objWelcome.Opt_Into_Social_Media_Feature = true;
         objWelcome.TermsAndConditionNext();
         List<AH_UDC_Contact__c> lstUDCContact = [SELECT Id, TermsandConditionsAcceptedDate__c, TermsandConditionsAccepted__c
                                                  FROM AH_UDC_Contact__c
                                                  WHERE Contact__c = :lstUser[0].ContactId
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 1];
         System.assertEquals(true, (lstUDCContact != null && lstUDCContact.size() > 0 && lstUDCContact[0].TermsandConditionsAcceptedDate__c != null), 'Error occurred in welcome page execution');

         Test.stopTest();
      }
   }
}