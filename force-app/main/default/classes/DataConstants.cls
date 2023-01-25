/************************************************************************************************
Name            : DataConstants
Author          : Mike Pedro 
Created Date    : 05/18/2022
Last Mod Date   : 05/18/2022
Last Mod By     : Mike Pedro
NICC Reference  : NICC-058970 
Description     : 
        projects may wish to declaratively enable/disable CRUD/FLS/SHR checks
    via a protected custom setting. Update the line below to point to the
    PCS.
    
    Example:
    ENABLED = CustomSetting__c.getOrgDefaults().CRUDFLS_Enabled__c;
*************************************************************************************************/
@namespaceAccessible
public with sharing class DataConstants {

    @namespaceAccessible
    public static Boolean ENABLED = true;

    @namespaceAccessible
    public static System.LoggingLevel LOGGING_LEVEL = LoggingLevel.DEBUG;

    @namespaceAccessible
    public enum SecurityOperation {
        READ,
        CREATE,
        MODIFY,
        REMOVE,
        UNREMOVE
    }
}