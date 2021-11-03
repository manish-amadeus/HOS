/****************************************************************************************
Name            : NI_EmailMessage_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 02/02/2017
Last Mod Date   : 02/02/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-020976
Description     :
                :
                :
******************************************************************************************/
trigger NI_EmailMessage_AfterInsert on EmailMessage (after insert) 
{

    NI_EmailMessage_TriggerHandler handler = new NI_EmailMessage_TriggerHandler();
    handler.OnAfterInsert(Trigger.new);
   
}