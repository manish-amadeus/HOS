/****************************************************************************************
Name            : StatusReportRedirect Class
Author          : Sean Harris
Created Date    : 
Last Mod Date   : 04/10/2015
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
                : 
******************************************************************************************/
public with sharing class StatusReportRedirect 
{

    private StatusReport__c sr;
        
    public StatusReportRedirect(ApexPages.StandardController controller) 
    {
        this.sr = (StatusReport__c)controller.getRecord();     
    }
    
    public PageReference FormRedirect() 
    {
        
        PageReference srForm;
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Id = :sr.RecordTypeId];

        if (rt.Name == 'EMEA TAC A v1')
        {
            srForm = Page.SRFormEMEATACAv1;
        }

        if (rt.Name == 'EMEA TAC A v2')
        {
            srForm = Page.SRFormEMEATACAv2;
        }
        
        if (rt.Name == 'EMEA TAC S v1')
        {
            srForm = Page.SRFormEMEATACSv1;
        }
                
        if (rt.Name == 'US TAC A v1')
        {
            srForm = Page.SRFormUSTACAv1;
        }
        
        if (rt.Name == 'US TAC S v1')
        {
            srForm = Page.SRFormUSTACSv1;
        }
        
        if (rt.Name == 'US BRT v1')
        {
            srForm = Page.SRFormUSBRTv1;
        }
        
        if (rt.Name == 'PSS v1')
        {
            srForm = Page.SRFormPSSv1;
        }        
        
        if (rt.Name == 'US INT v1')
        {
            srForm = Page.SRFormUSINTv1;
        }
        
        if (rt.Name == 'US TAC A v2')
        {
            srForm = Page.SRFormUSTACAv2;
        }
        
        if (rt.Name == 'US TAC Senior A v1')
        {
            srForm = Page.SRFormUSTACSeniorAv1;
        }
        
        if (rt.Name == 'US TAC Lead A v1')
        {
            srForm = Page.SRFormUSLeadAv1; 
        }
        
        if (rt.Name == 'US TAC Lead A v2')
        {
            srForm = Page.SRFormUSLeadAv2; 
        }
        
        if (rt.Name == 'PMS Standard v1')
        {
            srForm = Page.SRFormPMSStandardv1; 
        }
        
        if (rt.Name == 'PMS Technical v1')
        {
            srForm = Page.SRFormPMSTechnicalv1; 
        }
        
        srForm.setRedirect(true);
        srForm.getParameters().put('id', sr.id);
        srForm.getParameters().put('RecordType', rt.id);        
        return srForm; 
        
    }    
    
    public PageReference ReportRedirect() 
    {
        
        PageReference srForm;
        
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'StatusReport__c' AND Id = :sr.RecordTypeId];

        if (rt.Name == 'EMEA TAC A v1')
        {
            srForm = Page.SReportEMEATACAv1;
        }

        if (rt.Name == 'EMEA TAC A v2')
        {
            srForm = Page.SReportEMEATACAv2;
        }
        
        if (rt.Name == 'EMEA TAC S v1')
        {
            srForm = Page.SReportEMEATACSv1;
        }
                
        if (rt.Name == 'US TAC A v1')
        {
            srForm = Page.SReportUSTACAv1;
        }        
        
        if (rt.Name == 'US TAC S v1')
        {
            srForm = Page.SReportUSTACSv1;
        }
                
        if (rt.Name == 'US BRT v1')
        {
            srForm = Page.SReportUSBRTv1;
        }
        
        if (rt.Name == 'PSS v1')
        {
            srForm = Page.SReportPSSv1;
        }        
                
        if (rt.Name == 'US INT v1')
        {
            srForm = Page.SReportUSINTv1;
        }

        if (rt.Name == 'US TAC A v2')
        {
            srForm = Page.SReportUSTACAv2;
        }     
        
        if (rt.Name == 'US TAC Senior A v1')
        {
            srForm = Page.SReportUSTACSeniorAv1;
        }
        
        if (rt.Name == 'US TAC Lead A v1')
        {
            srForm = Page.SReportUSLeadAv1;
        }
        
        if (rt.Name == 'US TAC Lead A v2')
        {
            srForm = Page.SReportUSLeadAv2;
        }
        
        if (rt.Name == 'PMS Standard v1')
        {
            srForm = Page.SReportPMSStandardv1; 
        }
        
        if (rt.Name == 'PMS Technical v1')
        {
            srForm = Page.SReportPMSTechnicalv1; 
        }
                
        srForm.setRedirect(true);
        srForm.getParameters().put('id', sr.id);        
        return srForm; 
        
    }        
    
}