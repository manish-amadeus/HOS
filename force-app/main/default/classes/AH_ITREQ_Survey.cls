public class AH_ITREQ_Survey {
   
    public String Internal_IT_Req_Name {get;set;}
	public String Internal_IT_Req_Title {get;set;}
	public String Internal_IT_Req_Technician {get;set;}
	public AH_IT_Survey__c survey{get;set;}     
    //public List<SelectOption> ROptions {get;set;}
    public AH_ITREQ_Survey(){
       // one =1;
	   survey = new AH_IT_Survey__c();
	   if(ApexPages.currentPage().getParameters().get('Id') == null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Kindly provide Id of IT Request for Survey'));			
	   } else {
		   String Internal_IT_Request = Id.valueOf(ApexPages.currentPage().getParameters().get('Id'));
		   survey.Internal_IT_Request__c = Internal_IT_Request;
		   getDetailsOfITrequest(Internal_IT_Request);
	   }
    }
    public void getDetailsOfITrequest(String itreq){
		AH_Internal_IT_Request__c objItReq = [Select id,Subject__c,Owner.Name , Name from  AH_Internal_IT_Request__c where id = :itreq];
		Internal_IT_Req_Title = objItReq.Subject__c;
		Internal_IT_Req_Technician = objItReq.Owner.Name;
		Internal_IT_Req_Name = objItReq.Name;
	}
    public List<SelectOption> getROptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
         options.add(new SelectOption('4','4')); 
         options.add(new SelectOption('5','5')); 
         options.add(new SelectOption('','N/A')); 
        return options; 
    }
    public List<SelectOption> getROptionslabels() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('1','1')); 
        options.add(new SelectOption('2','2')); 
        options.add(new SelectOption('3','3')); 
         options.add(new SelectOption('4','4')); 
         options.add(new SelectOption('5','5')); 
         options.add(new SelectOption('','N/A')); 
        return options; 
    }
	public PageReference doSave(){
		System.debug(survey);
		PageReference pg = null;
		if(survey.Resolved_in_timely_manner__c ==null &&
			survey.Professionalism_of_technician__c ==null &&
			survey.Was_the_issue_completely_resolved__c ==null &&
			survey.Was_the_technician_knowledgeable__c ==null &&
			survey.Did_technician_provide_status_updates__c ==null &&
			survey.Rate_your_overall_experience__c ==null &&
			survey.IT_Request_system_user_experience__c ==null &&
			survey.IT_Request_system_acceptable_speed__c ==null &&
			survey.Were_the_fields_clear_and_understandable__c ==null ){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Kindly submit valid values for Survey'));			
		}
			
		else {
			
			insert survey;
			  pg = new PageReference('/apex/AH_ITREQ_Survey_Details?Id=' + survey.Id);
		}
		
		return pg;
	}
}