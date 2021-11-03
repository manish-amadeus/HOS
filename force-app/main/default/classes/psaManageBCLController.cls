public class psaManageBCLController 
{
    public Billing_Contract__c billingContract {get; set;}
    public List<billingLineModel> openlineItems {get; set;}
    public List<Billing_Contract_Line_Item__c> invoicedlineItems {get; set;}
    public Boolean checked {get;set;}

    public psaManageBCLController(ApexPages.StandardController controller) {
        this.billingContract = (Billing_Contract__c)controller.getRecord(); 
        this.billingContract = [
         SELECT Id, 
         Services_Total__c, 
         Subscription_Total__c, 
         Hosting_and_Support_Total__c,
         Software_Total__c,
         Support_Total__c
         FROM Billing_Contract__c 
         WHERE id = :billingContract.id];
        loadLineItems(); 
        checked = false;
    }    
    
    public void loadLineItems(){
    	openlineItems = new List<billingLineModel>();
    	invoicedlineItems = new List<Billing_Contract_Line_Item__c>();
        
        for(Billing_Contract_Line_Item__c bcli : [
        	SELECT
	        	Billing_Contract__c,
	        	CreatedById,
	        	CreatedDate,
	        	CurrencyIsoCode,
	        	Id,
	        	Invoice_Date__c,
	        	Invoiced__c,
	        	IsDeleted,
	        	LastActivityDate,
	        	LastModifiedById,
                Status__c,
	        	LastModifiedDate,
	        	Name,
	        	Opp_Line_Item_ID__c,
                Line_Item_Description__c,
	        	Payment_Terms__c,
	        	Product__c,
	        	Quantity__c,
	        	Ready_to_Invoice__c,
	        	Revenue_Category__c,
                Activity_Line_Item__c,
	        	Sales_Invoice_Line_Item__c,
	        	SystemModstamp,
	        	Total_Amount__c,
	        	Unit_Price__c, 
            	SKU__c 
        	FROM Billing_Contract_Line_Item__c 
        	WHERE Billing_Contract__c = :billingContract.Id])
        {
        	if(bcli.Invoiced__c == true)
        	{
        		invoicedlineItems.add(bcli);
        	}
        	else
        	{
        		billingLineModel b = new billingLineModel();
        		b.bcli_object = bcli;
        		openlineItems.add(b);
        	}
        }
        system.debug('***** \n\n psaManageBCLController - loadLineItems - billingContract.Id = ' + billingContract.Id);
        system.debug('***** \n\n psaManageBCLController - loadLineItems - invoicedlineItems.size() = ' + invoicedlineItems.size());
        system.debug('***** \n\n psaManageBCLController - loadLineItems - openlineItems.size() = ' + openlineItems.size());

    }
    
    public PageReference saveLines(){
        Boolean isValid = validateBCLSave();
        if(isValid == true){
            List<Billing_Contract_Line_Item__c> updateList = new List<Billing_Contract_Line_Item__c>();
            for(billingLineModel b : openlineItems)
            {
                if(b.check == true)
                {
                    updateList.add(b.bcli_object);
                }
            }
            if(updateList.size()>0)
            {
                try {
                upsert updateList;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Save Successful!'));  
                }
                catch (Exception e){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
                    return null; 
                }
                return null; 
            }
            else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'No Line Items Selected!'));  
                return null; 
            }
        }
        else{
            return null;
        }
    }

    public void cloneLines(){
        List<Billing_Contract_Line_Item__c> updateList = new List<Billing_Contract_Line_Item__c>();
        List<billingLineModel> toClone = new List<billingLineModel>();
        for(billingLineModel b : openlineItems){
            if(b.check == true)
            {
                toClone.add(b);
            }
        }
        for(billingLineModel b : toClone){
            billingLineModel mod = new billingLineModel();
            mod.check = true;
            mod.bcli_object = b.bcli_object.clone(false, true, false, false);
            //mod.bcli_object.CreatedById = UserInfo.getUserId();
            openlineItems.add(mod);
        }
    }
    
    public PageReference backToBC(){
        PageReference ref = new PageReference('/'+billingContract.Id); 
        return ref; 
    }

    //Method to ensure the quantity of the billing line is not greater than the Activity Line Item.
    public Boolean validateBCLSave(){
        Boolean isValid = true;
        Map<Id, Decimal> bliQuantityMap = new Map<Id, Decimal>();
        Map<Id, Decimal> aliQuantityMap = new Map<Id, Decimal>();
        for(billingLineModel b : openlineItems){
            if(b.check == true){
                if(!bliQuantityMap.containsKey(b.bcli_object.Activity_Line_Item__c)){
                    bliQuantityMap.put(b.bcli_object.Activity_Line_Item__c, b.bcli_object.Quantity__c);
                }
                else{
                    Decimal tmp = bliQuantityMap.get(b.bcli_object.Activity_Line_Item__c) + b.bcli_object.Quantity__c;
                    bliQuantityMap.put(b.bcli_object.Activity_Line_Item__c, tmp);
                }
            }
        }
        /*for(Activity_Line_Item__c ali : [SELECT Id, Units__c, Product__r.Name FROM Activity_Line_Item__c WHERE Id in :bliQuantityMap.keyset() AND Product_Package__c = null]){
            if(bliQuantityMap.get(ali.id) > ali.Units__c){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'ERROR on Product: '+ali.Product__r.Name+' The quantities from the Billing Lines ('+bliQuantityMap.get(ali.id)+') exceed the quantities from the Activity Line ('+ali.Units__c+')'));  
                isValid = false;
            }
        }*/
        return isValid;
    }

    public void addRow(){
        billingLineModel mod = new billingLineModel();
        mod.check = true;
        mod.bcli_object.Billing_Contract__c = billingContract.id;
        mod.bcli_object.Quantity__c = 0;
        mod.bcli_object.Unit_Price__c = 0;
        mod.bcli_object.Total_Amount__c = 0;
        openlineItems.add(mod);
        system.debug('***** \n\n psaManageBCLController - addRow - openlineItems.size()'+openlineItems.size());
    }

    public void deleteSelected(){
        List<Billing_Contract_Line_Item__c> bcliList = new List<Billing_Contract_Line_Item__c>();
        List<billingLineModel> templist = new List<billingLineModel>();
        for(billingLineModel mod : openlineItems){
            if(mod.check == true){
                if(mod.bcli_object.id != null){
                    bcliList.add(mod.bcli_object);
                }
            }
            else{
                templist.add(mod);
            }
        }
        openlineItems = templist;

        system.debug('***** \n\n psaManageBCLController - deleteSelected - bcliList.size()'+bcliList.size());

        if(bcliList.size()>0)
        {
            try {
            delete bcliList;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Delete Successful!'));  
            }
            catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage())); 
            }
        }
    }

    public class billingLineModel{
        public Billing_Contract_Line_Item__c bcli_object {get;set;}
        public boolean check {get;set;}
        public billingLineModel(){
            bcli_object = new Billing_Contract_Line_Item__c();
            check = false;
        }
    }

}