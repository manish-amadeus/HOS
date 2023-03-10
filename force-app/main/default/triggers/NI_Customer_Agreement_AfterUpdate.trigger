/****************************************************************************************
Name            : NI_Customer_Agreement_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 10/31/2015
Last Mod Date   : 1/11/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Call the After Update Methods in the NI_Customer_Agreement_TriggerHandler Class
                : 
******************************************************************************************/
trigger NI_Customer_Agreement_AfterUpdate on NI_Customer_Agreement__c (after update) {
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI CUSTOMER AGREEMENT'))
    {    
        NI_Customer_Agreement_TriggerHandler handler = new NI_Customer_Agreement_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}