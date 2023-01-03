/****************************************************************************************
Name            : AH_Statement_Sched
Author          : Shashikant Nikam
Created Date    : 11/17/2020
Modified Date   : 11/19/2020
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Schedulable class to update the "Statement Eligible" checkbox to TRUE on Product Package object.
                :
                :
******************************************************************************************/

global class AH_Statement_Schedule implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        // BATCH CLASS 
        AH_Statement_Batch batchable = new AH_Statement_Batch();
        Database.executeBatch(batchable, 1); 
        system.debug('Schedule class execution completed...');
    }
}