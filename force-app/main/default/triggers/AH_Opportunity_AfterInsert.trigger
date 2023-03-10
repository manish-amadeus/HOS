/****************************************************************************************
Name            : AH_Opportunity_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 06/12/2019
Last Mod Date   : 06/12/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_Opportunity_AfterInsert on Opportunity (after insert) 
{
    // GLOBAL SWITCHES FOR CONTROLLING EXECUTION BASED ON WHAT OBJECT TRIGGER IS INVOKED
    NI_TriggerManager.isOpportunityInvoked = true;
    NI_TriggerManager.isOpptyLineItemInvoked = false;     
    AH_Opportunity_TriggerHandler handler = new AH_Opportunity_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
}