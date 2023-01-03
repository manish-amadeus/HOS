/****************************************************************************************
Name            : emailLoopKiller Trigger
Author          : Sean Harris
Created Date    : 1/19/2011
Last Mod Date   : 1/30/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-020940
Description     : emailLoopKiller trigger on Case 
                :    01/30/2017 (NICC-020940) Added IF condition to bypass when 
				:    context user for E2CP Context User is running user 
******************************************************************************************/
trigger emailLoopKiller on Case (before insert) 
{  
    
    //VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    NI_TriggerBypassSwitches__c bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    if (!bpSwitch.BypassCaseEmailLoopKiller_ON__c)
    {        
        
        string strEmailSubject = '';
        string strCaseOrigin = '';
        User runningUsr = [SELECT Id, Alias FROM User WHERE Id =: UserInfo.getUserId()];
        
        Set<String> setUserAliases = new Set<String>();
        
        // LIST TO HOLD THE VALUES FROM THE EmailLoopKillerUserExceptions__c CUSTOM SETTING  
        List<EmailLoopKillerUserExceptions__c> lstCS = EmailLoopKillerUserExceptions__c.getAll().values();
        
        // LOOP THROUGH THE lstCS AND GET THE USER ALIAS EXCEPTIONS
        for (EmailLoopKillerUserExceptions__c j : lstCS)
        {
            setUserAliases.add(j.User_Alias__c);
        }   
        
        case[] c = trigger.new; 
        case[] check = [SELECT ID, CreatedDate, Subject, Origin 
                        FROM Case 
                        WHERE SuppliedEmail =: c[0].SuppliedEmail  
                        AND Subject =: c[0].Subject 
                        AND IsClosed = false 
                        ORDER BY CreatedDate DESC]; 
        
        if (c[0].Subject != null)
        {
            strEmailSubject = c[0].Subject;
        }
        
        if (c[0].Origin != null)
        {
            strCaseOrigin = c[0].Origin;
        }
        
        if (strCaseOrigin != null)
        {		
            if (strCaseOrigin.contains('Email'))    // If origin comes from email.
            {
                if (strEmailSubject.contains('[ ref:') || 
                    strEmailSubject.contains('eSupport Information Request') || 
                    strEmailSubject.contains('Your Messages From Communication Solutions') || 
                    strEmailSubject.startsWith('iHotelier OTA Sync') || 
                    setUserAliases.contains(runningUsr.Alias))
                { 
                    // Email is valid. Email should be attached to the case or new case created.
                    // 01/30/2017 (NICC-020940) Added IF condition to bypass when context user for E2CP Context User is running user 
                } 
                else
                {
                    if (check.size() > 0)
                    {	            	
                        if (check[0].Subject == strEmailSubject)
                        {	            	            	
                            c[0].addError('The emailLoopKiller trigger has prevented this case from being created because an open case with this contact has the same subject.');      
                        }
                    }
                }	        
            }	    
        }
        
    }
    
}