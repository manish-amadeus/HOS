/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentDocLink_TriggerHandler Class
Author          : Princy Jain
Created Date    : 03/04/2018
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Trigger Handler Class for the ContentDocumentLink Object
				: 
************************************************************************************************/
public class INTGR_ContentDocLink_TriggerHandler
{
    
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public INTGR_ContentDocLink_TriggerHandler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();         
    }
    
    public void OnBeforeInsert(List<ContentDocumentLink> newTrigger)
    {
        
        system.debug(' ***** INTGR_ContentDocLink_TriggerHandler.OnBeforeInsert START');
        
        for (ContentDocumentLink cdl : newTrigger) 
        {
            // CASE FILE VISIBILITY IN CUSTOMER CENTRAL EXPERIENCE 
            // IF RUNNING USER IS Integration User THEN SET FILE VISIBILITY TO AllUsers
            if ((UserInfo.getUserId() == '00560000000yI7jAAE') || (Test.isRunningTest() && UserInfo.getUserName() == 'test_integration_user@xxxxxxx.com'))
            {
                String objName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                if (objName == 'User' || objName == 'Case' || objName == 'EmailMessage')
                { 
                    cdl.Visibility = 'AllUsers';
                }  
            } 
        }

        system.debug(' ***** INTGR_ContentDocLink_TriggerHandler.OnBeforeInsert END');
        
    }
    
    public void OnAfterInsert(List<ContentDocumentLink> newTrigger) 
    {
        
        system.debug(' ***** INTGR_ContentDocLink_TriggerHandler.OnAfterInsert START');

        setInvoiceVisibility(newTrigger);
        processAfterConDocInsert(newTrigger);
        
        if (!bpSwitch.Bypass_Winaproach_ON__c)
        {
            List<ContentDocumentLink> lstFiles = new List<ContentDocumentLink>();
            lstFiles = lstValidFilesToProcess(newTrigger);
            if (!lstFiles.isEmpty())
            {
                INTGR_IHG_ProcessFiles(lstFiles);
            }  
        }        

        system.debug(' ***** INTGR_ContentDocLink_TriggerHandler.OnAfterInsert END');
        
    }
    
    
    // ===================================================================================================================
    // 	FUNCTIONS 
    // ===================================================================================================================
    private List<ContentDocumentLink> lstValidFilesToProcess(List<ContentDocumentLink> newTrigger)
    {
		
        system.debug(' ***** ENTERING INTGR_ContentDocLink_TriggerHandler.lstValidFilesToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LIST OF VALID FILES TO BE RETURNED 
        List<ContentDocumentLink> retLst = new List<ContentDocumentLink>();
        
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
         
        // GET RELATED CASE IDS
        Set<Id> setParentCaseIds = new Set<Id>();
        for (ContentDocumentLink cdlCase : newTrigger)
        {    
            if (cdlCase.LinkedEntityId != null)
            {
                String strPrefix = String.valueOf(cdlCase.LinkedEntityId).substring(0, 3);

                if (strPrefix == '500')
                {
                    setParentCaseIds.add(cdlCase.LinkedEntityId);
                } 
            }
        }
        
        // FILL A MAP OF RELATED CASES
        Map<Id, Id> mapCaseId2RecTypeId = new Map<Id, Id>();
        for (Case cs : [SELECT Id, RecordTypeId FROM Case WHERE Id IN : setParentCaseIds])
        {
            mapCaseId2RecTypeId.put(cs.Id, cs.RecordTypeId);
        }

        // LOOP THROUGH TRIGGER LOOKING FOR DOCUMENTS RELATED TO CASES WITH VALID IHG INTEGRATION TYPES
        for (ContentDocumentLink cdl : newTrigger)
        { 
            if (setRecordTypeIds.contains(mapCaseId2RecTypeId.get(cdl.LinkedEntityId)))
            {
                retLst.Add(cdl);
            }
        }

        system.debug(' *** EXITING INTGR_ContentDocLink_TriggerHandler.lstValidFilesToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return retLst;
        
     }     

    private void processAfterConDocInsert(List<ContentDocumentLink> newTrigger)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of trigger.new ContentDocumentLink object
        // Description: To check share type and populate parent id and case id to content version
        
        system.debug(' *** ENTERING INTGR_ContentDocLink_TriggerHandler.processAfterConDocInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
        
        for (ContentDocumentLink docLink : newTrigger)
        {
            if (docLink.ShareType == 'V' || docLink.ShareType == 'Viewers') 
            {
                linkList.add(docLink);
            }
        }
        
        if (!linkList.isEmpty())
        {
            populateParentIdOnContentVersion(linkList);
        }
        
        system.debug(' *** EXITING INTGR_ContentDocLink_TriggerHandler.processAfterConDocInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void populateParentIdOnContentVersion(List<ContentDocumentLink> newTrigger)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: new contentdoclink list      
        // Description: Populate Case Id and Parent Id to Integration case or case        
        
        system.debug(' *** ENTERING INTGR_ContentDocLink_TriggerHandler.populateParentIdOnContentVersion() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String objectType = '';
        Map<Id, Id> docIdVsCaseIdMap = new Map<Id, Id>();
        Map<Id, Id> docIdVsIntCaseIdMap = new Map<Id, Id>();
        List<ContentVersion> cvListInsert = new List<ContentVersion>();
        List<ContentVersion> cVListUpdate = new List<ContentVersion>();
        List<INTGR_Case__c> intCaseList = new List<INTGR_Case__c>();
        
        for (ContentDocumentLink docLink : newTrigger)
        {
            
            if (docLink.ShareType == 'V' || docLink.ShareType == 'Viewers') 
            {
                
                objectType = docLink.LinkedEntityId.getSObjectType().getDescribe().getName();
                
                if (objectType.equalsIgnoreCase('Case')) 
                {
                    docIdVsCaseIdMap.put(docLink.ContentDocumentId, docLink.LinkedEntityId);
                }
                
                if (objectType.equalsIgnoreCase('INTGR_Case__c')) 
                {
                    docIdVsIntCaseIdMap.put(docLink.ContentDocumentId, docLink.LinkedEntityId);
                }
                
            }
        }
        
        ContentVersion cvObj = new ContentVersion();
        blob fileData = null;
        
        // Assumption: object type is case and need to copy contentversion for Int Case and populate caseid to contentversion
        if (docIdVsCaseIdMap.size() > 0)
        {
            for (ContentVersion cv : [SELECT Id, Title, FileType, Customer_Ticket_System_Id__c, CaseId__c, ContentDocumentId, INTGR_Case__c 
                                      FROM ContentVersion 
                                      WHERE ContentDocumentId IN : docIdVsCaseIdMap.keySet() 
                                      AND CaseId__c = null])
            { 
                cv.CaseId__c = docIdVsCaseIdMap.get(cv.ContentDocumentId);
                cVListUpdate.add(cv);
            }
        }
        
        if (docIdVsIntCaseIdMap.size() > 0)
        {
            
            // Assumption: object type is int case and need to copy contentversion to Case and populate INTGR_Case__c to contentversion
            for (ContentVersion cv : [SELECT Id, Title, FileType, Customer_Ticket_System_Id__c, CaseId__c, ContentDocumentId, INTGR_Case__c 
                                      FROM ContentVersion 
                                      WHERE ContentDocumentId IN: docIdVsIntCaseIdMap.keySet() 
                                      AND INTGR_Case__c = null])
            {
                cv.INTGR_Case__c = docIdVsIntCaseIdMap.get(cv.ContentDocumentId);
                cVListUpdate.add(cv);
            }
            
        }
        
        try
        { 
            if (cVListUpdate.size() > 0)
            {
                update cVListUpdate;
            }
        }
        catch (Exception e)
        {
            system.debug(' **** Error occured : ' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_ContentDocLink_TriggerHandler.populateParentIdOnContentVersion() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void INTGR_IHG_ProcessFiles(List<ContentDocumentLink> newTrigger)
    {
        
        system.debug(' *** ENTERING INTGR_ContentDocLink_TriggerHandler.INTGR_IHG_ProcessFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LOAD CUSTOM SETTINGS
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        Winaproach_Incident_Case_Record_Type__c csRecType = Winaproach_Incident_Case_Record_Type__c.getValues('Default');
        ServiceNowIncidentSettings__c serviceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        
        List<String> lstRecordtypes = String.valueOf(csRecType.record_type__c).split(',');
        Set<String> setRecordtypes = new Set<String>(lstRecordtypes);
        Set<Id> parentIds = new Set<Id>();
        Set<Id> documentIds = new Set<Id>();
        Set<Id> setParentIdsServiceNow = new Set<Id>();
        Set<Id> setFilesToServiceNow = new Set<Id>();
        

        // FILE IMPLEMENTATION FOR WIN@PROACH 
        if (winSettings.Integration_Username__c != null && winSettings.Integration_Username__c != UserInfo.getUserName())
        {         
            
            for (ContentDocumentLink dLink1 : newTrigger) 
            {
                if (dLink1.LinkedEntityId != null)
                {
                    String strPrefix = String.valueOf(dLink1.LinkedEntityId).substring(0, 3);
                    if (strPrefix == '500')  //if (dLink1.LinkedEntity.Type.equalsIgnoreCase('Case'))
                    {
                        parentIds.add(dLink1.LinkedEntityId);
                        documentIds.add(dLink1.ContentDocumentId);
                    }
                }
            }
            
            Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id, RecordTypeId, RecordType.Name FROM Case WHERE Id IN : parentIds]);
            Map<Id, ContentDocument> mapContentDocuments = new Map<Id, ContentDocument>([SELECT Id, ContentSize FROM ContentDocument WHERE Id IN : documentIds]);
            
            if (mapCases.size() > 0)
            {
                for (ContentDocumentLink dLink2 : newTrigger) 
                {
                    // VERIFY THE RECORD TYPES EXIST IN CUSTOM SETTING 
                    if (setRecordtypes.contains(mapCases.get(dLink2.LinkedEntityId).RecordType.Name)) 
                    {
                        if (mapContentDocuments.containsKey(dLink2.ContentDocumentId))
                        {
                            if (mapContentDocuments.get(dLink2.ContentDocumentId).ContentSize > csRecType.Attachment_Size_Limit__c)
                            {
                                dLink2.addError('File size should be less than 6 MB ');
                                return;     
                            }                                 
                        }                   
                    } 
                } 
                
                // CALLING EXTERNAL WIN@PROACH WEB SERVICE 
                NI_WinaproachService.createActionLogOrAttachment(newTrigger, new Set<String>());
                
            }
            
        }

        // FILE IMPLEMENTATION FOR SERVICENOW
        if (serviceNowSettings.Integration_Username__c != null && serviceNowSettings.Integration_Username__c != UserInfo.getUserName())
        { 

            for (ContentDocumentLink dLinkSN1 : newTrigger) 
            {
           
                String strPrefix = String.valueOf(dLinkSN1.LinkedEntityId).substring(0, 3);
                if (strPrefix == '500') 
                {
                    setParentIdsServiceNow.add(dLinkSN1.LinkedEntityId);
                }
            }
            
            Map<Id, Case> mapCasesSN = new Map<Id, Case>(
                [SELECT Id, INTGR_Create_Ticket_in_Customer_System__c, INTGR_Customer_Ticket_System_Id__c, 
                 CreatedById, RecordTypeID, RecordType.Name, Integration_Sync_Status__c 
                 FROM Case 
                 WHERE Id IN : setParentIdsServiceNow]);

            if (mapCasesSN.size() > 0)
            {
                for (ContentDocumentLink dLinkSN2 : newTrigger)
                {

                    // VERIFY THE RECORD TYPES EXIST IN CUSTOM SETTING  
                    if (serviceNowSettings.ServiceNow_Incident_Case_Record_Type__c.equals(mapCasesSN.get(dLinkSN2.LinkedEntityId).RecordType.Name))
                    {
                        
                        Id idIHGServiceNowUser = Id.valueOf(serviceNowSettings.Integration_UserId__c);
                        Id idCaseCreatedBy = mapCasesSN.get(dLinkSN2.LinkedEntityId).CreatedById;
                        Boolean bCaseSyncIsOn = mapCasesSN.get(dLinkSN2.LinkedEntityId).Integration_Sync_Status__c;
                        Boolean bActionCreateTicket = mapCasesSN.get(dLinkSN2.LinkedEntityId).INTGR_Create_Ticket_in_Customer_System__c;
                        String strCustomerTicketId = '';
                        
                        if (mapCasesSN.get(dLinkSN2.LinkedEntityId).INTGR_Customer_Ticket_System_Id__c != null)
                        {
                            strCustomerTicketId = mapCasesSN.get(dLinkSN2.LinkedEntityId).INTGR_Customer_Ticket_System_Id__c;
                        }

                        // IF CASE IS SET TO BE SYNCED AND CREATED BY THE IHG SERVICENOW USER
                        if ((idCaseCreatedBy == idIHGServiceNowUser) && bCaseSyncIsOn)
                        {
                            setFilesToServiceNow.add(dLinkSN2.ContentDocumentId);
                        }
                        
                        // IF CASE IS INTEGRATED AND NOT CREATED BY THE IHG SERVICENOW USER
                        if ((idCaseCreatedBy != idIHGServiceNowUser) && bActionCreateTicket)
                        {
                            setFilesToServiceNow.add(dLinkSN2.ContentDocumentId);
                        }

                        // IF CASE IS SET TO BE SYNCED, HAD CUSTOMER TICKET ID AND CASE NOT CREATED BY THE IHG SERVICENOW USER
                        if ((idCaseCreatedBy != idIHGServiceNowUser) && strCustomerTicketId != '' && bCaseSyncIsOn)
                        {
                            setFilesToServiceNow.add(dLinkSN2.ContentDocumentId);
                        }                        

                    }
                } 
               
                // CALLING EXTERNAL SERVICENOW WEB SERVICE  
                if (!setFilesToServiceNow.isEmpty())
                {
                    NI_ServicenowFunctions.fileCallout(setFilesToServiceNow);
                }
                
            }   
            
        }
        
        system.debug(' *** EXITING INTGR_ContentDocLink_TriggerHandler.INTGR_IHG_ProcessFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }   

    private void setInvoiceVisibility(List<ContentDocumentLink> newTrigger)
    {
        
        // FILL MAP OF Sales Invoice IDs to ContentDocumentLink RECORD
        Map<Id, ContentDocumentLink> mapSinId2CDL = new Map<Id, ContentDocumentLink>(); 
        for (ContentDocumentLink cdl : newTrigger) 
        { 
            if (cdl.LinkedEntityId.getSObjectType().getDescribe().getName() == 'c2g__codaInvoice__c') 
            { 
                mapSinId2CDL.put(cdl.LinkedEntityId, cdl);
            } 
        } 
      
        // RETURN IF NO Sales Invoice RELATED FILE(S) AS FOUND
        if (mapSinId2CDL.isEmpty()) { return; }
        
        // FILL LIST OF NEW ContentDocumentLink TO LINK RELATED Billing Contract RECORDS TO FILE
        List<ContentDocumentLink> lstCDLInserts = new List<ContentDocumentLink>();    
        for (c2g__codaInvoice__c sin : [SELECT Id, Billing_Contract__c 
                                        FROM c2g__codaInvoice__c 
                                        WHERE Billing_Contract__c != null 
                                        AND Id IN : mapSinId2CDL.keySet()])
        { 
            ContentDocumentLink lnk = new ContentDocumentLink();
            lnk.LinkedEntityId = sin.Billing_Contract__c;
            lnk.ContentDocumentId = mapSinId2CDL.get(sin.Id).ContentDocumentId;
            lnk.Visibility  = mapSinId2CDL.get(sin.Id).Visibility;
            lnk.ShareType = mapSinId2CDL.get(sin.Id).ShareType;
            lstCDLInserts.add(lnk);
        } 
      
        if (!lstCDLInserts.isEmpty())
        {
            try
            {
                database.upsert(lstCDLInserts, false);
            }
            catch (Exception ex) {}
        }
        
    }

}