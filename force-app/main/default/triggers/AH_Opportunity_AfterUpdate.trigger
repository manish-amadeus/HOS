/****************************************************************************************
Name            : AH_Opportunity_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 06/12/2019
Last Mod Date   : 06/12/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_Opportunity_AfterUpdate on Opportunity (after update) 
{
    NI_TriggerManager.isOpportunityInvoked = true;
    NI_TriggerManager.isOpptyLineItemInvoked = false;             
    AH_Opportunity_TriggerHandler handler = new AH_Opportunity_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}