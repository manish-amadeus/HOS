@isTest
private class NI_SCRUM_Report_TestClass 
{

    static testMethod void myUnitTest() 
    {
    
        // SCRUM_PS__c OBJECT
        SCRUM_PS__c scrum = new SCRUM_PS__c(); 
        //= [SELECT AmountSort__c, Amount_Text__c, BackColorIndex__c, DataRefreshDate__c, 
        //FY01__c, FY02__c, FY03__c, FY04__c, FY05__c, FY06__c, FY07__c, FY08__c, FY09__c, FY10__c, FY11__c, FY12__c, 
        //Grand_Total__c, ReportSort__c, Service_Group__c FROM SCRUM_PS__c LIMIT 100];
            
        // PAGE REFERENCE
        PageReference pageRef = Page.SCRUMReport;
        Test.setCurrentPage(pageRef);
        
        // CONTROLLER 
        NI_SCRUM_Report ctrl = new NI_SCRUM_Report(new ApexPages.StandardController(scrum));
        ctrl.getSCRUMPS();
        ctrl.getSCRUMBackLog();
        ctrl.getChart();
        NI_SCRUM_Report.getScheduledComparisonData();
        NI_SCRUM_Report.getSCRUMChartData();
        NI_SCRUM_Report.getRemoteData();
        
        String strHeadrText;
        
        strHeadrText = ctrl.colFY01;
        strHeadrText = ctrl.colFY02;
        strHeadrText = ctrl.colFY03;
        strHeadrText = ctrl.colFY04;
        strHeadrText = ctrl.colFY05;
        strHeadrText = ctrl.colFY06;
        strHeadrText = ctrl.colFY07;
        strHeadrText = ctrl.colFY08;
        strHeadrText = ctrl.colFY09;
        strHeadrText = ctrl.colFY10;
        strHeadrText = ctrl.colFY11;
        strHeadrText = ctrl.colFY12;
        
        strHeadrText = ctrl.colQCurrent;
        strHeadrText = ctrl.colQ1;
        strHeadrText = ctrl.colQ2;
        strHeadrText = ctrl.colQ3;
        strHeadrText = ctrl.colQ4;
        
        
        
        
    }
}