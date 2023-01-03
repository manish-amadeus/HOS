public class NI_IMT_MassUpdateAssignment {
	ApexPages.StandardSetController setCon;
	public pse__Assignment__c asg;
	public boolean isError {get;set;}
	private final List<SObject> objs;
	
    public NI_IMT_MassUpdateAssignment(ApexPages.StandardSetController controller){
		// Setting value to Class variable
		setCon = controller;
		// Setting error flag 
		isError = true;
		List<String> strProfile = new List<String>();
		
		// for error message
		this.objs = (List<SObject>)controller.getSelected();
		if(this.objs.size()<1) {
			String msg = Label.NI_IMT_Mass_Update_Project_No_Record_Selected; 
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
		}
		
		// Get profile names from Custom setting 
		List<NI_Assignments_Profile_Access__c> lstProfiles = NI_Assignments_Profile_Access__c.getAll().values();
		for(NI_Assignments_Profile_Access__c proAsc:lstProfiles){
			strProfile.add(String.valueOf(proAsc.Profile_Name__c));
		}		
		Id profileId=userinfo.getProfileId();
		system.debug(LoggingLevel.Error,profileId);
		// Get profile name of current user
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
		boolean errorFlag = false; 
		for(String proName:strProfile){
			if(proName == profileName){
				isError = false;							
			} 
		}
		if(isError){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,Label.Assignment_Status_Update_Insufficient_privileges));
		}
		
	}
	public pagereference doSave(){
		List<pse__Assignment__c> lstAssignments = new List<pse__Assignment__c>();
		List<ID> lstIds = new List<ID>();
		System.debug((List<pse__Assignment__c>)setCon.getSelected());
		system.debug(asg);
		
		
		for(pse__Assignment__c assignment :(List<pse__Assignment__c>)setCon.getSelected()){
			if(assignment.pse__Status__c != asg.pse__Status__c && asg.pse__Status__c != null ||
				(asg.Cancellation_Reason__c != null && assignment.Cancellation_Reason__c != asg.Cancellation_Reason__c)){
				assignment.pse__Status__c = asg.pse__Status__c;
				if(asg.Cancellation_Reason__c != null){
					assignment.Cancellation_Reason__c = asg.Cancellation_Reason__c;
				}
				lstAssignments.add(assignment);
			}
			lstIds.add(assignment.Id);
		}
		system.debug(lstAssignments);
		system.debug(lstAssignments.size());
        
        try{
			//update Assignments;
			//USE DATABASE DML METHOD TO UPDATE ALL OF THE SELECTED AND NON-SELECTED RECORDS
			  integer intSuccess = 0;
               Database.SaveResult[] results = Database.update(lstAssignments,false);
               system.debug(results);
               system.debug((List<pse__Assignment__c>)setCon.getSelected());
                for(Database.SaveResult sr: results)
                {
                  if(!sr.isSuccess())
                   {
                   	system.debug(sr);
                     Database.Error err = sr.getErrors()[0];
                     System.debug(err.getMessage());
                     ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage())); 
                    }
                 else
                    {
                     intSuccess += 1;
                     //Operation was successful, get the Id of the record that was processed
                     //  System.debug(Label.NI_IMT_Mass_Update_Assignment_Successfully_Updated + sr.getId());
                    // ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,'NI Cancellation Record successfully created.  ' + sr.getId()));  
                    }
                }
                if(lstIds.size()>0){
	                Map<Id,pse__Assignment__c> mapAssignment = new Map<Id,pse__Assignment__c>([Select id, Name, pse__Status__c, Cancellation_Reason__c from pse__Assignment__c where Id in :lstIds]);
	                // Setting orignal Status of the Assignments
	                for(pse__Assignment__c assignment :(List<pse__Assignment__c>)setCon.getSelected()){					
							assignment.pse__Status__c = mapAssignment.get(assignment.id).pse__Status__c;
							assignment.Cancellation_Reason__c = mapAssignment.get(assignment.id).Cancellation_Reason__c;					
						
					}
                }
              ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,intSuccess+' ' + Label.Assignment_Status_Update_Records_Updated));
             
			
			
			//setCon.save();
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,String.valueOf(lstProjects.size()) +' ' + 'Projects updated.'));
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
			}
		
		//PageReference cancel = setCon.cancel();
        //controller.save();
        return null;
		
	}
    public pagereference cancel(){
    	//Redirect to list page
    	PageReference cancel = setCon.cancel();
        
        return cancel;
    	
    }
    public pse__Assignment__c getNewAssignment(){
    	asg = new pse__Assignment__c();
    	asg.pse__Status__c = '';
    	return asg;
    }
}