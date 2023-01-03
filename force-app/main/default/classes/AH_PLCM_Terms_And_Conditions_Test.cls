/***********************************************************************************************
Name            : AH_PLCM_Terms_And_Conditions_Test
Author          : Tushar Gupta
Created Date    : 17-June-2019
Last Mod Date   : 17-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Test Class for Terms and Conditions 
************************************************************************************************/

@isTest
public  class AH_PLCM_Terms_And_Conditions_Test {
    
    static String ProjectId = '';
    static testMethod void AH_PLCM_Terms_And_Conditions_Test_Method() {
        //Create new record into Ni Documentation object for testing
        NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        insert niDoc;
        ProjectId = niDoc.Id;

        //Initialize the current page AH_PLCM_Introduction
		PageReference pRef = Page.AH_PLCM_Terms_And_Conditions;
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set current page

        //Intialize the Terms and Condtion controller
        AH_PLCM_Terms_And_Conditions terms = new AH_PLCM_Terms_And_Conditions();

        //set the result value
        String pageUrl = '';

        Test.startTest();

        boolean IsTestClass = terms.setIsTestClassAsTrue();
        terms.CommunityUrl = 'neighbor';

        //test the method IsTermsAndConditionsAccepted
        PageReference pr  = terms.IsTermsAndConditionsAccepted();
        if (pr != null) {
            pageUrl = pr.getUrl();
            if (terms.TermsAndCondtionAccepted == true) {
                System.assertEquals('/apex/AH_PLCM_Introduction', pageUrl);
            }
            else {
                System.assertEquals('', pageUrl);
            }
        }
        else {
            System.assertEquals('', pageUrl);
        }
        
        //test the method AcceptTermsAndCondtion
        terms.Opt_Out_Social_Media_Feature = true;
        pageUrl =  terms.AcceptTermsAndCondtion().getUrl();
        System.assertEquals('/apex/AH_PLCM_Introduction', pageUrl);    

        terms.Opt_Out_Social_Media_Feature = null;
        pageUrl =  terms.AcceptTermsAndCondtion().getUrl();

        //Start - Test common class methods
        boolean targetUser =  terms.IsTargetUserExist;

        terms.GetParameterValue('ProjectId');
        
        terms.UpdatePortalStatus(terms.ProjectPortalStatus.PropertyUpdated);
        terms.SetVariablesValue();

        terms.UpdatePortalStatus(terms.ProjectPortalStatus.UsersCreated);
        terms.SetVariablesValue();

        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = terms.RedirectToErrorPage('AH_PLCM_Terms_And_Conditions_Test', ex).getUrl();
            System.assertEquals('/apex/AH_PLCM_Error_Page', pageUrl);
            terms.CommunityUrl = 'neighborhood';
            pageUrl = terms.RedirectToErrorPage('AH_PLCM_Terms_And_Conditions_Test', ex).getUrl();
        }

        terms.CheckTermsAndConditionStatus();
        //End - Test common class methods
        Test.stopTest();

    }
}