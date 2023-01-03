/****************************************************************************************
Name            : AH_PartnerForms_Test Class
Author          : Sean Harris
Created Date    : 12/04/2017
Last Mod Date   : 12/04/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-024156
Description     : Test class for AH_PartnerForms controller
                : 
                : 
******************************************************************************************/
@isTest 
public class AH_PartnerForms_Test 
{
    
    // ======================================================================================================================================= //
    // = TEST METHOD 1: CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
		
        // CREATE TEST CUSTOM SETTINGS 
        PartnerCentralTemplateTypes__c cs1 = new PartnerCentralTemplateTypes__c();
        cs1.Name = 'Non-Perpetual';
        cs1.TermLength__c = 1095;
        insert cs1;

        PartnerCentralTemplateTypes__c cs2 = new PartnerCentralTemplateTypes__c();
        cs2.Name = 'Perpetual';
        cs2.TermLength__c = 7305;
        insert cs2;
        
        // CREATE TEST ACCOUNT RECORD 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();         
        Id rtPartnerAccountId = AccountRecordTypeInfo.get('Partner Account').getRecordTypeId();    
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEXT FOR AH_PartnerForms_Test Class #1';
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
    
    @isTest static void testPartnerForm1() 
    {
        
        Account a = [SELECT Id FROM Account WHERE Name = 'APEX TEXT FOR AH_PartnerForms_Test Class #1'];
        Contact cnt = [SELECT Id FROM Contact WHERE Email = 'jnauff@somedomain.com'];         
        Partners_Form_Template__c ptNonPer = [SELECT Id FROM Partners_Form_Template__c WHERE Subject__c = 'APEX TEST Non-Perpetual FORM'];
        Partners_Form_Template__c ptPerpet = [SELECT Id FROM Partners_Form_Template__c WHERE Subject__c = 'APEX TEST Perpetual FORM'];
        Partners_Form_Template_to_Account__c pftNonPer = [SELECT Id FROM Partners_Form_Template_to_Account__c WHERE partners_Form_Template__c =: ptNonPer.Id];
        Partners_Form_Template_to_Account__c pftPerpet = [SELECT Id FROM Partners_Form_Template_to_Account__c WHERE partners_Form_Template__c =: ptPerpet.Id];
        User u = [SELECT Id, Partner_Terms_Accepted__c FROM User WHERE ContactId =: cnt.Id AND AccountId =: a.Id];

        // VERIFY PARTNER PORTAL USER WAS UPDATED CORRECTLY DURING DATA CREATION
        system.AssertEquals('False', u.Partner_Terms_Accepted__c, 'Creation of new Partners_Form_Template_to_Account__c record should have set the users Partner_Terms_Accepted__c field to false.');   

        // SET THE CURRENT VF PAGE
        PageReference pageRef;
        AH_PartnerForms ctrl;
        
        system.runAs(u) 
        {
            
            pageRef = Page.AH_PartnerForms;
            Test.setCurrentPage(pageRef);
            ctrl = new AH_PartnerForms();    
            
            // ASSERT THAT VARIABLES WERE POPULATED IN CONSTRUCTOR BASED ON RUNNING USER ID
            system.assertEquals(u.Id, ctrl.usr.Id); 
            system.assertEquals(a.Id, ctrl.accId);             
            system.assertEquals(2, ctrl.lstForms.size()); 
            
            // OPEN TEST Non-Perpetual FORM
            ctrl.formId = ptNonPer.Id; 
            ctrl.openForm();  
            
            // ASSERTIONS
            system.assertEquals(true, ctrl.displayPopup);
            system.assertEquals(ptNonPer.Id, ctrl.frm.Id);
            
        }
        
        ctrl.acceptTerms(); 
        
        // ASSERT THAT ALL FORMS HAVE NOT BEEN ACCEPTED YET 
        boolean bAssertAccept1 = ctrl.allFormsAccepted(a.Id); 
        system.assertEquals(false, bAssertAccept1); 
        
        // ASSERT THAT CONTRACT HAS BEEN CREATED 
        List<Contract> lstContractAsserts1 = new List<Contract>([SELECT Id, StartDate, EndDate FROM Contract WHERE PartnerForm__c =: pftNonPer.Id]); 
        system.assertEquals(1, lstContractAsserts1.size()); 
        
        // OPEN TEST Perpetual FORM 
        ctrl.formId = ptPerpet.Id; 
        ctrl.openForm(); 
        ctrl.acceptTerms(); 
        
        // ASSERT THAT ALL FORMS HAVE BEEN ACCEPTED
        boolean bAssertAccept2 = ctrl.allFormsAccepted(a.Id); 
        system.assertEquals(true, bAssertAccept2); 
        
        // ASSERT THAT CONTRACT HAS BEEN CREATED
        List<Contract> lstContractAsserts2 = new List<Contract>([SELECT Id, StartDate, EndDate FROM Contract WHERE PartnerForm__c =: pftPerpet.Id]); 
        system.assertEquals(1, lstContractAsserts1.size()); 
        
        ctrl.closePopup(); 
        
        ctrl.accessCommunity(); 

        PageReference pageRef2 = Page.AH_PartnerForms; 
        Test.setCurrentPage(pageRef2); 
        AH_PartnerForms ctrl2 = new AH_PartnerForms(); 

    }
    
}