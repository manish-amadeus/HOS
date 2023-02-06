/****************************************************************************************
Name            : AH_SCIM_UserSyncCallout_Schedule
Author          : Ganesh Bora
Created Date    : 02/02/2022
Modified Date	: 02/02/2022
Last Mod By     : Ganesh Bora
NICC Reference  : NICC-056411
Description     : To schedule Valamis SCIM User Synchronization batch
				:
Scheduling Commands:
System.schedule('SCIM Scheduler 1',  '0 00 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
System.schedule('SCIM Scheduler 2',  '0 15 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
System.schedule('SCIM Scheduler 3',  '0 30 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
System.schedule('SCIM Scheduler 4',  '0 45 * * * ?', new AH_SCIM_UserSyncCallout_Schedule());
******************************************************************************************/
global class AH_SCIM_UserSyncCallout_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        AH_SCIM_UserSyncCallout_Batch batchable = new AH_SCIM_UserSyncCallout_Batch();
        Database.executeBatch(batchable, 10);
        system.debug('Schedule class execution completed...');
    }
}