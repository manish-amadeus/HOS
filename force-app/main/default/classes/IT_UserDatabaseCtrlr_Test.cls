/****************************************************************************************
Name            : IT_UserDatabaseCtrlr_Test Test Class
Author          : Stuart Emery
Created Date    : 4/3/2015
Last Mod Date   : 4/3/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : test Class for the IT_UserDatabaseCtrlr Class
                : 
******************************************************************************************/
@isTest (SeeAllData=false)
private class IT_UserDatabaseCtrlr_Test {
    
    static testMethod void myUnitTest() 
    {    
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;
        
        //CREATE A TEST HARDWARE MODEL RECORD
        IT_Hardware_Model__c hm = NI_TestClassData.createITHardwareModel(1);
        insert hm;
        
        //CREATE A TEST HARDWARE ASSET RECORD
        IT_Hardware_Asset__c ha = NI_TestClassData.createITHardwareAsset(1, hm.Id);
        ha.User__c = u.Id;  //ADD THE TEST USER AS THE CUSTODIAN FOR THE HARDWARE ASSET RECORD
        insert ha;
        
        //CREATE A TEST SOFTWARE PACKAGE RECORD
        IT_Software_Package__c sp = NI_TestClassData.createITSoftwarePackage(1);
        insert sp;
        
         //CREATE A TEST SOFTWARE ASSET RECORD
        IT_Software_Asset__c sa = NI_TestClassData.createITSoftwareAsset(1, sp.Id);
        sa.Assigned_User__c = u.Id;  //ADD THE TEST USER AS THE CUSTODIAN FOR THE SOFTWARE ASSET RECORD
        insert sa;
        
         //INSTANTIATE CONTROLLER
       IT_UserDatabaseCtrlr ctrl = new IT_UserDatabaseCtrlr(new ApexPages.StandardController(u)); 
        
        
    }

}