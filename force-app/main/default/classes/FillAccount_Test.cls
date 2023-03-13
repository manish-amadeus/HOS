/****************************************************************************************
Name            : FillAccount_Test Class
Author          : Sean Harris
Created Date    : 11/21/2016
Last Mod Date   : 04/25/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test Class for the FillAccount_Test Class 
                : 
                : 
******************************************************************************************/
@isTest
public class FillAccount_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {    
        
        // CREATE 2 ORG DETAILS RECORDS WITH DIFFERENT ORG TYPES AND ASSERT THEY WERE CREATED ================================================
        Id rtInit = NI_TestClassData.getRecordTypeId('NI_Org_Details__c', 'LOD Support Admin');       
        
        NI_Org_Details__c odProd = NI_TestClassData.createTestNiOrgDetails(rtInit, 1, 'Salesforce Production');  
        odProd.Org_Type__c = 'Salesforce Production';
        NI_Org_Details__c odSand = NI_TestClassData.createTestNiOrgDetails(rtInit, 2, 'Salesforce Sandbox'); 
        odSand.Org_Type__c = 'Salesforce Sandbox - Full';
        
        List<NI_Org_Details__c> lstOrgDetailInsert = new List<NI_Org_Details__c>();
        lstOrgDetailInsert.Add(odProd);
        lstOrgDetailInsert.Add(odSand);
        
        Database.Insert(lstOrgDetailInsert);
        
        List<NI_Org_Details__c> lstOrgDetailAsserts1 = new List<NI_Org_Details__c>([SELECT Id FROM NI_Org_Details__c WHERE Org_Name__c = 'TEST1' AND Org_Type__c = 'Salesforce Production']);
        system.assertEquals(1, lstOrgDetailAsserts1.Size());
        
        List<NI_Org_Details__c> lstOrgDetailAsserts2 = new List<NI_Org_Details__c>([SELECT Id FROM NI_Org_Details__c WHERE Org_Name__c = 'TEST2' AND Org_Type__c = 'Salesforce Sandbox - Full']);
        system.assertEquals(1, lstOrgDetailAsserts2.Size());
        
        NI_Org_Details_Installed_Packages__c insPkg = new NI_Org_Details_Installed_Packages__c();
        insPkg.Name='Salesforce1 and Chatter Apps';
        insPkg.Namespace_Prefix__c='sf_chttr_apps_test';
        insPkg.Publisher__c='Salesforce.com';
        insPkg.NI_Org_Details__c=lstOrgDetailAsserts2[0].Id;
        insert insPkg;
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // =======================================================================================================================================     
    @isTest static void test1()
    {
        
        FillAccount fillAccount = new FillAccount();
        
        fillAccount.isTest = true;
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name = 'LOD Support Admin' AND isActive = true];
        Id rtInit =  rt.Id;
        String orgId = UserInfo.getOrganizationId();
        
        orgId = orgId.substring(0, 15); 
        account primacc = NI_TestClassData.createTestAccount(1);
        primacc.c2g__CODABankAccountName__c = 'FFA Bank';
        primacc.c2g__CODABankAccountNumber__c = '007';
        primacc.c2g__CODABankCity__c = 'Pune';
        primacc.c2g__CODABankCountry__c = 'India';
        primacc.c2g__CODABankName__c = 'ABC Corp.';
        primacc.c2g__CODABankStateProvince__c = 'Maharashtra';
        primacc.c2g__CODABankSWIFTNumber__c = '00112233';
        primacc.c2g__CODABankStreet__c = 'Koregaon Park';
        insert primacc;
        
        NI_Org_Details__c orgdets = [SELECT Id, Name, Org_Name__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, Security_Token_Encrypted__c, Org_Type__c, RecordTypeId  
                                     FROM NI_Org_Details__c 
                                     WHERE Org_Name__c = 'TEST2' 
                                     AND Org_Type__c = 'Salesforce Sandbox - Full'];
        
        orgdets.Primary_Account__c = primacc.Id;
        orgdets.Security_Token_Encrypted__c = '123456789';        
        update orgdets;
        
        Test.startTest();
        
        fillAccount.account = new NI_Org_Details__c();
        fillAccount.account = [SELECT Id, Name, Primary_Account__c, Org_Name__c, Org_Type__c, Security_Token_Encrypted__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c 
                               FROM NI_Org_Details__c 
                               WHERE Id =: orgdets.Id];
        
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.sessionId = '00DP0000003oo7k!ARIAQMHvusZ12Pyo1fZmrAeEv5NJG5rV0tFMx5lay.PM.QqAwLRG9zGmLyqpHYYd8MpoL9pIKOpr6TJNPEhnx63s92pfcqVV';
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl('endPoint'));
     
        fillAccount.fill(); 
        
        StaticResource sr = [SELECT Id, body FROM StaticResource WHERE Name = 'Mock_Data_For_getPackageDataElement'];
        Blob bContents = sr.body;
        
        String contents = bContents.toString();
        
        fillAccount testparam = new fillAccount();
        string str = testparam.getPackageDataElement(contents, 1);
        
        Test.stopTest();
        
    }       
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // =======================================================================================================================================    
    @isTest static void test2()
    {
        
        FillAccount fillAccount = new FillAccount();
        
        fillAccount.isTest = true;
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name  = 'LOD Support Admin' AND isActive = true];
        Id rtInit =  rt.Id;
        String orgId = UserInfo.getOrganizationId();
        
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        account primacc = NI_TestClassData.createTestAccount(1);
        primacc.c2g__CODABankAccountName__c = 'FFA Bank';
        primacc.c2g__CODABankAccountNumber__c = '007';
        primacc.c2g__CODABankCity__c = 'Pune';
        primacc.c2g__CODABankCountry__c = 'India';
        primacc.c2g__CODABankName__c = 'ABC Corp.';
        primacc.c2g__CODABankStateProvince__c = 'Maharashtra';
        primacc.c2g__CODABankSWIFTNumber__c = '00112233';
        primacc.c2g__CODABankStreet__c = 'Koregaon Park';
        insert primacc;
        
        NI_Org_Details__c orgdets = [SELECT Id, Name, Org_Name__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, 
                                     Security_Token_Encrypted__c, Org_Type__c, RecordTypeId  
                                     FROM NI_Org_Details__c 
                                     WHERE Org_Name__c = 'TEST2' AND Org_Type__c = 'Salesforce Sandbox - Full'];
        
        orgdets.Primary_Account__c = primacc.id;
        orgdets.Security_Token_Encrypted__c = '123456789';
        
        update orgdets;

        Test.StartTest();
        
        fillAccount.account = new NI_Org_Details__c();
        fillAccount.account = [SELECT  Id,Name, Primary_Account__c, Org_Name__c, Org_Type__c, Security_Token_Encrypted__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c FROM NI_Org_Details__c WHERE Id =: orgdets.Id];
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.sessionId = '00DP0000003oo7k!ARIAQMHvusZ12Pyo1fZmrAeEv5NJG5rV0tFMx5lay.PM.QqAwLRG9zGmLyqpHYYd8MpoL9pIKOpr6TJNPEhnx63s92pfcqVV';
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());  
        
        fillAccount.fill();  
        
        StaticResource sr = [SELECT Id, body FROM StaticResource WHERE Name = 'Mock_Data_For_getPackageDataElement'];
        
        Blob bContents = sr.body;
        
        String contents = bContents.toString();
        
        fillAccount testparam = new fillAccount();
        string str = testparam.getPackageDataElement(contents, 1);
        
        Test.StopTest();
        
        List<NI_Org_Details_Installed_Packages__c> lstODInstPacks = new List<NI_Org_Details_Installed_Packages__c>(
            [SELECT Id, Name, Namespace_Prefix__c, Publisher__c, NI_Org_Details__c, Managed__c, Install_Date__c, 
             Version_Number__c, Status__c, Allowed_Licenses__c, Used_Licenses__c, Expiration_Date__c, Limits__c, 
             Apps__c, Tabs__c, Objects__c 
             FROM NI_Org_Details_Installed_Packages__c]
        );
    }              
    
    // ======================================================================================================================================= 
    // = TEST METHOD 3: 
    // ======================================================================================================================================= 
    @isTest static void test3() 
    {
        FillAccount fillAccount = new FillAccount();        
        fillAccount.fill();
        System.assert(fillAccount.result.ErrorOccured__c);
    }
 
}