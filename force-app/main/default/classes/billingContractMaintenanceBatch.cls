/****************************************************************************************
Name            : billingContractMaintenanceBatch
Author          : CLD
Created Date    : 4/27/16
Last Updated    : 3/20/2019
Last Updated By : Stuart Emery
Description     : Batch Job to process any Billing Line Items in order to cause WFRs to fire.
                  Updated 3/20/2019 per NICC-033574
*****************************************************************************************/

global class billingContractMaintenanceBatch implements Database.Batchable<sObject>{
	/****************************************************************************
    * This method is required for batchable Apex.
    * It's where we set the query that is used to get the Resource records...
    * It sets up the Exectute() method
  	****************************************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC) 
  	{
	    String query = 'SELECT Id,'+
	    'Invoice_Date__c,'+
	    'Billing_Notification_Date__c,'+
	    'Invoiced__c'+
	    
	    ' FROM Billing_Contract_Line_Item__c'+ 
	    ' WHERE Billing_Notification_Date__c <= THIS_MONTH'+ 
        ' AND Status__c != \'Cancelled\' AND Invoiced__c = false'; //CHANGED 'Invoice_Date__c' TO 'Billing_Notification_Date__c' Per NICC-033574
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
  		List<Billing_Contract_Line_Item__c> invoiceDateUpdateList = new List<Billing_Contract_Line_Item__c>();
  		for(Sobject s : scope)
 	  	{
	  		Billing_Contract_Line_Item__c bli = (Billing_Contract_Line_Item__c)s;
	  		invoiceDateUpdateList.add(bli);
      	}
      	update invoiceDateUpdateList;
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
	    String apexJobDetails = '**** ffaSOBLMaintenance_Batch Finish()  status: ' + a.status + ' Total Jobs: ' + a.TotalJobItems + ' Errors: ' + a.NumberOfErrors;
	    system.debug(apexJobDetails);
  	}
}