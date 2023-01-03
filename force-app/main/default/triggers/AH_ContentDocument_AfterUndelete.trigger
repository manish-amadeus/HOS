/****************************************************************************************
Name            : AH_ContentDocument_AfterUndelete
Author          : Bhagwat Garkal
Created Date    : 02/22/2021
Modified Date   : 02/22/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : This Trigger is used to update Zip file Version when files deleted.
                :
******************************************************************************************/

trigger AH_ContentDocument_AfterUndelete on ContentDocument (after undelete) 
{
    AH_ContentPacks_TriggerHandler cpHandler = new AH_ContentPacks_TriggerHandler();
    cpHandler.updateFileInZipfileOnFileUnDelete(Trigger.New);
}