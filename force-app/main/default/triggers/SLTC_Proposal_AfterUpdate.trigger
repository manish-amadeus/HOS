/**********************************************************
*************************************
Name : SLTC_Proposal_AfterUpdate
Author : Japtej Lamba
Created Date : 1/10/2023
Last Mod Date : 1/10/2023v
Last Mod By : Japtej Lamba
NICC Reference :
Description : Call After Update methods in SLTC_Apttus_Proposal_TriggerHandler class
*************************************/
trigger SLTC_Proposal_AfterUpdate on Apttus_Proposal__Proposal__c (after update) {

    SLTC_Apttus_Proposal_TriggerHandler handler = new SLTC_Apttus_Proposal_TriggerHandler();
    if(Trigger.isAfter && Trigger.isUpdate)
    {   
        //after update
        handler.OnAfterUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
    }
    
}