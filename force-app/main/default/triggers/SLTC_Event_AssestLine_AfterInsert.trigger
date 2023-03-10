/****************************************************************************************
Name            : SLTC_Event_AssestLine_AfterInsert 
Author          : Ganesh Bora
Created Date    : 11/25/2022
Last Mod Date   : 12/09/2022
Last Mod By     : Ganesh Bora
NICC Reference  : NICC-#########
Description     : Trigger Class for after insert AssetEvent__e to add record in captured event custom object.
:  
******************************************************************************************/
trigger SLTC_Event_AssestLine_AfterInsert on AssetEvent__e (after insert) {
    List<SLTCAssetCapturedEvent__c> listcaptured =  new List<SLTCAssetCapturedEvent__c>();
    for (AssetEvent__e event : Trigger.New) {
        SLTCAssetCapturedEvent__c capturedevent = new SLTCAssetCapturedEvent__c();
        capturedevent.AssetId__c = event.Line_Id__c;
        capturedevent.ReplayId__c  = event.ReplayId;
        capturedevent.EventType__c  = event.EventType__c;
        capturedevent.Payload__c = JSON.serialize(event);
        listcaptured.add(capturedevent);
    }
    insert  listcaptured;
}