/**********************************************************
*************************************
Name 				: SLTC_Request_AfterInsertRecordFlow_Test 
Author 				: Lamu Sreeharsha
Created Date 		: 11/22/22
Last Mod Date 		: 11/25/22
Last Mod By 		: Lamu Sreeharsha
NICC Reference 		: 
Description 		: Test class to test Run Immediately path for Flow: SLTC Request After update Flow and SLTC Case Set case queue

***********************************************************
*************************************/
@Istest
private class SLTC_Request_AfterUpdateRecordFlow_Test {
	
    // ==========================================================    
    // Create Test Data.
    // ==========================================================
     @testSetup static void setup(){
         List<User> user_data = new List<User>();
            user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','DirectorofSales','DOS','WWSales'));
            user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales'));
            user_data.add(SLTC_TestDataFactory.createuser('SLTC Order Management','ContractSupport','Team','CEOCFO'));
            user_data.add(SLTC_TestDataFactory.createuser('SLTC Customer Operations-Customer Experience','SupportRepresentatives','Team','CEOCFO'));
            INSERT user_data;
        
            List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        	List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
            System.runAs(new User(Id=UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
       		INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c = true,BypassContactSunsetContact__c =true, ByPassServiceNowIntegration_ON__c =true);
            requirePermission_data.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Proposal_Create_View_Modify'));
            
            for(PermissionSet ps: requirePermission_data){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[1].id, PermissionSetId = ps.Id)); 
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[2].id, PermissionSetId = ps.Id)); 
            }
            INSERT permissionassignment_data;
            }
           List<Account> account_data = New List<Account>();
           Apttus__APTS_Agreement__c agreement_data = New Apttus__APTS_Agreement__c();
           Apttus_Proposal__Proposal__c proposal_data = New Apttus_Proposal__Proposal__c();
           List<Opportunity> opportunity_data = New List<Opportunity>();    
           //run in context of Business Development
            System.runAs(user_data[1]){
            account_data = SLTC_TestDataFactory.createAccounts('Request','Test','MDM Approved', 'SLTC_Property', 'Preliminary',1);
            INSERT account_data; 
                                
            opportunity_data.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity'));
            INSERT opportunity_data;
                
            List<Contact> contact_data = SLTC_TestDataFactory.createcontact('firstcontact', 'Contact', account_data[0].Id,1);
            INSERT contact_data;
                
            //Create a Proposal 
            proposal_data = SLTC_TestDataFactory.createProposal(account_data[0].Id, contact_data[0].Id, opportunity_data[0].Id, 'Proposal'); 
            INSERT proposal_data;  
            
            //Create a Agreement
            agreement_data = SLTC_TestDataFactory.createAgreement(account_data[0].Id, opportunity_data[0].Id, contact_data[0].Id, proposal_data.Id,'Order_Form'); 
            INSERT agreement_data; 
         } 
         
         System.runAs(new User(Id=UserInfo.getUserId())){
            AccountTeamMember teamMember_data = SLTC_TestDataFactory.createAccountTeamMember(account_data[0].Id,user_data[0].Id,'Retention Manager');
            INSERT teamMember_data;     
            List<Product2> product = SLTC_TestDataFactory.createProduct('Web Solutions - Bundle', 1);
            INSERT product;  
            List<PricebookEntry> pricebookEntries = SLTC_TestDataFactory.createPricebookEntry(product);
            INSERT pricebookEntries;
            //run in context of Business Development 
            System.runAs(user_data[1]){
                Request__c request_data = SLTC_TestDataFactory.createTerminationRequest_AtAgreement(opportunity_data[0].Id, proposal_data.Id, agreement_data.Id);    
            	INSERT request_data;
            	}
            }  
    }
      
     // ============================================================================================================
    // Test Method for Termination Request When Status is set to pendingRetention.
    // ============================================================================================================
    @isTest public static void pendingRetentionStatusTest(){
        List<User> user_records = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='DirectorofSales' OR FirstName='ContractSupport' ORDER BY Name limit 3]; 
        Opportunity opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%Request_Test' LIMIT 1];
        Request__c requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c,OwnerId,Owner.Name FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id];
        System.runAs(user_records[1]){                                   
               Test.startTest();
               requestItem.OwnerId = user_records[1].Id; 
               requestItem.Request_Status__c = 'Pending retention';
               UPDATE requestItem;  
               Test.stopTest();
         } 
        requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id];
        Task task_record = [Select Id, OwnerId, WhatId, recordType.DeveloperName, Subject from Task WHERE WhatId =: requestItem.Id LIMIT 1];
        System.assertEquals(requestItem.Id,task_record.WhatId);
        System.assertEquals('SLTC_Termination_Retention',task_record.recordType.DeveloperName);
        System.assertEquals('Termination Retention Efforts',task_record.Subject);
        System.assertEquals(user_records[2].Id,task_record.OwnerId);
       } 
    
    // ============================================================================================================
    // Test Method for Termination Request When Status is set to Internally rejected, Internally approved.
    // ============================================================================================================
    @isTest public static void bellNotificationRequiredStatusTest(){
        List<User> user_records = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='DirectorofSales' OR FirstName='ContractSupport' ORDER BY Name limit 3];
        Opportunity opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%Request_Test' LIMIT 1];
        Request__c requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c,OwnerId FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id];
        System.runAs(user_records[1]){                                   
               Test.startTest();
               requestItem.OwnerId = user_records[1].Id; 
               requestItem.Request_Status__c = 'Internally approved';
               UPDATE requestItem;  
               Test.stopTest();
         } 
        requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id]; 
         System.assertEquals('Internally approved',requestItem.Request_Status__c); 
       } 
    
    // ============================================================================================================
    // Test Method for Termination Request When Status is set to completed.
    // ============================================================================================================
    @isTest public static void completedStatusTest(){
        List<User> user_records = [SELECT Id FROM User WHERE FirstName='Business Development' OR FirstName='DirectorofSales' OR FirstName='ContractSupport' ORDER BY Name limit 3];
        Opportunity opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%Request_Test' LIMIT 1];
        Request__c requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c,OwnerId FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id];
        System.runAs(user_records[1]){                                   
               Test.startTest();
               requestItem.OwnerId = user_records[1].Id; 
               requestItem.Request_Status__c = 'completed';
               UPDATE requestItem;  
               Test.stopTest();
         } 
        requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id]; 
         System.assertEquals('completed',requestItem.Request_Status__c); 
       } 
    
    // ============================================================================================================
    // Test Method for Termination Request When Status is set to TerminationInitiated and to test the Flow: SLTC Case Set case queue.
    // ============================================================================================================
    @isTest public static void terminationInitiatedStatusTest(){
        List<User> user_records = [SELECT Id,Name FROM User WHERE FirstName='Business Development' OR FirstName='ContractSupport' OR FirstName='DirectorofSales' OR FirstName='SupportRepresentatives' ORDER BY Name limit 4];
        Opportunity opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%Request_Test' LIMIT 1];
        Product2 product_record = [Select Id from Product2 WHERE Name LIKE '%Web Solutions - Bundle%'];
        Group terminationcase_queueId = [Select Id from Group WHERE DeveloperName = 'SLTC_Q_Terminations'];
        Request__c requestItem = [SELECT Id,Request_Status__c,Request_Contact__c,SLTC_RelatedProduct__c, Account__c,OwnerId,Owner.Name FROM Request__c WHERE Related_Opportunity__c =: opportunity_record.Id];
        Test.startTest();
        System.runAs(user_records[1]){                                   
               requestItem.OwnerId = user_records[1].Id; 
               requestItem.SLTC_RelatedProduct__c = product_record.Id;
               requestItem.Request_Status__c = 'Termination initiated';
               UPDATE requestItem;         
        }
        //After case is created. 
        List<Case> case_record = [Select Id,SLTC_Related_Request__c,recordType.DeveloperName,OwnerId from Case WHERE SLTC_Related_Request__c =: requestItem.Id];
        List<CaseShare> caseShareRecord = [SELECT Id, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId =:case_record[0].Id];
        
        System.assertEquals(requestItem.Id,case_record[0].SLTC_Related_Request__c);
        System.assertEquals('Case',case_record[0].recordType.DeveloperName);
        System.assertEquals(terminationcase_queueId.Id,case_record[0].OwnerId);
        System.assertEquals('Manual', caseShareRecord[0].RowCause);
        System.assertEquals(requestItem.Request_Contact__c,caseShareRecord[0].UserOrGroupId);
        
        //After case is Updated.
        System.runAs(new User(Id=UserInfo.getUserId())){
               case_record[0].OwnerId = user_records[3].Id; 
               UPDATE case_record;  
        }
        case_record = [Select Id,SLTC_Related_Request__c,recordType.DeveloperName,OwnerId from Case WHERE SLTC_Related_Request__c =: requestItem.Id];       
        System.assertEquals(user_records[3].Id,case_record[0].OwnerId);
        Test.stopTest();
       } 
}