public class billingContractSplitLinesController {
    public Billing_Contract__c billingContract {get; set;}
    public List<Activity_Line_Item__c> aliUpsertList;
    public List<Billing_Contract_Line_Item__c> bliUpsertList;
    public List<activityLineModel> activitylineItems {get; set;}
    public Boolean disablePage {get; set;}
    public Boolean globalError {get; set;}


    public billingContractSplitLinesController(ApexPages.StandardController controller) {
        this.billingContract = (Billing_Contract__c)controller.getRecord(); 
        aliUpsertList = new List<Activity_Line_Item__c>();
        bliUpsertList = new List<Billing_Contract_Line_Item__c>();
        globalError = false;
        loadLineItems();
    }

    public void loadLineItems(){
        activitylineItems = new List<activityLineModel>();
        disablePage = false;        

        billingContract = [SELECT id, Opportunity__c, Agreement__c, VSOE_Calculation_Status__c FROM Billing_Contract__c WHERE Id = :billingContract.id];    
       
        for(Activity_Line_Item__c ali : [
            SELECT Activity_Project_Billing__c,
                 Billing_Contract__c,
                 Billing_Contract__r.VSOE_Calculation_Status__c,
                 Billing_Contract__r.Effective_Date__c,
                 Contract_Amount__c,
                 Contract_End_Date__c,
                 Contract_Start_Date__c,
                 Contract_Total_Amount__c,
                 CreatedById,
                 CreatedDate,
                 Final_SW_Group_Allocation__c,
                 Attn_to_Contact__c,
                 CurrencyIsoCode,
                 Payment_Terms__c,
                 Fair_Value__c,
                 PCS_Days__c,
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
                 Software_Discount__c,
                 VSOE_Discount__c,
                 SystemModstamp,
                 Units__c,
                 VSOE_Pricing_Item__c,
                 (SELECT Id,
                    Quantity__c,
                    Unit_Price__c
                  FROM Billing_Contract_Line_Items__r)
            FROM Activity_Line_Item__c
            WHERE Billing_Contract__c = :billingContract.Id
            AND Revenue_Category__c != 'Services'
            AND Id not in (SELECT Activity_Line_Item__c FROM Billing_Contract_Line_Item__c WHERE Billing_Contract__c = :billingContract.Id AND Invoiced__c = true)
            ORDER BY Revenue_Category__c, SKU__c, Units__c desc])
        {            
            activityLineModel a = new activityLineModel();
            a.ali_object = ali;
            activitylineItems.add(a);
        }
    }
    
    public PageReference splitLines(){
        String nextlink = '/apex/billingContractSplitLines?Id=' + billingContract.Id;
        PageReference pageRef = new PageReference(nextlink);
        pageRef.setRedirect(true);
        List<activityLineModel> splitList = new List<activityLineModel>();
        for(activityLineModel a : activitylineItems){
            if(a.check == true){
                if(a.splitQuantity == null || a.splitQuantity == 0 || a.splitQuantity > a.ali_object.Units__c){
                    a.hasError = true;
                    globalError = true;
                    splitList.add(a);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, a.ali_object.Name + ' - The split quantity is blank, zero, or exceeds the original quantity'));  
                }
                else if(a.ali_object.Units__c == 1){
                    a.hasError = true;
                    globalError = true;
                    splitList.add(a);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, a.ali_object.Name + ' - You cannot split a line item with a quantity of 1'));  
                }
                else{
                    splitList.add(a);
                }
            }
        }

        if(splitList.size()>0 && globalError == false){
            try {
            splitAndClone(splitList);
            loadLineItems();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Split / Clone Successful!'));  
            
            }
            catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
            return pageRef;
            
        }
        else if(splitList.size()==0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Line Items Selected!'));
            return null;
        }
        else{
            return null;
        }
    }
    
    public PageReference backToBC(){
        PageReference ref = new PageReference('/'+billingContract.Id);
        return ref;
    }

    public void splitAndClone (List<activityLineModel> aliModelList){
        for(activityLineModel aModel : aliModelList){
            //1) Update existing ali
            aModel.ali_object.Units__c = aModel.ali_object.Units__c - aModel.splitQuantity;
            aliUpsertList.add(aModel.ali_object);

            //2) Clone new ali
            Activity_Line_Item__c splitALI = aModel.ali_object.clone(false,true,false,false);
            splitALI.Units__c = aModel.splitQuantity;
            aliUpsertList.add(splitALI);
        }

        upsert aliUpsertList;
        bliUpsertList = billingContractHandler.recalcBillingLines(aliUpsertList, true);
        insert bliUpsertList;
    }

    public class activityLineModel{
        public Activity_Line_Item__c ali_object {get;set;}
        public boolean check {get;set;}
        public Integer splitQuantity {get;set;}
        public Boolean hasError {get;set;}
        public activityLineModel(){
            ali_object = new Activity_Line_Item__c();
            check = false;
            hasError = false;
        }
    }
}