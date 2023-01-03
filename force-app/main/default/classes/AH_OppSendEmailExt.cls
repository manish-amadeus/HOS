/****************************************************************************************
Name            : AH_OppSendEmailExt
Author          : Ria Chawla
Created Date    : 12/12/2017
Last Mod Date   : 12/14/2017
Last Mod By     : 
NICC Reference  : 
Description     : Extention Class for AH_OppSendEmail VF page
******************************************************************************************/
public class AH_OppSendEmailExt 
{
    
    public Opportunity oppId {get; set;}
    public Opportunity opp {get; set;}
    public Boolean disableButton {get; set;}
    
    
    public AH_OppSendEmailExt(ApexPages.StandardController stdController)
    {        
        this.oppId = (Opportunity)stdController.getRecord();    
        opp = [SELECT Id, Name, Opportunity_Number__c, OwnerId,	CaseId__c, Notes_to_Sales__c, CreatedBy.Name, CreatedBy.Id, CreatedDate, Notes_from_Sales_Escalation__c
               FROM Opportunity 
               WHERE Id = :oppId.Id];
        disableButton = false;
    }
    
    public PageReference sendEmail()
    {
        
        if (opp.Notes_from_Sales_Escalation__c != null && opp.Notes_from_Sales_Escalation__c != '')
        {
            Database.update(opp);
        }
        
        try
        {
            
            Id taskRecId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('NI Standard Task').getRecordTypeId();
            
            Task tsk = new Task();
            tsk.WhatId = opp.Id;
            tsk.RecordTypeId = taskRecId;
            tsk.Type = 'Outgoing Email';
            tsk.Priority = 'Low';
            tsk.Status = 'Completed';
            tsk.Subject = 'Email: New Opportunity - Case to Opportunity';
            tsk.Description = 'Email: New Opportunity - Case to Opportunity'; 
            tsk.OwnerId = '00560000000yI7jAAE';
            
            insert tsk;
            
            disableButton = true;            
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email sent successfully!'));
            
        }            
        catch (DMLException e)
        {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not able to create task on case'));
        }                
        
        return null;
        
    }
    
    public PageReference closeAndReturn()
    {
        PageReference pg = new PageReference('/' + opp.Id);
        pg.setRedirect(true);
        return pg;
    }
    
}