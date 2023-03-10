/****************************************************************************************
Name            : NI_Invoice_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 12/30/2015
Last Mod Date   : 1/11/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Call the After Update Methods in the NI_Invoice_TriggerHandler Class
                : 
******************************************************************************************/
trigger NI_Invoice_AfterUpdate on NI_Invoice__c (after update) {
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI INVOICE'))
    {    
        NI_Invoice_TriggerHandler handler = new NI_Invoice_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}