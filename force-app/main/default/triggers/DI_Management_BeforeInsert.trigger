trigger DI_Management_BeforeInsert on DI_Management__c (before insert) {
	DI_Management_TriggerHandler handler = new DI_Management_TriggerHandler();
    handler.OnBeforeInsert(Trigger.new);
}