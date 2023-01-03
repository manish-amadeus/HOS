/***********************************************************************************************
Name            : AH_PLCM_MM_Welcome
Author          : Tushar Gupta
Created Date    : 06-June-2020
Last Mod Date   : 06-June-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Welcome page
************************************************************************************************/
public class AH_PLCM_MM_Welcome extends AH_PLCM_MM_Common_Class {
    //Properties declaration
    public List<NI_Documentation__c> lstProjects { get; set; }
    public List<SelectOption> ddlProjects { get; set; }
    public NI_Documentation__c objProject { get; set; } 

    public AH_PLCM_MM_Welcome() {
        try {           
            //Get all projects from salesforce object
            lstProjects = GetProjectsByUser(false);            
            //Prepare list for project drop down
            FillListForProjectDropDown();
        }
        catch(Exception ex) {   
            //set error variable to redirect at error page
            IsErrorOccurred = true;            
        }
    }

    //Fill values in project drop down
    private void FillListForProjectDropDown() { 
        Map<Id, string> lstCompletedProjects = null;
        try {           
            //Fill list for project drop down
            ddlProjects = new List<SelectOption>();
            ddlProjects.add(new SelectOption('', '-- None --'));
            
            if(lstProjects.size() == 1) {
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

                if(obj.AH_PLCM_Portal_Progress__c == ProjectPortalStatus.InventoryInformationProvided || obj.AH_PLCM_Portal_Progress__c == ProjectPortalStatus.CustomerInputCompleted) {
                    //Add project in completed list
                    lstCompletedProjects.put(obj.Id, obj.Document_Name__c + ' (Mapping Completed)');
                }
                else {
                    //Add project in not completed list
                    ddlProjects.add(new SelectOption(obj.Id, obj.Document_Name__c));
                }
            }
            
            if(lstCompletedProjects.size() > 0) {
                //Add completed projects in list after mapping pending projects
                for (Id id : lstCompletedProjects.keySet()) {
                    ddlProjects.add(new SelectOption(id, lstCompletedProjects.get(id)));
                }
            }
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            //Release memory of objects
            lstCompletedProjects = null;
        }
    }   

    //Redirect to property page on click of next button
    public PageReference RedirectToFunctionRoomPage() { 
        List<NI_Documentation__c> lstProj = null;
        Map<string, string> lstParameters = null;
        try {
            if(!String.IsBlank(ProjectId)) {
                //Get project details based on id
                lstProj = new List<NI_Documentation__c>([SELECT Id, Name, AH_PLCM_Portal_Completion_Due_Date__c, DRC_Call_Date__c, AH_PLCM_Portal_Progress__c FROM NI_Documentation__c WHERE Id =: ProjectId]);

                if(lstProj != null && lstProj.size() > 0) {
                    //Update Migration Dates in Project Object
                    NI_Documentation__c obj = lstProj.get(0);
                
                   	obj.DRC_Call_Date__c = objProject.DRC_Call_Date__c;
                    if(String.isBlank(lstProj.get(0).AH_PLCM_Portal_Progress__c) || lstProj.get(0).AH_PLCM_Portal_Progress__c == 'Portal Invitation Sent'){
                        obj.AH_PLCM_Portal_Progress__c = ProjectPortalStatus.PropertyInformationConfirmed;
                    }
                    update obj;
                }

                //Redirect to function room page
                lstParameters = new Map<string, string>();
                lstParameters.put('ProjectId', ProjectId);
                System.debug('lstParameters'+lstParameters);
                return RedirectToPage(PageNames.FunctionRoomPage, lstParameters);
            }
            return null;
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('RedirectToFunctionRoomPage',ex);
        }
        finally {
            //Release memory of objects
            lstParameters = null;
            lstProj= null;
        }        
    }
}