/***********************************************************************************************
Name            : AH_PLCM_MM_Function_Room_Test
Author          : Tushar Gupta
Created Date    : 13-Aug-2020
Last Mod Date   : 13-Aug-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Function Room test page
************************************************************************************************/
@isTest
public class AH_PLCM_MM_Function_Room_Test {
        static String ProjectId = ''; // set the project id

        static testMethod void AH_PLCM_MM_Function_Room_Test_Method() { 

        //insert new record into NI Documentatin object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_DocumentationForMM('Hotel Wonderful MM Conversion', date.today().format(), date.today().format(), 'Property Information Confirmed', false, false, false, 'Project Plan', true, date.today().format());
        insert niDoc;
        ProjectId = niDoc.Id;

        System.debug('ProjectId'+niDoc);

        //Initialize the page AH_PLCM_MM_Function_Room
        PageReference pRef = Page.AH_PLCM_MM_Function_Room;
        
        String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set the current page

        Test.startTest();
        //Intialize the function Room controller
        AH_PLCM_MM_Function_Room functionRoomObj= new AH_PLCM_MM_Function_Room();

        boolean IsTestClass = functionRoomObj.setIsTestClassAsTrue();
        functionRoomObj.CommunityUrl = 'community';
        //test the RedirectToPropertyPage method
        PageReference prPPage = functionRoomObj.BackToHomePage(); // get current page url
        if (prPPage != null) {
            System.assertEquals('/apex/AH_PLCM_MM_Welcome', prPPage.getUrl());
        }

        // initialize the picklist values
        List<SelectOption> lstSourceType = functionRoomObj.lstSourceType;

        List<SelectOption> lstFunctionRoomType = functionRoomObj.lstFunctionRoomType;

        // Adding Function Room        
        functionRoomObj.functionRoom = NI_TestClassData.createTest_FunctionRoom('Room 1','MM','Source Locations', 10, 1, '', '1', true, 'Function room descriptions');
       // functionRoom.functionRoom.Name = 'Room 1';
        functionRoomObj.functionRoomId = 'test id';
        System.debug('functionRoomId'+ functionRoomObj.functionRoomId);
        System.debug('functionRoom12' + functionRoomObj.functionRoom);

        functionRoomObj.AddFunctionRoom();

        // set the function room id for do other operations like edit and delete.
        functionRoomObj.functionRoomId = functionRoomObj.lstFunctionRoom.get(0).Id;
        
        // call the edit method
        functionRoomObj.EditFunctionRoom();
        System.debug('functionRoom.functionRoom.MM_NI_Doc_Record__c'+functionRoomObj.functionRoom.MM_NI_Doc_Record__c);
        // check the ni doc id is correct as our requirement
        System.assertEquals(functionRoomObj.functionRoom.MM_NI_Doc_Record__c, ProjectId);

        // update the function room
        functionRoomObj.functionRoom.Name = 'Room 2';
        functionRoomObj.UpdateFunctionRoom();

        // check the function room is updated or not
        functionRoomObj.EditFunctionRoom();
        System.assertEquals('Room 2', functionRoomObj.functionRoom.Name);

        // get the project id through query string and verify the project id is valid or not
        string projId = functionRoomObj.GetParameterValue('ProjectId');
        System.assertEquals(ProjectId, projId);

        // delete the function room 
        functionRoomObj.DeleteFunctionRoom();

        // check the catch block of update method
        functionRoomObj.UpdateFunctionRoom();
        functionRoomObj.DeleteFunctionRoom();

        // check the function room is deleted or not
        System.assertEquals(functionRoomObj.lstFunctionRoom.Size(), 0);
        
        // call the method for go to next page.
        functionRoomObj.GoToRoomCapacities();

        // initialize the variable
        functionRoomObj.SourceType = 'MM';
        functionRoomObj.FunctionRoomType = '';
        functionRoomObj.message = '';
        
        //Start - Test common class methods
        try {
               integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = functionRoomObj.RedirectToErrorPage('AH_PLCM_MM_functionRoom_Test_Method', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_MM_Error_Page', pageUrl);
        }
        // test the terms and condtions status
        functionRoomObj.CheckTermsAndConditionStatus();
    
        // initialize the invetory values
        functionRoomObj.SetDefaultInventoryValue();
              
        // get querystring Value
        string queryString = functionRoomObj.getAllQueryString();
    
        //End - Test common class methods
        Test.stopTest();
    }
}