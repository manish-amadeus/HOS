/****************************************************************************************
Name            : NI_Org_Details_TriggerHandler Class_Test Test Class
Author          : Stuart Emery
Created Date    : 7/16/2013
Last Mod Date   : 8/8/2014 - NICC-011439
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : test Class for NI_Org_Details_TriggerHandler Class
: 
: 
******************************************************************************************/
@isTest (SeeAllData=true)
private class NI_Org_Details_TriggerHandler_Test 
{
    
    static testMethod void myUnitTest() 
    {    
        
        NI_Org_Details_TriggerHandler handler = new NI_Org_Details_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;        
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE ORGANIZATION ID OF THE CURRENT USER  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        od.ParentAccountId__c = a.Id;
        //od.Org_ID__c = '00DA0000000abcd';
        od.Org_ID__c = orgId;
        insert od;
        
    } 
    
    static testMethod void testUpdate() 
    {    
        
        NI_Org_Details_TriggerHandler handler = new NI_Org_Details_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;        
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE ORGANIZATION ID OF THE CURRENT USER  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        od.ParentAccountId__c = a.Id;
        od.File_Storage_Percent_Used__c = '10000';
        od.Data_Storage_Limit__c = 100;
        od.Data_Storage__c = 110;
        //od.Org_ID__c = '00DA0000000abcd';
        od.Org_ID__c = orgId;
        od.Purchased_Limited_Users__c = 2;
        od.Shared_Org__c = false ; 
        insert od;
        
        od.File_Storage_Percent_Used__c = '100';
        od.Data_Storage_Limit__c = 120;
        od.Purchased_Limited_Users__c = -2;
        od.Shared_Org__c = true;
        update od;
        
    }   
    
    static testMethod void testUpdate1()
    {
         NI_Org_Details_TriggerHandler handler = new NI_Org_Details_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;        
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE ORGANIZATION ID OF THE CURRENT USER  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        od.ParentAccountId__c = a.Id;
        od.File_Storage_Percent_Used__c = '100';
        od.Data_Storage_Limit__c = 120;
        od.Data_Storage__c = 110;
        //od.Org_ID__c = '00DA0000000abcd';
        od.Org_ID__c = orgId;
        od.Purchased_Limited_Users__c = -2;
        od.Shared_Org__c = true;
        insert od;
        
        od.File_Storage_Percent_Used__c = '1000';
        od.Data_Storage_Limit__c = 100;
        od.Purchased_Limited_Users__c = 2;
        od.Shared_Org__c = false;
        update od;
    }
    
    static testMethod void testUpdate2() 
    {    
        
        NI_Org_Details_TriggerHandler handler = new NI_Org_Details_TriggerHandler(true);
        boolean IsTriggerContext = handler.IsTriggerContext;        
        
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');
        
        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
        
        //GET THE ORGANIZATION ID OF THE CURRENT USER  
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');
        od.ParentAccountId__c = a.Id;
        //od.File_Storage_Percent_Used__c = '10000';
        //od.Data_Storage_Limit__c = 23;
        //od.Org_ID__c = '00DA0000000abcd';
        od.Org_ID__c = orgId;
        insert od;
        
        od.File_Storage_Percent_Used__c = '100';
        od.Data_Storage_Limit__c = 23;
        update od;
        
    }      
    
}