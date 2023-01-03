/************************************************************************************************
                 !!! INTEGRATION CLASS - DO NOT ALTER !!!
*************************************************************************************************
Name            : INTGR_WinSN_CaseComment_Handler Class
Integration     : Win@pproach / Service Now
Author          : Sean Harris
Created Date    : 02/08/2019
Last Mod Date   : 02/08/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
public class INTGR_WinSN_CaseComment_Handler 
{

    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}

    
    public INTGR_WinSN_CaseComment_Handler()
    {
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults(); 
    }
    
    public void OnAfterInsert(List<CaseComment> newTrigger)
    { 
        
        system.debug(' *** ENTERING INTGR_WinSN_CaseComment_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassCaseComment_ON__c) 
        {
            
            List<CaseComment> lstValidCaseComments = new List<CaseComment>();
            lstValidCaseComments = lstValidCasesCommentsToProcess(newTrigger);

            if (lstValidCaseComments.Size() > 0)
            {

                if (!INTGR_IntegrationHelper.isICCFlow) 
                {
                    populateIntegrationCaseComment(newTrigger);
                }	
                
                // Verify for the Win@proach integration username 
                WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');

                if (winSettings.Integration_Username__c != null && winSettings.Integration_Username__c != UserInfo.getUserName() && NI_WinaproachService.taskFlag == false)
                { 
                    // Calling External Win@proach web service  
                    NI_WinaproachService.createActionLogOrAttachment(newTrigger, new Set<String>(NI_WinaproachService.caseFieldsForComments)); 
                }
                
                // VERIFY FOR THE SERVICENOW IF ELIGIBLE SEND UPDATE TO SERVICENOW
                ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');

                // Null check on custom setting as part of sprint S-00112 
                if (SNSettings != null)
                {
                    if ((NI_ServicenowIntegration.caseCommentFlag || (!NI_WinaproachService.caseCommentFlag)) && 
                        SNSettings.Integration_UserId__c != null && UserInfo.getUserId() != SNSettings.Integration_UserId__c) 
                    {
                        NI_ServicenowIntegration.updateIncidents(newTrigger, new Set<String>(NI_WinaproachService.caseFieldsForComments));
                    }
                }        
            }
        }
        
        system.debug(' *** EXITING INTGR_WinSN_CaseComment_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void OnAfterUpdate(List<CaseComment> newTrigger, Map<Id, CaseComment> oldMapTrigger)
    {
		
        system.debug(' *** ENTERING INTGR_WinSN_CaseComment_Handler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (!bpSwitch.BypassCaseComment_ON__c) 
        { 
            
            List<CaseComment> lstValidCaseComments = new List<CaseComment>();
            lstValidCaseComments = lstValidCasesCommentsToProcess(newTrigger);

            if (lstValidCaseComments.Size() > 0)
            {
                
                // Update Integreation Case Comment after Case Comment Update.
                if (!INTGR_IntegrationHelper.isICCFlow) 
                {
                    updateIntegrationCaseComments(newTrigger, oldMapTrigger); 
                } 
                
            }
        }
        
        system.debug(' *** EXITING INTGR_WinSN_CaseComment_Handler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
                
    }
    

    // =========================================================================
    //    FUNCTIONS ============================================================
    // =========================================================================    
    private List<CaseComment> lstValidCasesCommentsToProcess(List<CaseComment> newTrigger)
    {
		
        system.debug(' *** ENTERING INTGR_WinSN_CaseComment_Handler.lstValidCasesCommentsToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LIST OF VALID CASES TO BE RETURNED 
        List<CaseComment> retLst = new List<CaseComment>();
        
        // GET ALL VALID CASE RECORD TYPE NAMES FROM CUSTOM SETTING
        Winaproach_Incident_Case_Record_Type__c wcsRecordTypes = Winaproach_Incident_Case_Record_Type__c.getValues('Default'); 
        
        // NICC-027116 4/23/2018- ADDED BY RIA TO CONSIDER 'CRS WORK ORDER' CASE RECORD TYPES
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

        system.debug(' **** Integration Case Comment');
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
        for (CaseComment csc : newTrigger)
        {        
        	setParentCaseIds.add(csc.ParentId);
        }
        
        Map<Id, Id> mapCaseId2RecTypeId = new Map<Id, Id>();
        for (Case cs : [SELECT Id, RecordTypeId FROM Case WHERE Id IN : setParentCaseIds])
        {
            mapCaseId2RecTypeId.put(cs.Id, cs.RecordTypeId);
        }
        
        for (CaseComment cc : newTrigger)
        {
            // IF PARENT CASE IS OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE 
            if (setRecordTypeIds.contains(mapCaseId2RecTypeId.get(cc.ParentId)))
            {
                retLst.Add(cc);
            }
        }
        
        system.debug(' **** retLst = ' + retLst);
        
        system.debug(' *** EXITING INTGR_WinSN_CaseComment_Handler.lstValidCasesCommentsToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return retLst;
        
    } 

    public void populateIntegrationCaseComment(List<CaseComment> newTrigger)
    { 
        
        // Author: Princy Jain
        // Date: 04/18/2018   
        // Param: List of Case Comments Records
        // Description: Method responsible for replicating Case Comments to Integration case Comments.        
        
        system.debug(' *** ENTERING INTGR_WinSN_CaseComment_Handler.populateIntegrationCaseComment() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<INTGR_Case_Comment__c> caseCommToInsert = new List<INTGR_Case_Comment__c>();
        Map<Id, List<String>> caseIdVsCommentBodyMap = new Map<Id, List<String>>();
        String caseId = '';
        
        for (CaseComment caseComObj : newTrigger)
        {
            if (!caseIdVsCommentBodyMap.containsKey(caseComObj.ParentId))
            {
                caseIdVsCommentBodyMap.put(caseComObj.ParentId, new List<String>());
            } 
            caseIdVsCommentBodyMap.get(caseComObj.ParentId).add(caseComObj.CommentBody);
        }
        
system.debug(' **** caseIdVsCommentBodyMap.keySet() = ' + caseIdVsCommentBodyMap.keySet());
        
        Set<String> caseCommBodySet = new Set<String>();

        for (INTGR_Case_Comment__c caseComm : [SELECT Id, INTGR_Case__r.Case__c,INTGR_Case__r.Status__c, INTGR_Case__c, Customer_Ticket_System_Id__c, CommentBody__c 
                                               FROM INTGR_Case_Comment__c 
                                               WHERE INTGR_Case__r.Case__c IN : caseIdVsCommentBodyMap.keySet()])
        {
            caseId = caseComm.INTGR_Case__r.Case__c;
            caseCommBodySet.add(caseComm.INTGR_Case__c + '~' + caseComm.CommentBody__c);
        }
        
        for (INTGR_Case__c caseObj : [SELECT Id, Case__c, Case__r.Update_External_System__c, Customer_Ticket_System_Id__c 
                                      FROM INTGR_Case__c 
                                      WHERE Case__c IN : caseIdVsCommentBodyMap.keySet()])
        {

            // TO CHECK IF Case__r.Update_External_System__c IS CHECKED ONLY THEN ALLOW INTEGRATION CASE COMMENT CREATE
			if (caseObj.Case__r.Update_External_System__c)
			{
                for (String commBody : caseIdVsCommentBodyMap.get(caseObj.Case__c))
                {
                    caseId = caseObj.Case__c;
                    if (caseCommBodySet == null || (caseCommBodySet != null && !caseCommBodySet.contains(caseObj.id + '~' + commBody)))
                    {
                        caseCommToInsert.add (new INTGR_Case_Comment__c (INTGR_Case__c = caseObj.id, CommentBody__c = commBody, CreateDate__c = system.now()));
                    }
                }
			}
        }
        
        system.debug(' **** caseCommToInsert.size() = ' + caseCommToInsert.size());
        
        if (caseCommToInsert.size() > 0)
        {
            Database.SaveResult[] srList = Database.insert(caseCommToInsert, false);
        }
        
        system.debug(' *** EXITING INTGR_WinSN_CaseComment_Handler.populateIntegrationCaseComment() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void updateIntegrationCaseComments(List<CaseComment> newTrigger, Map<Id, CaseComment> oldMapTrigger)
    { 
        
        // Author: Princy Jain
        // Date: 04/18/2018   
        // Param: List of Case Comments Revords
        // Description: Method responsible for replicating Case Comments to Integration case Comments. 
        
        system.debug(' *** ENTERING INTGR_WinSN_CaseComment_Handler.updateIntegrationCaseComments() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<INTGR_Case_Comment__c> caseCommToUpdate = new List<INTGR_Case_Comment__c>();
        Map<Id, String> caseCommBodyMap = new Map<Id, String>();
        String val = '';
        
        for (CaseComment caseComm : newTrigger)
        {
            if (!caseComm.CommentBody.equalsIgnoreCase(oldMapTrigger.get(caseComm.id).CommentBody))
            {
                caseCommBodyMap.put(caseComm.ParentId, caseComm.ParentId + '~' + caseComm.CommentBody);
            }
        }

        for (INTGR_Case_Comment__c intComm : [SELECT Id, INTGR_Case__r.Case__c, INTGR_Case__r.Case__r.Update_External_System__c, CommentBody__c 
                                              FROM INTGR_Case_Comment__c 
                                              WHERE INTGR_Case__r.Case__c IN : caseCommBodyMap.keySet()])
        {
            // TO CHECK IF Update_External_System__c IS CHECKED FOR INT CASE COMMENT CREATE
            if (intComm.INTGR_Case__r.Case__r.Update_External_System__c)
            {
                val = intComm.INTGR_Case__r.Case__c + '' + intComm.CommentBody__c;
                if (!caseCommBodyMap.get(intComm.INTGR_Case__r.Case__c).equalsIgnoreCase(val))
                {
                    intComm.CommentBody__c = caseCommBodyMap.get(intComm.INTGR_Case__r.Case__c).split('~')[1];
                }
                caseCommToUpdate.add(intComm);
            }
        }
        
        try 
        {
            if (caseCommToUpdate.size() > 0)
            {
                update caseCommToUpdate;
            }
        }
        catch (exception e)
        {
            system.debug ('Error Occured: ' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_WinSN_CaseComment_Handler.updateIntegrationCaseComments() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

}