@isTest
private class SolutionNewExtensionTestClass 
{

    static testMethod void myUnitTest() 
    {

        Solution sol = NI_TestClassData.createSolution(1); 
        insert sol;

        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
                
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        SFDC_CSP_Development_Request__c cr1 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);        
        insert cr1;
        
        SFDC_CSP_Development_Request__c cr2 = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);      
        insert cr2;
        
        
        // PAGE REFERENCE
        PageReference pageRef = Page.SolutionNew;
        Test.setCurrentPage(pageRef);
        
        // ADD URL PARAMS
        pageRef.getParameters().put('crid', cr1.Id);
        
        // CONTROLLER 
        SolutionNewExtension ctrl = new SolutionNewExtension(new ApexPages.StandardController(sol));        
        
        // ADD URL PARAMS
        pageRef.getParameters().put('crid', cr2.Id);
        
        // CONTROLLER 
        SolutionNewExtension ctrl2 = new SolutionNewExtension(new ApexPages.StandardController(sol));           
        
        ctrl2.saveSolution();

    }

}