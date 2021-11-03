/************************************************************************************************
Name            : AH_ProjectIntake_Functions Class
Author          : Sean Harris
Created Date    : 10/12/2020
Last Mod Date   : 02/21/2021
Last Mod By     : Stuart Emery
NICC Reference  : NICC-047197
Description     : UPDATED 02/21/2021 PER NICC-048128
                : Function Class that handles the AH Project Backlog Priority calculation
                : This is called from the "NI Project Backlog - CBS and Process Improvement"
                : Process Builder and the "AH_ProjectIntake_RecalcPriorities" VF Page
                :
				:                 
*************************************************************************************************/
public class AH_ProjectIntake_Functions 
{

 
    public AH_ProjectIntake_Functions()
    {
    }
    
    public AH_ProjectIntake_Functions(ApexPages.StandardSetController controller) 
    {
    }
    
    public AH_ProjectIntake_Functions(ApexPages.StandardController controller) 
    {
    }
    
    @InvocableMethod(label='Recalculate project backlog priority' description='Method that schedules recalculates the priority values on all valid project backlog records.')
    public static void recalcPriority()
    {
        // BUILD UNIQUE JOB NAME
        Blob b = Crypto.GenerateAESKey(128);
        String strGUID = EncodingUtil.ConvertTohex(b);
        String strJobName = 'RecalcPriorities_' + strGUID;
        
        // BUILD CRON TRIGGER EXPRESSION
        DateTime dt = DateTime.now();
        dt = dt.addMinutes(2);
        String strCronTrig = '0 ' + dt.minute() + ' ' + dt.hour() + ' ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year() + '';
        
        // INSTANTIATE SCHEDULABLE CLASS
        AH_ProjectIntake_Schedule objSchedClass = new AH_ProjectIntake_Schedule();
        
        // SCHEDULE APEX JOB
        system.schedule(strJobName, strCronTrig, objSchedClass); 
    }
    
    public pageReference goBack()
    {    
        
        PageReference pr;
        String strURL = System.URL.getSalesforceBaseURL().toExternalForm() + '/aEQ/o';
        
        if (ApexPages.currentPage().getParameters().get('retURL') != null)
        {
            pr = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
        }
        else
        {
            pr = new PageReference(strURL);
        }

        return pr;  
        
    }
    
    public void doRecalc()
    {        

        if (NI_FUNCTIONS.hasAccessByPublicGroup(UserInfo.getUserId(), 'Recalculate Priorities Users') || Test.isRunningTest())
        {
            recalcPriorityOnDemand();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Your request to recalculate priorites on project backlogs has been submitted successfully.'));
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.Label.Recalculate_Priorities_Button_Message));
        }

    }    
    
    public static void recalcPriorityOnDemand()      
    {

        // GET RECORD TYPE REFERENCES TO CUSTOM METADATA TYPE
        Set<Id> setRecTypeIds = new Set<Id>();
        for (AH_Recalculate_Priority_Record_Types__mdt cs : [SELECT Record_Type_Name__c FROM AH_Recalculate_Priority_Record_Types__mdt])
        {
            setRecTypeIds.add(Schema.SObjectType.NI_Project_Backlog__c.getRecordTypeInfosByName().get(cs.Record_Type_Name__c).getRecordTypeId());
        } 
        
        // GET VALID STATUSES FROM CUSTOM METADATA TYPE
        // ADDED PER NICC-048128
        Set<String> setStatuses = new Set<String>();
        for (AH_Recalculate_Priority_Status__mdt cmt : [SELECT Status__c FROM AH_Recalculate_Priority_Status__mdt])
        {
            setStatuses.add(cmt.Status__c);
        } 
        
        /*
        setStatuses.add('Backlog Item');
        setStatuses.add('Pending Scheduling'); //ADDED PER NICC-047197
        setStatuses.add('New');
        */
        
        // MAP OF PROJECT BACKLOG RECORDS WITH OVERRIDDEN PRIOIRTIES (Record Id, NI_Project_Backlog__c Record)
        Map<Id, NI_Project_Backlog__c> mapOverrides = new Map<Id, NI_Project_Backlog__c>();        

        // SET THAT STORES PROJECT BACKLOG RECORD IDs THAT HAVE BEEN EVALUATED TO EXCLUDE IN SUBSEQUENT EVALUATIONS
        Set<Id> setIds2Exclude = new Set<Id>();        
        
        // LIST OF WRAPPER CLASS OBJECT FOR RECALCULATIONS
        List<searchResult> lstSearchResults = new List<searchResult>();

        // QUERY VALID PROJECT BACKLOG RECORDS TO TARGET FOR PRIORITY RECALCULATIONS
        for (NI_Project_Backlog__c pb : [SELECT Id, Priority__c, Priority_Overriden__c, Estimated_Total_Net_Project_Value__c, RecordTypeId, Request_Status__c, CreatedDate, 
                                         Estimated_First_Year_Benefit__c, Estimated_Cost__c, Legal_Compliance__c, Required_for_Security_Compliance__c  
                                         FROM NI_Project_Backlog__c 
                                         WHERE RecordTypeId IN : setRecTypeIds
                                         AND Request_Status__c IN : setStatuses
                                         ORDER BY RecordType.Name ASC, Legal_Compliance__c DESC, Required_for_Security_Compliance__c DESC, Priority__c ASC])
        {
            
            // SET NON-NULL DEFAULT PRIORITY
            Decimal dPriority = 0;
            if (pb.Priority__c != null)
            {
                dPriority = pb.Priority__c;
            }
            
            // CREATE NEW INSTANCE OF WRAPPER CLASS OBJECT
            searchResult sr = new searchResult(
                pb.Id, 
                pb.RecordTypeId, 
                dPriority, 
                0, 
                pb.Estimated_Total_Net_Project_Value__c, 
                false, 
                pb.Request_Status__c, 
                pb.CreatedDate, 
                pb.Legal_Compliance__c, 
                pb.Required_for_Security_Compliance__c
            );
            
            // WHEN PROJECT BACKLOG PRIORITY FIELD HAS BEEN OVERRIDDEN
            if (pb.Priority_Overriden__c)
            {
                sr.bPriorityIsStatic = true;
                sr.dNewPriority = pb.Priority__c;  
                mapOverrides.put(pb.Id, pb);
                setIds2Exclude.add(pb.Id);
            }

            lstSearchResults.add(sr);
            
        }
        
        // MAP TO STORE INCREMENTAL PRIORITIES BY RECORD TYPE
        Map<Id, Decimal> mapRecType2Priority = new Map<Id, Decimal>();        
        for (Id rId : setRecTypeIds)
        {
            mapRecType2Priority.put(rId, 1);
        }
        
        // LIST THAT STORES FINAL SORTED LIST OF PRIORITIES
        List<searchResult> lstSearchResultsSorted = new List<searchResult>();

        // LOOP THROUGH ALL PROJECT BACKLOGS SORT EVALUATE AND ADD TO ORDERED LIST
        for (searchResult sr2 : lstSearchResults)
        {  
            // USE FUNCTION TO RETURN RECORD WITH NEXT GREATEST "Estimated Total Net Project Value" 
            searchResult srMax = getMaxPriorityRecord(lstSearchResults, setIds2Exclude, sr2.recordTypeId); 
            
            if (srMax != null)
            { 
                // LOOP THROUGH OVERRIDES MAP TO STUFF IN ORDER
                for (NI_Project_Backlog__c pbkl : mapOverrides.values())
                {
                    // IF RECORD TYPES MATCH AND PRIORTY MATCHES AN OVERRIDDEN ONE
                    if ((srMax.recordTypeId == pbkl.RecordTypeId) && (mapRecType2Priority.get(srMax.recordTypeId) == pbkl.Priority__c))
                    {
                        // LOOK FOR PROJECT BACKLOG WITH OVERRIDDEN PRIORITY
                        for (searchResult sr4 : lstSearchResults)
                        {
                            if (sr4.projectBacklogId == pbkl.Id)
                            {
                                // ADD TO ORDERED LIST
//                                lstSearchResultsSorted.add(sr4); // DOESN'T NEED TO BE UPDATED
                                // INCREMENT FOR NEXT
                                mapRecType2Priority.put(sr4.recordTypeId, (sr4.dOldPriority + 1));                          
                            }
                        }
                    }                      
                }
                
                // ASSIGN NEW PRIORITY
                srMax.dNewPriority = mapRecType2Priority.get(srMax.recordTypeId); 
                // INCREMENT FOR NEXT
                mapRecType2Priority.put(srMax.recordTypeId, (srMax.dNewPriority + 1)); 
                // ADD TO ORDERED LIST
                lstSearchResultsSorted.add(srMax); 
                // ADD TO EXCLUDE LIST TO TAKE OUT OF NEXT EVALUATIONS
                setIds2Exclude.add(srMax.projectBacklogId);
                
            }
        }
        
        // LIST THAT STORES PROJECT BACKLOG RECORDS FOR UPDATING
        List<NI_Project_Backlog__c> lstPBUpdates = new List<NI_Project_Backlog__c>();   
             
        // LOOP THROUGH AND ADD ORDERED LIST ITEMS TO FINAL UPDATE LIST
        for (searchResult sr3 : lstSearchResultsSorted)
        {
            NI_Project_Backlog__c pbl = new NI_Project_Backlog__c();
            pbl.Id = sr3.projectBacklogId;
            pbl.Priority__c = sr3.dNewPriority;
            lstPBUpdates.add(pbl);
        }

        // UPDATE PROJECT BACKLOG RECORD PRIORITY FIELDS
        if (!lstPBUpdates.isEmpty())
        {
        	Database.update(lstPBUpdates, false);    
        }   
        
    }
    
    public static searchResult getMaxPriorityRecord(List<searchResult> lst, Set<Id> setIdExcludes, Id RecTypeId)
    {
        
        searchResult retSR = null;
        boolean bIsFirstPass = true;
        boolean bIsCompliance = false;
        
        // LOOP THROUGH ALL PROJECT BACKLOG REFERENCES PASSED IN
        for (searchResult sr : lst)
        {            
            // IF RECORD HAS NOT BEEN EVALUATED YET
            if (!setIdExcludes.contains(sr.projectBacklogId))
            {
                // IF THE RECORD TYPE MATCHES THE RECORD TYPE PASSED IN
                if (sr.recordTypeId == RecTypeId)
                {
                    // LOAD FIRST RECORD FOR EVALUATION
                    if (bIsFirstPass)
                    {
                        retSR = sr;
                        bIsFirstPass = false;
                        // IF "Required for Legal Compliance" OR "Required for Security Compliance" IS CHECKED SET FLAG VARIABLE TO True
                        if (retSR.bIsLegalCompliance || retSR.bIsSecurityCompliance)
                        {
                            bIsCompliance = true;
                        }
                    }
                    else
                    {
                        
                        boolean bIsComplianceToo = false;
                        
                        if (sr.bIsLegalCompliance || sr.bIsSecurityCompliance)
                        {
                            bIsComplianceToo = true;
                        }
                        
                        if (!bIsCompliance)
                        {
                            // COMPARE ESTIMATED TOTAL NET PROJECT VALUES                      
                            if (sr.dEstimatedTotalNetProjectValue >= retSR.dEstimatedTotalNetProjectValue)
                            {                         
                                // IF VALUES MATCH THEN CHECK CREATED DATE
                                if (sr.dEstimatedTotalNetProjectValue == retSR.dEstimatedTotalNetProjectValue)
                                {                                  
                                    if (sr.dtCreatedDate <= retSR.dtCreatedDate)
                                    {  
                                        retSR = sr;
                                    }
                                    else
                                    {                                      
                                        // DO NOT ASSIGN
                                    }
                                }
                                else
                                {                              
                                    retSR = sr;
                                }
                            }
                            else
                            {
                                // DO NOT ASSIGN
                            }
                        }
                        else
                        {
                            if (bIsComplianceToo)
                            {
                                if (sr.dtCreatedDate <= retSR.dtCreatedDate)
                                {  
                                    retSR = sr;
                                }
                                else
                                {
                                    // DO NOT ASSIGN
                                }
                            }
                            else
                            {
                                // DO NOT ASSIGN
                            }
                        }
                    }                
                } 
            }
        }
        
        return retSR;
        
    }

    
    // ================================================================================================================================
	//  WRAPPER CLASSES ===============================================================================================================
    // ================================================================================================================================
    public class searchResult
    {    

        public Id projectBacklogId {get; set;}
        public Id recordTypeId {get; set;}
        public Decimal dOldPriority {get; set;}
        public Decimal dNewPriority {get; set;}
        public Decimal dEstimatedTotalNetProjectValue {get; set;}
        public Boolean bPriorityIsStatic {get; set;}
		public String strStatus {get; set;} 
        public DateTime dtCreatedDate {get; set;} 
        public Boolean bIsLegalCompliance {get; set;} 
        public Boolean bIsSecurityCompliance {get; set;} 
        
        public searchResult (Id p1, Id p2, Decimal p3, Decimal p4, Decimal p5, Boolean p6, String p7, DateTime p8, Boolean p9, Boolean p10)
        {
            this.projectBacklogId = p1; 
            this.recordTypeId = p2;
            this.dOldPriority = p3; 
            this.dNewPriority = p4; 
            this.dEstimatedTotalNetProjectValue = p5; 
			this.bPriorityIsStatic = p6;  
            this.strStatus = p7;
            this.dtCreatedDate = p8;
            this.bIsLegalCompliance = p9;
            this.bIsSecurityCompliance = p10;
        }
        
    }       
    
  
}