/****************************************************************************************
Name            : AH_SINManager_Sched_NonRenewals
Author          : 
Created Date    : 10/17/2019
Modified Date   : 11/22/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Class to schedule AH_SINManager_Batch class
                :
                :
******************************************************************************************/
global class AH_SINManager_Sched_NonRenewals implements Schedulable 
{
    
    global void execute(SchedulableContext sc)
    {
        // CHANGE IN EXISTING QUERY
        String  groupByQuery = 'SELECT Billing_Contract__c, COUNT(ID) recCount ';       
                groupByQuery += 'FROM Billing_Contract_Line_Item__c ';
                groupByQuery += 'WHERE Ready_to_Invoice__c = true ';
                groupByQuery += 'AND Invoiced__c = false ';
                groupByQuery += 'AND Total_Amount__c >= 0 ';
                groupByQuery += 'AND Type__c != \'Credit\' ';
                groupByQuery += 'AND Activity_Line_Item__r.Origin__c != \'Renewal\' ';
                groupByQuery += 'AND Billing_Contract__r.Exclude_Automated_Invoicing__c = false  '; 
                groupByQuery += 'AND Billing_Contract__r.Billing_Hold__c = FALSE  ' ; 
                groupByQuery += 'AND Billing_Contract__r.Company__r.Excl_frm_Automated_NonRenewal_Invoicing__c = false ' ; 
                groupByQuery += 'AND Billing_Contract__r.Opportunity__r.Order_Status__c = \'Definite\' ';                                         
                groupByQuery += 'GROUP BY Billing_Contract__c ';
                
        system.debug(' **** groupByQuery = ' + groupByQuery);
        
        Set<String> bcQueryIds = new Set<String>();
        integer iMode = 2;
        
        AggregateResult[] groupedResults = Database.query(groupByQuery);
        
        if (groupedResults != null && groupedResults.size() > 0)
        {
            for (AggregateResult ar : groupedResults)
            {
                bcQueryIds.add(String.valueOf(ar.get('Billing_Contract__c')));
            }
        }
                
        //REPLACE BATCH CLASS AH_BatchCreateInvoices WITH AH_SINManager_Batch
        AH_SINManager_Batch batchable = new AH_SINManager_Batch(bcQueryIds, iMode);
        Database.executeBatch(batchable, 1); 
        system.debug('Schedule class execution completed...');
        
        // CODE TO CREATE JOB SCHEDULED RECORD IN RUN HISTORIES OBJECT
        Job_Run_History__c runHist = new Job_Run_History__c();
        runHist.Apex_Class__c = 'AH_SINManager_Sched_NonRenewals';
        runHist.Status__c = 'Queued';
        runHist.Target_Object__c = 'Sales Invoice';
        runHist.User__c = UserInfo.getUserName();
        runHist.Created_Date__c = Datetime.now();
        
        insert runHist;
       
    }
    
}