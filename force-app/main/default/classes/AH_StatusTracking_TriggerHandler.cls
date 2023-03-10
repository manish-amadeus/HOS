/****************************************************************************************
Name            : AH_StatusTracking_TriggerHandler Class
Author          : Bhagwat Garkal
Created Date    : 22/03/2022
Last Mod Date   : 22/03/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : AH_StatusTracking_TriggerHandler Class
                : 
                : 
******************************************************************************************/

public class AH_StatusTracking_TriggerHandler {
    
    Public void OnBeforeUpdate(List<Status_Tracking__c> lstOfStatusTrackRecord)
    {
        try
        {
            if(!lstOfStatusTrackRecord.isEmpty())
            {
                //Get BusinessHours
                BusinessHours businessHourId = new BusinessHours();
                If(Test.isRunningTest())
                {
                	 businessHourId = [select Id,Name from BusinessHours limit 1];    
                }
                else
                {
                	 businessHourId = [select Id,Name from BusinessHours where Name = 'Status Tracking' and IsActive = true];    
                }
                
                for(Status_Tracking__c st : lstOfStatusTrackRecord)
                {
                    if(st.Enter_Time__c != null && st.Exit_Time__c != null && businessHourId != null)
                    {
                        // Exit Time should not be less than Enter Time
                        if(st.Exit_Time__c < st.Enter_Time__c)
                        {
                        	st.Exit_Time__c.addError('Exit Time should not be less than Enter Time');    
                        }
                        else
                        {
                        	//Get the difference between start and end Date.
                            Decimal hoursdiff = BusinessHours.diff(businessHourId.Id, st.Enter_Time__c, st.Exit_Time__c);
                            System.debug('BusinessHours==>'+hoursdiff);
                            
                            // Calculate Hours
                            st.Time_Elapsed_Hours_24hr_day__c = hoursdiff/3600000;    
                        }
                    }    
                }
            }
        }
        catch(Exception e)
        {
        	System.debug('The following exception has occurred: ' + e.getMessage());    
        }    
    }
}