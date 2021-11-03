/*=======================================================================================
Name            : ffaActivityLineItemCloneController
Author          : CLD
Created Date    : 1/23/17
Description     : Controller for ALI Clone Page
=======================================================================================*/

public with sharing class ffaActivityLineItemCloneController {
	//public List<bliWrapper> wrapperList {get; set;}
	public Boolean recreateBillingLines {get; set;}
	public Boolean deleteExistingBillingLines {get; set;}
	public Boolean disableNewLinkButton {get; set;}
	public Activity_Line_Item__c clonedAli {get; set;}
	public Activity_Line_Item__c activityLine {get; set;}

	public ffaActivityLineItemCloneController(ApexPages.StandardController controller) {
		this.activityLine = (Activity_Line_Item__c)controller.getRecord(); 
		recreateBillingLines = true;
		deleteExistingBillingLines = false;
		disableNewLinkButton = true;
		fetchData();
	}

	public void fetchData(){
		activityLine = [
        	SELECT
        		Name,
	        	ACTION_Rebuild_Billing_Lines__c,
				Account_Name__c,
				Activation_Date__c,
				Activation_Required__c,
				Activity_Project_Billing__c,
				Adjusted_Revenue_Amount__c,
				Attn_to_Contact__c,
				Auto_Renewal__c,
				Billing_Contract__c,
				Billing_Renewal_Lead_Time_Days__c,
				Contract_Amount__c,
				Contract_End_Date__c,
				Contract_Start_Date__c,
				Contract_Total_Amount__c,
				Deferred_Rev_Balance__c,
				Deferred_Revenue_GLA__c,
				Delivery_Complete__c,
				Delivery_Offset_Months__c,
				Deployment_Instance__c,
				Fair_Value__c,
				Final_SW_Group_Allocation__c,
				Fulfillment_Complete__c,
				Fulfillment_Date__c,
				Fulfillment_Notes__c,
				Fulfillment_Required__c,
				Group__c,
				Include_in_Revenue_Recognition__c,
				List_Price__c,
				Milestone_Name_Prefix__c,
				Milestone_Revenue_Rollup__c,
				Milestone_Rollup_Amount__c,
				No_Price_Increase_Through__c,
				Opp_Product_ID__c,
				Opportunity__c,
				Origin__c,
				PCS_Days__c,
				PCS_Notes__c,
				PSA_Milestone__c,
				Payment_Terms__c,
				Percent_of_Total__c,
				Post_Contract_Support__c,
				Previous_ALI__c,
				Pro_Rated_Date__c,
				Pro_Rated__c,
				Product_Description__c,
				Product_Package_Item__c,
				Product_Package__c,
				Product__c,
				Relative_Selling_Price_Allocation__c,
				Renewal_Base_Price__c,
				Renewal_Comments_Additional__c,
				Renewal_Comments__c,
				Renewal_Date__c,
				Renewal_Increase_Amount__c,
				Renewal_Notification_Sent__c,
				Renewal_Pricebook__c,
				Renewal_Processed__c,
				Revenue_Category__c,
				Revenue_Position__c,
				Revenue_Recognition_GLA__c,
				Revenue_Recognized_to_Date__c,
				SKU__c,
				Send_Customer_Renewal_Notice__c,
				Service_Discount__c,
// SOFTRAX ASSET REMOVAL:	Softrax_Asset__c,
				Softrax_Renewal_Record_ID__c,
				Software_Discount__c,
				Status__c,
				Suspend_Revenue_Recognition_Notes__c,
				Suspend_Revenue_Recognition_Reason__c,
				Suspend_Revenue_Recognition__c,
				Total_Delivered_Service_Amount__c,
				Total_Invoiced_to_Date__c,
				Total_Revenue_to_Recognize__c,
				Trans_Billing_Dollars_Delivered__c,
				Trans_Billing_Percent_Complete__c,
				Unbilled_AR_Balance__c,
				Units__c,
				VSOE_Adjustment__c,
				VSOE_Calculation_Status__c,
				VSOE_Discount__c,
				VSOE_Element_Type__c,
				VSOE_Pricing_Item__c,
				ffrrtemplate__c
        	FROM Activity_Line_Item__c
        	WHERE id = :activityLine.id];
	}

	public PageReference backToBC(){
        PageReference ref = new PageReference('/'+activityLine.Id); 
        return ref; 
    }
    public PageReference goToNewALI(){
        PageReference ref = new PageReference('/'+clonedAli.Id); 
        return ref; 
    }

	public void processClone()
	{
		Try{
			cloneALI(activityLine);
			if(recreateBillingLines == true){
				recalcBillingLines(clonedAli);
			}
			disableNewLinkButton = false;
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Clone Successful!'));
		}
		Catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
			system.debug('\n*****\n Error: ffaActivityLineItemCloneController - processClone : ' + e.getMessage());
		}
	}

    /*=======================================================================================
    Helper Methods:
    =======================================================================================*/
    public void cloneALI(Activity_Line_Item__c oldALI){
    	clonedAli = oldALI.clone(false,true,false,false);
		clonedAli.Revenue_Recognized_to_Date__c = 0;
		clonedAli.Units__c = oldALI.Units__c;
		clonedAli.Contract_Amount__c = oldALI.Contract_Amount__c;
		clonedAli.List_Price__c = oldALI.Contract_Amount__c;
		clonedAli.Renewal_Base_Price__c = oldALI.Contract_Amount__c;
		clonedAli.Contract_Start_Date__c = oldALI.Contract_Start_Date__c;
		clonedAli.Contract_End_Date__c = oldALI.Contract_End_Date__c;
		clonedAli.Activation_Date__c = oldALI.Activation_Date__c;
		clonedAli.Payment_Terms__c = oldALI.Payment_Terms__c;
		clonedAli.Origin__c = 'Clone';
		clonedAli.Previous_ALI__c = oldALI.id;
		clonedAli.Origin__c = 'Clone';
		insert clonedAli;
    }
    public void recalcBillingLines(Activity_Line_Item__c newAli){
    	List<Activity_Line_Item__c> aliList = new List<Activity_Line_Item__c>{newAli};
    	List<Billing_Contract_Line_Item__c> bcliList = billingContractHandler.recalcBillingLines(aliList, false);
    	insert bcliList;
    }
}