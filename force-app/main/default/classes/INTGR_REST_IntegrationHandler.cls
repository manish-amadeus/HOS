/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_REST_IntegrationHandler Class
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 03/21/2018
Last Mod By     : 
NICC Reference  : 
Description     : Integration handler class which takes care of calling 3rd party application and handling 
				: 
************************************************************************************************/
public class INTGR_REST_IntegrationHandler 
{
    
    public static final String SOAP_REQ_Format = 'SOAP';
    public static final String REST_XML_REQ_Format = 'XML';
    public static final String REST_JSON_REQ_Format = 'JSON';


    public string generateIntegrationRequestBody(String requestFormat, sObject intObj, Map <String, String> srcTargetFieldMap) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Request Format, Map of Case Id vs Integration Case Object, Map of Source and Target Field Mapping based on Integration account selected.
        // Return: String of request body could be XML or JSON string.
        // Description: Method responsible to generate request body string based on format selected.        
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.generateIntegrationRequestBody() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //INTGR_XMLGeneratorCls : Responsible for XML request generation
        if (requestFormat.equalsIgnoreCase(REST_XML_REQ_Format)) 
        {
            return INTGR_REST_XMLGenerator.generateXMLRequestString(intObj, srcTargetFieldMap);
        }
        
        //INTGR_JSONGeneratorCls : Responsible for JSON request generation
        if (requestFormat.equalsIgnoreCase(REST_JSON_REQ_Format)) 
        {
            return INTGR_REST_JSONGenerator.generateJSONRequestString(intObj, srcTargetFieldMap);
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.generateIntegrationRequestBody() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return null;
        
    }

    // ==========================================================================================================================
    // 	HTTP RESPONSE & REQUEST FUNCTIONS
    // ==========================================================================================================================

    private HttpResponse getIntegrationResponseAfterCallouts(String unamePwd, String endPointURL, String reqFormat, String reqType, String reqBody) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Integration Params to make callout to ServiceNow
        // Return: HttpResponse based on request format
        // Description: Method being called from future method and populates request header along with request body best on request format.        
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.getIntegrationResponseAfterCallouts() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //LOCAL VARIABLES
        Http objhttp = new Http();
        HttpRequest requestObj = new HttpRequest();
        HttpResponse responseObj = new HttpResponse();
        String updateFor = '';
        
        if (reqFormat == null || reqFormat == '') 
        {
            reqFormat = REST_XML_REQ_Format;
        }
        
        // PREPARE INCIDENT CREATE REQUEST HEADERS
        requestObj = serviceNow_prepareIncidentCreateUpdateReq(requestObj, unamePwd, reqType, endPointURL, reqFormat);
        requestObj.setBody(reqBody);
        responseObj = objhttp.send(requestObj);
        
        system.debug(' *** EXITRING INTGR_REST_IntegrationHandler.getIntegrationResponseAfterCallouts() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return responseObj;
        
    }
    
    private HttpRequest serviceNow_prepareIncidentCreateUpdateReq(HttpRequest req, String userNamePwd, String requestType, String endPointURL, String requestFormat) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: HttpRequest Object, Connection User Name appended with Password, Request Type (Post, GET etc..), EndPoint URL, Request Format.
        // Return: updated HttpRequest with header information.
        // Description: Method responsible for connection authorization and populating request parameter.        
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.serviceNow_prepareIncidentCreateUpdateReq() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String auth_header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(userNamePwd));
        req.setHeader('Authorization', auth_header);
        
        if (endPointURL != null)
        {
            req.setEndpoint(endPointURL);
        }
        
        if (requestFormat != null && requestFormat.equalsIgnoreCase(REST_XML_REQ_Format) ) 
        {
            req.setHeader('Content-Type', 'application/XML');
            req.setHeader('Accept', 'application/XML');
        }
        
        if (requestFormat != null && requestFormat.equalsIgnoreCase(REST_JSON_REQ_Format)) 
        {
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
        }
        
        req.setMethod(requestType);
        req.setTimeout(120000);
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.serviceNow_prepareIncidentCreateUpdateReq() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return req;
        
    }

    public static HttpRequest serviceNow_SetHeaderForFiles(HttpRequest req, String reqType, String queryParams, string uNamePwd) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Req Obj, request type, endpointurl and integration usercreds 
        // Description: To parse response from integration system and log errors if any
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.serviceNow_SetHeaderForFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String auth_header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(uNamePwd));
        req.setHeader('Authorization', auth_header);
        req.setEndpoint(queryParams);
        req.setHeader('Accept', 'application/xml,*.*');
        req.setHeader('Content-Type', 'multipart/form-data');
        req.setMethod(reqType);
        req.setTimeout(120000);
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.serviceNow_SetHeaderForFiles() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return req;
        
    }    

    // ==========================================================================================================================
    // 	PARSING FUNCTIONS
    // ==========================================================================================================================
    
    private string parseAttachmentResponse(HttpResponse response, String format) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: fileId, Integration system name, requestformat
        // Description: To parse response from integration system and log errors if any        
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.parseAttachmentResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
        dom.Document resDoc = new dom.Document();
        dom.XmlNode result = null;
        dom.XmlNode envelope = null;
        dom.XmlNode resultNode = null;
        dom.XmlNode errorNode = null;
        String strMessage = '';
        string xmlStatus = '';
        String errMsgNode = '';
        String responseBody = '';
        String responseStatus =''; 
        
        if (response != null || response.getStatus() != null)
        {
            responseBody = response.getBody();
            responseStatus = response.getStatus();
            
        }
        
        if (responseBody != null) 
        {
            resDoc.load(responseBody);
        }
        
        //GET ROOT ELEMENTS FROM RESPONSE
        if (resDoc != null) 
        {
            envelope = resDoc.getRootElement();
            resultNode = envelope.getChildElement('result', null);
            errorNode = envelope.getChildElement('error', null);
        }
        
        if (responseStatus != null && !responseStatus.equalsIgnoreCase('Created') && !responseStatus.equalsIgnoreCase('OK')) 
        {
            
            if (responseStatus.equalsIgnoreCase('Bad Request'))
            {
                strMessage += ' Error Code ' + response;
            }
            
            if (errorNode != null) 
            {
                xmlStatus = envelope.getChildElement('status', null).getText();
                errMsgNode = errorNode.getChildElement('message', null).getText();
                strMessage = errMsgNode + '\n ' + strMessage;
            }
            
        }
        
        if (responseStatus.equalsIgnoreCase('Created')) 
        {
            strMessage = 'Succesfully Created';
            xmlStatus = 'success';
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.parseAttachmentResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return '\n' + strMessage;
        
    }
        
    private static void parseXMLResponse(HttpResponse response, String responseStatus, INTGR_Case__c integrationObj, INTGR_Case_Comment__c caseCommObj, String operationName, String reqBody, String endPointURL, String updateFor) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: callout Response and case and case Comm objects.
        // Description: Method responsible to parse XML response for Integration Case create/update and Integration Case comment Insert        
		
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.parseXMLResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //LOCAL VARIABLES
        String ticketNumber = '';
        String sysId = '';
        dom.Document resDoc = new dom.Document();
        dom.XmlNode result = null;
        String strMessage = '';
        string xmlStatus = '';
        dom.XmlNode envelope = null;
        dom.XmlNode resultNode = null;
        dom.XmlNode errorNode = null;
        String responseBody = response.getBody();
        
        // PREPARE LOG OBJECT
        NI_Integration_Log__c logObj = new NI_Integration_Log__c();
        List<NI_Integration_Log__c> logList = new List<NI_Integration_Log__c>();
        
        String errMsgNode;
        if (responseBody != null) 
        {
            resDoc.load(responseBody);
        }
        
        //GET ROOT ELEMENTS FROM RESPONSE
        if (resDoc != null)
        {
            envelope = resDoc.getRootElement();
            resultNode = envelope.getChildElement('result', null);
            errorNode = envelope.getChildElement('error', null);
        }
        
        if (responseStatus != null && !responseStatus.equalsIgnoreCase('Created') && !responseStatus.equalsIgnoreCase('OK')) 
        {
            if (responseStatus.equalsIgnoreCase('Bad Request')) 
            {
                strMessage += ' Error Code ' + response;
            }
            
            if (errorNode != null) 
            {
                xmlStatus = envelope.getChildElement('status', null).getText();
                errMsgNode = errorNode.getChildElement('message', null).getText();
                strMessage = errMsgNode + '\n ' + strMessage;
            }
            
            if (updateFor.equalsIgnoreCase('INTGR_Case__c') && integrationObj != null) 
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, strMessage, 'Failed', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
            } 
            else 
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(caseCommObj.INTGR_Case__r.Case__c, caseCommObj.INTGR_Case__r.Id, caseCommObj.Id, strMessage, 'Failed', operationName, 'INTGR_Case_Comment__c', endPointURL, caseCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
            }
            logList.add (logObj);
        } 
        else 
        {
            
            if (resultNode != null && !operationName.equalsIgnoreCase('Update') && !updateFor.equalsIgnoreCase('INTGR_Case_Comment__c')) 
            {
                
                if (resultNode.getChildElement('number', null) != null) 
                {
                    ticketNumber = resultNode.getChildElement('number', null).getText();
                }
                
                if (resultNode.getChildElement('sys_id', null) != null) 
                {
                    sysId = resultNode.getChildElement('sys_id', null).getText();
                }
                
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, 'Record Created', 'Success', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                
            }
            
            if (resultNode != null && operationName.equalsIgnoreCase('Update') && updateFor.equalsIgnoreCase('INTGR_Case__c'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, 'Record Updated', 'Success', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
            }
            
            if (resultNode != null&& operationName.equalsIgnoreCase('Insert') && updateFor.equalsIgnoreCase('INTGR_Case_Comment__c')) 
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(caseCommObj.INTGR_Case__r.Case__c, caseCommObj.INTGR_Case__r.Id, caseCommObj.Id, 'Record Updated', 'Success', operationName, 'INTGR_Case_Comment__c', endPointURL, caseCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
            }
            
            logList.add (logObj);
            
        }
        
        String dbErrMessage;
        
        try 
        {
            if (errorNode == null && integrationObj != null && !operationName.equalsIgnoreCase('Update') && !updateFor.equalsIgnoreCase('INTGR_Case_Comment__c')) 
            {
                
                INTGR_Case_SOQLDataProvider daoObj = new INTGR_Case_SOQLDataProvider();
                dbErrMessage = daoObj.updateINTCaseSysIdAndIncidentNo(sysId, ticketNumber, integrationObj);
                
                if (!dbErrMessage.ContainsIgnoreCase('error')) 
                {
                    INTGR_IntegrationHelper.isUpdateSFCase = true;
                }
            }
        } 
        catch (Exception e) 
        {
            strMessage += e.getMessage();
            if (updateFor.equalsIgnoreCase('INTGR_Case__c') && integrationObj != null) 
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, strMessage, xmlStatus, operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                logList.add (logObj);
            } 
        }
        
        try 
        {
            if (logList.size() > 0) 
            {
                insert (logList);
            } 
        }
        catch (Exception e) 
        {
            system.debug('[INTGR_REST_IntegrationHandler] Error logging operation failed = ' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.parseXMLResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public static void parseJSONResponse(HttpResponse response, String responseStatus, INTGR_Case__c integrationObj, INTGR_Case_Comment__c intCaseCommObj, String operationName, String reqBody, String endPointURL, String updateFor) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: String of JSON Response, Integration case list to update sys id and incident number
        // Description: Method responsible to parse JSON response and get sys id and incident number to be populated on sales-force integration case.        
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.parseJSONResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // PREPARE LOG OBJECT
        NI_Integration_Log__c logObj = new NI_Integration_Log__c();
        List<NI_Integration_Log__c> logList = new List<NI_Integration_Log__c>();
        Map<String, Object> resultMap = new Map<String, Object>();
        String responseBody = response.getBody();
        String dbErrMessage = '';
        
        try 
        {
            
            if (responseBody != null)
            {
                responseBody = responseBody.removeStart('{"result":');
                responseBody = responseBody.removeEnd('}');
                resultMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            }
            
            if ((string)resultMap.get('sys_id') != null && 
                (string)resultMap.get('number') != null && 
                integrationObj != null && 
                operationName.equalsIgnoreCase('Insert') && 
                updateFor.equalsIgnoreCase('INTGR_Case__c'))
            {
                INTGR_Case_SOQLDataProvider daoObj = new INTGR_Case_SOQLDataProvider();
                dbErrMessage = daoObj.updateINTCaseSysIdAndIncidentNo((string)resultMap.get('sys_id'), (string)resultMap.get('number'), integrationObj);  
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, responseBody, 'Success', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
            }
            else 
            { 
                if (response.getStatus() != null && response.getStatus().equalsIgnoreCase('OK')) 
                {
                    
                    if (operationName.equalsIgnoreCase('Update') && updateFor.equalsIgnoreCase('INTGR_Case__c'))
                    {
                        logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, responseBody, 'Success', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                    }
                    
                    if (operationName.equalsIgnoreCase('Insert') && updateFor.equalsIgnoreCase('INTGR_Case_Comment__c') && operationName.equalsIgnoreCase('Insert'))
                    {
                        logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseCommObj.INTGR_Case__r.Case__c, intCaseCommObj.INTGR_Case__r.Id, intCaseCommObj.Id, responseBody, 'Success', 'Insert', 'INTGR_Case_Comment__c', endPointURL, intCaseCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                    }
                    
                }
            }
            
            logList.add (logObj);
            
        }
        catch (Exception e)
        {
            
            dbErrMessage += e.getMessage();
            
            if (integrationObj != null && updateFor.equalsIgnoreCase('INTGR_Case__c') && operationName.equalsIgnoreCase('Insert'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, dbErrMessage, 'Failed', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                
            }
            
            if (integrationObj != null && updateFor.equalsIgnoreCase('INTGR_Case__c') && operationName.equalsIgnoreCase('Update'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(integrationObj.Case__c, integrationObj.Id, null, dbErrMessage, 'Failed', operationName, 'INTGR_Case__c', endPointURL, integrationObj.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                
            }
            
            if (intCaseCommObj != null && updateFor.equalsIgnoreCase('INTGR_Case_Comment__c') && operationName.equalsIgnoreCase('Insert'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseCommObj.INTGR_Case__r.Case__c, intCaseCommObj.INTGR_Case__r.Id, intCaseCommObj.Id, dbErrMessage, 'Failed', 'Insert', 'INTGR_Case_Comment__c', endPointURL, intCaseCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, reqBody);
                
            }
            
            logList.add (logObj);
            
        }
        
        try 
        {
            if (logList.size() > 0) 
            {
                insert (logList);
            } 
        }
        catch (Exception e) 
        {
            system.debug('[INTGR_REST_IntegrationHandler] Error looging operation failed =:' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.parseJSONResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    // ==========================================================================================================================
    // 	FUTURE CALLOUTS
    // ==========================================================================================================================
    
    @future(callout=true)
    public static void prepareFilesCreateCallout(String recordId, String integrationSysName, String reqFormat) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: fileId, Integration system name, requestformat
        // Description: future call out responsible for Create post Request to Service Now for Files creation        
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.prepareFilesCreateCallout() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //LOCAL VARIABLES
        Id caseId = null;
        List<ContentVersion> fileList = new List<ContentVersion>();
        INTGR_Case__c intCaseObj = new INTGR_Case__c();
        String fileName = '';
        Blob fileData = null;
        String userNamePwd = '';
        String attEndPointURL = '';
        NI_Integration_Log__c niLog = new NI_Integration_Log__c();
        List<NI_Integration_Log__c> resLog = new List<NI_Integration_Log__c>();
        List<NI_Integration_Log__c> reqLog = new List<NI_Integration_Log__c>();
        Id fileId = null;
        HttpResponse response = new HttpResponse();
        
        //GET FILE INFORMATION
        fileList = [SELECT Id, CaseId__c, Title, VersionData, FileExtension FROM ContentVersion WHERE Id =: recordId OR ContentDocumentId =: recordId];
        
        for (ContentVersion versionObj : fileList) 
        {
            caseId = versionObj.CaseId__c;
            fileName = versionObj.Title.replaceAll('\\s+', '') + '.' + versionObj.FileExtension;
            fileData = versionObj.VersionData;
            fileId = versionObj.Id;
        }
        
        // GET INTEGRATION CASE AND ACCOUNT INFORMATION
        HttpRequest req = new HttpRequest();
        
        try 
        {
            
            if (INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList(caseId) != null)
            {
                intCaseObj = INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList(caseId);
                userNamePwd = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
                integrationSysName = intCaseObj.INTGR_Account__r.External_Integration_System_Name__c;
                attEndPointURL = intCaseObj.INTGR_Account__r.Attachment_Endpoint__c + '=incident&table_sys_id=' + intCaseObj.Customer_Ticket_System_Id__c + '&file_name=' + fileName;
            }
            
            if (attEndPointURL != null) 
            {
                
                req = INTGR_REST_IntegrationHandler.serviceNow_SetHeaderForFiles(req, 'POST', attEndPointURL, userNamePwd);
                req.setBodyAsBlob(fileData);
                Http h = new Http();
                response = h.send(req);
                String message = new INTGR_REST_IntegrationHandler().parseAttachmentResponse(response, reqFormat);
                niLog = new NI_Integration_Log__c();
                
                if (!message.ContainsIgnoreCase('Succesfully Created')) 
                {
                    niLog = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, message, 'Failed', 'Insert', 'ContentVersion', attEndPointURL, integrationSysName, '');
                    niLog.Attachment_Id__c = fileId;
                    niLog.Attachment_Name__c = fileName;
                    reqLog.add(niLog);
                }
                else 
                {
                    niLog = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, message, 'Success', 'Insert', 'ContentVersion', attEndPointURL, integrationSysName, '');
                    niLog.Attachment_Id__c = fileId;
                    niLog.Attachment_Name__c = fileName;
                    reqLog.add(niLog);
                }
                
            }
            
        } 
        catch (exception e) 
        {
            niLog = new NI_Integration_Log__c();
            niLog = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, e.getMessage(), 'Failed', 'Insert', 'ContentVersion', attEndPointURL, integrationSysName, '');
            niLog.Attachment_Id__c = fileId;
            niLog.Attachment_Name__c = fileName;
            reqLog.add(niLog);
        }
        
        try 
        {
            if (reqLog.size() > 0) 
            {
                insert reqLog;
            }
        } 
        catch (Exception e) 
        {
            system.debug('Error Occured while saving record: ' + e.getMessage());
        }
        finally
        {

            if (system.Label.Integration_Debug_Show_All == 'true')
            {
                //system.debug(' **** message = ' + message);
                system.debug(' **** response = ' + response);
            }
                        
            system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_REST_IntegrationHandler.prepareFilesCreateCallout');
            system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_REST_IntegrationHandler.prepareFilesCreateCallout');
            system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_REST_IntegrationHandler.prepareFilesCreateCallout');
            system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_REST_IntegrationHandler.prepareFilesCreateCallout');
            system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_REST_IntegrationHandler.prepareFilesCreateCallout');
            
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.prepareFilesCreateCallout() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    @future(callout=true)
    public static void prepareIncidentCreateRequest(Id caseId) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: CaseId to be inserted in Service now
        // Return: NA
        // Description: future call responsible for Create post Request to Service Now for Incident Creation and get the Incident id and system id in return.  
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LOCAL VARIABLES
        Http objhttp = new Http();
        HttpResponse response = new HttpResponse();
        INTGR_Case__c intCaseObj = new INTGR_Case__c();
        String requestBody = '';
        String intUNamePwd = '';
        String intEndPointURL = '';
        String intRequestFormat = '';
        List<NI_Integration_Log__c> resLog = new List<NI_Integration_Log__c>();
        NI_Integration_Log__c logObj = new NI_Integration_Log__c();
        
        try 
        {
            
            // POPULATE INTEGRATION CASE ALONG WITH INTEGRATION ACCOUNT INFORMATION BASED ON CASE ID.
            intCaseObj = INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList(caseId);
            
            if (intCaseObj.INTGR_Account__r.External_System_Username__c != null) 
            {
                intUNamePwd = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
            } 
            
            if (intCaseObj.INTGR_Account__r.Integration_Endpoint__c != null) 
            {
                intEndPointURL = intCaseObj.INTGR_Account__r.Integration_Endpoint__c;
            } 
            
            intRequestFormat = intCaseObj.INTGR_Account__r.RequestFormat__c;
            
            if (intRequestFormat != null && intRequestFormat.equalsIgnoreCase(REST_JSON_REQ_Format)) 
            {
                String replaceStr = '.';
                intCaseObj.Description__c = intCaseObj.Description__c.replaceAll('(\r\n|\n)', replaceStr);
            }
            
            requestBody = new INTGR_REST_IntegrationHandler().generateIntegrationRequestBody(intRequestFormat, intCaseObj, INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseObj.INTGR_Account__c, 'INTGR_Case__c'));
            response = new INTGR_REST_IntegrationHandler().getIntegrationResponseAfterCallouts(intUNamePwd, intEndPointURL, intRequestFormat, 'POST', requestBody);
            
            if (response.getStatus() != null && response.getStatusCode() != 0) 
            {
                
                if (intRequestFormat != null && intRequestFormat.equalsIgnoreCase(REST_XML_REQ_Format)) 
                {
                    INTGR_REST_IntegrationHandler.parseXMLResponse(response, response.getStatus(), intCaseObj, null, 'Insert', requestBody, intEndPointURL, 'INTGR_Case__c');
                }
                
                if (intRequestFormat != null && intRequestFormat.equalsIgnoreCase(REST_JSON_REQ_Format)) 
                {
                    INTGR_REST_IntegrationHandler.parseJSONResponse(response, response.getStatus(), intCaseObj, null, 'Insert', requestBody, intEndPointURL, 'INTGR_Case__c');
                }
                
            }
            
        } 
        catch (Exception e) 
        {
            system.debug('Error Occured :' + e.getMessage());
            logObj =  INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, e.getMessage(), 'Failed', 'Insert', 'INTGR_Case__c', intEndPointURL, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, requestBody);
        }
        
        resLog.add (logObj);
        
        try
        {
            if (resLog.size() > 0)
            {
                insert resLog;
            }
        }
        catch (Exception e)
        {
            system.debug('Error Occured while saving NI Log: ' + e.getMessage());
        }
        finally 
        {
            
            if (system.Label.Integration_Debug_Show_All == 'true')
            {
                system.debug(' **** requestBody = ' + requestBody);
                system.debug(' **** response = ' + response);
            }
            
            system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest');
            system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest');
            system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest');
            system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest');
            system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest');
            
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.prepareIncidentCreateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    @future(callout=true)
    public static void prepareIncUpdateCaseCommCreateRequest(Id recordId, String updateFor) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: case or Case Comment Id and String to identify update for which object
        // Description: future call responsible for Create post Request to Service Now for Incident update and Case Comment Creation       
        
        system.debug(' *** ENTERING INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //LOCAL VARIABLES
        HttpResponse response = new HttpResponse();
        String requestBody = '';
        String intUserNamePWD = '';
        String intEndPointURL = '';
        String integrationSysName = '';
        String intRequestFormat = '';
        String oprationName = '';
        List<NI_Integration_Log__c> resLog = new List<NI_Integration_Log__c> ();
        NI_Integration_Log__c logObj = new NI_Integration_Log__c();
        INTGR_Case__c intCaseObj = new INTGR_Case__c();
        INTGR_Case_Comment__c intCaseCommObj = new INTGR_Case_Comment__c();
        
        // POPULATE INTEGRATION CASE ALONG WITH INTEGRATION ACCOUNT INFORMATION BASED ON CASE ID.
        if (updateFor.equalsIgnoreCase('INTGR_Case__c')) 
        {
            
            oprationName = 'Update';
            intCaseObj = INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList(recordId);
            intUserNamePWD = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
            integrationSysName = intCaseObj.INTGR_Account__r.External_Integration_System_Name__c;
            intEndPointURL = intCaseObj.INTGR_Account__r.Integration_Endpoint__c + '/' + intCaseObj.Customer_Ticket_System_Id__c;
            intRequestFormat = intCaseObj.INTGR_Account__r.RequestFormat__c;
            
            if (intRequestFormat != null && intRequestFormat.equalsIgnoreCase(REST_JSON_REQ_Format)) 
            {
                String linebreak = '.';
                if (intCaseObj.Description__c != null) 
                {
                    intCaseObj.Description__c = ' ' + intCaseObj.Description__c.replaceAll('(\r\n|\n)', linebreak);
                }
            }
        }
        
        if (updateFor.equalsIgnoreCase('INTGR_Case_Comment__c')) 
        {
            
            oprationName = 'Insert';
            intCaseCommObj = INTGR_Case_SOQLDataProvider.getCaseCommIdVsIntegrationAccDetails(recordId);
            intUserNamePWD = intCaseCommObj.INTGR_Case__r.INTGR_Account__r.External_System_Username__c + ':' + intCaseCommObj.INTGR_Case__r.INTGR_Account__r.External_System_Password__c;
            integrationSysName = intCaseCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c;
            intEndPointURL = intCaseCommObj.INTGR_Case__r.INTGR_Account__r.Integration_Endpoint__c + '/' + intCaseCommObj.INTGR_Case__r.Customer_Ticket_System_Id__c;
            intRequestFormat = intCaseCommObj.INTGR_Case__r.INTGR_Account__r.RequestFormat__c;
            
            // FORMAT CASE COMMENT BODY
            String linebreak = ' ' + '<br/>';
            String replaceStr = '';
            String createdDate = '';
            
            if (!intCaseCommObj.CommentBody__c.ContainsIgnoreCase('-- [Created By Amadeus'))
            {
                
                if (intCaseCommObj.CreateDate__c != null)
                {
                    createdDate = INTGR_IntegrationHelper.getFormattedComment(intCaseCommObj.CreateDate__c);
                } 
                else 
                {
                    createdDate = intCaseCommObj.createddate + '';
                }
                
                if (!intRequestFormat.equalsIgnoreCase(REST_XML_REQ_Format))
                {
                    replaceStr = ']' + '<br/>';
                    intCaseCommObj.CommentBody__c = '-- [Created By Amadeus ' + createdDate + '' + replaceStr + ' ' + intCaseCommObj.CommentBody__c.replaceAll('(\r\n|\n)', linebreak);
                }
                else
                {
                    replaceStr = ']' + '\n';
                    intCaseCommObj.CommentBody__c = '-- [Created By Amadeus ' + createdDate + '' + replaceStr + ' ' + intCaseCommObj.CommentBody__c ;
                }
                
            }
        }
        
        try 
        {
            if (updateFor.equalsIgnoreCase('INTGR_Case__c')) 
            {
                
                INTGR_IntegrationHelper.isUpdateIncident = true;
                
                requestBody = new INTGR_REST_IntegrationHandler().generateIntegrationRequestBody(intRequestFormat, intCaseObj, INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseObj.INTGR_Account__c, 'INTGR_Case__c'));
                response = new INTGR_REST_IntegrationHandler().getIntegrationResponseAfterCallouts(intUserNamePWD, intEndPointURL, intRequestFormat, 'PUT', requestBody);
                
                if (response != null && response.getStatus() != null && response.getStatusCode() != 0) 
                {
                    if (intRequestFormat.equalsIgnoreCase(REST_XML_REQ_Format)) 
                    {
                        INTGR_REST_IntegrationHandler.parseXMLResponse(response, response.getStatus(), intCaseObj, null, oprationName, requestBody, intEndPointURL, updateFor);
                    }
                    else
                    {
                        INTGR_REST_IntegrationHandler.parseJSONResponse(response, response.getStatus(), intCaseObj, null, oprationName, requestBody, intEndPointURL, updateFor);
                    }
                }
                
            }
            else
            {
                
                requestBody = new INTGR_REST_IntegrationHandler().generateIntegrationRequestBody(intRequestFormat, intCaseCommObj, INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseCommObj.INTGR_Case__r.INTGR_Account__c, 'INTGR_Case_Comment__c'));
                response = new INTGR_REST_IntegrationHandler().getIntegrationResponseAfterCallouts(intUserNamePWD, intEndPointURL, intRequestFormat, 'PUT', requestBody);
                
                if (intRequestFormat.equalsIgnoreCase(REST_XML_REQ_Format)) 
                {
                    INTGR_REST_IntegrationHandler.parseXMLResponse(response, response.getStatus(), null, intCaseCommObj, oprationName, requestBody, intEndPointURL, updateFor);
                }
                else
                {
                    INTGR_REST_IntegrationHandler.parseJSONResponse(response, response.getStatus(), null, intCaseCommObj, oprationName, requestBody, intEndPointURL, updateFor);
                }
                
            }
            
        } 
        catch (Exception e)
        {
            system.debug('Error Occured : ' + e.getMessage());
            
            if (updateFor.equalsIgnoreCase('INTGR_Case__c')) 
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, e.getMessage(), 'Failed', 'Update', 'INTGR_Case__c', intEndPointURL, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, requestBody);
            }
            
            if (updateFor.equalsIgnoreCase('INTGR_Case_Comment__c')) 
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseCommObj.INTGR_Case__r.Case__c, intCaseCommObj.INTGR_Case__r.Id, intCaseCommObj.Id, e.getMessage(), 'Failed', 'Insert', 'INTGR_Case_Comment__c', intEndPointURL, intCaseCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, requestBody);
            }
            
            resLog.add(logObj);
            
        }
        
        try
        {
            if (resLog.size() > 0)
            {
                insert resLog;
            }
        }
        catch (Exception e)
        {
            system.debug('Error Occured while saving NI Log: ' + e.getMessage());
        }
        finally 
        {
            
            if (system.Label.Integration_Debug_Show_All == 'true')
            {
                system.debug(' **** requestBody = ' + requestBody);
                system.debug(' **** response = ' + response);
            }
            
            system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest');
            system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest');
            system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest');
            system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest');
            system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest');
            
        }
        
        system.debug(' *** EXITING INTGR_REST_IntegrationHandler.prepareIncUpdateCaseCommCreateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
 
}