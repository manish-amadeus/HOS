/*===========================================================================================
Name            : ffaIntercompanyPayableInvoiceBatch
Author          : CLD
Created Date    : Jan 17, 2016
Description     : Contains methods for batch processing Payable Invoices that need to have the Intercompany Journals created.
=============================================================================================*/

global class ffaIntercompanyCashEntryBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global ffaIntercompanyCashEntryBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
  	{
	    String query = 'SELECT Id FROM c2g__codaCashEntryLineItem__c WHERE Destination_Company__c != null AND Intercompany_Journal_Created__c = false AND c2g__cashEntry__r.c2g__Transaction__c != null AND Reversing_Journal_Created__c = true';
	    if(Test.isRunningTest() == TRUE)
	    {
	      query = query +' LIMIT 1';
	    }
		  return Database.getQueryLocator(query);
  	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		for(Sobject s : scope){
	  		c2g__codaCashEntryLineItem__c cLine = (c2g__codaCashEntryLineItem__c)s;
      		List<c2g__codaCashEntryLineItem__c> cLineList = new List<c2g__codaCashEntryLineItem__c>();
      		cLineList.add(cLine);
      		ffaUtilities.createIntercompanyJournals(cLineList);
      	}
	}
	
	global void finish(Database.BatchableContext BC) {
		// Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
	    AsyncApexJob a = [
	        SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
	        FROM AsyncApexJob WHERE Id = :BC.getJobId()];

	    // log Apex job details
	    String apexJobDetails = '**** ffaIntercompanyPayableInvoiceBatch Finish()  status: ' + a.status + ' Total Jobs: ' + a.TotalJobItems + ' Errors: ' + a.NumberOfErrors;
	    system.debug(apexJobDetails);
	}
	
}