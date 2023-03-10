/************************************************************************************************
Name            : AH_Batch_ProcessActivityLines Class
Author          : Ria Chawla
Created Date    : 05/17/2018
Last Mod Date   : 04/25/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Query Activity Line Item records that have 
				: Renewal Notification Sent is False, Renewal Eligible is True, Renewal Processed is False
				: and Revenue Category is ‘Hosting and Support’ OR ‘Subscription’ OR ‘Support’ and today’s date is 90 days before Activity End / Delivered Date
				: 
**************************************************************************************************/
global class AH_Batch_ProcessActivityLines implements Database.Batchable<sObject> 
{
    //CLASS VARIABLES
    public String query;
    public Map<Id, Integer> BillCntrIdActCountMap = new Map<Id, Integer>();
    //List<Billing_Contract__c> accountsList = new List<Billing_Contract__c>();
    
    //CONSTRUCTOR
    public AH_Batch_ProcessActivityLines(Map<Id, Integer> BCIdActCount)
    {
        BillCntrIdActCountMap = BCIdActCount;
        
        system.debug('BillCntrIdActCountMap : '+BillCntrIdActCountMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //GET THE LIST OF Billing Contracts FOR WHICH EMAIL HAS TO BE SENT
        if(!BillCntrIdActCountMap.isEmpty())
        {
            Set<Id> keys = BillCntrIdActCountMap.keyset();
            query = 'SELECT Id, Name,Send_Email__c '
                + ' FROM Billing_Contract__c WHERE Id IN :keys';
        }
        else
        {
            query = 'Select Id FROM Billing_Contract__c ' + 
                + ' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc1, List<Billing_Contract__c> scope)
    {
        system.debug('scope size : '+scope.size());
        
        //CREATE A LIST TO STORE Billing Contracts TO UPDATE
        List<Billing_Contract__c> BCsToUpdate = new List<Billing_Contract__c>();
                
        //LOOP THROUGH Billing Contract RECORDS TO UPDATE CHECKBOX
        if(!BillCntrIdActCountMap.isEmpty())
        {
            for(Billing_Contract__c bc : scope)
            {
                if(BillCntrIdActCountMap.containsKey(bc.Id))
                {
                    Integer k  = BillCntrIdActCountMap.get(bc.Id);
                    if(k > 0)
                    {
                        bc.Send_Email__c = true;
                        BCsToUpdate.add(bc);
                    }
                }
            }
        }
        
        //UPDATE Billing Contract
        if(!BCsToUpdate.isEmpty()){
            Database.update(BCsToUpdate);
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {}
}