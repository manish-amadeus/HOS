/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_IntegrationHelper
Author          : Princy Jain
Created Date    : 04/23/2018
Last Mod Date   : 01/11/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class which will interact with Integration layer to create incident in customer system.
                : Updated per NICC-039247
************************************************************************************************/
public class INTGR_IntegrationHelper
{
    
    // UTILITY VARIABLES
    
    // VARIABLE THAT CLASSES CAN REFER TO TO GET RUNNING USER'S PROFILE NAME
    public static String uProfileName = [SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserId()][0].Profile.Name;
    // VARIABLE THAT STORES VALID INTEGRATION USER PROFILE NAME
    public static final String INT_PROFILENAME = 'Case Integration Customers';
	public static Map<Id, INTGR_Account__c> intAccidVsAcc = new Map<Id, INTGR_Account__c>(); // INTGR_Case_SOQLDataProvider.getIntAccIdVsAccMap();
    public static Map<Id, INTGR_Account__c> allIntAccIdVsAcc = INTGR_Case_SOQLDataProvider.getAllIntAccMap();
	public INTGR_Case_SOQLDataProvider daoObj = new INTGR_Case_SOQLDataProvider();
    
	// BOOLEAN LOGIC VARIABLES
    public static boolean isInsertIncident = false;
    public static boolean isUpdateIncident = false;
    public static boolean isInsertCaseComment = false;
    public static boolean isUpdateSFCase = false;
    public static boolean isInsertFiles = false;
    public static boolean isUpdateContentVersion = false;
    
    // BYPASS LOGIC VARIABLES
    public static boolean isICFlow = false;
    public static boolean isCCFromSC = false;    
    public static boolean isICCFlow = false;    
    public static boolean isUpdateOncaseFlags = false;    
    private static boolean run = true;
    public static boolean runOnce()
    {
        if (run)
        {
            run = false;
            return true;
        }
        else
        {
            return run;
        }
    }
    

    public INTGR_IntegrationHelper() 
    {
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
   		INTGR_Case_SOQLDataProvider obj = new INTGR_Case_SOQLDataProvider();
    	intAccidVsAcc = obj.getIntAccIdVsAccMap();
        
        system.debug(' *** EXITING INTGR_IntegrationHelper CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public static String getFormattedComment(DateTime inDateTime)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018
        // Param: Set of integration case id after insert trigger
        // Description: To format case comment as per given format.
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.getFormattedComment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        TimeZone tz = UserInfo.getTimeZone();
        string dateTimeStr = inDateTime.format('yyyy-MM-dd HH:mm:ss', tz.toString());
        Datetime localDateTime = DateTime.valueOf(dateTimeStr);
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.getFormattedComment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return localDateTime + '';
        
    }
    
    public static NI_Integration_Log__c createNIIntegraionLog(String caseID, String intCaseId, String intCaseCommId, String message, String status, String traType, String updateFor, String endPoint, String intName, String requestBody) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Return: Integration log object for error logging
        // Description: Method for Integration log creation.
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.createNIIntegraionLog() - QUERIES ISSUED = ' + Limits.getQueries());
        
        NI_Integration_Log__c niLog = new NI_Integration_Log__c();
        
        //niLog.Name = 'NI Integration Log - ' + Datetime.now().format();
        niLog.Name = 'NI Integration Log - ' + DateTime.now().format('MM/dd/yyyy hh:mm a', 'GMT') + ' GMT';
        niLog.Case__c = caseID;
        niLog.Integration_Case_Comment__c = intCaseCommId;
        niLog.Description__c = message;
        niLog.Integration_Case__c = intCaseId;
        niLog.Log_Date__c = Datetime.now();
        niLog.Status__c = status;
        niLog.Transaction_Type__c = traType;
        niLog.Web_Service_Endpoint__c = endPoint;
        niLog.Integration_Name__c = intName;
        
        if (requestBody != null) 
        {
            niLog.XMLRequest__c = requestBody.escapeXML();
        }
        else
        {
            niLog.XMLRequest__c = '';
        }
        
        if (status == 'Failed') 
        {
            niLog.Do_Retries__c = true;
            niLog.Retries_Performed__c = 0;
        }
        
        if (updateFor != null) 
        {
            niLog.UpdateFor__c = updateFor;
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.createNIIntegraionLog() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return niLog;
        
    }

    public void initiate_IncidentCreateRequestToServiceNow(Set<Id> recordIdSet, String operationName) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Set of integration case id after insert trigger and operation Name   
        // Description: Method being called from Integration case Handler to initiate outbound call to Service Now.        
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, String> caseIdVsReqFormatMap = new Map<Id, String>();
        
        caseIdVsReqFormatMap = daoObj.getCaseIdVsReqFormatMap(recordIdSet);
        
        if (caseIdVsReqFormatMap.size() > 0)
        {
            for (Id recordId: recordIdSet)
            {
                if (caseIdVsReqFormatMap.get(recordId).equalsIgnoreCase('SOAP')) 
                {
                    INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout(recordId, 'INTGR_Case__c', operationName);
                    INTGR_IntegrationHelper.isUpdateSFCase = true;
                } 
                else 
                {
                    if (operationName.equalsIgnoreCase('update') && !INTGR_IntegrationHelper.isUpdateIncident) 
                    {
                        INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest(recordId, 'INTGR_Case__c');
                    } 
                    else 
                    {
                        INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest(recordId);
                        INTGR_IntegrationHelper.isUpdateSFCase = true;
                    }
                }
            }
        }
        
        system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow');
        system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow');
        system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow');
        system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow');
        system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow');
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.initiate_IncidentCreateRequestToServiceNow() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void initiate_IncidentCommCreateRequestToServiceNow(Set<Id> recordIdSet) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Set of integration case id after insert trigger     
        // Description: Method being called from Integration case Handler to initiate ouitbound call to Service Now. 
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, String> caseIdVsReqFormatMap = new Map<Id, String>();
        caseIdVsReqFormatMap = INTGR_Case_SOQLDataProvider.getCaseCommIdVsReqFormatMap(recordIdSet);
        
        if (caseIdVsReqFormatMap.size() > 0)
        {
            for (Id recordId : recordIdSet) 
            {
                if (caseIdVsReqFormatMap.get(recordId).equalsIgnoreCase('SOAP')) 
                {
                    INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout(recordId, 'INTGR_Case_Comment__c', 'insert');
                } 
                else 
                {
                    if (!INTGR_IntegrationHelper.isInsertCaseComment) 
                    {
                        INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest(recordId, 'INTGR_Case_Comment__c');
                    }
                }
            }
        }
        
        system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow');
        system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow');
        system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow');
        system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow');
        system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow');
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.initiate_IncidentCommCreateRequestToServiceNow() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public static void initiateResendFailedRecordsToSN(Map<Id, NI_Integration_Log__c> mapNiIntLog, Map<Id, Id> mapLogCaseIdsCreate, Map<Id, Id> mapLogCaseIdsUpdate, Map<Id, Id> mapIntCaseCommCreate, Map<Id, Id> mapIntFilesCreate) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Map of logid and Object, Map of caseIdvsLogid, Map of CaseCommIdVsLogid, Map Of filesIdVsLogid    
        // Description: Method being From ServiceNow Resend Batch to Retry failed request
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.initiateResendFailedRecordsToSN() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Http objhttp = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
        Map<String, String> mapParseRes = new Map<String, String>();
        Map<String, String> mapRequest = new Map<String, String>();
        Map<String, String> mapResHeader = new Map<String, String>();
        List<INTGR_Case__c> resUpdateCase = new List<INTGR_Case__c>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        //MAP OF LOG ID AND ATTACHMENT
        Map<Id, ContentVersion> mapLogAttach = new Map<Id, ContentVersion>();
        
        List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
        List<NI_Integration_Log_Message__c> reqExceptionLogMsg = new List<NI_Integration_Log_Message__c>();
        List<Id> resUpdateLog = new List<Id>();
        List<Id> resFailedLog = new List<Id>();
        String request = '';
        HttpRequest requestOne = new HttpRequest();
        
        Map<Id, ContentVersion> mapAttach = new Map<Id, ContentVersion>();
        Map<Id, INTGR_Case__c> caseMap = new Map<Id, INTGR_Case__c>();
        Set<Id> fileIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();
        
        if (mapIntFilesCreate.size() > 0) 
        {
            for (Id niLog: mapIntFilesCreate.keyset()) 
            {
                if (niLog != null) 
                {
                    fileIdSet.add(niLog);
                    caseIdSet.add(mapNiIntLog.get(mapIntFilesCreate.get(niLog)).case__c);
                }
            }
        }
        
        //FETCH ALL THE ATTACHMENTS WHICH GOT FAILED AND PUT IN A MAP
        if (!fileIdSet.isEmpty()) 
        {
            mapAttach = new Map<Id, ContentVersion>([SELECT Id, CaseId__c, Title, VersionData, FileExtension 
                                                     FROM ContentVersion 
                                                     WHERE (Id IN : fileIdSet OR ContentDocumentId IN : fileIdSet OR INTGR_Case__c IN : caseIdSet)]);
            system.debug(' **** mapAttach' + mapAttach);
        }
        
        // FETCH ALL THE INTEGRATION CASE COMMENTS FAILED AND PUT IT IN A MAP
        Map<Id, INTGR_Case_Comment__c> caseCommMap = new Map<Id, INTGR_Case_Comment__c>();
        Map<Id, Id> commIdCaseIdMap = new Map<Id, Id>();
        
        if (mapIntCaseCommCreate.size() > 0) 
        {
            for (INTGR_Case_Comment__c comm: [SELECT Id, CommentBody__c,CreatedDate, Customer_Ticket_System_Id__c, CreateDate__c, INTGR_Case__c, INTGR_Case__r.Case__r.Update_External_System__c 
                                              FROM INTGR_Case_Comment__c 
                                              WHERE Id IN : mapIntCaseCommCreate.keySet()]) 
            {
                commIdCaseIdMap.put(comm.Id, comm.INTGR_Case__c);
                caseCommMap.put(comm.Id, comm);
            }
            system.debug(' **** commIdCaseIdMap = ' + commIdCaseIdMap);
        }
        
        //GET Customer_Ticket_System_Id__c OF CASES IN ORDER TO SEND WITH REQUEST
        if (mapLogCaseIdsCreate.size() > 0 || mapLogCaseIdsUpdate.size() > 0 || mapIntFilesCreate.size() > 0 || mapIntCaseCommCreate.size() > 0) 
        {
            caseMap = new Map<Id, INTGR_Case__c> ([SELECT Id,
                                                   Case__c,
                                                   Case__r.Update_External_System__c,
                                                   Description__c,
                                                   Error_Message__c,
                                                   INTGR_Account__c,
                                                   INTGR_Account__r.RequestFormat__c,
                                                   INTGR_Account__r.Max_Count_To_Resend_Failed_Message__c,
                                                   INTGR_Account__r.Integration_User__c,
                                                   INTGR_Account__r.Integration_Endpoint__c,
                                                   INTGR_Account__r.ImportSet_Endpoint__c,
                                                   INTGR_Account__r.External_System_Username__c,
                                                   INTGR_Account__r.External_System_Password__c,
                                                   INTGR_Account__r.External_Integration_System_Name__c,
                                                   INTGR_Account__r.External_Integration_Name__c,
                                                   INTGR_Account__r.Attachment_Endpoint__c,
                                                   Severity__c,
                                                   Status__c,
                                                   Subject__c,
                                                   Affected_Service__c,
                                                   Assignment_Group__c,
                                                   Hotel_Code__c,
                                                   System_Affected__c,
                                                   Customer_Name__c,
                                                   Customer_Ticket_Number__c,
                                                   Customer_Ticket_System_Id__c
                                                   FROM INTGR_Case__c
                                                   WHERE Id IN: mapLogCaseIdsCreate.keySet() OR Id IN: mapLogCaseIdsUpdate.keySet() OR Case__c IN: caseIdSet OR Id IN: commIdCaseIdMap.values()
                                                  ]);
        }
        
        
        if (mapNiIntLog.size() > 0) 
        {
            
            INTGR_IntegrationHelper servNowHelper = new INTGR_IntegrationHelper();
            INTGR_REST_IntegrationHandler restHandler = new INTGR_REST_IntegrationHandler();
            
            for (NI_Integration_Log__c niLog: mapNiIntLog.values()) 
            {
                try 
                {
                    if (niLog.UpdateFor__c == 'ContentVersion') 
                    {
                        INTGR_IntegrationHelper.isInsertFiles = false;
                        for (ContentVersion at : mapAttach.values()) 
                        {
                            if (niLog.File_Id__c == at.Id) 				// NICC-039247
                            {
                                // IF CASES MAP CONTAINS CASE ID THEN ONLY PROCEED FURTHER
                                INTGR_Case__c caseObj = caseMap.get(mapNiIntLog.get(niLog.id).Integration_Case__c);
                                mapLogAttach.put(mapIntFilesCreate.get(at.Id), at);
                                HttpRequest req1 = new HttpRequest();
                                
                                if (caseObj != null) 
                                {
                                    INTGR_IntegrationHelper.isInsertFiles = true;
                                    String userNamePwd = caseObj.INTGR_Account__r.External_System_Username__c + ':' + caseObj.INTGR_Account__r.External_System_Password__c;
                                    String fileName = at.Title.replaceAll('\\s+', '') + '.' + at.FileExtension;
                                    String attEndPointURL = caseObj.INTGR_Account__r.Attachment_Endpoint__c + '=incident&table_sys_id=' + caseObj.Customer_Ticket_System_Id__c + '&file_name=' + EncodingUtil.urlEncode(fileName, 'UTF-8');
                                    
                                    //CREATING REQUEST - POST ATTACHMENT
                                    req1 = servNowHelper.Servicenow_SetHeaderForFiles(req1, 'POST', attEndPointURL, userNamePwd);
                                    req1.setBodyAsBlob(at.VersionData);
                                    Http h = new Http();
                                    res = h.send(req1);

                                }
                                //request = req1.getBody();
                            }
                        }
                        
                    }
                    
                    if (niLog.UpdateFor__c == 'INTGR_Case__c' && niLog.Transaction_Type__c.equalsIgnoreCase('Insert')) 
                    {
                        INTGR_IntegrationHelper.isInsertIncident = false;
                        if (mapLogCaseIdsCreate.size() > 0) 
                        {
                            for (Id intCaseId: mapLogCaseIdsCreate.keySet()) 
                            {
                                INTGR_Case__c intCaseObj = caseMap.get(intCaseId);
                                if (intCaseObj != null) 
                                {
                                    INTGR_IntegrationHelper.isInsertIncident = true;
                                    //Flag for updating Case object with SysId and Inegration ticket No.
                                    INTGR_IntegrationHelper.isUpdateSFCase = false;
                                    
                                    if (intCaseObj.Customer_Ticket_System_Id__c == null) 
                                    {
                                        String uNamePwd = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
                                        String intEndPointURL = intCaseObj.INTGR_Account__r.Integration_Endpoint__c;
                                        String reqBody = restHandler.generateIntegrationRequestBody('XML', intCaseObj, INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseObj.INTGR_Account__c, 'INTGR_Case__c'));
                                        mapRequest.put(niLog.Id, reqBody);
                                        res = servNowHelper.Servicenow_Post_IncidentRequest(uNamePwd, intEndPointURL, reqBody, 'POST');
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    if (niLog.UpdateFor__c == 'INTGR_Case__c' && niLog.Transaction_Type__c.equalsIgnoreCase('Update')) 
                    {
                        INTGR_IntegrationHelper.isUpdateIncident = false;
                        
                        if (mapLogCaseIdsUpdate.size() > 0) 
                        {
                            for (Id intCaseIdUpdate: mapLogCaseIdsUpdate.keySet()) 
                            {
                                INTGR_Case__c intCaseObj = caseMap.get(intCaseIdUpdate);
                                
                                if (intCaseObj != null) 
                                {
                                    INTGR_IntegrationHelper.isUpdateIncident = true;
                                    
                                    if (intCaseObj.Customer_Ticket_System_Id__c != null) 
                                    {
                                        String uNamePwd = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
                                        String intEndPointURL = intCaseObj.INTGR_Account__r.Integration_Endpoint__c + '/' + intCaseObj.Customer_Ticket_System_Id__c;
                                        String reqBody = restHandler.generateIntegrationRequestBody('XML', intCaseObj, INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseObj.INTGR_Account__c, 'INTGR_Case__c'));
                                        mapRequest.put(niLog.Id, reqBody);
                                        res = servNowHelper.Servicenow_Post_IncidentRequest(uNamePwd, intEndPointURL, reqBody, 'PUT');
                                    }
                                }
                            }
                        }
                    }
                    
                    if (niLog.UpdateFor__c == 'INTGR_Case_Comment__c' && niLog.Transaction_Type__c.equalsIgnoreCase('Insert')) 
                    {
                        INTGR_IntegrationHelper.isInsertCaseComment = false;
                        if (mapIntCaseCommCreate.size() > 0) 
                        {
                            for (Id commId : mapIntCaseCommCreate.keySet()) 
                            {
                                INTGR_Case_Comment__c intCommObj = caseCommMap.get(commId);
                                INTGR_Case__c intCaseObj1 = caseMap.get(mapNiIntLog.get(niLog.id).Integration_Case__c);
                                
                                if (intCaseObj1 != null && intCaseObj1.Customer_Ticket_System_Id__c != null) 
                                {
                                    INTGR_IntegrationHelper.isInsertCaseComment = true;
                                    String uNamePwd = intCaseObj1.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj1.INTGR_Account__r.External_System_Password__c;
                                    String intEndPointURL = intCaseObj1.INTGR_Account__r.Integration_Endpoint__c + '/' + intCaseObj1.Customer_Ticket_System_Id__c;
                                    
                                    //FORMAT CASE COMMENT BODY
                                    if (intCommObj.CreateDate__c != null)
                                    {
                                        String createdDate = INTGR_IntegrationHelper.getFormattedComment(intCommObj.CreateDate__c );
                                        intCommObj.CommentBody__c = '-- [Created By Amadeus ' + createdDate +'] \n     ' + intCommObj.CommentBody__c ;
                                    } 
                                    else 
                                    {
                                        intCommObj.CommentBody__c = '-- [Created By Amadeus ' + intCommObj.createddate +'] \n     ' + intCommObj.CommentBody__c ;
                                    }
                                    String reqBody = restHandler.generateIntegrationRequestBody('XML', intCommObj, INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseObj1.INTGR_Account__c, 'INTGR_Case_Comment__c'));
                                    mapRequest.put(niLog.Id, reqBody);
                                    res = servNowHelper.Servicenow_Post_IncidentRequest(uNamePwd, intEndPointURL, reqBody, 'PUT');
                                }
                            }
                        }
                    }
                    
                    mapRetriesID.put(niLog.Id, Integer.valueOf(niLog.Retries_Performed__c));
                    mapParseRes.put(niLog.Id, res.getBody());
                    mapResHeader.put(niLog.Id, res.getStatus());                    
                    
                } 
                catch (exception e) 
                {
                    
                    String strdate = Datetime.now().format('YYYY-MM-dd-hh-mm-ss');
                    String strError = '';
                    String endPoint = '';
                    List<String> arrParsed = strdate.split('-');
                    DateTime expected = DateTime.newInstance(Integer.valueOf(arrParsed.get(0)), Integer.valueOf(arrParsed.get(1)), Integer.valueOf(arrParsed.get(2)), Integer.valueOf(arrParsed.get(3)), Integer.valueOf(arrParsed.get(4)), Integer.valueOf(arrParsed.get(5)));
                    
                    strError += 'Error Details: \n';
                    strError += e.getMessage();
                    
                    system.debug(strError);
                    system.debug('e.getMessage()' + e.getMessage() + '+e.getStackTraceString()' + e.getStackTraceString());
                    
                    NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
                    nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(niLog.Id), '', '', 'Failed', strError, '');
                    resFailedLog.add(niLog.Id);
                    reqExceptionLogMsg.add(nException);
                    
                }
                finally 
                {
                    system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                    system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                    system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                    system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                    system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                    
                }
            }
            
            if (!mapParseRes.isEmpty()) 
            {
                for (String lID : mapParseRes.keySet()) 
                {
                    try 
                    {
                        
                        if (mapLogCaseIdsUpdate.size() > 0) 
                        {
                            servNowHelper.parseAndLogSNResponseBatch(lId, mapNiIntLog.get(lId).Integration_Case__c, mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase, resInsertLogMsg, resUpdateLog, resFailedLog, '');
                        }
                        
                        if (mapIntCaseCommCreate.size() > 0) 
                        {
                            servNowHelper.parseAndLogSNResponseBatch(lId, mapNiIntLog.get(lId).Integration_Case__c, mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase, resInsertLogMsg, resUpdateLog, resFailedLog, '');
                        }
                        
                        if (mapIntFilesCreate.size() > 0) 
                        {
                            servNowHelper.parseAndLogSNResponseBatch(lId, mapNiIntLog.get(lId).Integration_Case__c, mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase, resInsertLogMsg, resUpdateLog, resFailedLog, '');
                        }
                        
                        if (mapLogCaseIdsCreate.size() > 0) 
                        {
                            servNowHelper.parseAndLogSNResponseBatch(lId, mapNiIntLog.get(lId).Integration_Case__c, mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase, resInsertLogMsg, resUpdateLog, resFailedLog, 'intCaseInsert');
                        }
                        
                        //servNowFun.parseAndLogResponseBatch(mapParseRes.get(lID),lID,servNowFun.importSetEndPoint,'Update','Case',resUpdateCase,resInsertLog,mapXMLrequest.get(cId), new List<Task>());
                        
                    } 
                    catch (Exception e) 
                    {
                        // In case if there is an error while parsing then bach apex continue untill desired condition met.
                        // putting an exception in error log.
                        String strError = 'Error Details: \n';
                        strError += e.getMessage() + ' ' + e.getStackTraceString();
                        
                        System.debug(strError);
                        
                        NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
                        nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(lID), '', '', 'Failed', strError, '');
                        resFailedLog.add(lID);
                        reqExceptionLogMsg.add(nException);
                        
                    }
                    finally 
                    {
                        system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                        system.debug(' ***  HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                        system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                        system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                        system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_IntegrationHelper.initiateResendFailedRecordsToSN');
                    }
                }
            }
            
            // Update Cases with record_id
            if (resUpdateCase.size() > 0) 
            {
                update resUpdateCase;
            }
            
            // Insert NI_Integration_Log_Message
            if (resInsertLogMsg.size() > 0) 
            {
                Map<Id, NI_Integration_Log_Message__c> temp = new Map<Id, NI_Integration_Log_Message__c>();
                for (NI_Integration_Log_Message__c logMsg : resInsertLogMsg) 
                {
                    if (!temp.containsKey(logMsg.Id)) 
                    {
                        temp.put(logMsg.Id, logMsg);
                    }
                }
                
                if (temp.size() > 0) 
                {
                    insert temp.values();
                }
            }
            
            if (reqExceptionLogMsg.size() > 0) 
            {
                insert reqExceptionLogMsg;
            }
            
            // Update NI_Integration Log for the sucessful messages
            if (resUpdateLog.size() > 0) 
            {
                List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();
                
                for (ID iLog : resUpdateLog) 
                {
                    NI_Integration_Log__c nLog = new NI_Integration_Log__c();
                    nlog.Id = iLog;
                    
                    //For sucessful log no need to do retries               
                    if (!nlog.isRetry__c) 
                    {
                        nlog.Do_Retries__c = false;
                    }
                    
                    nlog.Status__c = 'Success';
                    nlog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1;
                    lstLog.add(nlog);
                    
                }
                
                if (lstLog.size() > 0) 
                {
                    
                    Map<Id, NI_Integration_Log__c> tempLog1 = new Map<Id, NI_Integration_Log__c>();
                    
                    for (NI_Integration_Log__c log : lstLog)
                    {
                        if (!tempLog1.containsKey(log.Id)) 
                        {
                            tempLog1.put(log.Id, log);
                        }
                    }
                    
                    if (tempLog1.size() > 0) 
                    {
                        update tempLog1.values();
                    }
                    
                }
            }
            
            //Update NI_Integration Log for the failed messages
            
            if (resFailedLog.size() > 0) 
            {
                List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();
                
                for (Id iLog : resFailedLog) 
                {
                    
                    NI_Integration_Log__c nLog = new NI_Integration_Log__c();
                    nlog.Id = iLog;
                    
                    //Custom setting reffered for no. of tries //keeping CS it for now
                    // Null check on custom setting as part of sprint S-00112 
                    //if (ServiceNowSettings != null){
                    if (mapRetriesID.containsKey(iLog) && (Integer.valueOf(mapRetriesID.get(iLog)) + 1) >= Integer.valueOf(ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c) ) 
                    {
                        nlog.Do_Retries__c = false;
                    } 
                    else 
                    {
                        nlog.Do_Retries__c = true;
                    }
                    //}
                    
                    if (mapRetriesID.containsKey(iLog)) 
                    {
                        nlog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1;
                    }
                    
                    lstLog.add(nlog);
                    
                }
                
                if (lstLog.size() > 0) 
                {
                    
                    Map<Id, NI_Integration_Log__c> tempLog = new Map<Id, NI_Integration_Log__c>();
                    
                    for (NI_Integration_Log__c log : lstLog) 
                    {
                        if (!tempLog.containsKey(log.Id)) 
                        {
                            tempLog.put(log.Id, log);
                        }
                    }
                    
                    if (tempLog.size() > 0)
                    {
                        update tempLog.values();
                    }
                    
                }
            }
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.initiateResendFailedRecordsToSN() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public HttpRequest Servicenow_SetHeaderForFiles(HttpRequest req, String reqType, String queryParams, string uNamePwd) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Parameters being used for making outbound call.      
        // Return: Request Object with all header info   
        // Description: Method being called for setting files header
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.Servicenow_SetHeaderForFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String auth_header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(uNamePwd));
        req.setHeader('Authorization', auth_header);
        req.setEndpoint(queryParams);
        req.setHeader('Accept', 'application/xml,*.*');
        req.setHeader('Content-Type', 'multipart/form-data');
        req.setMethod(reqType);
        req.setTimeout(120000);
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.Servicenow_SetHeaderForFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return req;
        
    }

    public HttpResponse Servicenow_Post_IncidentRequest(String userNamePwd, String endPointUrl, String requestBody, String reqType) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Parameters being used for making outbound call.  
        // Return: Callout Response   
        // Description: Method for making HTTP callouts
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.Servicenow_Post_IncidentRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Http objhttp = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req = Servicenow_Set_Header(req, userNamePwd, endPointUrl, reqType);
        req.setBody(requestBody);
        res = objhttp.send(req);
        system.debug(res.getHeader('Location'));
        system.debug(res.getBody());
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.Servicenow_Post_IncidentRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return res;
        
    }

    public HttpRequest Servicenow_Set_Header(HttpRequest req, String userNamePwd, String endPointUrl, String reqType) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Params for callout    
        // Return: HttpRequest
        // Description: To set HttpHeader for outbound request
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.Servicenow_Set_Header() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Blob headerValue = Blob.valueOf(userNamePwd);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type', 'application/xml');
        req.setHeader('Accept', 'application/xml');
        req.setTimeout(120000);
        
        if (reqType == 'POST') 
        {
            req.setEndpoint(endPointUrl);
            req.setMethod('POST');
        }
        
        if (reqType == 'PUT') 
        {
            req.setEndpoint(endPointUrl);
            req.setMethod('PUT');
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.Servicenow_Set_Header() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return req;
        
    }

    public void parseAndLogSNResponseBatch(String logId, String cs, String reqBody, String response, String resHeader, List<INTGR_Case__c> resUpdateCase, List<NI_Integration_Log_Message__c> resInsertLogMsg, List<Id> resUpdateLog, List<Id> resFailedLog, string operationName) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: logid, caseid, requestbody, response, response status, list of Integration case, List of logObj, operation name   
        // Description: Method to parse response after retry attempt        
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.parseAndLogSNResponseBatch() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        dom.Document resDoc = new dom.Document();
        
        NI_Integration_Log_Message__c niLog = new NI_Integration_Log_Message__c();
        dom.XmlNode envelope = null;
        dom.XmlNode header = null;
        dom.XmlNode createResponse = null;
        dom.XmlNode fault = null;
        dom.XmlNode updateResponse = null;
        String unauthorized = null;
        
        try 
        {
            
            resDoc.load(response);
            envelope = resDoc.getRootElement();
            dom.XmlNode resultNode = envelope.getChildElement('result', null);
            
            if (!resHeader.equalsIgnoreCase('Created') && !resHeader.equalsIgnoreCase('OK')) 
            {
                
                if (envelope.getChildElement('error', null) != null) 
                {
                    niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Failed', '', resHeader);
                    resInsertLogMsg.add(niLog);
                    resFailedLog.add(Id.valueOf(logId));
                }
            } 
            else 
            {
                
                String ticketNumber = '';
                String sysId = '';
                String retStatus = '';
                
                if (resultNode.getChildElement('number', null) != null)
                {
                    ticketNumber = resultNode.getChildElement('number', null).getText();
                }
                
                if (resultNode.getChildElement('sys_id', null) != null) 
                {
                    sysId = resultNode.getChildElement('sys_id', null).getText();
                }
                
                if (resultNode.getChildElement('status', null) != null) 
                {
                    retStatus = envelope.getChildElement('status', null).getText();
                }
                
                if (ticketNumber != null && sysId != null && operationName.equalsIgnoreCase('intCaseInsert')) 
                {
                    // UPDATE THE CASE WITH SETTING VALUE FOR EXTERNEL SYSTEM ID 
                    INTGR_Case__c cCase = new INTGR_Case__c();
                    cCase.id = cs;
                    cCase.Customer_Ticket_Number__c = ticketNumber;
                    cCase.Customer_Ticket_System_Id__c = sysId;
                    //cCase.Update_External_System__c = true;
                    resUpdateCase.add(cCase);
                    INTGR_IntegrationHelper.isInsertCaseComment = true;
                    INTGR_IntegrationHelper.isInsertFiles = true;
                    INTGR_IntegrationHelper.isUpdateSFCase = true;
                    // NI_ServicenowIntegration.updateAttCaseCmtSN = true;
                }
                
                niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Successful', '', resHeader);
                resInsertLogMsg.add(niLog);
                resUpdateLog.add(logId);
                
            }
            
        } 
        catch (Exception e) 
        {
            niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Failed', '', resHeader);
            resInsertLogMsg.add(niLog);
            resFailedLog.add(Id.valueOf(logId));
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.parseAndLogSNResponseBatch() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public static void populateIntegrationAccountOnCase(List<Case> newTrigger)
    {
        
        // Author: Princy Jain
        // Date: 07/10/2018   
        // Param: New Case List  
        // Description: Populates Integration Account lookup on case object.
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.populateIntegrationAccountOnCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, Id> intAccMap = new Map<Id, Id>();
        String recName = 'CRS Incident';
        String caseRTName = '';
        
        //POPULATE MAP W.R.T. ACCOUNT ID AND INTEGRATION ACCOUNT ID
        for (INTGR_Account__c acc : [SELECT Id, Account__c FROM INTGR_Account__c WHERE Active__c = true])
        {
            if (acc.Account__c != null)
            {
                intAccMap.put(acc.Account__c, acc.Id);
            }
        }
        
        for (Case c : newTrigger)
        {
            
            caseRTName = Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname();
            
            // CHECK CASE RT AND POPULATE INTEGRATION ACCOUNT LOOKUP IF NULL
            if (caseRTName.equalsIgnoreCase (recName))
            {
                if (c.Integration_Account__c == null) 
                {
                    c.Integration_Account__c = intAccMap.get(c.AccountId);
                }
            }
            
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.populateIntegrationAccountOnCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public static void upsertIntegrationCase(Map<Id, Case> caseObjMap, boolean isInsert, boolean isUpdate, Map<Id, Case> oldCaseMap)
    {    
        
        // Author: Princy Jain
        // Date: 07/10/2018  
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.upsertIntegrationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<INTGR_Case__c> intCaseInsert = new List<INTGR_Case__c>();
        List<INTGR_Case__c> intCaseUpdate = new List<INTGR_Case__c>();
        INTGR_Case__c intCaseObj = new INTGR_Case__c();
        
        List<INTGR_Case__c> lstExistingCases = INTGR_Case_SOQLDataProvider.getICdetails(caseObjMap.keySet());
        
        // FAIL SAFE CHECK TO AVOID DUPLICATE INTEGRATION CASE FOR THE SAME CASE
        if (isInsert && lstExistingCases.isEmpty())
        {
            for (Case cCR : caseObjMap.values())
            {
                intCaseObj.Case__c = cCR.Id; 
                intCaseObj.Description__c = cCR.Description;
                intCaseObj.Hotel_Code__c = cCR.Hotel_Code__c;
                intCaseObj.Severity__c = cCR.Customer_Severity__c;
                intCaseObj.Subject__c = cCR.Subject;
                intCaseObj.Status__c = cCR.Status;
                intCaseObj.Assignment_Group__c = cCR.Amadeus_ExternalSystemAssigneeGroup__c;
                intCaseObj.Customer_Name__c = cCR.Customer_Name__c;
                intCaseObj.System_Affected__c = cCR.System_Affected__c;
                intCaseObj.Affected_Service__c = cCR.Affected_Service__c;

                // !NEW
                intCaseObj.Work_Around_Available__c = cCR.Work_Around_Available__c;
                intCaseObj.Workaround_Provided_Date__c = cCR.Workaround_Provided_Date__c;
                intCaseObj.Workaround_Rejected_Date__c = cCR.Workaround_Rejected_Date__c;    
                intCaseObj.IsOperationalIssue__c = cCR.IsOperationalIssue__c;   

                if (cCR.Integration_Account__c != null)
                {
                    intCaseObj.INTGR_Account__c = cCR.Integration_Account__c;
                }
                
                intCaseInsert.add(intCaseObj);
            }
        }
        else
        {            
            for (INTGR_Case__c intCase : lstExistingCases)
            {
                if (!intCase.Status__c.containsIgnoreCase('Closed'))
                {
                    intCase.Description__c = caseObjMap.get(intCase.Case__c).Description;
                    intCase.Hotel_Code__c = caseObjMap.get(intCase.Case__c).Hotel_Code__c;
                    intCase.Severity__c = caseObjMap.get(intCase.Case__c).Customer_Severity__c;
                    intCase.Status__c = caseObjMap.get(intCase.Case__c).Status;
                    intCase.Subject__c = caseObjMap.get(intCase.Case__c).Subject;
                    intCase.Assignment_Group__c = caseObjMap.get(intCase.Case__c).Amadeus_ExternalSystemAssigneeGroup__c;
                    intCase.Customer_Name__c = caseObjMap.get(intCase.Case__c).Customer_Name__c;
                    intCase.System_Affected__c = caseObjMap.get(intCase.Case__c).System_Affected__c;
                    intCase.Affected_Service__c = caseObjMap.get(intCase.Case__c).Affected_Service__c;

                    // !NEW
                    intCase.Work_Around_Available__c = caseObjMap.get(intCase.Case__c).Work_Around_Available__c;
                    intCase.Workaround_Provided_Date__c = caseObjMap.get(intCase.Case__c).Workaround_Provided_Date__c;
                    intCase.Workaround_Rejected_Date__c = caseObjMap.get(intCase.Case__c).Workaround_Rejected_Date__c;
                    intCase.IsOperationalIssue__c = caseObjMap.get(intCase.Case__c).IsOperationalIssue__c;   

                    if (caseObjMap.get(intCase.Case__c).Integration_Account__c != null)
                    {
                        intCase.INTGR_Account__c = caseObjMap.get(intCase.Case__c).Integration_Account__c;
                    }
                    
                    if (intCase.Customer_Ticket_System_Id__c == null && caseObjMap.get(intCase.Case__c).INTGR_Customer_Ticket_System_Id__c != null) 
                    {
                        intCase.Customer_Ticket_System_Id__c = caseObjMap.get(intCase.Case__c).INTGR_Customer_Ticket_System_Id__c;
                    }
                    
                    if (intCase.Customer_Ticket_Number__c == null && caseObjMap.get(intCase.Case__c).Customer_Ticket_Number__c != null) 
                    {
                        intCase.Customer_Ticket_Number__c = caseObjMap.get(intCase.Case__c).Customer_Ticket_Number__c;
                    }

                    intCaseUpdate.add(intCase);
                    
                }
            }
        }
        
        try 
        {
            if (intCaseInsert.size() > 0)
            {
                insert intCaseInsert;
            }
            if (intCaseUpdate.size() > 0)
            {
                update intCaseUpdate;
            }
        }
        catch (Exception ex)
        {
            system.debug ('Exception Occurred: ' + ex.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.upsertIntegrationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public static void shareIntegrationCase(Set<Id> intCaseId, Id userId)
    {
        
        // Author: Princy Jain
        // Date: 07/10/2018  
        
        system.debug(' *** ENTERING INTGR_IntegrationHelper.shareIntegrationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<INTGR_Case__Share> caseShareList = new List<INTGR_Case__Share>();
        INTGR_Case__Share caseShareObj = new INTGR_Case__Share();
        
        for (Id caseId : intCaseId)
        {
            caseShareObj.ParentId = caseId;
            caseShareObj.RowCause = 'Manual';
            caseShareObj.UserOrGroupId = userId;
            caseShareObj.AccessLevel = 'Edit';
            caseShareList.add(caseShareObj);
        }
        
        try
        {
            if (caseShareList.size() > 0)
            {
                insert caseShareList;
            }
        }
        catch (Exception ex)
        {
            system.debug ('Error Occured While sharing the object: ' + ex.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_IntegrationHelper.shareIntegrationCase() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    //@future (callout=true)
    public static void createCustomerIncident(Id caseId, Set<Id> setCCmtIds, Set<Id> setCVerIds)
    {
        
        Case sc = [SELECT Id, Subject, Status, Description, Hotel_Code__c, Customer_Name__c, Customer_Severity__c, 
                   Amadeus_ExternalSystemAssigneeGroup__c, System_Affected__c, Affected_Service__c, Integration_Account__c
                   FROM Case
                   WHERE Id =: caseId]; 
        
        INTGR_Case__c ic = new INTGR_Case__c();
        ic.Case__c = sc.Id; 
        ic.Description__c = sc.Description;
        ic.Hotel_Code__c = sc.Hotel_Code__c;
        ic.Severity__c = sc.Customer_Severity__c;
        ic.Subject__c = sc.Subject;
        ic.Status__c = sc.Status;
        ic.Assignment_Group__c = sc.Amadeus_ExternalSystemAssigneeGroup__c;
        ic.Customer_Name__c = sc.Customer_Name__c;
        ic.System_Affected__c = sc.System_Affected__c;
        ic.Affected_Service__c = sc.Affected_Service__c;
        
        if (sc.Integration_Account__c != null)
        {
            ic.INTGR_Account__c = sc.Integration_Account__c;
        }
        
        insert ic;
        
        sendCommentsAndFiles(caseId, setCCmtIds, setCVerIds);
        
    }
    
    @future (callout=true)
    public static void sendCommentsAndFiles(Id caseId, Set<Id> setCCmtIds, Set<Id> setCVerIds)
    {  
        
    }
    
    
}