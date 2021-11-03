/************************************************************************************************
Name            : billingContractRenewalHandler Class
Author          : Sean Harris
Created Date    : 04/04/2016
Last Mod Date   : 08/31/2018 
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Contains various methods for interacting with Billing Contracts
                : Updated 08/31/2018 per NICC-029803
                :
*************************************************************************************************/
public class billingContractRenewalHandler 
{

	// =========================================================================================
	//  Method to Process Renewals for Activity Lines
	// =========================================================================================
	public static void processBCRenewals(List<manageBillingContractRenewalController.aliWrapper> wrapperList)
	{
        
        List<Activity_Line_Item__c> aliInsertList = new List<Activity_Line_Item__c>();
        List<Activity_Line_Item__c> aliUpdateList = new List<Activity_Line_Item__c>();
        List<Billing_Contract_Line_Item__c> bliInsertList = new List<Billing_Contract_Line_Item__c>();
        Set<String> revenueCategoriesToApply = new Set<String>{'Support', 'Hosting and Support', 'Subscription'};
        
        Map<Id, Payment_Terms__c> pmtTermsMap = new Map<Id, Payment_Terms__c>([
            SELECT Id, Offset_Date__c, Activation_Required__c, Invoice_Split_Method__c, Billed_through_PSA__c, Bill_if_Activation_Date_comes_first__c,
            (SELECT Id, Order__c, Offset_Measure__c, Offset_Units__c, Percent_of_Total__c, Invoice_Line_Description__c
             FROM Payment_Term_Line_Items__r
             ORDER BY Order__c)
            FROM Payment_Terms__c]);

		// STEP 1: CREATE THE NEW ACTIVITY LINE ITEM BASED ON THE ONES IN THE WRAPPER
		for (manageBillingContractRenewalController.aliWrapper wrapper : wrapperList)
		{
			Activity_Line_Item__c newAli = wrapper.ali_object.clone(false, true, false, false);
			newAli.Contract_Start_Date__c = wrapper.ali_object.Contract_End_Date__c.addDays(1);
			newAli.Contract_End_Date__c = newAli.Contract_Start_Date__c.addMonths(wrapper.ali_object.Product__r.Duration_Months__c.intValue()).addDays(-1);
			newAli.Contract_Amount__c = wrapper.renewalAmount;
			newAli.Revenue_Recognized_to_Date__c = 0;
			newAli.Renewal_Base_Price__c = wrapper.renewalAmount;
			newAli.Renewal_Date__c = newAli.Contract_End_Date__c.addDays((wrapper.ali_object.Billing_Renewal_Lead_Time_Days__c * -1).intvalue());
			newAli.Units__c = wrapper.dummy_ali_object.Units__c;
			newAli.Origin__c = 'Renewal';
			newAli.Previous_ALI__c = wrapper.ali_object.id;
			newAli.Renewal_Increase_Amount__c = (wrapper.renewalAmount * wrapper.dummy_ali_object.Units__c) - wrapper.ali_object.Contract_Total_Amount__c;
			newAli.Origin__c = 'Renewal';
			newAli.Payment_Terms__c = wrapper.dummy_ali_object.Payment_Terms__c;
			newAli.Delivery_Offset_Months__c = null;
			newAli.Billing_Contract__c = wrapper.dummy_ali_object.Billing_Contract__c;
            newAli.Billing_Renewal_Lead_Time_Days__c = wrapper.ali_object.Billing_Renewal_Lead_Time_Days__c;
            newAli.Pro_Rated__c = false;
			newAli.Revenue_Category__c = wrapper.ali_object.Revenue_Category__c;
			aliInsertList.add(newAli);
			aliUpdateList.add(wrapper.ali_object);
		}
        
		insert aliInsertList;

		// STEP 2: CREATE THE NECESSARY BILLING LINES.
		for (Activity_Line_Item__c ali : aliInsertList)
        {
            
			Payment_Terms__c pmtTerms = pmtTermsMap.containsKey(ali.Payment_Terms__c) ? pmtTermsMap.get(ali.Payment_Terms__c) : null;

			Integer numberOfInvoicesToCreate = pmtTerms.Payment_Term_Line_Items__r.size();
			
			//Date invoiceDate = ali.Contract_Start_Date__c;
			//Date invoiceStartDate = ali.Contract_Start_Date__c;
            
            Date Contract_Start_Date = ali.Contract_Start_Date__c;
            Integer lead_Time = Integer.valueOf(ali.Billing_Renewal_Lead_Time_Days__c);
			Date invoiceDate = Contract_Start_Date.addDays(-lead_Time); 
            Date invoiceStartDate = invoiceDate;
            
			if (pmtTerms.Billed_through_PSA__c == true)
			{
				continue;	// do not create a billing contract line item since it will be invoiced out of psa
			}

			if (numberOfInvoicesToCreate == 1)
            {
				Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
				bcli.Invoice_Date__c = invoiceDate;
				bcli.Product__c = ali.Product__c;
				bcli.Billing_Contract__c = ali.Billing_Contract__c;
				bcli.Revenue_Category__c = ali.Revenue_Category__c;
				bcli.Opportunity__c = ali.Opportunity__c;
				bcli.Quantity__c = ali.Units__c;
				bcli.Unit_Price__c = ali.Contract_Amount__c;
				bcli.Total_Amount__c = ali.Contract_Amount__c * ali.Units__c;
				bcli.Payment_Terms__c = ali.Payment_Terms__c;
				bcli.Activation_Required__c = ali.Activation_Required__c;
				bcli.Deployment_Instance__c = ali.Deployment_Instance__c;
				bcli.Activity_Line_Item__c = ali.id;
                
				if (revenueCategoriesToApply.contains(bcli.Revenue_Category__c) && ali.Contract_Start_Date__c != null && ali.Contract_End_Date__c != null)
                {
					bcli.Line_Item_Description__c = bcli.Revenue_Category__c + ' - Start: ' + ali.Contract_Start_Date__c.format() + ' End: ' + ali.Contract_End_Date__c.format();
				}
                
				bliInsertList.add(bcli);
			}

			// NOTE PRO-RATA CALCULATIONS DO NOT APPLY FOR RENEWALS
			
			if (numberOfInvoicesToCreate > 1)
			{
                
				system.debug(' *** billingContractRenewalHandler - processBCRenewals - ENTER > 1 ***');
				Integer invoicesCreated = 0;

/*              
NICC-029803 (START)
                Map<Decimal, Decimal> invoiceAmountMap = new Map<Decimal, Decimal>();
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r) // populate the invoice amount map based on the order
                {
                    Decimal invoiceAmount;
                    if (pmtTerms.Invoice_Split_Method__c == 'Equal')
                    {
                        invoiceAmount = (((ali.Contract_Amount__c * ali.Units__c) / numberOfInvoicesToCreate)).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                    }
                    if (pmtTerms.Invoice_Split_Method__c == 'Percent Breakdown')
                    {
                        invoiceAmount = ((ali.Contract_Amount__c * ali.Units__c) * (pmtLine.Percent_of_Total__c/100)).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                    }
                }
NICC-029803 (END)
*/

                // NICC-029803 (START)
                Map<Decimal, Decimal> invoiceAmountMap = new Map<Decimal, Decimal>();
                Map<Decimal, Decimal> invoiceUnitPriceMap = new Map<Decimal, Decimal>();
                for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r) // populate the invoice amount map based on the order
                {
                    Decimal invoiceAmount;
                    Decimal unitPrice;
                    if (pmtTerms.Invoice_Split_Method__c == 'Equal')
                    {
                        invoiceAmount = (((ali.Contract_Amount__c * ali.Units__c) / numberOfInvoicesToCreate)).setscale(2);
                        unitPrice = (ali.Contract_Amount__c / numberOfInvoicesToCreate).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        invoiceUnitPriceMap.put(pmtLine.Order__c, unitPrice);
                    }
                    if (pmtTerms.Invoice_Split_Method__c == 'Percent Breakdown')
                    {
                        invoiceAmount = ((ali.Contract_Amount__c * ali.Units__c) * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        unitPrice = (ali.Contract_Amount__c * (pmtLine.Percent_of_Total__c / 100)).setscale(2);
                        invoiceAmountMap.put(pmtLine.Order__c, invoiceAmount);
                        invoiceUnitPriceMap.put(pmtLine.Order__c, unitPrice);
                    }
                }
                // NICC-029803 (END)

				Decimal billingLinesTotal = 0; // this will store the summed amount, we may need to adjust this for rounding
				Decimal roundingAdjustment = 0;
			
				for (Payment_Term_Line_Item__c pmtLine : pmtTerms.Payment_Term_Line_Items__r)
				{
					if (invoicesCreated != 0) // if this is not the first item in the list, then add months / days / years
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
                    
					String lineDescription = pmtLine.Invoice_Line_Description__c != null ? pmtLine.Invoice_Line_Description__c : null;

					Billing_Contract_Line_Item__c bcli = new Billing_Contract_Line_Item__c();
					bcli.Invoice_Date__c = invoiceDate;
					bcli.Product__c = ali.Product__c;
					bcli.Billing_Contract__c = ali.Billing_Contract__c;
					bcli.Revenue_Category__c = ali.Revenue_Category__c;
					bcli.Payment_Term_Line_Item__c = pmtLine.id;
					bcli.Quantity__c = ali.Units__c;
                    // NICC-029803 (START)
                    //bcli.Unit_Price__c = invoiceAmountMap.get(pmtLine.Order__c);
                    //bcli.Total_Amount__c = invoiceAmountMap.get(pmtLine.Order__c);
                    bcli.Unit_Price__c = invoiceUnitPriceMap.get(pmtLine.Order__c).setScale(2);
                    bcli.Total_Amount__c = invoiceAmountMap.get(pmtLine.Order__c).setScale(2);
                    // NICC-029803 (END)
					bcli.Payment_Terms__c = ali.Payment_Terms__c;
					bcli.Activation_Required__c = ali.Activation_Required__c;
					bcli.Deployment_Instance__c = ali.Deployment_Instance__c;
					bcli.Activity_Line_Item__c = ali.id;
					bcli.Line_Item_Description__c = lineDescription;
                    
					if (bcli.Line_Item_Description__c == null || bcli.Line_Item_Description__c == '')
                    {
						if (revenueCategoriesToApply.contains(bcli.Revenue_Category__c) && ali.Contract_Start_Date__c != null && ali.Contract_End_Date__c != null)
                        {
							bcli.Line_Item_Description__c = bcli.Revenue_Category__c + ' - Start: ' + ali.Contract_Start_Date__c.format() + ' End: ' + ali.Contract_End_Date__c.format();
						}
					}

					billingLinesTotal += bcli.Total_Amount__c; 		// keep track of the total amount being applied to the lines

					invoicesCreated ++;
					if (invoicesCreated == numberOfInvoicesToCreate) //	this is the last item to create so account for any rounding.
					{
						roundingAdjustment = ali.Contract_Amount__c * ali.Units__c - billingLinesTotal;
						system.debug(' *** billingContractRenewalHandler - processBCRenewals - ENTER PAYMENT SPLIT - ROUNDING ADJUSTMENT *****');
						bcli.Unit_Price__c += roundingAdjustment;
						bcli.Total_Amount__c += roundingAdjustment;
						system.debug(' *** billingContractRenewalHandler - processBCRenewals - ENTER PAYMENT SPLIT - billingLinesTotal = ' + billingLinesTotal);
						system.debug(' *** billingContractRenewalHandler - processBCRenewals - ENTER PAYMENT SPLIT - ali.Contract_Amount__c * ali.Units__c = ' + ali.Contract_Amount__c * ali.Units__c);
						system.debug(' *** billingContractRenewalHandler - processBCRenewals - ENTER PAYMENT SPLIT - ROUNDING ADJUSTMENT = ' + roundingAdjustment);

					}
					bliInsertList.add(bcli);
					system.debug(' *** billingContractRenewalHandler - processBCRenewals - invoicesCreated = ' + invoicesCreated);
				}
			}
		}
        
		insert bliInsertList;
        
//		activityLineTriggerHandler.updateBillingLineDescriptions(aliInsertList);	// NICC-029729
		AH_ActivityLineItem_Statics.updateBillingLineDescriptions(aliInsertList);	// NICC-029729
        
		// STEP 3: UPDATE ANY ACTIVITY LINES THAT HAVE BEEN RENEWED AND INSERT NEW RECORDS
		for (Activity_Line_Item__c ali : aliUpdateList)
        {
			ali.Renewal_Processed__c = true;
		}
        
		update aliUpdateList;
        
	}
    
}