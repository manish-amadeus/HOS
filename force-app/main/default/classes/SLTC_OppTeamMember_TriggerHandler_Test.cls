/*******************************************************************************************
****************************************************************
Name 			: SLTC_OppTeamMember_TriggerHandler_Test
Author 			: Lamu Sreeharsha
Created Date 	: 4/29/2022
Last Mod Date 	: 4/29/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	: 
Description 	: Test Class for sltc_OppTeamMember_TriggerHandler
: 
*********************************************************************************************
*****************************************************************/
@isTest
private class SLTC_OppTeamMember_TriggerHandler_Test {
    
    // ==========================================================
    // Create Test Data
    // ==========================================================
    @testSetup static void setup(){      
        List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
        List<User> user_data = new List<User>();
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','SLTC_Sales_Manger'));
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Order Management','Order','Management','SLTC_Data_Governance_Team'));
        INSERT user_data;
        System.runAs(new User(Id=UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
       		INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true);
            requirePermission_data.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            for(PermissionSet ps: requirePermission_data){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));          
            }
            INSERT permissionassignment_data;
        }
        //run in context of Business Development Manager
        System.runAs(user_data[0]){
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('SLTC','Test','Approved', 'SLTC_Corporate', 'Preliminary',1);
            INSERT account_data;
            
            List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity');
            INSERT opportunity_data;
            
            List<Contact> contact_data = SLTC_TestDataFactory.createcontact('firstcontact', 'SLTC_Contact', account_data[0].Id,1);
            contact_data.addAll(SLTC_TestDataFactory.createcontact('secondcontact_data', 'SLTC_Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('thridcontact_data', 'SLTC_Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('fourthcontact_data', 'SLTC_Contact', account_data[0].Id,1));
            INSERT contact_data;
        }       
     } 
    
    // ============================================================================================================================
    // Test Method - User without Custom Permission cannot delete the opportunity Team Members when opportunity in Awaiting QA
    // =============================================================================================================================
    @isTest static void beforeDeleteRecord_AtAwaitingQA_PTest(){    
            User user_data = [SELECT Id FROM User where FirstName='Business Development' limit 1];
            User orderUser_data = [SELECT Id FROM User where FirstName='Order' limit 1];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, orderUser_data.Id));
            INSERT opportunityTeamMember_data;
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data){
               opportunity_data[0].StageName = 'Awaiting QA';
               opportunity_data[0].Win_Loss_Reason__c = 'Price';
               Test.startTest();
               update opportunity_data;
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);
               Test.stopTest();
               System.assertEquals(false, result.isSuccess());
            }
        }

	// =========================================================================================================================
    // Test Method - User with Custom Permission can delete the opportunity Team Members when opportunity in Awaiting QA
    // =========================================================================================================================
     @isTest private static void beforeDeleteRecord_AtAwaitingQA_NTest(){    
            User user_data = [SELECT Id FROM User where FirstName='Business Development' limit 1];
            User orderUser_data = [SELECT Id FROM User where FirstName='Order' limit 1];
          	List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = new List<Opportunity>();
            System.runAs(new User(Id=UserInfo.getUserId())){
               opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
               opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, orderUser_data.Id));
               INSERT opportunityTeamMember_data;
               PermissionSet requirePermission_data = new PermissionSet();
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Opportunity_Lock_stage_Awaiting_QA');
               PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data.id, PermissionSetId = requirePermission_data.Id);
               INSERT permissionassignment_data;
            }
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data){
               System.debug(FeatureManagement.checkPermission('SLTC_Bypass_Opportunity_Lock_stage_Awaiting_QA'));
               opportunity_data[0].StageName = 'Awaiting QA';
               opportunity_data[0].Win_Loss_Reason__c = 'Price';             
               Test.startTest();
               update opportunity_data;
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], true);  
               Test.stopTest();
               System.assertEquals(true, result.isSuccess());
            } 
        }
    
    // ==========================================================================================================================
    // Test Method - User without Custom Permission cannot delete the opportunity Team Members when opportunity in Closed Lost
    // =========================================================================================================================
    @isTest static void beforeDeleteRecord_AtClosedLost_PTest(){    
            User user_data = [SELECT Id FROM User where FirstName='Business Development' limit 1];
            User orderUser_data = [SELECT Id FROM User where FirstName='Order' limit 1];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, orderUser_data.Id));
            INSERT opportunityTeamMember_data;
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data){
               opportunity_data[0].StageName = 'Closed Lost';
               opportunity_data[0].Win_Loss_Reason__c = 'Duplicate Opportunity Exists';
               Test.startTest();
               update opportunity_data;
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);
               Test.stopTest();
               System.assertEquals(false, result.isSuccess());
            }
        }
    
    // =======================================================================================================================
    // Test Method - User with Custom Permission can delete the opportunity Team Members when opportunity in Closed Lost
    // ======================================================================================================================
     @isTest private static void beforeDeleteRecord_AtClosedLost_NTest(){    
            User user_data = [SELECT Id FROM User where FirstName='Business Development' limit 1];
            User orderUser_data = [SELECT Id FROM User where FirstName='Order' limit 1];
         	List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = new List<Opportunity>();
            System.runAs(new User(Id=UserInfo.getUserId())){
               opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
               opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, orderUser_data.Id));
               INSERT opportunityTeamMember_data;
               PermissionSet requirePermission_data = new PermissionSet();
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Opportunity_Lock_stage_ClosedLost');
               PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data.id, PermissionSetId = requirePermission_data.Id);
               INSERT permissionassignment_data;
            }
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data){
               opportunity_data[0].StageName = 'Closed Lost';
               opportunity_data[0].Win_Loss_Reason__c = 'Duplicate Opportunity Exists';             
               Test.startTest();
               update opportunity_data;
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);  
               Test.stopTest();
               System.assertEquals(true, result.isSuccess());
            } 
        }
    
    // =========================================================================================================================
    // Test Method - User without Custom Permission cannot delete the opportunity Team Members when opportunity in Closed Won
    // =========================================================================================================================
    @isTest private static void beforeDeleteRecord_AtClosedWon_PTest(){  
            User user_data = [SELECT Id FROM User where FirstName='Business Development' limit 1];
            User orderUser_data = [SELECT Id FROM User where FirstName='Order' limit 1];
            List<Contact> contact_data = [Select Id from Contact WHERE Account.Name Like '%SLTC_Test' LIMIT 4];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, orderUser_data.Id));
            INSERT opportunityTeamMember_data;
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data){
               opportunity_data[0].StageName = 'Closed Won';
               opportunity_data[0].Win_Loss_Reason__c = 'Price';
               //Create Contact Roles
               List<OpportunityContactRole> contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[0].Id,'Customer Project Contact');
               contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[1].Id,'Bill To'));
               contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[2].Id,'Sold To'));
               contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[3].Id,'Authorizer'));
               INSERT contactRoleList; 
                
               Test.startTest();
               update opportunity_data;
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);
               Test.stopTest();
               System.assertEquals(false, result.isSuccess());
            }
        }
    
    // ===================================================================================================================
    // Test Method - User with Custom Permission can delete the opportunity Team Members when opportunity in Closed Won
    // =====================================================================================================================
     @isTest private static void beforeDeleteRecord_AtClosedWon_NTest(){    
            User user_data = [SELECT Id FROM User where FirstName='Business Development' limit 1];
            User orderUser_data = [SELECT Id FROM User where FirstName='Order' limit 1];
            List<Contact> contact_data = [Select Id from Contact WHERE Account.Name Like '%SLTC_Test' LIMIT 4];
           
         	List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = new List<Opportunity>();
            System.runAs(new User(Id=UserInfo.getUserId())){
               opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
               opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, orderUser_data.Id));
               INSERT opportunityTeamMember_data;
               PermissionSet requirePermission_data = new PermissionSet();
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Opportunity_Lock_stage_Closed_Won');
               PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data.id, PermissionSetId = requirePermission_data.Id);
               INSERT permissionassignment_data;
            }
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data){
               opportunity_data[0].StageName = 'Closed Won';
               opportunity_data[0].Win_Loss_Reason__c = 'Price';
               //Create Contact Roles 
               List<OpportunityContactRole> contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[0].Id,'Customer Project Contact');
               contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[1].Id,'Bill To'));
               contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[2].Id,'Sold To'));
               contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[3].Id,'Authorizer'));
               INSERT contactRoleList;  
               Test.startTest();
               update opportunity_data;
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);  
               Test.stopTest();
               System.assertEquals(true, result.isSuccess());
            } 
     }

}