/************************************************************************************************
Name            : NI_Change_Control_TriggerHandler Class
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   : 11/5/2019
Last Mod By     : Ria Chawla
NICC Reference  : 
Description     : Class that handles all trigger code for the NI_Change_Control__c Object
                : Updated 11/5/2019 Per NICC-038406
                : Updated Record Type references to include 'Internal - IT'
: 
*************************************************************************************************/
public class NI_Change_Control_TriggerHandler 
{
    
    private boolean m_isExecuting = false;
    
    
    public NI_Change_Control_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }
    
    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }
    
    public void OnBeforeInsert(List<NI_Change_Control__c> newTrigger)
    {
        Validate_Production_Start_End_Date(newTrigger);
    }
    
    public void OnBeforeUpdate(List<NI_Change_Control__c> newTrigger, Map<Id, NI_Change_Control__c> oldMap)
    {
        Validate_Production_Start_End_Date(newTrigger);
        for (NI_Change_Control__c niChangeControl : newTrigger)
        {
            NI_Change_Control__c old_niChangeControl = oldMap.get(niChangeControl.Id);
            String recordTypeName=Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosById().get(niChangeControl.RecordTypeId).getName();
            
            if (recordTypeName.equals('Hosted RFC') || recordTypeName.equals('HRM RFC'))
            {
                if (niChangeControl.Change_Status__c != null && 
                    niChangeControl.Change_Status__c != old_niChangeControl.Change_Status__c &&
                    (niChangeControl.Change_Status__c == 'CRB Approved' || niChangeControl.Change_Status__c == 'Approved - Standard Change'))
                {
                    updateEvents(newTrigger, oldMap);
                }
                else 
                {
                    if(((old_niChangeControl.Date_Scheduled__c != niChangeControl.Date_Scheduled__c) ||
                        (old_niChangeControl.Assigned_Production_End_Date__c != niChangeControl.Assigned_Production_End_Date__c) ||
                        (old_niChangeControl.Request_Summary__c != niChangeControl.Request_Summary__c)) && 
                        (niChangeControl.Change_Status__c == 'CRB Approved' || niChangeControl.Change_Status__c == 'Approved - Standard Change'))
                    {
                        updateEvents(newTrigger, oldMap);
                    }
                }
            } 
        }
    }
    
    public void OnAfterInsert(List<NI_Change_Control__c> newTrigger)
    {
    }

    public void OnAfterUpdate(List<NI_Change_Control__c> newTrigger, Map<Id,NI_Change_Control__c> oldMapTrigger)
    {           
        for (NI_Change_Control__c n: newTrigger)
        {
            NI_Change_Control__c oldRFC = oldMapTrigger.get(n.Id);
            
            if ((n.Re_submit_for_Approval__c == true) && (n.Re_submit_for_Approval__c != oldRFC.Re_submit_for_Approval__c))       
            {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('4 days past Assigned Production Date. Re-submitting for approval.');
                req1.setObjectId(n.Id);
                //req1.setSubmitterId(n.Developer_Compiler__c); //SUBMIT ON BEHALF OF THE COMPILER
                //req1.setProcessDefinitionNameOrId('Hosted_RFC_Normal_Approval'); //SUBMIT THE RECORD TO A SPECIFIC PROCESS
                //req1.setSkipEntryCriteria(true); //SKIP THE ENTRY CRITERIA
                
                //SUBMIT FOR APPROVAL
                Approval.ProcessResult result = Approval.process(req1);
            }
        }    
    } 

    
//    public void OnBeforeDelete(List<NI_Change_Control__c> newTrigger)
//    {
//    }
    
//    public void OnAfterDelete(List<NI_Change_Control__c> newTrigger)
//    {
//    }
    
//    public void OnAfterUnDelete(List<NI_Change_Control__c> newTrigger)
//    {  
//    }    

    // ====================================================================================================
    // FUNCTIONS ==========================================================================================
    // ====================================================================================================
    
    // FUNCTION TO CHECK PRODUCTION DATE VALIDATION
    private void Validate_Production_Start_End_Date(List<NI_Change_Control__c> newTrigger)
    {
        for (NI_Change_Control__c niChangeControl: newTrigger)
        {
            String recordTypeName = Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosById().get(niChangeControl.RecordTypeId).getName();
            if (recordTypeName.equals('Hosted RFC')|| recordTypeName.equals('HRM RFC'))
            {
                // IF ASSIGNED PRODUCTION DATE IS NOT NULL
                if (niChangeControl.Date_Scheduled__c!=null && niChangeControl.Assigned_Production_End_Date__c!=null)
                {
                    if (niChangeControl.Assigned_Production_End_Date__c < niChangeControl.Date_Scheduled__c)
                    {
                        niChangeControl.addError('Assigned Production Date should be less than Assigned Production End Date');
                    }
                }                
                if (niChangeControl.Date_Scheduled__c != null && niChangeControl.Assigned_Production_End_Date__c == null)
                {
                    niChangeControl.Assigned_Production_End_Date__c = niChangeControl.Date_Scheduled__c;
                }
                if (niChangeControl.Date_Scheduled__c == null && niChangeControl.Assigned_Production_End_Date__c != null)
                {
                    niChangeControl.Date_Scheduled__c = niChangeControl.Assigned_Production_End_Date__c;
                }
            }
        }  
    }
        
    private void updateEvents(List<NI_Change_Control__c> newTrigger, Map<Id, NI_Change_Control__c> oldMap)
    { 
        List<Id> list_ni_ChangeControlIDs = new List<Id>();
        Map<String, Id> mapUserName = new Map<String, Id>();
        List<Event> lstEventToInsert = new List<Event>();
        List<Event> lstEventToDelete = new List<Event>();
        
        for (NI_Change_Control__c niChangeControl : newTrigger)
        {
            // CHECKING ASSIGNED PRODUCTION DATE VALIDATION
            if (niChangeControl.Assigned_Production_End_Date__c < niChangeControl.Date_Scheduled__c)
            { 
                niChangeControl.Assigned_Production_End_Date__c.addError('Assigned Production Date should be less than Assigned Production End Date');
                break;
            }
            list_ni_ChangeControlIDs.add(niChangeControl.id);
            
        }
        
        if (list_ni_ChangeControlIDs.size() > 0)
        {
            
            // LIST OF USERS WITH NAME 'Hosted RFC' OR 'HRM RFC'  
            List<User> lstUser = new List<User>([SELECT Id, Name FROM User WHERE Name LIKE 'Hosted RFC' OR Name LIKE 'HRM RFC']);
            
            for (User usr : lstUser)
            {
                mapUserName.put(usr.Name, usr.id);
            }  
            
            List<Event> event = [SELECT StartDateTime, EndDateTime, Subject FROM Event WHERE whatId IN : list_ni_ChangeControlIDs];

            for (NI_Change_Control__c niChangeControl: newTrigger)
            {  
                String recordTypeName = Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosById().get(niChangeControl.RecordTypeId).getName();  
                if (mapUserName.keySet().contains(recordTypeName))
                {
                    if (event.size() > 0)
                    {
                        for (Event ev: event)
                        {
                            lstEventToDelete.add(ev);
                        }
                    }      
                }
            }
            
            if (lstEventToDelete != null)
            {
                delete lstEventToDelete;
            }
            
            for (NI_Change_Control__c niChangeControl: newTrigger)
            {
                
                String recordTypeName = Schema.SObjectType.NI_Change_Control__c.getRecordTypeInfosById().get(niChangeControl.RecordTypeId).getName();
                
                if (mapUserName.keySet().contains(recordTypeName))
                {
                    if (niChangeControl.Date_Scheduled__c != null || niChangeControl.Assigned_Production_End_Date__c != null)
                    {
                        Event ev = new Event();       
                        // IF Assigned_Production_End_Date__c NULL AND Date_Scheduled__c NOT NULL. SETTING Assigned_Production_End_Date__c -> Date_Scheduled__c
                        if (niChangeControl.Date_Scheduled__c != null && niChangeControl.Assigned_Production_End_Date__c == null)
                        {
                            ev.StartDateTime = niChangeControl.Date_Scheduled__c;
                            ev.EndDateTime = niChangeControl.Date_Scheduled__c;
                            niChangeControl.Assigned_Production_End_Date__c = niChangeControl.Date_Scheduled__c;
                            ev.Subject = niChangeControl.Request_Summary__c;
                            ev.OwnerId = mapUserName.get(recordTypeName);
                            ev.WhatId = niChangeControl.id;

                            //ADDING EVENT WITH REQUIRED VALUES
                            lstEventToInsert.add(ev);
                        }
                        else //IF Date_Scheduled__c NULL and Assigned_Production_End_Date__c NOTNULL Setting Date_Scheduled__c -> Assigned_Production_End_Date__c
                        {
                            if (niChangeControl.Assigned_Production_End_Date__c != null && niChangeControl.Date_Scheduled__c == null)
                            {
                                ev.StartDateTime = niChangeControl.Assigned_Production_End_Date__c;
                                ev.EndDateTime = niChangeControl.Assigned_Production_End_Date__c;
                                niChangeControl.Date_Scheduled__c = niChangeControl.Assigned_Production_End_Date__c;
                                ev.Subject = niChangeControl.Request_Summary__c;
                                ev.OwnerId = mapUserName.get(recordTypeName);
                                ev.WhatId = niChangeControl.id;
                                //ADDING EVENT WITH REQUIRED VALUES
                                lstEventToInsert.add(ev);
                            }
                            else 	// IF BOTH DATES ARE GIVEN/NOTNULL
                            {
                                if (niChangeControl.Date_Scheduled__c != null && niChangeControl.Assigned_Production_End_Date__c != null)
                                {
                                    DateTime endDateTime = DateTime.now();
                                    endDateTime = niChangeControl.Assigned_Production_End_Date__c;
                                    DateTime strDateTime = DateTime.now();
                                    strDateTime = niChangeControl.Date_Scheduled__c;
                                    Date strDt = Date.valueOf(String.valueof(strDateTime));
                                    Date endDt = Date.valueOf(String.valueof(endDateTime));
                                    
                                    //CALCULATE NUMBER OF DAYS BETWEEN START DATE AND END DATE
                                    Integer numOfDays = strDt.daysBetween(endDt);
                                    Integer stDay = strDt.day();
                                    Integer stMonth = strDt.month();
                                    Integer stYear = strDt.year();
                                    Integer endDay = endDt.day();
                                    Integer endMonth = endDt.month();
                                    Integer endYear = endDt.year();
                                    
                                    //IF LESS THAN 14 CREATE SINGLE EVENT WITH GIVEN START AND END DATES
                                    if (numOfDays < 14)
                                    {
                                        for (integer j = 0; j <= numOfDays ; j++)
                                        {
                                            Event e = new Event();
                                            if (j == 0)
                                            {
                                                e.StartDateTime = niChangeControl.Date_Scheduled__c;
                                            }
                                            else
                                            {
                                                if (j == numOfDays && (! (j == 0)))
                                                {
                                                    //e.StartDateTime = DateTime.parse(endMonth+'/'+endDay+'/'+endYear+' 12:00 AM');
                                                    DateTime myDate = DateTime.newInstance(endYear, endMonth, endDay, 00, 00, 00);
                                                    e.StartDateTime = myDate;
                                                }
                                                else
                                                {
                                                    e.StartDateTime = strDateTime.addDays(j);
                                                }
                                            }
                                            
                                            //e.StartDateTime = strDate1.addDays(j);
                                            if (j == 0 && numOfDays != 0)
                                            {
                                                //e.EndDateTime = DateTime.parse(stMonth+'/'+stDay+'/'+stYear+' 11:59 PM');
                                                DateTime myDate = DateTime.newInstance(stYear, stMonth, stDay, 23, 59, 00);
                                                e.EndDateTime = myDate;
                                            }
                                            else 
                                            {
                                                if (j == 0 && numOfDays == 0)
                                                {
                                                    e.EndDateTime = niChangeControl.Assigned_Production_End_Date__c;
                                                }
                                                else 
                                                {
                                                    if (j == numOfDays  && (! (j == 0)))
                                                    {
                                                        e.EndDateTime = niChangeControl.Assigned_Production_End_Date__c;
                                                    }
                                                    else
                                                    {
                                                        e.EndDateTime = strDateTime.addDays(j);
                                                    }
                                                }
                                            }
                                            
                                            //e.EndDateTime = strDate1.addDays(j);
                                            e.Subject = niChangeControl.Request_Summary__c;
                                            e.OwnerId = mapUserName.get(recordTypeName);
                                            e.WhatId = niChangeControl.id;
                                            
                                            if (!(j == 0 || j == numOfDays))
                                            {
                                                e.IsAllDayEvent = true;
                                            }
                                            
                                            lstEventToInsert.add(e);
                                            
                                        }
                                    }
                                    else	//IF MORE THAN 14 THEN CREATE DAILY EVENT(ONE EVENT FOR EACH DAY) BETWEEN GIVEN START AND END DATES
                                    {
                                        DateTime strDate = niChangeControl.Date_Scheduled__c;
                                        Datetime endDate = niChangeControl.Assigned_Production_End_Date__c;
                                        for (integer j = 0; j <= numOfDays ; j++)
                                        {
                                            Event e = new Event();
                                            if (j == 0)
                                            {
                                                e.StartDateTime = niChangeControl.Date_Scheduled__c;
                                            }
                                            else 
                                            {
                                                if (j == numOfDays)
                                                {
                                                    //e.StartDateTime = DateTime.parse(endMonth+'/'+endDay+'/'+endYear+' 12:00 AM');
                                                    DateTime myDate = DateTime.newInstance(endYear, endMonth, endDay, 00, 00, 00);
                                                    e.StartDateTime = myDate;
                                                }
                                                else
                                                {
                                                    e.StartDateTime = strDateTime.addDays(j);
                                                }
                                            }
                                            
                                            //e.StartDateTime = strDate1.addDays(j);
                                            if (j == 0)
                                            {
                                                //e.EndDateTime = DateTime.parse(stMonth+'/'+stDay+'/'+stYear+' 11:59 PM');
                                                DateTime myDate = DateTime.newInstance(stYear, stMonth, stDay, 23, 59, 00);
                                                e.EndDateTime = myDate;
                                            }
                                            else 
                                            {
                                                if (j == numOfDays)
                                                {
                                                    e.EndDateTime = niChangeControl.Assigned_Production_End_Date__c;
                                                }
                                                else
                                                {
                                                    e.EndDateTime = strDateTime.addDays(j);
                                                }
                                            }
                                            
                                            //e.EndDateTime = strDate1.addDays(j);
                                            e.Subject = niChangeControl.Request_Summary__c;
                                            e.OwnerId = mapUserName.get(recordTypeName);
                                            e.WhatId = niChangeControl.id;
                                            
                                            if (!(j == 0 || j == numOfDays))
                                            {
                                                e.IsAllDayEvent = true;
                                            }
                                            
                                            lstEventToInsert.add(e);
                                            
                                        }                                        
                                    }                                    
                                }
                            }                        
                        }                        
                    }                    
                }                
            }
            
            // INSERTING EVENT IN CALENDAR 
            if (lstEventToInsert.size() > 0)
            {
                insert lstEventToInsert; 
            }  
            
        }
        
    }

    public void addCustomerSignOffArtifact(List<NI_Change_Control__c> newTrigger)
    {
        
        // LIST OF TARGET RECORD TYPES
        List<RecordType> lstRTs = new List<RecordType>([
            SELECT Name, Id 
            FROM RecordType 
            WHERE sObjectType = 'NI_Change_Control__c' 
            AND Name IN ('Hosted RFC', 'HRM RFC', 'PMS RFC') //ADDED PMS RFC NICC-038406
            AND isActive = true
        ]);  
        
        // GENERATE LIST FROM TRIGGER OF ALL CANDIDATE NI_Change_Control__c RECORDS
        List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>([
            SELECT Id, RecordTypeId, Outage_Required__c, Data_Change__c 
            FROM NI_Change_Control__c 
            WHERE Id IN : newTrigger 
            AND RecordTypeId IN : lstRTs 
            AND Outage_Required__c = 'Yes' 
            AND Data_Change__c = 'Yes'
        ]);
        
        // GENERATE LIST FROM TRIGGER OF ALL CANDIDATE NICC_Artifact__c RECORDS
        List<NICC_Artifact__c> lstArts = new List<NICC_Artifact__c>([
            SELECT Id, Type__c, Description__c, Document_Link__c, NI_Change_Control__c 
            FROM NICC_Artifact__c 
            WHERE NI_Change_Control__c IN : lstNICC 
            AND Type__c = 'Customer Sign-off'
        ]);
        
        // SET THAT CONTAINS A LIST OF NI_Change_Control__c ID THAT HAVE Customer Sign-off ARTIFACTS
        Set<Id> setNICC = new Set<Id>();
        
        // LOOP THROUGH AND POPULATE SET WITH ALL NI_Change_Control__c ID THAT HAVE Customer Sign-off ARTIFACTS
        for (NICC_Artifact__c arts : lstArts)
        {
            setNICC.add(arts.NI_Change_Control__c);           
        }
        
        // GENERATE A LIST OF NI_Change_Control__c RECORDS THAT NEED A HAVE Customer Sign-off ARTIFACT
        List<NI_Change_Control__c> lstNeedSignOff = new List<NI_Change_Control__c>([
            SELECT Id, RecordTypeid, Outage_Required__c, Data_Change__c 
            FROM NI_Change_Control__c 
            WHERE Id IN : newTrigger 
            AND RecordTypeId IN : lstRTs 
            AND Outage_Required__c = 'Yes' 
            AND Data_Change__c = 'Yes' 
            AND Id NOT IN : setNICC 
        ]);        
        
        // GENERATE A LIST OF NI_Change_Control__c RECORDS THAT NEED A HAVE Customer Sign-off ARTIFACT
        List<NICC_Artifact__c> lstArtInserts = new List<NICC_Artifact__c>();
        
        // GENERATE A LIST THAT WILL CONTAIN ALL CUSTOMER SIGN-OFF ARTIFACTS TO BE INSERTED
        for (NI_Change_Control__c nicc : lstNeedSignOff)
        {
            NICC_Artifact__c a = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Customer Sign-off'); 
            lstArtInserts.add(a);             
        }
        
        // INSERT ALL SIGN-OFF ARTIFACTS
        List<Database.SaveResult> dsr = Database.insert(lstArtInserts);
        
    }    
    
    public void addArtifactTemplates(List<NI_Change_Control__c> newTrigger)
    {
        
        // LIST OF TARGET RECORD TYPES
        List<RecordType> lstRTs = new List<RecordType>([
            SELECT Name, Id 
            FROM RecordType 
            WHERE sObjectType = 'NI_Change_Control__c' 
            AND Name IN ('Hosted RFC', 'HRM RFC', 'Internal - IT') 
            AND isActive = true
        ]);    
        
        // NARROW BATCH TO NICC RECORDS WITH CASE IDS AND RECORDTYPES ONLY 
        List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>([
            SELECT Id, Cloned_w_Artifacts__c, RecordTypeId 
            FROM NI_Change_Control__c 
            WHERE Cloned_w_Artifacts__c = false
            AND RecordTypeId IN : lstRTs 
            AND Id IN : newTrigger
        ]);    
        
        // LIST FOR ALL CASE JUNCTION RECORD INSERTS 
        List<NICC_Artifact__c> lstArts = new List<NICC_Artifact__c>();
        
        // FOR COMPARISON, GET HRM RFC RECORDTYPE ID
        RecordType rtHRM = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'HRM RFC' AND isActive = true];
        
        // LOOP THROUGH ALL TARGET NICC AND ADDING ARTIFACT TEMPLATES TO INSERT LIST 
        for (NI_Change_Control__c nicc : lstNICC) 
        {          
            NICC_Artifact__c a1 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Communication Plan');         
            NICC_Artifact__c a2 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Deployment Plan');         
            NICC_Artifact__c a3 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Monitoring Plan');         
            NICC_Artifact__c a4 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Rollback Plan');         
            NICC_Artifact__c a5 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Test Plan');         
            
            lstArts.add(a1);
            lstArts.add(a2);
            lstArts.add(a3);
            lstArts.add(a4);
            lstArts.add(a5);
            
            if (nicc.RecordTypeId == rtHRM.Id)        
            {
                NICC_Artifact__c a6 = new NICC_Artifact__c(NI_Change_Control__c = nicc.Id, Type__c = 'Customer Sign-off');
                lstArts.add(a6);
            }
            
        }
        
        // BULK INSERT JUNCTION RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstArts);
        
    }
    
    public void AddCase_To_NICCRequestCaseJunction(List<NI_Change_Control__c> newTrigger)
    {
        
        // LIST OF TARGET RECORD TYPES
        List<RecordType> lstRTs = new List<RecordType>([
            SELECT Name, Id 
            FROM RecordType 
            WHERE sObjectType = 'NI_Change_Control__c' 
            AND Name IN ('Hosted RFC', 'HRM RFC', 'Internal - IT') 
            AND isActive = true
        ]);     
        
        // NARROW BATCH TO NICC RECORDS WITH CASE IDS AND RECORDTYPES ONLY 
        List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>([
            SELECT Id, Case_Id__c
            FROM NI_Change_Control__c 
            WHERE Case_Id__c != null 
            AND RecordTypeId IN : lstRTs 
            AND Id IN : newTrigger
        ]);
        
        // LIST FOR ALL CASE JUNCTION RECORD INSERTS 
        List<NICCRequestCaseJunction__c> lstCaseJuncs = new List<NICCRequestCaseJunction__c>();
        
        // LIST FOR ALL ACCOUNT JUNCTION RECORD INSERTS 
        List<NICCRequestAccountJunction__c> lstAcctJuncs = new List<NICCRequestAccountJunction__c>();
        
        // SET TO HOLD CASE IDS FOR RELATED RECORDS 
        Set<Id> setCaseIds = new Set<Id>();
        
        // MAP TO HOLD CASE IDS AND RELATED ACCOUNT IDS
        Map<Id, Id> mapCaseId2AcctId = new Map<Id, Id>();
        
        // LOOP THROUGH AND POPULATE THE SET WITH RELATED CASE IDS
        for (NI_Change_Control__c cc : lstNICC) 
        {
            setCaseIds.add(cc.Case_Id__c);
        }
        
        // LOOP THROUGH AND POPULATE THE CASEID TO ACCT ID MAP
        for (Case cs : [SELECT Id, AccountId FROM Case WHERE Id IN : setCaseIds])
        {     
            mapCaseId2AcctId.put(cs.Id, cs.AccountId);
        }
        
        // LOOP THROUGH ALL NICC RECORDS THAT HAVE A CASE ID PRESENT
        for (NI_Change_Control__c nicc : lstNICC) 
        {
            // ADD CASE JUNCTION RECORD TO UPDATE LIST
            NICCRequestCaseJunction__c junc1 = new NICCRequestCaseJunction__c();
            junc1.Case__c = nicc.Case_Id__c; 
            junc1.NI_Change_Control_Request__c = nicc.Id;
            lstCaseJuncs.add(junc1);
            
            // ADD ACCOUNT JUNCTION RECORD TO UPDATE LIST
            if (mapCaseId2AcctId.get(nicc.Case_Id__c) != null)
            {
                NICCRequestAccountJunction__c junc2 = new NICCRequestAccountJunction__c(); 
                junc2.Account__c = mapCaseId2AcctId.get(nicc.Case_Id__c); 
                junc2.NI_Change_Control_Request__c = nicc.Id;
                lstAcctJuncs.add(junc2);
            }         
        }
        
        // BULK INSERT JUNCTION RECORDS
        List<Database.SaveResult> dsr1 = Database.insert(lstCaseJuncs);
        List<Database.SaveResult> dsr2 = Database.insert(lstAcctJuncs);
        
    }
    
    public void HRFCcompilerBlank(List<NI_Change_Control__c> newTrigger)
    {      
        
        // LIST OF TARGET RECORD TYPES
        List<RecordType> lstRTs = new List<RecordType>([
            SELECT Name, Id 
            FROM RecordType 
            WHERE sObjectType = 'NI_Change_Control__c' 
            AND Name IN ('Hosted RFC', 'HRM RFC', 'Internal - IT') 
            AND isActive = true
        ]); 
        
        // NARROW BATCH TO NICC RECORDS WITH CASE IDS AND RECORDTYPES ONLY 
        List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>([
            SELECT Id, Developer_Compiler__c, CreatedById 
            FROM NI_Change_Control__c 
            WHERE Developer_Compiler__c = null 
            AND RecordTypeId IN : lstRTs 
            AND Id IN : newTrigger
        ]);
        
        // LIST FOR ALL NICC RECORD UPDATES 
        List<NI_Change_Control__c> lstUpdates = new List<NI_Change_Control__c>();
        
        for (NI_Change_Control__c nicc : lstNICC) 
        {
            nicc.Developer_Compiler__c = nicc.CreatedById;  
            lstUpdates.add(nicc);           
        }
        
        // BULK UPDATE NICC RECORDS
        List<Database.SaveResult> dsr = Database.update(lstUpdates);
        
    }    
    
    // SHARING FUNCTIONS =====================================================================
    
    public void Change_Owner_Share(List<NI_Change_Control__c> newTrigger)
    {          
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Change_Control__Share> lstRemoveShares = new List<NI_Change_Control__Share>([
            SELECT id
            FROM NI_Change_Control__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Change_Owner_Access__c' 
        ]); 
        
        // BULK REMOVE NICC SHARE RECORDS
        List<Database.DeleteResult> ddr = Database.delete(lstRemoveShares, false);        
        
        // LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Change_Control__Share> lstShares = new List<NI_Change_Control__Share>();
        
        for (NI_Change_Control__c nicc : newTrigger)
        {
            NI_Change_Control__Share niccShare = new NI_Change_Control__Share();
            
            if (nicc.NI_Change_Owner__c != nicc.OwnerId)
            {
                niccShare.ParentId = nicc.Id;
                niccShare.UserOrGroupId = nicc.NI_Change_Owner__c;
                niccShare.AccessLevel = 'edit';
                niccShare.RowCause = Schema.NI_Change_Control__Share.RowCause.Change_Owner_Access__c;
                lstShares.add(niccShare);
            }
        }
        
        // BULK UPDATE NICC SHARE RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstShares, false); 
        
    }    
    
    public void NICCCompShare(List<NI_Change_Control__c> newTrigger)
    {      
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Change_Control__Share> lstRemoveShares = new List<NI_Change_Control__Share>([
            SELECT id
            FROM NI_Change_Control__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Developer_Compiler_Share__c' 
        ]); 
        
        // BULK REMOVE NICC SHARE RECORDS
        List<Database.DeleteResult> ddr = Database.delete(lstRemoveShares, false);        
        
        // LIST OF SHARES THAT NEED TO BE ADDED   
        List<NI_Change_Control__Share> lstShares = new List<NI_Change_Control__Share>();
        
        for (NI_Change_Control__c nicc : newTrigger)
        {
            NI_Change_Control__Share niccShare = new NI_Change_Control__Share();
            
            if (nicc.Developer_Compiler__c != nicc.OwnerId)
            {
                niccShare.ParentId = nicc.Id;
                niccShare.UserOrGroupId = nicc.Developer_Compiler__c;
                niccShare.AccessLevel = 'edit';
                niccShare.RowCause = Schema.NI_Change_Control__Share.RowCause.Developer_Compiler_Share__c;
                lstShares.add(niccShare);
            }
        }
        
        // BULK UPDATE NICC SHARE RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstShares, false); 
        
    }
    
    public void NICCMRShare(List<NI_Change_Control__c> newTrigger)
    {       
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Change_Control__Share> lstRemoveShares = new List<NI_Change_Control__Share>([
            SELECT id
            FROM NI_Change_Control__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Manager_Reviewer_Share__c' 
        ]); 
        
        // BULK REMOVE NICC SHARE RECORDS
        List<Database.DeleteResult> ddr = Database.delete(lstRemoveShares, false);        
        
        // LIST OF SHARES THAT NEED TO BE ADDED    
        List<NI_Change_Control__Share> lstShares = new List<NI_Change_Control__Share>();
        
        for (NI_Change_Control__c nicc : newTrigger)
        {
            NI_Change_Control__Share niccShare = new NI_Change_Control__Share();
            
            if (nicc.Manager_Reviewer__c != nicc.OwnerId)
            {
                niccShare.ParentId = nicc.Id;
                niccShare.UserOrGroupId = nicc.Manager_Reviewer__c;
                niccShare.AccessLevel = 'edit';
                niccShare.RowCause = Schema.NI_Change_Control__Share.RowCause.Manager_Reviewer_Share__c;
                lstShares.add(niccShare);
            }
        }
        
        // BULK UPDATE NICC SHARE RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstShares, false); 
        
    }
    
    public void NICCdevReviewerShare(List<NI_Change_Control__c> newTrigger)
    {       
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Change_Control__Share> lstRemoveShares = new List<NI_Change_Control__Share>([
            SELECT id
            FROM NI_Change_Control__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Developer_Reviewer_Share__c' 
        ]); 
        
        // BULK REMOVE NICC SHARE RECORDS
        List<Database.DeleteResult> ddr = Database.delete(lstRemoveShares, false);        
        
        // LIST OF SHARES THAT NEED TO BE ADDED    
        List<NI_Change_Control__Share> lstShares = new List<NI_Change_Control__Share>();
        
        for (NI_Change_Control__c nicc : newTrigger)
        {
            NI_Change_Control__Share niccShare = new NI_Change_Control__Share();
            
            if (nicc.Developer_Reviewer__c != null)
            {
                niccShare.ParentId = nicc.Id;
                niccShare.UserOrGroupId = nicc.Developer_Reviewer__c;
                niccShare.AccessLevel = 'edit';
                niccShare.RowCause = Schema.NI_Change_Control__Share.RowCause.Developer_Reviewer_Share__c;
                lstShares.add(niccShare);
            }
        }
        
        // BULK UPDATE NICC SHARE RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstShares, false); 
        
    }    
    
    public void NICCpeerReviewerShare(List<NI_Change_Control__c> newTrigger)
    {
        
        // LIST OF SHARES THAT NEED TO BE REMOVED
        List<NI_Change_Control__Share> lstRemoveShares = new List<NI_Change_Control__Share>([
            SELECT id
            FROM NI_Change_Control__Share 
            WHERE ParentId IN : newTrigger 
            AND RowCause = 'Peer_Reviewer_Share__c' 
        ]); 
        
        // BULK REMOVE NICC SHARE RECORDS
        List<Database.DeleteResult> ddr = Database.delete(lstRemoveShares, false);        
        
        // LIST OF SHARES THAT NEED TO BE ADDED
        List<NI_Change_Control__Share> lstShares = new List<NI_Change_Control__Share>();
        
        for (NI_Change_Control__c nicc : newTrigger)
        {
            NI_Change_Control__Share niccShare = new NI_Change_Control__Share();
            
            if (nicc.Peer_Reviewer__c != nicc.OwnerId)
            {
                niccShare.ParentId = nicc.Id;
                niccShare.UserOrGroupId = nicc.Peer_Reviewer__c;
                niccShare.AccessLevel = 'edit';
                niccShare.RowCause = Schema.NI_Change_Control__Share.RowCause.Peer_Reviewer_Share__c;
                lstShares.add(niccShare);
            }
        }
        
        // BULK UPDATE NICC SHARE RECORDS
        List<Database.SaveResult> dsr = Database.insert(lstShares, false); 
        
    }    
    
    
}