/***********************************************************************************************
Name            : AH_PLCM_MM_Inventory
Author          : Tushar Gupta
Created Date    : 10-July-2020
Last Mod Date   : 10-July-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for  Inventory Page
************************************************************************************************/
public class AH_PLCM_MM_Inventory extends AH_PLCM_MM_Common_Class {
    public AH_PLCM_MM_Inventory_Default_Wrapper defaultInventoryWrapper {get; set;}
    public AH_PLCM_MM_Inventory__c inventoryObj { get; set; }
   // public Blob file { get; set; }
  //  public String fileName { get; set; }
  //  public String contentType { get; set; }
    public AH_PLCM_MM_Inventory() {        
        //Get already inserted inventory
        List<AH_PLCM_MM_Inventory__c> inventory = [SELECT Id,MM_Chair_1_Description__c,MM_Chair_2_Is_Default__c,MM_Chair_1_Height__c,MM_Chair_1_Is_Default__c,MM_Chair_1_Is_Rental__c,MM_Chair_1_Length__c,MM_Chair_1_Width__c,MM_Chair_2_Description__c,MM_Chair_2_Height__c,MM_Chair_2_Is_Rental__c,MM_Chair_2_Length__c,MM_Chair_2_Width__c,MM_Chair_3_Description__c,MM_Chair_3_Height__c,MM_Chair_3_Is_Default__c,MM_Chair_3_Is_Rental__c,MM_Chair_3_Length__c,MM_Chair_3_Width__c,MM_Chair_4_Description__c,MM_Chair_4_Height__c,MM_Chair_4_Is_Default__c,MM_Chair_4_Is_Rental__c,MM_Chair_4_Length__c,MM_Chair_4_Width__c,MM_Conference_Chair_1_Description__c,MM_Conference_Chair_1_Height__c,MM_Conference_Chair_1_Is_Default__c,MM_Conference_Chair_1_Is_Rental__c,MM_Conference_Chair_1_Length__c,MM_Conference_Chair_1_Width__c,MM_Conference_Chair_2_Description__c,MM_Conference_Chair_2_Height__c,MM_Conference_Chair_2_Is_Default__c,MM_Conference_Chair_2_Is_Rental__c,MM_Conference_Chair_2_Length__c,MM_Conference_Chair_2_Width__c,MM_Conference_Chair_3_Description__c,MM_Conference_Chair_3_Height__c,MM_Conference_Chair_3_Is_Default__c,MM_Conference_Chair_3_Is_Rental__c,MM_Conference_Chair_3_Length__c,MM_Conference_Chair_3_Width__c,MM_Conference_Chair_4_Description__c,MM_Conference_Chair_4_Height__c,MM_Conference_Chair_4_Is_Default__c,MM_Conference_Chair_4_Is_Rental__c,MM_Conference_Chair_4_Length__c,MM_Conference_Chair_4_Width__c,MM_Dance_Floor_1_Description__c,MM_Dance_Floor_1_Is_Default__c,MM_Dance_Floor_1_Is_Rental__c,MM_Dance_Floor_1_Length__c,MM_Dance_Floor_1_Width__c,MM_Dance_Floor_2_Description__c,MM_Dance_Floor_2_Is_Default__c,MM_Dance_Floor_2_Is_Rental__c,MM_Dance_Floor_2_Length__c,MM_Dance_Floor_2_Width__c,MM_Reception_Description__c,MM_Reception_Length__c,MM_Reception_Width__c,MM_Rectangular_Table_1_Description__c,MM_Rectangular_Table_1_Height__c,MM_Rectangular_Table_1_Is_Default__c,MM_Rectangular_Table_1_Is_Rental__c,MM_Rectangular_Table_1_Length__c,MM_Rectangular_Table_1_Width__c,MM_Rectangular_Table_2_Description__c,MM_Rectangular_Table_2_Height__c,MM_Rectangular_Table_2_Is_Default__c,MM_Rectangular_Table_2_Is_Rental__c,MM_Rectangular_Table_2_Length__c,MM_Rectangular_Table_2_Width__c,MM_Rectangular_Table_3_Description__c,MM_Rectangular_Table_3_Height__c,MM_Rectangular_Table_3_Is_Default__c,MM_Rectangular_Table_3_Is_Rental__c,MM_Rectangular_Table_3_Length__c,MM_Rectangular_Table_3_Width__c,MM_Rectangular_Table_4_Description__c,MM_Rectangular_Table_4_Height__c,MM_Rectangular_Table_4_Is_Default__c,MM_Rectangular_Table_4_Is_Rental__c,MM_Rectangular_Table_4_Length__c,MM_Rectangular_Table_4_Width__c,MM_Riser_Stage_1_Description__c,MM_Riser_Stage_1_Height__c,MM_Riser_Stage_1_Is_Default__c,MM_Riser_Stage_1_Is_Rental__c,MM_Riser_Stage_1_Length__c,MM_Riser_Stage_1_Width__c,MM_Riser_Stage_2_Description__c,MM_Riser_Stage_2_Height__c,MM_Riser_Stage_2_Is_Default__c,MM_Riser_Stage_2_Is_Rental__c,MM_Riser_Stage_2_Length__c,MM_Riser_Stage_2_Width__c,MM_Round_Table_1_Description__c,MM_Round_Table_1_Height__c,MM_Round_Table_1_Is_Default__c,MM_Round_Table_1_Is_Rental__c,MM_Round_Table_1_Width__c,MM_Round_Table_2_Description__c,MM_Round_Table_2_Height__c,MM_Round_Table_2_Is_Default__c,MM_Round_Table_2_Is_Rental__c,MM_Round_Table_2_Width__c,MM_Round_Table_3_Description__c,MM_Round_Table_3_Height__c,MM_Round_Table_3_Is_Default__c,MM_Round_Table_3_Is_Rental__c,MM_Round_Table_3_Width__c,MM_Round_Table_4_Description__c,MM_Round_Table_4_Height__c,MM_Round_Table_4_Is_Default__c,MM_Round_Table_4_Is_Rental__c,MM_Round_Table_4_Width__c,MM_Square_Table_1_Description__c,MM_Square_Table_1_Height__c,MM_Square_Table_1_Is_Default__c,MM_Square_Table_1_Is_Rental__c,MM_Square_Table_1_Length__c,MM_Square_Table_1_Width__c,MM_Square_Table_2_Description__c,MM_Square_Table_2_Height__c,MM_Square_Table_2_Is_Default__c,MM_Square_Table_2_Is_Rental__c,MM_Square_Table_2_Length__c,MM_Square_Table_2_Width__c,MM_Square_Table_3_Description__c,MM_Square_Table_3_Height__c,MM_Square_Table_3_Is_Default__c,MM_Square_Table_3_Is_Rental__c,MM_Square_Table_3_Length__c,MM_Square_Table_3_Width__c,MM_Square_Table_4_Description__c,MM_Square_Table_4_Height__c,MM_Square_Table_4_Is_Default__c,MM_Square_Table_4_Is_Rental__c,MM_Square_Table_4_Length__c,MM_Square_Table_4_Width__c,Name,NI_Doc_Record__c FROM AH_PLCM_MM_Inventory__c WHERE NI_Doc_Record__c =: ProjectId];
        
        //Initialize default inventroy values object
        defaultInventoryWrapper = SetDefaultInventoryValue();

        if(inventory != null && inventory.Size() > 0) {
            inventoryObj = inventory.get(0);
            
            //Set amadeus defalut checkbox value
            setDefaultValue();
        }
        else {
            //Initialize inventory values object
            inventoryObj = new AH_PLCM_MM_Inventory__c();
        }
    }

    //Click on Save button
    public void SaveData() {
        try {
            //Get latest Bubble Help text flag values                   
            SetVariablesValue();

            //Set amadeus defalut checkbox value
            setDefaultValue();

            if(string.IsBlank(inventoryObj.Id)) {
                inventoryObj.Name = GetMMPropertyName();
                inventoryObj.NI_Doc_Record__c = ProjectId;
                insert inventoryObj;
            }
            else {
                update inventoryObj;
            }
    
            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Inventory data has been saved successfully!!'));
        }
        catch(Exception ex) {
            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
    }
    
    //Click on Confirm & Next button
    public PageReference ConfirmAndNext() {
        Map<string, string> lstParameters = null;
        try {
            if(!ProjectPortalStatus.IsInventoryInformationProvided){
                //Save inventory values
                SaveData();
                
                //Attach customer inputs workbook in NI Documentation Record
                AttachReport('All', 'Customer_Inputs_Report_' + ProjectId + '.xls');
                
                //Update portal status
                UpdatePortalStatus(ProjectPortalStatus.CustomerInputCompleted);
            }
            //Set query string value
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);

            //Redirect to Inventory Page
            return RedirectToPage(PageNames.ThankYouPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('InventoryPage', ex);
        }
        finally {
            lstParameters = null;
        }
    }
    
    //Go back to room capacities page on click of back button
    public PageReference BackToRoomCapacitiesPage() {
        Map<string, string> lstParameters = null;
        try {
            //Set query string value
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);

            //Redirect Back to Room Capacities Page
            return RedirectToPage(PageNames.RoomCapacitiesPage, lstParameters);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('RoomCapacitiesPage', ex);
        }
        finally {
            lstParameters = null;
        }
    }
    
    //Set default checkbox value
    public void setDefaultValue() {
        //CHAIR
        if(inventoryObj.MM_Chair_1_Is_Default__c || inventoryObj.MM_Chair_2_Is_Default__c || inventoryObj.MM_Chair_3_Is_Default__c || inventoryObj.MM_Chair_4_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Chair_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Chair_Is_Default = true;
        }

        //CONFERENCE CHAIR
        if(inventoryObj.MM_Conference_Chair_1_Is_Default__c || inventoryObj.MM_Conference_Chair_2_Is_Default__c || inventoryObj.MM_Conference_Chair_3_Is_Default__c || inventoryObj.MM_Conference_Chair_4_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Conference_Chair_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Conference_Chair_Is_Default = true;
        }

        //RECTANGULAR TABLE
        if(inventoryObj.MM_Rectangular_Table_1_Is_Default__c || inventoryObj.MM_Rectangular_Table_2_Is_Default__c || inventoryObj.MM_Rectangular_Table_3_Is_Default__c || inventoryObj.MM_Rectangular_Table_4_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Rectangular_Table_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Rectangular_Table_Is_Default = true;
        }
        
        //SQUARE TABLE
        if(inventoryObj.MM_Square_Table_1_Is_Default__c || inventoryObj.MM_Square_Table_2_Is_Default__c || inventoryObj.MM_Square_Table_3_Is_Default__c || inventoryObj.MM_Square_Table_4_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Square_Table_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Square_Table_Is_Default = true;
        }
        
        //ROUND TABLE
        if(inventoryObj.MM_Round_Table_1_Is_Default__c || inventoryObj.MM_Round_Table_2_Is_Default__c || inventoryObj.MM_Round_Table_3_Is_Default__c || inventoryObj.MM_Round_Table_4_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Round_Table_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Round_Table_Is_Default = true;
        }
        
        //RISER/STAGE
        if(inventoryObj.MM_Riser_Stage_1_Is_Default__c || inventoryObj.MM_Riser_Stage_2_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Riser_Stage_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Riser_Stage_Is_Default = true;
        }

        //DANCE FLOOR
        if(inventoryObj.MM_Dance_Floor_1_Is_Default__c || inventoryObj.MM_Dance_Floor_2_Is_Default__c) {
            defaultInventoryWrapper.MM_Default_Dance_Floor_Is_Default = false;
        }
        else {
            defaultInventoryWrapper.MM_Default_Dance_Floor_Is_Default = true;
        }
    }
    
    //Attach Meeting Matrix report to NI Documentation record
    private void AttachReport(string strRecordType, string strFileName) {
        PageReference pageRef = null;
        try {
            //Call export report page to get file content
            pageRef = new PageReference('/apex/AH_PLCM_MM_Export_Excel_' + strRecordType);

            //Add require parameters in page request
            pageRef.getParameters().put('ProjectId', ProjectId);
            pageRef.getParameters().put('RecordType', strRecordType);
            pageRef.getParameters().put('ReportType', 'xls');

            if (Test.IsRunningTest()){ 
                SaveFile(ProjectId, strFileName, Blob.valueOf('TEST'));
            } else {
                //Insert file in salesforce standard object
                SaveFile(ProjectId, strFileName, pageRef.getContent());
            }
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