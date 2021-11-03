/****************************************************************************************
Name            : AH_OpportunityLineItem_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 06/02/2015
Last Mod Date   : 05/30/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_OpportunityLineItem_AfterInsert on OpportunityLineItem (after insert) 
{
    // GLOBAL SWITCHES FOR CONTROLLING EXECUTION BASED ON WHAT OBJECT TRIGGER IS INVOKED 
    NI_TriggerManager.isOpptyLineItemInvoked = true; 
    NI_TriggerManager.isOpportunityInvoked = false; 
    AH_OpportunityLineItemTriggerHandler handler = new AH_OpportunityLineItemTriggerHandler(); 
    handler.onAfterInsert(Trigger.new); 
}