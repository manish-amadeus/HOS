/****************************************************************************************
Name            : NI_UpdateOpportunityLineItem
Author          : Suzanne LeDuc
Created Date    : 5/15/2014 
Last Mod Date   : 7/22/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010386
Description     : After Update Trigger
                : Automated Service Order Class
                : 
******************************************************************************************/

trigger NI_UpdateOpportunityLineItem on CHANNEL_ORDERS__Service_Order__c (after update) {
    
  //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI SERVICE ORDER'))
       {
         NI_ServiceOrderTriggerHandler.handleServiceOrderProvision(Trigger.old, Trigger.new);  
       }  
}