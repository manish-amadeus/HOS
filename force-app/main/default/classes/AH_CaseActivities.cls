/****************************************************************************************
Name            : AH_CaseActivities Class
Author          : Sean Harris
Created Date    : 03/23/2012
Last Mod Date   : 04/17/2020 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller class for AH_CaseActivities VF Page
                : 
******************************************************************************************/
public class AH_CaseActivities //implements Queueable 
{
    
    public Case c {get; set;}
    public List<String> lstAllActivities {get; set;}
    public String strDescription {get; set;}
    
    // FOR TEST CLASS ONLY
    private List<DA_EmailMessage__b> lstEMs;
    
    public AH_CaseActivities(List<DA_EmailMessage__b> lst) 
    {
        this.lstEMs = lst;
    }
    
    public AH_CaseActivities() 
    {
        
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {
            
            Id CaseId = ApexPages.CurrentPage().getParameters().get('id');
            c = [SELECT Id, CaseNumber, Subject, CreatedDate, Description, Account.Name, Contact.Name FROM Case WHERE Id =: CaseId];
            strDescription = lineBreaks(c.Description);
            lstAllActivities = new List<String>();    
            Map<String, String> mapStatusCode2Text = new Map<String, String>(); 
            mapStatusCode2Text.put('0', 'New');
            mapStatusCode2Text.put('1', 'Read');
            mapStatusCode2Text.put('2', 'Replied');
            mapStatusCode2Text.put('3', 'Sent');
           
            // GET CASE COMMENTS
            for (CaseComment cc : [SELECT Id, ParentId, CreatedDate, CommentBody, CreatedBy.Name FROM CaseComment WHERE ParentId =: CaseId])
            {
                lstAllActivities.Add('<u><b>' + DateTime.ValueOf(cc.CreatedDate) + ' - Comment - ' + cc.CreatedBy.Name + '</b></u><br/><br/>' + lineBreaks(cc.CommentBody));                  
            }             
            
            // GET CASE ACTIVITIES
            for (Task tsk : [SELECT Id, WhatId, Subject, Description, CreatedDate, Status, CreatedBy.Name FROM Task WHERE WhatId =: CaseId])
            {
                if (!tsk.Subject.startsWith('Email: '))
                {
                    lstAllActivities.Add('<u><b>' + DateTime.ValueOf(tsk.CreatedDate) + ' - ' + tsk.Subject + ' - ' + tsk.CreatedBy.Name + '</b></u><br/><br/>' + lineBreaks(tsk.Description));
                }
            }             
            
            // GET EMAIL MESSAGES
            for (EmailMessage eml : [SELECT Id, ToAddress, TextBody, Subject, Status, ParentId, FromName, FromAddress, CreatedDate, CreatedBy.Name, CcAddress, BccAddress FROM EmailMessage e WHERE e.ParentId =: CaseId])
            {

                string strRecord = '';
                
                strRecord = '<u><b>' + DateTime.ValueOf(eml.CreatedDate); 
                strRecord += ' - Email (' + mapStatusCode2Text.get(eml.Status) + ') - '; 
                strRecord += eml.CreatedBy.Name + '</b></u><br/><br/>'; 
                
                if (eml.FromAddress != null)
                {
                    strRecord += 'From: ' + eml.FromAddress + '<br/>'; 
                }
                
                if (eml.ToAddress != null)
                {                       
                    strRecord += 'To: ' + eml.ToAddress + '<br/>'; 
                }
                
                if (eml.ccAddress != null)
                {                                       
                    strRecord += 'Cc: ' + eml.ccAddress + '<br/>'; 
                }
                
                if (eml.BccAddress != null)
                {                                       
                    strRecord += 'Bcc: ' + eml.BccAddress + '<br/>'; 
                }
                
                if (eml.Subject != null)
                {               
                    strRecord += 'Subject: ' + eml.Subject + '<br/><br/>'; 
                }
                
                if (eml.TextBody != null)
                {       
                    strRecord += lineBreaks(eml.TextBody);
                }

                lstAllActivities.Add(strRecord);
                
            } 

            string strArcRecord = '';
            String strCaseId = string.valueOf(CaseId);  
            strCaseId = (strCaseId.substring(0, 15).toLowerCase());    
            
            // GET ARCHIVED EMAIL MESSAGES
            for (DA_EmailMessage__b arcEm : [SELECT S_Id__c, S_ToAddress__c, S_TextBody__c, S_Subject__c, S_Status__c, S_ParentId__c, 
                                             S_FromName__c, S_FromAddress__c, S_CreatedDate__c, S_CreatedById__c, S_CcAddress__c, S_BccAddress__c
                                             FROM DA_EmailMessage__b 
                                             //WHERE S_ParentId_Indexed__c =: strCaseId]) // CHANGED TO FIX "Filters may not have any gaps within the composite key" ERROR
                                             WHERE S_RelatedToId_Indexed__c =: strCaseId])
            {
                
                if (arcEm.S_ParentId__c == CaseId)
                {
                                       
                    strArcRecord = '<u><b>' + DateTime.ValueOf(arcEm.S_CreatedDate__c); 
                    strArcRecord += ' - Email (' + mapStatusCode2Text.get(arcEm.S_Status__c)  + ') - '; 
                    User u = [SELECT Name FROM User WHERE Id =: arcEm.S_CreatedById__c];
                    strArcRecord += u.Name + '</b></u><br/><br/>'; 
                    
                    if (arcEm.S_FromAddress__c != null) { strArcRecord += 'From: ' + arcEm.S_FromAddress__c + '<br/>'; }
                    
                    if (arcEm.S_ToAddress__c != null) { strArcRecord += 'To: ' + arcEm.S_ToAddress__c + '<br/>'; }
                    
                    if (arcEm.S_CcAddress__c != null) { strArcRecord += 'Cc: ' + arcEm.S_CcAddress__c + '<br/>'; }
                    
                    if (arcEm.S_BccAddress__c != null) { strArcRecord += 'Bcc: ' + arcEm.S_BccAddress__c + '<br/>'; }
                    
                    if (arcEm.S_Subject__c != null) { strArcRecord += 'Subject: ' + arcEm.S_Subject__c + '<br/><br/>'; }
                    
                    if (arcEm.S_TextBody__c != null) { strArcRecord += lineBreaks(arcEm.S_TextBody__c); }
                    
                    lstAllActivities.Add(strArcRecord);
                    
                }
                
            }             
            
            // SORT THE ACTIVITIES 
            lstAllActivities.sort();
            
        }   
        
    }
    
    private string lineBreaks(string inText)
    {
        if (inText == null)
        {
            return '';
        }
        else
        {
            return inText.replaceAll('<','(').replaceAll('>',')').replaceAll('\n','<br/>');
        }
    }
/*
    @TestVisible
    private void insertTestBigObjectRecords(List<DA_EmailMessage__b> lstEMs)
    {
        if (Test.isRunningTest() && !lstEMs.isEmpty())
        {
            Database.insertImmediate(lstEMs);   
        }
    }
    
    @TestVisible
    private void deleteTestBigObjectRecords(List<DA_EmailMessage__b> lstEMs)
    {
        if (Test.isRunningTest() && !lstEMs.isEmpty())
        {
            Database.deleteImmediate(lstEMs);   
        }
    }
*/    
}