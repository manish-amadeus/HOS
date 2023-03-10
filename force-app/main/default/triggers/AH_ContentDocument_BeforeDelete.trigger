/****************************************************************************************
Name            : AH_ContentDocument_BeforeDelete
Author          : Bhagwat Garkal
Created Date    : 02/22/2021
Modified Date   : 02/22/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : 
                :
******************************************************************************************/
trigger AH_ContentDocument_BeforeDelete on ContentDocument (before delete) 
{
    AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
    cpHandler.deleteFileFromZipfileOnFileDelete(Trigger.Old);
}