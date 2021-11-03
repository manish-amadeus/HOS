/****************************************************************************************
Name            : AH_CreateRemoteSites_Test Class
Author          : Shashikant Nikam
Created Date    : 4/22/2019
Last Mod Date   : 5/7/2019 
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-034473
Description     : Test Class for the AH_CreateRemoteSites Class 
                : 
                : 
******************************************************************************************/
@isTest
public class AH_CreateRemoteSites_Test 
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

    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: 
    // ======================================================================================================================================= //    
    @isTest static void testMethod1()
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
        
        PollingResult__c poll = new PollingResult__c();
        poll.AccountId__c = orgdets.id;
        poll.ErrorType__c = 'Unauthorized endpoint';
        poll.ErrorOccured__c = true;
        poll.Error__c = 'Unauthorized endpoint, please check Setup->Security->Remote site settings. endpoint =';
        poll.Endpoint_URL__c = 'https://xyzAA.salesforce.com/setup/systemOverview.apexp';
		insert poll;
        
 		List<PollingResult__c> pollList = new List<PollingResult__c>([SELECT ID,  Name,  Endpoint_URL__c, AccountId__c, AccountId__r.Org_Type__c, AccountId__r.Admin_Login_Name_Encrypted__c, AccountId__r.Admin_Password_Encrypted__c, AccountId__r.Security_Token_Encrypted__c  FROM PollingResult__c WHERE ErrorType__c = 'Unauthorized endpoint']);
        system.assertEquals(1, pollList.size(), 'Polling Result count object doesn\'t match');
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl('endPoint'));        

		AH_CreateRemoteSites sites = new AH_CreateRemoteSites(pollList[0], 'https://xyzAA.salesforce.com/setup/systemOverview.apexp');
        sites.login();
        
        system.assertEquals(true, sites.results[0].success, 'Failed while creating Remote Site Settings metadata.');
        system.assertEquals(true, sites.results1[0].success, 'Failed while creating Remote Site Settings metadata.');
        
        Test.stopTest();
    }
}