/***********************************************************************************************
Name            : AH_PLCM_MM_Welcome_Test
Author          : Tushar Gupta
Created Date    : 11-Aug-2020
Last Mod Date   : 11-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Welcome test page
************************************************************************************************/
@isTest
Public class AH_PLCM_MM_Welcome_Test {

    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_MM_Welcome_Test_Method() {
    
    //insert new record into NI Documentatin object for testing
    NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Inventory Information Provided', false, false, false, 'Project Plan', true, date.today().format());
    insert niDoc;
    ProjectId = niDoc.Id;

    //Initialize the page AH_PLCM_MM_Welcome
    PageReference pRef = Page.AH_PLCM_MM_Welcome;
    
    String pageUrl = '';
    System.debug('ProjectId'+ProjectId);
    //Add parameters to page URL
    pRef.getParameters().put('ProjectId', ProjectId);
    Test.setCurrentPage(pRef); //set the current page

    Test.startTest();
    //Intialize the Welcome controller
    AH_PLCM_MM_Welcome welcome= new AH_PLCM_MM_Welcome();

    boolean IsTestClass = welcome.setIsTestClassAsTrue();
    welcome.CommunityUrl = 'community';
   
    //Start - Test common class methods
    //test the RedirectToPropertyPage method
    PageReference prPPage = welcome.RedirectToFunctionRoomPage(); // get current page url
    if (prPPage != null) {
      System.assertEquals('/apex/AH_PLCM_MM_Function_Room?ProjectId='+ ProjectId, prPPage.getUrl());
    }

    string projId = welcome.GetParameterValue('ProjectId');
    System.assertEquals(ProjectId, projId);

    welcome.UpdatePortalStatus(welcome.ProjectPortalStatus.PropertyInformationConfirmed);

    try {
           integer a = 0, b = 1, c = b/a;
    }
    catch(Exception ex){
        pageUrl = welcome.RedirectToErrorPage('AH_PLCM_MM_Welcome_Test_Method', ex).getUrl();
        System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
    }
    // test the terms and condtions status
    welcome.CheckTermsAndConditionStatus();

    // test the default room capacities values
    welcome.GetDefaultRoomCapacityValues();

    // initialize the invetory values
    welcome.SetDefaultInventoryValue();

    // initalize the picklist values
    welcome.GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c','MM_Source_Type__c');
   
    // get property name which is assigned to ni doc
    string propertyName = welcome.GetMMPropertyName();
    System.assertEquals(niDoc.Document_Name__c, propertyName);
    System.debug('propertyName'+propertyName);
    // get querystring Value
    string queryString = welcome.getAllQueryString();

    //End - Test common class methods
    Test.stopTest();
  }

  
}