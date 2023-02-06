/**
 * Name          : AH_UDC_WorkbookStepResponseTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2022-01-10
 * Description   : This class is the single entry point for processing triggers on object WorkbookStepResponse__c
 * Dependencies  : 
 **/
public without sharing class AH_UDC_WorkbookStepResponseTriggerHelper {

   //Set to TRUE by code to prevent recursive calls to the trigger
   public static Boolean hasCheckedLatestResponse = false;

   public static void onTrigger() {
      //Used to prevent recursive firing of the trigger
      if (hasCheckedLatestResponse) return;

      try {         
         if ((Test.isRunningTest() && Trigger.new != null) && Trigger.new.size() == 1)
         {
            if (((AH_UDC_WorkbookStepResponse__c) Trigger.new[0]).Name == 'TestException') integer i = 1 / 0;
         }
         if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete)) {
            hasCheckedLatestResponse = true;

            //Detect which WorkBookSteps have responses that are changing.
            Set<Id> workbookStepIdsChanging = new Set<Id> ();

            //Determine impacted Workbook Step IDs
            List<Object> triggerObjects = null;
            if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) triggerObjects = Trigger.new;
            if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isDelete)) triggerObjects = Trigger.old;
            for (Object obj : triggerObjects) {
               AH_UDC_WorkbookStepResponse__c wbsResponse = (AH_UDC_WorkbookStepResponse__c) obj;
               workbookStepIdsChanging.add(wbsResponse.WorkbookStep__c);
            }

            //Process All Workbook Steps that have responses to find latest Response
            Set<Id> WbsResponseMaxIds = new Set<Id> ();

            //Get the highest response ID for each Workbook Step
            AggregateResult[] groupedResults = [SELECT WorkbookStep__c wbsId, max(id) maxWbsResponseId
                                                FROM AH_UDC_WorkbookStepResponse__c
                                                WHERE WorkbookStep__c in :workbookStepIdsChanging
                                                GROUP BY WorkbookStep__c];

            for (AggregateResult ar : groupedResults) {
               WbsResponseMaxIds.Add((Id) ar.get('maxWbsResponseId'));
            }

            //Get Responses that need to be updated and lock them
            List<AH_UDC_WorkbookStepResponse__c> wbsResponses = [SELECT Id, IsMostRecentResponse__c
                                                                 FROM AH_UDC_WorkbookStepResponse__c
                                                                 WHERE WorkbookStep__c in :workbookStepIdsChanging
                                                                 AND(Id in :WbsResponseMaxIds
                                                                     OR
                                                                     IsMostRecentResponse__c = true)
                                                                 LIMIT 2000
                                                                 FOR UPDATE];

            //This is an edge case; being practical there should never be 2000 responses for 1 step 
            if (wbsResponses.size() == 2000) throw new AH_UDC_LogHelper.AH_UDC_LogException('There are too many responses changing in this batch to allow update');

            List<AH_UDC_WorkbookStepResponse__c> wbsResponseUpdates = new List<AH_UDC_WorkbookStepResponse__c> ();
            for (AH_UDC_WorkbookStepResponse__c wbsResponse : wbsResponses) {
               if (WbsResponseMaxIds.contains(wbsResponse.id)) {
                  if (wbsResponse.IsMostRecentResponse__c != true) {
                     wbsResponse.IsMostRecentResponse__c = true;
                     wbsResponseUpdates.add(wbsResponse);
                  }
               } else {
                  if (wbsResponse.IsMostRecentResponse__c == true) {
                     wbsResponse.IsMostRecentResponse__c = false;
                     wbsResponseUpdates.add(wbsResponse);
                  }
               }
            }
            AH_UDC_SystemContext.UpdateObjects(wbsResponseUpdates);
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_WorkbookStepResponseTriggerHelper.onTrigger: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_WorkbookStepResponseTriggerHelper', 'onTrigger',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, null, null);
      }
   }
}