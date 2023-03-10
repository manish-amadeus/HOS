/************************************************************************************************
Name            : AH_ProjectIntake_Schedule Class
Author          : Sean Harris
Created Date    : 10/12/2020
Last Mod Date   : 10/12/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047197
Description     : Schedulable class for the AH_ProjectIntake_Batch class
                : 
*************************************************************************************************/
global class AH_ProjectIntake_Schedule implements Schedulable 
{
    
    global void execute(SchedulableContext sc)
    {
        system.debug(' **$** AH_ProjectIntake_Schedule.execute');  
        Database.executeBatch(new AH_ProjectIntake_Batch());
    }
    
}