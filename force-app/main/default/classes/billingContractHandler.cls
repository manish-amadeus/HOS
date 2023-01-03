/****************************************************************************************
Name            : billingContractHandler
Author          : CLD
Created Date    : 11/13/2015
Last Mod Date   : 04/08/2019
Last Mod By     : Sean Harris
Description     : Contains various methods for interacting with Billing Contracts
                : Updated 10/27/2017 per NICC-024530
				: Updated 08/31/2018 per NICC-029803
				: UPDATED 04/08/2019 per NICC-033935 - 
				: 	Because this is a class of static methods, 
				: 	moved public methods for Billing Contract Trigger handling to 
				: 	AH_Billing_Contract_TriggerHandler
******************************************************************************************/
global class billingContractHandler 
{

    // Queries the Account Team to retrieve the NI Collector
    public static Map<Id, Id> getAccountTeam(Set<Id> acctIds)
    {
        Map<Id, Id> returnMap = new Map<Id, Id>();
        for (AccountTeamMember atm : [SELECT AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE accountid IN : acctIds AND TeamMemberRole = 'NI Collector'])
        {
            returnMap.put(atm.AccountId, atm.UserId);
        }
        return returnMap;
    }    
    
    // Method for Querying the Deployment Instances related to a particular set of Accounts and Products  (REFERENCED BY billingContract_TEST) 
    public static Map<String, Asset> fetchDeploymentInstance(Set<Id> accountIds, Set<Id> productIds)
    {	
        Map<String, Asset> di_map = new Map<String, Asset>();
        for(Asset deploymentInstance : [
            SELECT 
            AccountId, 
            Id, 
            Product2Id,
            InstallDate
            FROM Asset
            WHERE AccountId in :accountIds 
            AND Product2Id in :productIds])
        {		
            String key = deploymentInstance.AccountId + '|' + deploymentInstance.Product2Id;
            di_map.put(key, deploymentInstance); 
        }
        system.debug(' *** billingContractHandler - fetchDeploymentInstance - di_map = ' + di_map);
        return di_map;
    }

    // Method for applying the deplyment instance to Billing Line Items  (REFERENCED BY billingContract_TEST)
    public static Id applyDeploymentInstance(Map<String, Asset> diMap, OpportunityLineItem oli)
    {	
        Id returnId;
        String key = oli.Opportunity.AccountId + '|' + oli.Product2Id;
        if (diMap.containsKey(key))
        {
            returnId = diMap.get(key).id;
        }
        return returnId;
    }

    // Method to re-cast the Billing Line Items from an Activity Line  (REFERENCED BY AH_ActivityLineItem_TriggerHandler, billingContractSplitLinesController, ffaActivityLineItemCloneController)
    public static List<Billing_Contract_Line_Item__c> recalcBillingLines(List<Activity_Line_Item__c> aliList, Boolean doDelete)
    {
        
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        
        if (doDelete == true)
        {
            List<Billing_Contract_Line_Item__c> deleteList = [SELECT Id FROM Billing_Contract_Line_Item__c WHERE Activity_Line_Item__c IN : aliList];
            delete deleteList;
        }
        
        Set<Id> paymentTermsIds = new Set<Id>();
        for (Activity_Line_Item__c ali : aliList)
        {
            paymentTermsIds.add(ali.Payment_Terms__c);
        }
        
        Map<Id, Payment_Terms__c> paymentTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT
            Id,
            Offset_Date__c,
            Activation_Required__c,
            Invoice_Split_Method__c,
            Billed_through_PSA__c,
            Bill_if_Activation_Date_comes_first__c,
            (SELECT
             Id,
             Order__c,
             Offset_Measure__c,
             Offset_Units__c,
             Percent_of_Total__c,
             Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             Order BY Order__c)
            FROM
            Payment_Terms__c
            WHERE id in :paymentTermsIds
        ]);
        
        Set<String> revenueCategoriesToApply = new Set<String>{'Support','Hosting and Support','Subscription'};
            
        for(Activity_Line_Item__c ali : aliList)
        {
            
            Payment_Terms__c pmtTerms;
            
            if (paymentTermsMap.containsKey(ali.Payment_Terms__c))
            {
                pmtTerms = paymentTermsMap.get(ali.Payment_Terms__c);
            }
            
            system.assert(pmtTerms != null, 'No applicable payment terms found!');
            
            Integer numberOfInvoicesToCreate = pmtTerms.Payment_Term_Line_Items__r.size();
            Date invoiceStartDate = ali.Contract_Start_Date__c != null ? ali.Contract_Start_Date__c : ali.Billing_Contract__r.Effective_Date__c;
            Date invoiceDate;
            
            //PRO RATA THE INVOICE BASED ON THE PRO-RATA DATE, DISREGARD THE OTHER PAYMENT TERMS
            //if(ali.Pro_Rated__c == true)
            //{
            //	continue;
            //}
            
            // if number of invoices is > 1, split out the single Opp line into multiple billing line items.
            if (numberOfInvoicesToCreate >= 1)
            {
                
                system.debug(' *** billingContractHandler - paymentSplit_Billing - ENTER > 1 *****');
                Integer invoicesCreated = 0;
                Map<Decimal, Decimal> totalAmountMap = new Map<Decimal, Decimal>();
                Map<Decimal, Decimal> unitPriceMap = new Map<Decimal, Decimal>();
                
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r) // populate the invoice amount map based on the order
                {
                    Decimal invoiceAmount;
                    Decimal unitPriceAmount;
                    if (pmtTerms.Invoice_Split_Method__c == 'Equal')
                    {
                        invoiceAmount = ((ali.Contract_Amount__c * ali.Units__c) / numberOfInvoicesToCreate).setscale(2);
                        unitPriceAmount = ((ali.Contract_Amount__c / numberOfInvoicesToCreate).setscale(2));
                        totalAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        unitPriceMap.put(pmtLine.Order__c, unitPriceAmount);
                    }
                    if (pmtTerms.Invoice_Split_Method__c == 'Percent Breakdown')
                    {
                        invoiceAmount = ((ali.Contract_Amount__c * ali.Units__c) * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        unitPriceAmount = ((ali.Contract_Amount__c) * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        totalAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        unitPriceMap.put(pmtLine.Order__c, unitPriceAmount);
                    }
                }
                
                Decimal billingLinesTotal = 0; //this will store the summed amount, we may need to adjust this for rounding
                Decimal roundingAdjustment = 0;
                
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r)
                {
                    if (invoicesCreated != 0) //if this is not the first item in the list, then add months / days / years.
                    {
                        if (pmtLine.Offset_Measure__c == 'Days' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = invoiceStartDate.addDays(pmtLine.Offset_Units__c.intValue());
                        }
                        if (pmtLine.Offset_Measure__c == 'Months' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = invoiceStartDate.addMonths(pmtLine.Offset_Units__c.intValue());
                        }
                        if (pmtLine.Offset_Measure__c == 'Years' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = invoiceStartDate.addYears(pmtLine.Offset_Units__c.intValue());
                        }
                    }
                    else // if its the first item, then the date will be the invoice start date
                    {
                        invoiceDate = invoiceStartDate;
                    }
                    
                    String lineDescription = pmtLine.Invoice_Line_Description__c != null ? pmtLine.Invoice_Line_Description__c : null;
                    
                    Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
                    bcli.Invoice_Date__c = invoiceDate;
                    bcli.Product__c = ali.Product__c;
                    bcli.Opp_Line_Item_ID__c = ali.Opp_Product_ID__c;
                    bcli.Payment_Term_Line_Item__c = pmtLine.id;
                    bcli.Billing_Contract__c = ali.Billing_Contract__c;
                    bcli.Product_Package__c = ali.Product_Package__c;
                    bcli.Pro_Rated__c = ali.Pro_Rated__c;
                    bcli.Product_Package_Item__c = ali.Product_Package_Item__c;
                    bcli.Revenue_Category__c = ali.Revenue_Category__c;
                    bcli.Line_Item_Description__c = lineDescription;
                    bcli.Opportunity__c = ali.Opportunity__c;
                    bcli.Split_Order__c = invoicesCreated + 1;
                    bcli.Quantity__c = ali.Units__c;
                    bcli.Unit_Price__c = unitPriceMap.get(pmtLine.Order__c).setScale(2);
                    bcli.Total_Amount__c = totalAmountMap.get(pmtLine.Order__c).setScale(2);
                    bcli.Payment_Terms__c = ali.Payment_Terms__c;
                    bcli.Activation_Required__c = ali.Activation_Required__c;
                    bcli.Status__c = ali.Activation_Date__c != null ? 'Active' : 'Pending';
                    bcli.Deployment_Instance__c = ali.Deployment_Instance__c;
                    bcli.CurrencyIsoCode = ali.CurrencyIsoCode;
                    bcli.Activity_Line_Item__c = ali.id;
                    
                    if (bcli.Line_Item_Description__c == null || bcli.Line_Item_Description__c == '')
                    {
                        if (revenueCategoriesToApply.contains(bcli.Revenue_Category__c) && ali.Contract_Start_Date__c != null && ali.Contract_End_Date__c != null)
                        {
                            bcli.Line_Item_Description__c = bcli.Revenue_Category__c + ' - Start: ' + ali.Contract_Start_Date__c.format() + ' End: ' + ali.Contract_End_Date__c.format();
                        }
                    }
                    
                    billingLinesTotal += bcli.Total_Amount__c; //keep track of the total amount being applied to the lines
                    
                    invoicesCreated ++;
                    if (invoicesCreated == numberOfInvoicesToCreate) //this is the last item to create so account for any rounding.
                    {
                        roundingAdjustment = (ali.Contract_Amount__c * ali.Units__c) - billingLinesTotal;
                        bcli.Unit_Price__c += roundingAdjustment.setScale(2);
                        bcli.Total_Amount__c += roundingAdjustment.setScale(2);
                        system.debug('***** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - billingLinesTotal = '+ billingLinesTotal);
                        system.debug('***** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - ali.Contract_Total_Amount__c = '+ ali.Contract_Total_Amount__c);
                        system.debug('***** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - ROUNDING ADJUSTMENT = '+ roundingAdjustment);
                        
                    }
                    returnList.add(bcli);
                    system.debug(' *** billingContractHandler - paymentSplit_Billing - invoicesCreated =' + invoicesCreated);
                }
                continue;
            }
        }
        
        return returnList;
        
    }

    // Method to re-cast the Billing Line Items from a pro-rated Activity Line  (REFERENCED BY manageActivityLinesController)
    public static List<Billing_Contract_Line_Item__c> recalcBillingLinesProRated(List<Activity_Line_Item__c> aliList, Boolean doDelete)
    {
        
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        
        if (doDelete == true)
        {
            List<Billing_Contract_Line_Item__c> deleteList = [SELECT Id FROM Billing_Contract_Line_Item__c WHERE Activity_Line_Item__c in :aliList];
            delete deleteList;
        }
        
        Set<Id> paymentTermsIds = new Set<Id>();
        for (Activity_Line_Item__c ali : aliList)
        {
            paymentTermsIds.add(ali.Payment_Terms__c);
        }
        
        Map<Id, Payment_Terms__c> paymentTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT
            Id,
            Offset_Date__c,
            Activation_Required__c,
            Invoice_Split_Method__c,
            Billed_through_PSA__c,
            Bill_if_Activation_Date_comes_first__c,
            (SELECT
             Id,
             Order__c,
             Offset_Measure__c,
             Offset_Units__c,
             Percent_of_Total__c,
             Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             Order BY Order__c)
            FROM
            Payment_Terms__c
            WHERE id in :paymentTermsIds
        ]);
        
        for (Activity_Line_Item__c ali : aliList)
        {
            Date startDate = ali.Contract_Start_Date__c;
            Date proRateDate = ali.Contract_End_Date__c;
            Date endDate = ali.Contract_Start_Date__c.addMonths(ali.Product__r.Duration_Months__c.intValue());
            Decimal numerator = startDate.daysBetween(proRateDate);
            Decimal denominator = startDate.daysBetween(endDate);
            Decimal proRataPercent = numerator/denominator.setScale(2);
            Decimal amount = ali.Contract_Amount__c; //it's already been pro-rated
            
            Payment_Terms__c pmtTerms;
            if (paymentTermsMap.containsKey(ali.Payment_Terms__c))
            {
                pmtTerms = paymentTermsMap.get(ali.Payment_Terms__c);
            }
            
            system.assert(pmtTerms != null, 'No applicable payment terms found!');
            
            Integer numberOfInvoicesToCreate = 1;
            Date invoiceStartDate = ali.Contract_Start_Date__c != null ? ali.Contract_Start_Date__c : null;
            Date invoiceDate;
            Set<String> revenueCategoriesToApply = new Set<String>{'Support','Hosting and Support','Subscription'};
                
            // if number of invoices is > 1, split out the single Opp line into multiple billing line items.
            if(numberOfInvoicesToCreate >= 1)
            {
                system.debug(' *** billingContractHandler - paymentSplit_Billing - ENTER > 1 *****');
                invoiceDate = invoiceStartDate;
                
                Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
                bcli.Invoice_Date__c = invoiceDate;
                bcli.Product__c = ali.Product__c;
                bcli.Opp_Line_Item_ID__c = ali.Opp_Product_ID__c;
                //bcli.Payment_Term_Line_Item__c = pmtLine.id;
                bcli.Billing_Contract__c = ali.Billing_Contract__c;
                bcli.Product_Package__c = ali.Product_Package__c;
                bcli.Pro_Rated__c = ali.Pro_Rated__c;
                bcli.Product_Package_Item__c = ali.Product_Package_Item__c;
                bcli.Revenue_Category__c = ali.Revenue_Category__c;
                bcli.Line_Item_Description__c = '';
                bcli.Opportunity__c = ali.Opportunity__c;
                bcli.Quantity__c = ali.Units__c;
                bcli.Unit_Price__c = amount.setScale(2);
                bcli.Total_Amount__c = amount*bcli.Quantity__c.setScale(2);
                bcli.Payment_Terms__c = ali.Payment_Terms__c;
                bcli.Activation_Required__c = ali.Activation_Required__c;
                bcli.Status__c = ali.Activation_Date__c != null ? 'Active' : 'Pending';
                bcli.Deployment_Instance__c = ali.Deployment_Instance__c;
                bcli.CurrencyIsoCode = ali.CurrencyIsoCode;
                bcli.Activity_Line_Item__c = ali.id;
                bcli.Line_Item_Description__c = 'Annual amount has been pro-rated for '+numerator.setScale(2).format()+' days to sync to the following date: \n'+proRateDate.format()+ ' | '+ ali.Renewal_Base_Price__c.setScale(2).format() +' / '+denominator.setScale(2).format() +' * '+ numerator.setScale(2).format()+' days = '+ amount.setScale(2).format() + '\n | ' + amount.setScale(2).format() + ' * '+ali.Units__c.setScale(0).format() +' = '+(bcli.Total_Amount__c).setScale(2).format();
                bcli.Line_Item_Description__c += '\n '+bcli.Revenue_Category__c + ' - Start: '+ali.Contract_Start_Date__c.format() + ' End: '+ali.Contract_End_Date__c.format();
                
                if (bcli.Line_Item_Description__c.length() > 255)
                {
                    bcli.Line_Item_Description__c = bcli.Line_Item_Description__c.left(255);
                }
                
                returnList.add(bcli);
                
            }
        }
        
        return returnList;
        
    }

    // Method to return Billing Contract Line Items  (REFERENCED BY AH_ActivityLineItem_TriggerHandler)
    public static List<Activity_Line_Item__c> returnActivityLineList(Set<Id> aliIds)
    {
        
        List<Activity_Line_Item__c> newAliList = [
            SELECT
            Product__r.Name,
            Product__r.ProductCode,
            Billing_Contract__r.Account__c,
            Activity_Project_Billing__c,
            Billing_Contract__c,
            Billing_Contract__r.VSOE_Calculation_Status__c,
            Billing_Contract__r.Effective_Date__c,
            Contract_Amount__c,
            Contract_End_Date__c,
            Contract_Start_Date__c,
            Contract_Total_Amount__c,
            CreatedById,
            Pro_Rated__c,
            Opp_Product_ID__c,
            CreatedDate,
            Final_SW_Group_Allocation__c,
            Attn_to_Contact__c,
            CurrencyIsoCode,
            Payment_Terms__c,
            Fair_Value__c,
            PCS_Days__c,
            Product_Package__c,
            Id,
            Activation_Date__c,
            VSOE_Element_Type__c,
            Activation_Required__c,
            IsDeleted,
            LastActivityDate,
            LastModifiedById,
            LastModifiedDate,
            List_Price__c,
            PSA_Milestone__c,
            Revenue_Category__c,
            Post_Contract_Support__c,
            Include_in_Revenue_Recognition__c,
            Name,
            Origin__c,
            Renewal_Date__c,
            Opportunity__c,
            Deployment_Instance__c,
            Auto_Renewal__c,
            Delivery_Offset_Months__c,
            No_Price_Increase_Through__c,
            Renewal_Comments__c,
            Suspend_Revenue_Recognition__c,
            Suspend_Revenue_Recognition_Reason__c,
            Suspend_Revenue_Recognition_Notes__c,
            Fulfillment_Date__c,
            Fulfillment_Complete__c,
            Fulfillment_Notes__c,
            Percent_of_Total__c,
            Product__c,
            Product_Description__c,
            Relative_Selling_Price_Allocation__c,
            Revenue_Recognized_to_Date__c,
            Service_Discount__c,
            Adjusted_Revenue_Amount__c,
            SKU__c,
            Product_Package_Item__c,
            Software_Discount__c,
            VSOE_Discount__c,
            SystemModstamp,
            ACTION_Rebuild_Billing_Lines__c,
            Units__c,
            VSOE_Pricing_Item__c
            FROM Activity_Line_Item__c
            WHERE Id IN : aliIds];
        
        return newAliList;
        
    }

    // Method to return Billing Contract Line Items  (REFERENCED BY AH_ActivityLineItem_TriggerHandler)
    public static List<Activity_Line_Item__c> returnActivityLineList(List<Activity_Line_Item__c> oldAliList)
    {
        List<Activity_Line_Item__c> newAliList = [
            SELECT
            Product__r.Name,
            Product__r.ProductCode,
            Billing_Contract__r.Account__c,
            Activity_Project_Billing__c,
            Softrax_Asset__c,
            Billing_Contract__c,
            Billing_Contract__r.VSOE_Calculation_Status__c,
            Billing_Contract__r.Effective_Date__c,
            Product_Package_Item__c,
            Contract_Amount__c,
            Contract_End_Date__c,
            Opp_Product_ID__c,
            Contract_Start_Date__c,
            Contract_Total_Amount__c,
            CreatedById,
            Pro_Rated__c,
            ACTION_Rebuild_Billing_Lines__c,
            CreatedDate,
            Final_SW_Group_Allocation__c,
            Attn_to_Contact__c,
            CurrencyIsoCode,
            Payment_Terms__c,
            Fair_Value__c,
            PCS_Days__c,
            Id,
            Activation_Date__c,
            Product_Package__c,
            VSOE_Element_Type__c,
            Activation_Required__c,
            IsDeleted,
            LastActivityDate,
            LastModifiedById,
            LastModifiedDate,
            List_Price__c,
            PSA_Milestone__c,
            Revenue_Category__c,
            Post_Contract_Support__c,
            Include_in_Revenue_Recognition__c,
            Name,
            Origin__c,
            Renewal_Date__c,
            Opportunity__c,
            Deployment_Instance__c,
            Auto_Renewal__c,
            Delivery_Offset_Months__c,
            No_Price_Increase_Through__c,
            Renewal_Comments__c,
            Suspend_Revenue_Recognition__c,
            Suspend_Revenue_Recognition_Reason__c,
            Suspend_Revenue_Recognition_Notes__c,
            Fulfillment_Date__c,
            Fulfillment_Complete__c,
            Fulfillment_Notes__c,
            Percent_of_Total__c,
            Product__c,
            Product_Description__c,
            Relative_Selling_Price_Allocation__c,
            Revenue_Recognized_to_Date__c,
            Service_Discount__c,
            Adjusted_Revenue_Amount__c,
            SKU__c,
            Software_Discount__c,
            VSOE_Discount__c,
            SystemModstamp,
            Order_of_Delivery__c,
            Units__c,
            VSOE_Pricing_Item__c,
            (SELECT Id,
             Quantity__c,
             Unit_Price__c
             FROM Billing_Contract_Line_Items__r)
            FROM Activity_Line_Item__c
            WHERE Id IN : oldAliList];
        
        return newAliList;
        
    }

    // Method to calculate the pro-Rated Amount on Billing Lines  (REFERENCED BY manageActivityLinesController)
    public static Billing_Contract_Line_Item__c proRateInvoiceAmount_Billing(Billing_Contract_Line_Item__c bcli, Date startDate, Date endDate, Date proRateDate, Decimal amount, Activity_Line_Item__c ali)
    {
        
        Decimal numerator = startDate.daysBetween(proRateDate) + 1;
        Decimal denominator = startDate.daysBetween(endDate) - 1;
        Decimal proRataPercent = numerator/denominator.setScale(2);
        bcli.Pro_Rated__c = true;
        bcli.Total_Amount__c = (amount * proRataPercent * ali.Units__c).setScale(2);
        bcli.Unit_Price__c = (amount * proRataPercent).setScale(2);
        bcli.Line_Item_Description__c = 'Annual amount has been pro-rated for ' + numerator.setScale(2).format() + ' days to sync to the following date: \n' + proRateDate.format() + ' | ' + amount.setScale(2).format() + ' / ' + denominator.setScale(2).format() + ' * ' + numerator.setScale(2).format() + ' days = ' + (amount * proRataPercent).setScale(2).format() + '\n | ' + (amount * proRataPercent).setScale(2).format() + ' * ' + ali.Units__c.setScale(0).format() + ' = ' + (bcli.Total_Amount__c).setScale(2).format();
        bcli.Line_Item_Description__c += '\n ' + bcli.Revenue_Category__c + ' - Start: ' + ali.Contract_Start_Date__c.format() + ' End: ' + ali.Contract_End_Date__c.format();
        
        if (bcli.Line_Item_Description__c.length() > 255)
        {
            bcli.Line_Item_Description__c = bcli.Line_Item_Description__c.left(255);
        }
        
        return bcli;
        
    }

    // Method to calculate the pro-Rated Amount on Activity Lines  (REFERENCED BY manageActivityLinesController)
    public static Activity_Line_Item__c proRateInvoiceAmount_Activity(Activity_Line_Item__c ali, Date startDate, Date endDate, Date proRateDate, Decimal amount)
    {
        Decimal numerator = startDate.daysBetween(proRateDate) + 1;
        Decimal denominator = startDate.daysBetween(endDate);
        Decimal proRataPercent = numerator/denominator.setScale(2);
        ali.Pro_Rated__c = true;
        ali.Pro_Rated_Date__c = proRateDate;
        system.debug(' *** billingContractHandler - proRateInvoiceAmount_Activity - input proRataPercent = '+proRataPercent);
        ali.Contract_Amount__c = (amount * proRataPercent).setScale(2);
        system.debug(' *** billingContractHandler - proRateInvoiceAmount_Activity - input proRataPercent = '+proRataPercent);
        system.debug(' *** billingContractHandler - proRateInvoiceAmount_Activity - ali.Contract_Amount__c = '+ali.Contract_Amount__c);
        //ali.Line_Item_Description__c = 'Annual amount has been pro-rated for '+numerator.setScale(2).format()+' days to match the Org renewal date. \n'+ amount.setScale(2).format() +' / '+denominator.setScale(2).format() +' * '+ numerator.setScale(2).format()+' days = '+ bcli.Unit_Price__c.setScale(2).format() + '\n' + unitPrice.setScale(2).format() + ' * '+oli.Quantity.setScale(0).format() +' = '+(unitPrice*oli.Quantity).setScale(2).format();;
        return ali;
    }
    
	// Method to return Billing Contract Line Items
    public static void resetOpportunityLines(Id oppId)
    {
        
        Set<String> oppProductIdSet = new Set<String>();
        Set<Id> restrictOliSet = new Set<Id>();
        Set<Id> restrictAliSet = new Set<Id>();
        List<OpportunityLineItem> fullOliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>();
        
        for (OpportunityLineItem oli : [SELECT Id, 
                                        BC_Line_Created__c, 
                                        Activity_Line_Created__c
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId =: oppId
                                        AND (BC_Line_Created__c = true OR Activity_Line_Created__c = true)])
        {
            oppProductIdSet.add(oli.id);
            fullOliList.add(oli);
        }
        
        for (Billing_Contract_Line_Item__c bli : [SELECT Id,Activity_Line_Item__c,Opp_Line_Item_ID__c
                                                 FROM Billing_Contract_Line_Item__c
                                                 WHERE Billing_Contract__r.Opportunity__c = :oppId
                                                 AND Invoiced__c = true])
        {
            restrictAliSet.add(bli.Activity_Line_Item__c);
            restrictOliSet.add(bli.Opp_Line_Item_ID__c);
        }
        
        system.debug(' *** billingContractHandler - resetOpportunityLines - restrictAliSet = '+ restrictAliSet);
        
        List<Activity_Line_Item__c> aliDeleteList = [SELECT Id
                                                     FROM Activity_Line_Item__c 
                                                     WHERE Opportunity__c =: oppId
                                                     AND Id not IN : restrictAliSet];
        
        system.debug(' *** billingContractHandler - resetOpportunityLines - aliDeleteList = '+ aliDeleteList);
        
        for (OpportunityLineItem oli : fullOliList)
        {
            if (!restrictOliSet.contains(oli.Id))
            {
                oli.Activity_Line_Created__c = false;
                oli.BC_Line_Created__c = false;
                updateOliList.add(oli);
            }
        }
        delete aliDeleteList;
        update updateOliList;
    }

    // webservice method that is invoked from the Opportunity
    Webservice static string resetOppLinesWS(Id oppId)
    {
        string message = '';
        try
        {
            billingContractHandler.resetOpportunityLines(oppId);
            message = 'SUCCESS';
        }
        catch (System.CalloutException e)
        {
            message = e.getMessage();
        }
        return message;
    }


// ========================================================================================================    
// INACTIVE / MIGRATED FUNCTIONS    
// ========================================================================================================



    
/*
    
    public static Map<String, Id> oppProductActivityLineMap;
    public static Map<String, Id> contactRoleMap;





















    // Method to return Billing Contract Line Items
    public static List<Billing_Contract_Line_Item__c> returnBillingContractLines(Id bcID)
    {
        List<Billing_Contract_Line_Item__c> bcliList = [
            SELECT
            Id,
            Name,
            Invoiced__c,
            Invoice_Date__c,
            Product__r.Name,
            Product__r.ProductCode,
            Total_Amount__c,
            Revenue_Category__c,
            Ready_to_Invoice__c,
            Type__c,
            Unit_Price__c
            FROM Billing_Contract_Line_Item__c
            WHERE Billing_Contract__c = : bcId];
        return bcliList;
    }
    

    // Method to handle user reduction from Cancellation Record
    public static void processUserReduction(List<NI_Cancellation__c> cancellationList)
    {
        
        Map<Id, NI_Cancellation__c> diCancelMap = new Map<Id, NI_Cancellation__c>();
        List<Activity_Line_Item__c> aliUpdateList = new List<Activity_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> bliUpdateList = new List<Billing_Contract_Line_Item__c>();
        
        for (NI_Cancellation__c can : cancellationList)
        {
            diCancelMap.put(can.Deployment_Instance__c, can);
        }
        
        for (Activity_Line_Item__c ali : [SELECT Id, Units__c, Deployment_Instance__c 
                                          FROM Activity_Line_Item__c 
                                          WHERE Deployment_Instance__c IN : diCancelMap.keyset()])
        {
            ali.Units__c = diCancelMap.get(ali.Deployment_Instance__c).Number_of_Users_Reduced__c != null ? ali.Units__c - diCancelMap.get(ali.Deployment_Instance__c).Number_of_Users_Reduced__c : ali.Units__c;
            aliUpdateList.add(ali);
        }
        
        for (Billing_Contract_Line_Item__c bli : [SELECT Id, Quantity__c, Deployment_Instance__c 
                                                  FROM Billing_Contract_Line_Item__c 
                                                  WHERE Deployment_Instance__c IN : diCancelMap.keyset() 
                                                  AND Invoiced__c = false])
        {
            bli.Quantity__c = diCancelMap.get(bli.Deployment_Instance__c).Number_of_Users_Reduced__c != null ? bli.Quantity__c - diCancelMap.get(bli.Deployment_Instance__c).Number_of_Users_Reduced__c : bli.Quantity__c;
            bliUpdateList.add(bli);
        }
        
        update aliUpdateList;
        
    }

    // Method to handle a full Cancellation - will prevent the auto renewal of this line in the future
    public static void processCancellation(List<NI_Cancellation__c> cancellationList)
    {
        
        Map<Id, NI_Cancellation__c> diCancelMap = new Map<Id, NI_Cancellation__c>();
        List<Activity_Line_Item__c> aliUpdateList = new List<Activity_Line_Item__c>();
        
        for (NI_Cancellation__c can : cancellationList)
        {
            diCancelMap.put(can.Deployment_Instance__c, can);
        }
        
        for (Activity_Line_Item__c ali : [SELECT Id, Auto_Renewal__c, Deployment_Instance__c, Status__c 
                                         FROM Activity_Line_Item__c 
                                         WHERE Deployment_Instance__c IN : diCancelMap.keyset()])
        {
            ali.Auto_Renewal__c = false;
            ali.Send_Customer_Renewal_Notice__c = false;
            ali.Status__c = 'Cancelled';
            aliUpdateList.add(ali);
        }
        
        update aliUpdateList;
        
    }



    // Method for returning All Payment Applicable Payment Terms from a set of ids	
    public static Map<Id, Payment_Terms__c> queryAllPaymentTerms()
    {
        
        Map<Id, Payment_Terms__c> paymentTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT
            Id,
            Offset_Date__c,
            Activation_Required__c,
            Invoice_Split_Method__c,
            Billed_through_PSA__c,
            Bill_if_Activation_Date_comes_first__c,
            (SELECT
             Id,
             Order__c,
             Offset_Measure__c,
             Offset_Units__c,
             Percent_of_Total__c,
             Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             ORDER BY Order__c)
            FROM Payment_Terms__c]);
        
        return paymentTermsMap;
        
    }


    // Determine whether or not the line item requires activation 
    public static Boolean activationRequiredforBilling(Map<String, Payment_Terms__c> paymentTermsMap, OpportunityLineItem oli)
    {
        Boolean returnValue;
        if (paymentTermsMap.containsKey(oli.Product2.Apttus_Revenue_Category__c))
        {
            returnValue = paymentTermsMap.get(oli.Product2.Apttus_Revenue_Category__c).Activation_Required__c;
        }
        return returnValue;
    }


    // Method for returning the Aptus Agreement 
    public static Apttus__APTS_Agreement__c fetchAgreement(Opportunity opp)
    {	
        Apttus__APTS_Agreement__c aptusAgreement;
        for (Apttus__APTS_Agreement__c agreement : opp.Apttus__R00N50000001Xl0FEAS__r)
        {		
            aptusAgreement = agreement; 	// we only expect 1 agreement in this list
        }
        system.debug(' *** billingContractHandler - fetchAgreement - aptusAgreement = ' + aptusAgreement);
        return aptusAgreement;
    }

    
    // Method for Creating Billing Contract Header and Parent Objects 
    public static Billing_Contract__c returnBillingContractHeader(Opportunity opp) 
    {
        
        Billing_Contract__c billContract = new Billing_Contract__c();
        Id contractGroupAccountID;
        String contractGroupAccountName;
        Parent_Contract_Group__c parentContractGroup;
        Map<String, c2g__codaCompany__c> ffaCompanymap = new Map<String, c2g__codaCompany__c>();
        Map<String, Id> ffaCurrencymap = new Map<String, Id>();
        Set<Id> accountIdSet = new Set<Id>();
        accountIdSet.add(opp.AccountId);
        Map<Id, Id> accountCollectorMap = getAccountTeam(accountIdSet);
        Apttus__APTS_Agreement__c aptusAgreement = fetchAgreement(opp);
        
        if (opp.account.parentid != null)
        {
            contractGroupAccountID = opp.account.parentid;
            contractGroupAccountName = opp.account.parent.Name;
        }
        else 
        {
            if (opp.accountid != null)
            {
                contractGroupAccountID = opp.accountid;
                contractGroupAccountName = opp.account.Name;
            }
        }
        
        // FILL ffaCompanymap MAP 
        for (c2g__codaCompany__c company : [SELECT id, Legal_Entity_Name__c, Remittance_Info__c, Physical_Countries__c FROM c2g__codaCompany__c])
        {
            ffaCompanymap.put(company.Legal_Entity_Name__c, company);
        }
        
        // FILL ffaCurrencymap MAP 
        for (c2g__codaAccountingCurrency__c acctCurr : [SELECT Id, Name, c2g__ownerCompany__c FROM c2g__codaAccountingCurrency__c])
        {
            ffaCurrencymap.put(acctCurr.c2g__ownerCompany__c + '|' + acctCurr.Name, acctCurr.id);
        }
        
        // query the existing parent contract group record:
        for (Parent_Contract_Group__c pcg : [SELECT Id FROM Parent_Contract_Group__c WHERE Account__c =: contractGroupAccountID])
        {
            parentContractGroup = pcg;
        }
        
        if (parentContractGroup == null)
        {
            Parent_Contract_Group__c pcg = new Parent_Contract_Group__c();
            pcg.Name = contractGroupAccountName;
            pcg.Account__c = contractGroupAccountID;
            insert pcg;
            parentContractGroup = pcg;
        }
        
        // query the existing billing contract:
        if (opp.Billing_Contract__c != null)
        {
            billContract = [SELECT Id, Effective_Date__c FROM Billing_Contract__c WHERE Id = : opp.Billing_Contract__c];
        }
        
        // get the contact roles from the opp:
        getContactRoles(opp.Id);
        
        // STEP 2: Create the Billing Contract if need be
        if (opp.Billing_Contract__c == null)
        {
            
            billContract.Opportunity__c = opp.Id;
            billContract.Account__c = opp.AccountId;
            billContract.CurrencyIsoCode = opp.CurrencyIsoCode;
            billContract.Pricebook__c = opp.Pricebook2Id;
            billContract.Effective_Date__c = opp.Effective_Date__c != null ? opp.Effective_Date__c : opp.CloseDate;
            billContract.Name = 'BC - ' + opp.Opportunity_Number__c;
            billContract.Parent_Contract_Group__c = parentContractGroup.id;
            // Shashikant Nikam (NICC-033453)
            //billContract.Company__c = aptusAgreement != null && ffaCompanymap.containsKey(aptusAgreement.APTS_Legal_Entity__c) ? ffaCompanymap.get(aptusAgreement.APTS_Legal_Entity__c).id : null;
            billContract.Company__c = opp.Company__c;		// Shashikant Nikam (NICC-033453)
            
            billContract.Collector__c = accountCollectorMap.containsKey(opp.AccountId) ? accountCollectorMap.get(opp.AccountId) : null;
            //billContract.Remittance_Info__c = aptusAgreement != null && ffaCompanymap.containsKey(aptusAgreement.APTS_Legal_Entity__c) ? ffaCompanymap.get(aptusAgreement.APTS_Legal_Entity__c).Remittance_Info__c : null;
            //billContract.Remittance_Info__c = opp.account.Remittance_Info__c != null ? opp.account.Remittance_Info__c : billContract.Remittance_Info__c;
            billContract.Accounting_Currency__c = ffaCurrencymap.containsKey(billContract.Company__c + '|' + billContract.CurrencyIsoCode) ? ffaCurrencymap.get(billContract.Company__c + '|' + billContract.CurrencyIsoCode) : null;
            billContract.Agreement__c = aptusAgreement != null ? aptusAgreement.id : null;
            billContract.Bill_to_Contact__c = contactRoleMap.containsKey('Bill To') ? contactRoleMap.get('Bill To') : null;
            billContract.Ship_to_Contact__c = contactRoleMap.containsKey('Ship To') ? contactRoleMap.get('Ship To') : null;
            billContract.Attn_to_Contact__c = contactRoleMap.containsKey('Customer Project Contact') ? contactRoleMap.get('Customer Project Contact') : null;
            //if(aptusAgreement != null){
            //	if((aptusAgreement.APTS_Customer_Account_Billing_Country__c == 'AU' || aptusAgreement.APTS_Customer_Account_Billing_Country__c == 'NZ') && aptusAgreement.APTS_Legal_Entity__c == 'Amadeus Hospitality Asia Pacific Pte. Ltd.'){
            //		billContract.Company__c = ffaCompanymap.containsKey('Amadeus Hospitality Asia Pacific Pte. Ltd. AUS') ? ffaCompanymap.get('Amadeus Hospitality Asia Pacific Pte. Ltd. AUS').id : null;
            //	}else if(aptusAgreement.APTS_Legal_Entity__c == 'Amadeus Hospitality Asia Pacific Pte. Ltd.'){
            //		billContract.Company__c = ffaCompanymap.containsKey('Amadeus Hospitality Asia Pacific Pte. Ltd. AP') ? ffaCompanymap.get('Amadeus Hospitality Asia Pacific Pte. Ltd. AP').id : null;
            //	}
            //}
            
            // NEW CODE TO POPULATE THE COMPANY AND REMITTANCE FIELDS PER NICC-024530 
            // IF AGREEMENT RECORD EXISTS 
            if (aptusAgreement != null) 
            {                 
                // LOOP THOUGH ALL COMPANIES WHERE Physical_Countries__c IS FILLED IN 
                for (c2g__codaCompany__c company : [SELECT Id, Legal_Entity_Name__c, Remittance_Info__c,Physical_Countries__c FROM c2g__codaCompany__c]) 
                { 
                    // IF AGREEMENT LEGAL NAME MATCHES LEGAL NAME ON COMPANY 
                    if (company.Legal_Entity_Name__c == aptusAgreement.APTS_Legal_Entity__c && company.Physical_Countries__c == null) 
                    { 
                        // billContract.Company__c = company.Id; 		// Shashikant Nikam (NICC-033453)
                        billContract.Remittance_Info__c = company.Remittance_Info__c; 
                    }                     
                    // IF COUNTRY ON AGREEMENT IS CONTAINED IN Billing_Countries__c ON COMPANY 
                    if (company.Legal_Entity_Name__c == aptusAgreement.APTS_Legal_Entity__c && 
                        company.Physical_Countries__c != null && 
                        company.Physical_Countries__c.contains(aptusAgreement.Customer_Account_Physical_Country__c)) 
                    { 
                        // billContract.Company__c = company.Id; 		// Shashikant Nikam (NICC-033453)
                        billContract.Remittance_Info__c = company.Remittance_Info__c; 
                        break; 
                    } 
                }                 
            } 
        }        
        
        // STEP 3: Insert the Billing Contract Header if need be
        if (billContract.Id == null)
        {
            insert billContract;
        }
        
        opp.Billing_Contract__c = billContract.Id;
        opp.Order_Status__c = 'Integrated';
        update opp;

        return billContract;
        
    }


    // Calculate the Delivery Offset of each Opportunity Line Item  
    public static Map<Id,Integer> calculateDeliveryOffset(Id oppId)
    {
        Map<Id,Integer> deliveryOffsetMap = new Map<Id,Integer>();
        system.debug(' *** ENTERING NI_OpportunityProduct_TriggerHandler.calculateDeliveryOffset()'); 
        Set<String> productProcessedSet = new Set<String>();
        List<OpportunityLineItem> oppLinestoUpdate = [SELECT Id, OpportunityId, Product2.Duration_Months__c, Product2id, Order_of_Delivery__c, Delivery_Offset_Months__c 
                                                      FROM OpportunityLineItem
                                                      WHERE OpportunityId =: oppId
                                                      AND Product2.Duration_Months__c != null
                                                      AND Order_of_Delivery__c != null
                                                      ORDER BY Product2id, Order_of_Delivery__c];
        Integer deliveryOffset;
        for (OpportunityLineItem oli : oppLinestoUpdate)
        {
            if (!productProcessedSet.contains(oli.Product2id))
            {
                deliveryOffset = 0;
                productProcessedSet.add(oli.Product2id);
                deliveryOffsetMap.put(oli.id, deliveryOffset);
            }
            else
            {
                deliveryOffset = deliveryOffset + oli.Product2.Duration_Months__c.intValue();
                deliveryOffsetMap.put(oli.id, deliveryOffset);
            }
        }
        return deliveryOffsetMap;
    }


    // Queries the Account Team to retrieve the NI Collector
    public static Map<Id, Id> getAccountTeam(Set<Id> acctIds)
    {
        Map<Id, Id> returnMap = new Map<Id, Id>();
        for (AccountTeamMember atm : [SELECT AccountId, UserId, TeamMemberRole FROM AccountTeamMember WHERE accountid IN : acctIds AND TeamMemberRole = 'NI Collector'])
        {
            returnMap.put(atm.AccountId, atm.UserId);
        }
        return returnMap;
    }
    

    // Queries the Contact Roles 
    public static void getContactRoles(Id oppId)
    {
        contactRoleMap = new Map<String,Id>();
        for (OpportunityContactRole oc : [SELECT Id, OpportunityId, ContactId, Role FROM OpportunityContactRole WHERE OpportunityId =: oppId])
        {
            contactRoleMap.put(oc.Role, oc.ContactId);
        }
    }
    

    // Method for returning the Payment Applicable Payment Terms from a set of ids
    public static Map<Id, Payment_Terms__c> queryPaymentTerms(List<Billing_Contract_Line_Item__c> bliList)
    {
        
        Set<Id> termsIds = new Set<Id>();
        for (Billing_Contract_Line_Item__c bli : bliList)
        {
            termsIds.add(bli.Payment_Terms__c);
        }
        
        Map<Id, Payment_Terms__c> paymentTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT
            Id,
            Offset_Date__c,
            Activation_Required__c,
            Invoice_Split_Method__c,
            Billed_through_PSA__c,
            Bill_if_Activation_Date_comes_first__c,
            (SELECT
             Id,
             Order__c,
             Offset_Measure__c,
             Offset_Units__c,
             Percent_of_Total__c,
             Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             Order BY Order__c)
            FROM
            Payment_Terms__c
            WHERE id in :termsIds
        ]);
        
        return paymentTermsMap;
        
    }

    // Method to populate the Billing Contract Line Item's - Line Description
    public static List<Billing_Contract_Line_Item__c> populateBillingLineDescription(List<Billing_Contract_Line_Item__c> lines)
    {
        
        Set<Id> aliIds = new Set<Id>();
        Set<String> revenueCategoriesToApply = new Set<String>{'Support','Hosting and Support','Subscription'};
        String strbillingPeriodStart;
        String strbillingPeriodEnd;
        
        for (Billing_Contract_Line_Item__c bli : lines)
        {
            aliIds.add(bli.Activity_Line_Item__c);
        }
        
        Map<Id, Activity_Line_Item__c> aliMap = new Map<Id, Activity_Line_Item__c>([SELECT Id,
                                                                                    Contract_Start_Date__c,
                                                                                    Contract_End_Date__c,
                                                                                    Revenue_Category__c
                                                                                    FROM Activity_Line_Item__c
                                                                                    WHERE id in:aliIds
                                                                                    AND Contract_Start_Date__c != null
                                                                                    AND Contract_End_Date__c != null]);
        
        system.debug(' *** billingContractHandler - populateBillingLineDescription - aliMap = '+ aliMap);
        
        for (Billing_Contract_Line_Item__c bli : lines)
        {
            if (bli.Pro_Rated__c == false && (bli.Line_Item_Description__c == '' || bli.Line_Item_Description__c == null))
            {
                if (aliMap.containsKey(bli.Activity_Line_Item__c))
                {
                    Activity_Line_Item__c ali = aliMap.get(bli.Activity_Line_Item__c);					
                    if (revenueCategoriesToApply.contains(bli.Revenue_Category__c))
                    {
                        //10/17/2016: ADDED BY STUART EMERY PER SALESFORCE CHANGE REQUEST NICC-019640
                        //CHANGE START AND END DATE FORMATS TO DAY MONTH ABREVIATION AND YEAR.  EX: '7 Oct 2016' 
                        strbillingPeriodEnd = DateTime.NewInstance(ali.Contract_End_Date__c.year(),ali.Contract_End_Date__c.month(),ali.Contract_End_Date__c.day()).format('d MMM yyyy');
                        strbillingPeriodStart = DateTime.NewInstance(ali.Contract_Start_Date__c.year(),ali.Contract_Start_Date__c.month(),ali.Contract_Start_Date__c.day()).format('d MMM yyyy');
                        
                        system.debug('strbillingPeriodStart: ' + strbillingPeriodStart);
                        system.debug('strbillingPeriodEnd: ' + strbillingPeriodEnd);
                        bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: '+ strbillingPeriodStart + ' End: '+ strbillingPeriodEnd;
                        //bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: '+ali.Contract_Start_Date__c.format() + ' End: '+ali.Contract_End_Date__c.format();
                    }
                }
            }
        }
        return lines;
    }


    // Method for returning the Applicable Payment Terms from the Opportunity
    public static Map<String, List<PSA_Product_Package_Milestone__c>> fetchProductPackage (List<OpportunityLineItem> oliList)
    {
        
        Map<String, List<PSA_Product_Package_Milestone__c>> package_Map = new Map<String, List<PSA_Product_Package_Milestone__c>>();
        Set<Id> packageId_Set = new Set<Id>();
        
        //loop through the opp line items and collect the ids from any product package objects
        for (OpportunityLineItem oli : oliList)
        {
            if (oli.Product2.Product_Package__c != null)
            {
                packageId_Set.add(oli.Product2.Product_Package__c);
            }
        }
        
        //grab necessary distribution data
        for (PSA_Product_Package_Milestone__c packageLine : [SELECT Id,
                                                             Product__c,
                                                             Percent__c,
                                                             Milestone_Name_Prefix__c,
                                                             Product_Package__c,
                                                             Milestone_Type__c
                                                             FROM PSA_Product_Package_Milestone__c
                                                             WHERE Product_Package__c in :packageId_Set])
        {
            if (package_Map.containsKey(packageLine.Product_Package__c))
            {
                List<PSA_Product_Package_Milestone__c> tmpList = package_Map.get(packageLine.Product_Package__c);
                tmpList.add(packageLine);
                package_Map.put(packageLine.Product_Package__c,tmpList);
            }
            else
            {
                List<PSA_Product_Package_Milestone__c> tmpList = new List<PSA_Product_Package_Milestone__c>();
                tmpList.add(packageLine);
                package_Map.put(packageLine.Product_Package__c, tmpList);
            }
        }
        
        return package_Map;
        
    }








    // Root Method for Processing Line Items	
    public static void linkDeploymentInstance(List<Activity_Line_Item__c> aliList, List<Billing_Contract_Line_Item__c> bcliList, Map <String, Asset> di_map, Opportunity opp)
    {
        
        for (Activity_Line_Item__c ali : aliList)
        {
            ali.Deployment_Instance__c = di_map.containsKey(opp.AccountId + '|' + ali.Product__c) ? di_map.get(opp.AccountId + '|' + ali.Product__c).id : null;
        }
        
        update aliList;
        
        for (Billing_Contract_Line_Item__c bcli : bcliList)
        {
            bcli.Deployment_Instance__c = di_map.containsKey(opp.AccountId + '|' + bcli.Product__c) ? di_map.get(opp.AccountId + '|' + bcli.Product__c).id : null;
        }
        
        update bcliList;
        
    }


    // Method for initializing the Billing Line
    public static List<Billing_Contract_Line_Item__c> initBillingLine(List<OpportunityLineItem> oliList, Opportunity opp, Apttus__APTS_Agreement__c agreement, Billing_Contract__c bc, Map<Id, Payment_Terms__c> paymentTermsMap, Map<String, Asset> di_map, Map<Id, Integer> deliveryOffsetMap, Map<Id, Activity_Line_Item__c> oliALIMap)
    {
        
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        
        Payment_Terms__c pmtTerms;
        Payment_Term_Line_Item__c pmtLine;
        
        system.debug(' *** billingContractHandler - initBillingLine - di_map = ' + di_map);
        system.debug(' *** billingContractHandler - initBillingLine - paymentTermsMap = ' + paymentTermsMap);
        
        for (OpportunityLineItem oli : oliList)
        {

            pmtTerms = paymentTermsMap.containsKey(oli.Invoice_Terms__c) ? paymentTermsMap.get(oli.Invoice_Terms__c) : null;
            
            Date invoiceDate = deliveryOffsetMap.containsKey(oli.id) ? bc.Effective_Date__c.addMonths(deliveryOffsetMap.get(oli.id)) : bc.Effective_Date__c;
            if (oliALIMap.containsKey(oli.id) && oliALIMap.get(oli.id).Contract_Start_Date__c != null)
            {
                invoiceDate = oliALIMap.get(oli.id).Contract_Start_Date__c;
            }
            
            if (pmtTerms.Billed_through_PSA__c == true)
            {
                continue; //do not create a billing contract line item since it will be invoiced out of psa.
            }
            if (pmtTerms.Payment_Term_Line_Items__r.size() > 0)
            {
                pmtLine = pmtTerms.Payment_Term_Line_Items__r[0];	
            }
            else
            {
                continue;
            }
            
            system.debug(' *** billingContractHandler - initBillingLine - pmtTerms = ' + pmtTerms);
            //system.assert(pmtTerms != null && pmtLine != null, 'ERROR: No applicable payment terms were found or the payment terms are setup incorrectly, please check the Agreement record related to this Opportunity');
            
            String lineDescription = pmtLine.Invoice_Line_Description__c != null ? pmtLine.Invoice_Line_Description__c : '';
            
            //just create a single line item based on the opp
            Decimal unitPrice = oli.UnitPrice;
            system.debug(' *** billingContractHandler - initBillingLine - numberofInstances not Greater than 1');
            Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
            bcli.Invoice_Date__c = invoiceDate;
            bcli.Product__c = oli.Product2id;
            bcli.CurrencyIsoCode = bc.CurrencyIsoCode;
            bcli.Opp_Line_Item_ID__c = oli.id;
            bcli.Product_Package__c = oli.Product2.Product_Package__c;
            bcli.Line_Item_Description__c = lineDescription;
            bcli.Billing_Contract__c = bc.id;
            bcli.Revenue_Category__c = oli.Product2.Apttus_Revenue_Category__c;
            bcli.Quantity__c = oli.Quantity;
            bcli.Unit_Price__c = unitPrice.setScale(2);
            bcli.Split_Order__c = 1;			
            bcli.Opportunity__c = oli.OpportunityId;
            bcli.Total_Amount__c = (unitPrice * oli.Quantity).setScale(2);
            bcli.Payment_Terms__c = pmtTerms.id;
            bcli.Payment_Term_Line_Item__c = pmtLine != null ? pmtline.id : null;
            bcli.Activation_Required__c = oli.Product2.Product_Group__r.Name == 'Cendyn' ? true : pmtTerms.Activation_Required__c;
            bcli.Status__c = bcli.Activation_Required__c == true ? 'Pending' : 'Active';
            bcli.Deployment_Instance__c = di_map.containsKey(opp.AccountId + '|' + oli.Product2Id) ? di_map.get(opp.AccountId + '|' + oli.Product2Id).id : null;
            
            //set the invoice date based on the units offset from the pmt line:
            if (pmtLine.Offset_Measure__c =='Days' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
            {
                bcli.Invoice_Date__c = invoiceDate.addDays(pmtLine.Offset_Units__c.intValue());
            }
            if (pmtLine.Offset_Measure__c =='Months' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
            {
                bcli.Invoice_Date__c = invoiceDate.addMonths(pmtLine.Offset_Units__c.intValue());
            }
            if (pmtLine.Offset_Measure__c =='Years' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
            {
                bcli.Invoice_Date__c = invoiceDate.addYears(pmtLine.Offset_Units__c.intValue());
            }
            
            //calculate any pro-rated prices:
            Date proRataDate;
            
            if (oli.Pro_Rated_Date__c != null)
            {
                proRataDate = oli.Pro_Rated_Date__c;
            }
            
            system.debug(' *** billingContractHandler - initBillingLine - proRataDate = ' + proRataDate);
            
            if (proRataDate != null && 
                (oli.Order_of_Delivery__c <= 1 || oli.Order_of_Delivery__c == null) &&
                oli.Pro_Rata_Billing__c == true &&
                oli.Product2.Duration_Months__c != null
               )
            {
                bcli = proRateInvoiceAmount_Billing(bcli, bc.Effective_Date__c, bc.Effective_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue()), proRataDate, oli.UnitPrice, oliALIMap.get(oli.id));
                system.debug(' *** billingContractHandler - initBillingLine - ENTER PRO RATA CALC');
                system.debug(' *** billingContractHandler - initBillingLine - PRO RATA - unitPrice = '+ unitPrice);
            }
            
            returnList.add(bcli);
            
            system.debug(' *** billingContractHandler - initBillingLine - bcli = '+ bcli);
            
            oli.BC_Line_Created__c = true;
            oli.Auto_Renew__c = oli.Product2.Auto_Renew__c;
            
        }
        
        try 
        {
            update oliList;
        }
        catch (Exception e) {}
        
        return returnList;
        
    }

    // Method for initializing the Activity Line	
    public static List<Activity_Line_Item__c> initActivityLine(List<OpportunityLineItem> oliList, Opportunity opp, Apttus__APTS_Agreement__c agreement, Billing_Contract__c bc, Map<Id, Payment_Terms__c> invoiceTermsMap, Map <String, Asset> di_map, Map<Id,Integer> deliveryOffsetMap)
    {
        
        Payment_Terms__c pmtTerms;
        
        system.debug(' *** billingContractHandler - initActivityLine - *** START ***');
        Set<Id> packageId_Set = new Set<Id>();
        Map<String,VSOE_Pricing_Item__c> vsoePricingMap = new Map<String,VSOE_Pricing_Item__c>();
        List<Activity_Line_Item__c> returnList = new List<Activity_Line_Item__c>();
        
        for (VSOE_Pricing_Item__c vsoe : [
            SELECT
            id,
            Software_Discount__c,
            Service_Discount__c,
            Customer_Account__c,
            Product__c
            FROM VSOE_Pricing_Item__c
            WHERE Customer_Account__c = : opp.AccountId])
        {
            if (vsoe.Product__c != null)
            {
                vsoePricingMap.put(vsoe.Customer_Account__c + '|' + vsoe.Product__c, vsoe);	
            }
            else
            {
                vsoePricingMap.put(vsoe.Customer_Account__c + '|', vsoe);	
            }	
        }
        
        Date aliStartDate;
        Map<String, Date> proRataStartDateMap = new Map<String, Date>(); //used to track the appropriate activity line start date in the case of multi-year lines
        
        //loop through and create the activity line items
        for (OpportunityLineItem oli : oliList)
        {

            pmtTerms = invoiceTermsMap.containsKey(oli.Invoice_Terms__c) ? invoiceTermsMap.get(oli.Invoice_Terms__c) : null;
            
            system.debug(' *** billingContractHandler - initBillingLine - pmtTerms = ' + pmtTerms);
            system.assert(pmtTerms != null, 'ERROR: No applicable payment terms were found, please check the Agreement record related to this Opportunity');
            
            if (oli.Activity_Line_Created__c == false)
            {
                Asset diObject = di_map.containsKey(opp.AccountId + '|' + oli.Product2Id) ? di_map.get(opp.AccountId + '|' + oli.Product2Id) : null;
                Decimal unitPrice = oli.UnitPrice;
                
                system.debug(' *** billingContractHandler - initActivityLine - INSTANCES = 1 *****');
                
                Activity_Line_Item__c activityLine = new Activity_Line_Item__c(
                    Billing_Contract__c = bc.id,
                    Attn_to_Contact__c = bc.Attn_to_Contact__c,
                    CurrencyIsoCode = bc.CurrencyIsoCode,
                    Contract_Amount__c = unitPrice,
                    Renewal_Base_Price__c = unitPrice,
                    List_Price__c = oli.ListPrice,
                    Product_Package__c = oli.Product2.Product_Package__c,
                    Origin__c = 'New Order',
                    Opportunity__c = oli.OpportunityId,
                    Renewal_Pricebook__c = oli.Renewal_Pricebook__c,
                    Auto_Renewal__c = unitPrice > 0  && oli.Quantity > 0 ? oli.Product2.Auto_Renew__c : false,
                    Send_Customer_Renewal_Notice__c = oli.Product2.Auto_Renew__c,
                    Payment_Terms__c = pmtTerms.id,
                    Order_of_Delivery__c = oli.Order_of_Delivery__c,
                    Opp_Product_ID__c = oli.id,                
                    //CLD Update - set Derliver Offset to zero
                    //Delivery_Offset_Months__c = deliveryOffsetMap.containsKey(oli.id) ? deliveryOffsetMap.get(oli.id) : 0,
                    Delivery_Offset_Months__c = 0,                
                    Product__c = oli.Product2id,
                    Activation_Required__c = oli.Product2.Product_Group__r.Name == 'Cendyn' ? true : pmtTerms.Activation_Required__c,
                    Revenue_Category__c = oli.Product2.Apttus_Revenue_Category__c,
                    Units__c = oli.Quantity,
                    Deployment_Instance__c = di_map.containsKey(opp.AccountId + '|' + oli.Product2Id) ? di_map.get(opp.AccountId + '|' + oli.Product2Id).id : null);
                
                //calculate any pro-rated prices
                Date proRataDate;
                Date proRataEndDate;
                
                if (oli.Pro_Rata_Billing__c == true)
                {
                    if (oli.Pro_Rated_Date__c != null)
                    {
                        proRataDate = oli.Pro_Rated_Date__c;
                    }
                    
                    //if(oli.Product2.Product_Group__r.Name == 'Salesforce' && opp.Annual_Salesforce_Renewal_Date__c != null){
                    //proRataDate = opp.Annual_Salesforce_Renewal_Date__c;
                    //if(proRataDate < opp.CloseDate){
                    //while(proRataDate < opp.CloseDate){
                    //proRataDate = proRataDate.addYears(1);
                    //}
                    //}
                    //}
                    //else if(opp.Billing_Cycle_Date_Pro_Rata__c != null){
                    //proRataDate = opp.Billing_Cycle_Date_Pro_Rata__c;
                    //}
                    
                    if (proRataDate != null)
                    {
                        proRataStartDateMap.put(oli.Product2.ProductCode, proRataDate);
                    }
                    
                    if (proRataDate != null && 
                        (oli.Order_of_Delivery__c <= 1 || oli.Order_of_Delivery__c == null) &&
                        oli.Pro_Rata_Billing__c == true &&
                        oli.Product2.Duration_Months__c != null
                       )
                    {
                        activityLine = proRateInvoiceAmount_Activity(activityLine, bc.Effective_Date__c, bc.Effective_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue()), proRataDate, oli.UnitPrice);
                        proRataEndDate = proRataDate;
                    }
                }
                
                //vsoe pricing considerations
                if (vsoePricingMap.containsKey(oli.Opportunity.AccountId + '|' + oli.Product2id))
                {
                    activityLine.VSOE_Pricing_Item__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|' + oli.Product2id).id;
                    if (activityLine.Revenue_Category__c == 'Services')
                    {
                        activityLine.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|' + oli.Product2id).Service_Discount__c;
                    }
                    if (activityLine.Revenue_Category__c == 'Software')
                    {
                        activityLine.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|' + oli.Product2id).Software_Discount__c;
                    }
                }
                else if(vsoePricingMap.containsKey(oli.Opportunity.AccountId + '|'))
                {
                    activityLine.VSOE_Pricing_Item__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|').id;
                    if (activityLine.Revenue_Category__c == 'Services')
                    {
                        activityLine.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|').Service_Discount__c;
                    }
                    if (activityLine.Revenue_Category__c == 'Software')
                    {
                        activityLine.VSOE_Discount__c = vsoePricingMap.get(oli.Opportunity.AccountId + '|').Software_Discount__c;
                    }
                }
                else
                {
                    activityLine.VSOE_Discount__c = 0;
                }
                
                //vsoe element type:
                if (activityLine.Revenue_Category__c == 'Support' || activityLine.Revenue_Category__c == 'Software'|| activityLine.Revenue_Category__c == 'Hosting and Support')
                {
                    activityLine.VSOE_Element_Type__c = 'Software';
                }
                if (activityLine.Revenue_Category__c == 'Subscription' || activityLine.Revenue_Category__c == 'Services')
                {
                    activityLine.VSOE_Element_Type__c = 'Non-Software';
                }
                
                //contract start and end dates:
                if (oli.Product2.Duration_Months__c != null)
                {
                    aliStartDate = proRataStartDateMap.containsKey(oli.Product2.ProductCode) && proRataEndDate == null ? proRataStartDateMap.get(oli.Product2.ProductCode) : opp.CloseDate.addMonths(activityLine.Delivery_Offset_Months__c.intValue());
                    if (activityLine.Activation_Required__c == false && activityLine.Revenue_Category__c != 'Subscription' && activityLine.Revenue_Category__c != 'Hosting and Support')
                    {
                        activityLine.Contract_Start_Date__c = aliStartDate != null ? aliStartDate : opp.CloseDate.addMonths(activityLine.Delivery_Offset_Months__c.intValue());
                        activityLine.Contract_End_Date__c = proRataEndDate != null ? proRataEndDate : activityLine.Contract_Start_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue());
                        activityLine.Activation_Date__c = diObject != null && diObject.InstallDate != null ? diObject.InstallDate : null;
                    }
                    if (activityLine.Revenue_Category__c == 'Support')
                    {
                        activityLine.Activation_Date__c = opp.CloseDate.addDays(60);
                        activityLine.Contract_Start_Date__c = opp.CloseDate.addDays(60);
                        activityLine.Contract_End_Date__c = proRataEndDate != null ? proRataEndDate : activityLine.Contract_Start_Date__c.addMonths(oli.Product2.Duration_Months__c.intValue());
                    }
                }
                returnList.add(activityLine);
            }
            oli.Activity_Line_Created__c = true;
        }
        
        try 
        {
            update oliList;
        }
        catch (Exception e) {}
        
        return returnList;
        
    }
    

    
    // Root Method for Processing Line Items	
    public static billingContractLineWrapper createLineItems(List<OpportunityLineItem> oliList, Opportunity opp, Apttus__APTS_Agreement__c agreement, Billing_Contract__c bc)
    {
        
        billingContractLineWrapper returnWrapper = new billingContractLineWrapper();
        Map<Id, Integer> deliveryOffsetMap = calculateDeliveryOffset(opp.id);
        Map<String, Asset> di_map = new Map<String, Asset>();
        Map<Id, Activity_Line_Item__c> oliALIMap = new Map<Id, Activity_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> tmpBillingList = new List<Billing_Contract_Line_Item__c>();
        List<Activity_Line_Item__c> tmpActivityList = new List<Activity_Line_Item__c>();		
        Map<Id, Payment_Terms__c> invoiceTermsMap = queryAllPaymentTerms();
        
        //FETCH THE DEPLOYMENT INSTANCES:
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> productIdSet = new Set<Id>();
        accountIdSet.add(opp.AccountId);
        for (OpportunityLineItem oli : oliList)
        {
            productIdSet.add(oli.Product2Id);
        }
        
        //UPDATE ON 7/11/16 - SINCE THE DI FUNCTIONALITY IS NOT IN PLACE, WE'LL COMMENT THIS LINE OUT, UNCOMMENT WHEN READY
        //di_map = fetchDeploymentInstance(accountIdSet, productIdSet);
        
        // INIT THE BILLING AND ACTIVITY LINES
        tmpActivityList = initActivityLine(oliList, opp, agreement, bc, invoiceTermsMap, di_map, deliveryOffsetMap);
        returnWrapper.activityLineList = packageSplit_Activity(tmpActivityList, oliList);
        
        for (Activity_Line_Item__c ali : returnWrapper.activityLineList)
        {
            oliALIMap.put(ali.Opp_Product_ID__c, ali);
        }
        
        tmpBillingList = initBillingLine(oliList, opp, agreement, bc, invoiceTermsMap, di_map, deliveryOffsetMap, oliALIMap);
        
        // PRODUCT PACKAGE BURST OUT:
        returnWrapper.billingLineList = packageSplit_Billing(tmpBillingList, oliList);
        
        // SPLIT BILLING LINES BY PAYMENT TERMS:
        returnWrapper.billingLineList = paymentSplit_Billing(returnWrapper.billingLineList, bc, opp);
        
        // INSERT THE ACTIVITY LINE ITEMS:
        insert returnWrapper.activityLineList;

        // Populate the opp Product ALI map
        oppProductActivityLineMap = new Map<String, Id>();
        
        for (Activity_Line_Item__c ali : returnWrapper.activityLineList)
        {
            oppProductActivityLineMap.put(ali.Opp_Product_Id__c + '|' + ali.Product_Package_Item__c, ali.id);
        }
        
        // Loop through the Billing Lines and populated the ALI lookup
        for (Billing_Contract_Line_Item__c bli : returnWrapper.billingLineList)
        {
            if (oppProductActivityLineMap.containsKey(bli.Opp_Line_Item_ID__c + '|' + bli.Product_Package_Item__c))
            {
                bli.Activity_Line_Item__c = oppProductActivityLineMap.get(bli.Opp_Line_Item_ID__c + '|' + bli.Product_Package_Item__c);
            }
        }
        
        // Populate the line descriptions where applicable:
        returnWrapper.billingLineList = populateBillingLineDescription(returnWrapper.billingLineList);
        
        // INSERT THE BILLING LINE ITEMS:
        insert returnWrapper.billingLineList;
        
        // LINK DEPLOYMENT INSTANCES TO BILLING AND ACTIVITY LINES:
        linkDeploymentInstance(returnWrapper.activityLineList, returnWrapper.billingLineList, di_map, opp);
        
        return returnWrapper;
        
    }

    // Method for Splitting Billing Lines by Package Components
    public static List<Billing_Contract_Line_Item__c> packageSplit_Billing(List<Billing_Contract_Line_Item__c> oldBillinglist, List<OpportunityLineItem> oliList)
    {
        
        system.debug(' *** billingContractHandler - packageSplit_Billing - ENTER PACKAGE SPLIT *****');
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        Map<String, List<PSA_Product_Package_Milestone__c>> packageMap = fetchProductPackage(oliList);
        
        for (Billing_Contract_Line_Item__c old_bcli : oldBillinglist)
        {
            if (packageMap.containsKey(old_bcli.Product_Package__c))//split out the items by package
            {
                
                Integer numberOfLinesToCreate = packageMap.get(old_bcli.Product_Package__c).size();
                Integer linesCreated = 0;
                Decimal billingLinesTotal = 0; //this will store the summed amount, we may need to adjust this for rounding
                Decimal roundingAdjustment = 0;
                
                for (PSA_Product_Package_Milestone__c pkg : packageMap.get(old_bcli.Product_Package__c))
                {
                    Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
                    bcli.Unit_Price__c = (old_bcli.Unit_Price__c * (pkg.Percent__c / 100)).setScale(2);
                    bcli.Total_Amount__c = (old_bcli.Total_Amount__c * (pkg.Percent__c / 100)).setScale(2);                    
                    bcli.Invoice_Date__c = old_bcli.Invoice_Date__c;
                    bcli.Product__c = pkg.Product__c != null ? pkg.Product__c : null;
                    bcli.Opp_Line_Item_ID__c = old_bcli.Opp_Line_Item_ID__c;
                    bcli.Product_Package__c = pkg.Product_Package__c;
                    bcli.Product_Package_Item__c = pkg.id;
                    bcli.Billing_Contract__c = old_bcli.Billing_Contract__c;
                    bcli.Revenue_Category__c = old_bcli.Revenue_Category__c;
                    bcli.Pro_Rated__c = old_bcli.Pro_Rated__c;
                    bcli.Line_Item_Description__c = old_bcli.Line_Item_Description__c;
                    bcli.Quantity__c = old_bcli.Quantity__c;
                    bcli.Payment_Term_Line_Item__c = old_bcli.Payment_Term_Line_Item__c;
                    bcli.Payment_Terms__c = old_bcli.Payment_Terms__c;
                    bcli.Activation_Required__c = old_bcli.Activation_Required__c;
                    bcli.Status__c = old_bcli.Status__c;
                    bcli.Deployment_Instance__c = old_bcli.Deployment_Instance__c;
                    bcli.CurrencyIsoCode = old_bcli.CurrencyIsoCode;
                    
                    billingLinesTotal += bcli.Total_Amount__c; //keep track of the total amount being applied to the lines
                    
                    linesCreated ++;
                    if (linesCreated == numberOfLinesToCreate) //this is the last item to create so account for any rounding.
                    {
                        roundingAdjustment = (old_bcli.Total_Amount__c - billingLinesTotal).setScale(2);
                        bcli.Unit_Price__c += roundingAdjustment;
                        bcli.Total_Amount__c += roundingAdjustment;
                    }
                    returnList.add(bcli);
                }
            }
            else
            {
                returnList.add(old_bcli);//add the items to the new list.
            }
        }
        
        return returnList;
        
    }

    // Method for Splitting Activity Lines by Package Components	
    public static List<Activity_Line_Item__c> packageSplit_Activity(List<Activity_Line_Item__c> oldActivityList, List<OpportunityLineItem> oliList)
    {
        
        List<Activity_Line_Item__c> returnList = new List<Activity_Line_Item__c>();
        Map<String, List<PSA_Product_Package_Milestone__c>> packageMap = fetchProductPackage(oliList);

        for (Activity_Line_Item__c old_ali : oldActivityList)
        {
            // split out the items by package
            if (packageMap.containsKey(old_ali.Product_Package__c)) 
            {

                Integer numberOfLinesToCreate = packageMap.get(old_ali.Product_Package__c).size();
                Integer linesCreated = 0;
                Decimal activityLinesTotal = 0; //this will store the summed amount, we may need to adjust this for rounding
                Decimal roundingAdjustment = 0;
                
                for (PSA_Product_Package_Milestone__c pkg : packageMap.get(old_ali.Product_Package__c))
                {

                    Activity_Line_Item__c ali = new Activity_Line_Item__c();
                    ali.Billing_Contract__c = old_ali.Billing_Contract__c; 
                    ali.List_Price__c = (old_ali.List_Price__c * (pkg.Percent__c / 100)).setScale(2); 
                    ali.Renewal_Base_Price__c = (old_ali.Contract_Amount__c * (pkg.Percent__c / 100)).setScale(2); 
                    ali.Contract_Amount__c = (old_ali.Contract_Amount__c * (pkg.Percent__c / 100)).setScale(2); 
                    ali.Attn_to_Contact__c = old_ali.Attn_to_Contact__c; 
                    ali.Product_Package__c = pkg.Product_Package__c; 
                    ali.Product_Package_Item__c = pkg.Id; 
                    ali.Product__c = pkg.Product__c != null ? pkg.Product__c : null; 
                    ali.Opp_Product_ID__c = old_ali.Opp_Product_ID__c; 
                    ali.Pro_Rated__c = old_ali.Pro_Rated__c; 
                    ali.Opportunity__c = old_ali.Opportunity__c; 
                    ali.Revenue_Category__c = old_ali.Revenue_Category__c; 
                    ali.Order_of_Delivery__c = old_ali.Order_of_Delivery__c; 
                    ali.Origin__c = old_ali.Origin__c; 
                    ali.Auto_Renewal__c = old_ali.Auto_Renewal__c; 
                    ali.Send_Customer_Renewal_Notice__c = old_ali.Send_Customer_Renewal_Notice__c; 
                    ali.Units__c = old_ali.Units__c; 
                    ali.VSOE_Element_Type__c = old_ali.VSOE_Element_Type__c; 
                    ali.Renewal_Pricebook__c = old_ali.Renewal_Pricebook__c; 
                    ali.Payment_Terms__c = old_ali.Payment_Terms__c; 
                    ali.Delivery_Offset_Months__c = old_ali.Delivery_Offset_Months__c; 
                    ali.VSOE_Pricing_Item__c = old_ali.VSOE_Pricing_Item__c; 
                    ali.Activation_Required__c = old_ali.Activation_Required__c; 
                    ali.VSOE_Discount__c = old_ali.VSOE_Discount__c; 
                    ali.Deployment_Instance__c = old_ali.Deployment_Instance__c; 
                    ali.CurrencyIsoCode = old_ali.CurrencyIsoCode; 
                    ali.Milestone_Name_Prefix__c = pkg.Milestone_Name_Prefix__c; 
                    
                    // keep track of the total amount being applied to the lines
                    activityLinesTotal += ali.Contract_Amount__c; 
                    
                    linesCreated ++;
                    
                    // this is the last item to create so account for any rounding.                    
                    if (linesCreated == numberOfLinesToCreate) 
                    {
                        roundingAdjustment = (old_ali.Contract_Amount__c - activityLinesTotal).setScale(2);
                        ali.Contract_Amount__c += roundingAdjustment;
                        ali.List_Price__c += roundingAdjustment;
                    }
                    
                    returnList.add(ali);
                    
                }
            }
            else
            {
                returnList.add(old_ali);//add the items to the new list.
            }
        }
        
        return returnList;
        
    }

    // Method for Splitting Billing Lines by Payment Terms	
    public static List<Billing_Contract_Line_Item__c> paymentSplit_Billing(List<Billing_Contract_Line_Item__c> oldBillinglist, Billing_Contract__c bc, Opportunity opp)
    {
        
        system.debug(' *** billingContractHandler - paymentSplit_Billing - ENTERING *****');
        List<Billing_Contract_Line_Item__c> returnList = new List<Billing_Contract_Line_Item__c>();
        
        Map<Id, Payment_Terms__c> paymentTermsMap = queryPaymentTerms(oldBillinglist);
        
        for (Billing_Contract_Line_Item__c old_bcli : oldBillinglist)
        {
            
            Payment_Terms__c pmtTerms;
            pmtTerms = paymentTermsMap.containsKey(old_bcli.Payment_Terms__c) ? paymentTermsMap.get(old_bcli.Payment_Terms__c) : null;
            system.assert(pmtTerms != null, 'No applicable payment terms found!');
            Integer numberOfInvoicesToCreate = pmtTerms.Payment_Term_Line_Items__r.size();
            Date invoiceDate = old_bcli.Invoice_Date__c;
            
            //SKIP SPLITTING BECAUSE THERE IS ONLY 1 INVOICE IN THE PAYMENT TERMS
            if (numberOfInvoicesToCreate == 1)
            {
                returnList.add(old_bcli);
                continue;
            }
            
            //PRO RATA THE INVOICE BASED ON THE PRO-RATA DATE, DISREGARD THE OTHER PAYMENT TERMS
            if (old_bcli.Pro_Rated__c == true)
            {
                returnList.add(old_bcli);
                continue;
            }
            
            // if number of invoices is > 1, split out the single Opp line into multiple billing line items.
            if (numberOfInvoicesToCreate > 1)
            {
                
                system.debug(' *** billingContractHandler - paymentSplit_Billing - ENTER > 1 *****');
                Integer invoicesCreated = 0;
                Map<Decimal, Decimal> invoiceAmountMap = new Map<Decimal, Decimal>();
                Map<Decimal, Decimal> invoiceUnitPriceMap = new Map<Decimal, Decimal>();
                
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r) // populate the invoice amount map based on the order
                {
                    Decimal invoiceAmount;
                    Decimal unitPrice;
                    if (pmtTerms.Invoice_Split_Method__c == 'Equal')
                    {
                        invoiceAmount = (old_bcli.Total_Amount__c / numberOfInvoicesToCreate).setscale(2);
                        unitPrice = (old_bcli.Unit_Price__c / numberOfInvoicesToCreate).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        invoiceUnitPriceMap.put(pmtLine.Order__c, unitPrice);
                    }
                    if (pmtTerms.Invoice_Split_Method__c == 'Percent Breakdown')
                    {
                        invoiceAmount = (old_bcli.Total_Amount__c * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        unitPrice = (old_bcli.Unit_Price__c * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        invoiceUnitPriceMap.put(pmtLine.Order__c, unitPrice);
                    }
                }
                
                Decimal billingLinesTotal = 0; //this will store the summed amount, we may need to adjust this for rounding
                Decimal roundingAdjustment = 0;
                
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r)
                {
                    if (invoicesCreated != 0) //if this is not the first item in the list, then add months / days / years.
                    {
                        if (pmtLine.Offset_Measure__c == 'Days' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = bc.Effective_Date__c.addDays(pmtLine.Offset_Units__c.intValue());
                        }
                        if (pmtLine.Offset_Measure__c == 'Months' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = bc.Effective_Date__c.addMonths(pmtLine.Offset_Units__c.intValue());
                        }
                        if (pmtLine.Offset_Measure__c == 'Years' && pmtLine.Offset_Units__c != 0 && pmtLine.Offset_Units__c != null)
                        {
                            invoiceDate = bc.Effective_Date__c.addYears(pmtLine.Offset_Units__c.intValue());
                        }
                    }
                    
                    String lineDescription = pmtLine.Invoice_Line_Description__c != null ? pmtLine.Invoice_Line_Description__c : old_bcli.Line_Item_Description__c;
                    
                    Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
                    bcli.Invoice_Date__c = invoiceDate;
                    bcli.Product__c = old_bcli.Product__c;
                    bcli.Opp_Line_Item_ID__c = old_bcli.Opp_Line_Item_ID__c;
                    bcli.Payment_Term_Line_Item__c = pmtLine.id;
                    bcli.Billing_Contract__c = old_bcli.Billing_Contract__c;
                    bcli.Product_Package__c = old_bcli.Product_Package__c;
                    bcli.Pro_Rated__c = old_bcli.Pro_Rated__c;
                    bcli.Product_Package_Item__c = old_bcli.Product_Package_Item__c;
                    bcli.Revenue_Category__c = old_bcli.Revenue_Category__c;
                    bcli.Line_Item_Description__c = lineDescription;
                    bcli.Opportunity__c = old_bcli.Opportunity__c;
                    bcli.Split_Order__c = invoicesCreated + 1;
                    bcli.Quantity__c = old_bcli.Quantity__c;
                    bcli.Unit_Price__c = invoiceUnitPriceMap.get(pmtLine.Order__c).setScale(2);
                    bcli.Total_Amount__c = invoiceAmountMap.get(pmtLine.Order__c).setScale(2);
                    bcli.Payment_Terms__c = old_bcli.Payment_Terms__c;
                    bcli.Activation_Required__c = old_bcli.Activation_Required__c;
                    bcli.Status__c = old_bcli.Status__c;
                    bcli.Deployment_Instance__c = old_bcli.Deployment_Instance__c;
                    bcli.CurrencyIsoCode = old_bcli.CurrencyIsoCode;
                    
                    billingLinesTotal += bcli.Total_Amount__c; //keep track of the total amount being applied to the lines
                    
                    invoicesCreated ++;
                    if(invoicesCreated == numberOfInvoicesToCreate) //this is the last item to create so account for any rounding.
                    {
                        roundingAdjustment = old_bcli.Total_Amount__c - billingLinesTotal;
                        system.debug(' *** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - ROUNDING ADJUSTMENT *****');
                        bcli.Unit_Price__c += roundingAdjustment.setScale(2);
                        bcli.Total_Amount__c += roundingAdjustment.setScale(2);
                        system.debug('***** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - billingLinesTotal = '+ billingLinesTotal);
                        system.debug('***** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - old_bcli.Total_Amount__c = '+ old_bcli.Total_Amount__c);
                        system.debug('***** billingContractHandler - packageSplit_Billing - ENTER PAYMENT SPLIT - ROUNDING ADJUSTMENT = '+ roundingAdjustment);
                        
                    }
                    returnList.add(bcli);
                    system.debug(' *** billingContractHandler - paymentSplit_Billing - invoicesCreated =' + invoicesCreated);
                }
                continue;
            }
        }
        
        return returnList;
        
    }

    // Method for returning the necessary Opp Data  
    public static Opportunity queryOpportunity(Id opportunityID) 
    {
        
        system.debug(' *** billingContractHandler - queryOpportunity - START');
        //step 1: Query the Opp and Related data
        Opportunity opp = [
            SELECT
            Id,
            accountid,
            account.Name,
            account.Remittance_Info__c,
            currencyIsoCode,
            account.parentid,
            Annual_Salesforce_Renewal_Date__c,
            account.parent.Name,
            Pricebook2Id,
            Company__c,			// Shashikant Nikam (NICC-033453)
            StageName,
            License_Program_Payment_Terms__c,
            Support_Payment_Terms__c,
            Order_Status__c,
            Services_Payment_Terms__c,
            Subscription_Payment_Terms__c,
            Hosting_and_Support_Payment_Terms__c,
            Opportunity_Number__c,
            HRM_Subscription_Invoice_Terms__c,
            HRM_Service_Invoice_Terms__c,
            Billing_Cycle_Date_Pro_Rata__c,
            CloseDate,
            Effective_Date__c,
            Billing_Contract__c,
            (SELECT 
             id, 
             Product2id,
             Product2.Apttus_Revenue_Category__c,
             Product2.Override_Invoice_Terms__c,
             Product2.Duration_Months__c,
             Product2.Product_Group__r.Name,
             Product2.Product_Line__c,
             Product2.Product_Group__c,
             Order_of_Delivery__c,
             Delivery_Offset_Months__c,
             Quantity,
             Renewal_Pricebook__c,
             OpportunityId,
             Name,
             Pro_Rata_Billing__c,
             Product2.Product_Package__c,
             Product2.ProductCode,
             Product2.Auto_Renew__c,
             Product2.Name,
             Description,
             Opportunity.CloseDate,
             Opportunity.AccountId,
             BC_Line_Created__c,
             Activity_Line_Created__c,
             Number_of_Instances__c,
             UnitPrice,
             ListPrice,
             TotalPrice,
             Auto_Renew__c,
             Pro_Rated_Date__c,
             Invoice_Terms__c
             FROM OpportunityLineItems
             ORDER BY Product2.Apttus_Revenue_Category__c, ProductCode),
            (SELECT
             id,
             CreatedDate,
             License_Program_Payment_Terms__c,
             Hosting_and_Support_Payment_Terms__c,
             Support_Payment_Terms__c,
             APTS_Legal_Entity__c,
             Services_Payment_Terms__c,
             Subscription_Payment_Terms__c,
             APTS_Customer_Account_Billing_Country__c,
             Customer_Account_Physical_Country__c 		// ADDED PER NICC-024530
             FROM Apttus__R00N50000001Xl0FEAS__r
             ORDER BY CreatedDate desc Limit 1)
            FROM
            Opportunity
            WHERE
            id = :opportunityID];
        
        system.debug(' *** billingContractHandler - queryOpportunity - opp = ' + opp);
        return opp;
        
    }

	// Method for returning the Payment Applicable Payment Terms from the Opportunity
    public static Map<String, Payment_Terms__c> queryOppPaymentTerms(Opportunity opp)
    {
        
        Set<Id> paymentTermsIds = new Set<Id>();
        paymentTermsIds.add(opp.License_Program_Payment_Terms__c);
        paymentTermsIds.add(opp.Hosting_and_Support_Payment_Terms__c);
        paymentTermsIds.add(opp.Support_Payment_Terms__c);
        paymentTermsIds.add(opp.Services_Payment_Terms__c);
        paymentTermsIds.add(opp.Subscription_Payment_Terms__c);
        paymentTermsIds.add(opp.HRM_Subscription_Invoice_Terms__c);
        paymentTermsIds.add(opp.HRM_Service_Invoice_Terms__c);
        
        Map<String, Payment_Terms__c> paymentTermsMapreturn = new Map<String, Payment_Terms__c>(); // the key for this map is the Apttus revenue category of the product.
        Map<String, Payment_Terms__c> paymentTermsMap = new Map<String, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c,
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r 
             ORDER BY Order__c)
            FROM Payment_Terms__c
            WHERE Id IN : paymentTermsIds]);
        
system.debug(' *^* paymentTermsMap.size() = ' + paymentTermsMap.size());         
        
        Map<String, Payment_Terms__c> fullpaymentTermsMap = new Map<String, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c,
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             ORDER BY Order__c)
            FROM Payment_Terms__c]);
        
system.debug(' *^* fullpaymentTermsMap.size() = ' + fullpaymentTermsMap.size());   
        
        //transform this map into one based on aptus revenue category:
        if (paymentTermsMap.containsKey(opp.Services_Payment_Terms__c))
        {
            paymentTermsMapreturn.put('Services', paymentTermsMap.get(opp.Services_Payment_Terms__c));
        }
        if (paymentTermsMap.containsKey(opp.License_Program_Payment_Terms__c))
        {
            paymentTermsMapreturn.put('Software', paymentTermsMap.get(opp.License_Program_Payment_Terms__c));
        }
        if (paymentTermsMap.containsKey(opp.Subscription_Payment_Terms__c))
        {
            paymentTermsMapreturn.put('Subscription', paymentTermsMap.get(opp.Subscription_Payment_Terms__c));
        }
        if (paymentTermsMap.containsKey(opp.Support_Payment_Terms__c))
        {
            paymentTermsMapreturn.put('Support', paymentTermsMap.get(opp.Support_Payment_Terms__c));
        }
        if (paymentTermsMap.containsKey(opp.Hosting_and_Support_Payment_Terms__c))
        {
            paymentTermsMapreturn.put('Hosting and Support', paymentTermsMap.get(opp.Hosting_and_Support_Payment_Terms__c));
        }
        if (paymentTermsMap.containsKey(opp.HRM_Subscription_Invoice_Terms__c))
        {
            paymentTermsMapreturn.put('HRM Subscription', paymentTermsMap.get(opp.HRM_Subscription_Invoice_Terms__c));
        }
        if (paymentTermsMap.containsKey(opp.HRM_Service_Invoice_Terms__c))
        {
            paymentTermsMapreturn.put('HRM Services', paymentTermsMap.get(opp.HRM_Service_Invoice_Terms__c));
        }
        
        //overload the map with the payment term ids as keys (this will be useful for overriding at the product level):
        paymentTermsMapreturn.putAll(fullpaymentTermsMap);
        
        return paymentTermsMapreturn;
        
    }
 

    // MOVED TO AH_Billing_Contract_TriggerHandler
    // Method to sync up fields from the Billing Contract to the Activity Line Items
    public static void syncFieldsfromBillingContract(Map<Id,Billing_Contract__c> bcMap)
    {
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
    }


// Method to lock the Billing Contract
global static String lockBillingContract(Id billingContractId)
{
    String message = '';
    List<Billing_Contract__c> bc = [SELECT Id FROM Billing_Contract__c WHERE Id = :billingContractId];
    Approval.LockResult[] lrList = Approval.lock(bc, false);
    
    for(Approval.LockResult lr : lrList) {
    if (lr.isSuccess()) {
    // Operation was successful, so get the ID of the record that was processed
    message = 'Billing Contract has been locked';
    }
    else {
    // Operation failed, so get all errors                
    for(Database.Error err : lr.getErrors()) {
    system.debug('The following error has occurred.');                    
    system.debug(err.getStatusCode() + ': ' + err.getMessage());
    system.debug('Account fields that affected this error: ' + err.getFields());
    message += err.getMessage();
    }
    }
    }
    return message;
}
*/    
    
/*
// webservice method to lock the Billing Contract
Webservice static string lockBillingContractWS(Id bcId)
{
	string message = '';
	message = billingContractHandler.lockBillingContract(bcId);
	return message;
}
*/

/*
// Method for returning the Payment Applicable Payment Terms
public static Map<String, Payment_Terms__c> queryPaymentTerms(Apttus__APTS_Agreement__c agreement)
{
    Set<Id> paymentTermsIds = new Set<Id>();
    paymentTermsIds.add(agreement.License_Program_Payment_Terms__c);
    paymentTermsIds.add(agreement.Hosting_and_Support_Payment_Terms__c);
    paymentTermsIds.add(agreement.Support_Payment_Terms__c);
    paymentTermsIds.add(agreement.Services_Payment_Terms__c);
    paymentTermsIds.add(agreement.Subscription_Payment_Terms__c);
    
    Map<String, Payment_Terms__c> paymentTermsMapreturn = new Map<String, Payment_Terms__c>(); // the key for this map is the aptus revenue category of the product.
    Map<Id, Payment_Terms__c> paymentTermsMap = new Map<Id, Payment_Terms__c>([
    SELECT
    Id,
    Offset_Date__c,
    Days_Offset__c,
    Number_of_Scheduled_Invoices__c,
    Months_between_Invoices__c,
    Activation_Required__c,
    Invoice_Split_Method__c,
    Billed_through_PSA__c
    FROM
    Payment_Terms__c
    WHERE id in :paymentTermsIds
    ]);
    
    //transform this map into one based on aptus revenue category:
    if(paymentTermsMap.containsKey(agreement.Services_Payment_Terms__c))
    {
    paymentTermsMapreturn.put('Services', paymentTermsMap.get(agreement.Services_Payment_Terms__c));
    }
    if(paymentTermsMap.containsKey(agreement.License_Program_Payment_Terms__c))
    {
    paymentTermsMapreturn.put('Software', paymentTermsMap.get(agreement.License_Program_Payment_Terms__c));
    }
    if(paymentTermsMap.containsKey(agreement.Subscription_Payment_Terms__c))
    {
    paymentTermsMapreturn.put('Subscription', paymentTermsMap.get(agreement.Subscription_Payment_Terms__c));
    }
    if(paymentTermsMap.containsKey(agreement.Support_Payment_Terms__c))
    {
    paymentTermsMapreturn.put('Support', paymentTermsMap.get(agreement.Support_Payment_Terms__c));
    }
    if(paymentTermsMap.containsKey(agreement.Hosting_and_Support_Payment_Terms__c))
    {
    paymentTermsMapreturn.put('Hosting and Support', paymentTermsMap.get(agreement.Hosting_and_Support_Payment_Terms__c));
    }
    
    system.debug(' *** billingContractHandler - queryPaymentTerms - paymentTermsMap = ' + paymentTermsMap);
    system.debug(' *** billingContractHandler - queryPaymentTerms - paymentTermsMapreturn = ' + paymentTermsMapreturn);
    return paymentTermsMapreturn;
}


//Root Method for Processing Line Items
    public static void createSoftTraxAssets(List<Activity_Line_Item__c> aliList)
    {
        // SOFTRAX ASSET REMOVAL:	Map<Id, Softrax_Asset__c> sftxInsertMap = new Map<Id, Softrax_Asset__c>();
        List<Activity_Line_Item__c> newAliList = returnActivityLineList(aliList);
        for(Activity_Line_Item__c ali : newAliList)
        {
            if(ali.Revenue_Category__c == 'Subscription' || ali.Revenue_Category__c == 'Support' || ali.Revenue_Category__c == 'Hosting and Support')
            {
                SOFTRAX ASSET REMOVAL: Softrax_Asset__c newAsset = new Softrax_Asset__c(
                    Account__c = ali.Billing_Contract__r.Account__c,
                    Description__c = ali.Product__r.Name,
                    Name = ali.Product__r.ProductCode,
                    Start_Date__c = ali.Contract_Start_Date__c,
                    End_Date__c = ali.Contract_End_Date__c,
                    Product2Id__c = ali.Product__c,
                    Quantity__c = ali.Units__c,
                    Fee__c = ali.Contract_Amount__c,
                    Total__c = ali.Contract_Total_Amount__c,
                    Units__c = ali.Units__c,
                    Activity_Line_Item__c = ali.id,
                    NumberOfUsers__c = ali.Units__c);
                sftxInsertMap.put(ali.id, newAsset);
            }
        }
        // SOFTRAX ASSET REMOVAL:	insert sftxInsertMap.values();
        
        for (Activity_Line_Item__c ali : newAliList)
        {
            // SOFTRAX ASSET REMOVAL:	ali.Softrax_Asset__c = sftxInsertMap.containsKey(ali.id) && sftxInsertMap.get(ali.id).id != null ? sftxInsertMap.get(ali.id).id : ali.Softrax_Asset__c;
        }
        update newAliList;
        
    }   


*/    

}