/****************************************************************************************
Name            : NI_Invoice_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 11/3/2015
Last Mod Date   : 1/11/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Handles Before Insert Trigger Logic for the NI Invoice object
                : 
                : 
******************************************************************************************/
trigger NI_Invoice_BeforeInsert on NI_Invoice__c (before insert) {
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI INVOICE'))
    {
        NI_Invoice_TriggerHandler handler = new NI_Invoice_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);
    }  
    
}