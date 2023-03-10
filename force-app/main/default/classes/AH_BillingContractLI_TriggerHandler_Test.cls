/****************************************************************************************
Name            : AH_BillingContractLI_TriggerHandler_Test
Author          : CLD Partners
Created Date    : 04/06/2017
Last Mod Date   : 06/03/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for AH_BillingContractLI_TriggerHandler
				: 
******************************************************************************************/
@isTest
public class AH_BillingContractLI_TriggerHandler_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START AH_BillingContractLI_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.startTest();  
        
        Billing_Contract__c blgCnrct = NI_TestClassData.createBillingContract(1);
        insert blgCnrct;
        
        Activity_Line_Item__c actLI = NI_TestClassData.createActivityLineItem(blgCnrct.Id);
        insert actLI;
        
        Billing_Contract_Line_Item__c bcli = NI_TestClassData.createBillingContract(blgCnrct.Id, actLI.Id);    
        insert bcli;
        
        Test.stopTest(); 
        
        system.debug(' *** END AH_BillingContractLI_TriggerHandler_Test.createTestData() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }


    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        system.debug(' *** START AH_BillingContractLI_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
        Test.startTest();          

        List<Billing_Contract_Line_Item__c> lstBLIs = new List<Billing_Contract_Line_Item__c>([SELECT Id FROM Billing_Contract_Line_Item__c]);
        system.assertEquals(1, lstBLIs.size());
        
        lstBLIs[0].Invoiced__c = true;
        database.update(lstBLIs);
        
        try
        {
            database.delete(lstBLIs);
        }
        catch (Exception ex)
        {
            system.assert(ex.getMessage().Contains('Cannot delete a billing contract line item that has been invoiced.'));
        }
        
        Test.stopTest(); 
        
        system.debug(' *** END AH_BillingContractLI_TriggerHandler_Test.test1() - NUMBER OF QUERIES = ' + Limits.getQueries());
        
    }        
        
        
}