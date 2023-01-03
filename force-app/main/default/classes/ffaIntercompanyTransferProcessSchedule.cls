/****************************************************************************************
Name            : ffaIntercompanyTransferProcessSchedule
Author          : CLD
Created Date    : 1/14/16
Description     : Schedule the call to process intercompany transfers
*****************************************************************************************/
global class ffaIntercompanyTransferProcessSchedule implements Schedulable {
	global void execute(SchedulableContext sc)
	{
		ffaIntercompanyTransferProcessBatch batchClass = new ffaIntercompanyTransferProcessBatch();
		Id batchID = database.executebatch(batchClass, 1);
	}
}