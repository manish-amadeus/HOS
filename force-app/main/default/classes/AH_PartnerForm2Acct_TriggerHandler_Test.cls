/****************************************************************************************
Name            : AH_PartnerForm2Acct_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 10/13/2017
Last Mod Date   : 10/13/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-024156
Description     : Test class for AH_PartnerForm2Acct_TriggerHandler
                : 
                : 
******************************************************************************************/
@isTest 
public class AH_PartnerForm2Acct_TriggerHandler_Test 
{
    // ======================================================================================================================================= //
    // = TEST METHOD 1: CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
		
        // CREATE TEST ACCOUNT RECORD 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id rtPartnerAccountId = AccountRecordTypeInfo.get('Partner Account').getRecordTypeId();    
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEXT FOR AH_PartnerForm2Acct_TriggerHandler_Test Class #1';
        a.RecordTypeId = rtPartnerAccountId;
        insert a;

        // CREATE TEST CONTACT RECORD
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jackie';
        cnt.LastName = 'Nauff';
        cnt.Email = 'jnauff@somedomain.com';
        insert cnt;
        
        List<Contact> lstContactAsserts = new List<Contact>([SELECT Id FROM Contact WHERE AccountId =: a.Id]);
        system.AssertEquals(1, lstContactAsserts.size());      
            
        // CREATE TEST PARTNER USER
        Profile pro = [SELECT Id, UserType FROM Profile WHERE Name = 'AH PartnerCentral Login User'];        
        system.assertEquals('PowerPartner', pro.UserType);
        
        User pu = NI_TestClassData.createTestUser(2, 'AH PartnerCentral Login User');
        pu.ContactId = cnt.Id;
        pu.Partner_Permissions__c = 'Cendyn';
        pu.Partner_Terms_Accepted__c = 'True';
        insert pu;
        
        // VERIFY THAT A PARTNER PORTAL USER WAS CREATED
        List<User> lstTestUser = new List<User>([SELECT Id, AccountId FROM User WHERE ProfileId =: pro.Id AND ContactId =: cnt.Id AND AccountId =: a.Id]);
        system.AssertEquals(1, lstTestUser.Size());  
        
        // CREATE TEST PARTNER FORM RECORDS
        Partners_Form_Template__c pt1 = new Partners_Form_Template__c();        
        pt1.Start_Date__c = Date.today();
        pt1.End_Date__c = Date.today() + 7;
        pt1.Subject__c = 'APEX TEST Non-Perpetual FORM';
        pt1.Template_Type__c = 'Non-Perpetual';
        pt1.Terms__c = 'These are the terms.';
		insert pt1;
        
        Partners_Form_Template__c pt2 = new Partners_Form_Template__c();        
        pt2.Start_Date__c = Date.today();
        pt2.End_Date__c = Date.today() + 7;
        pt2.Subject__c = 'APEX TEST Perpetual FORM';
        pt2.Template_Type__c = 'Perpetual';
        pt2.Terms__c = 'These are the terms.';
        insert pt2;
        
        // CREATE TEST PARTNER FORM TO ACCOUNT JUNCTION RECORDS
        Partners_Form_Template_to_Account__c pft1 = new Partners_Form_Template_to_Account__c();
        pft1.Partners_Form_Template__c = pt1.Id;
        pft1.Account__c = a.Id;
        insert pft1;
        
        Partners_Form_Template_to_Account__c pft2 = new Partners_Form_Template_to_Account__c();
        pft2.Partners_Form_Template__c = pt2.Id;
        pft2.Account__c = a.Id;
        insert pft2;         

    }
    
    @isTest static void testPartnerForm2AcctTrgHdr1() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEXT FOR AH_PartnerForm2Acct_TriggerHandler_Test Class #1'];
        Contact cnt = [SELECT Id FROM Contact WHERE Email = 'jnauff@somedomain.com'];         
        Partners_Form_Template__c ptNonPer = [SELECT Id FROM Partners_Form_Template__c WHERE Subject__c = 'APEX TEST Non-Perpetual FORM'];
        Partners_Form_Template__c ptPerpet = [SELECT Id FROM Partners_Form_Template__c WHERE Subject__c = 'APEX TEST Perpetual FORM'];
        Partners_Form_Template_to_Account__c pftNonPer = [SELECT Id FROM Partners_Form_Template_to_Account__c WHERE partners_Form_Template__c =: ptNonPer.Id];
        Partners_Form_Template_to_Account__c pftPerpet = [SELECT Id FROM Partners_Form_Template_to_Account__c WHERE partners_Form_Template__c =: ptPerpet.Id];
        User u = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];

        // VERIFY PARTNER PORTAL USER WAS UPDATED CORRECTLY DURING DATA CREATION
        system.AssertEquals('False', u.Partner_Terms_Accepted__c, 'Creation of new Partners_Form_Template_to_Account__c record should have set the users Partner_Terms_Accepted__c field to false.');   

        // EMULATE PARTNER USER ACCEPTING ALL FORMS
//        system.runAs(u)
//        {
            pftNonPer.Accepted_Terms__c = true;
            pftNonPer.Date_Accepted__c = DateTime.now();
            pftNonPer.Accepted_By__c = u.Id;
            pftNonPer.IP_Address__c = '192.168.1.101';
            update pftNonPer;
            
            pftPerpet.Accepted_Terms__c = true;
            pftPerpet.Date_Accepted__c = DateTime.now();
            pftPerpet.Accepted_By__c = u.Id;
            pftPerpet.IP_Address__c = '192.168.1.101';
            update pftPerpet;            
//        }
        
//        Test.startTest();
//        User u2 = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];
//        system.AssertEquals('True', u2.Partner_Terms_Accepted__c);
//        Test.stopTest();
        
    }
    
}