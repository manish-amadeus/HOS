/****************************************************************************************
Name            : NI_RequisitionLineItem_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 6/03/2016
Last Mod Date   : 6/07/2016
Last Mod By     : Stuart Emery
NICC Reference  : NICC-018180
Description     : After Update Logic for the SCMC__Requisition_Line_Item__c Object
                : 
                : 
******************************************************************************************/

trigger NI_RequisitionLineItem_AfterUpdate on SCMC__Requisition_Line_Item__c (after update) {
    
    if (!NI_FUNCTIONS.bypassTriggerCode('REQUISITION LINE ITEM'))
    {
        
        NI_RequisitionLineItem_TriggerHandler handler = new NI_RequisitionLineItem_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }    
    
}