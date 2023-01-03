/***********************************************************************************************
Name            : AH_PLCM_MM_Thank_You_Test
Author          : Tushar Gupta
Created Date    : 18-Aug-2020
Last Mod Date   : 18-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Class for Thank you Test page
************************************************************************************************/
@isTest
public class AH_PLCM_MM_Thank_You_Test {
    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_MM_Thank_You_Test_Method() {         
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Customer Inputs Complete', false, false, false, 'Project Plan', true, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_MM_Thank_You
        PageReference pRef = Page.AH_PLCM_MM_Thank_You;
        
        String pageUrl = '';
        
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the thank you controller
        AH_PLCM_MM_Thank_You thankYou = new AH_PLCM_MM_Thank_You();
        
        // check navigation of welcome page
        string welcomePage = thankYou.BackToWelcomePage().getUrl();
        System.assertEquals('/apex/AH_PLCM_MM_Welcome', welcomePage);

        boolean IsTestClass = thankYou.setIsTestClassAsTrue();
        thankYou.CommunityUrl = 'community';
    
        //Start - Test common class methods
        string projId = thankYou.GetParameterValue('ProjectId');
        System.assertEquals(ProjectId, projId);

        thankYou.UpdatePortalStatus(thankYou.ProjectPortalStatus.PropertyInformationConfirmed);

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = thankYou.RedirectToErrorPage('AH_PLCM_MM_Terms_And_Conditions_Test_Method', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
        }
        // test the terms and condtions status
        thankYou.CheckTermsAndConditionStatus();

        // test the default room capacities values
        thankYou.GetDefaultRoomCapacityValues();

        // initialize the invetory values
        thankYou.SetDefaultInventoryValue();

        // initalize the picklist values
        thankYou.GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c','MM_Source_Type__c');
    
        // get property name which is assigned to ni doc
        string propertyName = thankYou.GetMMPropertyName();
        System.assertEquals(niDoc.Document_Name__c, propertyName);
        System.debug('propertyName'+propertyName);
        // get querystring Value
        string queryString = thankYou.getAllQueryString();

        //End - Test common class methods
        Test.stopTest();
    }
}