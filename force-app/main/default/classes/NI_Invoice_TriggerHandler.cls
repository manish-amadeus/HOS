/************************************************************************************************
Name            : NI_Invoice_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 11/3/2015
Last Mod Date   : 12/30/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-015836
Description     : Class that handles all trigger code for the NI_Invoice__c Object
                :
*************************************************************************************************/
public class NI_Invoice_TriggerHandler {
    
    public NI_Invoice_TriggerHandler()
    {
     
    }
    
    //========================================================================================================================
    public void OnBeforeInsert(List<NI_Invoice__c> newTrigger)
    {
        Set_OpportunityField(newTrigger);
    }
    
    //===================================================================================================================    
    public void OnAfterUpdate(List<NI_Invoice__c> newTrigger, Map<Id,NI_Invoice__c> oldMapTrigger)
    { 
        //CREATE LIST TO HOLD ALL INVOICE RECORDS WHERE UPDATES ARE MADE TO THE PAID AMOUNT FIELD
        List<NI_Invoice__c> lstInvPaidAmountChanged = new List<NI_Invoice__c>();
        
        for (NI_Invoice__c inv : newTrigger) 
        {
            NI_Invoice__c oldInv = oldMapTrigger.get(inv.Id);
            
            if ((inv.Paid_Amount__c != null) && (inv.Paid_Amount__c != oldInv.Paid_Amount__c))
            {
                lstInvPaidAmountChanged.add(inv);   
            }
        }
        
        if (lstInvPaidAmountChanged.size() > 0)
        {  
            Update_CustomerAgrAmountReceived(lstInvPaidAmountChanged);
        }
    }
    //=========================================================================================================================          
    //THIS METHOD POPULATES THE OPPORTUNITY FIELD ON THE NI INVOICE RECORD
    //=========================================================================================================================
    public void Set_OpportunityField(List<NI_Invoice__c> newTrigger)
    {   
        System.debug(' *** ENTERING NI_Invoice_TriggerHandler.Set_OpportunityField()');
        
        Set<String> setOrderNumbers = new Set<String>();
        
        for (NI_Invoice__c i : newTrigger)
        {
            setOrderNumbers.add(i.Order_Number__c);  
        }
        
        
        List<Opportunity> lstOpportunities = [SELECT Id, Opportunity_Number__c
                                              FROM Opportunity
                                              WHERE Opportunity_Number__c IN: setOrderNumbers];
        
        System.Debug('NUMBER OF OPPORTUNITIES IN lstOpportunities: ' + lstOpportunities.size());
        
        
        //MAP OF OPPORTUNITY RECORDS RELATED TO THE NI INVOICE RECORDS
        Map<String,Opportunity> mapOpps = new Map<String,Opportunity> ();
        
        for(Opportunity o : lstOpportunities)
        {
            mapOpps.Put(o.Opportunity_Number__c, o);   
        }
        
        //PERFORM THE NEXT STEPS IF THERE ARE OPPORTUNITY RECORDS
        If(mapOpps.size()>0)
        {   
            for(NI_Invoice__c inv : newTrigger)
            {   
                if(setOrderNumbers.contains(inv.Order_Number__c))
                {
                    inv.Opportunity__c = mapOpps.get(inv.Order_Number__c).Id;   
                }       
                
            }
        }       
    }
    
    //=========================================================================================================================          
    //THIS METHOD UPDATES THE AMOUNT RECEIVED FIELD ON THE CUSTOMER AGREEMENT RECORDS RELATED TO INVOICE DETAIL RECORDS
    //=========================================================================================================================
    public void Update_CustomerAgrAmountReceived(List<NI_Invoice__c> newTrigger)
    {   
        System.debug(' *** ENTERING NI_Invoice_TriggerHandler.Update_CustomerAgrAmountReceived()');
        
        Set<Id> setInvoiceIds = new Set<Id>();
        
        for (NI_Invoice__c i : newTrigger)
        {
            setInvoiceIds.add(i.Id);  
        }
        
        
        List<NI_Invoice_Detail__c> lstInvoiceDetails = [SELECT Id, NI_Invoice__c, Customer_Agreement__c, Applied_Amount__c
                                              FROM NI_Invoice_Detail__c
                                              WHERE NI_Invoice__c IN: setInvoiceIds
                                              AND Customer_Agreement__c != null];
        
        System.Debug('NUMBER OF INVOICE DETAIL RECORDS: ' + lstInvoiceDetails.size());
        
        //MAP USED TO REFERENCE THE INVOICE DETAIL RECORD BY CUSTMER AGREEMENT ID
        Map<Id,NI_Invoice_Detail__c> mapInvoiceDetails = new Map<Id,NI_Invoice_Detail__c>();
        
        //SET TO HOLD THE CUSTOMER AGREEMENT IDs RELATED TO INVOICE DETAIL RECORDS
        Set<Id> setCustAgrIds = new Set<Id>();
        
        for(NI_Invoice_Detail__c invDet : lstInvoiceDetails)
        {
          setCustAgrIds.add(invDet.Customer_Agreement__c);
          mapInvoiceDetails.put(invDet.Customer_Agreement__c,invDet);  
        }
        
        List<NI_Customer_Agreement__c> lstCustomerAgreements = [SELECT Id, Amount_Received__c
                                                                FROM NI_Customer_Agreement__c
                                                                WHERE Id IN: setCustAgrIds];
        
        List<NI_Customer_Agreement__c> lstCustAgrToUpdate = new List<NI_Customer_Agreement__c>();
        
        for(NI_Customer_Agreement__c ca : lstCustomerAgreements)
        {
          ca.Amount_Received__c = mapInvoiceDetails.get(ca.Id).Applied_Amount__c;
          lstCustAgrToUpdate.add(ca);
        }
        
        System.debug('NUMBER OF CUSTOMER AGREEMENT RECORDS TO UPDATE: ' + lstCustAgrToUpdate.size());
        
        //USE DATABASE DML METHOD TO BULK UPDATE THE CUSTOMER AGREEMENT RECORDS RECORDS
        if(lstCustAgrToUpdate.size() > 0)
        {
            Database.SaveResult[] results = Database.update(lstCustAgrToUpdate,true);
            for(Database.SaveResult sr: results)
            {
                if(!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                }
            }
        } 
    }
    
    
}