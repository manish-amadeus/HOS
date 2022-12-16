/**********************************************************
Name : SLTC_DeleteRenewalConfiguration_Test
Author : Japtej Lamba
Created Date : 12/5/2022
Last Mod Date : 12/5/2022
Last Mod By : Japtej Lamba
Description : Test Class for SLTC_DeleteRenewalConfiguration.
***********************************************************/
@isTest
public class SLTC_DeleteRenewalConfiguration_Test{

    @isTest
    public static void deleteRenewalConfigTest(){
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

        //Product Configuration
        Apttus_Config2__ProductConfiguration__c prod_config = new Apttus_Config2__ProductConfiguration__c();
        prod_config.Apttus_QPConfig__Proposald__c = proposal.id;
        prod_config.Name = 'Test product configuration';
        prod_config.SLTC_Renewal_Configuration__c= TRUE;
        INSERT prod_config;

        PageReference pageRef1 = Page.SLTC_DeleteRenewalConfiguration;
        Test.setCurrentPage(pageRef1);
        pageRef1.getParameters().put('id',proposal.id);
        
        Test.startTest();
        SLTC_DeleteRenewalConfiguration ctr1 = new SLTC_DeleteRenewalConfiguration();
        ctr1.deleteRenewalOppty();
        Test.stopTest();
        List<Apttus_Config2__ProductConfiguration__c> configList = [SELECT Id from Apttus_Config2__ProductConfiguration__c WHERE Id=:prod_config.Id];
       
        System.assertEquals(true, configList.isEmpty());
    }


}