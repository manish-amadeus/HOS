/****************************************************************************************
Name            : AIP_GDSMonthlyRevenueAfterInsert Trigger
Author          : Stuart Emery
Created Date    : 1/16/2015
Last Mod Date   : 1/16/2015
Last Mod By     : Stuart Emery
NICC Reference  : NICC-012537
Description     : Handles After Insert Trigger Logic for the AIP_GDS_Monthly_Revenue__c object
                : 
                : 
******************************************************************************************/
trigger AIP_GDSMonthlyRevenueAfterInsert on AIP_GDS_Monthly_Revenue__c (after insert) 
{
  //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('GDS MONTHLY REVENUE'))
        {
          AIP_GDS_Monthly_Revenue_TriggerHandler handler = new AIP_GDS_Monthly_Revenue_TriggerHandler();
          handler.OnAfterInsert(Trigger.new);
        }       
}