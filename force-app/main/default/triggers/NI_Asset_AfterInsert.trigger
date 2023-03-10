/****************************************************************************************
Name            : NI_Asset_AfterInsert Trigger
Author          : Stuart Emery
Created Date    : 2/13/2014
Last Mod Date   : 2/13/2014
Last Mod By     : Stuart Emery
NICC Reference  : NICC-009258
Description     : Call the After Insert Methods in the NI_DeploymentInstance_TriggerHandler 
                : Class
                : 
******************************************************************************************/
trigger NI_Asset_AfterInsert on Asset (after insert) 
{
    NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
    handler.OnAfterInsert(Trigger.new);    
}