/************************************************************************************************
Name            : AH_SandboxInit
Author          : Bhuleshwar Deshpande
Created Date    : 04/03/2020
Last Mod Date   : 04/16/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-042469
Description     : Class will be used to perform post sandbox refresh steps
                : 
************************************************************************************************/
public class AH_SandboxInit implements SandboxPostCopy 
{
    
    public void runApexClass(SandboxContext context) 
    {
        maskCSIntegrationData();  
        delNIjobRequisition();
        delEmpPerfEval();
    }
    
    private void maskCSIntegrationData()
    {
        
        // DISABLE LEGACY SERVICE NOW CUSTOM SETTINGS
        ServiceNowIncidentSettings__c incidentSettings = ServiceNowIncidentSettings__c.getValues('Default');
        incidentSettings.ServiceNow_Password__c = 'XXXXX';
        incidentSettings.SerrviceNow_Username__c = 'XXXXX';
        incidentSettings.Integration_Username__c= 'XXXXXihg_servicenow@newmarketinc.com.XXXXX';
        incidentSettings.Integration_UserId__c= '00517000001YWXyAAO';
        incidentSettings.ServiceNow_Incident_Case_Record_Type__c = 'XXXXX CRS Incident';
        incidentSettings.Incident_Endpoint__c = 'https://XXXXXihgsndev.service-now.com/api/now/table/incident';
        incidentSettings.ImportSet_Endpoint__c = 'https://XXXXXihgsndev.service-now.com/api/now/import/u_integ_amadeus_incidents';
        incidentSettings.Attachment_Endpoint__c = 'https://XXXXXihgsndev.service-now.com/api/now/attachment';
        update incidentSettings;
        
        // DISABLE LEGACY WINAPROACH CUSTOM SETTINGS
        WinaproachIncidentSettings__c winSettings = WinaproachIncidentSettings__c.getValues('Default');
        winSettings.Username__c = 'XXXXX';
        winSettings.Password__c = 'XXXXX';
        winSettings.Task_Record_Type__c = 'XXXXX Amadeus Parallel Investigation';
        winSettings.Endpoint__c = 'https://XXXXXaproach.amadeus.net/aproach/webserviceDEV/services/AproachWebServices';
        winSettings.Integration_Username__c = 'XXXXX.XXXXX@newmarketinc.com.XXXXX';
        update winSettings;
        
    }    
    
    // METHOD TO INVOKE BATCH CLASS AND PERFORM DELETE OPERATION FOR NI_Job_Requisition__c OBJECT RECORDS
    private void delNIjobRequisition()
    {   
        AH_SandboxInit_BatchJobReq objBatchToDeleteRecord = new AH_SandboxInit_BatchJobReq();
        ID batchprocessid = Database.executeBatch(objBatchToDeleteRecord, 200);
    }
    
    // METHOD TO INVOKE BATCH CLASS AND PERFORM DELETE OPERATION FOR NI_Employee_Performance_Evaluation__c OBJECT RECORDS
    private void delEmpPerfEval()
    {
        AH_SandboxInit_BatchPerfEval objBatchToDeleteRecord = new AH_SandboxInit_BatchPerfEval();
        ID batchprocessid = Database.executeBatch(objBatchToDeleteRecord, 200);
    }
    
}