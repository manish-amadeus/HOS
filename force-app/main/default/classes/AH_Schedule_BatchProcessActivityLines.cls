/********************************************************************************************************
Name            : AH_Schedule_BatchProcessActivityLines Class
Author          : Ria Chawla
Created Date    : 05/17/2018
Last Mod Date   : 04/25/2019 
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Schedule Batch Apex job AH_Batch_ProcessActivityLines 
: 
/**********************************************************************************************************/
global class AH_Schedule_BatchProcessActivityLines implements Schedulable
{
    @ReadOnly
    global void execute(SchedulableContext sc)
    {
        //INITIALIZE METHOD VARIABLES
        Map<Id, Integer> BCIdActCountMap = new Map<Id, Integer>();
        Date d = system.today().addDays(90);
        system.debug('d  :' + d);
        
        //GET THE COUNT OF ACTIVITY LINE ITEMS 
        List<AggregateResult> query = [Select Count(Id) cnt, Billing_Contract__c
                                       FROM Activity_Line_Item__c
                                       WHERE Renewal_Notification_Sent__c = False AND Auto_Renewal__c = True AND Renewal_Processed__c = FALSE
                                       AND (Revenue_Category__c = 'Hosting and Support' OR Revenue_Category__c = 'Support' OR Revenue_Category__c = 'Subscription')
                                       AND (Contract_End_Date__c = :d)
                                       Group By Billing_Contract__c]; 
        
        system.debug('query size : '+query.size());
        
        //ITERATE OVER THE LIST AND PUT THE COUNT AGAINST ACCOUNT
        for(AggregateResult aggr : query){
            BCIdActCountMap.put((Id)aggr.get('Billing_Contract__c'), (Integer)aggr.get('cnt'));
        }
        
        AH_Batch_ProcessActivityLines batchALIRecords = new AH_Batch_ProcessActivityLines(BCIdActCountMap);
        
        try{
            // EXECUTE BATCH CLASS
            // System.scheduleBatch(batchSurveyRecords, 'Update Contact Score',50);
            Database.executeBatch(batchALIRecords, 25); 
        }
        catch(Exception e){
            // DO NOTHING
            system.debug('e.getMessage()'+e.getMessage());
        }
    }
}