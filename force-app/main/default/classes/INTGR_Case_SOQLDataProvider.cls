/************************************************************************************************
                  !!! INTEGRATION CLASS - DO NOT ALTER !!!                          
*************************************************************************************************
Name            : INTGR_Case_SOQLDataProvider 
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 01/11/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Class which acts like a DAO layer between integration classes and database.
				: 
************************************************************************************************/
public class INTGR_Case_SOQLDataProvider 
{
    
    public INTGR_Case_SOQLDataProvider() 
    {
        
    }
    
    public static List<INTGR_Account__c> getAccountConnectionDetails(Id accountId) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Set<String>     
        // Return: List<INTGR_Account__c>    
        // Description: Method to get integration account connection details like uname,password,endpoint etc.
        
        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getAccountConnectionDetails() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return [SELECT Id, Name, Account__c, 
                External_Integration_Name__c,
                External_Integration_System_Name__c
                FROM INTGR_Account__c
                WHERE Active__c = true
                AND Account__c =: accountId];
        
    }

    public boolean isValidField(String fieldName, String objectType) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Request Format, Map of Case Id vs Integration Case Object, Map of Source and Target Field Mapping based on Integration account selected.
        // Return: String of request body could be XML or JSON string.
        // Description: Method responsible to generate request body string based on format selected.        

        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.isValidField() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
        
        if (fieldMap != null && fieldMap.containsKey(fieldName)) 
        {
            return true;
        } 
        else 
        {
            return false;
        }
    }
   
    public Map<Id, String> getCaseIdVsReqFormatMap(Set<Id> caseIdSet) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Set Intgration case Id    
        // Return: Map of integration CaseId and request format for the outbound call
        // Description: Method to get integration account request format based on integration case id.        

        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getCaseIdVsReqFormatMap() - QUERIES ISSUED = ' + Limits.getQueries());
                
        Map<Id, String> caseIdVsReqFormatMap = new Map<Id, String>();
        
        for (INTGR_Case__c caseObj : [SELECT Id, 
                                      Case__c, 
                                      INTGR_Account__r.RequestFormat__c 
                                      FROM INTGR_Case__c 
                                      WHERE INTGR_Account__r.Active__c = true  
                                      AND (Id IN : caseIdSet OR Case__c IN : caseIdSet)])  //AND Case__r.Update_External_System__c = true ])
        {
            
            if (!caseIdSet.contains(caseObj.Case__c)) 
            {
                caseIdVsReqFormatMap.put(caseObj.Id, caseObj.INTGR_Account__r.RequestFormat__c);
            } 
            else 
            {
                caseIdVsReqFormatMap.put(caseObj.Case__c, caseObj.INTGR_Account__r.RequestFormat__c);
            }
        }

        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.getCaseIdVsReqFormatMap() - QUERIES ISSUED = ' + Limits.getQueries());
                    
        return caseIdVsReqFormatMap;
        
    }
 
    public static Map<Id, String> getCaseCommIdVsReqFormatMap(Set<Id> commIdSet) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Set Intgration case Id    
        // Return: Map of integrationCaseId and request format for the outbound call
        // Description: Method to get integration account request format based on integration case comment id.        

        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getCaseCommIdVsReqFormatMap() - QUERIES ISSUED = ' + Limits.getQueries());
                    
        Map<Id, String> caseIdVsReqFormatMap = new Map<Id, String>();
        
        for (INTGR_Case_Comment__c caseCommObj : [SELECT Id, 
                                                  INTGR_Case__r.INTGR_Account__r.RequestFormat__c 
                                                  FROM INTGR_Case_Comment__c 
                                                  WHERE INTGR_Case__r.INTGR_Account__r.Active__c = true 
                                                  AND Id IN : commIdSet 
                                                  AND INTGR_Case__r.Case__r.Update_External_System__c = true])   //AND INTGR_Case__r.INTGR_Account__r.Integration_User__c !=: userInfo.getUserId()                                        
        {
            if (!caseIdVsReqFormatMap.containsKey(caseCommObj.Id)) 
            {
                caseIdVsReqFormatMap.put(caseCommObj.Id, caseCommObj.INTGR_Case__r.INTGR_Account__r.RequestFormat__c);
            }
        }

        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.getCaseCommIdVsReqFormatMap() - QUERIES ISSUED = ' + Limits.getQueries());
                    
        return caseIdVsReqFormatMap;
        
    }

    public static INTGR_Case__c getCaseIdVsIntegrationDetailsList(Id caseId) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Intgration case Id    
        // Return: Integration Case object with Integration connection details.
        // Description: Method to get integration case and integration account based on integration case id.        

        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getCaseIdVsIntegrationDetailsList() - QUERIES ISSUED = ' + Limits.getQueries());
                    
        return [SELECT Id,
                Case__c,
                Case__r.Update_External_System__c,
                Description__c,
                Error_Message__c,
                Customer_Name__c,
                INTGR_Account__c,
                INTGR_Account__r.RequestFormat__c,
                INTGR_Account__r.Max_Count_To_Resend_Failed_Message__c,
                INTGR_Account__r.Integration_User__c,
                INTGR_Account__r.Integration_Endpoint__c,
                INTGR_Account__r.ImportSet_Endpoint__c,
                INTGR_Account__r.External_System_Username__c,
                INTGR_Account__r.External_System_Password__c,
                INTGR_Account__r.External_Integration_System_Name__c,
                INTGR_Account__r.External_Integration_Name__c,
                INTGR_Account__r.Attachment_Endpoint__c,
                INTGR_Account__r.Attachment_Endpoint_SOAP__c,
                INTGR_Account__r.Integration_Endpoint_SOAP__c,
                Severity__c,
                Status__c,
                Subject__c,
                Affected_Service__c,
                Assignment_Group__c,
                Hotel_Code__c,
                System_Affected__c,
                Customer_Ticket_Number__c,
                Customer_Ticket_System_Id__c,
                Work_Around_Available__c, 
                Workaround_Provided_Date__c, 
                Workaround_Rejected_Date__c, 
                IsOperationalIssue__c 
                FROM INTGR_Case__c
                WHERE Id =: caseId OR Case__c =: caseId 
                ORDER BY createdDate DESC 
                LIMIT 1
               ][0];
        
    }
     
    public static Map<String, String> getSourceTargetFieldMapViaAccId(Id intAccountId, String objectAPIName) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: Intgration case Id    
        // Return: Integration Case object with Integration connection details.
        // Description: Method to get integration case and integration account based on integration case id.        

        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId() - QUERIES ISSUED = ' + Limits.getQueries());
                 
        Map<String, String> srcTargetFieldMap = new Map<String, String>();
        
        for (INTGR_Field_Mapping__c mappingObj : [SELECT Id,
                                                 Source_Field__c,
                                                 Target_Field__c,
                                                 Source_Object_API_Name__c
                                                 FROM INTGR_Field_Mapping__c
                                                 WHERE Integration_Account__r.Active__c = true
                                                 AND Integration_Account__c = : intAccountId]) 
        {
            
            if (!srcTargetFieldMap.ContainsKey(mappingObj.Source_Field__c)) 
            {
                if (objectAPIName.containsIgnoreCase(mappingObj.Source_Object_API_Name__c)) 
                {
                    srcTargetFieldMap.put(mappingObj.Source_Field__c, mappingObj.Target_Field__c);
                }
            }
        }

        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.getSourceTargetFieldMapViaAccId() - QUERIES ISSUED = ' + Limits.getQueries());
                        
        return srcTargetFieldMap;
        
    }
    
    public string updateINTCaseSysIdAndIncidentNo(String sysId, String incNumber, INTGR_Case__c caseObj) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018   
        // Param: sysId, incidentNo, integration case obj
        // Return: result string after database operation.
        // Description: Method to populate external customer's sys id and incident no to Salesforce Integration case.
		
        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.updateINTCaseSysIdAndIncidentNo() - QUERIES ISSUED = ' + Limits.getQueries());
        
        String dbMessage = '';
        
        //UPDATE INTEGRATION CASE OBJECT WITH SYSID AND INCIDENT NUMBER
        caseObj.Customer_Ticket_System_Id__c = sysId;
        caseObj.Customer_Ticket_Number__c = incNumber;
        
        try 
        {
            Database.SaveResult updateResult = Database.update(caseObj, false);
            if (updateResult.getErrors().size() > 0) 
            {
                for (Database.Error err: updateResult.getErrors()) 
                {
                    dbMessage = 'Error Occured :' + err.getMessage();
                }
            } 
            else 
            {
                dbMessage = 'Record updated Successfully ';
            }
        } 
        catch (Exception ex) 
        {
            dbMessage += ex.getMessage();
        }
        
        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.updateINTCaseSysIdAndIncidentNo() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return dbMessage;
        
    }
    
    public static INTGR_Case_Comment__c getCaseCommIdVsIntegrationAccDetails(Id recordId) 
    {
        
        // Author: Princy Jain
        // Date: 03/21/2018 
        // Return: Integration Case object with Integration connection details.
        // Description: Method to get integration case and integration account based on integration case id.         
        
        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getCaseCommIdVsIntegrationAccDetails() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return [SELECT Id, 
                CommentBody__c, 
                CreateDate__c, 
                CreatedDate, 
                INTGR_Case__c, 
                INTGR_Case__r.Case__c, 
                INTGR_Case__r.Case__r.Update_External_System__c, 
                INTGR_Case__r.INTGR_Account__r.RequestFormat__c, 
                INTGR_Case__r.INTGR_Account__r.Max_Count_To_Resend_Failed_Message__c, 
                INTGR_Case__r.INTGR_Account__r.Integration_User__c, 
                INTGR_Case__r.INTGR_Account__r.Integration_Endpoint__c, 
                INTGR_Case__r.INTGR_Account__r.ImportSet_Endpoint__c, 
                INTGR_Case__r.INTGR_Account__r.Integration_Endpoint_SOAP__c, 
                INTGR_Case__r.INTGR_Account__r.External_System_Username__c, 
                INTGR_Case__r.INTGR_Account__r.External_System_Password__c, 
                INTGR_Case__r.INTGR_Account__r.External_Integration_System_Name__c, 
                INTGR_Case__r.INTGR_Account__r.External_Integration_Name__c, 
                INTGR_Case__r.Customer_Ticket_Number__c, 
                INTGR_Case__r.Customer_Ticket_System_Id__c 
                FROM INTGR_Case_Comment__c 
                WHERE Id =: recordId 
                ORDER BY createdDate DESC  
                LIMIT 1
               ][0];
        
    }

    public Map<Id, INTGR_Account__c> getIntAccIdVsAccMap()
    {
		
        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getIntAccIdVsAccMap() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, INTGR_Account__c> accIdVsUserMap = new Map<Id, INTGR_Account__c>();
        
        for (INTGR_Account__c acc : [SELECT Id, Assignment_Group__c, Case_Origin__c, Integration_User__c, Logger_Desk_Agent_Name__c, Logger_Group__c,
                                     Logger_Desk_Agent_Phone__c, Default_New_Case_Status__c, Active__c, Account__c, Contact__c, External_Integration_System_Name__c 
                                     FROM INTGR_Account__c
                                     WHERE Active__c = true 
                                     AND Integration_User__c =: userInfo.getUserId()])
        {
            accIdVsUserMap.put(acc.Id, acc);
        }
        
        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.getIntAccIdVsAccMap() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return accIdVsUserMap;
        
    }
    
    public static Map<Id, INTGR_Account__c> getAllIntAccMap()
    {
        
        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getAllIntAccMap() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, INTGR_Account__c> intAccIdVsAccMap = new Map<Id, INTGR_Account__c>();
        
        for (INTGR_Account__c acc : [SELECT Id, Assignment_Group__c, Case_Origin__c, Integration_User__c, Logger_Desk_Agent_Name__c, Logger_Group__c,
                                     Logger_Desk_Agent_Phone__c, Default_New_Case_Status__c, Active__c, Account__c, Contact__c, External_Integration_System_Name__c 
                                     FROM INTGR_Account__c
                                     WHERE Active__c = true 
                                     AND Integration_User__c != null])
        {
            intAccIdVsAccMap.put(acc.id, acc);
        }
        
        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.getAllIntAccMap() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return intAccIdVsAccMap;
        
    }
    
    public static Map<Id, Case> getSCdetailsToInsertIC(Id caseId)
    {
		
        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC() - QUERIES ISSUED = ' + Limits.getQueries());
        
        Map<Id, Case> scMap = new Map<Id, Case>(
            [SELECT 
             Id,
             Update_External_System__c,
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
            Work_Around_Available__c, 
            IsOperationalIssue__c, 
            Workaround_Provided_Date__c, 
            Workaround_Rejected_Date__c,             
             Integration_Account__c, 
             Integration_Account__r.Name, 
             Integration_Account__r.External_Integration_Name__c, 
             Integration_Account__r.External_Integration_System_Name__c, 
             Integration_Account__r.Assignment_Group__c,
             Integration_Account__r.Default_New_Case_Status__c, 
             Account_Name__c 
             FROM Case 
             WHERE Id =: caseId]);
        
        system.debug(' *** EXITING INTGR_Case_SOQLDataProvider.getSCdetailsToInsertIC() - QUERIES ISSUED = ' + Limits.getQueries());
        
        return scMap;
        
    }
    
    public static List<INTGR_Case__c> getICdetails(Set<Id> caseIdSet)
    {

        system.debug(' *** ENTERING INTGR_Case_SOQLDataProvider.getICdetails() - QUERIES ISSUED = ' + Limits.getQueries());
                
   		return [SELECT Id,
   				Case__c,
   				Case__r.Update_External_System__c,
		   		Customer_Name__c,
		   		Affected_Service__c,
		   		System_Affected__c,
		   		Assignment_Group__c,
		   		Customer_Ticket_Number__c,
		   		Customer_Ticket_System_Id__c,
		   		Status__c,
		   		INTGR_Account__c,
		   		Subject__c,
		   		Severity__c,
		   		Description__c,
		   		Hotel_Code__c, 
                Work_Around_Available__c, 
                Workaround_Provided_Date__c, 
                Workaround_Rejected_Date__c, 
                IsOperationalIssue__c  
		   		FROM INTGR_Case__c 
		   		WHERE Case__c IN : caseIdSet];
    }
    
}