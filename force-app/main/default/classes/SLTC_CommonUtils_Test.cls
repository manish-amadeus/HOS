/**********************************************************
Name : SLTC_AgreementTriggerHelper
Author : Japtej Lamba
Created Date : 12/6/2022
Last Mod Date : 12/6/2022
Last Mod By : Japtej Lamba
Description : Test Class for SLTC_CommonUtils
***********************************************************/
@isTest
public class SLTC_CommonUtils_Test{

    @testSetup static void setup(){ 
        User user = SLTC_TestDataFactory.createuser('SLTC Sales','First','Last','SLTC_Sales_Manger'); 
        INSERT user;
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment = new List<PermissionSetAssignment>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            INSERT new NI_TriggerBypassSwitches__c(Name='Bypass Control Panel',BypassOpportunity_ON__c = true,BypassAccount_ON__c = true,  Bypass_AH_Opportunity_Related_Account__c = true);
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTCCPQSalesUser'));
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTCCPQFullUser'));
            for(PermissionSet ps: requirePermission){
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id));
            }
           // permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = requirePermission_data.Id));
        }
        INSERT permissionassignment;
    } 

    @isTest
    public static void commonUtilsTest(){
        

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
        	proposal.Apttus_Proposal__Proposal_Name__c = 'Test proposalrecord';
            INSERT proposal;
            //create child Proposal 
            Apttus_Proposal__Proposal__c childProposal= SLTC_TestDataFactory.createProposal(accountList[0].id, contactList[0].id,opportunityList[0].id,'Proposal');  
        	proposal.Apttus_Proposal__Proposal_Name__c = 'Test proposalrecord2';
            INSERT childProposal;
            
            List<Apttus_Proposal__Proposal__c> proposalsList = new List<Apttus_Proposal__Proposal__c>();
            proposalsList.add(proposal);
            //proposalsList = [SELECT id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Name__c LIKE 'Test proposalrecord%'];
            
            Test.startTest();
            List<Id> cartIds = SLTC_CommonUtils.createCart(proposalsList); 
            System.assertEquals(True, !cartIds.isEmpty());
            Test.stopTest();
        }
    }


}