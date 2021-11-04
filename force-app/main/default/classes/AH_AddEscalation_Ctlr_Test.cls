/****************************************************************************************
Name            : AH_AddEscalation_Ctlr_Test
Author          : Sean Harris
Created Date    : 11/18/2020
Last Mod Date   : 11/18/2020
Last Mod By     : Sean Harris 
NICC Reference  : 
Description     : Test class for AH_AddEscalation_Ctlr Controller.
                           
******************************************************************************************/
@isTest
public class AH_AddEscalation_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(2);
        a.Name = 'AH_AddEscalation_Ctlr_Test ACCOUNT';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;    
        
        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Jack';
        cnt.LastName = 'Tors';
        cnt.Email = 'jtors@somedomain.com';
        insert cnt;        
        
        // CREATE TEST CASE
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'AH_AddEscalation_Ctlr_Test CASE';
        c.ContactId = cnt.Id;
        insert c;        
        
        // CREATE TEST ESCALATION
        Escalation_QA_Checklists__c e = new Escalation_QA_Checklists__c();   
        insert e;
          
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: SEARCH & ATTACH EXISTING ESCALATION
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_AddEscalation_Ctlr_Test CASE'];
        Escalation_QA_Checklists__c e = [SELECT Id FROM Escalation_QA_Checklists__c];
        
        Test.startTest(); 
     
        // INSTANTIATE PAGE REFERENCE 
        PageReference pr = Page.AH_AddEscalation; 
        Test.setCurrentPage(pr);       
        
        // ADD URL PARAMS 
        pr.getParameters().put('id', c.Id); 
        
        // INSTANTIATE PAGE CONTROLLER         
        AH_AddEscalation_Ctlr ctrl = new AH_AddEscalation_Ctlr(); 

        // ASSET DIV VISIBILTY VARIABLES
        system.assertEquals(true, ctrl.bShowInitialDecision); 
        system.assertEquals(false, ctrl.bEscalationCreated); 
        system.assertEquals(false, ctrl.bShowSearch); 
        system.assertEquals(false, ctrl.bShowSelectRecType); 
        system.assertEquals(false, ctrl.bEscalationAttached); 
        
        // TEST OPEN SEARCH MODE
        ctrl.openSearch();
        
        // ASSET DIV VISIBILTY VARIABLES
        system.assertEquals(false, ctrl.bShowInitialDecision); 
        system.assertEquals(false, ctrl.bEscalationCreated); 
        system.assertEquals(true, ctrl.bShowSearch); 
        system.assertEquals(false, ctrl.bShowSelectRecType); 
        system.assertEquals(false, ctrl.bEscalationAttached); 
        
        // TEST DO SEARCH
		ctrl.searchText = '%';
        ctrl.doSearch();
        
        // ASSERT RECORD WAS FOUND
        system.assertEquals(1, ctrl.lstEscalationResults.size());
        ctrl.selSearchId = ctrl.lstEscalationResults[0].Id;
        
        // TEST DO SELECT ESCALATION
        ctrl.doSelect();
        
        // ASSET DIV VISIBILTY VARIABLES
        system.assertEquals(false, ctrl.bShowInitialDecision); 
        system.assertEquals(false, ctrl.bEscalationCreated); 
        system.assertEquals(false, ctrl.bShowSearch); 
        system.assertEquals(false, ctrl.bShowSelectRecType); 
        system.assertEquals(true, ctrl.bEscalationAttached); 

        // ASSERT SUCCESS
        List<Escalations_2_Cases__c> lstEsc2Case = new List<Escalations_2_Cases__c>([SELECT Case__c, Escalation__c FROM Escalations_2_Cases__c]);
        system.assertEquals(1, lstEsc2Case.size());
        system.assertEquals(c.Id, lstEsc2Case[0].Case__c); 
        system.assertEquals(e.Id, lstEsc2Case[0].Escalation__c);
        
		ctrl.goToCase();


        Test.stopTest(); 
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: CREATE & ATTACH NEW ESCALATION
    // =======================================================================================================================================    
    @isTest static void test2() 
    {
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'AH_AddEscalation_Ctlr_Test CASE'];
        
        Test.startTest(); 
     
        // INSTANTIATE PAGE REFERENCE 
        PageReference pr = Page.AH_AddEscalation; 
        Test.setCurrentPage(pr);       
        
        // ADD URL PARAMS 
        pr.getParameters().put('id', c.Id); 
        
        // INSTANTIATE PAGE CONTROLLER         
        AH_AddEscalation_Ctlr ctrl = new AH_AddEscalation_Ctlr(); 

        // ASSET DIV VISIBILTY VARIABLES
        system.assertEquals(true, ctrl.bShowInitialDecision); 
        system.assertEquals(false, ctrl.bEscalationCreated); 
        system.assertEquals(false, ctrl.bShowSearch); 
        system.assertEquals(false, ctrl.bShowSelectRecType); 
        system.assertEquals(false, ctrl.bEscalationAttached); 
        
        // TEST OPEN SEARCH MODE
        ctrl.doRecTypeSel();
        
        // ASSET DIV VISIBILTY VARIABLES
        system.assertEquals(false, ctrl.bShowInitialDecision); 
        system.assertEquals(false, ctrl.bEscalationCreated); 
        system.assertEquals(false, ctrl.bShowSearch); 
        system.assertEquals(true, ctrl.bShowSelectRecType); 
        system.assertEquals(false, ctrl.bEscalationAttached); 
        
        // TEST RECORD TYPE SELECTION
		//SelectOption selOpt = new SelectOption(lstRecordTypes[0]);
		ctrl.selRecordType = ctrl.lstRecordTypes[0].getValue();
        ctrl.doCreate();
        
        // ASSET DIV VISIBILTY VARIABLES
        system.assertEquals(false, ctrl.bShowInitialDecision); 
        system.assertEquals(true, ctrl.bEscalationCreated); 
        system.assertEquals(false, ctrl.bShowSearch); 
        system.assertEquals(false, ctrl.bShowSelectRecType); 
        system.assertEquals(false, ctrl.bEscalationAttached); 

        // ASSERT SUCCESS
        Escalation_QA_Checklists__c e = [SELECT Id FROM Escalation_QA_Checklists__c WHERE Related_Case__c =: c.Id];
        List<Escalations_2_Cases__c> lstEsc2Case = new List<Escalations_2_Cases__c>([SELECT Case__c, Escalation__c FROM Escalations_2_Cases__c WHERE Escalation__c =: e.Id]);
        system.assertEquals(1, lstEsc2Case.size());
        system.assertEquals(c.Id, lstEsc2Case[0].Case__c); 
        
        Test.stopTest();     
    }
    
}