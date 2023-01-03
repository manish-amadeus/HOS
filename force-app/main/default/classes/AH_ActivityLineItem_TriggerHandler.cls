/************************************************************************************************
Name            : AH_ActivityLineItem_TriggerHandler Class
Author          : Sean Harris
Created Date    : 08/13/2018
Last Mod Date   : 02/07/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Written by CLD Partners. Updated to meet AH Standards
                : Class that handles all trigger code for the Activity_Line_Item__c Object
                : UPDATED PER NICC-034700 commented default ali.Auto_Renewal__c = true
                : UPDATED PER NICC-034730 Removed @future on rebuildRevenueSchedules()
*************************************************************************************************/
public class AH_ActivityLineItem_TriggerHandler
{
    
    private NI_TriggerBypassSwitches__c ffaTriggers {get; set;}
    private Boolean isDIALILinked_afterUpdate = false;
    private Boolean isDIALILinked_afterInsert = false;
    
    
    public AH_ActivityLineItem_TriggerHandler()
    {   
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        ffaTriggers = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler - CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // ========================================================================================================================
    //  PUBLIC ENTRY METHODS 
    // ========================================================================================================================     
    public void OnBeforeInsert(List<Activity_Line_Item__c> newTrigger)
    {
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!ffaTriggers.Bypass_activityLineItemTrigger__c)
        {
            evaluateRenewalsMultiYearOpp(newTrigger);	
            defaultFields(newTrigger);  
            setAccountAndStatus(newTrigger);
        }

        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void OnAfterInsert(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        NI_TriggerManager.is1stInsert_ActivityLineItem = false;
        
        if (!ffaTriggers.Bypass_activityLineItemTrigger__c)
        {
            evalVSOERequirement(newTrigger);            
            AH_ActivityLineItem_Statics.updateBillingLineDescriptions(Trigger.new);
            linkALIandDI(newTrigger, oldMapTrigger);
            isDIALILinked_afterInsert = true;
            
            // BUILD SET OF ALI IDS TO PASS TO @FUTURE ANNOTATED FUNCTION
            Set<Id> setALIIds = new Set<Id>();
            for (Activity_Line_Item__c ali : newTrigger)
            {
                setALIIds.add(ali.Id); 
            }
            rebuildRevenueSchedules(setALIIds); 

        }  
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeUpdate(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldMapTrigger, Map<Id, Activity_Line_Item__c> newMapTrigger)
    {
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!ffaTriggers.Bypass_activityLineItemTrigger__c)
        {
            persistDecimalPlaces(newTrigger, oldMapTrigger);
            handleActivation(newTrigger, oldMapTrigger, newMapTrigger);	
            recalculateBillingLines(newTrigger); 
            handleALICancellation(newTrigger, oldMapTrigger); 
            defaultFields(newTrigger);
        } 

		system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());     
        
    }
    
    public void OnAfterUpdate(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldMapTrigger)
    {      
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        NI_TriggerManager.is1stUpdate_ActivityLineItem = false;
        
        if (!ffaTriggers.Bypass_activityLineItemTrigger__c)
        {
            AH_ActivityLineItem_Statics.updateBillingLineDescriptions(newTrigger);
            linkALIandDI(newTrigger, oldMapTrigger);
            isDIALILinked_afterUpdate = true;
            
            Set<Id> setALIIds = new Set<Id>();
            for (Activity_Line_Item__c ali : newTrigger)
            {
                
                // REBUILD REVENUE SCHEDULE ONLY WHEN 1 OF 3 FIELDS CHANGE
                Activity_Line_Item__c oldAli = oldMapTrigger.get(ali.id);                
				
                if (ali.Total_Revenue_to_Recognize__c != oldAli.Total_Revenue_to_Recognize__c ||
                    ali.Contract_Start_Date__c != oldAli.Contract_Start_Date__c ||
                    ali.Contract_End_Date__c != oldAli.Contract_End_Date__c)
                {                
                    setALIIds.add(ali.Id);
                }
                
            } 
           
            if (!setALIIds.isEmpty())
            {
                rebuildRevenueSchedules(setALIIds);
            }
                            
        }  
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeDelete(List<Activity_Line_Item__c> oldTrigger)
    {
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.OnBeforeDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!ffaTriggers.Bypass_activityLineItemTrigger__c)
        {
            validateDeletion(oldTrigger);           
        }
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.OnBeforeDelete() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    

    // ========================================================================================================================
    //  PRIVATE HANDLER METHODS/FUNCTIONS 
    // ========================================================================================================================  
    private void evaluateRenewalsMultiYearOpp(List<Activity_Line_Item__c> newTrigger)
    {  

        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.evaluateRenewalsMultiYearOpp() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // FILL A SET OF RELATED PRODUCT2 IDS
        Set<Id> OppLineIds = new Set<Id>();        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            OppLineIds.add(ali.Opp_Product_ID__c);
        }
        
        // FILL A LIST OF RELATED OPPORTUNITY LINE ITEMS
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>(
            [SELECT Id, OpportunityId, Product2Id, Order_of_Delivery__c  
             FROM OpportunityLineItem 
             WHERE Order_of_Delivery__c != null 
             AND Id IN : OppLineIds
             ORDER BY OpportunityId, Product2Id, Order_of_Delivery__c DESC]);

        // FILL AN AGGREGATED LIST OF RELATED OPPORTUNITY LINE ITEMS 
        List<AggregateResult> lstAggregates = new List<AggregateResult>(
            [SELECT OpportunityId, Product2Id, MIN(Order_of_Delivery__c) MinOOD, MAX(Order_of_Delivery__c) MaxOOD, COUNT(Id) RecordCount
             FROM OpportunityLineItem 
             WHERE Order_of_Delivery__c != null 
             AND Id IN : OppLineIds    
             GROUP BY OpportunityId, Product2Id]);

		// LOOP THROUGH TRIGGER AND CONTIONALLY SET THE Renewal_Processed__c AND Renewal_Notification_Sent__c FIELDS
        for (Activity_Line_Item__c ali : newTrigger)
        {
            
            // SET DEFAULT
            ali.Renewal_Processed__c = false;
            //ali.Renewal_Notification_Sent__c = false;
            
            // FIND MATCHING OPPORTUNITY LINE ITEM ON THE ACTIVITY LINE ITEM
            for (OpportunityLineItem oli : lstOLIs)
            {
                if (ali.Opp_Product_ID__c == oli.Id)
                {
                    // FIND MATCHING AGGREGATED OPPORTUNITY LINE ITEM ON THE ACTIVITY LINE ITEM
                    for (AggregateResult x : lstAggregates)
                    {                        
                        if (oli.OpportunityId == x.get('OpportunityId') && oli.Product2Id == x.get('Product2Id'))
                        {
                            //Decimal dMin = (Decimal) x.get('MinOOD');
                            Decimal dMax = (Decimal) x.get('MaxOOD');
                            Decimal dCnt = (Decimal) x.get('RecordCount');
                            
                            // IF THIS CONDITION IS TRUE THEN MANY OLIs FOR SAME PRODUCT HAS ORDER OF DELIVERY EQUAL TO 1
                            //if (dMin == 1 && dMax == 1 && dCnt > 1){}
                            
                            // IF THIS CONDITION IS TRUE THEN MANY OLIs FOR SAME PRODUCT HAS AN ORDER OF DELIVERY SEQUENCE
                            if (dMax > 1 && dCnt > 1)
                            {
                                // THIS PREVENTS THE ALI FROM BEING CHECKED WHEN LINKED OLI IS LAST IN THE ORDER OF DELIVERY SEQUENCE
                                if (oli.Order_of_Delivery__c != dMax)
                                {
                                    if (ali.Origin__c == 'New Order')
                                    {
                                        ali.Renewal_Processed__c = true;
                                        //ali.Renewal_Notification_Sent__c = true;                                        
                                    } 
                                }
                            }
                        }  
                    }                    
                }
            }
        }
 
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.evaluateRenewalsMultiYearOpp() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
	
    private void defaultFields(List<Activity_Line_Item__c> newTrigger)
    {
        
        // Default Fields from the Product
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.defaultFields() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> productids = new Set<Id>();
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            productids.add(ali.Product__c);
        }
        
        Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Revenue_Recognition_Template__c
                                                             FROM Product2
                                                             WHERE Id IN : productids]);
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            ali.ffrrtemplate__c = productMap.containsKey(ali.Product__c)? productMap.get(ali.Product__c).Revenue_Recognition_Template__c : null;
        }
        
        // SET Auto_Renewal__c
        for (Activity_Line_Item__c ali : newTrigger)
        {               
// (COMMENTED PER NICC-034700) ali.Auto_Renewal__c = true;
            if (ali.Units_Cancelled__c >= ali.Units__c)
            {
                ali.Auto_Renewal__c = false;
            }
        } 
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.defaultFields() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void setAccountAndStatus(List<Activity_Line_Item__c> newTrigger)
    {
        
        // METHOD TO SET ACCOUNT FIELD AND DEFAULT STATUS OF NEW ACTIVITY LINE ITEM RECORD
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.setAccountAndStatus() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // MAP TO HOLD BILLING CONTRACT ID WITH ACCOUNT
        Map<Id, Billing_Contract__c> billingConMap = new Map<Id, Billing_Contract__c>();
        
        // SET TO HOLD BILLING CONTRACT ID
        Set<Id> billingIdSet = new Set<Id>();
        
        // SET TO HOLD PRICE BOOK IDS
        Set<Id> priceBookIdSet = new Set<Id>();
        
        // Load the Maps to be used for Price Increases
        Map<String, Id> renewalPriceMap = new Map<String, Id>();
        
        List<Renewal_Pricing_Entry__c> rpeList = new List<Renewal_Pricing_Entry__c>();
        
        // ITEARATE OVER NEWLY INSERTED RECORDS AND ADD BILLING CONRTRACT ID TO SET
        for (Activity_Line_Item__c ali : newTrigger)
        {
            if (ali.Billing_Contract__c != null)
            {
                billingIdSet.add(ali.Billing_Contract__c);
            }
            if (ali.Renewal_Pricebook__c != null)
            {
                priceBookIdSet.add(ali.Renewal_Pricebook__c);
            }
        }
        
        // IF SET IS NOT EMPTY, GET ACCOUNT ID AND STORE IN MAP
        if (!billingIdSet.isEmpty())
        {
            billingConMap = new Map<Id, Billing_Contract__c>([SELECT Id, Account__c FROM Billing_Contract__c WHERE Id IN : billingIdSet]);
        }
        
        system.debug(' **** priceBookIdSet = ' + priceBookIdSet);
            
        Renewal_Pricing_Entry__c mostRecentRPE = new Renewal_Pricing_Entry__c();
        
        if (!priceBookIdSet.isEmpty())
        {
            
            rpeList = [SELECT Id, Start_Date__c, End_Date__c, Percent_Increase__c, Renewal_Pricebook__c
                       FROM Renewal_Pricing_Entry__c
                       WHERE Renewal_Pricebook__c IN : priceBookIdSet 
                       ORDER BY createdDate DESC];
            
            system.debug(' **** rpeList.size = ' + rpeList.size());
            system.debug(' **** rpeList = ' + rpeList);
            
            if (!rpeList.isEmpty())
            {
                
                mostRecentRPE = rpeList[0];
                system.debug(' **** mostRecentRPE = ' + mostRecentRPE);                
                
                for (Renewal_Pricing_Entry__c rpe : rpeList)
                {
                    Date loopDate = rpe.Start_Date__c;
                    while (loopDate < rpe.End_Date__c)
                    {
                        renewalPriceMap.put(rpe.Renewal_Pricebook__c + '|' + loopDate.format(), rpe.Id);
                        loopDate = loopDate.addDays(1);
                    }
                    continue;
                }
            }
            
        }
        
        //ITERATE OVER NEWLY INSERTED ACTIVITY LINE ITEM RECORDS
        for (Activity_Line_Item__c ali : newTrigger)
        {
            
            if (ali.Origin__c == 'Renewal')
            {
                ali.Status__c = 'Active';
                // ali.Status__c = 'Renewal';
            }
            else
            {
                ali.Status__c = 'Active';
                // ali.Status__c = 'New';
            }
            
            //SET ACCOUNT ID AS THAT OF BILLING CONTRACT'S ACCOUNT ID
            if (ali.Billing_Contract__c != null)
            {
                if (billingConMap.containsKey(ali.Billing_Contract__c))
                {
                    Billing_Contract__c billingObj = new Billing_Contract__c();
                    billingObj = billingConMap.get(ali.Billing_Contract__c);
                    ali.Account__c = billingObj.Account__c;
                }
            }
            
            if (ali.Renewal_Pricebook__c != null && ali.Renewal_Date__c != null)
            {
                if (!renewalPriceMap.isEmpty() && renewalPriceMap.containsKey(ali.Renewal_Pricebook__c + '|' + ali.Renewal_Date__c.format()))
                {
                    ali.Renewal_Pricing_Entry__c = renewalPriceMap.get(ali.Renewal_Pricebook__c + '|' + ali.Renewal_Date__c.format());
                }
                else 
                {
                    // POPULATE RPE WHEN ALI CREATED FROM "RENEWAL BILLING CONTRACT" 
                    if (!renewalPriceMap.isEmpty() && !renewalPriceMap.containsKey(ali.Renewal_Pricebook__c + '|' + ali.Renewal_Date__c.format()))
                    {
                        if (mostRecentRPE != null)
                        {
                            ali.Renewal_Pricing_Entry__c = mostRecentRPE.Id;
                        }
                    }
                }
            }
            else 
            {
                // POPULATE RPE IF RENEWAL DATE == NULL 
                if (ali.Renewal_Pricebook__c != null && ali.Renewal_Date__c == null) 
                {
                    ali.Renewal_Pricing_Entry__c = mostRecentRPE.id;
                }
            }
        }
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.setAccountAndStatus() - QUERIES ISSUED = ' + Limits.getQueries());
        
    } 
    
    private void handleActivation(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldTriggerMap, Map<Id, Activity_Line_Item__c> newTriggerMap)
    {
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.handleActivation() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> aliIdSet = new Set<Id>();
        Map<Id, Activity_Line_Item__c> updatedAliDateMap = new Map<Id, Activity_Line_Item__c>();
        Map<Id, Activity_Line_Item__c> aliMap = new Map<Id, Activity_Line_Item__c>(
            [SELECT Id, Activation_Date__c, Contract_Start_Date__c, Contract_End_Date__c, Pro_Rated_Date__c,
             Product__r.Duration_Months__c, Delivery_Offset_Months__c, Payment_Terms__c
             FROM Activity_Line_Item__c 
             WHERE Id IN : newTrigger 
             AND Delivery_Offset_Months__c != null]);
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            if (oldTriggerMap.containsKey(ali.id) && 
                ali.Activation_Date__c != oldTriggerMap.get(ali.id).Activation_Date__c &&
                ali.Activation_Date__c != null &&
                aliMap.containsKey(ali.id))
            {
                ali.Contract_Start_Date__c = ali.Activation_Date__c.addMonths(ali.Delivery_Offset_Months__c.intValue());
                ali.Contract_End_Date__c = aliMap.get(ali.id).Product__r.Duration_Months__c != null ? ali.Contract_Start_Date__c.addMonths(aliMap.get(ali.id).Product__r.Duration_Months__c.intValue()).addDays(-1) : ali.Contract_Start_Date__c;
                ali.Contract_End_Date__c = aliMap.get(ali.id).Pro_Rated_Date__c != null ? aliMap.get(ali.id).Pro_Rated_Date__c : ali.Contract_End_Date__c;
                aliIdSet.add(ali.id);
                updatedAliDateMap.put(ali.id, ali);
            }
        }
        
        List<Billing_Contract_Line_Item__c> bliUpdateList = [SELECT Id,
                                                             Payment_Terms__r.Invoice_Split_Method__c, 
                                                             Payment_Terms__r.Name, 
                                                             Payment_Terms__r.Offset_Date__c,
                                                             Payment_Term_Line_Item__r.Offset_Measure__c,
                                                             Payment_Term_Line_Item__r.Offset_Units__c,
                                                             Payment_Term_Line_Item__r.Order__c,
                                                             Split_Order__c,
                                                             Pro_Rated__c,
                                                             Line_Item_Description__c,
                                                             Revenue_Category__c,
                                                             Activity_Line_Item__c,
                                                             Invoice_Date__c
                                                             FROM Billing_Contract_Line_Item__c
                                                             WHERE Activity_Line_Item__c in : aliIdSet
                                                             AND Activation_Required__c = true
                                                             ORDER BY Split_Order__c];
        
        Date invoiceDate;
        
        Set<String> revenueCategoriesToApply = new Set<String>{ 'Support', 'Hosting and Support', 'Subscription' };
            
        for (Billing_Contract_Line_Item__c bli : bliUpdateList)
        {
            
            Activity_Line_Item__c ali = newTriggerMap.containsKey(bli.Activity_Line_Item__c) ? newTriggerMap.get(bli.Activity_Line_Item__c) : null;
            
            if (bli.Payment_Term_Line_Item__r.Offset_Measure__c == 'Days' && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
            {
                bli.Invoice_Date__c = ali.Activation_Date__c.addDays(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
            }
            
            if (bli.Payment_Term_Line_Item__r.Offset_Measure__c == 'Months' && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
            {
                bli.Invoice_Date__c = ali.Activation_Date__c.addMonths(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
            }
            
            if (bli.Payment_Term_Line_Item__r.Offset_Measure__c == 'Years' && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
            {
                bli.Invoice_Date__c = ali.Activation_Date__c.addYears(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
            }
            
            bli.Status__c = 'Active';
            
            system.debug(' **** handleActivation - bli.Invoice_Date__c = ' + bli.Invoice_Date__c);
            
            //set the Line Description for any Subscriptions or Support:
            if (bli.Pro_Rated__c == false && revenueCategoriesToApply.contains(bli.Revenue_Category__c) && updatedAliDateMap.containsKey(bli.Activity_Line_Item__c))
            {
                Activity_Line_Item__c tmpali = updatedAliDateMap.get(bli.Activity_Line_Item__c);
                
                //10/08/2016: ADDED BY STUART EMERY PER SALESFORCE CHANGE REQUEST NICC-019640
                //CHANGE START AND END DATE FORMATS TO DAY MONTH ABREVIATION AND YEAR.  EX: '7 Oct 2016'
                Date contractStartDate = tmpali.Contract_Start_Date__c;
                Date contractEndDate = tmpali.Contract_End_Date__c;    
                String strContractStartDate = DateTime.NewInstance(contractStartDate.year(),contractStartDate.month(),contractStartDate.day()).format('d MMM yyyy');
                String strContractEndDate = DateTime.NewInstance(contractEndDate.year(),contractEndDate.month(),contractEndDate.day()).format('d MMM yyyy');
                
                system.debug(' **** strContractStartDate = ' + strContractStartDate);
                system.debug(' **** strContractEndDate = ' + strContractEndDate);
                
                //bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: '+tmpali.Contract_Start_Date__c.format() + ' End: '+tmpali.Contract_End_Date__c.format();
                bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: ' + strContractStartDate + ' End: ' + strContractEndDate;
            }	
        }
        
        system.debug(' **** bliUpdateList = ' + bliUpdateList);
        
        update bliUpdateList;
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.handleActivation() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
	private void recalculateBillingLines(List<Activity_Line_Item__c> newTrigger)
    {
        
        // Default Fields from the Product
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.recalculateBillingLines() - QUERIES ISSUED = ' + Limits.getQueries());
        
		Set<Id> aliRecalcIds = new Set<Id>();
        
		for (Activity_Line_Item__c ali : newTrigger)
        {
			if (ali.ACTION_Rebuild_Billing_Lines__c == true)
            {
				aliRecalcIds.add(ali.id);
				ali.ACTION_Rebuild_Billing_Lines__c = false; //reset the flag
			}
		}
        
		if (aliRecalcIds.size() > 0)
        {
			List<Activity_Line_Item__c> aliList = billingContractHandler.returnActivityLineList(aliRecalcIds);
			List<Billing_Contract_Line_Item__c> bliInsertList = billingContractHandler.recalcBillingLines(aliList, true);
			insert bliInsertList;
		}
     
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.recalculateBillingLines() - QUERIES ISSUED = ' + Limits.getQueries());
        
	}
	
    private void handleALICancellation(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldMap)
    {
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.handleALICancellation() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // ids of the activity line item
        Set<Id> billingLineDeleteIDs = new Set<Id>(); 
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            if (ali.Status__c == 'Cancelled' && oldMap.get(ali.id).Status__c != 'Cancelled')
            {
                billingLineDeleteIDs.add(ali.id);
            }
        }
        
        List<Billing_Contract_Line_Item__c> bliDeleteList = [SELECT Id FROM Billing_Contract_Line_Item__c 
                                                             WHERE Invoiced__c = false 
                                                             AND Activity_Line_Item__c IN : billingLineDeleteIDs];
        
        delete bliDeleteList;
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.handleALICancellation() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void validateDeletion(List<Activity_Line_Item__c> newTrigger)
    {
        
        // Prevent Deletion of Invoiced / Revenue recognized ALIs
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.validateDeletion() - QUERIES ISSUED = ' + Limits.getQueries());
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            if ((ali.Revenue_Recognized_to_Date__c != null && ali.Revenue_Recognized_to_Date__c != 0) ||
                (ali.Total_Invoiced_to_Date__c != null && ali.Total_Invoiced_to_Date__c != 0))
            {
                ali.addError('Attention: You cannot delete Activity Line Items that have either been recognized in revenue or have been invoiced');
            }
        }
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.validateDeletion() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void evalVSOERequirement(List<Activity_Line_Item__c> newTrigger)
    {

		system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.evalVSOERequirement() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> billingContractIds = new Set<Id>();
        Map<Id, Set<String>> bcRevenueElementTypeMap = new Map<Id, Set<String>>();
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            billingContractIds.add(ali.Billing_Contract__c);
        }
        
        List<Activity_Line_Item__c> aliUpdateList = [SELECT Id, Revenue_Category__c, Billing_Contract__c
                                                     FROM Activity_Line_Item__c
                                                     WHERE Billing_Contract__c IN : billingContractIds];
        
        for (Activity_Line_Item__c ali : aliUpdateList)
        {
            
            String value = ali.Billing_Contract__c + '|' + ali.Revenue_Category__c;
            
            if (bcRevenueElementTypeMap.containsKey(ali.Billing_Contract__c))
            {
                if (!bcRevenueElementTypeMap.get(ali.Billing_Contract__c).contains(value))
                {
                    Set<String> tmpset = bcRevenueElementTypeMap.get(ali.Billing_Contract__c);
                    tmpset.add(value);
                    bcRevenueElementTypeMap.put(ali.Billing_Contract__c, tmpset);
                }
            }
            else
            {
                Set<String> tmpset = new Set<String>();
                tmpset.add(value);
                bcRevenueElementTypeMap.put(ali.Billing_Contract__c, tmpset);
            }
        }
        
        for (Activity_Line_Item__c ali : aliUpdateList)
        {
            if (bcRevenueElementTypeMap.containsKey(ali.Billing_Contract__c))
            {
                Set<String> revcats = bcRevenueElementTypeMap.get(ali.Billing_Contract__c);
                if (!revcats.contains('Software') || revcats.size() <= 1)
                {
                    ali.VSOE_Calculation_Status__c = 'N/A';
                }
            }
        }
        
        List<Billing_Contract__c> bcUpdateList = new List<Billing_Contract__c>();
        
        for (Billing_Contract__c bc : [SELECT id, VSOE_Calculation_Status__c FROM Billing_Contract__c WHERE id in :bcRevenueElementTypeMap.keyset()])
        {
            Set<String> revcats = bcRevenueElementTypeMap.get(bc.id);
            if (!revcats.contains('Software') || revcats.size() <= 1)
            {
                bc.VSOE_Calculation_Status__c = 'N/A';
                bcUpdateList.add(bc);
            }
        }
        
        system.debug(' **** aliUpdateList = ' + aliUpdateList);
        
        update aliUpdateList;
        update bcUpdateList;
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.evalVSOERequirement() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void linkALIandDI(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldMap) 
    {
        
        // METHOD TO LINK ACTIVITY LINE ITEM & DEPLOYMENT INSTANCE - ADDED BY SHASHIAKNT ON 08/16/2018
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.linkALIandDI() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //if (!isDIALILinked) 
        if (!isDIALILinked_afterInsert || !isDIALILinked_afterUpdate) 
        {
            
            Set<Id> accIdSet = new Set<Id>();
            Set<Id> prodIdSet = new Set<Id>();
            Set<Id> aliIdSet = new Set<Id>();
            Set<Id> optyIdSet = new Set<Id>();
            
            // CREATE SET OF ACCOUNT ID, PRODUCT ID & ALI ID
            for (Activity_Line_Item__c ali : newTrigger) 
            {
                accIdSet.add(ali.Account__c);
                prodIdSet.add(ali.Product__c);
                aliIdSet.add(ali.id);
                optyIdSet.add(ali.Opportunity__c);
            }
            
            Set<Id> allAccounts = new Set<Id>();
            
            // GET THE RELATED ACCOUNTS FROM OPPORTUNITY & CREATE MAP "Opportunity__c | accprod.Product__c => DI"
            Integer k = 1;
            Map<String, Map<Integer, String>> accProd_map_WithOpp = new Map<String, Map<Integer, String>>();
            for(AH_Account_Product__c accprod : [SELECT Id, Account__c, Product__c, Opportunity__c, Deployment_Instance__c 
                                                 FROM AH_Account_Product__c 
                                                 WHERE Opportunity__c IN : optyIdSet 
                                                 AND Product__c IN : prodIdSet])
            {
                // CREATE SET OF RELATED ACCOUNTS
                allAccounts.add(accprod.Account__c);
                
                // CREATE MAP "Opportunity__c | accprod.Product__c => DI"
                String key = accprod.Opportunity__c + '|' + accprod.Product__c;
                if (accProd_map_WithOpp != NULL && accProd_map_WithOpp.containsKey(key))
                {
                    Map<Integer,String> iMap = new Map<Integer,String>();
                    iMap = accProd_map_WithOpp.get(key);
                    iMap.put(k, accprod.Deployment_Instance__c);
                    accProd_map_WithOpp.put(key, iMap);
                }
                else 
                {
                    Map<Integer,String> innerMap = new Map<Integer,String>();
                    innerMap.put(k, accprod.Deployment_Instance__c);
                    accProd_map_WithOpp.put(key, innerMap);
                }
                k++;
            }
            
            allAccounts.addAll(accIdSet);
            
            system.debug(' **** accProd_map_WithOpp = ' + accProd_map_WithOpp);
            system.debug(' **** allAccounts = ' + allAccounts);
            
            // CREATE DEPLOYMENT INSTACE MAP
            Map<String, Asset> di_map = new Map<String, Asset>();
            di_map = fetchDeploymentInstance(allAccounts, prodIdSet);
            
            Integer i = 1;
            Map<String, Map<Integer, String>> ali_map = new Map<String, Map<Integer, String>>();
            String key = '';
            Map<String, Map<Integer, String>> ali_map_WithOpp = new Map<String, Map<Integer, String>>();
        	String ali_key1 = '';
            
            for (Activity_Line_Item__c ALI: [SELECT Account__c, Id, Product__c, Opportunity__c 
                                             FROM Activity_Line_Item__c 
                                             WHERE Account__c IN : allAccounts 
                                             AND Opportunity__c IN : optyIdSet 
                                             AND Product__c IN : prodIdSet
                                             AND Id IN : aliIdSet])
            {
                // CREATE "ACCOUNT | PRODUCT => ALI" 	MAP
                key = ALI.Account__c + '|' + ALI.Product__c;
                
                if (ali_map != null && ali_map.containsKey(key))
                {                    
                    Map<Integer, String> iMap = new Map<Integer, String>();
                    iMap = ali_map.get(key);
                    iMap.put(i, ALI.id);
                    ali_map.put(key, iMap);
                }
                else 
                {
                    Map<Integer, String> innerMap = new Map<Integer, String>();
                    innerMap.put(i, ALI.id);
                    ali_map.put(key, innerMap);
                }
                
                // CREATE "OPPORTUNITY | PRODUCT => ALI" 	MAP 
                ali_key1 = ALI.Opportunity__c + '|' + ALI.Product__c;
                
                if (ali_map_WithOpp != null && ali_map_WithOpp.containsKey(ali_key1))
                {
                    
                    Map<Integer, String> iMap = new Map<Integer, String>();
                    iMap = ali_map_WithOpp.get(ali_key1);
                    iMap.put(i, ALI.id);
                    ali_map_WithOpp.put(ali_key1, iMap);
                }
                else 
                {
                    Map<Integer, String> innerMap = new Map<Integer, String>();
                    innerMap.put(i, ALI.id);
                    ali_map_WithOpp.put(ali_key1, innerMap);
                }
                i++;
            }
            
            system.debug(' **** ali_map = ' + ali_map.size());
            system.debug(' **** ali_map_WithOpp = ' + ali_map_WithOpp.size());
            
            set<String> aliSet = new set<String>();
            set<String> DISet = new set<String>();
            Map<String, DI_to_Activity_Line_Item__c> junctionObjMap = new Map<String, DI_to_Activity_Line_Item__c>();
            
            // CREATE JUNCTION OBJECT MAP COMPARING ACCOUNT & PRODUCT
            if (!ali_map.isEmpty())
            {
                for (String key1 : di_map.keyset())
                {                
                    if (ali_map.containsKey(key1))
                    {
                        
                        //system.debug('di_map.get(key1).id : '+di_map.get(key1).id);
                        
                        Map<Integer, String> iMap = ali_map.get(key1);
                        for (String iVal : iMap.values())
                        {
                            DI_to_Activity_Line_Item__c juncObj = new DI_to_Activity_Line_Item__c();
                            juncObj.Activity_Line_Item__c = iVal;
                            juncObj.Deployment_Instance__c = di_map.get(key1).id;
                            
                            junctionObjMap.put(iVal + '_' + juncObj.Deployment_Instance__c, juncObj);
                            
                            aliSet.add(juncObj.Activity_Line_Item__c);
                            DISet.add(juncObj.Deployment_Instance__c);
                        }
                    }
                }
            }
            
            //system.debug(' **** junctionObjMap 1 = ' + junctionObjMap);
            
            // // CREATE JUNCTION OBJECT MAP COMPARING OPPORTUNITY & PRODUCT
            if (!accProd_map_WithOpp.isEmpty()) 
            {
                for (String mapKey :accProd_map_WithOpp.keyset()) 
                {
                    if (ali_map_WithOpp.containsKey(mapKey))
                    {
                        for (String DI : accProd_map_WithOpp.get(mapKey).values())
                        {
                            //system.debug('DI : '+DI);
                            
                            for (String ALI : ali_map_WithOpp.get(mapKey).values())
                            {
                                DI_to_Activity_Line_Item__c juncObj = new DI_to_Activity_Line_Item__c();
                                juncObj.Activity_Line_Item__c = ALI;
                                juncObj.Deployment_Instance__c = DI;
                                
                                junctionObjMap.put(ALI + '_' + DI, juncObj);
                                
                                aliSet.add(juncObj.Activity_Line_Item__c);
                                DISet.add(juncObj.Deployment_Instance__c);
                            }
                        }
                    }
                }
            }
            
            
            // ADDED THIS CODE TO REMOVE - 'Required fields are missing: [Deployment Instance]' error
            // IF Deployment Instance IS NULL IN junctionObjMap, THEN REMOVING THEM
            system.debug('Before junctionObjMap size : '+junctionObjMap.size());
            for(String s : junctionObjMap.keyset())
            {
                if (junctionObjMap.get(s).Deployment_Instance__c == NULL)
                {
                    junctionObjMap.remove(s);
                    system.debug('Removed : '+s +' => '+junctionObjMap.get(s));
                }
            }
            system.debug('After junctionObjMap size : '+junctionObjMap.size());
            

            if (!aliSet.isEmpty() && !DISet.isEmpty()) 
            {
                // REMOVE ELEMENT FROM 'junctionObjMap' IF RECORD ALREADY PRESENT ON DI_to_Activity_Line_Item__c
                for (DI_to_Activity_Line_Item__c d : [SELECT Id, Activity_Line_Item__c, Deployment_Instance__c 
                                                      FROM DI_to_Activity_Line_Item__c 
                                                      WHERE Activity_Line_Item__c IN : aliSet 
                                                      AND Deployment_Instance__c IN : DISet])
                {   
                    if (junctionObjMap.containsKey(d.Activity_Line_Item__c + '_' + d.Deployment_Instance__c))
                    {
                        junctionObjMap.remove(d.Activity_Line_Item__c + '_' + d.Deployment_Instance__c);
                    }
                }
                
                system.debug('2 After junctionObjMap size : '+junctionObjMap.size());
                
                List<DI_to_Activity_Line_Item__c> finalAll_DItoALI = new List<DI_to_Activity_Line_Item__c>();
                finalAll_DItoALI = junctionObjMap.values();
                system.debug('finalAll_DItoALI : ' + finalAll_DItoALI);
                
                // INSERT RECORDS IN DI_to_Activity_Line_Item__c
                try 
                {
                    if (!finalAll_DItoALI.isEmpty()) 
                    {
                        insert finalAll_DItoALI;
                    }
                }
                catch (Exception e)
                {
                    system.debug(' **** Exception while inserting records in DI_to_Activity_Line_Item__c at line : ' + e.getLineNumber() + ' => ' + e);
                }
                
            }
            system.debug(' **** Queries = ' + Limits.getQueries());
        }
        
        // isDIALILinked = true;
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.linkALIandDI() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private Map<String, Asset> fetchDeploymentInstance(Set<Id> accountIds, Set<Id> productIds)
    {   
        
        // Method for Querying the Deployment Instances related to a particular set of Accounts and Products
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.fetchDeploymentInstance() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<String, Asset> di_map = new Map<String, Asset>();
        for (Asset deploymentInstance : [SELECT AccountId, Id, Product2Id, InstallDate
                                         FROM Asset
                                         WHERE AccountId IN : accountIds 
                                         AND Product2Id IN : productIds])
        {       
            String key = deploymentInstance.AccountId + '|' + deploymentInstance.Product2Id;
            di_map.put(key, deploymentInstance); 
        }
        
        system.debug(' **** RETURNING di_map = ' + di_map);
        
        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.fetchDeploymentInstance() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return di_map;
        
    }
    
    private void rebuildRevenueSchedules(Set<Id> setALIIds)
    {
        
        // Deletes and Rebuilds the Revenue Schedules

        system.debug(' *** ENTERING AH_ActivityLineItem_TriggerHandler.rebuildRevenueSchedules() - QUERIES ISSUED = ' + Limits.getQueries());

        // CREATE REV REQ TEMPLATE LOOKUP MAP
		Map<Id, ffrr__Template__c> revTemplateMap = new Map<Id, ffrr__Template__c>([SELECT Id, ffrr__RevRecType__c FROM ffrr__Template__c]);

        // GET REVENUE SCHEDULE RECORDTYPE ID WITHOUT ISSUING A SOQL QUERY
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Revenue_Schedule__c.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rtInfo = recordTypesMap.get('Active Revenue');
        Id ActiveRevRecTypeId = rtInfo.getRecordTypeId();         

        // 'Active Revenue' REVENUE SCHEDULE DELETE LIST
        List<Revenue_Schedule__c> lstRevenueScheduleDeletes = new List<Revenue_Schedule__c>(); 
        
        // LOOK FOR 'Active Revenue' REVENUE SCHEDULE RECORDS AND ADD TO LIST TO DELETE
        for (Revenue_Schedule__c rs : [SELECT Id FROM Revenue_Schedule__c WHERE Activity_Line_Item__c IN : setALIIds AND RecordTypeId =: ActiveRevRecTypeId])
        {
            lstRevenueScheduleDeletes.add(rs);
        }

        // IF 'Active Revenue' REVENUE SCHEDULE RECORDS FOUND, DELETE THEM
        if (!setALIIds.isEmpty())
        {
            try
            {
                database.delete(lstRevenueScheduleDeletes);
            }
            catch (Exception ex)
            {
                system.debug(' **** ERROR: When deleting Revenue Schedule Records: ' + ex.getMessage());
            }
        }   

        // 'Active Revenue' REVENUE SCHEDULE INSERT LIST
        List<Revenue_Schedule__c> lstRevenueScheduleInserts = new List<Revenue_Schedule__c>();

		//for (Activity_Line_Item__c ali : newTrigger)
        for (Activity_Line_Item__c ali : [SELECT Id, ffrrtemplate__c, Contract_Start_Date__c, Contract_End_Date__c,  
                                          CurrencyIsoCode, Total_Revenue_to_Recognize__c, Adjusted_Revenue_Amount__c
                                          FROM Activity_Line_Item__c 
                                          WHERE Id IN : setALIIds])
        {
            
			if (revTemplateMap.containsKey(ali.ffrrtemplate__c))
            {
                
				ffrr__Template__c template = revTemplateMap.get(ali.ffrrtemplate__c);
                
				if (template.ffrr__RevRecType__c == 'Equal Split')
                {
                    
					if (ali.Contract_Start_Date__c != null && ali.Contract_End_Date__c != null)
                    {
                        
						Integer schedCreated = 0;
						Integer schedToCreate = ali.Contract_Start_Date__c.monthsBetween(ali.Contract_End_Date__c);
						Integer totalDays = ali.Contract_Start_Date__c.daysBetween(ali.Contract_End_Date__c) + 1;
						Double totalDaysDouble = totalDays;
						Decimal totalAmountReleased = 0;
						Date schedDate = ali.Contract_Start_Date__c;

						while (schedCreated <= schedToCreate)
                        {
                            
							Integer daysinPeriod = Date.daysinMonth(schedDate.year(), schedDate.month());
							Integer allocationdays = daysinPeriod;
                            
                            // if it's the first then calculate the starting 
							if (schedCreated == 0)
							{
								allocationdays = daysinPeriod - ali.Contract_Start_Date__c.day()+1;
							}
                            
                            // if this is the last item then account for potential partial periods
							if (schedCreated == schedToCreate)
							{
								allocationdays = ali.Contract_End_Date__c.day() -1;
							}
                            
							Double allocationdaysDouble = allocationdays;
							Decimal deferredAmount = ((allocationdaysDouble / totalDaysDouble) * ali.Total_Revenue_to_Recognize__c).setScale(2); 
							totalAmountReleased += deferredAmount;

                            // if this is the last item then also account for rounding errors
							if (schedCreated == schedToCreate)
							{
								if (totalAmountReleased != ali.Total_Revenue_to_Recognize__c)
								{
									deferredAmount -= (totalAmountReleased - ali.Total_Revenue_to_Recognize__c);
								}
							}
                            
                            Revenue_Schedule__c revSchedule = new Revenue_Schedule__c();
                            revSchedule.RecordTypeId = ActiveRevRecTypeId;
                            revSchedule.Start_Date__c = schedDate;
                            revSchedule.End_Date__c = ali.Contract_End_Date__c < schedDate.addMonths(1).toStartofMonth().addDays(-1) ? ali.Contract_End_Date__c : schedDate.addMonths(1).toStartofMonth().addDays(-1);
                            revSchedule.Activity_Line_Item__c = ali.Id;
                            revSchedule.CurrencyIsoCode = ali.CurrencyIsoCode;
                            revSchedule.Deferred_Revenue_Amount__c = deferredAmount;
                            lstRevenueScheduleInserts.add(revSchedule);
                            
							// increment some key variables
							schedDate = schedDate.addMonths(1).toStartofMonth();
							schedCreated += 1;
                            
						}
					}
				}
                
                if (template.ffrr__RevRecType__c == 'Deliverable')
                {
                    // ACTIVE REVENUE SCHEDULE RECORDS                            
                    Revenue_Schedule__c revSchedule = new Revenue_Schedule__c();
                    revSchedule.RecordTypeId = ActiveRevRecTypeId;
                    revSchedule.Start_Date__c = ali.Contract_End_Date__c;
                    revSchedule.End_Date__c = ali.Contract_End_Date__c;
                    revSchedule.Activity_Line_Item__c = ali.Id;
                    revSchedule.CurrencyIsoCode = ali.CurrencyIsoCode;
                    revSchedule.Deferred_Revenue_Amount__c = ali.Adjusted_Revenue_Amount__c;
                    lstRevenueScheduleInserts.add(revSchedule);
                }
                
			}
            
		}

        if (!lstRevenueScheduleInserts.isEmpty())
        {
            insert lstRevenueScheduleInserts;
        }
        
        system.debug(' *** EXITING AH_ActivityLineItem_TriggerHandler.rebuildRevenueSchedules() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }    

    private void persistDecimalPlaces(List<Activity_Line_Item__c> newTrigger, Map<Id, Activity_Line_Item__c> oldMapTrigger)
    {
        
        for (Activity_Line_Item__c ali : newTrigger)
        {
            if (oldMapTrigger.containsKey(ali.Id))
            {
                Activity_Line_Item__c oldALI = oldMapTrigger.get(ali.Id);
                if (oldALI.Contract_Amount__c != null)
                {
                    system.debug('*^* dRemainder = (' + oldALI.Contract_Amount__c + ' - ' + ali.Contract_Amount__c + ')');                         
                    Decimal dRemainder = Math.abs(oldALI.Contract_Amount__c - ali.Contract_Amount__c);
                    system.debug('*^* dRemainder = ' + dRemainder);
                    // IF Unit Price HAS CHANGED (dRemainder != 0) AND DECIMALS MISSING AFTER THE HUNDREDTH PLACE (dRemainder < .01)
                    if (dRemainder != 0 && dRemainder < .01)
                    {
                        // RESTORE NEW "Unit Price" Contract_Amount__c FROM OLD Contract_Amount__c 
                        ali.Contract_Amount__c = oldALI.Contract_Amount__c;
                    }              
                }
            }
        }
        
    }
        
}