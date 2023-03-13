/*
 * Name         : AH_UDC_DataMaintenanceResponse_Batch
 * Created By   : Vaishali Patel (vaishali.patel@amadeus.com)
 * Created Date : 4/22/2022
 * Description  : Used to purge all the orphan responses 
 * Dependencies : 
 * Test Class   : AH_UDC_DataMaintenanceResponse_Test.cls
 */
global class AH_UDC_DataMaintenanceResponse_Batch implements Database.Batchable<SObject> {
   @TestVisible
   private static Boolean IsTestException = false;
   global AH_UDC_DataMaintenanceResponse_Batch() {

   }
   global database.querylocator start(database.BatchableContext bc) {
      AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_MESSAGE, 'AH_UDC_DataMaintenanceResponse_Batch', 'start', 'Data Maintenance Response Job: Started', null, null, null);
      return database.getQueryLocator('SELECT Id FROM AH_UDC_Response__c');      
   }
   global void execute(database.BatchableContext bc, list<AH_UDC_Response__c> lstResponses) {
      try {
         if (Test.isRunningTest() && IsTestException) Integer a = 1 / 0;
         Set<Id> setResponses = new Set<Id> ();
         if (lstResponses.size() < 0) return;
         for (AH_UDC_Response__c res : lstResponses)
         {
            setResponses.add(res.Id);
         }
         Set<Id> setWBSR = new Set<Id> ();
         List<AH_UDC_WorkbookStepResponse__c> lstWBSR = [SELECT Response__c FROM AH_UDC_WorkbookStepResponse__c WHERE Response__c in :setResponses];
         for (AH_UDC_WorkbookStepResponse__c wsr : lstWBSR) {
            setWBSR.add(wsr.Response__c);
         }
         List<AH_UDC_Response__c> lstResponsesToDelete = new List<AH_UDC_Response__c> ();
         for (AH_UDC_Response__c res : lstResponses)
         {
            if (!setWBSR.contains(res.Id)) {
               lstResponsesToDelete.add(res);
            }
         }
         //Delete the Responses - ResponseQA records are Parent-Child so it will be deleted too
         if (lstResponsesToDelete.size() > 0)
         {
            delete lstResponsesToDelete;
            database.emptyRecycleBin(lstResponsesToDelete);
            String strDelete = 'Data Maintenance Response Job: Total deleted responses ' + lstResponsesToDelete.size();
            AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_TRACE, 'AH_UDC_DataMaintenanceResponse_Batch', 'execute', strDelete, null, null, null);
         }
      }
      catch(Exception e) {
         AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_ERROR,
                              'AH_UDC_DataMaintenanceResponse_Batch', 'execute',
                              'Error while deleting responses in batch class',
                              e, null, null);
      }
   }
   global void finish(database.BatchableContext bc) {

      AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob
                        WHERE Id = :bc.getJobId()];
      String strStatusMessage = 'Data Maintenance Response Job Status: ' + a.Status + '. The batch Apex job processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.';
      AH_UDC_LogHelper.Log(AH_UDC_LogHelper.LogLevel_MESSAGE, 'AH_UDC_DataMaintenanceResponse_Batch', 'finish', strStatusMessage, null, null, null);
   }   
}