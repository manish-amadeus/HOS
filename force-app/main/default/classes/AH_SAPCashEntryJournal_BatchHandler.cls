/****************************************************************************************
Name            : AH_SAPCashEntryJournal_BatchHandler Class
Author          : Bhagwat Garkal
Created Date    : 10/26/2021
Last Mod Date   : 11/23/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Controller class for AH_SAPCashEntryJournal_Batch VF Page 
                : 
******************************************************************************************/
public class AH_SAPCashEntryJournal_BatchHandler 
{

    // =============================================================================
    // This method creates Journal records From SAP Transactions
    // =============================================================================
    public static void createJournals(List<AH_SAP_Transaction__c> sapTrasList)
    {
        
        Map<String, c2g__codaCompany__c> ffaCompanyMap = new Map<String, c2g__codaCompany__c>();
        Map<String, Account> accountsMap = new Map<String, Account>();
        Set<String> accountNumbers = new Set<String>(); 
        Map<String, AH_SAP_Transaction__c> mapOfSAPTrans = new Map<String, AH_SAP_Transaction__c>();
        Map<String, List<c2g__codaAccountingCurrency__c>> mapOfAccountingCurrency = new Map<String, List<c2g__codaAccountingCurrency__c>>();
        List<c2g__codaJournal__c> insertListOfJournal = new List<c2g__codaJournal__c>();
        
        // Fetch FFA Company
        for (c2g__codaCompany__c ffaCompany : [SELECT Id, Name, c2g__BankAccount__c, c2g__CustomerWriteOffDimension2__c, 
                                               c2g__CustomerCurrencyWriteOffDimension3__c, c2g__CustomerWriteOff__c 
                                               FROM c2g__codaCompany__c])
        {
            ffaCompanyMap.put(ffaCompany.Name, ffaCompany);
        }
        
        // Fetch Accounting Currency
        for (c2g__codaAccountingCurrency__c ac : [SELECT Id, Name, c2g__Home__c, c2g__Dual__c, c2g__OwnerCompany__c, c2g__OwnerCompany__r.Name 
                                                  FROM c2g__codaAccountingCurrency__c])
        {
            if (mapOfAccountingCurrency != null && mapOfAccountingCurrency.containsKey(ac.c2g__OwnerCompany__r.Name))
            {
                mapOfAccountingCurrency.get(ac.c2g__OwnerCompany__r.Name).add(ac);
            }
            else
            {
                mapOfAccountingCurrency.put(ac.c2g__OwnerCompany__r.Name, new List<c2g__codaAccountingCurrency__c>{ac});
            }
        }
        
        Map<String, c2g__codaAccountingCurrency__c> mapOfCurrency = new Map<String, c2g__codaAccountingCurrency__c>();
        
        for (AH_SAP_Transaction__c saptrans : sapTrasList) 
        { 
            // Journal Object
            c2g__codaJournal__c newJournal = new c2g__codaJournal__c();
            if (saptrans.Customer_Number__c != null)
            {
                accountNumbers.add(saptrans.Customer_Number__c);
                // Add FFACompany
                if (ffaCompanyMap != null && ffaCompanyMap.containskey(saptrans.FFA_Company__c))
                {
                    newJournal.c2g__OwnerCompany__c = ffaCompanyMap.get(saptrans.FFA_Company__c).Id;
                    
                    // ADD Accounting Currency from FFA_Company__c
                    if (mapOfAccountingCurrency != null && mapOfAccountingCurrency.containsKey(saptrans.FFA_Company__c))
                    {
                        for (c2g__codaAccountingCurrency__c curr : mapOfAccountingCurrency.get(saptrans.FFA_Company__c))
                        {
                            mapOfCurrency.put(curr.Name, curr);
                        }     
                    }     
                }
                
                newJournal.ffgl__DerivePeriod__c = true;
                newJournal.c2g__DerivePeriod__c = true;
                
                if (mapOfCurrency != null && mapOfCurrency.containsKey(saptrans.Document_Currency__c))
                {
                    newJournal.c2g__JournalCurrency__c = mapOfCurrency.get(saptrans.Document_Currency__c).Id;
                    
                    // Check Home Currency
                    if (mapOfCurrency.get(saptrans.Document_Currency__c).c2g__Home__c == true)
                    {
                        newJournal.ffgl__DeriveCurrency__c = true;
                        newJournal.c2g__DeriveCurrency__c = true;
                    }
                    else
                    {
                        newJournal.ffgl__DeriveCurrency__c = false;
                        newJournal.c2g__DeriveCurrency__c = false;
                    }
                }
                
                newJournal.c2g__JournalDate__c = saptrans.Posting_Date__c;
                newJournal.c2g__JournalDescription__c = saptrans.Bank_Reference_Number__c;
                newJournal.AH_SAP_Transaction__c = saptrans.Id;
                insertListOfJournal.add(newJournal);
                mapOfSAPTrans.put(saptrans.Id, saptrans);
                
            }
            
        }    
        
        try 
        {
            
            Set<Id> journalIds = new Set<Id>();
            
            if (insertListOfJournal != null && insertListOfJournal.Size() != 0)
            {
                Database.SaveResult[] srList = Database.insert(insertListOfJournal, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) 
                {
                    if (sr.isSuccess()) 
                    {
                        // Operation was successful, so get the ID of the record that was processed
                        journalIds.add(sr.getId());
                    }
                    else 
                    {             
                        for (Database.Error err : sr.getErrors()) 
                        {
                            // Operation failed, so get all errors   
                            system.debug('The following error has occurred ==>'+err.getStatusCode() + ': ' + err.getMessage() + '. Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
            
            if (journalIds != null && journalIds.Size() != 0)
            {
                List<AH_SAP_Transaction__c> updateSapTransList = new List<AH_SAP_Transaction__c>();
                
                if (accountNumbers != null && accountNumbers.size() != 0)
                {
                    for (Account acc : [SELECT Id, Name, c2g__CODAAccountsReceivableControl__c, Type, AccountNumber 
                                        FROM Account 
                                        WHERE AccountNumber IN : accountNumbers])
                    {
                        accountsMap.put(acc.AccountNumber, acc);
                    }
                }
                
                c2g.CODAAPICommon_10_0.Context companyWrapper = new c2g.CODAAPICommon_10_0.Context();
                List<c2g__codaJournalLineItem__c> insertListOfJournalLineItem =  new List<c2g__codaJournalLineItem__c>();
                List<c2g.CODAAPICommon.Reference> listOfPostJournal = new List<c2g.CODAAPICommon.Reference>();
                
                for (c2g__codaJournal__c journal : [SELECT Id, AH_SAP_Transaction__c, c2g__JournalRate__c, AH_SAP_Transaction__r.Customer_Number__c, c2g__OwnerCompany__c, 
                                                    AH_SAP_Transaction__r.Document_Currency__c, AH_SAP_Transaction__r.Invoice_Number__c, AH_SAP_Transaction__r.Document_Amount__c, 
                                                    AH_SAP_Transaction__r.Document_Currency_Conversion__c, c2g__OwnerCompany__r.c2g__CustomerWriteOffDimension2__c, 
                                                    c2g__OwnerCompany__r.c2g__CustomerWriteOffDimension3__c, ffgl__DeriveCurrency__c, c2g__DeriveCurrency__c,
                                                    c2g__OwnerCompany__r.c2g__CustomerWriteOff__c, c2g__OwnerCompany__r.Name 
                                                    FROM c2g__codaJournal__c 
                                                    WHERE Id IN : journalIds])
                {
                    
                    if (journal.AH_SAP_Transaction__c != null)
                    { 
                        
                        // GL Line
                        c2g__codaJournalLineItem__c glline = new c2g__codaJournalLineItem__c();
                        
                        // Account Line
                        c2g__codaJournalLineItem__c accline = new c2g__codaJournalLineItem__c();
                        
                        glline.c2g__Journal__c = journal.Id;
                        glline.ffgl__DeriveLineNumber__c = true;
                        glline.c2g__DeriveLineNumber__c = true;
                        glline.c2g__LineType__c = 'General Ledger Account';
                        glline.c2g__LineDescription__c = journal.AH_SAP_Transaction__r.Invoice_Number__c;
                        String amountString = String.valueof(journal.AH_SAP_Transaction__r.Document_Amount__c);
                        amountString = amountString.replace('-', '');
                        Decimal amount = Decimal.valueof(amountString);
                        
                        // Set negative For GL Line
                        if (amount > 0)
                        {
                            glline.c2g__Value__c = (-1)*amount;    
                        }
                        else
                        {
                            glline.c2g__Value__c = amount;
                        }
                        
                        // Set Journal Rate If Not Home Currency
                        if (mapOfCurrency != null && mapOfCurrency.containskey(journal.AH_SAP_Transaction__r.Document_Currency__c) && mapOfCurrency.get(journal.AH_SAP_Transaction__r.Document_Currency__c).c2g__Home__c != true)
                        {
                            glline.c2g__JournalRate__c = journal.AH_SAP_Transaction__r.Document_Currency_Conversion__c;
                            accline.c2g__JournalRate__c = journal.AH_SAP_Transaction__r.Document_Currency_Conversion__c;
                        }
                        
                        accline.c2g__Journal__c = journal.Id;
                        accline.ffgl__DeriveLineNumber__c = true;
                        accline.c2g__DeriveLineNumber__c = true;   
                        accline.c2g__LineType__c = 'Account - Customer';
                        accline.c2g__LineDescription__c = journal.AH_SAP_Transaction__r.Invoice_Number__c;
                        accline.c2g__Value__c = amount;
                        
                        if (accountsMap != null && journal.AH_SAP_Transaction__r.Customer_Number__c != null && accountsMap.containskey(journal.AH_SAP_Transaction__r.Customer_Number__c))
                        {
                            glline.c2g__AccountAnalysis__c = accountsMap.get(journal.AH_SAP_Transaction__r.Customer_Number__c).Id;
                            accline.c2g__AccountAnalysis__c = accountsMap.get(journal.AH_SAP_Transaction__r.Customer_Number__c).Id;
                            accline.c2g__Account__c = accountsMap.get(journal.AH_SAP_Transaction__r.Customer_Number__c).Id;
                            accline.c2g__GeneralLedgerAccount__c = accountsMap.get(journal.AH_SAP_Transaction__r.Customer_Number__c).c2g__CODAAccountsReceivableControl__c;
                        }
                        
                        if (journal.c2g__OwnerCompany__c != null)
                        {
                            glline.c2g__OwnerCompany__c = journal.c2g__OwnerCompany__c;
                            glline.c2g__Dimension2__c = journal.c2g__OwnerCompany__r.c2g__CustomerWriteOffDimension2__c; 
                            glline.c2g__Dimension3__c = journal.c2g__OwnerCompany__r.c2g__CustomerWriteOffDimension3__c;
                            glline.c2g__GeneralLedgerAccount__c = journal.c2g__OwnerCompany__r.c2g__CustomerWriteOff__c;
                            
                            accline.c2g__OwnerCompany__c = journal.c2g__OwnerCompany__c;
                            accline.c2g__Dimension2__c = journal.c2g__OwnerCompany__r.c2g__CustomerWriteOffDimension2__c; 
                            accline.c2g__Dimension3__c = journal.c2g__OwnerCompany__r.c2g__CustomerWriteOffDimension3__c;
                        }
                        
                        insertListOfJournalLineItem.add(glline);
                        insertListOfJournalLineItem.add(accline);
                        
                        // Update AH Sap Transaction with journal
                        if (mapOfSAPTrans != null && journal.AH_SAP_Transaction__c != null && mapOfSAPTrans.containskey(journal.AH_SAP_Transaction__c))
                        {
                            AH_SAP_Transaction__c sapTransaction = mapOfSAPTrans.get(journal.AH_SAP_Transaction__c);
                            sapTransaction.FFA_Journal__c = journal.Id;
                            sapTransaction.FFA_Processing_Date_Time__c = System.Now();
                            sapTransaction.FFA_Processing_Status__c = 'Processed Successfully';
                            updateSapTransList.add(sapTransaction);
                        }
                        
                        // Create Transaction Records
                        companyWrapper.CompanyName = journal.c2g__OwnerCompany__r.Name;
                        c2g.CODAAPICommon.Reference journalWrapper = new c2g.CODAAPICommon.Reference();
                        journalWrapper.id = journal.Id;
                        listOfPostJournal.add(journalWrapper);
                    }   
                }
                
                // Insert Journal Line Item
                if (insertListOfJournalLineItem != null && insertListOfJournalLineItem.size() != 0)
                {
                    Database.SaveResult[] srList = Database.insert(insertListOfJournalLineItem, false);
                
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) 
                    {
                        if (sr.isSuccess()) 
                        {
                            // Operation was successful, so get the ID of the record that was processed
                            journalIds.add(sr.getId());
                        }
                        else 
                        {             
                            for (Database.Error err : sr.getErrors()) 
                            {
                                // Operation failed, so get all errors   
                                system.debug('The following error has occurred ==>'+err.getStatusCode() + ': ' + err.getMessage() + '. Fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                    //insert insertListOfJournalLineItem;
                }
                
                if (updateSapTransList != null && updateSapTransList.size() != 0)
                {
                    // Update AH Sap Transaction with Journals
                    update updateSapTransList;
                    
                    // Post Journals in bulk.
                    if (companyWrapper != null && listOfPostJournal != null && listOfPostJournal.Size() != 0)
                    {
                        c2g.CODAAPIJournal_12_0.BulkPostJournal(companyWrapper, listOfPostJournal);    
                    }
                    
                    set<Id> transIds = new set<Id>();
                    
                    // Match Journals in bulk.
                    c2g.CODAAPICashMatchingTypes_8_0.Configuration configuration2 = new c2g.CODAAPICashMatchingTypes_8_0.Configuration();
                    configuration2.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_8_0.enumMatchingCurrencyMode.Document;
                    
                    c2g.CODAAPICommon_8_0.Context context = new c2g.CODAAPICommon_8_0.Context();
                    c2g.CODAAPICashMatchingTypes_8_0.Analysis analysisInfoAPI = new c2g.CODAAPICashMatchingTypes_8_0.Analysis();
                    
                    for (c2g__codaTransaction__c trans : [SELECT Id, SystemModstamp, c2g__OwnerCompany__c, c2g__OwnerCompany__r.Name, c2g__Period__c, c2g__Period__r.c2g__StartDate__c,
                                                          c2g__OwnerCompany__r.c2g__CustomerSettlementDiscount__c, c2g__OwnerCompany__r.c2g__CustomerWriteOff__c, c2g__Journal__c,
                                                          c2g__Account__c, c2g__TransactionType__c 
                                                          FROM c2g__codaTransaction__c 
                                                          WHERE c2g__Journal__c IN : journalIds])
                    {
                        configuration2.Account = c2g.CODAAPICommon.getRef(trans.c2g__Account__c, null);
                        configuration2.MatchingDate = trans.c2g__Period__r.c2g__StartDate__c;
                        configuration2.DiscountDate = System.today();
                        configuration2.MatchingPeriod = c2g.CODAAPICommon.getRef(trans.c2g__Period__c, null);
                        
                        context.CompanyName = trans.c2g__OwnerCompany__r.Name;
                        
                        analysisInfoAPI.DiscountGLA = c2g.CODAAPICommon.getRef(trans.c2g__OwnerCompany__r.c2g__CustomerSettlementDiscount__c, null);
                        analysisInfoAPI.WriteOffGLA = c2g.CODAAPICommon.getRef(trans.c2g__OwnerCompany__r.c2g__CustomerWriteOff__c, null);
                        transIds.add(trans.Id);
                    }
                    
                    System.debug('transIds==>'+analysisInfoAPI);
                    
                    if (transIds != null && transIds.size() != 0)
                    {
                        
                        List<Id> transLineIds = new List<Id>();
                        List<c2g.CODAAPICashMatchingTypes_8_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_8_0.Item>();
                        
                        for (c2g__codaTransactionLineItem__c transLine : [SELECT Id, SystemModstamp, c2g__LineType__c 
                                                                          FROM c2g__codaTransactionLineItem__c 
                                                                          WHERE c2g__LineType__c = 'Account' 
                                                                          AND c2g__Transaction__c IN : transIds])
                        {
                            transLineIds.add(transLine.Id);
                            c2g.CODAAPICashMatchingTypes_8_0.Item item = new c2g.CODAAPICashMatchingTypes_8_0.Item();
                            items.add(item);
                            item.TransactionLineItem = c2g.CODAAPICommon.getRef(transLine.Id, null);
                            item.TransactionLineItemSystemModStamp = transLine.SystemModstamp;
                        }              
                        System.debug('transLineIds==>'+transLineIds);
                        if (transLineIds != null && transLineIds.Size() != 0)
                        {
                            c2g.BackgroundMatchingService.Configuration configuration = new c2g.BackgroundMatchingService.Configuration();
                            configuration.MatchType = c2g.BackgroundMatchingService.MatchType.DocumentReference;
                            c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_8_0.Match(context, configuration2, items, analysisInfoAPI);
                            System.debug('matchReference==>'+matchReference);
                        }
                    }
                    
                }
                
            }  
            
        }    
        catch (Exception e) 
        {
            system.debug(' **** Error Occured: ' + e.getMessage()+'-Line-'+e.getLineNumber());
        }    
    }
    
    // =============================================================================
    // This method creates Cash Entry records From SAP Transactions
    // =============================================================================
    public static void createCashEntry(List<AH_SAP_Transaction__c> sapTrasList) 
    { 
        
        system.debug('  in createCashEntry ... ');

        if (sapTrasList != null && sapTrasList.size() != 0)
        {
            String CurrentCompany = c2g.CODAAPICompany_2_0.GetCurrentCompanies(null)[0];
            Map<String, c2g__codaCashEntryLineItem__c> mapOfCEL = new Map<String, c2g__codaCashEntryLineItem__c>();
            Map<String, AH_SAP_Transaction__c> mapOfSAPTrans = new Map<String, AH_SAP_Transaction__c>();
            Map<String, c2g__codaCompany__c> ffaCompanyMap = new Map<String, c2g__codaCompany__c>();
            Map<String, c2g__codaBankAccount__c> bankAccountsMap = new Map<String, c2g__codaBankAccount__c>();
            Map<String, Account> accountsMap = new Map<String, Account>();
            Set<String> accountNumbers = new Set<String>();
            List<c2g__codaCashEntry__c> insertListOfCE = new list<c2g__codaCashEntry__c>();
            List<c2g__codaCashEntryLineItem__c> insertListOfCEL = new List<c2g__codaCashEntryLineItem__c>();
            
            for (c2g__codaCompany__c ffaCompany : [SELECT Id, Name,c2g__BankAccount__c,c2g__BankAccount__r.c2g__BankAccountCurrency__c,c2g__CustomerWriteOff__c 
                                                   FROM c2g__codaCompany__c])
            {
                ffaCompanyMap.put(ffaCompany.Name, ffaCompany);
            }
            
            for (c2g__codaBankAccount__c bankAccount : [SELECT Id, Name, c2g__BankAccountCurrency__c,c2g__AccountNumber__c,c2g__Dimension1__c,c2g__Dimension4__c,
                                                        c2g__Dimension2__c,c2g__Dimension3__c,c2g__OwnerCompany__c 
                                                        FROM c2g__codaBankAccount__c])
            {
                bankAccountsMap.put(bankAccount.c2g__AccountNumber__c, bankAccount);
            }
            
            Map<String,c2g__codaPeriod__c> mapOfCurrentPeriod = new Map<String,c2g__codaPeriod__c>();
            
            for(c2g__codaPeriod__c currentPeriod : [SELECT Id, c2g__OwnerCompany__c, c2g__OwnerCompany__r.Name 
                                                    FROM c2g__codaPeriod__c 
                                                    WHERE c2g__Description__c = 'Trading Period' 
                                                    AND c2g__StartDate__c = THIS_MONTH 
                                                    AND c2g__EndDate__c = THIS_MONTH])
            {
                mapOfCurrentPeriod.put(currentPeriod.c2g__OwnerCompany__r.Name,currentPeriod);
            }
            
            system.debug('CurrentCompany==>' + CurrentCompany);
            
            for (AH_SAP_Transaction__c saptrans : sapTrasList) 
            {
                
                c2g__codaCashEntry__c newCashEntry = new c2g__codaCashEntry__c();
                
                system.debug('bankAccountsMap==>'+bankAccountsMap);
                
                if (bankAccountsMap != null && bankAccountsMap.containskey(saptrans.Bank_Account_Number__c))
                {
                    newCashEntry.c2g__BankAccount__c = bankAccountsMap.get(saptrans.Bank_Account_Number__c).Id;
                }
                
                // Add FFACompany
                if (ffaCompanyMap != null && ffaCompanyMap.containskey(saptrans.FFA_Company__c))
                {
                    newCashEntry.c2g__OwnerCompany__c = ffaCompanyMap.get(saptrans.FFA_Company__c).Id;
                    
                    System.debug('BankAccount==>'+newCashEntry.c2g__BankAccount__c);
                    System.debug('mapOfCurrentPeriod==>'+mapOfCurrentPeriod);
                    
                    // Add FFA Company Bank Account if transaction is missing a value for the Bank Account Number field
                    if (newCashEntry.c2g__BankAccount__c == null)
                    {
                        system.debug('FFACompany==>'+saptrans.FFA_Company__c);
                        newCashEntry.c2g__BankAccount__c = ffaCompanyMap.get(saptrans.FFA_Company__c).c2g__BankAccount__c;
                        newCashEntry.c2g__CashEntryCurrency__c = ffaCompanyMap.get(saptrans.FFA_Company__c).c2g__BankAccount__r.c2g__BankAccountCurrency__c;
                        
                        if (mapOfCurrentPeriod != null && mapOfCurrentPeriod.containskey(saptrans.FFA_Company__c))
                        {
                            newCashEntry.c2g__Period__c = mapOfCurrentPeriod.get(saptrans.FFA_Company__c).Id;  
                        }
                    }
                    
                    system.debug('Period==>'+newCashEntry.c2g__Period__c);
                    system.debug('BankAccount==>'+newCashEntry.c2g__BankAccount__c);
                    
                }
                
                newCashEntry.c2g__Date__c = saptrans.Posting_Date__c;
                newCashEntry.ffcash__DeriveBankAccount__c = true;
                newCashEntry.ffcash__DeriveBankAccountDimensions__c = true;
                newCashEntry.ffcash__DeriveBankChargesAnalysis__c = true;
                newCashEntry.ffcash__DeriveCurrency__c = true;
                newCashEntry.ffcash__DerivePeriod__c = true;
                newCashEntry.c2g__Description__c = 'SAP TRANSACTION';
                newCashEntry.c2g__Reference__c = saptrans.Bank_Reference_Number__c;
                newCashEntry.c2g__Type__c = saptrans.FFA_Transaction_Type__c ;
                newCashEntry.AH_SAP_Transaction__c = saptrans.Id;
                insertListOfCE.add(newCashEntry);
                mapOfSAPTrans.put(saptrans.Id, saptrans);
                
                // Cash Entry Line Item
                c2g__codaCashEntryLineItem__c celi = new c2g__codaCashEntryLineItem__c();
                if (saptrans.Customer_Number__c != null)
                {
                    accountNumbers.add(saptrans.Customer_Number__c);
                    celi.c2g__AccountReference__c = saptrans.Invoice_Number__c;
                    
                    String amountString = String.valueof(saptrans.Document_Amount__c);
                    amountString = amountString.replace('-', '');
                    Decimal amount = Decimal.valueof(amountString);
                    
                    // Check negative Value
                    /* if (amount < 0.00)
                    {
                    	celi.c2g__CashEntryValue__c = (-1)*amount;  
                    }
                    else
                    {
                    	celi.c2g__CashEntryValue__c = amount;  
                    }*/
                    celi.c2g__CashEntryValue__c = amount;
                    celi.ffcash__DeriveAccountDimensions__c = true;
                    celi.ffcash__DeriveLineNumber__c = true;
                    celi.ffcash__DerivePaymentMethod__c = true;
                    celi.c2g__LineDescription__c = saptrans.Line_Description__c;
                    mapOfCEL.put(saptrans.Id, celi);
                }    
                
            }     
            
            try 
            {
                
                Set<Id> cashEntryIds = new Set<Id>();
                
                if (insertListOfCE != null && insertListOfCE.Size() != 0)
                {
                    System.debug('insertListOfCE==>'+insertListOfCE);
                    Database.SaveResult[] srList = Database.insert(insertListOfCE, false);
                    // Iterate through each returned result
                    Map<Id, String> failedSapTransMapRecords = New Map<Id, String>();
                    
                    Integer recordid = 0;
                    for (Database.SaveResult sr : srList) 
                    {
                        if (sr.isSuccess()) 
                        {
                            // Operation was successful, so get the ID of the record that was processed
                            cashEntryIds.add(sr.getId());
                        }
                        else 
                        {
                            system.debug('EntryId ==>'+insertListOfCE[recordid].AH_SAP_Transaction__c +'-Msg==>'+sr.getErrors());
                            failedSapTransMapRecords.put(insertListOfCE[recordid].AH_SAP_Transaction__c,sr.getErrors()[0].getMessage());
                            recordid++;
                            
                            for (Database.Error err : sr.getErrors()) 
                            {
                                // Operation failed, so get all errors   
                                System.debug('The following error has occurred ==>' + err.getStatusCode() + ': ' + err.getMessage() + ', fields that affected this error: ' + err.getFields()+'-Fields==>'+err.fields);
                            }
                        }
                    }
                    
                    if (failedSapTransMapRecords != null)
                    {
                        // Update failed Sap Transaction with Errors
                      
                        List<AH_SAP_Transaction__c> updatefailedsapTrans = new List<AH_SAP_Transaction__c>();
                        for(ID transId : failedSapTransMapRecords.keyset())
                        {
                            if(failedSapTransMapRecords.containskey(transId))
                            {
                                AH_SAP_Transaction__c failedsapTrans = new AH_SAP_Transaction__c();
                                failedsapTrans.id = transId;
                                failedsapTrans.FFA_Processing_Date_Time__c = System.Now();
                                failedsapTrans.FFA_Processing_Status__c = failedSapTransMapRecords.get(transId);
                                updatefailedsapTrans.add(failedsapTrans);
                            }
                        }
                        
                        if(updatefailedsapTrans != null && updatefailedsapTrans.size() != 0)
                        {
                            update updatefailedsapTrans;
                        }  
                    }
                    System.debug('failedSapTransMapRecords==>'+failedSapTransMapRecords);
                } 
                
                if (cashEntryIds != null && cashEntryIds.Size() != 0)
                {
                    
                    List<AH_SAP_Transaction__c> updateSapTransList = new List<AH_SAP_Transaction__c>();
                    
                    if (accountNumbers != null && accountNumbers.size() != 0)
                    {
                        for (Account acc : [SELECT Id, Name, Type, AccountNumber FROM Account WHERE AccountNumber IN : accountNumbers])
                        {
                            accountsMap.put(acc.AccountNumber, acc);
                        }
                    }
                    
                    List<c2g.CODAAPICommon.Reference> listOfPostCashEntry = new List<c2g.CODAAPICommon.Reference>();
                    Map<String,List<c2g.CODAAPICommon.Reference>> mapOfCashEntryForPost = new Map<String,List<c2g.CODAAPICommon.Reference>>();
                    
                    c2g.CODAAPICommon_7_0.Context companyWrapper = new c2g.CODAAPICommon_7_0.Context();
                    
                    for (c2g__codaCashEntry__c cashEntry : [SELECT Id,OwnerId, AH_SAP_Transaction__c, AH_SAP_Transaction__r.Customer_Number__c, c2g__Date__c, c2g__OwnerCompany__c, c2g__OwnerCompany__r.Name 
                                                            FROM c2g__codaCashEntry__c 
                                                            WHERE Id IN : cashEntryIds])
                    {
                        if (mapOfCEL != null && cashEntry.AH_SAP_Transaction__c != null && mapOfCEL.containskey(cashEntry.AH_SAP_Transaction__c))
                        {
                            c2g__codaCashEntryLineItem__c celi = mapOfCEL.get(cashEntry.AH_SAP_Transaction__c);
                            celi.c2g__CashEntry__c = cashEntry.Id;
                            //celi.OwnerId = cashEntry.OwnerId;
                            
                            if (accountsMap != null && cashEntry.AH_SAP_Transaction__r.Customer_Number__c != null && accountsMap.containskey(cashEntry.AH_SAP_Transaction__r.Customer_Number__c))
                            {
                                celi.c2g__Account__c = accountsMap.get(cashEntry.AH_SAP_Transaction__r.Customer_Number__c).Id;
                            }   
                            insertListOfCEL.add(celi);
                        }
                        
                        if (mapOfSAPTrans != null && cashEntry.AH_SAP_Transaction__c != null && mapOfSAPTrans.containskey(cashEntry.AH_SAP_Transaction__c))
                        {
                            // Update AH Sap Transaction with cash entries
                            AH_SAP_Transaction__c sapTransaction = mapOfSAPTrans.get(cashEntry.AH_SAP_Transaction__c);
                            sapTransaction.FFA_Cash_Entry__c = cashEntry.Id;
                            sapTransaction.FFA_Processing_Date_Time__c = System.Now();
                            sapTransaction.FFA_Processing_Status__c = 'Processed Successfully';
                            updateSapTransList.add(sapTransaction);
                        }
                        
                        // Create Transaction Records
                        //companyWrapper.CompanyName = cashEntry.c2g__OwnerCompany__r.Name;
                        c2g.CODAAPICommon.Reference cashEntryWrapper = new c2g.CODAAPICommon.Reference();
                        cashEntryWrapper.id = cashEntry.Id;
                        listOfPostCashEntry.add(cashEntryWrapper);
                        
                        if(mapOfCashEntryForPost != null && mapOfCashEntryForPost.containskey(cashEntry.c2g__OwnerCompany__r.Name))
                        {
                            mapOfCashEntryForPost.get(cashEntry.c2g__OwnerCompany__r.Name).add(cashEntryWrapper);
                        }
                        else
                        {
                            mapOfCashEntryForPost.put(cashEntry.c2g__OwnerCompany__r.Name, new List<c2g.CODAAPICommon.Reference>{cashEntryWrapper});
                        }
                    }
                    
                    if (insertListOfCEL != null && insertListOfCEL.size() != 0)
                    {
                        Database.SaveResult[] srCLIList = Database.insert(insertListOfCEL, false);
                        // Iterate through each returned result
                        Map<Id,String> failedCelRecords = New Map<Id,String>();
                        List<Id> successCLIIds = new List<Id>();
                        Integer recordid = 0;
                        for (Database.SaveResult sr : srCLIList) 
                        {
                            if (sr.isSuccess()) 
                            {
                                // Operation was successful, so get the ID of the record that was processed
                                successCLIIds.add(sr.getId());
                            }
                            else 
                            {
                                System.debug('EntryId ==>'+insertListOfCEL[recordid].c2g__CashEntry__c +'-Msg==>'+sr.getErrors());
                                failedCelRecords.put(insertListOfCEL[recordid].c2g__CashEntry__c,sr.getErrors()[0].getMessage());
                                recordid++;
                                
                                for (Database.Error err : sr.getErrors()) 
                                {
                                    // Operation failed, so get all errors   
                                    System.debug('The following error has occurred ==>' + err.getStatusCode() + ': ' + err.getMessage() + ', fields that affected this error: ' + err.getFields()+'-Fields==>'+err.fields);
                                }
                            }
                        }
                        
                        System.debug('successCLIIds ==>'+successCLIIds);
                        System.debug('failedCelRecords==>'+failedCelRecords);
                        //insert insertListOfCEL;
                    }
                    
                    if (updateSapTransList != null && updateSapTransList.size() != 0)
                    {
                        
                        // Update AH Sap Transaction with cash entries
                        update updateSapTransList;
                        
                        // Post cash entries in bulk.
                        if (mapOfCashEntryForPost != null)
                        {
                            system.debug(' *^* companyWrapper = ' + companyWrapper + ', listOfPostCashEntry = '+ listOfPostCashEntry);                            
                            if (!Test.isRunningTest())
                            {
                                for(String companyName : mapOfCashEntryForPost.keyset())
                                {
                                    c2g.CODAAPICommon_7_0.Context companyWrap = new c2g.CODAAPICommon_7_0.Context();
                                    companyWrap.CompanyName = companyName;
                                    System.debug('companyWrap==>'+companyWrap.CompanyName);
                                    c2g.CODAAPICashEntry_7_0.BulkPostCashEntry(companyWrap, mapOfCashEntryForPost.get(companyName));
                                }
                            }
                        }
                        
                        Set<Id> transIds = new Set<Id>();
                        
                        // Matching Logic Code
                        c2g.CODAAPICashMatchingTypes_8_0.Configuration configuration2 = new c2g.CODAAPICashMatchingTypes_8_0.Configuration();
                        configuration2.MatchingCurrencyMode = c2g.CODAAPICashMatchingTypes_8_0.enumMatchingCurrencyMode.Document;
                        
                        c2g.CODAAPICommon_8_0.Context context = new c2g.CODAAPICommon_8_0.Context();
                        c2g.CODAAPICashMatchingTypes_8_0.Analysis analysisInfoAPI = new c2g.CODAAPICashMatchingTypes_8_0.Analysis();
                        
                        for (c2g__codaTransaction__c trans : [SELECT Id, SystemModstamp, c2g__OwnerCompany__c, c2g__OwnerCompany__r.Name, c2g__Period__c, c2g__Period__r.c2g__StartDate__c,
                                                              c2g__OwnerCompany__r.c2g__CustomerSettlementDiscount__c, c2g__OwnerCompany__r.c2g__CustomerWriteOff__c,
                                                              c2g__Account__c, c2g__TransactionType__c 
                                                              FROM c2g__codaTransaction__c 
                                                              WHERE c2g__CashEntry__c IN : cashEntryIds])
                        {
                            configuration2.Account = c2g.CODAAPICommon.getRef(trans.c2g__Account__c, null);
                            configuration2.MatchingDate = trans.c2g__Period__r.c2g__StartDate__c;
                            configuration2.DiscountDate = System.today();
                            configuration2.MatchingPeriod = c2g.CODAAPICommon.getRef(trans.c2g__Period__c, null);
                            
                            context.CompanyName = trans.c2g__OwnerCompany__r.Name;
                            
                            analysisInfoAPI.DiscountGLA = c2g.CODAAPICommon.getRef(trans.c2g__OwnerCompany__r.c2g__CustomerSettlementDiscount__c, null);
                            analysisInfoAPI.WriteOffGLA = c2g.CODAAPICommon.getRef(trans.c2g__OwnerCompany__r.c2g__CustomerWriteOff__c, null);
                            transIds.add(trans.Id);
                        }
                        System.debug('transIds==>'+transIds);
                        
                        if (transIds != null && transIds.size() != 0)
                        {
                            List<Id> transLineIds = new List<Id>();
                            List<c2g.CODAAPICashMatchingTypes_8_0.Item> items = new List<c2g.CODAAPICashMatchingTypes_8_0.Item>();
                            
                            for (c2g__codaTransactionLineItem__c transLine : [SELECT Id, SystemModstamp, c2g__LineType__c 
                                                                              FROM c2g__codaTransactionLineItem__c 
                                                                              WHERE c2g__LineType__c = 'Account' 
                                                                              AND c2g__Transaction__c IN : transIds])
                            {
                                transLineIds.add(transLine.Id);
                                c2g.CODAAPICashMatchingTypes_8_0.Item item = new c2g.CODAAPICashMatchingTypes_8_0.Item();
                                items.add(item);
                                item.TransactionLineItem = c2g.CODAAPICommon.getRef(transLine.Id, null);
                                item.TransactionLineItemSystemModStamp = transLine.SystemModstamp;
                            }
                            
                            System.debug('transLineIds==>'+transLineIds);
                            if (!transLineIds.isEmpty())
                            {
                                c2g.CODAAPICommon.Reference matchReference = c2g.CODAAPICashMatching_8_0.Match(context, configuration2, items, analysisInfoAPI);
                            	System.debug('matchReference==>'+matchReference);
                            }
                        }
                    }
                }
                
            }    
            catch (Exception e) 
            {
                system.debug(' **** Error Occured: ' + e.getMessage()+'-line-'+e.getLineNumber());
            }
        }
    }
    
}