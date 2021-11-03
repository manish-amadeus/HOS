/****************************************************************************************
Name            : AH_SolutionDetails_Ctlr_Test
Author          : Sean Harris
Created Date    : 04/10/2019
Last Mod Date   : 04/10/2019
Last Mod By     : Sean Harris
NICC Reference  : NICC-034157
Description     : Test class for AH_SolutionDetails_Ctlr
                :            
******************************************************************************************/
@isTest
public class AH_SolutionDetails_Ctlr_Test 
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

        Case c = NI_TestClassData.createTestCase(1, a.Id);
        c.Subject = 'APEX TEST CASE FOR AH_SolutionDetails_Ctlr_Test';
        insert c;

        // CREATE TEST SOLUTION RECORD
        Solution s1 = NI_TestClassData.createSolution(1); 
        s1.SolutionName = 'BEO Test Solution';
        s1.Solution_Category__c = 'Systems Engineering';
        s1.Business_Domain__c = 'S&C';
        s1.Status = 'Active';
        insert s1;        
        
        Test.stopTest();
        
    }
    
    // ======================================================================================================================================= 
    // = TEST METHOD 1: 
    // ======================================================================================================================================= 
    @isTest static void test1() 
    {
        
        Solution s = [SELECT Id FROM Solution WHERE SolutionName = 'BEO Test Solution'];
        Case c = [SELECT Id FROM Case WHERE Subject = 'APEX TEST CASE FOR AH_SolutionDetails_Ctlr_Test'];
        
        Test.startTest();

        // INSTANTIATE PAGE REFERENCE
        PageReference pr = Page.AH_SolutionDetails;
        Test.setCurrentPage(pr);             
        
        // ADD URL PARAMS
        pr.getParameters().put('id', s.Id);
        pr.getParameters().put('caseid', c.Id);
        
        // INSTANTIATE PAGE CONTROLLER 
        AH_SolutionDetails_Ctlr ctrl = new AH_SolutionDetails_Ctlr(new ApexPages.StandardController(s));            
        
        ctrl.attachCase();
        
        List<CaseSolution> lstCaseSolutionAsserts = new List<CaseSolution>([SELECT Id FROM CaseSolution WHERE CaseId =: c.Id AND SolutionId =: s.Id]);
        system.assertEquals(1, lstCaseSolutionAsserts.size());
        
        Test.stopTest();
                
    }
    
}