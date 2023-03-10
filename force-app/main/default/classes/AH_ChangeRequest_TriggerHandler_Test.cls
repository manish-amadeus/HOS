/****************************************************************************************
Name            : AH_ChangeRequest_TriggerHandler_Test Test Class
Author          : Bhuleshwar Deshpande
Created Date    : 09/11/2018
Last Mod Date   : 11/09/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test Class for AH_ChangeRequest_TriggerHandler Class
                : 11/10/2021 Updated API to v52
                : 
******************************************************************************************/
@isTest
public class AH_ChangeRequest_TriggerHandler_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData()
    {
        
        Test.startTest();

		// CREATE WIN@PROACH & SERVICE NOW CUSTOM SETTINGS
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        AH_CaseFlagPreferences__c caseFlagSetting = NI_TestClassData.createCaseFlagPreferences();
        upsert caseFlagSetting;   
        
        // CREATE TEST PRODUCT GROUP RECORD
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;

        Product2 prd = NI_TestClassData.createProduct2(2, pgp.Id, 'APEX-TEST-25', 'Subscription');        
        insert prd;
        
        // CREATE TEST VERSION RECORD
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        // CREATE TEST PART RECORD
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        // CREATE TEST CHANGE REQUEST RECORD
        SFDC_CSP_Development_Request__c cr = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);
        cr.Type__c = 'Defect';
        cr.Support_Priority__c = '2-High';
        cr.Product_Group__c = pgp.Id;
        cr.Public_Status__c = 'New';
        cr.Title__c = 'Test product review';
        cr.Description__c = 'The product test';
        cr.Number_of_Cases_Linked__c = 0;
        insert cr;

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'AH_ChangeRequest_TriggerHandler_Test ACCOUNT';
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Change_Request__c = cr.Id;
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId();
        insert c;

        SFDC_CSP_Development_Request__c lstCRAssert = [SELECT Id, Public_Status_Description__c, Number_of_Cases_Linked__c FROM SFDC_CSP_Development_Request__c WHERE Id =: cr.Id];
        system.assertEquals('The Change Request is newly submitted and will be assigned an official Product Team status within 10 business days', lstCRAssert.Public_Status_Description__c, 'Error in Public_Status_Description__c');
        system.assertEquals(1, lstCRAssert.Number_of_Cases_Linked__c);
        
        // BACK OUT CASE COUNT FOR TESTING PURPOSES
        cr.Number_of_Cases_Linked__c = 0;
        update cr;
        
        Test.stopTest(); 
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: UNIT TEST FOR countLinkedCases METHOD
    // ======================================================================================================================================= 
    @isTest static void testMethod1()
    {
        
        List<SFDC_CSP_Development_Request__c> CRlst = new List<SFDC_CSP_Development_Request__c>([SELECT Id, Public_Status__c, Number_of_Cases_Linked__c FROM SFDC_CSP_Development_Request__c]);

        Test.startTest(); 
        
        CRlst[0].Public_Status__c = 'Product Team Review';
        Database.update(CRlst);  
        
        List<SFDC_CSP_Development_Request__c> lstAssert1 = new List<SFDC_CSP_Development_Request__c>([SELECT Id, Public_Status_Description__c, Number_of_Cases_Linked__c FROM SFDC_CSP_Development_Request__c]);
        system.assertEquals('The Change Request is undergoing Product Team review for roadmap consideration and feedback', lstAssert1[0].Public_Status_Description__c, 'Error in Public_Status_Description__c');
        
        // UNIT TEST FOR NEW METHOD ADDED FOR NICC-054506 - added countLinkedCases method
        system.assertEquals(1, lstAssert1.size());							// ASSERT THAT THERE IS ONLY 1 CR RECORD
        system.assertEquals(1, lstAssert1[0].Number_of_Cases_Linked__c);	// ASSERT THAT THE Number_of_Cases_Linked__c WAS UPDATED
        
        Test.stopTest();
        
    }
    
}