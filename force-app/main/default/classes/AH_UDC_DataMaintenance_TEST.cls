/*
 * Name         : AH_UDC_DataMaintenance_TEST
 * Created By   : Vaishali Patel (vaishali.patel@amadeus.com)
 * Created Date : 9/2/2021
 * Description  : Unit test for AH_UDC_DataMaintenance_Batch class and AH_UDC_DataMaintenance_Schedule class
 * Dependencies : AH_UDC_DataMaintenance_Batch, AH_UDC_DataMaintenance_Schedule, AH_UDC_DataMaintenanceResponse_Batch
 */

@isTest
public class AH_UDC_DataMaintenance_TEST {
   //TotalStepRecords * TotalResponse should be less than or equal to AH_UDC_DataMaintenance_Schedule MAX_BATCH_SIZE
   public static final Integer TotalStepRecords = 3;
   public static final Integer TotalResponse = 5;
   public static final Integer TotalFormRecords = TotalStepRecords;
   public static final Integer TotalResponseQA = 10;

   @testSetup
   private static void setupTestData() {
      AH_UDC_InitializationHelper.Initialize('ConfigurationSettings');
      //Insert new Account data
      Account objAccount = AH_UDC_TestData.GetAccountObject('GUID');
      insert objAccount;
      //System.assert(AH_UDC_DataMaintenance_Schedule.MAX_BATCH_SIZE >= TotalStepRecords * TotalResponse, 'TotalStepRecords * TotalResponse should be less than or equal to AH_UDC_DataMaintenance_Schedule.MAX_BATCH_SIZE');

      NI_Documentation__c objNIDoc = AH_UDC_TestData.GetNIDocObject('UDC Test NI Document DM1', Date.newInstance(2021, 7, 30));
      objNIDoc.Account__c = objAccount.Id;
      insert objNIDoc;

      Schema.DescribeFieldResult fieldResult = null;
      List<Schema.PicklistEntry> pickListEntry = null;

      //Get Product Picklist
      fieldResult = AH_UDC_Workbook__c.Product__c.getDescribe();
      if (fieldResult != null) {
         pickListEntry = fieldResult.getPicklistValues();
      }

      //Insert Workbook Record
      AH_UDC_Workbook__c objWorkbook1 = AH_UDC_TestData.GetWorkbookObject(objNIDoc.Id, 'Test Workbook 1', 'Test Workbook 1 Description', pickListEntry[0].getLabel());
      insert objWorkbook1;

      Id FormAssemblyFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_FORM_ASSEMBLY);

      Id AmadeusFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FORM);

      //Create Form
      List<AH_UDC_Form__c> lstForms = new List<AH_UDC_Form__c> ();
      for (Integer i = 1; i <= TotalFormRecords; i++) {
         AH_UDC_Form__c objForm = null;
         if (i< 2) {
            objForm = AH_UDC_TestData.GetForm('', '', 'TestFormAF', '');
            objForm.RecordTypeId = AmadeusFormRecordTypeId;
         }
         else
         {
            //Generate 7 digits form assembly Id
            Integer intFormAssemblyId = (Integer) Math.round(Math.random() * (9000000) + 1000000);
            objForm = AH_UDC_TestData.GetForm('', '222222' + i, 'TestFormFA' + i, String.valueOf(intFormAssemblyId));
            objForm.RecordTypeId = FormAssemblyFormRecordTypeId;
         }
         lstForms.add(objForm);
      }
      insert lstForms;
      AH_UDC_LogHelper.Debug('lstForms : lstForms.size(): ' + lstForms.size());
      //Create steps and responses 
      Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(workbookStepRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP);

      List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = new List<AH_UDC_WorkbookStep__c> ();
      for (Integer i = 0; i<TotalStepRecords; i++) {
         AH_UDC_WorkbookStep__c objWBStep = AH_UDC_TestData.GetWorkbookStepObject(objWorkbook1.Id, 'Test Step ' + (i + 1));
         objWBStep.Form__c = lstForms[i].Id;
         lstWorkbookSteps.add(objWBStep);
      }
      AH_UDC_LogHelper.Debug('CreateStepsForWorkbook : lstWorkbookSteps.size(): ' + lstWorkbookSteps.size());
      insert lstWorkbookSteps;

      Id FormAssemblyResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_FORM_ASSEMBLY);

      Id AmadeusFormResponseRecordTypeId = Schema.SObjectType.AH_UDC_Response__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseRecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_AMADEUS_FORM);

      List<AH_UDC_Response__c> lstResponses = new List<AH_UDC_Response__c> ();

      for (AH_UDC_WorkbookStep__c objStep : lstWorkbookSteps) {
         for (Integer i = 0; i<TotalResponse; i++) {
            AH_UDC_Response__c objResponse = AH_UDC_TestData.GetStepResponseObject();
            if (objStep.Form__r.RecordTypeId == FormAssemblyFormRecordTypeId)
            objResponse.RecordTypeId = FormAssemblyResponseRecordTypeId;
            else if (objStep.Form__r.RecordTypeId == AmadeusFormRecordTypeId)
            objResponse.RecordTypeId = AmadeusFormResponseRecordTypeId;
            lstResponses.add(objResponse);
         }
      }
      AH_UDC_LogHelper.Debug('CreateResponseForAllSteps : lstResponses.size(): ' + lstResponses.size());
      insert lstResponses;

      Id FormAssemblyResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(FormAssemblyResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_FORM_ASSEMBLY);

      Id AmadeusFormResponseQARecordTypeId = Schema.SObjectType.AH_UDC_ResponseQA__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM).getRecordTypeId();
      System.assert(String.isNotBlank(String.valueOf(AmadeusFormResponseQARecordTypeId)), 'Record Type not found - ' + AH_UDC_Constants.RECORD_TYPE_RESPONSE_QA_AMADEUS_FORM);

      List<AH_UDC_WorkbookStepResponse__c> lstWorkbookStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();
      List<AH_UDC_ResponseQA__c> lstResponseQA = new List<AH_UDC_ResponseQA__c> ();
      Integer index = 1, iSortOrder = 1, stepCount = 0, responseCounter = 1;
      AH_UDC_LogHelper.Debug('ABOVE ResponseQA loop : lstResponses.size(): ' + lstResponses.size());
      AH_UDC_LogHelper.Debug('FormAssemblyResponseRecordTypeId: ' + FormAssemblyResponseRecordTypeId);
      AH_UDC_LogHelper.Debug('AmadeusFormResponseRecordTypeId: ' + AmadeusFormResponseRecordTypeId);

      for (AH_UDC_Response__c objResponse : lstResponses) {
         iSortOrder = 1;
         AH_UDC_LogHelper.Debug('In ResponseQA loop : objResponse: ' + objResponse);
         AH_UDC_LogHelper.Debug(' objResponse.RecordTypeId: ' + objResponse.RecordTypeId);
         for (Integer i = 0; i<TotalResponseQA; i++) {
            AH_UDC_ResponseQA__c objResponseQA;
            if (stepCount> 2)
            {
               objResponseQA = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, 'Test Question ' + index, 'Test Question Field ' + index, 'Test Answer ' + index, 'Test Answer Field ' + index);
               objResponseQA.RecordTypeId = FormAssemblyResponseQARecordTypeId;
            }
            else {
               String strJSON = '{"SortOrder":"1","QuestionField":"AHUDC_1_3_0","Question":"Textbox","AnswerField":"","Answer":"Test1"},{"SortOrder":"2","QuestionField":"AHUDC_1_4_0","Question":"Use Buildings?","AnswerField":"AHUDC_1_4_Yes","Answer":"Yes"},{"SortOrder":"3","QuestionField":"AHUDC_1_5_0","Question":"Banquet?","AnswerField":"","Answer":"true"},{"SortOrder":"4","QuestionField":"AHUDC_1_6_0","Question":"Will you be interfacing your phone system to APMS?","AnswerField":"AHUDC_1_6_No","Answer":"No"}';
               objResponseQA = AH_UDC_TestData.GetStepResponseQAObject(objResponse.Id, strJSON, iSortOrder);
               objResponseQA.RecordTypeId = AmadeusFormResponseQARecordTypeId;
            }
            lstResponseQA.add(objResponseQA);
            index++; iSortOrder++;
            if (index> 2000) break;
         }

         //Insert record into junction object to map response with the step            
         lstWorkbookStepResponses.add(AH_UDC_TestData.GetWorkbookStepResponseObject(lstWorkbookSteps[stepCount].Id, objResponse.Id));

         AH_UDC_LogHelper.Debug(' in for stepCount: ' + stepCount + 'responseCounter: ' + responseCounter + ' TotalResponse : ' + TotalResponse);
         if (math.mod(responseCounter, TotalResponse) == 0)
         {
            stepCount++;
            AH_UDC_LogHelper.Debug('in if stepCount: ' + stepCount + 'responseCounter: ' + responseCounter);
         }
         if (index> 2000) break;
         responseCounter++;
      }
      AH_UDC_LogHelper.Debug('stepCount: ' + stepCount);
      insert lstWorkbookStepResponses;
      insert lstResponseQA;
   }

   @isTest
   private static void testPurgeWorkbookStepResponses()
   {
      Test.startTest();

      Integer noOfResponsesToKeep = AH_UDC_ConfigHelper.GetInteger('AH_UDC_NumberOfPriorWorkbookStepSentResponsesToKeep', 3);
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, SentStatus__c FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook with name Test Workbook 1.');
      System.assert(lstWorkbook[0].SentStatus__c != AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED, 'Workbook status is Completed/Locked');

      AH_UDC_DataMaintenance_Batch obj = new AH_UDC_DataMaintenance_Batch();
      Database.executeBatch(obj);
      Test.stopTest();

      List<AH_UDC_WorkbookStep__c> workbookSteps = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :lstWorkbook[0].Id order by SortOrder__c];
      Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :workbookSteps[0].Id];
      System.assertEquals(noOfResponsesToKeep, noOfResponse, 'Expected Responses for Workbook Steps : ' + noOfResponse + ' should be: ' + noOfResponsesToKeep);
   }

   @isTest
   private static void testPurgeLockedCompletedWorkbookStepResponse()
   {
      Test.startTest();
      List<AH_UDC_Workbook__c> lstWorkbookOri = [SELECT Id, SentStatus__c FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assertEquals(1, lstWorkbookOri.size(), 'Expected 1 Workbook with name Test Workbook 1.');
      lstWorkbookOri[0].SentStatus__c = AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED;
      lstWorkbookOri[0].CompletedDate__c = System.today() - 5;
      update lstWorkbookOri[0];

      Integer noOfDaysFromConfig = AH_UDC_ConfigHelper.GetInteger('AH_UDC_PurgeResponseAfterNumberOfDaysForCompletedLockedWorkbooks', 3);


      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, CompletedDate__c, SentStatus__c FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assertEquals(AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED, lstWorkbook[0].SentStatus__c, 'Workbook status is not Completed/Locked');
      Boolean IsCompletedBefore = (Date.valueOf(lstWorkbook[0].CompletedDate__c).daysBetween(System.today()))> noOfDaysFromConfig;
      System.assert(IsCompletedBefore, 'Workbook should be Completed/Locked before ' + noOfDaysFromConfig);

      AH_UDC_DataMaintenance_Batch obj = new AH_UDC_DataMaintenance_Batch();
      Database.executeBatch(obj);
      Test.stopTest();

      List<AH_UDC_WorkbookStep__c> workbookStepsResult = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :lstWorkbook[0].Id order by SortOrder__c];
      System.assertEquals(TotalStepRecords, workbookStepsResult.size(), 'Expected ' + TotalStepRecords + ' Workbook Steps');

      List<AH_UDC_WorkbookStepResponse__c> responseResult = [SELECT Response__c, WorkbookStep__c, IsMostRecentResponse__c FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :workbookStepsResult[0].Id];
      System.assertEquals(1, responseResult.size(), 'Expected Responses for Workbook Steps : ' + workbookStepsResult[0].Id + 'should be 1');
      System.assertEquals(True, responseResult[0].IsMostRecentResponse__c, 'Expected most recent response');
   }



   @isTest
   private static void ExceptionTestForWorkbookStepResponse() {
      Test.startTest();
      try {
         AH_UDC_DataMaintenance_Batch.IsTestException = true;
         AH_UDC_DataMaintenance_Batch obj = new AH_UDC_DataMaintenance_Batch();
         Database.executeBatch(obj);
      }
      catch(Exception ex)
      {
         System.assert(ex.getMessage().indexOf('Divide by 0') > - 1, 'Different error occurred in the method GetAddress. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
      }
      Test.stopTest();
   }

   //Test for AH_UDC_DataMaintenanceResponse_Batch 
   @isTest
   private static void testPurgeResponses()
   {
      Integer noOfResponsesToKeep = AH_UDC_ConfigHelper.GetInteger('AH_UDC_NumberOfPriorWorkbookStepSentResponsesToKeep', 3);
      List<AH_UDC_Workbook__c> lstWorkbook = [SELECT Id, SentStatus__c FROM AH_UDC_Workbook__c WHERE Name = 'Test Workbook 1'];
      System.assertEquals(1, lstWorkbook.size(), 'Expected 1 Workbook with name Test Workbook 1.');
      System.assert(lstWorkbook[0].SentStatus__c != AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED, 'Workbook status is Completed/Locked');

      Integer noOfWBSResponse = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c];
      System.assertEquals((TotalResponse * TotalStepRecords), noOfWBSResponse, 'Expected Responses for Workbook Steps : ' + noOfWBSResponse + ' should be: ' + TotalResponse * TotalStepRecords);

      List<AH_UDC_WorkbookStep__c> workbookStep = [SELECT Id FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :lstWorkbook[0].Id order by SortOrder__c];
      System.assertEquals(TotalStepRecords, workbookStep.size(), 'Expected ' + TotalStepRecords + ' Workbook steps but actual workbook steps are ' + workbookStep.size() + '.');
      Integer noOfWBSResponseFor1Step = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c WHERE WorkbookStep__c = :workbookStep[1].Id];
      System.assertEquals(TotalResponse, noOfWBSResponseFor1Step, 'Expected Workbook Step Responsess: ' + noOfWBSResponseFor1Step + ' should be: ' + TotalResponse);

      List<AH_UDC_WorkbookStepResponse__c> lstWSRtoDelete = [Select Id FROM AH_UDC_WorkbookStepResponse__c WHERE IsMostRecentResponse__c = false];
      delete lstWSRtoDelete;

      noOfWBSResponse = [SELECT COUNT() FROM AH_UDC_WorkbookStepResponse__c];
      System.assertEquals(TotalStepRecords, noOfWBSResponse, 'Expected Responses for Workbook Steps : ' + noOfWBSResponse + ' should be: ' + TotalStepRecords);

      Test.startTest();
      AH_UDC_DataMaintenanceResponse_Batch obj = new AH_UDC_DataMaintenanceResponse_Batch();
      Database.executeBatch(obj);
      Test.stopTest();

      Integer noOfResponse = [SELECT COUNT() FROM AH_UDC_Response__c];
      AH_UDC_LogHelper.Debug('Total Response :  ' + noOfResponse);
      System.assertEquals(TotalStepRecords, noOfResponse, 'Expected Responses for Workbook Steps : ' + noOfResponse + ' should be: ' + TotalStepRecords);
   }

   @isTest
   private static void ExceptionTestForResponse() {
      Test.startTest();
      try {
         AH_UDC_DataMaintenanceResponse_Batch.IsTestException = true;
         AH_UDC_DataMaintenanceResponse_Batch obj = new AH_UDC_DataMaintenanceResponse_Batch();
         Database.executeBatch(obj);
      }
      catch(Exception ex)
      {
         System.assert(ex.getMessage().indexOf('Divide by 0') > - 1, 'Different error occurred in the method GetAddress. Error: ' + ex.getMessage() + ' at line number ' + ex.getLineNumber());
      }
      Test.stopTest();
   }

   //Test for AH_UDC_DataMaintenance_Schedule 
   @isTest
   private static void DataMaintenanceScheduleTest() {
      Test.StartTest();
      AH_UDC_DataMaintenance_Schedule testBatchSchedule = new AH_UDC_DataMaintenance_Schedule();
      String sch = '0 0 0 1 1 ? ';
      sch += System.Today().year() + 1;

      // Schedule the test job
      String jobId = System.schedule('AH UDC DataMaintenance Test Job', sch, testBatchSchedule);
      Test.stopTest();
      // Get the information from the CronTrigger API object 
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      // Verify the job has not run 
      System.assertEquals(0, ct.TimesTriggered);
      // Verify the next time the job will run 
      String expResult = System.Today().year() + 1 + '-01-01 00:00:00';
      System.assertEquals(expResult, String.valueOf(ct.NextFireTime));
   }
}