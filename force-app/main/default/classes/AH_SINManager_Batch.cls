/************************************************************************************************
Name            : AH_SINManager_Batch Class
Author          : Bhuleshwar Deshpande
Created Date    : 11/09/2018
Last Mod Date   : 11/14/2019    
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Batch class for AH_SINManager_Sched_Renewals & AH_SINManager_Sched_NonRenewals schedulable class.
				: Query Billing Contract Line Item records & create invoices.
				: 
				:
*************************************************************************************************/
global class AH_SINManager_Batch implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful 
{
    
    AH_SINManager_FUNCTIONS sinFuncs = new AH_SINManager_FUNCTIONS();
    Set<String> bcQueryIds = new Set<String>();
    integer iMode;
    Boolean disableBtnFlag = false;
    // CONSTRUCTOR
    global AH_SINManager_Batch(Set<String> idList,integer Mode) 
    {
        bcQueryIds.addAll(idList);
        iMode=Mode;
    }
    
    // START METHOD
    global Database.QueryLocator start (Database.BatchableContext bc)
    {
        
        List<c2g__codaCompany__c> currentCompanies = getCurrentCompanies();
        Set<Id> companyIds = new Set<Id>();
        for (c2g__codaCompany__c c : currentCompanies)
        {
            companyIds.add(c.id);
        }
		system.debug('MODE VALUE  :' +  iMode);
        // ***************************************************
       // CHANGE IN EXISTING QUERY BY BHULESHWAR 
      //**************************************************//
           
        	 String retQuery = 'SELECT Id, Name, Account__c, ' +
            				' Account__r.Name, Ready_to_Invoice_Numeric__c, '+
            				' Company__c, Company__r.Name, '+
                            ' (SELECT ID, Name,'+ 
                            ' Billing_Contract__c, '+
                            ' Billing_Contract__r.Company__c, '+
                            ' Billing_Contract__r.Account__c, '+ 
                            ' Billing_Contract__r.Name, '+
                            ' Billing_Contract__r.Account__r.Name, '+
                            ' Billing_Contract__r.Company__r.Name, '+
                            ' Billing_Contract__r.Accounting_Currency__c, '+
                            ' Billing_Contract__r.Accounting_Currency__r.c2g__Home__c, '+
                            ' Billing_Contract__r.Accounting_Currency__r.c2g__Dual__c, '+
                            ' Billing_Contract__r.Account__r.c2g__CODATaxCalculationMethod__c, '+
                            ' Billing_Contract__r.Remittance_Info__c, '+
                            ' Billing_Contract__r.Opportunity__c,'+
                            ' Billing_Contract__r.Invoice_Date__c,'+
                            ' Billing_Contract__r.Collector__c,'+
                            ' Billing_Contract__r.Invoice_Due_Date__c,'+
                            ' Billing_Contract__r.Parent_Account_Id__c,'+
                            ' Billing_Contract__r.Summarize_Service_Lines__c,'+
                            ' Billing_Contract__r.PO_Number__c,'+
                            ' Billing_Contract__r.Bill_to_Contact__c,'+
                            ' Activity_Line_Item__r.Payment_Terms__c, '+
                            ' Activity_Line_Item__r.Name, '+
            				' Product__r.IsActive, ' +
                            ' Product__r.Dimension_3__c, '+
                            ' Product__r.Dimension_2__c, '+
                            ' Product__r.Dimension_3__r.Name, '+
                            ' Product__r.c2g__CODASalesRevenueAccount__c, '+
                            ' Activity_Line_Item__c,'+
                            ' Start_Date__c,'+
                            ' Unit_Price__c,'+
                            ' Dimension_2__c,'+
                            ' Quantity__c,'+
                            ' Product__c,'+
                            ' Dimension_3__c,'+
                            ' End_Date__c,'+
                            ' Line_Item_Description__c,'+
                            ' Total_Amount__c,'+    
                            ' Invoiced__c,'+
                            ' Ready_to_Invoice__c,'+
                            ' Invoice_Date__c'+
                            ' FROM Billing_Contract_Line_Items__r' +
                 			' WHERE  Ready_to_Invoice__c = true ' +
            				' AND Invoiced__c = false '+
            				' AND Total_Amount__c >= 0 ' +
            				' AND Type__c != \'Credit\' ' ;
                
        system.debug('iMode' + iMode);   
        
        if (Test.isRunningTest() == false)     
        {       
            if(iMode == 1)              
            {
                retQuery += ' AND Activity_Line_Item__r.Origin__c = \'Renewal\' ';
                retQuery += 'AND Billing_Contract__r.Company__r.Exclude_from_Automated_Renewal_Invoicing__c = false ' ;
            }
            else if(iMode == 2)    
            {      
               
                retQuery += 'AND Activity_Line_Item__r.Origin__c != \'Renewal\' ';
                retQuery += 'AND Billing_Contract__r.Company__r.Excl_frm_Automated_NonRenewal_Invoicing__c = false ' ;
                retQuery += 'AND Billing_Contract__r.Opportunity__r.Order_Status__c = \'Definite\' ';
            }
        }
        retQuery +=  ' ) FROM Billing_Contract__c ';
        retQuery += 'WHERE Exclude_Automated_Invoicing__c = false ';
        retQuery += ' AND Id IN : bcQueryIds ';  
        retQuery += ' AND Company__c IN : companyIds ';  
        retQuery += ' AND Billing_Hold__c = false ';
            
        system.debug('****bcQueryIds = ' + bcQueryIds);
        system.debug('****companyIds = ' + companyIds);
        system.debug('****retQuery = ' + retQuery);   
        
        return Database.getQueryLocator(retQuery);    
      
        
    }

    // EXECUTE METHOD
    global void execute (Database.BatchableContext bc1 , List<Billing_Contract__c> BCS)
    {

        try
        {
            
            List<AH_SINManager_FUNCTIONS.bcliWrapper> wrapperList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
            List<AH_SINManager_FUNCTIONS.bcWrapper> wrapList = new List<AH_SINManager_FUNCTIONS.bcWrapper>();

            system.debug('LIST OF BCS    :' + BCS);
            for (Billing_Contract__c bc : BCS)
            {
                if (bc.Billing_Contract_Line_Items__r != null)
                {
                    
                    AH_SINManager_FUNCTIONS.bcWrapper wr = new AH_SINManager_FUNCTIONS.bcWrapper();
                    
                    wr.check = true;
                    wr.processed = false;
                    wr.bc = bc;

                    List<AH_SINManager_FUNCTIONS.bcliWrapper> bcliWrapList = new List<AH_SINManager_FUNCTIONS.bcliWrapper>();
                    
                    for (Billing_Contract_Line_Item__c bcli : bc.Billing_Contract_Line_Items__r)
                    {
                        AH_SINManager_FUNCTIONS.bcliWrapper bcliWrap = new AH_SINManager_FUNCTIONS.bcliWrapper();
                        bcliWrap.bcId = bcli.Billing_Contract__c;
                        bcliWrap.check = true;
                        bcliWrap.bcliObj = bcli;
                        bcliWrap.bcliObj.Invoice_Date__c = Date.today();
                        bcliWrapList.add(bcliWrap);
                        wrapperList.add(bcliWrap);
                    }
                    wr.bcliWrapperList = bcliWrapList;
                    wrapList.add(wr);
                }
            }
            
            // ASSIGN WRAPPER LIST TO CONTROLLER'S LIST
            sinFuncs.wrapList = wrapList.clone();   
            sinFuncs.wrapperList = wrapperList.clone();
            sinFuncs.updateInvoiceDate(wrapperList);
            
            system.debug('BEFORE CREATE  INVOICE INSIDE SINMANAGER BATCH');
            // CALL CREATE INVOICE METHOD
            List<AH_SINManager_FUNCTIONS.SINWrapper> sinWrapLst = sinFuncs.createInvoices();
            sinFuncs.SINWrapperList = sinWrapLst;
			//sinFuncs.SINWrapperList(sinWrapLst);
			system.debug('**** sinWrapLst  :' +  sinWrapLst);
			system.debug('AFTER CREATE  INVOICE INSIDE SINMANAGER BATCH');    
        }     
        catch(Exception e)  
        {
            system.debug('Error occured while executing a scheduled job... at line number : ' + e.getLineNumber() + ' => ' + e);
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_SINManager_Batch', 'INSERT');
        }
        
    }
    
    // FINISH METHOD
    global void finish (Database.BatchableContext bc) 
    {
		system.debug('***** BEFORE TRY CATCH BLOCK INSIDE FINISH METHOD - IN SINMANAGER BATCH********');
        try 
        {
            system.debug('INSIDE FINISH sinFuncs.SINWrapperList  :' +  sinFuncs.SINWrapperList);
            if (sinFuncs.SINWrapperList != null && !Test.isRunningTest())
            {
                system.debug('BEFORE POST INVOICE INSIDE FINISH IN SINMANAGER BATCH');
                 Boolean postbutn = sinFuncs.postInvoices(disableBtnFlag);
                 system.debug(' POST INVICE CATCH RESULT  :' + postbutn );
            }
        }
        catch(Exception e) 
        {
            system.debug('Error occured while executing a scheduled job... at line number : ' + e.getLineNumber() + ' => ' + e);
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_SINManager_Batch', 'UPDATE');
        }  
        
    }
    
    //*********************************************************************************************************************************
    // USER DEFINED FUNCTIONS
    //*********************************************************************************************************************************    
    public List<c2g__codaCompany__c> getCurrentCompanies()
    {
        
        List<c2g__codaCompany__c> allCompanies = [SELECT Id, Ownerid, Name 
                                                  FROM c2g__codaCompany__c]; 
                                                  //WHERE Exclude_from_Automated_Renewal_Invoicing__c = false];

        Id currentUserId = UserInfo.getUserId();
        List<c2g__codaCompany__c> myCompanies = new List<c2g__codaCompany__c>();
        Set<Id> currentUserGroupIds = new Set<Id>();
        
        for (GroupMember gm : [SELECT Id, GroupId FROM GroupMember WHERE UserOrGroupId =: currentUserId]) 
        {
            currentUserGroupIds.add(gm.GroupId);
        }
        
        for (c2g__codaCompany__c company : allCompanies)
        {
            if (currentUserGroupIds.contains(company.ownerid))
            {
                myCompanies.add(company);
            }
        }
        
        return myCompanies;
        
    }
    
}