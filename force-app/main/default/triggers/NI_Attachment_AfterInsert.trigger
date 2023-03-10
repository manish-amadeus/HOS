/****************************************************************************************
Name            : NI_Attachment_AfterInsert Trigger
Author          : Swapnil Patil
Created Date    : 02/18/2016
Last Mod Date   : 06/29/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
trigger NI_Attachment_AfterInsert on Attachment (after insert) 
{
   
    NI_TriggerBypassSwitches__c bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
    if (!bpSwitch.Bypass_CRSInboundOutboundAttachments__c)
    {    
        INTGR_WinSN_Attachment_Handler WinSN = new INTGR_WinSN_Attachment_Handler();
        WinSN.OnAfterInsert(Trigger.new); 
    }
    
    NI_Attachment_TriggerHandler handler = new NI_Attachment_TriggerHandler();
    handler.OnAfterInsert(Trigger.new); 
    
}