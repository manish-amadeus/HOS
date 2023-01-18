/**********************************************************
******************************
Name :  SLTC_Opportunity_TriggerHandler_Test
Author : Jaswanth R
Created Date : 09/01/2022
Last Mod Date : 09/01/2022
Last Mod By :  Jaswanth R
NICC Reference : 
Description : Test Class for SLTC_Opportunity_TriggerHandler
: 
***********************************************************
*******************************/
@isTest
public class SLTC_Opportunity_TriggerHandler_Test {
    
    // ==========================================================
    // Create Test Data
    // ==========================================================
    
    @testSetup static void setup(){ 
        User user = SLTC_TestDataFactory.createuser('SLTC Sales','First','Last','WWSales'); 
        User user_exec = SLTC_TestDataFactory.createuser('SLTC Sales','Second','Last','WWSales'); 
        INSERT user;
        INSERT user_exec;
        PermissionSet requirePermission_data = new PermissionSet();
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Skip_the_contact_Role_ValIdation');
               //PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data.Id, PermissionSetId = requirePermission_data.Id);
               //INSERT permissionassignment_data;
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment = new List<PermissionSetAssignment>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            INSERT new NI_TriggerBypassSwitches__c(Name='Bypass Control Panel',BypassOpportunity_ON__c = true,BypassAccount_ON__c = true,  Bypass_AH_Opportunity_Related_Account__c = true);
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Proposal_Create_View_Modify'));
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Affiliation_CRUD_Access'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Brand_Edit_Access'));
            for(PermissionSet ps: requirePermission){
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
            }
            permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = requirePermission_data.Id));
        }
        INSERT permissionassignment;
        //stop running trigger code
        System.runAs(user){
            //create Account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','SLTC_Test','MDM Approved','SLTC_ParentAccount','Prospect',1);
            INSERT accountList;
            List<Account> accountList1 = SLTC_TestDataFactory.createAccounts('Property','SLTC_Property','MDM Approved','SLTC_Property','Prospect',1);
            INSERT accountList1;
            List<Account> accountListInvalId = SLTC_TestDataFactory.createAccounts('Property','SLTC_Account','MDM Approved','SLTC_Property','Prospect',1);
            INSERT accountListInvalId;
            //create Opportunity
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', accountList[0],1, 'SLTC_Opportunity');
            INSERT opportunityList;
            List<Opportunity> opportunityListChild = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', accountList[0],1, 'SLTC_Opportunity');
            opportunityListChild[0].pse__Parent_Opportunity__c=opportunityList[0].Id;
            opportunityListChild[0].SLTC_Opportunity_Description__c='CHILD123';
            INSERT opportunityListChild;
            //create Contact
            List<Contact> contactList = SLTC_TestDataFactory.createcontact('A Con', 'Contact', accountList[0].Id, 1);
            INSERT contactList;
            List<Contact> contactListAff = SLTC_TestDataFactory.createcontact('BB Con', 'Contact', accountList1[0].Id, 1);
            INSERT contactListAff;
            List<Contact> contactListInvalId = SLTC_TestDataFactory.createcontact('CCC Con', 'Contact', accountListInvalId[0].Id, 1);
            INSERT contactListInvalId;
            //create Proposal 
            Apttus_Proposal__Proposal__c proposal = SLTC_TestDataFactory.createProposal(accountList[0].Id, contactList[0].Id, opportunityList[0].Id, 'Proposal'); 
            INSERT proposal;
            // create Product
            List<Product2> productList = SLTC_TestDataFactory.createProduct('Test_Pro', 1);
            INSERT productList;
            //create Proposal Line Item 
            List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = SLTC_TestDataFactory.createProposalLineItem(proposal.Id, productList, 'New');
            INSERT proposalLineItemList;
            //Create a Agreement
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(accountList[0].Id, opportunityList[0].Id, contactList[0].Id, proposal.Id,'Order_Form'); 
            INSERT agreement_data;
        }
    } 
    
    // =================================================================================================
    // Test Method: Test Before Opportunity Closed-Won when only Customer Project Contact Role is added
    // =================================================================================================
    @isTest private static void oppContactRoleTestCustomerProjectContact(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest=[SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        List<OpportunityContactRole>contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Customer Project Contact');
        INSERT contactRoleList;
        System.runAs(userData)
        {
            Test.startTest();
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest, false);
            Test.stopTest(); 
            System.assertEquals(false, result.isSuccess(), 'Add Bill-To,Sold-To,Authorizer'); 
        }
    }  
    // ==========================================================================
    // Test Method: Test Before Opportunity Closed-Won when only Sold-To is added
    // ==========================================================================
    @isTest private static void oppContactRoleTestSoldTo(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest = [SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        List<OpportunityContactRole>contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Sold To');
        INSERT contactRoleList;
        System.runAs(userData)
        {
            Test.startTest();
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest, false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(), 'Add Bill-To,Customer Project Contact,Authorizer');  
        }
    }   
    // ==================================================================================================================
    // Test Method: Test Before Opportunity Closed-Won when only Bill-To  Role is added for Invoice type 'Ind to Ind'
    // ==================================================================================================================
    @isTest private static void oppContactRoleTestBillToMultiProperty(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest = [SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        List<OpportunityContactRole>contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Bill To');
        List<Apttus_Proposal__Proposal__c> proposalVar = [SELECT Id,Apttus_Proposal__Account__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Account__r.Name LIKE '%SLTC_Test' LIMIT 1];
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemId = [SELECT Id FROM  Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN : proposalVar LIMIT 1];
        proposalVar[0].SLTC_Type_of_Invoice__c = 'Ind to Ind';
        proposalLineItemId[0].Apttus_QPConfig__BillToAccountId__c = proposalVar[0].Apttus_Proposal__Account__c;
        System.runAs(userData)
        {
            Test.startTest();
            UPDATE proposalVar[0];
            UPDATE proposalLineItemId[0];
            INSERT contactRoleList;            
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest, false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(), 'Add Customer Project Contact,Sold-To,Authorizer');   
        }
    }   
    // ==================================================================================================================
    // Test Method: Test Before Opportunity Closed-Won when only Bill-To  Role is added for Invoice type 'Corp to Corp'
    // ==================================================================================================================
    @isTest private static void oppContactRoleTestBillToSingleProperty(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest = [SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        List<OpportunityContactRole>contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Bill To');
        List<Apttus_Proposal__Proposal__c> proposalVar = [SELECT Id,Apttus_Proposal__Account__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Account__r.Name LIKE '%SLTC_Test' LIMIT 1];
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemId = [SELECT Id FROM  Apttus_Proposal__Proposal_Line_Item__c WHERE Apttus_Proposal__Proposal__c IN : proposalVar LIMIT 1];
        proposalVar[0].SLTC_Type_of_Invoice__c = 'Corp to Corp';
        proposalLineItemId[0].Apttus_QPConfig__BillToAccountId__c = proposalVar[0].Apttus_Proposal__Account__c;
        System.runAs(userData)
        {
            Test.startTest();
            UPDATE proposalVar[0];
            UPDATE proposalLineItemId[0];
            INSERT contactRoleList;            
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest, false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(),  'Add Customer Project Contact,Sold-To,Authorizer');   
        }
    }   
    // =================================================================================================
    // Test Method: Test Before Opportunity Closed-Won when only Authorizer Role is added
    // =================================================================================================
    @isTest private static void oppContactRoleTestAuthorizer(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest = [SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName='First' limit 1];
        List<OpportunityContactRole>contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Authorizer');
        INSERT contactRoleList;
        System.runAs(userData)
        {
            Test.startTest();
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest,false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(),  'Add Customer Project Contact,Sold-To,Bill-To');  
        }
    }  
    // =============================================================================
    // Test Method: Test Before Opportunity Closed-Won when no contact role is added
    // =============================================================================
    @isTest private static void oppContactRoleTestNoContactRoles(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        System.runAs(userData)
        {
            Test.startTest();
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest, false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(),  'Add Customer Project Contact,Sold-To,Authorizer,Bill-To');  
        }
    }
    // =============================================================================
    // Test Method: Test Before Opportunity Closed-Won when All contact roles is added
    // =============================================================================
    @isTest private static void oppContactRoleTestAllContactRoles(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest = [SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        List<OpportunityContactRole>contactRoleList= SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Authorizer');
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Bill To'));
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Sold To'));
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Customer Project Contact'));
        INSERT contactRoleList;
        System.runAs(userData)
        {
            Test.startTest();
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest,false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(),'All contact roles were added ,Oppty was marked=>Closed Won ');  
        }
    }
    // =============================================================================
    // Test Method: Test Before Opportunity Closed-Won when All contact roles is added
    // =============================================================================
    @isTest private static void oppContactRoleTestExceptionHandling(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        Contact contactToTest = [SELECT Id FROM Contact WHERE Account.Name LIKE'%SLTC_Test' LIMIT 1];
        User userData = [SELECT Id FROM User WHERE FirstName = 'Second' limit 1];
        List<OpportunityContactRole>contactRoleList= SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Authorizer');
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Bill To'));
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Sold To'));
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityToTest.Id, contactToTest.Id, 'Customer Project Contact'));
        INSERT contactRoleList;
        System.runAs(userData)
        {
            Test.startTest();
            opportunityToTest.StageName = 'Closed Won';
            Database.SaveResult result = Database.update(opportunityToTest,false);
            Test.stopTest();
            System.assertEquals(false, result.isSuccess(),'Exception encountered');  
        }
    }
   
}