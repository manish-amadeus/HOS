public class AH_PLCM_User_Xref extends AH_PLCM_Common_Class {
    //Initialize Variables
    public List<AH_PLCM_MigrationUser_Mapping__c> lstUsers { get; set; }
    public List<SelectOption> ddlUsers { get; set; }
    public List<SelectOption> ddlUserNames { get; set; }
    public List<SelectOption> ddlUserProperties { get; set; }
    public List<SelectOption> ddlSalesforceUsers { get; set; }
    public List<SelectOption> ddlSalesforceUserEmails { get; set; }
    public string SalesforceUserEmail { get; set; }

    public AH_PLCM_User_Xref() {
        try {
            if(!String.IsBlank(ProjectId)){           
                //Get User List
                lstUsers = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, MappedTo_User__c, MappedTo_User_Name__c, MappedTo_User_Property__c, MappedTo_PLCM_TargetOrg_User__c FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId AND (New_User__c = true OR TotalTasks__c > 0 OR TotalEvents__c > 0 OR TotalBookings__c > 0) ORDER BY Name, User_Email_Address__c]);
                
                for(AH_PLCM_MigrationUser_Mapping__c obj : lstUsers) {
                    if(obj.New_User__c && String.IsBlank(obj.MappedTo_User__c)) {
                        //Map new users with own
                        obj.MappedTo_User__c = obj.Id;
                    }
                }

                //Prepare List for Drop Downs
                FillListForDropDowns();
            }
        }
        catch(Exception ex) {
            //set error variable to redirect at error page
            IsErrorOccurred = true;
        }
    }

    //Fill dron down values for new users and existing users
    private void FillListForDropDowns() {
        List<AH_PLCM_MigrationUser_Mapping__c> lstMigrationUsers = null;
        List<AH_PLCM_TargetOrg_User__c> lstSalesforceUsers = null;
        try {                
            //Prepare List For User Drop Down
            ddlUsers = new List<SelectOption>();
            ddlUserNames = new List<SelectOption>();
            ddlUserProperties = new List<SelectOption>();
            
            //Add defualt option none
            ddlUsers.add(new SelectOption('', '--None--'));
            ddlUserNames.add(new SelectOption('', ''));
            ddlUserProperties.add(new SelectOption('', ''));
            
            //Get Users for Drop Down
            lstMigrationUsers = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, PLCM_Migration_Property_Assignment__r.Name FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId AND New_User__c = true ORDER BY Name]);

            if(lstMigrationUsers != null && lstMigrationUsers.size() > 0) {
                for(AH_PLCM_MigrationUser_Mapping__c obj : lstMigrationUsers) {
                    ddlUsers.add(new SelectOption(obj.Id, obj.Name));
                    ddlUserNames.add(new SelectOption(obj.Name, obj.Id));
                    //ddlUserProperties.add(new SelectOption(obj.PLCM_Migration_Property_Assignment__r.Name, obj.Id));
                }
            }
                
            //Prepare List For Target User Drop Down
            ddlSalesforceUsers = new List<SelectOption>();
            ddlSalesforceUsers.add(new SelectOption('', '--None--'));

            //Prepare list for email drop down (It will not display but only for showing email on target user selection)
            ddlSalesforceUserEmails = new List<SelectOption>();
            ddlSalesforceUserEmails.add(new SelectOption('', ''));

            //Get Salesforce Users for Drop Down
            lstSalesforceUsers = new List<AH_PLCM_TargetOrg_User__c>([SELECT Id, Name, User_Email_Address__c FROM AH_PLCM_TargetOrg_User__c WHERE PLCM_Migration_Project_Name__c = : ProjectId ORDER BY Name]);

            if(lstSalesforceUsers != null && lstSalesforceUsers.size() > 0) {
                for(AH_PLCM_TargetOrg_User__c obj : lstSalesforceUsers) {
                    ddlSalesforceUsers.add(new SelectOption(obj.Id, obj.Name));
                    ddlSalesforceUserEmails.add(new SelectOption(obj.Id, obj.User_Email_Address__c));
                }
            }
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            //Release memory of objects
            lstMigrationUsers = null;
            lstSalesforceUsers = null;
        }
    }
    
    //Go back to create user page on click of back button
    public PageReference BackToCreateUserPage() {
        Map<string, string> lstParameters = null;
        try {
            //Redirect Back to Users Selection Page
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);
            return RedirectToPage(PageNames.CreateUserPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('BackToCreateUserPage',ex);
        }
        finally {
            //Release memory of objects
            lstParameters = null;
        }
    }
    
    //Save User Cross Reference Mapping Data
    public void SaveXrefData() {
        try {
            //Get latest Buuble Help text flag values                   
            SetVariablesValue();
            
            if(ProjectPortalStatus.IsXrefCompleted == false && lstUsers.Size() > 0) {
                //Update Users Details
                update lstUsers;
            }
        }
        catch(Exception ex) {
            //Redirect to error page
            RedirectToErrorPage('SaveXrefData',ex);
        }
    }
    
    //Save data and redirect to thank you page on click of confirm button
    public PageReference ConfirmAndSubmit() {
        Map<string, string> lstParameters = null;
        try {
            if(!String.IsBlank(ProjectId) && ProjectPortalStatus.IsXrefCompleted == false) {
                //Update Project Portal Status
                UpdatePortalStatus(ProjectPortalStatus.XrefCompleted);

                //Attach customer inputs workbook in NI Documentation Record
                AttachReport('All', 'Customer_Inputs_Report_' + ProjectId + '.xls');

                //Get project portal status values
                List<NI_Documentation__c> lstProjects = new List<NI_Documentation__c>([SELECT AH_PLCM_Portal_Progress__c, AH_PLCM_MigrationProgress__c FROM NI_Documentation__c WHERE Id = :ProjectId]);
                if(lstProjects.size() > 0) {
                    //Update Completed Status
                    lstProjects[0].AH_PLCM_Portal_Progress__c = ProjectPortalStatus.CustomerInputCompleted;
                    lstProjects[0].AH_PLCM_MigrationProgress__c = ProjectPortalStatus.CustomerInputCompleted;
                    update lstProjects;
                }
            }

            //Redirect to Thank You Page
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);
            return RedirectToPage(PageNames.ThankYouPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('ConfirmAndSubmit',ex);
        }
        finally {
            //Release memory of objects
            lstParameters = null;
        }
    }

    //Attach user cross reference report to NI Documentation record
    private void AttachReport(string strRecordType, string strFileName) {
        PageReference pageRef = null;
        try {
            //Call export report page to get file content
            pageRef = new PageReference('/apex/AH_PLCM_Export_Excel_' + strRecordType);

            //Add require parameters in page request
            pageRef.getParameters().put('ProjectId', ProjectId);
            pageRef.getParameters().put('RecordType', strRecordType);
            pageRef.getParameters().put('ReportType', 'xls');
            pageRef.getParameters().put('includealluser', 'y');

            //Insert file in salesforce standard object
            SaveFile(ProjectId, strFileName, pageRef.getContent());
        }
        catch(Exception ex) {
            System.System.debug('AttachReport' + ex);
            throw ex;
        }
        finally {
            //Release memory of objects
            pageRef = null;
        }
    }
}