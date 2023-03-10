trigger NI_Product2_BeforeInsert on Product2 (before Insert) {
    NI_Product2_Triggerhandler handler = new NI_Product2_Triggerhandler();
    handler.onBeforeInsert(Trigger.New);
}