/***********************************************************************************************
Name            : AH_Account_Product_AfterUpdate
Author          : Ria Chawla
Created Date    : 04/16/2018
Last Mod Date   : 05/30/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Call the After Update Methods in the AH_Account_Product_TriggerHandler Class
				:
************************************************************************************************/
trigger AH_Account_Product_AfterUpdate on AH_Account_Product__c (after update) 
{
    AH_Account_Product_TriggerHandler handler = new AH_Account_Product_TriggerHandler();
    handler.onAfterUpdate(Trigger.new);
}