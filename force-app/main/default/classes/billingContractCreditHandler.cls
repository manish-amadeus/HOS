/****************************************************************************************
Name            : billingContractCreditHandler
Author          : CLD
Created Date    : April 19, 2016
Description     : Contains various methods for interacting with Billing Contracts
Open Items:
******************************************************************************************/

public class billingContractCreditHandler {
	
	/****************************************************************************************
	Method to Process Renewals for Activity Lines
	****************************************************************************************/
	public static void processBCCredits (List<billingContractCreditController.bliWrapper> wrapperList)
	{
		List<Billing_Contract_Line_Item__c> bliInsertList = new List<Billing_Contract_Line_Item__c>();
		List<Billing_Contract_Line_Item__c> bliUpdateList = new List<Billing_Contract_Line_Item__c>();

		
		//======STEP 1: CLONE THE BILLING LINES SELECTED.
		for(billingContractCreditController.bliWrapper wrapper : wrapperList)
		{
			Billing_Contract_Line_Item__c newBLI = wrapper.bliObject.clone(false,true,false,false);
			newBLI.Quantity__c = wrapper.dummy_bliObject.Quantity__c;
			newBLI.Unit_Price__c = wrapper.dummy_bliObject.Unit_Price__c;
			newBLI.Total_Amount__c = (newBLI.Quantity__c * newBLI.Unit_Price__c).setScale(2);
			newBLI.Payment_Terms__c = wrapper.dummy_bliObject.Payment_Terms__c;
			newBLI.Line_Item_Description__c = 'CREDIT - ' + newBLI.Line_Item_Description__c;
			newBLI.Invoiced__c = false;

			bliInsertList.add(newBLI);
			bliUpdateList.add(wrapper.bliObject);
		}
		insert bliInsertList;

		
		//======STEP 3: UPDATE ANY BILLING LINES THAT HAVE BEEN CREDITED SO THE CAN BE 
		for(Billing_Contract_Line_Item__c bli : bliUpdateList){
			bli.Credit_Processed__c = true;
		}
		update bliUpdateList;
	}
}