/****************************************************************************************
Name            : NI_Milestone_Forecast_BeforeUpdate Trigger
Author          : Stuart Emery
Created Date    : 4/24/2014
Last Mod Date   : 4/24/2014
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Before Update Trigger that calls the OnBeforeUpdate methods in the 
                : NI_MilestoneForecast_TriggerHandler Class
                : 
******************************************************************************************/
trigger NI_Milestone_Forecast_BeforeUpdate on Milestone_Forecast__c (before update) 
{

    NI_MilestoneForecast_TriggerHandler handler = new NI_MilestoneForecast_TriggerHandler(true);

        handler.OnBeforeUpdate(Trigger.new,Trigger.oldMap);
    
}