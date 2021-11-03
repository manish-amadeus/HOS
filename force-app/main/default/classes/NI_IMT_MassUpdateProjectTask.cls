public class NI_IMT_MassUpdateProjectTask {
	
	public ApexPages.StandardSetController setcon;
	public pse__Project_Task__c proj;
	public boolean isError {get;set;}
	private final List<SObject> objs;
	 
	public NI_IMT_MassUpdateProjectTask(ApexPages.StandardSetController controller){
		setcon = controller;
		isError = true;
		List<String> strProfile = new List<String>();
		this.objs = (List<SObject>)controller.getSelected();
		if(this.objs.size()<1) {
			String msg = Label.NI_IMT_Mass_Update_Project_Task_No_Record_Selected;
			//isError = true; 
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
        	
		}
		// Get profile names from Custom setting 
		List<NI_Project_Task_Profile_Access__c> lstProfiles = NI_Project_Task_Profile_Access__c.getAll().values();
		for(NI_Project_Task_Profile_Access__c proAsc:lstProfiles){
			strProfile.add(String.valueOf(proAsc.Profile_Name__c));
		}		
		Id profileId=userinfo.getProfileId();
		// Get profile name of current user
		String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
		for(String proName:strProfile){
			if(proName == profileName){
				isError = false;								
			} 
			
		}
		
		if(isError){							
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,Label.NI_IMT_Mass_Update_Project_Task_Insufficient_privileges));			
			
		} 
		
	}
	// Action Function to Update records
	public pagereference doSave(){
		List<pse__Project_Task__c> lstProjects = new List<pse__Project_Task__c>();
		System.debug((List<pse__Project_Task__c>)setCon.getSelected());
		boolean addFlag = false;		
		List<ID> lstIds = new List<ID>();
		// Display Error if no record Selected
		if(((List<pse__Project_Task__c>)setCon.getSelected()).size()<1) {
			String msg = Label.NI_IMT_Mass_Update_Project_Task_No_Record_Selected;
			//isError = true; 
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
        	
		}
		// Apply change as per the selected input field values.
		for(pse__Project_Task__c projectToUpdate :(List<pse__Project_Task__c>)setCon.getSelected()){
			if(projectToUpdate.pse__Started__c != proj.pse__Started__c && proj.pse__Started__c != null){
				projectToUpdate.pse__Started__c = proj.pse__Started__c;
				addFlag = true;
			}
			if(projectToUpdate.pse__Completed__c != proj.pse__Completed__c && proj.pse__Completed__c != null){
				projectToUpdate.pse__Completed__c = proj.pse__Completed__c;
				addFlag = true;
			}
			if(projectToUpdate.pse__Status__c != proj.pse__Status__c && proj.pse__Status__c != null){
				projectToUpdate.pse__Status__c = proj.pse__Status__c;
				addFlag = true;
			}
			if(projectToUpdate.Name != proj.Name && proj.Name != null){
				projectToUpdate.Name = proj.Name;
				addFlag = true;
			}
			/*if(projectToUpdate.pse__End_Date__c != proj.pse__End_Date__c){
				projectToUpdate.pse__End_Date__c = proj.pse__End_Date__c;
				addFlag = true;
			}*/
			if(addFlag){
				lstProjects.add(projectToUpdate);				
			}
			lstIds.add(projectToUpdate.Id);
		}
		system.debug(lstProjects);
		system.debug(lstProjects.size());
		
		try{
			//update Projects;
			//USE DATABASE DML METHOD TO UPDATE ALL OF THE SELECTED AND NON-SELECTED RECORDS
			  integer intSuccess = 0;
               Database.SaveResult[] results = Database.update(lstProjects,false);
                for(Database.SaveResult sr: results)
                {
                  if(!sr.isSuccess())
                   {
                     Database.Error err = sr.getErrors()[0];
                     System.debug(err.getMessage());
                     ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR,err.getMessage())); 
                    }
                 else
                    {
                     intSuccess += 1;
                     //Operation was successful, get the Id of the record that was processed
                       System.debug(Label.NI_IMT_Mass_Update_Project_Task_Successfully_Updated + sr.getId());                      
                    }
                }
              ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.NI_IMT_Mass_Update_Project_Task_Records_Updated + intSuccess));
              if(lstIds.size()>0){
			  	Map<Id,pse__Project_Task__c> mapProjects = new Map<Id,pse__Project_Task__c>([Select id, Name, pse__Started__c, pse__Completed__c,pse__Status__c  from pse__Project_Task__c where Id in :lstIds]);
	            // Setting orignal values of the Projects
	            for(pse__Project_Task__c projects :(List<pse__Project_Task__c>)setCon.getSelected()){					
						projects.pse__Started__c = mapProjects.get(projects.id).pse__Started__c;
						projects.pse__Completed__c = mapProjects.get(projects.id).pse__Completed__c;	
						projects.Name = mapProjects.get(projects.id).Name;
						projects.pse__Status__c = mapProjects.get(projects.id).pse__Status__c;					
					
				}
			  }
			
			}catch(Exception e){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
			}		
		
        return null;
		
	}
	public pagereference cancel(){
    	//Redirect to list page
    	PageReference cancel = setCon.cancel();
        return cancel;
    	
    }
	public pse__Project_Task__c getNewProjectTask(){
    	proj = new pse__Project_Task__c();
    	proj.pse__Status__c = ''; 	
    	return proj;
    }
    
	
    
}