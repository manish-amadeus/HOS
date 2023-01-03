/****************************************************************************************
Name            : AH_Utilization_Engine_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 10/19/2018
Last Mod Date   : 10/19/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : 
                :
                :
******************************************************************************************/
trigger AH_Utilization_Engine_AfterInsert on pse__Utilization_Engine__c (after insert) 
{
    AH_UtilizationEngine_TriggerHandler handler = new AH_UtilizationEngine_TriggerHandler();
    handler.OnAfterInsert(Trigger.new, Trigger.oldMap);
}