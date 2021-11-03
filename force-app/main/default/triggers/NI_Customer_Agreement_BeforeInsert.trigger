/****************************************************************************************
Name            : NI_Customer_Agreement_BeforeInsert Trigger
Author          : Stuart Emery
Created Date    : 10/15/2015
Last Mod Date   : 1/11/2016
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Handles Before Insert Trigger Logic for the NI Customer Agreement object
                : 
                : 
******************************************************************************************/
trigger NI_Customer_Agreement_BeforeInsert on NI_Customer_Agreement__c (before insert) {
    
    //ONLY RUN THE TRIGGER IF THE BYPASSTRIGGER SWITCH IS NOT CHECKED
    if (!NI_FUNCTIONS.bypassTriggerCode('NI CUSTOMER AGREEMENT'))
    {
        NI_Customer_Agreement_TriggerHandler handler = new NI_Customer_Agreement_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);
    }       
    
}