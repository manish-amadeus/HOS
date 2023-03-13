/************************************************************************************************
Name            : NI_fetchObjectAccessTest
Author          : Kasim Badami
Created Date    : 06/30/2016
Last Mod By     : Bhuleshwar Deshpande
Last Mod Date   : 11/14/2018
NICC Reference  :  
Description     : 
				: 

    // CODE TO SCHEDULE THIS IN EXEC ANON
    String strJobName = 'Salesforce User Fetch TEMP';
    String strSchedule = '0 20 13 * * ? *';
    System.schedule(strJobName, strSchedule, new NI_fetchObjectAccess());

*************************************************************************************************/
@isTest
private class NI_fetchObjectAccessTest 
{
    @isTest
    static void testFetchObjectAccess() 
    {
        
        //RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name = 'Delphi.Net Support User' AND isActive = true];
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'Delphi.Net Support User');
        //Id rtInit = rt.Id;
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Test' + String.valueOf(1);        
        a.BillingPostalCode = '03801';
        a.BillingCountry = 'US';
        a.BillingState = 'NH';
        a.BillingStreet = '75 NH Ave';
        a.BillingCity = 'Portsmouth';
        a.Type = 'Customer';
        insert a;   
        
        Account acc1 = [Select Id, Name from Account where Id =: a.Id];
        system.assertEquals('Test' + String.valueOf(1), acc1.Name, 'Account name do not match ');
        
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production'); 
        od.RecordTypeId = rtInit;
        od.Primary_Account__c = a.Id;
        od.Org_ID__c = orgId;
        od.Org_Type__c = 'Salesforce Production';
        od.Org_Name__c = 'Test Org';
        od.Admin_Login_Name_Encrypted__c = 'testusername';
        od.Admin_Password_Encrypted__c = 'testpass';
        od.Security_Token_Encrypted__c = 'testtoken';
        insert od; 

        NI_Org_Details__c NIorg = [Select ID, Org_Name__c from NI_Org_Details__c  where ID =: od.Id];
        system.assertEquals('Test Org', NIorg.Org_Name__c, 'Org Name do not match');
               
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new NI_MockHttpResponseGenerator());
        
        NI_FetchObjectAccessBatch batch = new NI_FetchObjectAccessBatch();
        Database.executeBatch(batch,1);
        
        Test.StopTest();  
                
    }
   
    @isTest
    static void testGetpermset() 
    {
        //RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name = 'Delphi.Net Support User' AND isActive = true];
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'Delphi.Net Support User');
        //Id rtInit = rt.Id;
        String orgId = UserInfo.getOrganizationId();
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'Test' + String.valueOf(1);        
        a.BillingPostalCode = '03801';
        a.BillingCountry = 'US';
        a.BillingState = 'NH';
        a.BillingStreet = '75 NH Ave';
        a.BillingCity = 'Portsmouth';
        a.Type = 'Customer';
        insert a;   
        
        Account acc1 = [Select Id, Name from Account where Id =: a.Id];
        system.assertEquals('Test' + String.valueOf(1), acc1.Name, 'Account name do not match ');
        
        NI_Org_Details__c od = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production'); 
        od.RecordTypeId = rtInit;
        od.Primary_Account__c = a.Id;
        od.Org_ID__c = orgId;
        od.Org_Type__c = 'Salesforce Production';
        od.Org_Name__c = 'Test Org';
        od.Admin_Login_Name_Encrypted__c = 'testusername';
        od.Admin_Password_Encrypted__c = 'testpass';
        od.Security_Token_Encrypted__c = 'testtoken';
        insert od; 

        NI_Org_Details__c NIorg = [Select ID, Org_Name__c,Admin_Login_Name_Encrypted__c,Admin_Password_Encrypted__c,Security_Token_Encrypted__c from NI_Org_Details__c  where ID =: od.Id];
        system.assertEquals('Test Org', NIorg.Org_Name__c, 'Org Name do not match');
        
        system.debug('Org_Name__c-' + NIorg.Org_Name__c );
        //system.debug('Admin_Login_Name_Encrypted__c :' +  NIorg.Admin_Login_Name_Encrypted__c);
        
        List<Salesforce_User__c> SfuserLst = new List<Salesforce_User__c>();
        Salesforce_User__c sforceUser = NI_TestClassData.createTestSalesforceUserDetails(NIorg.Id);
        
        sforceUser.User_Full_Name__c='Test User';    
        sforceUser.UserEmail__c = 'newmarket_cybage.com';
        sforceUser.UserName__c = 'newmarket_cybage.com.fdc';
        sforceUser.User_Profile_Status__c ='Active';
        sforceUser.userIDFromOrg__c = '005G0000004tCyeIAE';
        sforceUser.testscheduler__c = DateTime.valueOf('2019-07-26 09:10:20');
        sforceUser.User_License__c = 'Salesforce Platform';        
        
        SfuserLst.add(sforceUser);
        
        Database.insert(SfuserLst);
        system.debug('sforceUser.ID' + sforceUser.Id);
        system.debug('NIorg.ID' + NIorg.Id);
        
        Salesforce_User__c SfuserLst2 =[Select ID,User_Full_Name__c,UserEmail__c,UserName__c,User_Profile_Status__c,userIDFromOrg__c,testscheduler__c,User_License__c from Salesforce_User__c];
        system.debug('SfuserLst2 : ' + SfuserLst2 );
        
        // SET FOR PERMISSIONSET ID'S 
        Set<String> PermissionId = new Set<String>{'0PSG00000005u1UOBQ','0PSG00000005u1UOBL'};  
        
        test.StartTest();
        Test.setMock(HttpCalloutMock.class, new NI_MockHttpResponseGenerator());
        
        NI_FetchFullAccessPermissions_Batch batch = new NI_FetchFullAccessPermissions_Batch(NIorg,PermissionId,SfuserLst);
        Database.executeBatch(batch,50);
        
        Test.StopTest();  
    }
    
    @isTest
    static void testSchedule()  
    {
        Test.startTest();
        NI_fetchObjectAccess fetchObjectAccess = new NI_fetchObjectAccess();
        String sch = '0 0 23 * * ?';
        String jobId = system.schedule('Test Territory Check', sch, fetchObjectAccess);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId ];  

        system.assertNotEquals( Null, ct.Id, 'JOB IS NOT BE SCHEDULED');
        Test.stopTest();
    } 
}