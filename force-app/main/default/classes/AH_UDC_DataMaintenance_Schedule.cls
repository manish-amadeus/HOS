/*
 * Name         : AH_UDC_DataMaintenance_Schedule
 * Created By   : Vaishali Patel (vaishali.patel@amadeus.com)
 * Created Date : 9/13/2021
 * Description  : Used to schedule batch class - AH_UDC_DataMaintenance_Batch
 * Dependencies : AH_UDC_DataMaintenance_Batch.cls
 * NOTE: Since this Class is Scheduled, it can not be deployed as part of the package unless it is first unscheduled manually.
*/
/*
  //EXAMPLE: Don't delete this. This class must be scheduled in order for the purge batch to occur.
  String cronStr = '0 0 2 * * ?'; //Class runs every day at 2 AM
  String jobID = System.schedule('AH UDC DataMaintenance', cronStr, new AH_UDC_DataMaintenance_Schedule());
*/

global class AH_UDC_DataMaintenance_Schedule implements Schedulable {
   global void execute(SchedulableContext ctx) {
      //If the purge is not enabled then don't do any work.
      if (!AH_UDC_ConfigHelper.GetBoolean('AH_UDC_PurgeEnabled', false)) return;

      //Get the size of the batch to run
      Integer MAX_BATCH_SIZE = AH_UDC_ConfigHelper.GetInteger('AH_UDC_PurgeBatchSize', 200);
      
      if(Test.isRunningTest()) MAX_BATCH_SIZE = 200;
      //Start the Batch
      AH_UDC_DataMaintenance_Batch dataMaintenanceBatch = new AH_UDC_DataMaintenance_Batch();
      database.executebatch(dataMaintenanceBatch, MAX_BATCH_SIZE);
   }
}