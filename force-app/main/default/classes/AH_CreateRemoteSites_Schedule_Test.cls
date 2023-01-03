/****************************************************************************************
Name            : AH_CreateRemoteSites_Schedule_Test Class
Author          : Shashikant Nikam
Created Date    : 4/24/2019
Last Mod Date   : 5/8/2019 
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-034473
Description     : Test Class for the AH_Schedule_CreateRemoteSites Class 
                : UPDATED 5/7/2019 PER NICC-034473
                : 
******************************************************************************************/
@isTest
public class AH_CreateRemoteSites_Schedule_Test 
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
    @isTest static void testSchedulableClass()
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
        
        Test.startTest();
        
        system.debug('test1');
        fillAccount.account = new NI_Org_Details__c();
        fillAccount.account = [SELECT  Id,Name, Primary_Account__c, Org_Name__c, Org_Type__c, Security_Token_Encrypted__c, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c FROM NI_Org_Details__c WHERE Id =: orgdets.Id];
        fillAccount.previous = new PollingResult__c();
        fillAccount.previous.DateTime__c = Datetime.newInstance(0);
        fillAccount.sessionId = '00DP0000003oo7k!ARIAQMHvusZ12Pyo1fZmrAeEv5NJG5rV0tFMx5lay.PM.QqAwLRG9zGmLyqpHYYd8MpoL9pIKOpr6TJNPEhnx63s92pfcqVV';
        
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl('endPoint'));        
        
        Datetime n = Datetime.now();                                                                                                                                                                                   
        n = n.addMinutes(5);                                                                                      
        String CRON_EXP = '0 ' + n.format('m') + ' ' + n.format('H') + ' ' + n.format('d') + ' ' + n.format('M') + ' ? '+ n.format('yyyy');
        
        AH_CreateRemoteSites_Schedule sh1 = new AH_CreateRemoteSites_Schedule();
        system.schedule('Test', CRON_EXP, sh1);
        
        List<AsyncApexJob> asyncJob = new List<AsyncApexJob>();
        asyncJob = [SELECT ApexClassId, CompletedDate, CreatedDate, Id, NumberOfErrors, Status 
                    FROM AsyncApexJob 
                    WHERE Status = 'Queued' 
                    AND ApexClassId IN (Select Id from ApexClass where Name = 'AH_CreateRemoteSites_Schedule')
                    ORDER BY CompletedDate DESC];
        System.debug('AsyncJob : '+asyncJob);
        System.assertEquals(1, asyncJob.size());

        Test.stopTest();
    }
}