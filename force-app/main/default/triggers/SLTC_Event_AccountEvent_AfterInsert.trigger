/****************************************************************************************
Name            : SLTC_Event_AccountEvent_AfterInsert 
Author          : Ganesh Bora
Created Date    : 12/21/2022
Last Mod Date   : 12/21/2022
Last Mod By     : Ganesh Bora
NICC Reference  : NICC-#########
Description     : Trigger Class for after insert AccountEvent__e to add record in captured event custom object.
:  
******************************************************************************************/
trigger SLTC_Event_AccountEvent_AfterInsert on AccountEvent__e (after insert) {
   List<SLTC_Account_Captured_Event__c> listcaptured =  new List<SLTC_Account_Captured_Event__c>();
    for (AccountEvent__e event : Trigger.New) {
        SLTC_Account_Captured_Event__c capturedevent = new SLTC_Account_Captured_Event__c();
        capturedevent.AccountId__c = event.AccountId__c;
        capturedevent.EventType__c = event.EventType__c;
        capturedevent.ReplayId__c  = event.ReplayId;
        capturedevent.Payload__c = JSON.serialize(event);        
        listcaptured.add(capturedevent);
    }
	insert  listcaptured;
}