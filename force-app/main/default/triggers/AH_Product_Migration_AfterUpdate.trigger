/****************************************************************************************
Name            : AH_Product_Migration_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 11/13/2018
Last Mod Date   : 11/13/2018
Last Mod By     : Sean Harris
NICC Reference  : NICC-034281
Description     : Handles After Update Trigger Logic for the AH_Product_Migration__c object
                : 
                : 
******************************************************************************************/
trigger AH_Product_Migration_AfterUpdate on AH_Product_Migration__c (after update) 
{
    AH_ProdMigration_TriggerHandler handler = new AH_ProdMigration_TriggerHandler();
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
}