/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_ContentVersion_TriggerHandler Class
Author          : Sean Harris
Created Date    : 03/20/2018
Last Mod Date   : 02/18/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Trigger Handler Class for the ContentVersion Object
				: Changes for Integration to Service Now.
				: 
************************************************************************************************/
public class INTGR_ContentVersion_TriggerHandler
{
    
    public INTGR_ContentVersion_TriggerHandler() 
    {
        
    }
    
    public void OnBeforeInsert(List<ContentVersion> newTrigger)  
    {
        // ONLY DO A DUPLICATE FILE NAME CHECK IN RUNNING USER'S PROFILE IS 'Case Integration Customers'
        if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
        {        
            validateFileNames(newTrigger); 
        }
    }
    
    public void OnAfterInsert(List<ContentVersion> newTrigger)  
    {        
        createConDocLink(newTrigger);
  		doSharing(newTrigger);
    } 
    
    public void OnAfterUpdate(Map<Id, ContentVersion> newMap) 
    {

        Map<Id, Boolean> caseIdVsFlagMap = new Map<Id, Boolean>();
        for (ContentVersion cv : [SELECT CaseId__c, CaseId__r.Update_External_System__c FROM ContentVersion WHERE Id IN : newMap.keySet()])
        {
            if (cv.CaseId__r.Update_External_System__c != null && cv.CaseId__r.Update_External_System__c)
            {
                caseIdVsFlagMap.put(cv.CaseId__c, cv.CaseId__r.Update_External_System__c);
            }
        }
        
        // FOR INBOUND CALLS AND COPY FILE TO STANDARD CASE OBJECT
        copyContentVersion(newMap.values(), caseIdVsFlagMap);
        
        if (caseIdVsFlagMap.size() > 0 && !INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
        {
            // FOR OUTBOUND CALL TO INTEGRATION SYSTEM
            processAfterContentVersionUpdate(newMap.values());  
        }
  
    }
    
    
    // ===================================================================================================================
    // 	FUNCTIONS 
    // ===================================================================================================================
    
    private void validateFileNames(List<ContentVersion> cvList)
    {
        
        // METHOD TO VALIDATE FILE NAMES AND THROW ERROR IF DUPLICATE EXISTS
        
        system.debug(' *** ENTERING INTGR_ContentVersion_TriggerHandler.validateFileNames() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String errorMsg = '';
        List<ContentVersion> cvObjOld = new List<ContentVersion>();
        
        for (ContentVersion cv : cvList)
        {
            
            try
            {
// CYBAGE - SOQL IN FOR LOOP                
                cvObjOld = [SELECT Id FROM ContentVersion WHERE INTGR_Case__c =: cv.INTGR_Case__c AND PathOnClient =: cv.PathOnClient LIMIT 1];
                
                if (cvObjOld.size() > 0)
                {
                    cv.addError('File already Exists. ');
                }
                
            }
            catch (Exception e)
            {
                system.debug(' **** Error Occured: ' + e.getMessage());
            }
            
        }
        
        system.debug(' *** EXITING INTGR_ContentVersion_TriggerHandler.validateFileNames() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void processAfterContentVersionUpdate(List<ContentVersion> newTrigger)
    {
        
        // INITIATE OUTBOUND CALL TO EXTERNAL SYSTEM AFTER UPDATE      
        
        system.debug(' *** ENTERING INTGR_ContentVersion_TriggerHandler.processAfterContentVersionUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        for (ContentVersion cv : newTrigger)
        {
            if (!INTGR_IntegrationHelper.isInsertFiles && cv.CaseId__c != null) 
            {
                initiateIncidentFilesCreate(cv.CaseId__c, cv.Id);
            }
        }
        
        system.debug(' *** EXITING INTGR_ContentVersion_TriggerHandler.processAfterContentVersionUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    private void createConDocLink(List<ContentVersion> newTrigger)
    {
        
        // Create ContentDoclink if Case or Integration Case is created from API
        
        system.debug(' *** ENTERING INTGR_ContentVersion_TriggerHandler.createConDocLink() - QUERIES ISSUED = ' + Limits.getQueries());
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentDocumentLink cdlCopy = new ContentDocumentLink();
        List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
        
        for (ContentVersion cv : newTrigger)
        {

            // IF VERSION IS FOR A STANDARD CASE
            if (cv.CaseId__c != null)
            {
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = cv.CaseId__c;
                cdl.ShareType = 'V';
                cdlInsert.add(cdl);
            }
            
            // IF VERSION IS FOR AN INTEGRATION CASE AND RUNNING USER'S PROFILE IS 'Case Integration Customers'
            if (cv.INTGR_Case__c != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
            {

                // CREATE A DOCUMENT LINK TO INTEGRATION CASE
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = cv.INTGR_Case__c;
                cdl.ShareType = 'V';
                
                // CREATE A DOCUMENT LINK TO RELATED STANDARD CASE
                INTGR_Case__c obj = [SELECT Case__c FROM INTGR_Case__c WHERE Id =: cv.INTGR_Case__c AND Case__c != null LIMIT 1];
                if (obj != null)
                {
                    cdlCopy.ContentDocumentId = cv.ContentDocumentId;
                    cdlCopy.LinkedEntityId = obj.Case__c;
                    cdlCopy.ShareType = 'V';
                }
                
                cdlInsert.add(cdlCopy);
                cdlInsert.add(cdl);
            }
            
        }

        try 
        {
            if (cdlInsert.size() > 0)
            {
                insert cdlInsert;
            }
        }
        catch (Exception e)
        {
            system.debug(' **** Error Occured: ' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_ContentVersion_TriggerHandler.createConDocLink() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void copyContentVersion(List<ContentVersion> newTrigger, Map<Id, Boolean> caseIdVsFlagMap) 
    {
        
        // COPY INTEGRATION CASE FILES TO CASE AND VICE VERSA       
        
        system.debug(' *** ENTERING INTGR_ContentVersion_TriggerHandler.copyContentVersion() - QUERIES ISSUED = ' + Limits.getQueries());

        Map<Id, ContentVersion> intMap = new Map<Id, ContentVersion>();
        Map<Id, ContentVersion> extMap = new Map<Id, ContentVersion>();
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        List<ContentDocumentLink> cdlInsert = new List<ContentDocumentLink>();
        
        for (ContentVersion cv : newTrigger)
        {
            
            if (cv.INTGR_Case__c != null)
            {
            	intMap.put(cv.INTGR_Case__c, cv);
            }
            
            if (cv.CaseId__c != null)
            {
                extMap.put(cv.CaseId__c, cv);
            }
            
        }

        if (intMap.size() > 0)
        {
            for (INTGR_Case__c caseObj : [SELECT Id, case__c FROM INTGR_Case__c WHERE Id IN : intMap.keySet()])
            {
                if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
                {
                    cdl.ContentDocumentId = intMap.get(caseObj.Id).ContentDocumentId;
                    cdl.LinkedEntityId = caseObj.case__c;
                    cdl.ShareType = 'V';
                    cdlInsert.add(cdl);
                }
            }
        }
        
        // TO CHECK IF SYNC FLAG IS TRUE
        if (extMap.size()>0 && caseIdVsFlagMap.size() > 0)
        {
            for (INTGR_Case__c caseObj : [SELECT Id, Case__c, case__r.Update_External_System__c FROM INTGR_Case__c WHERE case__c IN : extMap.keySet()])
            {
                // PREVENT CREATING FILES TO INTEGRATION CASE IF SYNC STATUS FLAG IS FALSE
                if (!INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
                {
                    cdl.ContentDocumentId = extMap.get(caseObj.case__c).ContentDocumentId;
                    cdl.LinkedEntityId =  caseObj.Id;
                    cdl.ShareType = 'V';
                    cdlInsert.add(cdl);
                }
            }            
        }
        
        try 
        {
            // TO CREATE CONTENT DOCUMENT LINK FROM STANDARD CASE TO INTEGRATION CASE AND INTEGRATION CASE TO STANDARD CASE
            if (cdlInsert.size() > 0)
            {
                insert cdlInsert;
            }
        }
        catch (Exception e)
        {
            system.debug(' **** Error occured : ' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_ContentVersion_TriggerHandler.copyContentVersion() - QUERIES ISSUED = ' + Limits.getQueries());

    }
   
    @testvisible  
    private void initiateIncidentFilesCreate(Id parentId, Id fileId) 
    {
        
        // INITIATE OUTBOUND CALL TO SERVICE NOW       
        
        system.debug(' *** ENTERING INTGR_ContentVersion_TriggerHandler.initiateIncidentFilesCreate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> caseIdSet = new Set<Id>();

        caseIdSet.add(parentId);
        INTGR_Case_SOQLDataProvider daoObj = new INTGR_Case_SOQLDataProvider();
        Map<Id, String> idVsReqFormatMap = new Map<Id, String>();
        idVsReqFormatMap = daoObj.getCaseIdVsReqFormatMap(caseIdSet);
        
        if (idVsReqFormatMap.size() > 0 && fileId != null)
        {
            // TO CHECK IF REQUEST FORMAT ON INTEGRATION ACCOUNT IS SOAP
            if (idVsReqFormatMap.get(parentId).equalsIgnoreCase('SOAP')) 
            {
                INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout(fileId);
                INTGR_IntegrationHelper.isInsertFiles = true;
            }
            else 
            {
                // ELSE MAKE REST CALLS
                INTGR_REST_IntegrationHandler.prepareFilesCreateCallout(fileId, '', idVsReqFormatMap.get(parentId));
                INTGR_IntegrationHelper.isInsertFiles = true;
            }
        }
        
        system.debug(' *** EXITING INTGR_ContentVersion_TriggerHandler.initiateIncidentFilesCreate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    private void doSharing(List<ContentVersion> newTrigger)
    {
        
        List<ContentDocumentLink> lstInserts = new List<ContentDocumentLink>();
        
        for (ContentVersion cv : newTrigger)
        {
            if (cv.ShareId__c != null)
            {    
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = Id.valueOf(cv.ShareId__c);
                cdl.ShareType = 'V';   
                insert cdl;
            }
        }
        
    }
    
}