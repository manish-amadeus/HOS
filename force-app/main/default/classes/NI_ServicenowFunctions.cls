/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_ServicenowFunctions Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 12/06/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     :
                : Updated 01/18/2019 per NICC-023347
                : Updated 12/06/2019 per NICC-039247
*************************************************************************************************/
public class NI_ServicenowFunctions
{
    
	public String username = '';
	public String password = '';
	public String endpoint = '';
	public String importSetEndPoint = '';
	public String attachEndpoint = '';
	public Boolean isAttachment = false;
	public static Map<Id, String> caseOwnerIdMap = new Map<Id, String>();

	public NI_ServicenowFunctions()
	{
		//username = 'integration_amadeus';
		//password = '3bPWPSER1ggC';
		//endpoint = 'https://ihgsndev.service-now.com/api/now/table/incident';
		//importSetEndPoint = 'https://ihgsndev.service-now.com/api/now/import/u_integ_amadeus_incidents';
		//attachEndpoint = 'https://ihgsndev.service-now.com/api/now/attachment';

		system.debug(' *** ENTERING NI_ServicenowFunctions CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());

		ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
		username = SNSettings.SerrviceNow_Username__c;
		password = SNSettings.ServiceNow_Password__c;
		endpoint = SNSettings.Incident_Endpoint__c;
		importSetEndPoint = SNSettings.ImportSet_Endpoint__c;
		attachEndpoint = SNSettings.Attachment_Endpoint__c;

		system.debug(' *** EXITING NI_ServicenowFunctions CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public HttpResponse Servicenow_Post_Request(String reqBody)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.Servicenow_Post_Request() - QUERIES ISSUED = ' + Limits.getQueries());

		Http objhttp = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		req = Servicenow_Set_Header(req, 'POST', null);
		req.setBody(reqBody);
		res = objhttp.send(req);

		system.debug(' **** RETURNING: ' + res);
		system.debug(' *** EXITING NI_ServicenowFunctions.Servicenow_Post_Request() - QUERIES ISSUED = ' + Limits.getQueries());

		return res;
	}

    //@TestVisible
	public static void resendRequestToServiceNowUpdate(Map<Id, Id> mapLogCaseIdsUpdate, Map<Id, Id> mapLogCaseIdsCreate, Map<Id, NI_Integration_Log__c> mapNiIntLog)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.resendRequestToServiceNowUpdate() - QUERIES ISSUED = ' + Limits.getQueries());

		Http objhttp = new Http();
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
		ServiceNowIncidentSettings__c ServiceNowSettings = ServiceNowIncidentSettings__c.getValues('Default');
		Map<String, String> mapParseRes = new Map<String, String>();
		Map<String, String> mapRequest = new Map<String, String>();
		Map<String, String> mapResHeader = new Map<String, String>();
		List<Case> resUpdateCase = new List<Case>();
		List<Task> resUpdateTask = new List<Task>();
		Map<Id, Integer> mapRetriesID = new Map<Id, Integer>();

		//MAP OF LOG ID AND ATTACHMENT
		Map<Id, Attachment> mapLogAttach = new Map<Id, Attachment>();
		mapLogCaseIdsUpdate = new Map<Id, Id>();

		NI_WinaproachServiceHelper winAp = new NI_WinaproachServiceHelper();
		List<NI_Integration_Log_Message__c> resInsertLogMsg = new List<NI_Integration_Log_Message__c>();
		List<NI_Integration_Log_Message__c> reqExceptionLogMsg = new List<NI_Integration_Log_Message__c>();
		List<Id> resUpdateLog = new List<Id>();
		List<Id> resFailedLog = new List<Id>();
		String request = '';

		HttpRequest requestOne = new HttpRequest();

		List<Id> attachIdSet = new List<Id>();
		Map<Id, Attachment> mapAttach = new Map<Id, Attachment>();
		Map<Id, Case> caseMap = new Map<Id, Case>();

		//ITERATE OVER NI Integration Log VALUES AND GET ATTACHMENT IDs OF FAILED LOGS
		if (mapNiIntLog.size() > 0)
		{
			system.debug('mapNiIntLog' + mapNiIntLog);
			for (NI_Integration_Log__c niLog : mapNiIntLog.values())
			{
				if (niLog.Attachment_Id__c != null)
				{
					//ADD ATTACHMENT IDs TO THE SET
					attachIdSet.add(niLog.Attachment_Id__c);
				}
			}
		}

		//FETCH ALL THE ATTACHMENTS WHICH GOT FAILED AND PUT IN A MAP
		if (!attachIdSet.isEmpty())
		{
			mapAttach = new Map<Id, Attachment>([SELECT Id, Body, Name, BodyLength, parentID, LastModifiedDate
			                                     FROM Attachment WHERE Id IN: attachIdSet
			                                     AND parentID IN: mapLogCaseIdsCreate.values()]);
		}

		Set<Id> parentIdSet = new Set<Id>();
		//ITERATE OVER ATTACHMENTS AND GET PARENT IDs(CASE IDs)
		for (Attachment attachmn : mapAttach.values())
		{
			parentIdSet.add(attachmn.parentID);
		}

		system.debug('parentIdSet = ' + parentIdSet);

		//GET INTGR_Customer_Ticket_System_Id__c OF CASES IN ORDER TO SEND WITH REQUEST
		if (!parentIdSet.isEmpty())
		{
			caseMap = new Map<Id, Case>([SELECT Id, INTGR_Customer_Ticket_System_Id__c
			                             FROM Case
			                             WHERE Id IN: parentIdSet]);
		}

		if (mapNiIntLog.size() > 0)
		{
			NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();

			for (NI_Integration_Log__c niLog : mapNiIntLog.values())
			{
				//body.addChildElement('update',null,null)
				//			.addChildElement('incomingXML',null,null).
				//			addTextNode(String.valueOf(niLog.XMLRequest__c).unescapeXml());

				mapRetriesID.put(niLog.Id, Integer.valueOf(niLog.Retries_Performed__c));

				try
				{
					//IF UPDATEFOR FIELD ON LOG IS FOR ATTACHMENT ITERATE OVER CASE AND ATTACHMENT
					//AND CREATE REQUEST DYNAMICALLY WITH REQUIRED QUERY PARAMS
					if (niLog.UpdateFor__c == 'Attachment')
					{
						for (Attachment at : mapAttach.values())
						{
							// IF ATTACHMENT ID ON FAILED LOG IS EQUAL TO ATTACHMENT ID OF QUERY THEN PROCEED FURTHER FOR RESEND LOGIC
							if (niLog.Attachment_Id__c == at.Id)
							{
								// IF CASES MAP CONTAINS CASE ID THEN ONLY PROCEED FURTHER
								if (caseMap.containsKey(at.ParentId))
								{
									Case caseObj = caseMap.get(at.ParentId);
									mapLogAttach.put(niLog.Id, at);

									//requestOne = new HttpRequest();
									HttpRequest req1 = new HttpRequest();
									String sys_ID = caseObj.INTGR_Customer_Ticket_System_Id__c;
									//String sys_ID='0c681a30db6a32008a14f6dfbf961937';
									String queryParams = 'table_name=incident&table_sys_id=' + sys_ID + '&file_name=' + EncodingUtil.urlEncode(at.Name, 'UTF-8');
									//CREATING REQUEST - POST ATTACHMENT
									req1 = servNowFun.Servicenow_SetHeaderForAttachment(req1, 'POST', queryParams);
									req1.setBodyAsBlob(at.Body);
									Http h = new Http();
									system.debug('req1 = ' + req1);
									system.debug('req1 = ' + req1.getBody());
									res = h.send(req1);
									//request = req1.getBody();
								}
							}
						}
					}
					else
					{
						request = String.valueOf(niLog.XMLRequest__c).unescapeXml();
						system.debug('request = ' + request);
						res = servNowFun.Servicenow_Post_Request(request);
					}

					system.debug('res = ' + res);
					system.debug('res.getBody() = ' + res.getBody());

                    // mapRetriesID.put(niLog.Id, Integer.valueOf(niLog.Retries_Performed__c));
					mapRequest.put(niLog.Id, request);
					mapParseRes.put(niLog.Id, res.getBody());
					mapResHeader.put(niLog.Id, res.getStatus());
				}
				catch(exception e)
				{
					String strdate = Datetime.now().format('YYYY-MM-dd-hh-mm-ss');
					String strError = '';
					String endPoint = '';
					List<String> arrParsed = strdate.split('-');
					DateTime expected = DateTime.newInstance(Integer.valueOf(arrParsed.get(0)),Integer.valueOf(arrParsed.get(1)), Integer.valueOf(arrParsed.get(2)),Integer.valueOf(arrParsed.get(3)), Integer.valueOf(arrParsed.get(4)), Integer.valueOf(arrParsed.get(5)));

					if (ServiceNowSettings == null)
					{
						strError += 'Possible Error Cause : Winaproach Custom Setting record might not be exist as a name "Default" \n\n';
					}
					else
					{
						endPoint = ServiceNowSettings.ImportSet_Endpoint__c;
					}

					strError += 'Error Details: \n';
					strError += e.getMessage();

					system.debug('Error Occurred: ' + e.getMessage());

					NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
					nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(niLog.Id),'','','Failed',strError,'');
					resFailedLog.add(niLog.Id);
					reqExceptionLogMsg.add(nException);
				}
			}

			if (!mapParseRes.isEmpty())
			{
				for (String lID : mapParseRes.keySet())
				{
					try
					{
						if (!mapLogCaseIdsUpdate.isEmpty())
						{
							servNowFun.parseAndLogResponseBatch(lId,mapLogCaseIdsUpdate.get(lId), mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase, resInsertLogMsg, resUpdateLog, resFailedLog, resUpdateTask);
						}
						else
						{
							servNowFun.parseAndLogResponseBatch(lId,mapLogCaseIdsCreate.get(lId), mapRequest.get(lId), mapParseRes.get(lId), mapResHeader.get(lId), resUpdateCase, resInsertLogMsg, resUpdateLog, resFailedLog, resUpdateTask);
						}
					}
					catch(Exception e)
					{
						// In case if there is an error while parsing then bach apex continue untill desired condition met.
						// putting an exception in error log.
						String strError = 'Error Details: \n';
						strError += e.getMessage() + ' ' + e.getStackTraceString();
						system.debug(strError);
						NI_Integration_Log_Message__c nException = new NI_Integration_Log_Message__c();
						nException = NI_WinaproachServiceHelper.createIntegraionLogMessage(String.valueOf(lID), '', '', 'Failed', strError,'');
						resFailedLog.add(lID);
						reqExceptionLogMsg.add(nException);
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

			//Update NI_Integration Log for the sucessful messages
			if (resUpdateLog.size() > 0)
			{
				List<NI_Integration_Log__c> lstLog = new List<NI_Integration_Log__c>();

				for (Id iLog : resUpdateLog)
				{
					NI_Integration_Log__c nLog = new NI_Integration_Log__c();
					nLog.Id = iLog;

					//For sucessful log no need to do retries
					nLog.Do_Retries__c = false;
					nLog.Status__c = 'Success';
					nLog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1;
					lstLog.add(nLog);
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
					nLog.Id = iLog;
					nLog.Retries_Performed__c = 0;
					//Custom setting reffered for no. of tries
					if (mapRetriesID.containsKey(iLog) && ((Integer.valueOf(mapRetriesID.get(iLog)) + 1 ) >= Integer.valueOf(ServiceNowSettings.Max_Count_To_Resend_Failed_Message__c)))
					{
						nLog.Do_Retries__c = false;
					}
					else
					{
						nLog.Do_Retries__c = true;
					}
					system.debug(' **** ^ iLog = ' + iLog);
					system.debug(' **** ^ mapRetriesID = ' + mapRetriesID);
					system.debug(' **** ^ nLog = ' + nLog);
					system.debug(' **** ^ nLog.Retries_Performed__c = ' + nLog.Retries_Performed__c);
					nLog.Retries_Performed__c = Integer.valueOf(mapRetriesID.get(iLog)) + 1;
					lstLog.add(nLog);
				}

				if (lstLog.size() > 0)
				{
					update lstLog;
				}
			}
		}

		system.debug(' *** EXITING NI_ServicenowFunctions.resendRequestToServiceNowUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public HttpRequest Servicenow_Set_Header(HttpRequest req, String reqType, String queryParam)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.Servicenow_Set_Header() - QUERIES ISSUED = ' + Limits.getQueries());

		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		req.setHeader('Authorization', authorizationHeader);
		req.setHeader('Content-Type', 'application/xml');
		req.setHeader('Accept', 'application/xml');
		req.setTimeout(120000);

		if (reqType == 'GET')
		{
			req.setEndpoint(endpoint + '?' + queryParam);
			req.setMethod('GET');
		}

		if (reqType == 'POST')
		{
			req.setEndpoint(importSetEndPoint);
			req.setMethod('POST');
		}

		system.debug(' **** RETURNING: ' + req);
		system.debug(' *** EXITING NI_ServicenowFunctions.Servicenow_Set_Header() - QUERIES ISSUED = ' + Limits.getQueries());

		return req;
	}

	public void postFiles(Map<Id, List<ContentVersion> > mapContentVersions)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.postFiles() - QUERIES ISSUED = ' + Limits.getQueries());

		List<NI_Integration_Log__c> resInsertLog = new List<NI_Integration_Log__c>();
		List<NI_Integration_Log__c> resInsertLog2 = new List<NI_Integration_Log__c>();

		//CREATING SET OF CASE ID's
		Set<Id> setCaseIds = mapContentVersions.keySet();

		List<ContentVersion> lstContentVersion;

		//CREATING LIST OF CASES
		List<Case> lstCases = new List<Case>([SELECT Id, INTGR_Customer_Ticket_System_Id__c
		                                      FROM Case
		                                      WHERE Id IN: setCaseIds]);

		for (Case lstCase : lstCases)
		{
			lstContentVersion = mapContentVersions.get(lstCase.Id);

			for (ContentVersion cVers : lstContentVersion)
			{
				resInsertLog = new List<NI_Integration_Log__c>();

				HttpRequest req = new HttpRequest();

				// SETTING SYS_ID
				String sys_Id = lstCase.INTGR_Customer_Ticket_System_Id__c;
				String queryParams = 'table_name=incident&table_sys_id=' + sys_Id + '&file_name=' + EncodingUtil.urlEncode(cVers.PathOnClient, 'UTF-8');

				//CREATING REQUEST - POST ATTACHMENT
				HttpRequest req1 = Servicenow_SetHeaderForAttachment(req, 'POST', queryParams);
				req1.setBodyAsBlob(cVers.VersionData);

				Http h = new Http();
				HTTPResponse res1 = h.send(req1);

				String caseId = String.valueOf(lstCase.Id);

				// SHOWING REQUEST AND RESPONSE INTO LOG
				parseAndLogResponse(res1.getBody(), caseId, req1.getEndpoint(), 'Insert', 'File', lstCases, resInsertLog, req1.toString(), res1.getStatus(), cVers.Id, cVers.PathOnClient);
				resInsertLog2.add(resInsertLog[0]);
			}
		}

		if (resInsertLog2.size() > 0)
		{
			insert resInsertLog2;
		}

		system.debug(' *** EXITING NI_ServicenowFunctions.postFiles() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public HttpRequest Servicenow_SetHeaderForFile(HttpRequest req, String strQueryParams)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.Servicenow_SetHeaderForFile() - QUERIES ISSUED = ' + Limits.getQueries());

		String auth_header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
		req.setHeader('Authorization', auth_header);
		req.setEndpoint(attachEndpoint + '/file?' + strQueryParams);
		req.setHeader('Accept', 'application/xml,*.*');
		req.setHeader('Content-Type', 'application/octet-stream');
		req.setMethod('POST');
		req.setTimeout(120000);

		system.debug(' **** RETURNING: ' + req);
		system.debug(' *** ENTERING NI_ServicenowFunctions.Servicenow_SetHeaderForFile() - QUERIES ISSUED = ' + Limits.getQueries());

		return req;
	}

	public void Post_Attachment(Map<Id, List<Attachment> > mapCaseAttachment)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.Post_Attachment() - QUERIES ISSUED = ' + Limits.getQueries());

		List<NI_Integration_Log__c> resInsertLog = new List<NI_Integration_Log__c>();
		List<NI_Integration_Log__c> resInsertLog2 = new List<NI_Integration_Log__c>();

		//CREATING SET OF CASE ID's
		Set<Id> setCaseID = mapCaseAttachment.keySet();

		List<Attachment> lstAttachment;

		//CREATING LIST OF CASES
		List<Case> lstCases = [SELECT Id, INTGR_Customer_Ticket_System_Id__c
		                       FROM Case
		                       WHERE Id IN : setCaseID];

		for (Case lstCase : lstCases)
		{
			system.debug('Case = ' + lstCase);
			lstAttachment = mapCaseAttachment.get(lstCase.id);

			for (Attachment at : lstAttachment)
			{
				resInsertLog = new List<NI_Integration_Log__c>();

				HttpRequest req = new HttpRequest();

				//SETTING SYS_ID
				String sys_ID = lstCase.INTGR_Customer_Ticket_System_Id__c;

				//String sys_ID1='0c681a30db6a32008a14f6dfbf961937';
				String queryParams = 'table_name=incident&table_sys_id=' + sys_ID + '&file_name=' + EncodingUtil.urlEncode(at.Name, 'UTF-8');

				//CREATING REQUEST - POST ATTACHMENT
				HttpRequest req1 = Servicenow_SetHeaderForAttachment(req, 'POST', queryParams);
				req1.setBodyAsBlob(at.Body);

				Http h = new Http();
				HTTPResponse res1 = h.send(req1);

				String case_ID = String.valueOf(lstCase.id);

				// SHOWING REQUEST AND RESPONSE INTO LOG
				parseAndLogResponse(res1.getBody(), case_ID, req1.getEndpoint(), 'Insert', 'Attachment', lstCases, resInsertLog, req1.toString(),res1.getStatus(), at.Id, at.Name);
				resInsertLog2.add(resInsertLog[0]);
			}
		}

		if (resInsertLog2.size() > 0)
		{
			insert resInsertLog2;
		}

		system.debug(' *** EXITING NI_ServicenowFunctions.Post_Attachment() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public HttpRequest Servicenow_SetHeaderForAttachment(HttpRequest req, String reqType, String queryParams)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.Servicenow_SetHeaderForAttachment() - QUERIES ISSUED = ' + Limits.getQueries());

		String auth_header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
		req.setHeader('Authorization', auth_header);
		req.setEndpoint(attachEndpoint + '/file?' + queryParams);
		req.setHeader('Accept', 'application/xml,*.*');
		req.setHeader('Content-Type', 'application/octet-stream');
		req.setMethod('POST');
		req.setTimeout(120000);

		system.debug(' **** RETURNING: ' + req);
		system.debug(' *** ENTERING NI_ServicenowFunctions.Servicenow_SetHeaderForAttachment() - QUERIES ISSUED = ' + Limits.getQueries());

		return req;
	}

	public void parseAndLogResponse(String response, String cs, String endPoint, String opType, String updateFor, List<Case> resUpdateCase, List<NI_Integration_Log__c> resInsertLog, String xmlRequest, String responseHeader, String attachmentId, String attachName)
	{
		// This function is used for the parsing the response of request and logging into "NI Integraion log" object

		system.debug(' *** ENTERING NI_ServicenowFunctions.parseAndLogResponse() - QUERIES ISSUED = ' + Limits.getQueries());

		dom.Document resDoc = new dom.Document();
		dom.XmlNode result = null;
		NI_Integration_Log__c niLog = new NI_Integration_Log__c();

		system.debug(' **** response = ' + response);
		system.debug(' **** cs = ' + cs);
		system.debug(' **** endPoint = ' + endPoint);
		system.debug(' **** opType = ' + opType);
		system.debug(' **** updateFor = ' + updateFor);
		system.debug(' **** resUpdateCase = ' + resUpdateCase);
		system.debug(' **** resInsertLog = ' + resInsertLog);
		system.debug(' **** xmlRequest = ' + xmlRequest);
		system.debug(' **** responseHeader = ' + responseHeader);

		try
		{
			// Load xml string into dom element
			resDoc.load(response);

			// Get root element of the response xml
			dom.XmlNode envelope = resDoc.getRootElement();

			if (responseHeader != 'Created')
			{
				// If unauthorized response
				String unauthorized = null;
				// If response is unauthorized insert integraion log as failed
				if (envelope.getChildElement('error', null) != null)
				{
					unauthorized = envelope.getChildElement('error', null).getText();
					niLog = NI_WinaproachService.createIntegraionLog(cs, response, 'Failed', opType, updateFor, endPoint, 'ServiceNow', xmlRequest.escapeXml());

                    // NICC-039247 (START)
                    if (updateFor == 'Attachment') 	
                    {
                        if (attachmentId != null)
                        {
                            niLog.Attachment_Id__c = attachmentId;
                        }
                        
                        if (attachName != null)
                        {
                            niLog.Attachment_Name__c = attachName;
                        }                        
                    }

                    if (updateFor == 'File')
                    {
                        if (attachmentId != null)
                        {
                            niLog.File_Id__c = attachmentId;
                        }
                        
                        if (attachName != null)
                        {
                            niLog.File_Name__c = attachName;
                        }                        
                    }
                    // NICC-039247 (END)
                    
					resInsertLog.add(niLog);
				}
			}
			else
			{
				String ticketNumber = '';
				String sysId = '';
				String retStatus = '';

				dom.XmlNode resultNode = envelope.getChildElement('result', null);
				if (resultNode.getChildElement('display_value', null) != null)
				{
					ticketNumber = resultNode.getChildElement('display_value', null).getText();
				}

				if (resultNode.getChildElement('sys_id', null) != null)
				{
					sysId = resultNode.getChildElement('sys_id', null).getText();
				}

				if (resultNode.getChildElement('status', null) != null)
				{
					retStatus = resultNode.getChildElement('status', null).getText();
				}
/*
				if (ticketNumber != null && sysId != null && retStatus == 'inserted')
				{
					system.debug(' *^* UPDATING CASE ============================================== ');
					// UPDATE THE CASE WITH SETTING VALUE FOR EXTERNEL SYSTEM ID
					Case cCase = new Case();
					cCase.Id = cs;
					cCase.Customer_Ticket_Number__c = ticketNumber;
					cCase.INTGR_Customer_Ticket_System_Id__c = sysId;
					cCase.Integration_Sync_Status__c = true;
					resUpdateCase.add(cCase);
					NI_ServicenowIntegration.updateAttCaseCmtSN = true;
				}
*/
				niLog = NI_WinaproachService.createIntegraionLog(cs, response, 'Success', opType, updateFor, endPoint, 'ServiceNow', xmlRequest.escapeXml());
                
                // NICC-039247 (START)
                if (updateFor == 'Attachment')
                {
                    if (attachmentId != null)
                    {
                        niLog.Attachment_Id__c = attachmentId;
                    }
                    
                    if (attachName != null)
                    {
                        niLog.Attachment_Name__c = attachName;
                    }                        
                }
                
                if (updateFor == 'File')
                {
                    if (attachmentId != null)
                    {
                        niLog.File_Id__c = attachmentId;
                    }
                    
                    if (attachName != null)
                    {
                        niLog.File_Name__c = attachName;
                    }                        
                }
                // NICC-039247 (END)
                 
				resInsertLog.add(niLog);
                
			}
		}
		catch(exception e)
		{
			system.debug('Error Occcured: ' + e.getMessage());
		}

		system.debug(' *** EXITING NI_ServicenowFunctions.parseAndLogResponse() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	public void parseAndLogResponseBatch(String logId, String cs, String reqBody, String response, String resHeader, List<Case> resUpdateCase, List<NI_Integration_Log_Message__c> resInsertLogMsg, List<Id> resUpdateLog, List<Id> resFailedLog, List<Task> resUpdateTask)
	{
		// This function is used for the parsing the response of request and logging into "NI Integraion log" object

		system.debug(' *** ENTERING NI_ServicenowFunctions.parseAndLogResponseBatch() - QUERIES ISSUED = ' + Limits.getQueries());

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

			if (resHeader != 'Created')
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

				dom.XmlNode resultNode = envelope.getChildElement('result', null);

				if (resultNode.getChildElement('display_value', null) != null)
				{
					system.debug('not null');
					ticketNumber = resultNode.getChildElement('display_value', null).getText();
				}

				if (resultNode.getChildElement('sys_id', null) != null)
				{
					sysId = resultNode.getChildElement('sys_id', null).getText();
				}

				if (resultNode.getChildElement('status', null) != null)
				{
					retStatus = resultNode.getChildElement('status', null).getText();
				}

				if (ticketNumber != null && sysId != null && retStatus == 'inserted')
				{
					// UPDATE THE CASE WITH SETTING VALUE FOR EXTERNEL SYSTEM ID
					Case cCase = new Case();
					cCase.Id = cs;
					cCase.Customer_Ticket_Number__c = ticketNumber;
					cCase.INTGR_Customer_Ticket_System_Id__c = sysId;
					cCase.Integration_Sync_Status__c = true;
					resUpdateCase.add(cCase);
					NI_ServicenowIntegration.updateAttCaseCmtSN = true;
				}

				niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Successful', '', resHeader);
				resInsertLogMsg.add(niLog);
				resUpdateLog.add(logId);
			}
		}
		catch(Exception e)
		{
			niLog = NI_WinaproachServiceHelper.createIntegraionLogMessage(logId, reqBody, response, 'Failed', '', resHeader);
			resInsertLogMsg.add(niLog);
			resFailedLog.add(Id.valueOf(logId));
		}

		system.debug(' *** EXITING NI_ServicenowFunctions.parseAndLogResponseBatch() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	// ================================================================================================================
	//  FUTURE CALLOUT METHODS ========================================================================================
	// ================================================================================================================
	@future(callout = true)
	public static void attachment_Callout(Set<Id> setAttachID)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.attachment_Callout() - QUERIES ISSUED = ' + Limits.getQueries());

		Map<Id, List<Attachment> > mapCaseAttachment = new Map<Id, List<Attachment> >();

		Set<Id> attachment_Parent_ID = new Set<Id>();

		//LIST OF FILTERED ATTACHMENTS
		List<Attachment> lstAttach = [SELECT Id, Body, Name, BodyLength, parentID
		                              FROM Attachment
		                              WHERE Id IN : setAttachID];

		system.debug('lstAttach = ' + lstAttach);

		for (Attachment att : lstAttach)
		{
			if (mapCaseAttachment.containsKey(att.parentID))
			{
				List<Attachment> att1 = mapCaseAttachment.get(att.parentID);
				att1.add(att);
				mapCaseAttachment.put(att.parentID, att1);
			}
			else
			{
				List<Attachment> att2 = new List<Attachment>();
				att2.add(att);
				mapCaseAttachment.put(att.parentID, att2);
			}
		}

		new NI_ServicenowFunctions().Post_Attachment(mapCaseAttachment);

		system.debug(' *** EXITING NI_ServicenowFunctions.attachment_Callout() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	@future(callout = true)
	public static void fileCallout(Set<Id> setDocumentIds)
	{
		system.debug(' *** ENTERING NI_ServicenowFunctions.file_Callout() - QUERIES ISSUED = ' + Limits.getQueries());

		// LIST OF RELATED CONTENT VERSIONS
		List<ContentVersion> lstContentVersions = [SELECT Id, ContentDocumentId, Title, ContentSize, PathOnClient, VersionData
		                                           FROM ContentVersion
		                                           WHERE IsLatest = true
		                                                            AND ContentDocumentId IN : setDocumentIds];

		Map<Id, List<ContentVersion> > mapCase2Files = new Map<Id, List<ContentVersion> >();

		for (ContentDocumentLink cdLink : [SELECT Id, ContentDocumentId, LinkedEntityId, LinkedEntity.Type
		                                   FROM ContentDocumentLink
		                                   WHERE ContentDocumentId IN : setDocumentIds])
		{
			if (cdLink.LinkedEntity.Type.equalsIgnoreCase('Case'))
			{
				for (ContentVersion cVers : lstContentVersions)
				{
					if (cdLink.ContentDocumentId == cVers.ContentDocumentId)
					{
						if (mapCase2Files.containsKey(cdLink.LinkedEntityId))
						{
							List<ContentVersion> lstCV1 = mapCase2Files.get(cdLink.LinkedEntityId);
							lstCV1.add(cVers);
							mapCase2Files.put(cdLink.LinkedEntityId, lstCV1);
						}
						else
						{
							List<ContentVersion> lstCV2 = new List<ContentVersion>();
							lstCV2.add(cVers);
							mapCase2Files.put(cdLink.LinkedEntityId, lstCV2);
						}
					}
				}
			}
		}

		new NI_ServicenowFunctions().postFiles(mapCase2Files);

		system.debug(' *** EXITING NI_ServicenowFunctions.file_Callout() - QUERIES ISSUED = ' + Limits.getQueries());
	}
    
}