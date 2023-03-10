/****************************************************************************************
Name            : AH_Manual_Cred_Lines_TriggerHandlerTest Class 
Author          : Stuart Emery
Created Date    : 9/17/2018
Last Mod Date   : 11/1/2018 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-030091
Description     : Test Class for the AH_Manual_Credit_Lines_TriggerHandler Class
                : 
				:
******************************************************************************************/  
@isTest
public class AH_Manual_Cred_Lines_TriggerHandlerTest
{
    
    // CREATE TEST DATA
    @testSetup static void createTestData()
    {
        
        //CREATE A TEST FINANCE REQUEST RECORD
        AH_Finance_Request__c fr = NI_TestClassData.createFinanceRequest();
        insert fr;
        
    }
    
    
    // TEST INSERTING A RECORD
    @isTest static void testRecordInsert()
    {
        
        Test.startTest();
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            AH_Finance_Request__c fr = [SELECT Id, CurrencyIsoCode FROM AH_Finance_Request__c LIMIT 1];
            
            //CREATE A TEST MANUAL CREDIT LINES RECORD
            AH_Manual_Credit_Lines__c mc = NI_TestClassData.createManualCreditLines(fr.Id);
            insert mc;
            
            //TEST THE BEFORE INSERT LOGIC FOR THE SetCurrency METHOD 
            //VERIFY THE CURRENCY ISO CODE ON THE AH_Manual_Credit_Lines__c RECORD
            //MATCHES THE CURRENCY ISO CODE ON THE FINANCE REQUEST OBJECT 
            AH_Manual_Credit_Lines__c mcli2 = [SELECT Id, CurrencyIsoCode FROM AH_Manual_Credit_Lines__c LIMIT 1];
            system.assertEquals(mcli2.CurrencyIsoCode, fr.CurrencyIsoCode);
            
            //VERIFY THE NET CREDIT AMOUNT ON THE FINANCE REQUEST HAS BEEN UPDATED APPROPRIATELY
            AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr1.Net_Credit_Amount__c, 110);
        }         
        Test.stopTest();
    }
    
    
    // TEST UPDATING A RECORD
    @isTest static void testRecordUpdate()
    {
        
        Test.startTest();
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            AH_Finance_Request__c fr = [SELECT Id FROM AH_Finance_Request__c LIMIT 1];            
            
            //CREATE A TEST FINANCE REQUEST RECORD
            AH_Manual_Credit_Lines__c mc = NI_TestClassData.createManualCreditLines(fr.Id);
            insert mc;
            
            AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr1.Net_Credit_Amount__c, 110);
            
            //GET THE INSERTED MANUAL CREDIT LINES RECORD
            AH_Manual_Credit_Lines__c mc2 = [SELECT Id, Requested_Credit_Amount__c FROM AH_Manual_Credit_Lines__c LIMIT 1];
            
            //UPDATE THE REQUESTED CREDIT AMOUNT
            mc2.Requested_Credit_Amount__c = 150;
            update mc2;
            
            //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST HAS BEEN UPDATED TO REFLECT THE NEW CREDIT AMOUNT
            AH_Finance_Request__c fr2 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr2.Net_Credit_Amount__c, 160);    
        }         
        Test.stopTest();
    }
    
    
    // TEST DELETING A RECORD
    @isTest static void testRecordDelete()
    {
        
        Test.startTest();
        system.runAs([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()][0]) 
        {
            
            AH_Finance_Request__c fr = [SELECT Id FROM AH_Finance_Request__c LIMIT 1];            
            
            //CREATE A TEST FINANCE REQUEST RECORD
            AH_Manual_Credit_Lines__c mc = NI_TestClassData.createManualCreditLines(fr.Id);
            insert mc;
            
            AH_Finance_Request__c fr1 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr1.Net_Credit_Amount__c, 110);
            
            //GET THE INSERTED MANUAL CREDIT LINES RECORD
            AH_Manual_Credit_Lines__c mc2 = [SELECT Id, Requested_Credit_Amount__c FROM AH_Manual_Credit_Lines__c LIMIT 1];
            
            //DELETE THE MANUAL CREDIT LINE RECORD
            delete mc2;
            
            //ASSERT THAT THE NET CREDIT AMOUNT ON THE FINANCE REQUEST HAS BEEN UPDATED TO REFLECT THE NEW CREDIT AMOUNT
            AH_Finance_Request__c fr2 = [SELECT Id, Net_Credit_Amount__c FROM AH_Finance_Request__c LIMIT 1];
            system.assertEquals(fr2.Net_Credit_Amount__c, 10);    
        }         
        Test.stopTest();
    }
    
}