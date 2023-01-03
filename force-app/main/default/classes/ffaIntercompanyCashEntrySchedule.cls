global class ffaIntercompanyCashEntrySchedule implements Schedulable {
	global void execute(SchedulableContext sc)
	{
		ffaIntercompanyCashEntryBatch batchClass = new ffaIntercompanyCashEntryBatch();
		Id batchID = database.executebatch(batchClass, 1);
	}
}