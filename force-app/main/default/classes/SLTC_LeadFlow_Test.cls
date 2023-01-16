/**********************************************************
******************************
Name :  SLTC_LeadFlow_Test
Author : Jaswanth R
Created Date : 02/01/2023
Last Mod Date : 03/01/2023
Last Mod By :  Jaswanth R
NICC Reference : 
Description : Test Class for all Flows on Lead
: 
***********************************************************
*******************************/
@isTest
public class SLTC_LeadFlow_Test {
    // ==========================================================
    // Create Test Data
    // ==========================================================
    @testSetup
    static void setup(){
        
        List<PermissionSet> requirePermission = new List<PermissionSet>();
        List<PermissionSetAssignment> permissionassignment = new List<PermissionSetAssignment>();
        User user = SLTC_TestDataFactory.createuser('SLTC Sales','Jon','Snow','WWSales');  
        INSERT user;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            INSERT new NI_TriggerBypassSwitches__c(Name='Bypass Control Panel',BypassOpportunity_ON__c = true,BypassAccount_ON__c = true, Bypass_SLTC_Account_Affiliation_Trigger__c  = false);
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Account_Create_Modify_View'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Lead_Create_View_Edit'));
            requirePermission.add(SLTC_TestDataFactory.getpermissionset('SLTC_Contact_Create_Modify_View'));
            requirePermission.Add(SLTC_TestDataFactory.getpermissionset('SLTC_Opportunity_Create_Modify_View'));
            for(PermissionSet ps: requirePermission){
                permissionassignment.add(new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id));          
            }
            INSERT permissionassignment;
        }
        System.runAs(user)
        {
            List<Account> account_data = SLTC_TestDataFactory.createAccounts('Partner','Test','MDM Approved','SLTC_ParentAccount','Prospect',1);
            INSERT account_data;
            List<Opportunity> opportunityListNewAcc = SLTC_TestDataFactory.createopportunity('Initial Interest', 'Renewal', account_data[0],1, 'SLTC_Opportunity');
            INSERT opportunityListNewAcc;
            List<Contact> contactList = SLTC_TestDataFactory.createcontact('A Con', 'Contact', account_data[0].Id, 1);
            INSERT contactList;
            
        }
        
    }
    // ==========================================================
    // Test Method: Test Flow SLTC_Lead_Trigger_Handler_Before_Insert_Update
    // ==========================================================
    @isTest private static void leadBeforeInsertUpdateTest()
    {
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SLTC_Lead').getRecordTypeId();
        List<Lead> leads = SLTC_TestDataFactory.createLead(1,'Test_Lead', recordTypeId);
        INSERT leads;
        Test.startTest();
        leads[0].Status = 'Nurture';
        leads[0].SLTC_Disqualified_Reason__c = 'Competitor';
        UPDATE leads;
        Test.stopTest();
        System.assertEquals(TRUE, leads[0].OwnerId==NULL, 'Lead Owner was changed To Group');
    }
    // ==========================================================
    // Test Method: Test Flow SLTC_Lead_Trigger_Handler_After_Insert_Update 
    // ==========================================================
    @isTest private static void leadAfterInsertTest()
    {
        Account newAcc = [SELECT Id FROM Account LIMIT 1];
        Opportunity newOpp = [SELECT Id FROM Opportunity LIMIT 1];
        Contact newCon = [SELECT Id FROM Contact LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SLTC_Lead').getRecordTypeId();
        User getUser = [SELECT Id FROM User WHERE FirstName ='Jon' limit 1];
        List<Lead> leads = SLTC_TestDataFactory.createLead(1, 'jk_test', recordTypeId);
        leads[0].Description = 'New Recx`';
        INSERT leads;
        leads[0].OwnerId = getUser.Id;
        Test.startTest();
        update leads;
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leads[0].Id);
        lc.setAccountId(newAcc.Id);
        lc.setOpportunityId(newOpp.Id);
        lc.setContactId(newCon.Id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setOwnerId(getUser.Id);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        Test.stopTest();
        Opportunity oppRec = [SELECT Id FROM Opportunity LIMIT 1];
        Contact conRec = [SELECT Id,Description FROM Contact LIMIT 1];
        
        System.assertEquals(TRUE, oppRec.Id!=NULL, 'Lead values were mapped to Opportunity');
        System.assertEquals(TRUE, conRec.Description!=NULL, 'Lead values were mapped to Contact');
    }   
}