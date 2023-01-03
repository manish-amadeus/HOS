/****************************************************************************************
Name            : ffaSOBLMaintenance_Schedule
Author          : CLD
Created Date    : 4/27/16	
Description     : Schedule to call the Billing Line Maintenance Batch
*****************************************************************************************/
global class billingContractMaintenanceSchedule implements Schedulable{
	global void execute(SchedulableContext sc)
	{
		billingContractMaintenanceBatch batchClass = new billingContractMaintenanceBatch();
		Id batchID = database.executebatch(batchClass, 10);
	}
}