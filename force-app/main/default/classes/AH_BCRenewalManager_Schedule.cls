/****************************************************************************************
Name            : AH_BCRenewalManager_Schedule
Author          : Ria Chawla
Created Date    : 04/02/2018
Modified Date	: 08/01/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : To schedule Renewal process of those activity line items that older than yerterday
				:
******************************************************************************************/
global class AH_BCRenewalManager_Schedule implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        AH_BCRenewalManager_Batch batchable = new AH_BCRenewalManager_Batch();
        Database.executeBatch(batchable, 10);
        system.debug('Schedule class execution completed...');
    }
}