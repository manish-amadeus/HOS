/****************************************************************************************
Name            : ffaIntercompanyPayableInvoiceSchedule
Author          : CLD
Created Date    : 1/14/16
Description     : Schedule the call to create intercompany transfers
*****************************************************************************************/
global class ffaIntercompanyPayableInvoiceSchedule implements Schedulable 
{
	global void execute(SchedulableContext sc)
	{
		ffaIntercompanyPayableInvoiceBatch batchClass = new ffaIntercompanyPayableInvoiceBatch();
		Id batchID = database.executebatch(batchClass, 1);
	}
}