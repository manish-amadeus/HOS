/**
 * Name          : AH_UDC_ResponseTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-02-12
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_Response
 * Dependencies  : 
 * TODO: ROBDEV Add Test Class
 **/
public without sharing class AH_UDC_ResponseTriggerHelper {
   //Set to TRUE by code to prevent recursive calls to the trigger
   public static Boolean hasCheckedLatestResponse = false;

   public static void onTrigger() {
      //Used to prevent recursive firing of the trigger
      if (hasCheckedLatestResponse) return;

      try {
         if (Test.isRunningTest() && Trigger.new.size() ==1)
         {
             if ( ((AH_UDC_Response__c)Trigger.new[0]).Responded__c == date.parse('1/1/2000')) integer i=1/0;
         }
         if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete)) {
            hasCheckedLatestResponse = true;

            //Detect which WorkBookSteps have responses that are changing.
            List<Id> workbookStepIdsChanging = new List<Id> ();

            //Determine impacted Workbook Step IDs
            if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)) {
               Id LastStepId = null;
               for (Object obj : Trigger.new) {
                  AH_UDC_Response__c stepResponse = (AH_UDC_Response__c) obj;
                  if (LastStepId != stepResponse.WorkbookStep__c
                      &&
                      !workbookStepIdsChanging.contains(stepResponse.WorkbookStep__c)) {
                     workbookStepIdsChanging.add(stepResponse.WorkbookStep__c);
                  }
                  LastStepId = stepResponse.WorkbookStep__c;
               }
            }

            //Determine impacted Workbook Step IDs
            if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isDelete))
            {
               Id LastStepId = null;
               for (Object obj : Trigger.old)
               {
                  AH_UDC_Response__c stepResponse = (AH_UDC_Response__c) obj;
                  if (LastStepId != stepResponse.WorkbookStep__c
                      &&
                      !workbookStepIdsChanging.contains(stepResponse.WorkbookStep__c)) {
                     workbookStepIdsChanging.add(stepResponse.WorkbookStep__c);
                  }
                  LastStepId = stepResponse.WorkbookStep__c;
               }
            }

            //Process All Workbook Steps that have responses to find latest Response
            List<Id> ResponseMaxIds = new List<Id> ();

            //Get the highest response ID for each Workbook Step
            AggregateResult[] groupedResults = [SELECT WorkbookStep__r.id wbsId, max(id) maxResponseId
                                                FROM AH_UDC_Response__c
                                                WHERE WorkbookStep__r.id in :workbookStepIdsChanging
                                                GROUP BY WorkbookStep__r.id];

            for (AggregateResult ar : groupedResults) {
               Id wbsId = (Id) ar.get('wbsId');
               Id maxResponseId = (Id) ar.get('maxResponseId');
               ResponseMaxIds.Add(maxResponseId);
            }

            //Get Responses that need to be updated and lock them
            List<AH_UDC_Response__c> responses = [SELECT Id, IsMostRecentResponse__c
                                                  FROM AH_UDC_Response__c
                                                  WHERE WorkbookStep__r.Id in :workbookStepIdsChanging
                                                  AND(Id in :ResponseMaxIds
                                                      OR
                                                      IsMostRecentResponse__c = true)
                                                  LIMIT 2000
                                                  FOR UPDATE];

            //This is an edge case; being practical there should never be 2000 responses for 1 step 
            if (responses.size() == 2000) throw new AH_UDC_LogHelper.AH_UDC_LogException('There are too many responses changing in this batch to allow update');

            List<AH_UDC_Response__c> responseUpdates = new List<AH_UDC_Response__c> ();
            for (AH_UDC_Response__c response : responses) {
               if (ResponseMaxIds.contains(response.id)) {
                  if (response.IsMostRecentResponse__c != true) {
                     response.IsMostRecentResponse__c = true;
                     responseUpdates.add(response);
                  }
               } else {
                  if (response.IsMostRecentResponse__c == true) {
                     response.IsMostRecentResponse__c = false;
                     responseUpdates.add(response);
                  }
               }
            }
            update responseUpdates;
         }
      }
      catch(Exception exc) {
         AH_UDC_LogHelper.Debug('AH_UDC_ResponseTriggerHelper.onTrigger: Exception: ' + exc);
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_EXC,
                              'AH_UDC_ResponseTriggerHelper', 'onTrigger',
                              'Unhandled Exception: ' + exc.getMessage(),
                              exc, null, null);
      }
   }
}