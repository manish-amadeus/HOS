/****************************************************************************************
Name            : NI_Asset_BeforeUpdate Trigger
Author          : Sean Harris
Created Date    : 7/14/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Call the Before Update Methods in the NI_DeploymentInstance_TriggerHandler 
                : Class
                : 
******************************************************************************************/
trigger NI_Asset_BeforeUpdate on Asset (before update) 
{
    NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
    handler.OnBeforeUpdate(Trigger.new, Trigger.oldMap);    
}