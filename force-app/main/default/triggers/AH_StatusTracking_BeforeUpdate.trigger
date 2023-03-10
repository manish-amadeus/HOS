/****************************************************************************************
Name            : AH_StatusTracking_BeforeInsert Trigger
Author          : Bhagwat Garkal
Created Date    : 22/03/2022
Last Mod Date   : 22/03/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Call the Before Insert Methods in the AH_Status_Tracking_BeforeInsert Class
                : 
                : 
******************************************************************************************/
trigger AH_StatusTracking_BeforeUpdate on Status_Tracking__c(Before update) 
{
    AH_StatusTracking_TriggerHandler statusTrackHandler = new AH_StatusTracking_TriggerHandler();
    if(Trigger.IsUpdate && Trigger.IsBefore)
    {
       statusTrackHandler.OnBeforeUpdate(Trigger.new);
    }
}