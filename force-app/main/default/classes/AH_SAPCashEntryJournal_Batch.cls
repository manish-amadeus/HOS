/***********************************************************************************************
Name            : AH_SAPCashEntryJournal_Batch
Author          : Bhagwat Garkal
Created Date    : 10/11/2021
Last Mod Date   : 11/23/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Create new cash entries or journals in FFA from the records in the AH SAP Transaction object.  
                :
                :
************************************************************************************************/
global class AH_SAPCashEntryJournal_Batch implements Database.Batchable<sObject>
{
   	
    private String strTargetCompany;
    
    // CONSTRUCTOR
    global AH_SAPCashEntryJournal_Batch(String sTargetCompany)
    {    
        strTargetCompany = sTargetCompany;
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        system.debug('  In AH_SAPCashEntryJournal_Batch.start ... ');
        
        String strSOQL = 'SELECT Name, Bank_Account_Number__c, FFA_Company__c, Bank_Account_Value__c, Import_Date_Time__c, FFA_Cash_Entry__c, '; 
        strSOQL += 'Transaction_Type__c, FFA_Transaction_Type__c, FFA_Journal__c, Invoice_Number__c, Document_Amount__c, Document_Currency__c, Line_Description__c, ';
        strSOQL += 'Posting_Date__c, Customer_Number__c, Bank_Reference_Number__c, Document_Currency_Conversion__c, FFA_Processing_Status__c ';
        strSOQL += 'FROM AH_SAP_Transaction__c ';
        
        String strSOQLWhere = 'WHERE FFA_Processing_Status__c != \''+ 'Processed Successfully' + '\' '; 
        strSOQLWhere += 'AND FFA_Processing_Status__c != \''+ 'Manual Match' + '\' ';
        strSOQLWhere += 'AND FFA_Transaction_Type__c IN (\'Receipt\', \'Refund\', \'Write-Off\', \'Clearing\') ';
        strSOQLWhere += 'AND FFA_Company__c =: strTargetCompany ';
        strSOQLWhere += 'AND Exempt_From_Processing__c = false ';
                
        strSOQL += strSOQLWhere;
        
        system.debug('  strSOQLWhere ==> ' + strSOQLWhere);
        
        return Database.getQueryLocator(strSOQL); 
        
    }
    
    global void execute(Database.BatchableContext bc, List<AH_SAP_Transaction__c> lstSAPTransactions) 
    { 
        
        system.debug('  In AH_SAPCashEntryJournal_Batch.execute ... ');
        
        if (!lstSAPTransactions.isEmpty())
        {
            
            List<AH_SAP_Transaction__c> lstCashEntryInserts = new List<AH_SAP_Transaction__c>();
            List<AH_SAP_Transaction__c> lstJournalInserts = new List<AH_SAP_Transaction__c>();
            List<AH_SAP_Transaction__c> lstIncorrectSapTransaction = new List<AH_SAP_Transaction__c>();
            Map<String, Account> accountsMap = new Map<String, Account>();
            Set<String> accountNumbers = new Set<String>();
            
            // COLLECTING CUSTOMER NUMBER FROM SAP TRANSACTIONS FOR QUERYING ACCOUNT RECORDS
            for (AH_SAP_Transaction__c saptrans : lstSAPTransactions)
            {
                if(saptrans.Customer_Number__c != null)
                {
                    accountNumbers.add(saptrans.Customer_Number__c);
                }    
            }
            
            // FETCH ACCOUNT RECORDS TO CHECK CUSTOMER NUMBER
            if(!accountNumbers.isEmpty())
            {
            	for (Account acc : [SELECT Id, Name, Type, AccountNumber FROM Account WHERE AccountNumber IN : accountNumbers])
                {
                    accountsMap.put(acc.AccountNumber, acc);
                }    
            }    
            
            for (AH_SAP_Transaction__c saptrans : lstSAPTransactions)
            {
                system.debug('  saptrans ==> ' + saptrans);
                
                //Replace '-' if Document_Amount__c field contains i.e '1543-'.
                String amountString = String.valueof(saptrans.Document_Amount__c);
                String lastChar = amountString.substring(amountString.length()-1);
                system.debug('lastChar=>'+lastChar);
                
                if (lastChar != null && lastChar == '-')
                {
                    amountString = amountString.replace('-', '');   
                }
                
                Decimal amount = Decimal.valueof(amountString);
                
                //CHECK CUSTOMER NUMBER IN ACCOUNTS
                if (accountsMap != null && saptrans.Customer_Number__c != null && !accountsMap.containskey(saptrans.Customer_Number__c))
                {
                    saptrans.FFA_Processing_Status__c = 'Failed to Process – Customer Number not found in Salesforce';
                    lstIncorrectSapTransaction.add(saptrans);
                }
                else if (amount <= 0.00) //THE DOCUMENT AMOUNT MUST BE GREATER THAN ZERO
                {
                    saptrans.FFA_Processing_Status__c = 'Failed to Process - The Document Amount must be greater than zero';
                    lstIncorrectSapTransaction.add(saptrans);
                }
                else
                {
                    // PROCESS AS JOURNALS
                    if (saptrans.FFA_Transaction_Type__c == 'Write-Off')
                    {
                        lstJournalInserts.add(saptrans);
                    }
                    else
                    {
                        // ONLY 'RECEIPT' AND 'REFUND' WE BE PROCESS AS CASH ENTRIES AT THIS TIME. OTHER TYPES WILL BE IGNORED. 
                        if (saptrans.FFA_Transaction_Type__c == 'Receipt' || 
                            saptrans.FFA_Transaction_Type__c == 'Refund' || 
                            saptrans.FFA_Transaction_Type__c == 'Clearing')    // 'Clearing' ADDED 2022-10-06 
                        {
                            lstCashEntryInserts.add(saptrans);     
                        }
                    }
                }    
            }
          
            // CREATE CASH ENTRIES          
            if (!lstCashEntryInserts.isEmpty())
            {
                system.debug('  CALLING AH_SAPCashEntryJournal_BatchHandler.createCashEntry... ');
                AH_SAPCashEntryJournal_BatchHandler.createCashEntry(lstCashEntryInserts);
            }
            
            // CREATE JOURNALS
            if (!lstJournalInserts.isEmpty())
            {               
                system.debug('  CALLING AH_SAPCashEntryJournal_BatchHandler.createJournals... ');
                AH_SAPCashEntryJournal_BatchHandler.createJournals(lstJournalInserts);  
            }
            
            if (!lstIncorrectSapTransaction.isEmpty())
            {
                update lstIncorrectSapTransaction;
            }    
        }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {       
        
        system.debug('  In AH_SAPCashEntryJournal_Batch.finish ... ');
        
        String schedTime;
        //String strCurrentJobName = 'SAP Cash Entry Journals - ' + strTargetCompany;
        
        // ABORT FINISHED JOB
        for (AsyncApexJob job : [SELECT Id, JobType, ApexClass.Name, CronTriggerId, ParentJobId, Status 
                                 FROM AsyncApexJob 
                                 WHERE Status != 'Aborted'
                                 AND ApexClass.Name = 'AH_SAPCashEntryJournal_Schedule'])
        {
            try
            {
                system.abortJob(job.CronTriggerId);
            }
            catch (Exception ex)
            {
                system.debug('  ERROR WHEN ABORTING JOB!: ' + ex.getMessage());
            }
        }
        
        // QUERY 1 SAP TRANSACTION FOR NEXT FFA COMPANY CONTEXT BATCH
        List<AH_SAP_Transaction__c> lstNextSAPTransaction = new List<AH_SAP_Transaction__c>(
            [SELECT FFA_Company__c 
             FROM AH_SAP_Transaction__c 
             //WHERE FFA_Processing_Status__c != 'Processed Successfully' 
             WHERE (NOT FFA_Processing_Status__c IN ('Processed Successfully', 'Manual Match')) // NICC-062343
             AND (NOT FFA_Processing_Status__c LIKE '%fail%')    
             AND FFA_Transaction_Type__c IN ('Receipt', 'Refund', 'Write-Off', 'Clearing')      // 'Clearing' ADDED 2022-10-06 
             AND Exempt_From_Processing__c = false 
             LIMIT 1]); 
        
        if (lstNextSAPTransaction.isEmpty())
        {
            // ADD A DAY TO CURRENT TIME MINUS 10 MINUTES 
            schedTime = getNextRun(DateTime.now().addDays(1).addMinutes(-8));
            // SCHEDULE JOB FOR NEXT FFA COMPANY
            if (Test.isRunningTest()) { AH_SAPCashEntryJournal_Schedule.scheduleIt('Newmarket US APEX TEST', schedTime); } else { AH_SAPCashEntryJournal_Schedule.scheduleIt('Newmarket US', schedTime); }
        }
        else
        {
            // ADD 2 MINUTES TO CURRENT TIME 
            schedTime = getNextRun(DateTime.now().addMinutes(2));
            // SCHEDULE JOB FOR NEXT FFA COMPANY
            if (Test.isRunningTest()) { AH_SAPCashEntryJournal_Schedule.scheduleIt('Newmarket US APEX TEST', schedTime); } else { AH_SAPCashEntryJournal_Schedule.scheduleIt(lstNextSAPTransaction[0].FFA_Company__c, schedTime); }
        }
        
    }    
    
    private String getNextRun(DateTime dt) 
    {       
        return '0 ' + 
            string.valueOf(dt.minute()) + ' ' +
            string.valueOf(dt.hour()) + ' ' + 
            string.valueOf(dt.day()) + ' ' +
            string.valueOf(dt.month()) + ' ' + 
            '? '  + 
            string.valueOf(dt.year());
    }    
    
}