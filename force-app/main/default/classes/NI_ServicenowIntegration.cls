/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_ServicenowIntegration Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/23/2019
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     :
                :
*************************************************************************************************/
public class NI_ServicenowIntegration
{
	public Boolean isAttachment = false;
	public static boolean caseCommentFlag = false;
	public static boolean updateAttCaseCmtSN = false;
	public static Set<String> fieldUpdateListSN = new Set<String> {'subject', 'description', 'INTGR_Recovery_Plan_Date_Time__c', 'status', 'Assignment_Group__c', 'Customer_Severity__c', 'Work_Around_Available__c', 'IsOperationalIssue__c'};


	public NI_ServicenowIntegration()
	{
	}

	// FUNCTION PREPARING THE UPDATE REQUEST FOR SERVICENOW
	public static String prepareUpdateRequest(Case cs, Casecomment cscm, Attachment csAtt, Task csTask, Set<String> updatedFieldNames)
	{
		system.debug(' *** ENTERING NI_ServicenowIntegration.prepareUpdateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
		system.debug(' *^* updatedFieldNames = ' + updatedFieldNames);
		DOM.Document doc = new DOM.Document();
		// CREATE REQUEST ENVELOPE
		Dom.XmlNode request = doc.createRootElement('request', Null, null);
		// CREATE BODY OF THE REQUEST
		Dom.XmlNode entry = request.addChildElement('entry', null, null);

		if (cs.Customer_Ticket_Number__c != null && cs.Customer_Ticket_Number__c != '')
		{
			Dom.XmlNode u_number = entry.addChildElement('u_number', null, null).addTextNode(cs.Customer_Ticket_Number__c);
		}

		Dom.XmlNode u_correlation_display = entry.addChildElement('u_correlation_display', null, null).addTextNode(cs.CaseNumber);
		Dom.XmlNode u_problem_id = entry.addChildElement('u_problem_id', null, null).addTextNode(cs.CaseNumber);
		Dom.XmlNode u_correlation_id = entry.addChildElement('u_correlation_id', null, null).addTextNode(cs.Id);

		// u_short_description
		if (updatedFieldNames.contains('subject'))
		{
			Dom.XmlNode u_short_description = entry.addChildElement('u_short_description', null, null).addTextNode(cs.subject);
		}

		if (updatedFieldNames.contains('description'))
		{
			Dom.XmlNode u_description = entry.addChildElement('u_description', null, null).addTextNode(cs.Description);
		}

		// NEW!
		if (updatedFieldNames.contains('Work_Around_Available__c'))
		{
			String sBoolValWA = 'false';
			if (cs.Work_Around_Available__c)
			{
				sBoolValWA = 'true';
			}
			Dom.XmlNode u_work_around = entry.addChildElement('u_work_around', null, null).addTextNode(sBoolValWA);
		}

		// NEW!
		if (updatedFieldNames.contains('IsOperationalIssue__c'))
		{
			String sBoolValOI = 'false';
			if (cs.IsOperationalIssue__c)
			{
				sBoolValOI = 'true';
			}
			Dom.XmlNode u_software_load = entry.addChildElement('u_software_load', null, null).addTextNode(sBoolValOI);
		}

		//ADDED BY STUART EMERY ON 10/18/2017 PER PROJECT BACKLOG: CRS Case Support - Recovery Plan Sev 3/4
		if (updatedFieldNames.contains('INTGR_Recovery_Plan_Date_Time__c'))
		{
			Dom.XmlNode u_recovery_plan_dt = entry.addChildElement('u_recovery_plan_dt', null, null).addTextNode(string.valueOfGmt(cs.INTGR_Recovery_Plan_Date_Time__c));
		}

		// u_work_notes node implementation mapped with commentBody
		// ONLY RECENT COMMENTS FETCHED I.E. WITHIN LAST MIN.
		if (cscm != null && cscm.CommentBody != null)
		{
			if (cscm.IsPublished)
			{
				Dom.XmlNode u_comments = entry.addChildElement('u_comments', null, null).addTextNode(cscm.CommentBody);
			}
			else
			{
				Dom.XmlNode u_work_notes = entry.addChildElement('u_work_notes', null, null).addTextNode(cscm.CommentBody);
			}
		}

		if (updatedFieldNames.contains('status'))
		{
			// u_state implementation based on custom setting
			if (ServiceNow_Incident_Status_Mapping__c.getValues(cs.Status) != null)
			{
				Dom.XmlNode u_state = entry.addChildElement('u_state', null, null).addTextNode(ServiceNow_Incident_Status_Mapping__c.getValues(cs.Status).ServiceNow_Mapped_Option__c);
			}
			//COMMENTED 10/13- Ria - TO STOP SENDING PENDING CODE ON HOLD REASON VALUES
			// if (cs.Status == 'Open' && updatedFieldNames.contains('status') && cs.Pending_Code__c != null && ServiceNow_Pending_Code_Mapping__c.getValues(cs.Pending_Code__c) != null)
			// {
			//     Dom.XmlNode u_hold_reason = entry.addChildElement('u_hold_reason', null, null).addTextNode(ServiceNow_Pending_Code_Mapping__c.getValues(cs.Pending_Code__c).ServiceNow_Mapped_Option__c);
			// }

			//RECOVERED STATUS
			else
			{
				if (cs.Status == 'Recovered' && updatedFieldNames.contains('status'))
				{
					if (cs.Resolution_Summary__c != null)
					{
						Dom.XmlNode u_comments = entry.addChildElement('u_comments', null, null).addTextNode(cs.Resolution_Summary__c);
					}
					if (cs.Resolution_Code__c != null)
					{
						Dom.XmlNode u_close_code = entry.addChildElement('u_close_code', null, null).addTextNode(cs.Resolution_Code__c);
					}
				}
				else
				{
					if (cs.Status == 'Returned to Customer' && updatedFieldNames.contains('status'))
					{
						Dom.XmlNode u_wrong_classification = entry.addChildElement('u_wrong_classification', null, null).addTextNode('true');
					}
				}
			}
		}

		// ASSIGNMENT GROUP
		if (cs.Assignment_Group__c != null && updatedFieldNames.contains('Assignment_Group__c'))
		{
			Dom.XmlNode u_assignment_group = entry.addChildElement('u_assignment_group', null, null).addTextNode(cs.Assignment_Group__c);
		}

		// SEVERITY
		if (cs.Customer_Severity__c != null && updatedFieldNames.contains('Customer_Severity__c'))
		{
			Dom.XmlNode u_priority = entry.addChildElement('u_priority', null, null).addTextNode(ServiceNow_Incident_Severity_Mapping__c.getValues(cs.Customer_Severity__c).ServiceNow_Mapped_Option__c);
		}

		system.debug(' **** RETURNING: ' + doc.toXmlString());
		system.debug(' *** EXITING NI_ServicenowIntegration.prepareUpdateRequest() - QUERIES ISSUED = ' + Limits.getQueries());

		return doc.toXmlString();
	}

	// FUNCTION PREPARING THE UPDATE REQUEST FOR SERVICENOW
	public static String prepareCreateRequest(Case cs, Casecomment cscm, Attachment csAtt, Task csTask)
	{
		// The following fields on the Case record are sent:
		// - Salesforce Case "Description" field is mapped to ServiceNow "u_description" field
		// - Salesforce Case Number field is mapped to ServiceNow "u_correlation_display" field
		// - Salesforce Case Id field is mapped to ServiceNow "u_correlation_id" field
		// - Salesforce Case Status is mapped to ServiceNow "sys_import_state" field
		// - Salesforce Case Subject is mapped to ServiceNow "u_short_description" field

		system.debug(' *** ENTERING NI_ServicenowIntegration.prepareCreateRequest() - QUERIES ISSUED = ' + Limits.getQueries());

		Dom.Document doc = new Dom.Document();

		// CREATE REQUEST ENVELOPE
		Dom.XmlNode request = doc.createRootElement('request', null, null);
		// CREATE BODY OF THE REQUEST
		Dom.XmlNode entry = request.addChildElement('entry', null, null);
		Dom.XmlNode u_correlation_display = entry.addChildElement('u_correlation_display', null, null).addTextNode(cs.CaseNumber);
		Dom.XmlNode u_problem_id = entry.addChildElement('u_problem_id', null, null).addTextNode(cs.CaseNumber);
		Dom.XmlNode u_correlation_id = entry.addChildElement('u_correlation_id', null, null).addTextNode(cs.Id);

		// u_short_description
		if (cs.Subject != null && cs.Subject != '')
		{
			Dom.XmlNode u_short_description = entry.addChildElement('u_short_description', null, null).addTextNode(cs.subject);
		}

		if (cs.Description != null && cs.Description != '')
		{
			Dom.XmlNode u_description = entry.addChildElement('u_description', null, null).addTextNode(cs.Description);
		}

		//ADDED BY STUART EMERY ON 10/18/2017 PER PROJECT BACKLOG: CRS Case Support - Recovery Plan Sev 3/4
		if (cs.INTGR_Recovery_Plan_Date_Time__c != null)
		{
			Dom.XmlNode u_recovery_plan_dt = entry.addChildElement('u_recovery_plan_dt', null, null).addTextNode(string.valueOfGmt(cs.INTGR_Recovery_Plan_Date_Time__c));
		}

		if (cs.Status != null && cs.Status != '')
		{
			//u_state implementation based on custom setting
			if (ServiceNow_Incident_Status_Mapping__c.getValues(cs.Status) != null)
			{
				Dom.XmlNode u_state = entry.addChildElement('u_state', null, null).addTextNode(ServiceNow_Incident_Status_Mapping__c.getValues(cs.Status).ServiceNow_Mapped_Option__c);
			}
			//COMMENTED- 10/13 - Ria
			//ON HOLD REASON VALUES
			//if (cs.Status == 'Open' && cs.Pending_Code__c != null && ServiceNow_Pending_Code_Mapping__c.getValues(cs.Pending_Code__c) != null)
			//{
			//    Dom.XmlNode u_hold_reason = entry.addChildElement('u_hold_reason', null, null).addTextNode(ServiceNow_Pending_Code_Mapping__c.getValues(cs.Pending_Code__c).ServiceNow_Mapped_Option__c);
			//}

			//RECOVERED STATUS
			else
			{
				if (cs.Status == 'Recovered')
				{
					if (cs.Resolution_Summary__c != null)
					{
						Dom.XmlNode u_comments = entry.addChildElement('u_comments', null, null).addTextNode(cs.Resolution_Summary__c);
					}
					if (cs.Resolution_Code__c != null)
					{
						Dom.XmlNode u_close_code = entry.addChildElement('u_close_code', null, null).addTextNode(cs.Resolution_Code__c);
					}
				}
				else
				{
					if (cs.Status == 'Returned to Customer')
					{
						Dom.XmlNode u_wrong_classification = entry.addChildElement('u_wrong_classification', null, null).addTextNode('true');
					}
				}
			}
		}

		// ASSIGNMENT GROUP
		if (cs.Assignment_Group__c != null)
		{
			Dom.XmlNode u_assignment_group = entry.addChildElement('u_assignment_group', null, null).addTextNode(cs.Assignment_Group__c);
		}

		// SEVERITY
		if (cs.Customer_Severity__c != null)
		{
			Dom.XmlNode u_priority = entry.addChildElement('u_priority', null, null).addTextNode(ServiceNow_Incident_Severity_Mapping__c.getValues(cs.Customer_Severity__c).ServiceNow_Mapped_Option__c);
		}

		// NEW!
		//if (cs.Work_Around_Available__c)
		//{
			String sBoolValWA = 'false';
			if (cs.Work_Around_Available__c)
			{
				sBoolValWA = 'true';
			}
			Dom.XmlNode u_work_around = entry.addChildElement('u_work_around', null, null).addTextNode(sBoolValWA);
		//}

		// NEW!
		//if (cs.IsOperationalIssue__c)
		//{
			String sBoolValOI = 'false';
			if (cs.IsOperationalIssue__c)
			{
				sBoolValOI = 'true';
			}
			Dom.XmlNode u_software_load = entry.addChildElement('u_software_load', null, null).addTextNode(sBoolValOI);
		//}

		system.debug(' **** RETURNING: ' + doc.toXmlString());
		system.debug(' *** EXITING NI_ServicenowIntegration.prepareCreateRequest() - QUERIES ISSUED = ' + Limits.getQueries());

		return doc.toXmlString();
	}

	public static void updateIncidents(List<Sobject> lstSobject, Set<String> updatedFieldNames)
	{
		// @DESCRIPTION: USED TO CALL FUTURE CALLOUT METHOD TO UPDATE INCIDENT THERE WILL BE MAX 2 FUTURE CALLOUT AS TRIGGER PROCESS MAX 200 RECORDS AT A TIME.
		// @PARAM LIST OF SOBJECT MIGHT BE CASE, CASECOMMENT OR TASK
		// @PARAM SET OF UPDATED FIELD NAMES OF OBJECT
		// @RETURN VOID, CALLING FUTURE CALLOUT REQUEST TO SERVICENOW

		system.debug(' *** ENTERING NI_ServicenowIntegration.updateIncidents() - QUERIES ISSUED = ' + Limits.getQueries());

		List<Id> parentIDs = new List<Id>();
		Map<Id, Id> csIdCommentId = new Map<Id, Id>();
		Map<Id, Id> filteredMap = new Map<Id, Id>();
		Map<Integer, Map<Id, Id> > mapSobjFiltered = new Map<Integer, Map<Id, Id> >();
		Map<Id, Id> mapSobj = new Map<Id, Id>();
		Integer i = 0;
		Set<Id> caseCommentIdSet = new Set<Id>();

		if (String.valueOf(lstSobject.getSobjectType()) == 'Case')
		{
			for (Case cs : (List<Case>)lstSobject)
			{
				filteredMap.put(cs.Id, cs.Id);
			}

			if (filteredMap.keySet().size() > 0)
			{
				// IF RECORD SIZE IS LESS OR EQUAL ASSIGN DIRECTLY AS WE HAVE LIMITATION FOR HTTP CALLOUT IN ONE TRANSACTION IS 100
				// PREPARING MAP WITH HAVING MAX 100 RECORDS MORE THAN THAT WILL BE IN NEXT BATCH
				// THERE WILL BE MAX 2 FUTURE CALLOUT AS TRIGGER PROCESS MAX 200 RECORDS AT A TIME.
				if (filteredMap.size() <= 100)
				{
					mapSobjFiltered.put(i, filteredMap);
				}
				else
				{
					for (Id lcs : filteredMap.keyset())
					{
						mapSobj.put(lcs, filteredMap.get(lcs));
						if (mapSobj.size() >= 100)
						{
							mapSobjFiltered.put(i, mapSobj);
							mapSobj = new Map<Id, Id>();
							i++;
						}
					}
				}

				// THERE WILL BE MAX 2 FUTURE CALLOUT AS TRIGGER PROCESS MAX 200 RECORDS AT A TIME.
				for (Integer j : mapSobjFiltered.keySet())
				{
					// CALL SERVICENOW UPDATE REQUEST USING FUTURE CALLOUT AND ALSO BENEFIT OF HIGHER LIMIT INSTEAD OF TRIGGER CONTEXT
					sendUpdateRequestToServiceNow(mapSobjFiltered.get(j), updatedFieldNames, String.valueOf(lstSobject.getSobjectType()));
				}
			}
		}
		else
		{
			for (sobject cc : lstSobject)
			{
				if (String.valueOf(lstSobject.getSobjectType()) == 'Task')
				{
					parentIDs.add((Id)cc.get('WhatId'));
					csIdCommentId.put((Id)cc.get('WhatId'), (Id)cc.get('Id'));
				}
				else
				{
					parentIDs.add((Id)cc.get('ParentId'));
					csIdCommentId.put((Id)cc.get('ParentId'), (Id)cc.get('Id'));
					caseCommentIdSet.add((Id)cc.get('Id'));
				}
			}

			if (parentIDs.size() > 0)
			{
				List<String> lstRecType = new List<String>();

				if (ServiceNowIncidentSettings__c.getValues('Default').ServiceNow_Incident_Case_Record_Type__c != null)
				{
					lstRecType.add(String.valueOf(ServiceNowIncidentSettings__c.getValues('Default').ServiceNow_Incident_Case_Record_Type__c));
				}

				List<Case> lstCase = [SELECT Id, RecordTypeID, Casenumber, CreatedById, Customer_Ticket_Number__c, Integration_Sync_Status__c, Owner.Name
				                      FROM Case
				                      WHERE RecordType.Name IN : lstRecType
				                      AND Id IN : parentIDs];

				ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');

				if (lstCase.size() > 0)
				{
					//filteredCases = filterCasesFromRecordTypes(lstCase);
					for (Case cs : lstCase)
					{
						//APPLYING TO FILTER OUT TARGETED RECORDS
						if (cs.Customer_Ticket_Number__c != null && cs.Integration_Sync_Status__c == true)
						{
							filteredMap.put(cs.Id,csIdCommentId.get(cs.Id));
						}
					}

					if (filteredMap.keySet().size() > 0)
					{
						// IF RECORD SIZE IS LESS OR EQUAL ASSIGN DIRECTLY AS WE HAVE LIMITATION FOR HTTP CALLOUT IN ONE TRANSACTION IS 100
						// PREPARING MAP WITH HAVING MAX 100 RECORDS MORE THAN THAT WILL BE IN NEXT BATCH
						// THERE WILL BE MAX 2 FUTURE CALLOUT AS TRIGGER PROCESS MAX 200 RECORDS AT A TIME.
						if (filteredMap.size() <= 100)
						{
							mapSobjFiltered.put(i, filteredMap);
						}
						else
						{
							for (Id lcs : filteredMap.keyset())
							{
								mapSobj.put(lcs,filteredMap.get(lcs));
								if (mapSobj.size() >= 100)
								{
									mapSobjFiltered.put(i, mapSobj);
									mapSobj = new Map<Id, Id>();
									i++;
								}
							}
						}

						// THERE WILL BE MAX 2 FUTURE CALLOUT AS TRIGGER PROCESS MAX 200 RECORDS AT A TIME.
						for (Integer j : mapSobjFiltered.keySet())
						{
							if (String.valueOf(lstSobject.getSobjectType()) == 'CaseComment')
							{
								sendUpdateRequestForCaseComment(mapSobjFiltered.get(j), caseCommentIdSet, String.valueOf(lstSobject.getSobjectType()));
							}
							else
							{
								// CALL SERVICENOW UPDATE REQUEST USING FUTURE CALLOUT AND ALSO BENEFIT OF HIGHER LIMIT INSTEAD OF TRIGGER CONTEXT
								sendUpdateRequestToServiceNow(mapSobjFiltered.get(j), updatedFieldNames, String.valueOf(lstSobject.getSobjectType()));
							}
						}
					}
				}
			}
		}

		system.debug(' *** EXITING NI_ServicenowIntegration.updateIncidents() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	// ================================================================================================================
	//  FUTURE CALLOUT METHODS ========================================================================================
	// ================================================================================================================
	@future (callout = true)
	public static void createIHGIncident(Id caseId, Set<Id> setCCmtIds, Set<Id> setCVerIds)
	{
		// RETRIEVE CASE RECORD
		Case cs = [SELECT Id, Customer_Ticket_Number__c, RecordTypeID, RecordType.Name, Casenumber, Customer_Severity__c, Amadeus_External_System_Id__c,
		           Status, Subject, Owner.Name, Owner.phone, OwnerId, Acknowledged__c, Description, Pending_Code__c,
		           Amadeus_ExternalSystemAssigneeGroup__c,Assignment_Group__c, Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c,
		           Winaproach_Logger_Phone_Number__c, LastModifiedBy.Name, INTGR_Customer_Ticket_System_Id__c, INTGR_Recovery_Plan_Date_Time__c,
		           Cause_Id_Code__c, Resolution_Code__c, Reject_Reason_Code__c, Resolution_Summary__c, Incident_Start_Date_Time__c,
		           Resolved_Date_and_Time__c, Affected_Service__c, Winaproach_Owner_Group__c, parentId, Parent.Amadeus_External_System_Id__c, 
				   Rejected_Date__c, Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c
		           FROM Case
		           WHERE Id =: caseId];

		List<Case> lstCases = new List<Case>();
		lstCases.add(cs);

		system.debug(' *^* lstCases.size() = ' + lstCases.size());

		// RETRIEVE CASE COMMENT RECORDS
		List<CaseComment> lstCaseComments = [SELECT Id, CreatedDate, CreatedBy.Name, CommentBody, IsPublished
		                                     FROM CaseComment
		                                     WHERE Id IN : setCCmtIds
		                                     ORDER BY CreatedDate ASC];

		system.debug(' *^* lstCaseComments.size() = ' + lstCaseComments.size());

		// RETRIEVE CASE FILE RECORDS
		List<ContentVersion> lstContentVersions = [SELECT Id, ContentDocumentId, FileType, Description, ContentSize, Title, PathOnClient, VersionData, CreatedDate, LastModifiedDate,
		                                           CreatedBy.Name
		                                           FROM ContentVersion
		                                           WHERE Id IN : setCVerIds
		                                           ORDER BY LastModifiedDate DESC];

		system.debug(' *^* lstContentVersions.size() = ' + lstContentVersions.size());

		String strRequest = NI_ServicenowIntegration.prepareCreateRequest(cs, null, null, null);
        // Map<Id, String> mapXMLrequest = new Map<Id, String>();
		Map<String, String> mapParseResHeader = new Map<String, String>();
		Map<String, String> mapParseRes = new Map<String, String>();
		NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
		List<NI_Integration_Log__c> lstExceptionLogs = new List<NI_Integration_Log__c>();
		List<NI_Integration_Log__c> lstInsertLogs = new List<NI_Integration_Log__c>();
		Map<Id, String> mapUpdateFor = new Map<Id, String>();
		boolean parseFlag = false;
		HttpResponse httpCaseResponse;

		// TRY TO SEND CASE TO IHG
		try
		{
            // mapXMLrequest.put(cs.Id, strRequest);
			httpCaseResponse = servNowFun.Servicenow_Post_Request(strRequest);
			mapParseResHeader.put(String.valueOf(cs.Id), String.valueOf(httpCaseResponse.getStatus()));
			mapParseRes.put(String.valueOf(cs.Id), httpCaseResponse.getBody());
			mapUpdateFor.put(cs.Id, 'Case');
			// CREATE SUCCESS INTEGRATION LOG ENTRY
			servNowFun.parseAndLogResponse(httpCaseResponse.getBody(), String.valueOf(cs.Id), servNowFun.importSetEndPoint, 'Insert', 'Case', lstCases, lstInsertLogs, strRequest, httpCaseResponse.getStatus(), null, null);
		}
		catch(Exception e)
		{
			String strError = 'Error Details: \n';
			strError += e.getMessage() + ' ' + e.getStackTraceString();
			String endPoint = servNowFun.importSetEndPoint;
			NI_Integration_Log__c nException = new NI_Integration_Log__c();

			// CREATE FAILURE INTEGRATION LOG ENTRY
			if (parseFlag == true)
			{
				nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Insert', null, servNowFun.importSetEndPoint, 'ServiceNow', strRequest); //mapXMLrequest.get(cs.Id));
			}
			else
			{
				nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Update', null, endPoint, 'ServiceNow', strRequest); //mapXMLrequest.get(cs.Id));
			}
			lstExceptionLogs.add(nException);
		}

		String strSysId = '';
		String strTicketNumber = '';

		// PARSE RESPONSE AND UPDATE STANDARD CASE WITH
		dom.Document resDoc = new dom.Document();
		// Load xml string into dom element
		resDoc.load(httpCaseResponse.getBody());
		// Get root element of the response xml
		dom.XmlNode envelope = resDoc.getRootElement();

		if (httpCaseResponse.getStatus() == 'Created')
		{
			dom.XmlNode resultNode = envelope.getChildElement('result', null);

			if (resultNode.getChildElement('sys_id', null) != null)
			{
				strSysId = resultNode.getChildElement('sys_id', null).getText();
				system.debug(' *^* strSysId = ' + strSysId);
			}

			if (resultNode.getChildElement('display_value', null) != null)
			{
				strTicketNumber = resultNode.getChildElement('display_value', null).getText();
				system.debug(' *^* strTicketNumber = ' + strTicketNumber);
			}

			if (strSysId != '' && strTicketNumber != '')
			{
				cs.INTGR_Customer_Ticket_System_Id__c = strSysId;
				cs.Customer_Ticket_Number__c = strTicketNumber;
				cs.Integration_Sync_Status__c = true;
                // update cs;
			}
		}

		system.debug(' *^* httpCaseResponse.getStatusCode() = ' + httpCaseResponse.getStatusCode());
		system.debug(' *^* httpCaseResponse.getStatus() = ' + httpCaseResponse.getStatus());
		system.debug(' *^* httpCaseResponse.getBody() = ' + httpCaseResponse.getBody());

		// TRY TO SEND CASE COMMENTS
        // mapXMLrequest.clear();
		strRequest = '';
		mapParseResHeader.clear();
		mapParseRes.clear();
		mapUpdateFor.clear();
		HttpResponse httpCaseCmtResponse;
		Set<String> setNoFields = new Set<String>();
		setNoFields.add('no fields');

		for (CaseComment csCmt : lstCaseComments)
		{
			strRequest = prepareUpdateRequest(cs, csCmt, null, null, setNoFields);
			system.debug(' *^* Case Comment strRequest = ' + strRequest);
			try
			{
                // mapXMLrequest.put(csCmt.Id, strRequest);
				httpCaseCmtResponse = servNowFun.Servicenow_Post_Request(strRequest);
				mapParseResHeader.put(csCmt.Id, String.valueOf(httpCaseCmtResponse.getStatus()));
				mapParseRes.put(String.valueOf(csCmt.Id), httpCaseCmtResponse.getBody());
				mapUpdateFor.put(csCmt.Id, 'CaseComment');
				system.debug(' *^* Case Comment strRequest = SUCCESS ');
                servNowFun.parseAndLogResponse(httpCaseCmtResponse.getBody(), String.valueOf(cs.Id), servNowFun.importSetEndPoint, 'Insert', 'CaseComment', lstCases, lstInsertLogs, strRequest, httpCaseCmtResponse.getStatus(), null, null);
			}
			catch(Exception e)
			{
				system.debug(' *^* Case Comment strRequest = FAILED ');
				String strError = 'Error Details: \n';
				strError += e.getMessage() + ' ' + e.getStackTraceString();
				String endPoint = servNowFun.importSetEndPoint;
				NI_Integration_Log__c nException = new NI_Integration_Log__c();
				nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Update', null, endPoint, 'ServiceNow', strRequest); //mapXMLrequest.get(csCmt.Id));
				lstExceptionLogs.add(nException);
				system.debug(' *^* Case Comment strError = ' + strError);
			}
		}


		// TRY TO SEND FILES
		if (strSysId != '')
		{
			for (ContentVersion cv : lstContentVersions)
			{
				HttpRequest req = new HttpRequest();

				try
				{
					String queryParams = 'table_name=incident&table_sys_id=' + strSysId + '&file_name=' + EncodingUtil.urlEncode(cv.PathOnClient, 'UTF-8');

					// CREATING REQUEST - POST FILE
					HttpRequest req1 = servNowFun.Servicenow_SetHeaderForFile(req, queryParams);
					req1.setBodyAsBlob(cv.VersionData);

					Http h = new Http();
					HTTPResponse res1 = h.send(req1);

					// SHOWING REQUEST AND RESPONSE INTO LOG
                    servNowFun.parseAndLogResponse(res1.getBody(), String.valueOf(cs.Id), req1.getEndpoint(), 'Insert', 'File', lstCases, lstInsertLogs, req1.toString(), res1.getStatus(), cv.Id, cv.PathOnClient);
				}
				catch(Exception e)
				{
					String strError = 'Error Details: \n';
					strError += e.getMessage() + ' ' + e.getStackTraceString();
					String endPoint = servNowFun.importSetEndPoint;
					NI_Integration_Log__c nException = new NI_Integration_Log__c();
					nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Insert', null, endPoint, 'ServiceNow', req.getBody());
					lstExceptionLogs.add(nException);
				}
			}
		}

		system.debug(' *^* lstInsertLogs.size() = ' + lstInsertLogs.size());

		if (lstInsertLogs.size() > 0)
		{
			insert lstInsertLogs;
		}

		system.debug(' *^* lstExceptionLogs.size() = ' + lstExceptionLogs.size());

		// COMMIT INTEGRATION LOG RECORDS
		if (lstExceptionLogs.size() > 0)
		{
			insert lstExceptionLogs;
		}

		update cs;
	}

	@future (callout = true)
	public static void sendUpdateRequestToServiceNow(Map<Id, Id> mapCase, Set<String> updatedFieldNames, String oType)
	{
		system.debug(' *** ENTERING NI_ServicenowIntegration.sendUpdateRequestToServiceNow() - QUERIES ISSUED = ' + Limits.getQueries());

		// QUERY ON CASE BY HAVING IDS
		List<Case> lstCase = [SELECT Id, Customer_Ticket_Number__c,RecordTypeID, RecordType.Name, Casenumber,Customer_Severity__c, Amadeus_External_System_Id__c,
		                      Status, Subject, Owner.Name, Owner.phone, OwnerId, Acknowledged__c,Description, Pending_Code__c,
		                      Amadeus_ExternalSystemAssigneeGroup__c,Assignment_Group__c, Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c,
		                      Winaproach_Logger_Phone_Number__c, LastModifiedBy.Name, INTGR_Customer_Ticket_System_Id__c,
		                      Cause_Id_Code__c,Resolution_Code__c, Reject_Reason_Code__c,Resolution_Summary__c, Incident_Start_Date_Time__c, Resolved_Date_and_Time__c,
		                      Affected_Service__c, Winaproach_Owner_Group__c, parentId, Parent.Amadeus_External_System_Id__c, INTGR_Recovery_Plan_Date_Time__c, 
							  Rejected_Date__c, Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c 
		                      FROM Case
		                      WHERE Id IN : mapCase.keySet()];

		String request = '';
		NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
		Map<Id, Casecomment> mapCaseComt = new Map<Id, Casecomment>();
		Map<Id, Id> mapCaseIdCommId = new map<Id, Id>();
		Map<String, String> mapParseRes = new Map<String, String>();
		Map<String, String> mapParseResHeader = new Map<String, String>();
		Map<Id, String> updateFor = new Map<Id, String>();
		Map<Id, String> mapXMLrequest = new Map<Id, String>();
		List<Case> resUpdateCase = new List<Case>();
		List<NI_Integration_Log__c> reqExceptionLog = new List<NI_Integration_Log__c>();
		List<NI_Integration_Log__c> resInsertLog = new List<NI_Integration_Log__c>();
		String attachId = '';
		String attachName = '';
		boolean parseFlag = false;

		// Execute for each Case
		for (Case cs : lstCase)
		{
			if ((cs.Customer_Ticket_Number__c == null || cs.Customer_Ticket_Number__c == '') &&
			    (cs.INTGR_Customer_Ticket_System_Id__c == null || cs.INTGR_Customer_Ticket_System_Id__c == ''))
			{
				parseFlag = true;
				request = NI_ServicenowIntegration.prepareCreateRequest(cs, null, null, null);
			}
			else
			{
				boolean flag1 = false;
				for (String s : updatedFieldNames)
				{
					if (fieldUpdateListSN.contains(s))
					{
						flag1 = true;
					}
				}

				if (flag1)
				{
					request = NI_ServicenowIntegration.prepareUpdateRequest(cs, null, null, null, updatedFieldNames);
					system.debug(' **** SN Request = ' + request);
				}
				else
				{
					system.debug(' **** Cannot create SN Request!');
					continue;
				}
			}

			servNowFun = new NI_ServicenowFunctions();

			try
			{
				mapXMLrequest.put(cs.Id,request);
				HttpResponse res = servNowFun.Servicenow_Post_Request(request);
				mapParseResHeader.put(String.valueOf(cs.Id),String.valueOf(res.getStatus()));
				mapParseRes.put(String.valueOf(cs.Id),res.getBody());
				updateFor.put(cs.Id,'Case');
			}
			catch(Exception e)
			{
				String strError = 'Error Details: \n';
				strError += e.getMessage() + ' ' + e.getStackTraceString();
				String endPoint = servNowFun.importSetEndPoint;
				NI_Integration_Log__c nException = new NI_Integration_Log__c();
				// LOG FAILED MESSAGE
				if (parseFlag == true)
				{
					nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Insert', null, servNowFun.importSetEndPoint, 'ServiceNow', mapXMLrequest.get(cs.Id));
				}
				else
				{
					nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Update', null, endPoint,'ServiceNow', mapXMLrequest.get(cs.Id));
				}
				reqExceptionLog.add(nException);
			}
		}

		resUpdateCase = new List<Case>();
		resInsertLog = new List<NI_Integration_Log__c>();

		for (String cID : mapParseRes.keySet())
		{
			if (parseFlag == true)
			{
				servNowFun.parseAndLogResponse(mapParseRes.get(cId), cId, servNowFun.importSetEndPoint, 'Insert', updateFor.get(cID), resUpdateCase, resInsertLog, mapXMLrequest.get(cId), mapParseResHeader.get(cId), attachId, attachName);
			}
			else
			{
				servNowFun.parseAndLogResponse(mapParseRes.get(cId), cId, servNowFun.importSetEndPoint, 'Update', updateFor.get(cID), resUpdateCase, resInsertLog, mapXMLrequest.get(cId), mapParseResHeader.get(cId), attachId, attachName);
			}
		}

		if (resUpdateCase.size() > 0)
		{
			update resUpdateCase;
		}

		if (resInsertLog.size() > 0)
		{
			insert resInsertLog;
		}

		if (reqExceptionLog.size() > 0)
		{
			insert reqExceptionLog;
		}

		system.debug(' *** EXITING NI_ServicenowIntegration.sendUpdateRequestToServiceNow() - QUERIES ISSUED = ' + Limits.getQueries());
	}

	@future (callout = true)
	public static void sendUpdateRequestForCaseComment(Map<Id, Id> mapCase, Set<Id> caseCommentIdSet, String oType)
	{
		system.debug(' *** ENTERING NI_ServicenowIntegration.sendUpdateRequestForCaseComment() - QUERIES ISSUED = ' + Limits.getQueries());

		// QUERY ON CASE BY HAVING IDS
		List<Case> lstCase = [SELECT Id, Customer_Ticket_Number__c, RecordTypeID, RecordType.Name, Casenumber, Customer_Severity__c, Amadeus_External_System_Id__c,
		                      Status, Subject, Owner.Name, Owner.phone, OwnerId, Acknowledged__c, Description, Pending_Code__c,
		                      Amadeus_ExternalSystemAssigneeGroup__c,Assignment_Group__c, Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c,
		                      Winaproach_Logger_Phone_Number__c, LastModifiedBy.Name, INTGR_Customer_Ticket_System_Id__c,
		                      Cause_Id_Code__c, Resolution_Code__c, Reject_Reason_Code__c, Resolution_Summary__c, Incident_Start_Date_Time__c,
		                      Resolved_Date_and_Time__c, Affected_Service__c, Winaproach_Owner_Group__c, parentId, Parent.Amadeus_External_System_Id__c, 
							  INTGR_Recovery_Plan_Date_Time__c, Rejected_Date__c, Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c 
		                      FROM Case
		                      WHERE Id IN : mapCase.keySet()];

		String request = '';
		Set<String> updatedFieldNames = new Set<String>();
		NI_ServicenowFunctions servNowFun = new NI_ServicenowFunctions();
		Map<Id, Casecomment> mapCaseComt = new Map<Id, Casecomment>();
		Map<Id, Id> mapCaseIdCommId = new map<Id, Id>();
		Map<String, String> mapParseRes = new Map<String, String>();
		Map<String, String> mapParseResHeader = new Map<String, String>();
		Map<Id, String> updateFor = new Map<Id, String>();
		Map<Id, String> mapXMLrequest = new Map<Id, String>();
		List<Case> resUpdateCase = new List<Case>();
		List<NI_Integration_Log__c> reqExceptionLog = new List<NI_Integration_Log__c>();
		List<NI_Integration_Log__c> resInsertLog = new List<NI_Integration_Log__c>();
		List<NI_Integration_Log__c> resInsertLog2 = new List<NI_Integration_Log__c>();
		String attachId = '';
		String attachName = '';
		boolean parseFlag = false;

		if (oType == 'CaseComment')
		{
			mapCaseComt = new Map<Id, Casecomment>([SELECT Id, ParentId, CommentBody, CreatedBy.Name, IsPublished
			                                        FROM CaseComment
			                                        WHERE Id IN: caseCommentIdSet]);
		}
		else
		{
			mapCaseComt = new Map<Id, Casecomment>([SELECT Id, ParentId, CommentBody, CreatedBy.Name, IsPublished
			                                        FROM CaseComment
			                                        WHERE ParentId IN: caseCommentIdSet
			                                        AND LastModifiedDate > : Datetime.now().addMinutes(-1)]);
		}

		for (Id comm : mapCaseComt.keySet())
		{
			mapCaseIdCommId.put(comm, mapCaseComt.get(comm).ParentId);
		}

		resInsertLog = new List<NI_Integration_Log__c>();

		// Execute for each Case
		for (Case cs : lstCase)
		{
			for (Id csCmntId : mapCaseComt.keySet())
			{
				request = NI_ServicenowIntegration.prepareUpdateRequest(cs, mapCaseComt.get(csCmntId), null, null, updatedFieldNames);
				servNowFun = new NI_ServicenowFunctions();
				try
				{
					mapXMLrequest.put(csCmntId, request);
					HttpResponse res = servNowFun.Servicenow_Post_Request(request);
					mapParseResHeader.put(csCmntId, String.valueOf(res.getStatus()));
					mapParseRes.put(String.valueOf(csCmntId), res.getBody());
					updateFor.put(csCmntId, 'CaseComment');
				}
				catch(Exception e)
				{
					String strError = 'Error Details: \n';
					strError += e.getMessage() + ' ' + e.getStackTraceString();
					String endPoint = servNowFun.importSetEndPoint;
					NI_Integration_Log__c nException = new NI_Integration_Log__c();
					nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Update', null, endPoint, 'ServiceNow', mapXMLrequest.get(cs.Id));
					reqExceptionLog.add(nException);
				}
			}
		}

		resUpdateCase = new List<Case>();

		for (String cID : mapParseRes.keySet())
		{
			servNowFun.parseAndLogResponse(mapParseRes.get(cId), mapCaseIdCommId.get(cID), servNowFun.importSetEndPoint, 'Update', updateFor.get(cID), resUpdateCase, resInsertLog, mapXMLrequest.get(cId), mapParseResHeader.get(cId), attachId, attachName);
		}

		if (resUpdateCase.size() > 0)
		{
			update resUpdateCase;
		}

		if (resInsertLog.size() > 0)
		{
			insert resInsertLog;
		}

		if (reqExceptionLog.size() > 0)
		{
			insert reqExceptionLog;
		}

		system.debug(' *** EXITING NI_ServicenowIntegration.sendUpdateRequestForCaseComment() - QUERIES ISSUED = ' + Limits.getQueries());
	}
}