/****************************************************************************************
Name            : AH_ActivityLineItem_AfterInsert Trigger
Author          : Sean Harris
Created Date    : 08/13/2018
Last Mod Date   : 08/13/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Written by CLS Partners. Updated to meet AH Standards
                :
                :
******************************************************************************************/
trigger AH_ActivityLineItem_AfterInsert on Activity_Line_Item__c (after insert)
{
    if (NI_TriggerManager.is1stInsert_ActivityLineItem)
    {   
        AH_ActivityLineItem_TriggerHandler handler = new AH_ActivityLineItem_TriggerHandler();
        handler.OnAfterInsert(Trigger.new, Trigger.oldMap);
    }
}