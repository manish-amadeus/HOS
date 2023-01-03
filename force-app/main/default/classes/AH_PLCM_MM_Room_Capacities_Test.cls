/***********************************************************************************************
Name            : AH_PLCM_MM_Room_Capacities_Test
Author          : Tushar Gupta
Created Date    : 14-Aug-2020
Last Mod Date   : 14-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for  Room Capacities Page Test
************************************************************************************************/
@isTest
public class AH_PLCM_MM_Room_Capacities_Test {
    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_MM_Room_Capacities_Test_Method() {         
        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Function Room Information Provided', false, false, false, 'Project Plan', true, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the page AH_PLCM_MM_Room_Capacities
        PageReference pRef = Page.AH_PLCM_MM_Room_Capacities;
        
        String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the Room capacities controller
        AH_PLCM_MM_Room_Capacities roomCapacities= new AH_PLCM_MM_Room_Capacities();
        roomCapacities.GetNIDocDettails();

        roomCapacities.file = Blob.valueof('Some Random Value');
        roomCapacities.fileName = 'test.pdf';
        // call the uploadfile method
        roomCapacities.UploadFile();

        // for multiple file upload
        roomCapacities.UploadFile();
        
        // initialize the back to function room method
        PageReference functionRoomPage =  roomCapacities.BackToFunctionRoomPage();
        System.assertEquals('/apex/AH_PLCM_MM_Function_Room?ProjectId='+ ProjectId, functionRoomPage.getUrl());
        // initialize the confirm and next page method
        PageReference invetoryPage =  roomCapacities.ConfirmAndNext();
        System.assertEquals('/apex/AH_PLCM_MM_Inventory?ProjectId='+ ProjectId, invetoryPage.getUrl());
        // call the save method
        roomCapacities.SaveData();
        // call the Delete method
        roomCapacities.DeleteFile();

         //Start - Test common class methods
         try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = roomCapacities.RedirectToErrorPage('AH_PLCM_MM_Room_Capacities_Test_Method    ', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
        }
        // test the terms and condtions status
        roomCapacities.CheckTermsAndConditionStatus();
    
        // initialize the invetory values
        roomCapacities.SetDefaultInventoryValue();
        
        // get querystring Value
        string queryString = roomCapacities.getAllQueryString();
       
        // initialize  the test class method
        boolean IsTestClass = roomCapacities.setIsTestClassAsTrue();
        roomCapacities.CommunityUrl = 'community';

        // get property name which is assigned to ni doc
        string propertyName = roomCapacities.GetMMPropertyName();
        System.assertEquals(niDoc.Document_Name__c, propertyName);

        // initalize the picklist values
        roomCapacities.GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c','MM_Source_Type__c');
        //End - Test common class methods
        Test.stopTest();
    }
}