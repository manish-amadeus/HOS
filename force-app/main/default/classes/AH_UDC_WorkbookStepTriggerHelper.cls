<<<<<<< HEAD
/**
 * Name          : AH_UDC_WorkbookStepTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_WorkbookStep
 * Dependencies  : 
 **/

public with sharing class AH_UDC_WorkbookStepTriggerHelper {
   @TestVisible public static Boolean IsWorkbookSentRecordTypeForException = false;
   @TestVisible public static Boolean IsWorkbookRecordTypeException = false;
   @TestVisible public static Boolean IsFormRecordTypeException = false;
   @TestVisible public static Boolean IsExceptionToCoverCatchBlock = false;

   public static void onTrigger() {
      List<Id> lstPrerequisiteStep = null;
      Exception ex = null;
      Boolean isAnyExceptionOccurred = false;
      try {
         if (Test.isRunningTest() && Trigger.new != null && Trigger.new.size() > 0 && ((AH_UDC_WorkbookStep__c) Trigger.new[0]).name == 'TestException') integer i = 1 / 0;

         if (Trigger.isBefore && (Trigger.isInsert)) {
            onBeforeInsertStep();
            fileUploadStepValidation();
            return;
         }

         if (Trigger.isBefore && (Trigger.isUpdate)) {
            onBeforeUpdateStep();
            fileUploadStepValidation();
            return;
         }

         if (Trigger.isBefore && (Trigger.isDelete))
         {
            onDeleteStep();
            return;
         }

         if (Trigger.isAfter && (Trigger.isUndelete))
         {
            onUndeleteStep();
            fileUploadStepValidation();
            return;
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onTrigger', 'An exception occurred during workbook step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);

         // Mark all records as failed due to the unexpected exception that occurred
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage); // prevent upsert
         }
      }
   }

   private static void fileUploadStepValidation() {
      try {
         AH_UDC_LogHelper.Debug('Inside fileUploadStepValidation');
         Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => workbookStepRecordTypeId: ' + workbookStepRecordTypeId);

         //Generate exception for test class execution
         if (Test.isRunningTest() && IsWorkbookRecordTypeException == true) workbookStepRecordTypeId = null;

         if (String.isBlank(String.valueOf(workbookStepRecordTypeId))) {
            for (SObject obj : (Trigger.new != null ? Trigger.new : Trigger.old)) {
               obj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage);
            }
            AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: Workbook Step Record Type Id not found');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_WorkbookStepTriggerHelper',
                                 'fileUploadStepValidation', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                                 null, null, null);
            return;
         }

         Id fileUploadFormRecordTypeId = Schema.SObjectType.AH_UDC_Form__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_FORM_AMADEUS_FILE_UPLOAD).getRecordTypeId();
         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => fileUploadFormRecordTypeId: ' + fileUploadFormRecordTypeId);

         //Generate exception for test class execution
         if (Test.isRunningTest() && IsFormRecordTypeException == true) fileUploadFormRecordTypeId = null;

         if (String.isBlank(String.valueOf(fileUploadFormRecordTypeId))) {
            for (SObject obj : (Trigger.new != null ? Trigger.new : Trigger.old)) {
               obj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage);
            }
            AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: File Upload Form Record Type Id not found');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_WorkbookStepTriggerHelper',
                                 'fileUploadStepValidation', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                                 null, null, null);
            return;
         }

         //Generate exception for test class execution to cover catch block
         if (Test.isRunningTest() && IsExceptionToCoverCatchBlock == true) Integer a = 1 / 0;
         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => Trigger.isUpdate: ' + Trigger.isUpdate);

         Set<Id> formIds = new Set<Id> ();
         for (SObject obj : (Trigger.new != null ? Trigger.new : Trigger.old)) {
            AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
            if (wbs.RecordTypeId == workbookStepRecordTypeId //Only check workbook step records
                && String.isNotBlank(String.valueOf(wbs.Form__c))) { //Only check those steps which are associated with for forms
               if (Trigger.isUpdate) {
                  AH_UDC_WorkbookStep__c objOldStep = (AH_UDC_WorkbookStep__c) Trigger.oldMap.get(wbs.Id);
                  //Evaluate only those those steps for which form field updated
                  if (wbs.Form__c != objOldStep.Form__c) formIds.add(wbs.Form__c);
               }
               else {
                  formIds.add(wbs.Form__c);
               }
            }
         }

         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => formIds: ' + formIds);
         //If there are no workbook step records associated with forms then no need to proceed further
         if (formIds.size() == 0) return;

         //Fetch only file upload forms from the records which are being inserted/updated/undeleted
         List<AH_UDC_Form__c> lstFileUploadForms = [SELECT Id
                                                    FROM AH_UDC_Form__c
                                                    WHERE Id IN :formIds
                                                    AND RecordTypeId = :fileUploadFormRecordTypeId];

         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => lstFileUploadForms: ' + lstFileUploadForms);
         //If there are no file upload steps then no need to proceed further
         if (lstFileUploadForms.size() == 0) return;

         Set<Id> workbookIds = new Set<Id> (); //Set of workbook ids which has steps with file upload forms
         Set<Id> workbookStepIds = new Set<Id> (); //Set of workbook step ids which are associated with file upload forms
         for (AH_UDC_Form__c objForm : lstFileUploadForms) {
            for (SObject obj : (Trigger.new != null ? Trigger.new : Trigger.old)) {
               AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
               if (wbs.Form__c == objForm.Id) { //Pick only file upload form steps
                  workbookStepIds.add(wbs.Id);
                  if (workbookIds.contains(wbs.Workbook__c)) {
                     //In case of bulk insert/update/undelete it has more than one file upload steps within a workbook
                     obj.addError(Label.AH_UDC_FileUploadTriggerError);
                  }
                  else {
                     workbookIds.add(wbs.Workbook__c);
                  }
                  break;
               }
            }
         }
         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => workbookStepIds: ' + workbookStepIds);
         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => workbookIds: ' + workbookIds);

         //Fetch file upload steps other than the steps which are being inserted/updated/undeleted
         List<AH_UDC_WorkbookStep__c> lstWorkbookSteps = [SELECT Workbook__c
                                                          FROM AH_UDC_WorkbookStep__c
                                                          WHERE Workbook__c IN :workbookIds
                                                          AND Id NOT IN :workbookStepIds
                                                          AND Form__r.RecordTypeId = :fileUploadFormRecordTypeId];

         AH_UDC_LogHelper.Debug('fileUploadStepValidation() => lstWorkbookSteps: ' + lstWorkbookSteps);
         //If there are no file upload steps other than the steps which are being inserted/updated/undeleted then no need to proceed further
         if (lstWorkbookSteps.size() == 0) return;

         for (AH_UDC_WorkbookStep__c objStep : lstWorkbookSteps) {
            for (SObject obj : (Trigger.new != null ? Trigger.new : Trigger.old)) {
               AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
               if (wbs.Workbook__c == objStep.Workbook__c && String.isNotBlank(String.valueOf(wbs.Form__c))
                   && lstFileUploadForms.contains(new AH_UDC_Form__c(Id = wbs.Form__c))) {
                  //Prevent insert/update/undelete of another file upload steps
                  obj.addError(Label.AH_UDC_FileUploadTriggerError);
                  break;
               }
            }
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'fileUploadStepValidation', 'An exception occurred during workbook step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook Step List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                              exc, null, null);
         // Mark all records as failed due to the unexpected exception that occurred
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage); // prevent upsert
         }
      }
   }

   private static void onBeforeInsertStep() {
      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();

      // Get a unique set of all Workbook Ids included in the trigger's record collection
      Set<Id> wbIds = new Set<Id> ();
      for (SObject obj : Trigger.new) {
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
         if (wbs.RecordTypeId == WorkbookStepRecordTypeId) {
            wbIds.add(wbs.workbook__c);
         }
      }

      // If there are no BEFORE INSERT records in the trigger record collection, then nothing to do
      if (wbIds.size() == 0) return;

      // Get current maximum SortOrder value for each Workbook included in the Workbook's Steps
      Map<Id, Integer> mapWbsMaxOrder = new Map<Id, Integer> ();
      List<AggregateResult> workbookMaxSteps = [SELECT Workbook__c, MAX(SortOrder__c) MaxSortOrder
                                                FROM AH_UDC_WorkbookStep__c
                                                WHERE Workbook__c in :wbIds
                                                GROUP BY Workbook__c];
      for (AggregateResult ar : workbookMaxSteps) {
         mapWbsMaxOrder.put(String.valueOf(ar.get('workbook__c')), Integer.valueOf(ar.get('MaxSortOrder')));
      }

      // Set SortOrder__c for Step being inserted to be one higher than the highest SortOrder__C
      for (SObject obj : Trigger.new) {
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;

         // If Workbook has no steps currently, set the starting sort order at 0
         if (!mapWbsMaxOrder.containsKey(wbs.Workbook__c)) {
            mapWbsMaxOrder.put(wbs.workbook__c, 0);
         }

         // Get the next highest numbered SortOrder__c value for this Workbook
         Integer iSortOrder = mapWbsMaxOrder.get(wbs.Workbook__c) + 1;

         wbs.SortOrder__c = iSortOrder;

         // Update the Map to have the new highest CortOrder__c value for this Workbook stored
         mapWbsMaxOrder.put(String.valueOf(wbs.workbook__c), iSortOrder);
      }

      // Store Workbook Steps workbook wise
      Map<Id, List<AH_UDC_WorkbookStep__c>> mapExistingSteps = new Map<Id, List<AH_UDC_WorkbookStep__c>> ();

      // Old already available workbookstep id with sort order to get prerequisite steps sortorder
      // to test based on workbooks selected to insert
      Map<Id, Decimal> mapWbsOrder = new Map<Id, Decimal> ();

      // Ensure that any Step that is being inserted, that has a Prerequisite Step, has a higher SortOrder__c than
      // the Prerequisite Step and check that this new Step doesn't have the same URL or Form as another existing Step
      for (AH_UDC_WorkbookStep__c wbsTemp :[SELECT Id, Name, URL__c, Form__c, SortOrder__c, Workbook__c
           FROM AH_UDC_WorkbookStep__c
           WHERE Workbook__c IN :wbIds
           ORDER BY Workbook__c, SortOrder__c]) {
         // If workbook steps are not in mapExistingSteps then add it for iterating through workbook
         if (mapExistingSteps.containsKey(wbsTemp.Workbook__c)) {
            mapExistingSteps.get(wbsTemp.Workbook__c).add(wbsTemp);
         } else {
            mapExistingSteps.put(wbsTemp.Workbook__c, new list<AH_UDC_WorkbookStep__c> { wbsTemp });
         }
         mapWbsOrder.put(wbsTemp.Id, wbsTemp.SortOrder__c);
      }

      // from newly inserted values to compare URL & Form
      for (SObject obj : Trigger.new) {
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
         if (wbs.Prerequisite_Step__c != null && wbs.SortOrder__c != null) {
            // Used mapWbsOrder.get(wbs.Prerequisite_Step__c)'s static value to test this scenario
            if (mapWbsOrder.get(wbs.Prerequisite_Step__c) > wbs.SortOrder__c) {
               obj.addError(Label.AH_UDC_WorkbookStepCreateWithPrerequisiteSortOrderTriggerValidationMessage);
            }
         }

         if (!mapExistingSteps.containsKey(wbs.Workbook__c)) continue;

         for (AH_UDC_WorkbookStep__c existingStep : mapExistingSteps.get(wbs.Workbook__c)) {
            // Ensure not using the same URL as another step
            if (wbs.URL__c != null && wbs.URL__c.equalsIgnoreCase(existingStep.URL__c)) {
               obj.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
               break;
            }

            // Ensure not using the same FORM as another step
            if (wbs.Form__c != null && existingStep.Form__c == wbs.Form__c) {
               obj.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
               break;
            }
         }
      }
   }

   private static void onBeforeUpdateStep()
   {
      try {
         AH_UDC_LogHelper.Debug('Inside onBeforeUpdateStep');
         Map<Id, Decimal> stepIdAndSortOrderMap = new Map<Id, Decimal> ();
         List<AH_UDC_WorkbookStep__c> stepsWithSortOrderChanged = new List<AH_UDC_WorkbookStep__c> ();
         List<AH_UDC_WorkbookStep__c> stepsWithFormOrURLChanged = new List<AH_UDC_WorkbookStep__c> ();
         Map<Id, List<AH_UDC_WorkbookStep__c>> workbookIdAndStepMap = new Map<Id, List<AH_UDC_WorkbookStep__c>> ();
         Set<Id> preReqStepIds = new Set<Id> ();
         Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookStepRecordTypeId: ' + workbookStepRecordTypeId);

         //Generate exception for test class execution
         if (Test.isRunningTest() && IsWorkbookRecordTypeException == true) workbookStepRecordTypeId = null;

         if (String.isBlank(String.valueOf(workbookStepRecordTypeId))) {
            for (SObject obj : Trigger.new) {
               obj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage);
            }
            AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: Workbook Step Record Type Id not found');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_WorkbookStepTriggerHelper',
                                 'onBeforeUpdateStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                                 null, null, null);
            return;
         }

         for (SObject obj : Trigger.new) {
            AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
            AH_UDC_WorkbookStep__c objOldStep = (AH_UDC_WorkbookStep__c) Trigger.oldMap.get(objStep.Id);
            if (objStep.RecordTypeId != workbookStepRecordTypeId //Evaluate only workbook step records
                || (objStep.SortOrder__c == objOldStep.SortOrder__c
                    && objStep.Enabled__c == objOldStep.Enabled__c
                    && objStep.URL__c == objOldStep.URL__c
                    && objStep.Form__c == objOldStep.Form__c)) {
               //Ignore step if record type is workbook step sent record
               //Ignore step if Sort Order, Enable, URL or Form field is not changed
               continue;
            }

            if (objStep.SortOrder__c != objOldStep.SortOrder__c
                || objStep.Enabled__c != objOldStep.Enabled__c) {
               stepsWithSortOrderChanged.add(objStep);
               stepIdAndSortOrderMap.put(objStep.Id, objStep.SortOrder__c);
               if (String.isNotBlank(String.valueOf(objStep.Prerequisite_Step__c)))
               preReqStepIds.add(objStep.Prerequisite_Step__c);
            }

            if (objStep.URL__c != objOldStep.URL__c || objStep.Form__c != objOldStep.Form__c) {
               stepsWithFormOrURLChanged.add(objStep);
               //Prepare a map of workbook id and it's steps
               if (workbookIdAndStepMap.containsKey(objStep.Workbook__c)) {
                  workbookIdAndStepMap.get(objStep.Workbook__c).add(objStep);
               }
               else {
                  workbookIdAndStepMap.put(objStep.Workbook__c, new List<AH_UDC_WorkbookStep__c> { objStep });
               }
            }
         }

         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => stepsWithSortOrderChanged:' + stepsWithSortOrderChanged);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => stepsWithFormOrURLChanged:' + stepsWithFormOrURLChanged);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => preReqStepIds:' + preReqStepIds);
         if (stepsWithSortOrderChanged.size() == 0 && stepsWithFormOrURLChanged.size() == 0)
         return;

         if (preReqStepIds.size() > 0) {
            //Get sort order of prerequisite steps to compare
            List<AH_UDC_WorkbookStep__c> lstPreReqSteps = [SELECT Id, SortOrder__c
                                                           FROM AH_UDC_WorkbookStep__c
                                                           WHERE Id IN :preReqStepIds];
            AH_UDC_LogHelper.Debug('onBeforeUpdateStep => lstPreReqSteps:' + lstPreReqSteps);
            Map<Id, Decimal> preReqStepOrderMap = new Map<Id, Decimal> ();
            for (AH_UDC_WorkbookStep__c item : lstPreReqSteps) {
               preReqStepOrderMap.put(item.Id, item.SortOrder__c);
            }

            AH_UDC_LogHelper.Debug('onBeforeUpdateStep => preReqStepOrderMap:' + preReqStepOrderMap);
            for (AH_UDC_WorkbookStep__c step : stepsWithSortOrderChanged) {
               //Ignore steps which don't have prerequisite step associated
               if (String.isBlank(String.valueOf(step.Prerequisite_Step__c))) continue;

               //Get sort order of prerequisite step
               //If prerequisite step is being updated then get sort order from the map otherwise get from the retrieved list
               Decimal preReqStepOrder = stepIdAndSortOrderMap.containsKey(step.Prerequisite_Step__c) ? stepIdAndSortOrderMap.get(step.Prerequisite_Step__c) : preReqStepOrderMap.get(step.Prerequisite_Step__c);
               if (step.SortOrder__c <= preReqStepOrder) { //Step is moving earlier than it's prerequisite step
                  for (SObject obj : Trigger.new) {
                     AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
                     if (objStep.Id == step.Id) {
                        //Prevent step being moved earlier than it's prerequisite step
                        obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message);
                        break;
                     }
                  }
               }
            }
         }

         //If updating steps are prerequisite of other steps then get details of those steps 
         List<AH_UDC_WorkbookStep__c> stepDetails = [SELECT Id, Prerequisite_Step__c, SortOrder__c
                                                     FROM AH_UDC_WorkbookStep__c
                                                     WHERE Prerequisite_Step__c IN :stepsWithSortOrderChanged];
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => stepDetails:' + stepDetails);
         for (AH_UDC_WorkbookStep__c item : stepDetails) {
            for (AH_UDC_WorkbookStep__c step : stepsWithSortOrderChanged) {
               if (item.Prerequisite_Step__c == step.Id) {
                  String errorMsg = '';
                  Decimal stepOrder = stepIdAndSortOrderMap.containsKey(item.Id) ? stepIdAndSortOrderMap.get(item.Id) : item.SortOrder__c;
                  if (step.SortOrder__c >= stepOrder) { //Step is moving after the step for which it is set as prerequisite
                     //Prevent step which is being moved after than the step for which it is set as a prerequisite step
                     errorMsg = Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message;
                  }
                  else if (step.Enabled__c == false) {
                     //Prevent disabling step which is prerequisite of another step
                     errorMsg = Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message;
                  }

                  if (String.isNotBlank(errorMsg)) {
                     for (SObject obj : Trigger.new) {
                        AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
                        if (objStep.Id == step.Id) {
                           obj.adderror(errorMsg);
                           break;
                        }
                     }
                  }
                  break;
               }
            }
         }

         Map<Id, Set<String>> workbookAndStepURLMap = new Map<Id, Set<String>> ();
         Map<Id, Set<Id>> workbookAndStepFormIdMap = new Map<Id, Set<Id>> ();
         //Get workbook step records other than the records which are being updated
         List<AH_UDC_WorkbookStep__c> lstSteps = [SELECT Id, Workbook__c, URL__c, Form__c
                                                  FROM AH_UDC_WorkbookStep__c
                                                  WHERE Workbook__c IN :workbookIdAndStepMap.keySet()
                                                  AND Id NOT IN :stepsWithFormOrURLChanged];
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => lstSteps:' + lstSteps);
         for (AH_UDC_WorkbookStep__c step : lstSteps) {
            if (String.isNotBlank(step.URL__c)) {
               if (workbookAndStepURLMap.containsKey(step.Workbook__c)) {
                  workbookAndStepURLMap.get(step.Workbook__c).add(step.URL__c.toLowerCase());
               }
               else {
                  workbookAndStepURLMap.put(step.Workbook__c, new Set<String> { step.URL__c.toLowerCase() });
               }
            }
            else if (String.isNotBlank(String.valueOf(step.Form__c))) {
               if (workbookAndStepFormIdMap.containsKey(step.Workbook__c)) {
                  workbookAndStepFormIdMap.get(step.Workbook__c).add(step.Form__c);
               }
               else {
                  workbookAndStepFormIdMap.put(step.Workbook__c, new Set<Id> { step.Form__c });
               }
            }
         }
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookAndStepURLMap:' + workbookAndStepURLMap);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookAndStepFormIdMap:' + workbookAndStepFormIdMap);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookIdAndStepMap:' + workbookIdAndStepMap);
         for (Id wbId : workbookIdAndStepMap.keySet()) {
            List<AH_UDC_WorkbookStep__c> lstWorkbookStep = workbookIdAndStepMap.get(wbId);
            Set<String> stepURLSet = new Set<String> ();
            Set<Id> formIdSet = new Set<Id> ();
            for (AH_UDC_WorkbookStep__c step : lstWorkbookStep) {
               String errorMsg = '';
               if (String.isNotBlank(step.URL__c) && String.isNotBlank(String.valueOf(step.Form__c))) {
                  //Ignore if both URL and Form are present in the step because it is already handling by validation rule
                  continue;
               }

               if (String.isNotBlank(step.URL__c)) {
                  if (stepURLSet.contains(step.URL__c.toLowerCase()) //Check within bulk insert records
                      //Check within records other than the records which are being updated
                      || (workbookAndStepURLMap.containsKey(step.Workbook__c) && workbookAndStepURLMap.get(step.Workbook__c).contains(step.URL__c.toLowerCase()))) {
                     errorMsg = Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage;
                  }
                  else {
                     stepURLSet.add(step.URL__c.toLowerCase());
                  }
               }
               else if (String.isNotBlank(String.valueOf(step.Form__c))) {
                  if (formIdSet.contains(step.Form__c) //Check within bulk insert records
                      //Check within records other than the records which are being updated
                      || (workbookAndStepFormIdMap.containsKey(step.Workbook__c) && workbookAndStepFormIdMap.get(step.Workbook__c).contains(step.Form__c))) {
                     errorMsg = Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage;
                  }
                  else {
                     formIdSet.add(step.Form__c);
                  }
               }

               if (String.isNotBlank(errorMsg)) {
                  for (SObject obj : Trigger.new) {
                     AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
                     if (objStep.Id == step.Id) {
                        obj.adderror(errorMsg);
                        break;
                     }
                  }
               }
            }
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onBeforeUpdateStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);
         throw exc;
      }
   }

   private static void onDeleteStep()
   {
      List<Id> lstPrerequisiteStep = null;
      try {
         SObject oldSObjectDelete = null;
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         AH_UDC_LogHelper.Debug('Config Setting Value (AH_UDC_PermissionSetUDCSystemAdministrator) : ' + UDCSystemAdminPermissionSetName);
         AH_UDC_LogHelper.Debug('Logged In User Name : ' + System.UserInfo.getUserName());
         Integer intCount = (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];
         Boolean isUdcSystemAdmin = intCount > 0;
         AH_UDC_LogHelper.Debug('intCount : ' + intCount);

         Id WorkbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
         if (Test.isRunningTest() && IsWorkbookSentRecordTypeForException == true) WorkbookStepSentRecordTypeId = null; // Check for record type id is null for testing

         if (String.isBlank(String.valueOf(WorkbookStepSentRecordTypeId))) {
            for (SObject obj : Trigger.old) {
               obj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage);
            }
            AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: Workbook Step Record Type Id not found');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_WorkbookStepTriggerHelper',
                                 'onDeleteStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                                 null, null, null);
            return;
         }

         Set<Id> delWBStepsIdSet = new Set<Id> ();
         Set<Id> delWBIdsSet = new Set<Id> ();
         for (SObject obj : Trigger.old)
         {
            AH_UDC_WorkbookStep__c objWBS = (AH_UDC_WorkbookStep__c) obj;
            if (objWBS.RecordTypeId == WorkbookStepSentRecordTypeId && !isUdcSystemAdmin)
            {
               // Prevent users other than UDC System Admin from deleting Workbook Step Sent record
               obj.addError(Label.AH_UDC_NoAccessRightsDelete);
               AH_UDC_LogHelper.Log('Trace', 'AH_UDC_WorkbookStepTriggerHelper', 'onTrigger', 'The user (' + System.UserInfo.getUserName() + ') is trying to delete WorkbookStep Sent record');
            }
            else
            {
               delWBStepsIdSet.add(objWBS.Id);
               delWBIdsSet.add(objWBS.workbook__c);
            }
         }

         Set<Id> setPrerequisiteStep = new Set<Id> (); //Set of all deleted step id with prerequisite step
         for (AH_UDC_WorkbookStep__c steps :[SELECT Prerequisite_Step__c
              FROM AH_UDC_WorkbookStep__c
              WHERE Workbook__c In :delWBIdsSet]) {
            setPrerequisiteStep.add(steps.Prerequisite_Step__c);
         }

         for (SObject obj : Trigger.old)
         {
            AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
            if (setPrerequisiteStep.contains(wbs.Id)) {
               obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message);
               delWBStepsIdSet.remove(wbs.Id);
            }
         }

         // Get all the remaining workbook steps that are not being deleted
         List<AH_UDC_WorkbookStep__c> lstUpdatedSortOrder = new List<AH_UDC_WorkbookStep__c> ();

         // Set the sort order for all remaining records
         for (AH_UDC_Workbook__c wb :[SELECT Id, (SELECT Id, SortOrder__c FROM Workbook_Steps__r
                                                  WHERE Id Not In :delWBStepsIdSet //RecordTypeId = :workbookStepSentRecordTypeId AND 
                                                  ORDER BY SortOrder__c) FROM AH_UDC_Workbook__c WHERE Id In :delWBIdsSet])
         {
            Integer count = 0;
            for (AH_UDC_WorkbookStep__c steps : wb.Workbook_Steps__r) {
               steps.SortOrder__c =++ count;
               lstUpdatedSortOrder.add(steps);
            }
         }

         if (lstUpdatedSortOrder.size() > 0) {
            AH_UDC_SystemContext.UpdateObjects(lstUpdatedSortOrder);
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onDeleteStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.old,
                              exc, null, null);
         throw exc;
      }
   }

   private static void onUndeleteStep()
   {
      Map<Id, List<String>> updatedStepUrlFormMap = null; //undeleted step URL list to compare
      Set<Id> undelWBStepIdsSet = null; // hold unique undeleted workbook step id list
      Set<Id> undelWBIdsSet = null; // hold unique undeleted workbook id list
      try {
         undelWBIdsSet = new Set<Id> ();
         undelWBStepIdsSet = new Set<Id> ();
         updatedStepUrlFormMap = new Map<ID, List<String>> ();
         List<String> lstDuplicateCheck = new List<String> ();
         Map<Id, list<AH_UDC_WorkbookStep__c>> undelWorkbookAndStepMap = new Map<Id, list<AH_UDC_WorkbookStep__c>> ();

         //Check for duplicate url/form in Trigger.new
         for (AH_UDC_WorkbookStep__c undeletedWorkbookStep : (List<AH_UDC_WorkbookStep__c>) Trigger.New)
         {
            undelWBStepIdsSet.add(undeletedWorkbookStep.Id);
            undelWBIdsSet.add(undeletedWorkbookStep.Workbook__c);
            //add updated workbook step its workbook wise 
            if (undelWorkbookAndStepMap.containsKey(undeletedWorkbookStep.Workbook__c))
            {
               undelWorkbookAndStepMap.get(undeletedWorkbookStep.Workbook__c).add(undeletedWorkbookStep);
            }
            else
            {
               undelWorkbookAndStepMap.put(undeletedWorkbookStep.Workbook__c, new list<AH_UDC_WorkbookStep__c> { undeletedWorkbookStep });
            }
         }

         //Check new map has duplicate Url or Form, if it does, then add error for that step
         for (Id wb : undelWorkbookAndStepMap.keySet())
         {
            List<AH_UDC_WorkbookStep__c> workbookStepCompare = undelWorkbookAndStepMap.get(wb);
            List<String> lstURLForm = new List<String> (); //store url or form details
            for (AH_UDC_WorkbookStep__c wbStep : workbookStepCompare)
            {
               if (lstURLForm.contains(wbStep.URL__c) || lstURLForm.contains(wbStep.Form__c))
               {
                  wbStep.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
                  undelWBStepIdsSet.remove(wbStep.Id);
                  break;
               }
               else {
                  if (String.isNotBlank(wbStep.URL__c)) {
                     lstURLForm.add(wbStep.URL__c);
                  }
                  if (wbStep.Form__c != null) {
                     lstURLForm.add(wbStep.Form__c);
                  }
               }
            }
            lstURLForm.clear();
         }


         //Retrive and add all the Url and Form workbook wise in the Map from database
         List<AH_UDC_WorkbookStep__c> workbookStepDetails = [SELECT Id, Enabled__c, SortOrder__c, Prerequisite_Step__c, URL__c, Form__c, Workbook__c
                                                             FROM AH_UDC_WorkbookStep__c
                                                             WHERE IsDeleted = false AND Workbook__c IN :undelWBIdsSet AND Id NOT IN :undelWBStepIdsSet];

         for (AH_UDC_WorkbookStep__c item : workbookStepDetails)
         {
            if (updatedStepUrlFormMap.containsKey(item.Workbook__c))
            {
               if (Item.URL__c != null) {
                  updatedStepUrlFormMap.get(item.Workbook__c).add(item.URL__c.toLowerCase());
               }
               else if (Item.Form__c != null) {
                  updatedStepUrlFormMap.get(item.Workbook__c).add(item.Form__c);
               }
            }
            else
            {
               if (Item.URL__c != null) {
                  updatedStepUrlFormMap.put(item.Workbook__c, new list<String> { item.URL__c.toLowerCase() });
               }
               else if (Item.Form__c != null) {
                  updatedStepUrlFormMap.put(item.Workbook__c, new list<String> { item.Form__c });
               }
            }
         }
         //get max sortorder workbook wise so we can set undleted value at the end of current workbook step
         Map<Id, Integer> workbookMaxStepSortOrderMap = new Map<Id, Integer> ();
         for (AggregateResult ar :[SELECT Workbook__c, MAX(SortOrder__c) MaxSortOrder
              FROM AH_UDC_WorkbookStep__c
              WHERE IsDeleted = false AND Workbook__c IN :undelWBIdsSet
              AND Id NOT IN :undelWBStepIdsSet
              GROUP BY Workbook__c])
         {
            workbookMaxStepSortOrderMap.put((Id) ar.get('Workbook__c'), Integer.valueOf(ar.get('MaxSortOrder')));
         }
         

         List<AH_UDC_WorkbookStep__c> lstStepToUpdate = new List<AH_UDC_WorkbookStep__c> ();
         for (SObject sobj : Trigger.new) {
            AH_UDC_WorkbookStep__c undeletedWorkbookStep = (AH_UDC_WorkbookStep__c) sobj;
            if (!undeletedWorkbookStep.hasErrors())       
            {
               if (updatedStepUrlFormMap.get(undeletedWorkbookStep.Workbook__c) != null)
               {
                  List<String> lstUrlForm = updatedStepUrlFormMap.get(undeletedWorkbookStep.Workbook__c);
                  if (undeletedWorkbookStep.URL__c != null && undeletedWorkbookStep.Form__c == null && lstUrlForm.contains(undeletedWorkbookStep.URL__c.toLowerCase()))
                  {
                     undeletedWorkbookStep.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
                     undelWBStepIdsSet.remove(undeletedWorkbookStep.Id);

                  }
                  if (undeletedWorkbookStep.Form__c != null && undeletedWorkbookStep.URL__c == null && lstUrlForm.contains((String) undeletedWorkbookStep.Form__c))
                  {
                     sobj.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
                     undelWBStepIdsSet.remove(undeletedWorkbookStep.Id);

                  }
               }
            }
         }
         List<AH_UDC_WorkbookStep__c> lstUpdatedSortOrder = new List<AH_UDC_WorkbookStep__c> ();
         // Set the sort order for all remaining records without error
         for (AH_UDC_Workbook__c wb :[SELECT Id, (SELECT Id, Prerequisite_Step__c, SortOrder__c FROM Workbook_Steps__r
                                                  WHERE Id In :undelWBStepIdsSet
                                                  ORDER BY SortOrder__c) FROM AH_UDC_Workbook__c WHERE Id In :undelWBIdsSet])
         {
            Integer count = 0;
            if (workbookMaxStepSortOrderMap.containsKey(wb.Id))
            {
               count = workbookMaxStepSortOrderMap.get(wb.Id);
            }
            for (AH_UDC_WorkbookStep__c steps : wb.Workbook_Steps__r) {
               steps.SortOrder__c =++ count;
               steps.Prerequisite_Step__c = null;
               lstUpdatedSortOrder.add(steps);
            }
         }

         if (lstUpdatedSortOrder.size() > 0) {
            AH_UDC_SystemContext.UpdateObjects(lstUpdatedSortOrder);
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onUndeleteStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);
         throw exc;
      }
   }
=======
/**
 * Name          : AH_UDC_WorkbookStepTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_WorkbookStep
 * Dependencies  : 
 **/

public with sharing class AH_UDC_WorkbookStepTriggerHelper {
   @TestVisible public static Boolean IsWorkbookSentRecordTypeForException = false;
   @TestVisible public static Boolean IsWorkbookRecordTypeException = false;
   @TestVisible public static Boolean IsFormRecordTypeException = false;
   @TestVisible public static Boolean IsExceptionToCoverCatchBlock = false;

   public static void onTrigger() {
      List<Id> lstPrerequisiteStep = null;
      Exception ex = null;
      Boolean isAnyExceptionOccurred = false;
      try {
         if (Test.isRunningTest() && Trigger.new != null && Trigger.new.size() > 0 && ((AH_UDC_WorkbookStep__c) Trigger.new[0]).name == 'TestException') integer i = 1 / 0;

         if (Trigger.isBefore && (Trigger.isInsert)) {
            onBeforeInsertStep();
            return;
         }

         if (Trigger.isBefore && (Trigger.isUpdate)) {
            onBeforeUpdateStep();
            return;
         }

         if (Trigger.isBefore && (Trigger.isDelete))
         {
            onDeleteStep();
            return;
         }

         if (Trigger.isAfter && (Trigger.isUndelete))
         {
            onUndeleteStep();
            return;
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onTrigger', 'An exception occurred during workbook step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);

         // Mark all records as failed due to the unexpected exception that occurred
         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            sObj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage); // prevent upsert
         }
      }
   }

   private static void onBeforeInsertStep() {
      Id WorkbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();

      // Get a unique set of all Workbook Ids included in the trigger's record collection
      Set<Id> wbIds = new Set<Id> ();
      for (SObject obj : Trigger.new) {
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
         if (wbs.RecordTypeId == WorkbookStepRecordTypeId) {
            wbIds.add(wbs.workbook__c);
         }
      }

      // If there are no BEFORE INSERT records in the trigger record collection, then nothing to do
      if (wbIds.size() == 0) return;

      // Get current maximum SortOrder value for each Workbook included in the Workbook's Steps
      Map<Id, Integer> mapWbsMaxOrder = new Map<Id, Integer> ();
      List<AggregateResult> workbookMaxSteps = [SELECT Workbook__c, MAX(SortOrder__c) MaxSortOrder
                                                FROM AH_UDC_WorkbookStep__c
                                                WHERE Workbook__c in :wbIds
                                                GROUP BY Workbook__c];
      for (AggregateResult ar : workbookMaxSteps) {
         mapWbsMaxOrder.put(String.valueOf(ar.get('workbook__c')), Integer.valueOf(ar.get('MaxSortOrder')));
      }

      // Set SortOrder__c for Step being inserted to be one higher than the highest SortOrder__C
      for (SObject obj : Trigger.new) {
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;

         // If Workbook has no steps currently, set the starting sort order at 0
         if (!mapWbsMaxOrder.containsKey(wbs.Workbook__c)) {
            mapWbsMaxOrder.put(wbs.workbook__c, 0);
         }

         // Get the next highest numbered SortOrder__c value for this Workbook
         Integer iSortOrder = mapWbsMaxOrder.get(wbs.Workbook__c) + 1;

         wbs.SortOrder__c = iSortOrder;

         // Update the Map to have the new highest CortOrder__c value for this Workbook stored
         mapWbsMaxOrder.put(String.valueOf(wbs.workbook__c), iSortOrder);
      }

      // Store Workbook Steps workbook wise
      Map<Id, List<AH_UDC_WorkbookStep__c>> mapExistingSteps = new Map<Id, List<AH_UDC_WorkbookStep__c>> ();

      // Old already available workbookstep id with sort order to get prerequisite steps sortorder
      // to test based on workbooks selected to insert
      Map<Id, Decimal> mapWbsOrder = new Map<Id, Decimal> ();

      // Ensure that any Step that is being inserted, that has a Prerequisite Step, has a higher SortOrder__c than
      // the Prerequisite Step and check that this new Step doesn't have the same URL or Form as another existing Step
      for (AH_UDC_WorkbookStep__c wbsTemp :[SELECT Id, Name, URL__c, Form__c, SortOrder__c, Workbook__c
           FROM AH_UDC_WorkbookStep__c
           WHERE Workbook__c IN :wbIds
           ORDER BY Workbook__c, SortOrder__c]) {
         // If workbook steps are not in mapExistingSteps then add it for iterating through workbook
         if (mapExistingSteps.containsKey(wbsTemp.Workbook__c)) {
            mapExistingSteps.get(wbsTemp.Workbook__c).add(wbsTemp);
         } else {
            mapExistingSteps.put(wbsTemp.Workbook__c, new list<AH_UDC_WorkbookStep__c> { wbsTemp });
         }
         mapWbsOrder.put(wbsTemp.Id, wbsTemp.SortOrder__c);
      }

      // from newly inserted values to compare URL & Form
      for (SObject obj : Trigger.new) {
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
         if (wbs.Prerequisite_Step__c != null && wbs.SortOrder__c != null) {
            // Used mapWbsOrder.get(wbs.Prerequisite_Step__c)'s static value to test this scenario
            if (mapWbsOrder.get(wbs.Prerequisite_Step__c) > wbs.SortOrder__c) {
               obj.addError(Label.AH_UDC_WorkbookStepCreateWithPrerequisiteSortOrderTriggerValidationMessage);
            }
         }

         if (!mapExistingSteps.containsKey(wbs.Workbook__c)) continue;

         for (AH_UDC_WorkbookStep__c existingStep : mapExistingSteps.get(wbs.Workbook__c)) {
            // Ensure not using the same URL as another step
            if (wbs.URL__c != null && wbs.URL__c.equalsIgnoreCase(existingStep.URL__c)) {
               obj.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
               break;
            }

            // Ensure not using the same FORM as another step
            if (wbs.Form__c != null && existingStep.Form__c == wbs.Form__c) {
               obj.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
               break;
            }
         }
      }
   }

   private static void onBeforeUpdateStep()
   {
      try {
         AH_UDC_LogHelper.Debug('Inside onBeforeUpdateStep');
         Map<Id, Decimal> stepIdAndSortOrderMap = new Map<Id, Decimal> ();
         List<AH_UDC_WorkbookStep__c> stepsWithSortOrderChanged = new List<AH_UDC_WorkbookStep__c> ();
         List<AH_UDC_WorkbookStep__c> stepsWithFormOrURLChanged = new List<AH_UDC_WorkbookStep__c> ();
         Map<Id, List<AH_UDC_WorkbookStep__c>> workbookIdAndStepMap = new Map<Id, List<AH_UDC_WorkbookStep__c>> ();
         Set<Id> preReqStepIds = new Set<Id> ();
         Id workbookStepRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP).getRecordTypeId();
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookStepRecordTypeId: ' + workbookStepRecordTypeId);

         //Generate exception for test class execution
         if (Test.isRunningTest() && IsWorkbookRecordTypeException == true) workbookStepRecordTypeId = null;

         if (String.isBlank(String.valueOf(workbookStepRecordTypeId))) {
            for (SObject obj : Trigger.new) {
               obj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage);
            }
            AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: Workbook Step Record Type Id not found');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_WorkbookStepTriggerHelper',
                                 'onBeforeUpdateStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                                 null, null, null);
            return;
         }

         for (SObject obj : Trigger.new) {
            AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
            AH_UDC_WorkbookStep__c objOldStep = (AH_UDC_WorkbookStep__c) Trigger.oldMap.get(objStep.Id);
            if (objStep.RecordTypeId != workbookStepRecordTypeId //Evaluate only workbook step records
                || (objStep.SortOrder__c == objOldStep.SortOrder__c
                    && objStep.Enabled__c == objOldStep.Enabled__c
                    && objStep.URL__c == objOldStep.URL__c
                    && objStep.Form__c == objOldStep.Form__c)) {
               //Ignore step if record type is workbook step sent record
               //Ignore step if Sort Order, Enable, URL or Form field is not changed
               continue;
            }

            if (objStep.SortOrder__c != objOldStep.SortOrder__c
                || objStep.Enabled__c != objOldStep.Enabled__c) {
               stepsWithSortOrderChanged.add(objStep);
               stepIdAndSortOrderMap.put(objStep.Id, objStep.SortOrder__c);
               if (String.isNotBlank(String.valueOf(objStep.Prerequisite_Step__c)))
               preReqStepIds.add(objStep.Prerequisite_Step__c);
            }

            if (objStep.URL__c != objOldStep.URL__c || objStep.Form__c != objOldStep.Form__c) {
               stepsWithFormOrURLChanged.add(objStep);
               //Prepare a map of workbook id and it's steps
               if (workbookIdAndStepMap.containsKey(objStep.Workbook__c)) {
                  workbookIdAndStepMap.get(objStep.Workbook__c).add(objStep);
               }
               else {
                  workbookIdAndStepMap.put(objStep.Workbook__c, new List<AH_UDC_WorkbookStep__c> { objStep });
               }
            }
         }

         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => stepsWithSortOrderChanged:' + stepsWithSortOrderChanged);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => stepsWithFormOrURLChanged:' + stepsWithFormOrURLChanged);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => preReqStepIds:' + preReqStepIds);
         if (stepsWithSortOrderChanged.size() == 0 && stepsWithFormOrURLChanged.size() == 0)
         return;

         if (preReqStepIds.size() > 0) {
            //Get sort order of prerequisite steps to compare
            List<AH_UDC_WorkbookStep__c> lstPreReqSteps = [SELECT Id, SortOrder__c
                                                           FROM AH_UDC_WorkbookStep__c
                                                           WHERE Id IN :preReqStepIds];
            AH_UDC_LogHelper.Debug('onBeforeUpdateStep => lstPreReqSteps:' + lstPreReqSteps);
            Map<Id, Decimal> preReqStepOrderMap = new Map<Id, Decimal> ();
            for (AH_UDC_WorkbookStep__c item : lstPreReqSteps) {
               preReqStepOrderMap.put(item.Id, item.SortOrder__c);
            }

            AH_UDC_LogHelper.Debug('onBeforeUpdateStep => preReqStepOrderMap:' + preReqStepOrderMap);
            for (AH_UDC_WorkbookStep__c step : stepsWithSortOrderChanged) {
               //Ignore steps which don't have prerequisite step associated
               if (String.isBlank(String.valueOf(step.Prerequisite_Step__c))) continue;

               //Get sort order of prerequisite step
               //If prerequisite step is being updated then get sort order from the map otherwise get from the retrieved list
               Decimal preReqStepOrder = stepIdAndSortOrderMap.containsKey(step.Prerequisite_Step__c) ? stepIdAndSortOrderMap.get(step.Prerequisite_Step__c) : preReqStepOrderMap.get(step.Prerequisite_Step__c);
               if (step.SortOrder__c <= preReqStepOrder) { //Step is moving earlier than it's prerequisite step
                  for (SObject obj : Trigger.new) {
                     AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
                     if (objStep.Id == step.Id) {
                        //Prevent step being moved earlier than it's prerequisite step
                        obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message);
                        break;
                     }
                  }
               }
            }
         }

         //If updating steps are prerequisite of other steps then get details of those steps 
         List<AH_UDC_WorkbookStep__c> stepDetails = [SELECT Id, Prerequisite_Step__c, SortOrder__c
                                                     FROM AH_UDC_WorkbookStep__c
                                                     WHERE Prerequisite_Step__c IN :stepsWithSortOrderChanged];
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => stepDetails:' + stepDetails);
         for (AH_UDC_WorkbookStep__c item : stepDetails) {
            for (AH_UDC_WorkbookStep__c step : stepsWithSortOrderChanged) {
               if (item.Prerequisite_Step__c == step.Id) {
                  String errorMsg = '';
                  Decimal stepOrder = stepIdAndSortOrderMap.containsKey(item.Id) ? stepIdAndSortOrderMap.get(item.Id) : item.SortOrder__c;
                  if (step.SortOrder__c >= stepOrder) { //Step is moving after the step for which it is set as prerequisite
                     //Prevent step which is being moved after than the step for which it is set as a prerequisite step
                     errorMsg = Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message;
                  }
                  else if (step.Enabled__c == false) {
                     //Prevent disabling step which is prerequisite of another step
                     errorMsg = Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message;
                  }

                  if (String.isNotBlank(errorMsg)) {
                     for (SObject obj : Trigger.new) {
                        AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
                        if (objStep.Id == step.Id) {
                           obj.adderror(errorMsg);
                           break;
                        }
                     }
                  }
                  break;
               }
            }
         }

         Map<Id, Set<String>> workbookAndStepURLMap = new Map<Id, Set<String>> ();
         Map<Id, Set<Id>> workbookAndStepFormIdMap = new Map<Id, Set<Id>> ();
         //Get workbook step records other than the records which are being updated
         List<AH_UDC_WorkbookStep__c> lstSteps = [SELECT Id, Workbook__c, URL__c, Form__c
                                                  FROM AH_UDC_WorkbookStep__c
                                                  WHERE Workbook__c IN :workbookIdAndStepMap.keySet()
                                                  AND Id NOT IN :stepsWithFormOrURLChanged];
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => lstSteps:' + lstSteps);
         for (AH_UDC_WorkbookStep__c step : lstSteps) {
            if (String.isNotBlank(step.URL__c)) {
               if (workbookAndStepURLMap.containsKey(step.Workbook__c)) {
                  workbookAndStepURLMap.get(step.Workbook__c).add(step.URL__c.toLowerCase());
               }
               else {
                  workbookAndStepURLMap.put(step.Workbook__c, new Set<String> { step.URL__c.toLowerCase() });
               }
            }
            else if (String.isNotBlank(String.valueOf(step.Form__c))) {
               if (workbookAndStepFormIdMap.containsKey(step.Workbook__c)) {
                  workbookAndStepFormIdMap.get(step.Workbook__c).add(step.Form__c);
               }
               else {
                  workbookAndStepFormIdMap.put(step.Workbook__c, new Set<Id> { step.Form__c });
               }
            }
         }
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookAndStepURLMap:' + workbookAndStepURLMap);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookAndStepFormIdMap:' + workbookAndStepFormIdMap);
         AH_UDC_LogHelper.Debug('onBeforeUpdateStep => workbookIdAndStepMap:' + workbookIdAndStepMap);
         for (Id wbId : workbookIdAndStepMap.keySet()) {
            List<AH_UDC_WorkbookStep__c> lstWorkbookStep = workbookIdAndStepMap.get(wbId);
            Set<String> stepURLSet = new Set<String> ();
            Set<Id> formIdSet = new Set<Id> ();
            for (AH_UDC_WorkbookStep__c step : lstWorkbookStep) {
               String errorMsg = '';
               if (String.isNotBlank(step.URL__c) && String.isNotBlank(String.valueOf(step.Form__c))) {
                  //Ignore if both URL and Form are present in the step because it is already handling by validation rule
                  continue;
               }

               if (String.isNotBlank(step.URL__c)) {
                  if (stepURLSet.contains(step.URL__c.toLowerCase()) //Check within bulk insert records
                      //Check within records other than the records which are being updated
                      || (workbookAndStepURLMap.containsKey(step.Workbook__c) && workbookAndStepURLMap.get(step.Workbook__c).contains(step.URL__c.toLowerCase()))) {
                     errorMsg = Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage;
                  }
                  else {
                     stepURLSet.add(step.URL__c.toLowerCase());
                  }
               }
               else if (String.isNotBlank(String.valueOf(step.Form__c))) {
                  if (formIdSet.contains(step.Form__c) //Check within bulk insert records
                      //Check within records other than the records which are being updated
                      || (workbookAndStepFormIdMap.containsKey(step.Workbook__c) && workbookAndStepFormIdMap.get(step.Workbook__c).contains(step.Form__c))) {
                     errorMsg = Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage;
                  }
                  else {
                     formIdSet.add(step.Form__c);
                  }
               }

               if (String.isNotBlank(errorMsg)) {
                  for (SObject obj : Trigger.new) {
                     AH_UDC_WorkbookStep__c objStep = (AH_UDC_WorkbookStep__c) obj;
                     if (objStep.Id == step.Id) {
                        obj.adderror(errorMsg);
                        break;
                     }
                  }
               }
            }
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onBeforeUpdateStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);
         throw exc;
      }
   }

   private static void onDeleteStep()
   {
      List<Id> lstPrerequisiteStep = null;
      try {
         SObject oldSObjectDelete = null;
         String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
         AH_UDC_LogHelper.Debug('Config Setting Value (AH_UDC_PermissionSetUDCSystemAdministrator) : ' + UDCSystemAdminPermissionSetName);
         AH_UDC_LogHelper.Debug('Logged In User Name : ' + System.UserInfo.getUserName());
         Integer intCount = (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];
         Boolean isUdcSystemAdmin = intCount > 0;
         AH_UDC_LogHelper.Debug('intCount : ' + intCount);

         Id WorkbookStepSentRecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
         if (Test.isRunningTest() && IsWorkbookSentRecordTypeForException == true) WorkbookStepSentRecordTypeId = null; // Check for record type id is null for testing

         if (String.isBlank(String.valueOf(WorkbookStepSentRecordTypeId))) {
            for (SObject obj : Trigger.old) {
               obj.addError(Label.AH_UDC_WorkbookStepTriggerExceptionMessage);
            }
            AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: Workbook Step Record Type Id not found');
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                                 'AH_UDC_WorkbookStepTriggerHelper',
                                 'onDeleteStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + (Trigger.new != null ? Trigger.new : Trigger.old),
                                 null, null, null);
            return;
         }

         Set<Id> delWBStepsIdSet = new Set<Id> ();
         Set<Id> delWBIdsSet = new Set<Id> ();
         for (SObject obj : Trigger.old)
         {
            AH_UDC_WorkbookStep__c objWBS = (AH_UDC_WorkbookStep__c) obj;
            if (objWBS.RecordTypeId == WorkbookStepSentRecordTypeId && !isUdcSystemAdmin)
            {
               // Prevent users other than UDC System Admin from deleting Workbook Step Sent record
               obj.addError(Label.AH_UDC_NoAccessRightsDelete);
               AH_UDC_LogHelper.Log('Trace', 'AH_UDC_WorkbookStepTriggerHelper', 'onTrigger', 'The user (' + System.UserInfo.getUserName() + ') is trying to delete WorkbookStep Sent record');
            }
            else
            {
               delWBStepsIdSet.add(objWBS.Id);
               delWBIdsSet.add(objWBS.workbook__c);
            }
         }

         Set<Id> setPrerequisiteStep = new Set<Id> (); //Set of all deleted step id with prerequisite step
         for (AH_UDC_WorkbookStep__c steps :[SELECT Prerequisite_Step__c
              FROM AH_UDC_WorkbookStep__c
              WHERE Workbook__c In :delWBIdsSet]) {
            setPrerequisiteStep.add(steps.Prerequisite_Step__c);
         }

         for (SObject obj : Trigger.old)
         {
            AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
            if (setPrerequisiteStep.contains(wbs.Id)) {
               obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message);
               delWBStepsIdSet.remove(wbs.Id);
            }
         }

         // Get all the remaining workbook steps that are not being deleted
         List<AH_UDC_WorkbookStep__c> lstUpdatedSortOrder = new List<AH_UDC_WorkbookStep__c> ();

         // Set the sort order for all remaining records
         for (AH_UDC_Workbook__c wb :[SELECT Id, (SELECT Id, SortOrder__c FROM Workbook_Steps__r
                                                  WHERE Id Not In :delWBStepsIdSet //RecordTypeId = :workbookStepSentRecordTypeId AND 
                                                  ORDER BY SortOrder__c) FROM AH_UDC_Workbook__c WHERE Id In :delWBIdsSet])
         {
            Integer count = 0;
            for (AH_UDC_WorkbookStep__c steps : wb.Workbook_Steps__r) {
               steps.SortOrder__c =++ count;
               lstUpdatedSortOrder.add(steps);
            }
         }

         if (lstUpdatedSortOrder.size() > 0) {
            AH_UDC_SystemContext.UpdateObjects(lstUpdatedSortOrder);
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onDeleteStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.old,
                              exc, null, null);
         throw exc;
      }
   }

   private static void onUndeleteStep()
   {
      Map<Id, List<String>> updatedStepUrlFormMap = null; //undeleted step URL list to compare
      Set<Id> undelWBStepIdsSet = null; // hold unique undeleted workbook step id list
      Set<Id> undelWBIdsSet = null; // hold unique undeleted workbook id list
      try {
         undelWBIdsSet = new Set<Id> ();
         undelWBStepIdsSet = new Set<Id> ();
         updatedStepUrlFormMap = new Map<ID, List<String>> ();
         List<String> lstDuplicateCheck = new List<String> ();
         Map<Id, list<AH_UDC_WorkbookStep__c>> undelWorkbookAndStepMap = new Map<Id, list<AH_UDC_WorkbookStep__c>> ();

         //Check for duplicate url/form in Trigger.new
         for (AH_UDC_WorkbookStep__c undeletedWorkbookStep : (List<AH_UDC_WorkbookStep__c>) Trigger.New)
         {
            undelWBStepIdsSet.add(undeletedWorkbookStep.Id);
            undelWBIdsSet.add(undeletedWorkbookStep.Workbook__c);
            //add updated workbook step its workbook wise 
            if (undelWorkbookAndStepMap.containsKey(undeletedWorkbookStep.Workbook__c))
            {
               undelWorkbookAndStepMap.get(undeletedWorkbookStep.Workbook__c).add(undeletedWorkbookStep);
            }
            else
            {
               undelWorkbookAndStepMap.put(undeletedWorkbookStep.Workbook__c, new list<AH_UDC_WorkbookStep__c> { undeletedWorkbookStep });
            }
         }

         //Check new map has duplicate Url or Form, if it does, then add error for that step
         for (Id wb : undelWorkbookAndStepMap.keySet())
         {
            List<AH_UDC_WorkbookStep__c> workbookStepCompare = undelWorkbookAndStepMap.get(wb);
            List<String> lstURLForm = new List<String> (); //store url or form details
            for (AH_UDC_WorkbookStep__c wbStep : workbookStepCompare)
            {
               if (lstURLForm.contains(wbStep.URL__c) || lstURLForm.contains(wbStep.Form__c))
               {
                  wbStep.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
                  undelWBStepIdsSet.remove(wbStep.Id);
                  break;
               }
               else {
                  if (String.isNotBlank(wbStep.URL__c)) {
                     lstURLForm.add(wbStep.URL__c);
                  }
                  if (wbStep.Form__c != null) {
                     lstURLForm.add(wbStep.Form__c);
                  }
               }
            }
            lstURLForm.clear();
         }


         //Retrive and add all the Url and Form workbook wise in the Map from database
         List<AH_UDC_WorkbookStep__c> workbookStepDetails = [SELECT Id, Enabled__c, SortOrder__c, Prerequisite_Step__c, URL__c, Form__c, Workbook__c
                                                             FROM AH_UDC_WorkbookStep__c
                                                             WHERE IsDeleted = false AND Workbook__c IN :undelWBIdsSet AND Id NOT IN :undelWBStepIdsSet];

         for (AH_UDC_WorkbookStep__c item : workbookStepDetails)
         {
            if (updatedStepUrlFormMap.containsKey(item.Workbook__c))
            {
               if (Item.URL__c != null) {
                  updatedStepUrlFormMap.get(item.Workbook__c).add(item.URL__c.toLowerCase());
               }
               else if (Item.Form__c != null) {
                  updatedStepUrlFormMap.get(item.Workbook__c).add(item.Form__c);
               }
            }
            else
            {
               if (Item.URL__c != null) {
                  updatedStepUrlFormMap.put(item.Workbook__c, new list<String> { item.URL__c.toLowerCase() });
               }
               else if (Item.Form__c != null) {
                  updatedStepUrlFormMap.put(item.Workbook__c, new list<String> { item.Form__c });
               }
            }
         }
         //get max sortorder workbook wise so we can set undleted value at the end of current workbook step
         Map<Id, Integer> workbookMaxStepSortOrderMap = new Map<Id, Integer> ();
         for (AggregateResult ar :[SELECT Workbook__c, MAX(SortOrder__c) MaxSortOrder
              FROM AH_UDC_WorkbookStep__c
              WHERE IsDeleted = false AND Workbook__c IN :undelWBIdsSet
              AND Id NOT IN :undelWBStepIdsSet
              GROUP BY Workbook__c])
         {
            workbookMaxStepSortOrderMap.put((Id) ar.get('Workbook__c'), Integer.valueOf(ar.get('MaxSortOrder')));
         }
         

         List<AH_UDC_WorkbookStep__c> lstStepToUpdate = new List<AH_UDC_WorkbookStep__c> ();
         for (SObject sobj : Trigger.new) {
            AH_UDC_WorkbookStep__c undeletedWorkbookStep = (AH_UDC_WorkbookStep__c) sobj;
            if (!undeletedWorkbookStep.hasErrors())       
            {
               if (updatedStepUrlFormMap.get(undeletedWorkbookStep.Workbook__c) != null)
               {
                  List<String> lstUrlForm = updatedStepUrlFormMap.get(undeletedWorkbookStep.Workbook__c);
                  if (undeletedWorkbookStep.URL__c != null && undeletedWorkbookStep.Form__c == null && lstUrlForm.contains(undeletedWorkbookStep.URL__c.toLowerCase()))
                  {
                     undeletedWorkbookStep.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
                     undelWBStepIdsSet.remove(undeletedWorkbookStep.Id);

                  }
                  if (undeletedWorkbookStep.Form__c != null && undeletedWorkbookStep.URL__c == null && lstUrlForm.contains((String) undeletedWorkbookStep.Form__c))
                  {
                     sobj.addError(Label.AH_UDC_WorkbookStepCreateDuplicateFormOrURLTriggerValidationMessage);
                     undelWBStepIdsSet.remove(undeletedWorkbookStep.Id);

                  }
               }
            }
         }
         List<AH_UDC_WorkbookStep__c> lstUpdatedSortOrder = new List<AH_UDC_WorkbookStep__c> ();
         // Set the sort order for all remaining records without error
         for (AH_UDC_Workbook__c wb :[SELECT Id, (SELECT Id, Prerequisite_Step__c, SortOrder__c FROM Workbook_Steps__r
                                                  WHERE Id In :undelWBStepIdsSet
                                                  ORDER BY SortOrder__c) FROM AH_UDC_Workbook__c WHERE Id In :undelWBIdsSet])
         {
            Integer count = 0;
            if (workbookMaxStepSortOrderMap.containsKey(wb.Id))
            {
               count = workbookMaxStepSortOrderMap.get(wb.Id);
            }
            for (AH_UDC_WorkbookStep__c steps : wb.Workbook_Steps__r) {
               steps.SortOrder__c =++ count;
               steps.Prerequisite_Step__c = null;
               lstUpdatedSortOrder.add(steps);
            }
         }

         if (lstUpdatedSortOrder.size() > 0) {
            AH_UDC_SystemContext.UpdateObjects(lstUpdatedSortOrder);
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Debug('An error occurred in Workbook Step trigger execution: ' + exc.getMessage() + ' at Line Number : ' + exc.getLineNumber());
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onUndeleteStep', 'An exception occurred during Workbook Step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);
         throw exc;
      }
   }
>>>>>>> be8f81a97d079e6e4c45f805d88969f9bcae9d8a
}