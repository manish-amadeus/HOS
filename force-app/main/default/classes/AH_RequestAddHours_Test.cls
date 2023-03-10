/****************************************************************************************
Name            : AH_RequestAddHours_Test
Author          : Bhuleshwar Deshpande 
Created Date    : 10/19/2019
Last Mod Date   : 10/22/2019  
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Apex Test Class AH_RequestAddHours_Test which is a controller for 
: AH_RequestAddHours_Cntlr Controller.

******************************************************************************************/
@isTest 
public class AH_RequestAddHours_Test {

    //======================================================================================================================================= 
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
        
        Test.stopTest();
		
    }
     // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST1
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        Account acc=[Select ID from Account where Name='APEX TEST PROPERTY ACCOUNT 1' LIMIT 1];
        
        Test.startTest();
        // INSTANTIATE PAGE REFERENCE
        Opportunity reuestaddhours = new Opportunity();
        reuestaddhours.AccountId= acc.Id;
            
        PageReference pr = Page.AH_RequestAdditionalHours;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(reuestaddhours);
        AH_RequestAddHours_Cntlr cntlr = new AH_RequestAddHours_Cntlr(sc);       
        Test.setCurrentPage(pr);    
        
        
        cntlr.strLayoutFields = '[{"Header":"Information","Columns":"2","Fields":[{"Field":"Phase__c","isUpdatable":"true","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"Account__c","isUpdatable":"true","isRequired":"false"},{"Field":"Contact__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cluster__c","isUpdatable":"true","isRequired":"false"},{"Field":"Customer_Approval__c","isUpdatable":"true","isRequired":"false"},{"Field":"Asset__c","isUpdatable":"true","isRequired":"false"},{"Field":"Contracts_Manager__c","isUpdatable":"true","isRequired":"false"},{"Field":"License_Exemption__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Audit Results","Columns":"2","Fields":[{"Field":"License_Need__c","isUpdatable":"true","isRequired":"false"},{"Field":"Audit_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Actual_License_Need__c","isUpdatable":"true","isRequired":"false"},{"Field":"Peak_Usage_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Licenses_Owned__c","isUpdatable":"true","isRequired":"false"},{"Field":"Audit_Origin__c","isUpdatable":"true","isRequired":"true"},{"Field":"License_Variance__c","isUpdatable":"false","isRequired":"false"},{"Field":"Audit_Reason__c","isUpdatable":"true","isRequired":"false"},{"Field":"Active_Named_Users__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Notes__c","isUpdatable":"true","isRequired":"false"},{"Field":"Discovered_Revenue__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"},{"Field":"Data_Collection_Case_Created__c","isUpdatable":"true","isRequired":"false"},{"Field":"Has_No_DI__c","isUpdatable":"true","isRequired":"false"}]}]';
        cntlr.showSelectedRecord();
        cntlr.create_RequestOpportunity();
        
        system.debug('cntlr.opportunityObjNew : '+cntlr.opportunityObjNew.id);
        system.assertNotEquals(NULL, cntlr.opportunityObjNew.id, 'Record ID is null.');
        
        cntlr.cancelSave();   
            
        Test.stopTest();
    }
}