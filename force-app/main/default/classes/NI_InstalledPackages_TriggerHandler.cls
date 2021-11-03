/************************************************************************************************
Name            : NI_InstalledPackages_TriggerHandler
Author          : Supriya Galinde
Created Date    : 02/20/2017
Last Mod Date   : 02/23/2017
Last Mod By     : Supriya Galinde
NICC Reference  : 
Description     : 
    This class sets the Package_Allowed__c & Package_Verified__c fields before 
	NI_Org_Details_Installed_Packages__c records are inserted by looking them up
	in Salesforce_Packages__c.
    This class creates new Salesforce_Packages__c packages found in new 
	NI_Org_Details_Installed_Packages__c records inserted.
*************************************************************************************************/
public class NI_InstalledPackages_TriggerHandler 
{
    
    public NI_InstalledPackages_TriggerHandler()
    {
        
    }
    
    public void onBeforeInsert(List<NI_Org_Details_Installed_Packages__c> newTrigger)
    {

        // LIST TO STORE Salesforce_Packages__c FOUND IN NEWLY INSERTED NI_Org_Details_Installed_Packages__c  
        List<Salesforce_Packages__c> salesforcePackageList = new List<Salesforce_Packages__c>() ;
        // LIST TO STORE Salesforce_Packages__c -NOT- FOUND IN NEWLY INSERTED NI_Org_Details_Installed_Packages__c 
        List<Salesforce_Packages__c> salesforcePckListToInsert = new List<Salesforce_Packages__c>() ;        
        // Map to store Name as key and Installed Packages as value in order to modify Package Allowed and Package Verified fields.
        Map<String, NI_Org_Details_Installed_Packages__c> newTriggerMap = new Map<String, NI_Org_Details_Installed_Packages__c>();        
        // Map to store unique combination of 'Name,Prefix,Publisher' as Key and Name as Value 
        Map<String, String> mapWithUniqueKeyId = new Map<String, String>();
        
        for (NI_Org_Details_Installed_Packages__c installedPackage : newTrigger)
        {
            //String to store unique combination of 'Name,Prefix,Publisher' of inserted record
            String str = '';
            if (installedPackage.Name != '' && installedPackage.Name != null)
            {
                str += installedPackage.Name;
            }
            if (installedPackage.Namespace_Prefix__c != '' && installedPackage.Namespace_Prefix__c != null)
            {
                str += installedPackage.Namespace_Prefix__c;
            }
            if (installedPackage.Publisher__c != '' && installedPackage.Publisher__c != null)
            {
                str += installedPackage.Publisher__c;
            }            
            newTriggerMap.put(installedPackage.Name, installedPackage);            
            mapWithUniqueKeyId.put(str, installedPackage.Name);            
        }
       
        // Query to get all Salesforce Packages with the help of unique field 'Name_Prefix_Publisher__c'
        salesforcePackageList = [SELECT Name, Namespace_Prefix__c, Publisher__c, Name_Prefix_Publisher__c, 
                                 Package_Allowed__c, Package_Verified__c FROM Salesforce_Packages__c 
                                 WHERE Name_Prefix_Publisher__c IN : mapWithUniqueKeyId.keySet()];        
        
        // Set the Package_Allowed__c & Package_Verified__c fields before NI_Org_Details_Installed_Packages__c records 
        // are inserted by looking them up in Salesforce_Packages__c.
        if (!salesforcePackageList.isEmpty())
        {
            for (Salesforce_Packages__c salesPackage : salesforcePackageList)
            {
                if (salesPackage.Package_Verified__c == true)
                {
                    String installedPackageName = mapWithUniqueKeyId.get((salesPackage.Name_Prefix_Publisher__c));
                    NI_Org_Details_Installed_Packages__c newOrgInstalledPck = newTriggerMap.get(installedPackageName);
                    newOrgInstalledPck.Package_Allowed__c = salesPackage.Package_Allowed__c;
                    newOrgInstalledPck.Package_Verified__c = salesPackage.Package_Verified__c;                           
                } 
                mapWithUniqueKeyId.remove(salesPackage.Name_Prefix_Publisher__c);
            }
        } 
		
        // Create new Salesforce_Packages__c packages found in new NI_Org_Details_Installed_Packages__c records inserted.
        if (!mapWithUniqueKeyId.isEmpty())
        {
        	for (String installedPackageName : mapWithUniqueKeyId.values())
            {               
                NI_Org_Details_Installed_Packages__c installedPackage = newTriggerMap.get(installedPackageName);
                Salesforce_Packages__c newSFPackageRecord = new Salesforce_Packages__c();
                newSFPackageRecord.Name = installedPackage.Name;
                newSFPackageRecord.Namespace_Prefix__c = installedPackage.Namespace_Prefix__c;
                newSFPackageRecord.Publisher__c = installedPackage.Publisher__c;
                newSFPackageRecord.Package_Allowed__c = false;
                newSFPackageRecord.Package_Verified__c = false;
                salesforcePckListToInsert.add(newSFPackageRecord);
        	}
            if (!salesforcePckListToInsert.isEmpty())
            {
                insert salesforcePckListToInsert;
            }            
        }       
    }
    
}