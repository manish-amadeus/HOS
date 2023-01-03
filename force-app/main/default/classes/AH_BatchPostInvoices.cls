/************************************************************************************************
Name            : AH_BatchPostInvoices Class
Author          : Shashikant Nikam
Created Date    : 12/03/2018
Last Mod Date   : 01/16/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Batch class to Post sales invoices. 
				: This class will be called from AH_ManageSalesInvoicesController Class.
				: 
				:
*************************************************************************************************/

global class AH_BatchPostInvoices implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful  {

    public List<String> invoiceIds;
    public AH_ManageSalesInvoicesController ctrl = new AH_ManageSalesInvoicesController();
    public Integer postingFailedCount = 0;
    public Integer postingSuccessCount = 0;
    public Integer errBCsCount = 0;
    public String timeStamp = '';

    public AH_BatchPostInvoices (List<String> Ids, List<String> erroredBCs, String timeString)
    {
        invoiceIds = new List<String>();
        invoiceIds.addAll(Ids);
        
        system.debug('Ids count : '+Ids.size());
        
        errBCsCount = erroredBCs.size(); 
        timeStamp = timeString;
        system.debug('timeStamp : '+ timeString);
    }
    
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        String query = 'SELECT ID, NAME, c2g__OwnerCompany__r.Name ' +
            			' FROM c2g__codaInvoice__c '+
            			' WHERE ID IN: invoiceIds';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<c2g__codaInvoice__c> sinList)
    {
        system.debug('Queries 1: '+Limits.getQueries());
        system.debug('sinList : '+sinList);
        
        try {
            c2g.CODAAPICommon_10_0.Context compWrapper = new c2g.CODAAPICommon_10_0.Context();
            compWrapper.CompanyName = sinList[0].c2g__OwnerCompany__r.Name;
            List<c2g.CODAAPICommon.Reference> invoiceWrapper = new List<c2g.CODAAPICommon.Reference>();
            
            for(c2g__codaInvoice__c sin: sinList)
            {
                c2g.CODAAPICommon.Reference wrapper = new c2g.CODAAPICommon.Reference();
            	wrapper.id = sin.id;
                invoiceWrapper.add(wrapper);
                postingSuccessCount++;
            }

			c2g.CODAAPISalesInvoice_10_0.BulkPostInvoice(compWrapper, invoiceWrapper);
            //c2g.CODAAPISalesInvoice_10_0.PostInvoice(compWrapper, invoiceWrapper);
            
            system.debug('done....');
            system.debug('Posted SIN : '+sinList.size());
            
        }
        catch(Exception e)
        {
            postingFailedCount++;
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_BatchPostInvoices', 'UPDATE');
            system.debug('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage());
        }
    }
    
    global void finish (Database.BatchableContext bc)
    {
    	system.debug('in finish of posting batch...');
        System.debug('Failed whiole creating invoice : '+errBCsCount);
        system.debug('Failed records count : '+postingFailedCount);
        system.debug('Success records count : '+postingSuccessCount);
        
        Job_Run_History__c runHist = new Job_Run_History__c();
        runHist.Apex_Class__c = 'AH_Schedule_SalesInvoices';
        runHist.Status__c = 'Run';
        runHist.No_of_Items_Processed__c = errBCsCount + postingFailedCount + postingSuccessCount;
        runHist.Target_Object__c = 'Sales Invoice';
        runHist.User__c = UserInfo.getUserName();
        runHist.Created_Date__c = Datetime.now();
        runHist.Unique_Timestamp__c = timeStamp;

        if (errBCsCount == 0 &&  postingFailedCount == 0 )
        {
        	runHist.Status_Detail__c = 'Success';
        }
        else if (errBCsCount != 0 || postingFailedCount != 0 )
        {
            runHist.Status_Detail__c = 'Failed';
        } 
        
        insert runHist;

        AH_ManageSalesInvoicesController.disablePostBtn = true;
        
        system.debug('runHist : '+runHist.id);
    }
}