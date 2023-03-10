/****************************************************************************************
Name            : NI_Case_BeforeInsert Trigger
Author          : Sean Harris
Created Date    : 05/02/2014 
Last Mod Date   : 03/01/2022
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 03/01/2022 Moved emailLoopKiller trigger to this trigger. Added if/else 
                :            block to skip code when new Case created via email-to-case 
                : 
******************************************************************************************/
trigger NI_Case_BeforeInsert on Case (before Insert) 
{

    // EMAIL-TO-CASE = IF ONE CASE COMES THROUGH THAT HAS A "Web Email" VALUE AND RUNNING USER IS "Integration User" 
    if ((Trigger.new.size() == 1 && Trigger.new[0].SuppliedEmail != null && Trigger.new[0].Origin == 'Email' && Trigger.new[0].RecordTypeId == '0126000000011YUAAY' && UserInfo.getUserId() == '00560000000yI7jAAE') || 
        (Test.isRunningTest() && UserInfo.getUserName() == 'test_integration_user@xxxxxxx.com'))
    {
        system.debug(' ***** NI_Case_BeforeInsert - THIS IS A CASE GENERATED FROM INBOUND EMAIL-2-CASE. SETTING NI_TriggerManager.bypassTriggersInvokedByCaseDML = true'); 
        
        // SET Case TRIGGER BYPASS FLAG TO SKIP CODE EXECUTION IN RELATED TRIGGERS
        NI_TriggerManager.bypassTriggersInvokedByCaseDML = true;
        
        // EMAIL LOOP CHECK/STOP (Formerly emailLoopKiller Trigger)
        // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
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
    else
    {
        
        // DO NOT EXECUTE TRIGGER IF THIS STATEMENT IS TRUE (Set initially in emailLoopKiller trigger)
        if (NI_TriggerManager.bypassTriggersInvokedByCaseDML)
        {
            system.debug(' ***** NI_Case_BeforeUpdate WAS BYPASSED VIA NI_TriggerManager.bypassTriggersInvokedByCaseDML');       
            return;
        }
        
        // INTEGRATION - DO NOT ALTER!!! 
        if (!NI_FUNCTIONS.bypassTriggerCode('WIN@PROACH'))
        {
            INTGR_WinSN_Case_Handler WinSN = new INTGR_WinSN_Case_Handler();
            WinSN.OnBeforeInsert(Trigger.new); 
        }
        
        NI_Case_TriggerHandler handler = new NI_Case_TriggerHandler();
        handler.OnBeforeInsert(Trigger.new);
        
    }
    
    system.debug(' ***** NI_Case_BeforeInsert SUMMARY: Limits.getQueries() = ' + Limits.getQueries()); 
   
}