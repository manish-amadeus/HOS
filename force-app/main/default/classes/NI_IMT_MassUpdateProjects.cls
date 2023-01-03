public with sharing class NI_IMT_MassUpdateProjects {
	
	public ApexPages.StandardSetController setcon;
	public pse__Proj__c proj;
	public boolean isError {get;set;}
	private final List<SObject> objs;
	 
	public NI_IMT_MassUpdateProjects(ApexPages.StandardSetController controller){
		setcon = controller;
		isError = true;
		List<String> strProfile = new List<String>();
		this.objs = (List<SObject>)controller.getSelected();
		if(this.objs.size()<1) {
			String msg = Label.NI_IMT_Mass_Update_Project_No_Record_Selected; 
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msg));
		}
		// Get profile names from Custom setting 
		List<NI_Projects_Profile_Access__c> lstProfiles = NI_Projects_Profile_Access__c.getAll().values();
		for(NI_Projects_Profile_Access__c proAsc:lstProfiles){
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
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning,Label.NI_IMT_Mass_Update_Project_Insufficient_privileges));			
			
		} 
	}
	public pagereference doSave(){
		List<pse__Proj__c> lstProjects = new List<pse__Proj__c>();
		System.debug((List<pse__Proj__c>)setCon.getSelected());
		boolean addFlag = false;
		//system.debug(asg);
		List<ID> lstIds = new List<ID>();
		
		for(pse__Proj__c projectToUpdate :(List<pse__Proj__c>)setCon.getSelected()){
			addFlag = false;
			if(projectToUpdate.pse__Stage__c != proj.pse__Stage__c && proj.pse__Stage__c != null){
				projectToUpdate.pse__Stage__c = proj.pse__Stage__c;
				addFlag = true;
			}
			if(projectToUpdate.pse__Project_Manager__c != proj.pse__Project_Manager__c && proj.pse__Project_Manager__c != null){				
				projectToUpdate.pse__Project_Manager__c = proj.pse__Project_Manager__c;
				addFlag = true;
			}
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
                       System.debug(Label.NI_IMT_Mass_Update_Project_Successfully_Updated + sr.getId());                      
                    }
                }
              ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.NI_IMT_Mass_Update_Project_Records_Updated + intSuccess));
              
			  if(lstIds.size()>0){
			  	Map<Id,pse__Proj__c> mapProjects = new Map<Id,pse__Proj__c>([Select id, Name, pse__Stage__c, pse__Project_Manager__c from pse__Proj__c where Id in :lstIds]);
	            // Setting orignal values of the Projects
	            for(pse__Proj__c projects :(List<pse__Proj__c>)setCon.getSelected()){					
						projects.pse__Stage__c = mapProjects.get(projects.id).pse__Stage__c;
						projects.pse__Project_Manager__c = mapProjects.get(projects.id).pse__Project_Manager__c;					
					
				}
			  }
			
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
	public pse__Proj__c getNewProject(){
    	proj = new pse__Proj__c();
    	proj.pse__Stage__c = ''; 	
    	return proj;
    }
    
}