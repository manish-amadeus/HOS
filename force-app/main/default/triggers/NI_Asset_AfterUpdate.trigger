/****************************************************************************************
Name            : NI_Asset_AfterUpdate Trigger
Author          : Stuart Emery
Created Date    : 2/13/2014
Last Mod Date   : 2/13/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-009258
Description     : Call the After Update Methods in the NI_DeploymentInstance_TriggerHandler 
                : Class
                : 
******************************************************************************************/
trigger NI_Asset_AfterUpdate on Asset (after update) 
{
    NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
    handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);    
}