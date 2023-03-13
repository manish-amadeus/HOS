/************************************************************************************************
Name            : DebugSettings
Author          : Mike Pedro 
Created Date    : 05/18/2022
Last Mod Date   : 05/18/2022
Last Mod By     : Mike Pedro
NICC Reference  : NICC-058970 
Description     : 
                : 
*************************************************************************************************/
public with sharing class DebugSettings {
    public Boolean isLimitsSnapshotEnabled;

    public DebugSettings() {
        DebugSettings__c settings = DebugSettings__c.getInstance();

        isLimitsSnapshotEnabled = (settings.EnableLimitsSnapshot__c == null) ? false : settings.EnableLimitsSnapshot__c;
    }
}