/**********************************************************
Name : SLTC_AgreementTriggerHelper
Author : Japtej Lamba
Created Date : 12/5/2022
Last Mod Date : 12/5/2022
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
               //PermissionSetAssignment permissionassignment_data = new PermissionSetAssignment(AssigneeId = user_data.Id, PermissionSetId = requirePermission_data.Id);
               //INSERT permissionassignment_data;
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

    @isTest
    public static void updateAgreementTest(){
        

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
            INSERT proposal;
            //create child Proposal 
            Apttus_Proposal__Proposal__c childProposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal'); 
            INSERT childProposal;
            Test.startTest();

            Apttus__APTS_Agreement__c parentAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, proposal.Id, 'Order_Form');
            parentAgreement.Apttus__Status__c = 'In Signatures';
            parentAgreement.Apttus__Status_Category__c = 'Ready for Signatures';
            parentAgreement.STLC_Is_SLTC_Record__c = True;
            INSERT parentAgreement;

            Apttus__APTS_Agreement__c childAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, childProposal.Id, 'Order_Form');
            childAgreement.Apttus__Parent_Agreement__c=parentAgreement.Id;
            childAgreement.STLC_Is_SLTC_Record__c = True;
            INSERT childAgreement;

            Attachment attach=new Attachment();
            attach.Name='Test Attachment';
            Blob bodyBlob=Blob.valueOf('Body');
            attach.body=bodyBlob;
            attach.parentId=parentAgreement.id;
            insert attach;
            

            parentAgreement.Apttus__Status__c = 'Activated';
            parentAgreement.Apttus__Status_Category__c = 'In Effect';
            parentAgreement.SLTC_Effective_Date__c = system.now().date();
            UPDATE parentAgreement;

            childAgreement = [SELECT Id, SLTC_Effective_Date__c FROM Apttus__APTS_Agreement__c WHERE Id=: childAgreement.Id];

            Test.stopTest();

            System.assertEquals(childAgreement.SLTC_Effective_Date__c,parentAgreement.SLTC_Effective_Date__c);
        }
    }


}