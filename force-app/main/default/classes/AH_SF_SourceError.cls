/****************************************************************************************
Name            : AH_SF_SourceError Class
Author          : Sean Harris
Created Date    : 06/03/2018
Last Mod Date   : 06/03/2018 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Email Service class that validates, parses & logs errors emailed from Salesforce 
                : (forwarded via MS exchange rule)
				: FEATURES INCLUDE:
                : Filters any errors from a sandbox envorment.
				: Removes header & footer text. (Set via custom labels)
				: Removes email subject prefixes (RE:, FW:, [EXT])
				: Parses user record "error victim" from ID in email body
				: Parsed affected component name an links to Salesforce Source record
				: 
******************************************************************************************/
global class AH_SF_SourceError implements Messaging.InboundEmailHandler 
{

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
    
        // DECLARE THE RESULT VARIABLE ===========================================================================================================
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        string sFrom = email.fromName;
        string sAddr = email.fromAddress;
        string sSubj = cleanSubject(email.subject);
system.debug(' *** Cleaned Subject = ' + sSubj);         
        string sBody = cleanBody(email.plainTextBody);
		string sType = '';
        string sName = '';
        datetime sHapp = system.now();
        Id idSFSC = null;
        Id idUser = null;
        
        if (!isValidEmail(sSubj))
        {
system.debug(' *** Email did not pass validation');             
            return null;
        }      
system.debug(' *** Email passed validation');  
        
		sType = getComponentType(sSubj, sBody);
system.debug(' *** Component Type = ' + sType); 
        
        sName = parseComponentName(sType, sSubj);
system.debug(' *** Component Name = ' + sName); 
        
        List<AH_SFDC_Source_Control__c> sc = new List<AH_SFDC_Source_Control__c>(
            [SELECT Id, API_Name__c 
             FROM AH_SFDC_Source_Control__c 
             WHERE Salesforce_Source_Type__c =: sType 
             AND API_Name__c =: sName]
        );
        
system.debug(' *** Number of Matching AH_SFDC_Source_Control__c Records = ' + sc.size());  
        
        if (sc.size() != 1)
        {
system.debug(' *** Did not find just 1 AH_SFDC_Source_Control__c record. Exiting.');             
            return null;
        }

        idSFSC = sc[0].Id;
system.debug(' *** AH_SFDC_Source_Control__c Id = ' + idSFSC); 
        
        idUser = parseErrorVictimId(sType, sBody);
system.debug(' *** Affected User Id = ' + idUser); 
        
string msg = ' *** sType = ' + sType + '\n idSFSC = ' + idSFSC + '\n idUser = ' + idUser + ',\n\n From = ' + sFrom + ',\n sAddr = ' + sAddr + ',\n sSubj = ' + sSubj + ',\n sBody = ' + sBody;        
system.debug(msg);        
// DEV LOGGER
// string msg = 'sType = ' + sType + 'idSFSC = ' + idSFSC + '\n idUser = ' + idUser + ',\n\n From = ' + sFrom + ',\n sAddr = ' + sAddr + ',\n sSubj = ' + sSubj + ',\n sBody = ' + sBody;
// NI_Error_Logger.WriteToLog(msg, sName, 'AH_SF_SourceError', 'DEBUG');                
                
        AH_SFDC_Source_Errors__c e = new AH_SFDC_Source_Errors__c();
        e.Description__c = sSubj;
        e.Error_Message__c = sBody;
        e.Happened_At__c = sHapp;
        e.IsFixed__c = false;
        e.Salesforce_Source_Control__c = idSFSC;
        e.User__c = idUser;  
        insert e;

        return result;
        
    }
    
    private boolean isValidEmail(string s)
    {
        boolean isValid = false;        
        if (
            s.contains('Sandbox:') == false && 										// NOT FROM A SANDBOX
            (s.contains('Developer script exception from Amadeus Hospitality') ||	// APEX CLASS OR TRIGGER ERROR
             s.contains('Error Occurred During Flow'))								// PROCESS BUILDER ERROR
            		//s.contains('Salesforce Email Processor') || // EMAIL SERVICES ERROR
        )
        {
            isValid = true;       
        }
        return isValid;
    }

    private string getComponentType(string s, string b)
    {
        string t = 'Unknown';
        if (s.contains('Developer script exception from Amadeus Hospitality'))
        {
            if (b.contains('Apex script unhandled trigger exception'))
            {
                t = 'Apex Trigger';
            }
			if (b.contains('Apex script unhandled exception'))
            {
                t = 'Apex Class';
                if (b.contains('Visualforce Page: /apex/'))
                {
                    t = 'Visualforce Page';
                }
            }            
        }
        else 
        {
            if (s.contains('Error Occurred During Flow'))
            {
                t = 'Process Builder';
            }
        }
        return t;
    }
    
    private string parseComponentName(string t, string s)
    {
        string sTmp;
        string n = '';
		if (t == 'Apex Class')
        { 
            sTmp = s.replace('Developer script exception from Amadeus Hospitality :', '').trim();
            n = sTmp.substringBetween('\'');
        }
        if (t == 'Visualforce Page')
        { 
            integer i = 0;
            integer j = 0;
            i = s.indexOf('Developer script exception from Amadeus Hospitality :') + 53;
            sTmp = s.substring(i).trim();
            j = sTmp.indexOf(':');
            n = sTmp.substring(0, j).trim();
        }
        if (t == 'Apex Trigger')
        {
            sTmp = s.replace('Developer script exception from Amadeus Hospitality :', '').trim();
            n = sTmp.substring(0, sTmp.indexOf(':')).trim();            
        }
        if (t == 'Process Builder')
        {
            sTmp = s.replace('Error Occurred During Flow', '').trim();
            sTmp = sTmp.replace('"', '').trim();
            n = sTmp.substring(0, sTmp.indexOf(':'));         
        }
        return n;
    }

    private Id parseErrorVictimId (string t, string b)
    {
		string sTmp = '';
        Id vid;
        if (t == 'Apex Class')
        {        
			sTmp = b.substring(b.indexOf('user/organization: ') + 19).trim().substring(0, 15); 
        }
        if (t == 'Apex Trigger')
        {
        	sTmp = b.substring(b.indexOf('user/organization: ') + 19).trim().substring(0, 15); 
        }
        if (t == 'Visualforce Page')
        {        
			sTmp = b.substring(b.indexOf('user/organization: ') + 19).trim().substring(0, 15); 
        }
        if (t == 'Process Builder')
        {
        	sTmp = b.substring(b.indexOf('(005') + 1).trim().substring(0, 15);			
        }
        if (sTmp != '')
        {
            try
            {
                vid = (Id)sTmp;
            }
            catch (exception ex)
            {            
            }            
        }
        return vid;
    }
    
    private string cleanBody(string b)
    {
        string strBody = b.trim();
		strBody = strBody.removeStartIgnoreCase(Label.Source_Error_Header);        
        strBody = strBody.removeEndIgnoreCase(Label.Source_Error_Disclaimer);
        strBody = strBody.trim();
        return strBody;
    }

    private string cleanSubject(string s)
    {
        string strSubject = s.trim();
		strSubject = strSubject.removeStartIgnoreCase('FW:').trim();        
		strSubject = strSubject.removeStartIgnoreCase('RE:').trim(); 
        strSubject = strSubject.removeStartIgnoreCase('[EXT]').trim(); 
        strSubject = strSubject.trim();
        return strSubject;
    }   
    
}