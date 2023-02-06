/***********************************************************************************************
  Name            : AH_UDC_CloneWorkbook_TEST
  Author          : Tushar Gupta
  Created Date    : 29-Jan-2021
  Last Mod Date   : 29-Jan-2021
  Last Mod By     : Tuhsar Gupta
  Description     : Test class for Workbook clone of UDC 
 ************************************************************************************************/
@isTest
public class AH_UDC_CloneWorkbook_TEST {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      List<User> listUsers = new List<User> ();

      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN,
                                    'cloneWorkbookAdmin', null, false));
      listUsers.add(AH_UDC_TestData.BuildUser(AH_UDC_Constants.PROFILE_DEFAULT_NAME_PSA_SF_LIGHTNING,
                                    AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER,
                                    'cloneWorkbookUser', null, false));

      User oCurrentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
      oCurrentUser.ContactId = null;

      System.runAs(oCurrentUser) {
         AH_UDC_TestData.InsertWithRetries(listUsers);

         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_ADMIN, listUsers[0].Id);
         AH_UDC_TestData.AddPermissionSetToUser(AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_WORKBOOK_USER, listUsers[1].Id);
      }

      //Insert Workbook Record
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Descriptions', 'Central Sales');
      insert objWorkbook;

      //Insert First Workbook Record 
      AH_UDC_WorkbookStep__c objWorkbookStepOne = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
      objWorkbookStepOne.URL__c = 'https://www.Amadeus.com/1';
      insert objWorkbookStepOne;

      //Insert Second Workbook Record 
      AH_UDC_WorkbookStep__c objWorkbookStepTwo = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 2');
      objWorkbookStepTwo.URL__c = 'https://www.Amadeus.com/2';
      objWorkbookStepTwo.Prerequisite_Step__c = objWorkbookStepOne.Id;
      insert objWorkbookStepTwo;
   }

   @isTest
   private static void TestWithWorkbookAdmin() {
      List<User> lstUser = [Select Id From User Where Email = 'TestcloneWorkbookAdmin@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook Admin user is not created');

      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id, Name From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbook record is not created.');

      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      pageRef.getParameters().put('id', lstWorkbook[0].Id);
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      System.runAs(lstUser[0]) {
         ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
         AH_UDC_CloneWorkbook objCloneWorkbook = new AH_UDC_CloneWorkbook(sController);

         //Workbook should not be null
         System.assertEquals(true, objCloneWorkbook.Workbook != null, 'Workbook object did not initialize');

         //Check the query string value
         System.assertEquals(objCloneWorkbook.WorkbookId, lstWorkbook[0].Id, 'Workbook Id did not match');

         //Check the name which is display in UI
         System.assertEquals(objCloneWorkbook.Workbook.Name, 'Clone of ' + lstWorkbook[0].Name, 'Workbook name did not match');

         //Call the method for clone the workbook
         objCloneWorkbook.CloneWorkbook();

         if (objCloneWorkbook.IsErrorOccurred) {
            AH_UDC_LogHelper.GetTestMethodLogs('AH_UDC_CloneWorkbook_TEST');
         }

         //If any errors are not occurred then IsErrorOccurred should be false
         System.assertEquals(false, objCloneWorkbook.IsErrorOccurred, 'Clone workbook has received an error');

         //Workbook name should be valid if workbook name is unique
         System.assertEquals(true, objCloneWorkbook.IsWorkbookNameValid, 'Workbook name is not valid');

         //If everything going good then NewWorkbookId should not be empty
         System.assertEquals(true, !String.isBlank(objCloneWorkbook.NewWorkbookId), 'NewWorkbookId should not blank');
      }
      Test.stopTest();
   }

   @isTest
   private static void TestWithWorkbookUser() {
      List<User> lstUser = [Select Id From User Where Email = 'TestcloneWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook user is not created.');

      List<AH_UDC_Workbook__c> lstWorkbook = [Select Id, Name From AH_UDC_Workbook__c Where Name = 'Test Workbook 1'];
      System.assert(lstWorkbook.size() > 0, 'Workbook record is not created');

      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      pageRef.getParameters().put('id', lstWorkbook[0].Id);
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      System.runAs(lstUser[0]) {
         ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
         AH_UDC_CloneWorkbook objCloneWorkbook = new AH_UDC_CloneWorkbook(sController);
         System.assertEquals(true, objCloneWorkbook.IsErrorOccurred, 'Workbook User have cloned access on workbook.');

         //Workbook should not be null
         System.assertEquals(true, objCloneWorkbook.Workbook == null, 'Workbook object should not blank/null');

         //Check the query string value
         System.assertEquals(objCloneWorkbook.WorkbookId, lstWorkbook[0].Id, 'Workbook Id did not match');

         //Check the name which is display in UI
         System.assert(String.isBlank(objCloneWorkbook.Workbook.Name), 'Clone Workbook name should be blank/null');

         //Call the method for clone the workbook
         objCloneWorkbook.CloneWorkbook();

         //If any errors are not occurred then IsErrorOccurred should be false
         System.assertEquals(false, objCloneWorkbook.IsErrorOccurred, 'Clone workbook has received an error');

         //If everything going good then NewWorkbookId should not be empty
         System.assert(String.isBlank(objCloneWorkbook.NewWorkbookId), 'NewWorkbookId should be blank');
      }
      Test.stopTest();
   }   

   @isTest
   private static void NegativeTest2() {
      List<User> lstUser = [Select Id From User Where Email = 'TestcloneWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook user is not created.');

      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      pageRef.getParameters().put('id', lstUser[0].Id); // Pass the wrong Id for negative testing
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      System.runAs(lstUser[0]) {
         AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
         ApexPages.StandardController sController = new ApexPages.standardController(objWorkbook);
         AH_UDC_CloneWorkbook objCloneWorkbook = new AH_UDC_CloneWorkbook(sController);
         objCloneWorkbook.ServerLogMessages();
         Boolean hasError = objCloneWorkbook.HasPageLoadLogMessages;
         System.assert(hasError == false, 'hasError should be false');
         System.assertEquals(false, objCloneWorkbook.Workbook != null, 'Workbook object should not be null');
      }
      Test.stopTest();
   }

   @isTest
   private static void NegativeTest3() {
      List<User> lstUser = [Select Id From User Where Email = 'TestcloneWorkbookUser@amadeus.com'];
      System.assert(lstUser.size() > 0, 'Workbook user is not created.');
      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      System.runAs(lstUser[0]) {
         AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
         ApexPages.StandardController sController = new ApexPages.standardController(objWorkbook);
         AH_UDC_CloneWorkbook objCloneWorkbook = new AH_UDC_CloneWorkbook(sController);
         System.assertEquals(false, objCloneWorkbook.Workbook != null, 'workbook object should not be null');
         objCloneWorkbook.LogFunctionalArea = 'TestException'; //For generating the error and cover the catch block
         objCloneWorkbook.CloneWorkbook();
         //If any errors are not occurred then IsErrorOccurred should be false
         System.assert(objCloneWorkbook.IsErrorOccurred, 'Clone workbook has not received an error');
      }
      Test.stopTest();
   }
}