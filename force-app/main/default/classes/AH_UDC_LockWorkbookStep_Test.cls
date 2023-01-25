/***********************************************************************************************
  Name            : AH_UDC_LockWorkbookStep_Test
  Author          : Tushar Gupta
  Created Date    : 20-Apr-2021
  Last Mod Date   : 20-Apr-2021
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     : Test class for lock workbook step
 ************************************************************************************************/
@isTest
public class AH_UDC_LockWorkbookStep_Test {

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @isTest
   private static void AH_UDC_LockWorkbookStep_Test() {
      Boolean isException = false;
      Account objAccount = null;
      Contact objContact = null;
      User objUser = null;
      AH_UDC_PropertyAccount__c objProperty = null;
      NI_Documentation__c objNIDoc = null;
      AH_UDC_Contact__c objUDCContact = null;
      AH_UDC_Workbook__c objWorkbook = null;
      String errorMessage = '';
      AH_UDC_WorkbookStep__c objWorkbookStep = null;
      try {
         //Create Account record
         objAccount = AH_UDC_TestData.GetAccountObject('UDC Test Account', 'Hospitality Companies', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave');
         insert objAccount;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating account record - ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }

      try {
         //Create Contact record
         objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
         insert objContact;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating contact record - ' + errorMessage);

      //Get ProfileId to create User record
      Id profileId = [SELECT Id FROM profile WHERE name = 'AH Customer Community Plus Login User'].Id;
      System.assertEquals(true, profileId != null, 'Profile (AH Customer Community Plus Login User) record not found');

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }

      try {
         //Create User record
         objUser = AH_UDC_TestData.GetUserObject(objContact.Id, profileId, 'Test', 'User', 'Mr.', 'test@user.com', 'test@user.com' + AH_UDC_ConfigHelper.GetString('AH_UDC_CommunityUserNamePostfix', AH_UDC_Constants.DEFAULT_COMMUNITY_USER_NAME_POSTFIX));
         insert objUser;
      }
      catch(Exception ex) {
         isException = true;
         errorMessage = ex.GetMessage();
      }
      System.assertEquals(false, isException, 'Error occurred in creating user record - ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }

      System.runAs(objUser) {
         try {
            //Insert into Property Account object with blank property name to get more code coverage
            objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105', 'St 104', '1 Portsmouth Ave.');
            insert objProperty;
         }
         catch(Exception ex) {
            isException = true;
            errorMessage = ex.GetMessage();
         }
         System.assertEquals(false, isException, 'Error occurred in creating property account record - ' + errorMessage);

         //Reset with Default Values
         if (isException) {
            isException = false;
            errorMessage = '';
         }

         try {
            //Create NI Doc record
            objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
            objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
            insert objNIDoc;
         }
         catch(Exception ex) {
            isException = true;
            errorMessage = ex.GetMessage();
         }
         System.assertEquals(false, isException, 'Error occurred in creating NI Doc record - ' + errorMessage);

         //Reset with Default Values
         if (isException) {
            isException = false;
            errorMessage = '';
         }

         try {
            //Insert Contact NI Doc mapping record
            objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
            insert objUDCContact;
         }
         catch(Exception ex) {
            isException = true;
            errorMessage = ex.GetMessage();
         }
         System.assertEquals(false, isException, 'Error occurred in creating UDC Contact record - ' + errorMessage);

         //Reset with Default Values
         if (isException) {
            isException = false;
            errorMessage = '';
         }

         try {
            //Insert Workbook Record
            objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
            objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
            insert objWorkbook;
         }
         catch(Exception ex) {
            isException = true;
            errorMessage = ex.GetMessage();
         }
         System.assertEquals(false, isException, 'Error occurred in creating workbook record - ' + errorMessage);

         //Reset with Default Values
         if (isException) {
            isException = false;
            errorMessage = '';
         }

         try {
            //Insert Workbook Step Record
            objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
            objWorkbookStep.URL__c = 'https://www.lipsum.com/';
            objWorkbookStep.Description__c = 'Test Step 1 Description';
            objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_COMPLETED;
            insert objWorkbookStep;
         } catch(Exception exc) {
            isException = true;
            errorMessage = exc.GetMessage();
         }

         System.assertEquals(false, isException, 'Could not create AH_UDC_WorkbookStep__c record for testing ' + errorMessage);

         PageReference pageRef = Page.AH_UDC_LockWorkbookStep;
         pageRef.getParameters().put('id', objWorkbookStep.Id);
         Test.setCurrentPageReference(pageRef);
         Test.startTest();
         ApexPages.StandardController sController = new ApexPages.standardController(objWorkbookStep);
         AH_UDC_LockWorkbookStep lockWorkbook = new AH_UDC_LockWorkbookStep(sController);
         lockWorkbook.IsWorkbookComplete = false;
         System.assertEquals(false, lockWorkbook.IsStepNotCompleted, 'IsStepNotCompleted value could not be true');
         System.assertEquals(false, lockWorkbook.IsStepAlreadyLocked, 'IsWorkbookStepSentLocked value could be true');
         System.assertEquals(false, lockWorkbook.IsErrorOccurred, 'Error occurred in page execution');
         lockWorkbook.LockWorkbookStepSent();

         lockWorkbook.IsStepAlreadyLocked = true;
         System.assertEquals(true, lockWorkbook.IsStepAlreadyLocked, 'IsWorkbookStepSentLocked value could be false');
         lockWorkbook.LockWorkbookStepSent();        

         System.assertEquals(false, lockWorkbook.IsErrorOccurred, 'Error occurred in locking step');
         Test.stopTest();
      }
   }

   @isTest
   private static void AH_UDC_LockWorkbookStep_NegativeTest() {
      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
      PageReference pageRef = Page.AH_UDC_LockWorkbookStep;
      pageRef.getParameters().put('id', 'Test Id'); //Passing wrong id to generate error
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(objWorkbookStep);
      AH_UDC_LockWorkbookStep lockWorkbook = new AH_UDC_LockWorkbookStep(sController);
      System.assertEquals(true, lockWorkbook.IsErrorOccurred, 'Erro not occurred ith negative test');     
      lockWorkbook.LockWorkbookStepSent();
      System.assertEquals(true, lockWorkbook.IsErrorOccurred, 'Error not occurred in locking step');
      Test.stopTest();
   }

   @isTest
   private static void TestNagative() {
      AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
      PageReference pageRef = Page.AH_UDC_LockWorkbookStep; //Call AH_UDC_LockWorkbookStep page without Id parameter to generate error      
      Test.setCurrentPageReference(pageRef);
      Test.startTest();       
      ApexPages.StandardController sController = new ApexPages.standardController(objWorkbookStep);
      AH_UDC_LockWorkbookStep lockWorkbook = new AH_UDC_LockWorkbookStep(sController);
      System.assert(lockWorkbook.IsErrorOccurred, 'Expected an error to occur because Id for the NI Doc was not passed in');     
      Test.stopTest();
   }
}