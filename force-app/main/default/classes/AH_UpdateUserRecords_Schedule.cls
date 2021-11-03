/************************************************************************************************
Name            : AH_UpdateUserRecords_Schedule Class
Author          : Stuart Emery
Created Date    : 03/25/2019
Last Mod Date   : 01/03/2020 
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : NICC-039914
Description     : 
                : 
*************************************************************************************************/
global class AH_UpdateUserRecords_Schedule implements Schedulable 
{
    
    global void execute(SchedulableContext sc)
    {
        AH_UpdateUserRecords_Batch batchable = new AH_UpdateUserRecords_Batch();
        Database.executeBatch(batchable, 100);
        system.debug('Schedule class execution completed...');
    }

}