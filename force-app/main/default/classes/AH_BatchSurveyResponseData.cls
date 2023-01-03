/************************************************************************************************
Name            : AH_BatchSurveyResponseData Class
Author          : Ria Chawla
Created Date    : 09/14/2017
Last Mod Date   : 10/11/2017 
Last Mod By     : Stuart Emery
NICC Reference  : NICC-024092
Description     : Query Survey Response Data records that have been created or modified in between date range specified
                : to update NPS and OSAT values on Contact record.
				: Test class is called AH_UpdateContactScoreControllerTest
                : Updated 10/11/2017 Per NICC-024272
*************************************************************************************************/
global class AH_BatchSurveyResponseData implements Database.Batchable<sObject>, Database.stateful 
{
    
    public String query;
    public Datetime startDate;
    public Datetime endDate;
    public Boolean testIsRunning = false;
    public Set<Id> failedContactSet = new Set<Id>();
    public Set<Id> successContactSet= new Set<Id>();
    public Integer totalAmtOfRecords = 0;
    
    public AH_BatchSurveyResponseData(Datetime startDt, Datetime endDt)
    {
        // SET START DATE AND END DATE
        startDate = startDt;
        endDate = endDt;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        
        system.debug('in AH_BatchSurveyResponseData.start: startDate = ' + startDate + ', endDate = ' + endDate);
        
        // QUERY ALL SURVEY RESPONSE DATA RECORDS WHICH HAVE BEEN CREATED OR MODIFIED WITHIN THE START DATE AND END DATE
        query = 'SELECT Id, Name, Contact__c, NPS__c, OSAT__c '+
            'FROM Confirmit_Survey_Response_Data__c ' + 
            'WHERE (CreatedDate >=: startDate AND CreatedDate <=: endDate) ' + 
            'OR (LastModifiedDate >=: startDate AND LastModifiedDate <=: endDate) ';
        
        system.debug('AH_BatchSurveyResponseData query = ' + query);
        
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Confirmit_Survey_Response_Data__c> scope)
    {
        
        system.debug('in AH_BatchSurveyResponseData.execute: scope = ' + scope);
        
        totalAmtOfRecords += scope.size();
        Set<Id> contactIdSet = new Set<Id>();
//        List<Confirmit_Survey_Response_Data__c> recordsToProcess = new List<Confirmit_Survey_Response_Data__c>();
        List<NI_Admin_Error_Log__c> errorLogList = new List<NI_Admin_Error_Log__c>();
        
        // LOOP THROUGH RESPONSE DATA RECORDS AND STORE THEIR CONTACTS IN A SET
        for (Confirmit_Survey_Response_Data__c surveyData : scope)
        {
            if (surveyData.Contact__c != null)
            {
                contactIdSet.add(surveyData.Contact__c);
//                recordsToProcess.add(surveyData);
            }
        }
        
        if (!contactIdSet.isEmpty())
        {
            
            AH_SurveyResponseDataTriggerHandler handler = new AH_SurveyResponseDataTriggerHandler();
            
            try
            {
                // CALL METHOD TO CALCULATE NPS and OSAT on CONTACT
//				List<Contact> contactsToUpdate = handler.calculateNPSandOST(recordsToProcess, contactIdSet);
                List<Contact> contactsToUpdate = handler.calculateNPSandOST(contactIdSet);
                if (!contactsToUpdate.isEmpty())
                {
                    database.saveresult[] ds = Database.update(contactsToUpdate, false);
                    for (integer i = 0; i < ds.size(); i++)
                    {
                        if (ds.get(i).isSuccess() == false)
                        {                
                            for (Database.Error err : ds.get(i).getErrors()) 
                            {
                                failedContactSet.add(contactsToUpdate[i].Id);
                            }
                        }
                        else
                        {
                            successContactSet.add(contactsToUpdate[i].Id);
                        }
                    }
                }
                
                if (testIsRunning)
                {
                    throw new DmlException();
                }
                
            }
            catch (Exception e)
            {
                system.debug('ERROR OCCURRED: ' + e.getMessage());
                
                // CREATE ERROR LOG IF ANY ERROR IS ENCOUNTERED
                NI_Admin_Error_Log__c errorLog = new NI_Admin_Error_Log__c();
                errorLog.Apex_Class_Name__c = 'AH_BatchSurveyResponseData';
                errorLog.Object_Name__c = 'Confirmit_Survey_Response_Data__c';
                
                if (e.getStackTraceString() != null)
                {
                    errorLog.Message__c = e.getStackTraceString();
                }
                    
                if (e.getTypeName() != null)
                {
                    errorLog.Type__c = e.getTypeName();
                }
                    
                errorLogList.add(errorLog);
            }
        }
        
        if (!errorLogList.isEmpty())
        {
            // INSERT ERROR LOG LIST
            insert errorLogList;
        }
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
        system.debug('in AH_BatchSurveyResponseDatafinish');
        system.debug('Total amount of records processed : ' + totalAmtOfRecords); 
        system.debug('successContactSet = ' + successContactSet);
        
        AsyncApexJob asyncJob = new AsyncApexJob();
        asyncJob = [SELECT Id, ApexClassId, CompletedDate, CreatedById, CreatedDate, NumberOfErrors, Status
                    FROM AsyncApexJob
                    WHERE Id =: bc.getJobId()
                    ORDER BY CreatedDate DESC LIMIT 1];
        
        system.debug('asyncJob = ' + asyncJob);
        AH_Batch_Apex_Result__c batchApexResult = new AH_Batch_Apex_Result__c();
        batchApexResult.Name = 'Batch Job - ' + Datetime.now().format();
        
        if (asyncJob != null)
        {
            batchApexResult.Batch_Job_Id__c = asyncJob.Id;
        }
            
        batchApexResult.Failed_Records__c = failedContactSet.size();
        batchApexResult.Success_Records__c = successContactSet.size();
        batchApexResult.Total_Survey_Records_Processed__c = totalAmtOfRecords;
        batchApexResult.Apex_Class__c = 'AH_BatchSurveyResponseData';
        
        if (!failedContactSet.isEmpty())
        {
            batchApexResult.Failed_Contact_Records__c = '' + failedContactSet;
        }
        
        insert batchApexResult;
        
    }
    
}