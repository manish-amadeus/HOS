/****************************************************************************************
Name            : AH_Finance_Request_Trigger_Handler_Test Class 
Author          : Stuart Emery
Created Date    : 9/18/2018
Last Mod Date   : 9/18/2018 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Test Class for the AH_Finance_Request_Trigger_Handler Class
                : 
				:
*****************************************************************************************/
@isTest
public class AH_Finance_Request_Trigger_Handler_Test 
{
    
    // CREATE TEST DATA
    @testSetup static void createTestData()
    {
        
        //CREATE A TEST ACCOUNT  
        Account a = NI_TestClassData.createTestAccount(1); 
        insert a;
        
    }
    
    // TEST INSERTING A RECORD
    @isTest static void testRecordInsert()
    {
        
        Test.startTest();
        
        Account a = [SELECT Id FROM Account Limit 1]; 
        
        //CREATE A TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
        insert fr;
        
        //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST REFLECTS THE TAX AMOUNT
        AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
        system.assertEquals(fr1.Net_Credit_Amount__c, 10);
        
        Test.stopTest();
    }
    
    
    // TEST UPDATING A RECORD  
    @isTest static void testRecordUpdate()
    {
        
        Test.startTest();
        
        Account a = [SELECT Id FROM Account Limit 1]; 
        
        //CREATE A TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
        insert fr;
        
        //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST REFLECTS THE TAX AMOUNT
        AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
        system.assertEquals(fr1.Net_Credit_Amount__c, 10);
        
        //UPDATE THE TAX AMOUNT
        fr1.Tax_Amount__c = 15;
        update fr1;
        
        //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST HAS BEEN UPDATED TO REFLECT THE NEW TAX AMOUNT
        AH_Finance_Request__c fr2 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
        system.assertEquals(fr2.Net_Credit_Amount__c, 15);    
        
        Test.stopTest();
    }
    
}