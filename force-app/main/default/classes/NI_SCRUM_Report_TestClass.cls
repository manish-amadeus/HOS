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
        Date dCurrent = date.today();
        String strMonth = String.ValueOf(dCurrent.Month());
        if (dCurrent.Month() < 10)
        {
            strMonth = '0' + strMonth;
        }

        String strLastYearTP = 'FY-' + String.ValueOf(Date.today().addYears(-1).Year()) + '-' + strMonth;
        List<Services_Scrum_Snapshot__c> sn_list = new List<Services_Scrum_Snapshot__c>();
        for (Integer i=0; i< 11; i++){
            Services_Scrum_Snapshot__c sn = new Services_Scrum_Snapshot__c();
            
            sn.Actual_Amount__c 	= 100;
            sn.Backlog_Amount__c 	= 20;
            sn.Budget_Amount__c 	= 200;
            sn.Comp_Amount__c 		= 150;
            if(i==1)
            sn.Date_of_Pull__c	 	= Date.today().addYears(-2);    
            else
            sn.Date_of_Pull__c	 	= Date.today().addYears(-1);
            
            sn.Downside_Amount__c 	= 12;
            sn.Forecast_Amount__c	= 250;
            sn.Group__c 			= 'Group_'+i;
            if(i==0)
            sn.Service_Group__c 	= 'CAD Services';//+i;
            else if(i==1)
            sn.Service_Group__c 	= 'Data Services';//+i;
            else if(i==2)
            sn.Service_Group__c 	= 'Integrations';//+i;
            else if(i == 3)
            sn.Service_Group__c 	= 'Project Management';//+i;
            else if(i == 4)
            sn.Service_Group__c 	= 'MeetingMatrix';//+i; 
            else if(i == 5)
            sn.Service_Group__c 	= 'Report Service';//+i;
            else if(i == 6)
            sn.Service_Group__c 	= 'Solutions Consulting';//+i;
            else if(i == 7)
            sn.Service_Group__c 	= 'Strategic Consulting';//+i;
            else if(i == 8)
            sn.Service_Group__c 	= 'Systems Engineering';//+i;
            else
            sn.Service_Group__c 	= 'Training';//+i;
            
            sn.Region_Name__c 		= 'US';//+i;
            sn.Reimbursable_Expenses__c = 300;
            sn.Scheduled_Amount__c 	= 240;
            sn.Scheduled_Hours__c 	= 2;
            sn.Target_Period__c 	= strLastYearTP;
            sn.Tentative_Value__c 	= 150;
            sn.Upside_Amount__c 	= 150;
            System.debug('Date_of_Pull__c==>'+sn.Date_of_Pull__c);
            sn_list.add(sn);
        }
       
        Database.insert(sn_list);
        // ASSERT STATEMENTS HERE
        List<Services_Scrum_Snapshot__c> sn_list1 = [SELECT id, Name from Services_Scrum_Snapshot__c];
        system.assertEquals(11, sn_list1.size(), 'Record count mismatch..');
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