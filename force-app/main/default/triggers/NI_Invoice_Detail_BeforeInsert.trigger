/****************************************************************************************
Name            : NI_Invoice_Detail_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 10/26/2015
Last Mod Date   : 1/11/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Handles Before Insert Trigger Logic for the NI Invoice Detail object
                : 
                : 
******************************************************************************************/
trigger NI_Invoice_Detail_BeforeInsert on NI_Invoice_Detail__c (before insert) {
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI INVOICE DETAIL'))
    {
        NI_Invoice_Detail_TriggerHandler handler = new NI_Invoice_Detail_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);
    }       
    
}