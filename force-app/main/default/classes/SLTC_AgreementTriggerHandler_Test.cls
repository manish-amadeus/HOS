/**********************************************************
Name : SLTC_AgreementTriggerHandler_Test
Author : Japtej Lamba
Created Date : 12/5/2022
Last Mod Date : 01/02/2023
Last Mod By : Japtej Lamba
Description : Test Class for SLTC_AgreementTriggerHandler and SLTC_AgreementTriggerHelper.
***********************************************************/
@isTest
public class SLTC_AgreementTriggerHandler_Test{

    @testSetup static void setup(){ 
        User user = SLTC_TestDataFactory.createuser('SLTC Sales','First','Last','SLTC_Sales_Manger'); 
        User user_exec = SLTC_TestDataFactory.createuser('SLTC Sales','Second','Last','SLTC_Sales_Manger'); 
        INSERT user;
        INSERT user_exec;
        PermissionSet requirePermission_data = new PermissionSet();
        requirePermission_data = SLTC_TestDataFactory.createPermissionSet('SLTC_Skip_the_contact_Role_ValIdation');
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment = new List<PermissionSetAssignment>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            INSERT new NI_TriggerBypassSwitches__c(Name='Bypass Control Panel',BypassOpportunity_ON__c = true,BypassAccount_ON__c = true,  Bypass_AH_Opportunity_Related_Account__c = true);
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTCCPQSalesUser'));
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTCCPQFullUser'));
            for(PermissionSet ps: requirePermission){
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
            }
            permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = requirePermission_data.Id));
        }
        INSERT permissionassignment;
    } 

    // Test method to check Status when Signed document is attached to Agreement record
    @isTest
    public static void updateAgreementTest(){
        
        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        System.runAs(userData)
        {
            //create Account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',1);
            accountList[0].Name+='123 TEST';
            INSERT accountList;
            //create Opportunity
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest','New Business', accountList[0], 1, 'SLTC_Opportunity');
            INSERT opportunityList;
            //create Contact
            List<Contact> contactList=SLTC_TestDataFactory.createcontact('Test Contact Role','Contact',accountList[0].id,1);
            INSERT contactList;
            //create Proposal 
            Apttus_Proposal__Proposal__c proposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            INSERT proposal;
            //create child Proposal 
            Apttus_Proposal__Proposal__c childProposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            INSERT childProposal;
            
            Apttus_Config2__ProductConfiguration__c prod_config = new Apttus_Config2__ProductConfiguration__c();
            prod_config.Apttus_QPConfig__Proposald__c = proposal.id;
            prod_config.Name = 'Test product configuration';
            INSERT prod_config;

            Apttus__APTS_Agreement__c parentAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, proposal.Id, 'Order_Form');
            parentAgreement.Apttus__Status_Category__c = 'In Signatures';
            parentAgreement.Apttus__Status__c = 'Ready for Signatures';
            parentAgreement.SLTC_Is_SLTC_Record__c = True;
            parentAgreement.SLTC_Product_Configuration__c=prod_config.Id;
            INSERT parentAgreement;

            Apttus__APTS_Agreement__c childAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, childProposal.Id, 'Order_Form');
            childAgreement.Apttus__Parent_Agreement__c=parentAgreement.Id;
            childAgreement.SLTC_Is_SLTC_Record__c = True;
            INSERT childAgreement;

            Attachment attach=new Attachment();
            attach.Name='Test Attachment';
            Blob bodyBlob=Blob.valueOf('Body');
            attach.body=bodyBlob;
            attach.parentId=parentAgreement.id;
            insert attach;

            Test.startTest();

            parentAgreement.Apttus__Status__c = 'Activated';
            parentAgreement.Apttus__Status_Category__c = 'In Effect';
            parentAgreement.SLTC_Effective_Date__c = system.now().date();
            UPDATE parentAgreement;

            childAgreement = [SELECT Id, SLTC_Effective_Date__c FROM Apttus__APTS_Agreement__c WHERE Id=: childAgreement.Id];

            Test.stopTest();

            System.assertEquals(childAgreement.SLTC_Effective_Date__c,parentAgreement.SLTC_Effective_Date__c);
        }
    }

    // Test method to check Agreement Date on Child and Parent Agreements
    // when Status is updated to Fully Signed - In Signatures
    @isTest
    public static void updateAgreementDateTest(){

        User userData = [SELECT Id FROM User WHERE FirstName = 'First' limit 1];
        System.runAs(userData)
        {
            //create Account
            List<Account> accountList = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',1);
            INSERT accountList;
            //create Opportunity
            List<Opportunity> opportunityList = SLTC_TestDataFactory.createopportunity('Initial Interest','New Business', accountList[0], 1, 'SLTC_Opportunity');
            INSERT opportunityList;
            //create Contact
            List<Contact> contactList=SLTC_TestDataFactory.createcontact('Test Contact Role','Contact',accountList[0].id,1);
            INSERT contactList;
            //create Proposal 
            Apttus_Proposal__Proposal__c proposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            proposal.SLTC_Is_Date_Calculation_required__c=False;
            INSERT proposal;
            //create child Proposal 
            Apttus_Proposal__Proposal__c childProposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            INSERT childProposal;

            Apttus__APTS_Agreement__c parentAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, proposal.Id, 'Order_Form');
            parentAgreement.Apttus__Status__c = 'In Signatures';
            parentAgreement.Apttus__Status_Category__c = 'Ready for Signatures';
            parentAgreement.SLTC_Is_SLTC_Record__c = True;
            parentAgreement.Apttus__Contract_Start_Date__c=Date.today();
            parentAgreement.Apttus__Term_Months__c=12;
            parentAgreement.Apttus__Contract_End_Date__c=Date.today().addMonths(12);
            
            INSERT parentAgreement;
            
            Apttus__AgreementLineItem__c agline = new Apttus__AgreementLineItem__c();
            agLine.Apttus__AgreementId__c=parentAgreement.Id;
            agLine.Apttus_CMConfig__StartDate__c=Date.today();
            agLine.Apttus_CMConfig__EndDate__c=Date.today().addMonths(12);
            INSERT agline;
            
            Apttus__AgreementLineItem__c agline2 = new Apttus__AgreementLineItem__c();
            agLine2.Apttus__AgreementId__c=parentAgreement.Id;
            agLine2.Apttus_CMConfig__StartDate__c=Date.today();
            agLine2.Apttus_CMConfig__EndDate__c=Date.today().addMonths(12);
            INSERT agline2;

            Apttus__APTS_Agreement__c childAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, childProposal.Id, 'Order_Form');
            childAgreement.Apttus__Parent_Agreement__c=parentAgreement.Id;
            childAgreement.SLTC_Is_SLTC_Record__c = True;
            childAgreement.Apttus__Contract_Start_Date__c=Date.today();
            childAgreement.Apttus__Term_Months__c=12;
            childAgreement.Apttus__Contract_End_Date__c=Date.today().addMonths(12);
            INSERT childAgreement;
            
            Apttus__AgreementLineItem__c childAgline = new Apttus__AgreementLineItem__c();
            childAgline.Apttus__AgreementId__c=childAgreement.Id;
            childAgline.Apttus_CMConfig__PriceType__c='Recurring';
            childAgLine.Apttus_CMConfig__PriceGroup__c='Price Ramp';
            childAgline.Apttus_CMConfig__LineNumber__c=2;
            childAgline.Apttus_CMConfig__StartDate__c=Date.today();
            childAgline.Apttus_CMConfig__EndDate__c=Date.today().addMonths(12);
            INSERT childAgline;
            
            Apttus__AgreementLineItem__c childAgline2 = new Apttus__AgreementLineItem__c();
            childAgline2.Apttus__AgreementId__c=childAgreement.Id;
            childAgline2.Apttus_CMConfig__PriceType__c='Recurring';
            childAgline2.Apttus_CMConfig__PriceGroup__c='Price Ramp';
            childAgline2.Apttus_CMConfig__LineNumber__c=2;
            childAgline2.Apttus_CMConfig__StartDate__c=Date.today();
            childAgline2.Apttus_CMConfig__EndDate__c=Date.today().addMonths(12);
            INSERT childAgline2;

            Test.startTest();
            
            parentAgreement.Apttus__Status__c = 'Fully Signed';
            parentAgreement.Apttus__Status_Category__c = 'In Signatures';
            parentAgreement.SLTC_Effective_Date__c = system.now().date();
            UPDATE parentAgreement;
            
            
            parentAgreement = [SELECT Id, Apttus__Contract_Start_Date__c FROM Apttus__APTS_Agreement__c WHERE Id=: parentAgreement.Id];

            childAgreement = [SELECT Id, Apttus__Contract_Start_Date__c FROM Apttus__APTS_Agreement__c WHERE Id=: childAgreement.Id];

            Test.stopTest();

            System.assertEquals(childAgreement.Apttus__Contract_Start_Date__c,parentAgreement.Apttus__Contract_Start_Date__c);
        }
    }

}