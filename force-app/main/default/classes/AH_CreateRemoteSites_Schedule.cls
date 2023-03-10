/****************************************************************************************
Name            : AH_CreateRemoteSites_Schedule
Author          : Shashikant Nikam
Created Date    : 4/20/2019
Modified Date	: 5/7/2019
Last Mod By     : Stuart Emery
NICC Reference  : NICC-034473
Description     : This class schedules AH_CreateRemoteSites_Batch batch class
				:
				:
******************************************************************************************/

global class AH_CreateRemoteSites_Schedule implements Schedulable 
{
    global void execute(SchedulableContext sc)
    {
        AH_CreateRemoteSites_Batch bc = new AH_CreateRemoteSites_Batch();
        Database.executeBatch(bc, 1);
        system.debug('Schedule class execution completed...');
    }
}