/****************************************************************************************
Name            : AH_OpportunityLineItem_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 06/02/2015
Last Mod Date   : 05/30/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_OpportunityLineItem_AfterUpdate on OpportunityLineItem (after update) 
{
    // GLOBAL SWITCHES FOR CONTROLLING EXECUTION BASED ON WHAT OBJECT TRIGGER IS INVOKED
    NI_TriggerManager.isOpptyLineItemInvoked = true; 
    NI_TriggerManager.isOpportunityInvoked = false;     
    AH_OpportunityLineItemTriggerHandler handler = new AH_OpportunityLineItemTriggerHandler();    
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}