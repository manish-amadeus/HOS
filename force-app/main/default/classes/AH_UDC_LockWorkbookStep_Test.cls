/***********************************************************************************************
  Name            : AH_UDC_LockWorkbookStep_TEST
  Author          : Tushar Gupta
  Created Date    : 20-Apr-2021
  Last Mod Date   : 20-Apr-2021
  Last Mod By     : Tushar Gupta
  NICC Reference  : 
  Description     : Test class for lock workbook step
 ************************************************************************************************/
@isTest
public class AH_UDC_LockWorkbookStep_TEST {

   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
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

      List<User> listUsers = new List<User> ();
      //Create Workbook user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'lockWorkbookUser', null, false));
      //Create Workbook Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'lockWorkbookAdmin', null, false));
      //Create UDC System Admin user
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN,
                                    'lockUDCSysAdmin', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         // Community Users
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[1].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN, listUsers[2].Id);
      }

      User workbookUser = listUsers[0];
      User workbookAdmin = listUsers[1];

      //Create Account record
      objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;

      //Create Contact record
      objContact = AH_UDC_TestData.GetContactObject(objAccount.Id, 'Test', 'Contact', 'US', 'Portsmouth', '03801', 'NH', '75 New Hampshire Ave');
      insert objContact;

      //Insert into Property Account object with blank property name to get more code coverage
      objProperty = AH_UDC_TestData.GetPropertyObject('', 'Portsmouth', 'US', '03801', 'NH', '75 New Hampshire Ave', '3410 Via Mercato, St 105');
      insert objProperty;

      //Create NI Doc record
      objNIDoc = AH_UDC_TestData.GetNIDocObject('Test NI Document 1', Date.newInstance(2021, 3, 31));
      objNIDoc.AH_UDC_PropertyAccount__c = objProperty.Id;
      insert objNIDoc;

      //Insert Contact NI Doc mapping record
      objUDCContact = AH_UDC_TestData.GetUDCContactObject(objNIDoc.Id, objContact.Id, 'USD');
      insert objUDCContact;

      //Insert Workbook Record
      objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', 'Central Sales');
      objWorkbook.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
      // objWorkbook.RecordTypeId = wbsRTId;
      insert objWorkbook;

      //Insert Workbook Step Record
      objWorkbookStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
      objWorkbookStep.URL__c = 'https://www.lipsum.com/';
      objWorkbookStep.Description__c = 'Test Step 1 Description';
      objWorkbookStep.StepStatus__c = AH_UDC_Constants.STEP_STATUS_COMPLETED;
      insert objWorkbookStep;
      AH_UDC_WorkbookStep__c objWorkbookStep2;
      AH_UDC_Workbook__c wb2;
      //Insert workbook and it's steps for workbook user
      System.runAs(workbookUser) {
         NI_Documentation__c objNIDoc1 = null;
         //Create NI Doc record
         objNIDoc1 = AH_UDC_TestData.GetNIDocObject('Test NI Document 12', Date.newInstance(2021, 3, 31));
         objNIDoc1.AH_UDC_PropertyAccount__c = objProperty.Id;
         objNIDoc1.OwnerId = workbookUser.Id;
         insert objNIDoc1;

         //Insert Workbook Record
         wb2 = AH_UDC_TestData.GetWorkbookObject(objNIDoc1.Id, 'Test Workbook 2', 'Test Workbook 2 Description', 'Central Sales');
         wb2.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         wb2.OwnerId = workbookUser.Id;
         insert wb2;

         //Insert Workbook Step Record
         objWorkbookStep2 = AH_UDC_TestData.GetWorkbookStepObject(wb2.Id, 'Test Step 2');
         objWorkbookStep2.URL__c = 'https://www.lipsum1.com/';
         objWorkbookStep2.Description__c = 'Test Step 2 Description';
         objWorkbookStep2.StepStatus__c = AH_UDC_Constants.STEP_STATUS_COMPLETED;
         insert objWorkbookStep2;
      }

      //Insert workbook and it's steps for workbook Admin
      System.runAs(workbookAdmin) {
         //Insert Workbook Record
         AH_UDC_Workbook__c wb1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 3', 'Test Workbook 3 Description', 'Central Sales');
         wb1.SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
         insert wb1;

         //Insert Workbook Step Record
         objWorkbookStep2 = AH_UDC_TestData.GetWorkbookStepObject(wb1.Id, 'Test Step 3');
         objWorkbookStep2.URL__c = 'https://www.lipsum1.com/';
         objWorkbookStep2.Description__c = 'Test Step 3 Description';
         objWorkbookStep2.StepStatus__c = AH_UDC_Constants.STEP_STATUS_COMPLETED;
         insert objWorkbookStep2;
      }
   }

   @isTest
   private static void TestWithUDCSysAdmin() {
      List<User> lstUser = [SELECT Id FROM User WHERE Email = 'TestlockUDCSysAdmin@amadeus.com'];
      System.assert(lstUser.size() > 0, 'UDC System Admin is not created');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id FROM AH_UDC_WorkbookStep__c Where Name = 'Test Step 1'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook step record is not created.');

      Test.startTest();
      System.runAs(lstUser[0]) {
         ProcessExecution(lstWorkbookStep[0], true);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestWithWorkbookAdmin() {
      List<User> lstUser = [SELECT Id FROM User WHERE Email = 'TestlockWorkbookAdmin@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook Admin user is not created');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Name = 'Test Step 3'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook step record is not created.');

      Test.startTest();
      System.runAs(lstUser[0]) {
         ProcessExecution(lstWorkbookStep[0], false);
      }
      Test.stopTest();
   }

   @isTest
   private static void TestWithWorkbookUser() {
      List<User> lstUser = [SELECT Id FROM User WHERE Email = 'TestlockWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook user is not created');

      List<AH_UDC_WorkbookStep__c> lstWorkbookStep = [SELECT Id, Name, CreatedById, CreatedBy.Username
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Name = 'Test Step 2'];
      System.assert(lstWorkbookStep.size() > 0, 'Workbook step record is not created.');
      Test.startTest();
      System.runAs(lstUser[0]) {
         try {
            ProcessExecution(lstWorkbookStep[0], false);
         }
         catch(exception ex)
         {
            System.assert(ex.getMessage().indexOfIgnoreCase(Label.AH_UDC_UserAccessErrorMessageForWorkbookStep) > - 1, 'Workbook User should not be able to Unlock/Lock workbook step.');
            AH_UDC_LogHelper.Debug('Error while Unlocking/Locking workbook Step ' + ex.getMessage());
         }
      }
      Test.stopTest();
   }

   private static void ProcessExecution(AH_UDC_WorkbookStep__c workbookStep, Boolean isSysAdmin) {
      PageReference pageRef = Page.AH_UDC_LockWorkbookStep;
      pageRef.getParameters().put('id', workbookStep.Id);
      Test.setCurrentPageReference(pageRef);
      ApexPages.StandardController sController = new ApexPages.standardController(workbookStep);
      AH_UDC_LockWorkbookStep lockWorkbook = new AH_UDC_LockWorkbookStep(sController);

      lockWorkbook.IsWorkbookComplete = false;
      // If there is one or more error messages, extract the first one to add to the ASSERT message where applicable
      String msg = ApexPages.getMessages().size() > 0 ? ': ' + ApexPages.getMessages() [0] : '';
      System.assertEquals(false, lockWorkbook.IsStepNotCompleted, 'IsStepNotCompleted value is not true' + msg);
      System.assertEquals(false, lockWorkbook.IsStepAlreadyLocked, 'IsWorkbookStepSentLocked value is true' + msg);
      System.assertEquals(false, lockWorkbook.IsErrorOccurred, 'Error occurred in AH_UDC_LockWorkbookStep page initialization' + msg);
      lockWorkbook.LockWorkbookStepSent();

      List<AH_UDC_WorkbookStep__c> lstWorkbookStepDetails = [SELECT StepStatus__c FROM AH_UDC_WorkbookStep__c WHERE Name = 'Test Step 1'];
      if (isSysAdmin) {
         System.assertEquals(AH_UDC_Constants.STEP_STATUS_LOCKED, lstWorkbookStepDetails[0].StepStatus__c, 'Workbook step status is not locked');
      } else {
         System.assertEquals(AH_UDC_Constants.STEP_STATUS_COMPLETED, lstWorkbookStepDetails[0].StepStatus__c, 'Workbook step status is not completed');
      }
   }

   @isTest
   private static void NegativeTestA() {
      List<User> lstUser = [SELECT Id FROM User WHERE Email = 'TestlockUDCSysAdmin@amadeus.com'];
      System.assert(lstUser.size() > 0, 'UDC System Admin is not created');

      Test.startTest();
      System.runAs(lstUser[0]) {
         AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
         PageReference pageRef = Page.AH_UDC_LockWorkbookStep;
         pageRef.getParameters().put('id', lstUser[0].Id); //Passing wrong id to generate error
         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sController = new ApexPages.standardController(objWorkbookStep);
         AH_UDC_LockWorkbookStep lockWorkbook = new AH_UDC_LockWorkbookStep(sController);
         System.assertEquals(true, lockWorkbook.IsErrorOccurred, 'Error not occurred while initializing the AH_UDC_LockWorkbookStep');
         lockWorkbook.LockWorkbookStepSent();
         System.assertEquals(true, lockWorkbook.IsErrorOccurred, 'Error not occurred in locking step');
      }
      Test.stopTest();
   }

   @isTest
   private static void NagativeTestB() {
      List<User> lstUser = [SELECT Id FROM User WHERE Email = 'TestlockWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook User is not created');

      Test.startTest();
      System.runAs(lstUser[0]) {
         AH_UDC_WorkbookStep__c objWorkbookStep = new AH_UDC_WorkbookStep__c();
         PageReference pageRef = Page.AH_UDC_LockWorkbookStep; //Call AH_UDC_LockWorkbookStep page without Id parameter to generate error 
         Test.setCurrentPageReference(pageRef);
         ApexPages.StandardController sController = new ApexPages.standardController(objWorkbookStep);
         AH_UDC_LockWorkbookStep lockWorkbook = new AH_UDC_LockWorkbookStep(sController);
         System.assert(lockWorkbook.IsErrorOccurred, 'Expected an error to occur because Id for the NI Doc was not passed in');
         lockWorkbook.ServerLogMessages();
         System.assert(!lockWorkbook.HasPageLoadLogMessages, 'An error occurred while calling the method ServerLogMessages');
         lockWorkbook.LogFunctionalArea = 'TestException';
         lockWorkbook.ServerLogMessages();
      }
      Test.stopTest();
   }
}