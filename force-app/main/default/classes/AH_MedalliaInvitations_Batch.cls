/***********************************************************************************************
Name            : AH_MedalliaInvitations_Batch
Author          : Bhagwat Garkal
Created Date    : 07/08/2022
Last Mod Date   : 10/05/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Create Invitations records From Survey.  
                : SMH: Updated finish method to accurately write Success Log records
                :
************************************************************************************************/
global class AH_MedalliaInvitations_Batch implements Database.Batchable<sObject>
{
    
    @testvisible private String query;
    @testvisible private String surveyType;
    @testvisible private String fieldSetName;
    @testvisible private String serviceEndpoint;
    @testvisible private boolean bFail;
    
    global AH_MedalliaInvitations_Batch(String query, String fieldSetName, String serviceEndpoint, String surveyType)
    {
        this.query = query;
        this.surveyType = surveyType;
        this.fieldSetName = fieldSetName;
        this.serviceEndpoint = serviceEndpoint;
        this.bFail = false;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(this.query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope) 
    {
        
        try
        {
            
            List<medallia_xm.QueueItemPayload> payloads = new List<medallia_xm.QueueItemPayload>();
            
            for (SObject record : scope)
            {
                medallia_xm.QueueItemPayload payload = new medallia_xm.QueueItemPayload();
                payload.fieldSet = fieldSetName;
                payload.recordId = record.Id;
                payload.service = serviceEndpoint;
                payload.whenToSend = System.now();
                payload.sendInvite = true;
                payloads.add(payload);
            }
            medallia_xm.MedGenericProcess.Process(payloads);
        }
        catch (Exception e)
        {
			bFail = true;
            // WRITE DTS INTEGRATION LOG ERROR 
            AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Batch', 'Active', 'Error', 'Error while creating Invitations', e.getMessage(), '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaInvitations_Batch', 'Apex Job', 'Salesforce', true, false); 
        }
        
    }
    
    global void finish(Database.BatchableContext bc) 
    {
        
        // WRITE DTS INTGRATION LOG SUCCESS 
        if (!bFail) 
        {
            AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Batch', 'Active',  'Success', 'Batch finish() method', 'No errors to report', '4 - Minor', UserInfo.getUserName(), 'AH_MedalliaInvitations_Batch', 'Apex Job', 'Salesforce', true, false); 
        }
		
    }
    
}