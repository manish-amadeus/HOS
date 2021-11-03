/************************************************************************************************
Name            : NI_Case_TriggerHandler Class
Author          : Stuart Emery
Created Date    : 12/07/2013
Last Mod Date   : 04/06/2021 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class that handles all trigger code for the Case Object
                : 
                : 
*************************************************************************************************/
public class NI_Case_TriggerHandler 
{
    
    public static Boolean callFuture = true;
    public static Boolean createHisTrack = true;
    public static Boolean beforeUpdateCaseFlag = true;
    Map<String, Schema.RecordTypeInfo> CaseRecordTypeInfo;
    
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
    
    
    public NI_Case_TriggerHandler()
    {
        
        // ADDED PER NICC-032948
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Case; 
        CaseRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
        
    }

    public void OnBeforeInsert(List<Case> newTrigger)
    {  
      
        if (!bpSwitch.BypassCase_ON__c)
        {
             
            // METHOD TO PREVENT WIN@PROACH / SERVICE NOW INTEGRATION CASES FROM BEING UPDATED
            List<Case> lstValidCases = new List<Case>();
            lstValidCases = lstValidCasesToProcess(newTrigger);
            
            if (lstValidCases.Size() > 0)
            {
                
                // CREATED BY CYBAGE FOR NICC-026092
                // CONDITIONALLY SETS CASE FLAG RELATED FIELD BEFORE COMMIT TO DATABASE (IF TRIGGER BYPASS NOT ON)               
                if (!bpSwitch.BypassCaseFlags_ON__c)
                {   
                    // CALL CASE FLAGS METHOD
                    caseFlagsOnBeforeInsert(lstValidCases);
                }
                
                // PROCESS DEPLOYMENT INSTANCES
                processDI(lstValidCases, null);
                
                // PROCESS SUPPORT TIER DESIGNATION
                setSupportTier(lstValidCases); // ADDED PER NICC-023689

            }
            
        }
        
    }

    public void OnAfterInsert(List<Case> newTrigger)
    {   
     
        if (!bpSwitch.BypassCase_ON__c)
        {
            
            // METHOD TO PREVENT WIN@PROACH / SERVICE NOW INTEGRATION CASES FROM BEING UPDATED
            List<Case> lstValidCases = new List<Case>();
            lstValidCases = lstValidCasesToProcess(newTrigger);     
            
            if (lstValidCases.Size() > 0)
            {
                
                // DUE TO ORDER OF EXECUTION THIS METHOD MUST BE FIRST (START)
                NI_TriggerManager.is1stInsert_Case_Report_Detail = true;
                // CALL WRITE CASE DETAILS METHOD
                writeCaseDetails(lstValidCases, null);                
                // DUE TO ORDER OF EXECUTION THIS METHOD MUST BE FIRST ( END )
               
                if (!bpSwitch.BypassCaseFlags_ON__c)
                {  
                    // CALL CASE FLAGS METHOD
                    caseFlagsOnAfterInsert(lstValidCases);
                }                  
                
                // SET TO HOLD THE CR IDs RELATED TO CASES
                Set<Id> setCRIds = new Set<Id>();
                
                //LIST OF CRs THAT NEED TO BE UPDATED TO SET THE LASTMODIFIEDDATE
                List<SFDC_CSP_Development_Request__c> lstCRsToUpdate = new List<SFDC_CSP_Development_Request__c>();
                
                // LOOP THROUGH THE LIST OF UPDATED CASES TO FIND THE CASES WHERE THE CR FIELD HAS BEEN UPDATED
                for (Case cCR : lstValidCases) 
                { 
                    if (cCR.Change_Request__c != null)
                    {
                        setCRIds.add(cCR.Change_Request__c);
                    }
                }
                
                if (setCRIds.size() > 0)
                {
                    lstCRsToUpdate = [SELECT Id FROM SFDC_CSP_Development_Request__c WHERE Id IN: setCRIds];
                }
                
                if (lstCRsToUpdate.size() > 0)
                {
                    // CALL LAST CHANGE REQUEST MODIFIED DATE METHOD
                    UpdateCRLastModDate(lstCRsToUpdate);
                } 
                
                // CALL CASE SOLUTION METHOD
                caseSolutionTrigger(newTrigger, null);
   
            }
            
        }
        
    }
        
    public void OnBeforeUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {

        if (!bpSwitch.BypassCase_ON__c)
        {
            
            // METHOD TO PREVENT WIN@PROACH / SERVICE NOW INTEGRATION CASES FROM BEING UPDATED
            List<Case> lstValidCases = new List<Case>();
            lstValidCases = lstValidCasesToProcess(newTrigger);
            
            if (lstValidCases.Size() > 0)
            {
                
                // ADDD PER NICC-032948
                // LIST TO GET THE VALID CASE RECORD TYPES FROM THE CUSTOM METADATA RECORD TYPE
                List<AH_Support_Case_Validation__mdt> lstCustomMetadataLst = ([SELECT Record_Type_Name__c FROM AH_Support_Case_Validation__mdt]);
                
                List<Case> lstCasesToEvaluate = new List<Case>();
                
                // IF THE CUSTOM METADATA TYPE CONTAINS RECORD TYPE VALUES, LOOP THROUGH THE NEWTRIGGER LIST OF CASES
                if (lstCustomMetadataLst.size() > 0)
                {
                    for (Case c : lstValidCases) 
                    {
                        
                        Case oldCase = oldMapTrigger.get(c.Id);
                        
                        for (AH_Support_Case_Validation__mdt mdt : lstCustomMetadataLst)
                        {                            
                            // IF THE STATUS IS BEING CHANGED TO CLOSED AND THE CASE RECORD TYPE EXISTS IN THE CUSTOM METADATA TYPE THEN ADD THE CASE TO THE LIST COLLECTION FOR PROCESSING
                            if (((c.Status == 'Closed') && (oldCase.Status != 'Closed')) && 
                                (c.Bypass_Support_Close_Case_Validation__c == false) && 
                                (c.RecordTypeId == CaseRecordTypeInfo.get(mdt.Record_Type_Name__c).getRecordTypeId())) 
                            {
                                lstCasesToEvaluate.add(c);
                            }
                        }  
                    }
                }
                
                // CREATED BY CYBAGE FOR NICC-026092
                // CONDITIONALLY SETS CASE FLAG RELATED FIELD BEFORE COMMIT TO DATABASE (IF TRIGGER BYPASS NOT ON)                  
                if (!bpSwitch.BypassCaseFlags_ON__c && beforeUpdateCaseFlag == true)
                {  
                    // CALL CASE FLAGS METHOD
                    caseFlagsOnBeforeUpdate(lstValidCases, oldMapTrigger);
                    beforeUpdateCaseFlag = false;
                } 
                
                // CALL PROCESS DEPLOYMENT INSTANCES
                processDI(lstValidCases, oldMapTrigger); 
                
                // CALL PROCESS SUPPORT TIER DESIGNATION
                setSupportTier(lstValidCases);  
                
                // CALL RESET CHANGE REQUEST LOOKUP
                resetCRLookup(lstValidCases, oldMapTrigger);                
                
                if (lstCasesToEvaluate.size() > 0)
                {
                    // CALL VALIDATION ON CLOSED CASE DEPENDENCIES
                    Validate_ClosedCaseDependencies(lstCasesToEvaluate);
                }    
                
                // ADDED 12/14/2016
                if (!bpSwitch.BypassCaseReshare_ON__c)
                {
                    // CALL METHOD TO RESHARE CASES TO USERS AFTER OWNER CHANGES
                    persistCaseSharesOnOwnerChange(lstValidCases, oldMapTrigger); 
                }
                
            }
            
        }
        
    }

    public void OnAfterUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {
        
        if (!bpSwitch.BypassCase_ON__c)
        {
            
            // METHOD TO PREVENT WIN@PROACH / SERVICE NOW INTEGRATION CASES FROM BEING UPDATED
            List<Case> lstValidCases = new List<Case>();
            lstValidCases = lstValidCasesToProcess(newTrigger);     
            
            if (lstValidCases.Size() > 0)
            {

                // DUE TO ORDER OF EXECUTION THIS METHOD MUST BE FIRST (START)			
                // CALL WRITE CASE DETAILS METHOD
                writeCaseDetails(lstValidCases, oldMapTrigger);                
                // DUE TO ORDER OF EXECUTION THIS METHOD MUST BE FIRST ( END )	
                 
                // SET TO HOLD THE CR IDs RELATED TO CASES
                Set<Id> setCRIds = new Set<Id>();
                
                // LIST OF CRs THAT NEED TO BE UPDATED TO SET THE LASTMODIFIEDDATE
                List<SFDC_CSP_Development_Request__c> lstCRsToUpdate = new List<SFDC_CSP_Development_Request__c>();
                
                // LOOP THROUGH THE LIST OF UPDATED CASES TO FIND THE CASES WHERE THE CR FIELD HAS BEEN UPDATED
                for (Case cCR : lstValidCases) 
                {
                    
                    Case oldCase = oldMapTrigger.get(cCR.Id);            
                    
                    if (cCR.Change_Request__c != oldCase.Change_Request__c) 
                    {
                        setCRIds.add(cCR.Change_Request__c);
                        setCRIds.add(oldCase.Change_Request__c);
                    }
                    
                    if ((cCR.Change_Request__c == null) && (oldCase.Change_Request__c != null))
                    {
                        setCRIds.add(oldCase.Change_Request__c);
                    }
                    
                }
                
                if (setCRIds.size() > 0)
                {
                    lstCRsToUpdate = [SELECT Id FROM SFDC_CSP_Development_Request__c WHERE Id IN: setCRIds];
                }
                
                if (lstCRsToUpdate.size() > 0)
                {
                    // CALL LAST CHANGE REQUEST MODIFIED DATE METHOD
                    UpdateCRLastModDate(lstCRsToUpdate);
                }
                
                // CALL CASE SOLUTION METHOD
                caseSolutionTrigger(lstValidCases, oldMapTrigger); 
                
                if (!bpSwitch.BypassCaseFlags_ON__c)
                {    
                    // CALL CASE FLAGS METHOD
                    caseFlagsOnAfterUpdate(lstValidCases, oldMapTrigger);
                }
                
                // ADDED 12/14/2016            
                if (!bpSwitch.BypassCaseReshare_ON__c)
                { 
                    // CALL METHOD TO RESHARE CASES TO USERS AFTER OWNER CHANGES
                    persistCaseSharesAfterCaseUpdate(lstValidCases);
                } 
                
                // CALL CLOSE USER STORY IN RALLY METHOD
				closeUserStoryInRally(newTrigger, oldMapTrigger); 
              
            }
  
        }
        
    } 

    // =========================================================================
    //    FUNCTIONS ============================================================
    // =========================================================================    
    private List<Case> lstValidCasesToProcess (List<Case> newTrigger)
    {
        
        // LIST OF VALID CASES TO BE RETURNED 
        List<Case> retLst = new List<Case>();
        
        // GET ALL VALID CASE RECORD TYPE NAMES FROM CUSTOM SETTING
        Winaproach_Incident_Case_Record_Type__c wcsRecordTypes = Winaproach_Incident_Case_Record_Type__c.getValues('Default'); 
        
        // 4/23/2018- ADDED BY RIA TO CONSIDER 'CRS WORK ORDER' CASE RECORD TYPES
        Winaproach_Work_Order_Case_Record_Type__c workOrderRecType = Winaproach_Work_Order_Case_Record_Type__c.getValues('Default');
        
        // IF NO RECORD TYPE NAMES FROM CUSTOM SETTING FOUND RETURN 0 SIZED CASE LIST
        if (wcsRecordTypes == null  && workOrderRecType == null){return retLst;}
        
        // PARSE RECORD TYPE NAMES FROM CUSTOM SETTING INTO LIST
        List<String> lstRecordtypes = String.valueOf(wcsRecordTypes.record_type__c).split(',');
        
        // SET TO HOLD CASE RECORD TYPE IDS 
        Set<Id> setRecordTypeIds = new Set<Id>();
        
        // 4/23/2018- ADDED BY RIA TO CONSIDER 'CRS WORK ORDER CASE' RECORD TYPES ALSO
        // LOOK FOR RECORD TYPE OF CRS WORK ORDERS
        if (workOrderRecType != null)
        {
            lstRecordtypes.add(String.valueOf(workOrderRecType.Record_Type__c));
        }

        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.Case.getRecordTypeInfosByName();

        for (String recType : lstRecordtypes)
        {
            if (recordTypesMap.containsKey(recType)) 
            {
                Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
                setRecordTypeIds.Add(rr.getRecordTypeId());
            }
        }

        for (Case c : newTrigger)
        {
            // IF CASE IS NOT OF A WIN@PROACH / SERVICE NOW INTEGRATION RECORD TYPE 
            if (!setRecordTypeIds.contains(c.RecordTypeId))
            {
                retLst.Add(c); 
            }
        }
        
        return retLst;
        
    }
    
    private void persistCaseSharesOnOwnerChange(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {
        
        Set<Id> setCaseIdsWithOwnerChanged = new Set<Id>();
        
        for (Case c : newTrigger)
        {
            Case oldCase = oldMapTrigger.get(c.Id);             
            if (c.OwnerId != oldCase.OwnerId)
            {
                setCaseIdsWithOwnerChanged.Add(c.Id);
            }            
        }
        
        List<Case_Share__c> lstCSInsert = new List<Case_Share__c>();
        
        for (CaseShare cs : [SELECT CaseAccessLevel, CaseId, RowCause, UserOrGroupId 
                             FROM CaseShare 
                             WHERE RowCause = 'Manual' 
                             AND CaseId IN : setCaseIdsWithOwnerChanged])
        {
            Case_Share__c x = new Case_Share__c(CaseAccessLevel__c = cs.CaseAccessLevel, CaseId__c = cs.CaseId, RowCause__c = cs.RowCause, UserOrGroupId__c = cs.UserOrGroupId);
            lstCSInsert.Add(x);
        }
        
        Database.insert(lstCSInsert);
        
    }
    
    private void persistCaseSharesAfterCaseUpdate(List<Case> newTrigger)
    { 
        
        List<CaseShare> lstCSInsert = new List<CaseShare>();
        List<Case_Share__c> lstCSDelete = new List<Case_Share__c>();
        
        Set<Id> setCaseIds = new Set<Id>();
        
        for (Case c : newTrigger)
        {
            setCaseIds.Add(c.Id);
        }
        
        for (Case_Share__c cs : [SELECT CaseAccessLevel__c, CaseId__c, RowCause__c, UserOrGroupId__c FROM Case_Share__c WHERE CaseId__c IN : setCaseIds])
        {
            CaseShare x = new CaseShare(CaseAccessLevel = cs.CaseAccessLevel__c, CaseId = cs.CaseId__c, UserOrGroupId = cs.UserOrGroupId__c); 
            lstCSInsert.Add(x);
            lstCSDelete.Add(cs); 
        }
        
        database.delete(lstCSDelete);
        database.insert(lstCSInsert);
        
    }    
    
    private void processDI(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {

        // SET OF RELATED ACCOUNT IDS
        Set<Id> setDIs = new Set<Id>();
        
        // POPULATE SET OF RELATED ACCOUNT IDS
        for (Case cs : newTrigger)
        {
            if (oldMapTrigger != null)
            {
                Case oldCs = oldMapTrigger.get(cs.Id); 
                
                if (cs.AssetId != oldCs.AssetId)
                {
                    if (cs.AssetId != null)
                    {
                        setDIs.Add(cs.AssetId);
                    }
                }
            }
            else
            {
                setDIs.Add(cs.AssetId);
            }
        }
        
        if (setDIs.Size() != 0)
        {
            Map<Id, Id> mapDHIs = NI_FUNCTIONS.getLatestDIHistoryIDMap(setDIs);    
            for (Case x : newTrigger)
            {           
                if (mapDHIs.get(x.AssetId) != null)
                {    
                    x.Deployment_Instance_History_Record__c = mapDHIs.get(x.AssetId);
                }
            }
        }
        
    }

    private void setSupportTier(List<Case> newTrigger)
    {
        
        Set<Id> setOwnerIds = new Set<Id>();
        
        for (Case cs : newTrigger)
        {
            setOwnerIds.Add(cs.OwnerId);
        }
        
        List<Support_Tier_Designation__c> lstSTD = new List<Support_Tier_Designation__c>(
            [SELECT Id, Support_Rep__c, Support_Rep_Role__c, Tier__c  
             FROM Support_Tier_Designation__c 
             WHERE Support_Rep__c IN : setOwnerIds 
             AND Inactive__c = false 	// PER NICC-016917 
            ]);

        for (Case c : newTrigger)
        {

            if (c.OwnerId.getSObjectType() == Group.SObjectType) //ADDED PER NICC-023689
            {
                c.Support_Tier__c = null;
                c.Support_Tier_Designation__c = null;                
            }
            
            if (c.OwnerId.getSObjectType() == User.SObjectType) //ADDED PER NICC-023689
            {  
                for (Support_Tier_Designation__c t : lstSTD)
                {  
                    if (c.OwnerId == t.Support_Rep__c)
                    {
                        c.Support_Tier__c = t.Support_Rep_Role__c;
                        c.Level_1_Tier__c = t.Tier__c;
                        c.Support_Tier_Designation__c = t.Id;
                    }
                }                
            }
            
        }
        
    }

    public void UpdateCRLastModDate(List<SFDC_CSP_Development_Request__c> newTrigger)
    {

        // ISSUE AN UPDATE TO THE lstCR LIST COLLECTION SO THE LastModDate FOR EACH CR IS UPDATED TO THE CURRENT DATE AND TIME.
        // THE TFS INTEGRATION LOOKS FOR THE LASTMODDATE ON CR RECORDS
        if (newTrigger.size() > 0) 
        {
            
            Database.SaveResult[] results = Database.update(newTrigger, false);
            for (Database.SaveResult sr: results)
            {
                if (!sr.isSuccess()) { Database.Error err = sr.getErrors()[0]; }
            }
        } 

    }       

    private void caseSolutionTrigger(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {
        
        // IS INSERT TOGGLE 
        boolean isInsertEvent = false;
        
        if (oldMapTrigger == null)
        {
            isInsertEvent = true;
        }
        
        List<CaseSolution> lstCaseSolutionInserts = new List<CaseSolution>(); 
        List<Case> lstChildCases = new List<Case>(); 
        Set<Id> setClosedCaseIds = new Set<Id>(); 
        Set<Id> setChildCaseIds = new Set<Id>();         
        
        // LOOP THROUGH CASE TRIGGER TO FIND NEWLY CLOSED CASES AND ADD THE ID TO THE SET
        for (Case c : newTrigger) 
        {
            if (isInsertEvent)
            {
                if (c.status == 'Closed') 
                {
                    setClosedCaseIds.add(c.Id);
                }
            }
            else
            {           
                if ((c.status == 'Closed') && (oldMapTrigger.get(c.Id).Status != 'Closed'))
                {
                    setClosedCaseIds.add(c.Id);
                }
            }
            
        }
        
        // CHECK TO SEE IF ANY CASE IDS WERE COLLECTED IN BLOCK ABOVE. IF SO, FIND CHILD CASE IDS.
        if (setClosedCaseIds.size() > 0) 
        {
            for (Case[] cases : [SELECT Id, ParentId FROM Case WHERE ParentId IN : setClosedCaseIds]) 
            {
                lstChildCases.addAll(cases);
                for (Case cse : cases) 
                {
                    setChildCaseIds.add(cse.Id);
                }
            }
        }
        
        // IF PARENT AND CHILD CASES WERE FOUND ADD ALL SOLUTIONS TO CaseSolution JUNCTION OBJECT
        if ((lstChildCases.size() > 0) && (setClosedCaseIds.size() > 0)) 
        {
            for (CaseSolution[] caseSols : [SELECT CaseID, SolutionId FROM CaseSolution WHERE CaseId IN : setClosedCaseIds]) 
            {
                for (Case c: lstChildCases) 
                {
                    for (CaseSolution cs : caseSols) 
                    {
                        if (cs.CaseId == c.ParentId) 
                        {
                            CaseSolution s = new CaseSolution(CaseId = c.Id, SolutionId = cs.SolutionId);
                            s.CaseId = c.Id;
                            s.SolutionId = cs.SolutionId;
                            lstCaseSolutionInserts.add(s);
                        }
                    }
                }
            }
        }
        
        // THE REMAINDER OF THIS CODE WRITES RECORDS TO THE CUSTOM OBJECT CALLED Solution_Count__c THAT IS USED IN THE 
        // FOLLOWING ROLLUP SUMMARY FIELD ON CASE OBJECT: Number_of_Solutions__c
        // THAT THIS VALIDATION CASE RULE USES: https://amadeus-hospitality.my.salesforce.com/03d600000000B7M?setupid=CaseValidations
        Solution_Count__c[] updateSolutionCounts = new Solution_Count__c[0];
        Solution_Count__c[] insertSolutionCounts = new Solution_Count__c[0];
        Map <Id, Solution_Count__c> scMap = new Map <Id, Solution_Count__c>();
        
        for (Solution_Count__c[] scs : [SELECT Id, Case__c FROM Solution_Count__c WHERE Case__c IN : setChildCaseIds]) 
        {
            for (Solution_Count__c sc : scs) 
            {
                scMap.put(sc.Case__c, sc);
            }   
        } 
        
        if (setChildCaseIds.size() > 0) 
        {
            for (Case[] cs : [SELECT Id, (SELECT Id FROM CaseSolutions) FROM Case WHERE Id IN : setChildCaseIds]) 
            {
                for (Case c : cs) 
                {
                    if (scMap.containsKey(c.Id)) 
                    {
                        Solution_count__c tempSC = scMap.get(c.Id);
                        tempSC.Number_of_Solutions__c = c.caseSolutions.size();
                        updateSolutionCounts.add(tempSC);
                    }
                    else 
                    {
                        Solution_count__c tempNewSC = new Solution_count__c(Case__c = c.Id, Number_of_Solutions__c = c.caseSolutions.size());
                        insertSolutionCounts.add(tempNewSC);
                    }
                }
            }
        }

        Database.update(updateSolutionCounts);
        Database.insert(insertSolutionCounts);
        Database.insert(lstCaseSolutionInserts);
        
    }
    
    private void resetCRLookup(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {
        for (Case c : newTrigger) 
        {        
            // IF Approval_Status__c CHANGES
            if (c.Approval_Status__c != oldMapTrigger.get(c.Id).Approval_Status__c)
            {
                // IF Approval_Status__c IS CHANGED TO 'Rejected' OR 'Recalled'
                if (c.Approval_Status__c == 'Rejected' || c.Approval_Status__c == 'Recalled')
                {
                    c.Change_Request__c = null;
                }
            }
        }
    }

    private void writeCaseDetails(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {
        
        // THIS METHOD CREATES AH_Case_Report_Detail__c RECORDS 

        // BLOCK THAT PREVENTS RECUSIVE CALLS TO THIS METHOD
        if (NI_TriggerManager.is1stInsert_Case_Report_Detail == false)
        {            
            return;
        }
        
        NI_TriggerManager.is1stInsert_Case_Report_Detail = false;
        
        // FILL SET WITH RELATED SUPPORT TIER DESIGNATION IDS
        Set<Id> setSTDIds = new Set<Id>();        
        for (Case std1 : newTrigger)
        {
            if (std1.Support_Tier_Designation__c != null)
            {
                setSTDIds.add(std1.Support_Tier_Designation__c);
            }
        }
       
        // IF THIS IS AN UPDATE, ADD OLD SUPPORT TIER DESIGNATION IDS
        if (oldMapTrigger != null)
        {
            for (Case std2 : oldMapTrigger.values())
            {
                if (std2.Support_Tier_Designation__c != null)
                {                
                    setSTDIds.add(std2.Support_Tier_Designation__c);
                }
            }
        }

        // CREATE A MAP OF SUPPORT TIER DESIGNATION RECORDS WITH Id AS THE KEY
//        Map<Id, Support_Tier_Designation__c> mapSupportTierDesignation = new Map<Id, Support_Tier_Designation__c>(
//            [SELECT Id, Support_Rep_Role__c, Tier__c  
//             FROM Support_Tier_Designation__c 
//             WHERE Id IN : setSTDIds]); 
        Map<Id, Support_Tier_Designation__c> mapCaseOwner2SptTierDesgn = new Map<Id, Support_Tier_Designation__c>();
        for (Support_Tier_Designation__c std : [SELECT Id, Support_Rep__c, Support_Rep_Role__c, Tier__c FROM Support_Tier_Designation__c WHERE Id IN : setSTDIds])
        {
            mapCaseOwner2SptTierDesgn.put(std.Support_Rep__c, std);
        }

        // CREATE LIST TO HOLD CASE REPORT DETAIL RECORDS TO INSERT
        List<AH_Case_Report_Detail__c> lstCRDInserts = new List<AH_Case_Report_Detail__c>();
        
        // LOOP THROUGH AND CONDITIONALLY POPULATE AH_Case_Report_Detail__c LIST FOR INSERTS
        // IF UPDATE
        if (oldMapTrigger != null) 
        {
 
            // GET MAX AH_Case_Report_Detail__c LOG DATES FOR ALL CASES
            List<AggregateResult> lstMaxRecords = new List<AggregateResult>(
                [SELECT Case__c, MAX(Log_DateTime__c) Log_DateTime__c 
                 FROM AH_Case_Report_Detail__c 
                 WHERE Case__c IN : newTrigger 
                 GROUP BY Case__c]); 

            for (Case newCase : newTrigger)
            {

                Case oldCase = oldMapTrigger.get(newCase.Id);

                // IF CASE OWNER (SUPPORT TIER DESIGNATION) CHANGES OR CASE GETS CLOSED OR REOPENED
                if (
                    ((newCase.Status != oldCase.Status) && newCase.Status == 'Closed' && oldCase.Status != 'Resolved - Pending Customer Confirmation') || // CLOSED CASE
                    ((newCase.Status != oldCase.Status) && oldCase.Status == 'Closed') || // REOPENED CASE 
                    ((newCase.Status != oldCase.Status) && newCase.Status == 'Resolved - Pending Customer Confirmation') || // RESOLVED CASE
                    (newCase.OwnerId != oldCase.OwnerId)  // CASE OWNER CHANGED
                    )
                {

                    // BUILD SUPPORT TIER DESIGNATION NAMES
                    String strNewSTD = ''; 
                    String strNewTier = ''; 
                    String strOldSTD = ''; 
                    String strOldTier = '';                     
                    
//                    if (newCase.Support_Tier_Designation__c != null)
//                    {
//                        strNewSTD = mapSupportTierDesignation.get(newCase.Support_Tier_Designation__c).Support_Rep_Role__c;
//                        strNewTier = mapSupportTierDesignation.get(newCase.Support_Tier_Designation__c).Tier__c;
//                        if (strNewTier == null)
//                        {
//                            strNewTier = ''; 
//                        }
//                    }
                    
                    if (mapCaseOwner2SptTierDesgn.containsKey(newCase.OwnerId))
                    {
                        if (mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Support_Rep_Role__c != null)
                        {
                            strNewSTD = mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Support_Rep_Role__c;
                        }
                        if (mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Tier__c != null)
                        {
                            strNewTier = mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Tier__c;
                        }                          
                    }
                    
//                    if (oldCase.Support_Tier_Designation__c != null)
//                    {
//                        strOldSTD = mapSupportTierDesignation.get(oldCase.Support_Tier_Designation__c).Support_Rep_Role__c;
//                        strOldTier = mapSupportTierDesignation.get(oldCase.Support_Tier_Designation__c).Tier__c;
//                        if (strOldTier == null)
//                        {
//                            strOldTier = ''; 
//                        }
//                    }
                    
                    if (mapCaseOwner2SptTierDesgn.containsKey(oldCase.OwnerId))
                    {
                        if (mapCaseOwner2SptTierDesgn.get(oldCase.OwnerId).Support_Rep_Role__c != null)
                        {
                            strOldSTD = mapCaseOwner2SptTierDesgn.get(oldCase.OwnerId).Support_Rep_Role__c;
                        }
                        if (mapCaseOwner2SptTierDesgn.get(oldCase.OwnerId).Tier__c != null)
                        {
                            strOldTier = mapCaseOwner2SptTierDesgn.get(oldCase.OwnerId).Tier__c;
                        } 
                    }
                    
                    // INIT NEW AH_Case_Report_Detail__c AND ASSIGN FIELD VALUES
                    AH_Case_Report_Detail__c crd = new AH_Case_Report_Detail__c();
                    crd.Case__c = newCase.Id;
                    
                    String strOwnerId = newCase.OwnerId;
                    if (strOwnerId.substring(0, 3) == '00G')
                    {
                        crd.New_Value__c = 'Queue';
                    }
                    else
                    {
                        if (strNewSTD == '' && strNewTier == '')
                        {
                            crd.New_Value__c = 'Non-Support user';
                        }
                        else
                        {
                            crd.New_Value__c = strNewSTD + ' ' + strNewTier;
                        }                        
                    }                    
                    
                    // IF CASE WAS UPDATED TO "Closed"
                    if (newCase.Status == 'Closed' && oldCase.Status != 'Closed')
                    {
                        crd.Event_Type__c = 'Closed';
                        crd.Old_Value__c = strNewSTD + ' ' + strNewTier;
                        crd.Detail__c = UserInfo.getName() + ' closed case.';
                    }
                    // IF CASE WAS UPDATED TO "Reopened"
                    else if (newCase.Status != 'Closed' && oldCase.Status == 'Closed')
                    {
                        crd.Event_Type__c = 'Reopened';
                        crd.Old_Value__c = strNewSTD + ' ' + strNewTier;
                        crd.Detail__c = UserInfo.getName() + ' reopened case.';
                    }
                    // IF CASE WAS UPDATED TO "Resolved - Pending Customer Confirmation"
                    else if (newCase.Status == 'Resolved - Pending Customer Confirmation' && oldCase.Status != 'Resolved - Pending Customer Confirmation')
                    {
                        crd.Event_Type__c = 'Resolved';
                        crd.Old_Value__c = strNewSTD + ' ' + strNewTier;
                        crd.Detail__c = UserInfo.getName() + ' resolved case.';
                    }
                    // ELSE CONSIDER THIS AN OWNER CHANGE
                    else
                    {

                        crd.Event_Type__c = 'Changed';
                        
                        String strOldOwnerId = oldCase.OwnerId;
                        if (strOldOwnerId.substring(0, 3) == '00G')
                        {
                            crd.Old_Value__c = 'Queue';
                        }                                
                        else
                        {
                            if ((strOldSTD == '' && strOldTier == '') || (strOldSTD == null && strOldTier == null)) 
                            {
                                crd.Old_Value__c = 'Non-Support user';
                            }
                            else
                            {
                                crd.Old_Value__c = strOldSTD;
                                if (strOldTier != null)
                                {
                                    crd.Old_Value__c = strOldSTD + ' ' + strOldTier;
                                }
                            }                    
                        }
                        crd.Detail__c = UserInfo.getName() + ' changed Support Tier Designation from ' + crd.Old_Value__c + ' to ' + crd.New_Value__c + '.';
                    }
                    
                    lstCRDInserts.add(crd);
                    
                }
                
            }

            if (!lstCRDInserts.isEmpty())
            {
                for (AH_Case_Report_Detail__c newCRD : lstCRDInserts)
                {
                    for (AggregateResult x : lstMaxRecords)
                    {
                        Id p1 = (Id) x.get('Case__c');
                        if ((newCRD.Case__c == p1) && (newCRD.Event_Type__c != 'Reopened'))
                        {
                            DateTime dtLogTime = (DateTime) x.get('Log_DateTime__c');
                            DateTime dtNow = DateTime.now();
                            newCRD.Log_DateTime__c = dtNow;
                            Long d = (dtNow.getTime() - dtLogTime.getTime());
                            newCRD.Time_Elapsed__c = (Decimal) (d / 1000);
                            if (Test.isRunningTest()){ newCRD.Time_Elapsed__c = (Decimal) ((d / 1000) + 345600);} // THIS LINE IS FOR TEST CLASS. IT EMULATES TIME STAMPS
                        }
                    }
                }                
            } 
            
        }
        else
        {
         	// NEW CASE(s) INSERTED
            for (Case newCase : newTrigger)
            {
                
                String strNewSTD = '';
                String strNewTier = '';
                String strOldSTD = ''; 
                String strOldTier = ''; 
                
//                if (newCase.Support_Tier_Designation__c != null)
//                {
//                    strNewSTD = mapSupportTierDesignation.get(newCase.Support_Tier_Designation__c).Support_Rep_Role__c;
//                    strNewTier = mapSupportTierDesignation.get(newCase.Support_Tier_Designation__c).Tier__c;
//                }
                
                if (mapCaseOwner2SptTierDesgn.containsKey(newCase.OwnerId))
                {
                    if (mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Support_Rep_Role__c != null)
                    {
                        strNewSTD = mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Support_Rep_Role__c;
                    }
                    if (mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Tier__c != null)
                    {
                        strNewTier = mapCaseOwner2SptTierDesgn.get(newCase.OwnerId).Tier__c;
                    }                          
                }
                
                AH_Case_Report_Detail__c crd = new AH_Case_Report_Detail__c();
                crd.Case__c = newCase.Id;
                String strOwnerId = newCase.OwnerId;
                
                if (strOwnerId.substring(0, 3) == '00G')
                {
                    crd.New_Value__c = 'Queue';
                }
                else
                {
                    crd.New_Value__c = strNewSTD + ' ' + strNewTier;
                }

                crd.Old_Value__c = null;
                crd.Event_Type__c = 'Opened';
                crd.Detail__c = UserInfo.getName() + ' opened case.';

                lstCRDInserts.add(crd);
                
                // CHECK TO SEE IF THE CASE WAS CREATED WITH A CLOSED STATUS
                if (newCase.Status == 'Closed')
                {
                    AH_Case_Report_Detail__c crd2 = new AH_Case_Report_Detail__c();
                    crd2.Case__c = newCase.Id;
                    if (strOwnerId.substring(0, 3) == '00G')
                    {
                        crd2.New_Value__c = 'Queue';
                        crd2.Old_Value__c = 'Queue';
                    }
                    else
                    {
                        crd2.New_Value__c = strNewSTD + ' ' + strNewTier;
                        crd2.Old_Value__c = strNewSTD + ' ' + strNewTier;
                    }                     
                    
                    crd2.Event_Type__c = 'Closed';
                    crd2.Detail__c = UserInfo.getName() + ' closed case.';        
                    crd2.Log_DateTime__c = DateTime.now();
                    crd2.Time_Elapsed__c = 120; // INTENTIONALLY HARD-CODED TO 2 MINUTES      
                    lstCRDInserts.add(crd2);
                }
                
            }
            
        }
		
        if (!lstCRDInserts.isEmpty())
        {        
            database.insert(lstCRDInserts);
        }
           
    }

    private void closeUserStoryInRally(List<Case> newTrigger, Map<Id, Case> oldMapTrigger) 
    {
        
        // VARIABLES 
        String OldStatusValue;
        String NewStatusValue;
        String strArtifact;
        String strId;
        String strStatus;
        String oldManagementCompany;
        String newManagementCompany; 
        String oldResProductRetentionRiskItem;
        String newResProductRetentionRiskItem;
        Set<String> setCaseData = new Set<String>(); 
        Map<String, List<String>> oldMapValues;
        Map<String, List<String>> newMapValues;
        
        for (Case c : oldMapTrigger.values())
        {
            OldStatusValue = c.Status; 
            oldResProductRetentionRiskItem = c.Res_Product_Retention_Risk__c; 
            oldManagementCompany = c.Management_Company__c;
            oldMapValues = AH_Rally_FieldMapper.oldValuesMap(c); 
        }
        
        for (Case c1 : newTrigger)
        {
            NewStatusValue = c1.Status;
            newResProductRetentionRiskItem = c1.Res_Product_Retention_Risk__c;
            strArtifact = c1.Rally_Artifact_Ref__c;
            strId = c1.Id;
            newManagementCompany = c1.Management_Company__c; 
            newMapValues = AH_Rally_FieldMapper.newValuesMap(c1);
        }   
        
        try
        {
            
            if (OldStatusValue != NewStatusValue && (NewStatusValue == 'Closed' || NewStatusValue == 'Duplicate' || NewStatusValue == 'SPAM'))
            {
                setCaseData.add('Status');
            }

            if (oldManagementCompany != newManagementCompany)
            {
                setCaseData.add('Management_Company__c');
            }
            
            if (oldResProductRetentionRiskItem != newResProductRetentionRiskItem)
            {       
                setCaseData.add('Res_Product_Retention_Risk__c');            
            } 

            Map<Id, String> accNamesM = new Map<Id, String>();
            for (String c1 : newMapValues.keySet())
            {
                if (oldMapValues.get(c1).get(0) == null)
                {
                    oldMapValues.put(c1,new List<String>{'', oldMapValues.get(c1).get(1)});
                }
                if (newMapValues.get(c1).get(0) == null)
                {
                    newMapValues.put(c1,new List<String>{'', newMapValues.get(c1).get(1)});
                }
                if (oldMapValues.get(c1).get(0) != newMapValues.get(c1).get(0))
                {   
                    setCaseData.add(newMapValues.get(c1).get(1));
                }
            }        

            if (strArtifact != null)
            {
                if (strArtifact != '')
                {
                    if (setCaseData.size() > 0)   
                    {
                        AH_Rally_Library.updateValuesInRally(strArtifact, strId, new List<String>(setCaseData));
                        if (setCaseData.contains('Status'))
                        {
                            case c2 = new case();
                            c2.Id = strId;
                            c2.UserStory_Rally_Status__c = 'Closed';
                            update c2;
                        }                        
                    }
                }
            }
        }
        catch (Exception e) { system.debug('AN ERROR OCCURED: ' + e.getMessage()); }
        
    }    
    
    //==============================================================================================================   
    // VALIDATE DEPENDENCIES FOR CLOSING A SUPPORT CASE.  ADDED PER NICC-032948
    private void Validate_ClosedCaseDependencies(List<Case> newTrigger)    
    { 

        Boolean isValidationRuleExempt = FeatureManagement.checkPermission('Validation_Rule_Exempt_User');

        //EXECUTE THE CODE IF THE BYPASS SWITCH IS NOT CHECKED
        if (!bpSwitch.Bypass_Case_Validate_Support_Close_Case__c && isValidationRuleExempt == false) 
        {  

            // CREATE A LIST OF CASEARTICLE RECORDS RELATED TO THE UPDATED CASES
            List<CaseArticle> lstArticles = [SELECT CaseId, KnowledgeArticleId, ArticleLanguage, ArticleVersionNumber 
                                             FROM CaseArticle  
                                             WHERE CaseId IN : newTrigger]; 
                                             
            // NICC-045910 (START)
            // BECAUSE SALESFORCE DOES NOT LET US LINK KNOWLEDGE VERSION OBJECT ("__kav") FROM CaseArticle BUT DOES LINK TO ARTICLE ("__ka")
            // THE SOLUTION USED HERE GETS THE KnowledgeArticleId IDS THEN ISSUES A QUERY TO LOOK FOR FOR -- INVALID -- ARTICLES. 
            // IF ANY MATCHES ARE FOUND WHILE LOOPING THOUGH CaseArticle LIST THEN THE INDEX IS REMOVED FROM THE LIST TO CAUSE VALIDATION FAILURE LATER
            Set<Id> setKAVIds = new Set<Id>();
            
            for (CaseArticle ca : lstArticles)
            {
                setKAVIds.add(ca.KnowledgeArticleId); 
            }
            
            for (Lightning_Knowledge__kav kav : [SELECT Id, KnowledgeArticleId, PublishStatus, RecordType.Name 
                                                 FROM Lightning_Knowledge__kav 
                                                 WHERE IsLatestVersion = true
                                                 AND KnowledgeArticleId IN : setKAVIds])
            {
                // ONLY LOOP IF INVALID PublishStatus OR RecordType Name
                if ((kav.PublishStatus == 'Archived') || (kav.RecordType.Name == 'Procedural'))
                {
                    // LOOP TROUGH BACKWARDS TO PREVENT POTENTIAL OUT-OF-BOUNDS ERRORS
                    for (Integer i = (lstArticles.size() - 1); (i > -1); i--)
                    {
                        // REMOVE INVALID ITEM FROM LIST
                        if (kav.KnowledgeArticleId == lstArticles[i].KnowledgeArticleId)
                        {
                            lstArticles.remove(i);
                        }
                    }
                }
            }
            // NICC-045910 (END)
            
            // CREATE A LIST OF CASESOLUTION RECORDS RELATED TO THE UPDATED CASES
            List<CaseSolution> lstCaseSolutions = [SELECT CaseId, SolutionId
                                                   FROM CaseSolution
                                                   WHERE CaseId IN : newTrigger 
                                                   AND Solution.Status NOT IN ('Archived', 'Duplicate', 'Inactive')];  // ADDED THIS LINE (NICC-034157)
            
            //SET COLLECTION TO HOLD THE UNIQUE CASE IDs THAT ARE IN THE Articles LIST COLLECTION
            Map<Id, Id> mapCaseIds = new Map<Id, Id>();
            
            for (CaseArticle ca1 : lstArticles)
            {
                mapCaseIds.put(ca1.CaseId, ca1.KnowledgeArticleId); 
            }
            
            for (CaseSolution cs1 : lstCaseSolutions)
            {
                mapCaseIds.put(cs1.CaseId, cs1.SolutionId); 
            }
            
            // LOOP THROUGH THE CASES
            for (Case c1 : newTrigger) 
            {
                // IF ANY OF THE LIST SIZES ARE ZERO RAISE ERROR
                if ((!mapCaseIds.containsKey(c1.Id)) && (c1.Change_Request__c == null)) 
                {
                    c1.addError(system.Label.AH_Case_Support_Case_Closed_Requirements);
                }                
            }  
            
        } 
		
    }
        
    
    // ========================================================================================================================
    //  CASE FLAGS "TRIGGER ENTRY" FUNCTIONS (NICC-026092) ====================================================================
    // ========================================================================================================================
    
    // AH CASE FLAGS FIELDS ===================================================================================================

    // AH Flag							AH_Flag__c							Formula (Text)	
    // AH Flag (BH)						AH_Flag_BH__c						Formula (Text)
    // AH Case Flag Age Text			AH_Case_Flag_Age_Text__c			Formula (Text)
    // AH Case Flag Age					AH_Case_Flag_Age__c					Formula (Number)    
    // AH Case Flag Business Age		AH_Case_Flag_Business_Age__c		Formula (Number)
    // AH Current Business Hours		AH_Current_Business_Hours__c		Formula (Number)
    // AH Initial Response Hours		AH_Initial_Response_Hours__c		Formula (Number)    
    
    // AH Initial response				AH_Initial_response__c				Date/Time    
    // AH Case Flags Escalation Time 1	AH_CaseFlagsEscalationTime_1__c		Date/Time	
    // AH Case Flags Escalation Time 2	AH_CaseFlagsEscalationTime_2__c		Date/Time	
    // AH Case Flags Escalation Time 3	AH_CaseFlagsEscalationTime_3__c		Date/Time	
    // AH Case Flags Escalation Time 4	AH_CaseFlagsEscalationTime_4__c		Date/Time
    // Case Flagged Date/Time			AH_Case_Flagged_Date__c				Date/Time	
    // Todays End Time					Todays_End_Time__c					Date/Time	
    // Todays Start Time				Todays_Start_Time__c				Date/Time	
    
    // AH Case Flags Age 1 Hours		AH_Case_Flags_Age_1_Hours__c		Number(16, 2)	
    // AH Case Flags Age 2 Hours		AH_Case_Flags_Age_2_Hours__c		Number(16, 2)	
    // AH Case Flags Age 3 Hours		AH_Case_Flags_Age_3_Hours__c		Number(16, 2)	
    // AH Case Flags Age 4 Hours		AH_Case_Flags_Age_4_Hours__c		Number(16, 2)
    // AH Previous Business Hours		AH_Previous_Business_Hours__c		Number(16, 2)	
    // AH Initial Response Business Hours	AH_Initial_Response_Business_Hours__c	Number(16, 2)	
    
    // AH Enable Case Flag				AH_Enable_Case_Flag__c				Checkbox	
		
    
    
    // AH_CaseFlagPreferences__c CUSTOM SETTING FIELDS =================================================================
    
    // Add_Trigger_Comments__c		TRUE
    // Age_1_Hours__c				0.00
    // Age_1_Image__c				0150d000002GlTyAAK
    // Age_2_Hours__c				6.00
    // Age_2_Image__c				0150d000002GlTzAAK
    // Age_3_Hours__c				12.00
    // Age_3_Image__c				0150d000002GlU0AAK
    // Age_4_Hours__c				24.00
    // Age_4_Image__c				0150d000002GlTwAAK
    // AH_Blank_Image__c			NULL
    // Clear_on_Activity__c			TRUE
    // Clear_On_Case_Close__c		TRUE
    // Clear_On_Case_Origin__c		TRUE
    // Clear_On_Company_Comment__c	TRUE
    // Clear_on_Outbound_Email__c	TRUE
    // Company_Domain__c			NULL
    // Enable_History__c			TRUE
    // Excluded_Users__c			00532000005XHNIAA4,00560000000yI7jAAE
    // Hours__c						Business
    // Organisation_Wide__c			TRUE
    // Set_On_Case_Attachment__c	TRUE
    // Set_On_Case_Create__c		TRUE
    // Set_On_Case_File__c			FALSE
    // Set_On_Customer_Comment__c	TRUE
    // Set_On_Inbound_Email__c		TRUE
    // Track_Case_Ownership__c		FALSE
    // Track_Case_Status__c			FALSE
    // Track_Flag_Clear__c			TRUE
    // Track_Flag_Set__c			TRUE    
    
    
    // AH_Case_Flags_Store_Types__c OBJECT FIELDS ===================================================================
    // AH Case Flags Store Types Name - Name:				'Default'
    // Enabled Activity Types - Enabled_Activity_Types__c:	'Call,Email,Incoming Call,Left Message,Outgoing Call,Outgoing Email'
    // Clear Case Origins - Clear_Case_Origins__c: 			'Customer Project,LiveChat,Phone'
    // Enabled Case Type - Enabled_Case_Type__c: 			'0126000000011YUAAY,01232000000JNnBAAW,0126000000011YWAAY';

    private void caseFlagsOnBeforeInsert(List<Case> newTrigger)
    {

        // CREATED BY CYBAGE FOR NICC-026092
        // CONDITIONALLY SETS CASE FLAG RELATED FIELD BEFORE COMMIT TO DATABASE
        
        AH_CaseFlagPreferences__c caseFlagSetting = new AH_CaseFlagPreferences__c();
        caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();          
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        
        List<String> lstCaseTypes = new List<String>();
        Map<String, String> mapCaseTypes = new Map<String, String>();
        
        List<String> lstCaseOrigins = new List<String>();        
        Map<String, String> mapCaseOrigins = new Map<String, String>();
        
        // FILL A MAP OF CASE RECORD TYPES DEFINED IN OBJECT/FIELD AH_Case_Flags_Store_Types__c.Enabled_Case_Type__c
        try
        {

            flagRecTypes = [SELECT Name, Enabled_Case_Type__c, Clear_Case_Origins__c, Enabled_Activity_Types__c        
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' 
                            LIMIT 1];
            
            // FILL "ENABLED" CASE TYPES MAP
            if (flagRecTypes.Enabled_Case_Type__c != null)
            {
                lstCaseTypes = flagRecTypes.Enabled_Case_Type__c.split(',');
            }
            
            if (!lstCaseTypes.isEmpty())
            {
                for (String s : lstCaseTypes)
                {
                    mapCaseTypes.put(s, s);
                }
            }
            else
            {
                mapCaseTypes.put('None', 'None');
            }
            
            // FILL "CLEAR" CASE ORIGINS MAP
            if (flagRecTypes.Clear_Case_Origins__c != null)
            {
                lstCaseOrigins = flagRecTypes.Clear_Case_Origins__c.split(',');
            }
            
            if (!lstCaseOrigins.isEmpty())
            {
                for (String o : lstCaseOrigins)
                {
                    mapCaseOrigins.put(o, o);
                }
            }
            else
            {
                mapCaseOrigins.put('None', 'None');
            }
            
        }
        catch (Exception e) { system.debug('Error Occurred: ' + e.getMessage()); }
        
        // INITIALIZE AH CASE FLAG FIELDS
        if (!mapCaseTypes.isEmpty()) 
        {
            for (Case c : newTrigger)
            {

                // IF THE CASE IS CLONED OR THE AH_Case_Flagged_Date__c HAS A VALUE,
                // INTIALIZE ALL CASE FLAG FIELDS WITH BASE DEFAULTS 
                if (c.isClone() && c.AH_Case_Flagged_Date__c != null)
                {
                    c.AH_Case_Flagged_Date__c = null;
                    c.AH_CaseFlagsEscalationTime_1__c = null;
                    c.AH_CaseFlagsEscalationTime_2__c = null;
                    c.AH_CaseFlagsEscalationTime_3__c = null;
                    c.AH_CaseFlagsEscalationTime_4__c = null;
                    c.Todays_Start_Time__c = null;
                    c.Todays_End_Time__c = null;
                    c.AH_Previous_Business_Hours__c = null;
                    c.AH_Initial_response__c = null;
                    c.isInitialResponseSet__c = false;					// NICC-044303
                    c.AH_Initial_Response_Business_Hours__c = null;
                    c.AH_Case_Flags_Age_1_Hours__c = null;
                    c.AH_Case_Flags_Age_2_Hours__c = null;
                    c.AH_Case_Flags_Age_3_Hours__c = null;
                    c.AH_Case_Flags_Age_4_Hours__c = null;
                }
                
                // SET 4 TYPES OF AH CASE FLAG HOURS
                if (c.AH_Case_Flags_Age_1_Hours__c == null)
                {
                    c.AH_Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
                }
                
                if (c.AH_Case_Flags_Age_2_Hours__c == null) 
                {
                    c.AH_Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
                }
                
                if (c.AH_Case_Flags_Age_3_Hours__c == null) 
                {
                    c.AH_Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
                }
                
                if (c.AH_Case_Flags_Age_4_Hours__c == null) 
                {
                    c.AH_Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
                }

                // IF IS TARGETED CASE ORIGIN 
                if (mapCaseOrigins.containsKey(c.Origin))
                {

                    // ADDED THIS IF STATEMENT TO PREVENT AH_Initial_response__c FROM BEING UPDATED AFTER IT HAS THE INITIAL VALUE ASSIGNED
                    if (c.AH_Initial_response__c == null  &&  c.isInitialResponseSet__c == false)	// NICC-044303
                    {
                        c.AH_Initial_response__c = DateTime.now();
                        c.isInitialResponseSet__c = true;											// NICC-044303
                    }

                    if (c.CreatedDate != null)
                    {
                        c.AH_Initial_Response_Business_Hours__c = BusinessHours.diff(c.BusinessHoursId, c.CreatedDate, c.AH_Initial_response__c);
                    }
                    
                }
                
                // IF 
                // 	1. CASE'S RECORD TYPE IS FOUND IN AH_Case_Flags_Store_Types__c.Enabled_Case_Type__c MAP 
                // 	2. Case Flagged Date/Time IS NULL -AND- 
                // 	3. Track Flag Set CUSTOM SETTING FIELD IS TRUE -AND- 
                // 	4. Organisation Wide CUSTOM SETTING FIELD IS TRUE 
                // 	   -OR- 
                // 	   Organisation Wide CUSTOM SETTING FIELD IS FALSE BUT AH Enable Case Flag IS CHECKED
                if (mapCaseTypes.containsKey(c.RecordTypeId) && 
                    c.AH_Case_Flagged_Date__c == null && 
                    caseFlagSetting.Track_Flag_Set__c == true && 
                    (caseFlagSetting.Organisation_Wide__c == true || (caseFlagSetting.Organisation_Wide__c == false && c.AH_Enable_Case_Flag__c == true))
                   )
                {
                    if (c.Origin != 'Pager' && 
                        c.Origin != 'Trainer/Onsite' && 
                        c.Origin != 'LiveChat' && 
                        c.Origin != 'Phone')
                    {
                        c.AH_Case_Flagged_Date__c = DateTime.now();
                        if (c.BusinessHoursId != null)
                        {
                            c.AH_CaseFlagsEscalationTime_1__c = BusinessHours.add(c.BusinessHoursId, DateTime.now(), (caseFlagSetting.Age_1_Hours__c*60*60*1000).longValue());
                            c.AH_CaseFlagsEscalationTime_2__c = BusinessHours.add(c.BusinessHoursId, DateTime.now(), (caseFlagSetting.Age_2_Hours__c*60*60*1000).longValue());
                            c.AH_CaseFlagsEscalationTime_3__c = BusinessHours.add(c.BusinessHoursId, DateTime.now(), (caseFlagSetting.Age_3_Hours__c*60*60*1000).longValue());
                            c.AH_CaseFlagsEscalationTime_4__c = BusinessHours.add(c.BusinessHoursId, DateTime.now(), (caseFlagSetting.Age_4_Hours__c*60*60*1000).longValue());
                        }
                    }
                }
            }
        }

    }
    
    private void caseFlagsOnAfterInsert(List<Case> newTrigger)
    {
        
        // CREATED BY CYBAGE FOR NICC-026092
           
        NI_Case_TriggerHandler.createHisTrack = false;
        List<Case> casesToProcess = new List<Case>();
        AH_CaseFlagPreferences__c caseFlagSetting = new AH_CaseFlagPreferences__c();
        caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();

        Set<Id> caseIdSet = new Set<Id>();        
        for (Case c : newTrigger)
        {          
            if (caseFlagSetting.Set_On_Case_Create__c == true && 
                (c.Origin != 'Pager' && 
                 c.Origin != 'Trainer/Onsite' && 
                 c.Origin != 'LiveChat' && 
                 c.Origin != 'Phone')
               )
            {
                caseIdSet.add(c.Id);
            }
        }
              
        if (!caseIdSet.isEmpty())
        {
            casesToProcess = [SELECT Id, RecordTypeId, CaseNumber, BusinessHoursId, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, 
                              AH_Flag_BH__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, 
                              AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, 
                              AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, AH_Case_Flag_Business_Age__c, Todays_End_Time__c, 
                              Todays_Start_Time__c, CreatedDate  
                              ,AH_Initial_response__c, isInitialResponseSet__c  // ADDED BY CYBAGE ON 09/25/2002 TO FIX INITIAL RESPONSE ISSUE
                              FROM Case 
                              WHERE Id IN :caseIdSet];
        }

        if (!casesToProcess.isEmpty())
        {
            setCaseFlagRelatedData(casesToProcess, false, 'Case Created');
        }

    }
        
    private void caseFlagsOnBeforeUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {
        
        // CREATED BY CYBAGE FOR NICC-026092
        // CONDITIONALLY SETS CASE FLAG RELATED FIELD BEFORE COMMIT TO DATABASE

        AH_CaseFlagPreferences__c caseFlagSetting = new AH_CaseFlagPreferences__c();
        caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_case_types = new List<String>();
        List<String> selected_case_origins = new List<String>();        
        Map<String, String> MapSelectedCaseTypes = new Map<String, String>();
        Map<String, String> MapSelectedCaseOrigins = new Map<String, String>();
        
        // CREATE LIST OF SELECTED CASE RECORD TYPE
        try
        {
            flagRecTypes = [SELECT  Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c            
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' 
                            LIMIT 1];

            if (flagRecTypes.Enabled_Case_Type__c != null)
            {
                selected_case_types = flagRecTypes.Enabled_Case_Type__c.split(',');
            }
            
            if (flagRecTypes.Clear_Case_Origins__c != null)
            {
                selected_case_origins = flagRecTypes.Clear_Case_Origins__c.split(',');
            }
            
            if (!selected_case_types.isEmpty())
            {
                for (String s : selected_case_types)
                {
                    MapSelectedCaseTypes.put(s,s);
                }
            }
            else
            {
                MapSelectedCaseTypes.put('None', 'None');
            }
            
            if (!selected_case_origins.isEmpty())
            {
                for (String s : selected_case_origins)
                {
                    MapSelectedCaseOrigins.put(s, s);
                }
            }
            else
            {
                MapSelectedCaseOrigins.put('None', 'None');
            }
            
        }
        catch (Exception e) { system.debug('Error Occurred: ' + e.getMessage()); }
        
        if (!MapSelectedCaseTypes.isEmpty()) 
        {  
            
            for (Case c : newTrigger)
            {
                Case oldCase = oldMapTrigger.get(c.Id);
                if (
                    (c.Status != oldCase.Status && c.Status == 'Closed' && caseFlagSetting.Clear_On_Case_Close__c == true) || 
                    (c.Origin != oldCase.Origin && caseFlagSetting.Clear_On_Case_Origin__c == true && MapSelectedCaseOrigins.containsKey(c.Origin))
                )
                {

                    if (caseFlagSetting.Track_Flag_Clear__c == true && (c.AH_Flag__c != null || c.AH_Flag_BH__c != null))
                    {
                        c.AH_Case_Flagged_Date__c = null;
                        c.AH_CaseFlagsEscalationTime_1__c = null;
                        c.AH_CaseFlagsEscalationTime_2__c = null;
                        c.AH_CaseFlagsEscalationTime_3__c = null;
                        c.AH_CaseFlagsEscalationTime_4__c = null;
                        c.AH_Enable_Case_Flag__c = false;
                        c.Todays_Start_Time__c = null;
                        c.Todays_End_Time__c = null;
                        c.AH_Previous_Business_Hours__c = 0.00;
                    }
                }
            }
        }  

    }

    private void caseFlagsOnAfterUpdate(List<Case> newTrigger, Map<Id, Case> oldMapTrigger)
    {

        // CREATED BY CYBAGE FOR NICC-026092

        List<Case> caseToProcess = new List<Case>();
        AH_CaseFlagPreferences__c caseFlagSetting = new AH_CaseFlagPreferences__c();
        caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_case_types = new List<String>();
        Map<String, String> MapSelectedCaseTypes = new Map<String, String>();
        List<String> selected_case_origins = new List<String>();
        Map<String, String> MapSelectedCaseOrigins = new Map<String, String>();
        
        Boolean bIsCancellationCase = false;
        
        // CREATE LIST OF SELECTED CASE RECORD TYPE
        try
        {
            
            flagRecTypes = [SELECT  Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c            
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' 
                            LIMIT 1];
            
            if (flagRecTypes.Enabled_Case_Type__c != null)
            {
                selected_case_types = flagRecTypes.Enabled_Case_Type__c.split(',');
            }
            
            if (flagRecTypes.Clear_Case_Origins__c != null)
            {
                selected_case_origins = flagRecTypes.Clear_Case_Origins__c.split(',');
            }
            
            if (!selected_case_types.isEmpty())
            {
                for (String s : selected_case_types)
                {
                    MapSelectedCaseTypes.put(s, s);
                }
            }
            else
            {
                MapSelectedCaseTypes.put('None','None');
            }
            if (!selected_case_origins.isEmpty())
            {
                for (String s : selected_case_origins)
                {
                    MapSelectedCaseOrigins.put(s, s);
                }
            }
            else
            {
                MapSelectedCaseOrigins.put('None', 'None');
            }
        }
        catch (Exception e) { system.debug('e' + e.getMessage()); } //DO NOTHING 
        
        if (!MapSelectedCaseTypes.isEmpty()) 
        {  
            
            List<Id> cases_tobeUpdated = new List<Id>();
            List<Case> caseToSetOffset = new List<Case>();
            List<Case> caseStatusChanged = new List<Case>();
            List<Case> caseOwnerChanged = new List<Case>();
            List<Case> casesToClear = new List<Case>();
            
            for (Case c : newTrigger) 
            {
                
                if (c.Origin == 'Cancellation')
                {
                    bIsCancellationCase = true;
                }
                
                // COLLECT CASES FOR FUTURE METHOD
                if (MapSelectedCaseTypes.containsKey(c.RecordTypeId) && (caseFlagSetting.Organisation_Wide__c == true || (caseFlagSetting.Organisation_Wide__c == false && c.AH_Enable_Case_Flag__c == true))) 
                {
 
                    cases_tobeUpdated.add(c.Id);
                    
                    Case oldCase = oldMapTrigger.get(c.Id);
                    if (c.Origin != null && c.Origin != oldCase.Origin &&  MapSelectedCaseOrigins.containsKey(c.Origin) && caseFlagSetting.Clear_On_Case_Origin__c == true)
                    {
                        casesToClear.add(c);
                    }
                    
                    // COLLECT CASES TO SET OFFSET
                    if (c.AH_Case_Flagged_Date__c != oldCase.AH_Case_Flagged_Date__c && oldCase.AH_Case_Flagged_Date__c != null && c.AH_Case_Flagged_Date__c != null)
                    {
                        caseToSetOffset.add(c);
                    }
                    
                    // COLLECT CASES ON CASE CLOSE
                    if (c.Status != oldCase.Status && c.Status == 'Closed' && caseFlagSetting.Clear_On_Case_Close__c == true)
                    {
                        caseToProcess.add(c);
                    }
                    
                    // COLLECT CASES ON STATUS CHANGE
                    if (c.Status != null && c.Status != oldCase.Status && caseFlagSetting.Track_Case_Status__c == true && (c.Status != 'Closed'))
                    {
                        caseStatusChanged.add(c);
                    }
                    
                    // COLLECT CASES ON OWNER CHANGE
                    if (c.OwnerId != null && c.OwnerId != oldCase.OwnerId && caseFlagSetting.Track_Case_Ownership__c == true)
                    {
                        caseOwnerChanged.add(c);
                    }
                    
                }
                
            }            
            
            if (!caseToSetOffset.isEmpty() && createHisTrack == true)
            {
                createHistoryTracking(caseToSetOffset, oldMapTrigger, 'Flag Set', 'User Action or Non-Flags Automation');
            }
            
            if (!caseToProcess.isEmpty() && createHisTrack == true)
            {
                createHistoryTracking(caseToProcess, oldMapTrigger, 'Flag Cleared', 'Case Closed');
            }
            
            if (!caseOwnerChanged.isEmpty() && createHisTrack == true)
            {
                createHistoryTracking(caseOwnerChanged, oldMapTrigger, 'Case Owner Changed', 'User Action or Non-Flags Automation');
            }
            
            if (!caseStatusChanged.isEmpty() && createHisTrack == true)
            {
                createHistoryTracking(caseStatusChanged, oldMapTrigger, 'Case Status Changed', 'User Action or Non-Flags Automation');
            }
            
            if (!casesToClear.isEmpty() && createHisTrack == true)
            {
                createHistoryTracking(casesToClear, oldMapTrigger, 'Flag Cleared', 'Case Origin');
            }
            
            // CALL FUTURE METHOD TO CALCULATE BUSINESS HOURS AGE
            if (!cases_tobeUpdated.isEmpty() && NI_Case_TriggerHandler.callFuture == true && (!system.isBatch()) && bIsCancellationCase == false)
            {
                NI_Case_TriggerHandler.callFuture = false;
                NI_Case_TriggerHandler.calculateBusinessHoursFut(cases_tobeUpdated);
            }
            
        }
        
    }
    
    // ========================================================================================================================
    //  CASE FLAGS FUNCTIONS (NICC-026092) ====================================================================================
    // ========================================================================================================================    
    public void setCaseFlagRelatedData(List<Case> listCases, Boolean toUpdate, String actionType) 
    {
        
        // CREATED BY CYBAGE FOR NICC-026092 
        
        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        List<Case> casesToUpdate = new List<Case>();
        List<AH_Case_Flags_History_Tracking__c> historyTrackList = new List<AH_Case_Flags_History_Tracking__c>();        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_case_types = new List<String>();
        Map <String, String> MapSelectedCaseTypes = new Map <String, String>();
        
        // CREATE LIST OF SELECTED CASE RECORD TYPE
        try
        {
            flagRecTypes = [SELECT  Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c            
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' LIMIT 1];
            
            if (flagRecTypes.Enabled_Case_Type__c != null)
            {
                selected_case_types = flagRecTypes.Enabled_Case_Type__c.split(',');
            }

            if (!selected_case_types.isEmpty())
            {
                for (String s : selected_case_types)
                {
                    MapSelectedCaseTypes.put(s,s);
                }
            }
            else
            {
                MapSelectedCaseTypes.put('None', 'None');
            }
        }
        catch (Exception e) { system.debug('e' + e.getMessage()); }	//DO NOTHING 
 
        if (!MapSelectedCaseTypes.isEmpty()) 
        {  
            for (Case c : listCases) 
            {

                if (MapSelectedCaseTypes.containsKey(c.RecordTypeId) && 
                    (c.AH_Case_Flagged_Date__c == null || actionType == 'Case Created') && 
                    caseFlagSetting.Track_Flag_Set__c == true && 
                    (caseFlagSetting.Organisation_Wide__c == true || (caseFlagSetting.Organisation_Wide__c == false && c.AH_Enable_Case_Flag__c == true))
                   )
                {
                    if (c.BusinessHoursId != null)
                    {
                        c.AH_Case_Flagged_Date__c = DateTime.now();
                        c.AH_CaseFlagsEscalationTime_1__c = BusinessHours.add(c.BusinessHoursId, DateTime.now(), (caseFlagSetting.Age_1_Hours__c*60*60*1000).longValue());
                        c.AH_CaseFlagsEscalationTime_2__c = BusinessHours.add(c.BusinessHoursId, DateTime.now(), (caseFlagSetting.Age_2_Hours__c*60*60*1000).longValue());
                        c.AH_CaseFlagsEscalationTime_3__c = BusinessHours.add(c.BusinessHoursId,DateTime.now(), (caseFlagSetting.Age_3_Hours__c*60*60*1000).longValue());
                        c.AH_CaseFlagsEscalationTime_4__c = BusinessHours.add(c.BusinessHoursId,DateTime.now(), (caseFlagSetting.Age_4_Hours__c*60*60*1000).longValue());
                    }
                    
                    if (c.AH_Case_Flags_Age_1_Hours__c == null)
                    {
                        c.AH_Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
                    }
                    
                    if (c.AH_Case_Flags_Age_2_Hours__c == null) 
                    {
                        c.AH_Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
                    }
                    
                    if (c.AH_Case_Flags_Age_3_Hours__c == null) 
                    {
                        c.AH_Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
                    }
                    
                    if (c.AH_Case_Flags_Age_4_Hours__c == null) 
                    {
                        c.AH_Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
                    }

                    if (toUpdate)
                    {
                        casesToUpdate.add(c);
                    }

                    if (caseFlagSetting.Enable_History__c == true && c.AH_Case_Flagged_Date__c != null)
                    {
                        
                        AH_Case_Flags_History_Tracking__c hisTrackObj = new AH_Case_Flags_History_Tracking__c();
                        hisTrackObj.Action__c = actionType;
                        hisTrackObj.Business_Hours__c = c.BusinessHoursId;
                        hisTrackObj.Case__c = c.Id;
                        hisTrackObj.Case_Status__c = c.Status;
                        hisTrackObj.Event__c = 'Flag Set';

                        if (c.OwnerId != null)
                        {
                            if ((String.ValueOf(c.OwnerId)).startsWith('005'))
                            {
                                hisTrackObj.Owner__c = c.OwnerId;
                            }
                            else
                            {
                                if ((String.ValueOf(c.OwnerId)).startsWith('00G'))
                                {
                                    hisTrackObj.Queue_Id__c = String.ValueOf(c.OwnerId);
                                }
                            } 
                        }
                        
                        hisTrackObj.Case_Flags_Age_1_Hours__c = c.AH_Case_Flags_Age_1_Hours__c;
                        hisTrackObj.Case_Flags_Age_2_Hours__c = c.AH_Case_Flags_Age_2_Hours__c;
                        hisTrackObj.Case_Flags_Age_3_Hours__c = c.AH_Case_Flags_Age_3_Hours__c;
                        hisTrackObj.Case_Flags_Age_4_Hours__c = c.AH_Case_Flags_Age_4_Hours__c;
                        historyTrackList.add(hisTrackObj);
                        
                    }
                }
            }
              
            if (!casesToUpdate.isEmpty())
            {
                Database.update(casesToUpdate);
            }
         
            if (!historyTrackList.isEmpty())
            {
                Database.insert(historyTrackList);
            }
            
        }

    }
    
    public void clearCaseFlagRelatedData(List<Case> listCases, Boolean toUpdate, String actionType) 
    {
        
        // CREATED BY CYBAGE FOR NICC-026092

        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        List<Case> casesToUpdate = new List<Case>();
        List<AH_Case_Flags_History_Tracking__c> historyTrackList = new List<AH_Case_Flags_History_Tracking__c>();
        
        AH_Case_Flags_Store_Types__c flagRecTypes = new AH_Case_Flags_Store_Types__c();
        List<String> selected_case_types = new List<String>();
        
        // CREATE LIST OF SELECTED CASE RECORD TYPE
        try
        {
            
            flagRecTypes = [SELECT Name, Enabled_Activity_Types__c, Clear_Case_Origins__c, Enabled_Case_Type__c            
                            FROM AH_Case_Flags_Store_Types__c
                            WHERE Name = 'Default' 
                            LIMIT 1];
            
            if (flagRecTypes.Enabled_Case_Type__c != null)
            {
                selected_case_types = flagRecTypes.Enabled_Case_Type__c.split(',');
            }
            else
            {
                selected_case_types.add('None');
            }

        }
        catch (Exception e) { system.debug('e = ' + e.getMessage()); } //DO NOTHING 
        
        if (!selected_case_types.isEmpty()) 
        {  

            Set<ID> caseIdsSet = new Set<ID>();
            
            for (Case c : listCases)    
            {
                caseIdsSet.add(c.id);
            }

            List<Case> casesList = new List<Case>([SELECT Id, RecordTypeID, CaseNumber, BusinessHoursId, CreatedDate, AH_Flag__c, AH_Flag_BH__c, AH_Case_Flagged_Date__c, 
                         AH_Enable_Case_Flag__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                         AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c,
						 Todays_Start_Time__c, Todays_End_Time__c, AH_Initial_Response_Business_Hours__c, OwnerId, Owner.Name, Status, CreatedById, 
                         AH_Case_Flag_Business_Age__c, AH_Initial_response__c, isInitialResponseSet__c 
                         FROM Case
                         WHERE Id IN :caseIdsSet ]);

            
            for (Case c : casesList)    
            {

                if (selected_case_types.contains(c.RecordTypeID) &&
                    caseFlagSetting.Track_Flag_Clear__c == true &&  
                    c.AH_Case_Flagged_Date__c != null && 
                    (caseFlagSetting.Organisation_Wide__c == true || (caseFlagSetting.Organisation_Wide__c == false && c.AH_Enable_Case_Flag__c == true))
                   )
                {

                    c.AH_Case_Flagged_Date__c = null;
                    c.AH_CaseFlagsEscalationTime_1__c = null;
                    c.AH_CaseFlagsEscalationTime_2__c = null;
                    c.AH_CaseFlagsEscalationTime_3__c = null;
                    c.AH_CaseFlagsEscalationTime_4__c = null;
                    c.AH_Previous_Business_Hours__c = 0.00;
                    c.Todays_Start_Time__c = null;
                    c.Todays_End_Time__c = null;
									
                    if (c.AH_Initial_response__c == null  &&  c.isInitialResponseSet__c == false)	// NICC-044303
                    {
                        c.AH_Initial_response__c = DateTime.now();
                        c.isInitialResponseSet__c = true;											// NICC-044303
                    }

                    if (c.CreatedDate != null)
                    {                     
                        Decimal bsHours = BusinessHours.diff(c.BusinessHoursId, c.CreatedDate, c.AH_Initial_response__c);                        
                        c.AH_Initial_Response_Business_Hours__c = bsHours / (60 * 60 * 1000);
                    }  
                    
                    if (toUpdate)
                    {
                        casesToUpdate.add(c);
                    }
                    
                    if (caseFlagSetting.Enable_History__c == true)
                    {
                        AH_Case_Flags_History_Tracking__c hisTrackObj = new AH_Case_Flags_History_Tracking__c();
                        hisTrackObj.Action__c = actionType;
                        hisTrackObj.Business_Hours__c = c.BusinessHoursId;
                        hisTrackObj.Case__c = c.Id;
                        hisTrackObj.Case_Status__c = c.Status;
                        hisTrackObj.Event__c = 'Flag Cleared';
                        if (c.OwnerId != null)
                        {
                            if ((String.ValueOf(c.OwnerId)).startsWith('005'))
                            {
                                hisTrackObj.Owner__c = c.OwnerId;
                            }
                            else 
                            {
                                if ((String.ValueOf(c.OwnerId)).startsWith('00G'))
                                {
                                    hisTrackObj.Queue_Id__c = String.ValueOf(c.OwnerId);
                                }
                            }
                            
                        }

                        hisTrackObj.Case_Flags_Age_1_Hours__c = caseFlagSetting.Age_1_Hours__c;
                        hisTrackObj.Case_Flags_Age_2_Hours__c = caseFlagSetting.Age_2_Hours__c;
                        hisTrackObj.Case_Flags_Age_3_Hours__c = caseFlagSetting.Age_3_Hours__c;
                        hisTrackObj.Case_Flags_Age_4_Hours__c = caseFlagSetting.Age_4_Hours__c;
                        historyTrackList.add(hisTrackObj);
                    }
                }
            }
            
            if (!casesToUpdate.isEmpty())
            {
                Database.update(casesToUpdate);
            }
            
            if (!historyTrackList.isEmpty())
            {
                Database.insert(historyTrackList);
            }
            
        }
        
    }   
    
    public void createHistoryTracking(List<Case> listCases, Map<Id, Case> oldMapTrigger, String eventType, String actionType)
    {
        
    	// CREATED BY CYBAGE FOR NICC-026092

        AH_CaseFlagPreferences__c caseFlagSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        List<Case> casesToUpdate = new List<Case>();
        List<AH_Case_Flags_History_Tracking__c> historyTrackList = new List<AH_Case_Flags_History_Tracking__c>();
        
        for (Case c : listCases)
        {
            if (caseFlagSetting.Enable_History__c == true)
            {
                Case oldCase = oldMapTrigger.get(c.Id);

                AH_Case_Flags_History_Tracking__c hisTrackObj = new AH_Case_Flags_History_Tracking__c();
                hisTrackObj.Action__c = actionType;
                hisTrackObj.Business_Hours__c = c.BusinessHoursId;
                hisTrackObj.Case__c = c.Id;

                if (oldCase.Status != null)
                {
                    hisTrackObj.Case_Status__c = oldCase.Status;
                }  
                hisTrackObj.Event__c = eventType;

                if (oldCase.OwnerId != null)
                {
                    if ((String.ValueOf(oldCase.OwnerId)).startsWith('005'))
                    {
                        hisTrackObj.Owner__c = oldCase.OwnerId;
                    }
                    else 
                    {
                        if ((String.ValueOf(oldCase.OwnerId)).startsWith('00G'))
                        {
                            hisTrackObj.Queue_Id__c = String.ValueOf(oldCase.OwnerId);
                        }
                    }
                }
                hisTrackObj.Case_Flags_Age_1_Hours__c = c.AH_Case_Flags_Age_1_Hours__c;
                hisTrackObj.Case_Flags_Age_2_Hours__c = c.AH_Case_Flags_Age_2_Hours__c;
                hisTrackObj.Case_Flags_Age_3_Hours__c = c.AH_Case_Flags_Age_3_Hours__c;
                hisTrackObj.Case_Flags_Age_4_Hours__c = c.AH_Case_Flags_Age_4_Hours__c;
                historyTrackList.add(hisTrackObj);
            }
        }
        
        if (!historyTrackList.isEmpty())
        {
            NI_Case_TriggerHandler.createHisTrack = false;
            Database.insert(historyTrackList);
        }

    }

    @future    
    public static void calculateBusinessHoursFut(List<Id> newTriggerId) 
    {
        
        // CREATED BY CYBAGE FOR NICC-026092
        // CALL FUTURE METHOD TO CALCULATE BUSINESS HOURS 
        
        String dayOfWeek = System.now().format('EEEE');
        Set<Id> case_ids = new Set<Id>();
        List<Case> newTrigger = new List<Case>();
        
        if (!newTriggerId.isEmpty())
        {
            newTrigger = [SELECT Id, CaseNumber, BusinessHoursId, AH_Flag__c, Status, CreatedById, Owner.Name, Owner.Id, AH_Flag_BH__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c,
                          AH_Case_Flag_Business_Age__c, Todays_End_Time__c, Todays_Start_Time__c, CreatedDate ,AH_Initial_response__c, isInitialResponseSet__c, 
                          AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c,
                          AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c 
                          FROM Case
                          WHERE Id IN : newTriggerId];
        }

        for (Case c : newTrigger)
        {
            case_ids.add(c.Id);
        } 
        
        String query = 'SELECT Id, BusinessHours.Id, BusinessHours.Name, ' +
            'BusinessHours.MondayStartTime, BusinessHours.MondayendTime, ' +
            'BusinessHours.TuesdayStartTime, BusinessHours.TuesdayendTime, ' +
            'BusinessHours.WednesdayStartTime, BusinessHours.WednesdayendTime, ' +
            'BusinessHours.ThursdayStartTime, BusinessHours.ThursdayendTime, ' + 
            'BusinessHours.FridayStartTime, BusinessHours.FridayendTime, ' +
            'BusinessHours.SaturdayStartTime, BusinessHours.SaturdayendTime, ' +
            'BusinessHours.SundayStartTime, BusinessHours.SundayendTime, ' +
            'AH_Case_Flagged_Date__c, AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, ' +
            'AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, ' +
            'AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, ' +
            'AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, ' +
            'AH_Initial_response__c,isInitialResponseSet__c '+
            'FROM Case ' + 
            'WHERE AH_Case_Flagged_Date__c != NULL AND Id IN : case_ids';
        
        List<Case> cases = Database.query(query);        
        AH_BatchCaseTodaysStartEndTimeHandler handler_obj = new AH_BatchCaseTodaysStartEndTimeHandler();
        List<Case> case_list = handler_obj.getCasesWithTime(cases);

        if (!case_list.isEmpty())
        {
            NI_Case_TriggerHandler.callFuture = false;
            try
            {
                database.update(case_list);
            }
            catch (Exception e)
            {
                system.debug('Error occurred updating case(s): ' + e.getMessage());
            }            
        }
        
    }    

}