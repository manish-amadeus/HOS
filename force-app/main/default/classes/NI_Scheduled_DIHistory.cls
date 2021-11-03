/************************************************************************************************************************
Name            : NI_Scheduled_DIHistory Schedulable Class
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
*************************************************************************************************************************/
global class NI_Scheduled_DIHistory Implements Schedulable
{
    
    // RUN NI_Scheduled_DIHistory.scheduleIt(); IN DEV CONSOLE TO CREATE SCHEDULED APEX JOB
    global static String scheduleIt(String CRON_EXP) 
    {
        NI_Scheduled_DIHistory sched = new NI_Scheduled_DIHistory();
        return System.schedule('Insert Deployment Instance History', CRON_EXP, sched);
    }    
    
    global void execute(SchedulableContext sc)
    {
        NI_Scheduled_DIHistory_Batch b = new NI_Scheduled_DIHistory_Batch();
        ID batchprocessid = Database.executeBatch(b); 
    }

}