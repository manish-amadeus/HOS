/**********************************************************
Name : SLTC_ContentDocLink_TriggerHandler_Test
Author : Japtej Lamba
Created Date : 12/5/2022
Last Mod Date : 12/5/2022
Last Mod By : Japtej Lamba
Description : Test Class for SLTC_ContentDocumentLink_TriggerHandler.
***********************************************************/
@isTest
public class SLTC_ContentDocLink_TriggerHandler_Test{

    @isTest
    public static void contentDocLinkTriggerTest(){

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
        Apttus__APTS_Agreement__c parentAgreement = SLTC_TestDataFactory.createAgreement(accountList[0].id, opportunityList[0].id, contactList[0].id, proposal.Id, 'Order_Form');
        parentAgreement.Apttus__Status__c = 'In Signatures';
        parentAgreement.Apttus__Status_Category__c = 'Ready for Signatures';
        INSERT parentAgreement;

        Test.startTest();
        ContentVersion contentV = SLTC_TestDataFactory.createContentVersion();
        contentV.title = 'Test_Signed';
        INSERT contentV;
        ContentDocumentLink contentDocLink = SLTC_TestDataFactory.createContentDocumentLink(parentAgreement.Id,contentV.Id);
        INSERT contentDocLink;
        Test.stopTest();

        parentAgreement = [SELECT Id,Apttus__Status_Category__c,Apttus__Status__c, SLTC_Effective_Date__c FROM Apttus__APTS_Agreement__c WHERE Id=: parentAgreement.Id];

        System.assertEquals(parentAgreement.Apttus__Status_Category__c,'In Signatures');
        System.assertEquals(parentAgreement.Apttus__Status__c,'Fully Signed');
    }


}