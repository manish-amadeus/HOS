/****************************************************************************************
Name            : billingContractLineWrapper Class
Author          : CLD
Created Date    : 12/13/2015
Last Mod Date   : 04/23/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Wrapper Class to hold both Billing and Activity Line Items
                : 
                : 
******************************************************************************************/
public class billingContractLineWrapper 
{
    
	public List<Billing_Contract_Line_Item__c> billingLineList;
	public List<Activity_Line_Item__c> activityLineList;

	public void billingContractLineWrapper()
    {
		billingLineList = new List<Billing_Contract_Line_Item__c>();
		activityLineList = new List<Activity_Line_Item__c>();
	}
    
}