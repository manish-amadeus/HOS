/************************************************************************************************
Name            : AH_ActivityLineItem_Statics Class
Author          : Sean Harris
Created Date    : 08/13/2018
Last Mod Date   : 08/13/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Written by CLD Partners. Updated to meet AH Standards
                : TEST CLASSES: 
				: AH_ActivityLineItem_TriggerHandler_Test, NI_Cancellation_TriggerHandler_Test
                :
*************************************************************************************************/
public class AH_ActivityLineItem_Statics 
{

    // CALLED FROM AH_ActivityLineItem_TriggerHandler, billingContractRenewalHandler
    public static void updateBillingLineDescriptions(List<Activity_Line_Item__c> newTriggerList)
    {   
        
        system.debug(' *** ENTERING AH_ActivityLineItem_Statics.updateBillingLineDescriptions() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> filterSet = new Set<Id>();
        Set<String> filterRevCatSet = new Set<String>{'Subscription','Support','Hosting and Support'};
        List<Billing_Contract_Line_Item__c> bclUpdateList = new List<Billing_Contract_Line_Item__c>();
        
        for (Activity_Line_Item__c ali : newTriggerList)
        {
            if (filterRevCatSet.contains(ali.Revenue_Category__c) && ali.Pro_Rated__c == false && ali.Contract_Start_Date__c != null)
            {
                filterSet.add(ali.id);
            }
        }
        
        List<Activity_Line_Item__c> aliList = [SELECT Id, Contract_Start_Date__c, Contract_End_Date__c, Pro_Rated__c, 
                                               (SELECT Id, Payment_Terms__r.Invoice_Split_Method__c, Payment_Terms__r.Name, Payment_Terms__r.Offset_Date__c,
                                                Payment_Term_Line_Item__r.Offset_Measure__c, Payment_Term_Line_Item__r.Payment_Terms__r.Count_of_Items__c,
                                                Payment_Term_Line_Item__r.Duration_Units__c, Payment_Term_Line_Item__r.Offset_Units__c, Payment_Term_Line_Item__r.Order__c,
                                                Split_Order__c, Pro_Rated__c, Line_Item_Description__c, Revenue_Category__c, Activity_Line_Item__c, Invoice_Date__c
                                                FROM Billing_Contract_Line_Items__r
                                                ORDER BY Split_Order__c)
                                               FROM Activity_Line_Item__c
                                               WHERE Id IN : filterSet];
system.debug(' *^* aliList = ' + aliList); 
        for (Activity_Line_Item__c ali : aliList)
        {
            system.debug(' **** billing lines = ' + ali.Billing_Contract_Line_Items__r);
            Date billingPeriodStart = ali.Contract_Start_Date__c;
            Date billingPeriodEnd = ali.Contract_End_Date__c;
            for (Billing_Contract_Line_Item__c bli : ali.Billing_Contract_Line_Items__r)
            {
                
                if (bli.Payment_Term_Line_Item__r.Payment_Terms__r.Count_of_Items__c != 1 && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
                {
                    if (bli.Payment_Term_Line_Item__r.Offset_Measure__c == 'Days')
                    {
                        billingPeriodStart = ali.Contract_Start_Date__c.addDays(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
                        billingPeriodEnd = billingPeriodStart.addDays(bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                        system.debug(' **** PAYMENT TERMS DURATION UNITS(DAYS) = ' + bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                        //adjust the end date back one day:
                        billingPeriodEnd = billingPeriodEnd.addDays(-1);
                    }
                    else 
                    {
                        if (bli.Payment_Term_Line_Item__r.Offset_Measure__c == 'Months')
                        {
                            billingPeriodStart = ali.Contract_Start_Date__c.addMonths(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
                            billingPeriodEnd = billingPeriodStart.addMonths(bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                            system.debug(' **** PAYMENT TERMS DURATION UNITS(MONTH) = ' + bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                            //adjust the end date back one day:
                            billingPeriodEnd = billingPeriodEnd.addDays(-1);
                        }
                        else 
                        {
                            if (bli.Payment_Term_Line_Item__r.Offset_Measure__c == 'Years')
                            {
                                billingPeriodStart = ali.Contract_Start_Date__c.addYears(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
                                billingPeriodEnd = billingPeriodStart.addYears(bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                                system.debug(' **** PAYMENT TERMS DURATION UNITS(YEARS) = ' + bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                                //adjust the end date back one day:
                                billingPeriodEnd = billingPeriodEnd.addDays(-1);
                            }
                        }
                    }                    
                }

                //10/07/2016: ADDED BY STUART EMERY PER SALESFORCE CHANGE REQUEST NICC-019640
                //CHANGE START AND END DATE FORMATS TO DAY MONTH ABREVIATION AND YEAR.  EX: '7 Oct 2016' 
                String strbillingPeriodEnd = DateTime.NewInstance(billingPeriodEnd.year(), billingPeriodEnd.month(), billingPeriodEnd.day()).format('d MMM yyyy');
                String strbillingPeriodStart = DateTime.NewInstance(billingPeriodStart.year(), billingPeriodStart.month(), billingPeriodStart.day()).format('d MMM yyyy');
                
                system.debug(' **** strbillingPeriodStart = ' + strbillingPeriodStart);
                system.debug(' **** strbillingPeriodEnd = ' + strbillingPeriodEnd);
                
                //set the Line Description for any Subscriptions or Support:    
                bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: '+ strbillingPeriodStart + ' End: '+ strbillingPeriodEnd;
                system.debug(' **** BILLING LINE ITEM DESCRIPTION = ' + bli.Line_Item_Description__c);
                
                bclUpdateList.add(bli);
                
            }
        }
        
        if (!bclUpdateList.isEmpty())
        {
            update bclUpdateList;
        }
        
        system.debug(' *** EXITING AH_ActivityLineItem_Statics.updateBillingLineDescriptions() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    
/*    
    // CALLED FROM AH_ActivityLineItem_TriggerHandler, billingContractRenewalHandler
    public static void updateBillingLineDescriptions(List<Activity_Line_Item__c> newTriggerList)
    {   
        
        system.debug(' *** ENTERING AH_ActivityLineItem_Statics.updateBillingLineDescriptions() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> filterSet = new Set<Id>();
        Set<String> filterRevCatSet = new Set<String>{'Subscription','Support','Hosting and Support'};
        List<Billing_Contract_Line_Item__c> bclUpdateList = new List<Billing_Contract_Line_Item__c>();
        
        for (Activity_Line_Item__c ali : newTriggerList)
        {
            if (filterRevCatSet.contains(ali.Revenue_Category__c) && ali.Pro_Rated__c == false && ali.Contract_Start_Date__c != null)
            {
                filterSet.add(ali.id);
            }
        }
        
        List<Activity_Line_Item__c> aliList = [
            SELECT Id,
            Contract_Start_Date__c,
            Contract_End_Date__c,
            (SELECT Id,
             Payment_Terms__r.Invoice_Split_Method__c, 
             Payment_Terms__r.Name, 
             Payment_Terms__r.Offset_Date__c,
             Payment_Term_Line_Item__r.Offset_Measure__c,
             Payment_Term_Line_Item__r.Payment_Terms__r.Count_of_Items__c,
             Payment_Term_Line_Item__r.Duration_Units__c,
             Payment_Term_Line_Item__r.Offset_Units__c,
             Payment_Term_Line_Item__r.Order__c,
             Split_Order__c,
             Pro_Rated__c,
             Line_Item_Description__c,
             Revenue_Category__c,
             Activity_Line_Item__c,
             Invoice_Date__c
             FROM Billing_Contract_Line_Items__r
             ORDER BY Split_Order__c)
            FROM Activity_Line_Item__c
            WHERE Id IN : filterSet];
        
        for (Activity_Line_Item__c ali : aliList)
        {
            system.debug(' **** billing lines' + ali.Billing_Contract_Line_Items__r);
            Date billingPeriodStart = ali.Contract_Start_Date__c;
            Date billingPeriodEnd = ali.Contract_End_Date__c;
            for (Billing_Contract_Line_Item__c bli : ali.Billing_Contract_Line_Items__r)
            {
                if (bli.Payment_Term_Line_Item__r.Payment_Terms__r.Count_of_Items__c == 1)
                {
                }
                else if(bli.Payment_Term_Line_Item__r.Offset_Measure__c =='Days' && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
                {
                    billingPeriodStart = ali.Contract_Start_Date__c.addDays(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
                    billingPeriodEnd = billingPeriodStart.addDays(bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                    system.debug(' **** PAYMENT TERMS DURATION UNITS(DAYS) = ' + bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                    //adjust the end date back one day:
                    billingPeriodEnd = billingPeriodEnd.addDays(-1);
                }
                else if (bli.Payment_Term_Line_Item__r.Offset_Measure__c =='Months' && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
                {
                    billingPeriodStart = ali.Contract_Start_Date__c.addMonths(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
                    billingPeriodEnd = billingPeriodStart.addMonths(bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                    system.debug(' **** PAYMENT TERMS DURATION UNITS(MONTH) = ' + bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                    //adjust the end date back one day:
                    billingPeriodEnd = billingPeriodEnd.addDays(-1);
                }
                else if (bli.Payment_Term_Line_Item__r.Offset_Measure__c =='Years' && bli.Payment_Term_Line_Item__r.Offset_Units__c != null)
                {
                    billingPeriodStart = ali.Contract_Start_Date__c.addYears(bli.Payment_Term_Line_Item__r.Offset_Units__c.intValue());
                    billingPeriodEnd = billingPeriodStart.addYears(bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                    system.debug(' **** PAYMENT TERMS DURATION UNITS(YEARS) = ' + bli.Payment_Term_Line_Item__r.Duration_Units__c.intValue());
                    //adjust the end date back one day:
                    billingPeriodEnd = billingPeriodEnd.addDays(-1);
                }
                
                //10/07/2016: ADDED BY STUART EMERY PER SALESFORCE CHANGE REQUEST NICC-019640
                //CHANGE START AND END DATE FORMATS TO DAY MONTH ABREVIATION AND YEAR.  EX: '7 Oct 2016' 
                String strbillingPeriodEnd = DateTime.NewInstance(billingPeriodEnd.year(),billingPeriodEnd.month(),billingPeriodEnd.day()).format('d MMM yyyy');
                String strbillingPeriodStart = DateTime.NewInstance(billingPeriodStart.year(),billingPeriodStart.month(),billingPeriodStart.day()).format('d MMM yyyy');
                
                system.debug(' **** strbillingPeriodStart = ' + strbillingPeriodStart);
                system.debug(' **** strbillingPeriodEnd = ' + strbillingPeriodEnd);
                
                //set the Line Description for any Subscriptions or Support:    
                //bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: '+ billingPeriodStart.format() + ' End: '+ billingPeriodEnd.format();
                bli.Line_Item_Description__c = bli.Revenue_Category__c + ' - Start: '+ strbillingPeriodStart + ' End: '+ strbillingPeriodEnd;
                system.debug(' **** BILLING LINE ITEM DESCRIPTION = ' + bli.Line_Item_Description__c);
                
                bclUpdateList.add(bli);
                
            }
        }
        
        if (!bclUpdateList.isEmpty())
        {
            update bclUpdateList;
        }
        
        system.debug(' *** EXITING AH_ActivityLineItem_Statics.updateBillingLineDescriptions() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
*/   
}