/****************************************************************************************
Name            : NI_InstalledPackages_TrigrHndlrTest
Author          : Supriya Galinde
Created Date    : 2/21/2017
Last Mod Date   : 2/23/2017
Last Mod By     : Supriya Galinde
NICC Reference  : -
Description     : test Class for NI_InstalledPackages_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest
public class NI_InstalledPackages_TrigrHndlrTest {
    @testSetup static void createTestData(){
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.NI_Org_Details__c; 
        Map<String, Schema.RecordTypeInfo> OrgDetailsRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id orgRecordType = OrgDetailsRecordTypeInfo.get('LOD Support Admin').getRecordTypeId();
        
        NI_Org_Details__c org1 = NI_TestClassData.createTestNiOrgDetails(orgRecordType, 1, 'Salesforce Sandbox - Developer');
        insert org1;
        
        Salesforce_Packages__c package1 = new Salesforce_Packages__c();
        package1.Name = 'Package-1';
        package1.Package_Verified__c = true;
        package1.Package_Allowed__c = true;  
        package1.Publisher__c = 'Publisher';
        package1.Namespace_Prefix__c = 'pck';
        insert package1;        
    }
    
    static testMethod void testMethodOne(){
        Test.startTest();
        NI_InstalledPackages_TriggerHandler handler = new NI_InstalledPackages_TriggerHandler();   
        NI_Org_Details__c org1 = [SELECT Id FROM NI_Org_Details__c WHERE Org_Type__c = 'Salesforce Sandbox - Developer'];
        
        
        NI_Org_Details_Installed_Packages__c niOrgInsPackage1 = new NI_Org_Details_Installed_Packages__c();
        niOrgInsPackage1.Name = 'Package-1';
        niOrgInsPackage1.NI_Org_Details__c = org1.Id;
        niOrgInsPackage1.Publisher__c = 'Publisher';
        niOrgInsPackage1.Namespace_Prefix__c = 'pck';
        insert(niOrgInsPackage1);      
            
        Test.stopTest();
    }
    
    static testMethod void bulkTestMethodTwo(){
        Test.startTest();
        NI_InstalledPackages_TriggerHandler handler = new NI_InstalledPackages_TriggerHandler(); 
        
        NI_Org_Details__c org1 = [SELECT Id FROM NI_Org_Details__c WHERE Org_Type__c = 'Salesforce Sandbox - Developer'];
        
        

        List<NI_Org_Details_Installed_Packages__c> niOrgInsPackageList = new List<NI_Org_Details_Installed_Packages__c>();
        for(Integer i=1; i<205; i++){
            NI_Org_Details_Installed_Packages__c niOrgInsPackage1 = new NI_Org_Details_Installed_Packages__c();
            niOrgInsPackage1.Name = 'Package-'+i;
            niOrgInsPackage1.NI_Org_Details__c = org1.Id;
            niOrgInsPackage1.Publisher__c = 'Publisher'+i;
            niOrgInsPackage1.Namespace_Prefix__c = 'pck'+i;
            niOrgInsPackageList.add(niOrgInsPackage1);
        }
        
        system.debug('niOrgInsPackageList.size()  --:' + niOrgInsPackageList.size());
        //Test.startTest();
        insert niOrgInsPackageList;
              
        Test.stopTest();
    }
}