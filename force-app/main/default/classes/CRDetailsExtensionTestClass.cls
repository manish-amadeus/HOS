@isTest
public class CRDetailsExtensionTestClass 
{

    static testMethod void myUnitTest() 
    {

        Account a = NI_TestClassData.createTestAccount(1);
        insert a;
                
        Case c = NI_TestClassData.createTestCase(1, a.Id);
        insert c;
                
        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;
        
        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
        
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;

        SFDC_CSP_Development_Request__c cr = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);        
        insert cr;        

        // PAGE REFERENCE
        PageReference pageRef = Page.CRDetails;
        Test.setCurrentPage(pageRef);
        
        // ADD URL PARAMS
        pageRef.getParameters().put('caseid', c.Id);
        
        // CONTROLLER 
        CRDetailExtension ctrl = new CRDetailExtension(new ApexPages.StandardController(cr));    

        PageReference ePR = ctrl.editCR(); 

        ctrl.attachCase();
        
    }

}