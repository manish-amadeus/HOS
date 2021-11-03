/****************************************************************************************
Name            : ffaIntercompanyPayableInvoiceBatch
Author          : CLD
Created Date    : Jan 17, 2016
Description     : Contains methods for batch processing Payable Invoices that need to have the Intercompany Journals created.
******************************************************************************************/
global class ffaIntercompanyPayableInvoiceBatch implements Database.Batchable<sObject>{
	  /****************************************************************************
    * This method is required for batchable Apex.
    * It's where we set the query that is used to get the Resource records...
    * It sets up the Exectute() method
  	****************************************************************************/
	  global Database.QueryLocator start(Database.BatchableContext BC) 
  	{
	    String query = 'SELECT Id FROM c2g__codaPurchaseInvoice__c WHERE Id in (select c2g__PurchaseInvoice__c FROM c2g__codaPurchaseInvoiceExpenseLineItem__c WHERE Destination_Company__c != null AND Inter_Company_Journal_Created__c = false) AND c2g__Transaction__c != null';
	    if(Test.isRunningTest() == TRUE)
	    {
	      query = query +' LIMIT 1';
	    }
		  return Database.getQueryLocator(query);
  	}

  	/****************************************************************************
  	* This method is REQUIRED for batchable Apex and is where we loop through the
  	* results of the query specified in the execte() method
  	*****************************************************************************/
   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
  	{
  		for(Sobject s : scope)
 	  	{
	  		c2g__codaPurchaseInvoice__c pin = (c2g__codaPurchaseInvoice__c)s;
      	String message = ffaUtilities.createIntercompanyJournals(pin.id);
      	system.debug('**** ffaIntercompanyPayableInvoiceBatch executeBatch()');
      	system.debug('**** ffaIntercompanyPayableInvoiceBatch message = '+ message);
      	}
  	}

  	/****************************************************************************
    * This method is REQUIRED for batchable Apex... It puts some results in the log
    *
  	*****************************************************************************/
  	global void finish(Database.BatchableContext BC) 
  	{
  		// Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
	    // Query the AsyncApexJob object to retrieve the current job's information.
	    AsyncApexJob a = [
	        SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
	        FROM AsyncApexJob WHERE Id = :BC.getJobId()];

	    // log Apex job details
	    String apexJobDetails = '**** ffaIntercompanyPayableInvoiceBatch Finish()  status: ' + a.status + ' Total Jobs: ' + a.TotalJobItems + ' Errors: ' + a.NumberOfErrors;
	    system.debug(apexJobDetails);
  	}

}