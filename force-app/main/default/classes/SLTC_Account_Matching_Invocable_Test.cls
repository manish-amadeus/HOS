/**********************************************************
*************************************
Name :SLTC_Account_Matching_Invocable_Test
Author :Jaswanth R
Created Date :05-04-22
Last Mod Date :07-04-22
Last Mod By :Jaswanth R
NICC Reference :Description : Test Class used to Test SLTC_Account_Matching_Invocable invocable method 
                              which call from Flows (SLTC_Lead_Trigger_Handler_After_Insert_Update) to find out all the duplicate realted to lead company
***********************************************************
*************************************/
@isTest
private class SLTC_Account_Matching_Invocable_Test { 
   
    //Test method to find duplicate Account with same lead company name
    @isTest private static void testfindDuplicateAccount_bulk(){
        Id [] fixedSearchResults = new Id[1];
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SLTC_Lead').getRecordTypeId();
        List<Account> account_data = SLTC_TestDataFactory.createAccounts('Corporate','Test','Approved','SLTC_Corporate','Prospect',1);
        Insert account_data;
        
        Test.startTest();
        fixedSearchResults[0] = account_data[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<Lead> leads = SLTC_TestDataFactory.createLead(1, account_data[0].Name, recordTypeId);
        INSERT leads;
        Test.stopTest();
        Lead lead_data = [SELECT ID,SLTC_Duplicate_Account__c FROM LEAD];
        System.assertEquals(true , lead_data.SLTC_Duplicate_Account__c != null , 'Lead fild updated once it found account match');
       
        
    }
   
    //Test method to execute when no Account match found related to lead company name 
    @isTest private static void testfindDuplicateAccount_bulkNull(){
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SLTC_Lead').getRecordTypeId();
        List<Account> account_data = SLTC_TestDataFactory.createAccounts('Corporate','Test','Approved','SLTC_Corporate','Prospect',1);
        INSERT account_data;
        Test.startTest();
        List<Lead> lead_data = SLTC_TestDataFactory.createLead(1, 'test sltc', recordTypeId);
        INSERT lead_data;
        Test.stopTest();
        
        Lead lead_result = [SELECT ID,SLTC_Duplicate_Account__c FROM LEAD];
        System.assertEquals(false , lead_result.SLTC_Duplicate_Account__c != null , 'No matching record forund');
    }
   
    //test method when leads list is empSty
    @isTest private static void testfindDuplicateAccount_leadsNull(){
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SLTC_Lead').getRecordTypeId();
        List<Account> account_data = SLTC_TestDataFactory.createAccounts('Corporate','Test','Approved','SLTC_Corporate','Prospect',1);
        INSERT account_data;
     
        Test.startTest();
        
        List<Lead> leads = new List<Lead>();
        SLTC_Account_Matching_Invocable.findDuplicateAccount(new List<List<Lead>>{leads});
        Test.stopTest();
    }
}