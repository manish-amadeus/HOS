/***********************************************************************************************
Name            : AH_PLCM_MM_Function_Room
Author          : Sanjay
Created Date    : 01-July-2020
Last Mod Date   : 01-July-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for  Room Capacities Page
************************************************************************************************/
public class AH_PLCM_MM_Room_Capacities extends AH_PLCM_MM_Common_Class {
    public class FileWrapper {
        public Id Id { get; set; }
        public Id ContentDocumentId { get; set; }
        public String Name { get; set; }
        public String Type { get; set; }
        public String DownloadUrl { get; set; }
        public String UploadedOn { get; set; }
    }

    public NI_Documentation__c objNIDoc { get; set; }
    public AH_PLCM_MM_Seating_Capacity__c objDefaultValues { get; set; }
    public AH_PLCM_MM_Seating_Capacity__c objUpdatedValues { get; set; }
    public List<FileWrapper> lstFiles { get; set; }
    public Blob file { get; set; }
    public String fileName { get; set; }
    public String contentType { get; set; }
    public String FileIdToDelete { get; set; }
    public AH_PLCM_MM_Room_Capacities() {
        List<AH_PLCM_MM_Seating_Capacity__c> lstRoomCapacities = null;
        try {
            //Get NI Docdetails
            GetNIDocDettails();
            
            //Fill already uploaded files in list
            FillFileList();

            //Get Amadeus Default Standard Room Capacities Values
            objDefaultValues = GetDefaultRoomCapacityValues();
    
            //Get already inserted room capacities values
            lstRoomCapacities = new List<AH_PLCM_MM_Seating_Capacity__c>([SELECT Id, MM_NI_Doc_Record__c, Name, Accept_AHD_Default_Standard__c, MM_THE_Center_Aisle_s_quantity__c, MM_THE_Center_Aisle_s_Width__c, MM_THE_Cross_Aisle_s_quantity__c, MM_THE_Cross_Aisle_s_Width__c, MM_THE_Default_Chair_Size_Length__c, MM_THE_Default_Chair_Size_Width__c, MM_THE_Distance_Between_Chairs__c, MM_THE_Distance_Between_Rows_of_Chairs__c, MM_THC_Center_Aisle_s_quantity__c, MM_THC_Center_Aisle_s_Width__c, MM_THC_Cross_Aisle_s_quantity__c, MM_THC_Cross_Aisle_s_Width__c, MM_THC_Default_Chair_Size_Length__c, MM_THC_Default_Chair_Size_Width__c, MM_THC_Distance_Between_Chairs__c, MM_THC_Distance_Between_Rows_of_Chairs__c, MM_CLA_Center_Aisle_s_quantity__c, MM_CLA_Center_Aisle_s_Width__c, MM_CLA_Cross_Aisle_s_quantity__c, MM_CLA_Cross_Aisle_s_Width__c, MM_CLA_Distance_Between_Rows_of_Tables__c, MM_CLA_Distance_Between_Tables__c, MM_CLA_Default_Table_Size_Length__c, MM_CLA_Default_Table_Size_Width__c, MM_CLA_Default_Chair_Size_Length__c, MM_CLA_Default_Chair_Size_Width__c, MM_CLA_Seats_per_Table__c, MM_CLC_Center_Aisle_s_quantity__c, MM_CLC_Center_Aisle_s_Width__c, MM_CLC_Cross_Aisle_s_quantity__c, MM_CLC_Cross_Aisle_s_Width__c, MM_CLC_Distance_Between_Rows_of_Tables__c, MM_CLC_Distance_Between_Tables__c, MM_CLC_Default_Table_Size_Length__c, MM_CLC_Default_Table_Size_Width__c, MM_CLC_Default_Chair_Size_Length__c, MM_CLC_Default_Chair_Size_Width__c, MM_CLC_Seats_per_Table__c, MM_BAN_Center_Aisle_s_quantity__c, MM_BAN_Center_Aisle_s_Width__c, MM_BAN_Cross_Aisle_s_quantity__c, MM_BAN_Cross_Aisle_s_Width__c, MM_BAN_Distance_Between_Rows_of_Tables__c, MM_BAN_Distance_Between_Tables__c, MM_BAN_Default_Table_Size_Width__c, MM_BAN_Default_Chair_Size_Length__c, MM_BAN_Default_Chair_Size_Width__c, MM_BAN_Seats_per_Table__c, MM_BAS_Center_Aisle_s_quantity__c, MM_BAS_Center_Aisle_s_Width__c, MM_BAS_Cross_Aisle_s_quantity__c, MM_BAS_Cross_Aisle_s_Width__c, MM_BAS_Distance_Between_Rows_of_Tables__c, MM_BAS_Distance_Between_Tables__c, MM_BAS_Default_Table_Size_Width__c, MM_BAS_Default_Chair_Size_Length__c, MM_BAS_Default_Chair_Size_Width__c, MM_BAS_Seats_per_Table__c, MM_CON_Default_Table_Size_Length__c, MM_CON_Default_Table_Size_Width__c, MM_CON_Default_Chair_Size_Length__c, MM_CON_Default_Chair_Size_Width__c, MM_CON_Seats_per_Table__c, MM_USH_Default_Table_Size_Length__c, MM_USH_Default_Table_Size_Width__c, MM_USH_Default_Chair_Size_Length__c, MM_USH_Default_Chair_Size_Width__c, MM_USH_Seats_per_Table__c, MM_HSQ_Default_Table_Size_Length__c, MM_HSQ_Default_Table_Size_Width__c, MM_HSQ_Default_Chair_Size_Length__c, MM_HSQ_Default_Chair_Size_Width__c, MM_HSQ_Seats_per_Table__c, MM_REC_Room_Total_Length__c, MM_REC_Room_Total_Width__c FROM AH_PLCM_MM_Seating_Capacity__c WHERE MM_NI_Doc_Record__c =: ProjectId]);
            if(lstRoomCapacities != null && lstRoomCapacities.size() > 0) {
                objUpdatedValues = lstRoomCapacities.get(0);
            }
            else {
                objUpdatedValues = new AH_PLCM_MM_Seating_Capacity__c();
            }
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            //Redirect to error page
            //RedirectToErrorPage('Constructor', ex);
        }
        finally {
            lstRoomCapacities = null;
        }
    }
    
    //Get NI Deco details based on PojectId
    public void GetNIDocDettails() {
        List<NI_Documentation__c> lstNIDocs = null;
        try {
            lstNIdocs = new List<NI_Documentation__c>([SELECT Document_Name__c, AH_PLCM_MM_Maximum_Capacity_Option__c FROM NI_Documentation__c WHERE Id =: ProjectId]);
            if(lstNIdocs != null && lstNIdocs.size() > 0) {
                objNIDoc = lstNIdocs.get(0);
            }
            else {
                objNIDoc = new NI_Documentation__c();
            }
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            lstNIDocs = null;
        }
    }
    
    //Fill files list based on NI Doc
    public void FillFileList() {
        List<ContentDocumentLink> lstContentDocumentLinks = null;
        List<ContentVersion> lstContentVersions = null;
        List<ContentDistribution> lstContentDistributions = null;
        List<Id> lstContentDocIds = null;
        try {
            //Initialize filse list
            lstFiles = new List<FileWrapper>();
        
            //Get content document id list by NI Doc Id
            lstContentDocumentLinks = new List<ContentDocumentLink>([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: ProjectId]);
            
            if(lstContentDocumentLinks != null && lstContentDocumentLinks.size() > 0) {
                lstContentDocIds = new List<Id>();
                for(ContentDocumentLink docLink : lstContentDocumentLinks) {
                    lstContentDocIds.add(docLink.ContentDocumentId);
                }

                //Get files details based on ContentDocumentId
                lstContentVersions = new List<ContentVersion>([SELECT Id, ContentDocumentId, Title, FileType, FileExtension, CreatedDate FROM ContentVersion WHERE ContentDocumentId IN : lstContentDocIds AND Title LIKE 'Room Capacity Diagram %' ORDER BY CreatedDate DESC]);
                
                if(lstContentVersions != null && lstContentVersions.size() > 0) {
                    //Get file download details based on ContentVersionId
                    lstContentDistributions = new List<ContentDistribution>([SELECT Id, ContentVersionId, ContentDownloadUrl FROM ContentDistribution WHERE ContentVersionId IN : lstContentVersions]);
                    
                    for(ContentVersion cv : lstContentVersions) {
                        for(ContentDistribution cd : lstContentDistributions) {
                            if(cd.ContentVersionId == cv.Id) {
                                FileWrapper file = new FileWrapper();
                                file.Id = cv.Id;
                                file.ContentDocumentId = cv.ContentDocumentId;
                                file.Name = cv.Title;
                                file.Type = cv.FileType;
                                file.DownloadUrl = cd.ContentDownloadUrl;
                                file.UploadedOn = cv.CreatedDate.formatGMT('EEEE d MMMM yyyy HH:mm a');
                                lstFiles.add(file);
                            }
                        }
                    }
                }
            }
        }
        catch(Exception ex) {
            lstFiles = new List<FileWrapper>();
            throw ex;
        }
        finally {
            lstContentDocumentLinks = null;
            lstContentVersions = null;
            lstContentDistributions = null;
            lstContentDocIds = null;
        }
    }
    
    //Upload selected file
    public PageReference UploadFile() {
        String strFileName = '', strFileType = '';
        try {
            //Get latest Bubble Help text flag values                   
            SetVariablesValue();

            //Get dynamic file name based on total uploaded files
            strFileName = GetFileName();
            
            //Set file type
            strFileType = GetFileType(fileName);
            
            //Upload file
            SaveFile(ProjectId, strFileName + '.' + strFileType, file);
            
            //Update files list to inlude uploaded files
            FillFileList();
            
            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'File uploaded successfully!!'));
            return null;
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            //Redirect to error page
            //RedirectToErrorPage('UploadFile', ex);
            return null;
        }
        finally {
            strFileName = null;
            strFileType = null;
        }
    }
    
    //Get file name based on total file uploaded
    public String GetFileName() {
        List<ContentDocumentLink> lstContentDocumentLinks = null;
        List<ContentVersion> lstContentVersions = null;
        List<Id> lstContentDocIds = null;
        integer fileCount = 0;
        try {
            //Get content document id list by NI Doc Id
            lstContentDocumentLinks = new List<ContentDocumentLink>([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: ProjectId]);
            
            if(lstContentDocumentLinks != null && lstContentDocumentLinks.size() > 0) {
                lstContentDocIds = new List<Id>();
                for(ContentDocumentLink docLink : lstContentDocumentLinks) {
                    lstContentDocIds.add(docLink.ContentDocumentId);
                }

                //Get files details based on ContentDocumentId
                lstContentVersions = new List<ContentVersion>([SELECT Id, Title FROM ContentVersion WHERE ContentDocumentId IN : lstContentDocIds AND Title LIKE 'Room Capacity Diagram %' ORDER BY CreatedDate DESC]);
                if(lstContentVersions != null && lstContentVersions.size() > 0 && !String.IsBlank(lstContentVersions.get(0).Title)) {
                    String[] arr = lstContentVersions.get(0).Title.split(' '); //For example Room Capacity Diagram 1.xls
                    if(arr != null && arr.size() > 0) {
                        String[] arr2 = arr[arr.size() - 1].split('\\.'); //For Example 1.xls
                        if(arr2 != null && arr2.size() > 0 && arr2[0].isNumeric()) {
                            fileCount = integer.valueOf(arr2[0]);
                        }
                    }
                }
            }

            return 'Room Capacity Diagram ' + (fileCount + 1);
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            lstContentDocumentLinks = null;
            lstContentVersions = null;
            lstContentDocIds = null;
        }
    }
    
    //Get file extension
    public String GetFileType(String strFileName) {
        String[] arr = null;
        try {
            if(!String.IsBlank(strFileName)) {
                arr = strFileName.split('\\.');
                if(arr != null && arr.size() > 0) {
                    return arr[arr.size() - 1];
                }
            }
            return '';
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            arr = null;
        }
    }
    
    //Delete file by Id
    public void DeleteFile() {
        List<ContentDocument> lstDeletedFiles = null;
        try {
            //Get latest Bubble Help text flag values                   
            SetVariablesValue();
        
            lstDeletedFiles = new List<ContentDocument>([SELECT Id FROM ContentDocument WHERE Id =: FileIdToDelete]);
            delete lstDeletedFiles;
            
            //Update files list to remove deleted files
            FillFileList();

            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'File deleted successfully!!'));
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
            //Redirect to error page
            //RedirectToErrorPage('UploadFile', ex);
        }
        finally {
            lstDeletedFiles = null;
        }
    }
    
    //Click on Save button
    public void SaveData() {
        try {
            //Get latest Bubble Help text flag values                   
            SetVariablesValue();

            update objNIDoc; //Update selected option in NIDocumentation__c object
            update objUpdatedValues; //Update room capacities values

            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Room capacity values has been saved successfully!!'));
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
    }
    
    //Click on Confirm & Next button
    public PageReference ConfirmAndNext() {
        Map<string, string> lstParameters = null;
        try {
            if(!ProjectPortalStatus.IsInventoryInformationProvided) {
                //Save room capacities values
                SaveData();
            }

            if(!ProjectPortalStatus.IsRoomCapacityInformationProvided) {
                //Update portal status
                UpdatePortalStatus(ProjectPortalStatus.RoomCapacityInformationProvided);
            }
            //Set query string value
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);

            //Redirect to Inventory Page
            return RedirectToPage(PageNames.InventoryPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('FunctionRoomPage', ex);
        }
        finally {
            lstParameters = null;
        }
    }

    //Go back to function room page on click of back button
    public PageReference BackToFunctionRoomPage() {
        Map<string, string> lstParameters = null;
        try {
            //Set query string value
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);

            //Redirect Back to Welcome Page
            return RedirectToPage(PageNames.FunctionRoomPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('FunctionRoomPage', ex);
        }
        finally {
            lstParameters = null;
        }
    }
}