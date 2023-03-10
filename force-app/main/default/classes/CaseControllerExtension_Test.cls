/****************************************************************************************
Name            : CaseControllerExtension_Test 
Author          : Sean Harris
Created Date    : 04/13/2017
Last Mod Date   : 11/09/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Tests controller extension for VF page called OverrideCase
                : NICC-054506 - COMMENTED LINES
****************************************************************************************/
@isTest
public class CaseControllerExtension_Test 
{
    
    static testMethod void CaseControllerExtensionTest() 
    {

        // CREATE TEST DATA ==========================================================
        
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'APEX TEST');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'APEX-TEST-01', 'Subscription');        
        insert prd;
        
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        SFDC_CSP_Development_Request__c cr01 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);    
		cr01.Title__c = 'APEX TESTER 01';
        insert cr01;
        
        Account a = NI_TestClassData.createTestAccount(1);
        a.Name = 'APEX TEST CaseControllerExtension ACCOUNT 1';
        insert a;
		
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Status = 'New';
        c.Origin = 'Phone';
        c.Change_Request__c = cr01.Id;
        insert c;

        Id rtId = NI_TestClassData.getRecordTypeId('Solution', 'Child Solution');

        Solution s = NI_TestClassData.createSolution(1); 
        s.RecordTypeId = rtId;
        insert s;
        
        Solution s2 = NI_TestClassData.createSolution(2); 
        s2.RecordTypeId = rtId;
        insert s2;        
        
		List<CaseSolution> lstCaseSolution = new List<CaseSolution>();
        CaseSolution cs1 = NI_TestClassData.createCaseSolution(c.Id, s.Id);
        lstCaseSolution.add(cs1);
        CaseSolution cs2 = NI_TestClassData.createCaseSolution(c.Id, s2.Id);
        lstCaseSolution.add(cs2);
        database.insert(lstCaseSolution);

        List<CaseSolution> lstCaseSolutionAsserts = new List<CaseSolution>([SELECT Id FROM CaseSolution]);
        system.assertEquals(2, lstCaseSolutionAsserts.size(), 'Problem with inserted CaseSolution test records!');
    
        
        
        // TEST PAGE ==========================================================
        
		PageReference pr = Page.OverrideCase;
		
		pr.getParameters().put('id', c.Id);
		pr.getParameters().put('a_case_soln', s.Id);
		Test.setCurrentPageReference(pr);
		ApexPages.StandardController std = new ApexPages.StandardController(c);
		CaseControllerExtension cce = new CaseControllerExtension(std);
		cce.caseRedirect();
		
		pr.getParameters().put('id', '');
		pr.getParameters().put('a_case_soln', '');
		Test.setCurrentPageReference(pr);
		std = new ApexPages.StandardController(c);
		cce = new CaseControllerExtension(std);
		cce.caseRedirect();		
		
		pr.getParameters().remove('a_case_soln');
		pr.getParameters().put('r_case_soln', s2.Id);
		Test.setCurrentPageReference(pr);
		std = new ApexPages.StandardController(c);
		cce = new CaseControllerExtension(std);
		cce.caseRedirect();
		
        pr.getParameters().put('r_case_soln', '');
        Test.setCurrentPageReference(pr);
        std = new ApexPages.StandardController(c);
        cce = new CaseControllerExtension(std);
        cce.caseRedirect();		
        
        // NICC-054506 - COMMENTED LINES
        //SFDC_CSP_Development_Request__c crAssert = [SELECT Id, Number_of_Cases_Linked__c FROM SFDC_CSP_Development_Request__c WHERE Title__c = 'APEX TESTER 01'];
		//system.assertEquals(1, crAssert.Number_of_Cases_Linked__c);
        
        
    }
    
}