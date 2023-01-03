/***********************************************************************************************
  Name            : AH_UDC_StepOrder_Test
  Author          : Ravi Shah
  Created Date    : 30-Jan-2021
  Last Mod Date   : 8-Feb-2021
  Last Mod By     : Sanjay Parmar
  NICC Reference  : 
  Description     : Test class for Step Order class
  Change History  :
  1. 590045 - Refactoring Code - Changed by Sanjay Parmar on 8-Feb-2021
  2. 594855 - Refactoring Code - Changed by Tushar Gupta on 23-Feb-2021
 ************************************************************************************************/
@isTest
private class AH_UDC_StepOrder_Test {
   
   private static final String TEST_NI_DOC_NAME = 'Test NI Document 1';
   private static final String TEST_WORKBOOK_NAME = 'Test Workbook 1';

   @TestSetup
   private static void setup() {
      //Prevent error : System.LimitException: Too many SOQL queries: 101
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');

      // Create NI Doc record
      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject(TEST_NI_DOC_NAME, Date.newInstance(2021, 3, 31));      
      insert objNIDoc;

      //Get workbook record type Id
      Id workbookRecordTypeId = Schema.SObjectType.AH_UDC_Workbook__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK).getRecordTypeId();
      system.assertEquals(true, workbookRecordTypeId != null, 'Could not get workbook record type Id of AH_UDC_Workbook');

      // Create Workbook Record
      String product = AH_UDC_TestData.GetProductPicklist() [0].getLabel();
      AH_UDC_Workbook__c objWorkbook = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, TEST_WORKBOOK_NAME, 'Test Workbook 1 Description', product);
      objWorkbook.RecordTypeId = workbookRecordTypeId; //Above function return object with Workbook Sent record type so need to change it
      insert objWorkbook;   
            
   }

   @isTest
   private static void AH_UDC_StepOrder_Test() {
     
      //Get workbook step record type Id
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get('AH_UDC_WorkbookStep').getRecordTypeId();
      system.assertEquals(true, workbookStepRecordTypeId != null, 'Could not get workbook record type Id of AH_UDC_WorkbookStep');
      
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                                   FROM AH_UDC_Workbook__c
                                                   WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.'); 
      
      //Create Form
      AH_UDC_Form__c form = new AH_UDC_Form__c(Name = 'TestForm1', FormAssemblyId__c = '123');
      insert form;
      System.assert(form != null, 'Could not create form record');

      List<AH_UDC_WorkbookStep__c> wbsteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 0; i <= 40; i++)
      {
         wbsteps.add(new AH_UDC_WorkbookStep__c(Name = 'WBStep' + i,
                                                RecordtypeId = workbookStepRecordTypeId,
                                                Workbook__c = lstWorkbook[0].Id,
                                                form__c = form.id));
      }
      insert wbsteps;
      System.assert(wbsteps.size() > 0, 'WorkbookStep records could not be found.');
      
      PageReference pageRef = Page.AH_UDC_StepOrder;
      pageRef.getParameters().put('id', lstWorkbook[0].Id);
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
      AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);
      system.assertEquals(true, (objStepOrder.IsErrorOccurred != true && objStepOrder.StepList != null && objStepOrder.StepList.size() > 0), 'Error occurred in Step Order page execution');

      if (objStepOrder.StepList.size() > 0) {
         String strStpeIds = '';
         for (Integer i = objStepOrder.StepList.size() - 1; i > 0; i--) { //Change step order in reverse
            if (String.isNotBlank(strStpeIds)) {
               strStpeIds += ',' + objStepOrder.StepList[i].Id;
            }
            else {
               strStpeIds = objStepOrder.StepList[i].Id;
            }
         }

         //Change order of workbook steps
         objStepOrder.StepIds = strStpeIds;
         objStepOrder.SaveStepOrders();
         system.assert(objStepOrder.IsErrorOccurred != true, 'Error occurred in updating Step Orders');         

         //Make StepIds blank to generate error and get more code coverage
         objStepOrder.StepIds = '';
         objStepOrder.SaveStepOrders();
         system.assert(objStepOrder.IsErrorOccurred, 'Error not generated after passing blank StepIds');
      }
      Test.stopTest();
   }

   @isTest
   private static void AH_UDC_StepOrder_Negative_Test() {   
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, Name
                                             FROM AH_UDC_Workbook__c
                                             WHERE Name = :TEST_WORKBOOK_NAME];
      System.assert(lstWorkbook.size() > 0, 'Workbook records could not be found.');

      PageReference pageRef = Page.AH_UDC_StepOrder;
      Test.setCurrentPageReference(pageRef);
      Test.startTest();
      ApexPages.StandardController sController = new ApexPages.standardController(lstWorkbook[0]);
      AH_UDC_StepOrder objStepOrder = new AH_UDC_StepOrder(sController);

      //Set name to generate error in LogException method
      objStepOrder.LogFunctionalArea = 'TestException';
      System.assert(objStepOrder.IsErrorOccurred, 'Error not occurred while executing page without id parameter');
      System.assert(objStepOrder.HasPageLoadLogMessages, 'No log entries found in queue list');

      objStepOrder.ServerLogMessages();
      System.assertEquals(false, objStepOrder.HasPageLoadLogMessages, 'PageLoadLogMessages is not empty');      

      Test.stopTest();
   }   
}