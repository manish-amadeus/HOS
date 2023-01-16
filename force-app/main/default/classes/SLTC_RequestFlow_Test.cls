/**********************************************************
*************************************
Name 				: SLTC_RequestFlow_Test 
Author 				: Lamu Sreeharsha
Created Date 		: 11/22/22
Last Mod Date 		: 11/25/22
Last Mod By 		: Lamu Sreeharsha
NICC Reference 		: 
Description 		: Test class to test Run Immediately path for Request Flow: SLTC Request Create Record Flow,  SLTC Request Before Insert/Update.
***********************************************************
*************************************/
@IsTest
public class SLTC_RequestFlow_Test {
    
    // ==========================================================    
    // Create Test Data
    // ==========================================================
     @testSetup static void setup(){
            List<User> user_data = new List<User>();
            user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales'));
            user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','DirectorofSales','DOS','WWSales'));
            INSERT user_data;
        
            List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        	List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
            System.runAs(new User(Id=UserInfo.getUserId())){
                //stop running old legacy trigger code and Assign the Required permission set to user.
                INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c = true,BypassContactSunsetContact__c =true);
                requirePermission_data.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
                requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
                requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
                requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Proposal_Create_View_Modify'));
                for(PermissionSet ps: requirePermission_data){
                    permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
                    permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[1].id, PermissionSetId = ps.Id)); 
                }
                INSERT permissionassignment_data;
            }
           List<Account> account_data = New List<Account>();
           Zuora__Subscription__c subscriptionrecord;
         
           //run in context of Business Development
            System.runAs(user_data[0]){
            account_data = SLTC_TestDataFactory.createAccounts('Request','Test','MDM Approved', 'SLTC_Property', 'Preliminary',1);
            INSERT account_data; 
                
            List<Opportunity> opportunity_data = New List<Opportunity>();
            opportunity_data.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity'));
            opportunity_data[0].SLTC_Opportunity_Description__c = 'ContractRequest';
            INSERT opportunity_data;
                
            List<Contact> contact_data = SLTC_TestDataFactory.createcontact('firstcontact', 'Contact', account_data[0].Id,1);
            INSERT contact_data;
            
            //Create a Proposal 
            Apttus_Proposal__Proposal__c proposal_data = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
            INSERT proposal_data;  
            
            //Create a Agreement
            Apttus__APTS_Agreement__c agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data.Id,'Order_Form'); 
            INSERT agreement_data; 
        }
        System.runAs(new User(Id=UserInfo.getUserId())){
               AccountTeamMember teamMember_data = SLTC_TestDataFactory.createAccountTeamMember(account_data[0].Id,user_data[1].Id,'Retention Manager');
               INSERT teamMember_data;
               subscriptionrecord = SLTC_TestDataFactory.createZuoraSubscription(account_data[0].Id);
               INSERT subscriptionrecord;
         }
    }
    
    // ============================================================================================================
    // Test Method on After Insert of Contract Request record. 
    // ============================================================================================================
    @isTest public static void createContractRequestTest(){
        User Salesrep_user = [SELECT Id FROM User WHERE FirstName='Business Development' limit 1];
        Account account_data = [Select Id from Account WHERE Name LIKE '%Request_Test' LIMIT 1]; 
        Opportunity opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%Request_Test' LIMIT 1];
        Request__c requestItem;
        //run in context of Business Development Manager
        System.runAs(Salesrep_user){                                   
            requestItem = SLTC_TestDataFactory.createContractRequest(opportunity_record.Id);
            Test.startTest();
            INSERT requestItem;
            Test.stopTest();
         } 
        Opportunity opportunity_result  = [SELECT Id,SLTC_Complexity__c FROM Opportunity WHERE Id =: opportunity_record.Id LIMIT 1];
        requestItem = [SELECT Id,Request_Contact__c,Account__c FROM Request__c WHERE Id =: requestItem.Id];
        System.assertEquals('Complex',opportunity_result.SLTC_Complexity__c);
        System.assertEquals(account_data.Id,requestItem.Account__c);
        System.assertEquals(Salesrep_user.Id,requestItem.Request_Contact__c); 
       }  
    
    // ============================================================================================================
    // Test Method on After/Before Insert of Termination Request Creation from Agreement or Proposal
    // ============================================================================================================
    @isTest public static void createTerminationRequestTest(){
        List<User> users_record = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='DirectorofSales' ORDER BY Name limit 2];
        Account account_data = [Select Id from Account WHERE Name LIKE '%Request_Test' LIMIT 1]; 
        Opportunity opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%Request_Test' LIMIT 1];
        Apttus_Proposal__Proposal__c proposal_record = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c =: opportunity_record.Id LIMIT 1];
        Apttus__APTS_Agreement__c Agreement_record = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Apttus__Related_Opportunity__c =: opportunity_record.Id  LIMIT 1];
        Request__c requestItem;
        //run in context of Business Development Manager
        System.runAs(users_record[0]){                                   
            requestItem = SLTC_TestDataFactory.createTerminationRequest_AtAgreement(opportunity_record.Id,proposal_record.Id,Agreement_record.Id);
            Test.startTest();
            INSERT requestItem;
            Test.stopTest();
       } 
        proposal_record = [SELECT Id,recordType.DeveloperName FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Opportunity__c =: opportunity_record.Id LIMIT 1];
        requestItem = [SELECT Id,Account__c,Request_Contact__c,SLTC_RetentionOwner__c FROM Request__c WHERE Id =: requestItem.Id];
        System.assertEquals('SLTC_Read_Only',proposal_record.recordType.DeveloperName);
        System.assertEquals(users_record[1].Id,requestItem.SLTC_RetentionOwner__c);
        System.assertEquals(account_data.Id,requestItem.Account__c);
        System.assertEquals(users_record[0].Id,requestItem.Request_Contact__c);
       } 
       
    // ============================================================================================================
    // Test Method on Before Insert of Termiantion Request Creation from Zuora Subscription  
    // ============================================================================================================
    @isTest public static void createTerminationAtSubscriptionTest(){
        List<User> users_record = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='DirectorofSales' ORDER BY Name limit 2];
        Account account_data = [Select Id from Account WHERE Name LIKE '%Request_Test' LIMIT 1];
        Zuora__Subscription__c subscription_record = [Select Id from Zuora__Subscription__c WHERE Zuora__Account__c =: account_data.Id LIMIT 1];
        Request__c requestItem;
        //run in context of Business Development Manager
        System.runAs(users_record[0]){                                   
            requestItem = SLTC_TestDataFactory.createTerminationRequest_AtZuora(account_data.Id,subscription_record.Id);
            Test.startTest();
            INSERT requestItem;
            Test.stopTest();
       } 
        requestItem = [SELECT Id,Request_Contact__c,SLTC_RetentionOwner__c FROM Request__c WHERE Id =: requestItem.Id];
        System.assertEquals(users_record[1].Id,requestItem.SLTC_RetentionOwner__c);
        System.assertEquals(users_record[0].Id,requestItem.Request_Contact__c);
       }
}