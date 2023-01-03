/**********************************************************
Name : SLTC_AgreementTriggerHelper
Author : Gopesh Banker
Created Date : 10/3/2022
Last Mod Date : 12/15/2022
Last Mod By : Japtej Lamba
Description : Helper Class for SLTC_AgreementTriggerHandler.
              Invokes Helper methods for Before Update and After Update
***********************************************************/

public without sharing class SLTC_AgreementTriggerHandler {
    private NI_TriggerBypassSwitches__c bpSwitch;
        
    public SLTC_AgreementTriggerHandler(){
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();         
    }

    public void onBeforeUpdate(Map<Id, Apttus__APTS_Agreement__c> mapNewAgreements, Map<Id,Apttus__APTS_Agreement__c> mapOldAgreements)
    {
        if (!bpSwitch.BypassApttusAgreement_ON__c){
            SLTC_AgreementTriggerHelper helper = new SLTC_AgreementTriggerHelper();
            helper.activateChildAgreements(mapNewAgreements, mapOldAgreements);
        }
    }

    public void onAfterUpdate(Map<Id, Apttus__APTS_Agreement__c> mapNewAgreements, Map<Id,Apttus__APTS_Agreement__c> mapOldAgreements)
    {
        if (!bpSwitch.BypassApttusAgreement_ON__c){
            SLTC_AgreementTriggerHelper helper = new SLTC_AgreementTriggerHelper();
            helper.updateAgreementDates(mapNewAgreements, mapOldAgreements);
        }
    }
}