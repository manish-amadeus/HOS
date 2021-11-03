/***********************************************************************************************
Name            : AH_Trust_Outage_Trigger_Handler
Author          : Shashikant Nikam
Created Date    : 05/16/2018
Last Mod Date   : 12/13/2018
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : This class handles all the trigger code for the NI_Trust_Outage object
                :
                :
************************************************************************************************/
public class AH_Trust_Outage_Trigger_Handler {

    public void onBeforeUpdate(List<NI_Trust_Outage__c> newTrigger,  Map<Id, NI_Trust_Outage__c> oldMapTrigger){

        // ITERATE OVER NEW TRIGGER
		for (NI_Trust_Outage__c incident : newTrigger)
        {
            if (!NI_FUNCTIONS.bypassTriggerCode('OUTAGE NOTIFICATION'))
            {
                // IF STATUS = RESOLVED, SET Send Notification = FALSE
                if (incident.Status__c != NULL && incident.Status__c != oldMapTrigger.get(incident.id).Status__c)
                {
                    if (incident.Status__c == 'Resolved'){
                        incident.Send_Notifications__c = FALSE;
                    }
                }
            }
        }
    }
    
    public void OnAfterUpdate(List<NI_Trust_Outage__c> newTrigger,  Map<Id, NI_Trust_Outage__c> oldMapTrigger) {
        
        if (!NI_FUNCTIONS.bypassTriggerCode('OUTAGE NOTIFICATION')) {
        	// CALL METHOD TO HANDLE STATUS UPDATE NOTIFICATIONS
			sendNotifications(newTrigger, oldMapTrigger);
        }
    }

    
    // =============================================================================
    //  		TRIGGER FUNCTIONS
    // =============================================================================
    
    private void sendNotifications(List<NI_Trust_Outage__c> newTrigger,  Map<Id, NI_Trust_Outage__c> oldMapTrigger){
        
        NI_Trust_Outage_Email__c outage_CustSetting = NI_Trust_Outage_Email__c.getInstance();

        // RETRIEVE RECIPIRENT'S ADDRESS
        List<String> bccAddresses = new List<String>();
        if (outage_CustSetting.Outgoing_Addresses__c != NULL){
			bccAddresses = outage_CustSetting.Outgoing_Addresses__c.split(',');
        }
        
        // RETRIEVE ACCOUNT & Contact ID HERE 
        Account acc = [SELECT ID, (select id, name from Contacts where Name = 'Dummy Contact') FROM ACCOUNT WHERE NAME = 'Amadeus Hospitality Business Systems'];
        
        SET<ID> OutageIDS = new SET<ID>();
        SET<id> setRecordTypeIds = new SET<id>();
        List<String> lstRecordtypes = new List<String>();
        List<AH_Trust_Outage_Mail_Alert__c> mailAlertList = new List<AH_Trust_Outage_Mail_Alert__c>();
        
        // GET REPLY TO ADDRESS ID 
        String ReplytoAddressId = '';
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: outage_CustSetting.Reply_To_Address__c];
        if ( owea.size() > 0 ) {
            ReplytoAddressId = String.valueOf(owea.get(0).Id);
        }
        
        // ACCESS VALID RECORD TYPES FROM 'NI Trust Outage' CUSTOM SETTING
        if (outage_CustSetting.Record_Types__c != NULL) {
        	lstRecordtypes = String.valueOf(outage_CustSetting.Record_Types__c).split(',');
        }
        
        // GET ALL THE RECORDTYPES FORM 'NI_Trust_Outage__c' object
        Map<String, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.NI_Trust_Outage__c.getRecordTypeInfosByName();
        for (String recType : lstRecordtypes)
        {
            if (recordTypesMap.containsKey(recType)) 
			{
            	Schema.RecordTypeInfo rr = recordTypesMap.get(recType);
            	setRecordTypeIds.Add(rr.getRecordTypeId());
            }
        }

        // CREATE SET OF TEMPLATE NAMES FROM CUSTOM SETTING
        Set<String> TemplateNames = new Set<String>();
        TemplateNames.add(outage_CustSetting.Status_New__c);
        TemplateNames.add(outage_CustSetting.Status_Open_Stage_1__c);
		TemplateNames.add(outage_CustSetting.Status_Open_Stage_2__c);
        TemplateNames.add(outage_CustSetting.Status_Resolved__c);

        // RETRIEVE ID & NAME OF EMAIL TEMPLATES 
		Map<ID, EmailTemplate> emailTemps = new Map<ID, EmailTemplate>([SELECT Name FROM EmailTemplate where Name in : TemplateNames]);
        
        if (!emailTemps.isEmpty()) 
        {
            // CREATE A MAP OF OUTAGE ID to CORRESPONDING EMAIL TEMPLATE ID
            Map<String, String> outageIDtoTempID = new Map<String, String>();
            for (ID TemplateId : emailTemps.keyset())
            {
                if (emailTemps.get(TemplateId).Name == 'Amadeus Hospitality Incident - New' ){
                    outageIDtoTempID.put('New', TemplateId);
                } 
                else if (emailTemps.get(TemplateId).Name == 'Amadeus Hospitality Incident - Update'){
                    outageIDtoTempID.put('Open Stage 1', TemplateId);
                    outageIDtoTempID.put('Open Stage 2', TemplateId);
                } 
                else if (emailTemps.get(TemplateId).Name == 'Amadeus Hospitality Incident - Resolved'){
                    outageIDtoTempID.put('Resolved', TemplateId);
                } 
            }
            //system.debug('outageIDtoTempID : '+outageIDtoTempID);
            
            for (NI_Trust_Outage__c outage : newTrigger)
            {
                if (((outage.Status__c != NULL && outage.Status__c != oldMapTrigger.get(outage.id).Status__c)
                     || outage.Workflow_Triggered_Time__c != oldMapTrigger.get(outage.id).Workflow_Triggered_Time__c 
                     || (outage.Severity__c != oldMapTrigger.get(outage.id).Severity__c))
                    && setRecordTypeIds.contains(outage.RecordTypeID))
                {
                    AH_Trust_Outage_Mail_Alert__c mailAlert = new AH_Trust_Outage_Mail_Alert__c();
                    mailAlert.NI_Trust_Outage_SF_ID__c = outage.id;
                    mailAlert.Outage_Status__c = outage.Status__c;
                    
                    // CALCULATE THE DATE TO BE SET IN AH Trust Outage Mail Alert SET FOR TIME TRIGGERED WORKFLOW 
                    // NOW() - 1/(60*24) x (60 - minutes from custom settings)
                    Double mainFactor = Double.valueOf(1.0/(60*24));
                    Double multiplyFactor = 0.0;
                    if (outage.Severity__c == '1 - Critical'){
                        multiplyFactor = 60 - Double.valueof(Integer.valueOf(outage_CustSetting.Delay_Time_Severity_1__c) / 60 );
                    }
                    else if (outage.Severity__c == '2 - Urgent'){
                        multiplyFactor = 60 - Double.valueof(Integer.valueOf(outage_CustSetting.Delay_Time_Severity_2__c) / 60 );
                    }
                    Double minusFactor = mainFactor * multiplyFactor;
                    Datetime dt = system.NOW() - minusFactor;
                    
                    mailAlert.WF_Trigger_Time__c = dt;
                    
                    // IF SEVERITY IS CRITICAL / SERIOUS THEN ONLY NOTIFICATION MAILS WILL BE SENT
                    if (outage.Severity__c == '1 - Critical' || outage.Severity__c == '2 - Urgent') {
                        
                        // SEND MAIL WHEN STATUS CHANGED FROM "NEW" to "OPEN STAGE 1"
                        if (outage.Status__c == 'Open Stage 1' && oldMapTrigger.get(outage.id).Status__c == 'New' 
                            && outage.Send_Notifications__c == TRUE)
                        {
                            mailAlertList.add(mailAlert);
                            ID templateId = emailTemps.get(outageIDtoTempID.get(oldMapTrigger.get(outage.id).Status__c)).id;
                            sendMail(acc.Contacts[0].id, bccAddresses, ReplytoAddressId, templateId, outage.id);
                        }
                        // SEND MAIL WHEN STATUS = "OPEN STAGE 1" OR "OPEN STAGE 2"
                        else if ((outage.Status__c == 'Open Stage 1' || outage.Status__c == 'Open Stage 2')
                                 && outage.Send_Notifications__c == TRUE) 
                        {
                            mailAlertList.add(mailAlert);
                            ID templateId = emailTemps.get(outageIDtoTempID.get(outage.Status__c)).id;
                            sendMail(acc.Contacts[0].id, bccAddresses, ReplytoAddressId, templateId, outage.id);
                        } 
                        // SEND MAIL WHEN STATUS = "RESOLVED"
                        else if (outage.Status__c == 'Resolved' && outage.Status__c != oldMapTrigger.get(outage.id).Status__c
                                 && (outage.Send_Notifications__c == false && 
                                     outage.Send_Notifications__c != oldMapTrigger.get(outage.id).Send_Notifications__c)
                                )
                        {
                            ID templateId = emailTemps.get(outageIDtoTempID.get(outage.Status__c)).id;
                            sendMail(acc.Contacts[0].id, bccAddresses, ReplytoAddressId, templateId, outage.id);
                            system.debug('in resolved if..');
                        }
                    }
                    
                    OutageIDS.add(outage.id);
                }
            }
        }
        
        // DELETE EXISTING AH Trust Outage Mail Alert RECORDS
        if (!OutageIDS.isEmpty()) {
            
            List<AH_Trust_Outage_Mail_Alert__c> lstToDelete = new List<AH_Trust_Outage_Mail_Alert__c>();
            lstToDelete = [select id from AH_Trust_Outage_Mail_Alert__c where NI_Trust_Outage_SF_ID__c IN: OutageIDS];
            if (!lstToDelete.isEmpty()) {
                Database.delete(lstToDelete);
            }
        }
        
        // INSERT NEW AH Trust Outage Mail Alert RECORD
        if (!mailAlertList.isEmpty()) {
            Database.insert(mailAlertList);
        }
    }
    
    // METHOD TO SEND NOTIFICATION MAIL
    private void sendMail(ID contactID, List<String> bccAddresses, String ReplytoId, ID tId, ID outageID)
    {
        if (!bccAddresses.isEmpty()){
			messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
			mail.setTemplateId(tId);
            mail.setWhatId(outageID);
            mail.setTargetObjectId(contactID); 
            if (ReplytoId!= NULL && ReplytoId != '') {
            	mail.setOrgWideEmailAddressId(ReplytoId);
            }
            mail.setBccAddresses(bccAddresses);
            // REMOVE EMAIL SIGNATURE
            mail.setUseSignature(false);
            // TRACK MAILS IN ACTIVITY HISTORY ON AH Trust Incident OBJECT
            mail.setSaveAsActivity(true);
            messaging.Email[] mails = new messaging.Email[]{mail};
            messaging.sendEmail(mails);
        }
        system.debug('Mail Sent...');
    }
}