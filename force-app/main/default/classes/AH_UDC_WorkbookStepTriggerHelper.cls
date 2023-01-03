/**
 * Name          : AH_UDC_WorkbookStepTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-04-20
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_WorkbookStep
 * Dependencies  : 
 **/

public without sharing class AH_UDC_WorkbookStepTriggerHelper {
   public static void onTrigger() {
      List<Id> lstPrerequisiteStep = null;
      Exception ex = null;
      Boolean isAnyExceptionOccurred = false;
      try
      {
         if (Test.isRunningTest() && Trigger.new != null && Trigger.new.size() > 0 && ((AH_UDC_WorkbookStep__c) Trigger.new[0]).name == 'TestException') integer i = 1 / 0;

         if (Trigger.isBefore && (Trigger.isInsert))
         {
            //Get unique Workbook ids and the existing steps for them
            Set<Id> wbIds = new Set<Id> ();
            for (SObject obj : Trigger.new)
            {
               AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
               wbIds.add(wbs.workbook__c);               
            }
            List<AH_UDC_WorkbookStep__c> workbookSteps = [select id, name, Workbook__c, SortOrder__c, Prerequisite_Step__c, Prerequisite_Step__r.SortOrder__c
                                                          from AH_UDC_WorkbookStep__c
                                                          where Workbook__c in :wbIds
                                                          order by Workbook__c, SortOrder__c];

            //Get existing step max sort orders
            Map<Id, Integer> workbookStepMax = new Map<Id, Integer> ();
            List<AggregateResult> workbookMaxSteps = [select Workbook__c, MAX(SortOrder__c) MaxSortOrder
                                                      from AH_UDC_WorkbookStep__c
                                                      where Workbook__c in :wbIds
                                                      group by Workbook__c];
            // AH_UDC_LogHelper.Debug('workbookMaxSteps: ' + workbookMaxSteps);

            for (AggregateResult ar : workbookMaxSteps)
            {
               workbookStepMax.put(String.valueOf(ar.get('workbook__c')), Integer.valueOf(ar.get('MaxSortOrder')));
            }

            //Set Sort Order for Inserted Step to highest Sort Order
            for (SObject obj : Trigger.new)
            {
               AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;

               //If no steps exist then start sort order at 0
               if (!workbookStepMax.containsKey(String.valueOf(wbs.workbook__c))) workbookStepMax.put(String.valueOf(wbs.workbook__c), 0);

               //Override sort order of new record
               Integer iSortOrder = workbookStepMax.get(String.valueOf(wbs.workbook__c));
               iSortOrder = iSortOrder + 1;
               // AH_UDC_LogHelper.Debug('iSortOrder: ' + iSortOrder);
               workbookStepMax.put(String.valueOf(wbs.workbook__c), iSortOrder);
               wbs.SortOrder__c = iSortOrder;
            }

            //changes for Check that an inserted step, with a Prerequisite Step, has a higher Sort Order than the Prerequisite Step & 
            //Check that this step doesn't have the same URL or Form as another step
            Map<Id, List<AH_UDC_WorkbookStep__c>> workbookStepInfo = new Map<Id, List<AH_UDC_WorkbookStep__c>> ();
            Map<Id, Decimal> workbookStepOrderMap = new Map<Id, Decimal> ();
            for (AH_UDC_WorkbookStep__c workbookStepObj :[SELECT id, name, URL__c, Form__c, SortOrder__c, Workbook__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c in :wbIds ORDER BY Workbook__c, SortOrder__c])
            {               
               if (workbookStepInfo.containsKey(workbookStepObj.Workbook__c))
               {
                  workbookStepInfo.get(workbookStepObj.Workbook__c).add(workbookStepObj);
               } else {
                  workbookStepInfo.put(workbookStepObj.Workbook__c, new list<AH_UDC_WorkbookStep__c> { workbookStepObj });
               }
               workbookStepOrderMap.put(workbookStepObj.Id, workbookStepObj.SortOrder__c);
            }            

            for (SObject obj : Trigger.new)
            {
               AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
               if (workbookStepInfo.get(wbs.Workbook__c) != null)
               {
                  List<AH_UDC_WorkbookStep__c> WorkbookStepList = workbookStepInfo.get(wbs.Workbook__c);
                  for (AH_UDC_WorkbookStep__c oldSteps : WorkbookStepList)
                  {
                     if (oldSteps.URL__c == wbs.URL__c && wbs.URL__c != null)
                     {
                        obj.addError(Label.Workbook_Step_Create_Duplicate_Form_Or_URL_Trigger_Validation_Message);
                     }
                     if (oldSteps.Form__c == wbs.Form__c && wbs.Form__c != null)
                     {                        
                        obj.addError(Label.Workbook_Step_Create_Duplicate_Form_Or_URL_Trigger_Validation_Message);
                     }
                  }
               }

               if (wbs.Prerequisite_Step__c != null && wbs.SortOrder__c != null)
               {
                  if (workbookStepOrderMap.get(wbs.Prerequisite_Step__c) > wbs.SortOrder__c) // Used workbookStepOrderMap.get(wbs.Prerequisite_Step__c)'s static value to test this scenario
                  {
                     obj.addError(Label.Workbook_Step_Create_With_Prerequisite_Sort_Order_Trigger_Validation_Message);
                  }
               }
            }
         }

         if (Trigger.isBefore && (Trigger.isUpdate))
         {

            Map<ID, Decimal> oldStepOrderMap = new Map<ID, Decimal> ();
            Map<ID, Decimal> newStepOrderMap = new Map<ID, Decimal> ();
            AH_UDC_WorkbookStep__c wbs = new AH_UDC_WorkbookStep__c();
            SObject newSObject = null;
            for (SObject obj : Trigger.new)
            {
               SObject oldSObject = Trigger.oldMap.get(obj.ID);
               newSObject = obj;
               AH_UDC_WorkbookStep__c oldWorkbooksentValue = (AH_UDC_WorkbookStep__c) oldSObject; //Old Value
               oldStepOrderMap.put(oldWorkbooksentValue.Id, oldWorkbooksentValue.SortOrder__c);
               wbs = (AH_UDC_WorkbookStep__c) obj; //new updated value 
               newStepOrderMap.put(wbs.Id, wbs.SortOrder__c);
            }
            if (newSObject != null && oldStepOrderMap.size() > 0 && newStepOrderMap.size() > 0 && wbs != null)
            {
               onUpdateStep(newSObject, lstPrerequisiteStep, oldStepOrderMap, newStepOrderMap, wbs);
            }
         }
         if (Trigger.isBefore && (Trigger.isDelete))
         {
            SObject oldSObjectDelete = null;
            Id RecordTypeId = Schema.SObjectType.AH_UDC_WorkbookStep__c.getRecordTypeInfosByDeveloperName().get(AH_UDC_Constants.RECORD_TYPE_WORKBOOK_STEP_SENT).getRecordTypeId();
            String UDCSystemAdminPermissionSetName = AH_UDC_ConfigHelper.GetString('AH_UDC_PermissionSetUDCSystemAdministrator', AH_UDC_Constants.PERMISSIONSET_DEFAULT_NAME_UDC_SYSTEM_ADMIN);
            AH_UDC_LogHelper.Debug('Config Setting Value (AH_UDC_PermissionSetUDCSystemAdministrator) : ' + UDCSystemAdminPermissionSetName);
            AH_UDC_LogHelper.Debug('Logged In User Name : ' + System.UserInfo.getUserName());
            Integer intCount = (Integer) [SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId = :System.UserInfo.getUserId() AND PermissionSet.Name = :UDCSystemAdminPermissionSetName];
            AH_UDC_LogHelper.Debug('intCount : ' + intCount);
            for (SObject obj : Trigger.old)
            {
               AH_UDC_WorkbookStep__c objWorkbookStep = (AH_UDC_WorkbookStep__c) obj;
               if (objWorkbookStep != null && objWorkbookStep.RecordTypeId == RecordTypeId && intCount == 0)
               {
                  //Prevent other users than UDC System Admin from deleting Workbook Step Sent record
                  obj.addError(Label.AH_UDC_NoAccessRightsDelete);
                  AH_UDC_LogHelper.Log('Trace', 'AH_UDC_WorkbookStepTriggerHelper', 'onTrigger', 'The user (' + System.UserInfo.getUserName() + ') is trying to delete workbook step sent record');
               }
               else if (objWorkbookStep != null)
               {
                  oldSObjectDelete = obj;
               }
            }

            //validate this step is prerequisite step for any other step of workbook before deleting step
            if (oldSObjectDelete != null)
            {
               onDeleteStep(oldSObjectDelete, lstPrerequisiteStep);
            }
         }

         if (Trigger.isAfter && (Trigger.isUndelete))
         {
            onUndeleteStep();
         }
      }
      catch(Exception exc)
      {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepTriggerHelper',
                              'onTrigger', 'An exception occurred during workbook step trigger execution for the user (' + System.UserInfo.getUserId() + ' : ' + System.UserInfo.getUserName() + ') and Workbook List : ' + Trigger.new,
                              exc, null, null);

         for (SObject sObj : (Trigger.new != null ? Trigger.new : Trigger.old))
         {
            //TODO this error is user facing and needs a label
            sObj.addError(Label.Workbook_Step_Trigger_Exception_Message); // prevent upsert
         }

      }
      finally {
         lstPrerequisiteStep = null;         
      }
   }

   private static void onUpdateStep(SObject obj, List<Id> lstPrerequisiteStep, Map<ID, Decimal> oldStepOrderMap, Map<ID, Decimal> newStepOrderMap, AH_UDC_WorkbookStep__c wbs)
   {
      try {
         //System.debug('Inside onUpdateStep - before SOQL execution');
         List<AH_UDC_WorkbookStep__c> workbookStepDetails = [SELECT Id, Enabled__c, SortOrder__c, Prerequisite_Step__c
                                                             FROM AH_UDC_WorkbookStep__c
                                                             WHERE Workbook__c = :wbs.Workbook__c];
         //System.debug('Inside onUpdateStep - after SOQL execution');
         for (AH_UDC_WorkbookStep__c Item : workbookStepDetails)
         {
            //validation on step order changed and kept as earlier then prerequisite step
            if (newStepOrderMap.get(Item.Id) != oldStepOrderMap.get(Item.Id))
            {
               if (Item.Prerequisite_Step__c != null) {
                  if (newStepOrderMap.get(Item.Id) <= newStepOrderMap.get(Item.Prerequisite_Step__c))
                  {
                     obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Sort_order_changes_Validation_Message);
                  }
               }
            }
            //validate this step is prerequisite step for any other step of workbook before disabling step
         }
         if (wbs.Enabled__c == false)
         {
            lstPrerequisiteStep = new List<Id> ();
            if (lstPrerequisiteStep.size() == 0)
            {
               for (AH_UDC_WorkbookStep__c steps : workbookStepDetails) {
                  lstPrerequisiteStep.add(steps.Prerequisite_Step__c);
               }
            }
            if (lstPrerequisiteStep.contains(wbs.Id))
            {
               obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message);
            }
         }
      }
      catch(Exception exc)
      {
         System.debug(exc.getMessage() + ' : ' + exc.getCause() + ' : ' + exc.getStackTraceString());
         throw exc;
      }
   }

   private static void onDeleteStep(SObject obj, List<Id> lstPrerequisiteStep)
   {
      try {
         //validate this step is prerequisite step for any other step of workbook before deleting step
         AH_UDC_WorkbookStep__c wbs = (AH_UDC_WorkbookStep__c) obj;
         lstPrerequisiteStep = new List<Id> ();
         if (lstPrerequisiteStep.size() == 0)
         {
            for (AH_UDC_WorkbookStep__c steps :[SELECT Prerequisite_Step__c FROM AH_UDC_WorkbookStep__c WHERE Workbook__c = :wbs.Workbook__c]) {
               lstPrerequisiteStep.add(steps.Prerequisite_Step__c);
            }
         }

         if (lstPrerequisiteStep.contains(wbs.Id)) {
            obj.adderror(Label.AH_UDC_Workbook_Step_Trigger_Disable_Delete_Validation_Message);
         }
         else {
            List<AH_UDC_WorkbookStep__c> workbookStepsWithoutdelete = [SELECT Workbook__c, SortOrder__c
                                                                       FROM AH_UDC_WorkbookStep__c
                                                                       WHERE Workbook__c = :wbs.Workbook__c AND Id != :wbs.Id
                                                                       ORDER BY SortOrder__c];
            Integer count = 1;
            for (AH_UDC_WorkbookStep__c allWorkbookStep : workbookStepsWithoutdelete) {
               allWorkbookStep.SortOrder__c = count;
               count++;
            }
            if (workbookStepsWithoutdelete != null && workbookStepsWithoutdelete.size() > 0) {
               update workbookStepsWithoutdelete;
            }
         }
      }
      catch(Exception exc)
      {
         System.debug(exc.getMessage() + ' : ' + exc.getCause() + ' : ' + exc.getStackTraceString());
         throw exc;
      }
   }

   private static void onUndeleteStep()
   {
      try {
         Integer sortOrderValue = 1;
         id undeletedWorkbookStepId = null;
         AH_UDC_WorkbookStep__c[] theWorkbookStep = [SELECT Prerequisite_Step__c, SortOrder__c, Workbook__c FROM AH_UDC_WorkbookStep__c WHERE id IN :trigger.new];
         if (theWorkbookStep != null && theWorkbookStep.size() > 0)
         {
            List<AggregateResult> workbookMaxSteps = [SELECT Workbook__c, MAX(SortOrder__c) MaxSortOrder
                                                      FROM AH_UDC_WorkbookStep__c
                                                      WHERE Workbook__c = :theWorkbookStep[0].Workbook__c
                                                      group by Workbook__c];

            if (workbookMaxSteps.size() > 0) {

               for (AggregateResult ar : workbookMaxSteps)
               {
                  sortOrderValue = Integer.valueOf(ar.get('MaxSortOrder')) + 1; //incremented with 1 as to count undeleted step
               }
            }
            for (AH_UDC_WorkbookStep__c undeletedWorkbookStep : theWorkbookStep) {
               undeletedWorkbookStep.Prerequisite_Step__c = null;
               undeletedWorkbookStep.SortOrder__c = sortOrderValue;
               undeletedWorkbookStepId = undeletedWorkbookStep.Id;

            }
            update theWorkbookStep;
            if (undeletedWorkbookStepId != null)
            {
               List<AH_UDC_WorkbookStep__c> workbookStepsWithoutUndelete = [SELECT Workbook__c, SortOrder__c
                                                                            FROM AH_UDC_WorkbookStep__c
                                                                            WHERE Workbook__c = :theWorkbookStep[0].Workbook__c //AND Id != :undeletedWorkbookStepId
                                                                            ORDER by SortOrder__c];
               Integer count = 1;
               for (AH_UDC_WorkbookStep__c allWorkbookStep : workbookStepsWithoutUndelete) {
                  allWorkbookStep.SortOrder__c = count;
                  count++;
               }
               if (workbookStepsWithoutUndelete != null && workbookStepsWithoutUndelete.size() > 0) {
                  update workbookStepsWithoutUndelete;
               }
            }
         }
      }
      catch(Exception exc)
      {
         System.debug(exc.getMessage() + ' : ' + exc.getCause() + ' : ' + exc.getStackTraceString());
         throw exc;
      }
   }
}