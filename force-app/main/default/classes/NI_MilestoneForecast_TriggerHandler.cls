/****************************************************************************************
Name            : NI_MilestoneForecast_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 5/1/2014
Last Mod Date   : 5/7/2014 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-010123
Description     : Class that handles all trigger code for the Milestone_Forecast__c Object
                : 
******************************************************************************************/
public with sharing class NI_MilestoneForecast_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NI_MilestoneForecast_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    
    public void OnBeforeInsert(List<Milestone_Forecast__c> newTrigger)
    {
        //SEE IF THE BY_PASS SWITCH IS SET TO TRUE IN THE CUSTOM SETTING.  
          if (!NI_FUNCTIONS.bypassTriggerCode('NI MILESTONE FORECAST'))
            {   
              List<Milestone_Forecast__c> lstHasForecastDate = new List<Milestone_Forecast__c>();
              for(Milestone_Forecast__c m : newTrigger)
                 {
                   if(m.Forecast_Date__c != null)
                     {
                       lstHasForecastDate.add(m);
                     }
                 }
             //CALL THE METHOD TO UPDATE THE FORECAST PERIOD
               UpdateForecastPeriod(lstHasForecastDate);  
            }
     }  
    
    public void OnBeforeUpdate(List<Milestone_Forecast__c> newTrigger, Map<Id,Milestone_Forecast__c> oldMapTrigger)
    {
      //SEE IF THE BY_PASS SWITCH IS SET TO TRUE IN THE CUSTOM SETTING.  
          if (!NI_FUNCTIONS.bypassTriggerCode('NI MILESTONE FORECAST'))
            {  
              List<Milestone_Forecast__c> lstHasForecastDate = new List<Milestone_Forecast__c>();
              for(Milestone_Forecast__c m : newTrigger)
                 {
                    if(m.Forecast_Date__c != oldMapTrigger.get(m.Id).Forecast_Date__c )
                     {
                       lstHasForecastDate.add(m);
                     }
                 }
             //CALL THE METHOD TO UPDATE THE FORECAST PERIOD
               UpdateForecastPeriod(lstHasForecastDate);
            }     
    }

//=====================================================================================================
    public void UpdateForecastPeriod(List<Milestone_Forecast__c> newTrigger)
    {
        List<Milestone_Forecast__c> lstForecastsToUpdate = new List<Milestone_Forecast__c>();
        for(Milestone_Forecast__c m : newTrigger)
            {
              lstforecastsToUpdate.add(m);
            }
    
        if(lstForecastsToUpdate.size() > 0)
          {
            //GET A LIST OF ALL MONTH TIME PERIODS
              List<pse__Time_Period__c> timePeriods = new List<pse__Time_Period__c>([
              SELECT Name, pse__Start_Date__c, pse__End_Date__c
              FROM pse__Time_Period__c 
              WHERE pse__Type__c = 'Month']);
        
              for(Milestone_Forecast__c forecast : lstForecastsToUpdate)
                 {
                   Date forecastDate = forecast.Forecast_Date__c;
                   if(forecastDate==null)
                     {
                      //IF THE FORECAST HAS NOT DATE, MAKE SURE IT DOESN'T HAVE A FORECAST PERIOD
                        forecast.Forecast_Period__c = null;
                     }
                else
                     {
                       boolean foundMatchingPeriod = false;
                       for(pse__Time_Period__c tp : timePeriods)
                          {
                           // Iterate through the month periods to find the one matching the forecast date
                           // and set the time period name as the forecast period
                           if(forecastDate >= tp.pse__Start_Date__c && forecastDate <= tp.pse__End_Date__c)
                             {
                               forecast.Forecast_Period__c = tp.Name;
                               foundMatchingPeriod=true;
                             }
                          }
                
                // If there was no matching time period, make sure the forecast period
                // is empty. (e.g., Forecast date was set to sometime in year 2025)
                if(!foundMatchingPeriod)
                {
                    forecast.Forecast_Period__c = null;
                }
            }
        }
    }
  }  
}