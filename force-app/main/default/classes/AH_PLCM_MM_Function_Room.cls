/***********************************************************************************************
Name            : AH_PLCM_MM_Function_Room
Author          : Tushar Gupta
Created Date    : 07-June-2020
Last Mod Date   : 07-June-2020
Last Mod By     : Tushar Gupta
NICC Reference  : 
Description     : Apex class for Function Room page
************************************************************************************************/
public class AH_PLCM_MM_Function_Room extends AH_PLCM_MM_Common_Class {
    public List<AH_PLCM_MM_Room_Details__c> lstFunctionRoom { get; set; }
    public String propertyName { get; set; }
    public AH_PLCM_MM_Room_Details__c functionRoom { get; set; }
    public String functionRoomId { get; set; }
    public String SourceType { get; set; }
    public String FunctionRoomType { get; set; }
    public String message { get; set; }
    //Bind select options list with source type
    public List<SelectOption> lstSourceType { 
        get {
            List<SelectOption> lst = null;
            try {
                lst = new List<SelectOption>();
                //Get picklist value
                List<Schema.PicklistEntry> sourceTypePickListValue = GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c', 'MM_Source_Type__c');
                
                for( Schema.PicklistEntry pickListVal : sourceTypePickListValue){
                    lst.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
                }   
                return lst;
            }
            catch(Exception ex) {
                //Display error Message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
                return new List<SelectOption>();
            }
            finally {
                lst = null;
            }
        }
    }

    //Bind select options list with function room type
    public List<SelectOption> lstFunctionRoomType { 
        get {
            List<SelectOption> lst = null;
            try {
                lst = new List<SelectOption>();
                //Get picklist values
                List<Schema.PicklistEntry> sourceTypePickListValue = GetPickListValueFromObject('AH_PLCM_MM_Room_Details__c', 'MM_Function_Room_Type__c');
                
                for( Schema.PicklistEntry pickListVal : sourceTypePickListValue){
                    lst.add(new SelectOption(pickListVal.getValue(), pickListVal.getLabel()));
                }   
                return lst;
            }
            catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
                return new List<SelectOption>();
            }
            finally {
                lst = null;
            }
        }
    }

    public AH_PLCM_MM_Function_Room() {
        //Get already added function rooms
        fillFunctionRoomList();

        //Initialize the function room object for form 
        functionRoom = new AH_PLCM_MM_Room_Details__c();
    }

    private void FillFunctionRoomList() {
        try {
            lstFunctionRoom = [SELECT Id,MM_Ceiling_Height__c,MM_Floor_Plan_Level__c,MM_Is_Reception_Only__c,MM_Is_Seating_Orientation_Non_Std__c,MM_NI_Doc_Record__c,MM_Seating_Orientation_Details__c,MM_Source_Location__c,MM_Source_Type__c,MM_Square_Feet__c,Name,  MM_Function_Room_Type__c FROM AH_PLCM_MM_Room_Details__c Where MM_NI_Doc_Record__c = : ProjectId ORDER BY Name];
        }
        catch(Exception ex) {
            throw ex;
        }
    }

    //Get function room details by Id
    private AH_PLCM_MM_Room_Details__c GetFunctionRoomById() {
        AH_PLCM_MM_Room_Details__c objRoom = null;
        try {
            if(!String.IsBlank(functionRoomId)) {
                objRoom =  [SELECT Id,MM_Ceiling_Height__c,MM_Floor_Plan_Level__c,MM_Function_Room_Type__c,MM_Is_Reception_Only__c,MM_Is_Seating_Orientation_Non_Std__c,MM_NI_Doc_Record__c,MM_Seating_Orientation_Details__c,MM_Source_Location__c,MM_Source_Type__c,MM_Square_Feet__c,Name FROM AH_PLCM_MM_Room_Details__c Where Id =: functionRoomId];
            }
            return objRoom;
        }
        catch(exception ex) {
            throw ex;
        }
        finally {
            objRoom = null;
        }
    }

    //Get the function room details based on function id
    public void EditFunctionRoom() {
        try {
            functionRoom = GetFunctionRoomById();
        }
        catch(Exception ex) {
            //Display message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
    }

    //Add function room
    public void AddFunctionRoom() {
        try {
            
            functionRoom.Id = null;
            functionRoom.MM_NI_Doc_Record__c = ProjectId;
            insert functionRoom;
            FillFunctionRoomList();
            functionRoom = new AH_PLCM_MM_Room_Details__c();
            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Function room has been saved successfully!!'));
        }
        catch(Exception ex) {
            
            //Display error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
    }

    //Update function room
    public void UpdateFunctionRoom() {
        try {
            update functionRoom;
            FillFunctionRoomList();
            functionRoom = new AH_PLCM_MM_Room_Details__c();
            //Display success message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Function room details has been updated successfully!!'));
        }
        catch(Exception ex) {
            //Display error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
    }

    //Delete function room 
    public void DeleteFunctionRoom() {
        AH_PLCM_MM_Room_Details__c functionRoomDetail = null;
        try {
            System.debug('DeleteFunctionRoom => functionRoomDetail => ' + functionRoomDetail);
            functionRoomDetail = GetFunctionRoomById();
            if(functionRoomDetail != null) {
                delete functionRoomDetail;
                FillFunctionRoomList();
                functionRoom = new AH_PLCM_MM_Room_Details__c();
                //Display success message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Function room has been deleted successfully!!'));
            }
        }
        catch(Exception ex) {
            //Display error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.valueOf(ex)));
        }
        finally {
            functionRoomDetail = null;
        }
    }

    //Go to next page
    public PageReference GoToRoomCapacities() {
        Map<string, string> lstParameters = null;
        try {
            if(!ProjectPortalStatus.IsFunctionRoomInfomationProvided){
                //Save default value into room capacities
                SaveDefaultValueIntoRoomCapacities();
                // update portal status
                UpdatePortalStatus(ProjectPortalStatus.FunctionRoomInfomationProvided);
            }
            //Set query string value
            lstParameters = new Map<string, string>();
            lstParameters.put('ProjectId', ProjectId);
            return RedirectToPage(PageNames.RoomCapacitiesPage, lstParameters);
        }
        catch(Exception ex) {
            System.debug(ex);
            //Redirect to error page
            return RedirectToErrorPage('GoToRoomCapacities', ex);
        }
        finally {
            lstParameters = null;
        }
    }

    //Go back to welcome page on click of back button
    public PageReference BackToHomePage() {
        try {
            //Redirect Back to Welcome Page
            return RedirectToPage(PageNames.WelcomePage, null);
        }
        catch(Exception ex) {
            //Redirect to error page
            return RedirectToErrorPage('BackToHomePage', ex);
        }        
    }

    //Insert default value into room capacities objcet
    public void SaveDefaultValueIntoRoomCapacities() {
        List<AH_PLCM_MM_Seating_Capacity__c> lstRoomCapacities = null;
        AH_PLCM_MM_Seating_Capacity__c objDefaultValues = null;
        try {
            //Get Amadeus Default Standard Room Capacities Values
            objDefaultValues = GetDefaultRoomCapacityValues();
            objDefaultValues.Name = GetMMPropertyName();

            //Get already inserted room capacities values
            lstRoomCapacities = [SELECT Id FROM AH_PLCM_MM_Seating_Capacity__c WHERE MM_NI_Doc_Record__c =: ProjectId];
            if(lstRoomCapacities != null && lstRoomCapacities.Size() > 0) {
                objDefaultValues.Id = lstRoomCapacities.get(0).Id;
                update objDefaultValues;
            }
            else {
                insert objDefaultValues;
            }
        }
        catch(Exception ex) {
            throw ex;
        }
        finally {
            lstRoomCapacities = null;
            objDefaultValues = null;
        }
    }
    
    
}