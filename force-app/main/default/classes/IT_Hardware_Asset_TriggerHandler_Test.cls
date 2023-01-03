/****************************************************************************************
Name            : IT_Hardware_Asset_TriggerHandler_Test Test Class
Author          : Stuart Emery
Created Date    : 4/1/2015
Last Mod Date   : 4/1/2015
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : test Class for the IT_Hardware_Asset_TriggerHandler Class
                : 
******************************************************************************************/
@isTest (SeeAllData=false)
private class IT_Hardware_Asset_TriggerHandler_Test {
    
    static testMethod void singleInsertTest() 
    {    
        
        // CREATE A TEST USER WITH THE NI ADMINISTRATOR PROFILE
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;
        
        //CREATE A TEST HARDWARE MODEL RECORD
        IT_Hardware_Model__c hm = NI_TestClassData.createITHardwareModel(1);
        insert hm;
        
        //TEST THE AFTER INSERT TRIGGER LOGIC
        Test.startTest();
        
        IT_Hardware_Asset__c ha = NI_TestClassData.createITHardwareAsset(1, hm.Id);
        ha.User__c = u.Id;  //ADD THE TEST USER AS THE CUSTODIAN FOR THE HARDWARE ASSET RECORD
        insert ha;
        
        Test.stopTest();
        
        //VERIFY THAT THE CUSTODIAN WAS ADDED TO THE IT HARDWARE ASSET SHARE
        List<IT_Hardware_Asset__Share> lstShares = [SELECT UserOrGroupId 
                                                    FROM IT_Hardware_Asset__Share 
                                                    WHERE ParentId =: ha.Id 
                                                    AND UserOrGroupId =: u.Id];
        System.assertEquals(1, lstShares.size());
        
    }
    //================================================================================================================================================    
    static testMethod void singleUpdateTest() 
    {    
        
        // CREATE A TEST USER TO USE WHEN THE RECORD IS INSERTED
        User u = NI_TestClassData.createTestUser(1, 'NI Administrator');
        insert u;
        
        // CREATE A TEST USER TO USE WHEN THE RECORD IS UPDATED
        User u2 = NI_TestClassData.createTestUser(2, 'NI Administrator');
        insert u2;
        
        //CREATE A TEST HARDWARE MODEL RECORD
        IT_Hardware_Model__c hm = NI_TestClassData.createITHardwareModel(1);
        insert hm;
        
        IT_Hardware_Asset__c ha = NI_TestClassData.createITHardwareAsset(1, hm.Id);
        ha.User__c = u.Id;  //ADD THE TEST USER AS THE CUSTODIAN FOR THE HARDWARE ASSET RECORD
        insert ha;
        
        //TEST THE AFTER UPDATE TRIGGER LOGIC
        Test.startTest();
        
        ha.User__c = u2.Id;
        update ha;
        
        Test.stopTest();
        
        //VERIFY THAT THE ORIGINAL CUSTODIAN WAS REMOVED FROM THE HARDWARE ASSET SHARE
        List<IT_Hardware_Asset__Share> lstSharesRemoved = [SELECT UserOrGroupId 
                                                           FROM IT_Hardware_Asset__Share 
                                                           WHERE ParentId =: ha.Id 
                                                           AND UserOrGroupId =: u.Id];
        System.assertEquals(0, lstSharesRemoved.size());
        
        
        //VERIFY THAT THE NEW CUSTODIAN WAS ADDED TO THE IT HARDWARE ASSET SHARE
        List<IT_Hardware_Asset__Share> lstSharesAdded = [SELECT UserOrGroupId 
                                                         FROM IT_Hardware_Asset__Share 
                                                         WHERE ParentId =: ha.Id 
                                                         AND UserOrGroupId =: u2.Id];
        System.assertEquals(1, lstSharesAdded.size());
        
    }
    
}