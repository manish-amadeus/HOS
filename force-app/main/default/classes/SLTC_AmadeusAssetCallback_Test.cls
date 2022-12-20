/**********************************************************
Name : SLTC_AmadeusAssetCallback_Test
Author : Japtej Lamba
Created Date : 12/8/2022
Last Mod Date : 12/8/2022
Last Mod By : Japtej Lamba
Description : Test Class for SLTC_AmadeusAssetCallback
***********************************************************/
@isTest
public class SLTC_AmadeusAssetCallback_Test{

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
            
            List<Product2> product = SLTC_TestDataFactory.createProduct('SLTC',1);
            INSERT product;
            
			List<Apttus_Config2__AssetLineItem__c> assetLIList = SLTC_TestDataFactory.createAssetLineItemwithproducts(accountList[0].id, product);
            INSERT assetLIList;
            
            Set<Id> assetIdSet = new Set<Id>();
            assetIdSet.add(assetLIList[0].Id);
            Set<Id> accountIdSet = new Set<Id>();
            accountIdSet.add(accountList[0].id);
            
            Test.startTest();
            SLTC_AmadeusAssetCallback callbackClass = new SLTC_AmadeusAssetCallback();
            callbackClass.getQueryFilter(accountList[0].id);
            Date dateTest = callbackClass.getAssetTerminationDate();
            callbackClass.getAssetSearchScope();
            Apttus_Config2.CustomClass.ActionParams params = new Apttus_Config2.CustomClass.ActionParams();
			String filterExpr = callbackClass.getFilterExpr(params);
            Boolean isResult = callbackClass.validateAssetTermination(assetIdSet, accountIdSet, dateTest);
            callbackClass.finish();
            Test.stopTest();
            System.assert(True, isResult);
            System.assert(True, filterExpr != null);
        }
    }


}