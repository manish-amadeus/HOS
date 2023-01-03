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

    // ======================================================================================================================================= //
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
        
        system.debug('odProd=='+odProd);
        system.debug('odSand=='+odSand);
        
        Database.Insert(lstOrgDetailInsert);
        
        List<NI_Org_Details__c> lstOrgDetailAsserts1 = new List<NI_Org_Details__c>([SELECT Id FROM NI_Org_Details__c WHERE Org_Name__c = 'TEST1' AND Org_Type__c = 'Salesforce Production']);
        system.debug('lstOrgDetailAsserts1=='+lstOrgDetailAsserts1);
        system.assertEquals(1, lstOrgDetailAsserts1.Size());
        
        List<NI_Org_Details__c> lstOrgDetailAsserts2 = new List<NI_Org_Details__c>([SELECT Id FROM NI_Org_Details__c WHERE Org_Name__c = 'TEST2' AND Org_Type__c = 'Salesforce Sandbox - Full']);
        system.debug('lstOrgDetailAsserts2=='+lstOrgDetailAsserts2);
        system.assertEquals(1, lstOrgDetailAsserts2.Size());
        
        /*NI_Org_Details_Installed_Packages__c:{Id=aJgq000000000ObCAI, 
        Name=Salesforce1 and Chatter Apps, Namespace_Prefix__c=sf_chttr_apps, 
        Publisher__c=Salesforce.com, NI_Org_Details__c=a4Oq00000004wjnEAA, 
        Managed__c=true, Install_Date__c=11/16/2015 4:58 PM, 
        Version_Number__c=1.11, Status__c=Free,
        Allowed_Licenses__c=N/A, Used_Licenses__c=N/A, 
        Expiration_Date__c=N/A, Limits__c=false, Apps__c=0, Tabs__c=0, Objects__c=0})*/
        
        NI_Org_Details_Installed_Packages__c insPkg = new NI_Org_Details_Installed_Packages__c();
        insPkg.Name='Salesforce1 and Chatter Apps';
        insPkg.Namespace_Prefix__c='sf_chttr_apps_test';
        insPkg.Publisher__c='Salesforce.com';
        insPkg.NI_Org_Details__c=lstOrgDetailAsserts2[0].Id;
        insert insPkg;
        
        
        
        /*Package_Namespace_Preefix__mdt pckPrefix = new Package_Namespace_Preefix__mdt();
        pckPrefix.DeveloperName = 'HRM';
        insert pckPrefix;*/
        
    }

    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //
    
    @isTest static void fillAccountTestError()
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
        system.debug('orgdets====' + orgdets);
        
        Test.startTest();
        
        system.debug('test1');
        fillAccount.account = new NI_Org_Details__c();
        fillAccount.account = [SELECT  Id,Name, Primary_Account__c, Org_Name__c, Org_Type__c, Security_Token_Encrypted__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c FROM NI_Org_Details__c WHERE Id =: orgdets.Id];
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.sessionId = '00DP0000003oo7k!ARIAQMHvusZ12Pyo1fZmrAeEv5NJG5rV0tFMx5lay.PM.QqAwLRG9zGmLyqpHYYd8MpoL9pIKOpr6TJNPEhnx63s92pfcqVV';
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl('endPoint'));        
        fillAccount.fill();  
        StaticResource sr = [SELECT Id, body FROM StaticResource WHERE Name = 'Mock_Data_For_getPackageDataElement'];
        Blob bContents = sr.body;

        String contents = bContents.toString();

        system.debug('contents'+contents);
        fillAccount testparam  = new fillAccount();
        string str = testparam.getPackageDataElement(contents,1);
        
        Test.stopTest();
    }       


    @isTest static void fillAccountTest()
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
        
        //createTestNiOrgDetails ( Id idRt,  Integer iRecordNumber,       String orgType ) 
//        NI_Org_Details__c orgdets = NI_TestClassData.createTestNiOrgDetails (rtInit, 1, 'Salesforce Sandbox - Developer' );
        NI_Org_Details__c orgdets = [SELECT Id, Name, Org_Name__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, 
                                Security_Token_Encrypted__c, Org_Type__c, RecordTypeId  
                                FROM NI_Org_Details__c 
                                WHERE Org_Name__c = 'TEST2' AND Org_Type__c = 'Salesforce Sandbox - Full'];
        
        orgdets.Primary_Account__c = primacc.id;
        orgdets.Security_Token_Encrypted__c = '123456789';
        
//        insert orgdets;
        update orgdets;
        system.debug('orgdets====' + orgdets);
        
        test.starttest();
        system.debug('test1');
        fillAccount.account = new NI_Org_Details__c();
        fillAccount.account = [SELECT  Id,Name, Primary_Account__c, Org_Name__c, Org_Type__c, Security_Token_Encrypted__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c FROM NI_Org_Details__c WHERE Id =: orgdets.Id];
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.sessionId = '00DP0000003oo7k!ARIAQMHvusZ12Pyo1fZmrAeEv5NJG5rV0tFMx5lay.PM.QqAwLRG9zGmLyqpHYYd8MpoL9pIKOpr6TJNPEhnx63s92pfcqVV';
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        fillAccount.fill();  
        system.debug('test2');
        StaticResource sr = [SELECT Id, body FROM StaticResource WHERE Name = 'Mock_Data_For_getPackageDataElement'];
        system.debug('test3');
        Blob bContents = sr.body;
        system.debug('test4');
        String contents = bContents.toString();
        system.debug('contents'+contents);
         fillAccount testparam  = new fillAccount();
        string str = testparam.getPackageDataElement(contents,1);
        
        test.stoptest();
        
            List<NI_Org_Details_Installed_Packages__c> lstODInstPacks = new List<NI_Org_Details_Installed_Packages__c>(
                [SELECT Id, Name, Namespace_Prefix__c, Publisher__c, NI_Org_Details__c, Managed__c, Install_Date__c, 
                 Version_Number__c, Status__c, Allowed_Licenses__c, Used_Licenses__c, Expiration_Date__c, Limits__c, 
                 Apps__c, Tabs__c, Objects__c 
                 FROM NI_Org_Details_Installed_Packages__c]
            );
        system.debug('lstODInstPacksExisting'+lstODInstPacks);
        
/*        
        FillAccount fillAccount = new FillAccount();
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
//        HttpResponse res = HttpCalloutMockImpl.respond();
        
        fillAccount.isTest = true;
        NI_Org_Details__c od = [SELECT Id, Name, Org_Name__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, 
                                Security_Token_Encrypted__c, Org_Type__c, RecordTypeId  
                                FROM NI_Org_Details__c 
                                WHERE Org_Name__c = 'TEST1' AND Org_Type__c = 'Salesforce Production'];
        fillAccount.account = od;
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.fill();     
        //System.assertEquals('PollingResult__c:{Error__c=, ErrorOccured__c=false, TotalReservations__c=0, TotalActiveSalesforcePlatformUsers__c=null, TotalLicensedSalesforceUsers__c=null, UnmanagedCustomApps__c=12, DateTime__c=1970-01-01 00:00:00, PackageStatus__c=Активно, HRMPackageVersion__c=1.373, DataStorageAllocation__c=0.244140625, TotalEmailCampaigns__c=0, ErrorType__c=, ApiAllocation__c=10000, DataStorageUsage__c=0.1412109375, TotalLicensedSalesforcePlatformUsers__c=null, PackageExpirationDate__c=Без срока действия, AccountId__c=null, PackageUsedLicenses__c=0, TotalMemberAccounts__c=0, ApiUsage__c=0, Name=1969-12-31 19:00:00, UnmanagedCustomTabs__c=0, TotalBookings__c=0, TotalActiveSalesforceUsers__c=null, ReportingPeriod__c=0, PackageAllowedLicenses__c=Не ограничено, UnmanagedCustomObjects__c=0}', string.valueOf(fillAccount.result));
*/        
    }              
    
    // ======================================================================================================================================= //
    // = TEST METHOD 2: 
    // ======================================================================================================================================= //
    @isTest static void testError() 
    {
        FillAccount fillAccount = new FillAccount();        
        fillAccount.fill();
        System.assert(fillAccount.result.ErrorOccured__c);
    }
    
    // ======================================================================================================================================= //
    // = TEST METHOD 3: 
    // ======================================================================================================================================= //

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
 /* @isTest static void fillAccountTest3()
    {

        FillAccount fillAccount = new FillAccount();

        fillAccount.isTest = true;
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name  = 'LOD Support Admin' AND isActive = true];
        Id rtInit =  rt.Id;
        String orgId = UserInfo.getOrganizationId();
        
        orgId = orgId.substring(0, 15); //SET THE ORGID TO THE 15 CHARACTER ORGID
        account primacc = NI_TestClassData.createTestAccount(1);
        insert primacc;
        
        //createTestNiOrgDetails ( Id idRt,  Integer iRecordNumber,       String orgType ) 
//        NI_Org_Details__c orgdets = NI_TestClassData.createTestNiOrgDetails (rtInit, 1, 'Salesforce Sandbox - Developer' );
        NI_Org_Details__c orgdets = [SELECT Id, Name, Org_Name__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, 
                                Security_Token_Encrypted__c, Org_Type__c, RecordTypeId  
                                FROM NI_Org_Details__c 
                                WHERE Org_Name__c = 'TEST2' AND Org_Type__c = 'Salesforce Sandbox - Full'];
        
        orgdets.Primary_Account__c = primacc.id;
        orgdets.Security_Token_Encrypted__c = '123456789';
        
//        insert orgdets;
        update orgdets;
        system.debug('orgdets====' + orgdets);
        
        test.starttest();
        system.debug('test1');
        fillAccount.account = new NI_Org_Details__c();
        fillAccount.account = [SELECT  Id,Name, Primary_Account__c, Org_Name__c, Org_Type__c, Security_Token_Encrypted__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c FROM NI_Org_Details__c WHERE Id =: orgdets.Id];
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.sessionId = '00DP0000003oo7k!ARIAQMHvusZ12Pyo1fZmrAeEv5NJG5rV0tFMx5lay.PM.QqAwLRG9zGmLyqpHYYd8MpoL9pIKOpr6TJNPEhnx63s92pfcqVV';
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl2());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        fillAccount.parsePackages();  

        test.stoptest();
         
    }              
*/ 
    
    
    
    
/*
  private class WebServiceMockImpl2 implements WebServiceMock 
  {
    public void doInvoke(
      Object stub, Object request, Map<String, Object> response,
      String endpoint, String soapAction, String requestName,
      String responseNS, String responseName, String responseType) 
    {
            if(request instanceof MetadataService.readMetadata_element){
                //MetadataService.readInstalledPackageResponse_element mr = new MetadataService.readInstalledPackageResponse_element();
        response.put('response_x', new MetadataService.readInstalledPackageResponse_element());
              return;
            }
            
            
            PartnerRemote.loginResponse_element  respElement =  new PartnerRemote.loginResponse_element();
         
         respElement.result = new PartnerRemote.LoginResult();
         respElement.result.serverUrl = 'd/services/d';
         respElement.result.sessionId = '';
         respElement.result.userInfo = new PartnerRemote.GetUserInfoResult();
         respElement.result.userInfo.organizationId = '';
         respElement.result.userInfo.organizationName = '';
         response.put('response_x', respElement); 
    }
  }
*/
    
    
    
    
    
}