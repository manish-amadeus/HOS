/****************************************************************************************
Name            : NI_Scheduled_DIHistory_Test
Author          : Sean Harris
Created Date    : 7/28/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-010621 - Product Group Consolidation Data Project 
Description     : If any of the following fields on Asset is changed:
                :     Name, Annual_Subscription_Amount__c, Cendyn_Location_ID__c, InstallDate, IsHostedDI__c, 
				:     MeetingMatrix_Product_Key__c, Product2Id, PurchaseDate, Quantity_Billed__c, Quantity_Ordered__c, 
				:     Quantity_Provisioned__c, Ship_Date__c, Status, UsageEndDate, Product_Group__c, Product_Line__c, Version__c
                : the WriteHistory__c field gets set to true.
				: The class writes a NI_Deployment_Instance_History__c record for every record flagged then unflags them.
				: 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NI_Scheduled_DIHistory_Test
{

    public static testMethod void testScheduled_DIHistory() 
    {
        NI_Scheduled_DIHistory.scheduleIt('0 0 * * * ?');   
    }

}