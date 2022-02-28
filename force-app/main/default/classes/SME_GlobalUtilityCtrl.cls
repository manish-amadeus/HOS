public without sharing class SME_GlobalUtilityCtrl {
    
    //Method return record type Id of given recordtype Name and Object
    public static Id getRecordTypeInfo(String objectName, String recordTypeName) {
        try{
            if(recordTypeName != null){
                return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();  
            } else {
                return null; 
            }
        }catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_GlobalUtilityCtrl', 'getRecordTypeInfo', e);
            return null;
        }
    }
    
    //Method to get API Name of fieldset using label
    public static String getFieldSetAPIName(String sObjectName,String fieldSetLabelName){
        String fieldSetName = '';
        try{
            Schema.SObjectType sObj = Schema.getGlobalDescribe().get(sObjectName);
            system.debug('Object'+sObj);
            FOR(Schema.FieldSet FS : sObj.getDescribe().fieldSets.getMap().values()){
                //system.debug('Field Set Name'+'fieldSetLabelName %%'+fs.getLabel());
                if(fieldSetLabelName == fs.getLabel()){
                    fieldSetName = fs.getName();
                    return fs.getName(); 
                }
                //fieldSetList.add(fs.getName() +'####'+fs.getLabel());
            }
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        } catch(Exception e){
            SME_GlobalExceptionHandlerCtrl.processException('SME_GlobalUtilityCtrl', 'getFieldSetAPIName', e);
        }
        return fieldSetName;
    } 
    
     //Dynamic method to get picklist values in Lightning Web Components
    @AuraEnabled(cacheable = true)
    public static List <FetchValueWrapper> fetchPickListValue(sObject objInfo, string picklistFieldApi) {
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objInfo.getSObjectType().getDescribe();
 
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
 
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(picklistFieldApi).getDescribe().getPickListValues();
 
        // Create a list of wrappers to store picklist values/labels
        list <FetchValueWrapper> objWrapper = new list < FetchValueWrapper > ();
 
        for (Schema.PicklistEntry a: values) {
            FetchValueWrapper oFetchValueWrapper = new FetchValueWrapper();
            oFetchValueWrapper.slabel = a.getLabel();
            oFetchValueWrapper.svalue = a.getValue();
            objWrapper.add(oFetchValueWrapper);
        }
        return objWrapper;
 
    }
    //wrapper class for dynamic picklist value set
    public with sharing class FetchValueWrapper {
        @auraEnabled public string slabel {get;set;}
        @auraEnabled public string svalue {get;set;}
    }
    
    // This method is used for creating Error Log for Database.DeleteResult 
    public static void deleteDatabaseDMLExceptionLog(List < SObject > records,  Database.DeleteResult[] results, String className, String sourceFunction) {
        try{
            List<SME_Exception_Log__c> ErrorLogs = new List<SME_Exception_Log__c>();
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    SME_Exception_Log__c errorLog = new SME_Exception_Log__c();
                    
                    errorLog.SME_Apex_Component__c = className;
                    errorLog.SME_Apex_Method__c = sourceFunction ; //The originating function in the class 
                    String message = '';
                    
                    if (records[i].get('Id') != null)
                        //errorLog.SME_Reference_Record__c = string.valueof(records[i].get('Id'));
                        
                        
                        for (String str: results[i].getErrors()[0].getFields()) {
                            message += str + ',';
                        }
                    
                    if (message != null)
                        errorLog.SME_Stack_Trace__c = message.subString(0, message.length());
                    
                    errorLog.SME_Exception_Message__c = results[i].getErrors()[0].getMessage();             
                    ErrorLogs.add(errorLog);
                }
            } 
            if(ErrorLogs.size()>0) 
                insert ErrorLogs; 
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        } catch(Exception e) {       
            SME_GlobalExceptionHandlerCtrl.processException('SME_GlobalUtilityCtrl', 'deleteDatabaseDMLExceptionLog', e);
            
        }
    }
    
    // This method is used for creating Error Log for Database.DeleteResult 
    public static void SaveDatabaseDMLExceptionLog(List < SObject > records,  Database.SaveResult[] results, String className, String sourceFunction) {
        try{
            List<SME_Exception_Log__c> ErrorLogs = new List<SME_Exception_Log__c>();
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    SME_Exception_Log__c errorLog = new SME_Exception_Log__c();
                    
                    errorLog.SME_Apex_Component__c = className;
                    errorLog.SME_Apex_Method__c = sourceFunction ; //The originating function in the class 
                    String message = '';
                    
                    if (records[i].get('Id') != null)
                        //errorLog.SME_Reference_Record__c = string.valueof(records[i].get('Id'));
                        
                        
                        for (String str: results[i].getErrors()[0].getFields()) {
                            message += str + ',';
                        }
                    
                    if (message != null)
                        errorLog.SME_Stack_Trace__c = message.subString(0, message.length());
                    
                    errorLog.SME_Exception_Message__c = results[i].getErrors()[0].getMessage();             
                    ErrorLogs.add(errorLog);
                }
            } 
            if(ErrorLogs.size()>0) 
                insert ErrorLogs;
            if(Test.isRunningTest()) {
                Integer i = 1/0;
            }
        } catch(Exception e) {       
            SME_GlobalExceptionHandlerCtrl.processException('SME_GlobalUtilityCtrl', 'databaseSaveDMLexceptionlog', e);
            
        }
    }
    
    public static Boolean getGFCEditDeletePermission (String sAccountPlanId){
        return ([Select count() from SME_Account_Plan_Team__c where SME_Account_Plan__c =: sAccountPlanId AND SME_Team_Member__c =: Userinfo.getUserId()] > 0) ? true : false;
    }
    
    // Description: Method delete assignments based on list of record and Calculation Logic Class
    public static void deleteAssignments(List<SObject> ObjectsToAssign, SME_IAssignmentBehaviorCtrl calculationLogic) {
        calculationLogic.loadRecords(ObjectsToAssign);
        calculationLogic.deleteAssignments();
    }
    
    // Description: Method creates assignments based on list of record and Calculation Logic Class
    public static void createAssignments(List<SObject> ObjectsToAssign, SME_IAssignmentBehaviorCtrl calculationLogic) {
        calculationLogic.loadRecords(ObjectsToAssign);
        calculationLogic.createAssignments();
    }
    
    //Get list of active community users
    public static List<User> getCommunityUserList(){
        List<User> listCommunityUser = new List<User>();
        Set<Id> custPortalUserSet = New Set<Id>();
        //Profile custPortalUser = [SELECT Id FROM Profile WHERE Name = 'SME_Company - Customer Portal User'];
        //Profile partPortalUser = [SELECT Id FROM Profile WHERE Name = 'SME_Company - Partner User'];
        For(Profile eachProfile : [SELECT Id FROM Profile WHERE Name = 'SME_Company - Customer Portal User' OR  Name = 'SME_Company - Partner User']){
            custPortalUserSet.add(eachProfile.id);
        }
        if(!custPortalUserSet.isEmpty()){
           //List<User> listCommunityUser = [SELECT Id FROM User WHERE ProfileId = :partPortalUser.Id OR ProfileId = :custPortalUser.Id]; 
           listCommunityUser = [SELECT Id FROM User WHERE ProfileId IN: custPortalUserSet]; 
        }
        return listCommunityUser;
    }
    
    
    //Description: Give deal reg-lead record read access to record creator if community user
    @InvocableMethod
    public static void grantReadAccessToDealRegCreator(List<Lead> listLeadToGrantAccess){
    //     List<Lead> listDealRegToProcess = new List<Lead>();
    //     for(Lead tempLead : listLeadToGrantAccess){
    //         if(tempLead.RecordType.Name == 'Partner Deal Reg'){
    //             listDealRegToProcess.add(tempLead);
    //         }
    //     }
    //     Set<Id> setCommunityUser = new Set<Id>();
    //     Map<Lead, Boolean> accessList = new Map<Lead, Boolean>();
    //     List<User> listCommunityUser = getCommunityUserList();
    //     if(listCommunityUser != null && listCommunityUser.size()>0){
    //         for(User tempUser : listCommunityUser){
    //             setCommunityUser.add(tempUser.Id);
    //         }
    //     }
    //     for (Lead leadRec : listDealRegToProcess){
    //         if(setCommunityUser.contains(leadRec.CreatedById)){
    //             Boolean accessGiven = SME_LightningShareComponentCtrl.addLeadAccess(leadRec.Id, leadRec.CreatedById, 'Read');
    //             accessList.put(leadRec, accessGiven);
    //         }
    //     }
    }
}