/************************************************************************************************
Name            : INTGR_WinSN_Attachment_Handler Class
Author          : Swapnil Patil
Created Date    : 02/18/2016
Last Mod Date   : 03/28/2018 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles Winaproach/ServiceNow integration trigger code for the Attachment Object
                : TEST FOR THIS CLASS IS: NI_Attachment_TriggerHandler_Test
                :    
*************************************************************************************************/
public class INTGR_WinSN_Attachment_Handler 
{

    public INTGR_WinSN_Attachment_Handler()
    {
    }

    // ==========================================================================================
    //  ENTRY FUNCTIONS
    // ==========================================================================================    
    public void OnAfterInsert(List<Attachment> newTrigger)
    {
        
        system.debug(' *** ENTERING INTGR_WinSN_Attachment_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Attachment> lstAttach = new List<Attachment>();
        lstAttach = lstValidAttachmentsToProcess(newTrigger);
        if (!lstAttach.isEmpty())
        {
            INTGR_IHG_ProcessAttachments(lstAttach);
        } 
        
        system.debug(' *** EXITING INTGR_WinSN_Attachment_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    // ==========================================================================================
    //  FUNCTIONS
    // ==========================================================================================
    private List<Attachment> lstValidAttachmentsToProcess(List<Attachment> newTrigger)
    {
		
        system.debug(' *** ENTERING INTGR_WinSN_Attachment_Handler.lstValidAttachmentToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LIST OF VALID CASES TO BE RETURNED 
        List<Attachment> retLst = new List<Attachment>();
        
        // GET ALL VALID CASE RECORD TYPE NAMES FROM CUSTOM SETTING
        Winaproach_Incident_Case_Record_Type__c wcsRecordTypes = Winaproach_Incident_Case_Record_Type__c.getValues('Default'); 
        
        // 'CRS WORK ORDER' CASE RECORD TYPES
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

        system.debug(' **** Integration Attachment');
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
        for (Attachment csa : newTrigger)
        {        
        	setParentCaseIds.add(csa.ParentId);
        }
        
        Map<Id, Id> mapCaseId2RecTypeId = new Map<Id, Id>();
        for (Case cs : [SELECT Id, RecordTypeId FROM Case WHERE Id IN : setParentCaseIds])
        {
            mapCaseId2RecTypeId.put(cs.Id, cs.RecordTypeId);
        }
        
        for (Attachment atch : newTrigger)
        {
            // IF PARENT CASE IS OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE  
            if (setRecordTypeIds.contains(mapCaseId2RecTypeId.get(atch.ParentId)))
            {
                retLst.Add(atch);
            }
        }
        
        system.debug(' **** retLst = ' + retLst);
        
        system.debug(' *** EXITING INTGR_WinSN_Attachment_Handler.lstValidAttachmentsToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return retLst;
        
    } 
    
    public void INTGR_IHG_ProcessAttachments(List<Attachment> newTrigger)
    {
        
        system.debug(' *** ENTERING INTGR_WinSN_Attachment_Handler.INTGR_IHG_ProcessAttachments() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // ATTACHMENT SIZE FOR THE WINAPROACH RECORD TYPE IS CONTROLLED 
        // FROM THE CUSTOM SETTING DEFINED IN WINAPROACH_INCIDENT_CASE_RECORD_TYPE__C
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        Winaproach_Incident_Case_Record_Type__c csRecType = Winaproach_Incident_Case_Record_Type__c.getValues('Default');
        List<String> lstRecordtypes;
        lstRecordtypes = String.valueOf(csRecType.Record_Type__c).split(',');
        Set<Id> parentIds = new Set<Id>();
        Set<String> setRecordtypes = new Set<String>(lstRecordtypes);
        
        // VERIFY FOR THE WIN@PROACH INTEGRATION USERNAME 
        if (winSettings.Integration_Username__c != null && winSettings.Integration_Username__c != UserInfo.getUserName())
        {         
            
            for (Attachment a : newTrigger) 
            {
                parentIds.add(a.ParentId);
            }
            
            Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id, RecordTypeId, RecordType.Name FROM Case WHERE Id IN : parentIds]);
            
            if (mapCases.size() > 0)
            {
                for (Attachment att : newTrigger) 
                {
                    
                    // VERIFY THE RECORD TYPES EXIST IN CUSTOM SETTING 
                    if (setRecordtypes.contains(mapCases.get(att.ParentId).RecordType.Name)) 
                    {                         
                        if (att.Body.size() > csRecType.Attachment_Size_Limit__c)
                        {
                            att.addError('File size should be less than 6 MB ');
                            return;     
                        }                        
                    } 
                    
                } 
                
                // CALLING EXTERNAL WIN@PROACH WEB SERVICE 
                NI_WinaproachService.createActionLogOrAttachment(newTrigger, new Set<String>());
                
            }
            
        }
        
        // ATTACHMENT IMPLEMENTATION FOR SERVICENOW
        Set<Id> setParentIds = new Set<Id>();
        Set<Id> setAttachToServiceNow = new Set<Id>();
        
        ServiceNowIncidentSettings__c serviceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        
        if (serviceNowSettings.Integration_Username__c != null && serviceNowSettings.Integration_Username__c != UserInfo.getUserName())
        { 
            
            for (Attachment a : newTrigger)
            {
                setParentIds.add(a.ParentId);
            }
            
            Map<Id, Case> mapCasesSN = new Map<Id, Case>(
                [SELECT Id, INTGR_Create_Ticket_in_Customer_System__c, INTGR_Customer_Ticket_System_Id__c, 
                 CreatedById, RecordTypeID, RecordType.Name, Integration_Sync_Status__c 
                 FROM Case 
                 WHERE Id IN : setParentIds]);
            
            if (mapCasesSN.size() > 0)
            {
                
                for (Attachment att : newTrigger)
                {
                    
                    // VERIFY THE RECORD TYPES EXIST IN CUSTOM SETTING  
                    if (serviceNowSettings.ServiceNow_Incident_Case_Record_Type__c.equals(mapCasesSN.get(att.ParentId).RecordType.Name))
                    {
                        
                        Id idIHGServiceNowUser = Id.valueOf(serviceNowSettings.Integration_UserId__c);
                        Id idCaseCreatedBy = mapCasesSN.get(att.ParentId).CreatedById;
                        Boolean bCaseSyncIsOn = mapCasesSN.get(att.ParentId).Integration_Sync_Status__c;
                        Boolean bActionCreateTicket = mapCasesSN.get(att.ParentId).INTGR_Create_Ticket_in_Customer_System__c;
                        String strCustomerTicketId = '';
                        
                        if (mapCasesSN.get(att.ParentId).INTGR_Customer_Ticket_System_Id__c != null)
                        {
                            strCustomerTicketId = mapCasesSN.get(att.ParentId).INTGR_Customer_Ticket_System_Id__c;
                        }                        
                        
                        // IF CASE IS SET TO BE SYNCED AND CREATED BY THE IHG SERVICENOW USER
                        if ((idCaseCreatedBy == idIHGServiceNowUser) && bCaseSyncIsOn)
                        {
                            setAttachToServiceNow.add(att.Id);
                        }
                        
                        // IF CASE IS INTEGRATED AND NOT CREATED BY THE IHG SERVICENOW USER
                        if ((idCaseCreatedBy != idIHGServiceNowUser) && bActionCreateTicket)
                        {
                            setAttachToServiceNow.add(att.Id);
                        }

                        // IF CASE IS SET TO BE SYNCED, HAD CUSTOMER TICKET ID AND CASE NOT CREATED BY THE IHG SERVICENOW USER
                        if ((idCaseCreatedBy != idIHGServiceNowUser) && strCustomerTicketId != '' && bCaseSyncIsOn)
                        {
                            setAttachToServiceNow.add(att.Id);
                        } 
                        
                    }
                } 
                
                // CALLING EXTERNAL SERVICENOW WEB SERVICE  
                if (!setAttachToServiceNow.isEmpty())
                {
                    NI_ServicenowFunctions.attachment_Callout(setAttachToServiceNow);
                }
                
            }   
            
        }
        
        system.debug(' *** EXITING INTGR_WinSN_Attachment_Handler.INTGR_IHG_ProcessAttachments() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
}