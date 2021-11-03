/****************************************************************************************
Name            : AH_FetchTrialExpiration Class
Author          : Shashikant Nikam
Created Date    : 10/27/2017
Last Mod Date   : 04/23/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-025235
Description     : Apex class to schedule AH_FetchTrailExpirationBatch class.
                : NICC-034313 - Updated API version
******************************************************************************************/
global class AH_FetchTrialExpiration implements Schedulable 
{
    
     public void execute(SchedulableContext sc) 
     {
         
        system.debug(' ***  ENTERING AH_FetchTrialExpiration.execute() - QUERIES ISSUED = ' + Limits.getQueries());
		
        AH_FetchTrialExpirationBatch batch = new AH_FetchTrialExpirationBatch();
        Database.executeBatch(batch, 1);
         
        system.debug(' ***  EXITING AH_FetchTrialExpiration.execute() - QUERIES ISSUED = ' + Limits.getQueries());
		
     }
    
}