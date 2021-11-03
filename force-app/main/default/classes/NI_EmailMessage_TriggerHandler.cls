/************************************************************************************************
Name            : NI_EmailMessage_TriggerHandler Class
Author          : Sean Harris
Created Date    : 02/02/2017
Last Mod Date   : 07/02/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-020976
Description     : Class that handles all trigger code for the EmailMessage Object
                : Ria added Trigger Switch to bypass 'CASE FLAGS' code.
				: New method added to set flag on Inbound email and clear flag on outbound email. 
                : UPDATED 07/02/2020 PER NICC-044303
*************************************************************************************************/
public with sharing class NI_EmailMessage_TriggerHandler
{
    
    public Static Map<String, String> emailMsgsMap = new Map<String, String>();
    
    
    public NI_EmailMessage_TriggerHandler()
    {
    
    }
    
    public void OnBeforeInsert(List<EmailMessage> newTrigger)
    {
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }
        
        // NICC-044303 (START)
        for (EmailMessage em : newTrigger)
        {

            if (em.RelatedToId != null)
            {
                
                String firstThreeChars = String.valueOf(em.RelatedToId).substring(0, 3);

                String Subject = '';
                Subject = em.Subject;
                
                String ToAddress = '';
                ToAddress = em.ToAddress;
                
                String txtBody = '';
                txtBody = em.TextBody.substring(0, 15);
                txtBody = txtBody.replace('\n','');
                
                String str = em.ParentId + '___' + 	Subject	+ '___' +	ToAddress	+ '___' + txtBody;

                // FOR MERGE CASE ISSUE 
                // CHECK IF PARENTID & RELATEDID ARE NOT EQUAL  AND	 RELATEDID IS OF CASE OBJECT
                if (em.ParentId != em.RelatedToId && String.valueOf(em.RelatedToId).substring(0, 3) == '500')
                {
                    emailMsgsMap.put(str, str);
                }
            }
            
        }
        // NICC-044303 (END)
         
    }
    
    public void OnAfterInsert(List<EmailMessage> newTrigger)
    {
        
        if (bypassTrigger(newTrigger))
        {
            return;
        }
        
        if (!NI_FUNCTIONS.bypassTriggerCode('CASE FLAGS'))
        {
            setClearFlagOnEmail(newTrigger);
        }
        
        if (!NI_FUNCTIONS.bypassTriggerCode('EMAILMESSAGE'))
        {
            rollUpEmailCounts(newTrigger);
        }
        
    }
    
    
    // =========================================================================
    //    FUNCTIONS ============================================================
    // =========================================================================        
    
    private Boolean bypassTrigger(List<EmailMessage> newTrigger)
    {
        boolean bRetVal = false;
        for (EmailMessage em : newTrigger)
        {
            if (em.ToAddress == Label.AH_EmailServicesAddress)
            {
                bRetVal = true;
            }
        }
        return bRetVal;
    }    
    
    // THIS FUNCTION INCREMENTS Number_of_Emails_Sent__c FIELD ON RELATED CASE
    private void rollUpEmailCounts(List<EmailMessage> newTrigger)
    {
        
        // COLLECT UNIQUE CASE IDS AND TASKS WHEN TASK RECORD TYPE IS VALID
        Set<Id> setCaseIds = new Set<Id>();
        
        for (EmailMessage em : newTrigger)
        {
            setCaseIds.Add(em.ParentId);
        }
        
        // USE MAP OF CASES TO INCREMENT Number_of_Emails_Sent__c VALUES LATER IN LOOP THROUGH EMAILMESSAGES 
        // MAP IS USED IN FINAL UPDATE COMMIT
        Map<Id, Case> mapCases = new Map<Id, Case>([SELECT Id, Number_of_Emails_Sent__c, Status FROM Case WHERE Id IN : setCaseIds]); 
        
        for (EmailMessage e : newTrigger)
        {
            if (mapCases.containsKey(e.ParentId))
            { 
                if (mapCases.get(e.ParentId).Number_of_Emails_Sent__c == null)
                {
                    mapCases.get(e.ParentId).Number_of_Emails_Sent__c = 1;
                }
                else
                {
                    mapCases.get(e.ParentId).Number_of_Emails_Sent__c += 1;
                }
                // TO PREVENT VALIDATION RULE ISSUE 
                //                if (mapCases.get(e.ParentId).Status == 'New')
                //                {
                //                    mapCases.get(e.ParentId).Status = 'Working';
                //                }
            }          
        }
        
        // IF THERE ARE ANY CASES TO UPDATE, COMMIT
        if (mapCases.Size() > 0)
        {
            update mapCases.values();
        }
        
    }
    
    // CASE FLAGS METHOD TO SET ON INBOUND EMAIL AND CLEAR ON OUTBOUND EMAIL
    private void setClearFlagOnEmail(List<EmailMessage> newTrigger)
    {
        
        system.debug('emailMsgsMap : '+emailMsgsMap);
        
        system.debug(' *** ENTERING NI_EmailMessage_TriggerHandler.setClearFlagOnEmail() ' );
        system.debug('newTrigger size : '+newTrigger.size());
        
        List<Case> casesListToSet = new List<Case>();
        Set<Id> caseIdsToSet = new Set<Id>();
        List<Case> casesListToClear = new List<Case>();
        Set<Id> caseIdsToClear = new Set<Id>();
        List<String> emailIdList = new List<String>();
        NI_Case_TriggerHandler caseHandler = new NI_Case_TriggerHandler();        
        AH_CaseFlagPreferences__c caseFlagCustomSetting = new AH_CaseFlagPreferences__c();
        caseFlagCustomSetting = AH_CaseFlagPreferences__c.getOrgDefaults();
        
        //CREATE A LIST TO HOLD VALUES OF COMPANY DOMAIN TO CHECK WHETHER TO CLEAR OR SET
        if (caseFlagCustomSetting.Company_Domain__c != null)
        {
            for (String str : caseFlagCustomSetting.Company_Domain__c.split(','))
            {
                emailIdList.add(str.Trim());
            }
        }
        
        system.debug(' **** emailIdList = ' + emailIdList);
        
        //ITERATE OVER ALL EMAIL MESSAGES TO CHECK IF COMPANY DOMAIN IS LISTED AND SET AND CLEAR ACCORDINGLY
        for (EmailMessage em : newTrigger)
        {
            system.debug(' *** em.ParentId = '+em.ParentId);
            system.debug(' **** em.Subject = ' + em.Subject);
            system.debug(' **** em.RelatedToId = ' + em.RelatedToId);
            system.debug(' **** em.ToAddress = ' + em.ToAddress);
            //system.debug(' **** em.TextBody = ' + em.TextBody);
            
            system.debug(' **** em.Incoming = ' + em.Incoming);
            //system.debug(' **** em.FromAddress.substringafter("@") = ' + em.FromAddress.substringafter('@')); 
            //system.debug(' **** emailIdList.contains(em.FromAddress.substringafter("@")) = ' + emailIdList.contains(em.FromAddress.substringafter('@'))); 
            system.debug(' **** caseFlagCustomSetting.Set_On_Inbound_Email__c = ' + caseFlagCustomSetting.Set_On_Inbound_Email__c);       
            system.debug(' **** caseFlagCustomSetting.Clear_on_Outbound_Email__c = ' + caseFlagCustomSetting.Clear_on_Outbound_Email__c); 
            
            
            String Subject = '';
            Subject = em.Subject;
            
            String ToAddress = '';
            ToAddress = em.ToAddress;
            
            String txtBody = '';
            if (em.TextBody.length() > 14)
            {
                txtBody = em.TextBody.substring(0, 15);
            }
            
            txtBody = txtBody.replace('\n','');
            
            String str = em.ParentId + '___' + 	Subject	+ '___' +	ToAddress	+ '___' + txtBody;

            system.debug('This string is not present .... str : '+str);
            
            // IF EMAIL LIST DOES NOT CONTAIN 'FROM' EMAIL ADDRESS, SET THE FLAG
            if (em.FromAddress != null &&
                caseFlagCustomSetting.Set_On_Inbound_Email__c == true && 
                (!emailIdList.contains(em.FromAddress.substringafter('@'))) && 
                em.Incoming == true)
            {
                caseIdsToSet.add(em.ParentId);
            }
            else 	
            {
                // ADDED BY SHASHIKANT ON 04/07/2002 FOR CASE MERGE ISSUE
                if (!emailMsgsMap.containsKey(str))
                {
                    // ELSE IF EMAIL LIST CONATINS 'FROM' EMAIL ADDRESS, CLEAR THE FLAG
                    if (em.FromAddress != null &&
                        caseFlagCustomSetting.Clear_on_Outbound_Email__c == true && 
                        (emailIdList.contains(em.FromAddress.substringafter('@'))) && 
                        em.Incoming == false)
                    {
                        caseIdsToClear.add(em.ParentId);
                    }
                }
                
            }
        }

        system.debug('caseIdsToSet size : '+caseIdsToSet.size()+'....caseIdsToSet : '+caseIdsToSet);
        system.debug('caseIdsToClear size : '+caseIdsToClear.size()+'....caseIdsToClear : '+caseIdsToClear);
        
        //IF caseIdsToSet IS NOT EMPTY CALL setCaseFlagRelatedData METHOD OF NI_Case_TriggerHandler CLASS
        if (!caseIdsToSet.isEmpty())
        {
            casesListToSet = [SELECT Id, BusinessHoursId, CaseNumber, CreatedById, CreatedDate, Owner.Id, Owner.Name, RecordTypeId, Status, 
                              AH_Case_Flag_Business_Age__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, AH_Flag__c, AH_Flag_BH__c, 
                              AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, 
                              AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, 
                              AH_Initial_response__c, AH_Initial_Response_Business_Hours__c, Todays_End_Time__c, Todays_Start_Time__c 
                              FROM Case
                              WHERE Id IN : caseIdsToSet 
                              AND AH_Case_Flagged_Date__c = null
                              AND Status != 'New'];
            
            system.debug(' **** casesListToSet.size() = ' + casesListToSet.size());   
            
            if (!casesListToSet.isEmpty())
            {
                caseHandler.setCaseFlagRelatedData(casesListToSet, true, 'Email Received');
            }   
        }
        
        //IF caseIdsToClear IS NOT EMPTY CALL clearCaseFlagRelatedData METHOD OF NI_Case_TriggerHandler CLASS
        if (!caseIdsToClear.isEmpty())
        {
            casesListToClear = [SELECT Id, BusinessHoursId, CaseNumber, CreatedById, CreatedDate, Owner.Id, Owner.Name, RecordTypeId, Status, 
                                AH_Case_Flag_Business_Age__c, AH_Case_Flagged_Date__c, AH_Enable_Case_Flag__c, AH_Flag__c, AH_Flag_BH__c, 
                                AH_Case_Flags_Age_1_Hours__c, AH_Case_Flags_Age_2_Hours__c, AH_Case_Flags_Age_3_Hours__c, AH_Case_Flags_Age_4_Hours__c, 
                                AH_CaseFlagsEscalationTime_1__c, AH_CaseFlagsEscalationTime_2__c, AH_CaseFlagsEscalationTime_3__c, AH_CaseFlagsEscalationTime_4__c, 
                                AH_Initial_response__c, AH_Initial_Response_Business_Hours__c, Todays_End_Time__c, Todays_Start_Time__c 
                                FROM Case
                                WHERE Id IN : caseIdsToClear 
                                AND AH_Case_Flagged_Date__c != null
                                AND Status != 'New'];
            
            system.debug(' **** casesListToClear.size() = ' + casesListToClear.size()); 
        
            if (!casesListToClear.isEmpty())
            {
                caseHandler.clearCaseFlagRelatedData(casesListToClear, true, 'Email Sent');
            }
        }
        
        system.debug(' *** EXITING NI_EmailMessage_TriggerHandler.setClearFlagOnEmail() ');
        
    }
    
    
}