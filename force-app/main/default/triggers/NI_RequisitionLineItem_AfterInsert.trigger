/****************************************************************************************
Name            : NI_RequisitionLineItem_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 6/03/2016
Last Mod Date   : 06/01/2017 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018180
Description     : After Insert Logic for the SCMC__Requisition_Line_Item__c Object
                : 
                : 
******************************************************************************************/

trigger NI_RequisitionLineItem_AfterInsert on SCMC__Requisition_Line_Item__c (after insert) {
    
    
    if (!NI_FUNCTIONS.bypassTriggerCode('REQUISITION LINE ITEM'))
    {
        NI_RequisitionLineItem_TriggerHandler handler = new NI_RequisitionLineItem_TriggerHandler();
        
        handler.OnAfterInsert(Trigger.new);
    }
}