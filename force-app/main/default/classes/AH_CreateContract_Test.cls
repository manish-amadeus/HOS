/****************************************************************************************
Name            : AH_CreateContract_Test
Author          : Bhuleshwar Deshpande
Created Date    : 09/18/2019     
Last Mod Date   :   
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Test class for AH_CreateContract_Cntlr
:            
******************************************************************************************/
@isTest  
public class AH_CreateContract_Test {
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        Test.startTest();
        
        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a.RecordTypeId = rtPropertyAccountId;
        insert a;
        
        // CREATE TEST OPPORTUNITY 
        Opportunity opp = NI_TestClassData.createTestOpportunity(2,a.Id);
        
        opp.Name = 'Test Opportunity ';
        opp.StageName = 'Prospecting';
        opp.Order_Status__c = 'Prospect';
        opp.Amount = 25000;
        opp.Opportunity_Source__c = 'Support';
        insert opp;
        
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST1
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Opportunity opp = [SELECT Id ,Name,Account.Name,AccountID FROM Opportunity WHERE Name = 'Test Opportunity'];
        
        Test.startTest();
        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_CreateContract;
        Test.setCurrentPage(pr);             
        
        // ADD URL PARAMS
        pr.getParameters().put('oppid', opp.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        Contract Con = new Contract ();
        ApexPages.standardController stdCon = new ApexPages.standardController(Con);
        AH_CreateContract_Cntlr ctrl = new AH_CreateContract_Cntlr(stdCon);
        ctrl.create_Contract();
        ctrl.strLayoutFields  ='[{"Header":"Contract Information","Columns":"2","Fields":[{"Field":"ContractNumber","isUpdatable":"false","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"AccountId","isUpdatable":"true","isRequired":"true"},{"Field":"StartDate","isUpdatable":"true","isRequired":"false"},{"Field":"Contract_Type__c","isUpdatable":"true","isRequired":"true"},{"Field":"Type_of_Term__c","isUpdatable":"true","isRequired":"true"},{"Field":"Core_Product_Involved__c","isUpdatable":"true","isRequired":"false"},{"Field":"EndDate","isUpdatable":"true","isRequired":"false"},{"Field":"Status","isUpdatable":"true","isRequired":"true"},{"Field":"Owner_Expiration_Notice_2__c","isUpdatable":"true","isRequired":"false"},{"Field":"Name","isUpdatable":"true","isRequired":"false"}]},{"Header":"Click Through Agreement Authorization","Columns":"2","Fields":[{"Field":"ct_Contact_ID__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Agreement_Version_Number__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Contact_Name__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Agreement_Version__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Contact_Title__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Has_Authority__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Contact_Email__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Physical_Signature__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_ContactIPAddress__c","isUpdatable":"true","isRequired":"false"},{"Field":"Asset__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_DateTime__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Address Information","Columns":"1","Fields":[{"Field":"BillingAddress","isUpdatable":"true","isRequired":"false"}]},{"Header":"Pricing and Payment Terms","Columns":"2","Fields":[{"Field":"VSOE_Tier_Classification__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Other","Columns":"1","Fields":[{"Field":"Description","isUpdatable":"true","isRequired":"false"}]},{"Header":"MTech Information","Columns":"2","Fields":[{"Field":"Sync_w_MTech_Org__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"MTech_Salesforce_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Time_Last_Synch_w_MTech__c","isUpdatable":"true","isRequired":"false"},{"Field":"Execution_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Expiration_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Billing_Frequency__c","isUpdatable":"true","isRequired":"false"},{"Field":"Price_Escalation__c","isUpdatable":"true","isRequired":"false"},{"Field":"Expenses__c","isUpdatable":"true","isRequired":"false"},{"Field":"Use_in_Aggregates__c","isUpdatable":"true","isRequired":"false"},{"Field":"Data_Retention_Months__c","isUpdatable":"true","isRequired":"false"},{"Field":"SLA__c","isUpdatable":"true","isRequired":"false"},{"Field":"Applicable_Law__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cancellation_Clause__c","isUpdatable":"true","isRequired":"false"},{"Field":"Annual_Cost__c","isUpdatable":"true","isRequired":"false"},{"Field":"Quantity__c","isUpdatable":"true","isRequired":"false"},{"Field":"Annual_Amount__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"Libra OnDemand Information","Columns":"2","Fields":[{"Field":"LOD_Salesforce_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LOD_ContractNumber__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Activated_By__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Activated_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_X60_Day_Renewal_Notice__c","isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Amount__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Amount_with_VAT__c","isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Billing_Cycle__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Bill_to_Account__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Channel__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_CreatedDate__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Contract_Entity__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Product_Type__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Contract_Subject__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Company_Signed_By_Contact__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Opportunity__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_CompanySigned_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_VAT_Amount__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Customer_Signed_By_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Billing_Check_Flag__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"},{"Field":"ActivatedDate","isUpdatable":"false","isRequired":"false"},{"Field":"ActivatedById","isUpdatable":"false","isRequired":"false"}]}]';
        ctrl.showSelectedRecord();
        
        Test.stopTest();
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST2
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {                 
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];
        
        Test.startTest(); 
        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_CreateContract;
        Test.setCurrentPage(pr);             
        // ADD URL PARAMS
        pr.getParameters().put('oppid', opp.Id);
        
        // INSTANTIATE PAGE CONTROLLER   
        Contract Con = new Contract ();
        ApexPages.standardController stdCon = new ApexPages.standardController(Con);
        AH_CreateContract_Cntlr ctrl = new AH_CreateContract_Cntlr(stdCon);
        ctrl.strLayoutFields  ='[{"Header":"Contract Information","Columns":"2","Fields":[{"Field":"ContractNumber","isUpdatable":"false","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"AccountId","isUpdatable":"true","isRequired":"true"},{"Field":"StartDate","isUpdatable":"true","isRequired":"false"},{"Field":"Contract_Type__c","isUpdatable":"true","isRequired":"true"},{"Field":"Type_of_Term__c","isUpdatable":"true","isRequired":"true"},{"Field":"Core_Product_Involved__c","isUpdatable":"true","isRequired":"false"},{"Field":"EndDate","isUpdatable":"true","isRequired":"false"},{"Field":"Status","isUpdatable":"true","isRequired":"true"},{"Field":"Owner_Expiration_Notice_2__c","isUpdatable":"true","isRequired":"false"},{"Field":"Name","isUpdatable":"true","isRequired":"false"}]},{"Header":"Click Through Agreement Authorization","Columns":"2","Fields":[{"Field":"ct_Contact_ID__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Agreement_Version_Number__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Contact_Name__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Agreement_Version__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Contact_Title__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Has_Authority__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Contact_Email__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_Physical_Signature__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_ContactIPAddress__c","isUpdatable":"true","isRequired":"false"},{"Field":"Asset__c","isUpdatable":"true","isRequired":"false"},{"Field":"ct_DateTime__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Address Information","Columns":"1","Fields":[{"Field":"BillingAddress","isUpdatable":"true","isRequired":"false"}]},{"Header":"Pricing and Payment Terms","Columns":"2","Fields":[{"Field":"VSOE_Tier_Classification__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Other","Columns":"1","Fields":[{"Field":"Description","isUpdatable":"true","isRequired":"false"}]},{"Header":"MTech Information","Columns":"2","Fields":[{"Field":"Sync_w_MTech_Org__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"MTech_Salesforce_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"Date_Time_Last_Synch_w_MTech__c","isUpdatable":"true","isRequired":"false"},{"Field":"Execution_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Expiration_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Billing_Frequency__c","isUpdatable":"true","isRequired":"false"},{"Field":"Price_Escalation__c","isUpdatable":"true","isRequired":"false"},{"Field":"Expenses__c","isUpdatable":"true","isRequired":"false"},{"Field":"Use_in_Aggregates__c","isUpdatable":"true","isRequired":"false"},{"Field":"Data_Retention_Months__c","isUpdatable":"true","isRequired":"false"},{"Field":"SLA__c","isUpdatable":"true","isRequired":"false"},{"Field":"Applicable_Law__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cancellation_Clause__c","isUpdatable":"true","isRequired":"false"},{"Field":"Annual_Cost__c","isUpdatable":"true","isRequired":"false"},{"Field":"Quantity__c","isUpdatable":"true","isRequired":"false"},{"Field":"Annual_Amount__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"Libra OnDemand Information","Columns":"2","Fields":[{"Field":"LOD_Salesforce_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Status__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LOD_ContractNumber__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Activated_By__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Activated_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_X60_Day_Renewal_Notice__c","isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Amount__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Amount_with_VAT__c","isUpdatable":"false","isRequired":"false"},{"Field":"LOD_Billing_Cycle__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Bill_to_Account__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Channel__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_CreatedDate__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Contract_Entity__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Product_Type__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Contract_Subject__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Company_Signed_By_Contact__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Opportunity__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_CompanySigned_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_VAT_Amount__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Customer_Signed_By_Id__c","isUpdatable":"true","isRequired":"false"},{"Field":"LOD_Billing_Check_Flag__c","isUpdatable":"false","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"},{"Field":"ActivatedDate","isUpdatable":"false","isRequired":"false"},{"Field":"ActivatedById","isUpdatable":"false","isRequired":"false"}]}]';
        ctrl.showSelectedRecord();
        ctrl.cancelSave();
        
        Test.stopTest();
    }
    
}