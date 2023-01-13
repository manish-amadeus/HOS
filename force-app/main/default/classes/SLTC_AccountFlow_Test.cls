/*******************************************************************************************
****************************************************************
Name 			: SLTC_AccountFlow_Test
Author 			: Lamu Sreeharsha
Created Date 	: 4/29/2022
Last Mod Date 	: 4/29/2022
Last Mod By 	: Lamu Sreeharsha
NICC Reference 	: 
Description 	: Test Class for the Flow: SLTC_Account_Handler_After_Insert_Update, SLTC Account Before Insert/Update Flow. 
: 
*********************************************************************************************
*****************************************************************/
@Istest
private class SLTC_AccountFlow_Test {
     
    // ==========================================================
    // Create Test Data
    // ==========================================================
    @testSetup static void setup(){      
        List<User> user_data = new List<User>();
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Adrienne','Agamasu','WWSales'));
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales Operations','SalesOpsLeaders','&PowerUsers','DirectorofMarketing'));
        user_data.Add(SLTC_TestDataFactory.createuser('NI Finance','CollectionsAccountsReceivable','Persona','Finance'));
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Elizabeth','Fuller','WWSales'));
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Director','Sales','WWSales'));
        user_data.Add(SLTC_TestDataFactory.createuser('SLTC Sales','Amit','Mandal','WWSales'));
        
        user_data[0].SLTC_Account_Owner_Notification__c = true;
        user_data[4].SLTC_Account_Owner_Notification__c = true;    
        INSERT user_data;
        
        List<PermissionSet> requirePermission_data = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment_data= new List<PermissionSetAssignment>();
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            //stop running old legacy trigger code and Assign the Required permission set to user.
       		INSERT new NI_TriggerBypassSwitches__c(Name ='Bypass Control Panel', BypassOpportunity_ON__c = true, BypassAccount_ON__c = true, Bypass_AH_Opportunity_Related_Account__c = true, Bypass_Contact__c =true, BypassContactSunsetContact__c = true );
            requirePermission_data.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission_data.Add(SLTC_TestDataFactory.createPermissionSet('SLTC_Bypass_Account_Owner_Lock'));
            requirePermission_data.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Collections_Accounts_Receivable_Persona_Permission_Set'));
            
            for(PermissionSet ps: requirePermission_data){
                if(ps.Name != 'SLTC_Bypass_Account_Owner_Lock' || ps.Name != 'SLTC_Collections_Accounts_Receivable_Persona_Permission_Set'){
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[0].id, PermissionSetId = ps.Id));
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[1].id, PermissionSetId = ps.Id));
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[2].id, PermissionSetId = ps.Id));  
                permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[3].id, PermissionSetId = ps.Id));  
                }
                else{
                    If((ps.Name == 'SLTC_Collections_Accounts_Receivable_Persona_Permission_Set') == true){
                        permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[2].id, PermissionSetId = ps.Id));
                    }else{
                        permissionassignment_data.add(new PermissionSetAssignment(AssigneeId = user_data[1].id, PermissionSetId = ps.Id));
                    }
                }
            }
            INSERT permissionassignment_data;
        }
        List<Account> account_data = New List<Account>{};
        //run in context of Anna Ransom Manager
         System.runAs(user_data[0]){ 
            Apttus_Config2__TaxCertificate__c tax_record = SLTC_TestDataFactory.createTaxcertificate('Alabama'); 
            INSERT tax_record;
            account_data.AddAll(SLTC_TestDataFactory.createAccounts('A','TestAccount','MDM Approved', 'SLTC_Property', 'Preliminary',1));
            account_data.AddAll(SLTC_TestDataFactory.createAccounts('B','TestAccount','MDM Approved', 'SLTC_Property', 'Preliminary',1)); 
            account_data[0].Apttus_Config2__TaxExemptStatus__c = 'Exempt';
            account_data[0].Apttus_Config2__CertificateId__c = tax_record.Id;
            //set the shipping address
            account_data[0].ShippingCountry = 'Canada';
            account_data[0].ShippingState = 'Alberta';
            account_data[0].ShippingStreet = '56 Avenue Northwest';
            account_data[0].ShippingCity = 'Edmonton';
            account_data[0].ShippingPostalCode = '2000'; 
            //set the billing address 
            account_data[1].BillingCountry = 'Australia';
            account_data[1].BillingState = 'New South Wales';
            account_data[1].BillingStreet = '264 George Street';
            account_data[1].BillingCity = 'Sydney';
            account_data[1].BillingPostalCode = '2000';
            //Set the shipping address Shipping
            account_data[1].ShippingCountry = 'India';
            account_data[1].ShippingState = 'Karnataka';
            account_data[1].ShippingStreet = '264 George Street';
            account_data[1].ShippingCity = 'Bengaluru';
            account_data[1].ShippingPostalCode = '560005';
            INSERT account_data;
             
            List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[0], 1, 'SLTC_Opportunity');
            opportunity_data.AddAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_data[1], 1, 'SLTC_Opportunity')); 
            INSERT opportunity_data;
         }
        System.runAs(user_data[2]){
            List<Account> account_record = SLTC_TestDataFactory.createAccounts('C','AccountTest','MDM Approved', 'SLTC_Property', 'Preliminary',1);
            INSERT account_record;
            account_data[1].SLTC_Credit_Hold__c = true;
            account_data[1].SLTC_Credit_Hold_Reason__c = 'Sent to 3rd party collections';
            UPDATE  account_data[1];
        }
    }
    
    // ============================================================================================================================
    // Test Method when Account record Inserted and if TaxExemptStatus is exempt on creation of account record.
    // =============================================================================================================================
    @isTest static void accountAfterInsertTest(){
        User salesRep_user = [SELECT Id FROM User WHERE FirstName = 'Adrienne' LIMIT 1];
        Apttus_Config2__TaxCertificate__c tax_record = [SELECT ID from Apttus_Config2__TaxCertificate__c WHERE SLTC_Tax_Exempt_Issuing_Jurisdiction__c = 'Alabama'];
        List<Account> account_data = SLTC_TestDataFactory.createAccounts('D','TestAccount','MDM Approved', 'SLTC_Property', 'Preliminary',1);
        Test.startTest();
        System.runAs(salesRep_user){
            account_data[0].Apttus_Config2__TaxExemptStatus__c = 'Exempt';
            account_data[0].Apttus_Config2__CertificateId__c = tax_record.Id;
            INSERT account_data; 
        }
        Test.stopTest();
        account_data = [Select Id,Apttus_Config2__TaxExemptStatus__c,CurrencyIsoCode from Account WHERE Name LIKE '%D_TestAccount'];
        System.assertEquals('CAD',account_data[0].CurrencyIsoCode);
        System.assertEquals('Exempt',account_data[0].Apttus_Config2__TaxExemptStatus__c);
    }
    
    // ============================================================================================================================
    // Test Method when the account is Updated to set TaxExemptStatus to Exempt.
    // =============================================================================================================================
    @isTest static void updateTaxcertitifcateTest(){ 
        User salesRep_user = [SELECT Id FROM User WHERE FirstName = 'Adrienne' LIMIT 1];
        Apttus_Config2__TaxCertificate__c tax_record = [Select Id from Apttus_Config2__TaxCertificate__c WHERE SLTC_Tax_Exempt_Issuing_Jurisdiction__c = 'Alabama'];
        Account account_records = [Select Id,Apttus_Config2__TaxExemptStatus__c from Account WHERE Name LIKE '%B_TestAccount'];
        Test.startTest();
        System.runAs(salesRep_user){
            account_records.Apttus_Config2__TaxExemptStatus__c = 'Exempt';
            account_records.Apttus_Config2__CertificateId__c = tax_record.Id;
            UPDATE account_records;
        }
        Test.stopTest();
        account_records = [Select Id,Apttus_Config2__TaxExemptStatus__c from Account WHERE Name LIKE '%B_TestAccount'];
        System.assertEquals('Exempt',account_records.Apttus_Config2__TaxExemptStatus__c);
    }
    
     // ============================================================================================================================
    // Test Method when account owner is updated. 
    // =============================================================================================================================
    @isTest static void updateAccountOwnerTest(){ 
        List<User> user_records = [SELECT Id FROM User WHERE FirstName = 'SalesOpsLeaders' OR FirstName = 'Director' ORDER BY Name];
        List<Account> account_records = [Select Id,OwnerId from Account WHERE Name LIKE '%B_TestAccount' OR Name LIKE '%C_AccountTest' ORDER BY Name];
        Test.startTest();
        System.runAs(user_records[1]){
              account_records[0].OwnerId = user_records[0].Id;
              account_records[1].OwnerId = user_records[0].Id;
              UPDATE  account_records;   
        }
        Test.stopTest();
        account_records = [Select Id,OwnerId from Account WHERE Name LIKE '%B_TestAccount' OR Name LIKE '%C_AccountTest' ORDER BY Name];
        System.assertEquals(user_records[0].Id,account_records[0].OwnerId);
        System.assertEquals(user_records[0].Id,account_records[1].OwnerId);
    }
    
    // ============================================================================================================================
    // Test Method when account billing address is updated.
    // =============================================================================================================================
    @isTest static void updateBillingAddressTest(){ 
        User salesRep_user = [SELECT Id FROM User WHERE FirstName = 'Adrienne' LIMIT 1];
        Account account_records = [Select Id,BillingCountry,BillingState,BillingStreet,BillingCity,BillingPostalCode from Account WHERE Name LIKE '%A_TestAccount'];
        Test.startTest();
        System.runAs(salesRep_user){
              account_records.BillingCountry = 'United States';
              account_records.BillingState = 'California';
              account_records.BillingStreet = '56th Street';
              account_records.BillingCity = 'Daly City';
              account_records.BillingPostalCode = '2000';
              UPDATE  account_records;   
        }
        Test.stopTest();
        account_records = [Select Id,CurrencyIsoCode from Account WHERE Name LIKE '%A_TestAccount'];
        System.assertEquals('USD',account_records.CurrencyIsoCode);
    }
    
    // ============================================================================================================================
    // Test Method when account Amadeus BP ID is updated.
    // =============================================================================================================================
    @isTest static void updateAccountBPIDTest(){ 
        User salesRep_user = [SELECT Id FROM User WHERE FirstName = 'Adrienne' LIMIT 1];
        Account account_records = [Select Id,Amadeus_BP_ID__c from Account WHERE Name LIKE '%A_TestAccount'];
        Test.startTest();
        System.runAs(salesRep_user){
              account_records.Amadeus_BP_ID__c = '3786689';
              UPDATE  account_records;   
        }
        Test.stopTest();
        Opportunity opportunity_record = [Select ID,Name from Opportunity WHERE Account.Name LIKE '%A_TestAccount'];
        System.assertEquals(true,opportunity_record.Name.startsWith('3786689')); 
    }
    
    // ============================================================================================================================
    // Test Method when account credit hold is updated to set true.
    // =============================================================================================================================
    @isTest static void updateCreditHoldCheckBoxTrueTest(){ 
        User collector_user = [SELECT Id FROM User WHERE FirstName = 'CollectionsAccountsReceivable' LIMIT 1];
        Account account_records = [Select Id,SLTC_Credit_Hold__c,SLTC_Credit_Hold_Reason__c from Account WHERE Name LIKE '%A_TestAccount'];
        Test.startTest();
        System.runAs(collector_user){
              account_records.SLTC_Credit_Hold__c = true;
              account_records.SLTC_Credit_Hold_Reason__c = 'Sent to 3rd party collections';
              UPDATE  account_records;
        }
        Test.stopTest();
        account_records = [Select Id,SLTC_Credit_Hold__c from Account WHERE Name LIKE '%A_TestAccount'];
        System.assertEquals(true,account_records.SLTC_Credit_Hold__c); 
    }
    
    // ============================================================================================================================
    // Test Method when account credit hold is updated to set false.
    // =============================================================================================================================
    @isTest static void updateCreditHoldCheckBoxFalseTest(){ 
        User collector_user = [SELECT Id FROM User WHERE FirstName = 'CollectionsAccountsReceivable' LIMIT 1];
        Account account_records = [Select Id,SLTC_Credit_Hold__c,SLTC_Credit_Unhold_Reason__c from Account WHERE Name LIKE '%B_TestAccount'];
        Test.startTest();
        System.runAs(collector_user){
              account_records.SLTC_Credit_Hold__c = false;
              account_records.SLTC_Credit_Unhold_Reason__c = 'CH removed due to pending dispute';
              UPDATE  account_records;
        }
        Test.stopTest();
        account_records = [Select Id,SLTC_Credit_Hold__c,SLTC_Credit_Hold_Reason__c from Account WHERE Name LIKE '%B_TestAccount'];
        System.assertEquals(false,account_records.SLTC_Credit_Hold__c);
        System.assertEquals(true,String.isBlank(account_records.SLTC_Credit_Hold_Reason__c)); 
    }
   
    // ============================================================================================================================
    // Test Method when type on account is updated to set customer.
    // =============================================================================================================================
    @isTest static void updateTypeTest(){ 
        List<Account> account_records = [Select Id,Type from Account WHERE Type =: 'Preliminary' ORDER BY Name];
        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())){
               account_records[0].Type = 'Customer';
               account_records[1].Type = 'Customer';
               UPDATE account_records;
         }
        Test.stopTest();
        List<AccountTeamMember> teammember_record = [Select Id from AccountTeamMember WHERE AccountId In: account_records AND TeamMemberRole = 'Collector'];
        System.assertEquals(2,teammember_record.Size());  
       
    } 
}