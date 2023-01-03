/****************************************************************************************
Name            : AH_CaseFlagSetupController Class
Author          : Cybage Developer - Ria Chawla
Created Date    : 01/15/2018
Last Mod Date   : 04/18/2018
Last Mod By     : Cybage Developer - Ria Chawla
NICC Reference  : NICC-026092
Description     : Controller for AH_CaseFlagSetupPage VF page
				: Contains code to store changes made in Case Flags Setup Wizard Page in custom settings 
				: 
*****************************************************************************************/
public class AH_CaseFlagSetupController 
{
    //CLASS VARIABLES
    public AH_CaseFlagPreferences__c caseFlagCustomSetting {get; set;}
    public ApexPages.StandardController stdCtrl {get; set;}
    public String formatSelection {get; set;}
    public List<User> excludedUsers {get; set;}
    public List<SelectOption> flagOptions{get; set;}
    public SelectOption[] selectedRecTypes { get; set; }
    public SelectOption[] remRecTypes { get; set; }
    
    public SelectOption[] selectedActTypes {get; set;}
    public SelectOption[] RemActTypes {get; set;}
    
    public SelectOption[] selectedCaseOrigins {get;set;}
    public SelectOption[] remCaseOrigins {get; set;}
    
    Map<String, String> allActivityTypes = new Map<String, String>();
    
    //CONSTRUCTOR
    public AH_CaseFlagSetupController(ApexPages.StandardController stdCtrl){
        this.stdCtrl = stdCtrl;
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_act_types = new List<String>();
        List<String> selected_case_types = new List<String>();
        List<String> selected_case_origins = new List<String>();
        
        Map <String, String> MapSelectedActTypes = new Map <String, String>();
        Map <String, String> MapSelectedCaseTypes = new Map <String, String>();
        Map <String, String> MapSelectedCaseOrigins = new Map <String, String>();
        
        Map<String, String> allCaseTypes = new Map<String, String>();
        Map<String, String> allActivityTypes = new Map<String, String>();
        Map<String, String> allCaseOrigins = new Map<String, String>();
        
        List<RecordType> RecTypes1 = new List<RecordType>();
        
        caseFlagCustomSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        if(caseFlagCustomSetting == null){
            caseFlagCustomSetting = new AH_CaseFlagPreferences__c();
        }
        else{
            if(caseFlagCustomSetting.Excluded_Users__c  != null){
                List<Id> userIds = new List<Id>();
                userIds = caseFlagCustomSetting.Excluded_Users__c.split(',');
                excludedUsers = new List<User>();
                excludedUsers = [SELECT Id, Name FROM User WHERE Id IN :userIds];
                formatSelection = caseFlagCustomSetting.Hours__c;
            }
        }
        
        //GET ALL CASE RECORD TYPES
        Map<Id, RecordType> allCaseRecTypes = new Map<Id, RecordType>([SELECT BusinessProcessId, Description,
                                                                       DeveloperName, Id, IsActive, Name, SobjectType
                                                                       FROM RecordType
                                                                       WHERE sObjectType = 'Case' AND isActive= true]);
        
        //GET ALL ACTIVITY TYPES
        Schema.DescribeFieldResult fieldResult1 = Task.Type.getDescribe();    
        List<Schema.picklistEntry> ple1 = fieldResult1.getPicklistValues();    
        for(Schema.picklistEntry f : ple1)    
        {
            allActivityTypes.put(f.getValue(),f.getValue());                  
        }
        
        //GET ALL CASE ORIGINS
        Schema.DescribeFieldResult fieldResult2 = Case.Origin.getDescribe();    
        List<Schema.picklistEntry> ple2 = fieldResult2.getPicklistValues();    
        for(Schema.picklistEntry f : ple2)    
        {
            allCaseOrigins.put(f.getLabel(),f.getLabel());
        }
        
        selectedRecTypes = new List<SelectOption>();
        selectedActTypes = new List<SelectOption>();
        selectedCaseOrigins = new List<SelectOption>();
        
        remRecTypes = new List<SelectOption>();
        RemActTypes = new List<SelectOption>();
        remCaseOrigins = new List<SelectOption>();
        
        //CREATE LIST OF SELECTED CASE RECORD TYPE, SELECTED ACTIVITY TYPE AND SELECTED CASE ORIGIN
        try{
            flagRecTypes = [SELECT 	Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c	 	 	
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' LIMIT 1];
            //system.debug('flagRecTypes'+flagRecTypes);
            if(flagRecTypes.Enabled_Case_Type__c != null)
                selected_case_types = flagRecTypes.Enabled_Case_Type__c.split(',');
            if(flagRecTypes.Enabled_Activity_Types__c != null)
                selected_act_types = flagRecTypes.Enabled_Activity_Types__c.split(',');
            if(flagRecTypes.Clear_Case_Origins__c != null)
                selected_case_origins = flagRecTypes.Clear_Case_Origins__c.split(',');
            //system.debug('selected_case_types'+selected_case_types);
            //system.debug('selected_act_types'+selected_act_types);
            //system.debug('selected_case_origins'+selected_case_origins);
            if(!selected_case_types.isEmpty()){
                for(String s : selected_case_types){
                    MapSelectedCaseTypes.put(s,s);
                }
            }
            
            if(!selected_act_types.isEmpty()){
                for(String s : selected_act_types){
                    MapSelectedActTypes.put(s,s);
                }
            }
            
            
            if(!selected_case_origins.isEmpty()){
                for(String s : selected_case_origins){
                    MapSelectedCaseOrigins.put(s,s);
                }
            }
            
        }
        catch(Exception e){
            system.debug('e'+e.getMessage());
            //DO NOTHING
        }
        
        if (!MapSelectedCaseTypes.isEmpty()) {
            //system.debug('MapSelectedCaseTypes'+MapSelectedCaseTypes);
            for (RecordType recType : allCaseRecTypes.values() ) {        
                if (MapSelectedCaseTypes.containsKey(recType.Id)){
                    selectedRecTypes.add(new SelectOption(recType.Id, recType.Name));
                }
                else{
                    remRecTypes.add(new SelectOption(recType.Id, recType.Name));
                }
            }
        }
        else {
            for (RecordType recType : allCaseRecTypes.values())
            {  
                remRecTypes.add(new SelectOption(recType.Id, recType.Name));
            }
        }
        
        if (!MapSelectedActTypes.isEmpty()) {
            for (String ActType : allActivityTypes.values() )
            {        
                if (MapSelectedActTypes.containsKey(ActType))
                {
                    selectedActTypes.add(new SelectOption(ActType, ActType));
                }
                else
                {
                    RemActTypes.add(new SelectOption(ActType, ActType));
                }
            }
        }
        else
        {
            for (String ActType : allActivityTypes.values())
            {
                RemActTypes.add(new SelectOption(ActType, ActType));
            }
        }
        
        if (!MapSelectedCaseOrigins.isEmpty())
        { 
            for (String caseOrigin : allCaseOrigins.values())
            {        
                if (MapSelectedCaseOrigins.containsKey(caseOrigin)){
                    selectedCaseOrigins.add(new SelectOption(caseOrigin, caseOrigin));
                }
                else{
                    remCaseOrigins.add(new SelectOption(caseOrigin, caseOrigin));
                }
            }
        }
        else {
            for (String caseOrigin : allCaseOrigins.values() ) {
                remCaseOrigins.add(new SelectOption(caseOrigin, caseOrigin));
            }
        }
        
        List<Document> docs = new List<Document>();
        flagOptions = new List<SelectOption>();
        docs = [SELECT Id, Name, Type, Folder.Name FROM Document
                WHERE (Type = 'png' OR Type='gif' OR Type = 'jpg' OR Type='jpeg') AND
                Folder.Name = 'AH Case Flags'];
        for (Document d: docs) {
            flagOptions.add(new SelectOption(d.Id,d.Name));
        }
    }
    
    public void radioChange(){
        if(formatSelection == 'Business'){
            //SCHEDULE PREVIOUS BUSINESS HOURS BATCH
        }
        else if(formatSelection == '24'){
            //ABORT SCHEDULED JOB
        }
    }
    
    public void organizationWideChange(){
        //BATCH TO SET BUSINESS HOURS (BusinessHoursBatch)
    }
    
    public void doSave(){
        //system.debug('SelectedRecordType'+selectedRecTypes);
        String recordTypeIds = '';
        String activityTypeIds = '';
        String caseOrigins = '';
        Boolean first = true;
        
        try{
            upsert caseFlagCustomSetting;  
        }
        catch(Exception e){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Datetime.now().format()+' - There is some error.'));
            return;
        }
        //System.debug('caseFlagCustomSetting in controller : '+caseFlagCustomSetting);
        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        if(selectedRecTypes != null){
            for ( SelectOption so : selectedRecTypes ) {
                if (so.getValue() != NULL) {
                    recordTypeIds += so.getValue()+',';
                }
            }
        }
        else{
            recordTypeIds = '' ;
        }
        
        if(!selectedActTypes.isEmpty()){
            for ( SelectOption so : selectedActTypes ) {
                if (so.getValue() != NULL) {
                    activityTypeIds += so.getValue()+',';
                }
            }
        }
        else{
            activityTypeIds = '';
        }
        
        if(!selectedCaseOrigins.isEmpty()){
            for ( SelectOption so : selectedCaseOrigins ) {
                if (so.getValue() != NULL) {
                    //System.debug('Case Origin Name : '+so.getValue());
                    caseOrigins += so.getValue()+',';
                }
            }
        }
        else{
            caseOrigins = '';
        }
        
        
        try{
            flagRecTypes = [SELECT 	Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' LIMIT 1];
            if(activityTypeIds != '' && activityTypeIds != null){
                flagRecTypes.Enabled_Activity_Types__c = activityTypeIds.removeEnd(',');
            }
            else{
                flagRecTypes.Enabled_Activity_Types__c = activityTypeIds;
            }
            if(recordTypeIds != '' && recordTypeIds != null){
                flagRecTypes.Enabled_Case_Type__c = recordTypeIds.removeEnd(',');
            }
            else{
                flagRecTypes.Enabled_Case_Type__c = recordTypeIds;
            }
            if(caseOrigins != '' && caseOrigins != null){
                flagRecTypes.Clear_Case_Origins__c = caseOrigins.removeEnd(',');
            }
            else{
                flagRecTypes.Clear_Case_Origins__c = caseOrigins;
            }
            update flagRecTypes;
        }
        catch(Exception e){
            flagRecTypes.Name = 'Default';
            if(activityTypeIds != '' && activityTypeIds != null){
                flagRecTypes.Enabled_Activity_Types__c = activityTypeIds.removeEnd(',');
            }
            else{
                flagRecTypes.Enabled_Activity_Types__c = activityTypeIds;
            }
            if(recordTypeIds != '' && recordTypeIds != null){
                flagRecTypes.Enabled_Case_Type__c = recordTypeIds.removeEnd(',');
            }
            else{
                flagRecTypes.Enabled_Case_Type__c = recordTypeIds;
            }
            if(caseOrigins != '' && caseOrigins != null){
                flagRecTypes.Clear_Case_Origins__c = caseOrigins.removeEnd(',');
            }
            else{
                flagRecTypes.Clear_Case_Origins__c = caseOrigins;
            }
            insert flagRecTypes;
        }
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Datetime.now().format()+' - Your preferences have been saved.'));
    }
}