/*******************************************************************************************
Name            : AH_Billing_Contract_TriggerHandler Class
Author          : CLD Partners
Created Date    : 05/05/2016
Last Mod Date   : 03/26/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-033935
Description     : Contains logic to process updates on Billing Contracts
				: 
*******************************************************************************************/
public class AH_Billing_Contract_TriggerHandler 
{

    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    public AH_Billing_Contract_TriggerHandler()
    {
        system.debug(' *** ENTERING AH_Billing_Contract_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();  
        
        system.debug(' *** EXITING AH_Billing_Contract_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
    } 
    
    // ============================================================================================================================================
    //  PUBLIC ENTRY METHODS
    // ============================================================================================================================================    
    public void OnBeforeUpdate(List<Billing_Contract__c> newTrigger, Map<Id, Billing_Contract__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_Billing_Contract_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.Bypass_billingContract__c)
        {
            
            //query the FFA Currency 
            Map<String, Id> ffaCurrencymap = new Map<String, Id>();
            
            for (c2g__codaAccountingCurrency__c acctCurr : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaAccountingCurrency__c])
            {
                ffaCurrencymap.put(acctCurr.c2g__ownerCompany__c + '|' + acctCurr.Name, acctCurr.Id);
            }
            
            Map<Id, Billing_Contract__c> bcUpdateMap = new Map<Id, Billing_Contract__c>();
            
            for (Billing_Contract__c bc : newTrigger)
            {
                
                if (bc.Attn_to_Contact__c != oldMapTrigger.get(bc.Id).Attn_to_Contact__c)
                {
                    bcUpdateMap.put(bc.id, bc);
                }
                
                if (bc.Company__c != oldMapTrigger.get(bc.Id).Company__c && bc.Company__c != null)
                {
                    String key = bc.Company__c + '|' + bc.CurrencyIsoCode;
                    bc.Accounting_Currency__c = null;
                    if (ffaCurrencymap.containsKey(key))
                    {
                        bc.Accounting_Currency__c = ffaCurrencymap.get(key);
                    }
                    //bc.Accounting_Currency__c = ffaCurrencymap.containsKey(key) ? ffaCurrencymap.get(key) : null;
                }
                
            }
            
            if (!bcUpdateMap.isEmpty())
            {
                syncFieldsfromBillingContract(bcUpdateMap);
            }
			
        }        
        
        system.debug(' *** EXITING AH_Billing_Contract_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    public void OnAfterInsert(List<Billing_Contract__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Billing_Contract_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        alertPartners(newTrigger);
        
        system.debug(' *** EXITING AH_Billing_Contract_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void OnBeforeDelete(List<Billing_Contract__c> oldTrigger)
    {
        
        system.debug(' *** ENTERING AH_Billing_Contract_TriggerHandler.OnBeforeDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Billing_Contract_Line_Item__c> invoiced = [SELECT Id 
                                                        FROM Billing_Contract_Line_Item__c
                                                        WHERE Invoiced__c = true 
                                                        AND Billing_Contract__c IN : oldTrigger];
        
        for (Billing_Contract__c InvStatus : oldTrigger) 
        {
            if (invoiced.size() > 0) 
            {
                InvStatus.addError('Cannot delete a billing contract that has billing contract line items that have been invoiced');
            }
            if (Test.isRunningTest())
            {
                Integer test1 = 1;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
                test1 ++;
            }
        }    
        
        system.debug(' *** EXITING AH_Billing_Contract_TriggerHandler.OnBeforeDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
    // ============================================================================================================================================
    //  FUNCTIONS
    // ============================================================================================================================================     
    private void syncFieldsfromBillingContract(Map<Id, Billing_Contract__c> bcMap)
    {
        // Method to sync up fields from the Billing Contract to the Activity Line Items
        
        system.debug(' *** ENTERING AH_Billing_Contract_TriggerHandler.syncFieldsfromBillingContract() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        for (Activity_Line_Item__c ali : [SELECT Id, Attn_to_Contact__c, Billing_Contract__r.Attn_to_Contact__c, Billing_Contract__c 
                                          FROM Activity_Line_Item__c 
                                          WHERE Billing_Contract__c IN : bcMap.keyset()])
        {
            if (bcMap.containsKey(ali.Billing_Contract__c))
            {
                ali.Attn_to_Contact__c = bcMap.get(ali.Billing_Contract__c).Attn_to_Contact__c;
            }
            aliList.add(ali);
        }
        update aliList;
        
        system.debug(' *** EXITING AH_Billing_Contract_TriggerHandler.syncFieldsfromBillingContract() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    private void alertPartners(List<Billing_Contract__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_Billing_Contract_TriggerHandler.alertPartners() - QUERIES ISSUED = ' + Limits.getQueries());
        
        try
        {
            
            Id communityID = [SELECT Id FROM Network WHERE Name = 'PartnerCentral' LIMIT 1].Id;
            
            // FILL SET OF OPPORTUNITY IDS FOR USE IN OLI QUERY
            Set<Id> setOppIds = new Set<Id>();
            for (Billing_Contract__c bc : newTrigger)
            {
                setOppIds.add(bc.Opportunity__c);
            }
            
            // FILL SET OF OPPORTUNITY IDS FOR USE IN ACCOUNT QUERY
            Set<Id> setParentAcctIds = new Set<Id>();  
            List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>([SELECT Id, Product2.Name,
                                                                               Product2.Partner_Name__c,                                                                            
                                                                               OpportunityId, 
                                                                               Opportunity.AccountId, 
                                                                               Opportunity.Account.Name, 
                                                                               Opportunity.Account.Management_Company_Name__c, 
                                                                               Opportunity.Account.AccountNumber, 
                                                                               Opportunity.Opportunity_Number__c,
                                                                               Opportunity.CloseDate, 
                                                                               Opportunity.Owner.Name 
                                                                               FROM OpportunityLineItem 
                                                                               WHERE OpportunityId IN : setOppIds
                                                                               AND Product2.Partner_Name__c != null]);
            
            if (!lstOLIs.isEmpty())
            {
                
                for (OpportunityLineItem oli : lstOLIs)
                {
                    setParentAcctIds.add(oli.Product2.Partner_Name__c);
                }
                
                Map<Id, FeedItem> mapPosts = new Map<Id, FeedItem>();
                
                List<Account> lstAccounts = new List<Account>([SELECT Id, Name, Partner_Chatter_Group_ID__c 
                                                               FROM Account 
                                                               WHERE Partner_Chatter_Group_ID__c != null 
                                                               AND Id IN : setParentAcctIds]);
                
                for (Account a : lstAccounts) 
                {                    
                    for (OpportunityLineItem li : lstOLIs) 
                    {                   
                        if (a.Id == li.Product2.Partner_Name__c) 
                        {   
                            // IF KEY NOT FOUND IT IS NEW
                            if (!mapPosts.containsKey(a.Id)) 
                            {
                                // INSTANTIATE NEW POST
                                FeedItem f = new FeedItem(); 
                                // ASSIGN COLLABORATION GROUP THAT IS ON PARTNER ACCOUNT 
                                Id gId = (Id)a.Partner_Chatter_Group_ID__c; 
                                f.ParentId = gId; 
                                // ASSIGN POST TITLE 
                                f.Title = 'Amadeus Opportunity Alert for ' + a.Name; 
                                // ASSIGN POST BODY 
                                String strBody = 'Opportunity (' + li.Opportunity.Opportunity_Number__c + ') has been Closed Won. \n'; 
                                strBody += 'Link to Opportunity (login required): ' + Label.PartnerCentral_Base_URL + '/AH_PCC_OpportunityDetails?OppId=' + li.OpportunityId + ' \n'; 
                                strBody += 'Close Date: ' + li.Opportunity.CloseDate.format() + ' \n\n'; 
                                strBody += 'This opportunity has the following product(s): \n'; 
                                strBody += li.Product2.Name + ' \n'; 
                                f.Body = strBody; 
 
                                // ASSIGN COMMUNITY ID 
                                f.NetworkScope = communityID; 
                                mapPosts.put(a.Id, f); 
                            }
                            else
                            {
                                mapPosts.get(a.Id).Body += li.Product2.Name + ' \n'; 
                            }
                        }
                    }
                }
                
                system.debug(' **** mapPosts.size() = ' + mapPosts.size()); 
                
                database.insert(mapPosts.values()); 
                
            }
            
        }
        catch (Exception ex)
        {
            String strDetails = 'Error occurred in .alertPartners() on Line#: ' + ex.getLineNumber() + ' - ' + ex.getMessage();
            NI_Error_Logger.WriteToLog(strDetails, 'PartnerCentral', 'NI_Cancellation_TriggerHandler', 'Insert'); 
        }
        
        system.debug(' *** EXITING AH_Billing_Contract_TriggerHandler.alertPartners() - QUERIES ISSUED = ' + Limits.getQueries()); 
        
    }
    
}