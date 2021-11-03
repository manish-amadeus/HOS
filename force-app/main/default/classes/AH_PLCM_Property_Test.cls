/***********************************************************************************************
Name            : AH_PLCM_Property_Test
Author          : Tushar Gupta
Created Date    : 18-June-2019
Last Mod Date   : 18-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test class for Property page
************************************************************************************************/
@isTest
public class AH_PLCM_Property_Test {
    static String ProjectId = ''; // set the project id
    static String TabName = '01rS0000000BCmd'; // set the tab name

    static testMethod void AH_PLCM_Property_Test_Method() {
        //Insert new record into NI Documentation object for testing
		NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //insert new record into migration property
        AH_PLCM_Migration_Property__c migrationProperty = NI_TestClassData.createTestAH_PLCM_Migration_Property(ProjectId, 'WHIAY Dummy Property7', 'NewHampshire Ave', 'NH', 'Portsmouth', 'USD');
        insert migrationProperty;
        
        //insert new record into migration user
        AH_PLCM_Migration_User__c migrationUser =  NI_TestClassData.createTestAH_PLCM_Migration_User_c(migrationProperty.Id, 'Ebony Wiggins', 'ebony.wiggins.test@hyattex.com', 'USD');
        insert migrationUser;

        //Initialize the current page AH_PLCM_Property
		PageReference pRef = Page.AH_PLCM_Property;
		
		String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef);

        //Intialize the controller
        AH_PLCM_Property property = new AH_PLCM_Property();

    	Test.startTest();
        boolean IsTestClass = property.setIsTestClassAsTrue();
        property.CommunityUrl = 'neighbor';
        
        property.ProjectPortalStatus.IsPropertyUpdated = false;
        //test the ConfirmAndNext 
        pageUrl = property.ConfirmAndNext().getUrl();
        
        System.assertEquals('/apex/AH_PLCM_Create_User?ProjectId=' + ProjectId + '&sfdc.tabName=' + TabName, pageUrl);

        //test the BackToIntroductionPage method
        pageUrl = property.BackToIntroductionPage().getUrl();
        
        System.assertEquals('/apex/AH_PLCM_Introduction?sfdc.tabName=' + TabName, pageUrl);
    
        //Start - Test common class method
        boolean targetUser =  property.IsTargetUserExist;

        property.GetParameterValue('ProjectId');

        property.UpdatePortalStatus(property.ProjectPortalStatus.PropertyUpdated);
        property.SetVariablesValue();

        property.UpdatePortalStatus(property.ProjectPortalStatus.UsersCreated);
        property.SetVariablesValue();

        //test catch block
        property.lstProperties[0].Name = null;
        property.lstProperties[0].Id = null;
        property.ProjectPortalStatus.IsPropertyUpdated = false;
        pageUrl = property.ConfirmAndNext().getUrl();

        //check again for test else part
        targetUser = property.IsTargetUserExist;

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = property.RedirectToErrorPage('AH_PLCM_Property_Test_Method', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);
        }

        property.CheckTermsAndConditionStatus();
        //End - Test common class method
        
        Test.stopTest();
    }

    static testMethod void Test_Without_ProjectID() {
        Test.startTest();
        
        //Initialize the current page AH_PLCM_Property
		PageReference pRef = Page.AH_PLCM_Property;
		
		String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef);

        //Intialize the controller
        AH_PLCM_Property property = new AH_PLCM_Property();

        boolean IsTestClass = property.setIsTestClassAsTrue();
        property.CommunityUrl = 'neighbor';
        
        //test the ConfirmAndNext 
        PageReference prCN = property.ConfirmAndNext();
        if(prCN != null) {
            System.assertEquals('/apex/AH_PLCM_Create_User?ProjectId=' + ProjectId + '&sfdc.tabName=' + TabName, prCN.getUrl());
        }
        
        
        //test the BackToIntroductionPage method
        pageUrl = property.BackToIntroductionPage().getUrl();
        
        System.assertEquals('/apex/AH_PLCM_Introduction?sfdc.tabName=' + TabName, pageUrl);
    
        //Start - Test common class method
        property.GetParameterValue('ProjectId');

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = property.RedirectToErrorPage('AH_PLCM_Property_Test_Method', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);
            property.CommunityUrl = 'neighborhood';
            pageUrl = property.RedirectToErrorPage('AH_PLCM_Property_Test_Method', ex).getUrl();
        }

        property.CheckTermsAndConditionStatus();
        //End - Test common class method

        Test.stopTest();
    }
}