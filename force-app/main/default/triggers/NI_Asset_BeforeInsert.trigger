/****************************************************************************************
Name            : NI_Asset_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 7/23/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : 
Description     : Call the Before Insert Methods in the NI_DeploymentInstance_TriggerHandler 
                : Class
                : 
******************************************************************************************/
trigger NI_Asset_BeforeInsert on Asset (before insert) 
{
    NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
    handler.OnBeforeInsert(Trigger.new);    
}