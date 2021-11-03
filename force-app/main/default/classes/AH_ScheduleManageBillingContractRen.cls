/****************************************************************************************
Name            : AH_ScheduleManageBillingContractRen
Author          : Ria Chawla
Created Date    : 04/02/2018
Modified Date	: 09/13/20118
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : To schedule Renewal process of those activity line items that older than yerterday
				:
******************************************************************************************/
global class AH_ScheduleManageBillingContractRen implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        AH_BatchManageBillingContractRen batchable = new AH_BatchManageBillingContractRen();
        Database.executeBatch(batchable, 10);
        system.debug('Schedule class execution completed...');
    }
}