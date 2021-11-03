/****************************************************************************************
Name            : AH_NewOpportunityRelAccount_Ext_Test
Author          : Ria Chawla
Created Date    : 04/30/2018
Last Mod Date   : 11/18/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_NewOpportunityRelAccount_Ext
				: Updated per NICC-039872
				: 
******************************************************************************************/
@isTest
public class AH_NewOpportunityRelAccount_Ext_Test
{
    
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        // GET RECORDTYPE INFO
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String, Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtLargeDealId = OpportunityRecordTypeInfo.get('Large Deal Opportunity').getRecordTypeId();
        
        List<Account> accountToInsert = new List<Account>();
        // CREATE ACCOUNT TEST RECORD
        Account a = NI_TestClassData.createTestAccount(1);
        accountToInsert.add(a);
        
        Account a2 = NI_TestClassData.createTestAccount(2);
        accountToInsert.add(a2);
        
        Account a3 = NI_TestClassData.createTestAccount(3);
        accountToInsert.add(a3);
        insert accountToInsert;
        
        test.startTest(); 
        
        // CREATE OPPORTUNITY RECORDS 
        List<Opportunity> lstOppInserts = new List<Opportunity>();
        Opportunity opp1 = NI_TestClassData.createTestOpportunity(1, a.Id); 
        opp1.Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!';
        opp1.RecordTypeId = rtLargeDealId;
        lstOppInserts.add(opp1);
        Database.Insert(lstOppInserts);
        
        Contact c = NI_TestClassData.createTestContact(1, a.Id);
        c.FirstName = 'Apex';
        c.LastName = 'Testuser';        
        insert c; 
        
        test.stopTest(); 
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: TEST AFTER INSERT AND AFTER UPDATE
    // =======================================================================================================================================     
    @isTest static void linkAccountWithProduct1() 
    {    
        
        test.startTest();
        
        //INSERT CUSTOM SETTINGS TO CONSIDER PRODUCT'S FAMILY FOR QUANTITY CALCULATION
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit);
        insert prodFamUnitList;
        
        //GET OPPORTUNITY        
        Opportunity opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c
                            FROM Opportunity 
                            WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        
        //GET ACCOUNTS
        List<Account> accList = new List<Account>();
        accList = [SELECT Id,Name FROM Account WHERE Id != :opp2.AccountId];
        system.debug('accList.size() : '+accList.size());
        system.assertEquals(2, accList.size());
        
        //INSERT A NEW AH_Opportunity_Related_Account__c RECORD
        AH_Opportunity_Related_Account__c oppRelatedAcc = new AH_Opportunity_Related_Account__c();
        oppRelatedAcc.Opportunity__c = opp2.Id;
        oppRelatedAcc.Account__c = accList[0].Id;
        insert oppRelatedAcc;
        
        //CREATE A NEW STANDARD CONTROLLER
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp2);
        
        //SET PAGE REFERENCE TO 'AH_NewOpportunityRelAccount' VF PAGE
        PageReference PageRef = Page.AH_NewOpportunityRelAccount;
        Test.setCurrentPage(PageRef);
        
        //SET PARAMETER OF URL
        ApexPages.currentPage().getParameters().put('retURL', '/' + opp2.Id);      
        
        //INITIATE EXTENSION
        AH_NewOpportunityRelAccount_Ext newOppRelatedAccCtrl = new AH_NewOpportunityRelAccount_Ext(stdCtrl);
        
        //SET PARAMETERS OF EXTENSION
        newOppRelatedAccCtrl.oppAccObj.Account__c = accList[1].Id;
        newOppRelatedAccCtrl.oppAccObj.Opportunity__c = opp2.Id;
        
        //CALL METHOD TO ADD ACCOUNT TO WRAPPER LIST AND ASSERT TO CHECK ACCOUNT IS ADDED TO THE LIST OF VF PAGE
        newOppRelatedAccCtrl.addAccount();
        system.debug('Wrapper list size : '+newOppRelatedAccCtrl.relatedAccWrapperList.size());
        System.assertEquals(2, newOppRelatedAccCtrl.relatedAccWrapperList.size());
        
        //SELECT AND DE-SELECT TO RELATE/UN-RELATE TO OPPORTUNITY AND ASSERT TO CHECK RELATED ACCOUNTS
        newOppRelatedAccCtrl.relatedAccWrapperList[1].isSelected = true;
        newOppRelatedAccCtrl.relatedAccWrapperList[0].isSelected = false;
        newOppRelatedAccCtrl.relateToOpportunity();
        List<AH_Opportunity_Related_Account__c> relatedAccounts = new List<AH_Opportunity_Related_Account__c>();
        relatedAccounts = [SELECT Id, Account__r.Name FROM AH_Opportunity_Related_Account__c WHERE Opportunity__c = :opp2.Id];
        system.assertEquals(1, relatedAccounts.size());
        
        //CALL METHODS OF PAGE
        newOppRelatedAccCtrl.returnBack();
        newOppRelatedAccCtrl.doSave();
        
        test.stopTest(); 
        
    } 
    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: ADDED BY SHASHIKANT TO TEST PAGINATION 
    // =======================================================================================================================================    
    @isTest static void linkAccountWithProduct2() 
    {    
        
        Test.startTest();
        
        //INSERT CUSTOM SETTINGS TO CONSIDER PRODUCT'S FAMILY FOR QUANTITY CALCULATION
        List<AH_Products_Family_Unit__c> prodFamUnitList = new List<AH_Products_Family_Unit__c>();
        AH_Products_Family_Unit__c prodFamUnit = new AH_Products_Family_Unit__c();
        prodFamUnit.Name = 'Subscription';
        prodFamUnitList.add(prodFamUnit);
        insert prodFamUnitList;
        
        //GET OPPORTUNITY        
        Opportunity opp2 = [SELECT Id, Name, AccountId, StageName, Order_Status__c
                            FROM Opportunity 
                            WHERE Name = '!! APEX TEST WITH LARGE DEAL OPPORTUNITY RECORD TYPE !!'];
        
        //GET ACCOUNTS
        Account aa = [SELECT Id, Name FROM Account WHERE Id =: opp2.AccountId];
        
        
        // INSERT MANY MORE THAN 200 ACCOUNTS HERE
        List<Account> accountToInsert = new List<Account>();
        
        for(Integer i = 6; i <= 50; i++)
        {
            // CREATE ACCOUNT TEST RECORD
            Account a = NI_TestClassData.createTestAccount(i);
            a.ParentId = aa.id;
            accountToInsert.add(a);
        }
        
        Database.insert(accountToInsert);
        
        
        //CREATE A NEW STANDARD CONTROLLER
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp2);
        
        //SET PAGE REFERENCE TO 'AH_NewOpportunityRelAccount' VF PAGE
        PageReference PageRef = Page.AH_NewOpportunityRelAccount;
        Test.setCurrentPage(PageRef);
        
        //SET PARAMETER OF URL
        ApexPages.currentPage().getParameters().put('retURL', '/' + opp2.Id);      
        
        //INITIATE EXTENSION
        AH_NewOpportunityRelAccount_Ext newOppRelatedAccCtrl = new AH_NewOpportunityRelAccount_Ext(stdCtrl);
        
        system.assertEquals(2, newOppRelatedAccCtrl.totalPages);
        
        //CALL METHODS OF PAGE
        newOppRelatedAccCtrl.gethasNext();
        newOppRelatedAccCtrl.next();
        
        newOppRelatedAccCtrl.gethasPrevious();
        newOppRelatedAccCtrl.previous();
        
        test.stopTest(); 
        
    } 
    
}