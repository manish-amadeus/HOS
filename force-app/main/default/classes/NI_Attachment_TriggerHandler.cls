/************************************************************************************************
Name            : NI_Attachment_TriggerHandler Class
Author          : Swapnil Patil
Created Date    : 02/18/2016
Last Mod Date   : 04/18/2018 
Last Mod By     : Ria Chawla
NICC Reference  : Last Updated Per NICC-023347
Description     : Class that handles all trigger code for the Attachment Object
                : NICC-026092 - Cybage added setCaseFlag function
				: Added switch to bypass CASE Flags code.
                :    
*************************************************************************************************/
public class NI_Attachment_TriggerHandler 
{

    public NI_Attachment_TriggerHandler()
    {
    }

    // ==========================================================================================
    //  ENTRY FUNCTIONS
    // ==========================================================================================    
    public void OnAfterInsert(List<Attachment> newTrigger)
    {
        
        if (!NI_FUNCTIONS.bypassTriggerCode('ATTACHMENT'))
        {
            List<Attachment> lstAttach = new List<Attachment>();
            lstAttach = lstValidAttachmentsToProcess(newTrigger);
            if (!lstAttach.isEmpty())
            {
                if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
                {  
                    setCaseFlag(lstAttach);
                }
            }  
        } 
        
    }

    // ==========================================================================================
    //  FUNCTIONS
    // ==========================================================================================
    private List<Attachment> lstValidAttachmentsToProcess (List<Attachment> newTrigger)
    {
        
        // LIST OF VALID CASES TO BE RETURNED 
        List<Attachment> retLst = new List<Attachment>();

    	// LOOK FOR CASES IDS
        Set<Id> setCaseIds = new Set<Id>();
        
        for (Attachment a : newTrigger) 
        {
            if ((String.ValueOf(a.ParentId)).startsWith('500'))
            {
                setCaseIds.add(a.ParentId);
            } 
        }        
        
        // IF NO ATTACHMENTS BELONG TO CASES, RETURN EMPTY LIST
        if (setCaseIds.isEmpty()) {return retLst;}

        // GET ALL VALID CASE RECORD TYPE NAMES FROM CUSTOM SETTING
        Winaproach_Incident_Case_Record_Type__c wcsRecordTypes = Winaproach_Incident_Case_Record_Type__c.getValues('Default'); 
        
        // IF NO RECORD TYPE NAMES FROM CUSTOM SETTING FOUND RETURN 0 SIZED CASE LIST
        if (wcsRecordTypes == null){return retLst;}
        
        // PARSE RECORD TYPE NAMES FROM CUSTOM SETTING INTO LIST
        List<String> lstRecordtypes = String.valueOf(wcsRecordTypes.record_type__c).split(',');
        
        // SET TO HOLD CASE RECORD TYPE IDS 
        Set<Id> setRecordTypeIds = new Set<Id>();
        
        /*
        // LOOP THROUGH CASE RECORD TYPES TO ASSIGN IDS TO SET 
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE sObjectType = 'Case' AND Name IN : lstRecordtypes])
        {
            setRecordTypeIds.Add(rt.Id);
        }
        */

        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Case.getRecordTypeInfosByName();

        for (String recType : lstRecordtypes)
        {
            if (recordTypesMap.containsKey(recType)) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                setRecordTypeIds.Add(rr.getRecordTypeId());
            }
        }

        // FILL LIST OF CASES THAT BELONG TO THE ATTACHMENTS IN TRIGGER AND "DO NOT" HAVE CASE RECORD TYPES PERTAINING TO INTGR
        List<Case> lstCases = new List<Case>([SELECT Id FROM Case WHERE Id IN : setCaseIds AND RecordTypeId NOT IN : setRecordTypeIds]);
        
        if (!lstCases.isEmpty())
        {
            for (Attachment a : newTrigger) 
            {        
                for (Case c : lstCases)
                {
                    if (a.ParentId == c.Id)
                    {
                        retLst.Add(a);
                    }
                }
            }            
        }

        return retLst;
        
    }
    
    public void setCaseFlag(List<Attachment> newTrigger)
    {
        // NICC-026092
        
        Set<Id> caseIdSet = new Set<Id>();
        AH_CaseFlagPreferences__c caseFlagCustomSetting = new AH_CaseFlagPreferences__c();
        caseFlagCustomSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        List<Case> casesToSetList = new List<Case>();
        Map<Id, User> usersMap = new Map<Id, User>();
        
        if (caseFlagCustomSetting.Set_On_Case_Attachment__c == true)
        {
            
            Set<Id> userIdSet = new Set<Id>();
            
            for (Attachment a : newTrigger)
            {
                userIdSet.add(a.CreatedById);
            }
            
            if (!userIdSet.isEmpty())
            {
                usersMap = new Map<Id, User>([SELECT Id, UserType FROM User WHERE Id IN :userIdSet]);
            }
            
            for (Attachment a : newTrigger)
            {
                if (a.ParentId != null && String.valueOf(a.ParentId).startsWith('500'))
                {
                    if (!usersMap.isEmpty())
                    {
                        User u = usersMap.get(a.CreatedById);                       
                        if (u.UserType != 'Standard')
                        {
                            caseIdSet.add(a.ParentId);
                        }
                    }
                    
                }
            }
            
            if (!caseIdSet.isEmpty())
            {
                
                casesToSetList = [SELECT Id, RecordTypeId, CaseNumber, BusinessHoursId, CreatedDate, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                                  AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                                  AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
                                  AH_Case_Flag_Business_Age__c, Todays_End_Time__c, Todays_Start_Time__c
                                  FROM Case
                                  WHERE Id IN :caseIdSet];
                
                NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();
                caseHandler.setCaseFlagRelatedData(casesToSetList, true, 'Customer Attachment Added');
                
            }
            
        }
        
    }
    
}