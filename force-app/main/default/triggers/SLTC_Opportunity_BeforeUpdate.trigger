/**********************************************************
*************************************
Name :   SLTC_Opportunity_BeforeUpdate
Author : Jaswanth R
Created Date : 5/05/2022
Last Mod Date :  5/14/2022
Last Mod By : Jaswanth R
NICC Reference : 
Description :Trigger on Opportunity before Update
***********************************************************
*************************************/
trigger SLTC_Opportunity_BeforeUpdate on Opportunity (before update) {
if(trigger.isBefore)
{
    SLTC_Opportunity_TriggerHandler triggerHandler =new SLTC_Opportunity_TriggerHandler();
    triggerHandler.onBeforeUpdate(trigger.new);
}
}