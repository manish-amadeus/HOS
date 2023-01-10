/****************************************************************************************
Name            : SLTC_AssetLineItem_AfterUpdate 
Author          : Heema solanki
Created Date    : 02/11/2022
Last Mod Date   : 02/22/2022 
Last Mod By     : Heema Solanki

Description     : trigger to insert the cart record once asset line gets activated
                :
****************************************************************************************/

trigger SLTC_AssetLineItem_AfterUpdate on Apttus_Config2__AssetLineItem__c (after Update) {
    
    SLTC_AssetLineItemTriggerHandler objHandler = new SLTC_AssetLineItemTriggerHandler(); 
    if((trigger.isAfter && trigger.isUpdate) )
    {
        //Create the asset line item on renewal oopportunity
        objHandler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap, Trigger.new);
    }
    
}