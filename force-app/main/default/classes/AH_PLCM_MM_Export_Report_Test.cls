/***********************************************************************************************
Name            : AH_PLCM_MM_Export_Report_Test
Author          : Tushar Gupta
Created Date    : 18-Aug-2020
Last Mod Date   : 18-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Export Report Test page
************************************************************************************************/
@isTest
public class AH_PLCM_MM_Export_Report_Test {
    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_MM_Export_Report_Test_Method_FunctionRoom_Excel() { 
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Inventory Information Provided', false, false, false, 'Project Plan', false, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_MM_Terms_And_Conditions
        PageReference pRef = Page.AH_PLCM_MM_Terms_And_Conditions;
        
        String pageUrl = '';
        System.debug('ProjectId'+ProjectId);
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('RecordType', 'functionroom');
        pRef.getParameters().put('ReportType', 'xls');
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the terms and condition controller
        AH_PLCM_MM_Export_Report exportReport = new AH_PLCM_MM_Export_Report();
        
        // initialize the field value
        exportReport.RenderAs = 'xls';
        
        // check header value
        string xlsHeader = exportReport.xlsHeader;
        System.assertEquals('<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>', xlsHeader);

        boolean IsTestClass = exportReport.setIsTestClassAsTrue();
        exportReport.CommunityUrl = 'community';
        
        
        //Start - Test common class methods
        string projId = exportReport.GetParameterValue('ProjectId');
        System.assertEquals(ProjectId, projId);

        exportReport.UpdatePortalStatus(exportReport.ProjectPortalStatus.PropertyInformationConfirmed);

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = exportReport.RedirectToErrorPage('AH_PLCM_MM_Export_Report_Test_Method_FunctionRoom_Excel', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
        }
        // test the terms and condtions status
        exportReport.CheckTermsAndConditionStatus();

        // test the default room capacities values
        exportReport.GetDefaultRoomCapacityValues();

        // initialize the invetory values
        exportReport.SetDefaultInventoryValue();

        // initalize the picklist values
        exportReport.GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c','MM_Source_Type__c');
    
        // get property name which is assigned to ni doc
        string propertyName = exportReport.GetMMPropertyName();

        // get querystring Value
        string queryString = exportReport.getAllQueryString();

        //End - Test common class methods
        Test.stopTest();
    }

    static testMethod void AH_PLCM_MM_Export_Report_Test_Method_RoomCapacities_Excel() {        
       //insert new record into NI Documentatin object for testing
       NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Inventory Information Provided', false, false, false, 'Project Plan', false, date.today().format());
       insert niDoc;
       ProjectId = niDoc.Id;

       //Initialize the page AH_PLCM_MM_Terms_And_Conditions
       PageReference pRef = Page.AH_PLCM_MM_Terms_And_Conditions;
       
       String pageUrl = '';
       System.debug('ProjectId'+ProjectId);
       //Add parameters to page URL
       pRef.getParameters().put('ProjectId', ProjectId);
       pRef.getParameters().put('RecordType', 'roomcapacities');
       pRef.getParameters().put('ReportType', 'xls');
       Test.setCurrentPage(pRef); //set the current page

       Test.startTest();
       //Intialize the terms and condition controller
       AH_PLCM_MM_Export_Report exportReport = new AH_PLCM_MM_Export_Report();   
       Test.stopTest();
   }

   static testMethod void AH_PLCM_MM_Export_Report_Test_Method_Inventory_Excel() { 
              
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Inventory Information Provided', false, false, false, 'Project Plan', false, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        // insert new record into Inventory Object
        AH_PLCM_MM_Inventory__c inventoryObj = NI_TestClassData.createTest_Inventory(true, 'Chair1', 12, 15, 6, ProjectId);
        insert inventoryObj;

        //Initialize the page AH_PLCM_MM_Terms_And_Conditions
        PageReference pRef = Page.AH_PLCM_MM_Terms_And_Conditions;
        
        String pageUrl = '';
        System.debug('ProjectId'+ProjectId);
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('RecordType', 'inventory');
        pRef.getParameters().put('ReportType', 'xls');
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the terms and condition controller
        AH_PLCM_MM_Export_Report exportReport = new AH_PLCM_MM_Export_Report();
                
        Test.stopTest();
    }

    static testMethod void AH_PLCM_MM_Export_Report_Test_Method_Inventory_Pdf() {         
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Inventory Information Provided', false, false, false, 'Project Plan', false, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        // insert new record into Inventory Object
        AH_PLCM_MM_Inventory__c inventoryObj = NI_TestClassData.createTest_Inventory(true, 'Chair1', 12, 15, 6, ProjectId);
        insert inventoryObj;

        //Initialize the page AH_PLCM_MM_Terms_And_Conditions
        PageReference pRef = Page.AH_PLCM_MM_Terms_And_Conditions;
        
        String pageUrl = '';
        System.debug('ProjectId'+ProjectId);
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('RecordType', 'inventory');
        pRef.getParameters().put('ReportType', 'pdf');
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the terms and condition controller
        AH_PLCM_MM_Export_Report exportReport = new AH_PLCM_MM_Export_Report();
                
        Test.stopTest();
    }

    static testMethod void AH_PLCM_MM_Export_Report_Test_Method_ALL_Excel() {         
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Inventory Information Provided', false, false, false, 'Project Plan', false, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_MM_Terms_And_Conditions
        PageReference pRef = Page.AH_PLCM_MM_Terms_And_Conditions;
        
        String pageUrl = '';
        System.debug('ProjectId'+ProjectId);
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('RecordType', 'all');
        pRef.getParameters().put('ReportType', 'xls');
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the terms and condition controller
        AH_PLCM_MM_Export_Report exportReport = new AH_PLCM_MM_Export_Report();
               
        Test.stopTest();
    }
}