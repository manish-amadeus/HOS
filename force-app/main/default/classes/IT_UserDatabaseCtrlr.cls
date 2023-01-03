/****************************************************************************************
Name            : IT_UserDatabaseCtrlr Class
Author          : Stuart Emery
Created Date    : 3/23/2015
Last Mod Date   : 4/3/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Controller Extension for the IT_UserDatabase Visualforce page
                :              
******************************************************************************************/
public class IT_UserDatabaseCtrlr {
    
    Public User usr {get; set;}
    
    //LIST TO HOLD THE HARDWARE RECORDS  
    public List<IT_Hardware_Asset__c> lstHardware {get; set;}
    
    //LIST TO HOLD THE SOFTWARE LICENSE RECORDS  
    public List<IT_Software_Asset__c> lstSoftware {get; set;}
    
    //LIST TO HOLD THE FORCE.COM LICENSE RECORDS  
    public List<UserPackageLicense> lstUserPackageLicense {get; set;}
    
    private ApexPages.StandardController stdCtrl;
    public Id id; 
    
    
    public IT_UserDatabaseCtrlr(ApexPages.StandardController stdController)
    {                      
        id = ApexPages.CurrentPage().getParameters().get('Id');            
        
        this.stdCtrl = stdController;
        this.usr = (User)stdController.getRecord();
        
        lstHardware = [SELECT Id, Name, Asset_Tag_Number__c, Acquisition_Date__c, Deployment_Type__c, HardwareType__c, 
                       Manufacturer__c, Model_Description__c, Status__c, Lifecycle_Date__c 
                       FROM IT_Hardware_Asset__c 
                       WHERE User__c =: id];
        
        lstSoftware = [SELECT Id, Name, Assigned_User__c, Date_Purchased__c, Software_Package_Name__c, Vendor__c, License_Status__c
                       FROM IT_Software_Asset__c 
                       WHERE Assigned_User__c =: id];
        
        lstUserPackageLicense = [SELECT PackageLicenseId, UserId, PackageLicense.NamespacePrefix,PackageLicense.Status, PackageLicense.ExpirationDate 
                                 FROM UserPackageLicense
                                 WHERE UserId =: id];
        
    }    
    
}