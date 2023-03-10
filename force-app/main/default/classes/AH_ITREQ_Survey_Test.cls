@isTest
private class AH_ITREQ_Survey_Test {

	@isTest
	private static void testInsertedRecord() {

		AH_Internal_IT_Request__c InternalReq = new AH_Internal_IT_Request__c();
		InternalReq.Subject__c = 'TestSubject';
		//InternalReq.Name = 'TestName';
		
		Insert InternalReq;
		//Use the PageReference Apex class to instantiate a page
		PageReference pageRef = Page.AH_ITREQ_Survey;
       
		//In this case, the Visualforce page named 'success' is the starting point of this test method. 
		Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('Id', InternalReq.id);
		//Instantiate and construct the controller class.   
		AH_ITREQ_Survey controller = new AH_ITREQ_Survey();
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
		
		controller.doSave();

		System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.WARNING) == false);


	}
	@isTest
	private static void testWaning() {

		AH_Internal_IT_Request__c InternalReq = new AH_Internal_IT_Request__c();
		InternalReq.Subject__c = 'TestSubject';
		
		Insert InternalReq;
		//Use the PageReference Apex class to instantiate a page
		PageReference pageRef = Page.AH_ITREQ_Survey;
       
		Test.setCurrentPage(pageRef);
		 ApexPages.currentPage().getParameters().put('Id', InternalReq.id);
		//Instantiate and construct the controller class.   
		AH_ITREQ_Survey controller = new AH_ITREQ_Survey();

       
		controller.survey.Resolved_in_timely_manner__c =null;
		controller.survey.Professionalism_of_technician__c =null ;
		controller.survey.Was_the_issue_completely_resolved__c =null ;
		controller.survey.Was_the_technician_knowledgeable__c =null ;
		controller.survey.Did_technician_provide_status_updates__c =null ;
		controller.survey.Rate_your_overall_experience__c =null ;
		controller.survey.IT_Request_system_user_experience__c =null ;
		controller.survey.IT_Request_system_acceptable_speed__c =null ;
		controller.survey.Were_the_fields_clear_and_understandable__c =null;
		//String nextPage = controller.doSave().getUrl();
		controller.doSave();
	   
		System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.WARNING) == true);


	}
	@isTest
	private static void testError() {
		//Use the PageReference Apex class to instantiate a page
		PageReference pageRef = Page.AH_ITREQ_Survey;
       
		//In this case, the Visualforce page named 'success' is the starting point of this test method. 
		Test.setCurrentPage(pageRef);		 
		AH_ITREQ_Survey controller = new AH_ITREQ_Survey();
		System.assert(ApexPages.hasMessages(ApexPages.SEVERITY.ERROR) == true);


	}
}