/***********************************************************************************************
Name            : AH_PLCM_Introduction_Test
Author          : Tushar Gupta
Created Date    : 12-June-2019
Last Mod Date   : 12-June-2019
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Introduction test page
************************************************************************************************/
@isTest
Public class AH_PLCM_Introduction_Test {

    static String ProjectId = ''; // set the project id
    static String TabName = '01rS0000000BCmd'; // set the tab name

    static testMethod void AH_PLCM_Introduction_Test_Method() {	    
		//insert new record into NI Documentatin object for testing
		NI_Documentation__c niDoc = NI_TestClassData.createTestNI_Documentation('Portal Setup And Migration Plan', 10, '07/21/2019', '07/28/2019', '07/30/2019', 'Cross-Reference Complete', false, false, false, 'Project Plan' );
        niDoc.AH_PLCM_IsTerms_and_Conditions_Accepted__c = true;
        niDoc.AH_PLCM_Terms_and_Cndtions_Accepted_Date__c = date.today();
        insert niDoc;
        ProjectId = niDoc.Id;

		//Initialize the page AH_PLCM_Introduction
		PageReference pRef = Page.AH_PLCM_Introduction;
		
		String pageUrl = '';

        //Add parameters to page URL
        pRef.getParameters().put('sfdc.tabName', TabName);
        pRef.getParameters().put('ProjectId', ProjectId);
        Test.setCurrentPage(pRef); //set the current page

    	Test.startTest();

		//Intialize the Introduction controller
		AH_PLCM_Introduction intro= new AH_PLCM_Introduction();
		        
		boolean IsTestClass = intro.setIsTestClassAsTrue();
		intro.CommunityUrl = 'neighbor';
		
		//test the RedirectToPropertyPage method
		PageReference prPPage = intro.RedirectToPropertyPage(); // get current page url
		if (prPPage != null) {
			System.assertEquals('/apex/AH_PLCM_Property?ProjectId='+ ProjectId +'&sfdc.tabName='+ TabName +'', prPPage.getUrl());
		}
	
		
		//test the CheckTermsAndConditionsStatus method
		// PageReference pr = intro.CheckTermsAndConditionsStatus();
		// if (pr != null) {
		// 	pageUrl = pr.getUrl(); // get current page url
		// 	System.assertEquals('/apex/AH_PLCM_Terms_And_Conditions?sfdc.tabName='+ TabName +'', pageUrl);
		// }
		// else {
		// 	System.assertEquals('', pageUrl);
		// }
		

		//Start - Test common class methods
		boolean targetUser =  intro.IsTargetUserExist;

        intro.GetParameterValue('ProjectId');

		intro.UpdatePortalStatus(intro.ProjectPortalStatus.UsersCreated);
		
		//check again for else part
		targetUser = intro.IsTargetUserExist;
		
        // call the query string method 
        intro.getAllQueryString();
        
        try {
            integer a = 0, b = 1, c = b/a;
        }
        catch(Exception ex){
            pageUrl = intro.RedirectToErrorPage('AH_PLCM_Introduction_Test_Method', ex).getUrl();
			System.assertEquals('/apex/AH_PLCM_Error_Page?sfdc.tabName='+ TabName, pageUrl);
			intro.CommunityUrl = 'neighborhood';
            pageUrl = intro.RedirectToErrorPage('AH_PLCM_Introduction_Test_Method', ex).getUrl();
        }

        intro.CheckTermsAndConditionStatus();
		//End - Test common class methods
		Test.stopTest();
	}

	
}