/***********************************************************************************************
Name            : AH_PLCM_Property_Test
Author          : Tushar Gupta
Created Date    : 18-June-2019
Last Mod Date   : 18-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test class for create user page
************************************************************************************************/
@IsTest(SeeAllData=true)
public class AH_PLCM_Create_User_Test {
    static String ProjectId = ''; // set the project id
    static String TabName = '01rS0000000BCmd'; // set the tab name

    static testMethod void AH_PLCM_Create_User_Test_Method() {
        //insert the new record into Ni documetation
		NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //insert the new record into AH_PLCM_MigrationUser_Mapping__c
        AH_PLCM_MigrationUser_Mapping__c migrationUser = NI_TestClassData.createTestAH_PLCM_MigrationUser_Mapping(ProjectId, '', 'Jim Cook', 'jcook_test@windsorcourt.com');
        insert migrationUser;
        
        //insert the new record into AH_PLCM_Migration_Property__c
        AH_PLCM_Migration_Property__c migrationProperty = NI_TestClassData.createTestAH_PLCM_Migration_Property(ProjectId, 'WHIAY Dummy Property7', 'NewHampshire Ave', 'NH', 'Portsmouth', 'USD');
        insert migrationProperty;
        
        // Intialize the AH_PLCM_Create_User page
        PageReference pRef = Page.AH_PLCM_Create_User;
		
		String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef);

        // Intialize the controller
        AH_PLCM_Create_User createUser = new AH_PLCM_Create_User();
        
    	Test.startTest();
        boolean IsTestClass = createUser.setIsTestClassAsTrue();
        createUser.CommunityUrl = 'neighbor';

        // test the save file method
        createUser.SaveFile(ProjectId, 'Customer_Inputs.xls', Blob.valueof('Some Random Value'));

        //test the SaveUserDetails method 
        createUser.SaveUserDetails();
        
        //set default values
        createUser.SetVariablesValue();
        
        //set property as false
        createUser.ProjectPortalStatus.IsUsersCreated = false;
        
        //test the ConfirmAndNext method 
        pageUrl = createUser.ConfirmAndNext().getUrl();
        System.assertEquals('/apex/AH_PLCM_User_Xref?ProjectId=' + ProjectId + '&sfdc.tabName=' + TabName, pageUrl);
        

        //test the BackToPropertyList method 
        PageReference pr = createUser.BackToPropertyList();
        if (pr != null) {
            System.assertEquals('/apex/AH_PLCM_Property?ProjectId=' + ProjectId + '&sfdc.tabName=' + TabName, pr.getUrl());
        }
        
        //test the catch block in SaveUserDetails method 
        createUser.lstUsers[0].Id = null;
        createUser.SaveUserDetails();

        //start - test the common class methods
        createUser.GetParameterValue('ProjectId');

        boolean targetUser =  createUser.IsTargetUserExist;

        createUser.UpdatePortalStatus(createUser.ProjectPortalStatus.PropertyUpdated);
        createUser.SetVariablesValue();

        createUser.UpdatePortalStatus(createUser.ProjectPortalStatus.UsersCreated);
        createUser.SetVariablesValue();
        
        //check again for test else part
        targetUser = createUser.IsTargetUserExist;

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = createUser.RedirectToErrorPage('AH_PLCM_Create_User', ex).getUrl();
            createUser.CommunityUrl = 'neighborhood';
            pageUrl = createUser.RedirectToErrorPage('AH_PLCM_Create_User', ex).getUrl();
        }

        createUser.CheckTermsAndConditionStatus();
        //end - test the common class methods
        Test.stopTest();
    }
}