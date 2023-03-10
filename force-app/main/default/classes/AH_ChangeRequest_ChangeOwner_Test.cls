/************************************************************************************************
Name            : AH_ChangeRequest_ChangeOwner_Test Class
Author          : Shashikant Nikam 
Created Date    : 12/28/2020
Last Mod By     : Shashikant Nikam
Last Mod Date   : 01/05/2021
NICC Reference  : 
Description     : Test class for AH_ChangeRequest_ChangeOwner_Cntlr class 
                : Code Coverage : 90%
                : 
*************************************************************************************************/ 

@isTest
public class AH_ChangeRequest_ChangeOwner_Test {
	
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
        
        changeRequest = [SELECT Id, Public_Status_Description__c FROM SFDC_CSP_Development_Request__c];
        system.assertEquals('The Change Request is newly submitted and will be assigned an official Product Team status within 10 business days', changeRequest.Public_Status_Description__c, 'Error in Public_Status_Description__c');
        
        Test.stopTest();  
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void testMethod1()
    {
		List<SFDC_CSP_Development_Request__c> changeRequestList = [SELECT Id, Public_Status_Description__c, OwnerID FROM SFDC_CSP_Development_Request__c];
		system.debug('changeRequestList : '+changeRequestList);
        
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(changeRequestList);
        standardController.setSelected(changeRequestList);
        
        PageReference pageRef = Page.AH_ChangeRequest_ChangeOwner;
        test.setCurrentPage(pageRef);
        
        AH_ChangeRequest_ChangeOwner_Cntlr ctlr = new AH_ChangeRequest_ChangeOwner_Cntlr(standardController);
        
        // CREATE A COMMUNITY USER
        User u1 = NI_TestClassData.createTestUser(1024, 'System Administrator');
        u1.Alias = 'APEXSYSU';
        u1.UserRoleId = [SELECT Id FROM UserRole WHERE Name LIKE 'CEO%' LIMIT 1].Id;
        insert u1; 
        
        User u2 = NI_TestClassData.createTestUser(1025, 'System Administrator');
        u2.ManagerId = u1.Id;
        u2.Alias = 'APEXSLSU'; 
        insert u2;  
        
        System.runAs(u1){
            
            Test.startTest();
            
            ctlr.cr.OwnerId = u2.Id;
            
            ctlr.doSave();
            
            List<SFDC_CSP_Development_Request__c> changeRequestList1 = [SELECT Id, Public_Status_Description__c, OwnerID FROM SFDC_CSP_Development_Request__c];
            system.assertEquals(u2.Id, changeRequestList1[0].OwnerID);
            
            Test.stopTest();
        }
        
    }
    
    
    // ======================================================================================================================================= 
    // = TEST METHOD 2: 
    // ======================================================================================================================================= 
    @isTest static void testMethod2()
    {
		List<SFDC_CSP_Development_Request__c> changeRequestList = [SELECT Id, Public_Status_Description__c, OwnerID FROM SFDC_CSP_Development_Request__c];
        
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(changeRequestList);
        standardController.setSelected(changeRequestList);
        
        PageReference pageRef = Page.AH_ChangeRequest_ChangeOwner;
        test.setCurrentPage(pageRef);
        
        AH_ChangeRequest_ChangeOwner_Cntlr ctlr = new AH_ChangeRequest_ChangeOwner_Cntlr(standardController);
        
        Test.startTest();
        
        ctlr.doCancel();
        
        Test.stopTest();
    }
}