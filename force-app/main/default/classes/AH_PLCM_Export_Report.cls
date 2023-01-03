/***********************************************************************************************
Name            : AH_PLCM_Export_Report
Author          : Umang Ankleshwaria
Created Date    : 24-May-2019
Last Mod Date   : 24-May-2019
Last Mod By     : Umang Ankleshwaria
NICC Reference  : 
Description     : Apex class for Export Report page
************************************************************************************************/
public class AH_PLCM_Export_Report extends AH_PLCM_Common_Class {
    //Initialize Variables
    public List<AH_PLCM_Migration_Property__c> lstExportProperties { get; set; }
    public List<AH_PLCM_MigrationUser_Mapping__c> lstExportUsers { get; set; }
    public List<AH_PLCM_MigrationUser_Mapping__c> lstExportCreateUsers { get; set; }
    public List<AH_PLCM_MigrationUser_Mapping__c> lstExportUserXrefs { get; set; }
    public string ContentType { get; set; }
    public string RenderAs { get; set; }
    public string RecordType { get; set; }
    public string TargetOrgCorpAdmin { get; set; }
    public string TargetOrgCorpAdminEmail { get; set; }
    public Decimal totalAvailableLicences{get; set;}
    public string FlagIncludeAllUser {get; set;}
    public boolean IsNiDoc {get;set;}
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public AH_PLCM_Export_Report() {
        try {
            string ReportType = '', FileName = '';
            
            // set default value as false
            IsNiDoc = false;
            //Get Record Type from Parameters
            RecordType = GetParameterValue('RecordType').toLowerCase();

            //Get Report Type Pdf Or Excel from Parameters
            ReportType = GetParameterValue('ReportType').toLowerCase();

            // Set default target org admin as null
            TargetOrgCorpAdmin = null;

            //Set default count value 0
            totalAvailableLicences=0;

            if(!String.IsBlank(RecordType)) {
                
                //set file name
                switch on RecordType {
                    when 'properties' {
                        FileName = 'Property_Information_Report_' + ProjectId; //Example : Property Information Report.xls/pdf
                    }
                    when 'users' {
                        FileName = 'Create_Users_for_Migration_Report_' + ProjectId;
                    }
                    when 'xref' {
                        FileName = 'Transfer_User_Records_Report_' + ProjectId;
                    }
                    when 'all' {
                        FileName = 'Customer_Inputs_Report_' + ProjectId;
                    }
                }

                if(ReportType == 'pdf') {
                    RenderAs = 'pdf';
                    ContentType = 'application/x-pdf';
                    ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + FileName + '.pdf');
                }
                else {
                    //ContentType = 'application/vnd.ms-excel#' + FileName + '.xls';
                    ContentType = 'txt/xml#' + FileName + '.xls';
                }
            }

            if(!String.IsBlank(ProjectId) && !String.IsBlank(RecordType)) {                 
                //Get Users list for Drop Down hide
                List<NI_Documentation__c> lstNIDocDetails = new List<NI_Documentation__c>([select AH_PLCM_Total_Available_Licenses__c from NI_Documentation__c where Id=: ProjectId]);
                if(lstNIDocDetails!=null && lstNIDocDetails.Size()>0){
                    if(lstNIDocDetails.get(0).AH_PLCM_Total_Available_Licenses__c != null) {
                        totalAvailableLicences = lstNIDocDetails.get(0).AH_PLCM_Total_Available_Licenses__c;
                    }
                    else {
                        totalAvailableLicences = 0;
                    }
                }
                switch on RecordType {
                    when 'properties' {
                        //Get All Properties
                        lstExportProperties = new List<AH_PLCM_Migration_Property__c>([SELECT Id, Database_Name__c, Name, Site_Name__c, Property_State__c, Property_City__c, Property_Time_Zone__c, Property_Currency__c FROM AH_PLCM_Migration_Property__c WHERE NI_Doc_Record__c=:ProjectId ORDER BY Name]);
                    }
                    when 'users' {
                        //Get All Users
                        lstExportCreateUsers = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, PLCM_Migration_Property_Assignment__r.Name FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId ORDER BY Name]);
                    }
                    when 'xref' {
                        //Get Users Mapping
                        lstExportUserXrefs = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, PLCM_Migration_Property_Assignment__r.Name, MappedTo_User_Name__c, MappedTo_User_Property__c, MappedTo_PLCM_TargetOrg_User__r.Name, MappedTo_PLCM_TargetOrg_User__r.User_Email_Address__c FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId AND (New_User__c = true OR TotalTasks__c > 0 OR TotalEvents__c > 0 OR TotalBookings__c > 0) ORDER BY Name]);
                    }
                    when 'all' {
                        //Get All Properties
                        lstExportProperties = new List<AH_PLCM_Migration_Property__c>([SELECT Id, Database_Name__c, Name, Site_Name__c, Property_State__c, Property_City__c, Property_Time_Zone__c, Property_Currency__c FROM AH_PLCM_Migration_Property__c WHERE NI_Doc_Record__c=:ProjectId ORDER BY Name]);

                        //Get All Users
                        lstExportCreateUsers = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, PLCM_Migration_Property_Assignment__r.Name FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId ORDER BY Name]);
                        

                        //Check if need to include all users with count and without count of boooking, event and task
                        FlagIncludeAllUser = GetParameterValue('includealluser').toLowerCase();
                        
                        if(FlagIncludeAllUser == 'y') {
                            IsNiDoc = true;
                            List<NI_Documentation__c> lstNiDoc =  new List<NI_Documentation__c>([SELECT Target_Org_Corp_Admin__r.Name from NI_Documentation__c where Id =: ProjectId]);
                            if(lstNiDoc != null && lstNiDoc.Size() > 0) {
                                List<Contact> lstContact = new List<Contact>([select Name, Email from Contact where Id =: lstNiDoc[0].Target_Org_Corp_Admin__c]);
                                if(lstContact != null && lstContact.Size() > 0){
                                    TargetOrgCorpAdmin = lstContact[0].Name;
                                    TargetOrgCorpAdminEmail = lstContact[0].Email;
                                }
                            }
                            lstExportUserXrefs = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, PLCM_Migration_Property_Assignment__r.Name, MappedTo_User_Name__c, MappedTo_User_Property__c, MappedTo_PLCM_TargetOrg_User__r.Name, MappedTo_PLCM_TargetOrg_User__r.User_Email_Address__c, TotalTasks__c, TotalEvents__c, TotalBookings__c FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId ORDER BY Name]);
                        } else {
                            //Get Users Mapping
                            lstExportUserXrefs = new List<AH_PLCM_MigrationUser_Mapping__c>([SELECT Id, Name, User_Email_Address__c, New_User__c, PLCM_Migration_Property_Assignment__r.Name, MappedTo_User_Name__c, MappedTo_User_Property__c, MappedTo_PLCM_TargetOrg_User__r.Name, MappedTo_PLCM_TargetOrg_User__r.User_Email_Address__c, TotalTasks__c, TotalEvents__c, TotalBookings__c FROM AH_PLCM_MigrationUser_Mapping__c WHERE PLCM_Migration_Project_Name__c = : ProjectId AND (New_User__c = true OR TotalTasks__c > 0 OR TotalEvents__c > 0 OR TotalBookings__c > 0) ORDER BY Name]);
                        }
                    }
                }
            }        
        }
        catch(Exception ex) {
            throw ex;
        }        
    }
}