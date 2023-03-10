/*
 * Name         : AH_UDC_WorkbookSentEmail_Schedule
 * Created By   : Rob Stevens (Rob.Stevens@amadeus.com)
 * Created Date : 2022-10-17
 * Description  : Used to schedule batch class - AH_UDC_WorkbookSentEmail_Batch
 * Dependencies : AH_UDC_WorkbookSentEmail_Batch.cls
 * NOTE: Since this Class is Scheduled, it can not be deployed as part of the package unless it is first unscheduled manually.
*/
/*
  //EXAMPLE: Don't delete this. This class must be scheduled in order for the purge batch to occur.
  String cronStr = '0 0 2 * * ?'; //Class runs every day at 2 AM
  String jobID = System.schedule('UDC Workbook Sent Email', cronStr, new AH_UDC_WorkbookSentEmail_Schedule());
*/

global class AH_UDC_WorkbookSentEmail_Schedule implements Schedulable {
   global void execute(SchedulableContext ctx) {
      //If the purge is not enabled then don't do any work.
      if (!AH_UDC_ConfigHelper.GetBoolean('AH_UDC_WorkbookSentEmailEnabled', false)) return;

      //Get the size of the batch to run
      Integer MAX_BATCH_SIZE = AH_UDC_ConfigHelper.GetInteger('AH_UDC_WorkbookSentEmailBatchSize', 10);
      
      if(Test.isRunningTest()) MAX_BATCH_SIZE = 10;
      //Start the Batch
      AH_UDC_WorkbookSentEmail_Batch wbSentEmailBatch = new AH_UDC_WorkbookSentEmail_Batch();
      database.executebatch(wbSentEmailBatch, MAX_BATCH_SIZE);
   }
}