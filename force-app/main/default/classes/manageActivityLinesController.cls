public class manageActivityLinesController {
    public Billing_Contract__c billingContract {get; set;}
    public List<activityLineModel> activitylineItems {get; set;}

    public manageActivityLinesController(ApexPages.StandardController controller) {
        this.billingContract = (Billing_Contract__c)controller.getRecord(); 
        loadLineItems();
    }

    public void loadLineItems(){
        activitylineItems = new List<activityLineModel>();
       
        for(Activity_Line_Item__c ali : [
            SELECT Activity_Project_Billing__c,
                 Billing_Contract__c,
                 Contract_Amount__c,
                 Contract_End_Date__c,
                 Contract_Start_Date__c,
                 CreatedById,
                 CreatedDate,
                 Opp_Product_ID__c,
                 CurrencyIsoCode,
                 Fair_Value__c,
                 Id,
                 Activation_Date__c,
                 Activation_Required__c,
                 IsDeleted,
                 LastActivityDate,
                 LastModifiedById,
                 LastModifiedDate,
                 Pro_Rated__c,
                 Payment_Terms__c,
                 List_Price__c,
                 Renewal_Base_Price__c,
                 PSA_Milestone__c,
                 Revenue_Category__c,
                 Include_in_Revenue_Recognition__c,
                 Name,
                 Percent_of_Total__c,
                 Product__c,
                 Product__r.Duration_Months__c,
                 Product_Description__c,
                 Relative_Selling_Price_Allocation__c,
                 Revenue_Recognized_to_Date__c,
                 Service_Discount__c,
                 SKU__c,
                 Fulfillment_Required__c,
                 Fulfillment_Complete__c,
                 Software_Discount__c,
                 SystemModstamp,
                 Units__c,
                 VSOE_Pricing_Item__c,
            	 Order_of_Delivery__c, 
            Product_Package__c,
			Product_Package_Item__c,
            Opportunity__c,
            Deployment_Instance__c, 
                 (SELECT id FROM Billing_Contract_Line_Items__r WHERE Invoiced__c = true) 
            FROM Activity_Line_Item__c
            WHERE Billing_Contract__c = :billingContract.Id])
        {
            activityLineModel a = new activityLineModel();
            a.ali_object = ali;
            activitylineItems.add(a);
        }

        system.debug('***** \n\n psaManageBCLController - loadLineItems - billingContract.Id = ' + billingContract.Id);
        system.debug('***** \n\n psaManageBCLController - loadLineItems - activitylineItems.size() = ' + activitylineItems.size());
    }


    public PageReference proRateLines(){
        Map<Id,Activity_Line_Item__c> proRateMap = new Map<Id,Activity_Line_Item__c>();
        for(activityLineModel a : activitylineItems){
            if(a.check == true){
                if(a.ali_object.Contract_End_Date__c == null || a.ali_object.Contract_Start_Date__c == null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - you must select a Start Date and End Date'));  
                    return null; 
                }
                else if(a.ali_object.Billing_Contract_Line_Items__r.size() > 0){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - there are 1 or more related Billing Lines that have been invoiced already'));  
                    return null; 
                }
                else if(a.ali_object.Contract_End_Date__c <= a.ali_object.Contract_Start_Date__c){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - The end date must be greater than the start date.'));  
                    return null; 
                }
                else if(a.ali_object.Product__r.Duration_Months__c == null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - The related product does not have a duration set, unable to pro-rate the line.'));  
                    return null; 
                }
                else if(a.ali_object.Revenue_Category__c == 'Services'){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - You cannot pro-rate Services'));  
                    return null; 
                }
                else if(a.ali_object.Pro_Rated__c == true){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - This item has already been pro-rated'));  
                    return null; 
                }
                else if(a.ali_object.Activation_Required__c == true && a.ali_object.Activation_Date__c == null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Pro-Rate Unsuccessful - This item requires activation, please enter an activation date'));  
                    return null; 
                }
                else{
                    proRateMap.put(a.ali_object.id, a.ali_object);    
                }
            }
        }
        if(proRateMap.size()>0)
        {
            try {
                for(Activity_Line_Item__c ali : proRateMap.values()){
                    Date productDurationEndDate = ali.Contract_Start_Date__c.addMonths(ali.Product__r.Duration_Months__c.intValue());
                    ali = billingContractHandler.proRateInvoiceAmount_Activity(ali, ali.Contract_Start_Date__c, productDurationEndDate, ali.Contract_End_Date__c, ali.Contract_Amount__c);
                }
                List<Billing_Contract_Line_Item__c> bcliList = billingContractHandler.recalcBillingLinesProRated(proRateMap.values(), true);
                /*for(Billing_Contract_Line_Item__c bcli : bcliList){
                    Activity_Line_Item__c tmpAli = proRateMap.containsKey(bcli.Activity_Line_Item__c) ? proRateMap.get(bcli.Activity_Line_Item__c) : null;
                    system.assert(tmpAli != null,'ProRating Error - could not link Activity Line Item');
                    //Date productDurationEndDate = tmpAli.Contract_Start_Date__c.addMonths(tmpAli.Product__r.Duration_Months__c.intValue());
                    //bcli = billingContractHandler.proRateInvoiceAmount_Billing(bcli, tmpAli.Contract_Start_Date__c, productDurationEndDate, tmpAli.Contract_End_Date__c, bcli.Total_Amount__c, tmpAli);
                }*/
                update proRateMap.values();
                upsert bcliList;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Pro Rate Successful!'));  
            }
            catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
                return null; 
            }
            return null; 
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Line Items Selected!'));  
            return null; 
        }
    }

    
    public PageReference saveLines(){
        String nextlink = '/apex/manageActivityLines?Id=' + billingContract.Id;
        PageReference pageRef = new PageReference(nextlink);

        pageRef.setRedirect(true);
        List<Activity_Line_Item__c> updateList = new List<Activity_Line_Item__c>();
        for(activityLineModel b : activitylineItems)
        {
            if(b.check == true)
            {
                updateList.add(b.ali_object);
            }
        }
        if(updateList.size()>0)
        {
            try {
            update updateList;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,
                'Save Successful!'));  
            }
            catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
                return null; 
            }
            return pageRef; 
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Line Items Selected!'));  
            return null; 
        }
    }
    
    public PageReference backToBC(){
        PageReference ref = new PageReference('/'+billingContract.Id); 
        return ref; 
    }

    public void addRow(){
        activityLineModel mod = new activityLineModel();
        mod.check = true;
        mod.ali_object.Billing_Contract__c = billingContract.id;
        activitylineItems.add(mod);
        system.debug('***** \n\n psaManageBCLController - addRow - activitylineItems.size()'+activitylineItems.size());
    }

    public void deleteSelected(){
        List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>();
        List<activityLineModel> templist = new List<activityLineModel>();
        for(activityLineModel mod : activitylineItems){
            if(mod.check == true){
                if(mod.ali_object.id != null){
                    aliList.add(mod.ali_object);
                }
            }
            else{
                templist.add(mod);
            }
        }
        activitylineItems = templist;

        system.debug('***** \n\n psaManageBCLController - deleteSelected - aliList.size()'+aliList.size());

        if(aliList.size()>0)
        {
            try {
            delete aliList;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Delete Successful!'));  
            }
            catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
            }
        }
    }

    public class activityLineModel{
        public Activity_Line_Item__c ali_object {get;set;}
        public boolean check {get;set;}
        public activityLineModel(){
            ali_object = new Activity_Line_Item__c();
            check = false;
        }
    }


}