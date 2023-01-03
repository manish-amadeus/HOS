/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachServiceHelper Class
Integration     : Win@proach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 11/21/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-025961
Description     : Utility class for winaproach integration
				: resendRequestToWinaproach
				: resendRequestToWinaproachUpdate
				: parseAndLogResponse
				: createIntegraionLogMessage = Creates NI_Integration_Log_Message__c Records
				: 
Update History	: 08/13/2017 Per NICC-023347
				: 10/05/2017 Per NICC-024188
                : 10/12/2017 Per NICC-024311
				: 12/06/2019 Per NICC-039247
				: 
*************************************************************************************************/
public class NI_WinaproachServiceHelper 
{
	
    public static void resendRequestToWinaproach(Map<Id, Id> mapLogCaseIds, Map<Id, Integer> mapRetriesID)
    {
        
        system.debug(' *** ENTERING NI_WinaproachServiceHelper.resendRequestToWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Http objhttp = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        List<Case> resUpdateCase = new List<Case>();
        List<Task> resUpdateTask = new List<Task>();
        List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
        List<NI_Integration_Log_Message__c> reqExceptionLogMsg = new List<NI_Integration_Log_Message__c>();
        List<Id> resUpdateLog = new List<Id>();
        List<Id> resFailedLog = new List<Id>();
        
        Map<Id, Case> mapCase = new Map<Id, Case>(
            [SELECT Id, RecordTypeID, Hotel_Code__c, RecordType.Name, Casenumber, Customer_Ticket_Number__c, Customer_Severity__c, System_Affected__c, 
             Amadeus_External_System_Id__c, Amadeus_ExternalSystemAssigneeGroup__c, Status, Subject, Description, Owner.Name, Affected_Service__c, CreatedDate, 
             Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c, Winaproach_Logger_Phone_Number__c, Winaproach_Owner_Group__c, LastModifiedBy.Name,
             Cause_Id_Code__c, Resolution_Code__c, Reject_Reason_Code__c, Incident_Start_Date_Time__c, Resolved_Date_and_Time__c,  
             parentId, Parent.Amadeus_External_System_Id__c, INTGR_Recovery_Plan_Date_Time__c, Integration_Account__c, 
             Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c, Account.AccountNumber, Rejected_Date__c  
             FROM Case 
             WHERE Id IN : mapLogCaseIds.values()]
        );
        
        String request = '';
        NI_WinaproachServiceHelper winAp = new NI_WinaproachServiceHelper();
        Map<String, String> mapParseRes = new Map<String, String>();
        Map<String, String> mapRequest = new Map<String, String>();
        Map<String, String> mapResHeader = new Map<String, String>();
        String workOrderRecordType = '';
        
        if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && 
            Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
        {
            workOrderRecordType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c;
        }        
        
        for (Id logID : mapLogCaseIds.keySet())
        {
            
            Case cs = mapCase.get(mapLogCaseIds.get(logID));
            
            if (cs.RecordType.Name == workOrderRecordType)
            {
                request = NI_WinaproachService.prepareWorkOrderCreateRequestWinaproach(cs);
            }
            else
            {
                request = NI_WinaproachService.prepareCreateRequestWinaproach(cs);
            }
            
            try
            {
                
                req.setMethod('POST'); 
                req.setEndpoint(winSettings.Endpoint__c);
                Blob headerValue = Blob.valueOf(winSettings.Username__c + ':' + winSettings.Password__c);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                
                // Set the necessary Headers 
                req.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type', 'text/plain');                
                req.setHeader('SOAPAction', '');
                
                // Set Body of the Request 
                req.setBody(request);  
                req.setTimeout(120000);
                
                // Send HTTP Request and get Response 
                res = objhttp.send(req);
                winAp = new NI_WinaproachServiceHelper();	            
                
                mapRequest.put(logID, req.getBody());
                mapParseRes.put(logID, res.getBody());
                mapResHeader.put(logId, res.getStatus());
                
            } 
            catch (exception e)
            {
                
                String strdate = Datetime.now().format('YYYY-MM-dd-hh-mm-ss');
                String strError = '';
                String endPoint = '';
                List<String> arrParsed = strdate.split('-');		
                DateTime expected = DateTime.newInstance(Integer.valueOf(arrParsed.get(0)),Integer.valueOf(arrParsed.get(1)), Integer.valueOf(arrParsed.get(2)),Integer.valueOf(arrParsed.get(3)), Integer.valueOf(arrParsed.get(4)), Integer.valueOf(arrParsed.get(5)));
                
                if (winSettings == null)
                {
                    strError += 'Possible Error Cause : Winaproach Custom Setting record might not be exist as a name "Default" \n\n';				
                }
                else
                {
                    endPoint = winSettings.Endpoint__c;
                }
                
                strError += 'Error Details: \n';	
                strError += e.getMessage();
                
                system.debug('Error Occurred: ' + e.getMessage());
                
                NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
                nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(logID), '', '', 'Failed', strError, '');
                
                resFailedLog.add(logID);
                reqExceptionLogMsg.add(nException);
                
            }
        }
        
        for (String lID : mapParseRes.keySet())
        {
            winAp.parseAndLogResponse(lId, mapLogCaseIds.get(lId), mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase,resInsertLogMsg, resUpdateLog, resFailedLog, resUpdateTask);
        }
        
        // Update Cases with record_id
        if (resUpdateCase.size() > 0) 
        {
            update resUpdateCase;    		
        }
        
        // Insert NI_Integration_Log_Message
        if (resInsertLogMsg.size() > 0)
        {
            insert resInsertLogMsg;
        }
        
        if (reqExceptionLogMsg.size() > 0)
        {
            insert reqExceptionLogMsg;
        }
        
        // Update NI_Integration Log for the sucessful messages
        if (resUpdateLog.size() > 0)
        {
            
            List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();
            
            for (Id iLog : resUpdateLog)
            {
                
                NI_Integration_Log__c nLog = new NI_Integration_Log__c();
                nlog.Id = iLog;  			
                
                // For sucessful log no need to do retries    			
                nlog.Do_Retries__c = false;
                nlog.Status__c = 'Success';
                nlog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1; 
                lstLog.add(nlog);    
                
            }
            
            if (lstLog.size() > 0)
            {
                update lstLog;
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
                
                // Custom setting reffered for no. of tries
                if ((Integer.valueOf(mapRetriesID.get(iLog)) + 1 ) >= Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c))
                {
                    nlog.Do_Retries__c = false;
                }
                else
                {
                    nlog.Do_Retries__c = true;
                }
                
                nlog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1; 
                lstLog.add(nlog);    
                
            }
            
            if (lstLog.size() > 0)
            {
                update lstLog;
            }
            
        }
        
        system.debug(' *** EXITING NI_WinaproachServiceHelper.resendRequestToWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public static void resendRequestToWinaproachUpdate(Map<Id, Id> mapLogCaseIdsUpdate, Map<Id, NI_Integration_Log__c> mapNiIntLog)
    {
        
        system.debug(' *** ENTERING NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Http objhttp = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        Map<String, String> mapParseRes = new Map<String, String>();
        Map<String, String> mapRequest = new Map<String, String>();
        Map<String, String> mapResHeader = new Map<String, String>();
        List<Case> resUpdateCase = new List<Case>();
        List<Task> resUpdateTask = new List<Task>();
        Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();
        
        NI_WinaproachServiceHelper winAp = new NI_WinaproachServiceHelper();
        List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
        List<NI_Integration_Log_Message__c> reqExceptionLogMsg = new List<NI_Integration_Log_Message__c>();
        List<Id> resUpdateLog = new List<Id>();
        List<Id> resFailedLog = new List<Id>();
        String request = '';		
        
        DOM.Document doc = new DOM.Document();
        DOM.Document innerDoc = new DOM.Document();
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        
        Dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        
        envelope.setAttributeNS('xsi', 'http://www.w3.org/2001/XMLSchema-instance', null, null);
        // Create Body of the Request 
        dom.XmlNode body = null;
        body = envelope.addChildElement('Body', soapNS, null);
        
        // FILL MAP WITH CASE RECORDS
        Map<Id, Case> caseMap = new Map<Id, Case>();
        String strBody = '';
        
        caseMap = new Map<Id, Case>([SELECT Id, Amadeus_External_System_Id__c, Integration_Account__c 
                                     FROM Case 
                                     WHERE Id IN : mapLogCaseIdsUpdate.values()]);
                                     //AND Amadeus_External_System_Id__c != null]);
        
        system.debug(' **** caseMap.size() ' + caseMap.size());   
        
        // GET ALL ATTACHMENT & FILE IDs
        Set<Id> attachIdSet = new Set<Id>();
        Set<Id> setFileIds = new Set<Id>();
        
        if (mapNiIntLog.size() > 0)
        {
            for (NI_Integration_Log__c niLog : mapNiIntLog.values())
            {
                if (niLog.Attachment_Id__c != null)
                {
                    attachIdSet.add(niLog.Attachment_Id__c);
                }
                if (niLog.File_Id__c != null)			// NICC-039247
                {
                    setFileIds.add(niLog.File_Id__c);
                }                 
            }
        }
        
        // FILL MAP WITH ATTACHMENTS
        Map<Id, Attachment> attachMap = new Map<Id, Attachment>();   
        if (!attachIdSet.isEmpty()) 			// NICC-039247
        {
            attachMap = new Map<Id, Attachment>([SELECT Id, Body, Name, BodyLength, parentID, LastModifiedDate
                                                 FROM Attachment 
                                                 WHERE Id IN : attachIdSet
                                                 AND parentID IN : mapLogCaseIdsUpdate.values()
                                                 ORDER BY CreatedDate DESC]);
        }

        // NICC-039247 (START)
        // FILL MAP WITH FILES
        Map<Id, ContentVersion> mapCVs = new Map<Id, ContentVersion>();   
        if (!setFileIds.isEmpty())
        {
            mapCVs = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId, Title, ContentSize, PathOnClient, VersionData
                                                  FROM ContentVersion
                                                  WHERE IsLatest = true
                                                  AND Id IN : setFileIds]);            
        }
        // NICC-039247 (END)
         
        if (mapNiIntLog.size() > 0)
        {
            
            for (NI_Integration_Log__c niLog : mapNiIntLog.values())
            {

                body.addChildElement('update', null, null).addChildElement('incomingXML', null, null).addTextNode(String.valueOf(niLog.XMLRequest__c).unescapeXml());
                request = doc.toXmlString();
                
                // VERIFY THAT IN REQUEST THERE IS XX__RECORD_ID__XX
                String target = 'XX__RECORD_ID__XX';
                
                system.debug(' **** request = ' + request);
                system.debug(' **** niLog.Id = ' + niLog.Id);
                system.debug(' **** niLog.XMLRequest__c = ' + niLog.XMLRequest__c);                
                system.debug(' **** mapLogCaseIdsUpdate.get(niLog.Id) = ' + mapLogCaseIdsUpdate.get(niLog.Id));
                system.debug(' **** caseMap.get(mapLogCaseIdsUpdate.get(niLog.Id)) = ' + caseMap.get(mapLogCaseIdsUpdate.get(niLog.Id)));  
                
                if (request.contains(target))
                {   
                    if (caseMap.get(mapLogCaseIdsUpdate.get(niLog.Id)).Amadeus_External_System_Id__c != null)
                    {
                        request = request.replace(target, String.valueOf(caseMap.get(mapLogCaseIdsUpdate.get(niLog.Id)).Amadeus_External_System_Id__c));
                    }
                }
system.debug(' **** request after XX__RECORD_ID__XX replace = ' + request);                
                mapRetriesID.put(niLog.Id, Integer.valueOf(niLog.Retries_Performed__c));
                
                try
                {
                    
                    req.setMethod('POST'); 
                    req.setEndpoint(winSettings.Endpoint__c);
                    Blob headerValue = Blob.valueOf(winSettings.Username__c + ':' + winSettings.Password__c);
                    
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    // Set the necessary Headers 
                    req.setHeader('Authorization', authorizationHeader);
                    req.setHeader('SOAPAction', '');
                    
                    if (niLog.UpdateFor__c == 'Attachment')
                    {
                        
                        req.setHeader('Content-Type', ' multipart/related; boundary=' + NI_WinaproachService.boundary);
                        req.setHeader('MIME_VERSION', '1.0');
                        req.setHeader('ACCEPT_ENCODING', 'gzip, deflate');
                        req.setTimeout(120000);
                        strBody = request;
                        
                        if (attachMap.containsKey(niLog.Attachment_Id__c))
                        {
                            strBody = NI_WinaproachService.prepareAttachment(strBody, attachMap.get(niLog.Attachment_Id__c));
                        }
                        
                        Blob bodyBlob = EncodingUtil.base64Decode(strBody);
                        req.setBodyAsBlob(bodyBlob);
                        
                    }
                    
                    // NICC-039247 (START)
                    if (niLog.UpdateFor__c == 'File')
                    {
                        
                        req.setHeader('Content-Type', ' multipart/related; boundary=' + NI_WinaproachService.boundary);
                        req.setHeader('MIME_VERSION', '1.0');
                        req.setHeader('ACCEPT_ENCODING', 'gzip, deflate');
                        req.setTimeout(120000);
                        strBody = request;
                        
                        if (mapCVs.containsKey(niLog.File_Id__c))
                        {
                            strBody = NI_WinaproachService.prepareFile(strBody, mapCVs.get(niLog.File_Id__c));
                        }
                        
                        Blob bodyBlob = EncodingUtil.base64Decode(strBody);
                        req.setBodyAsBlob(bodyBlob);
                        
                    }
                    
                    if (niLog.UpdateFor__c != 'Attachment' && niLog.UpdateFor__c != 'File')
                    {
                        req.setHeader('Content-Type', 'text/xml');
                        // Set Body of the Request 			        
                        req.setBody(request); 
                    }		        	                
                    // NICC-039247 (END)
                    
                    // Send HTTP Request and get Response 
                    res = objhttp.send(req);
                    
                    mapRequest.put(niLog.Id, request);
                    mapParseRes.put(niLog.Id, res.getBody());
                    mapResHeader.put(niLog.Id, res.getStatus());
                    body.RemoveChild(body.getChildElement('update', null));
                    
                } 
                catch(exception e)
                {
                    
                    String strdate = Datetime.now().format('YYYY-MM-dd-hh-mm-ss');
                    String strError = '';
                    String endPoint = '';
                    List<String> arrParsed = strdate.split('-');		
                    DateTime expected = DateTime.newInstance(Integer.valueOf(arrParsed.get(0)), Integer.valueOf(arrParsed.get(1)), Integer.valueOf(arrParsed.get(2)), Integer.valueOf(arrParsed.get(3)), Integer.valueOf(arrParsed.get(4)), Integer.valueOf(arrParsed.get(5)));
                    
                    if (winSettings == null)
                    {
                        strError += 'Possible Error Cause : Winaproach Custom Setting record might not be exist as a name "Default" \n\n';				
                    }
                    else
                    {
                        endPoint = winSettings.Endpoint__c;
                    }
                    
                    strError += 'Error Details: \n';	
                    strError += e.getMessage();
                    
                    system.debug('Error Occurred: ' + e.getMessage());
                    
                    NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
                    nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(niLog.Id), '', '', 'Failed', strError, '');
                    resFailedLog.add(niLog.Id);
                    reqExceptionLogMsg.add(nException);
                    
                }
          
            }
            
            for (String lID : mapParseRes.keySet())
            {
                try
                {
                    winAp.parseAndLogResponse(lId,mapLogCaseIdsUpdate.get(lId),mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase,resInsertLogMsg, resUpdateLog, resFailedLog, resUpdateTask);
                }
                catch (Exception e)
                {
                    // In case if there is an error while parsing then bach apex continue untill desired condition met.
                    // putting an exception in error log.
                    String strError = 'Error Details: \n';	
                    strError += e.getMessage();
                    
                    system.debug('Error Occurred: ' + e.getMessage());
                    
                    NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
                    nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(lID), '', '', 'Failed', strError, '');
                    resFailedLog.add(lID);
                    reqExceptionLogMsg.add(nException);
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
                insert resInsertLogMsg;
            }
            
            if (reqExceptionLogMsg.size() > 0)
            {
                insert reqExceptionLogMsg;
            }
            
            // Update Task with investigation_id
            if (resUpdateTask.size() > 0) 
            {
                update resUpdateTask;    		
            }
            
            // Update NI_Integration Log for the sucessful messages
            if (resUpdateLog.size() > 0)
            {
                
                List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();
                
                for(Id iLog : resUpdateLog)
                {
                    
                    NI_Integration_Log__c nLog = new NI_Integration_Log__c();
                    nlog.Id = iLog;  			
                    
                    // For sucessful log no need to do retries    			
                    nlog.Do_Retries__c = false;
                    nlog.Status__c = 'Success';
                    nlog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1; 
                    lstLog.add(nlog); 
                    
                }
                
                if (lstLog.size() > 0)
                {
                    update lstLog;
                }
                
            }
            
            // Update NI_Integration Log for the failed messages
            if (resFailedLog.size() > 0)
            {
                
                List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();
                
                for (Id iLog : resFailedLog)
                {
                    
                    NI_Integration_Log__c nLog = new NI_Integration_Log__c();
                    nlog.Id = iLog;
                    
                    //Custom setting reffered for no. of tries
                    if ((Integer.valueOf(mapRetriesID.get(iLog)) + 1 ) >= Integer.valueOf(winSettings.Max_Count_To_Resend_Failed_Message__c))
                    {
                        nlog.Do_Retries__c = false;
                    }
                    else
                    {
                        nlog.Do_Retries__c = true;
                    }
                    system.debug(' **** ^ iLog = ' + iLog);   
                    system.debug(' **** ^ mapRetriesID = ' + mapRetriesID); 
                    system.debug(' **** ^ nLog = ' + nLog); 
                    system.debug(' **** ^ nLog.Retries_Performed__c = ' + nLog.Retries_Performed__c);                       
                    nlog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1; 
                    lstLog.add(nlog);
                    
                }
                
                if (lstLog.size() > 0)
                {
                    update lstLog;
                }
                
            }
            
        }
        
        system.debug(' *** EXITING NI_WinaproachServiceHelper.resendRequestToWinaproachUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }	
	 
    public void parseAndLogResponse(String logId, String cs, String reqBody, String response, String resHeader, List<Case> resUpdateCase, List<NI_Integration_Log_Message__c> resInsertLogMsg, List<Id> resUpdateLog, List<Id> resFailedLog, List<Task> resUpdateTask)
    {
        
    	// This function is used for the parsing the response of request and logging into "NI Integraion log" object
    	
        system.debug(' *** ENTERING NI_WinaproachServiceHelper.parseAndLogResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
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
            reqBody = reqBody.unescapeXml();         
            envelope = resDoc.getRootElement();   
            
            if (envelope.getChildElement('head', null) != null)
            {
                niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Failed', '', resHeader);
                resInsertLogMsg.add(niLog);
                resFailedLog.add(Id.valueOf(logId));         
            } 
            else 
            {
                
                header = envelope.getChildElement('Body', soapNS);
                createResponse = header.getChildElement('createResponse', null);
                fault = header.getChildElement('Fault', soapNS);
                updateResponse = header.getChildElement('updateResponse', null);
                
                // Check if response having any fault or exception
                if (fault != null)
                {
                    String faultString = fault.getChildElement('faultstring', null).getText();   	
                    niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, faultString, 'Failed', '', resHeader);
                    resInsertLogMsg.add(niLog);
                    resFailedLog.add(Id.valueOf(logId));        	
                } 
                else 
                {
                    if (createResponse != null)
                    {	
                        
                        dom.XmlNode createReturn = createResponse.getChildElement('createReturn', null);
                        String innerxmlRes = createReturn.getText();        	
                        innerxmlRes = EncodingUtil.urlDecode(innerxmlRes,'UTF-8');
                        
                        Dom.Document respDoc = new Dom.Document();
                        respDoc.load(innerxmlRes);
                        
                        Dom.XMLNode node = respDoc.getRootElement();
                        String record_id = node.getChildElement('success', null).getChildElement('record_id', null).getText();
                        
                        // Update the case with setting value for externel system id *
                        Case cCase = new Case();
                        cCase.id = cs;
                        cCase.Amadeus_External_System_Id__c = record_id;
                        
                        // update cCase;
                        resUpdateCase.add(cCase);
                        
                        niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, innerxmlRes, 'Successful', '', resHeader);
                        resInsertLogMsg.add(niLog);
                        resUpdateLog.add(Id.valueOf(logId));
                        
                    }
                    else 
                    {
                        if (updateResponse != null)
                        {
                            
                            dom.XmlNode updateReturn = updateResponse.getChildElement('updateReturn', null);
                            String innerxmlRes = updateReturn.getText();        	
                            innerxmlRes = EncodingUtil.urlDecode(innerxmlRes, 'UTF-8');
                            
                            Dom.Document respDoc = new Dom.Document();
                            respDoc.load(innerxmlRes);
                            
                            Dom.XMLNode node = respDoc.getRootElement();
                            String record_id = node.getChildElement('success', null).getChildElement('record_id', null).getText();
                            
                            Dom.XmlNode parallel_investigation_list = node.getChildElement('success', null).getChildElement('parallel_investigation_list', null);
                            
                            if (parallel_investigation_list != null)
                            {
                                
                                Map<String, Id> mapInvTask = new Map<String, Id>();
                                Dom.XmlNode[] chlds = node.getChildElement('success', null).getChildElement('parallel_investigation_list', null).getChildElements();    
                                
                                String maxId = '0';
                                ID taskId;
                                
                                //If there are multiple investigation then highest investigation Id need to refer Investigation id is in long integer format 
                                for (Dom.XmlNode bkElem : chlds) 
                                {
                                    // Getting max id
                                    if (Long.valueOf(maxId) < Long.valueOf(bkElem.getChildElement('investigation_id', null).getText()))
                                    {
                                        maxId = bkElem.getChildElement('investigation_id', null).getText();
                                        taskId = bkElem.getChildElement('external_investigation_id', null).getText();
                                        mapInvTask.put(maxId,taskId);
                                    }
                                }
                                
                                Task tTask = new Task(); 
                                
                                if (mapInvTask.get(maxId) != null)
                                {
                                    
                                    tTask.id = mapInvTask.get(maxId);	        			
                                    tTask.Amadeus_External_System_Id__c = maxId;
                                    
                                    // IMPORTANT: Win@proach server always response one task id for all investigation ids i.e. external_id is same for all investigation_ids
                                    if (resUpdateTask.size() == 0)
                                    {
                                        resUpdateTask.add(tTask);
                                    }
                                    
                                }
                                
                                // Clearing map
                                mapInvTask = new Map<String,Id>();
                                
                            }
                            
                            niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, innerxmlRes, 'Successful', '', resHeader);
                            resInsertLogMsg.add(niLog);
                            resUpdateLog.add(logId);
                            
                        }
                    }
                }
            }            
        } 
        catch (Exception e)
        {
            system.debug('Error Occurred: ' + e.getMessage());
            niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Failed', '', resHeader);
            resInsertLogMsg.add(niLog);
            resFailedLog.add(Id.valueOf(logId)); 
        }
    	
        system.debug(' *** EXITING NI_WinaproachServiceHelper.parseAndLogResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }	
	    
    public static NI_Integration_Log_Message__c createIntegraionLogMessage(String logID, String reqBody, String resBody, String status, String sfException, String resHeader)
    {
        
        // Used for creating the log for the request 
        
        system.debug(' *** ENTERING NI_WinaproachServiceHelper.createIntegraionLogMessage() - QUERIES ISSUED = ' + Limits.getQueries());
        
    	NI_Integration_Log_Message__c niLog = new NI_Integration_Log_Message__c();
        
    	//niLog.Name = 'NI Integration Resend Message Log - ' + Datetime.now().format();
    	niLog.Name = 'NI Integration Resend Message Log - ' + DateTime.now().format('MM/dd/yyyy hh:mm a', 'GMT') + ' GMT';
        niLog.NI_Integration_Log__c = logID;
    	niLog.Request_Body__c = reqBody;
    	niLog.Response_Body__c = resBody;
    	niLog.Status__c = status;
    	niLog.Salesforce_Exception__c = sfException;
    	niLog.HTTP_Response_Header__c = resHeader;
    	niLog.Message_Processed_Time__c = Datetime.now();

        system.debug(' *** EXITING NI_WinaproachServiceHelper.createIntegraionLogMessage() - QUERIES ISSUED = ' + Limits.getQueries());
        
    	return niLog;
        
    }
    
}