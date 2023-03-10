/************************************************************************************************
Name            : AH_BatchCreateInvoices Class
Author          : Bhuleshwar Deshpande
Created Date    : 11/09/2018
Last Mod Date   : 01/24/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Batch class for AH_Schedule_SalesInvoices schedulable class.
				: Query Billing Contract Line Item records & create invoices.
				: 
				:
*************************************************************************************************/
global class AH_BatchCreateInvoices implements Database.Batchable <sObject>, Database.AllowsCallouts, Database.Stateful 
{
    
    AH_ManageSalesInvoicesController ctrl = new AH_ManageSalesInvoicesController();
    Set<String> bcQueryIds = new Set<String>();
    
    // CONSTRUCTOR
    global AH_BatchCreateInvoices(Set<String> idList)
    {
        system.debug(' **** idList = ' + idList);
        bcQueryIds.addAll(idList);
        system.debug(' **** bcQueryIds = ' + bcQueryIds);
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
        
        system.debug(' **** companyIds = ' + companyIds);
        
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
                            ' Total_Amount__c, '+
                            ' Invoiced__c, '+
                            ' Ready_to_Invoice__c, '+
                            ' Invoice_Date__c '+
                            ' FROM Billing_Contract_Line_Items__r '+
                            ' WHERE  Ready_to_Invoice__c = true '+
                            ' AND Type__c != \'Credit\' '+
                            ' AND Total_Amount__c >= 0 '+
                            //' AND Exclude_Automated_Invoicing__c = false '+
                            ' AND Invoiced__c = false ';
			
			if (Test.isRunningTest() == false)
			{
				retQuery += ' AND Activity_Line_Item__r.Origin__c = \'Renewal\'';
				retQuery += ' AND Billing_Contract__r.Company__c IN : companyIds';
			}
						
			retQuery +=  ' ) FROM Billing_Contract__c ';
        	retQuery += ' WHERE Exclude_Automated_Invoicing__c = false AND Id IN : bcQueryIds ';  
        	retQuery += ' AND Company__c IN : companyIds ';  
        
        system.debug('Query = ' + retQuery);
        
        return Database.getQueryLocator(retQuery);
        
    }

    // EXECUTE METHOD
    global void execute (Database.BatchableContext bc1 , List<Billing_Contract__c> BCS)
    {
        
        //system.debug('billingLiItem : '+ billingLiItem);
        system.debug('Query result size : '+ BCS.size());
        system.debug('Query result : '+ BCS);
        
        try
        {
            
            List<AH_ManageSalesInvoicesController.bcliWrapper> wrapperList = new List<AH_ManageSalesInvoicesController.bcliWrapper>();
            List<AH_ManageSalesInvoicesController.bcWrapper> wrapList = new List<AH_ManageSalesInvoicesController.bcWrapper>();
            
            //AH_ManageSalesInvoicesController.totalRecordsCount = 0;
            
            for (Billing_Contract__c bc : BCS)
            {
                //if (!bc.Billing_Contract_Line_Items__r.isEmpty() && bc.Billing_Contract_Line_Items__r != null)
                if (bc.Billing_Contract_Line_Items__r != null)
                {
                    AH_ManageSalesInvoicesController.bcWrapper wr = new AH_ManageSalesInvoicesController.bcWrapper();
                    wr.check = true;
                    wr.processed = false;
                    wr.bc = bc;
                    //wr.processed = true;
                    List<AH_ManageSalesInvoicesController.bcliWrapper> bcliWrapList = new List<AH_ManageSalesInvoicesController.bcliWrapper>();
                    for (Billing_Contract_Line_Item__c bcli : bc.Billing_Contract_Line_Items__r)
                    {
                        AH_ManageSalesInvoicesController.bcliWrapper bcliWrap = new AH_ManageSalesInvoicesController.bcliWrapper();
                        bcliWrap.bcId = bcli.Billing_Contract__c;
                        bcliWrap.check = true;
                        bcliWrap.bcliObj = bcli;
                        bcliWrap.bcliObj.Invoice_Date__c = Date.today();
                        bcliWrapList.add(bcliWrap);
                        wrapperList.add(bcliWrap);
                        //AH_ManageSalesInvoicesController.totalRecordsCount++;
                    }
                    wr.bcliWrapperList = bcliWrapList;
                    wrapList.add(wr);
                }
            }
            
            // ASSIGN WRAPPER LIST TO CONTROLLER'S LIST
            ctrl.wrapList = wrapList.clone();
            ctrl.wrapperList = wrapperList.clone();
            ctrl.updateInvoiceDate();
            
            // CALL CREATE INVOICE METHOD
            ctrl.createInvoices();
            
            system.debug('After create invoice method : '+ctrl.SINWrapperList);
            
        }
        catch(Exception e)
        {
            system.debug('Error occured while executing a scheduled job... at line number : ' + e.getLineNumber() + ' => ' + e);
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_Schedule_SalesInvoices', 'INSERT');
        }
        
    }
    
    // FINISH METHOD
    global void finish (Database.BatchableContext bc) 
    {
        
        system.debug('in finish method...' + ctrl.SINWrapperList);
        
        try 
        {
            if (ctrl.SINWrapperList != null && !Test.isRunningTest())
            {
                ctrl.postInvoices();
            }
        }
        catch(Exception e)
        {
            system.debug('Error occured while executing a scheduled job... at line number : ' + e.getLineNumber() + ' => ' + e);
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','c2g__codaInvoice__c',  'AH_Schedule_SalesInvoices', 'UPDATE');
        }
        
    }
    
    //*********************************************************************************************************************************
    // USER DEFINED FUNCTIONS
    //*********************************************************************************************************************************    
    public List<c2g__codaCompany__c> getCurrentCompanies()
    {
        
        List<c2g__codaCompany__c> allCompanies = [SELECT Id, Ownerid, Name 
                                                  FROM c2g__codaCompany__c 
                                                  WHERE Exclude_from_Automated_Renewal_Invoicing__c = false];
        
        system.debug(' **** allCompanies = ' + allCompanies);
        
        Id currentUserId = UserInfo.getUserId();
        List<c2g__codaCompany__c> myCompanies = new List<c2g__codaCompany__c>();
        Set<Id> currentUserGroupIds = new Set<Id>();
        
        for (GroupMember gm :[SELECT Id, GroupId FROM GroupMember WHERE UserOrGroupId =: currentUserId]) 
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