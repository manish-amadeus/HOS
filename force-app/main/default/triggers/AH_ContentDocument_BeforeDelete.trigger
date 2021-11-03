trigger AH_ContentDocument_BeforeDelete on ContentDocument (before delete) 
{
    AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
    cpHandler.deleteFileFromZipfileOnFileDelete(Trigger.Old);
}