/****************************************************************************************
Name            : AH_SolutionSearch_Ctlr_Test
Author          : Sean Harris
Created Date    : 04/10/2019
Last Mod Date   : 04/10/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034157
Description     : Test class for AH_SolutionSearch_Ctlr
                :            
******************************************************************************************/
@isTest
public class AH_SolutionSearch_Ctlr_Test 
{
    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();

        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        

        Account a = NI_TestClassData.createTestAccount(2);
        a.Name = 'APEX TEST PROPERTY ACCOUNT 1';
        a.RecordTypeId = rtPropertyAccountId;
        insert a;

        // CREATE 5 TEST SOLUTION RECORDS
        List<Solution> lstSolutionInserts = new List<Solution>();
        
        Solution s1 = NI_TestClassData.createSolution(1); 
        s1.SolutionName = 'BEO Test Solution';
        s1.Solution_Category__c = 'Systems Engineering';
        s1.Business_Domain__c = 'S&C';
        s1.Status = 'Active';
        lstSolutionInserts.add(s1);
    
        Solution s2 = NI_TestClassData.createSolution(2); 
        s2.SolutionName = 'BEO Form Test Solution';
        s2.Business_Domain__c = 'S&C';
        s2.Status = 'Active';
        lstSolutionInserts.add(s2);
                
        Solution s3 = NI_TestClassData.createSolution(3); 
        s3.SolutionName = 'BEO Form Merge Test Solution';
        s3.Business_Domain__c = 'S&C';
        s3.Status = 'Active';
        lstSolutionInserts.add(s3);
                
        Solution s4 = NI_TestClassData.createSolution(4); 
        s4.SolutionName = 'BEO Form Merge Tax Test Solution';
        s4.Solution_Category__c = 'Systems Engineering';
        s4.Business_Domain__c = 'S&C';
        s4.Status = 'Inactive';
        lstSolutionInserts.add(s4);
                
        Solution s5 = NI_TestClassData.createSolution(5); 
        s5.SolutionName = 'ASEM BEO Test Solution';
        s5.Business_Domain__c = 'S&C';
        s5.Status = 'Active';
        lstSolutionInserts.add(s5);
        
        database.insert(lstSolutionInserts);
        
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'APEX TEST CASE FOR AH_SolutionSearch_Ctlr_Test';
        insert c;
        
        Solution sol = [SELECT Id FROM Solution WHERE SolutionName = 'ASEM BEO Test Solution'];
        
        CaseSolution csol = NI_TestClassData.createCaseSolution(c.Id, sol.Id);
        insert csol;        
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST LOADING PAGE AND COVERING ALL SEARCH COMBINATIONS
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Solution s1 = [SELECT Id FROM Solution WHERE SolutionName = 'BEO Test Solution'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'APEX TEST CASE FOR AH_SolutionSearch_Ctlr_Test'];
        
        Test.startTest();
     
        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_SolutionSearch;
        Test.setCurrentPage(pr);             
        
        // ADD URL PARAMS
        pr.getParameters().put('caseid', c.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        AH_SolutionSearch_Ctlr ctrl = new AH_SolutionSearch_Ctlr();        
        
        // TEST SEARCHING WITH KEYWORD 'BEO' (SHOULD RETURN 4 RECORDS BECAUSE 1 OF THE 5 IS INACTIVE)
        ctrl.searchText = 'BEO';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        // TEST SORTING 
        ctrl.sortByField = 'SolutionName';
        
        ctrl.doSort();
        system.assertEquals('DESC', ctrl.sortByDirection);        
        system.assertEquals(4, ctrl.lstSearchResults.size());        

        ctrl.doSort();
        system.assertEquals('ASC', ctrl.sortByDirection);
        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        // DO NEW SEARCH
        ctrl.newSearch();
        
        // TEST SEARCHING WITH KEYWORD 'BEO' & USER OPTIONS SELECT (SHOULD RETURN 5 RECORDS)
        ctrl.toggleSystemEngineering();
        system.assertEquals(true, ctrl.isSystemsEngineering);
        ctrl.selBusinessDomain = 'S&C';
        ctrl.selSolutionStatus = 'Inactive';
        ctrl.searchText = 'BEO';
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size());
        
        // DO NEW SEARCH
        ctrl.newSearch();
        
        // TEST DRILL DOWN SEARCHING 
        ctrl.isSystemsEngineering = false;
        ctrl.selBusinessDomain = 'All';
        ctrl.selSolutionStatus = 'Default';
        
        ctrl.searchText = 'BEO';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());        
        
        ctrl.searchText = 'Form';
        ctrl.doSearch();
        system.assertEquals(2, ctrl.lstSearchResults.size());       

        ctrl.searchText = 'Merge';
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size());  
        
        // TEST PREVIOUS BUTTON
        ctrl.goBack();
        system.assertEquals(2, ctrl.lstSearchResults.size());       
        
        // DO NEW SEARCH
        ctrl.newSearch();
        
        // TEST "NOT LIKE" SEARCH 
        ctrl.searchText = 'BEO';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        ctrl.searchText = '!Form';
        ctrl.doSearch();
        system.assertEquals(2, ctrl.lstSearchResults.size());        
        
        // TEST CLICKING "Select" LINK
        ctrl.solId = s1.Id;
        PageReference pgRef = ctrl.selectSol(); 
  
        Test.stopTest();
                
    }


    // ======================================================================================================================================= 
    // = TEST METHOD 2: TESTS DEFAULT STATUS ASSIGNMENT BY RUNNING USER'S SUPPORT TIER DESIGNATION BUSINESS DOMAIN
    // ======================================================================================================================================= 
    @isTest static void test2() 
    {
        
        User u = NI_TestClassData.createTestUser(1, 'NI Support CSR'); 
        insert u;

        Support_Tier_Designation__c std = NI_TestClassData.createSupportTierDesignation(1, u.Id, 'Level 1 Support');
        std.Business_Domain__c = 'Sales & Catering';
        insert std;

        system.runAs(u)
        {
            // INSTANTIATE PAGE REFERENCE
            PageReference pr = Page.AH_SolutionSearch;
            Test.setCurrentPage(pr);             
            
            // INSTANTIATE PAGE CONTROLLER 
            AH_SolutionSearch_Ctlr ctrl = new AH_SolutionSearch_Ctlr(); 
            system.assertEquals('S&C', ctrl.selBusinessDomain);   
            ctrl.isSystemsEngineering = true;
            ctrl.toggleSystemEngineering();
        }
     
    }

}