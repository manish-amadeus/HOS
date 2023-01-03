/************************************************************************************************
Name            : AH_BatchManageBillingContractRen Class
Author          : Shashikant Nikam
Created Date    : 09/13/2018
Last Mod Date   : 09/25/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Query Activity Line Item records
				: 
				: 
*************************************************************************************************/
global class AH_BatchManageBillingContractRen implements Database.Batchable<sObject>
{
    
    String filterRevCategory ='';
    String filterProductLine = '';
    String filterCorpProductGroup = '';
    Id filterProduct;
    Id filterAccount;
    List<Id> filterPriceBookList = new List<Id>();
    Set<Id> renewalpricebookIds = new Set<Id>();
    Date filterStart;
    Date filterEnd;
    public AH_Schedule_Renewal__c renewalSettings;
    manageBillingContractRenewalController ctrl = new manageBillingContractRenewalController();
    
    
    global Database.QueryLocator start (Database.BatchableContext bc) 
    {
        
        filterStart = Date.today().addyears(-100);
        filterEnd = Date.today().addDays(-1);		// SMH UPDATED THIS 07/10/2019 (from filterEnd = Date.today())
        
        renewalSettings = AH_Schedule_Renewal__c.getOrgDefaults();
        
        if (renewalSettings == null)
        {
            renewalSettings = new AH_Schedule_Renewal__c();
        }
        
        if (renewalSettings.Revenue_Category__c != null)
        {
            filterRevCategory = renewalSettings.Revenue_Category__c;
        }
        
        if (renewalSettings.Product_SKU__c != null)
        {
            filterProduct = Id.valueOf(renewalSettings.Product_SKU__c);
        }
        
        if (renewalSettings.Corp_Product_Group__c != null)
        {
            filterCorpProductGroup = renewalSettings.Corp_Product_Group__c;
        }
        
        if (renewalSettings.Customer_Account__c != null)
        {
            filterAccount = Id.valueOf(renewalSettings.Customer_Account__c);
        }
        
        if (renewalSettings.Product_Line__c != null)
        {
            filterProductLine = renewalSettings.Product_Line__c;
        }
        
        if (renewalSettings.Excluded_Pricebooks__c != null)
        {
            filterPriceBookList = renewalSettings.Excluded_Pricebooks__c.split(',');
        }
        
        List<c2g__codaCompany__c> currentCompanies = ffaUtilities.gerCurrentCompanies();
        Set<Id> companyIds = new Set<Id>();
        
        for (c2g__codaCompany__c c : currentCompanies)
        {
            companyIds.add(c.id);
        }
        
        String activityLineQuery = 'SELECT Activity_Project_Billing__c,' + 
            'Billing_Contract__c,' + 
            'Billing_Contract__r.Account__c,' + 
            'Billing_Contract__r.Company__c,' + 
            'Billing_Contract__r.Company__r.Name,' + 
            'Billing_Contract__r.Account__r.Name,' + 
            'Billing_Contract__r.Account__r.ParentId,' + 
            'Billing_Contract__r.Use_CPI_for_Renewal_Price_Increase__c,' + 
            'Billing_Contract__r.Renewal_Increase_Cap_Percentage__c,' + 
            'Billing_Contract__r.Name,' + 
            'No_Price_Increase_Through__c,' + 
            'Contract_Amount__c,' + 
            'Contract_Total_Amount__c,' + 
            'Contract_End_Date__c,' + 
            'Contract_Start_Date__c,' + 
            'CreatedById,' + 
            'CreatedDate,' + 
            'CurrencyIsoCode,' + 
            'Fair_Value__c,' + 
            'Id,' + 
            'IsDeleted,' + 
            'LastActivityDate,' + 
            'LastModifiedById,' + 
            'LastModifiedDate,' + 
            'List_Price__c,' + 
            'PSA_Milestone__c,' + 
            'Revenue_Category__c,' + 
            'Billing_Renewal_Lead_Time_Days__c,' + 
            'Include_in_Revenue_Recognition__c,' + 
            'Name,' + 
            'Percent_of_Total__c,' + 
            'Delivery_Offset_Months__c,' + 
            'Opp_Product_Id__c,' + 
            'Product__c,' + 
            'Product__r.Name,' + 
            'Product__r.Duration_Months__c,' + 
            'Payment_Terms__c,' + 
            'Payment_Terms__r.Aptus_Payment_Terms__c, ' + 
            'Payment_Terms__r.Billed_through_PSA__c, ' + 
            'Payment_Terms__r.Invoice_Split_Method__c, ' + 
            'Payment_Terms__r.Name, ' + 
            'Payment_Terms__r.Offset_Date__c,' + 
            'Opportunity__c,' + 
            'Product_Description__c,' + 
            'Activation_Date__c,' + 
            'Fulfillment_Date__c,' +
            'Fulfillment_Complete__c,' +
            'Fulfillment_Notes__c,' +
            'Renewal_Base_Price__c,' +
            'Deployment_Instance__c,' + 
            'Relative_Selling_Price_Allocation__c,' + 
            'Revenue_Recognized_to_Date__c,' + 
            'Service_Discount__c,' + 
            'SKU__c,' + 
            'Auto_Renewal__c,' + 
            'Renewal_Processed__c,' + 
            'Renewal_Date__c,' + 
            'Software_Discount__c,' + 
            'SystemModstamp,' + 
            'Renewal_Comments_Additional__c,' + 
            'Renewal_Comments__c,' + 
            'Units__c,' + 
            'Units_Remaining__c,' +           
            'Renewal_Pricebook__c,' + 
            'VSOE_Pricing_Item__c ' + 
            'FROM Activity_Line_Item__c ' + 
            'WHERE Renewal_Date__c <= :filterEnd ' +
            'AND Renewal_Date__c >= :filterStart ' +
            'AND Renewal_Base_Price__c != null ' +
            'AND Auto_Renewal__c = true ' +
            'AND Status__c != \'Cancelled\' ' +
            'AND Renewal_Processed__c = false ';
        
        if (Test.isRunningTest() == false)
        {
            activityLineQuery += 'AND Billing_Contract__r.Company__c IN : companyIds ';
        }
        
        if (filterRevCategory != null && filterRevCategory != '')
        {
            activityLineQuery += ' AND Revenue_Category__c =: filterRevCategory ';
        }
        
        if (filterProduct != null)
        {
            activityLineQuery += ' AND Product__c =: filterProduct ';
        }
        
        if (filterAccount != null)
        {
            activityLineQuery += ' AND Billing_Contract__r.Account__c =: filterAccount ';
        }
        
        if (filterProductLine != null && filterProductLine != '')
        {
            activityLineQuery += ' AND Product__r.Product_Line__c =: filterProductLine ';
        }
        
        if (filterCorpProductGroup != null && filterCorpProductGroup != '')
        {
            activityLineQuery += ' AND Product__r.Corporate_Product_Group__c =: filterCorpProductGroup ';
            
        }
        if (!filterPriceBookList.isEmpty())
        {
            activityLineQuery += ' AND Renewal_Pricebook__c NOT IN : filterPriceBookList ';
        }
        
        system.debug(' *** AH_BatchManageBillingContractRen - fetchData - activityLineQuery = ' +  activityLineQuery);
        
        return Database.getQueryLocator(activityLineQuery);
        
    }
    
    global void execute (Database.BatchableContext bc, List<Activity_Line_Item__c> aliList)
    {
        
        try
        { 
            
            for (Activity_Line_Item__c actLine : aliList)
            {
                renewalpricebookIds.add(actLine.Renewal_Pricebook__c);
            }        
            
            // LOAD THE MAPS TO BE USED FOR PRICE INCREASES
            Map<String, Renewal_Pricing_Entry__c> renewalPriceMap = new Map<String, Renewal_Pricing_Entry__c>();
            
            List<Renewal_Pricing_Entry__c> rpeList = [
                SELECT Id,
                Start_Date__c,
                End_Date__c,
                Percent_Increase__c,
                Renewal_Pricebook__c
                FROM Renewal_Pricing_Entry__c
                WHERE Renewal_Pricebook__c in :renewalpricebookIds
                AND End_Date__c >= :filterStart AND Start_Date__c <= :filterEnd];
            
            for (Renewal_Pricing_Entry__c rpe : rpeList)
            {
                Date loopDate = rpe.Start_Date__c;
                while (loopDate < rpe.End_Date__c)
                {
                    renewalPriceMap.put(rpe.Renewal_Pricebook__c + '|' + loopDate.format(), rpe);
                    loopDate = loopDate.addDays(1);
                }
                continue;  
            }
            
            system.debug(' *** AH_BatchManageBillingContractRen - renewalPriceMap size = ' + renewalPriceMap.size()); 
            
            List<manageBillingContractRenewalController.aliWrapper> wrapperList = new List<manageBillingContractRenewalController.aliWrapper>();
            
            for (Activity_Line_Item__c actLine : aliList)
            {
                
                manageBillingContractRenewalController.aliWrapper wrapper = new manageBillingContractRenewalController.aliWrapper();
                wrapper.ali_object = actLine;
                wrapper.basePrice = actLine.Renewal_Base_Price__c;
                wrapper.dummy_ali_object.Payment_Terms__c = actLine.Payment_Terms__c;
                wrapper.dummy_ali_object.Units__c = actLine.Units_Remaining__c;
                wrapper.ali_object.Billing_Renewal_Lead_Time_Days__c = actLine.Billing_Renewal_Lead_Time_Days__c;
                wrapper.dummy_ali_object.Billing_Contract__c = actLine.Billing_Contract__c;
                wrapper.check = true;
                
                //============ Calculate the Price increase for Renewal Lines ============//            
                // STEP 1: If a no price increase date is specifically stated in the contract then continue.
                if (actLine.No_Price_Increase_Through__c != null && actLine.Contract_End_Date__c < actLine.No_Price_Increase_Through__c)
                {
                    wrapper.rpe = null;
                    wrapper.renewalPriceMethodology = 'Contract Spec - No Increase';
                }
                else 
                {
                    // STEP 2: If a product specific increase exists, use that.
                    if (renewalPriceMap.containsKey(actLine.Renewal_Pricebook__c + '|' + actLine.Renewal_Date__c.format()))
                    {
                        wrapper.rpe = renewalPriceMap.get(actLine.Renewal_Pricebook__c + '|' + actLine.Renewal_Date__c.format());
                        wrapper.renewalPriceMethodology = 'Pricebook Increase';
                    }
                    else
                    {
                        wrapper.renewalPriceMethodology = 'No Price Increase Found';
                    }
                }
                
                wrapper.percentIncrease = 0;
                if (wrapper.rpe.Percent_Increase__c != null)
                {
                    wrapper.percentIncrease = wrapper.rpe.Percent_Increase__c;
                }            
                
                // STEP 3: Check to ensure the percent increase is below the cap:          
                if (wrapper.rpe != null && 
                    actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c != null && 
                    actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c != 0)
                {
                    if (wrapper.rpe.Percent_Increase__c > actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c)
                    {                    
                        wrapper.percentIncrease = actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c; 
                    }
                    else
                    {
                        wrapper.percentIncrease = wrapper.rpe.Percent_Increase__c;
                    }
                }
                
                // FINAL STEP: Calculate the new renewal amount:
                wrapper.renewalAmount = wrapper.percentIncrease != null ? ((wrapper.percentIncrease/100) * actLine.Renewal_Base_Price__c) + actLine.Renewal_Base_Price__c : actLine.Renewal_Base_Price__c;
                
                // CREATE LIST OF WRAPPER
                wrapperList.add(wrapper);
                
                // ASSIGN WRAPPER LIST TO CONTROLLER'S LIST
                ctrl.wrapperList = wrapperList.clone();
                
            }
            
            // CALL RELOAD PRICE INCREASE METHOD
            ctrl.reloadPriceIncrease();
            
            // CALL PROCESS RENEWAL METHOD
            ctrl.processRenewal();
            
            if (manageBillingContractRenewalController.isFailed == false) 
            {
                // CODE TO CREATE JOB SCHEDULED RECORD IN RUN HISTORIES OBJECT
                Job_Run_History__c runHist = new Job_Run_History__c();
                runHist.Apex_Class__c = 'AH_ScheduleManageBillingContractRen';
                runHist.Status__c = 'Run';
                runHist.Status_Detail__c = 'Success';
                runHist.No_of_Items_Processed__c = aliList.size();
                runHist.Target_Object__c = 'Activity Line Item';
                runHist.User__c = UserInfo.getUserName();
                runHist.Created_Date__c = Datetime.now();
                
                insert runHist;
                
            }
            
        }
        catch (Exception e) 
        {
            system.debug('Error occured while executing a scheduled job. Line#: ' + e.getLineNumber() + ' - ' + e.getMessage());
            // TRACK THIS ERROR IN NI Error Log OBJECT
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n','Activity_Line_Item__c',  'AH_ScheduleManageBillingContractRen', 'INSERT');
        }
    }
    
    global void finish (Database.BatchableContext bc) 
    {
        
    }
    
}