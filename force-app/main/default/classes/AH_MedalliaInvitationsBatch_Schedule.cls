/***********************************************************************************************
Name            : AH_MedalliaInvitationsBatch_Schedule
Author          : Bhagwat Garkal
Created Date    : 07/08/2022
Last Mod Date   : 07/08/2022
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : Schedulable class for AH_MedalliaInvitations_Schedule Class.   
                :
                :
************************************************************************************************/
global class AH_MedalliaInvitationsBatch_Schedule implements Schedulable
{
    
    global void execute(SchedulableContext sc) 
    {
        
        try
        {
            Date surveycreatedDate = System.today();
            //  Medallia_Support_Survey__c records
            String supportSurveySOQL = 'SELECT Id from Medallia_Support_Survey__c ';
            String supportSOQLWhere = 'WHERE Process_Status__c = \'Not Processed Yet\' AND (Retry__c = true OR CreatedDate = TODAY)';
            
            AH_MedalliaInvitations_Batch supportbatch = new AH_MedalliaInvitations_Batch(supportSurveySOQL + supportSOQLWhere, 'Support_FieldSet', 'sfdc_create_survey_hos_support', 'Customer Support');
            Id supportbatchId = Database.executeBatch(supportbatch, 10); 
            
            //  Medallia_Service_Survey__c records
            String serviceSurveySOQL = 'SELECT Id from Medallia_Service_Survey__c ';
            String serviceSOQLWhere = 'WHERE Process_Status__c = \'Not Processed Yet\' AND (Retry__c = true OR CreatedDate = TODAY)';
            
            AH_MedalliaInvitations_Batch servicebatch = new AH_MedalliaInvitations_Batch(serviceSurveySOQL + serviceSOQLWhere, 'Service_FieldSet', 'sfdc_create_survey_hos_implementations', 'Services - Installer Survey');
            Id servicebatchId = Database.executeBatch(servicebatch, 10); 
            
            //  Medallia_Adoption_Survey__c records
            String adoptionSurveySOQL = 'SELECT Id from Medallia_Adoption_Survey__c ';
            String adoptionSOQLWhere = 'WHERE Process_Status__c = \'Not Processed Yet\' AND AppointmentBookedEmailReceived__c = true AND (Retry__c = true OR CreatedDate = TODAY)';
           
            AH_MedalliaInvitations_Batch adoptionbatch = new AH_MedalliaInvitations_Batch(adoptionSurveySOQL + adoptionSOQLWhere, 'Adoption_FieldSet', 'sfdc_create_survey_hos_adoption', 'Adoption Survey');
            Id adoptionbatchId = Database.executeBatch(adoptionbatch, 10); 
            
        }
        catch (Exception e)
        {
            // CREATE DTS LOGS
            // AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Job', 'Active', 'Error', 'Error Scheduling Apex Job', e.getMessage(), '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaInvitationsBatch_Schedule', 'Apex Job Scheduling', 'Salesforce', true, false);
            // WRITE DTS INTGRATION LOG ERROR 
            AH_DTS_Integration_Logger.writeToDTSLog(system.now(), 'Medallia - Apex Job', 'Active', 'Error', 'Error Scheduling Apex Job', e.getMessage(), '3 - Medium', UserInfo.getUserName(), 'AH_MedalliaInvitationsBatch_Schedule','Apex Job Scheduling', 'Salesforce', true, false); 							// bWillSelfResolve        
        }
        
    }
    
}