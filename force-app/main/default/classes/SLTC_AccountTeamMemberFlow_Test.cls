/*******************************************************************************************
****************************************************************
Name 			: SLTC_AccountTeamMemberFlow_Test
Author 			: Lamu Sreeharsha
Created Date 	: 4/29/2022
Last Mod Date 	: 4/29/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	: 
Description 	: Test Class for the Flow: SLTC Account Team Member Before Insert, SLTC Account Team Role Handler After Insert/Update.

*********************************************************************************************
*****************************************************************/
@isTest
private class SLTC_AccountTeamMemberFlow_Test {
     
    // ==========================================================
    // Create Test Data
    // ==========================================================
    @testSetup static void setup(){      
        List<User> user_data = new List<User>();
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','BusinessDevelopment','Manager','WWSales'));
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Data Governance','SalesProcess','Administrators','DirectorofMarketing'));
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Director','Sales','WWSales'));
        INSERT user_data;
        
        List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
       		INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c =true, BypassContactSunsetContact__c = true );
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            
            for(PermissionSet ps: requirePermission_data){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
            }
            INSERT permissionassignment_data;
        }
       List<Account> account_data = New List<Account>{}; 
        //run in context of BusinessDevelopment Manager
        System.runAs(user_data[0]){
                account_data.AddAll(SLTC_TestDataFactory.createAccounts('A','TestAccount','MDM Approved', 'SLTC_Property', 'Preliminary',1));
                INSERT account_data;
         }
        System.runAs(new User(Id=UserInfo.getUserId())){
             AccountTeamMember teamMember_data = new AccountTeamMember();
             teamMember_data = SLTC_TestDataFactory.createAccountTeamMember(account_data[0].Id, user_data[0].Id, 'Retention Manager');
             INSERT teamMember_data;  
        }
         
    }
    
    // ============================================================================================================================
    // Test Method To check that account has only one team member with role Retention Manager.
    // =============================================================================================================================
    @isTest static void recordBeforeInsertTest(){ 
        Account account_records = [Select Id from Account WHERE Type =: 'Preliminary' ORDER BY Name];
        List<User> user_records = [SELECT Id FROM User WHERE FirstName = 'SalesProcess' OR FirstName = 'Director' ORDER BY Name LIMIT 2];
        List<AccountTeamMember> teamMember_data = new List<AccountTeamMember>();
        System.runAs(user_records[1]){
             Test.startTest();
             teamMember_data.Add(SLTC_TestDataFactory.createAccountTeamMember(account_records.Id, user_records[0].Id, 'Retention Manager'));
             Database.SaveResult result = Database.insert(teamMember_data[0],false);
             System.assertEquals(false, result.isSuccess(),'Only one team member with role Retention Manager to the account is allowed');
             Test.stopTest();
        }
    }
    
    // ============================================================================================================================
    // Test Method on After Insert of Account Team Member.
    // =============================================================================================================================
    @isTest static void recordAfterInsertTest(){ 
        Account account_records = [Select Id from Account WHERE Type =: 'Preliminary' ORDER BY Name];
        List<User> user_records = [SELECT Id FROM User WHERE FirstName = 'SalesProcess' OR FirstName = 'Director' ORDER BY Name LIMIT 2];
        List<AccountTeamMember> teamMember_data = new List<AccountTeamMember>();
         System.runAs(user_records[1]){
             Test.startTest();
             teamMember_data.Add(SLTC_TestDataFactory.createAccountTeamMember(account_records.Id, user_records[0].Id, 'RVP'));
             INSERT teamMember_data;
             Test.stopTest();
        }
        teamMember_data = [Select Id from AccountTeamMember WHERE AccountId =: account_records.Id AND TeamMemberRole = 'RVP'];
        System.assertEquals(1, teamMember_data.Size(),'Account Teammember got Inserted successfully');
    }
}