/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : INTGR_WinSN_Task_Handler Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 02/03/2016
Last Mod Date   : 05/11/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : UPDATED PER NICC-027588 Changed to used getRecordTypeInfosByName instead of query
                : 
*************************************************************************************************/
public class INTGR_WinSN_Task_Handler 
{
    
    
    public INTGR_WinSN_Task_Handler()
    {
        
    }
    
    public void OnAfterInsert(List<Task> newTrigger)
    {    
        
        system.debug(' *** ENTERING INTGR_WinSN_Task_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }        
        
        List<Task> lstValidTasks = new List<Task>();
        lstValidTasks = lstValidTasksToProcess(newTrigger);
        if (lstValidTasks.Size() > 0)
        {
            processAfterInsert(lstValidTasks);
        }	
        
        system.debug(' *** EXITING INTGR_WinSN_Task_Handler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }


    // =========================================================================
    //    FUNCTIONS ============================================================
    // =========================================================================    
    
    private Boolean bypassTrigger(List<Task> newTrigger)
    {
        boolean bRetVal = false;
        for (Task tsk : newTrigger) 
        {
            if (tsk.Description != null && tsk.Description.contains(Label.AH_EmailServicesAddress)) 
            {
                bRetVal = true;
            }
        }
        return bRetVal;
    }     
        
    private List<Task> lstValidTasksToProcess (List<Task> newTrigger)
    {
        
        system.debug(' *** ENTERING INTGR_WinSN_Task_Handler.lstValidTasksToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // LIST OF VALID TASK TO BE RETURNED 
        List<Task> retLst = new List<Task>();
        
        // GET ALL VALID TASK RECORD TYPE NAMES FROM CUSTOM SETTING
        WinaproachIncidentSettings__c wcsRecordTypes = WinaproachIncidentSettings__c.getValues('Default'); 
        
        // IF NO RECORD TYPE NAMES FROM CUSTOM SETTING FOUND RETURN 0 SIZED TASK LIST
        if (wcsRecordTypes == null) {return retLst;}
        
        // PARSE RECORD TYPE NAMES FROM CUSTOM SETTING INTO LIST
        List<String> lstRecordtypes = String.valueOf(wcsRecordTypes.Task_Record_Type__c).split(',');
        
        // SET TO HOLD TASK RECORD TYPE IDS 
        Set<Id> setRecordTypeIds = new Set<Id>();

        // UPDATED BY SHASHIKANT FOR OPTIMIZATION on 04/26/2018
        // LOOP THROUGH TASK RECORD TYPES TO ASSIGN IDS TO SET 
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Task.getRecordTypeInfosByName();

        for (String recType : lstRecordtypes)
        {
            if (recordTypesMap.containsKey(recType)) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                setRecordTypeIds.Add(rr.getRecordTypeId());
            }
        }
        
        for (Task t : newTrigger)
        {
            // IF TASK IS OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE 
            if (setRecordTypeIds.contains(t.RecordTypeId))
            {
                retLst.Add(t);
            }
        }
        
        system.debug(' **** RETURNING: ' + retLst);
        system.debug(' *** EXITING INTGR_WinSN_Task_Handler.lstValidTasksToProcess() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return retLst;
        
    }  

    private void processAfterInsert(List<Task> newTrigger)
    {
		
        system.debug(' *** ENTERING INTGR_WinSN_Task_Handler.processAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
        List<Task> lstTasks = new List<Task>();
        List<Id> lstCaseIds = new List<Id>();
        Map<Id, Task> mapCaseIdsSN = new Map<Id, Task>();
        List<Case> lstCase = new List<Case>();
        String strCaseId ='';
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        String taskRecordTypeName = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByName().get(String.valueOf(winSettings.Task_Record_Type__c)).getName();
        ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
        
        for (Task tsk : newTrigger)
        {
            // Verify for the Win@proach integration username 
            
            if (winSettings.Integration_Username__c != null && 
                winSettings.Integration_Username__c != UserInfo.getUserName() && 
                winSettings.Task_Record_Type__c != null && 
                taskRecordTypeName != null && 
                tsk.TaskSubtype != 'Email')
            { 
                lstTasks.add(tsk);
                strCaseId = String.valueOf(tsk.WhatId);
                if (strCaseId.startsWith('500'))
                {
                    lstCaseIds.add(strCaseId);
                }
            }

            strCaseId = String.valueOf(tsk.WhatId);
            
            if (strCaseId.startsWith('500') && 
                tsk.TaskSubtype == 'Email' &&
                SNSettings.Integration_UserId__c != null && 
                UserInfo.getUserId() != SNSettings.Integration_UserId__c)
            {
                mapCaseIdsSN.put(tsk.WhatId,tsk);
            }
        }
        
        if (lstTasks.size() > 0)
        {
            // Calling External Win@proach web service  
            NI_WinaproachService.createActionLogOrAttachment(lstTasks, new Set<String>()); 
        }
        
        if (lstCaseIds.size() > 0)
        {
            for (Case cs : [SELECT Id, Status FROM Case WHERE Id IN : lstCaseIds])
            {
                if (cs.status == 'Open') 
                {
                    cs.Status = 'Acknowledged';
                    lstCase.add(cs);
                } 
            }
            if (lstCase.size() > 0) 
            {
                NI_WinaproachService.taskFlag = true;
                update lstCase;
            }
        }
        
        List<CaseComment> lstCaseComments = new List<CaseComment>();
        
        if (mapCaseIdsSN.keySet().size() > 0)
        {
            for (Case cs : [SELECT Id, Status, CreatedById, Customer_Ticket_Number__c, RecordType.Name 
                            FROM Case 
                            WHERE Id IN : mapCaseIdsSN.keySet()])
            {
                //APPLYING TO FILTER OUT TARGETED RECORDS                 
                if (cs.CreatedById == SNSettings.Integration_UserId__c && 
                    cs.Customer_Ticket_Number__c != null && 
                    cs.RecordType.Name == SNSettings.ServiceNow_Incident_Case_Record_Type__c)
                {
                    CaseComment com = new CaseComment();
                    com.ParentId = cs.Id;
                    com.IsPublished = true;							
                    com.CommentBody = mapCaseIdsSN.get(cs.Id).Description;
                    lstCaseComments.add(com);	
                }
            }
            
            if (!NI_WinaproachService.caseCommentFlag)
            {
                if (lstCaseComments.size() > 0)
                {
                    NI_ServicenowIntegration.caseCommentFlag = true;
                    NI_WinaproachService.caseFieldsForComments = new List<String>();
                    insert lstCaseComments;
                }
            }
        }
        
        system.debug(' *** EXITING INTGR_WinSN_Task_Handler.processAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
		
    }
    
}