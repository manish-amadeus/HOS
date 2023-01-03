/****************************************************************************************
Name            : AH_Resource_Planner_Overbook_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 10/19/2018
Last Mod Date   : 10/19/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : 
                :
                :
******************************************************************************************/
trigger AH_Resource_Planner_Overbook_AfterInsert on AH_Resource_Planner_Overbooking__c (after insert) 
{

    AH_RsrcPlan_Overbook_TriggerHandler handler = new AH_RsrcPlan_Overbook_TriggerHandler();
    handler.OnAfterInsert(Trigger.new, Trigger.oldMap);
    
}