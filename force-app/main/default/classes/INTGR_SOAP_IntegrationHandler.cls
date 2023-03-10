/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_SOAP_IntegrationHandler 
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Integration handler class which takes care of calling 3rd party application and handling 
				: 
************************************************************************************************/
public class INTGR_SOAP_IntegrationHandler 
{
    
    public INTGR_Case_SOQLDataProvider daoObj = new INTGR_Case_SOQLDataProvider();
    

    private INTGR_SOAP_SN_Incident.insertResponse_element createInsertCallOut(INTGR_SOAP_SN_Incident.insert_element reqObj, INTGR_SOAP_SN_Incident.ServiceNowSoap soap, NI_Integration_Log__c logObj, INTGR_Case__c caseObj, String endPoint) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Request Format, Map of Case Id vs Integration Case Object, Map of Source and Target Field Mapping based on Integration account selected.
        // Return: String of request body could be XML or JSON string.
        // Description: Method responsible to generate request body string based on format selected      
        
        system.debug(' *** ENTERING INTGR_SOAP_IntegrationHandler.createInsertCallOut() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return soap.insert_x(reqObj, endPoint);
        
    }
    
    private string createUpdateCallOut(INTGR_SOAP_SN_Incident.update_element obj, INTGR_SOAP_SN_Incident.ServiceNowSoap soap, NI_Integration_Log__c logObj, INTGR_Case__c caseObj, INTGR_Case_Comment__c comm, String objName, String endPoint) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Request Format, Map of Case Id vs Integration Case Object, Map of Source and Target Field Mapping based on Integration account selected.
        // Return: String of request body could be XML or JSON string.
        // Description: Method responsible to generate request body string based on format selected
        
        system.debug(' *** ENTERING INTGR_SOAP_IntegrationHandler.createUpdateCallOut() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return soap.update_x(obj, endPoint);
        
    }

    @testvisible 
    private void parseSOAPResponse(String sysId, String incNumber, INTGR_Case__c caseObj) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Request Format, Map of Case Id vs Integration Case Object, Map of Source and Target Field Mapping based on Integration account selected.
        // Return: String of request body could be XML or JSON string.
        // Description: Method responsible to generate request body string based on format selected
        
        system.debug(' *** ENTERING INTGR_SOAP_IntegrationHandler.parseSOAPResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
        //daoObj.updateIntegrationCaseWithResponseParam(sysId, incNumber, caseObjList, sObjectType);
        String errorMsg = '';
        system.debug(' **** sysIdsysId = ' + sysId);
        system.debug(' **** incNumber = ' + incNumber);
        errorMsg = daoObj.updateINTCaseSysIdAndIncidentNo(sysId, incNumber, caseObj);
        
        if (!errorMsg.ContainsIgnoreCase('error')) 
        {
            INTGR_IntegrationHelper.isUpdateSFCase = true;
        }
        
        system.debug(' *** EXITING INTGR_SOAP_IntegrationHandler.parseSOAPResponse() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    @future(callout=true) 
    public static void incident_CreateSOAPCallout(Id recordId, String objType, String operationName) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Request Format, Map of Case Id vs Integration Case Object, Map of Source and Target Field Mapping based on Integration account selected.
        // Return: String of request body could be XML or JSON string.
        // Description: Method responsible to generate request body string based on format selected        
        
        system.debug(' *** ENTERING INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // String uNamePwd, Map <Id, sObject> caseObjMap, Map<String, String> srcTargetFieldMap, String caseObjStr, String operationName
        INTGR_SOAP_SN_Incident.insert_element insertObj = new INTGR_SOAP_SN_Incident.insert_element();
        INTGR_SOAP_SN_Incident.update_element updateObj = new INTGR_SOAP_SN_Incident.update_element();
        INTGR_Case_SOQLDataProvider daoObj = new INTGR_Case_SOQLDataProvider();
        INTGR_SOAP_SN_Incident.ServiceNowSoap soap = new INTGR_SOAP_SN_Incident.ServiceNowSoap();
        INTGR_Case__c intCaseObj = new INTGR_Case__c();
        INTGR_Case_Comment__c intCommObj = new INTGR_Case_Comment__c();
        String intUNamePWD = '';
        String intSysName = '';
        String sysId = '';
        String endPoint = '';
        String intReqFormat = '';
        NI_Integration_Log__c logObj = new NI_Integration_Log__c ();
        List<NI_Integration_Log__c> loglist = new list<NI_Integration_Log__c>();
        String response = '';
        Map<String, String> srcTargetFieldMap;
        
        // POPULATE INTEGRATION CASE ALONG WITH INTEGRATION ACCOUNT INFORMATION BASED ON CASE ID.
        if (objType.equalsIgnoreCase('INTGR_Case__c'))
        {
            srcTargetFieldMap = new Map<String,String>();
            intCaseObj = INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList(recordId);
            intUNamePWD = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
            intSysName = intCaseObj.INTGR_Account__r.External_Integration_System_Name__c;
            endPoint = intCaseObj.INTGR_Account__r.Integration_Endpoint_SOAP__c;
            intReqFormat = intCaseObj.INTGR_Account__r.RequestFormat__c;
            srcTargetFieldMap = INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCaseObj.INTGR_Account__c, 'INTGR_Case__c');
        }
        
        // POPULATE INTEGRATION CASE COMMENT WITH INTEGRATION ACCOUNT INFORMATION BASED ON CASE COMMENT ID.
        if (objType.equalsIgnoreCase('INTGR_Case_Comment__c'))
        {
            srcTargetFieldMap = new Map<String,String>();
            intCommObj = INTGR_Case_SOQLDataProvider.getCaseCommIdVsIntegrationAccDetails(recordId);
            intUNamePWD = intCommObj.INTGR_Case__r.INTGR_Account__r.External_System_Username__c + ':' + intCommObj.INTGR_Case__r.INTGR_Account__r.External_System_Password__c;
            intSysName = intCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c;
            endPoint = intCommObj.INTGR_Case__r.INTGR_Account__r.Integration_Endpoint_SOAP__c;
            intReqFormat = intCommObj.INTGR_Case__r.INTGR_Account__r.RequestFormat__c;
            
            if (operationName.equalsIgnoreCase('insert'))
            {
                sysId  = intCommObj.INTGR_Case__r.Customer_Ticket_System_Id__c;
            }
            
            if (!intCommObj.CommentBody__c.ContainsIgnoreCase('-- [Created By Amadeus'))
            {
                if (null != intCommObj.CreateDate__c )
                {
                    String createdDate = INTGR_IntegrationHelper.getFormattedComment(intCommObj.CreateDate__c );
                    intCommObj.CommentBody__c = '-- [Created By Amadeus ' + createdDate +'] \n     ' + intCommObj.CommentBody__c ;
                } 
                //else 
                //{
                //    intCommObj.CommentBody__c = '-- [Created By Amadeus ' + intCommObj.createddate +'] \n     ' + intCommObj.CommentBody__c ;
                //}
            }
            srcTargetFieldMap = INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId(intCommObj.INTGR_Case__r.INTGR_Account__c, 'INTGR_Case_Comment__c');
        }
        
        // POPULATE REQUEST BODY BASED ON OBJECT API NAME
        system.debug(' **** srcTargetFieldMap = ' + srcTargetFieldMap);
        
        for (String fieldVal: srcTargetFieldMap.keyset()) 
        {
            system.debug(' **** fieldVal = ' + fieldVal);
            if (daoObj.isValidField(fieldVal, objType)) 
            {
                if (objType.equalsIgnoreCase('INTGR_Case__c'))
                {
                    if (srcTargetFieldMap.get(fieldVal) == 'incident_state') 
                    {
                        if (operationName.containsIgnoreCase('insert'))
                        {
                            insertObj.incident_state = intCaseObj.get(fieldVal).toString();
                        }
                        
                        if (operationName.containsIgnoreCase('update')) 
                        {
                            updateObj.incident_state = intCaseObj.get(fieldVal).toString();
                        }
                    }
                    if (srcTargetFieldMap.get(fieldVal) == 'short_description') 
                    {
                        if (operationName.containsIgnoreCase('insert')) 
                        {
                            insertObj.short_description = intCaseObj.get(fieldVal).toString();
                        }
                        if (operationName.containsIgnoreCase('update')) 
                        {
                            updateObj.short_description = intCaseObj.get(fieldVal).toString();
                        }
                    }
                    if (srcTargetFieldMap.get(fieldVal) == 'priority') 
                    {
                        //if (operationName.containsIgnoreCase('insert')) insertObj.priority = (Integer) intCaseObj.get(fieldVal);
                        //if (operationName.containsIgnoreCase('update')) updateObj.priority = (Integer) intCaseObj.get(fieldVal);
                        if (operationName.containsIgnoreCase('insert')) 
                        {
                            insertObj.priority = intCaseObj.get(fieldVal).toString();
                        }
                        if (operationName.containsIgnoreCase('update')) 
                        {
                            updateObj.priority = intCaseObj.get(fieldVal).toString();
                        }
                    }
                    if (srcTargetFieldMap.get(fieldVal) == 'description') 
                    {
                        if (operationName.containsIgnoreCase('insert')) 
                        {
                            insertObj.description = intCaseObj.get(fieldVal).toString();
                        }
                        if (operationName.containsIgnoreCase('update')) 
                        {
                            updateObj.description = intCaseObj.get(fieldVal).toString();
                        }
                    }
                    if (srcTargetFieldMap.get(fieldVal) == 'caller_id') 
                    {
                        if (operationName.containsIgnoreCase('insert')) 
                        {
                            insertObj.caller_id = intCaseObj.get(fieldVal).toString();
                        }
                        if (operationName.containsIgnoreCase('update')) 
                        {
                            updateObj.caller_id = intCaseObj.get(fieldVal).toString();
                        }
                    }
                    if (srcTargetFieldMap.get(fieldVal) == 'sys_id') 
                    {
                        if (operationName.containsIgnoreCase('update') && null != intCaseObj.get(fieldVal)) 
                        {
                            updateObj.sys_id = intCaseObj.get(fieldVal).toString();
                        }
                    }
                }
                else
                {
                    // For Integration case comments
                    if (srcTargetFieldMap.get(fieldVal) == 'work_notes') 
                    {
                        updateObj.work_notes = intCommObj.get(fieldVal).toString();
                    }
                    if (srcTargetFieldMap.get(fieldVal) == 'sys_id') 
                    {
                        updateObj.sys_id = sysId;
                    }
                }
            }
        }
        
        // INITIALIZING SOAP HEADERS
        soap.inputHttpHeaders_x = new Map < String, String > ();
        soap.inputHttpHeaders_x.put('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(intUNamePWD)));
        
        system.debug(' **** obj = ' + insertObj);
        system.debug(' **** updateObj = ' + updateObj);
        
        try 
        {
            if (operationName.containsIgnoreCase('insert') && !objType.equalsIgnoreCase('INTGR_Case_Comment__c')) 
            {
                INTGR_SOAP_SN_Incident.insertResponse_element insertResponse = new INTGR_SOAP_IntegrationHandler().createInsertCallOut(insertObj, soap, logObj, intCaseObj, endPoint);
                system.debug(' **** insertResponse = ' + insertResponse);
                new INTGR_SOAP_IntegrationHandler().parseSOAPResponse(insertResponse.sys_id, insertResponse.number_x, intCaseObj);
            }
            else 
            {
                if(objType.equalsIgnoreCase('INTGR_Case_Comment__c'))
                {
                    system.debug(' **** objType = ' + objType);
                    response = new INTGR_SOAP_IntegrationHandler().createUpdateCallOut(updateObj, soap, logObj, intCaseObj, intCommObj, 'INTGR_Case_Comment__c', endPoint);
                    system.debug(' **** response 1 = '+ response);
                }
            }
            if (operationName.containsIgnoreCase('update') && objType.equalsIgnoreCase('INTGR_Case__c')) 
            {
                response = new INTGR_SOAP_IntegrationHandler().createUpdateCallOut(updateObj, soap, logObj, intCaseObj, intCommObj, 'INTGR_Case__c', endPoint);
                system.debug(' **** Update response = ' + response);
            }
         	if (operationName.containsIgnoreCase('update') && objType.equalsIgnoreCase('INTGR_Case__c'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, 'Record Updated', 'Success', 'Update', 'INTGR_Case__c', endPoint, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, updateObj.toString());
            }
            if (operationName.containsIgnoreCase('insert') && objType.equalsIgnoreCase('INTGR_Case__c'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, 'Record Created', 'Success', 'Insert', 'INTGR_Case__c', endPoint, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, updateObj.toString());
            }
            if (operationName.containsIgnoreCase('insert') && objType.equalsIgnoreCase('INTGR_Case_Comment__c'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCommObj.INTGR_Case__r.Case__c, intCommObj.INTGR_Case__r.Id, intCommObj.id, 'Record Created', 'Success', 'Insert', 'INTGR_Case_Comment__c', endPoint, intCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, updateObj.toString());
            }
            
        }
        catch (Exception e)
        {
            system.debug(' **** Error Message: ' + e.getMessage ());
            if (operationName.containsIgnoreCase('update') && objType.equalsIgnoreCase('INTGR_Case__c'))
            {
                logObj  = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, e.getMessage(), 'Failed', 'Update', 'INTGR_Case__c', endPoint, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, updateObj.toString());
            }
            if (operationName.containsIgnoreCase('insert') && objType.equalsIgnoreCase('INTGR_Case__c'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, e.getMessage(), 'Failed', 'Insert', 'INTGR_Case__c', endPoint, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, updateObj.toString());
            }
            if (operationName.containsIgnoreCase('insert') && objType.equalsIgnoreCase('INTGR_Case_Comment__c'))
            {
                logObj = INTGR_IntegrationHelper.createNIIntegraionLog(intCommObj.INTGR_Case__r.Case__c, intCommObj.INTGR_Case__r.Id, intCommObj.id, e.getMessage(), 'Failed', 'Insert', 'INTGR_Case_Comment__c', endPoint, intCommObj.INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, updateObj.toString());
            }
            
        }
        
        loglist.add(logObj);
        
        try 
        {
            system.debug(' **** loglist.size() = ' +  loglist.size());
            if (loglist.size() > 0)
            {
                system.debug(' **** loglist' + loglist);
                insert loglist;
            }
        }
        catch (Exception e)
        {
            system.debug(' **** Error occured: ' + e.getMessage());
        }
        finally 
        {
            system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout');
            system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout');
            system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout');
            system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout');
            system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout'); 
        }
        
        system.debug(' *** EXITING INTGR_SOAP_IntegrationHandler.incident_CreateSOAPCallout() - QUERIES ISSUED = ' + Limits.getQueries());

    }    
    
    @future(callout=true)
    public static void attachment_CreateSOAPCallout(String fileId) 
    {
		
        // Author: Princy Jain
        // Date: 05/02/2018   
        // Description: Method to create attachment callout
    	
        system.debug(' *** ENTERING INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout() - QUERIES ISSUED = ' + Limits.getQueries());
        
        ContentVersion fileObj = new ContentVersion();
        INTGR_Case__c intCaseObj = new INTGR_Case__c();
        String fileName = '';
        Blob fileData = null;
        String uNamePwd = '';
        Id caseId = null;
        String endPointURL = '';
        String source = '';
        INTGR_SOAP_SN_Attachment.insert_element insertObj = new INTGR_SOAP_SN_Attachment.insert_element();
        INTGR_SOAP_SN_Attachment.ServiceNowSoap soap = new INTGR_SOAP_SN_Attachment.ServiceNowSoap();
        soap.inputHttpHeaders_x = new Map<String, String>();
        
        fileObj = [SELECT Id, CaseId__c, Title, VersionData, FileExtension FROM ContentVersion where Id = : fileId OR ContentDocumentId = : fileId][0];
        system.debug(' **** file Object = ' + fileObj);
        
        if (null != fileObj) 
        {
            caseId = fileObj.CaseId__c;
            fileName = fileObj.Title.replaceAll('\\s+', '') + '.' + fileObj.FileExtension;
            fileData = fileObj.VersionData;
            fileId = fileObj.Id;
            intCaseObj = INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList(caseId);
            
            if (null != intCaseObj) 
            {
                uNamePwd = intCaseObj.INTGR_Account__r.External_System_Username__c + ':' + intCaseObj.INTGR_Account__r.External_System_Password__c;
                endPointURL = intCaseObj.INTGR_Account__r.Attachment_Endpoint_SOAP__c;
                source = 'incident:' + intCaseObj.Customer_Ticket_System_Id__c;
            }
            //'https://dev48905.service-now.com/ecc_queue.do?SOAP';
        }
        
        system.debug(' **** intCaseObj Object = ' + intCaseObj);
        soap.inputHttpHeaders_x.put('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(uNamePwd)));
        
        //POPULATE REQUEST PARAMS 
        insertObj.topic = 'AttachmentCreator';
        insertObj.agent = 'AttachmentCreator';
        insertObj.payload = EncodingUtil.base64Encode(fileData);
        //Source = incident:dd90c5d70a0a0b39000aac5aee704ae8
        insertObj.source = source;
        insertObj.name = fileName;
        
        List<NI_Integration_Log__c> logList = new List<NI_Integration_Log__c>();
        INTGR_SOAP_SN_Attachment.insertResponse_element insertResponse = new INTGR_SOAP_SN_Attachment.insertResponse_element();
        NI_Integration_Log__c log = new NI_Integration_Log__c();
        
        try 
        {
            insertResponse = soap.insert_x(insertObj, endPointURL);
            if (insertResponse.sys_id == null) 
            {
                log = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, insertResponse.toString(), 'Failed', 'Insert', 'ContentVersion', endPointURL, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, '');
                log.Attachment_Id__c = fileId;
                log.Attachment_Name__c = fileName;
                logList.add(log);
            }
            else
            {
                log = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, insertResponse.toString(), 'Success', 'Insert', 'ContentVersion', endPointURL, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, '');
            }
        } 
        catch (Exception ex) 
        {
            system.debug(' **** Error Occured : ' + ex.getMessage());
            // NI_Integration_Log__c log = new NI_Integration_Log__c();
            log = INTGR_IntegrationHelper.createNIIntegraionLog(intCaseObj.Case__c, intCaseObj.Id, null, ex.getMessage(), 'Failed', 'Insert', 'ContentVersion', endPointURL, intCaseObj.INTGR_Account__r.External_Integration_System_Name__c, '');
            log.Attachment_Id__c = fileId;
            log.Attachment_Name__c = fileName;
        }
        
        logList.add(log);
        
        try 
        {
            if (logList.size() > 0) 
            {
                insert logList;
            }
        } 
        catch (Exception e) 
        {
            system.debug(' **** Error Occured: ' + e.getMessage());
        }
        finally 
        {
            system.debug(' *** QUERIES ISSUED = ' + Limits.getQueries() + ' Class: INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout');
            system.debug(' *** HEAP SIZE LIMIT = ' + Limits.getLimitHeapSize() + ' Class: INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout');
            system.debug(' *** HEAP SIZE USED = ' + Limits.getHeapSize() + ' Class: INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout');
            system.debug(' *** CPU TIME LIMIT = ' + Limits.getLimitCpuTime() + ' Class: INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout');
            system.debug(' *** CPU TIME USED = ' + Limits.getCpuTime() + ' Class: INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout');
        }
        
        system.debug(' *** EXITING INTGR_SOAP_IntegrationHandler.attachment_CreateSOAPCallout() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}