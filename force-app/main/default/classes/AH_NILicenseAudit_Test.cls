/****************************************************************************************
Name            : AH_NILicenseAudit_Test Class
Author          : Bhuleshwar Deshpande
Created Date    : 10/1/2019
Last Mod Date   : 10/1/2019
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : Test class for AH_NILicenseAudit_Cntlr class
                : 
******************************************************************************************/
@isTest
public class AH_NILicenseAudit_Test 
{
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
            
        Contact c1 = NI_TestClassData.createTestContact(1,a.Id);
        insert c1;
        
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
        NI_License_Audit__c niliaudit = new NI_License_Audit__c();
        niliaudit.Account__c= acc.Id;
          
        PageReference pr = Page.AH_NILicenseAudit;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(niliaudit);
        AH_NILicenseAudit_Cntlr cntlr = new AH_NILicenseAudit_Cntlr(sc);       
        Test.setCurrentPage(pr);    
        
        
        cntlr.strLayoutFields  ='[{"Header":"Information","Columns":"2","Fields":[{"Field":"Phase__c","isUpdatable":"true","isRequired":"false"},{"Field":"OwnerId","isUpdatable":"false","isRequired":"false"},{"Field":"Account__c","isUpdatable":"true","isRequired":"false"},{"Field":"Contact__c","isUpdatable":"true","isRequired":"false"},{"Field":"Cluster__c","isUpdatable":"true","isRequired":"false"},{"Field":"Customer_Approval__c","isUpdatable":"true","isRequired":"false"},{"Field":"Asset__c","isUpdatable":"true","isRequired":"false"},{"Field":"Contracts_Manager__c","isUpdatable":"true","isRequired":"false"},{"Field":"License_Exemption__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"Audit Results","Columns":"2","Fields":[{"Field":"License_Need__c","isUpdatable":"true","isRequired":"false"},{"Field":"Audit_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Actual_License_Need__c","isUpdatable":"true","isRequired":"false"},{"Field":"Peak_Usage_Date__c","isUpdatable":"true","isRequired":"false"},{"Field":"Licenses_Owned__c","isUpdatable":"true","isRequired":"false"},{"Field":"Audit_Origin__c","isUpdatable":"true","isRequired":"true"},{"Field":"License_Variance__c","isUpdatable":"false","isRequired":"false"},{"Field":"Audit_Reason__c","isUpdatable":"true","isRequired":"false"},{"Field":"Active_Named_Users__c","isUpdatable":"true","isRequired":"false"},{"Field":null,"isUpdatable":"false","isRequired":"false"},{"Field":"Notes__c","isUpdatable":"true","isRequired":"false"},{"Field":"Discovered_Revenue__c","isUpdatable":"true","isRequired":"false"}]},{"Header":"System Information","Columns":"2","Fields":[{"Field":"CreatedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"CreatedDate","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedById","isUpdatable":"false","isRequired":"false"},{"Field":", ","isUpdatable":"false","isRequired":"false"},{"Field":"LastModifiedDate","isUpdatable":"false","isRequired":"false"},{"Field":"Data_Collection_Case_Created__c","isUpdatable":"true","isRequired":"false"},{"Field":"Has_No_DI__c","isUpdatable":"true","isRequired":"false"}]}]';
        cntlr.showSelectedRecord();
        
        cntlr.nilisenauditObjNew.Account__c= acc.Id; 
            
        cntlr.create_NILicenseAudit();
        
        system.debug('cntlr.nilisenauditObjNew : '+cntlr.nilisenauditObjNew.id);
        //system.assertNotEquals(NULL, cntlr.nilisenauditObjNew.id, 'Record ID is null.');
        
        cntlr.cancelSave();   
        
        Test.stopTest();
    }
}