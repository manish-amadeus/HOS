/************************************************************************************************
Name            : NI_CaseComment_TriggerHandler Class
Author          : Swapnil Patil
Created Date    : 02/18/2016
Last Mod Date   : 01/17/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the Case comment Object
                : Ria added Trigger Switch to bypass 'CASE FLAGS' code.
				: setCaseFlag method added to set case flags when a new case comment is added.
                :    
*************************************************************************************************/
public class NI_CaseComment_TriggerHandler 
{


    public NI_CaseComment_TriggerHandler()
    {
		
        system.debug(' *** ENTERING NI_CaseComment_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' *** EXITING NI_CaseComment_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterInsert(List<CaseComment> newTrigger)
    { 
        
        system.debug(' *** ENTERING NI_CaseComment_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());

        if (!NI_FUNCTIONS.bypassTriggerCode('CASECOMMENT')) 
        {
            
            if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
            {  
                List<CaseComment> lstValidCaseComments = new List<CaseComment>();
                lstValidCaseComments = lstValidCasesCommentsToProcess(newTrigger);
                
                system.debug(' **** lstValidCaseComments.size() = ' + lstValidCaseComments.size());
                
                if (lstValidCaseComments.Size() > 0)
                {
                    setCaseFlag(newTrigger);    
                }
            }
            
        }
        
        system.debug(' *** EXITING NI_CaseComment_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void OnAfterUpdate(List<CaseComment> newTrigger, Map<Id, CaseComment> oldMapTrigger)
    {
		
//        system.debug(' *** ENTERING NI_CaseComment_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
//        if (!NI_FUNCTIONS.bypassTriggerCode('CASECOMMENT')) 
//        { 

//        }
        
//        system.debug(' *** EXITING NI_CaseComment_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
                
    }
    

    // =========================================================================
    //    FUNCTIONS ============================================================
    // =========================================================================    
    private List<CaseComment> lstValidCasesCommentsToProcess(List<CaseComment> newTrigger)
    {
		
        system.debug(' *** ENTERING INTGR_WinSN_Case_Handler.lstValidCasesCommentsToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LIST OF VALID CASES TO BE RETURNED 
        List<CaseComment> retLst = new List<CaseComment>();
        
        // GET ALL VALID CASE RECORD TYPE NAMES FROM CUSTOM SETTING
        Winaproach_Incident_Case_Record_Type__c wcsRecordTypes = Winaproach_Incident_Case_Record_Type__c.getValues('Default'); 
        
        // NICC-027116 4/23/2018- ADDED BY RIA TO CONSIDER 'CRS WORK ORDER' CASE RECORD TYPES
        Winaproach_Work_Order_Case_Record_Type__c workOrderRecType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default');
        
        // IF NO RECORD TYPE NAMES FROM CUSTOM SETTING FOUND RETURN 0 SIZED CASE LIST
        if (wcsRecordTypes == null && workOrderRecType == null)
        {
            return retLst;
        }
        
        // PARSE RECORD TYPE NAMES FROM CUSTOM SETTING INTO LIST
        List<String> lstRecordtypes = String.valueOf(wcsRecordTypes.record_type__c).split(',');
          
        // LOOK FOR RECORD TYPE OF CRS WORK ORDERS
        if (workOrderRecType != null)
        {
            lstRecordtypes.add(String.valueOf(workOrderRecType.Record_Type__c));
        }        
      	
        // LOOP THROUGH CASE RECORD TYPES TO ASSIGN IDS TO SET 
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Case.getRecordTypeInfosByName();

        system.debug(' **** Standard Case Comment');
        system.debug(' **** recordTypesMap = ' + recordTypesMap);
        system.debug(' **** lstRecordtypes = ' + lstRecordtypes);
        
        // SET TO HOLD CASE RECORD TYPE IDS 
        Set<Id> setRecordTypeIds = new Set<Id>();
                
        for (String recType : lstRecordtypes)
        {
            if (recordTypesMap.containsKey(recType)) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                setRecordTypeIds.Add(rr.getRecordTypeId());
            }
        }

        Set<Id> setParentCaseIds = new Set<Id>();
        for (CaseComment csc : newTrigger)
        {        
        	setParentCaseIds.add(csc.ParentId);
        }
        
        Map<Id, Id> mapCaseId2RecTypeId = new Map<Id, Id>();
        for (Case cs : [SELECT Id, RecordTypeId FROM Case WHERE Id IN : setParentCaseIds])
        {
            mapCaseId2RecTypeId.put(cs.Id, cs.RecordTypeId);
        }
        
        for (CaseComment cc : newTrigger)
        {
            // IF PARENT CASE IS NOT OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE  
            if (!setRecordTypeIds.contains(mapCaseId2RecTypeId.get(cc.ParentId)))
            {
                retLst.Add(cc);
            }
        }
        
        system.debug(' **** retLst = ' + retLst);
        
        system.debug(' *** EXITING INTGR_WinSN_Case_Handler.lstValidCasesCommentsToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return retLst;
        
    } 
    
    private void setCaseFlag(List<CaseComment> newTrigger)
    {
        
        // METHOD TO SET OR CLEAR CASE FLAGS
        
        system.debug(' *** ENTERING NI_CaseComment_TriggerHandler.setCaseFlag() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // METHOD VARIABLES
        Set<Id> caseIdToClear = new Set<Id>();
        List<Case> caseListToClear = new List<Case>();
        Set<Id> caseIdToSet = new Set<Id>();
        List<Case> caseListToSet = new List<Case>();
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> users = new Map<Id, User>();
        AH_CaseFlagPreferences__c caseFlagCustomSetting = new AH_CaseFlagPreferences__c();
        caseFlagCustomSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
        
        List<Id> usrIds = new List<Id>();
        List<User> excludedUsers = new List<User>();
        Map<Id, SelfServiceUser> selfServiceUsers = new Map<Id, SelfServiceUser>();
        
        // CREATE A LIST OF EXCLUDED USERS FROM CUSTOM SETTING
        if (caseFlagCustomSetting.Excluded_Users__c != null)
        {
            for (String str : caseFlagCustomSetting.Excluded_Users__c.split(','))
            {
                usrIds.add(str.Trim());
            }
        }
        
        try
        {
            excludedUsers = [SELECT Id, Name FROM User WHERE Id IN : usrIds];
        }
        catch (Exception e) 
        { 
            system.debug('Error Occured: ' + e.getMessage()); 
        }
        
        if (caseFlagCustomSetting.Set_On_Customer_Comment__c == true || caseFlagCustomSetting.Clear_On_Company_Comment__c == true)
        {
            for (CaseComment csCmnt : newTrigger)
            {
                if (csCmnt.ParentId != null && 
                    String.valueOf(csCmnt.ParentId).startsWith('500') && 
                    csCmnt.IsPublished == true)
                {
                    userIds.add(csCmnt.CreatedById);
                }
            }
            
            if (!userIds.isEmpty())
            {
                users = new Map<Id, User>([SELECT Id, Email, UserType FROM User WHERE Id IN : userIds]);
                selfServiceUsers = new Map<Id, SelfServiceUser>([SELECT Id FROM SelfServiceUser WHERE Id IN : userIds]);
            }
            
            // ITERATE OVER CASE COMMENTS TO CHECK FOR CONDITIONS
            for (CaseComment csCmnt : newTrigger)
            {
                
                // CHECK THE CREATED BY OF CASE COMMENT
                if (csCmnt.CreatedById != null)
                {
                    system.debug(' **** created by ' + users);
                    User u = new User();
                    u = users.get(csCmnt.CreatedById);
                    
                    if (u != null)
                    {
                        // IF USER IS NOT STANDARD, SET CASE FLAG
                        if ((u.UserType != 'Standard' || usrIds.contains(u.Id) || selfServiceUsers.containsKey(csCmnt.CreatedById)))
                        {
                            caseIdToSet.add(csCmnt.ParentId);
                        }
                        else 
                        {
                            // IF USER IS OF STANDARD LICENSE TYPE, CLEAR FLAG
                            if((u.UserType == 'Standard' || (!usrIds.contains(u.Id)) || (!selfServiceUsers.containsKey(csCmnt.CreatedById))))
                            {
                                caseIdToClear.add(csCmnt.ParentId);
                            }
                        }
                    }
                }
            }

            // IF SET IS NOT EMPTY, GET THE LIST OF CASES AND CALL CASE TRIGGER HANDLER METHOD TO CLEAR FLAG
            if (!caseIdToClear.isEmpty())
            {
                caseListToClear = [SELECT Id, BusinessHoursId, CaseNumber, CreatedById, CreatedDate, Owner.Id, Owner.Name, RecordTypeId, Status, 
                                   AH_Case_Flag_Business_Age__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, AH_Flag__c, AH_Flag_BH__c, 
                                   AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, 
                                   AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, 
                                   AH_Initial_response__c, AH_Initial_Response_Business_Hours__c, Todays_End_Time__c, Todays_Start_Time__c 
                                   FROM Case 
                                   WHERE Id IN : caseIdToClear 
                                   AND AH_Case_Flagged_Date__c != null
                                   AND Status != 'New'];
            
                system.debug(' **** caseListToClear.size() = ' + caseListToClear.size()); 
                
                caseHandler.clearCaseFlagRelatedData(caseListToClear, true, 'Internal Comment Added');
                
            }

            // IF SET IS NOT EMPTY, GET THE LIST OF CASES AND CALL CASE TRIGGER HANDLER METHOD TO SET FLAG
            if (!caseIdToSet.isEmpty())
            {
                
                caseListToSet = [SELECT Id, BusinessHoursId, CaseNumber, CreatedById, CreatedDate, Owner.Id, Owner.Name, RecordTypeId, Status, 
                                 AH_Case_Flag_Business_Age__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, AH_Flag__c, AH_Flag_BH__c, 
                                 AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, 
                                 AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, 
                                 AH_Initial_response__c, AH_Initial_Response_Business_Hours__c, Todays_End_Time__c, Todays_Start_Time__c  
                                 FROM Case 
                                 WHERE Id IN : caseIdToSet 
                                 AND AH_Case_Flagged_Date__c = null]; // ADD THIS PER NICC-027588
            
                system.debug(' **** caseListToSet.size() = ' + caseListToSet.size()); 
                
                caseHandler.setCaseFlagRelatedData(caseListToSet, true, 'External Comment Added');
                
            }
        }
        
        system.debug(' *** EXITING NI_CaseComment_TriggerHandler.setCaseFlag() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    

}