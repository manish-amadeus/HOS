/************************************************************************************************
Name            : NI_Invoice_Detail_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 10/26/2015
Last Mod Date   : 11/3/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-015836
Description     : Class that handles all trigger code for the NI_Invoice_Detail__c Object
                :
*************************************************************************************************/

public class NI_Invoice_Detail_TriggerHandler {
    
    public NI_Invoice_Detail_TriggerHandler()
    {
        
    }
    
    //========================================================================================================================
    public void OnBeforeInsert(List<NI_Invoice_Detail__c> newTrigger)
    {
        Set_CustomerAgreementField(newTrigger);
        Set_TotalPriceField(newTrigger);
    }
    
    //========================================================================================================================
    public void OnAfterInsert(List<NI_Invoice_Detail__c> newTrigger)
    {
        Create_Amortization_Distribution_Records(newTrigger);
    }
    
    //=========================================================================================================================          
    //THIS METHOD POPULATES THE CUSTOMER AGREEMENT FIELD ON THE NI INVOICE DETAILS RECORD
    //=========================================================================================================================
    public void Set_CustomerAgreementField(List<NI_Invoice_Detail__c> newTrigger)
    {   
        System.debug(' *** ENTERING NI_Invoice_Detail_TriggerHandler.Set_CustomerAgreementField()');
        
        Set<Id> setInvIds = new Set<Id>();
        
        for (NI_Invoice_Detail__c iDetail : newTrigger)
        {
          setInvIds.add(iDetail.NI_Invoice__c);  
        }
            
         //MAP OF NI INVOICE RECORDS RELATED TO THE NI INVOICE DETAIL RECORDS
            Map<Id,NI_Invoice__c> mapInvoices = new Map<Id,NI_Invoice__c> ([SELECT Id, Account__c, Opportunity__c
                                                                            FROM NI_Invoice__c
                                                                            WHERE Id IN: setInvIds]);
        
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        
        for(NI_Invoice_Detail__c invDet : newTrigger)
        {
            System.debug('INVOICE ACCOUNT ID: ' + mapInvoices.get(invDet.NI_Invoice__c).Account__c);
            setAccountIds.add(mapInvoices.get(invDet.NI_Invoice__c).Account__c);
            
            System.debug('INVOICE DETAIL PRODUCT: ' + invDet.Product__c);
            setProductIds.add(invDet.Product__c);  
        }
        
        
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Account__c, Product__c, Opportunity__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Account__c IN: setAccountIds
                                                                AND Product__c IN: setProductIds
                                                                AND (Status__c = 'Active'
                                                                OR Status__c = 'Renewal')];
        
        System.debug('NUMBER OF CUSTOMER AGREEMENTS: ' + lstCustomerAgreements.size());
        
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        for (NI_Customer_Agreement__c ca : lstCustomerAgreements)
        {
          setOpportunityIds.add(ca.Opportunity__c);
        }
        
        List<OpportunityLineItem> lstOppProducts = [SELECT Id, OpportunityId, Opportunity.AccountId, PricebookEntry.Product2Id, Quantity, TotalPrice 
                                                  FROM OpportunityLineItem
                                                  WHERE opportunityId IN: setOpportunityIds];
        
        Map<Id,OpportunityLineItem> mapOppProducts = new Map<Id,OpportunityLineItem>();
            
        for(OpportunityLineItem oli : lstOppProducts)
        {
          mapOppProducts.Put(oli.Opportunity.AccountId, oli);   
        }
        
        //PERFORM THE NEXT STEPS IF THERE ARE CUSTOMER AGREEMENT RECORDS
        If(lstCustomerAgreements.size()>0)
        {   
            for(NI_Invoice_Detail__c invDetails : newTrigger)
            {   
                for(NI_Customer_Agreement__c cAgreement : lstCustomerAgreements)
                {
                    if((mapInvoices.get(invDetails.NI_Invoice__c).Account__c == cAgreement.Account__c) && (invDetails.Product__c == cAgreement.Product__c))
                    {
                        invDetails.Customer_Agreement__c = cAgreement.Id;   
                    }       
                }
            }
        }       
    }
    //===================================================================================================================================================          
    //THIS METHOD POPULATES THE TOTAL PRICE FIELD ON THE NI INVOICE DETAILS RECORD BASED ON THE TOTAL PRICE ON THE RELATED OPPORTUNITY LINE ITEM RECORD
    //===================================================================================================================================================
    public void Set_TotalPriceField(List<NI_Invoice_Detail__c> newTrigger)
    {    
        Set<Id> setInvIds = new Set<Id>();
        
        for (NI_Invoice_Detail__c iDetail : newTrigger)
        {
          setInvIds.add(iDetail.NI_Invoice__c);  
        }
            
         //MAP OF NI INVOICE RECORDS RELATED TO THE NI INVOICE DETAIL RECORDS
            Map<Id,NI_Invoice__c> mapInvoices = new Map<Id,NI_Invoice__c> ([SELECT Id, Account__c, Opportunity__c
                                                                            FROM NI_Invoice__c
                                                                            WHERE Id IN: setInvIds]);
        
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setProductIds = new Set<Id>();
        
        for(NI_Invoice_Detail__c invDet : newTrigger)
        {
            setAccountIds.add(mapInvoices.get(invDet.NI_Invoice__c).Account__c);
            setProductIds.add(invDet.Product__c);  
        }
        
        Set<Id> setOpportunityIds = new Set<Id>();
        
        List<OpportunityLineItem> lstOppProducts = [SELECT Id, OpportunityId, Opportunity.AccountId, PricebookEntry.Product2Id, Quantity, TotalPrice 
                                                  FROM OpportunityLineItem
                                                  WHERE Opportunity.AccountId IN: setAccountIds
                                                  AND PricebookEntry.Product2Id IN: setProductIds];
        
        Map<Id,OpportunityLineItem> mapOppProducts = new Map<Id,OpportunityLineItem>();
            
        for(OpportunityLineItem oli : lstOppProducts)
        {
          mapOppProducts.Put(oli.Opportunity.AccountId, oli);   
        }
        
        //PERFORM THE NEXT STEPS IF THERE ARE OPPORTUNITY PRODUCT RECORDS
        If(lstOppProducts.size()>0)
        {   
            for(NI_Invoice_Detail__c invDetails : newTrigger)
            {   
                for(OpportunityLineItem oppLineItem : lstOppProducts)
                {
                    if((mapInvoices.get(invDetails.NI_Invoice__c).Opportunity__c == oppLineItem.OpportunityId) && (invDetails.Product__c == oppLineItem.PricebookEntry.Product2Id))
                    {
                        invDetails.Total_Price__c = oppLineItem.TotalPrice;   
                    }  
               else if((mapInvoices.get(invDetails.NI_Invoice__c).Account__c == oppLineItem.Opportunity.AccountId) && (invDetails.Product__c == oppLineItem.PricebookEntry.Product2Id)
                      && (invDetails.Quantity__c == oppLineItem.Quantity))
                    {
                        invDetails.Total_Price__c = oppLineItem.TotalPrice;   
                    }       
                }
            }
        }       
    }
    
    //====================================================================================================================
    //THIS METHOD CREATES AMORTIZATION DISTRIBUTION RECORDS
    //==================================================================================================================
    public void Create_Amortization_Distribution_Records(List<NI_Invoice_Detail__c> newTrigger)
    {          
        System.debug(' *** ENTERING NI_Invoice_Detail_TriggerHandler.Create_Amortization_Distribution_Records()');
        
        Set<Id> setCustomerAgreementIds = new Set<Id>();
        
        for(NI_Invoice_Detail__c invDet : newTrigger)
        {
          setCustomerAgreementIds.add(invDet.Customer_Agreement__c);  
        }
        
        //LIST OF INVOICE DETAIL CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        //THIS LIST IS PASSED TO THE Create_Amortization_Distribution_Records METHOD IN THE 
        //NI_Customer_Agreement_TriggerHandler CLASS
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Product_Family__c 
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: setCustomerAgreementIds
                                                                AND Product_Family__c = 'Services'];
          
        System.debug('NUMBER OF INVOICE DETAIL CUSTOMER AGREEMENT RECORDS: ' + lstCustomerAgreements.size());
        
        if(lstCustomerAgreements.size()>0)
        {
            NI_Customer_Agreement_TriggerHandler handler = new NI_Customer_Agreement_TriggerHandler();
            handler.Create_Amortization_Distribution_Records(lstCustomerAgreements,true);  
        }
    }
  /*  
    //====================================================================================================================
    //THIS METHOD UPDATES SERVICES ROYALTY DISTRIBUTION RECORDS
    //==================================================================================================================
    public void Update_ServicesRoyaltyDistributionRecords(List<NI_Invoice_Detail__c> newTrigger)
    {          
        
        Set<Id> setCustomerAgreementIds = new Set<Id>();
        
        for(NI_Invoice_Detail__c invDet : newTrigger)
        {
          setCustomerAgreementIds.add(invDet.Customer_Agreement__c);  
        }
        
        //LIST OF INVOICE DETAIL CUSTOMER AGREEMENT RECORDS TO USE FOR DISTRIBUTION RECORD CREATION
        //THIS LIST IS PASSED TO THE Create_Amortization_Distribution_Records METHOD IN THE 
        //NI_Customer_Agreement_TriggerHandler CLASS
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Product_Family__c 
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: setCustomerAgreementIds
                                                                AND Product_Family__c = 'Services'];
          
        System.debug('NUMBER OF INVOICE DETAIL CUSTOMER AGREEMENT RECORDS: ' + lstCustomerAgreements.size());
        
        if(lstCustomerAgreements.size()>0)
        {
            NI_Customer_Agreement_TriggerHandler handler = new NI_Customer_Agreement_TriggerHandler();
            handler.Create_Royalty_Distribution_Records(lstCustomerAgreements,true);  
        }
    }
*/
}