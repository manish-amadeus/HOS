/****************************************************************************************
Name            : psa411ReportAi_RunExtract
Author          : CLD
Created Date    : December 30, 2011
Description     : After insert into the PSA_411_Report object, if the "Run As Scheduled Batch"
                : value is false, this invokes the PSA411ReportExtract class to perform
                : the data extract for the 411 report.  This trigger allows the batch to be
                : run manually from the UI using custom-specified start and end dates as
                : an alternative to scheduled batch run.
******************************************************************************************/
trigger psa411ReportAi_RunExtract on PSA_411_Report__c (after insert) 
{
	// In case of a batch insert (which shouldn't happen) only use the first record inserted
	PSA_411_Report__c reportHeader = trigger.new[0];
	
	// A batch run will have set the "Run as Scheduled Batch" value to true, so the indicator that
	// the report is being created from the UI is that it is false.  If false, run the batch report extract.
	if(reportHeader!=null && reportHeader.From_Date__c!=null && reportHeader.To_Date__c!=null && reportHeader.Run_As_Scheduled_Batch__c==false)
	{
		new Psa411ReportExtract().runExtractFromUI(reportHeader);
	}
}