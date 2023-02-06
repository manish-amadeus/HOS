/*
 * Name         : AH_UDC_DataMaintenance_Batch
 * Created By   : Vaishali Patel (vaishali.patel@amadeus.com)
 * Created Date : 8/30/2021
 * Description  : Used to purge all but most recent response for Completed/Locked workbooks. Purge Number of Prior Workbook Step Sent Responses to keep
                  Class didn't check for LIMIT because in batch class maximum of 50 million records can be returned in Database.QueryLocator object
 * Dependencies : 
 * Test Class   : AH_UDC_DataMaintenance_Test.cls
 */
global class AH_UDC_DataMaintenance_Batch implements Database.Batchable<SObject> {

   @TestVisible private static Boolean IsTestException = false;
   @TestVisible private static Boolean IsRecordTypeIdNull = false;
   global AH_UDC_DataMaintenance_Batch() {

   }

   /**
    * @description gets invoked when the batch job starts
    * @param context contains the job ID
    * @returns the record set as a QueryLocator object that will be batched for execution
    */
   global Database.QueryLocator start(Database.BatchableContext context) {
      AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_MESSAGE, 'AH_UDC_DataMaintenance_Batch', 'start', 'DataMaintenance Job started', null, null, null);
      return Database.getQueryLocator('SELECT Id, Name, Response__c, IsMostRecentResponse__c, WorkbookStep__c, WorkbookStep__r.Workbook__r.Id, WorkbookStep__r.Workbook__r.SentStatus__c, WorkbookStep__r.Workbook__r.CompletedDate__c, WorkbookStep__r.StepCompleted__c ' +
                                      'FROM AH_UDC_WorkbookStepResponse__c ' +
                                      'WHERE  IsMostRecentResponse__c = false ' + // AND WorkbookStep__r.Workbook__r.Id IN :workbookIds ' + //
                                      'ORDER BY WorkbookStep__r.Workbook__r.Id, WorkbookStep__r.Id, ID DESC');
   }

   /**
    * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
    * @param context contains the job ID
    * @param scope contains the batch of records to process.
    * NOTE: each batch is executed in serial not parallel
    */
   global void execute(Database.BatchableContext context, List<AH_UDC_WorkbookStepResponse__c> lstWbsResponses) {
      // process each batch of records default size is 200
      List<AH_UDC_Response__c> lstDeleteResponse = new List<AH_UDC_Response__c> ();
      Set<Id> setResponsesToDelete = new Set<Id> ();
      List<AH_UDC_WorkbookStepResponse__c> lstDeleteWorkbookStepResponses = new List<AH_UDC_WorkbookStepResponse__c> ();

      //Getting value from config settings
      Boolean purgeEnabled = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_PurgeEnabled', false);
      Boolean purgeResponses = AH_UDC_ConfigHelper.GetBoolean('AH_UDC_PurgeAllExceptMostRecentResponseForCompletedWorkbooks', true);
      Integer noOfDaysFromConfig = AH_UDC_ConfigHelper.GetInteger('AH_UDC_PurgeResponseAfterNumberOfDaysForCompletedLockedWorkbooks', 3);
      Integer noOfResponsesToKeep = AH_UDC_ConfigHelper.GetInteger('AH_UDC_NumberOfPriorWorkbookStepSentResponsesToKeep', 3);

      //Stop Purge right away if it becomes disabled
      if (!purgeEnabled) return;

      try {
         if (Test.isRunningTest() && IsTestException) Integer a = 1 / 0;
         List<AH_UDC_Response__c> lstResponses = new List<AH_UDC_Response__c> ();

         //Create a Map that can be used to lookup step IDs
         Map<Id, List<AH_UDC_WorkbookStepResponse__c>> stepAndResponseMap = new Map<Id, List<AH_UDC_WorkbookStepResponse__c>> ();
         for (AH_UDC_WorkbookStepResponse__c wbsResponse : lstWbsResponses)
         {
            if (stepAndResponseMap.containsKey(wbsResponse.WorkbookStep__c))
            {
               stepAndResponseMap.get(wbsResponse.WorkbookStep__c).add(wbsResponse);
            }
            else
            {
               stepAndResponseMap.put(wbsResponse.WorkbookStep__c, new list<AH_UDC_WorkbookStepResponse__c> { wbsResponse });
            }
         }

         Integer noOfDaysAfterWorkbookCompletion = 0;
         for (Id wbs : stepAndResponseMap.keySet())
         {
            List<AH_UDC_WorkbookStepResponse__c> lstWBSResponsesFromMap = stepAndResponseMap.get(wbs);
            AH_UDC_LogHelper.debug('Workbook: ' + lstWBSResponsesFromMap[0].WorkbookStep__r.Workbook__r.Id + '  Workbook Step Id : ' + wbs + ' lstWBSResponsesFromMap  size : ' + lstWBSResponsesFromMap.size());
            AH_UDC_LogHelper.debug('Workbook Status: ' + lstWBSResponsesFromMap[0].WorkbookStep__r.Workbook__r.SentStatus__c);
            if (lstWBSResponsesFromMap[0] != null && (lstWBSResponsesFromMap[0].WorkbookStep__r.Workbook__r.SentStatus__c == AH_UDC_Constants.SENT_STATUS_COMPLETE_LOCKED && lstWBSResponsesFromMap[0].WorkbookStep__r.Workbook__r.CompletedDate__c != NULL)) {
               noOfDaysAfterWorkbookCompletion = Date.valueOf(lstWBSResponsesFromMap[0].WorkbookStep__r.Workbook__r.CompletedDate__c).daysBetween(System.today());
               //Purge all but most recent response for Completed/Locked workbooks if purgeResponses is true
               if (noOfDaysAfterWorkbookCompletion > noOfDaysFromConfig && purgeResponses)
               {
                  for (AH_UDC_WorkbookStepResponse__c wbsr : lstWBSResponsesFromMap) {
                     //add all but most recent response
                     lstDeleteWorkbookStepResponses.add(wbsr);
                     AH_UDC_LogHelper.Debug('Workbook Responses for workbook with Locked/Completed Status : ' + wbsr.Name);
                  }
               }
            }
            else { //sent status Other than Completed/Locked
               Integer count = 0;
               for (AH_UDC_WorkbookStepResponse__c wbsr : lstWBSResponsesFromMap) {
                  //Number of Responses to keep
                  count++;
                  if (count > (noOfResponsesToKeep - 1)) //we are not getting most Recent Response in the query locator so I am subtracting 1 from noOfResponsesToKeep
                  {
                     lstDeleteWorkbookStepResponses.add(wbsr);
                     AH_UDC_LogHelper.Debug('Workbook Responses for workbook with In Progress or New Status : ' + wbsr.Name);
                  }
               }
            }
         }

         //These need to be delete first since they may point at responses being deleted
         if (lstDeleteWorkbookStepResponses.size() > 0)
         {
            Delete lstDeleteWorkbookStepResponses;
            DataBase.emptyRecycleBin(lstDeleteWorkbookStepResponses);
            String strDelete = 'Data Maintenance : Total deleted workbook step responses ' + lstDeleteWorkbookStepResponses.size();
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE,
                                 'AH_UDC_DataMaintenance_Batch', 'execute', strDelete, null, null, null);

         }
      } catch(Exception e) {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                              'AH_UDC_DataMaintenance_Batch', 'execute',
                              'Error while deleting responses in batch class',
                              e, null, null);
      }
   }

   /**
    * @description gets invoked when the batch job finishes. Place any clean up code in this method.
    * @param context contains the job ID
    */
   global void finish(Database.BatchableContext context) {
      // Query the AsyncApexJob object to retrieve the current job's information.
      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob
                        WHERE Id = :context.getJobId()];
      String strStatusMessage = 'Data Maintenance Status : ' + a.Status + '. The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.';
      AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_MESSAGE, 'AH_UDC_DataMaintenance_Batch', 'finish', strStatusMessage, null, null, null);
      if (!Test.isRunningTest())
      {
         try {
            Integer noOfResponsesPerBatch = AH_UDC_ConfigHelper.GetInteger('AH_UDC_PurgeResponseBatchSize', 200);
            Id batchJobId = Database.executeBatch(new AH_UDC_DataMaintenanceResponse_Batch(), noOfResponsesPerBatch);
         }
         catch(Exception e) {
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                                 'AH_UDC_DataMaintenance_Batch', 'finish',
                                 'Error while deleting responses via AH_UDC_DataMaintenanceResponse_Batch',
                                 e, null, null);
         }
      }
   }
}