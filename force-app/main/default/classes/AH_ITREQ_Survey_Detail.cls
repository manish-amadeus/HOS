public class AH_ITREQ_Survey_Detail { 
	public String Internal_IT_Req_Name {get;set;}
	public String Internal_IT_Req_Title {get;set;}
	public String Internal_IT_Req_Technician {get;set;}
	public AH_IT_Survey__c survey{get;set;}     
    //public List<SelectOption> ROptions {get;set;}
    public AH_ITREQ_Survey_Detail(){
       // one =1;
	   survey = new AH_IT_Survey__c();
	   if(ApexPages.currentPage().getParameters().get('Id') == null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Kindly provide Id of IT Request for Survey'));			
	   } else {
		   String Internal_IT_Request = Id.valueOf(ApexPages.currentPage().getParameters().get('Id'));
		   survey.Id = Internal_IT_Request;
		   getDetailsOfITrequest(Internal_IT_Request);
	   }
    }
    public void getDetailsOfITrequest(String itreq){
		AH_IT_Survey__c objItReq = [Select id,Name, Resolved_in_timely_manner__c,Professionalism_of_technician__c , 
												Was_the_issue_completely_resolved__c,Was_the_technician_knowledgeable__c,
												Did_technician_provide_status_updates__c, Rate_your_overall_experience__c,
												IT_Request_system_user_experience__c, IT_Request_system_acceptable_speed__c,
												Were_the_fields_clear_and_understandable__c, Comments__c,Internal_IT_Request__c,Internal_IT_Request__r.Name,
												Internal_IT_Request__r.Subject__c,Internal_IT_Request__r.Owner.Name 
												 From  AH_IT_Survey__c Where id = :itreq];
		Internal_IT_Req_Title = objItReq.Internal_IT_Request__r.Subject__c;
		Internal_IT_Req_Technician = objItReq.Internal_IT_Request__r.Owner.Name;
		Internal_IT_Req_Name = objItReq.Internal_IT_Request__r.Name;
		if(objItReq.Resolved_in_timely_manner__c ==null) objItReq.Resolved_in_timely_manner__c= 0;
		if(objItReq.Professionalism_of_technician__c ==null) objItReq.Professionalism_of_technician__c= 0;
		if(objItReq.Was_the_issue_completely_resolved__c ==null) objItReq.Was_the_issue_completely_resolved__c= 0;
		if(objItReq.Was_the_technician_knowledgeable__c ==null) objItReq.Was_the_technician_knowledgeable__c= 0;
		if(objItReq.Did_technician_provide_status_updates__c ==null) objItReq.Did_technician_provide_status_updates__c= 0;
		if(objItReq.Rate_your_overall_experience__c ==null) objItReq.Rate_your_overall_experience__c= 0;
		if(objItReq.IT_Request_system_user_experience__c ==null) objItReq.IT_Request_system_user_experience__c= 0;
		if(objItReq.IT_Request_system_acceptable_speed__c ==null) objItReq.IT_Request_system_acceptable_speed__c= 0;
		if(objItReq.Were_the_fields_clear_and_understandable__c ==null) objItReq.Were_the_fields_clear_and_understandable__c= 0;
		


		survey = objItReq;
	}
    public List<SelectOption> getROptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','1',true)); 
        options.add(new SelectOption('2','2',true)); 
        options.add(new SelectOption('3','3',true)); 
         options.add(new SelectOption('4','4',true)); 
         options.add(new SelectOption('5','5',true)); 
         options.add(new SelectOption('0','N/A',true)); 
        return options; 
    }
	
    public List<SelectOption> getROptionslabels() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','1',true)); 
        options.add(new SelectOption('2','2',true)); 
        options.add(new SelectOption('3','3',true)); 
         options.add(new SelectOption('4','4',true)); 
         options.add(new SelectOption('5','5',true)); 
         options.add(new SelectOption('0','N/A',true)); 
        return options; 
    }
	
}