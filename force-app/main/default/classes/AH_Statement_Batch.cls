/****************************************************************************************
Name            : AH_Statement_Batch
Author          : Bhagwat Garkal
Created Date    : 11/19/2020
Modified Date   : 11/19/2020
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Batch class for AH_Statement_Sched schedulable class.
                : Query Accounts for updating Statement_Eligible__c fields.
                :
                :
******************************************************************************************/
global class AH_Statement_Batch implements Database.Batchable<sObject> 
{
    
    // START METHOD
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        //COLLECT THE BATCHES OF ACCOUNT RECORDS TO BE PASSED TO EXECUTE
       
        String  accQuery = 'SELECT Account.Id,Statement_Eligible__c ';       
                accQuery += 'FROM Account ';
                accQuery += 'WHERE Account.Id IN (SELECT c2g__Account__c ';
                accQuery += 'FROM c2g__codaTransactionLineItem__c ';
                accQuery += 'WHERE c2g__Account__c != null ';
                accQuery += 'AND c2g__LineType__c = \'Account\' ';
                accQuery += 'AND c2g__MatchingStatus__c != \'Matched\' ';
                accQuery += 'AND c2g__OwnerCompany__c = \'a6832000000M2CX\')  ';
                //accQuery += 'AND Account.Exclude_from_Automated_Statement_Run__c = False  ' ; 
                accQuery += 'AND Account.Statement_Sent__c = False ' ; 
                accQuery += 'AND Account.c2g__CODAFinanceContact__c !=null ';                                         
                accQuery += 'ORDER BY Account.Id ';
                
        system.debug(' **** accQuery= ' + accQuery);
     
        return Database.getQueryLocator(accQuery );
    }
    
    // EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<Account> accList) 
    {
        if(accList != null && accList.Size() > 0)
        {
            for(Account acc : accList) 
            {        
                if(acc.Statement_Eligible__c == false)
                {
                    //UPDATE THE STATEMENT_ELIGIBLE__C FIELD. 
                    acc.Statement_Eligible__c = True;
                }
            }
        }
        
        try 
        {
            //UPDATE THE ACCOUNT RECORD LIST
            update accList;
        } 
        catch(Exception e) 
        {
            system.debug(' **** Error Occured: ' + e.getMessage());
        }
    }   
    
    // FINISH METHOD
    global void finish(Database.BatchableContext BC) 
    {
      
    }
}