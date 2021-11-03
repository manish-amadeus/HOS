/***********************************************************************************************
Name            : AH_PLCM_MM_Terms_And_Conditions_Test
Author          : Tushar Gupta
Created Date    : 17-Aug-2020
Last Mod Date   : 17-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Class for Terms And Conditions Test page
************************************************************************************************/
@isTest
public class AH_PLCM_MM_Terms_And_Conditions_Test {
    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_MM_Terms_And_Conditions_Test_Method() { 
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
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the terms and condition controller
        AH_PLCM_MM_Terms_And_Conditions termsAndCondition = new AH_PLCM_MM_Terms_And_Conditions();
        
        termsAndCondition.IsTermsAndConditionsAccepted();
        
        // check the accept term and conditions
        termsAndCondition.AcceptTermsAndCondtion();

        boolean IsTestClass = termsAndCondition.setIsTestClassAsTrue();
        termsAndCondition.CommunityUrl = 'community';
    
        //Start - Test common class methods
        string projId = termsAndCondition.GetParameterValue('ProjectId');
        System.assertEquals(ProjectId, projId);

        termsAndCondition.UpdatePortalStatus(termsAndCondition.ProjectPortalStatus.PropertyInformationConfirmed);

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = termsAndCondition.RedirectToErrorPage('AH_PLCM_MM_Terms_And_Conditions_Test_Method', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
        }
        // test the terms and condtions status
        termsAndCondition.CheckTermsAndConditionStatus();

        // test the default room capacities values
        termsAndCondition.GetDefaultRoomCapacityValues();

        // initialize the invetory values
        termsAndCondition.SetDefaultInventoryValue();

        // initalize the picklist values
        termsAndCondition.GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c','MM_Source_Type__c');
    
        // get property name which is assigned to ni doc
        string propertyName = termsAndCondition.GetMMPropertyName();
        System.assertEquals(niDoc.Document_Name__c, propertyName);
        System.debug('propertyName'+propertyName);
        // get querystring Value
        string queryString = termsAndCondition.getAllQueryString();

        //End - Test common class methods
        Test.stopTest();
    }
}