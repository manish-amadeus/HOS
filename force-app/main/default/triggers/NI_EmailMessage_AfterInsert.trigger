/****************************************************************************************
Name            : NI_EmailMessage_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 02/02/2017
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Added if/else block to skip code when new Case created via email-to-case 
                :
                :
******************************************************************************************/
trigger NI_EmailMessage_AfterInsert on EmailMessage (after insert) 
{

    if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
    {
        system.debug(' ***** NI_EmailMessage_AfterInsert WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML'); 
    }
    else
    {
        NI_EmailMessage_TriggerHandler handler = new NI_EmailMessage_TriggerHandler();
        handler.OnAfterInsert(Trigger.new);
    }
    
    system.debug(' ***** NI_EmailMessage_AfterInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
   
}