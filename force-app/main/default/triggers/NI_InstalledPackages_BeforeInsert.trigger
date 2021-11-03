/****************************************************************************************
Name            : NI_InstalledPackages_BeforeInsert
Author          : Supriya Galinde
Created Date    : 02/20/2017
Last Mod Date   : 02/23/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : Handles all before insert trigger logic 
******************************************************************************************/
trigger NI_InstalledPackages_BeforeInsert on NI_Org_Details_Installed_Packages__c (before insert) 
{    
    NI_InstalledPackages_TriggerHandler handler = new NI_InstalledPackages_TriggerHandler();   
    handler.onBeforeInsert(Trigger.new);
}