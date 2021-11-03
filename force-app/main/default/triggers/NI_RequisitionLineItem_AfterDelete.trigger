/****************************************************************************************
Name            : NI_RequisitionLineItem_AfterDelete Trigger
Author          : Stuart Emery
Created Date    : 6/03/2016
Last Mod Date   : 6/07/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018180
Description     : After Delete Logic for the SCMC__Requisition_Line_Item__c Object
                : 
******************************************************************************************/
trigger NI_RequisitionLineItem_AfterDelete on SCMC__Requisition_Line_Item__c (after delete) {
    
    
    if (!NI_FUNCTIONS.bypassTriggerCode('REQUISITION LINE ITEM'))
    {
        NI_RequisitionLineItem_TriggerHandler handler = new NI_RequisitionLineItem_TriggerHandler();
        
        handler.OnAfterDelete(Trigger.old);
    }
}