public class createMSfromActivityLinesController {
	public Billing_Contract__c billingContract {get; set;}
    public List<activityLineModel> activitylineItems {get; set;}
    public String projectCreationURL {get; set;}
    public Set<Id> accountIDSet;
    public Id projectID {get; set;}
    String oppName;

    public createMSfromActivityLinesController(ApexPages.StandardController controller) {
        this.billingContract = (Billing_Contract__c)controller.getRecord(); 
        billingContract = [SELECT id, Account__c, Opportunity__c, Opportunity__r.Opportunity_Number__c FROM Billing_Contract__c WHERE id = :billingContract.id];
        loadData();
        projectCreationURL = '/apex/CreateProjectFromOpportunity?scontrolCaching=1&id='+billingContract.Opportunity__c;
    }

    public void loadData()
    {
    	activitylineItems = new List<activityLineModel>();
    	accountIDSet = new Set<Id>();
       
        for(Activity_Line_Item__c ali : [
        	SELECT Activity_Project_Billing__c,
	        	 Billing_Contract__c,
                 Billing_Contract__r.Account__c,
                 Billing_Contract__r.Opportunity__r.Name,
                 Adjusted_Revenue_Amount__c,
	        	 Contract_Amount__c,
                 Contract_Total_Amount__c,
	        	 Contract_End_Date__c,
	        	 Contract_Start_Date__c,
	        	 CreatedById,
	        	 CreatedDate,
	        	 CurrencyIsoCode,
	        	 Fair_Value__c,
	        	 Id,
	        	 IsDeleted,
	        	 LastActivityDate,
                 Include_in_Revenue_Recognition__c,
	        	 LastModifiedById,
	        	 LastModifiedDate,
	        	 List_Price__c,
	        	 PSA_Milestone__c,
                 Payment_Terms__r.Billed_through_PSA__c,
	        	 PSA_Milestone__r.Name,
	        	 PSA_Milestone__r.pse__Project__c,
	        	 Name,
	        	 Revenue_Category__c,
	        	 Percent_of_Total__c,
                 Product_Package_Item__c,
                 Product_Package_Item__r.Practice__c,
	        	 Product__c,
                 Product__r.Name,
	        	 Product_Description__c,
	        	 Relative_Selling_Price_Allocation__c,
	        	 Revenue_Recognized_to_Date__c,
	        	 Service_Discount__c,
	        	 SKU__c,
	        	 Software_Discount__c,
                 Milestone_Name_Prefix__c,
	        	 SystemModstamp,
	        	 Units__c,
	        	 VSOE_Pricing_Item__c 
        	FROM Activity_Line_Item__c
        	WHERE Billing_Contract__c = :billingContract.Id
        	AND	 Revenue_Category__c = 'Services'
            AND Product__r.pse__IsServicesProduct__c = true])
        {
    		activityLineModel a = new activityLineModel();
    		a.ali_object = ali;
            a.check = ali.PSA_Milestone__c == null ? true : false;
            a.msName = ali.Milestone_Name_Prefix__c != null ? ali.Milestone_Name_Prefix__c + ' - '+billingContract.Opportunity__r.Opportunity_Number__c : ali.Product__r.Name + ' - '+billingContract.Opportunity__r.Opportunity_Number__c;
            a.disabled = ali.PSA_Milestone__c == null ? false : true;
    		activitylineItems.add(a);
    		accountIDSet.add(ali.Billing_Contract__r.Account__c);
        }

        system.debug('***** \n\n psaManageBCLController - loadData - billingContract.Id = ' + billingContract.Id);
        system.debug('***** \n\n psaManageBCLController - loadData - activitylineItems.size() = ' + activitylineItems.size());
    }

    /***** EXISTING PROJ PICKLIST ******/
	public List<selectOption> getProj_Options() {
	    list<SelectOption> projOptions = new list<SelectOption> ();

	    //add the first option of none:
	    projOptions.add(new selectOption('', '- None -'));
	    for(pse__Proj__c p :[
	        SELECT
	            Id,
	            Name
	        FROM
	            pse__Proj__c
	        WHERE
	            pse__Account__r.id = :accountIDSet
	        ORDER BY
	            Name asc
	    ]) {
	        //add it to the map:
	        projOptions.add(new SelectOption(p.id, p.Name));
	    }
	    return projOptions;
	}
  
    public PageReference backToBC(){
        PageReference ref = new PageReference('/'+billingContract.Id); 
        return ref; 
    }

    public pageReference openCreateProjPage() 
    {

        pageReference pg = new pageReference('https://pse.cs21.visual.force.com/apex/CreateProjectFromOpportunity?scontrolCaching=1&id='+billingContract.Opportunity__c);
        pg.setRedirect(true);
        return pg;
    }      



    public void createPSAMilestone()
    {
        List<activityLineModel> checkedActLines = new List<activityLineModel>();
        Map<Id,pse__Milestone__c> msInsertMap = new Map<Id,pse__Milestone__c>();
        List<pse__Budget__c> budgetInsertList = new List<pse__Budget__c>();
        List<Activity_Line_Item__c> aliUpdateList = new List<Activity_Line_Item__c>();
        String budgetName ='';
        Decimal totalAmount = 0;
        if(projectID == null){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Project Selected!'));   
           return;
        }
        for(activityLineModel actModel :activitylineItems ){
            if(actModel.check == true){
                checkedActLines.add(actModel);
                totalAmount += actModel.ali_object.Contract_Amount__c;
            }
        }
        if(checkedActLines.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'No Activity Lines Selected!'));   
            return;
        }
        for(activityLineModel actModel :checkedActLines ){
            pse__Milestone__c ms = new pse__Milestone__c(
                pse__Project__c = projectID,
                Activity_Line_Item__c = actModel.ali_object.id,
                pse__Audit_Notes__c = 'Created from Activity Line Item '+actModel.ali_object.Name +'by '+Userinfo.getName(),
                pse__Admin_Global_Edit__c = true,
                pse__Exclude_from_Billing__c = !actModel.ali_object.Payment_Terms__r.Billed_through_PSA__c,
                Name = actModel.msName,
                pse__Target_Date__c = Date.newInstance(2025, 12, 31),
                pse__Milestone_Amount__c = actModel.ali_object.Contract_Total_Amount__c,
                Milestone_Type__c = 'Billable Milestone',
                pse__Override_Project_Practice__c = actModel.ali_object.Product_Package_Item__r.Practice__c);
            msInsertMap.put(ms.Activity_Line_Item__c, ms); 
            budgetName = actModel.ali_object.Billing_Contract__r.Opportunity__r.Name + ' - Budget';
        }
        /*pse__Budget__c budget = new pse__Budget__c(
                Name = budgetName,
                pse__Project__c = projectID,
                pse__Account__c = billingContract.Account__c,
                pse__Amount__c = totalAmount,
                pse__Status__c = 'Approved',
                pse__Approved__c = true,
                pse__Include_In_Financials__c = true);
            budgetInsertList.add(budget);*/
        try{
            insert msInsertMap.values();
            //insert budgetInsertList;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Milestone and Budgets saved successfully!'));  
        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
        }      
        for(activityLineModel actModel :checkedActLines ){
            actModel.ali_object.PSA_Milestone__c = msInsertMap.containsKey(actModel.ali_object.id) && msInsertMap.get(actModel.ali_object.id).id != null ? msInsertMap.get(actModel.ali_object.id).id : null;
            aliUpdateList.add(actModel.ali_object);
            if(actModel.ali_object.PSA_Milestone__c != null){
                actModel.check = false;
                actModel.disabled = true;
            }
        }
        try{
            update aliUpdateList;
        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
        }      
    }

    public class activityLineModel{
        public Activity_Line_Item__c ali_object {get;set;}
        public pse__Milestone__c ms_object {get;set;}
        public boolean check {get;set;}
        public boolean disabled {get;set;}
        public String msName {get;set;}
        public activityLineModel(){
            ali_object = new Activity_Line_Item__c();
            check = true;
            disabled = false;
        }
    }

}