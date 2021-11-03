/***********************************************************************************************
  Name            : AH_UDC_CloneWorkbook
  Author          : Tushar Gupta
  Created Date    : 29-Jan-2021
  Last Mod Date   : 29-Jan-2021
  Last Mod By     : Tuhsar Gupta
  NICC Reference  : 
  User Story ID   : 574902
  Description     : Test class for Workbook clone of UDC 
                     1. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
@isTest
public class AH_UDC_CloneWorkbook_Test {
   @TestSetup private static void setup() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
   }

   @isTest
   private static void AH_UDC_CloneWorkbook_Test() {
      Boolean isException = false;
      String errorMessage = '';
      AH_UDC_Workbook__c objWorkbook = null;
      try {
         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Descriptions', 'Central Sales');
         insert objWorkbook;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_Workbook__c record for testing ' + errorMessage);

      //Reset with Default Values
      if (isException) {
         isException = false;
         errorMessage = '';
      }
      AH_UDC_WorkbookStep__c objWorkbookStepOne = null;
      AH_UDC_WorkbookStep__c objWorkbookStepTwo = null;
      try {
         //Insert First Workbook Record 
         objWorkbookStepOne = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 1');
         objWorkbookStepOne.URL__c = 'https://www.Amadeus.com/1';
         insert objWorkbookStepOne;
         //Insert Second Workbook Record 
         objWorkbookStepTwo = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook.Id, 'Test Step 2');
         objWorkbookStepTwo.URL__c = 'https://www.Amadeus.com/2';
         objWorkbookStepTwo.Prerequisite_Step__c = objWorkbookStepOne.Id;
         insert objWorkbookStepTwo;

      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_WorkbookStep__c record for testing ' + errorMessage);

      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      pageRef.getParameters().put('id', objWorkbook.Id);
      Test.setCurrentPageReference(pageRef);
      Test.startTest();

      ApexPages.StandardController sController = new ApexPages.standardController(objWorkbook);
      AH_UDC_CloneWorkbook clnWorkbook = new AH_UDC_CloneWorkbook(sController);

      //Workbook should not be null
      System.assertEquals(true, clnWorkbook.Workbook != null, 'Workbook object could not initialized');

      //Check the query string value
      System.debug(clnWorkbook.WorkbookId + ' ' + objWorkbook.Id);
      System.assertEquals(clnWorkbook.WorkbookId, objWorkbook.Id, 'Query String value could not be matched');

      //Check the name which is display in UI
      System.assertEquals(clnWorkbook.Workbook.Name, 'Clone of ' + objWorkbook.Name, 'Workbook name could not be matched');

      //Call the method for clone the workbook
      clnWorkbook.CloneWorkbook();

      //If any errors are not occurred then isAnyError should be false
      System.assertEquals(false, clnWorkbook.IsAnyError, 'Clone workbook has received error');

      //Workbook name should be valid if workbook name is unique
      System.assertEquals(true, clnWorkbook.IsWorkbookNameValid, 'Workbook name is not valid');

      //If everything going good then NewWorkbookId should not be empty
      System.assertEquals(true, !String.isBlank(clnWorkbook.NewWorkbookId), 'NewWorkbook Id could not blank');

      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_CloneWorkbook_NegativeTest() {
      Boolean isException = false;
      String errorMessage = '';
      AH_UDC_Workbook__c objWorkbook = null;
      try {
         //Insert Workbook Record
         objWorkbook = AH_UDC_TestData.GetWorkbookObjectWithoutDocId('Test Workbook 1', 'Test Workbook 1 Descriptions', 'Central Sales');
         insert objWorkbook;
      } catch(Exception exc) {
         isException = true;
         errorMessage = exc.GetMessage();
      }
      System.assertEquals(false, isException, 'Could not create AH_UDC_Workbook__c record for testing ' + errorMessage);

      //AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();

      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      pageRef.getParameters().put('id', objWorkbook.Id);
      Test.setCurrentPageReference(pageRef);

      ApexPages.StandardController sController = new ApexPages.standardController(objWorkbook);
      AH_UDC_CloneWorkbook clnWorkbook = new AH_UDC_CloneWorkbook(sController);
      clnWorkbook.Workbook.Name = 'Test Workbook 1';
      Test.startTest();
      //Call the method for clone the workbook
      clnWorkbook.CloneWorkbook();

      clnWorkbook.Workbook.Name = 'Clone of Test Workbook 1';
      clnWorkbook.CloneWorkbook();
      System.assertEquals(false, clnWorkbook.IsAnyError, 'IsAnyError in CloneWorkbook method could not false');
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_CloneWorkbook_NegativeTest2() {
      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      pageRef.getParameters().put('id', 'a0z29000001qZI8AAM');
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      ApexPages.StandardController sController = new ApexPages.standardController(objWorkbook);
      AH_UDC_CloneWorkbook clnWorkbook = new AH_UDC_CloneWorkbook(sController);
      clnWorkbook.ServerLogMessages();
      Boolean hasError = clnWorkbook.HasPageLoadLogMessages;
      System.assertEquals(false, clnWorkbook.Workbook != null, 'workbook object could not be null');
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_CloneWorkbook_NegativeTest3() {
      PageReference pageRef = Page.AH_UDC_CloneWorkbook;
      Test.setCurrentPageReference(pageRef);

      Test.startTest();
      AH_UDC_Workbook__c objWorkbook = new AH_UDC_Workbook__c();
      ApexPages.StandardController sController = new ApexPages.standardController(objWorkbook);
      AH_UDC_CloneWorkbook clnWorkbook = new AH_UDC_CloneWorkbook(sController);
      System.assertEquals(false, clnWorkbook.Workbook != null, 'workbook object could not be null');
      Test.stopTest();
   }
}