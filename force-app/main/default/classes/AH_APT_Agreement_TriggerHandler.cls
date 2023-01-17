/************************************************************************************************
Name            : AH_APT_Agreement_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 09/18/2013
Last Mod Date   : 05/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all custom trigger code
                : for the AH_APT_Agreement_TriggerHandler Object
                : 
*************************************************************************************************/
public class AH_APT_Agreement_TriggerHandler 
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_APT_Agreement_TriggerHandler()
    {
        
        system.debug(' *** ENTERING AH_APT_Agreement_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        system.debug(' *** EXITING AH_APT_Agreement_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    } 

    // ======================================================================================================================== 
    //  PUBLIC ENTRY METHODS 
    // ======================================================================================================================== 
    public void OnBeforeUpdate(List<Apttus__APTS_Agreement__c> newTrigger, Map<Id, Apttus__APTS_Agreement__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_APT_Agreement_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        updateTermsOnOpportunity(newTrigger, oldMapTrigger);
        
        system.debug(' *** EXITING AH_APT_Agreement_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
    }
    
    
    public void OnAfterInsert(List<Apttus__APTS_Agreement__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_APT_Agreement_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        updateLookupsOnAgreement(newTrigger);
        
        system.debug(' *** EXITING AH_APT_Agreement_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }   


    // ========================================================================================================================
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================      
    private void updateLookupsOnAgreement(List<Apttus__APTS_Agreement__c> newTrigger)
    {
        
        // METHOD TO UPDATE THE Apttus__Account__c FIELD WITH THE OPPORTUNITY ACCOUNT
        
        // MAP TO HOLD THE APTTUS PRICE LIST ID AND THE STANDARD SALESFORCE PRICE BOOK ID
        Map<Id, Id> mapPriceBookPriceList = new Map<Id, Id>(); 
        
        //LIST TO HOLD ALL APTTUS PRICE LISTS
        List<Apttus_Config2__PriceList__c> lstApttusPriceLists = new List<Apttus_Config2__PriceList__c>(
            [SELECT Id, Related_Salesforce_Price_Book__c FROM Apttus_Config2__PriceList__c]);
        
        for (Apttus_Config2__PriceList__c pl : lstApttusPriceLists)
        {                 
            if (pl.Related_Salesforce_Price_Book__c != null)
            {
                // ADD THE ID OF THE STANDARD PRICE BOOK AND RELATED APTTUS PRICE LIST
                mapPriceBookPriceList.put(pl.Related_Salesforce_Price_Book__c, pl.Id); 
            } 
        }    
        
        //LIST TO HOLD ALL OF THE AGREEMENT RECORDS THAT HAVE BEEN INSERTED
        List<Apttus__APTS_Agreement__c> lstAllAgreementRecords = new List<Apttus__APTS_Agreement__c>();
        
        //LIST TO HOLD ALL OF THE AGREEMENT RECORDS THAT WILL BE UPDATED
        List<Apttus__APTS_Agreement__c> lstAgreementsToUpdate = new List<Apttus__APTS_Agreement__c>();
        
        lstAllAgreementRecords = ([SELECT Id, Apttus__Account__c, Apttus__Related_Opportunity__c, Apttus__Related_Opportunity__r.AccountId,
                                   Apttus__Related_Opportunity__r.Name, Apttus__Related_Opportunity__r.Pricebook2Id 
                                   FROM Apttus__APTS_Agreement__c 
                                   WHERE Id IN : newTrigger]); 
        
        for (Apttus__APTS_Agreement__c a : lstAllAgreementRecords)
        {                 
            if ((a.Apttus__Account__c == null) && (a.Apttus__Related_Opportunity__c != null))
            {
                
                // SET THE ACCOUNT TO THE OPPORTUNITY ACCOUNT
                a.Apttus__Account__c = a.Apttus__Related_Opportunity__r.AccountId; 
                
                // SET THE AGREEMENT NAME TO THE NAME OF THE OPPORTUNITY
                a.Name = a.Apttus__Related_Opportunity__r.Name; 
                
                if (mapPriceBookPriceList.get(a.Apttus__Related_Opportunity__r.Pricebook2Id) != null)
                {
                    // SET THE PRICE LIST BASED ON THE PRICE BOOK OF THE OPPORTUNITY
                    a.Apttus_CMConfig__PriceListId__c = mapPriceBookPriceList.get(a.Apttus__Related_Opportunity__r.Pricebook2Id); 
                }
                
                lstAgreementsToUpdate.add(a);
                
            } 
        }
        
        // USE DATABASE DML METHOD TO UPDATE ALL OF THE AGREEMENT RECORDS
        if (lstAgreementsToUpdate.size() > 0)
        {
            Database.SaveResult[] results = Database.update(lstAgreementsToUpdate,false);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess())
                {
                    Database.Error err = sr.getErrors()[0];
                    system.debug(err.getMessage());
                }
            }
        }                     
        
    }

    private void updateTermsOnOpportunity(List<Apttus__APTS_Agreement__c> newTrigger, Map<Id, Apttus__APTS_Agreement__c> oldMapTrigger)
    {

        // FORMALLY FROM TRIGGER CALLED ffaAgreementTrigger
        
        Map<Id, Id> licensedProgramOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> servicesOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> subscriptionOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> supportOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> hostingSupportOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> hrmsubscriptionOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> hrmservicesOppPMTMap = new Map<Id, Id>();
        Map<Id, Id> chinaOppPMTMap = new Map<Id, Id>();
        
        Map<String, Id> invoiceTermsMap = new Map<String, Id>();
        Set<Id> oppIdSet = new Set<Id>();
        
        for (Payment_Terms__c invTerms : [SELECT Id, Aptus_Payment_Terms__c, Type__c FROM Payment_Terms__c WHERE Type__c != null AND Aptus_Payment_Terms__c != null])
        {
            String key = invTerms.Type__c + '|' + invTerms.Aptus_Payment_Terms__c;
            invoiceTermsMap.put(key, invTerms.Id);
        }	
system.debug('*^* invoiceTermsMap = ' + invoiceTermsMap);         
        for (Apttus__APTS_Agreement__c agreement : newTrigger)
        {
            
            Apttus__APTS_Agreement__c oldAgreement = oldMapTrigger.get(agreement.Id);
            
            if (agreement.Apttus__Related_Opportunity__c != null)
            {
                
                oppIdSet.add(agreement.Apttus__Related_Opportunity__c);
                
                if (agreement.APTS_Licensed_Program__c != null && oldAgreement.APTS_Licensed_Program__c != agreement.APTS_Licensed_Program__c)
                {                   
                    String key = 'Licensed Program' + '|' + agreement.APTS_Licensed_Program__c;
system.debug('*^* Licensed Program map key = ' + key);                       
                    if (invoiceTermsMap.containsKey(key))
                    {
                        licensedProgramOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }
                
                if (agreement.APTS_Services__c != null && oldAgreement.APTS_Services__c != agreement.APTS_Services__c)
                {
                    String key = 'Services' + '|' + agreement.APTS_Services__c;
system.debug('*^* Licensed Program map key = ' + key);                      
                    if (invoiceTermsMap.containsKey(key))
                    {
                        servicesOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }
                
                if (agreement.APTS_Hosting_and_Support__c != null && oldAgreement.APTS_Hosting_and_Support__c != agreement.APTS_Hosting_and_Support__c)
                {
                    String key = 'Hosting and Support' + '|' + agreement.APTS_Hosting_and_Support__c;
system.debug('*^* Licensed Program map key = ' + key);                      
                    if (invoiceTermsMap.containsKey(key))
                    {
                        hostingSupportOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }	
                
                if (agreement.APTS_Subscription__c != null && oldAgreement.APTS_Subscription__c != agreement.APTS_Subscription__c)
                {
                    String key = 'Subscription' + '|' + agreement.APTS_Subscription__c;
system.debug('*^* Licensed Program map key = ' + key);                      
                    if (invoiceTermsMap.containsKey(key))
                    {
                        subscriptionOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }
                
                if (agreement.APTS_Support__c != null && oldAgreement.APTS_Support__c != agreement.APTS_Support__c)
                {
                    String key = 'Support' + '|' + agreement.APTS_Support__c;
system.debug('*^* Licensed Program map key = ' + key);                      
                    if (invoiceTermsMap.containsKey(key))
                    {
                        supportOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }
                
                if (agreement.APTS_HRM_Apps_Subscription_Term__c != null && oldAgreement.APTS_HRM_Apps_Subscription_Term__c != agreement.APTS_HRM_Apps_Subscription_Term__c)
                {
                    String key = 'HRM Subscription' + '|' + agreement.APTS_HRM_Apps_Subscription_Term__c;
system.debug('*^* Licensed Program map key = ' + key);                      
                    if (invoiceTermsMap.containsKey(key))
                    {
                        hrmsubscriptionOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }
                
                if (agreement.HRM_Apps_Services_Terms__c != null && oldAgreement.HRM_Apps_Services_Terms__c != agreement.HRM_Apps_Services_Terms__c)
                {
                    String key = 'HRM Services' + '|' + agreement.HRM_Apps_Services_Terms__c;
system.debug('*^* Licensed Program map key = ' + key);                      
                    if (invoiceTermsMap.containsKey(key))
                    {
                        hrmservicesOppPMTMap.put(agreement.Apttus__Related_Opportunity__c, invoiceTermsMap.get(key));
                    } 
                }
                
            }	
        }
        
        List<Opportunity> lstOpp = [SELECT Id, Hosting_and_Support_Payment_Terms__c, License_Program_Payment_Terms__c, Services_Payment_Terms__c,
                                    Subscription_Payment_Terms__c, Support_Payment_Terms__c, HRM_Subscription_Invoice_Terms__c, HRM_Service_Invoice_Terms__c
                                    FROM Opportunity
                                    WHERE Id IN : oppIdSet 
                                    FOR UPDATE];			// ADDED TO PREVENT UNABLE_TO_LOCK_ROW ERRORS
        
        for (Opportunity o : lstOpp)
        {
            o.Hosting_and_Support_Payment_Terms__c = hostingSupportOppPMTMap.containsKey(o.Id) ? hostingSupportOppPMTMap.get(o.Id) : o.Hosting_and_Support_Payment_Terms__c;
            o.License_Program_Payment_Terms__c = licensedProgramOppPMTMap.containsKey(o.Id) ? licensedProgramOppPMTMap.get(o.Id) : o.License_Program_Payment_Terms__c;
            o.Services_Payment_Terms__c = servicesOppPMTMap.containsKey(o.Id) ? servicesOppPMTMap.get(o.Id) : o.Services_Payment_Terms__c;
            o.Subscription_Payment_Terms__c = subscriptionOppPMTMap.containsKey(o.Id) ? subscriptionOppPMTMap.get(o.Id) : o.Subscription_Payment_Terms__c;
            o.Support_Payment_Terms__c = supportOppPMTMap.containsKey(o.Id) ? supportOppPMTMap.get(o.Id) : o.Support_Payment_Terms__c;
            o.HRM_Subscription_Invoice_Terms__c = hrmsubscriptionOppPMTMap.containsKey(o.Id) ? hrmsubscriptionOppPMTMap.get(o.Id) : o.HRM_Subscription_Invoice_Terms__c;
            o.HRM_Service_Invoice_Terms__c = hrmservicesOppPMTMap.containsKey(o.Id) ? hrmservicesOppPMTMap.get(o.Id) : o.HRM_Service_Invoice_Terms__c;
        }
                
        database.update(lstOpp);
        
    }

}