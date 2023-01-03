/****************************************************************************************
Name            : NICaseActivities Class
Author          : Sean Harris
Created Date    : 03/23/2012
Last Mod Date   :
Last Mod By     :
NICC Reference  : NICC-004515 - https://c.na4.visual.force.com/apex/ni_change_control_tabbed_layout?id=a0s60000003o35HAAQ
Description     : Class used to gather activities, emails & case comments for a specified 
				: case. Sorts collected data by date.
				: 
******************************************************************************************/
public with sharing class NICaseActivities 
{
    
    Case theCase;
    Id CaseId;
    List<String> CaseNotes = new List<String>();
    
    public NICaseActivities(ApexPages.StandardController controller) 
    {
        if (ApexPages.CurrentPage().getParameters().containsKey('id')) 
        {
            CaseId = ApexPages.CurrentPage().getParameters().get('id');
            theCase = [SELECT Id, Subject, CreatedDate, Description FROM Case WHERE Id = :CaseId];
            GetCaseComments(CaseId);
            GetCaseActivities(CaseId);
            GetCaseEmails(CaseId);
            CaseNotes.sort();
        }       
    }
    
    private void GetCaseComments(ID idCaseId)
    {
        for (CaseComment cc : [SELECT ParentId, IsDeleted, Id, CreatedDate, CommentBody, CreatedBy.Name FROM CaseComment WHERE IsDeleted = false AND ParentId = :idCaseId])
        {
            CaseNotes.Add('<u><b>' + DateTime.ValueOf(cc.CreatedDate) + ' - Comment - ' + cc.CreatedBy.Name + '</b></u><br/><br/>' + lineBreaks(cc.CommentBody));                  
        } 
    }
    
    private void GetCaseActivities(ID idCaseId)
    {
        
        for (Task tsk : [SELECT WhatId, Subject, Description, CreatedDate, Status, CreatedBy.Name From Task WHERE IsDeleted = false AND WhatId = :idCaseId])
        {
            if (!tsk.Subject.startsWith('Email: '))
            {
                CaseNotes.Add('<u><b>' + DateTime.ValueOf(tsk.CreatedDate) + ' - ' + tsk.Subject + ' - ' + tsk.CreatedBy.Name + '</b></u><br/><br/>' + lineBreaks(tsk.Description));
            }
        }
    }
    
    private void GetCaseEmails(ID idCaseId)
    {
        
        for (EmailMessage eml : [Select ToAddress, TextBody, Subject, Status, ParentId, Id, FromName, FromAddress, CreatedDate, CreatedBy.Name, CcAddress, BccAddress From EmailMessage e WHERE e.ParentId = :idCaseId])
        {
            
            string strRecord = '';
            String strStatus = '';
            
            if (eml.Status == '0') 
            {
                strStatus = 'New';
            }
            if (eml.Status == '1')
            {
                strStatus = 'Read';
            }
            if (eml.Status == '2') 
            {
                strStatus = 'Replied';
            }
            if (eml.Status == '3') 
            {
                strStatus = 'Sent';
            }
            
            strRecord = '<u><b>' + DateTime.ValueOf(eml.CreatedDate); 
            strRecord += ' - Email (' + strStatus + ') - '; 
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
                //strRecord += stripOriginalMessage(lineBreaks(eml.TextBody));
                strRecord += lineBreaks(eml.TextBody);
            }
            
            CaseNotes.Add(strRecord);
            
        }
    }
    
    // Returns the final data results
    public List<String> results 
    {
        get 
        {
            //            if (CaseNotes == null) 
            //            {
            //                CaseNotes = new List<String>();
            //            }    
            return CaseNotes;
        }
        set;    
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
    
    public String getDescription
    {
        get 
        {
            string retVal;        
            retVal = lineBreaks(theCase.Description);
            return retVal;
        }
        set;
    }
    
/*    
    private string stripOriginalMessage(string inText)
    {
        
        String strRetVal = inText;
        
        if (inText != null)
        {
            if (inText.indexOf('Original Message', 0) != -1)
            {         
                strRetVal = inText.substring(0, inText.indexOf('Original Message', 0));
            }
        }
        return strRetVal;
        
    }
*/
    
}