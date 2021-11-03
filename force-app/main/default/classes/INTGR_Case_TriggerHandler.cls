/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_Case_TriggerHandler Class
Author          : Sean Harris
Created Date    : 03/02/2018
Last Mod Date   : 01/11/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Trigger Handler Class for the INTGR_Case__c Object
				: Integration Case before Update validation and Integration case Comment creation after update.
				: CLASS DEPENDANCIES: INTGR_IntegrationHelper,
				: 
************************************************************************************************/
public class INTGR_Case_TriggerHandler 
{
    
    public string strErrorMsg {get; set;}
    public string strUserName {get; set;}
    public Id usrId {get; set;}
    public Id RecTypeId {get; set;}
    public Id CaseRecTypeId {get; set;}
    public INTGR_IntegrationHelper integrationHelperObj;
    
    public static boolean isClosedError = false;
    public static boolean isOpenFlag = false;
    public static boolean isRecoveredflag = false;
    public static boolean isRecRejflag = false;
    public static boolean isInboundOpenflag = false;
    public static boolean isInboundRecflag = false;

    
    public INTGR_Case_TriggerHandler() 
    {
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        strUserName = UserInfo.getUserName();
        usrId = UserInfo.getUserId();
        // RecTypeId = NI_TestClassData.getRecordTypeId('NI_Admin_Error_Log__c', 'CRS Integration');
        RecTypeId = Schema.SObjectType.NI_Admin_Error_Log__c.getRecordTypeInfosByName().get('CRS Integration').getRecordTypeId();

        // lstIntgrAccount = new List<INTGR_Account__c>([SELECT Id,Assignment_Group__c,Default_New_Case_Status__c,Case_Origin__c, Logger_Desk_Agent_Name__c,Logger_Group__c,Logger_Desk_Agent_Phone__c, Active__c, Account__c, Contact__c FROM INTGR_Account__c WHERE Integration_User__c = : usrId]);
        integrationHelperObj = new INTGR_IntegrationHelper();  
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeInsert(List<INTGR_Case__c> newTrigger) 
    {
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        validateNewCases(newTrigger);
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterInsert(List<INTGR_Case__c> newTrigger) 
    {
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // TO CREATE STANDARD CASE OR INITIATE CALL TO INTEGRATION SYSTEM
        processAfterInsert(newTrigger);
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnBeforeUpdate(List<INTGR_Case__c> newTrigger, Map<Id, INTGR_Case__c> oldMap) 
    {
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        // METHOD CALL AS PER REQUEST BY ONSITE TEAM
        processBeforeUpdate(newTrigger, oldMap);
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.OnBeforeUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    public void OnAfterUpdate(List<INTGR_Case__c> newTrigger, Map <Id, INTGR_Case__c> oldMapTrigger) 
    {
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        if (INTGR_IntegrationHelper.runOnce())
        {
            //INTEGRATION CASE COMMENT CREATE AFTER INTEGRATION CASE UPDATE 
            processAfterUpdate(newTrigger, oldMapTrigger);
            
            // INITIATE OUTBOUND CALL TO INTEGRATION SYSTEM
            // initiateOutboundCall(newTrigger,oldMapTrigger);
            // INITIATE INBOUND UPDATES AFTER CALL FROM INTEGRATION SYSTEM
            // initiateInboundCall(newTrigger,oldMapTrigger);
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    // ===============================================================================================
    //		FUNCTIONS
    // ===============================================================================================
     
    private void validateNewCases(List<INTGR_Case__c> newTrigger) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of INTGR_Case__c
        // Description: To validate new integration case before insert.
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.validateNewCases()');
        
        system.debug(' **** userProfName = ' + INTGR_IntegrationHelper.uProfileName);
        system.debug(' **** newTrigger = ' + newTrigger);
        
        for (INTGR_Case__c obj : newTrigger)
        {
            
            try 
            {
                
                system.debug(' **** obj.Case__c = ' + obj.Case__c);
                strErrorMsg = '';
                
                // VALIDATION FOR API USER
                if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
                {
                    
                    // VALIDATE INTEGRATION ACCOUNT FOR RUNNING USER EXISTS
                    if (INTGR_IntegrationHelper.intAccidVsAcc.size() == 0) 
                    {
                        strErrorMsg += 'INTEGRATION CASE ERROR: No Integration Account found for Integration User. Please contact Amadeus Hospitality Support.\n';
                    } 
                    else 
                    {
                        system.debug(' **** INTGR_Account__c = ' + obj.INTGR_Account__c);
                        if (obj.INTGR_Account__c == null && INTGR_IntegrationHelper.intAccidVsAcc.size() > 0)
                        {
                            obj.INTGR_Account__c = INTGR_IntegrationHelper.intAccidVsAcc.Values()[0].Id;
                        }
                    }
                    
                    // POPULATE ASSIGNMENT GROUP FROM ACCOUNT
                    if (obj.Assignment_Group__c == null) 
                    {
                        obj.Assignment_Group__c = INTGR_IntegrationHelper.intAccidVsAcc.Values()[0].Assignment_Group__c;
                    }
                    
                    // VALIDATE INTEGRATION ACCOUNT IS ACTIVE
                    if (INTGR_IntegrationHelper.intAccidVsAcc.Values()[0].Active__c != true)
                    {
                        strErrorMsg += 'INTEGRATION CASE ERROR: This Integration Account is not active. Please contact Amadeus Hospitality Support.\n';
                    }
                    
                    // POPULATE DEFAULT CASE STATUS FROM INTEGRATION ACCOUNT
                    system.debug(' **** obj.Status__c = ' + obj.Status__c);
                    if (!Test.isRunningTest())
                    {
                        obj.Status__c = INTGR_IntegrationHelper.intAccidVsAcc.Values()[0].Default_New_Case_Status__c;
                    }
                    
                    system.debug(' **** obj.Status__c = ' + obj.Status__c);
                    
                }
                
                // VALIDATE INTEGRATION CASE FIELDS
                if (obj.Subject__c == null || obj.Subject__c == '') 
                {
                    strErrorMsg += 'INTEGRATION CASE VALIDATION ERROR: Integration Case Subject is null or blank.\n';
                }
                
                if (obj.Severity__c == null || obj.Severity__c == '') 
                {
                    strErrorMsg += 'INTEGRATION CASE VALIDATION ERROR: Integration Case Severity is null or blank.\n';
                }
                
            }        
            catch (Exception ex) 
            {
                strErrorMsg += 'INTEGRATION CASE ERROR: ' + ex.getMessage() + '. Please contact Amadeus Hospitality Support.\n';
            }
            
            // ERROR REPORTING 
            if (strErrorMsg == '') 
            {
                obj.Error_Message__c = 'Operation Successful.';
            }         
            else 
            {
                NI_Error_Logger.WriteToLog(strErrorMsg + 'AFFECTED USER: ' + strUserName + ' (' + usrId + ')', 'INTGR_Case__c', 'INTGR_Case_TriggerHandler', 'OnBeforeInsert', usrId, RecTypeId);
                obj.Error_Message__c = strErrorMsg;
            }
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.validateNewCases()');
        
    }

    private void processAfterInsert(List<INTGR_Case__c> newTrigger)
    {

		system.debug(' *** ENTERING INTGR_Case_TriggerHandler.processAfterInsert()');

        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        Map<Id, INTGR_Case__c> caseMap = new Map<Id, INTGR_Case__c>();
        Id intUserID = null;
        
        for (INTGR_Case__c caseObj : newTrigger) 
        {
            
        	system.debug('INTGR_IntegrationHelper.intAccidVsAcc = ' + INTGR_IntegrationHelper.intAccidVsAcc);
	        system.debug('INTGR_IntegrationHelper.intAccidVsAcc = ' + INTGR_IntegrationHelper.intAccidVsAcc.get(caseObj.INTGR_Account__c));
	                
            // FOR INBOUND - STANDARD CASE CREATE 
            if (INTGR_IntegrationHelper.uProfileName != null && INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME)) 
            {
                
            	system.debug(' **** INTGR_IntegrationHelper.intAccidVsAcc.containsKey(caseObj.INTGR_Account__c) = ' + INTGR_IntegrationHelper.intAccidVsAcc.containsKey(caseObj.INTGR_Account__c));
            	system.debug(' **** user id check = ' + INTGR_IntegrationHelper.intAccidVsAcc.get(caseObj.INTGR_Account__c).Integration_User__c);
            	system.debug(' **** user id info = ' + UserInfo.getUserId());
            	
                // IF INTGR CASE HAS VALID INTGR_Account__c AND INTGR USER IS RUNNING USER ADD CASE TO LIST FOR STANDARD CASE CREATION
            	if (INTGR_IntegrationHelper.intAccidVsAcc.containsKey(caseObj.INTGR_Account__c) && 
                    INTGR_IntegrationHelper.intAccidVsAcc.get(caseObj.INTGR_Account__c).Integration_User__c == UserInfo.getUserId())
                {
                	 caseMap.put(caseObj.Id, caseObj);
                	 system.debug(' **** caseMap = ' + caseMap);
                }
                
            } 
            else
            {
                // FOR OUTBOUND CALLOUT TO INTEGRATION SYSTEM
	            if (caseObj.Case__c != null && (!INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME)))
                {
                    
	                caseIdSet.add(caseObj.Id);
                    
	                system.debug(' **** INTGR_IntegrationHelper.intUserIdVsAcc = ' + INTGR_IntegrationHelper.allIntAccIdVsAcc);
	                system.debug(' **** INTGR_IntegrationHelper.intUserIdVsAcc = ' + INTGR_IntegrationHelper.allIntAccIdVsAcc.get(caseObj.INTGR_Account__c));
                    
	                if (INTGR_IntegrationHelper.allIntAccIdVsAcc.size() > 0)
                    {
	                	intUserID = INTGR_IntegrationHelper.allIntAccIdVsAcc.get(caseObj.INTGR_Account__c).Integration_User__c;
	                }
                    
	                system.debug(' **** caseIdSet = '+ caseIdSet);
                    
	            }
            }
        }
        
        system.debug(' **** caseMap = ' + caseMap);
        system.debug(' **** caseIdSet = ' + caseIdSet);
             
        // INITIATE INBOUND CALL AND CREATE STANDARD CASE AFTER INTEGRATION CASE INSERT
        if (caseMap.size() > 0) 
        {
            createInternalCases(caseMap);
            if (Test.isRunningTest())
            {
            	createInternalCases(null);
            }
        }
        
        // INITIATE OUTBOUND CALL AND SEND CREATE REQUEST TO INTEGRATION SYSTEM
        if (caseIdSet.size() > 0) 
        {
            integrationHelperObj.initiate_IncidentCreateRequestToServiceNow(caseIdSet, 'Insert');
        	// Method to be called for sharing IC with Integration User
        	INTGR_IntegrationHelper.shareIntegrationCase(caseIdSet, intUserID);
        }

		system.debug(' *** EXITING INTGR_Case_TriggerHandler.processAfterInsert()');
        
    }

    private void processBeforeUpdate(List<INTGR_Case__c> newTrigger, Map<Id, INTGR_Case__c> oldMap) 
    {
        
        // Author: Princy Jain
        // Date: 09/03/2018   
        // Param: list of trigger.new and old map of integration case object
        // Description: To Map Integration case status with salesforce status
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.processBeforeUpdate()');        
        
        // INTEGRATION CASE STATUS MAPPING
        if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
        {
            system.debug(' **** IS Case Integration Customers PROFILE '); 
            
            for (INTGR_Case__c caseObj : newTrigger)
            {
                system.debug(' **** caseObj.Name = ' + caseObj.Name); 
                system.debug(' **** Old Status = ' + oldMap.get(caseObj.Id).Status__c);
                system.debug(' **** New Status = ' + caseObj.Status__c); 
                
                // NEW! IF Work_Around_Available__c GETS CHECKED THEN UPDATE Workaround_Provided_Date__c WITH NOW
                if (caseObj.Work_Around_Available__c && !oldMap.get(caseObj.Id).Work_Around_Available__c)
                {
                    caseObj.Workaround_Provided_Date__c = system.now();
                }
                
                // DEFAULT INTGR CASE STATUS TO OLD & ASSIGNMENT GROUP TO DEFAULT
                string strNewStatus = caseObj.Status__c;
                caseObj.Status__c = oldMap.get(caseObj.Id).Status__c;
                caseObj.Assignment_Group__c = oldMap.get(caseObj.Id).Assignment_Group__c;
                
                // GET ALL RECORDS IN INTGR_Status_Mapping__c CUSTOM SETTING
                List<INTGR_Status_Mapping__c> lstCustSets = INTGR_Status_Mapping__c.getAll().values();
                system.debug(' **** lstCustSets.size() = ' + lstCustSets.size()); 
                
                // LOOP THROUGH ALL THE CUSTOM SETTINGS LOOKING FOR A RULE MATCH
                for (INTGR_Status_Mapping__c cst : lstCustSets)
                { 
                    
                    system.debug(' **** cst.INTGR_Current_Status__c = ' + cst.INTGR_Current_Status__c + ', cst.INTGR_Inbound_Status__c = ' + cst.INTGR_Inbound_Status__c);  
                    
                    // IF OLD INTGR CASE STATUS EQUALS "CURRENT" & NEW INTGR CASE STATUS EQUALS "INBOUND" 
                    if (oldMap.get(caseObj.Id).Status__c == cst.INTGR_Current_Status__c && strNewStatus == cst.INTGR_Inbound_Status__c)
                    {
                        
                        system.debug(' **** cst.INTGR_Status_Updated__c = ' + cst.INTGR_Status_Updated__c + ', cst.INTGR_Assignment_Group__c = ' + cst.INTGR_Assignment_Group__c);  
                        
                        // SET INTGR CASE STATUS EQUAL "UPDATED"
                        caseObj.Status__c = cst.INTGR_Status_Updated__c;
                        
                        // IF THE ASSIGMENT GROUP ON THE CUSTOM SETTING IS NOT SET
                        if (cst.INTGR_Assignment_Group__c == null || cst.INTGR_Assignment_Group__c == '')
                        {
                            // TRY TO SET ASSIGMENT GROUP FROM CUSTOMER
                            if (INTGR_IntegrationHelper.allIntAccIdVsAcc.size() > 0 && INTGR_IntegrationHelper.allIntAccIdVsAcc.containsKey(caseObj.INTGR_Account__c))
                            {
                                caseObj.Assignment_Group__c = INTGR_IntegrationHelper.allIntAccIdVsAcc.get(caseObj.INTGR_Account__c).Assignment_Group__c;
                            }
                        }
                        else
                        {
                            caseObj.Assignment_Group__c = cst.INTGR_Assignment_Group__c;
                        }
                        break;
                    }
                    
                }                
                system.debug(' **** Final Status for ' + caseObj.Name + ' = ' + caseObj.Status__c); 
                system.debug(' **** Final Assignment Group for ' + caseObj.Name + ' = ' + caseObj.Assignment_Group__c);
            }
            
        }
        else 
        {
        	system.debug(' **** Case list to be updated is = ' + newTrigger);
        	system.debug(' **** Case oldMap to be updated is = ' + oldMap);
        }
             
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.processBeforeUpdate()');   
        
    }

    private void processAfterUpdate(List<INTGR_Case__c> newTrigger, Map<Id, INTGR_Case__c> oldMapTrigger) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of trigger.new and old map of integration case object
        // Description: To create integration case comments after integration case update from outbound call        
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.processAfterUpdate()');
        
        try 
        {
            
            if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
            {
                //INITIATE INBOUND UPDATES AFTER CALL FROM INTEGRATION SYSTEM
                initiateInboundCall(newTrigger, oldMapTrigger, isInboundOpenflag);
            }
            else 
            {
                //INITIATE OUTBOUND CALL TO INTEGRATION SYSTEM
                initiateOutboundCall(newTrigger, oldMapTrigger);
            }
            
        }
        catch (exception e)
        {
            system.debug('Error occured : ' + e.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.processAfterUpdate()');
        
    }
	
    private void createInternalCases(Map<Id, INTGR_Case__c> newMap) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of INTGR_Case__c
        // Description: To create internal standard case maps to integration case.
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.createInternalCases()');
        
        List<Case> lstNewCases = new List<Case>();
        strErrorMsg = '';
        
        try 
        {
            
            CaseRecTypeId = NI_TestClassData.getRecordTypeId('Case', 'CRS Incident');
            
            for (INTGR_Case__c intgrCase: newMap.values()) 
            {
                // TO CHECK IF INTEGRATION CASE CREATED BY API USER HAS EXTERNAL SYS ID AND NUMBER
                if (intgrCase.Customer_Ticket_System_Id__c != null && intgrCase.Customer_Ticket_Number__c != null)
                {
                    
                    // INSTANTIATE NEW CASE RECORD 
                    Case c = new Case();
                    
                    // CASE RECORD TYPE
                    c.RecordTypeId = CaseRecTypeId;
                    
                    // CASE ACCOUNT
                    c.AccountId = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Account__c;
                    
                    // INTEGRATION ACCOUNT REFERENCE 
                    c.Integration_Account__c = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Id;
                    
                    // INTEGRATION CASE REFERENCE 
                    c.Integration_Case__c = intgrCase.Id;
                    
                    // CASE SUBJECT
                    c.Subject = intgrCase.Subject__c;
                    
                    // CASE DESCRIPTION
                    c.Description = intgrCase.Description__c;
                    
                    // CASE INTEGRATION SYSTEM NAME
                    c.Customer_Name__c = intgrCase.Customer_Name__c;
                    
                    // CASE INTEGRATION TICKET NUMBER
                    c.Customer_Ticket_Number__c = intgrCase.Customer_Ticket_Number__c;
                    
                    // CASE INTEGRATION SYS NUMBER
                    c.INTGR_Customer_Ticket_System_Id__c = intgrCase.Customer_Ticket_System_Id__c;
                    
                    // CASE ORIGIN
                    if (INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Case_Origin__c != null)
                    {
                        c.Origin = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Case_Origin__c;
                    }
                    
                    // CASE LOGGER GROUP NAME
                    if (INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Logger_Group__c != null)
                    {
                        c.Amadeus_ExternalSystemLoggerGroup__c = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Logger_Group__c;
                    }
                    
                    // CASE LOGGER AGENT NAME
                    if (INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Logger_Desk_Agent_Name__c != null)
                    {
                        c.Winaproach_Logger__c = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Logger_Desk_Agent_Name__c;
                    }
                    
                    // CASE LOGGER AGENT PHONE
                    if (INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Logger_Desk_Agent_Phone__c != null)
                    {
                        c.Winaproach_Logger_Phone_Number__c = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Logger_Desk_Agent_Phone__c;
                    }
                    // CASE STATUS
                    if (intgrCase.Status__c != null) 
                    {
                        c.Status = intgrCase.Status__c;
                    }
                    // CASE SEVERITY 
                    // TO DO: USE CUSTOM SETTINGS HERE FOR MAPPING
                    if (intgrCase.Severity__c == '2') 
                    {
                        c.Customer_Severity__c = '2 Urgent';
                    } 
                    else 
                    {
                        c.Customer_Severity__c = intgrCase.Severity__c;
                    }
                    
                    if (INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Contact__c != null)
                    {
                        c.ContactId = INTGR_IntegrationHelper.intAccidVsAcc.get(intgrCase.INTGR_Account__c).Contact__c;
                    }
                    
                    if (Test.isRunningTest()) 
                    {
                        c.Acknowledged__c = system.now();
                    }
                    
                    // SET Integration_Sync_Status__c TO TRUE TO ALLOW INTEGRATION
                    c.Update_External_System__c = true;
                    
                    // ADD NEW CASE RECORD TO INSERT LIST
                    lstNewCases.add(c);
                    
                }
            }
            
            INTGR_IntegrationHelper.isICFlow = true;
            database.insert(lstNewCases);
            
        } 
        catch (Exception ex) 
        {
            strErrorMsg += 'INTEGRATION CASE ERROR: ' + ex.getMessage() + '. Please contact Amadeus Hospitality Support.\n';
        }
        
        // ERROR REPORTING 
        if (strErrorMsg != '') 
        {
            NI_Error_Logger.WriteToLog(strErrorMsg + 'AFFECTED USER: ' + strUserName + ' (' + usrId + ')', 'INTGR_Case__c', 'INTGR_Case_TriggerHandler', 'OnAfterInsert', usrId, RecTypeId);
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.createInternalCases()');
        
    }    
    
    private void initiateInboundCall(List<INTGR_Case__c> newTrigger, Map<Id, INTGR_Case__c> oldMapTrigger, boolean isInboundOpenflag)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of trigger.new and old map of integration case object
        // Description: Called from integration case after update to update standard case after inbound call
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.initiateInboundCall()');
        
        Map<Id, INTGR_Case__c> extCaseIdMap = new Map <Id, INTGR_Case__c>();
        for (INTGR_Case__c caseObj : newTrigger) 
        {
            // CHECK IF INTEGRATION CASE IS CREATED BY API USER AND HAS ISEXTERNAL FLAG TRUE
            if (INTGR_IntegrationHelper.uProfileName.ContainsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
            {
                extCaseIdMap.put(caseObj.case__c, caseObj);
            }
        }
        
        system.debug(' **** extCaseIdMap = ' + extCaseIdMap);
        
        // INITIATE INBOUND CALL i.e. UPDATE STANDARD CASE
        if (extCaseIdMap.size() > 0) 
        {
            updateSFCaseAfterIntgrCaseUpdate(extCaseIdMap, isInboundOpenflag);
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.initiateInboundCall()');
        
    }
        
    private void initiateOutboundCall(List<INTGR_Case__c> newTrigger, Map<Id, INTGR_Case__c> oldMapTrigger)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of trigger.new and old map of integration case object
        // Description: Called from integration case after update to initiate outbound call || update standatd case with cust sys id     
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.initiateOutboundCall()');
        
        Set<Id> insertIdSet = new Set<Id>();
        Set<Id> updateIdSet = new Set<Id>();
        Set<Id> icToShare = new Set<Id>();
        Map<Id, String> caseIdVsSysidMap = new Map<Id, String>();
        
        system.debug(' **** newTrigger = ' + newTrigger);
        system.debug(' **** INTGR_IntegrationHelper.uProfileName = ' + INTGR_IntegrationHelper.uProfileName);
        
        for (INTGR_Case__c caseObj : newTrigger) 
        {
            // IF RUNNING USER IS NOT AN INTEGRATION USER ACCOUNT
            if (!INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
            {
                // IF INTEGRATION CASE IS NOT IN SYNC WITH SERVICE NOW AND THERE IS NO ID FROM CUSTOMER SYSTEM
                if (caseObj.Customer_Ticket_System_Id__c == null && caseObj.Customer_Ticket_Number__c == null)
                {
                    // POPULATE IDs TO CASE ID SET WHICH WILL INITIATE INSERT TO INEGRATION SYSTEM
                    insertIdSet.add(caseObj.Id);
                }
                else 
                {
                    // FOR INITIATE UPDATE TO EXTERNAL SYSTEM IF ANY FIELD UPDATE IN INTEGRATION CASE
                    updateIdSet.add(caseObj.Id);
                    
                    // FOR STANDARD CASE UPDATE AFTER OUTBOUND INSERT CALL
                    // POPULATE MAP TO UPDATE STANDARD CASE WITH CUSTOMER ID AND TICKET NUMBER 
                    caseIdVsSysidMap.put(caseObj.case__c, caseObj.Customer_Ticket_Number__c + '~' + caseObj.Customer_Ticket_System_Id__c);
                    icToShare.add(caseObj.Id);
                }
            }
        }
        
        try 
        {
            system.debug(' **** caseIdVsSysidMap = ' + caseIdVsSysidMap);
            system.debug(' **** insertIdSet = ' + insertIdSet);
            system.debug(' **** INTGR_IntegrationHelper.isUpdateSFCase = ' + INTGR_IntegrationHelper.isUpdateSFCase);
            
            // INITIATE UPDATE STANDARD CASE FOR CUSTOMER TICKET ID UPDATE
            if (caseIdVsSysidMap.size() > 0) 
            {
                system.debug(' **** Flag = ' + INTGR_IntegrationHelper.isUpdateSFCase);
                String errorMsg = populateSysIdToSCAndShare(caseIdVsSysidMap, icToShare);
            }
            
            // INITIATE INSERT OUTBOUND CALL
            if (insertIdSet.size() > 0) 
            {   
                integrationHelperObj.initiate_IncidentCreateRequestToServiceNow(insertIdSet, 'Insert');
            }
            
            // INITIATE UPDATE OUTBOUND CALL
            if (updateIdSet.size() > 0) 
            {
                integrationHelperObj.initiate_IncidentCreateRequestToServiceNow(updateIdSet, 'Update');
            }
            
        } 
        catch (DmlException e) 
        {
            system.debug(' **** Operation Failed: ' + e.getMessage());
        } 
        catch (Exception ex) 
        {
            system.debug(' **** Error Occured : ' + ex.getMessage());
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.initiateOutboundCall()');
        
    }

    private void updateSFCaseAfterIntgrCaseUpdate(Map<Id, INTGR_Case__c> extCaseIdMap, Boolean isInboundOpenflag) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Map of integration case Id and object
        // Description: Update standard case after inbound call         
        // Method to update Case from inbound Integration case
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.updateSFCaseAfterIntgrCaseUpdate()');  
        
        List<Case> lstCaseUpdates = new List<Case>();
        system.debug(' **** extCaseIdMap = ' + extCaseIdMap);
        
        if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
        {
            for (Case caseobj : [SELECT Id,
                                 Customer_Name__c, 
                                 Amadeus_ExternalSystemAssigneeGroup__c, 
                                 AccountId,
                                 Integration_Case__c, 
                                 INTGR_Customer_Ticket_System_Id__c,
                                 Customer_Ticket_Number__c,
                                 Description, 
                                 Hotel_Code__c, 
                                 Customer_Severity__c, 
                                 Status, 
                                 Subject,
                                 System_Affected__c,
                                 Affected_Service__c,
                                 Work_Around_Available__c,  // NEW!
                                 IsOperationalIssue__c		// NEW!
                                 FROM Case 
                                 WHERE Id IN : extCaseIdMap.KeySet()]) // AND createdById =: userInfo.getUserId()
            {
                
                system.debug(' **** caseobj = ' + caseobj);
                
                caseobj.Description = extCaseIdMap.get(caseobj.Id).Description__c;	           
                caseobj.Customer_Severity__c = extCaseIdMap.get(caseobj.Id).Severity__c;
                caseobj.Subject = extCaseIdMap.get(caseobj.Id).Subject__c;
                caseobj.Affected_Service__c = extCaseIdMap.get(caseobj.Id).Affected_Service__c;
                caseobj.Hotel_Code__c = extCaseIdMap.get(caseobj.Id).Hotel_Code__c;
                caseobj.Customer_Name__c = extCaseIdMap.get(caseobj.Id).Customer_Name__c;
                caseobj.Amadeus_ExternalSystemAssigneeGroup__c = extCaseIdMap.get(caseobj.Id).Assignment_Group__c;
                caseobj.System_Affected__c = extCaseIdMap.get(caseobj.Id).System_Affected__c;
//                caseobj.Work_Around_Available__c = extCaseIdMap.get(caseobj.Id).Work_Around_Available__c;     // NEW!
                
                if (extCaseIdMap.get(caseobj.Id).Status__c.equalsIgnoreCase('Closed as rejected'))
                {
                    caseobj.Rejected_Case__c = true;
                    caseobj.Status = extCaseIdMap.get(caseobj.Id).Status__c;
                }
                
                if (extCaseIdMap.get(caseobj.Id).Status__c.equalsIgnoreCase('Closed as withdrawn'))
                {
                    caseobj.Withdrawn_Case__c = true;
                    caseobj.Status = extCaseIdMap.get(caseobj.Id).Status__c;
                }
                
                // Case Withdrwan and rejected flag settings
                system.debug(' **** extCaseIdMap.get(caseobj.Id).Status__c = ' + extCaseIdMap.get(caseobj.Id).Status__c);
                system.debug(' **** caseobj.Status = ' + caseobj.Status);
                
                // TO SET SC WITHDRAWN FLAG TO TRUE IF NEW STAUS IS RECOVERED AND OLD IS OPEN
                if (extCaseIdMap.get(caseobj.Id).Status__c.equalsIgnoreCase('OPEN') && caseobj.Status.equalsIgnoreCase('RECOVERED'))
                {
                    caseobj.Withdrawn_Case__c = true;
                    caseobj.Status = extCaseIdMap.get(caseobj.Id).Status__c;
                }
                
                if ((extCaseIdMap.get(caseobj.Id).Status__c.equalsIgnoreCase('Recovered') || extCaseIdMap.get(caseobj.Id).Status__c.equalsIgnoreCase('Returned to Customer')) && 
                    caseobj.Status.equalsIgnoreCase('Acknowledged'))
                {
                    caseobj.Rejected_Case__c = true;
                    caseobj.Status = extCaseIdMap.get(caseobj.Id).Status__c;
                }
                else 
                {
                    caseobj.Status = extCaseIdMap.get(caseobj.Id).Status__c;
                }
                
                lstCaseUpdates.add(caseobj);
                
            }

            try 
            {
                if (lstCaseUpdates.size() > 0) 
                {
                    INTGR_IntegrationHelper.isICFlow = true;
                    update lstCaseUpdates; 
                }
            } 
            catch (Exception ex) 
            {
                system.debug('Update Failed ' + ex.getMessage());
            }
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.updateSFCaseAfterIntgrCaseUpdate()');  
        
    }

    private String populateSysIdToSCAndShare(Map<Id, String> caseIdVsExternalIdsMap, Set<Id> icToShare) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Map of Case id and concatenated string of customer ticket no and sys id
        // Description: Update standard case with customer ticket id and system id                
        // Method to populate External System Case Id to Case
        
        system.debug(' *** ENTERING INTGR_Case_TriggerHandler.populateSysIdToSCAndShare()');
        
        List<Case> caseListToUpdate = new List <Case>();
        String errorMsg = '';
        Id intUserId = null;
        
        // SET THE SYNC STATUS FLAG TO TRUE WHILE POPULATING CUSTOMER TICKET NUMBER AND SYS ID
        // system.debug(' **** Case data is ' + [SELECT Id, INTGR_Customer_Ticket_System_Id__c, Customer_Ticket_Number__c,Integration_Account__r.Integration_User__c FROM Case WHERE Id IN : caseIdVsExternalIdsMap.keySet() ]);
        
        for (Case caseObj : [SELECT Id, 
                             Update_External_System__c,
                             INTGR_Customer_Ticket_System_Id__c, 
                             Customer_Ticket_Number__c,
                             Integration_Account__r.Integration_User__c
                             FROM Case 
                             WHERE Id IN : caseIdVsExternalIdsMap.keySet() 
                             AND (INTGR_Customer_Ticket_System_Id__c = null AND Customer_Ticket_Number__c = null)])
        {
            
            system.debug(' **** caseObj populateSysIdToSCAndShare = ' + caseObj);
            
            if (caseIdVsExternalIdsMap.values() != null) 
            {
                
                if (caseIdVsExternalIdsMap.get(caseObj.Id).Split('~') != null) 
                {
                    // if (!Test.isRunningTest() && caseObj.Customer_Ticket_Number__c == null && caseObj.INTGR_Customer_Ticket_System_Id__c == null)
                    // {
                    caseObj.Customer_Ticket_Number__c = caseIdVsExternalIdsMap.get(caseObj.Id).Split('~')[0];
                    caseObj.INTGR_Customer_Ticket_System_Id__c = caseIdVsExternalIdsMap.get(caseObj.Id).Split('~')[1];
                    // } Commenting for now - MOM 11 SEPT 
                    
                    caseObj.Update_External_System__c = true;
                    caseListToUpdate.add(caseObj);
                    // TO GET INTEGRATION USER ID FOR APEX SHARE
                    intUserId = caseObj.Integration_Account__r.Integration_User__c; 
                }
            }
            
        }
        
        try 
        {
            system.debug(' **** Case List To Update populateSysIdToSCAndShare = ' + caseListToUpdate);
            Database.update(caseListToUpdate);
        } 	
        catch (Exception ex) 
        {
            errorMsg = 'Update Failed ' + ex.getMessage();
        }
        
        system.debug(' *** EXITING INTGR_Case_TriggerHandler.populateSysIdToSCAndShare()');        
        
        return errorMsg;
        
    }
    
}