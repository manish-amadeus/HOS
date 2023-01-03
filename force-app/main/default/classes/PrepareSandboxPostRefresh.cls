/************************************************************************************************
Name            : PrepareSandboxPostRefresh
Author          : Princy Jain
Created Date    : 11/28/2018
Last Mod Date   : 11/28/2018
Last Mod By     : Princy Jain
NICC Reference  : 
Description     : Class will be used to perform post sandbox refresh steps
                : 
************************************************************************************************/
public class PrepareSandboxPostRefresh implements SandboxPostCopy 
{
    
    public void runApexClass(SandboxContext context) 
    {
        
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        
        maskCSIntegrationData();
        
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
    
}