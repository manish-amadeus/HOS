/***********************************************************************************************
Name            : AH_PLCM_MM_Export_Report
Author          : Tushar Gupta
Created Date    : 24-June-2020
Last Mod Date   : 24-June-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Export Report page
************************************************************************************************/
public class AH_PLCM_MM_Export_Report extends AH_PLCM_MM_Common_Class {
    //Initialize Variables
    public List<AH_PLCM_MM_Room_Details__c> lstExportFunctionRoom { get; set; }
    public AH_PLCM_MM_Seating_Capacity__c objDefaultValues { get; set; }
    public AH_PLCM_MM_Seating_Capacity__c objUpdatedValues { get; set; }
    public AH_PLCM_MM_Inventory__c objExportInventory { get; set; }
    public string ContentType { get; set; }
    public string RenderAs { get; set; }
    public string RecordType { get; set; }
    public AH_PLCM_MM_Inventory_Default_Wrapper defaultInventoryWrapper {get; set;}
    public String xlsHeader {
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }

    public AH_PLCM_MM_Export_Report() {       
        // initialize the default inventroy value
        defaultInventoryWrapper = SetDefaultInventoryValue();
        String ReportType = '', FileName = '';
        try {
            //Get Record Type from Parameters
            RecordType = GetParameterValue('RecordType').toLowerCase();

            //Get Report Type Pdf Or Excel from Parameters
            ReportType = GetParameterValue('ReportType').toLowerCase();

            if(!String.IsBlank(RecordType)) {
                //Set file name
                switch on RecordType {
                    when 'functionroom' {
                        //Get function room list
                        lstExportFunctionRoom = new List<AH_PLCM_MM_Room_Details__c>([SELECT Id,MM_Ceiling_Height__c,MM_Floor_Plan_Level__c,MM_Is_Reception_Only__c,MM_Is_Seating_Orientation_Non_Std__c,MM_NI_Doc_Record__c,MM_Seating_Orientation_Details__c,MM_Source_Location__c,MM_Source_Type__c,MM_Square_Feet__c,Name,MM_Function_Room_Type__c FROM AH_PLCM_MM_Room_Details__c Where MM_NI_Doc_Record__c = : ProjectId ORDER BY Name]);
                        
                        //Set file name
                        FileName = 'Function_Room_Report_' + ProjectId;
                    }
                    when 'roomcapacities' {
                        //Get Amadeus Default Standard Room Capacities Values
                        objDefaultValues = GetDefaultRoomCapacityValues();

                        //Get Room Capacities list
                        GetRoomCapacity();
                        
                        //Set file name
                        FileName = 'Room_Capacity_Report_' + ProjectId;
                    }
                  when 'inventory' {
                        // Get inventory
                        GetInventory();
                        FileName = 'Inventory_Report_' + ProjectId;
                  }
                  when 'all' {
                        //Get function room list
                        lstExportFunctionRoom = new List<AH_PLCM_MM_Room_Details__c>([SELECT Id,MM_Ceiling_Height__c,MM_Floor_Plan_Level__c,MM_Is_Reception_Only__c,MM_Is_Seating_Orientation_Non_Std__c,MM_NI_Doc_Record__c,MM_Seating_Orientation_Details__c,MM_Source_Location__c,MM_Source_Type__c,MM_Square_Feet__c,Name,MM_Function_Room_Type__c FROM AH_PLCM_MM_Room_Details__c Where MM_NI_Doc_Record__c = : ProjectId ORDER BY Name]);
                      
                        //Get Amadeus Default Standard Room Capacities Values
                        objDefaultValues = GetDefaultRoomCapacityValues();

                        //Get Room Capacities list
                        GetRoomCapacity();

                        // Get inventory
                        GetInventory();
                        FileName = 'Customer_Inputs_Report_' + ProjectId;
                  }
                }

                if(ReportType == 'pdf') {
                    RenderAs = 'pdf';
                    ContentType = 'application/x-pdf';
                    ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + FileName + '.pdf');
                }
                else {
                    ContentType = 'application/vnd.ms-excel#' + FileName + '.xls';
                    //ContentType = 'txt/xml#' + FileName + '.xls';
                }
            }      
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            ReportType = null;
            FileName = null;
        }
    }
    
    private AH_PLCM_MM_Seating_Capacity__c GetRoomCapacity() {
       List<AH_PLCM_MM_Seating_Capacity__c> lstRoomCapacities = null;
        try {
            lstRoomCapacities = new List<AH_PLCM_MM_Seating_Capacity__c>([SELECT Id, MM_NI_Doc_Record__c, Name, Accept_AHD_Default_Standard__c, MM_THE_Center_Aisle_s_quantity__c, MM_THE_Center_Aisle_s_Width__c, MM_THE_Cross_Aisle_s_quantity__c, MM_THE_Cross_Aisle_s_Width__c, MM_THE_Default_Chair_Size_Length__c, MM_THE_Default_Chair_Size_Width__c, MM_THE_Distance_Between_Chairs__c, MM_THE_Distance_Between_Rows_of_Chairs__c, MM_THC_Center_Aisle_s_quantity__c, MM_THC_Center_Aisle_s_Width__c, MM_THC_Cross_Aisle_s_quantity__c, MM_THC_Cross_Aisle_s_Width__c, MM_THC_Default_Chair_Size_Length__c, MM_THC_Default_Chair_Size_Width__c, MM_THC_Distance_Between_Chairs__c, MM_THC_Distance_Between_Rows_of_Chairs__c, MM_CLA_Center_Aisle_s_quantity__c, MM_CLA_Center_Aisle_s_Width__c, MM_CLA_Cross_Aisle_s_quantity__c, MM_CLA_Cross_Aisle_s_Width__c, MM_CLA_Distance_Between_Rows_of_Tables__c, MM_CLA_Distance_Between_Tables__c, MM_CLA_Default_Table_Size_Length__c, MM_CLA_Default_Table_Size_Width__c, MM_CLA_Default_Chair_Size_Length__c, MM_CLA_Default_Chair_Size_Width__c, MM_CLA_Seats_per_Table__c, MM_CLC_Center_Aisle_s_quantity__c, MM_CLC_Center_Aisle_s_Width__c, MM_CLC_Cross_Aisle_s_quantity__c, MM_CLC_Cross_Aisle_s_Width__c, MM_CLC_Distance_Between_Rows_of_Tables__c, MM_CLC_Distance_Between_Tables__c, MM_CLC_Default_Table_Size_Length__c, MM_CLC_Default_Table_Size_Width__c, MM_CLC_Default_Chair_Size_Length__c, MM_CLC_Default_Chair_Size_Width__c, MM_CLC_Seats_per_Table__c, MM_BAN_Center_Aisle_s_quantity__c, MM_BAN_Center_Aisle_s_Width__c, MM_BAN_Cross_Aisle_s_quantity__c, MM_BAN_Cross_Aisle_s_Width__c, MM_BAN_Distance_Between_Rows_of_Tables__c, MM_BAN_Distance_Between_Tables__c, MM_BAN_Default_Table_Size_Width__c, MM_BAN_Default_Chair_Size_Length__c, MM_BAN_Default_Chair_Size_Width__c, MM_BAN_Seats_per_Table__c, MM_BAS_Center_Aisle_s_quantity__c, MM_BAS_Center_Aisle_s_Width__c, MM_BAS_Cross_Aisle_s_quantity__c, MM_BAS_Cross_Aisle_s_Width__c, MM_BAS_Distance_Between_Rows_of_Tables__c, MM_BAS_Distance_Between_Tables__c, MM_BAS_Default_Table_Size_Width__c, MM_BAS_Default_Chair_Size_Length__c, MM_BAS_Default_Chair_Size_Width__c, MM_BAS_Seats_per_Table__c, MM_CON_Default_Table_Size_Length__c, MM_CON_Default_Table_Size_Width__c, MM_CON_Default_Chair_Size_Length__c, MM_CON_Default_Chair_Size_Width__c, MM_CON_Seats_per_Table__c, MM_USH_Default_Table_Size_Length__c, MM_USH_Default_Table_Size_Width__c, MM_USH_Default_Chair_Size_Length__c, MM_USH_Default_Chair_Size_Width__c, MM_USH_Seats_per_Table__c, MM_HSQ_Default_Table_Size_Length__c, MM_HSQ_Default_Table_Size_Width__c, MM_HSQ_Default_Chair_Size_Length__c, MM_HSQ_Default_Chair_Size_Width__c, MM_HSQ_Seats_per_Table__c, MM_REC_Room_Total_Length__c, MM_REC_Room_Total_Width__c FROM AH_PLCM_MM_Seating_Capacity__c WHERE MM_NI_Doc_Record__c =: ProjectId]);
            if(lstRoomCapacities != null && lstRoomCapacities.size() > 0) {
                objUpdatedValues = lstRoomCapacities.get(0);
            }
            else {
                objUpdatedValues = new AH_PLCM_MM_Seating_Capacity__c();
            }
            return objUpdatedValues;
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            lstRoomCapacities = null;
        }
    }
    
    private AH_PLCM_MM_Inventory__c GetInventory() {
        List<AH_PLCM_MM_Inventory__c> lstInventory = null;
        try {
            lstInventory =new List<AH_PLCM_MM_Inventory__c>([SELECT Id,MM_Chair_1_Description__c,MM_Chair_2_Is_Default__c,MM_Chair_1_Height__c,MM_Chair_1_Is_Default__c,MM_Chair_1_Is_Rental__c,MM_Chair_1_Length__c,MM_Chair_1_Width__c,MM_Chair_2_Description__c,MM_Chair_2_Height__c,MM_Chair_2_Is_Rental__c,MM_Chair_2_Length__c,MM_Chair_2_Width__c,MM_Chair_3_Description__c,MM_Chair_3_Height__c,MM_Chair_3_Is_Default__c,MM_Chair_3_Is_Rental__c,MM_Chair_3_Length__c,MM_Chair_3_Width__c,MM_Chair_4_Description__c,MM_Chair_4_Height__c,MM_Chair_4_Is_Default__c,MM_Chair_4_Is_Rental__c,MM_Chair_4_Length__c,MM_Chair_4_Width__c,MM_Conference_Chair_1_Description__c,MM_Conference_Chair_1_Height__c,MM_Conference_Chair_1_Is_Default__c,MM_Conference_Chair_1_Is_Rental__c,MM_Conference_Chair_1_Length__c,MM_Conference_Chair_1_Width__c,MM_Conference_Chair_2_Description__c,MM_Conference_Chair_2_Height__c,MM_Conference_Chair_2_Is_Default__c,MM_Conference_Chair_2_Is_Rental__c,MM_Conference_Chair_2_Length__c,MM_Conference_Chair_2_Width__c,MM_Conference_Chair_3_Description__c,MM_Conference_Chair_3_Height__c,MM_Conference_Chair_3_Is_Default__c,MM_Conference_Chair_3_Is_Rental__c,MM_Conference_Chair_3_Length__c,MM_Conference_Chair_3_Width__c,MM_Conference_Chair_4_Description__c,MM_Conference_Chair_4_Height__c,MM_Conference_Chair_4_Is_Default__c,MM_Conference_Chair_4_Is_Rental__c,MM_Conference_Chair_4_Length__c,MM_Conference_Chair_4_Width__c,MM_Dance_Floor_1_Description__c,MM_Dance_Floor_1_Is_Default__c,MM_Dance_Floor_1_Is_Rental__c,MM_Dance_Floor_1_Length__c,MM_Dance_Floor_1_Width__c,MM_Dance_Floor_2_Description__c,MM_Dance_Floor_2_Is_Default__c,MM_Dance_Floor_2_Is_Rental__c,MM_Dance_Floor_2_Length__c,MM_Dance_Floor_2_Width__c,MM_Reception_Description__c,MM_Reception_Length__c,MM_Reception_Width__c,MM_Rectangular_Table_1_Description__c,MM_Rectangular_Table_1_Height__c,MM_Rectangular_Table_1_Is_Default__c,MM_Rectangular_Table_1_Is_Rental__c,MM_Rectangular_Table_1_Length__c,MM_Rectangular_Table_1_Width__c,MM_Rectangular_Table_2_Description__c,MM_Rectangular_Table_2_Height__c,MM_Rectangular_Table_2_Is_Default__c,MM_Rectangular_Table_2_Is_Rental__c,MM_Rectangular_Table_2_Length__c,MM_Rectangular_Table_2_Width__c,MM_Rectangular_Table_3_Description__c,MM_Rectangular_Table_3_Height__c,MM_Rectangular_Table_3_Is_Default__c,MM_Rectangular_Table_3_Is_Rental__c,MM_Rectangular_Table_3_Length__c,MM_Rectangular_Table_3_Width__c,MM_Rectangular_Table_4_Description__c,MM_Rectangular_Table_4_Height__c,MM_Rectangular_Table_4_Is_Default__c,MM_Rectangular_Table_4_Is_Rental__c,MM_Rectangular_Table_4_Length__c,MM_Rectangular_Table_4_Width__c,MM_Riser_Stage_1_Description__c,MM_Riser_Stage_1_Height__c,MM_Riser_Stage_1_Is_Default__c,MM_Riser_Stage_1_Is_Rental__c,MM_Riser_Stage_1_Length__c,MM_Riser_Stage_1_Width__c,MM_Riser_Stage_2_Description__c,MM_Riser_Stage_2_Height__c,MM_Riser_Stage_2_Is_Default__c,MM_Riser_Stage_2_Is_Rental__c,MM_Riser_Stage_2_Length__c,MM_Riser_Stage_2_Width__c,MM_Round_Table_1_Description__c,MM_Round_Table_1_Height__c,MM_Round_Table_1_Is_Default__c,MM_Round_Table_1_Is_Rental__c,MM_Round_Table_1_Width__c,MM_Round_Table_2_Description__c,MM_Round_Table_2_Height__c,MM_Round_Table_2_Is_Default__c,MM_Round_Table_2_Is_Rental__c,MM_Round_Table_2_Width__c,MM_Round_Table_3_Description__c,MM_Round_Table_3_Height__c,MM_Round_Table_3_Is_Default__c,MM_Round_Table_3_Is_Rental__c,MM_Round_Table_3_Width__c,MM_Round_Table_4_Description__c,MM_Round_Table_4_Height__c,MM_Round_Table_4_Is_Default__c,MM_Round_Table_4_Is_Rental__c,MM_Round_Table_4_Width__c,MM_Square_Table_1_Description__c,MM_Square_Table_1_Height__c,MM_Square_Table_1_Is_Default__c,MM_Square_Table_1_Is_Rental__c,MM_Square_Table_1_Length__c,MM_Square_Table_1_Width__c,MM_Square_Table_2_Description__c,MM_Square_Table_2_Height__c,MM_Square_Table_2_Is_Default__c,MM_Square_Table_2_Is_Rental__c,MM_Square_Table_2_Length__c,MM_Square_Table_2_Width__c,MM_Square_Table_3_Description__c,MM_Square_Table_3_Height__c,MM_Square_Table_3_Is_Default__c,MM_Square_Table_3_Is_Rental__c,MM_Square_Table_3_Length__c,MM_Square_Table_3_Width__c,MM_Square_Table_4_Description__c,MM_Square_Table_4_Height__c,MM_Square_Table_4_Is_Default__c,MM_Square_Table_4_Is_Rental__c,MM_Square_Table_4_Length__c,MM_Square_Table_4_Width__c,Name,NI_Doc_Record__c FROM AH_PLCM_MM_Inventory__c WHERE NI_Doc_Record__c =: ProjectId ]);
            if(lstInventory!=null && lstInventory.Size() > 0) {
                objExportInventory = lstInventory.get(0);
                //CHAIR
                if(objExportInventory.MM_Chair_1_Is_Default__c || objExportInventory.MM_Chair_2_Is_Default__c || objExportInventory.MM_Chair_3_Is_Default__c || objExportInventory.MM_Chair_4_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Chair_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Chair_Is_Default = true;
                }
                //CONFERENCE CHAIR
                if(objExportInventory.MM_Conference_Chair_1_Is_Default__c || objExportInventory.MM_Conference_Chair_2_Is_Default__c || objExportInventory.MM_Conference_Chair_3_Is_Default__c || objExportInventory.MM_Conference_Chair_4_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Conference_Chair_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Conference_Chair_Is_Default = true;
                }
                //RECTANGULAR TABLE
                if(objExportInventory.MM_Rectangular_Table_1_Is_Default__c || objExportInventory.MM_Rectangular_Table_2_Is_Default__c || objExportInventory.MM_Rectangular_Table_3_Is_Default__c || objExportInventory.MM_Rectangular_Table_4_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Rectangular_Table_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Rectangular_Table_Is_Default = true;
                }
                //SQUARE TABLE
                if(objExportInventory.MM_Square_Table_1_Is_Default__c || objExportInventory.MM_Square_Table_2_Is_Default__c || objExportInventory.MM_Square_Table_3_Is_Default__c || objExportInventory.MM_Square_Table_4_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Square_Table_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Square_Table_Is_Default = true;
                }
                
                //ROUND TABLE
                if(objExportInventory.MM_Round_Table_1_Is_Default__c || objExportInventory.MM_Round_Table_2_Is_Default__c || objExportInventory.MM_Round_Table_3_Is_Default__c || objExportInventory.MM_Round_Table_4_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Round_Table_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Round_Table_Is_Default = true;
                }
                
                //RISER/STAGE
                if(objExportInventory.MM_Riser_Stage_1_Is_Default__c || objExportInventory.MM_Riser_Stage_2_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Riser_Stage_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Riser_Stage_Is_Default = true;
                }
                
                //DANCE FLOOR
                if(objExportInventory.MM_Dance_Floor_1_Is_Default__c || objExportInventory.MM_Dance_Floor_2_Is_Default__c){
                    defaultInventoryWrapper.MM_Default_Dance_Floor_Is_Default = false;
                } else {
                    defaultInventoryWrapper.MM_Default_Dance_Floor_Is_Default = true;
                }
                
            }
            else {
                objExportInventory = new AH_PLCM_MM_Inventory__c();
            }
            return objExportInventory;
        } 
        catch(Exception ex) {
            throw ex;
        } 
        finally {
            lstInventory = null;
        }
    }
    
}