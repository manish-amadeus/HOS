/***********************************************************************************************
Name            : AH_PLCM_Introduction
Author          : Umang Ankleshwaria
Created Date    : 21-May-2019
Last Mod Date   : 21-May-2019
Last Mod By     : Umang Ankleshwaria
NICC Reference  : 
Description     : Apex class for Introduction page
************************************************************************************************/
public class AH_PLCM_Introduction extends AH_PLCM_Common_Class {
    //Properties declaration
    public List<NI_Documentation__c> lstProjects { get; set; }
    public List<SelectOption> ddlProjects { get; set; }
    public NI_Documentation__c objProject { get; set; } 

    public AH_PLCM_Introduction() {
        try {           
            //Get all projects from salesforce object
            lstProjects = GetProjectsByUser(false);
            System.debug('lstProject'+ lstProjects);
            //Prepare list for project drop down
            FillListForProjectDropDown();
            
            System.debug('FillListForProjectDropDown'+ lstProjects);
        }
        catch(Exception ex) {   
            //set error variable to redirect at error page
            IsErrorOccurred = true; 
            ErrorDetails = ex;
            system.debug('ex -error'+ ex);
        }
    }

    //Fill values in project drop down
    private void FillListForProjectDropDown() { 
        Map<Id, string> lstCompletedProjects = null;
        try {           
            //Fill list for project drop down
            ddlProjects = new List<SelectOption>();
            ddlProjects.add(new SelectOption('', '-- None --'));
            system.debug('FillListForProjectDropDown-lstProjects' + lstProjects);
            if(lstProjects!= null && lstProjects.size() == 1) {
                //If only one project assigned then select it as default
                ProjectId = lstProjects.get(0).Id;
            }

            //List of completed projects (Need to add these project after not completed projects)
            lstCompletedProjects = new Map<Id, string>();
			
            for (NI_Documentation__c obj : lstProjects) {
                if(objProject == null) {
                    //Set project object value in the case when customer have only one project assigned
                    objProject = obj;
                }

                if(obj.AH_PLCM_Portal_Progress__c == ProjectPortalStatus.XrefCompleted || obj.AH_PLCM_Portal_Progress__c == ProjectPortalStatus.CustomerInputCompleted) {
                    //Add project in completed list
                    lstCompletedProjects.put(obj.Id, obj.Document_Name__c + ' (Mapping Completed)');
                }
                else {
                    //Add project in not completed list
                    ddlProjects.add(new SelectOption(obj.Id, obj.Document_Name__c));
                }
            }
            
            if(lstCompletedProjects != null && lstCompletedProjects.size() > 0) {
                //Add completed projects in list after mapping pending projects
                for (Id id : lstCompletedProjects.keySet()) {
                    ddlProjects.add(new SelectOption(id, lstCompletedProjects.get(id)));
                }
            }
        }
        catch(Exception ex) {
            system.debug('FillListForProjectDropDown-error'+ex);
            throw ex;
        }
        finally {
            //Release memory of objects
            lstCompletedProjects = null;
        }
    }   

    //Redirect to property page on click of next button
    public PageReference RedirectToPropertyPage() { 
        List<NI_Documentation__c> lstProj = null;
        Map<string, string> lstParameters = null;
        try {
            if(!String.IsBlank(ProjectId)) {
                //Get project details based on id
                lstProj = new List<NI_Documentation__c>([SELECT Id, Name, AH_PLCM_Portal_Completion_Due_Date__c, AH_PLCM_Migration_Date__c FROM NI_Documentation__c WHERE Id =: ProjectId]);

                if(lstProj != null && lstProj.size() > 0) {
                    //Update Migration Dates in Project Object
                    NI_Documentation__c obj = lstProj.get(0);
                    obj.AH_PLCM_Migration_Date__c = objProject.AH_PLCM_Migration_Date__c;
                    obj.AH_PLCM_Proposed_Migration_Date__c = objProject.AH_PLCM_Proposed_Migration_Date__c;
                    update obj;
                }

                //Redirect to properties page
                lstParameters = new Map<string, string>();
                lstParameters.put('ProjectId', ProjectId);
                return RedirectToPage(PageNames.PropertyPage, lstParameters);
            }
            return null;
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('RedirectToPropertyPage',ex);
        }
        finally {
            //Release memory of objects
            lstParameters = null;
            lstProj= null;
        }        
    }
}