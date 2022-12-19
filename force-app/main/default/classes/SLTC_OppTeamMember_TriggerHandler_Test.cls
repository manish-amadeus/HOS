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
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales'));
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Order Management','Order','Management','ContractsAdministrator'));
        user_data.add((SLTC_TestDataFactory.createuser('SLTC Sales','Director','Sales','WWSales')));
        user_data.add((SLTC_TestDataFactory.createuser('SLTC Order Management','contractSupport','Team','CEOCFO')));
        INSERT user_data;
        System.runAs(new User(Id=UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
       		INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c =true, BypassContactSunsetContact__c = true );
            requirePermission_data.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Proposal_Create_View_Modify'));
            
            for(PermissionSet ps: requirePermission_data){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[1].id, PermissionSetId = ps.Id));
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[3].id, PermissionSetId = ps.Id)); 
            }
            INSERT permissionassignment_data;
        }
        //run in context of Business Development Manager
        System.runAs(user_data[0]){
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('SLTC','Test','MDM Approved', 'SLTC_Property', 'Preliminary',1);
            INSERT account_data;
            
            List<Contact> contact_data = SLTC_TestDataFactory.createcontact('firstcontact', 'Contact', account_data[0].Id,1);
            contact_data.addAll(SLTC_TestDataFactory.createcontact('secondcontact_data', 'Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('thridcontact_data', 'Contact', account_data[0].Id,1));
            contact_data.addAll(SLTC_TestDataFactory.createcontact('fourthcontact_data', 'Contact', account_data[0].Id,1));
            INSERT contact_data;
            
            List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity');
            INSERT opportunity_data;
            
            List<OpportunityContactRole> contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[0].Id,'Customer Project Contact');
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[1].Id,'Bill To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[2].Id,'Sold To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunity_data[0].Id, contact_data[3].Id,'Authorizer'));
            INSERT contactRoleList;
            
            //Create a Proposal 
            Apttus_Proposal__Proposal__c proposal_data = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
            INSERT proposal_data;  
            
            //Create a Agreement
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data.Id,'Order_Form'); 
            INSERT agreement_data;  
            
        }       
     } 
    
    // ============================================================================================================================
    // Test Method - User without Custom Permission cannot delete the opportunity Team Members when opportunity in Awaiting QA
    // =============================================================================================================================
    @isTest static void beforeDeleteRecordAtAwaitingQAPositiveTest(){    
            List<User> user_data = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='Order' ORDER BY Name limit 2];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
            INSERT opportunityTeamMember_data;
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data[0]){ 
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
     @isTest static void beforeDeleteRecordAtAwaitingQANegativeTest(){    
           List<User> user_data = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='Order' ORDER BY Name limit 2];
          	List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = new List<Opportunity>();
            System.runAs(new User(Id=UserInfo.getUserId())){
               opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
               opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
               INSERT opportunityTeamMember_data;
               PermissionSet requirePermission_data = new PermissionSet();
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Opportunity_Lock_stage_Awaiting_QA');
               PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = requirePermission_data.Id);
               INSERT permissionassignment_data;
            }
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data[0]){ 
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
    @isTest static void beforeDeleteRecordAtClosedLostPositiveTest(){    
            List<User> user_data = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='Order' ORDER BY Name limit 2];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
            INSERT opportunityTeamMember_data;
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data[0]){
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
     @isTest static void beforeDeleteRecordAtClosedLostNegativeTest(){    
            List<User> user_data = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='Order' ORDER BY Name limit 2];
         	List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = new List<Opportunity>();
            System.runAs(new User(Id=UserInfo.getUserId())){
               opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
               opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
               INSERT opportunityTeamMember_data;
               PermissionSet requirePermission_data = new PermissionSet();
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Opportunity_Lock_stage_ClosedLost');
               PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = requirePermission_data.Id);
               INSERT permissionassignment_data;
            }
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data[0]){
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
    @isTest static void beforeDeleteRecordAtClosedWonPositiveTest(){
            List<User> user_data = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='Order' ORDER BY Name limit 2];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            Apttus_Proposal__Proposal__c proposal_record = [SELECT Id,Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c in: opportunity_data LIMIT 1];
            Apttus__APTS_Agreement__c Agreement_record = [SELECT Id,Apttus__Status_Category__c,Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Related_Opportunity__c in: opportunity_data  LIMIT 1]; 
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
            INSERT opportunityTeamMember_data;
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
             System.runAs(user_data[0]){ 
                   proposal_record.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            	   UPDATE proposal_record;                   
                   Agreement_record.Apttus__Status_Category__c = 'In Effect';
            	   Agreement_record.Apttus__Status__c = 'Activated';
           	 	   UPDATE Agreement_record;
                   //run in context of Order Management persona to set the stage to Closed won.
                   System.runAs(user_data[1]){ 
                       opportunity_data[0].StageName = 'Closed Won';
                       opportunity_data[0].Win_Loss_Reason__c = 'Price';
                       Test.startTest();
                       UPDATE opportunity_data;
                       System.runAs(user_data[0]){  
                           Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);
                           Test.stopTest();
                           System.assertEquals(false, result.isSuccess());
                       }
                }
             }
        }
    
    // ===================================================================================================================
    // Test Method - User with Custom Permission can delete the opportunity Team Members when opportunity in Closed Won
    // =====================================================================================================================
     @isTest static void beforeDeleteRecordAtClosedWonNegativeTest(){    
            List<User> user_data = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='Order' ORDER BY Name limit 2];
         	List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            Apttus_Proposal__Proposal__c proposal_record = [SELECT Id,Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c in: opportunity_data limit 1];
            Apttus__APTS_Agreement__c Agreement_record = [SELECT Id,Apttus__Status_Category__c,Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Related_Opportunity__c in: opportunity_data  limit 1];
            System.runAs(new User(Id=UserInfo.getUserId())){ 
               opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
               INSERT opportunityTeamMember_data;
               PermissionSet requirePermission_data = new PermissionSet();        
               requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Opportunity_Lock_stage_Closed_Won');
               PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = requirePermission_data.Id);
               INSERT permissionassignment_data;
            }
            //run in context of Business Development Manager to update the opportunity and delete the opportuntiy team members
            System.runAs(user_data[0]){ 
                   proposal_record.Apttus_Proposal__Approval_Stage__c = 'Accepted';
            	   UPDATE proposal_record;
                   Agreement_record.Apttus__Status_Category__c = 'In Effect';
            	   Agreement_record.Apttus__Status__c = 'Activated';
           	 	   UPDATE Agreement_record;
                   //run in context of Order Management persona to set the stage to Closed won.
                   System.runAs(user_data[1]){
                       opportunity_data[0].StageName = 'Closed Won';
                       opportunity_data[0].Win_Loss_Reason__c = 'Price';
                        Test.startTest();
                       UPDATE opportunity_data;
                       System.runAs(user_data[0]){ 
                           Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);  
                           Test.stopTest();
                           System.assertEquals(true, result.isSuccess());
                       }
                } 
            }
     }
    
    // ===================================================================================================================
    // Test Method - exclude user's with profile SLTC Data Governance, SLTC Sales Operations, SLTC Order Management  
    // =====================================================================================================================
     @isTest static void excludeProfileTest(){  
            List<User> user_data = [SELECT Id,FirstName,Name FROM User WHERE FirstName = 'Director' OR FirstName = 'contractSupport' ORDER BY Name limit 2];
            List<OpportunityTeamMember> opportunityTeamMember_data = new List<OpportunityTeamMember>();
            List<Opportunity> opportunity_data = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test' LIMIT 1];
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[0].Id));
            opportunityTeamMember_data.addAll(SLTC_TestDataFactory.createOpportunityTeamMember(opportunity_data, user_data[1].Id));
            INSERT opportunityTeamMember_data; 
            System.runAs(user_data[0]){ 
               opportunity_data[0].StageName = 'Awaiting QA';
               opportunity_data[0].Win_Loss_Reason__c = 'Price';
               Test.startTest();
               update opportunity_data; 
               Database.DeleteResult result = Database.delete(opportunityTeamMember_data[0], false);
               Test.stopTest();
               System.assertEquals(true, result.isSuccess());
            }
     }    
}