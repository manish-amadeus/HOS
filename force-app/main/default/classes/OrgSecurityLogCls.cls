/************************************************************************************************
Name            : OrgSecurityLogCls
Author          : Beth Van Belle
Last Mod Date   : 05/05/2022
Last Mod By     : Beth Van Belle
Description     : Class to create security logs
*************************************************************************************************/
Public With sharing Class OrgSecurityLogCls {
    public static Boolean EnableSecurityLogCreation = false;
    public static final string SecurityLogAccessControlEvent = 'Access Control Event';
    public static final string SecurityLogLoggingEvent = 'Logging Event';
    public static final string SecurityLogInformational = 'Informational';
    public static final string SecurityLogWarning = 'Warning';
    public static final string SecurityLogCritical = 'Critical';
    public static final string SecurityLogASEMPolling = 'ASEM Polling';
    
    public void handle() {
			// Create security logs.
			//Triggers.TriggerParameters.put('EnableSecurityLogCreation','true');
            
			List<OrgSecurityLog__c> securityLogs = new List<OrgSecurityLog__c>();

            if (Trigger.isDelete && Trigger.isBefore) {
                for (OrgSecurityLog__c log : (List<OrgSecurityLog__c>)Trigger.old) {
                    OrgSecurityLog__c securityLog = createLog(
                                                    SecurityLogASEMPolling,
                                                    SecurityLogLoggingEvent,
                                                    SecurityLogCritical,
                                                    'Security Log entry deleted',
                                                    'Security Log ID: ' + log.Id + '\nLog Description: ' + log.Description__c
                                                );
                    securityLogs.add(securityLog);
                }
            
                if(securityLogs.size() > 0) {
                    EnableSecurityLogCreation = true;
                    insert securityLogs;
                    EnableSecurityLogCreation = false;
                }
            }

			if( Trigger.IsInsert)
        	{
            	for (OrgSecurityLog__c osl : (List<OrgSecurityLog__c>)Trigger.New)
	        	{
	        		if(EnableSecurityLogCreation == false){
                        osl.addError('Security Logs cannot be manually created.');
                    }
	        
	        	}
        	}

            if(Trigger.IsUpdate)
        	{
            	for (OrgSecurityLog__c osl : (List<OrgSecurityLog__c>)Trigger.New)
	        	{
	        		OrgSecurityLog__c oldosl = (OrgSecurityLog__c)trigger.oldMap.get(osl.Id);
	        		if(oldosl != null){
                        osl.addError('Security Logs cannot be updated.');
                    }
                    
	        	}
        	}
        }

        Public Static OrgSecurityLog__c createLog (String source, String eventType, 
                                            String severity, String description, String details) {
        return new OrgSecurityLog__c (
            Source__c = source, // What area of the system logged the event
            EventType__c = eventType, // Category of event
            Severity__c = severity, // Security level of event
            Description__c = description, // High level description
            Details__c = details, // Additional details as needed
            UserId__c = UserInfo.getUserId(), // User identification
            LogDate__c = System.now() // Log date when event occurred
                );
            }
    
    }