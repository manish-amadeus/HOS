/****************************************************************************************
Name            : AH_ActivityLineItem_AfterUpdate Trigger
Author          : Sean Harris
Created Date    : 08/13/2018
Last Mod Date   : 08/13/2018
Last Mod By     : Sean Harris
NICC Reference  :
Description     : Written by CLS Partners. Updated to meet AH Standards
                :
                :
******************************************************************************************/
trigger AH_ActivityLineItem_AfterUpdate on Activity_Line_Item__c (after update)
{
    if (NI_TriggerManager.is1stUpdate_ActivityLineItem)
    {   
        AH_ActivityLineItem_TriggerHandler handler = new AH_ActivityLineItem_TriggerHandler();
        handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}