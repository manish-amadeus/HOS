/***********************************************************************************************
Name            : AH_Account_Product_AfterInsert
Author          : Ria Chawla
Created Date    : 04/27/2018
Last Mod Date   : 05/30/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Call the After Insert Methods in the AH_Account_Product_TriggerHandler Class
				:
************************************************************************************************/
trigger AH_Account_Product_AfterInsert on AH_Account_Product__c (after insert) 
{
    AH_Account_Product_TriggerHandler handler = new AH_Account_Product_TriggerHandler();
    handler.onAfterInsert(Trigger.new);
}