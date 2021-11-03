/****************************************************************************************
Name            : AH_BillingContractLI_TriggerHandler
Author          : CLD Partners
Created Date    : 04/06/2017
Last Mod Date   : 06/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
				: 
******************************************************************************************/
public class AH_BillingContractLI_TriggerHandler 
{

    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    public AH_BillingContractLI_TriggerHandler()
    {

        system.debug(' *** ENTERING AH_BillingContractLI_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        system.debug(' *** EXITING AH_BillingContractLI_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());

    }


    // ======================================================================================================================== 
    //  PUBLIC ENTRY METHODS 
    // ========================================================================================================================  
    public void OnBeforeInsert(List<Billing_Contract_Line_Item__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
        updateTotalAmountExchangeRate(newTrigger);
		
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
                
    }

    public void OnBeforeUpdate(List<Billing_Contract_Line_Item__c> newTrigger, Map<Id, Billing_Contract_Line_Item__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        updateTotalAmountExchangeRate(newTrigger);
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
                
    }

    public void OnBeforeDelete(List<Billing_Contract_Line_Item__c> oldTrigger)
    {
        
        system.debug(' *** ENTERING AH_OpportunityLineItemTriggerHandler.OnBeforeDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        preventDelete(oldTrigger);
        
        system.debug(' *** EXITING AH_OpportunityLineItemTriggerHandler.OnBeforeDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    // ======================================================================================================================== 
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================       
    private void updateTotalAmountExchangeRate(List<Billing_Contract_Line_Item__c> newTrigger)
    {
        
        Set<String> currencySet = new Set<String>{'USD'};
        Set<Date> dateSet = new Set<Date>();
        
        for (Billing_Contract_Line_Item__c bcli : newTrigger)
        {
            currencySet.add(bcli.CurrencyIsoCode);
            dateSet.add(bcli.Invoice_Date__c);
        }
        
        Map<Date, Map<String, Decimal>> exchangeRateMap = ffaUtilities.loadConversionRates(currencySet, dateSet);
        
        for (Billing_Contract_Line_Item__c bcli : newTrigger)
        {
            Decimal exchangeRate = ffaUtilities.convertCurrencyRate(exchangeRateMap, bcli.CurrencyIsoCode, 'USD', bcli.Invoice_Date__c, bcli.Total_Amount__c);
            bcli.Total_Amount_USD__C = (exchangeRate * bcli.Total_Amount__c);
        }
        
    } 
    
    private void preventDelete(List<Billing_Contract_Line_Item__c> oldTrigger) 
    {
        
        for (Billing_Contract_Line_Item__c BCLIStatus : oldTrigger) 
        {
            if (BCLIStatus.Invoiced__c == true)
            {
                BCLIStatus.addError('Cannot delete a billing contract line item that has been invoiced.');
            } 
        }
        
//        if (Test.isRunningTest())
//        {
//            Integer test1 = 1;
//            test1 ++;
 //           test1 ++;
//            test1 ++;
//            test1 ++;
//            test1 ++;
//            test1 ++;
//            test1 ++;
//            test1 ++;
//            test1 ++;
//            test1 ++;
//        }
        
    }
    
}