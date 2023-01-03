/**************************************************************************************
// Name          : billingContractCreditController
// Date          : 4/19/16
// Description   : Controller for the cancellation page
// Author        : CLD Partners
***************************************************************************************/

public class billingContractCreditController {
	public List<bliWrapper> wrapperList {get; set;}
	public Billing_Contract_Line_Item__c dummyLine {get; set;}
	public Boolean isAllChecked {get; set;}
	public Billing_Contract__c billingContract {get; set;}
	public id billingContractid {get; set;}

	public billingContractCreditController(ApexPages.StandardController controller) {
		dummyLine = new Billing_Contract_Line_Item__c();
		this.billingContract = (Billing_Contract__c)controller.getRecord(); 
		fetchData();
	}

	public void fetchData(){
		wrapperList = new List<bliWrapper>();
		for(Billing_Contract_Line_Item__c billLine : [
        	SELECT
	        	Activation_Date__c,
				Activation_Required__c,
				Activity_Line_Item__c,
				Auto_Renew__c,
				Auto_Renewal__c,
				Billing_Contract__c,
				Billing_Notification_Date__c,
				Cancelled__c,
				Credit_Processed__c,
				Deployment_Instance__c,
				Dimension_2__c,
				Dimension_3__c,
				End_Date__c,
				FFA_Currency__c,
				Invoice_Date__c,
				Invoiced__c,
				Line_Item_Description__c,
				Opp_Line_Item_ID__c,
				Opportunity__c,
				Payment_Status__c,
				Payment_Term_Line_Item__c,
				Payment_Terms__c,
				Pro_Rated__c,
				Product_Package_Item__c,
				Product_Package__c,
				Product__c,
				Product__r.Name,
				Quantity__c,
				Ready_for_Annual_Invoice__c,
				Ready_to_Credit__c,
				Ready_to_Invoice__c,
				Renewal_Quantity__c,
				Revenue_Category__c,
				SKU__c,
				Sales_Invoice_Line_Item__c,
				Split_Order__c,
				Start_Date__c,
				Status__c,
				Total_Amount__c,
				Type__c,
				Unit_Price__c
        	FROM Billing_Contract_Line_Item__c
        	WHERE Billing_Contract__c = :billingContract.id
        	AND Type__c = 'Invoice'
        	AND Invoiced__c = true])
    	{
    		bliWrapper wrapper = new bliWrapper();
    		wrapper.bliObject = billLine;
    		wrapper.dummy_bliObject.Quantity__c = billLine.Quantity__c;
    		wrapper.dummy_bliObject.Unit_Price__c = (billLine.Unit_Price__c)*-1;
    		wrapper.check = false;
    		wrapper.disabled = billLine.Credit_Processed__c;
    		wrapperList.add(wrapper);
    	}
	}

	public PageReference backToBC(){
        PageReference ref = new PageReference('/'+billingContract.Id); 
        return ref; 
    }

	public void processCredit()
	{
		List<bliWrapper> creditList = new List<bliWrapper>();
		for(bliWrapper wrapper : wrapperList){
			if(wrapper.check == true){
				creditList.add(wrapper);
				if(wrapper.dummy_bliObject.Unit_Price__c > 0){
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Attention: you must enter a negative amount!')); 
					return;
				}
			}
		}

		Try{
			billingContractCreditHandler.processBCCredits(creditList);
			for(bliWrapper wrapper : wrapperList){
				if(wrapper.check == true){
					wrapper.check = false;
					wrapper.disabled = true;
				}
			}
			fetchData();
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Credit Successful!'));
		}
		Catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage() + '\n Line: '+e.getLineNumber() +'\n Cause:'+e.getCause())); 
		}
	}

	public class bliWrapper{
        public Billing_Contract_Line_Item__c bliObject {get;set;}
        public Billing_Contract_Line_Item__c dummy_bliObject {get;set;}
        public boolean check {get;set;}
        public boolean disabled {get;set;}
        public Renewal_Pricing_Entry__c rpe {get;set;}
        public decimal renewalAmount {get;set;}
        public bliWrapper(){
            bliObject = new Billing_Contract_Line_Item__c();
            dummy_bliObject = new Billing_Contract_Line_Item__c();
            check = false;
        }
    }
}