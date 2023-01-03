/****************************************************************************************
Name            : AH_Schedule_SalesInvoices
Author          : Bhuleshwar Deshpande
Created Date    : 11/02/2018
Modified Date	: 01/24/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : To schedule AH_BatchCreateInvoices bathc class.
				:
				:
******************************************************************************************/
global class AH_Schedule_SalesInvoices implements Schedulable 
{
    
    global void execute(SchedulableContext sc)
    {
        
        String groupByQuery = 'SELECT Billing_Contract__c, COUNT(Id) recCount ';
        groupByQuery += 'FROM Billing_Contract_Line_Item__c ';
        groupByQuery += 'WHERE  Ready_to_Invoice__c = true '; 
        groupByQuery += 'AND Type__c != \'Credit\' '; 
        groupByQuery += 'AND Total_Amount__c > 0 '; 
        //groupByQuery += 'AND Exclude_Automated_Invoicing__c = false '; 
        groupByQuery += 'AND Invoiced__c = false '; 
        groupByQuery += 'AND Activity_Line_Item__r.Origin__c = \'Renewal\' ';
        groupByQuery += 'GROUP BY Billing_Contract__c ';
        
        system.debug(' **** groupByQuery = ' + groupByQuery);
        
        Set<String> bcQueryIds = new Set<String>();
        AggregateResult[] groupedResults = Database.query(groupByQuery);
        
        if (groupedResults != null && groupedResults.size() > 0)
        {
            for (AggregateResult ar : groupedResults)
            {
                bcQueryIds.add(String.valueOf(ar.get('Billing_Contract__c')));
            }
        }
        
        AH_BatchCreateInvoices batchable = new AH_BatchCreateInvoices(bcQueryIds);
        Database.executeBatch(batchable, 1); 
        system.debug('Schedule class execution completed...');
        
        // CODE TO CREATE JOB SCHEDULED RECORD IN RUN HISTORIES OBJECT
        Job_Run_History__c runHist = new Job_Run_History__c();
        runHist.Apex_Class__c = 'AH_Schedule_SalesInvoices';
        runHist.Status__c = 'Queued';
        runHist.Target_Object__c = 'Sales Invoice';
        runHist.User__c = UserInfo.getUserName();
        runHist.Created_Date__c = Datetime.now();
        
        insert runHist;
        
    }
    
}