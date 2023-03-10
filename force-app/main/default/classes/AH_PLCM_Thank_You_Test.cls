/***********************************************************************************************
Name            : AH_PLCM_Thank_You_Test
Author          : Tushar Gupta
Created Date    : 20-June-2019
Last Mod Date   : 20-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test class for thank you page
************************************************************************************************/
@isTest
public class AH_PLCM_Thank_You_Test {

    static String TabName = '01rS0000000BCmd'; // set the tab name
    static String ProjectId = ''; // set the project id

    static testMethod void AH_PLCM_Thank_You_Test_Method() {
        //Insert new record into Ni Documentation object
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;
        
        //intialize the page
        PageReference pRef = Page.AH_PLCM_Thank_You;
        
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('sfdc.tabName', TabName);
		Test.setCurrentPage(pRef); //set the current page
		
        String pageUrl = '';

        Test.startTest();
        //intialize the controller
        AH_PLCM_Thank_You thankYou = new AH_PLCM_Thank_You();
       
        boolean IsTestClass = thankYou.setIsTestClassAsTrue();
        thankYou.CommunityUrl = 'neighbor';

        //test the BackToIntroductionPage
        PageReference pr = thankYou.BackToIntroductionPage();
        if (pr != null) {
            System.System.debug(pr.getUrl());
            System.assertEquals('/apex/AH_PLCM_Introduction?sfdc.tabName='+ TabName, pr.getUrl());
        }


        //Start - Test common class method
        boolean targetUser =  thankYou.IsTargetUserExist;

        //test the if and else part
        thankYou.UpdatePortalStatus(thankYou.ProjectPortalStatus.PropertyUpdated);
        thankYou.SetVariablesValue();

        thankYou.UpdatePortalStatus(thankYou.ProjectPortalStatus.UsersCreated);
        thankYou.SetVariablesValue();

        thankYou.GetParameterValue('ProjectId');

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = thankYou.RedirectToErrorPage('AH_PLCM_Thank_You_Test', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);
            thankYou.CommunityUrl = 'neighborhood';
            pageUrl = thankYou.RedirectToErrorPage('AH_PLCM_Thank_You_Test', ex).getUrl();
        }

        thankYou.CheckTermsAndConditionStatus();
        //Test - Test common class method
        Test.stopTest();

    }

    static testMethod void NegativeTesting() {
        ProjectId = null;

        //intialize the page
        PageReference pRef = Page.AH_PLCM_Thank_You;
        
        //Add parameters to page URL
        pRef.getParameters().put('ProjectId', ProjectId);
        pRef.getParameters().put('sfdc.tabName', TabName);
		Test.setCurrentPage(pRef); //set the current page
		
        String pageUrl = '';

        Test.startTest();
        //intialize the controller
        AH_PLCM_Thank_You thankYou = new AH_PLCM_Thank_You();

        Test.stopTest();
    }
}