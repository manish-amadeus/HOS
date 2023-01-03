/***********************************************************************************************
Name            : AH_PLCM_User_Xref_Test
Author          : Tushar Gupta
Created Date    : 19-June-2019
Last Mod Date   : 19-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test class for create user page
************************************************************************************************/
@isTest
public class AH_PLCM_User_Xref_Test {
    static String ProjectId = ''; // set the project id
    static String TabName = '01rS0000000BCmd'; // set the tab name
    
    static testMethod void AH_PLCM_User_Xref_Test_Method() {
        //insert the new record into Ni Documentation
		NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Migration Users Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //insert new record into Migration property
        AH_PLCM_Migration_Property__c migrationProperty = NI_TestClassData.createTestAH_PLCM_Migration_Property(ProjectId, 'WHIAY Dummy Property7', 'NewHampshire Ave', 'NH', 'Portsmouth', 'USD');
        insert migrationProperty;

        //insert the new record into AH_PLCM_MigrationUser_Mapping__c object
        AH_PLCM_MigrationUser_Mapping__c migrationUserMapping = NI_TestClassData.createTestAH_PLCM_MigrationUser_Mapping(ProjectId, migrationProperty.Id, 'Jim Cook', 'jcook_test@windsorcourt.com');
        insert migrationUserMapping;

        //insert the new record into AH_PLCM_TargetOrg_User_c object
        AH_PLCM_TargetOrg_User__c targetOrgUser = NI_TestClassData.createTestAH_PLCM_TargetOrg_User_c(ProjectId, 'DirectBook User', 'delphiTest@newmarket.com');
        insert targetOrgUser;
        
        //initialize the page
        PageReference pRef = Page.AH_PLCM_User_Xref;

        //Add parameters to page URL
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set current page

        //intialize the controller
        AH_PLCM_User_Xref userXref = new AH_PLCM_User_Xref();

        Test.startTest();
        
        boolean IsTestClass = userXref.setIsTestClassAsTrue();
        userXref.CommunityUrl = 'neighbor';

        // test the save file method
        userXref.SaveFile(ProjectId, 'Customer_Inputs.xls', Blob.valueof('Some Random Value'));
        
        // set the value for testing
        userXref.SalesforceUserEmail = 'tushar.c.gupta@capgemini.com';

        //test the BackToCreateUserPage method
        PageReference prUser = userXref.BackToCreateUserPage();
        if (prUser != null) {
            System.System.debug(prUser.getUrl());
            System.assertEquals('/apex/AH_PLCM_Create_User?ProjectId=' + ProjectId + '&sfdc.tabName=' + TabName, prUser.getUrl());
        }

        //test the SaveXrefData method
        userXref.SaveXrefData();

        //test the ConfirmAndSubmit method
        userXref.ProjectPortalStatus.IsXrefCompleted = false;
        PageReference prConfirmAndSubmit = userXref.ConfirmAndSubmit();

        //Start - Test common class method
        boolean targetUser =  userXref.IsTargetUserExist;

        userXref.GetParameterValue('ProjectId');

        // test if and else part
        userXref.UpdatePortalStatus(userXref.ProjectPortalStatus.PropertyUpdated);
        userXref.SetVariablesValue();

        userXref.UpdatePortalStatus(userXref.ProjectPortalStatus.UsersCreated);
        userXref.SetVariablesValue();

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            String pageUrl = userXref.RedirectToErrorPage('AH_PLCM_User_Xref_Test', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);

            userXref.CommunityUrl = 'neighborhood';
            pageUrl = userXref.RedirectToErrorPage('AH_PLCM_User_Xref_Test', ex).getUrl();
        }

        userXref.CheckTermsAndConditionStatus();
        //End - Test common class method

        Test.stopTest();
    }
}