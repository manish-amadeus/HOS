@isTest
private class ChangeRequestTabTestClass 
{

    static testMethod void myUnitTest() 
    {
        
        // CHANGE REQUEST OBJECT
        //Upgraded 11/27/2013 - smh
        //SFDC_CSP_Development_Request__c cr = [SELECT Id FROM SFDC_CSP_Development_Request__c LIMIT 1];

        Product_Group__c pgp = NI_TestClassData.createProductGroup(1, 'Apex Test Group');
        insert pgp;

        Product2 prd = NI_TestClassData.createProduct2(1, pgp.Id, 'ZZZFULFILL-APEX-001', 'Subscription');
        insert prd;
                
        SFDC_CSP_Version__c vrs01 = NI_TestClassData.createVersion('v1.', pgp.Id, 1);
        insert vrs01;
        
        SFDC_CSP_Part__c prt01 = NI_TestClassData.createPart(prd.Id, vrs01.Id, 1);
        insert prt01;
        
        SFDC_CSP_Development_Request__c cr = NI_TestClassData.createChangeRequest(pgp.Id, vrs01.Id, prt01.Id, 1);
        
        // Upgrade End =====
                
        // PAGE REFERENCE
        PageReference pageRef = Page.ChangeRequestTab;
        Test.setCurrentPage(pageRef);
       
        // CONTROLLER 
        ChangeRequestTab ctrl = new ChangeRequestTab(new ApexPages.StandardController(cr));
        
        // USER SEARCH EMULATION      
        ctrl.searchText = 'beo';        
        ctrl.doSearch();
    
        ctrl.searchText = 'form';       
        ctrl.doSearch();    
        
        ctrl.goBack(); 
        
        ctrl.searchText = '!XXXXXXX';       
        ctrl.doSearch();

        ctrl.newSearch();
        
        ctrl.drillDownCount = 0; 
        ctrl.bGoBack = true; 
        ctrl.goBack(); 
        
        ctrl.sql = '';
        ctrl.searchText = '!beo';        
        ctrl.doSearch();    
        
        ctrl.sql = 'BAD QUERY SYNTAX TO CAUSE INTENTIONAL ERROR';
        ctrl.searchText = 'beo';        
        ctrl.doSearch();    
        
        ctrl.searchText = 'beo';        
        ctrl.doSearch(); 
        ctrl.goBack(); 
        
        ctrl.drillDownCount = -1000;
        ctrl.sql = 'AND BAD QUERY SYNTAX TO CAUSE AND INTENTIONAL ERROR';
        ctrl.goBack();  
        
        
        // FETCH         
        String strDescText = ctrl.getDescText();
        String strResoText = ctrl.getResoText();  

        // PAGE REFERENCE FUNCTIONS
        PageReference pr1;           
        ctrl.RetrieveDesc();
        
        ctrl.selectCRId();
        
        List<SFDC_CSP_Development_Request__c> sl1 = ctrl.getCRs();
        List<SFDC_CSP_Development_Request__c> sl2 = ctrl.results;
        
        ctrl.results = null;
        sl2 = ctrl.results;        

    }
}