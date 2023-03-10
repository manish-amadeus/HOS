/**
 * Name          : AH_UDC_ResponseTriggerHelper
 * Created By    : Amadeus Hospitality Services (Rob.Stevens@Amadeus.com)
 * Created Date  : 2021-02-12
 * Description   : This class is the single entry point for processing triggers on object AH_UDC_Response__c
 * Dependencies  : 
 **/
public without sharing class AH_UDC_ResponseTriggerHelper {
   @TestVisible
   private static Boolean hasException = false;

   public static void onTrigger() {
      try {
         if (Test.isRunningTest() && hasException == true)
         {
            integer i = 1 / 0;
         }
         Set<Id> responseIds = new Set<Id> ();
         //Determine impacted Response IDs
         if (Trigger.isDelete)
         {
            //AH_UDC_Responce__c records should not be able to be deleted if they are assigned to an AH_UDC_WorkbookStepResponse__c record
            for (Object obj : Trigger.old)
            {
               AH_UDC_Response__c objResponse = (AH_UDC_Response__c) obj;
               responseIds.add(objResponse.id);
            }

            //Get the WorkbookStepResponses for each impacted response IDs
            Set<Id> existingWBSR = new Set<Id> ();
            AggregateResult[] groupedResponses = [SELECT Response__c
                                                FROM AH_UDC_WorkbookStepResponse__c
                                                WHERE Response__c in :responseIds
                                                GROUP by Response__c];

            for (AggregateResult groupedResponse : groupedResponses) {
               existingWBSR.add((ID)groupedResponse.get('Response__c'));
            }

            //Get Responses that can not be deleted since they are attached to a WorkbookStepResponse
            List<AH_UDC_WorkbookStepResponse__c> responseUpdates = new List<AH_UDC_WorkbookStepResponse__c> ();
            for (Object obj : Trigger.old)
            {
               AH_UDC_Response__c objResponse = (AH_UDC_Response__c) obj;
               if (existingWBSR.contains(objResponse.Id))
                  objResponse.addError(Label.AH_UDC_ResponseTriggerDeleteError);
            }
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