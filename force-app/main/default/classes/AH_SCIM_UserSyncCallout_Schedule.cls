/****************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Schedule
Author          : Ganesh Bora
Created Date    : 02/02/2022
Modified Date	: 02/02/2022
Last Mod By     : Ganesh Bora
NICC Reference  : 
Description     : To schedule Valamis SCIM User Synchronization batch
				:
******************************************************************************************/
global class AH_SCIM_UserSyncCallout_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        AH_SCIM_UserSyncCallout_Batch batchable = new AH_SCIM_UserSyncCallout_Batch();
        Database.executeBatch(batchable, 10);
        system.debug('Schedule class execution completed...');
    }
}