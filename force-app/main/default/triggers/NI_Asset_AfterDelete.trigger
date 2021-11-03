trigger NI_Asset_AfterDelete on Asset (after delete) {
    NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
    handler.OnAfterDelete(Trigger.old); 
}