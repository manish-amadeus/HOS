/***********************************************************************************************
Name            : AH_Account_Product_AfterDelete
Author          : Ria Chawla
Created Date    : 04/16/2018
Last Mod Date   : 05/30/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Call the After Delete Methods in the AH_Account_Product_TriggerHandler Class
				:
************************************************************************************************/
trigger AH_Account_Product_AfterDelete on AH_Account_Product__c (after delete) 
{
    AH_Account_Product_TriggerHandler handler = new AH_Account_Product_TriggerHandler();
    handler.onAfterDelete(Trigger.old);
}