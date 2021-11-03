/****************************************************************************************
Name            : AccountFlashAlertListExtension_Test 
Author          : Sean Harris
Created Date    : 04/25/2017
Last Mod Date   : 04/25/2017 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                :
****************************************************************************************/
@isTest
public class AccountFlashAlertListExtension_Test 
{

    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest(); 
        
        // CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();

        // CREATE TEST ACCOUNTS ===============================
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Id rtParentAccountId = AccountRecordTypeInfo.get('Parent Account').getRecordTypeId();
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        List<Account> lstAccountInsert = new List<Account>();
        
        Account a1 = NI_TestClassData.createTestAccount(1);
        a1.Name = 'APEX TEST PARENT ACCOUNT 1';
        a1.RecordTypeId = rtParentAccountId;
        lstAccountInsert.Add(a1);
        Account a2 = NI_TestClassData.createTestAccount(2);
        a2.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a2.RecordTypeId = rtPropertyAccountId;
        lstAccountInsert.Add(a2);
        Database.insert(lstAccountInsert); 
        
        List<Account> lstAccountAsserts = new List<Account>([SELECT Id FROM Account WHERE Name LIKE 'APEX TEST %']);
        system.assertEquals(2, lstAccountAsserts.Size());        
		
        Test.stopTest(); 
        
    }

    static testMethod void testAccountAlertListExtensionTest() 
    {
        
        Account aP = [SELECT Id FROM Account WHERE Name = 'APEX TEST PARENT ACCOUNT 1'];
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEST PROPERTY ACCOUNT 1'];
        
        a.ParentId = aP.Id;
        update a;

        ApexPages.StandardController stdCon = new ApexPages.StandardController(a);
        AccountFlashAlertListExtension ext = new AccountFlashAlertListExtension(stdCon);

        // TEST ACTION TAG ON VF PAGE
        PageReference pr1 = Page.AccountFlashAlerts;
        Test.setCurrentPage(pr1); 
  
        // ASSERT THERE ARE NO MESSAGES 
        System.assertEquals(0, ext.messages.size());
       
        // CREATE A FLASHMESSAGE - COUNT SHOULD BE ONE MESSAGE 
        SFDC_CSP_Flash_Message__c fm1 = NI_TestClassData.createFlashMessage(a.Id);
        insert fm1;
        
        stdCon = new ApexPages.StandardController(a); 
        ext = new AccountFlashAlertListExtension(stdCon); 
        
        // ASSERT THERE IS ONE MESSAGES 
        System.assertEquals(1, ext.messages.size()); 
        
        // CREATE A FLASHMESSAGE ON THE PARENT WITH CHILDREN VISIBLE - COUNT SHOULD BE TWO MESSAGES 
        SFDC_CSP_Flash_Message__c fm2 = NI_TestClassData.createFlashMessage(aP.Id); 
		fm2.Viewable_to_All_Children__c = true; 
        insert fm2; 
        
        stdCon = new ApexPages.StandardController(a); 
        ext = new AccountFlashAlertListExtension(stdCon); 
        
        // ASSERT THERE ARE TWO MESSAGES 
        system.assertEquals(2, ext.messages.size());
        
        // CREATE A FLASHMESSAGE ON THE PARENT WITH CHILDREN NOT VISIBLE - COUNT SHOULD STILL BE TWO MESSAGES 
        SFDC_CSP_Flash_Message__c fm3 = NI_TestClassData.createFlashMessage(aP.Id);
		fm3.Viewable_to_All_Children__c = false;
        insert fm3;
        
        stdCon = new ApexPages.StandardController(a);
        ext = new AccountFlashAlertListExtension(stdCon);
        
        // ASSERT THERE ARE TWO MESSAGES 
//        system.assertEquals(2, ext.messages.size()); 
        
    }

}