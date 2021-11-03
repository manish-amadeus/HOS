/****************************************************************************************
Name            : AH_LKA_Search_Ctlr
Author          : Sean Harris
Created Date    : 01/08/2020
Last Mod Date   : 01/08/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Test for AH_LKA_Search_Ctlr class.
                :            
******************************************************************************************/
@isTest
public class AH_LKA_Search_Ctlr_Test 
{

    
    // ======================================================================================================================================= 
    // = CREATE TEST DATA
    // ======================================================================================================================================= 
    @testSetup static void createTestData() 
    {
        
        Test.startTest();

        // CREATE TEST ACCOUNT
        Schema.DescribeSObjectResult sch1 = Schema.SObjectType.Account; 
        Map<String, Schema.RecordTypeInfo> AccountRecordTypeInfo = sch1.getRecordTypeInfosByName(); 
        Id rtPropertyAccountId = AccountRecordTypeInfo.get('Property Account').getRecordTypeId();        

        Account a = NI_TestClassData.createTestAccount(2);
        a.Name = 'AH_LKA_Search_Ctlr_Test';
        a.RecordTypeId = rtPropertyAccountId;
        insert a;

        // CREATE 5 TEST LKA RECORDS
        Schema.DescribeSObjectResult sch2 = Schema.SObjectType.Lightning_Knowledge__kav; 
        Map<String, Schema.RecordTypeInfo> LKARecordTypeInfo = sch2.getRecordTypeInfosByName(); 
        Id rtTechnicalDocumentId = LKARecordTypeInfo.get('Technical_Document').getRecordTypeId();            
		Id rtHowDoIId = LKARecordTypeInfo.get('How_Do_I').getRecordTypeId();    
        
        List<Lightning_Knowledge__kav> lstLKInserts = new List<Lightning_Knowledge__kav>();
        
        Lightning_Knowledge__kav kav1 = new Lightning_Knowledge__kav();
        kav1.RecordTypeId = rtTechnicalDocumentId;
        kav1.Title = 'Test LKA Title 1';
        kav1.UrlName = 'Test-LKA-Title-1';
        kav1.Article_Body__c = 'Test LKA body 1';
        kav1.Technical_Document_Internal_Notes__c = 'Test internal notes text 1...';
        kav1.Technical_Document_ResolutionText__c = 'Test resolution text 1...';
        kav1.ValidationStatus = 'Validated';
        kav1.Solution_Domain__c = 'Sales & Catering';
        lstLKInserts.add(kav1);

        Lightning_Knowledge__kav kav2 = new Lightning_Knowledge__kav();
        kav2.RecordTypeId = rtTechnicalDocumentId;
        kav2.Title = 'Test LKA Title 2';
        kav2.UrlName = 'Test-LKA-Title-2';
        kav2.Article_Body__c = 'Test LKA body 2';
        kav2.Technical_Document_Internal_Notes__c = 'Test internal notes text 2...';
        kav2.Technical_Document_ResolutionText__c = 'Test resolution text 2...';
        kav2.ValidationStatus = 'Validated';
        kav2.Solution_Domain__c = 'Sales & Catering';
        lstLKInserts.add(kav2);

        Lightning_Knowledge__kav kav3 = new Lightning_Knowledge__kav();
        kav3.RecordTypeId = rtTechnicalDocumentId;
        kav3.Title = 'Test LKA Title 3';
        kav3.UrlName = 'Test-LKA-Title-3';
        kav3.Article_Body__c = 'Test LKA body 3';
        kav3.Technical_Document_Internal_Notes__c = 'Test internal notes text 3...';
        kav3.Technical_Document_ResolutionText__c = 'Test resolution text 3...';
        kav3.ValidationStatus = 'Validated';
        kav3.Solution_Domain__c = 'Sales & Catering';
        lstLKInserts.add(kav3);

        Lightning_Knowledge__kav kav4 = new Lightning_Knowledge__kav();
        kav4.RecordTypeId = rtHowDoIId;
        kav4.Title = 'Test LKA Title 4';
        kav4.UrlName = 'Test-LKA-Title-4';
        kav4.Article_Body__c = 'Test LKA body 4';
        kav4.Technical_Document_Internal_Notes__c = 'Test internal notes text 4...';
        kav4.Technical_Document_ResolutionText__c = 'Test resolution text 4...';
        kav4.ValidationStatus = 'Validated';
        kav4.Solution_Domain__c = 'Service Optimization';
        lstLKInserts.add(kav4);

        Lightning_Knowledge__kav kav5 = new Lightning_Knowledge__kav();
        kav5.RecordTypeId = rtHowDoIId;
        kav5.Title = 'Test LKA Title 5';
        kav5.UrlName = 'Test-LKA-Title-5';
        kav5.Article_Body__c = 'Test LKA body 5';
        kav5.Technical_Document_Internal_Notes__c = 'Test internal notes text 5...';
        kav5.Technical_Document_ResolutionText__c = 'Test resolution text 5...';
        kav5.ValidationStatus = 'Validated';
        kav5.Solution_Domain__c = 'Service Optimization';
        lstLKInserts.add(kav5);
        
        database.insert(lstLKInserts);
          
        List<Lightning_Knowledge__ka> lstLKAAssert = new List<Lightning_Knowledge__ka>([SELECT Id FROM Lightning_Knowledge__ka]);
        system.debug(' *^* Lightning_Knowledge__ka Record Count = ' + lstLKAAssert.size());
        
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'APEX TEST CASE FOR AH_LKA_Search_Ctlr_Test';
        insert c;
        
        Lightning_Knowledge__kav kavA = [SELECT Id FROM Lightning_Knowledge__kav WHERE Title = 'Test LKA Title 1'];

        CaseArticle ca1 = new CaseArticle();
        ca1.KnowledgeArticleId = kavA.Id;
        ca1.CaseId = c.Id;
        
        Test.stopTest();
        
    }

    // ======================================================================================================================================= 
    // = TEST METHOD 1: TEST LOADING PAGE AND COVERING ALL SEARCH COMBINATIONS
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Lightning_Knowledge__kav kav1 = [SELECT Id FROM Lightning_Knowledge__kav WHERE Title = 'Test LKA Title 1'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'APEX TEST CASE FOR AH_LKA_Search_Ctlr_Test'];
        
        Test.startTest();
     
        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_SolutionSearch;
        Test.setCurrentPage(pr);             
        
        // ADD URL PARAMS
        pr.getParameters().put('caseid', c.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        AH_LKA_Search_Ctlr ctrl = new AH_LKA_Search_Ctlr();        
        
        // TEST SEARCHING WITH KEYWORD 'BEO' (SHOULD RETURN 4 RECORDS BECAUSE 1 OF THE 5 IS INACTIVE)
        ctrl.searchText = 'Test';
        ctrl.doSearch();
        
        system.debug(' *^* ctrl.lstSearchResults.size() = ' + ctrl.lstSearchResults.size());
        
//        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        // TEST SORTING 
        ctrl.sortByField = 'Title';
        
        ctrl.doSort();
        system.assertEquals('DESC', ctrl.sortByDirection);        
//        system.assertEquals(4, ctrl.lstSearchResults.size());        

        ctrl.doSort();
        system.assertEquals('ASC', ctrl.sortByDirection);
//        system.assertEquals(4, ctrl.lstSearchResults.size());
        
        // DO NEW SEARCH
        ctrl.newSearch();

        
        // TEST DRILL DOWN SEARCHING 
        ctrl.searchText = 'test';
        ctrl.doSearch();
        system.assertEquals(5, ctrl.lstSearchResults.size());        
        
        ctrl.searchText = '1';
        ctrl.doSearch();
        system.assertEquals(1, ctrl.lstSearchResults.size());       

        // TEST PREVIOUS BUTTON
        ctrl.goBack();
//        system.assertEquals(2, ctrl.lstSearchResults.size());       
        
        // DO NEW SEARCH
        ctrl.newSearch();
        
        // TEST SEARCH USING DIFFERENT FILTERS
        ctrl.searchText = 'test';
        ctrl.selArticleStatus = 'Online';
        ctrl.selValidationStatus = 'Validated';
        ctrl.selSolutionDomain = 'Service Optimization';
		ctrl.doSearch();        
        
        // DO NEW SEARCH
        ctrl.newSearch();
        
        // TEST "NOT LIKE" SEARCH 
        ctrl.searchText = 'test';
        ctrl.doSearch();
        system.assertEquals(5, ctrl.lstSearchResults.size());
        
        ctrl.searchText = '!1';
        ctrl.doSearch();
        system.assertEquals(4, ctrl.lstSearchResults.size());        

        // TEST CLICKING "Select" LINK
        ctrl.solId = kav1.Id;
        ctrl.iRow = ctrl.lstSearchResults[1].iRowIndex;
        ctrl.showVerify();
        ctrl.hideVerify();
        ctrl.iRow = ctrl.lstSearchResults[1].iRowIndex;
        ctrl.showVerify();
        PageReference pgRef = ctrl.doAttach(); 

        
        Test.stopTest();
                
    }
 
}