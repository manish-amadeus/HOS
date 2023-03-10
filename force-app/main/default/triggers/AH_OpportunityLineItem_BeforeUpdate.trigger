/****************************************************************************************
Name            : AH_OpportunityLineItem_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 06/02/2015
Last Mod Date   : 05/30/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger AH_OpportunityLineItem_BeforeUpdate on OpportunityLineItem (before update) 
{
    AH_OpportunityLineItemTriggerHandler handler = new AH_OpportunityLineItemTriggerHandler();    
    handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
}