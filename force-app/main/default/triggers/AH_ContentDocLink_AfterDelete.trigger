/****************************************************************************************
Name            : AH_ContentDocLink_AfterDelete
Author          : Bhagwat Garkal
Created Date    : 02/22/2021
Modified Date   : 02/22/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : This Trigger is used to Update Zip file Version when Content Packs files deleted.
                :
******************************************************************************************/
trigger AH_ContentDocLink_AfterDelete on ContentDocumentLink (After Delete) 
{
    AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
    cpHandler.updateZipFileVersionOnFileDelete(Trigger.old);
}