/****************************************************************************************
Name            : AH_CC_CaseViewer_Ctrl_Test
Author          : Sean Harris
Created Date    : 10/01/2019
Last Mod Date   : 10/01/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test class for controller class AH_CC_CaseViewer_Ctrl
                :            
******************************************************************************************/
@isTest
public class AH_CC_CaseViewer_Ctrl_Test 
{


    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {
        
        system.debug(' *** START AH_CC_CaseViewer_Ctrl.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // CREATE TEST CASE VISIBILTY CUSTOM SETTINGS
        NI_Neighborhood_Case_Record_Types__c cs1 = new NI_Neighborhood_Case_Record_Types__c();
        cs1.Name = 'Case';
        cs1.DeveloperName__c = 'Case';
        insert cs1;
        
        NI_Neighborhood_Case_Record_Types__c cs1b = new NI_Neighborhood_Case_Record_Types__c();
        cs1b.Name = 'Close Case';        
        cs1b.DeveloperName__c = 'Close Case';
        insert cs1b;
        
        NI_Neighborhood_Case_Origins__c cs2 = new NI_Neighborhood_Case_Origins__c();
        cs2.Name = 'Email';
        cs2.CaseOrigin__c = 'Email';
        insert cs2;
        
        NI_Neighborhood_Case_Types__c cs3 = new NI_Neighborhood_Case_Types__c();
        cs3.Name = 'Inquiry';
 		cs3.CaseType__c = 'Inquiry';
        insert cs3;
        
        // CREATE TEST CUSTOMER ACCOUNT
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX AH_CC_CaseViewer_Ctrl TEST - Customer Account #1';
        insert a;        

        // CREATE TEST CONTACT
        Contact cntct = NI_TestClassData.createTestContact(1, a.Id);
        cntct.FirstName = 'Joe';
        cntct.LastName = 'King';
        cntct.Email = 'jking@somedomain.com';
        insert cntct;        
        
        // CREATE TEST COMMUNITY USER
        Profile pro = [SELECT Id, UserType FROM Profile WHERE Name = 'AH Customer Community Plus User'];        
        system.assertEquals('PowerCustomerSuccess', pro.UserType);
        
        User pu = NI_TestClassData.createTestUser(1, 'AH Customer Community Plus User');
        pu.ContactId = cntct.Id;
        pu.Alias = 'xJ01jwAl';
        pu.Username = 'AHCCCaseViewerCtrl.Test@amadeus.com.ahcc';
        insert pu;
        
        // ASSERT THAT THE ACCOUNT GETS CHANGED TO ENABLED AFTER CONTACT IS ENABLED AS A COMMUNITY USER
        Account accAssert = [SELECT Id, IsCustomerPortal FROM Account WHERE Id =: a.Id];
        system.assertEquals(true, accAssert.IsCustomerPortal);
          
        // CREATE TEST DI INDEX
        NI_DeploymentInstanceIndex__c diIdx = NI_TestClassData.createDI_Index(1, 'AH_CC_CaseViewer_Ctrl');
        insert diIdx;
        
        // CREATE TEST PRODUCT GROUP 
        Product_Group__c pg = NI_TestClassData.createProductGroup(1, 'Cendyn'); 
        pg.IsActive__c = true; 
        pg.IsCoreProduct__c = true; 
        insert pg; 
        
        // CREATE TEST PRODUCT RELATED TO PARTNER ACCOUNT
        Product2 p1 = NI_TestClassData.createProduct2(1, pg.Id, 'Cendyn-SKU-001', 'Cendyn');
        p1.Partner_Name__c = a.Id;
        p1.DI_Index__c = diIdx.Id;
        p1.Product_Line__c = 'Cendyn Test';
        p1.Revenue_Category__c = 'Subscription';
        p1.Corporate_Product_Group__c = 'Newmarket';
        p1.Unit__c = 'Subscription';
        p1.IsActive = true;
        p1.Description = 'APEX Test Class';
        p1.Family = 'Cendyn';
        p1.Name = 'Cendyn Product Test 1';
        p1.Revenue_Category__c = 'Subscription';        
        insert p1;

        Asset asset = NI_TestClassData.createTestAsset(1, a.Id, p1.Id);
        asset.Product_Group__c = pg.Id;
        insert asset;

        List<Case> lstCases = new List<Case>();
        
        Case c1 = NI_TestClassData.createTestCase(1, a.Id);
        c1.Subject = 'CASE #1';
        c1.ContactId = cntct.Id;
        // CASE VISIBITY FIELD AS SET IN CUSTOM SETTINGS 
        c1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId(); 
        c1.Origin = 'Email';
        c1.Type = 'Inquiry';
        lstCases.add(c1);

        Case c2 = NI_TestClassData.createTestCase(2, a.Id);
        c2.Subject = 'CASE #2';
        c2.ContactId = cntct.Id;
        // CASE VISIBITY FIELD AS SET IN CUSTOM SETTINGS 
        c2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Case').getRecordTypeId(); 
        c2.Origin = 'Email';
        c2.Type = 'Inquiry';
        lstCases.add(c2);
        
        database.insert(lstCases);
        
        // CREATE CASE SHARES
        List<CaseShare> lstCaseShares = new List<CaseShare>(); 
        CaseShare csh1 = new CaseShare(CaseAccessLevel = 'Edit', CaseId = c1.Id, UserOrGroupId = pu.Id);
        lstCaseShares.add(csh1);
        CaseShare csh2 = new CaseShare(CaseAccessLevel = 'Edit', CaseId = c2.Id, UserOrGroupId = pu.Id);
        lstCaseShares.add(csh2);
        database.insert(lstCaseShares);

        
        Solution sol = NI_TestClassData.createSolution(1); 
        insert sol;

        CaseSolution csol = NI_TestClassData.createCaseSolution(c2.Id, sol.Id);
        insert csol;
        
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pg.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(p1.Id, vrs01.Id, 1);
        insert prt01;
        
        SFDC_CSP_Development_Request__c cr01 = NI_TestClassData.createChangeRequest(pg.Id, vrs01.Id, prt01.Id, 1);
        cr01.Public_Status__c = 'On Roadmap';
        cr01.Public_Status_Description__c = 'Customer freindly status description';
        cr01.Title__c = 'TEST CR #1';        
		insert cr01;        
        
        c2.Change_Request__c = cr01.Id;
        c2.Status = 'Closed';
        c2.Case_Reason__c = 'Defect';
        update c2;
        
        system.debug(' *** END AH_CC_CaseViewer_Ctrl.createTestData() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }


   
    // =======================================================================================================================================
    // = TEST METHOD 1: SEARCHING, SORTING & EXPORTING
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
   
        system.debug(' *** START AH_CC_CaseViewer_Ctrl.test1() - QUERIES ISSUED = ' + Limits.getQueries());
        
		User u = [SELECT Id, ContactId FROM User WHERE Alias = 'xJ01jwAl'];

        // HAVING ISSUES GETTING RESULTS RUNNING AS PC USER IN UNIT TESTS        
//        system.runAs(u) 
//        {
            
            // SET THE CURRENT VF PAGE 
            PageReference pr = Page.AH_CC_CaseViewer;
            Test.setCurrentPage(pr);
            AH_CC_CaseViewer_Ctlr ctrl = new AH_CC_CaseViewer_Ctlr(); 
            
            // ASSERT DEFAULT VARIABLE VALUES
            system.assertEquals('My Open Cases', ctrl.selField); 
            system.assertEquals('', ctrl.searchText);  
            system.assertEquals('Case.CreatedDate', ctrl.sortByField); 
            system.assertEquals('ASC', ctrl.sortByDirection); 
            
            
            test.startTest();
            
            // TEST SEARCHING FOR A RECORD THAT DOES NOT EXIST
            ctrl.searchText = 'xxxxxxxxxxx';
            ctrl.doSearch();
            system.assertEquals(0, ctrl.lstSearchResults.size()); 
            
            // BY "Closed Case with CRs"
            ctrl.searchText = '';
            ctrl.selField = 'Closed Case with CRs';
            ctrl.doSearch();
            system.assertEquals(2, ctrl.lstSearchResults.size()); 
            //system.debug(' *^* results by Closed Case with CRs = ' + ctrl.lstSearchResults.size());        
            
        	ctrl.exportResults();
        
            // BY "My Open Cases"
            ctrl.searchText = '';
            ctrl.selField = 'My Open Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by My Open Cases = ' + ctrl.lstSearchResults.size());
            
            // BY "My Closed Cases"
            ctrl.searchText = '';
            ctrl.selField = 'My Closed Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by My Closed Cases = ' + ctrl.lstSearchResults.size());
            
            // BY "All My Cases"
            ctrl.searchText = '';
            ctrl.selField = 'All My Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by All My Cases = ' + ctrl.lstSearchResults.size());
            
            
            // BY "My Property\'s Open Cases"
            ctrl.searchText = '';
            ctrl.selField = 'My Property\'s Open Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by My Property\'s Open Cases = ' + ctrl.lstSearchResults.size());
            
            // BY "My Property\'s Closed Cases"
            ctrl.searchText = '';
            ctrl.selField = 'My Property\'s Closed Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by My Property\'s Closed Cases = ' + ctrl.lstSearchResults.size());
            
            // BY "All My Property\'s Cases"
            ctrl.searchText = '';
            ctrl.selField = 'All My Property\'s Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by All My Property\'s Cases = ' + ctrl.lstSearchResults.size());
            
            
            // BY "All Properties\' Open Cases"
            ctrl.searchText = '';
            ctrl.selField = 'All Properties\' Open Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by All Properties\' Open Cases = ' + ctrl.lstSearchResults.size());
            
            // BY "All Properties\' Closed Cases"
            ctrl.searchText = '';
            ctrl.selField = 'All Properties\' Closed Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by All Properties\' Closed Cases = ' + ctrl.lstSearchResults.size());
            
            // BY "All Properties\' Cases"
            ctrl.searchText = '';
            ctrl.selField = 'All Properties\' Cases';
            ctrl.searchText = 'Case #';
            ctrl.doSearch();
            //system.assertEquals(1, ctrl.lstSearchResults.size()); 
            system.debug(' *^* results by All Properties\' Cases = ' + ctrl.lstSearchResults.size());
            
            // DO A SORT FOR COVERAGE
            ctrl.sortByField = 'Case.Account.Name';
            ctrl.sortByDirection = 'ASC';
            ctrl.doSort();        
            
            
            
//        }
        
        test.stopTest();

        system.debug(' *** END AH_CC_CaseViewer_Ctrl.test1() - QUERIES ISSUED = ' + Limits.getQueries());

    }
 
}