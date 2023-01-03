/***********************************************************************************************
Name            : AH_PLCM_Property
Author          : Sanjay Parmar
Created Date    : 21-May-2019
Last Mod Date   : 21-May-2019
Last Mod By     : Sanjay Parmar
NICC Reference  : 
Description     : Class for Property page
************************************************************************************************/
public class AH_PLCM_Property extends AH_PLCM_Common_Class {
    //Initialize Variables
    public List<AH_PLCM_Migration_Property__c> lstProperties { get; set; }
    
    public AH_PLCM_Property() {
        try {
            if(!String.IsBlank(ProjectId)) { //PropertyId's value set from common class
                //Get all properties for selected project
                lstProperties = new List<AH_PLCM_Migration_Property__c>([SELECT Id, Name, Site_Name__c, Property_State__c, Property_City__c, Property_Time_Zone__c, Property_Currency__c FROM AH_PLCM_Migration_Property__c WHERE NI_Doc_Record__c = :ProjectId AND IsActive__c = true ORDER BY Name]);
            }
            else {
                //Initialize to prevent null errors
                lstProperties = new List<AH_PLCM_Migration_Property__c>();
            }
        }
        catch(Exception ex) {
            //set error variable to redirect at error page
            IsErrorOccurred = true;
        }
    }
    
    //Action being called on click of confirm and next button
    public PageReference ConfirmAndNext() {
        Map<string, string> lstParameters = null;
        try {            
            if(!String.IsBlank(ProjectId)) {
                if(ProjectPortalStatus.IsPropertyUpdated == false) {
                    //Update Property Details
                    UpdatePropertyDetails();
                    
                    //Generate users data for properties
                    GenerateUsersData();
                    
                    //Update Project Portal Status
                    UpdatePortalStatus(ProjectPortalStatus.PropertyUpdated);
                }

                //Redirect to Create Users Page
                lstParameters = new Map<string, string>();
                lstParameters.put('ProjectId', ProjectId);
                return RedirectToPage(PageNames.CreateUserPage, lstParameters);
            }
            return null;
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('ConfirmAndNext',ex);
        }
        finally {
            //Release object's memory
            lstParameters = null;
        }
    }
    
    //Update property details such as currency and timezone
    public void UpdatePropertyDetails() {
        try {     
            //Get latest Buuble Help text flag values                   
            SetVariablesValue();

            if (lstProperties.Size() > 0) {
                //Update Property Details
                update lstProperties;
            }
        }
        catch(Exception ex) {
            //Redirect to error page
            RedirectToErrorPage('UpdatePropertyDetails',ex);
        }
    }

    //Fetch users for properties and insert into mapping object
    public void GenerateUsersData() {
        List<AH_PLCM_MigrationUser_Mapping__c> lstUsersData = null;
        AH_PLCM_MigrationUser_Mapping__c objUser = null;
        try {
            //Check for existing records (Do not generate data if already generated)
            long total = [SELECT COUNT() FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = :ProjectId];

            if(total == 0) {
                //Get user details based on properties of selected project
                AggregateResult[] results = [SELECT Name, User_Email_Address__c, SUM(TotalTasks__c) TotalTasks__c, SUM(TotalEvents__c) TotalEvents__c, SUM(TotalBookings__c) TotalBookings__c FROM AH_PLCM_Migration_User__c WHERE PLCM_Migration_Property__c IN : lstProperties AND IsActive__c = true GROUP BY Name, User_Email_Address__c];
                System.System.debug('result-'+ results);
                //Prepare list for users data
                lstUsersData = new List<AH_PLCM_MigrationUser_Mapping__c>();
                for (AggregateResult obj : results) {
                    objUser = new AH_PLCM_MigrationUser_Mapping__c();
                    objUser.PLCM_Migration_Project_Name__c = ProjectId;
                    objUser.Name = (string) obj.get('Name');
                    objUser.User_Email_Address__c = (string) obj.get('User_Email_Address__c');
                    objUser.IsActive__c = true;
                    objUser.TotalTasks__c = (Decimal) obj.get('TotalTasks__c');
                    objUser.TotalEvents__c = (Decimal) obj.get('TotalEvents__c');
                    objUser.TotalBookings__c = (Decimal) obj.get('TotalBookings__c');
                    lstUsersData.add(objUser);
                }
                
                if(lstUsersData.size() > 0) {
                    //Insert data in salesforceobject AH_PLCM_MigrationUser_Mapping__c
                    insert lstUsersData;
                }
            }
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            //Release memory of unused objects
            lstUsersData = null;
            objUser = null;
        }
    }
    
    //Go back to introduction page on click of back button
    public PageReference BackToIntroductionPage() {
        try {
            //Redirect Back to Introduction Page
            return RedirectToPage(PageNames.IntroductionPage, null);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('BackToIntroductionPage',ex);
        }        
    }
}