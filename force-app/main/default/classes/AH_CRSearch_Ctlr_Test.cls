/*************************************************************************************************
Name            : AH_CRSearch_Ctlr_Test Class
Author          : Sean Harris
Created Date    : 09/21/2021
Last Mod Date   : 09/21/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test for AH_CRSearch_Ctlr Controller
                : 
                : 
*************************************************************************************************/
@isTest
public class AH_CRSearch_Ctlr_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();

        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST AH_CRSearch_Ctlr_Test';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'APEX TEST AH_CRSearch_Ctlr_Test';
        insert c;       
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;

        // CREATE 5 TEST CR RECORDS
        List<SFDC_CSP_Development_Request__c> lstCRInserts = new List<SFDC_CSP_Development_Request__c>();
        
        SFDC_CSP_Development_Request__c s1 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);     
        s1.Title__c = 'CR Apex Test 1';
        s1.Public_Status__c = 'New';
        s1.Public_Status_Description__c = 'Apex test 1';
        lstCRInserts.add(s1);
    
        SFDC_CSP_Development_Request__c s2 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 2);     
        s2.Title__c = 'CR Apex Test 2';
        s2.Public_Status__c = 'New';
        s2.Public_Status_Description__c = 'Apex test 2';
        lstCRInserts.add(s2);
                
        SFDC_CSP_Development_Request__c s3 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 3);     
        s3.Title__c = 'CR Apex Test 3 TWO';
        s3.Public_Status__c = 'New';
        s3.Public_Status_Description__c = 'Apex test 3';
        lstCRInserts.add(s3);
                
        SFDC_CSP_Development_Request__c s4 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 4);     
        s4.Title__c = 'CR Apex Test 3 TWO ONE';
        s4.Public_Status__c = 'New';
        s4.Public_Status_Description__c = 'Apex test 4';
        lstCRInserts.add(s4);
                
        SFDC_CSP_Development_Request__c s5 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 5);     
        s5.Title__c = 'CR Apex Te5t 5';
        s5.Public_Status__c = 'New';
        s5.Public_Status_Description__c = 'Apex test 5';
        lstCRInserts.add(s5);
        
        database.insert(lstCRInserts);
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST LOADING PAGE AND COVERING ALL SEARCH COMBINATIONS
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Test.startTest();
     
        Case c = [SELECT Id, Subject FROM Case WHERE Subject = 'APEX TEST AH_CRSearch_Ctlr_Test'];
        
        // INSTANTIATE PAGE REFERENCE AND SET URL PARAM FOR CASE ID
        PageReference pr = Page.AH_CRSearch;
        pr.getParameters().put('caseid', c.Id);
        Test.setCurrentPage(pr);             
        
        // INSTANTIATE PAGE CONTROLLER 
        AH_CRSearch_Ctlr ctrl = new AH_CRSearch_Ctlr();       
        

        ctrl.searchText = 'test';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        // TEST SORTING 
        ctrl.sortByField = 'Name';
        
        ctrl.doSort();
        system.assertEquals('DESC', ctrl.sortByDirection);        
        system.assertEquals(4, ctrl.lstSearchResults.size());        

        ctrl.doSort();
        system.assertEquals('ASC', ctrl.sortByDirection);
        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        // DO NEW SEARCH
        ctrl.newSearch();

        // TEST DRILL DOWN SEARCHING 
        ctrl.selPublicStatus = 'New';
        
        ctrl.searchText = 'Test';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());        
        
        ctrl.searchText = 'TWO';
        ctrl.doSearch();
        system.assertEquals(2, ctrl.lstSearchResults.size());       

        ctrl.searchText = 'ONE';
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size());  
        
        // TEST PREVIOUS BUTTON
        ctrl.goBack();
        system.assertEquals(2, ctrl.lstSearchResults.size());       
        
        // DO NEW SEARCH
        ctrl.newSearch();
        
        // TEST "NOT LIKE" SEARCH 
        ctrl.searchText = 'CR Apex';
        ctrl.doSearch();
        system.assertEquals(5, ctrl.lstSearchResults.size());
        
        ctrl.searchText = '!te5t';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());        
        
        ctrl.strCRId = ctrl.lstSearchResults[0].crId;
        ctrl.strCRNumber = ctrl.lstSearchResults[0].crNumber;
        ctrl.strCRTitle = ctrl.lstSearchResults[0].crTitle;  

		ctrl.showConfirmation(); 
        system.assertEquals(true, ctrl.displayConfirm);
        
		ctrl.hideConfirmation();
        system.assertEquals(false, ctrl.displayConfirm);
        
		ctrl.showConfirmation(); 
        system.assertEquals(true, ctrl.displayConfirm);
        
		ctrl.attachCR();
        
        List<Case> lstCaseAssert1 = new List<Case>([SELECT Id, Subject, Change_Request__c FROM Case WHERE Subject LIKE '%APEX TEST AH_CRSearch_Ctlr_Test']);
        system.assertEquals(lstCaseAssert1.isEmpty(), false);
        system.assertEquals(lstCaseAssert1.size(), 1);
        system.assertEquals(lstCaseAssert1[0].Subject, ctrl.strCRNumber + ': APEX TEST AH_CRSearch_Ctlr_Test');
        system.assertEquals(lstCaseAssert1[0].Change_Request__c, (Id)ctrl.strCRId);
        
        system.assertEquals(false, ctrl.displayConfirm);
        system.assertEquals(false, ctrl.displayConfirm);
        system.assertEquals(false, ctrl.displayConfirm);
        
        
        ctrl.backToCase();
        
        Test.stopTest();
                
    }

}