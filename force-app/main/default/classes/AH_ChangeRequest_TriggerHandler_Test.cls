/****************************************************************************************
Name            : AH_ChangeRequest_TriggerHandler_Test Test Class
Author          : Bhuleshwar Deshpande
Created Date    : 09/11/2018
Last Mod Date   : 09/14/2018
Last Mod By     : Bhuleshwar Deshpande
NICC Reference  : 
Description     : test Class for AH_ChangeRequest_TriggerHandler Class
: 
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
        
        // CREATE TEST DATA FOR PRODUCT GROUP.
        Product_Group__c proGroup = new Product_Group__c();
        proGroup.Name = 'PMS';
        Database.insert(proGroup);
        proGroup = [SELECT Id, Name FROM Product_Group__c WHERE Name = 'PMS'];
        System.assertEquals('PMS', proGroup.Name, 'Wrong Product Name');

        // CREATE TEST DATA FOR CHANGE REQUESTS
      	SFDC_CSP_Development_Request__c changeRequest = new SFDC_CSP_Development_Request__c();
        changeRequest.Type__c = 'Defect';
        changeRequest.Support_Priority__c = '2-High';
        changeRequest.Product_Group__c = proGroup.Id;
        changeRequest.Public_Status__c = 'New';
        changeRequest.Title__c = 'Test product review';
        changeRequest.Description__c = 'The product test';
        Database.insert(changeRequest);
        
        system.debug('CR RECORD:'+changeRequest);
        changeRequest = [SELECT Id, Public_Status_Description__c FROM SFDC_CSP_Development_Request__c];
        system.assertEquals('The Change Request is newly submitted and will be assigned an official Product Team status within 10 business days', changeRequest.Public_Status_Description__c, 'Error in Public_Status_Description__c');
        
        Test.stopTest();  
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void testMethod1()
    {
        List<SFDC_CSP_Development_Request__c> CRlst = new List<SFDC_CSP_Development_Request__c>();
        CRlst = [SELECT Id, Public_Status__c FROM SFDC_CSP_Development_Request__c];

        Test.startTest(); 
        
        CRlst[0].Public_Status__c = 'Product Team Review';
        Database.update(CRlst);  
        
        List<SFDC_CSP_Development_Request__c> updatedLst = new List<SFDC_CSP_Development_Request__c>();
        updatedLst = [SELECT Id, Public_Status_Description__c FROM SFDC_CSP_Development_Request__c];
        system.assertEquals('The Change Request is undergoing Product Team review for roadmap consideration and feedback', updatedLst[0].Public_Status_Description__c, 'Error in Public_Status_Description__c');
        
        Test.stopTest();
    }
    
}