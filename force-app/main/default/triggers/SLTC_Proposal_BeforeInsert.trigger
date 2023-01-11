/**********************************************************
*************************************
Name : SLTC_Proposal_BeforeInsert
Author : Subramanya Bhagawant
Created Date : 1/11/2022
Last Mod Date : 1/19/2023
Last Mod By : Japtej Lamba
NICC Reference :
Description : Call the Before Insert method in SLTC_Apttus_Proposal_TriggerHandler class
***********************************************************
Modified By : Gopesh Banker
Description : Code Factoring
Modification Date : 26th Aug, 2022
*************************************/
trigger SLTC_Proposal_BeforeInsert on Apttus_Proposal__Proposal__c (before insert) {

    //Changes by Gopesh Banker on 26th Aug, 2022
    SLTC_Apttus_Proposal_TriggerHandler handler = new SLTC_Apttus_Proposal_TriggerHandler();
    if(Trigger.isBefore && Trigger.isInsert)
    {
        handler.onBeforeInsert(Trigger.new);
    }
}