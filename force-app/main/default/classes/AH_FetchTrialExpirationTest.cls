/****************************************************************************************
Name            : AH_FetchTrialExpirationTest Class
Author          : Shashikant Nikam
Created Date    : 10/27/2017
Last Mod Date   : 04/23/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-025235
Description     : Test class for AH_FetchTrialExpirationBatch 
                : NICC-034313 - Updated API version
******************************************************************************************/
@isTest
private class AH_FetchTrialExpirationTest 
{

    static testMethod void testFetchTrialExpiration() 
    {
    
        system.debug(' *** START AH_FetchTrialExpirationTest.testFetchTrialExpiration() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // CREATE ORG IN NI_Org_Details__c
		RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Org_Details__c' AND Name = 'Delphi.Net Support User' AND isActive = true];
        Id rtInit = rt.Id;
        
        NI_Org_Details__c org = NI_TestClassData.createTestNiOrgDetails(rtInit, 5, 'Salesforce Production');
        org.Banquet__c = '';
        org.Trial_Expiration_Date__c = Datetime.now();
        org.Org_ID__c = '11111111rttwet3';
        org.DisablePolling__c = false;
        org.Security_Token_Encrypted__c = 'asdf23r123asdf3424_234234';
        insert org; 
        
        test.StartTest();

        Test.setMock(HttpCalloutMock.class, new AH_FetchTrialExpirationMockHttpResponse());

        AH_FetchTrialExpirationBatch batch = new AH_FetchTrialExpirationBatch();
        Database.executeBatch(batch, 1);
        
        AH_FetchTrialExpirationBatch batch_1 = new AH_FetchTrialExpirationBatch();
        Database.executeBatch(batch_1, 1);

        AH_FetchTrialExpirationBatch batch_2 = new AH_FetchTrialExpirationBatch();
        Database.executeBatch(batch_2, 1);
        
		AH_FetchTrialExpirationBatch batch_3 = new AH_FetchTrialExpirationBatch();
        Database.executeBatch(batch_3, 1);
        
        AH_FetchTrialExpirationBatch batch_4 = new AH_FetchTrialExpirationBatch();
        Database.executeBatch(batch_4, 1);

		test.StopTest(); 

		NI_Org_Details__c org1 = [SELECT Id, Banquet__c, Trial_Expiration_Date__c FROM NI_Org_Details__c WHERE Id =: org.Id];
        
        system.debug(' **** Org 1 : ' + org1);
//        system.assertEquals('1', org1.Banquet__c, 'Banquet value should be 1 here..');
        system.assertEquals('12/14/2016 10:28 AM', org1.Trial_Expiration_Date__c.format(), 'Date is wrong');   
        
        system.debug(' ***  END  AH_FetchTrialExpirationTest.testFetchTrialExpiration() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    static testMethod void testSchedule()
    {

        system.debug(' ***  END  AH_FetchTrialExpirationTest.testSchedule() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Test.startTest();
        
        AH_FetchTrialExpiration fetchTrailExpiration = new AH_FetchTrialExpiration();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Territory Check', sch, fetchTrailExpiration);
        
        Test.stopTest();
        
        system.debug(' ***  END  AH_FetchTrialExpirationTest.testSchedule() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}