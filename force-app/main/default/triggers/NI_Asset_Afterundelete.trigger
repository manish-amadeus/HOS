/****************************************************************************************
Name            : NI_Asset_AfterUndelete Trigger
Author          : Sunita Mittal
Created Date    : 01/06/2016
Last Mod Date   : 01/06/2016
Last Mod By     : 
NICC Reference  : 
Description     : Call the After Undelete Methods in the NI_DeploymentInstance_TriggerHandler 
                : Class
                : 
******************************************************************************************/

trigger NI_Asset_Afterundelete on Asset (after undelete) {
    NI_DeploymentInstance_TriggerHandler handler = new NI_DeploymentInstance_TriggerHandler(true);
    handler.OnAfterUnDelete(Trigger.new);
}