/***********************************************************************************************
Name            : AH_PLCM_Create_User
Author          : Umang Ankleshwaria
Created Date    : 23-May-2019
Last Mod Date   : 23-May-2019
Last Mod By     : Umang Ankleshwaria
NICC Reference  : 
Description     : Class for Create User Page
************************************************************************************************/
public  class AH_PLCM_Create_User extends AH_PLCM_Common_Class  {
    //Initialize Variables
    public List<AH_PLCM_MigrationUser_Mapping__c> lstUsers { get; set; }
   // public List<SelectOption> ddlProperties { get; set; }
    public Decimal AvailableLicenses { get; set; }

     public AH_PLCM_Create_User() {
        List<NI_Documentation__c> lstProjects = null;
        //List<AH_PLCM_Migration_Property__c> lstProperties = null;
        try {        
            if(!String.IsBlank(ProjectId)){
                //Get User List
                lstUsers = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, PLCM_Migration_Property_Assignment__c FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId ORDER BY Name, User_Email_Address__c]);
                
                //Get Project Details
                lstProjects = new List<NI_Documentation__c>([SELECT AH_PLCM_Total_Available_Licenses__c FROM NI_Documentation__c WHERE Id = :ProjectId]);

                if(lstProjects != null && lstProjects.size() > 0 && lstProjects[0].AH_PLCM_Total_Available_Licenses__c > 0) {
                    //Set value of available licenses
                    AvailableLicenses = lstProjects[0].AH_PLCM_Total_Available_Licenses__c;
                }
                else {
                    AvailableLicenses = 0;
                }
                //Date:-06/18/20 Remove default property drop down from create users page
                //Get Properties for Selected Project
                /*lstProperties = new List<AH_PLCM_Migration_Property__c>([SELECT Id, Name FROM AH_PLCM_Migration_Property__c WHERE NI_Doc_Record__c=:ProjectId]);
                
                if(lstProperties != null && lstProperties.size() > 0) {
                    //Prepare list for properties drop down
                    ddlProperties = new List<SelectOption>();
                    ddlProperties.add(new SelectOption('', '--None--'));
                    for (AH_PLCM_Migration_Property__c obj : lstProperties) {
                        ddlProperties.add(new SelectOption(obj.Id, obj.Name));
                    }
                }*/
            }
        }
        catch(Exception ex) {
            //Set error variable to redirect at error page
            IsErrorOccurred = true;            
        }
        finally {
            //Release memory of unused objects
            lstProjects = null;
           // lstProperties = null;
        }
    }
    
    //Save details of user creation    
    public void SaveUserDetails() {
        try {    
            //Get latest Buuble Help text flag values 
            System.debug('AvailableLicenses'+AvailableLicenses);
            SetVariablesValue();
            if (lstUsers.Size() > 0 && AvailableLicenses>0 )
            {
                //Save Selected Users
                update lstUsers;
            }
        }
        catch(Exception ex) {
            //Redirect to error page
            RedirectToErrorPage('SaveUserDetails',ex);
        }
    }    
    
    //Save Entered Data and redirect to next Transfer User Page
    public PageReference ConfirmAndNext() {
        Map<string, string> lstParameters = null;
        try {            
            if(!String.IsBlank(ProjectId)){
                if(ProjectPortalStatus.IsUsersCreated == false) {
                    //Save selected user's details 
                    SaveUserDetails();
                    
                    //Update Project Status
                    UpdatePortalStatus(ProjectPortalStatus.UsersCreated);
                }

                //Redirect to Transfer User Page
                lstParameters = new Map<string, string>();
                lstParameters.put('ProjectId', ProjectId);
                return RedirectToPage(PageNames.TransferUserPage, lstParameters);
            }

            //If Project Id not found then do not redirect
            return null;
        }
        catch(Exception ex) {
            //Redirect to error page
           return RedirectToErrorPage('ConfirmAndNext',ex);
        }
        finally{
            lstParameters = null;
        }
    }
    
    //Go to previous Property List Page
    public PageReference BackToPropertyList() {
        Map<string, string> lstParameters =  null;
        try {
            //Redirect Back to Property List Page
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);
            return RedirectToPage(PageNames.PropertyPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('BackToPropertyList',ex);
        }  
        finally
        {
            lstParameters =  null;
        }             
    }
}