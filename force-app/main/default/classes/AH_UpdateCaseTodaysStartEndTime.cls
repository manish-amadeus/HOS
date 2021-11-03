/****************************************************************************************
Name            : AH_UpdateCaseTodaysStartEndTime Class
Author          : Shashikant Nikam
Created Date    : 01/30/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Apex class to schedule AH_BatchUpdateCaseTodaysStartEndTime class.
                :
******************************************************************************************/
global class AH_UpdateCaseTodaysStartEndTime implements Schedulable 
{
     
     global void execute(SchedulableContext sc) 
     {

        AH_BatchUpdateCaseTodaysStartEndTime batch = new AH_BatchUpdateCaseTodaysStartEndTime();
         
        if (!test.isRunningTest() && !NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
        {
            Database.executeBatch(batch, 1);
        }

        if (test.isRunningTest())
        {
            Database.executeBatch(batch, 50); 
        }
        	
     }
    
}