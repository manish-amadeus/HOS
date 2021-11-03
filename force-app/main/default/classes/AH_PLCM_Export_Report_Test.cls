/***********************************************************************************************
Name            : AH_PLCM_Export_Report_Test
Author          : Tushar Gupta
Created Date    : 19-June-2019
Last Mod Date   : 19-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Export test page
************************************************************************************************/
@isTest
public class AH_PLCM_Export_Report_Test {
    static String ProjectId = ''; // set the project id
    static String RecordType = ''; // set the RecordType
    static String TabName = '01rS0000000BCmd'; // set the tab name

    static testMethod void Export_Report_For_PDF_Properties() {
        //Insert new record into Ni Documentation object
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;
       
        //Initialize the page AH_PLCM_Export_Report
		PageReference pRef = Page.AH_PLCM_Export_Report_Pdf;

        String pageUrl = '';
        RecordType = 'properties'; // set the record type as properties
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('RecordType', RecordType);
        pRef.getParameters().put('ReportType', 'pdf');
        Test.setCurrentPage(pRef); // set current page

    	Test.startTest();
        //Intialize the Introduction controller
		AH_PLCM_Export_Report reportPro = new AH_PLCM_Export_Report();

        boolean IsTestClass = reportPro.setIsTestClassAsTrue();
        reportPro.CommunityUrl = 'neighbor';

        // test the save file method
        reportPro.SaveFile(ProjectId, 'Customer_Inputs.xls', Blob.valueof('Some Random Value'));

        reportPro.RenderAs = ''; //intialize the propertys as blankS
        reportPro.ContentType = 'application/x-pdf';
        String xlsHeader = reportPro.xlsHeader;
        // start - common class test
        boolean targetUser =  reportPro.IsTargetUserExist;
        reportPro.GetParameterValue('ProjectId');

        reportPro.UpdatePortalStatus(reportPro.ProjectPortalStatus.PropertyUpdated);
        reportPro.SetVariablesValue();

        reportPro.UpdatePortalStatus(reportPro.ProjectPortalStatus.UsersCreated);
        reportPro.SetVariablesValue();

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = reportPro.RedirectToErrorPage('Export_Report_For_PDF_Properties', ex).getUrl();
            //System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);
            reportPro.CommunityUrl = 'neighborhood';
            pageUrl = reportPro.RedirectToErrorPage('Export_Report_For_PDF_Properties', ex).getUrl();
            
        }

        Test.stopTest();
    }

    static testMethod void Export_Report_For_PDF_Users() {
        //Insert new record into Ni Documentation object
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_Export_Report
		PageReference pRef = Page.AH_PLCM_Export_Report_Pdf;

        String pageUrl = '';
        RecordType = 'users'; // set the record type as users
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('RecordType', RecordType);
        pRef.getParameters().put('ReportType', 'pdf');
        Test.setCurrentPage(pRef); // set current page

    	Test.startTest();
        //Intialize the Introduction controller
        AH_PLCM_Export_Report reportPro = new AH_PLCM_Export_Report();
        
        boolean IsTestClass = reportPro.setIsTestClassAsTrue();
        reportPro.CommunityUrl = 'neighbor';

        // start - common class test
        boolean targetUser =  reportPro.IsTargetUserExist;
        reportPro.GetParameterValue('ProjectId');
        
        reportPro.UpdatePortalStatus(reportPro.ProjectPortalStatus.PropertyUpdated);
        reportPro.SetVariablesValue();

        reportPro.UpdatePortalStatus(reportPro.ProjectPortalStatus.UsersCreated);
        reportPro.SetVariablesValue();

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = reportPro.RedirectToErrorPage('Export_Report_For_PDF_Users', ex).getUrl();
           // System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);

           reportPro.CommunityUrl = 'neighborhood';
           pageUrl = reportPro.RedirectToErrorPage('Export_Report_For_PDF_Users', ex).getUrl();
        }

        reportPro.CheckTermsAndConditionStatus();
        // end - common class test

        Test.stopTest();
    }

    static testMethod void Export_Report_For_PDF_Xref() {
        //Insert new record into Ni Documentation object
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_Export_Report
		PageReference pRef = Page.AH_PLCM_Export_Report_Pdf;

        String pageUrl = '';
        RecordType = 'All'; // set the record type as xref
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('RecordType', RecordType);
        pRef.getParameters().put('ReportType', 'pdf');
        pRef.getParameters().put('includealluser', 'y');
        Test.setCurrentPage(pRef); // set current page

    	Test.startTest();
        //Intialize the Introduction controller
		AH_PLCM_Export_Report reportPro = new AH_PLCM_Export_Report();
        
        boolean IsTestClass = reportPro.setIsTestClassAsTrue();
        reportPro.CommunityUrl = 'neighbor';

        // start - common class test
        boolean targetUser =  reportPro.IsTargetUserExist;
        reportPro.GetParameterValue('ProjectId');
        
        reportPro.UpdatePortalStatus(reportPro.ProjectPortalStatus.PropertyUpdated);
        reportPro.SetVariablesValue();

        reportPro.UpdatePortalStatus(reportPro.ProjectPortalStatus.UsersCreated);
        reportPro.SetVariablesValue();

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = reportPro.RedirectToErrorPage('Export_Report_For_PDF_Xref', ex).getUrl();
           // System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);

           reportPro.CommunityUrl = 'neighborhood';
           pageUrl = reportPro.RedirectToErrorPage('Export_Report_For_PDF_Xref', ex).getUrl();
        }

        reportPro.CheckTermsAndConditionStatus();
        // end - common class test

        Test.stopTest();
    }

    static testMethod void Export_Report_For_Excel() {
        //Insert new record into Ni Documentation object
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_Export_Report
		PageReference pRef = Page.AH_PLCM_Export_Report_Pdf;

        String pageUrl = '';
        RecordType = 'properties'; //set the record type as properties
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('RecordType', RecordType);
        pRef.getParameters().put('ReportType', 'xls');
        Test.setCurrentPage(pRef); //set current page

    	Test.startTest();
        //Intialize the Introduction controller
		AH_PLCM_Export_Report report = new AH_PLCM_Export_Report();

        boolean IsTestClass = report.setIsTestClassAsTrue();
        report.CommunityUrl = 'neighbor';

        // start - common class test
        boolean targetUser =  report.IsTargetUserExist;
        report.GetParameterValue('ProjectId');

        report.UpdatePortalStatus(report.ProjectPortalStatus.PropertyUpdated);
        report.SetVariablesValue();

        report.UpdatePortalStatus(report.ProjectPortalStatus.UsersCreated);
        report.SetVariablesValue();

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = report.RedirectToErrorPage('Export_Report_For_Excel', ex).getUrl();
            // System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);
            report.CommunityUrl = 'neighborhood';
            pageUrl = report.RedirectToErrorPage('Export_Report_For_Excel', ex).getUrl();
        }

        report.CheckTermsAndConditionStatus();
        // end - common class test

        Test.stopTest();
    }
}