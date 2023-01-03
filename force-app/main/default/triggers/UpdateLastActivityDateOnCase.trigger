trigger UpdateLastActivityDateOnCase on Task (after insert, after update) 
{

    // IF RECORD TYPE IS "Hosted_RFC"
    RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Task' AND Name = 'NI Support' AND isActive = true];
    Task[] tr = Trigger.new;            
    
    for (Task t: Trigger.new) 
    {
        if (t.RecordTypeId == rt.Id)
        {
            Case[] c = [SELECT Id, RealLastActivityDate__c, Status FROM Case WHERE Id =: t.WhatId];
            
            if (c.size() > 0)
            {
                if (c[0].Status != 'New')
                {   
                    if ((c[0].Status == 'Closed') && (!t.Subject.startsWith('Automated Email Out')) && UserInfo.getProfileId() != '00e0d0000016CwmAAE') // 'AH Support Managers - Lightning'
                    {
                        tr[0].addError('Adding activites to closed cases is not allowed. Please change the status of the case to Working then try again.');
                    }
                    else
                    {  
                        c[0].RealLastActivityDate__c = Datetime.now();
                        update c;
                    }
                }
            }
        }
    }
    
}