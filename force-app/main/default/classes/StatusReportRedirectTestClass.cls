/****************************************************************************************
Name            : StatusReportRedirectTestClass Class
Author          : Sean Harris
Created Date    : 
Last Mod Date   : 03/22/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
: 
: 
******************************************************************************************/
@isTest //(SeeAllData=true) 
private class StatusReportRedirectTestClass 
{
    
    static testMethod void myUnitTest() 
    {
        
        User sptMgr = NI_TestClassData.createTestUser(1, 'NI Support Managers'); 
        sptMgr.Department = 'Support';
        insert sptMgr;
        
        User sptTech = NI_TestClassData.createTestUser(2, 'NI Support CSR'); 
        sptTech.Department = 'Support';
        insert sptTech;
        
        system.runAs(sptMgr)
        {
            
            // TEST EMEA TAC A v1 EMEA TAC Analyst Status Report - Version 1
            // ==============================================================
            RecordType rt1 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC A v1' AND isActive = true LIMIT 1];
            //        User u1 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srEMEATACAv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt1.Id);        
            Insert srEMEATACAv1;        
            
            PageReference refEMEATACAv1 = Page.SReportEMEATACAv1;
            Test.setCurrentPage(refEMEATACAv1);        
            refEMEATACAv1.getParameters().put('id', srEMEATACAv1.id);
            
            StatusReportRedirect scEMEATACAv1 = new StatusReportRedirect(new ApexPages.StandardController(srEMEATACAv1));
            
            PageReference pr1 = scEMEATACAv1.FormRedirect();
            PageReference pr2 = scEMEATACAv1.ReportRedirect();
            
            
            // TEST EMEA TAC A v2 EMEA TAC Analyst Status Report
            // ==============================================================
            RecordType rtEMEATACAv2 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC A v2' AND isActive = true LIMIT 1];
            //        User u1 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srEMEATACAv2 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rtEMEATACAv2.Id);        
            Insert srEMEATACAv2;        
            
            PageReference refEMEATACAv2 = Page.SReportEMEATACAv2;
            Test.setCurrentPage(refEMEATACAv2);        
            refEMEATACAv2.getParameters().put('id', srEMEATACAv2.id);
            
            StatusReportRedirect scEMEATACAv2 = new StatusReportRedirect(new ApexPages.StandardController(srEMEATACAv2));
            
            PageReference prEMEATACAv2a = scEMEATACAv2.FormRedirect();
            PageReference prEMEATACAv2b = scEMEATACAv2.ReportRedirect();
            
            
            
            // TEST US TAC A v1 - US TAC Analyst Status Report - Version 1
            // ===========================================================
            RecordType rt2 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC A v1' AND isActive = true LIMIT 1];
            //        User u2 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srUSATACAv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt2.Id);        
            Insert srUSATACAv1;      
            
            PageReference refUSATACAv1 = Page.SRFormUSTACAv1;
            Test.setCurrentPage(refUSATACAv1); 
            refUSATACAv1.getParameters().put('id', srUSATACAv1.id);
            
            StatusReportRedirect scUSATACAv1 = new StatusReportRedirect(new ApexPages.StandardController(srUSATACAv1));
            
            PageReference pr3 = scUSATACAv1.FormRedirect();
            PageReference pr4 = scUSATACAv1.ReportRedirect();
            
            
            // TEST US TAC A v2 - US TAC Analyst Status Report - Version 2
            // ===========================================================
            RecordType rt2b = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC A v2' AND isActive = true LIMIT 1];
            //        User u2 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srUSATACAv2 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt2b.Id);        
            Insert srUSATACAv2;      
            
            PageReference refUSATACAv2 = Page.SRFormUSTACAv2;
            Test.setCurrentPage(refUSATACAv2); 
            refUSATACAv1.getParameters().put('id', srUSATACAv2.id);
            
            StatusReportRedirect scUSATACAv2 = new StatusReportRedirect(new ApexPages.StandardController(srUSATACAv2));
            
            PageReference pr3b = scUSATACAv2.FormRedirect();
            PageReference pr4b = scUSATACAv2.ReportRedirect();
            
            
            
            // TEST EMEA TAC S v1 EMEA TAC Specialist Status Report - Version 1
            // ================================================================
            RecordType rt3 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'EMEA TAC S v1' AND isActive = true LIMIT 1];
            //        User u3 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srEMEATACSv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt3.Id);        
            Insert srEMEATACSv1;        
            
            PageReference refEMEATACSv1 = Page.SReportEMEATACSv1;
            Test.setCurrentPage(refEMEATACSv1);        
            refEMEATACSv1.getParameters().put('id', srEMEATACSv1.id);
            
            StatusReportRedirect scEMEATACSv1 = new StatusReportRedirect(new ApexPages.StandardController(srEMEATACSv1));
            
            PageReference pr5 = scEMEATACSv1.FormRedirect();
            PageReference pr6 = scEMEATACSv1.ReportRedirect(); 
            
            
            
            // TEST US TAC S v1 - US TAC Specialist Status Report - Version 1
            // ==============================================================
            RecordType rt4 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC S v1' AND isActive = true LIMIT 1];
            //        User u4 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srUSATACSv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt4.Id);        
            Insert srUSATACSv1;      
            
            PageReference refUSATACSv1 = Page.SRFormUSTACSv1;
            Test.setCurrentPage(refUSATACSv1);        
            refUSATACSv1.getParameters().put('id', srUSATACSv1.id);
            
            StatusReportRedirect scUSATACSv1 = new StatusReportRedirect(new ApexPages.StandardController(srUSATACSv1));
            
            PageReference pr7 = scUSATACSv1.FormRedirect();
            PageReference pr8 = scUSATACSv1.ReportRedirect();        
            
            
            
            // TEST US BRT v1 - US TAC Business Reporting Team Status Report - Version 1
            // =========================================================================
            RecordType rt5 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US BRT v1' AND isActive = true LIMIT 1];
            //        User u5 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srUSBRTv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt5.Id);        
            Insert srUSBRTv1;      
            
            PageReference refUSBRTv1 = Page.SRFormUSBRTv1;
            Test.setCurrentPage(refUSBRTv1);        
            refUSBRTv1.getParameters().put('id', srUSBRTv1.id);
            
            StatusReportRedirect scUSBRTv1 = new StatusReportRedirect(new ApexPages.StandardController(srUSBRTv1));
            
            PageReference pr9 = scUSBRTv1.FormRedirect();
            PageReference pr10 = scUSBRTv1.ReportRedirect();
            
            
            // TEST US PSS v1 - US PREMIUM SUPPORT Status Report - Version 1
            // =================================================================
            RecordType rt6 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'PSS v1' AND isActive = true LIMIT 1];
            //        User u6 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srPSSv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt6.Id);        
            Insert srPSSv1;      
            
            PageReference refPSSv1 = Page.SRFormPSSv1;
            Test.setCurrentPage(refPSSv1);        
            refPSSv1.getParameters().put('id', srPSSv1.id);
            
            StatusReportRedirect scPSSv1 = new StatusReportRedirect(new ApexPages.StandardController(srPSSv1));
            
            PageReference pr11 = scPSSv1.FormRedirect();
            PageReference pr12 = scPSSv1.ReportRedirect();                
            
            
            // TEST US INT v1 - US INTEGRATION SUPPORT Status Report - Version 1
            // =================================================================
            RecordType rt7 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US INT v1' AND isActive = true LIMIT 1];
            //        User u7 = [SELECT id FROM User WHERE Name =: 'Sean Harris' LIMIT 1];
            StatusReport__c srUSINTv1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt7.Id);        
            Insert srUSINTv1;      
            
            PageReference refUSINTv1 = Page.SRFormUSINTv1;
            Test.setCurrentPage(refUSINTv1);        
            refUSINTv1.getParameters().put('id', srUSINTv1.id);
            
            StatusReportRedirect scUSINTv1 = new StatusReportRedirect(new ApexPages.StandardController(srUSINTv1));
            
            PageReference pr13 = scUSINTv1.FormRedirect();
            PageReference pr14 = scUSINTv1.ReportRedirect();         
            
            
            
            // ===========================================================
            //  TEST US TAC Lead Analyst (v1) Status Report Form
            // ===========================================================
            RecordType rt_US_TAC_Lead_A_v1 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC Lead A v1' AND isActive = true LIMIT 1];
            
            StatusReport__c sr_US_TAC_Lead_A_v1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt_US_TAC_Lead_A_v1.Id);        
            Insert sr_US_TAC_Lead_A_v1;      
            
            PageReference pr_US_TAC_Lead_A_v1 = Page.SRFormUSLeadAv1;
            Test.setCurrentPage(pr_US_TAC_Lead_A_v1); 
            pr_US_TAC_Lead_A_v1.getParameters().put('id', sr_US_TAC_Lead_A_v1.id);
            
            StatusReportRedirect re_US_TAC_Lead_A_v1 = new StatusReportRedirect(new ApexPages.StandardController(sr_US_TAC_Lead_A_v1));
            
            PageReference frm_US_TAC_Lead_A_v1 = re_US_TAC_Lead_A_v1.FormRedirect();
            PageReference rpt_US_TAC_Lead_A_v1 = re_US_TAC_Lead_A_v1.ReportRedirect();  
            
            
            // ===========================================================
            //  TEST US TAC Lead Analyst (v2) Status Report Form
            // ===========================================================
            RecordType rt_US_TAC_Lead_A_v2 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC Lead A v2' AND isActive = true LIMIT 1];
            
            StatusReport__c sr_US_TAC_Lead_A_v2 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt_US_TAC_Lead_A_v2.Id);        
            Insert sr_US_TAC_Lead_A_v2;      
            
            PageReference pr_US_TAC_Lead_A_v2 = Page.SRFormUSLeadAv2;
            Test.setCurrentPage(pr_US_TAC_Lead_A_v2); 
            pr_US_TAC_Lead_A_v2.getParameters().put('id', sr_US_TAC_Lead_A_v2.id);
            
            StatusReportRedirect re_US_TAC_Lead_A_v2 = new StatusReportRedirect(new ApexPages.StandardController(sr_US_TAC_Lead_A_v2));
            
            PageReference frm_US_TAC_Lead_A_v2 = re_US_TAC_Lead_A_v2.FormRedirect();
            PageReference rpt_US_TAC_Lead_A_v2 = re_US_TAC_Lead_A_v2.ReportRedirect();  

            
            // ===========================================================
            //  TEST US TAC Senior Analyst (v1) Status Report Form 
            // ===========================================================
            RecordType rt_US_TAC_Senior_A_v1 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'US TAC Senior A v1' AND isActive = true LIMIT 1];
            
            StatusReport__c sr_US_TAC_Senior_A_v1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt_US_TAC_Senior_A_v1.Id);        
            Insert sr_US_TAC_Senior_A_v1;      
            
            PageReference pr_US_TAC_Senior_A_v1 = Page.SRFormUSTACSeniorAv1;
            Test.setCurrentPage(pr_US_TAC_Senior_A_v1); 
            pr_US_TAC_Senior_A_v1.getParameters().put('id', sr_US_TAC_Senior_A_v1.id);
            
            StatusReportRedirect re_US_TAC_Senior_A_v1 = new StatusReportRedirect(new ApexPages.StandardController(sr_US_TAC_Senior_A_v1));
            
            PageReference frm_US_TAC_Senior_A_v1 = re_US_TAC_Senior_A_v1.FormRedirect();
            PageReference rpt_US_TAC_Senior_A_v1 = re_US_TAC_Senior_A_v1.ReportRedirect();  
            

            // ===========================================================
            //  TEST PMS Standard (v1) Status Report Form 
            // ===========================================================
            RecordType rt_PMS_Standard_v1 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'PMS Standard v1' AND isActive = true LIMIT 1];
            
            StatusReport__c sr_PMS_Standard_v1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt_PMS_Standard_v1.Id);        
            Insert sr_PMS_Standard_v1;      
            
            PageReference pr_PMS_Standard_v1 = Page.SRFormPMSStandardv1;
            Test.setCurrentPage(pr_PMS_Standard_v1); 
            pr_PMS_Standard_v1.getParameters().put('id', sr_PMS_Standard_v1.id);
            
            StatusReportRedirect re_PMS_Standard_v1 = new StatusReportRedirect(new ApexPages.StandardController(sr_PMS_Standard_v1));
            
            PageReference frm_PMS_Standard_v1 = re_PMS_Standard_v1.FormRedirect();
            PageReference rpt_PMS_Standard_v1 = re_PMS_Standard_v1.ReportRedirect();  
            

            // ===========================================================
            //  TEST PMS Technical (v1) Status Report Form 
            // ===========================================================
            RecordType rt_PMS_Technical_v1 = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Name = 'PMS Technical v1' AND isActive = true LIMIT 1];
            
            StatusReport__c sr_PMS_Technical_v1 = new StatusReport__c(Associate__c = sptTech.Id, RecordTypeId = rt_PMS_Technical_v1.Id);        
            Insert sr_PMS_Technical_v1;      
            
            PageReference pr_PMS_Technical_v1 = Page.SRFormPMSTechnicalv1;
            Test.setCurrentPage(pr_PMS_Technical_v1); 
            pr_PMS_Technical_v1.getParameters().put('id', sr_PMS_Technical_v1.id);
            
            StatusReportRedirect re_PMS_Technical_v1 = new StatusReportRedirect(new ApexPages.StandardController(sr_PMS_Technical_v1));
            
            PageReference frm_PMS_Technical_v1 = re_PMS_Technical_v1.FormRedirect();
            PageReference rpt_PMS_Technical_v1 = re_PMS_Technical_v1.ReportRedirect();  

            
        }
        
    }
    
}