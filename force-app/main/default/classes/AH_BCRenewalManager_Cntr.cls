/*************************************************************************************************
Name            : AH_BCRenewalManager_Cntr Class
Author          : CLD
Created Date    : 03/28/2016
Last Mod Date   : 05/15/2019
Last Mod By     : Sean Harris
NICC Reference  : UPDATED PER NICC-034730
Description     : Controller for the Renewal Page
                : 
*************************************************************************************************/
public class AH_BCRenewalManager_Cntr
{
    
    public List<aliWrapper> wrapperList {get; set;}
    public Activity_Line_Item__c dummyLine {get; set;}
    public Activity_Line_Item__c actLine {get; set;}
    public Product2 dummyProduct {get; set;}
    public Product2 testProduct {get; set;}
    public Billing_Contract__c dummyBC {get; set;} 
    public Billing_Contract__c testBC {get; set;} 
    public Boolean isAllChecked {get; set;}
    public AH_Schedule_Renewal__c renewalSettings {get; set;}
    public Boolean showMessage {get; set;}
    public Boolean showSchMessage {get; set;}
    public List<SelectOption> leftPBs {get; set;}
    public List<SelectOption> rightPBs {get; set;}
    public List<SelectOption> leftPBs1 {get; set;}
    public List<SelectOption> rightPBs1 {get; set;}
    public List<AsyncApexJob> asyncJobList; //{get; set;}
    public List<NI_Admin_Error_Log__c> errorLogsList; //{get; set;}
    public static Boolean isTestRun = false;
    public List<apxjobs> apexJobsList {get; set;}
    public List<errorLogWrapper> errorWrapList {get; set;}
    public List<apxjobs1> apexjobsList1 {get; set;}
    
    public Set<ID> actIds = new Set<ID>();
    public Boolean fromReload = false;
    public static Boolean isFailed = false;
    public String starDate {get; set;}
    
    public AH_BCRenewalManager_Cntr() 
    {
      
        starDate = 'Renewal Date older than Today';
        
        dummyLine = new Activity_Line_Item__c();
        dummyProduct = new Product2();
        dummyLine.Contract_Start_Date__c = Date.today().addMonths(-1);
        dummyLine.Contract_End_Date__c = Date.today().addMonths(1);
        dummyBC = new Billing_Contract__c();
        
        renewalSettings = AH_Schedule_Renewal__c.getOrgDefaults();
        actLine = new Activity_Line_Item__c();
        actLine.Contract_Start_Date__c = Date.today().addDays(-1);
        actLine.Contract_End_Date__c = Date.today().addDays(-1);
        testProduct = new Product2();
        
        if (renewalSettings == null)
        {
            renewalSettings = new AH_Schedule_Renewal__c();
        }
        
        actLine.Revenue_Category__c = renewalSettings.Revenue_Category__c;
        if (renewalSettings.Product_SKU__c != null)
        {
            actLine.Product__c = Id.valueOf(renewalSettings.Product_SKU__c);
        }
        
        testProduct.Corporate_Product_Group__c = renewalSettings.Corp_Product_Group__c  ;
        
        testBC = new Billing_Contract__c();
        testBC.Account__c = renewalSettings.Customer_Account__c;
        
        List<Renewal_Pricebook__c> renPriceBook = new List<Renewal_Pricebook__c>();
        renPriceBook = [select id, Name from Renewal_Pricebook__c];
        leftPBs = new List<SelectOption>();
        rightPBs = new List<SelectOption>();
        
        leftPBs1 = new List<SelectOption>();
        rightPBs1 = new List<SelectOption>();
        
        List<Id> pbIdList = new List<Id>();
        if (renewalSettings.Excluded_Pricebooks__c != null)
        {
            pbIdList = renewalSettings.Excluded_Pricebooks__c.split(','); 
        }
        
        for (Renewal_Pricebook__c pb : renPriceBook)
        {
            if (pbIdList.contains(pb.Id))
            {
                rightPBs.add(new SelectOption(pb.Id, pb.Name));
            }
            else
            {
                leftPBs.add(new SelectOption(pb.Id, pb.Name));
            }
            leftPBs1.add(new SelectOption(pb.Id, pb.Name));
        }

		//GET THE LIST OF LAST 5 RUNS TO SHOW ON VF PAGE        
		getRunHistory();

        CronTrigger cronJob = new CronTrigger();
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Renewal'];
            showSchMessage = true;
        }
        catch(Exception e)
        {
            showSchMessage = false;  
        }

        // GET THE ERROR LOGS
        getErrorLogsList();
    }
    
    public void fetchData()
    {
        
        Date filterStart = dummyLine.Contract_Start_Date__c;
        Date filterEnd = dummyLine.Contract_End_Date__c;
        String filterRevCategory ='';
        String filterProductLine = '';
        String filterCorpProductGroup = '';
        Id filterProduct;
        Id filterAccount;
        List<Id> filterPriceBookList = new List<Id>();
        Set<Id> renewalpricebookIds = new Set<Id>();
        
        if (system.isScheduled() || system.isBatch())
        {
            
            renewalSettings = AH_Schedule_Renewal__c.getOrgDefaults();
            
            system.debug('renewalSettings : '+renewalSettings);
            
            if (renewalSettings == null)
            {
                renewalSettings = new AH_Schedule_Renewal__c();
            }
            
            //filterStart = Date.today().addDays(-1);
            filterStart = Date.today().addyears(-100);
            filterEnd = Date.today();//.addDays(-1);
            
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
            
        }
        else
        {
            
            filterRevCategory = dummyLine.Revenue_Category__c;
            filterProductLine = dummyProduct.Product_Line__c;
            filterCorpProductGroup = dummyProduct.Corporate_Product_Group__c;
            filterProduct = dummyLine.Product__c;
            filterAccount = dummyBC.Account__c;
            
            system.debug('rightPBs1 : '+rightPBs1);
            if (rightPBs1 != null)
            {
                for (SelectOption so : rightPBs1) 
                {
                    if (so.getValue() != NULL) 
                    {
                        filterPriceBookList.add(so.getValue());
                    }
                }
            }
        }
        
		system.debug('filterStart' + filterStart);
		system.debug('filterEnd' + filterEnd);
        system.debug('filterRevCategory : '+filterRevCategory);
        system.debug('filterProductLine : '+filterProductLine);
        system.debug('filterCorpProductGroup : '+filterCorpProductGroup);
        system.debug('filterProduct : '+filterProduct);
        system.debug('filterAccount : '+filterAccount);
        system.debug('filterPriceBookList : '+filterPriceBookList);
        
        List<c2g__codaCompany__c> currentCompanies = ffaUtilities.gerCurrentCompanies();
        Set<Id> companyIds = new Set<Id>();
        
        for (c2g__codaCompany__c c : currentCompanies)
        {
            companyIds.add(c.id);
        }
        
        wrapperList = new List<aliWrapper>();
        
        // QUERY FOR ALL Activity_Line_Item__c RECORDS THAT MEET THE USERS CRITERIA SPECIFIED 
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
            'Billing_Contract__r.No_Price_Increase_Through__c,' +
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
            'Units_Remaining__c,' +           	// ADDED BY CYBAGE 3/5/2018
            'Pro_Rated__c, ' +
            'Renewal_Pricebook__c,' + 
            'VSOE_Pricing_Item__c, ' + 
            'Product_Package__c, ' + 			// ADDED 08/19/2019  NICC-036731
            'Activation_Required__c ' + 		// ADDED 08/19/2019  NICC-036731
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
            activityLineQuery += ' AND Renewal_Pricebook__c NOT IN :filterPriceBookList ';
        }
        
        // ADDED BY SHASHIKANT ON 09/13/2018
        if (fromReload == true && system.isBatch())
        {
            activityLineQuery += ' AND ID IN: actIds ';
        }
        
		system.debug(' *** AH_BCRenewalManager_Cntr - fetchData - activityLineQuery = ' +  activityLineQuery);
        List<Activity_Line_Item__c> fullaliList = new List<Activity_Line_Item__c>();
        
        try
        {
            fullaliList = Database.query(activityLineQuery);
            system.debug(' *** AH_BCRenewalManager_Cntr - fetchData - fullaliList = ' + fullaliList);
        }
        catch (Exception ex)
        {
            WriteToLog('Error Type: ' + ex.getTypeName() + ' \nCause: ' + ex.getCause() + ' \nLine: ' + ex.getLineNumber() + ' \nError Message: ' + ex.getMessage() + '. \n', 
                       'Activity_Line_Item__c', 
                       'AH_BCRenewalManager_Cntr', 
                       'SELECT'); 
        }
        
        //check the size of the list - if it's over 1000 then report this to the user and trim the list:
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        
        if (fullaliList.size() > 400)
        {
            for (Integer i = 0; i< 400; i++)
            {
                aliList.add(fullaliList[i]);
            }
            if (!system.isScheduled() && !system.isBatch())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Displaying ' + aliList.size().format() + ' of ' + fullaliList.size().format() + ' total activity lines. Refine filters to process all records.'));
            }  
        }
        else
        {
            aliList.addAll(fullaliList);
        }
        
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
        
		system.debug(' *** AH_BCRenewalManager_Cntr - fetchData - rpeList.size = ' + rpeList.size());
		system.debug(' *** AH_BCRenewalManager_Cntr - fetchData - rpeList = ' + rpeList);
        
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
        
		system.debug(' *** AH_BCRenewalManager_Cntr - fetchData - renewalPriceMap size = ' + renewalPriceMap.size());    
        
        try 
        {
            for (Activity_Line_Item__c actLine : aliList)
            {
                
                aliWrapper wrapper = new aliWrapper();
                wrapper.ali_object = actLine;
                wrapper.basePrice = actLine.Renewal_Base_Price__c;
                wrapper.dummy_ali_object.Payment_Terms__c = actLine.Payment_Terms__c;
                // CHANGED BY CYBAGE 3/5/2018 (START)
                //wrapper.dummy_ali_object.Units__c = actLine.Units__c;
                wrapper.dummy_ali_object.Units__c = actLine.Units_Remaining__c;
                wrapper.ali_object.Billing_Renewal_Lead_Time_Days__c = actLine.Billing_Renewal_Lead_Time_Days__c;
                // CHANGED BY CYBAGE 3/5/2018 (END)
                wrapper.dummy_ali_object.Billing_Contract__c = actLine.Billing_Contract__c;
                wrapper.check = true;
                
                // NICC- (START)
                
                // DATE VARIABLE DEFAULTED TO WAY BACK IN THE PAST
                Date dt = Date.newInstance(2000, 1, 1);

                // IF Billing Contract's "No_Price_Increase_Through__c" IS FILLED IN THEN ASSIGN TO dt VARIABLE
                if (actLine.Billing_Contract__r.No_Price_Increase_Through__c != null)
                {
                    dt = actLine.Billing_Contract__r.No_Price_Increase_Through__c;
                }
                
                // IF Activity Line Item's "No_Price_Increase_Through__c" IS FILLED IN 
                // AND IS GREATEST THEN ASSIGN TO dt VARIABLE
                if (actLine.No_Price_Increase_Through__c != null)
                {
                    if (actLine.No_Price_Increase_Through__c > dt)
                    {
                        dt = actLine.No_Price_Increase_Through__c;
                    }   
                }  

                //============ Calculate the Price increase for Renewal Lines ============//            
                //==== STEP 1 === If a no price increase date is specifically stated in the contract then continue.
                // if (actLine.No_Price_Increase_Through__c != null && actLine.Contract_End_Date__c < actLine.No_Price_Increase_Through__c)
                if (actLine.Contract_End_Date__c < dt)
                {   // NICC- (END)
                    wrapper.rpe = null;
                    wrapper.renewalPriceMethodology = 'Contract Spec - No Increase';
                }
                //==== STEP 2 === If a product specific increase exists, use that.
                else 
                {
                    if (renewalPriceMap.containsKey(actLine.Renewal_Pricebook__c + '|' + actLine.Renewal_Date__c.format()))
                    {
                        wrapper.rpe = renewalPriceMap.get(actLine.Renewal_Pricebook__c + '|' + actLine.Renewal_Date__c.format());
                        // wrapper.percentIncrease = wrapper.rpe.Percent_Increase__c != null ? wrapper.rpe.Percent_Increase__c : 0;
                        wrapper.renewalPriceMethodology = 'Pricebook Increase';
                    }
                    else
                    {
                        wrapper.renewalPriceMethodology = 'No Price Increase Found';
                    }
                }
                
                // wrapper.percentIncrease = wrapper.rpe.Percent_Increase__c != null ? wrapper.rpe.Percent_Increase__c : 0;
                
                wrapper.percentIncrease = 0;
                if (wrapper.rpe.Percent_Increase__c != null)
                {
                    wrapper.percentIncrease = wrapper.rpe.Percent_Increase__c;
                }            
                
                //=== STEP 3 === Check to ensure the percent increase is below the cap:          
                if (wrapper.rpe != null && 
                    actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c != null && 
                    actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c != 0)
                {
                    if (wrapper.rpe.Percent_Increase__c > actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c)
                    {                    
                        // wrapper.rpe.Percent_Increase__c = actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c;
                        wrapper.percentIncrease = actLine.Billing_Contract__r.Renewal_Increase_Cap_Percentage__c; 
                    }
                    else
                    {
                        wrapper.percentIncrease = wrapper.rpe.Percent_Increase__c;
                    }
                }
                
                //=== FINAL STEP === Calculate the new renewal amount:
                wrapper.renewalAmount = wrapper.percentIncrease != null ? ((wrapper.percentIncrease/100) * actLine.Renewal_Base_Price__c) + actLine.Renewal_Base_Price__c : actLine.Renewal_Base_Price__c;
                
                //add the wrapper to the list:            
                wrapperList.add(wrapper);
                
            }
        }
        catch (Exception ex)
        {
            WriteToLog('Error Type: ' + ex.getTypeName() + ' \nCause: ' + ex.getCause() + ' \nLine: ' + ex.getLineNumber() + ' \nError Message: ' + ex.getMessage() + '. \n', 
                       'Activity_Line_Item__c', 
                       'AH_BCRenewalManager_Cntr.fetchData()', 
                       '');            
        }
        
    }
    
    public void reloadPriceIncrease()
    {
        
        List<String> actLineNames = new List<String>();
        showMessage = true;
        List<Activity_Line_Item__c> recalcList = new List<Activity_Line_Item__c>();
        
        system.debug(' **** in AH_BCRenewalManager_Cntr.reloadPriceIncrease : wrapperList : ' + wrapperList);
        
        for (aliWrapper wrapper : wrapperList)
        {
            if (wrapper.check == true)
            {
                recalcList.add(wrapper.ali_object);
                actIds.add(wrapper.ali_object.id);
                actLineNames.add(wrapper.ali_object.Name);
            }
        }
        
        if (recalcList.size() == 0 && (!system.isScheduled() && !system.isBatch()))
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'No Lines Selected'));
            return;
        }
        else
        {
            try
            {
                
                update recalcList;
                fromReload = true;
                
                fetchData();
                
                if (!system.isScheduled() && !system.isBatch())
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Reload Successful!'));
                } 
                
            }
            catch (Exception e)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage() + '\n Line: ' + e.getLineNumber() + '\n Cause:' + e.getCause())); 
                WriteToLog('Error Type: ' + e.getTypeName() + ' \nCause: ' + e.getCause() + ' \nLine: ' + e.getLineNumber() + ' \nError Message: ' + e.getMessage() + '. \nError could be in some or all of the following Records : ' + actLineNames + ' \n', 
                           'Activity_Line_Item__c', 
                           'AH_BCRenewalManager_Cntr.reloadPriceIncrease()', 
                           'UPDATE');
            }
        }
        
    }
    
    public void processRenewal()
    {
        
        List<String> actLineNames = new List<String>();
        showMessage = true;
        List<aliWrapper> renewList = new List<aliWrapper>();
        
        for (aliWrapper wrapper : wrapperList)
        {
            if (wrapper.check == true)
            {
                wrapper.renewalAmount = ((wrapper.percentIncrease/100) * wrapper.basePrice) + wrapper.basePrice; //calculate any manual
                renewList.add(wrapper);
                actLineNames.add(wrapper.ali_object.Name);
                system.debug(' **** Act Names : ' + wrapper.ali_object.Name);
            }
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try 
        {
            
            AH_BCRenewalManager_FUNCTIONS.processBCRenewals(renewList);
            
            for (aliWrapper wrapper : wrapperList)
            {
                if (wrapper.check == true)
                {
                    wrapper.check = false;
                    wrapper.disabled = true;
                } 
            }
            
            if (!system.isScheduled() && !system.isBatch())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Renewal Successful!'));
            } 
            
        }
        catch (Exception e)
        {
            if (!system.isScheduled() && !system.isBatch())
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: ' + e.getLineNumber()  + '\n Cause:' + e.getCause())); 
            }
            
            Database.rollback(sp);
            
            WriteToLog('Error Type: ' + e.getTypeName() + ' \nCause: ' + e.getCause() + ' \nLine: ' + e.getLineNumber() + ' \nError Message: ' + e.getMessage() + '. \nError could be in some or all of the following Records : ' + actLineNames + ' \n', 
                       'Activity_Line_Item__c', 
                       'AH_BCRenewalManager_FUNCTIONS.processBCRenewals()', 
                       'INSERT');
        }
        
    }
    
    //METHOD IS CALLED WHEN 'SCHEDULE APEX' BUTTON ON VF PAGE IS CLICKED
    public void callSchedulableClass()
    {
        
        showMessage = false;        
        CronJobDetail cronJob = new CronJobDetail();
        String excludedPBIds = '';
        Product2 p = new Product2();
        Account a = new Account();
        
        //CHECK IF JOB IS ALREADY SCHEDULED
        try
        {
            cronJob = [SELECT Id, Name FROM CronJobDetail WHERE Name = 'Schedule Renewal'];
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Job is already scheduled, please abort and reschedule!'));
        }
        catch (Exception e)
        {
            renewalSettings = AH_Schedule_Renewal__c.getOrgDefaults();
            if (renewalSettings == null)
            {
                renewalSettings = new AH_Schedule_Renewal__c();
            }
            if (actLine.Revenue_Category__c != null)
            {
                renewalSettings.Revenue_Category__c = actLine.Revenue_Category__c;
            }
            if (testProduct.Corporate_Product_Group__c != null)
            {
                renewalSettings.Corp_Product_Group__c = testProduct.Corporate_Product_Group__c;
            }  
            if (testBC.Account__c != null)
            {
                renewalSettings.Customer_Account__c = testBC.Account__c;
                a = [SELECT Id, Name FROM Account WHERE Id = :testBC.Account__c];
            }
            if (actLine.Product__c != null)
            {
                renewalSettings.Product_SKU__c = actLine.Product__c;
                p = [SELECT Id, Name FROM Product2 WHERE Id = :actLine.Product__c];
            }
            if (testProduct != null && testProduct.Product_Line__c != null)
            {
                renewalSettings.Product_Line__c = testProduct.Product_Line__c;
            }                
            
            if (!rightPBs.isEmpty())
            {
                for (SelectOption so : rightPBs) 
                {
                    if (so.getValue() != NULL) 
                    {
                        excludedPBIds += so.getValue() + ',';
                        System.debug('Case Type Name : ' + so.getValue());
                    }
                }
            }
            else
            {
                excludedPBIds = '' ;
                renewalSettings.Excluded_Pricebooks__c = excludedPBIds;
            }
            
            if (excludedPBIds != '' && excludedPBIds != null)
            {
                renewalSettings.Excluded_Pricebooks__c = excludedPBIds.removeEnd(',');
            }
            
            try
            { 
                upsert renewalSettings;
                showSchMessage = true;    
                AH_BCRenewalManager_Schedule classObj = new AH_BCRenewalManager_Schedule();

                String sch = '';

                //CODE TO RUN SCHEDULER AT SPECIFC HOUR & MIN
                ///*
				DateTime myDateTime = DateTime.now();
                Integer min = myDateTime.minute() + 2;
                sch = '0 '+ min +' '+ myDateTime.hour() +' * * ?'; 
                //*/
                
                sch = '0 0 0 * * ? *';
                String jobID = system.schedule('Schedule Renewal', sch, classObj);
                String msg = 'Schedule Renewal job scheduled for 12:00 AM daily to process renewals of those Activity Line Items that have Renewal date older than Today.';
                
                if (actLine.Revenue_Category__c != null)
                {
                    msg += '<br/> Revenue_Category__c: ' +  actLine.Revenue_Category__c;
                }
                if (actLine.Product__c != null)
                {
                    msg += '<br/> Product / SKU: ' +  p.Name;
                }
                if (testProduct.Corporate_Product_Group__c != null)
                {
                    msg += '<br/> Corp Product Group: ' +  testProduct.Corporate_Product_Group__c;
                }
                if (testBC.Account__c != null)
                {
                    msg += '<br/> Customer Account: ' +  a.Name; 
                }
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, msg));
                
                getErrorLogsList();
                
                // CODE TO CREATE JOB SCHEDULED RECORD IN RUN HISTORIES OBJECT
                Job_Run_History__c runHist = new Job_Run_History__c();
                runHist.Apex_Class__c = 'AH_BCRenewalManager_Schedule';
                runHist.Status__c = 'Queued';
                runHist.Target_Object__c = 'Activity Line Item';
                runHist.User__c = UserInfo.getUserName();
                runHist.Created_Date__c = Datetime.now();
                
                insert runHist;
                
                getRunHistory();
                
            }
            catch (Exception ex)
            {
                showSchMessage = false;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error encountered, please retry.')); 
                WriteToLog('Error Type: ' + e.getTypeName() + ' \nCause: ' + e.getCause() + ' \nLine: ' + e.getLineNumber() + ' \nError Message: ' + e.getMessage() + '. \n',
                           'Activity_Line_Item__c', 
                           'AH_BCRenewalManager_Schedule', 
                           'INSERT');
            }
            
        }
        
    }
    
    public void abortScheduledJob()
    {
        showMessage = false;
        
        // QUERY AsyncApexJob TO KNOW THE LAST TIME THE JOB SUCCESSFULLY RAN
        CronTrigger cronJob = new CronTrigger();
        try
        {
            cronJob = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Schedule Renewal'];
            System.abortJob(cronJob.Id);
            showSchMessage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Job aborted successfully!'));
            
            getErrorLogsList();
            
            // CODE TO CREATE JOB ABORED RECORD IN RUN HISTORIES OBJECT
            Job_Run_History__c runHist = new Job_Run_History__c();
            runHist.Apex_Class__c = 'AH_BCRenewalManager_Schedule';
            runHist.Status__c = 'Aborted';
        	runHist.Status_Detail__c = 'Aborted';
            runHist.Target_Object__c = 'Activity Line Item';
            runHist.User__c = UserInfo.getUserName();
            runHist.Created_Date__c = Datetime.now();
			
            insert runHist;
            
            getRunHistory();
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No jobs found.')); 
        }
    }
    
    private void getErrorLogsList() 
    {
        errorLogsList = new List<NI_Admin_Error_Log__c>();
        List<String> classNames = new List<String>{'AH_BCRenewalManager_Schedule', 
                                   'AH_BCRenewalManager_Cntr.getRunHistory',
                                   'AH_BCRenewalManager_FUNCTIONS',
                                   'AH_BCRenewalManager_Cntr.getErrorLogsList'
            					  };
        try 
        {
            errorLogsList = [SELECT ID, 
                             Name, 
                             Apex_Class_Name__c, 
                             DML_Type__c, 
                             Message__c, 
                             Object_Name__c, 
                             CreatedBy.Name, 
                             CreatedDate 
                             FROM NI_Admin_Error_Log__c 
                             WHERE Apex_Class_Name__c IN : classNames  
                             ORDER BY createdDate DESC 
                             LIMIT 5
                            ];
            
            errorWrapList = new List<errorLogWrapper>();
            if (!errorLogsList.isEmpty())
            {
                for (NI_Admin_Error_Log__c err: errorLogsList)
                {
                    errorLogWrapper e = new errorLogWrapper();
                    e.errorId = err.id;
                    e.Name = err.Name;
                    e.Object_Name = err.Object_Name__c;
                    e.Apex_Class_Name = err.Apex_Class_Name__c;
                    e.DML_Type = err.DML_Type__c;
                    e.Message = err.Message__c;
                    e.CreatedByName = err.CreatedBy.Name;
                    if (err.CreatedDate != NULL) {
                        e.CreatedDate = err.CreatedDate;
                    }
                    errorWrapList.add(e);
                }
            }
        }
        catch (Exception e)
        {
            WriteToLog('Error Type: ' + e.getTypeName() + ' \nCause: ' + e.getCause() + ' \nLine: ' + e.getLineNumber() + ' \nError Message: ' + e.getMessage() + '. \n', 
                       'NI_Admin_Error_Log__c', 
                       'AH_BCRenewalManager_Cntr.getErrorLogsList()', 
                       'SELECT');
        }
    }
    
    private void getRunHistory() 
    {
        
        try
        {
            asyncJobList  = new List<AsyncApexJob>();
            apexJobsList = new List<apxjobs>();
            
            asyncJobList = [SELECT Id,
                            ApexClassId, 
                            ApexClass.Name,
                            CompletedDate, 
                            CreatedBy.Name,  
                            Status, 
                            CreatedDate,  
                            ExtendedStatus, 
                            TotalJobItems, 
                            JobItemsProcessed, 
                            NumberOfErrors
                            FROM AsyncApexJob
                            WHERE ApexClassId IN (SELECT Id from ApexClass WHERE Name = 'AH_BCRenewalManager_Schedule')
                            ORDER BY CreatedDate 
                            DESC LIMIT 5];
            
            if (!asyncJobList.isEmpty())
            {
                for (AsyncApexJob a : asyncJobList)
                {
                    apxjobs obj = new apxjobs();
                    obj.ApexClassID = a.ApexClassID;
                    obj.ApexClassName = a.ApexClass.Name;
                    obj.CreatedByName = a.CreatedBy.Name;
                    obj.Status = a.Status;
                    obj.CreatedDate = a.CreatedDate;
                    obj.TotalJobItems = a.TotalJobItems;
                    obj.JobItemsProcessed = a.JobItemsProcessed;
                    obj.NumberOfErrors = a.NumberOfErrors;
                    
                    if (a.CompletedDate != null) 
                    {
                        obj.CompletedDate = a.CompletedDate;
                    }
                    if (a.ExtendedStatus != null) 
                    {
                        obj.ExtendedStatus = a.ExtendedStatus;
                    }
                    
                    apexJobsList.add(obj);
                }
            }
            
            apexjobsList1 = new List<apxjobs1>();
            for (Job_Run_History__c r : [SELECT ID, Apex_Class__c, Created_Date__c, Status__c, 
                                     Target_Object__c, CreatedBy.Name, Status_Detail__c, No_of_Items_Processed__c  
                                     FROM Job_Run_History__c 
                                     WHERE Apex_Class__c = 'AH_BCRenewalManager_Schedule' 
                                     ORDER BY CreatedDate DESC LIMIT 5])
            {
                apxjobs1 ap = new apxjobs1();
                ap.Apex_Class = r.Apex_Class__c;
                ap.user = r.CreatedBy.Name;
                ap.Status = r.Status__c;
                ap.Status_Detail = r.Status_Detail__c;
                ap.No_of_Items_Processed = Integer.valueOf(r.No_of_Items_Processed__c);
                ap.CreatedDate = r.Created_Date__c;
                ap.Target_Object = r.Target_Object__c;
                
                apexjobsList1.add(ap);
            }
        }
        catch (Exception e) 
        {
            WriteToLog('Error Type: ' + e.getTypeName() + ' \nCause: ' + e.getCause() + ' \nLine: ' + e.getLineNumber() + ' \nError Message: ' + e.getMessage() + '. \n', 
                       'AsyncApexJob', 
                       'AH_BCRenewalManager_Cntr.getRunHistory()', 
                       'SELECT');
        }
    }

    // TRACK ERROR IN NI Error Log OBJECT
    public void WriteToLog (String error, String obj, String className, String dml)
    {
        
        NI_Error_Logger.WriteToLog(error, obj, className, dml);
        getErrorLogsList();
        
        isFailed = true;
        
        Job_Run_History__c runHist = new Job_Run_History__c();
        runHist.Apex_Class__c = 'AH_BCRenewalManager_Schedule';
        runHist.Status__c = 'Run';
        runHist.Status_Detail__c = 'Failed';
        runHist.Target_Object__c = 'Activity Line Item';
        runHist.User__c = UserInfo.getUserName();
        runHist.Created_Date__c = Datetime.now();
        
        insert runHist;
        
    }
    
    // ===============================================================
    //  WRAPPER CLASSES ==============================================
    // ===============================================================
    public class apxjobs
    {            
        public Id ApexClassID {get; set;}
        public String ApexClassName {get; set;}
        public Datetime CompletedDate {get; set;}
        public String CreatedByName {get; set;}
        public String Status {get; set;}
        public Datetime CreatedDate {get; set;}
        public String ExtendedStatus {get; set;}
        public Integer TotalJobItems {get; set;}
        public Integer JobItemsProcessed {get; set;}
        public Integer NumberOfErrors {get; set;}
        
        public apxjobs()
        {
            this.CreatedByName = '';
            this.Status = '';
            this.ExtendedStatus = '';
            this.ApexClassName = '';
        }
    }
    
    public class apxjobs1
    {            
        public String Apex_Class {get; set;}
        public String user {get; set;}
        public String Status {get; set;}
        public Datetime CreatedDate {get; set;}
        public String Target_Object {get; set;}
        public String Status_Detail {get; set;}
        public Integer No_of_Items_Processed {get; set;}
        
        public apxjobs1()
        {
            this.Apex_Class = '';
            this.Status = '';
            this.Target_Object = '';
        }
    }
    
    public class errorLogWrapper 
    {
        
        public ID errorId {get; set;}
        public String Name {get; set;}
        public String Object_Name {get; set;}
        public String Apex_Class_Name {get; set;}
        public String DML_Type {get; set;}
        public String Message {get; set;}
        public String CreatedByName {get; set;}
        public Datetime CreatedDate {get; set;}
        
        public errorLogWrapper() 
        {
            this.Name = '';
            this.Object_Name = '';
            this.Apex_Class_Name = '';
            this.DML_Type = '';
            this.Message = '';
            this.CreatedByName = '';
        }
    }
    
    public class aliWrapper 
    {
        public Activity_Line_Item__c ali_object {get; set;}
        public Activity_Line_Item__c dummy_ali_object {get; set;}
        public boolean check {get; set;}
        public boolean disabled {get; set;}
        public Renewal_Pricing_Entry__c rpe {get; set;}
        public decimal renewalAmount {get; set;}
        public decimal percentIncrease {get; set;}
        public decimal basePrice {get; set;}
        public String renewalPriceMethodology {get; set;}
        
        public aliWrapper()
        {
            ali_object = new Activity_Line_Item__c();
            dummy_ali_object = new Activity_Line_Item__c();
            renewalPriceMethodology = 'Not yet set';
            check = false;
        }
    }
        
}