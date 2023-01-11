/**********************************************************
*************************************
Name : SLTC_Proposal_BeforeUpdate
Author : Japtej Lamba
Created Date : 1/10/2023
Last Mod Date : 1/10/2023
Last Mod By : Japtej Lamba
NICC Reference :
Description : Call the Before Update methods in SLTC_Apttus_Proposal_TriggerHandler class
*************************************/
trigger SLTC_Proposal_BeforeUpdate on Apttus_Proposal__Proposal__c (before update) {

    SLTC_Apttus_Proposal_TriggerHandler handler = new SLTC_Apttus_Proposal_TriggerHandler();
    if(Trigger.isBefore && Trigger.isUpdate && SLTC_checkRecursive.runOnce())
    {
        //before update
        handler.OnBeforeUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
    }
    
}