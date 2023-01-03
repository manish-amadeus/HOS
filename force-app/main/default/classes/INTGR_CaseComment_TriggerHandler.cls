/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_CaseComment_TriggerHandler Class
Author          : Princy Jain
Created Date    : 06/06/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Trigger Handler Class for the INTGR_Case_Comment__c Object
				: Updated logic for external flag and integration user
				: 
************************************************************************************************/
public class INTGR_CaseComment_TriggerHandler
{
    
    public INTGR_IntegrationHelper integrationHelperObj;

    
    public INTGR_CaseComment_TriggerHandler() 
    {
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
        integrationHelperObj = new INTGR_IntegrationHelper();
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler CONSTRUCTOR - QUERIES ISSUED = ' + Limits.getQueries());
        
    }    
    
    public void OnBeforeInsert(List<INTGR_Case_Comment__c> newTrigger)
    {
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    	populateCreatedDate(newTrigger);
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.OnBeforeInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }

    public void OnAfterInsert(List<INTGR_Case_Comment__c> newTrigger) 
    {
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        processAfterCaseCommInsert (newTrigger);
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.OnAfterInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
    public void OnAfterUpdate(List<INTGR_Case_Comment__c> newTrigger) 
    {
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        processAfterCaseCommUpdate (newTrigger);
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.OnAfterUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }


	// ===================================================================================================================
	// 	FUNCTIONS 
    // ===================================================================================================================

    private void populateCreatedDate(List<INTGR_Case_Comment__c> newTrigger)
    {
        
        // To populate comment date on integration case comments
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.populateCreatedDate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    	for (INTGR_Case_Comment__c caseComm : newTrigger)
        {
    		if (caseComm.CreateDate__c == null)
            {
    			caseComm.CreateDate__c = system.now();
    		}
    	}
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.populateCreatedDate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
   	
    private void processAfterCaseCommInsert(List<INTGR_Case_Comment__c> newTrigger)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of trigger.new and old map of integration case object
        // Return: NA
        // Description: Called from integration case comment after insert for a) initiate inbound or b) initiate outbound calls
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.processAfterCaseCommInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> integrationAccIdSet = new Set<Id>();
        Set<Id> intgrCaseCommIdSet = new Set<Id>();
        Set<Id> intCaseIdSet = new Set<Id>();
        List<INTGR_Case_Comment__c> caseCommList = new List<INTGR_Case_Comment__c>();
        
       	system.debug(' **** userProfName = ' + INTGR_IntegrationHelper.uProfileName);
        
        for (INTGR_Case_Comment__c caseComment : newTrigger) 
        {

            string strCommBody = '';
            
            if (caseComment.CommentBody__c != null)
            {
                strCommBody = caseComment.CommentBody__c;
            }
            
            // CHECK IF INBOUND CASE COMMENT
            if (INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME))
            {
                
                system.debug(' **** Inside Integration user check. caseComment.CommentBody__c = ' + caseComment.CommentBody__c);
                system.debug(' **** Label.Prior_case_closure_comment = ' + Label.Prior_case_closure_comment);
            	system.debug(' **** Label.Integration_Case_Closure_Comment = ' + Label.Integration_Case_Closure_Comment);
            	system.debug(' **** INTGR_IntegrationHelper.isCCFromSC = ' + INTGR_IntegrationHelper.isCCFromSC);
            	
                if (INTGR_IntegrationHelper.isCCFromSC || 
                    strCommBody.equalsIgnoreCase(Label.Prior_case_closure_comment) || 
                    strCommBody.equalsIgnoreCase(Label.Integration_Case_Closure_Comment))
                {
            		intgrCaseCommIdSet.add(caseComment.Id);	
            	}
            	else 
                {
                    
            		system.debug(' **** INTGR_IntegrationHelper.isCCFromSC = ' + INTGR_IntegrationHelper.isCCFromSC);
                    
            		if (!INTGR_IntegrationHelper.isCCFromSC)
                    {
            			system.debug(' **** Inside Inbound Calling for INT CASE COMM');
            			caseCommList.add(caseComment);
                		intCaseIdSet.add(caseComment.INTGR_Case__c);
            		}
            		
            	}
                
            } 
            else 
            {
                // Check for CaseComments to be created in Service Now : Princy
                system.debug(' **** Inside ELSE INT CASE COMM');
                
                // ADD TO THE ID SET FOR OUTBOUND CALLS
                if (caseComment.Integration_Account_Id__c != null) 
                {
                    integrationAccIdSet.add(caseComment.Integration_Account_Id__c);
                    intgrCaseCommIdSet.add(caseComment.Id);
                }
            }
           
        }
        
        // FOR INTERNAL CASE COMMENTS CREATION
        system.debug(' **** Inside ELSE INT CASE COMM - caseCommList = ' + caseCommList);
        
		if (caseCommList.size() > 0) 
		{
            createInternalCaseComments(caseCommList, intCaseIdSet);
        }
        
        // FOR UPDATE CALLOUT TO INTEGRATION SYSTEM
        if (intgrCaseCommIdSet.size() > 0) 
        {
            integrationHelperObj.initiate_IncidentCommCreateRequestToServiceNow(intgrCaseCommIdSet);
        }
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.processAfterCaseCommInsert() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
	
    private void processAfterCaseCommUpdate(List<INTGR_Case_Comment__c> newTrigger)
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: list of trigger.new and old map of integration case object
        // Description: Called from integration case comment after update for initiate outbound call to integration system        
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.processAfterCaseCommUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Set<Id> commId = new Set<Id>();
        for (INTGR_Case_Comment__c caseComment : newTrigger) 
        {
            system.debug('processAfterCaseCommUpdate INTGR_IntegrationHelper.uProfileName = ' + INTGR_IntegrationHelper.uProfileName);
            if (!INTGR_IntegrationHelper.uProfileName.containsIgnoreCase(INTGR_IntegrationHelper.INT_PROFILENAME)) 
            {
                commId.add(caseComment.Id);
            }
        }
        
        if (commId.size() > 0) 
        {
            integrationHelperObj.initiate_IncidentCommCreateRequestToServiceNow(commId);
        }
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.processAfterCaseCommUpdate() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
	
    private void createInternalCaseComments(List<INTGR_Case_Comment__c> caseCommentList, Set<Id> caseIdSet) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: List of trigger.new and old map of integration case object
        // Description: Create standard case comment after Insert from INBOUND Call
        
        system.debug(' *** ENTERING INTGR_CaseComment_TriggerHandler.createInternalCaseComments() - QUERIES ISSUED = ' + Limits.getQueries());
        
        List<CaseComment> newCaseCommLst = new List<CaseComment>();
        Map<Id, Id> intCaseIdVsCaseId = new Map<Id, Id>();
        String strErrorMsg = '';
        
        for (INTGR_Case__c caseObj : [SELECT Id, Case__c FROM INTGR_Case__c WHERE Id IN : caseIdSet]) 
        {
            intCaseIdVsCaseId.put(caseObj.Id, caseObj.Case__c);
        }
        
        try 
        {
            for (INTGR_Case_Comment__c intComm : caseCommentList) 
            {
                
                // INSTANTIATE NEW CASE RECORD 
                CaseComment comm = new CaseComment();
                comm.CommentBody = intComm.CommentBody__c;
                comm.ParentId = intCaseIdVsCaseId.get(intComm.INTGR_Case__c);
                
                // if (Test.isRunningTest()) 
                //{  
                //	comm.ParentId = System.Now() + '~~~~~~~~~';
                //}
                
                newCaseCommLst.add(comm);
                
            }
            
            system.debug(' **** newCaseCommLst = ' + newCaseCommLst);
            
            if (newCaseCommLst.size() > 0) 
            {
                INTGR_IntegrationHelper.isICCFlow = true;
                insert(newCaseCommLst);
            }
            
        } 
        catch (Exception ex) 
        {
            strErrorMsg += 'INTEGRATION CASE COMMENT ERROR: ' + ex.getMessage() + '. Please contact Amadeus Hospitality Support.\n';
        }
        
        // ERROR REPORTING 
        if (strErrorMsg != '') 
        {
            NI_Error_Logger.WriteToLog(strErrorMsg + '\n\n AFFECTED USER: ' + UserInfo.getUserName() + ' (' + UserInfo.getUserId() + ')', 'INTGR_Case_Comment__c', 'INTGR_CaseComment_TriggerHandler', 'OnAfterInsert');
        }
        
        system.debug(' *** EXITING INTGR_CaseComment_TriggerHandler.createInternalCaseComments() - QUERIES ISSUED = ' + Limits.getQueries());
        
    }
    
}