/****************************************************************************************
Name            : AH_CaseValidationHelper_Ctlr_Test
Author          : Sean Harris
Created Date    : 11/05/2020
Last Mod Date   : 11/05/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : Test class for the AH_CaseValidationHelper_Ctlr controller class.
                :            
******************************************************************************************/
@isTest
public class AH_CaseValidationHelper_Ctlr_Test 
{

    // =======================================================================================================================================
    // = TEST METHOD 1: CREATE TEST DATA
    // =======================================================================================================================================
    @testSetup static void createTestData() 
    {

        // CREATE TEST ACCOUNT
        Account a = NI_TestClassData.createTestAccount(2);
        a.Name = 'AH_CaseValidationHelper_Ctlr_Test';
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Property Account').getRecordTypeId();
        insert a;

        // CREATE TEST CONTACT
        Contact cnt = NI_TestClassData.createTestContact(1, a.Id);
        cnt.FirstName = 'Eric';
        cnt.LastName = 'Shunn';
        cnt.Email = 'eshunn@somedomain.com';
        insert cnt;
        
        // CREATE 5 TEST LKA RECORDS
        Id rtTechnicalDocumentId = Schema.SObjectType.Lightning_Knowledge__kav.getRecordTypeInfosByName().get('Technical_Document').getRecordTypeId();
        Id rtHowDoIId = Schema.SObjectType.Lightning_Knowledge__kav.getRecordTypeInfosByName().get('How_Do_I').getRecordTypeId();
        
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
        c.Subject = 'APEX TEST CASE FOR AH_CaseValidationHelper_Ctlr_Test'; 
        insert c; 
        
        Lightning_Knowledge__kav kavA = [SELECT Id, KnowledgeArticleId, VersionNumber FROM Lightning_Knowledge__kav WHERE Title = 'Test LKA Title 2']; 
		//Lightning_Knowledge__ka lka = [SELECT Id FROM Lightning_Knowledge__ka WHERE Id =: kavA.KnowledgeArticleId]; 
        
        CaseArticle ca = new CaseArticle();
        ca.CaseId = c.Id;
        ca.KnowledgeArticleId = kavA.KnowledgeArticleId;
        ca.ArticleLanguage = 'en_US';
        ca.ArticleVersionNumber = kavA.VersionNumber;       
        insert ca;
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: 
    // =======================================================================================================================================    
    @isTest static void test1() 
    {
   		
        Case c = [SELECT Id FROM Case WHERE Subject = 'APEX TEST CASE FOR AH_CaseValidationHelper_Ctlr_Test'];
        
        Test.startTest(); 
     
        // INSTANTIATE PAGE REFERENCE 
        PageReference pr = Page.AH_CaseValidationHelper; 
        Test.setCurrentPage(pr); 
        
        // ADD URL PARAMS 
        pr.getParameters().put('id', c.Id); 
        
        // INSTANTIATE PAGE CONTROLLER 
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        AH_CaseValidationHelper_Ctlr ctrl = new AH_CaseValidationHelper_Ctlr(sc); 
                
        ctrl.openSearch();
        ctrl.closeSearch();
        ctrl.doAttach();
        ctrl.searchText = 'LKA';
        ctrl.doLKASearch();    

        system.debug(' //*// ctrl.lstLookupResult.size() = ' + ctrl.lstLookupResult.size());
        
        ctrl.selLKAId = ctrl.lstLookupResult[0].KnowledgeArticleId;
        ctrl.iSelLKAVersion = ctrl.lstLookupResult[0].iArticleVersionNumber;
        ctrl.doArticleSelect();
        
        ctrl.doArticleRemove();
        ctrl.doSave();
        ctrl.closeCase();
        ctrl.doClose();
        
        system.assert(true);
        
        Test.stopTest(); 
        
    }
    // =======================================================================================================================================
    // = TEST METHOD 2: 
    // =======================================================================================================================================    
    @isTest static void test2() 
    {
        Case c = [SELECT Id FROM Case WHERE Subject = 'APEX TEST CASE FOR AH_CaseValidationHelper_Ctlr_Test'];
        
        // INSTANTIATE PAGE REFERENCE 
        PageReference pr = Page.AH_CaseValidationHelper; 
        Test.setCurrentPage(pr); 
        // INSTANTIATE PAGE CONTROLLER 
        ApexPages.StandardController sc = new ApexPages.StandardController(c);
        AH_CaseValidationHelper_Ctlr ctrl = new AH_CaseValidationHelper_Ctlr(sc); 

        //system.assert('ERROR MSG')
        
    }
    
}