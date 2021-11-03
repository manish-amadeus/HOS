/***********************************************************************************************
Name            : AH_PLCM_MM_Inventory_Test
Author          : Tushar Gupta
Created Date    : 17-Aug-2020
Last Mod Date   : 17-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Inventory Page Test
************************************************************************************************/
@isTest
public class AH_PLCM_MM_Inventory_Test {
    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_MM_Inventory_Test_Method() {         
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Function Room Information Provided', false, false, false, 'Project Plan', true, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        // insert new record into Inventory Object
        AH_PLCM_MM_Inventory__c inventoryObj = NI_TestClassData.createTest_Inventory(true, 'Chair1', 12, 15, 6, ProjectId);
        insert inventoryObj;

        //Initialize the page AH_PLCM_MM_Inventory
        PageReference pRef = Page.AH_PLCM_MM_Inventory;
        
        String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the Room capacities controller
        AH_PLCM_MM_Inventory inventory= new AH_PLCM_MM_Inventory();
        
        // check the save action
        inventory.inventoryObj = new AH_PLCM_MM_Inventory__c();
        inventory.SaveData();

        // check the update action
        inventory.inventoryObj.MM_Chair_1_Height__c = 11;
        inventory.SaveData();
        System.assertEquals(11, inventory.inventoryObj.MM_Chair_1_Height__c);

        // check the navigation url
        string invetoryPage = inventory.ConfirmAndNext().getUrl();

        System.assertEquals('/apex/AH_PLCM_MM_Thank_You?ProjectId='+ ProjectId, invetoryPage);

        string RoomCapacitiesPage = inventory.BackToRoomCapacitiesPage().getUrl();
        System.assertEquals('/apex/AH_PLCM_MM_Room_Capacities?ProjectId='+ ProjectId, RoomCapacitiesPage);

        // check the exceptions
        inventory.inventoryObj = null;
        inventory.SaveData();

        //Start - Test common class methods
        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = inventory.RedirectToErrorPage('AH_PLCM_MM_Inventory_Test_Method    ', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
        }
        // test the terms and condtions status
        inventory.CheckTermsAndConditionStatus();
    
        // initialize the invetory values
        inventory.SetDefaultInventoryValue();
        
        // get querystring Value
        string queryString = inventory.getAllQueryString();
       
        // initialize  the test class method
        boolean IsTestClass = inventory.setIsTestClassAsTrue();
        inventory.CommunityUrl = 'community';

        // get property name which is assigned to ni doc
        string propertyName = inventory.GetMMPropertyName();
        System.assertEquals(niDoc.Document_Name__c, propertyName);

        // initalize the picklist values
        inventory.GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c','MM_Source_Type__c');

        // call the default room capacities page
        inventory.GetDefaultRoomCapacityValues();
        //End - Test common class methods

        Test.stopTest();
    }
}