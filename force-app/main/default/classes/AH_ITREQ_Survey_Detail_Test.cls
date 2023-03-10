@isTest
private class AH_ITREQ_Survey_Detail_Test {

	@isTest
	private static void testInsertedRecord() {

		AH_Internal_IT_Request__c InternalReq = new AH_Internal_IT_Request__c();
		InternalReq.Subject__c = 'TestSubject';
		Insert InternalReq;
		AH_IT_Survey__c survey = new AH_IT_Survey__c();
		survey.Resolved_in_timely_manner__c =1;
		survey.Professionalism_of_technician__c =2 ;
		survey.Was_the_issue_completely_resolved__c =2 ;
		survey.Was_the_technician_knowledgeable__c =2 ;
		survey.Did_technician_provide_status_updates__c =2 ;
		survey.Rate_your_overall_experience__c =2 ;
		survey.IT_Request_system_user_experience__c =2 ;
		survey.IT_Request_system_acceptable_speed__c =2 ;
		survey.Were_the_fields_clear_and_understandable__c =2;
		survey.Internal_IT_Request__c = InternalReq.id;
		insert survey;
		
		//InternalReq.Name = 'TestName';
		
		
		//Use the PageReference Apex class to instantiate a page
		PageReference pageRef = Page.AH_ITREQ_Survey_Details;
       
		//In this case, the Visualforce page named 'success' is the starting point of this test method. 
		Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('Id', survey.id);
		//Instantiate and construct the controller class.   
		AH_ITREQ_Survey_Detail controller = new AH_ITREQ_Survey_Detail();
		controller.getROptions();
		controller.getROptionslabels();
       
		controller.survey.Resolved_in_timely_manner__c =1;
		controller.survey.Professionalism_of_technician__c =2 ;
		controller.survey.Was_the_issue_completely_resolved__c =2 ;
		controller.survey.Was_the_technician_knowledgeable__c =2 ;
		controller.survey.Did_technician_provide_status_updates__c =2 ;
		controller.survey.Rate_your_overall_experience__c =2 ;
		controller.survey.IT_Request_system_user_experience__c =2 ;
		controller.survey.IT_Request_system_acceptable_speed__c =2 ;
		controller.survey.Were_the_fields_clear_and_understandable__c =2;
		
		//controller.doSave();

		System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.WARNING) == false);


	}
	
	@isTest
	private static void testError() {
		//Use the PageReference Apex class to instantiate a page
		PageReference pageRef = Page.AH_ITREQ_Survey_Details;
       
		//In this case, the Visualforce page named 'success' is the starting point of this test method. 
		Test.setCurrentPage(pageRef);		 
		AH_ITREQ_Survey_Detail controller = new AH_ITREQ_Survey_Detail();
		System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR) == true);


	}
}