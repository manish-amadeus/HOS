/************************************************************************************************
                 !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachService Class
Integration     : Win@proach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 12/06/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
				: Updated 10/05/2017 Per NICC-024188
                : Updated 10/12/2017 Per NICC-024311 
				: Updated 12/06/2019 per NICC-039247
*************************************************************************************************/
public class NI_WinaproachService 
{
	
	public static boolean caseCommentFlag = false;
	public static boolean taskFlag = false;
	public static boolean caseTemplateFlag = false;
	public static boolean crsCaseIncidentFlag = false;
	public static String boundary = '----------------------------741e90d31eff';
	public static List<String>caseFieldsForComments = new List<String>();
	public static Map<Id, String> caseOwnerIdMap = new Map<Id, String>();	
    
    
    public NI_WinaproachService() 
    {
        
    }
    
    public NI_WinaproachService(String transactionType, List<Case> lstCases)
    {
        
        system.debug(' *** ENTERING NI_WinaproachService CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Case> filteredCases = new List<Case>();
        List<Id> filteredCasesID = new List<Id>();
        List<Id> lstCase = new List<Id>();
        Integer i = 0;
        Map<Integer, List<Id>> mapListCase = new Map<Integer, List<Id>>();
        
        //EXECUTE FOR CREATE CALL
        if (transactionType == 'Create')
        {
            
            filteredCases = filterCasesFromRecordTypes(lstCases);
            
            for (Case cs : filteredCases)
            {
                filteredCasesID.add(cs.Id);
            }
            
            // IF WE HAVE RECORDS RELATED TO WIN@PROACH	    	
            if (filteredCasesID.size() > 0)
            {
                
                //IF RECORD SIZE IS LESS OR EQUAL, ASSIGN DIRECTLY
                //AS WE HAVE LIMITATION FOR HTTP CALLOUT IN ONE TRANSACTION IS 100
                //PREPARING MAP WITH HAVING MAX 100 RECORDS MORE THAN THAT WILL BE IN NEXT BATCH
                
                if (filteredCasesID.size() <= 100)
                {
                    mapListCase.put(i, filteredCasesID);	    			
                } 
                else 
                {	
                    for (Id lcs : filteredCasesID)
                    {	    				
                        lstCase.add(lcs);	    				
                        if (lstCase.size() >= 100)
                        {
                            mapListCase.put(i, lstCase);
                            lstCase = new List<Id>();
                            i++;
                        }
                    }	    		
                }
                
                //THERE WILL BE MAX 2 FUTURE CALLOUT AS TRIGGER PROCESS MAX 200 RECORDS AT A TIME
                for (Integer j : mapListCase.keySet())
                {
                    // CALL CREATE REQUEST 
                    sendRequestToWinaproach(mapListCase.get(j));
                }
                
            }
        }    	
        
        system.debug(' *** EXITING NI_WinaproachService CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    // ==========================================================================================================================
    // 	FUNCTIONS
    // ==========================================================================================================================

    public void parseAndLogResponse(String response, String cs, String endPoint, String opType, String updateFor, List<Case> resUpdateCase, List<NI_Integration_Log__c> resInsertLog, String xmlRequest, List<Task> resUpdateTask, Attachment at, ContentVersion cv)
    {
        
        // THIS FUNCTION IS USED FOR THE PARSING THE RESPONSE OF REQUEST AND LOGGING INTO "NI INTEGRAION LOG" OBJECT 
        
        system.debug(' *** ENTERING NI_WinaproachService.parseAndLogResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';	
        dom.Document resDoc = new dom.Document();    	
        dom.XmlNode header = null;
        dom.XmlNode fault = null;
        dom.XmlNode createResponse = null;
        dom.XmlNode updateResponse = null;
        NI_Integration_Log__c niLog = new NI_Integration_Log__c();
        
        try
        {
            //LOAD XML STRING INTO DOM ELEMENT
            resDoc.load(response);
            
            //GET ROOT ELEMENT OF THE RESPONSE XML
            dom.XmlNode envelope = resDoc.getRootElement();  
            
            //IF UNAUTHORIZED RESPONSE
            String unauthorized = null;
            
            //IF RESPONSE IS UNAUTHORIZED INSERT INTEGRAION LOG AS FAILED  
            if (envelope.getChildElement('head', null) != null)
            {
                unauthorized = envelope.getChildElement('head', null).getChildElement('title', null).getText();
                niLog = NI_WinaproachService.createIntegraionLog(cs, response, 'Failed', opType, updateFor, endPoint, 'Win@proach', xmlRequest);
                if (at != null)
                {
                    niLog.Attachment_Id__c = at.Id;
                    niLog.Attachment_Name__c = at.Name;
                }
                if (cv != null)				// NICC-039247
                {
                    niLog.File_Id__c = String.valueOf(cv.Id);
                    niLog.File_Name__c = String.valueOf(cv.PathOnClient);
                }
                resInsertLog.add(niLog);   
            } 
            else 
            {
                
                header = envelope.getChildElement('Body', soapNS);                    
                fault = header.getChildElement('Fault', soapNS);
                createResponse = header.getChildElement('createResponse', null);                  
                updateResponse = header.getChildElement('updateResponse', null);
                
                // CHECK IF RESPONSE HAVING ANY FAULT OR EXCEPTION 
                if (fault != null)
                {
                    String faultString = fault.getChildElement('faultstring', null).getText();
                    
                    niLog = NI_WinaproachService.createIntegraionLog(cs, faultString, 'Failed', opType, updateFor, endPoint, 'Win@proach', xmlRequest);
                    if (at != null)
                    {
                        niLog.Attachment_Id__c = String.valueOf(at.Id);
                        niLog.Attachment_Name__c = String.valueOf(at.Name);
                    }
                    if (cv != null)			// NICC-039247
                    {
                        niLog.File_Id__c = String.valueOf(cv.Id);
                        niLog.File_Name__c = String.valueOf(cv.PathOnClient);
                    }
                    resInsertLog.add(niLog);        	
                }
                // IF CREATE INCIDENT RESPONSE IS SUCCESSFUL  
                else if (createResponse != null)
                {
                    
                    dom.XmlNode createReturn = createResponse.getChildElement('createReturn', null);
                    String innerxmlRes = createReturn.getText(); 
                    innerxmlRes = EncodingUtil.urlDecode(innerxmlRes,'UTF-8');
                    Dom.Document respDoc = new Dom.Document();
                    respDoc.load(innerxmlRes);
                    Dom.XMLNode node = respDoc.getRootElement();
                    String record_id = node.getChildElement('success', null).getChildElement('record_id', null).getText();
                    niLog = NI_WinaproachService.createIntegraionLog(cs, innerxmlRes, 'Success', opType, updateFor, endPoint, 'Win@proach', xmlRequest);
                    resInsertLog.add(niLog);
                    
                    // UPDATE THE CASE WITH SETTING VALUE FOR EXTERNEL SYSTEM ID 
                    Case cCase = new Case();
                    cCase.id = cs;
                    cCase.Amadeus_External_System_Id__c = record_id;
                    
                    //UPDATE CCASE; 
                    resUpdateCase.add(cCase);
                    
                }
                // IF UPDATE RESPONSE IS SUCESSFUL
                else if (updateResponse != null)
                {
                    
                    dom.XmlNode updateReturn = updateResponse.getChildElement('updateReturn', null);
                    String innerxmlRes = updateReturn.getText();        	
                    innerxmlRes = EncodingUtil.urlDecode(innerxmlRes,'UTF-8');
                    Dom.Document respDoc = new Dom.Document();
                    respDoc.load(innerxmlRes);
                    Dom.XMLNode node = respDoc.getRootElement();
                    String record_id = node.getChildElement('success', null).getChildElement('record_id', null).getText();
                    
                    if (updateFor == 'Task')
                    {
                        
                        Map<String,Id> mapInvTask = new Map<String,Id>();
                        Dom.XmlNode[] chlds = node.getChildElement('success', null).getChildElement('parallel_investigation_list', null).getChildElements();    
                        String maxId = '0';
                        ID taskId;
                        
                        //IF THERE ARE MULTIPLE INVESTIGATION THEN HIGHEST INVESTIGATION ID NEED TO REFER INVESTIGATION ID IS IN LONG INTEGER FORMAT 
                        for (Dom.XmlNode bkElem: chlds) 
                        {
                            // Getting max id
                            if (Long.valueOf(maxId) < Long.valueOf(bkElem.getChildElement('investigation_id', null).getText()))
                            {
                                maxId = bkElem.getChildElement('investigation_id', null).getText();
                                taskId = bkElem.getChildElement('external_investigation_id', null).getText();
                                mapInvTask.put(maxId,taskId);
                            }
                        }
                        
                        // IMPORTANT: WIN@PROACH SERVER ALWAYS RESPONSE ONE TASK ID FOR ALL INVESTIGATION IDS
                        // I.E. EXTERNAL_ID IS SAME FOR ALL INVESTIGATION_IDS					
                        Task tTask = new Task();
                        
                        if (mapInvTask.get(maxId) != null)
                        {
                            tTask.id = mapInvTask.get(maxId);	        			
                            tTask.Amadeus_External_System_Id__c = maxId;		        		
                            resUpdateTask.add(tTask);
                        }
                        
                        //CLEARING MAP
                        mapInvTask = new Map<String, Id>();
                        
                    }	        	
                    
                    niLog = NI_WinaproachService.createIntegraionLog(cs, innerxmlRes, 'Success', opType, updateFor, endPoint, 'Win@proach', xmlRequest);
                    
                    if (at != null)
                    {
                        niLog.Attachment_Id__c = String.valueOf(at.Id);
                        niLog.Attachment_Name__c = String.valueOf(at.Name);
                    }
                    
                    if (cv != null)		// NICC-039247
                    {
                        niLog.File_Id__c = String.valueOf(cv.Id);
                        niLog.File_Name__c = String.valueOf(cv.PathOnClient);
                    }                    
                    
                    resInsertLog.add(niLog);
                    
                } 		
            }
        } 
        catch (Exception e)
        {
            
            niLog = NI_WinaproachService.createIntegraionLog(cs, response, 'Failed', opType, updateFor, endPoint, 'Win@proach', xmlRequest);
            
            if (at != null)
            {
                niLog.Attachment_Id__c = String.valueOf(at.Id);
                niLog.Attachment_Name__c = String.valueOf(at.Name);
            }
            
            if (cv != null)			// NICC-039247
            {
                niLog.File_Id__c = String.valueOf(cv.Id);
                niLog.File_Name__c = String.valueOf(cv.PathOnClient);
            }               
            
            resInsertLog.add(niLog);
            
            system.debug('Error occurred: ' + e.getMessage());
            
        }
        
        system.debug(' *** EXITING NI_WinaproachService.parseAndLogResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public static NI_Integration_Log__c createIntegraionLog(String caseID, String message, String status, String traType, String updateFor, String endPoint, String intName, String xmlRequest)
    {
        
        // USED FOR CREATING THE LOG FOR THE REQUEST  
        
        system.debug(' *** ENTERING NI_WinaproachService.createIntegraionLog() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Case c = [SELECT Id, Integration_Case__c FROM Case WHERE Id =: caseID LIMIT 1];
        
        NI_Integration_Log__c niLog = new NI_Integration_Log__c();
        
        //niLog.Name = 'NI Integration Log - ' + Datetime.now().format();
        niLog.Name = 'NI Integration Log - ' + DateTime.now().format('MM/dd/yyyy hh:mm a', 'GMT') + ' GMT';
        niLog.Integration_Case__c = c.Integration_Case__c;
        niLog.Case__c = caseID;
        niLog.Description__c = message;
        niLog.Log_Date__c = Datetime.now();
        niLog.Status__c = status;
        niLog.Transaction_Type__c = traType;
        niLog.Web_Service_Endpoint__c = endPoint;
        niLog.Integration_Name__c = intName;    	
        niLog.XMLRequest__c = xmlRequest;
        
        if (status == 'Failed')
        {
            niLog.Do_Retries__c = true;
            niLog.Retries_Performed__c = 0;
        }
        
        if (updateFor != null)
        {
            niLog.UpdateFor__c = updateFor;
        }
        
        system.debug(' *** EXITING NI_WinaproachService.createIntegraionLog() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return niLog;
        
    }

    public static void createActionLogOrAttachment(List<Sobject> lstSobject, Set<String> updatedFieldNames)
    {
        
        // FUNCTION USED TO PREPARE UPDATE REQUEST FOR ACTION LOG OR ATTACHMENT         
        
        system.debug(' *** ENTERING NI_WinaproachService.createActionLogOrAttachment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Id> parentIDs = new List<Id>();
        List<Case> filteredCases = new List<Case>();
        Map<Id, List<Id>> csIdCommentId = new Map<Id, List<Id>>();
        Map<Id, Id> csIdCommentId1 = new Map<Id, Id>();
        Map<Id, Id> filteredMap = new Map<Id, Id>();
        Map<Integer, Map<Id, Id>> mapSobjFiltered = new Map<Integer, Map<Id, Id>>();
        Map<Id, Id> mapSobj = new Map<Id, Id>(); 
        Set<Id> setContentDocIds = new Set<Id>();
        Integer i = 0;
        
        // IF LIST PARAMETER IS A "CASE" SOBJECT TYPE
        if (String.valueOf(lstSobject.getSobjectType()) == 'Case' && taskFlag == false)
        {
            
            for (Case cs : (List<Case>)lstSobject)
            {
                filteredMap.put(cs.Id, cs.Id);
            }
            
            if (filteredMap.keySet().size() > 0)
            {
                // IF RECORD SIZE IS LESS OR EQUAL ASSIGN DIRECTLY
                // AS WE HAVE LIMITATION FOR HTTP CALLOUT IN ONE TRANSACTION IS 100
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
                    // CALL WIN@PROACH UPDATE REQUEST USING FUTURE CALLOUT AND ALSO BENEFIT OF HIGHER LIMIT INSTED OF TRIGGER CONTEXT
                    sendUpdateRequestToWinaproach(mapSobjFiltered.get(j), String.valueOf(lstSobject.getSobjectType()), updatedFieldNames);
                }
                
            }
        }
        else 
        {
            
            // IS NOT A CASE
            
            Map<Id, Id> csIdCommentId_temp = new Map<Id, Id>();
            Map<Id, Id> mapDocId2CaseIds = new Map<Id, Id>();             
            boolean isFiles = false;
            
            for (sObject cc : lstSobject)
            {

                system.debug(' *^* SobjectType = ' + String.valueOf(lstSobject.getSobjectType()));
                
                // IF LIST PARAMETER IS A "Task" SOBJECT TYPE
                if (String.valueOf(lstSobject.getSobjectType()) == 'Task')
                {
                    parentIDs.add((Id)cc.get('WhatId'));
                    csIdCommentId_temp.put((Id)cc.get('Id'), (Id)cc.get('WhatId'));
                }
                
                // IF LIST PARAMETER IS A "CaseComment" SOBJECT TYPE
                if (String.valueOf(lstSobject.getSobjectType()) == 'CaseComment')
                { 
                    parentIDs.add((Id)cc.get('ParentId'));
                    csIdCommentId_temp.put((Id)cc.get('Id'), (Id)cc.get('ParentId'));
                }

                // IF LIST PARAMETER IS A "Attachment" SOBJECT TYPE
                if (String.valueOf(lstSobject.getSobjectType()) == 'Attachment')
                { 
                    parentIDs.add((Id)cc.get('ParentId'));
                    csIdCommentId_temp.put((Id)cc.get('Id'), (Id)cc.get('ParentId'));
                }
                
                // IF LIST PARAMETER IS A "ContentDocumentLink" SOBJECT TYPE
                if (String.valueOf(lstSobject.getSobjectType()) == 'ContentDocumentLink')
                {
                    parentIDs.add((Id)cc.get('LinkedEntityId'));
                    setContentDocIds.add((Id)cc.get('ContentDocumentId'));
                    mapDocId2CaseIds.put((Id)cc.get('ContentDocumentId'), (Id)cc.get('LinkedEntityId')); 
                    isFiles = true;
                }  
                
            }
            
            if (isFiles)
            {
                for (ContentVersion cv : [SELECT Id, ContentDocumentId, Title, FileType, VersionData, CreatedBy.Name 
                                          FROM ContentVersion
                                          WHERE IsLatest = true 
                                          AND ContentDocumentId IN : setContentDocIds])
                {
                    csIdCommentId_temp.put(cv.Id, mapDocId2CaseIds.get(cv.ContentDocumentId)); 
                }                
            }

            for (Id cc_id : csIdCommentId_temp.keySet())
            {
                
                if (csIdCommentId != null && csIdCommentId.containsKey(csIdCommentId_temp.get(cc_id)))
                {
                    Id case_id = csIdCommentId_temp.get(cc_id);
                    List<Id> listIds = csIdCommentId.get(case_id);
                    listIds.add(cc_id);
                    csIdCommentId.put(case_id, listIds);
                }
                else 
                {
                    List<Id> listIds1 = new List<Id>();
                    listIds1.add(cc_id);
                    Id case_id = csIdCommentId_temp.get(cc_id);
                    csIdCommentId.put(case_id, listIds1);
                }
                
            }
            
            if (parentIDs.size() > 0)
            {
                
                List<String> lstRecType = new List<String>();
                
                if (Winaproach_Incident_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
                {
                    lstRecType.addAll(String.valueOf(Winaproach_Incident_Case_Record_Type__c.getValues('Default').Record_Type__c).split(','));
                }
                
                List<Case> lstCase = [SELECT Id, RecordTypeId, CaseNumber, Amadeus_External_System_Id__c, Owner.Name 
                                      FROM Case 
                                      WHERE RecordType.Name IN : lstRecType 
                                      AND Id IN : parentIDs];
                
                if (lstCase.size() > 0)
                {
                    
                    filteredCases = filterCasesFromRecordTypes(lstCase);
                    
                    for (Case cs : filteredCases)
                    {
                        List<Id> cc_ids = new List<Id>();
                        cc_ids = csIdCommentId.get(cs.Id);
                        if (cc_ids.size() >= 1) 
                        {
                            for (Id cc_id : cc_ids)
                            {
                                filteredMap.put(cc_id, cs.Id);
                            }
                        }
                    }
                    
                    if (filteredMap.keySet().size() > 0)
                    {
                        // IF RECORD SIZE IS LESS OR EQUAL ASSIGN DIRECTLY
                        // AS WE HAVE LIMITATION FOR HTTP CALLOUT IN ONE TRANSACTION IS 100
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

                            String strObjectType = String.valueOf(lstSobject.getSobjectType());
                            if (strObjectType == 'ContentDocumentLink')
                            {
                                strObjectType = 'File';
                            }

                            // CALL WIN@PROACH UPDATE REQUEST USING FUTURE CALLOUT AND ALSO BENIFIT OF HIGHER LIMIT INSTED OF TRIGGER CONTEXT 
                            sendUpdateRequestToWinaproach(mapSobjFiltered.get(j), strObjectType, updatedFieldNames);
                            
                        }
                    }
                }
            }
        }
        
        system.debug(' *** EXITING NI_WinaproachService.createActionLogOrAttachment() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
 
    public static List<Case> filterCasesFromRecordTypes(List<Case> lstCases)
    {
        
        // FUNCTION FILTERS THE CASES BASED ON RECORD TYPES USED FOR WIN@PROACH INTEGRATION 
        
        system.debug(' *** ENTERING NI_WinaproachService.filterCasesFromRecordTypes() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<Winaproach_Incident_Case_Record_Type__c> lstCR = Winaproach_Incident_Case_Record_Type__c.getall().values();
        List<string> lstRecordtypes = new List<String>();
        List<Case> filteredCases = new List<Case>();
        
        // GET THE RECORD TYPES FROM "DEFAULT" CUSTOM SETTING FOR WHICH THE WIN@PROACH API GET EXECUTED. 
        for (Winaproach_Incident_Case_Record_Type__c cr : lstCR)
        {
            if (cr.Name == 'Default')
            {
                lstRecordtypes = String.valueOf(cr.Record_Type__c).split(',');
                break;
            } 
        }
        
        // LOOK FOR RECORD TYPE OF WORK ORDERS
        if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
        {
            lstRecordtypes.add(Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c);
        }
        
        Schema.DescribeSObjectResult dCase = Schema.SObjectType.Case;
        Map<Id, Schema.RecordTypeInfo> RT = dCase.getRecordTypeInfosByID();
        Set<String> setRecordtypes = new Set<String>(lstRecordtypes);
        lstRecordtypes.clear();
        
        for (Case cs : lstCases)
        {
            if (rt.get(cs.RecordTypeId).getName() != null && setRecordtypes.contains(rt.get(cs.RecordTypeId).getName()))
            {
                filteredCases.add(cs);
            }    		
        }
        
        system.debug(' *** EXITING NI_WinaproachService.filterCasesFromRecordTypes() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return filteredCases;
        
    }

    
    
    // ==========================================================================================================================
    // 	PARSING FUNCTIONS
    // ==========================================================================================================================

    public static String prepareUpdateRequest(Case cs, Casecomment cscm, Attachment csAtt, Task csTask, ContentVersion csCV, Set<String> updatedFieldNames)
    {
        
        // FUNCTION PREPARING THE UPDATE REQUEST FOR WIN@PROACH 
         
        system.debug(' *** ENTERING NI_WinaproachService.prepareUpdateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
    	Dom.Document doc = new Dom.Document();
    	Dom.Document innerDoc = new Dom.Document();
    	String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
    	String workOrderRecordType = '';
    	Boolean isForIncidentOnly = true;
		String sText;
        
		// THIS FLOW EXECUTES FOR BOTH RECORDS TYPE I.E. CRS INCIDENT AND CRS WORK ORDER BELOW IS THE PROVISION TO PREPARE REQEUST AS PER THE RECORD TYPES.
		if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
        {
			workOrderRecordType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c;
			if (cs.RecordType.Name == workOrderRecordType)
            {
                isForIncidentOnly = false;
            }
		}

    	// PREPARE INNERXML     	
        dom.XmlNode ticketExchange = innerDoc.createRootElement('ticket_exchange', null, null);
        dom.XmlNode createNote = ticketExchange.addChildElement('update', null, null);
        
        // RECORD TYPE INCIDENT  
        dom.XmlNode record_type = createNote.addChildElement('record_type', null, null);
        
        if (!isForIncidentOnly)
        {
            record_type.addTextNode('WO');
        }
        else
        {
            record_type.addTextNode('incident');
        }

        // EXTERNAL RECORD ID MAPPED WITH CASE ID 	
        if (cs.Id != null)
        {
            dom.XmlNode external_record_id = createNote.addChildElement('external_record_id', null, null);
            external_record_id.addTextNode(cs.Id);
        }
        
        // external_record_reference MAPPED WITH CASE Customer_Ticket_Number__c 	
        if (cs.Customer_Ticket_Number__c != null)
        {
	        dom.XmlNode external_record_reference = createNote.addChildElement('external_record_reference', null, null);
	        external_record_reference.addTextNode(cs.Customer_Ticket_Number__c);
        }
        
        // RECORD ID MAPPED WITH AMADEUS_EXTERNAL_SYSTEM_ID__C 	
        dom.XmlNode record_id = createNote.addChildElement('record_id', null, null); 	
        
        if (cs.Amadeus_External_System_Id__c != null)
        {	        
            record_id.addTextNode(cs.Amadeus_External_System_Id__c);
        } 
        else 
        {
            record_id.addTextNode('XX__RECORD_ID__XX');
        }
        
        // STATUS 
        if (cs.Status != null && (isForIncidentOnly) && (cscm != null && cscm.CommentBody.contains('Status')))
        {
        	sText = cs.Status;
 			sText = sText.replaceAll('\\s+', '_');
        	sText += '__c';
            
        	try
            {
	        	if (WinaproachIncidentStatusMapping__c.getValues('Default').get(sText) != null) 
                {
	        		 // Assigning status value from custom setting
			        dom.XmlNode status = createNote.addChildElement('status', null, null);
		        	status.addTextNode(String.valueOf(WinaproachIncidentStatusMapping__c.getValues('Default').get(sText)));
	        	}
        	} 
            catch(Exception e)
            {
        		system.debug('Error occurred: ' + e.getMessage());
        		dom.XmlNode status = createNote.addChildElement('status', null, null);
		        status.addTextNode(String.valueOf(cs.Status));
        	}        	
	        
        }
        
        //HOTEL CODE ADDED 10/5/2017 Per NICC-024188
        if (cs.Hotel_Code__c != null && (updatedFieldNames.contains('Hotel_Code__c')))
        {
            Dom.XmlNode hotelCode = createNote.addChildElement('hotel_code', null, null);
            hotelCode.addTextNode(cs.Hotel_Code__c);
        }
        
        // SEVERITY 
        if (cs.Customer_Severity__c != null && (isForIncidentOnly) && (cscm != null && cscm.CommentBody.contains('Severity')))
        {
            
        	sText = cs.Customer_Severity__c;
 			sText = sText.replaceAll( '\\s+', '_');
        	sText = 'X' + sText + '__c';
        	
        	try
            {
	        	if (WinaproachIncidentSeverityMapping__c.getValues('Default').get(sText) != null) 
                {
			        dom.XmlNode severity = createNote.addChildElement('severity', null, null);
			        severity.addTextNode(String.valueOf(WinaproachIncidentSeverityMapping__c.getValues('Default').get(sText)));
	        	}
                
	        	if (WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText) != null) 
                {
			        dom.XmlNode urgency = createNote.addChildElement('urgency', null, null);
			        urgency.addTextNode(String.valueOf(WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText)));
	        	}
                
        	} 
            catch(Exception e)
            {
        		system.debug('Error occurred: ' + e.getMessage());
        		dom.XmlNode severity = createNote.addChildElement('severity', null, null);
			    severity.addTextNode(String.valueOf(cs.Customer_Severity__c));
        	}
            
        }
        
        // System field 			
        if (cs.System_Affected__c != null && (isForIncidentOnly) && updatedFieldNames.contains('System_Affected__c') && cscm == null && csAtt == null && csTask == null && csCV == null)
        {
            dom.XmlNode category = createNote.addChildElement('category', null, null);
            category.addChildElement('system_category', null, null).addTextNode(Winaproach_System_Affected__c.getValues(cs.System_Affected__c).System_Category__c);
        }
		    
        // ASSIGNEE 
        if (cs.Amadeus_ExternalSystemAssigneeGroup__c != null && (isForIncidentOnly) && updatedFieldNames.contains('Amadeus_ExternalSystemAssigneeGroup__c') && cscm == null && csAtt == null && csTask == null && csCV == null)
        {
	        dom.XmlNode assignee = createNote.addChildElement('assignee', null, null);
		    assignee.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemAssigneeGroup__c);
        }
		
		// OWNER GROUP
		if (cs.OwnerId != null && (updatedFieldNames.contains('Winaproach_Owner_Group__c') || updatedFieldNames.contains('OwnerId')) 
			&& cscm == null && csAtt == null && csTask == null && csCV == null)
        {

			Map<String, Winaproach_Owner_Group__c> mapOwnerGrp = Winaproach_Owner_Group__c.getAll();
            
			if (mapOwnerGrp.containsKey(cs.Winaproach_Owner_Group__c))
            {

				Dom.XmlNode owner = createNote.addChildElement('owner', null, null);
                
        		if (cs.Winaproach_Owner_Group__c != null)
                {
                    owner.addChildElement('group', null, null).addTextNode(cs.Winaproach_Owner_Group__c);
                }
	        		
				if (caseOwnerIdMap.get(cs.OwnerId) != null)	
                {
                    owner.addChildElement('name', null, null).addTextNode(caseOwnerIdMap.get(cs.OwnerId));
                }
				else
                {
                    owner.addChildElement('name', null, null).addTextNode('&nbsp;');
                }
					
				if (caseOwnerIdMap.get(cs.OwnerId) != null && cs.Owner.phone != null)
                {
                    owner.addChildElement('tel', null, null).addTextNode(cs.Owner.phone);
                }
				else
                {
                    owner.addChildElement('tel', null, null).addTextNode('-');
                }
					
			}
		}

	    // ACKNOWLEDGED DATE TIME
		dom.XmlNode idates;
        if (cs.Acknowledged__c != null && updatedFieldNames.contains('Acknowledged__c') && (isForIncidentOnly) && csAtt == null && csTask == null && csCV == null)
        {
			idates = createNote.addChildElement('dates', null, null);	
			idates.addChildElement('acknowledged_date_time', null, null).addTextNode(string.valueOfGmt(cs.Acknowledged__c));
        } 
        
        // NEW! WORKAROUND PROVIDED DATE
//        if (cs.Workaround_Provided_Date__c != null && updatedFieldNames.contains('Workaround_Provided_Date__c') && (isForIncidentOnly) && csAtt == null && csTask == null && csCV == null)
//        {
//            idates.addChildElement('acknowledged_date_time', null, null).addTextNode(string.valueOfGmt(cs.Workaround_Provided_Date__c));
//        }
        
        // NEW! REJECTED DATE
        if (cs.Rejected_Date__c != null && updatedFieldNames.contains('Rejected_Date__c') && (isForIncidentOnly) && csAtt == null && csTask == null && csCV == null)
        {
            if (idates == null)
            {
                idates = createNote.addChildElement('dates', null, null);	
            }  
            idates.addChildElement('rejected_on_date_time', null, null).addTextNode(string.valueOfGmt(cs.Rejected_Date__c));
        }

        // CASE UPDATE WITH CAUSE OR RESOLUTION OR REASON CODE 
        if ((isForIncidentOnly) && cscm == null && csAtt == null && csTask == null && csCV == null)
        {
	        
			// INCIDENT DATE/TIME OR RESOLVED DATE/TIME
			if (updatedFieldNames.contains('Incident_Start_Date_Time__c') || updatedFieldNames.contains('Resolved_Date_and_Time__c') || updatedFieldNames.contains('Diagnosed_Date_and_Time__c')) 
            {
				
				if (idates == null)
                {
                    idates = createNote.addChildElement('dates', null, null);
                }

        		if (cs.Incident_Start_Date_Time__c != null && updatedFieldNames.contains('Incident_Start_Date_Time__c'))
                {
					idates.addChildElement('start_date_time', null, null).addTextNode(string.valueOfGmt(cs.Incident_Start_Date_Time__c));
        		}
                
				if (cs.Resolved_Date_and_Time__c != null && updatedFieldNames.contains('Resolved_Date_and_Time__c'))
                {
					idates.addChildElement('resolved_date_time', null, null).addTextNode(string.valueOfGmt(cs.Resolved_Date_and_Time__c));
        		}
                
				if (cs.Diagnosed_Date_and_Time__c != null && updatedFieldNames.contains('Diagnosed_Date_and_Time__c'))
                {
					idates.addChildElement('diagnosed_date_time', null, null).addTextNode(string.valueOfGmt(cs.Diagnosed_Date_and_Time__c));
        		}
				
			}
			
			// MASTER FLAG
			if (updatedFieldNames.contains('MasterFlag')) 
            {
				dom.XmlNode masterflag = createNote.addChildElement('master_record_flag', null, null).addTextNode('Y');
			}
            
			if (updatedFieldNames.contains('master_record_number')) 
            {
				dom.XmlNode master_record_number = createNote.addChildElement('master_record_number', null, null).addTextNode(cs.Parent.Amadeus_External_System_Id__c);
			}
            
			// LOGGER     	     
			if (updatedFieldNames.contains('Amadeus_ExternalSystemLoggerGroup__c') || 
               updatedFieldNames.contains('Winaproach_Logger__c') || 
               updatedFieldNames.contains('Winaproach_Logger_Phone_Number__c'))
            {

				dom.XmlNode logger = createNote.addChildElement('logger', null, null);
                
        		if (cs.Amadeus_ExternalSystemLoggerGroup__c != null)
                {
                    logger.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemLoggerGroup__c);
                }
	        		
				if (cs.Winaproach_Logger__c != null)	
                {
                    logger.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c);
                }
	        		
				if (cs.Winaproach_Logger_Phone_Number__c != null)
                {
                    logger.addChildElement('tel', null, null).addTextNode(cs.Winaproach_Logger_Phone_Number__c);
                }
	        		
			} 
            
			// CAUSEID_CODE         
	        if (cs.Cause_Id_Code__c != null)
            {
	        	
				sText = String.valueOf(cs.Cause_Id_Code__c);
				sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
				sText = sText.replaceAll('\\s+', '_');
				sText = sText + '__c';
				
                try
                {
					dom.XmlNode causeid = createNote.addChildElement('causeid_code', null, null);
			        causeid.addTextNode(String.valueOf(WinaproachIncidentCauseIdMapping__c.getValues('Default').get(sText)));
					
				} 
                catch (Exception e)
                {
					system.debug('Error occurred: ' + e.getMessage());
				}			
				
	        } 
            
	        // RESOLUTION_CODE 
	        if (cs.Resolution_Code__c != null && updatedFieldNames.contains('Resolution_Code__c'))
            {
	        	
				sText = String.valueOf(cs.Resolution_Code__c);
				sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
				sText = sText.replaceAll( '\\s+', '_');
				sText = sText +'__c';

				try
                { 
					dom.XmlNode resolutionCode = createNote.addChildElement('resolution_code', null, null);
			        resolutionCode.addTextNode(String.valueOf(WinaproachIncidentResolutionCodeMapping__c.getValues('Default').get(sText)));
				} 
                catch(Exception e)
                {
					system.debug('Error occurred: ' + e.getMessage());
				}			
				
	        } 
            
	        // REJECTED REASONCODE  
	        if(cs.Reject_Reason_Code__c != null && updatedFieldNames.contains('Reject_Reason_Code__c'))
            {

				sText = String.valueOf(cs.Reject_Reason_Code__c);
				sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
				sText = sText.replaceAll('\\s+', '_');
				sText = sText + '__c';

				try
                { 
					dom.XmlNode reasonCode = createNote.addChildElement('reject_reason_code', null, null);
			        reasonCode.addTextNode(String.valueOf(WinaproachIncidentRejectedReasonCode__c.getValues('Default').get(sText)));
				} 
                catch(Exception e)
                {
					system.debug('Error occurred: ' + e.getMessage());
				}			
				
	        } 
        }
        
        if (!isForIncidentOnly)
        {
			// DESCRIPTION
			if (cs.Description !=null && updatedFieldNames.contains('Description'))
            {
        		dom.XmlNode overview = createNote.addChildElement('overview', null, null);
	        	dom.XmlNode	entry = overview.addChildElement('entry', null, null);
	        	entry.addChildElement('date_time', null, null).addTextNode(string.valueOfGmt(Datetime.now()));
                
	        	if (cs.Amadeus_ExternalSystemAssigneeGroup__c != null)
                {
                    entry.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemAssigneeGroup__c);
                }
	        		
	        	if (cs.Winaproach_Logger__c != null)
                {
                    entry.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c);
                }
	        		
	        	if (cs.Winaproach_Logger_Phone_Number__c != null)
                {
                    entry.addChildElement('tel', null, null).addTextNode(String.valueOf(cs.Winaproach_Logger_Phone_Number__c));
                }
	
				String strDesc = cs.Description;
				if (strDesc.contains('\n--------------------------\n'))
                {
					List<String> lstDesc = strDesc.split('\n--------------------------\n');
					strDesc = lstDesc.get(lstDesc.size()-1);
				}
						
				entry.addChildElement('text', null, null).addChildElement('line', null, null).addTextNode(strDesc);
                
			}
            
			// STATUS 
			if (cs.Status !=null && updatedFieldNames.contains('Status'))
            {
        	
        		sText = cs.Status;
 				sText = sText.replaceAll('\\s+', '_');
        		sText += '__c';
                
        		try
                {
	        		if (WinaproachWorkOrderStatusMapping__c.getValues('Default').get(sText) != null) 
                    {
	        			// ASSIGNING STATUS VALUE FROM CUSTOM SETTING
						dom.XmlNode status = createNote.addChildElement('status', null, null);
		        		status.addTextNode(String.valueOf(WinaproachWorkOrderStatusMapping__c.getValues('Default').get(sText)));
	        		}
        		} 
                catch(Exception e)
                {
        			system.debug('Error occurred: ' + e.getMessage());
        			dom.XmlNode status = createNote.addChildElement('status', null, null);
					status.addTextNode(String.valueOf(cs.Status));
        		}        	
			}
        }
        
        //ADDED BY STUART EMERY ON 10/18/2017 PER PROJECT BACKLOG: CRS Case Support - Recovery Plan Sev 3/4 
        dom.XmlNode u_recovery_plan_dt;
        if (updatedFieldNames.contains('INTGR_Recovery_Plan_Date_Time__c') && cs.INTGR_Recovery_Plan_Date_Time__c != null)
        {
			u_recovery_plan_dt = createNote.addChildElement('dates', null, null);	
			u_recovery_plan_dt.addChildElement('recovery_date_plan_date', null, null).addTextNode(string.valueOfGmt(cs.INTGR_Recovery_Plan_Date_Time__c));
		}
        
        // ACTION LOG 
        if (cscm != null)
        {
            
	        dom.XmlNode action_log = createNote.addChildElement('action_log', null, null);
	        dom.XmlNode	entry = action_log.addChildElement('entry', null, null);
	        entry.addChildElement('date_time', null, null).addTextNode(string.valueOfGmt(Datetime.now()));
            
	        if (cs.Amadeus_ExternalSystemAssigneeGroup__c != null)
            {
                entry.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemAssigneeGroup__c);
            }
	        	
	        if (cs.Winaproach_Logger__c != null)
            {
                entry.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c);
            }
	        	
	        if (cs.Winaproach_Logger_Phone_Number__c != null)
            {
                entry.addChildElement('tel', null, null).addTextNode(String.valueOf(cs.Winaproach_Logger_Phone_Number__c));
            }
	        	
	        entry.addChildElement('text', null, null).addChildElement('line', null, null).addTextNode(cscm.CommentBody);
            
	     }
        
         // ATTACHMENT NODE
         if (csAtt != null)
         {
	        dom.XmlNode attachment_list = createNote.addChildElement('attachment_list', null, null);
	        dom.XmlNode	attachment = attachment_list.addChildElement('attachment', null, null);
	        attachment.addChildElement('filename', null, null).addTextNode(csAtt.Name);
	        attachment.addChildElement('filesize', null, null).addTextNode(String.valueOf(csAtt.body.size()) + 'KB');
             
	        if (cs.Amadeus_ExternalSystemLoggerGroup__c != null)
            {
                attachment.addChildElement('added_by_group', null, null).addTextNode(cs.Amadeus_ExternalSystemLoggerGroup__c);
            }
	        	
	        attachment.addChildElement('added_date_time', null, null).addTextNode(string.valueOfGmt(Datetime.now()));

        }
        
        // ATTACHMENT (FILES) NODE
        if (csCV != null)
        {
            dom.XmlNode attachment_list = createNote.addChildElement('attachment_list', null, null);
            dom.XmlNode	attachment = attachment_list.addChildElement('attachment', null, null);
            attachment.addChildElement('filename', null, null).addTextNode(csCV.PathOnClient);
            String strFileSize = NI_FUNCTIONS.FileSizeToString(csCV.VersionData.size());
            attachment.addChildElement('filesize', null, null).addTextNode(strFileSize);
            //attachment.addChildElement('filesize', null, null).addTextNode(String.valueOf(csCV.VersionData.size()) + 'KB');
            
            if (cs.Amadeus_ExternalSystemLoggerGroup__c != null)
            {
                attachment.addChildElement('added_by_group', null, null).addTextNode(cs.Amadeus_ExternalSystemLoggerGroup__c);
            }
            
            attachment.addChildElement('added_date_time', null, null).addTextNode(string.valueOfGmt(Datetime.now()));
            
        }        
        
        //PARALLEL INVESTIGATION NODE MAPPED WITH TASK
        if (csTask != null)
        {
        	dom.XmlNode parallel_investigation_list = createNote.addChildElement('parallel_investigation_list', null, null);
        	dom.XmlNode	parallel_investigation = parallel_investigation_list.addChildElement('parallel_investigation', null, null);
	        parallel_investigation.addChildElement('external_investigation_id', null, null).addTextNode(csTask.Id);	 
            
	        if (csTask.Parallel_Investigation_Reason_Code__c != null) 
            {
	        	sText = String.valueOf(csTask.Parallel_Investigation_Reason_Code__c);
				sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
				sText = sText.replaceAll('\\s+', '_');
				sText = sText +'__c';

				try
                {	        			
	        		parallel_investigation.addChildElement('investigation_reason_code', null, null).addTextNode(String.valueOf(WinaproachIncidentInvestigationMapping__c.getValues('Default').get(sText)));
				}
                catch(Exception e)
                {
					system.debug('Custom setting not found for investigation_reason_code: ' + e.getMessage());
				}	
	        }
            
	        if (csTask.Added_By_Group__c != null)
            {
                parallel_investigation.addChildElement('investigation_added_by_group', null, null).addTextNode(csTask.Added_By_Group__c);
            }
	        	
	        if (csTask.Parallel_Investigation_Group__c != null)
            {
                parallel_investigation.addChildElement('investigation_group', null, null).addTextNode(csTask.Parallel_Investigation_Group__c);
            }
	        	
	        if (csTask.Status != null)
            {
                parallel_investigation.addChildElement('investigation_status', null, null).addTextNode(csTask.Status);
            }
	        	
	        if (csTask.Sub_Status__c != null)
            {
               parallel_investigation.addChildElement('investigation_substatus', null, null).addTextNode(csTask.Sub_Status__c); 
            }

			if (csTask.Activity__c != null && csTask.Activity__c != '')
            {
                parallel_investigation.addChildElement('investigation_activity', null, null).addTextNode(String.valueOf(Winaproach_PI_Activity_Field_Mapping__c.getValues(String.valueOf(csTask.Activity__c)).Activity_Short_Name__c));	        		
            }
	        	
			if (csTask.Description != null)
            {
                parallel_investigation.addChildElement('investigation_comment', null, null).addTextNode(csTask.Description);  
            }
	        	      		    	
        }
        
        // CREATE REQUEST ENVELOPE 
        Dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        //envelope.setNamespace('acc', acc);
        envelope.setAttributeNS('xsi', 'http://www.w3.org/2001/XMLSchema-instance', null, null);
        
        // CREATE BODY OF THE REQUEST 
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
        body.addChildElement('update', null, null).addChildElement('incomingXML', null, null).addTextNode(innerDoc.toXmlString());

        system.debug(' *** EXITING NI_WinaproachService.prepareUpdateRequest() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (csAtt != null || csCV != null)
        {
            // XML REQUEST CONTAINS ACTUAL XML DATA AND BINARY ATTACHMENT SETTING UP MULTIPART HEADER IN REQUEST FOR ATTACHMENT 
            return(doc.toXmlString());
        } 
        else 
        {            
            return(doc.toXmlString());
        }

    }
    
    public static String prepareAttachment(String XML_BODY, Attachment attachObj) 
    {
        
        //	PREPARE ATTACHMENT (SPECIAL) FOR WIN@PROACH
        //	PARAMETER XML NODES OF ATTACHMENT E.G. RECORDID, EXTERNALID ETC.
        //	USE: #1 PREPARE XML REQUEST OF ATTACHMENT,
        // 		 #2 ACTUAL ATTACHMENT OBJECT         
        
        system.debug(' *** ENTERING NI_WinaproachService.prepareAttachment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String localboundary = NI_WinaproachService.boundary;
        String header = '';
        header += '--' + localboundary+'\r\n';
        header += 'Content-Type: text/xml; name="text"\r\n\r\n' + XML_BODY + '\r\n';		
        String footer = '--' + localboundary + '--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header + '\r\n\r\n'));
        
        while(headerEncoded.endsWith('=')) 
        {
            header += ' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        
        String attachmentsStr = '';
        String lastPrepend = '';
        
        if (attachObj != null) 
        {

            Blob fileBlob = attachObj.Body;
            String filename = attachObj.Name;
            String fHeader = lastPrepend + '--' + localboundary + '\r\n';
            fHeader += 'Content-Disposition: form-data; name="files[' + filename + ']"; filename="' + filename + '"\r\nContent-Type: application/octet-stream';
            String fHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(fHeader + '\r\n\r\n'));
            
            while (fHeaderEncoded.endsWith('=')) 
            {
                fHeader += ' ';
                fHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(fHeader + '\r\n\r\n'));
            }
            
            String fbodyEncoded = EncodingUtil.base64Encode(fileBlob);
            String last4Bytes = fbodyEncoded.substring(fbodyEncoded.length() - 4, fbodyEncoded.length());
            
            if (last4Bytes.endsWith('==')) 
            {
                last4Bytes = last4Bytes.substring(0, 2) + '0K';
                fBodyEncoded = fbodyEncoded.substring(0, fbodyEncoded.length() - 4) + last4Bytes;
                lastPrepend = '';
            } 
            else if (last4Bytes.endsWith('=')) 
            {
                last4Bytes = last4Bytes.substring(0, 3) + 'N';
                fBodyEncoded = fbodyEncoded.substring(0, fbodyEncoded.length() - 4) + last4Bytes;
                lastPrepend = '\n';
            } 
            else 
            {
                lastPrepend = '\r\n';
            }
            
            attachmentsStr += fHeaderEncoded + fBodyEncoded;
            footer = lastPrepend + footer;
        } 
        else 
        {
            footer = '\r\n' + footer;
        }
        
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        
        system.debug(' *** EXITING NI_WinaproachService.prepareAttachment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return headerEncoded + attachmentsStr + footerEncoded;
        
    }

    public static String prepareFile(String strXMLBody, ContentVersion cVers) 
    {

        system.debug(' *** ENTERING NI_WinaproachService.prepareAttachment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String strLocalboundary = NI_WinaproachService.boundary;
        String strHeader = '';
        strHeader += '--' + strLocalboundary + '\r\n';
        strHeader += 'Content-Type: text/xml; name="text"\r\n\r\n' + strXMLBody + '\r\n';		
        String strFooter = '--' + strLocalboundary + '--';
        String strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader + '\r\n\r\n'));

        while (strHeaderEncoded.endsWith('=')) 
        {
            strHeader += ' ';
            strHeaderEncoded = EncodingUtil.base64Encode(Blob.valueOf(strHeader + '\r\n\r\n'));     
        }
        
        String strFiles = '';
        String strLastPrepend = '';
        
        if (cVers != null) 
        {
            Blob fileBlob = cVers.VersionData;
            String strFilename = cVers.PathOnClient;
            String strHeader2 = strLastPrepend + '--' + strLocalboundary + '\r\n';
            strHeader2 += 'Content-Disposition: form-data; name="files[' + strFilename + ']"; filename="' + strFilename + '"\r\nContent-Type: application/octet-stream';
            String strHeaderEncoded2 = EncodingUtil.base64Encode(Blob.valueOf(strHeader2 + '\r\n\r\n'));
            
            while (strHeaderEncoded2.endsWith('=')) 
            {              
                strHeader2 += ' ';
                strHeaderEncoded2 = EncodingUtil.base64Encode(Blob.valueOf(strHeader2 + '\r\n\r\n'));               
            }
            
            String strBodyEncoded = EncodingUtil.base64Encode(fileBlob);
            String strLast4Bytes = strBodyEncoded.substring(strBodyEncoded.length() - 4, strBodyEncoded.length());
            
            if (strLast4Bytes.endsWith('==')) 
            {
                strLast4Bytes = strLast4Bytes.substring(0, 2) + '0K';
                strBodyEncoded = strBodyEncoded.substring(0, strBodyEncoded.length() - 4) + strLast4Bytes;
                strLastPrepend = '';
            } 
            else if (strLast4Bytes.endsWith('=')) 
            {
                strLast4Bytes = strLast4Bytes.substring(0, 3) + 'N';
                strBodyEncoded = strBodyEncoded.substring(0, strBodyEncoded.length() - 4) + strLast4Bytes;
                strLastPrepend = '\n';
            } 
            else 
            {
                strLastPrepend = '\r\n';
            }
            
            strFiles += strHeaderEncoded2 + strBodyEncoded;
            strFooter = strLastPrepend + strFooter;
            
        } 
        else 
        {
            strFooter = '\r\n' + strFooter;
        }
        
        String strFooterEncoded = EncodingUtil.base64Encode(Blob.valueOf(strFooter));
        
        system.debug(' *** EXITING NI_WinaproachService.prepareAttachment() - QUERIES ISSUED = ' + Limits.getQueries());
       
        return strHeaderEncoded + strFiles + strFooterEncoded;
        
    }    
    
    public static String prepareCreateRequestWinaproach(Case cs)
    {
        
        system.debug(' *** ENTERING NI_WinaproachService.prepareCreateRequestWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';	
        Dom.Document doc = new DOM.Document();
        Dom.Document innerDoc = new DOM.Document();
        String sText;    
        
        // PREPARE INNERXML    	
        Dom.XmlNode ticketExchange = innerDoc.createRootElement('ticket_exchange', null, null);        
        Dom.XmlNode createNote = ticketExchange.addChildElement('create', null, null);
        
        // RECORD TYPE INCIDENT  
        Dom.XmlNode record_type = createNote.addChildElement('record_type', null, null);
        record_type.addTextNode('incident');
        
        // EXTERNAL RECORD ID MAPPED WITH CASE NUMBER	
        if (cs.Id != null)
        {
            Dom.XmlNode external_record_id = createNote.addChildElement('external_record_id', null, null);
            external_record_id.addTextNode(cs.Id);
        }

        // NEW!
        ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
        if (SNSettings != null && SNSettings.Winaproach_AccountId__c != null)
        {
            Dom.XmlNode customer_accountid = createNote.addChildElement('customer_accountid', null, null);
            customer_accountid.addTextNode(SNSettings.Winaproach_AccountId__c); 
        }

        // NEW!
        if (cs.Integration_Account__c != null)
        {
            try
            {
                INTGR_Account__c iCase = [SELECT Id, Winaproach_AccountId__c FROM INTGR_Account__c WHERE Id =: cs.Integration_Account__c];
                Integer iTest = Integer.valueOf(iCase.Winaproach_AccountId__c);
                Dom.XmlNode customer_accountid = createNote.addChildElement('customer_accountid', null, null);
                customer_accountid.addTextNode(iCase.Winaproach_AccountId__c);                     
            }
            catch (Exception ex) {} 
        }


        // external_record_reference MAPPED WITH CASE Customer_Ticket_Number	
        if (cs.Customer_Ticket_Number__c != null)
        {
            Dom.XmlNode external_record_reference = createNote.addChildElement('external_record_reference', null, null);
            external_record_reference.addTextNode(cs.Customer_Ticket_Number__c);
        }
        
        // SYSTEM FIELD 			
        if (cs.System_Affected__c != null && Winaproach_System_Affected__c.getValues(cs.System_Affected__c) != null)
        {
            Dom.XmlNode category = createNote.addChildElement('category', null, null);
            category.addChildElement('system_category', null, null).addTextNode(Winaproach_System_Affected__c.getValues(cs.System_Affected__c).System_Category__c);
        }
        
        // SEVERITY  	
        if (cs.Customer_Severity__c != null)
        {
            
            // ASSIGNING SEVERITY VALUE FROM CUSTOM SETTING
            sText = cs.Customer_Severity__c;
            sText = sText.replaceAll('\\s+', '_');
            sText = 'X' + sText + '__c';
            
            try
            {
                
                if (WinaproachIncidentSeverityMapping__c.getValues('Default').get(sText) != null) 
                { 
                    Dom.XmlNode severity = createNote.addChildElement('severity', null, null);
                    severity.addTextNode(String.valueOf(WinaproachIncidentSeverityMapping__c.getValues('Default').get(sText)));
                }
                
                // URGENCY  
                if (WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText) != null) 
                { 
                    // ASSIGNING URGENCY VALUE FROM CUSTOM SETTING
                    Dom.XmlNode urgency = createNote.addChildElement('urgency', null, null);
                    urgency.addTextNode(String.valueOf(WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText)));
                }
                
            }
            catch (Exception e)
            {
                system.debug('Error occured: ' + e.getMessage());
                Dom.XmlNode severity = createNote.addChildElement('severity', null, null);
                severity.addTextNode(String.valueOf(cs.Customer_Severity__c));
            }
            
        }
        
        // STATUS MAPPED WITH STATUS NODE BY USING CUSTOM SETTINGS
        if (cs.Status != null)
        {
            
            sText = cs.Status;
            sText = sText.replaceAll('\\s+', '_');
            sText += '__c';

            // ADDED THIS TO PREVENT EXCEPTION WHEN THE CASE STATUS HAPPENS TO BE A VALUE THAT HAS NO CORRESPONDING CUSTOM SETTING FIELD NAME
            DescribeSObjectResult dsr = SObjectType.WinaproachIncidentStatusMapping__c;
            dsr = Schema.WinaproachIncidentStatusMapping__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> mapFlds = dsr.fields.getMap();
            
            if (mapFlds.containsKey(sText))
            {
                if (WinaproachIncidentStatusMapping__c.getValues('Default').get(sText) != null) 
                {
                    // ASSIGNING STATUS VALUE FROM CUSTOM SETTING
                    dom.XmlNode Status = createNote.addChildElement('Status', null, null);
                    Status.addTextNode(String.valueOf(WinaproachIncidentStatusMapping__c.getValues('Default').get(sText)));                    
                }
            }
            
        }
        
        // ADDED 10/5/2017 PER NICC-024188
        if (cs.Hotel_Code__c != null)
        {
            Dom.XmlNode hotelCode = createNote.addChildElement('hotel_code', null, null);
            hotelCode.addTextNode(cs.Hotel_Code__c);
        }
        
        // ASSIGNEE 	
        if (cs.Amadeus_ExternalSystemAssigneeGroup__c != null)
        {
            Dom.XmlNode assignee = createNote.addChildElement('assignee', null, null);
            assignee.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemAssigneeGroup__c);
        }
        
        // LOGGER     	     
        Dom.XmlNode logger = createNote.addChildElement('logger', null, null);
        
        if (cs.Amadeus_ExternalSystemLoggerGroup__c != null)
        {
            logger.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemLoggerGroup__c);
        }
        
        if (cs.Winaproach_Logger__c != null)	
        {
            logger.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c);
        }
        
        if (cs.Winaproach_Logger_Phone_Number__c != null)	
        {
            logger.addChildElement('tel', null, null).addTextNode(cs.Winaproach_Logger_Phone_Number__c);
        }
        
        // MASTER RECORD NUMBER
        if (cs.ParentId != null)
        {
            if (cs.Parent.Amadeus_External_System_Id__c != null)
            {
                Dom.XmlNode master_record_number = createNote.addChildElement('master_record_number', null, null).addTextNode(cs.Parent.Amadeus_External_System_Id__c);
            }            
        }
        
        // OWNER GROUP
        Map<String, Winaproach_Owner_Group__c> mapOwnerGrp = Winaproach_Owner_Group__c.getAll();
        
        if (mapOwnerGrp.containsKey(cs.Winaproach_Owner_Group__c))
        {
            
            Dom.XmlNode owner = createNote.addChildElement('owner', null, null);
            
            if (cs.Winaproach_Owner_Group__c != null)
            {
                owner.addChildElement('group', null, null).addTextNode(cs.Winaproach_Owner_Group__c);
            }
            
            if (caseOwnerIdMap.get(cs.OwnerId) != null)
            {
                owner.addChildElement('name', null, null).addTextNode(caseOwnerIdMap.get(cs.OwnerId));
            }
            
            if (caseOwnerIdMap.get(cs.OwnerId) != null && cs.Owner.phone != null)
            {
                owner.addChildElement('tel', null, null).addTextNode(cs.Owner.phone);
            }
            
        }
        
        // DATES     	     
        Dom.XmlNode dates = createNote.addChildElement('dates', null, null);
        
        if (cs.Incident_Start_Date_Time__c != null)
        {        		
            dates.addChildElement('start_date_time', null, null).addTextNode(string.valueOfGmt(cs.Incident_Start_Date_Time__c));
        }
        
        if (cs.Resolved_Date_and_Time__c != null)
        {	
            dates.addChildElement('resolved_date_time', null, null).addTextNode(string.valueOfGmt(cs.Resolved_Date_and_Time__c));
        }
        
        dom.XmlNode u_recovery_plan_dt;
        
        // NEW!   Populate Rejected Date Time field when the case status changes to Rejected (only null) 
        if (cs.INTGR_Recovery_Plan_Date_Time__c != null || cs.Workaround_Rejected_Date__c != null)
        {
            u_recovery_plan_dt = createNote.addChildElement('dates', null, null);	
            
            if (cs.INTGR_Recovery_Plan_Date_Time__c != null)
            {
                u_recovery_plan_dt.addChildElement('recovery_date_plan_date', null, null).addTextNode(string.valueOfGmt(cs.INTGR_Recovery_Plan_Date_Time__c));
            }            
            
            if (cs.Workaround_Rejected_Date__c != null)
            {
                u_recovery_plan_dt.addChildElement('rejected_on_date_time', null, null).addTextNode(string.valueOfGmt(cs.Workaround_Rejected_Date__c));
            }
        }        
        // AFFECTED SERVICE -> DI 
        if (cs.Affected_Service__c != null)
        {
            Dom.XmlNode affected_service = createNote.addChildElement('affected_service', null, null);
            affected_service.addTextNode(String.valueOf(cs.Affected_Service__c));
        }
        
        // TITLE -> SUBJECT 	
        if (cs.Subject != null)
        {
            dom.XmlNode title = createNote.addChildElement('title', null, null);
            title.addTextNode(String.valueOf(cs.Subject));
        }
        
        // DESCRIPTION -> DESCRIPTION 	
        if (cs.Description != null)
        {
            
            Dom.XmlNode action_log = createNote.addChildElement('description', null, null);
            Dom.XmlNode	entry = action_log.addChildElement('entry', null, null);
            entry.addChildElement('date_time', null, null).addTextNode(string.valueOfGmt(Datetime.now()));
            
            if (cs.Amadeus_ExternalSystemAssigneeGroup__c != null)
            {
                entry.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemAssigneeGroup__c);
            }
            
            if(cs.Winaproach_Logger__c != null)
            {
                entry.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c);
            }
            
            if (cs.Winaproach_Logger_Phone_Number__c != null)
            {
                entry.addChildElement('tel', null, null).addTextNode(String.valueOf(cs.Winaproach_Logger_Phone_Number__c));
            }
            
            entry.addChildElement('text', null, null).addChildElement('line', null, null).addTextNode(cs.Description);
            
        }
        
        // CAUSEID_CODE         
        if (cs.Cause_Id_Code__c != null)
        {
            
            sText = String.valueOf(cs.Cause_Id_Code__c);
            sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
            sText = sText.replaceAll('\\s+', '_');
            sText = sText + '__c';
            
            try
            {
                Dom.XmlNode causeid = createNote.addChildElement('causeid_code', null, null);
                causeid.addTextNode(String.valueOf(WinaproachIncidentCauseIdMapping__c.getValues('Default').get(sText)));
            } 
            catch(Exception e)
            {
                system.debug(' **** Error Occurred: ' + e.getMessage());
            }			
            
        } 
        
        // RESOLUTION_CODE 
        if (cs.Resolution_Code__c != null)
        {
            
            sText = String.valueOf(cs.Resolution_Code__c);
            sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
            sText = sText.replaceAll('\\s+', '_');
            sText = sText + '__c';
            
            try
            {
                Dom.XmlNode resolutionCode = createNote.addChildElement('resolution_code', null, null);
                resolutionCode.addTextNode(String.valueOf(WinaproachIncidentResolutionCodeMapping__c.getValues('Default').get(sText)));
            } 
            catch (Exception e)
            {
                system.debug('Error Occurred: ' + e.getMessage());
            }
        } 
        
        // REJECTED REASONCODE  
        if (cs.Reject_Reason_Code__c != null)
        {
            
            sText = String.valueOf(cs.Reject_Reason_Code__c);
            sText = sText.replaceAll('[\\(\\)\\,\\.\\/]','');			
            sText = sText.replaceAll('\\s+', '_');
            sText = sText + '__c';
            
            try
            { 
                Dom.XmlNode reasonCode = createNote.addChildElement('reject_reason_code', null, null);
                reasonCode.addTextNode(String.valueOf(WinaproachIncidentRejectedReasonCode__c.getValues('Default').get(sText)));
            } 
            catch (Exception e)
            {
                system.debug('Error Occurred: ' + e.getMessage());
            }			
            
        }
        
        // CREATE REQUEST ENVELOPE 
        Dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        
        // envelope.setNamespace('acc', acc);
        envelope.setAttributeNS('xsi', 'http://www.w3.org/2001/XMLSchema-instance', null, null);
        
        // CREATE BODY OF THE REQUEST 
        Dom.XmlNode body= envelope.addChildElement('Body', soapNS, null);        
        body.addChildElement('create', null, null).addChildElement('incomingXML', null, null).addTextNode(innerDoc.toXmlString());
        
        system.debug(' *** RETURNING: ' + doc.toXmlString());
        system.debug(' *** EXITING NI_WinaproachService.prepareCreateRequestWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());

        // RETURN CREATED XML REQUEST
        return(doc.toXmlString());
        
    }
    
    public static String prepareWorkOrderCreateRequestWinaproach(Case cs)
    {
        
        system.debug(' *** ENTERING NI_WinaproachService.prepareWorkOrderCreateRequestWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';	
        Dom.Document doc = new Dom.Document();
        Dom.Document innerDoc = new Dom.Document();
        String sText;
        
        // PREPARE INNERXML    	
        Dom.XmlNode ticketExchange = innerDoc.createRootElement('ticket_exchange', null, null);
        Dom.XmlNode createNote = ticketExchange.addChildElement('create', null, null);
        
        // RECORD TYPE INCIDENT  
        Dom.XmlNode record_type = createNote.addChildElement('record_type', null, null);
        record_type.addTextNode('WO');
        
        // EXTERNAL RECORD ID MAPPED WITH CASE NUMBER	
        if (cs.Id != null)
        {
            Dom.XmlNode external_record_id = createNote.addChildElement('external_record_id', null, null);
            external_record_id.addTextNode(cs.Id);
        }
        
        // NEW!
        ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
        if (SNSettings != null && SNSettings.Winaproach_AccountId__c != null)
        {
            Dom.XmlNode customer_accountid = createNote.addChildElement('customer_accountid', null, null);
            customer_accountid.addTextNode(SNSettings.Winaproach_AccountId__c); 
        }
        else
        {
            if (cs.Integration_Account__c != null)
            {
                try
                {
                    INTGR_Account__c iCase = [SELECT Id, Winaproach_AccountId__c FROM INTGR_Account__c WHERE Id =: cs.Integration_Account__c];
                    Integer iTest = Integer.valueOf(iCase.Winaproach_AccountId__c);
                    Dom.XmlNode customer_accountid = createNote.addChildElement('customer_accountid', null, null);
                    customer_accountid.addTextNode(iCase.Winaproach_AccountId__c);                     
                }
                catch (Exception ex) {}                
            }
        }        
        
        // SEVERITY  	
        if (cs.Customer_Severity__c != null) 
        {
            // ASSIGNING SEVERITY VALUE FROM CUSTOM SETTING
            sText = cs.Customer_Severity__c;
            
            if (!sText.isNumeric())
            {
                sText = sText.substring(0, 1);
            }
            
            if (sText.isNumeric())
            {  
                
                sText = sText.replaceAll('\\s+', '_');
                sText = 'X' + sText + '__c';
                
                if (WinaproachIncidentSeverityMapping__c.getValues('Default').get(sText) != null) 
                { 
                    Dom.XmlNode severity = createNote.addChildElement('severity', null, null);
                    severity.addTextNode(String.valueOf(WinaproachIncidentSeverityMapping__c.getValues('Default').get(sText)));
                }
                
                // URGENCY  
                if (WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText) != null) 
                { 
                    // ASSIGNING URGENCY VALUE FROM CUSTOM SETTING
                    Dom.XmlNode urgency = createNote.addChildElement('urgency', null, null);
                    urgency.addTextNode(String.valueOf(WinaproachIncidentUrgencyMapping__c.getValues('Default').get(sText)));
                }
                
            }
            
        }
        
        // CATEGORY     	     
        Dom.XmlNode dcategory = createNote.addChildElement('category', null, null);        	
        dcategory.addChildElement('system_category', null, null).addTextNode('T');	       
        dcategory.addChildElement('work_order_type', null, null).addTextNode('OTHER');
        
        // STATUS MAPPED WITH STATUS NODE BY USING CUSTOM SETTINGS
        if (cs.Status != null)
        {
            
            sText = cs.Status;
            sText = sText.replaceAll('\\s+', '_');
            sText += '__c';
            
            try
            {
                if (WinaproachWorkOrderStatusMapping__c.getValues('Default').get(sText) != null) 
                {
                    // ASSIGNING STATUS VALUE FROM CUSTOM SETTING
                    Dom.XmlNode Status = createNote.addChildElement('Status', null, null);		       
                    Status.addTextNode(String.valueOf(WinaproachWorkOrderStatusMapping__c.getValues('Default').get(sText)));
                }
            }
            catch (Exception e)
            {
                system.debug('Error occurred: ' + e.getMessage());
            }
            
        }
        
        // LOGGER     	     
        Dom.XmlNode logger = createNote.addChildElement('logger', null, null);
        
        if (cs.Amadeus_ExternalSystemLoggerGroup__c != null)
        {
            logger.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemLoggerGroup__c);
        }
        
        if (cs.Winaproach_Logger__c != null)	
        {
            logger.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c);
        }
        
        if (cs.Winaproach_Logger_Phone_Number__c != null)
        {
            logger.addChildElement('tel', null, null).addTextNode(cs.Winaproach_Logger_Phone_Number__c);
        }
        
        // DATES     	     
        Dom.XmlNode dates = createNote.addChildElement('dates', null, null);
        
        if (cs.CreatedDate != null)
        {
            dates.addChildElement('requested_date_time', null, null).addTextNode(string.valueOfGmt(cs.CreatedDate));
        }

        dom.XmlNode u_recovery_plan_dt;
        // NEW!   Populate Rejected Date Time field when the case status changes to Rejected (only null) 
        if (cs.INTGR_Recovery_Plan_Date_Time__c != null || cs.Workaround_Rejected_Date__c != null)
        {
            u_recovery_plan_dt = createNote.addChildElement('dates', null, null);	
            u_recovery_plan_dt.addChildElement('recovery_date_plan_date', null, null).addTextNode(string.valueOfGmt(cs.INTGR_Recovery_Plan_Date_Time__c));
            if (cs.Workaround_Rejected_Date__c != null)
            {
                u_recovery_plan_dt.addChildElement('rejected_on_date_time', null, null).addTextNode(string.valueOfGmt(cs.Workaround_Rejected_Date__c));
            }
        }
        
        
        // AFFECTED SERVICE -> DI 
        if (cs.Affected_Service__c != null)
        {
            Dom.XmlNode affected_service = createNote.addChildElement('affected_service', null, null);
            affected_service.addTextNode(String.valueOf(cs.Affected_Service__c));
        }
        
        // TITLE -> SUBJECT 	
        if (cs.Subject != null)
        {
            Dom.XmlNode title = createNote.addChildElement('title', null, null);
            title.addTextNode(String.valueOf(cs.Subject));
        }
        
        // DESCRIPTION -> DESCRIPTION 	
        if (cs.Description != null)
        {
            
            Dom.XmlNode action_log = createNote.addChildElement('overview', null, null);
            Dom.XmlNode	entry = action_log.addChildElement('entry', null, null);
            entry.addChildElement('date_time', null, null).addTextNode(string.valueOfGmt(cs.CreatedDate));
            
            if (cs.Amadeus_ExternalSystemAssigneeGroup__c != null)
            {
                entry.addChildElement('group', null, null).addTextNode(cs.Amadeus_ExternalSystemAssigneeGroup__c);
            }
            
            if (cs.Winaproach_Logger__c != null)
            {
                entry.addChildElement('name', null, null).addTextNode(cs.Winaproach_Logger__c); 
            }
            
            if (cs.Winaproach_Logger_Phone_Number__c != null)
            {
                entry.addChildElement('tel', null, null).addTextNode(String.valueOf(cs.Winaproach_Logger_Phone_Number__c));
            }
            
            entry.addChildElement('text', null, null).addChildElement('line', null, null).addTextNode(cs.Description);
            
        }
        
        // CREATE WORK ORDER REQUEST ENVELOPE 		
        Dom.XmlNode envelope = doc.createRootElement('Envelope', soapNS, 'soapenv');
        //envelope.setNamespace('acc', acc);
        envelope.setAttributeNS('xsi', 'http://www.w3.org/2001/XMLSchema-instance', null, null);
        
        // CREATE BODY OF THE REQUEST 
        Dom.XmlNode body = envelope.addChildElement('Body', soapNS, null);
        
        body.addChildElement('create', null, null).addChildElement('incomingXML', null, null).addTextNode(innerDoc.toXmlString());
        
        system.debug(' *** EXITING NI_WinaproachService.prepareWorkOrderCreateRequestWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //RETURN CREATED XML REQUEST
        return(doc.toXmlString());
        
    }
    
    
    // ==========================================================================================================================
    //  FUTURE CALLOUT METHODS ==================================================================================================
	// ==========================================================================================================================
    @future(callout=true)
    public static void sendRequestToWinaproach(List<Id> lstCaseIds)
    {
        
        //	FUTURE CALLOUT REQUEST TO CREATE INCIDENT IN WIN@PROACH
        //	PARAMETER LIST CASE IDS
        //	USE: #1 PREPARE XML REQUEST FROM GIVEN CASE IDS,
        // 		 #2 SEND HTTP REQUEST TO WIN@PROACH
        //		 #3 PARSE HTTP RESPONSE FROM WIN@PROACH
        //		 #4 LOG REQUEST AND RESPONSE WITH STATUS IN NI_INTEGRATION_LOG OBJECT			
        
        system.debug(' *** ENTERING NI_WinaproachService.sendRequestToWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //DEFINE REQUIRED VARIABLES 
        Http objhttp = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();        
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        List<NI_Integration_Log__c> resInsertLog = new List<NI_Integration_Log__c>();
        List<NI_Integration_Log__c> reqExceptionLog = new List<NI_Integration_Log__c>();		
        String workOrderRecordType = '';
        String request = '';
        String masterUpdateReq = '';
        NI_WinaproachService winAp = new NI_WinaproachService();
        Map<String, String> mapParseRes = new Map<String, String>();
        Map<Id, String> mapXMLrequest = new Map<Id, String>();
        List<Case> resUpdateCase = new List<Case>();
        Set<String> caseOwnerIDSet = new set<String>();
        List<NI_Integration_Log__c> resParentInsertLog = new List<NI_Integration_Log__c>();
        List<NI_Integration_Log__c> reqParentExceptionLog = new List<NI_Integration_Log__c>();
        Attachment att = new Attachment();
        
        if (Winaproach_Work_Order_Case_Record_Type__c.getValues('Default') != null && Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c != null)
        {
            workOrderRecordType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default').Record_Type__c;
        }	
        
        // LIST FOR CURRENT CASES
        List<Case> lstCase = [SELECT Id, Hotel_Code__c, RecordTypeID, RecordType.Name, Casenumber, Customer_Ticket_Number__c, Customer_Severity__c,System_Affected__c, Amadeus_External_System_Id__c, 
                              Amadeus_ExternalSystemAssigneeGroup__c, Status, Subject,Description, OwnerID, Owner.Name, Owner.phone, Affected_Service__c, 
                              Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c, Winaproach_Logger_Phone_Number__c, Winaproach_Owner_Group__c, LastModifiedBy.Name,
                              Cause_Id_Code__c, Resolution_Code__c, INTGR_Recovery_Plan_Date_Time__c, Reject_Reason_Code__c, Incident_Start_Date_Time__c, Resolved_Date_and_Time__c, 
                              CreatedDate, parentId, Parent.Amadeus_External_System_Id__c, Account.AccountNumber, Rejected_Date__c, 
                              Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c, Integration_Account__c 
                              FROM Case 
                              WHERE Id IN : lstCaseIds];
        
Map<Id, String> mapCase2WinaproachId = new Map<Id, String>();
        List<Id> lstMasterIds = new List<Id>();
        
        for (Case mcs : lstCase)
        {
            
if (mcs.Amadeus_External_System_Id__c != null)
{
	mapCase2WinaproachId.put(mcs.Id, mcs.Amadeus_External_System_Id__c);
}
            
            if (mcs.ParentId != null)
            {
                lstMasterIds.add(mcs.ParentId);
            }
        }
        
        // MAP OF PARENT CASES
        Map<Id, Case> mapParentCase = new Map<Id, Case>([SELECT Id, Hotel_Code__c, RecordTypeID, RecordType.Name, Casenumber,Customer_Severity__c,Customer_Ticket_Number__c, System_Affected__c, 
                                                         Amadeus_External_System_Id__c, status,Subject, Owner.Name, Owner.phone, OwnerId, Acknowledged__c,Description,
                                                         Amadeus_ExternalSystemAssigneeGroup__c, Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c, Winaproach_Logger_Phone_Number__c, 
                                                         LastModifiedBy.Name, Cause_Id_Code__c,Resolution_Code__c, INTGR_Recovery_Plan_Date_Time__c, Reject_Reason_Code__c, 
                                                         Incident_Start_Date_Time__c, Resolved_Date_and_Time__c, Affected_Service__c, Winaproach_Owner_Group__c, parentId, Parent.Amadeus_External_System_Id__c, 
                                                         Rejected_Date__c, Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c, Integration_Account__c  
                                                         FROM Case 
                                                         WHERE Id IN : lstMasterIds]);
        
        // PREPARING LIST FOR CASE OWNERIDS
        for (AggregateResult csowner : [SELECT OwnerId FROM Case WHERE Id IN : lstCaseIds GROUP BY OwnerId])
        {
            caseOwnerIDSet.add(String.valueOf(csowner.get('OwnerId')));
        }
        
        // PREPARING LIST FOR CASE OWNERIDS WITH WIN@PROACH USERS
        for (User usr : [SELECT Id, Win_proach_User_Login__c FROM User WHERE Id IN : caseOwnerIDSet])
        {
            caseOwnerIdMap.put(usr.Id, usr.Win_proach_User_Login__c);
        }
        
        // ITERATING OVER CASES AND SENDING HTTP REQUEST TO WIN@PROACH SERVER
        for (Case cs : lstCase)
        {
            
            // IF RECORD TYPE IS WORKORDER ELSE CASE IS OF TYPE INCIDENT
            if (cs.RecordType.Name == workOrderRecordType)
            {
                request = NI_WinaproachService.prepareWorkOrderCreateRequestWinaproach(cs);
            } 
            else 
            {
                request = NI_WinaproachService.prepareCreateRequestWinaproach(cs);
                
                // IF CASE HAVING PARENTID NEED TO PREPARE UPDATE REQUEST
                if (mapParentCase.get(cs.parentId) != null)
                {
                    masterUpdateReq = NI_WinaproachService.prepareUpdateRequest(mapParentCase.get(cs.parentId), null, null, null, null, new Set<String>{'MasterFlag'});
                    Http objhttpp = new Http();
                    HttpRequest reqp = new HttpRequest();
                    HttpResponse resp = new HttpResponse();
                    
                    try
                    {
                        reqp.setMethod('POST'); 
                        reqp.setEndpoint(winSettings.Endpoint__c);
                        Blob headerValue = Blob.valueOf(winSettings.Username__c + ':' + winSettings.Password__c);		        
                        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                        
                        // SET THE NECESSARY HEADERS
                        reqp.setHeader('Authorization', authorizationHeader);
                        reqp.setHeader('Content-Type','text/plain');                
                        reqp.setHeader('SOAPAction', '');
                        
                        // SET BODY OF THE REQUEST
                        reqp.setBody(masterUpdateReq);  
                        reqp.setTimeout(120000);
                        
                        // SEND HTTP REQUEST AND GET RESPONSE 
                        resp = objhttp.send(reqp);
                        
                        //winAp = new NI_WinaproachService();
                        mapParseRes.put(mapParentCase.get(cs.parentId).Id, resp.getBody());
                        mapXMLrequest.put(mapParentCase.get(cs.parentId).Id, masterUpdateReq);
                        
                    }
                    catch (Exception e)
                    {
                        String strError = 'Error Details: \n';	
                        strError += e.getMessage() + ' ' + e.getStackTraceString();
                        String endPoint= winSettings.Endpoint__c;
                        NI_Integration_Log__c nException = new NI_Integration_Log__c();
                        
                        // LOG FAILED MESSAGE
                        nException = NI_WinaproachService.createIntegraionLog(mapParentCase.get(cs.parentId).id, strError, 'Failed', 'Update', null, endPoint,'Win@proach', mapXMLrequest.get(mapParentCase.get(cs.parentId).Id));
                        reqExceptionLog.add(nException);
                        
                    }
                }
            }
            
            try
            {
                req.setMethod('POST'); 
                req.setEndpoint(winSettings.Endpoint__c);
                Blob headerValue = Blob.valueOf(winSettings.Username__c+ ':' + winSettings.Password__c);		        
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                
                // SET THE NECESSARY HEADERS
                req.setHeader('Authorization', authorizationHeader);
                req.setHeader('Content-Type','text/plain');                
                req.setHeader('SOAPAction', '');
                
                // SET BODY OF THE REQUEST
                req.setBody(request);  
                req.setTimeout(120000);
                
                // SEND HTTP REQUEST AND GET RESPONSE 
                res = objhttp.send(req);
                
                //winAp = new NI_WinaproachService();
                mapParseRes.put(cs.Id, res.getBody());
                mapXMLrequest.put(cs.Id, request);
                
            } 
            catch (exception e)
            {
                
                String strdate = Datetime.now().format('YYYY-MM-dd-hh-mm-ss');
                String strError = '';
                String endPoint = '';
                List<String> arrParsed = strdate.split('-');		
                DateTime expected = DateTime.newInstance(Integer.valueOf(arrParsed.get(0)), Integer.valueOf(arrParsed.get(1)), Integer.valueOf(arrParsed.get(2)), Integer.valueOf(arrParsed.get(3)), Integer.valueOf(arrParsed.get(4)), Integer.valueOf(arrParsed.get(5)));
                
                system.debug('Error occurred: ' + e.getMessage());
                
                if (winSettings == null)
                {
                    strError += 'Possible Error Cause : Winaproach Custom Setting record might not be exist as a name "Default" \n\n';				
                }
                else
                {
                    endPoint = winSettings.Endpoint__c;
                }
                
                strError += 'Error Details: \n';	
                strError += e.getMessage() + ' ' + e.getStackTraceString();
                
                // LOG FAILED MESSAGE
                NI_Integration_Log__c nException = new NI_Integration_Log__c();
                nException = NI_WinaproachService.createIntegraionLog(cs.Id, strError, 'Failed', 'Insert', null, endPoint, 'Win@proach', mapXMLrequest.get(cs.Id));
                reqExceptionLog.add(nException);
                
            }
            
        }
system.debug(' *%%* mapParseRes = ' + mapParseRes); 
        // PARSE AND LOG RESPONSE OF THE REQUEST FOR CREATE REQUEST
        for (String cId : mapParseRes.keySet())
        {
system.debug(' *%%* cId = ' + cId);             
            String strIns = 'Insert';
//            if (mapParentCase.containsKey(cId))
if (mapCase2WinaproachId.containsKey(cId))
            {
                strIns = 'Update';
            }
system.debug(' *%%* strIns = ' + strIns);  // NICC-039247
            //winAp.parseAndLogResponse(mapParseRes.get(cId), cId, winSettings.Endpoint__c, strIns, null, resUpdateCase, resInsertLog, mapXMLrequest.get(cId), null, null, null);
            winAp.parseAndLogResponse(mapParseRes.get(cId), cId, winSettings.Endpoint__c, 'Insert', null, resUpdateCase, resInsertLog, mapXMLrequest.get(cId), null, null, null);
        }
        
        // UPDATE CASE OBJECT WITH WIN@PRAOCH ID
        if (resUpdateCase.size() > 0)
        {
            update resUpdateCase;
        }
        
        // INSERT SUCESSFUL LOG
        if (resInsertLog.size() > 0)
        {
            insert resInsertLog;
        }
        
        // INSERT FAILED LOG FROM WIN@PROACH SERVER 
        if (reqExceptionLog.size() > 0)
        {
            insert reqExceptionLog;
        }
        
        system.debug(' *** EXITING NI_WinaproachService.sendRequestToWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    @future(callout=true)
    public static void sendUpdateRequestToWinaproach(Map<Id, Id> mapCase, String strObjType, Set<String> setUpdatedFieldNames)
    {
        
        //	FUTURE CALLOUT REQUEST TO UPDATE INCIDENT IN WIN@PROACH
        //	PARAMETER LIST CASE IDS AND OBJECT USED E.G. CASE, CASECOMMENT, TASK ETC.
        //	USE: #1 PREPARE XML REQUEST FROM GIVEN CASE IDS,
        // 		 #2 SEND HTTP REQUEST TO WIN@PROACH
        //		 #3 PARSE HTTP RESPONSE FROM WIN@PROACH
        //		 #4 LOG REQUEST AND RESPONSE WITH STATUS IN NI_INTEGRAION_LOG OBJECT			
        
        system.debug(' *** ENTERING NI_WinaproachService.sendUpdateRequestToWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        system.debug(' *^* PARAMS: mapCase = ' + mapCase + ', strObjType = ' + strObjType + ', setUpdatedFieldNames = ' + setUpdatedFieldNames);        
        
        // DEFINE VARIABLES
        Http objhttp = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        String masterUpdateReq = '';
        List<NI_Integration_Log__c> reqExceptionLog = new List<NI_Integration_Log__c>() ;
        List<NI_Integration_Log__c> resInsertLog = new List<NI_Integration_Log__c>();
        Map<String, String> mapParseRes = new Map<String, String>();
        Map<String, String> mapXMLrequest = new Map<String, String>();
        Map<String, String> updateFor = new Map<String, String>();
        List<Case> resUpdateCase = new List<Case>();
        List<Task> resUpdateTask = new List<Task>();
        NI_WinaproachService winAp = new NI_WinaproachService();
        Set<String> caseOwnerIDSet = new Set<String>();
        Map<Id, Casecomment> mapCaseComt;
        Map<Id, Attachment> mapCaseAtt;
        Map<Id, ContentVersion> mapCase2ContentVersion;
        Map<Id, Task> mapCaseTask;
        Map<Id, List<Id>> csIdCommentId = new Map<Id, List<Id>>();
        String strTransactionType = 'Update';				// NICC-039247     (was = 'Insert';)
        Set<Id> case_ids = new Set<Id>();
        case_ids = new Set<Id>(mapCase.values());
        
        for (Id cc_id : mapCase.keySet())
        {
            if (csIdCommentId != null && csIdCommentId.containsKey(mapCase.get(cc_id)))
            {
                Id case_id = mapCase.get(cc_id);
                List<Id> listIds = csIdCommentId.get(case_id);
                listIds.add(cc_id);
                csIdCommentId.put(case_id,listIds);
            }
            else 
            {
                List<Id> listIds1 = new List<Id>();
                listIds1.add(cc_id);
                Id case_id = mapCase.get(cc_id);
                csIdCommentId.put(case_id, listIds1);
            }
        }
        
        // QUERY ON CASE BY HAVING IDS
        List<case> lstCase = [SELECT Id, Hotel_Code__c,RecordTypeID,RecordType.Name, Casenumber,Customer_Ticket_Number__c,Customer_Severity__c, System_Affected__c, 
                              Amadeus_External_System_Id__c, status,Subject, Owner.Name, Owner.phone, OwnerId, Acknowledged__c, Description, Amadeus_ExternalSystemAssigneeGroup__c, 
                              Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c, Winaproach_Logger_Phone_Number__c, LastModifiedBy.Name, Cause_Id_Code__c,
                              Resolution_Code__c, INTGR_Recovery_Plan_Date_Time__c, Reject_Reason_Code__c, Incident_Start_Date_Time__c, Resolved_Date_and_Time__c, 
                              Diagnosed_Date_and_Time__c, Affected_Service__c, Winaproach_Owner_Group__c, parentId, Parent.Amadeus_External_System_Id__c, 
                              Rejected_Date__c, Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c, Account.AccountNumber  
                              FROM Case 
                              WHERE Id IN : case_ids];
        
        List<Id> lstMasterIds = new List<Id>();
        for (Case mcs : lstCase)
        {
            if (mcs.ParentId != null)
            {
                lstMasterIds.add(mcs.ParentId); 
            }
        }
        
        // MAP OF PARENT CASES
        Map<Id, Case> mapParentCase = new Map<Id, Case>([SELECT Id, Hotel_Code__c, RecordTypeID, RecordType.Name, Casenumber, Customer_Ticket_Number__c, Customer_Severity__c, 
                                                         System_Affected__c, Amadeus_External_System_Id__c, status,Subject, Owner.Name, Owner.phone, OwnerId, Acknowledged__c,
                                                         Description, Amadeus_ExternalSystemAssigneeGroup__c, Winaproach_Logger__c, Amadeus_ExternalSystemLoggerGroup__c, 
                                                         Winaproach_Logger_Phone_Number__c, LastModifiedBy.Name, Cause_Id_Code__c,Resolution_Code__c, Reject_Reason_Code__c, 
                                                         INTGR_Recovery_Plan_Date_Time__c, Incident_Start_Date_Time__c, Resolved_Date_and_Time__c, Diagnosed_Date_and_Time__c, 
                                                         Affected_Service__c, Winaproach_Owner_Group__c, parentId, Parent.Amadeus_External_System_Id__c, 
                                                         Rejected_Date__c, Work_Around_Available__c, Workaround_Provided_Date__c, Workaround_Rejected_Date__c, IsOperationalIssue__c 
                                                         FROM Case 
                                                         WHERE Id IN : lstMasterIds]);
        
        for (AggregateResult csowner : [SELECT OwnerId FROM Case WHERE Id IN : case_ids GROUP BY OwnerId])
        {
            caseOwnerIDSet.add(String.valueOf(csowner.get('OwnerId')));
        }
        
        for (User usr : [SELECT Id, Win_proach_User_Login__c FROM User WHERE Id IN : caseOwnerIDSet])
        {
            caseOwnerIdMap.put(usr.Id, usr.Win_proach_User_Login__c);
        }
        
        if (strObjType == 'Case')
        {
            strTransactionType = 'Insert';		// NICC-039247     (was = 'Update';)
        }

        if (strObjType == 'CaseComment')
        {
            strTransactionType = 'Update';
            mapCaseComt = new Map<Id, Casecomment>([SELECT Id, ParentId, CommentBody, CreatedBy.Name
                                                    FROM CaseComment 
                                                    WHERE Id IN : mapCase.keyset()
                                                    ORDER BY CreatedDate]);
        }
        else if (strObjType == 'Attachment')
        {
            mapCaseAtt = new Map<Id, Attachment>([SELECT Id, Name, ParentId, Body, ContentType, CreatedBy.Name 
                                                 FROM Attachment 
                                                 WHERE Id IN : mapCase.keyset()]);
        }
        else if (strObjType == 'File')
        {       
            mapCase2ContentVersion = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId, Title, FileType, PathOnClient, VersionData, CreatedBy.Name 
                                                                  FROM ContentVersion
                                                                  WHERE IsLatest = true 
                                                                  AND Id IN : mapCase.keyset()]); 
        }        
        else if (strObjType == 'Task')
        {
            mapCaseTask = new Map<Id, Task>([SELECT Id, WhatId, subject, CreatedBy.Name, Status, Sub_Status__c, Parallel_Investigation_Reason_Code__c, Added_By_Group__c, 
                                             Parallel_Investigation_Group__c, Description, Activity__c 
                                             FROM Task 
                                             WHERE Id IN : mapCase.keyset()]);
        }
        
        String request = '';
        String strBody = '';
        
        // EXECUTE FOR EACH CASE 
        for (Case cs : lstCase)
        {
System.debug(' cs.Amadeus_External_System_Id__c = ' + cs.Amadeus_External_System_Id__c);        
            List<Id> lst = new List<Id>();
            lst = csIdCommentId.get(cs.Id);
            
            for (Id cc_id : lst)
            {
                
                if (strObjType == 'CaseComment')
                {
                    request = NI_WinaproachService.prepareUpdateRequest(cs, mapCaseComt.get(cc_id), null, null, null, setUpdatedFieldNames);
                }
                else if (strObjType == 'Attachment')
                {
                    request = NI_WinaproachService.prepareUpdateRequest(cs, null, mapCaseAtt.get(cc_id), null, null, setUpdatedFieldNames);
                    strBody = prepareAttachment(request, mapCaseAtt.get(cc_id));
                }
                else if (strObjType == 'File')
                {
                    request = NI_WinaproachService.prepareUpdateRequest(cs, null, null, null, mapCase2ContentVersion.get(cc_id), setUpdatedFieldNames);
                    strBody = prepareFile(request, mapCase2ContentVersion.get(cc_id));
                }                
                else if (strObjType == 'Task')
                {
                    request = NI_WinaproachService.prepareUpdateRequest(cs, null, null, mapCaseTask.get(cc_id), null, setUpdatedFieldNames);
                }
                else if (strObjType == 'Case') 
                {
                    request = NI_WinaproachService.prepareUpdateRequest(cs, null, null, null, null, setUpdatedFieldNames);	
                    
                    if (mapParentCase.get(cs.parentid) != null && setUpdatedFieldNames.contains('master_record_number'))
                    {
                        
                        masterUpdateReq = NI_WinaproachService.prepareUpdateRequest(mapParentCase.get(cs.parentId), null, null, null, null, new Set<String>{'MasterFlag'});
                        Http objhttpp = new Http();
                        HttpRequest reqp = new HttpRequest();
                        HttpResponse resp = new HttpResponse();
                        
                        try
                        {
                            
                            reqp.setMethod('POST'); 
                            reqp.setEndpoint(winSettings.Endpoint__c);
                            Blob headerValue = Blob.valueOf(winSettings.Username__c + ':' + winSettings.Password__c);
                            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                            
                            // SET THE NECESSARY HEADERS
                            reqp.setHeader('Authorization', authorizationHeader);
                            reqp.setHeader('Content-Type','text/plain');                
                            reqp.setHeader('SOAPAction', '');
                            
                            // SET BODY OF THE REQUEST
                            reqp.setBody(masterUpdateReq);  
                            reqp.setTimeout(120000);
                            
                            // SEND HTTP REQUEST AND GET RESPONSE 
                            resp = objhttp.send(reqp);
                            
                            mapParseRes.put(mapParentCase.get(cs.parentId).Id + '_' + cs.Id, resp.getBody());
                            mapXMLrequest.put(mapParentCase.get(cs.parentId).Id + '_' + cs.Id,masterUpdateReq);
                            updateFor.put(mapParentCase.get(cs.parentId).Id + '_' + cs.Id, strObjType);
                            
                        }
                        catch (Exception e)
                        {
                            String strError = 'Error Details: \n';	
                            strError += e.getMessage() + ' ' + e.getStackTraceString();
                            String endPoint= winSettings.Endpoint__c;
                            
                            // LOG FAILED MESSAGE
                            NI_Integration_Log__c nException = new NI_Integration_Log__c();
                            nException = NI_WinaproachService.createIntegraionLog(mapParentCase.get(cs.parentId).Id, strError, 'Failed', 'Update', null, endPoint, 'Win@proach', mapXMLrequest.get(mapParentCase.get(cs.parentId).Id + '_' + cs.id));
                            reqExceptionLog.add(nException);
                        }
                    }
                }
                
                try
                {
                    
                    req.setMethod('POST'); 
                    req.setEndpoint(winSettings.Endpoint__c);
                    Blob headerValue = Blob.valueOf(winSettings.Username__c+ ':' + winSettings.Password__c);
                    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    
                    //  SET THE NECESSARY HEADERS 
                    req.setHeader('Authorization', authorizationHeader);
                    req.setHeader('SOAPAction', '""');
                    
                    if (strObjType == 'Attachment' || strObjType == 'File')
                    {                     
                        req.setHeader('Content-Type', 'multipart/related; boundary=' + NI_WinaproachService.boundary);
                        req.setHeader('MIME_VERSION', '1.0');
                        req.setHeader('Content-Length', String.valueOf(strBody.length()));
                        req.setHeader('ACCEPT_ENCODING', 'gzip,deflate');
                        req.setTimeout(120000);
                        Blob bodyBlob = EncodingUtil.base64Decode(strBody);
                        req.setBodyAsBlob(bodyBlob);
                    }
                    else 
                    {
                        req.setHeader('Content-Type','text/plain');
                        // SET BODY OF THE REQUEST 
                        req.setBody(request);
                    }
                    
                    mapXMLrequest.put(cs.Id + '_' + cc_id, request);

                    // SEND HTTP REQUEST AND GET RESPONSE 
                    res = objhttp.send(req);

                    mapParseRes.put(String.valueOf(cs.id + '_' + cc_id), res.getBody());	            
                    updateFor.put(cs.Id + '_' + cc_id, strObjType);
                    
                } 
                catch (exception e)
                {
                    
                    String strdate = Datetime.now().format('YYYY-MM-dd-hh-mm-ss');
                    String strError = '';
                    String endPoint = '';
                    List<String> arrParsed = strdate.split('-');		
                    DateTime expected = DateTime.newInstance(Integer.valueOf(arrParsed.get(0)), Integer.valueOf(arrParsed.get(1)), Integer.valueOf(arrParsed.get(2)),Integer.valueOf(arrParsed.get(3)), Integer.valueOf(arrParsed.get(4)), Integer.valueOf(arrParsed.get(5)));
                    
                    if (winSettings == null)
                    {
                        strError += 'Possible Error Cause : Winaproach Custom Setting record might not be exist as a name "Default" \n\n';				
                    }
                    else
                    {
                        endPoint = winSettings.Endpoint__c;
                    }
                    
                    strError += 'Error Details: \n';	
                    strError += e.getMessage() + ' ' + e.getStackTraceString();
                    
                    // LOG THE ERROR MESSAGE 
                    NI_Integration_Log__c nException = new NI_Integration_Log__c();
                    nException = NI_WinaproachService.createIntegraionLog(String.valueOf(cs.Id), strError, 'Failed', 'Update', strObjType, endPoint, 'Win@proach', mapXMLrequest.get(cs.Id + '_' + cc_id));
                    
                    if (mapCaseAtt != null)
                    {
                        //Attachment at = mapCaseAtt.get(mapCase.get(cs.Id));
                        Attachment at = mapCaseAtt.get(cc_id);
                        if (at != null) 
                        {
                            nException.Attachment_Id__c = at.Id;
                            nException.Attachment_Name__c = at.Name;
                        }
                    }
                    
                    if (mapCase2ContentVersion != null)
                    {
                        ContentVersion cv = mapCase2ContentVersion.get(cc_id);
                        if (cv != null) 
                        {
                            nException.File_Id__c = cv.Id;				// NICC-039247
                            nException.File_Name__c = cv.PathOnClient;
                        }
                    }                    
                    
                    reqExceptionLog.add(nException);
                }
            }
        }
        
        resUpdateCase = new List<Case>();
        resUpdateTask = new List<Task>();
        resInsertLog = new List<NI_Integration_Log__c>();
        
        for (String cId : mapParseRes.keySet())
        {
            
            List<String> ids = new List<String>();
            String case_id = '';
            String att_id = '';
            
            if (cID.contains('_')) 
            {
                ids = cId.split('_');
                case_id = ids[0];
                att_id = ids[1];
            }
            
            if (mapCaseAtt != null) 
            {
                winAp.parseAndLogResponse(mapParseRes.get(cId), case_id, winSettings.Endpoint__c, strTransactionType, updateFor.get(cID), resUpdateCase, resInsertLog, mapXMLrequest.get(cId), resUpdateTask, mapCaseAtt.get(att_id), null);
            }
            else 
            {
                if (mapCase2ContentVersion != null)
                {
                    winAp.parseAndLogResponse(mapParseRes.get(cId), case_id, winSettings.Endpoint__c, strTransactionType, updateFor.get(cID), resUpdateCase, resInsertLog, mapXMLrequest.get(cId), resUpdateTask, null, mapCase2ContentVersion.get(att_id));                  
                }
                else
                {
                    winAp.parseAndLogResponse(mapParseRes.get(cId), case_id, winSettings.Endpoint__c, strTransactionType, updateFor.get(cID), resUpdateCase, resInsertLog, mapXMLrequest.get(cId), resUpdateTask, null, null);                  
                }
                
            }
            
        }
        
        if (resUpdateCase.size() > 0)
        {
            update resUpdateCase;
        }
        
        if (resInsertLog.size() > 0)
        {
            system.debug(' *%* resInsertLog = ' + resInsertLog);
            database.insert(resInsertLog, false); // THIS CAUSES THE FOLLOWING ERROR INTERMITENTLY: System.DmlException: Insert failed. First exception on row 0; first error: UNABLE_TO_LOCK_ROW, unable to obtain exclusive access to this record or 1 records
        }
        
        if (resUpdateTask.size() > 0)
        {
            update resUpdateTask;
        }
        
        if (reqExceptionLog.size() > 0)
        {
            insert reqExceptionLog;
        }        
        
        system.debug(' *** EXITING NI_WinaproachService.sendUpdateRequestToWinaproach() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}