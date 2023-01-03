trigger UpdateCaseOwnerWhenCreated on Task (before insert) 
{

    // IF RECORD TYPE IS "Hosted_RFC"
    RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'Task' AND Name = 'NI Support' AND isActive = true];
    //Task[] tr = Trigger.new;            
    
    for (Task t: Trigger.new) 
    {
        if (t.RecordTypeId == rt.Id)
        {
            Case[] c = [SELECT Id, OwnerId, Status FROM Case WHERE Id =: t.WhatId];
            
            if (c.size() > 0)
            {
                if (c[0].Status != 'New')
                {   
                    if (c[0].Status != 'Closed')
                    {
                        t.CaseOwnerWhenCreated__c = c[0].OwnerId;
                    }
                }
            }
        }
    }
    
}