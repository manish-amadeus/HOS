trigger SLTC_Agreement_AfterUpdate on Apttus__APTS_Agreement__c (after update) {
    SLTC_AgreementTriggerHandler handler = new SLTC_AgreementTriggerHandler();
    handler.onAfterUpdate(Trigger.newMap, trigger.oldMap);
}