@isTest
private class ChangeRequestDetailsExtensionTestClass 
{

    static testMethod void myUnitTest() 
    {
        
        // SOLUTION OBJECT
        //Solution sol = [SELECT id, SolutionNumber, SolutionName FROM Solution LIMIT 1];
        Solution sol = NI_TestClassData.createSolution(1); 
        insert sol;
        
        // PRODUCT GROUP OBJECT
        //Product_Group__c pg1 = new Product_Group__c(Name = 'APEX TEXT PRODUCT GROUP'); 
        Product_Group__c pg1= NI_TestClassData.createProductGroup(1, 'Apex Test Group');      
        insert pg1;

        // PRODUCT OBJECT
        Product2 prd = NI_TestClassData.createProduct2(1, pg1.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd; 

        // VERSION OBJECT
        //SFDC_CSP_Version__c v1 = new SFDC_CSP_Version__c(Name = 'DELPHI v1000', Product_Group__c = pg1.Id);
        SFDC_CSP_Version__c v1 = NI_TestClassData.createVersion('v1.', pg1.Id, 1);
        insert v1;
        
        // PART OBJECT
        //SFDC_CSP_Part__c p1 = new SFDC_CSP_Part__c(Name = 'APEX TEST PART', Version__c = v1.Id);   
        SFDC_CSP_Part__c p1 = NI_TestClassData.createPart(prd.Id, v1.Id, 1);     
        insert p1;
                        
        // CR OBJECT 
        //SFDC_CSP_Development_Request__c cr = new SFDC_CSP_Development_Request__c (Title__c = 'APEX TEST CLASS CR', Description__c = 'APEX TEST CLASS CR', Product_Group__c = pg1.Id, Version__c = v1.Id, Part__c = p1.Id, Support_Priority__c = '4 - Low', Type__c = 'Defect', Child_Solution__c = sol.Id);
        SFDC_CSP_Development_Request__c cr = NI_TestClassData.createChangeRequest(pg1.Id, v1.Id, p1.Id, 1);
        cr.Child_Solution__c = sol.Id;
        insert cr;      

        // PAGE REFERENCE
        PageReference pageRef = Page.ChangeRequestDetails;
        Test.setCurrentPage(pageRef);
        
        // ADD URL PARAMS
        pageRef.getParameters().put('sol', sol.Id);
        
        // CONTROLLER 
        ChangeRequestDetailsExtension ctrl = new ChangeRequestDetailsExtension(new ApexPages.StandardController(cr));
        
    }
    
}