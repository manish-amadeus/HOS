/************************************************************************************************************************
Name            : NI_Scheduled_DINames_Batch Batchable Class
Author          : Sean Harris
Created Date    : 7/28/2014
Last Mod Date   : 
Last Mod By     : 
NICC Reference  : NICC-010771 
Description     : Scans Product2 & Product_Group__c objects for records where the Update_Related_DI_Names__c equals true.
                : Collects all related Product2 Ids then performs an update to all DI records referenced to these Products.
                : It updates by setting a bogus DI Name value invoking the workflow to then build and change the name.
				: This in turn will trigger another workflow that flags the Asset.WriteHistory__c field.
				: because of this, the NI_Scheduled_DIHistory class must be scheduled to run after this job.
*************************************************************************************************************************/
global class NI_Scheduled_DINames_Batch implements Database.Batchable<sObject>
{
    
    global final Set<Id> setProd2Ids;
    
    global NI_Scheduled_DINames_Batch(Set<Id> setProduct2Ids)
    {        
        setProd2Ids = setProduct2Ids; 
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator([SELECT Id, Name FROM Asset WHERE Product2Id IN : setProd2Ids]);
    }
    
    global void execute(Database.BatchableContext bc, List<Asset> scope)
    {
       List<Asset> lstAssets = new List<Asset>();
       for (Asset a : scope)
       { 
           a.Name = 'DI Name Generation Failed'; 
           lstAssets.add(a); 
       } 
       update lstAssets;         
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
    }
    
}