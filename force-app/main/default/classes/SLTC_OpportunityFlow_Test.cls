/**********************************************************
******************************
Name :  SLTC_OpportunityFlow_Test
Author : Jaswanth R
Created Date : 02/01/2023
Last Mod Date : 03/01/2023
Last Mod By :  Jaswanth R
NICC Reference : 
Description : Test Class for all Flows on Opportunity
: 
***********************************************************
*******************************/
@isTest
public class SLTC_OpportunityFlow_Test {
    
    // ==========================================================
    // Create Test Data
    // ==========================================================
    
    @testSetup static void setup(){ 
        List<User> user_data = new List<User>();
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Sales','Business Development','Manager','WWSales')); 
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Sales','Alexander','Fleming','WWSales')); 
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Sales','Ron','Graebe','WWSales')); 
        user_data[1].Title = 'Regional Vice President';
        user_data[1].Sales_Region__c = 'NORAM - Tier 3';
        user_data[1].SLTC_Region__c = 'Tier 3 - West';
        user gloHead = SLTC_TestDataFactory.createuser('SLTC Sales', 'Head', 'Support', 'WWSales'); 
        gloHead.Title =' Global Head of Customer Experience';
        user_data.add(SLTC_TestDataFactory.createuser('SLTC Order Management', 'ContractSupport', 'Team', 'CEOCFO'));
        INSERT user_data;
        
        PermissionSet requirePermission_data = new PermissionSet();
        requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Skip_the_contact_Role_ValIdation');
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
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user_data[0].Id, PermissionSetId = ps.Id));
            }
            permissionassignment.add(new PermissionSetAssignment(AssigneeId = user_data[0].Id, PermissionSetId = requirePermission_data.Id));
            
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            UPDATE standardPricebook;
            
            Pricebook2 custom_pricebook = new Pricebook2(Name = 'Amadeus Standard Pricebook', Description = 'Price Book 2009 Products', IsActive = true );
            
            INSERT custom_pricebook;

            List<Product2> product = SLTC_TestDataFactory.createProduct('Ihotlier', 1);
            INSERT product;

            List<PricebookEntry> standardPriceBookEntries  =  SLTC_TestDataFactory.createPricebookEntry(product);
            standardPriceBookEntries[0].Pricebook2Id = standardPricebook.Id;

            List<PricebookEntry> customPricebookEntries  =  SLTC_TestDataFactory.createPricebookEntry(product);
            customPricebookEntries[0].Pricebook2Id = custom_pricebook.Id;

            standardPriceBookEntries.addAll(customPricebookEntries);
            INSERT standardPriceBookEntries;    
        }


        INSERT permissionassignment;
        System.runAs(user_data[0]){
            
            //create Account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','SLTC_New_Acc','MDM Approved','SLTC_ParentAccount','Prospect',1);
            accountList.addAll(SLTC_TestDataFactory.createAccounts('Partner','SLTC_Test','MDM Approved','SLTC_Property','Prospect',1));
            INSERT accountList;
            //create Opportunity
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', accountList[0],1, 'SLTC_Opportunity');
            opportunityList.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'Renewal', accountList[0],1, 'SLTC_Renewal_Opportunity'));
            opportunityList.addAll(SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', accountList[1],1, 'SLTC_Opportunity'));
            INSERT opportunityList;
            //create Contact
            List<Contact> contactList = SLTC_TestDataFactory.createcontact('A Con', 'Contact', accountList[0].Id, 1);
            contactList.addAll(SLTC_TestDataFactory.createcontact('JJ Adams', 'Contact', accountList[1].Id, 1));
            INSERT contactList;
            //create Opportunity Contact Roles              
            List<OpportunityContactRole> contactRoleList = SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[0].Id, contactList[0].Id,'Customer Project Contact');
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[0].Id, contactList[0].Id,'Bill To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[0].Id, contactList[0].Id,'Sold To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[0].Id, contactList[0].Id,'Authorizer'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[1].Id, contactList[0].Id,'Customer Project Contact'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[1].Id, contactList[0].Id,'Bill To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[1].Id, contactList[0].Id,'Sold To'));
            contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityList[1].Id, contactList[0].Id,'Authorizer'));
            INSERT contactRoleList;
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
            agreement_data.Apttus__Status_Category__c = 'In Effect';
            agreement_data.Apttus__Status__c = 'Activated';
            INSERT agreement_data;
            
            //create order
            Apttus_Config2__Order__c order_data = SLTC_TestDataFactory.createApttusOrder(accountList[0].Id, opportunityList[0].Id, contactList[0].Id, proposal.Id,agreement_data.Id);
            order_data.Apttus_Config2__OrderStartDate__c=Date.today();
            INSERT order_data;
        }
        
    } 
    // ===========================================================================================================
    // Test Method: Test Flow SLTC Set Opportunity Team Members,SLTC Opportunity Before Insert Handler to check if team members are added to new records.
    // ===========================================================================================================
    @isTest private static void setTeamMemberTest(){
        
        User userData = [SELECT Id FROM User WHERE FirstName = 'Business Development' limit 1];
        
        System.runAs(userData){
            //create account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','SLTC_ABC_Test','MDM Approved','SLTC_ParentAccount','Prospect',1);
            INSERT accountList;
            
            //create renewal manager for renewal oppty testing
            AccountTeamMember newteam = new AccountTeamMember();
            newteam.AccountId = accountList[0].Id;
            newteam.UserId = userData.Id;
            newteam.TeamMemberRole = 'Renewal Manager';
            newteam.SLTC_Offerings__c = 'Business Intelligence';
            INSERT newteam;
            
            Test.startTest();
            
            //test Opportunity Address for US/CANADA RVP
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', accountList[0],1, 'SLTC_Opportunity'); 
            INSERT opportunityList;
            
            //update address to test INTL RVP
            accountList[0].BillingCountry = 'India';
            accountList[0].BillingState = 'Karnataka';
            accountList[0].BillingStreet = 'N12/237 street';
            accountList[0].BillingCity = 'India';
            accountList[0].BillingPostalCode = '22101';
            UPDATE accountList;
            List<Opportunity> opportunityListNewAcc = SLTC_TestDataFactory.createopportunity('Initial Interest', 'Renewal', accountList[0],1, 'SLTC_Opportunity');
            INSERT opportunityListNewAcc;
            
            //update to test EUROPE RVP
            accountList[0].BillingCountry = 'Italy';
            accountList[0].BillingState = 'Asti';
            accountList[0].BillingStreet = 'N12/237 street';
            accountList[0].BillingCity = 'India';
            accountList[0].BillingPostalCode = '22101';
            UPDATE accountList;
            List<Opportunity> opportunityListNewAccEUROPE = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', accountList[0],1, 'SLTC_Opportunity');
            INSERT opportunityListNewAccEUROPE;
            
            Test.stopTest();
            List<Opportunity> accOpps = [SELECT Id FROM Opportunity WHERE Account.name LIKE '%SLTC_ABC_Test%'];
            List<OpportunityTeamMember> oppTeam = [SELECT Id,OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN :accOpps];
            System.assertEquals(true,oppTeam.size()!=0, 'All Opportunity Team Members were inserted');  
        }
    }
    // ==============================================================================================================
    // Test Method: Test Flow SLTC Set Opportunity Name to check if name updates happen when value is updated on oppty
    // ===============================================================================================================
    @isTest private static void opportunityNamingTest(){
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' LIMIT 1];
        Test.startTest();
        {
            opportunityToTest.SLTC_Opportunity_Description__c='New_Test';
            UPDATE opportunityToTest;
        }
        Test.stopTest();
        Opportunity opportunityAssert = [SELECT Id,SLTC_Opportunity_Description__c FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' LIMIT 1];
        System.assertEquals(true,opportunityAssert.SLTC_Opportunity_Description__c=='New_Test', 'Opp name was updated');  
    }
    // ==============================================================================================================
    // Test Method: Test Flow SLTC Set Opportunity Name to check if sales credit set when closed-won
    // ===============================================================================================================
    @isTest private static void setSalesCreditTest(){
        
        Test.startTest();
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' LIMIT 1];
        opportunityToTest.StageName = 'Closed Won';
        Database.SaveResult result = Database.update(opportunityToTest, false);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Oppty was marked closed-won'); 
    } 
    // ==============================================================================================================
    // Test Method: Test Flow SLTC Set Opportunity Name to check if sales credit date set when closed won for iHotelier
    // ===============================================================================================================
    @isTest private static void setSalesCreditIhotelierTest(){
        
        Test.startTest();   
        Opportunity opportunityToTest = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' LIMIT 1];
        Product2 product = [SELECT Id,name FROM Product2 WHERE name like '%Test_Pro%'limit 1];
        product.Name = 'iHotelier';
        UPDATE product;
        opportunityToTest.StageName = 'Closed Won';
        Database.SaveResult result = Database.update(opportunityToTest, false);
        Test.stopTest();
        System.assertEquals(true, result.isSuccess(), 'Oppty was marked closed-won'); 
    } 
    
    // ============================================================================================================
    // Test Method for flow: SLTC Opportunity Record Lock stages.
    // To test the locking of opportunity record.
    // ============================================================================================================
    @isTest public static void recordLockTest(){
        User contractSupportTeam_user = [SELECT Id,Name FROM User WHERE FirstName='ContractSupport' limit 1];
        List<Opportunity> opportunityRecords = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' ORDER BY Type DESC];
        System.runAs(contractSupportTeam_user){   
            Test.startTest();
            opportunityRecords[0].StageName ='Closed Won';
            opportunityRecords[0].Win_Loss_Reason__c = 'Price';
            opportunityRecords[1].StageName = 'Closed Won';     
            opportunityRecords[1].Win_Loss_Reason__c = 'Price';
            Database.SaveResult[] result = Database.update(opportunityRecords, false);
            opportunityRecords = [SELECT Id,recordType.DeveloperName FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' ORDER BY Type DESC];    
            System.assertEquals(true, result[0].isSuccess(),'Opportunity was updated, locked and has at least one one activated agreement');
            System.assertEquals('SLTC_Opportunity_ReadOnly', opportunityRecords[0].recordType.DeveloperName);    
            System.assertEquals(false, result[1].isSuccess(),'Must have at least one activated agreement for the opportunity before Stage is set closedwon');    
            Test.stopTest();   
        }
    }
    // ============================================================================================================
    // Test Method for flow: SLTC Opportunity Contact Role After Update
    // ============================================================================================================
    @isTest public static void contactRoleAfterInsertTest(){
        Account AccountToTest = [SELECT Id FROM Account WHERE Name LIKE'%SLTC_New_Acc' LIMIT 1];
        OpportunityContactRole updContactRole = [SELECT Id,Role,ContactId,OpportunityId FROM OpportunityContactRole WHERE Role!='Authorizer' LIMIT 1];
        List<Opportunity> opportunityRecords = [SELECT Id FROM Opportunity WHERE Account.Name LIKE'%SLTC_New_Acc' LIMIT 1];
        List<Opportunity> opportunityListNewAcc = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', AccountToTest,1, 'SLTC_Opportunity');
        opportunityListNewAcc[0].pse__Parent_Opportunity__c = opportunityRecords[0].Id;
        INSERT opportunityListNewAcc;
        List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opportunityListNewAcc[0].Id, updContactRole.ContactId,updContactRole.Role));
        contactRoleList[0].SLTC_Opportunity_Contact_Role_Parent_ID__c = updContactRole.Id;
        INSERT contactRoleList;
        Test.startTest();
        updContactRole.Role = 'Authorizer';
        contactRoleList[0].Role = 'Authorizer';
        Database.SaveResult result = Database.update(updContactRole, false);
        Database.SaveResult resultChild = Database.update(contactRoleList[0], false);  
        System.assertEquals(true, result.isSuccess(),'Contact Role Updated');  
        System.assertEquals(true, resultChild.isSuccess(),'Child Contact Role Updated'); 
        Test.stopTest();   
    }
    // ============================================================================================================
    // Test Method for flow: SLTC Opportunity Contact Role Before Insert Update
    // ============================================================================================================
    @isTest public static void contactRoleBeforeInsertUpdateTest(){
        Account parentAcc = [SELECT Id FROM Account WHERE Name LIKE'%SLTC_New_Acc' LIMIT 1];
        Account propAcc = [SELECT Id FROM Account WHERE Name LIKE'%SLTC_Test' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test%' LIMIT 1];
        Contact parentCon = [SELECT Id FROM Contact WHERE Account.Name LIKE '%SLTC_New_Acc%' LIMIT 1];
        Contact propCon = [SELECT Id FROM Contact WHERE Account.Name LIKE '%SLTC_Test%' LIMIT 1];
        List<OpportunityContactRole> contactRoleList = new List<OpportunityContactRole>();
        contactRoleList.addAll(SLTC_TestDataFactory.createOpportunityContactRole(opp.Id, parentCon.Id, 'Authorizer'));    
        Test.startTest();
        INSERT contactRoleList;
        List<SLTC_Account_Affiliation__c> accAffReturnList = SLTC_TestDataFactory.createAccountAffiliation(parentAcc.Id,propAcc.Id, 'Other Third-Party Company', TRUE, 1, NULL);
        INSERT accAffReturnList;
        contactRoleList[0].ContactId = propCon.Id;
        Database.SaveResult result = Database.update(contactRoleList[0], false); 
        System.assertEquals(true, result.isSuccess(), 'Contact Role Updated'); 
        Test.stopTest();   
    }
    
    // ============================================================================================================
    // Test Method for flow: SLTC_Opportunity_Set Default PricebookId
    // to test default pricebook on opportunity creation or updated and auto-populate country tier. 
    // ============================================================================================================
    @isTest public static void defaultPricebookTest(){
        User salesuser = [SELECT Id FROM User WHERE FirstName='Business Development'];
        List<Pricebook2> pricebook_record = [SELECT Id, Name from Pricebook2 WHERE Name like '%Amadeus%' LIMIT 1];
        Account account_record = [SELECT Id from Account WHERE Name LIKE '%SLTC_Test%'];
        List<Opportunity> opportunity_record = [SELECT Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test'];
        System.runAs(salesuser){  
        Test.startTest();
        List<Opportunity> opportunity_data = SLTC_TestDataFactory.createopportunity('Initial Interest', 'New Business', account_record, 1, 'SLTC_Opportunity');
        opportunity_data[0].SLTC_Opportunity_Description__c='A';
        INSERT opportunity_data;
        opportunity_record[0].SLTC_Opportunity_Description__c='B';
        UPDATE opportunity_record;    
        Test.stopTest();
        }
        opportunity_record = [SELECT Id,SLTC_Country_Tier__c,Pricebook2Id FROM Opportunity WHERE Account.Name LIKE '%SLTC_Test%' ORDER BY SLTC_Opportunity_Description__c];
        //After Insert
        System.assertEquals('A',opportunity_record[0].SLTC_Country_Tier__c);
        System.assertEquals(pricebook_record[0].Id, opportunity_record[0].Pricebook2Id, 'Pricebook get populated once opprtunity got created');
        //After Update
        System.assertEquals('A',opportunity_record[1].SLTC_Country_Tier__c);
        System.assertEquals(pricebook_record[0].Id, opportunity_record[1].Pricebook2Id, 'Pricebook get populated once opprtunity got created');
        
    }
}