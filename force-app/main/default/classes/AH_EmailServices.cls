/****************************************************************************************
Name            : AH_EmailServices
Author          : Sean Harris
Created Date    : 07/08/2021
Modified Date   : 07/08/2021
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Email service class that parses ref:_ tag and creates an emailMessage
				: record and puts attachment on related record.
				: 
******************************************************************************************/
global class AH_EmailServices implements Messaging.InboundEmailHandler 
{    
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)  
    {
        
        // ====================================================================================
        
        system.debug(' *** SUBJECT: ' + email.subject);        
        system.debug(' *** BODY (html): ' + email.htmlBody);
        system.debug(' *** BODY (text): ' + email.plainTextBody);
        system.debug(' *** FROM NAME: ' + email.fromName);
        system.debug(' *** FROM ADDRESS: ' + email.fromAddress);
        system.debug(' *** TO ADDRESS: ' + email.toAddresses[0]);
        system.debug(' *** inReplyTo: ' + email.inReplyTo);
        
        // ====================================================================================
        
        // INBOUND EMAIL VARIABLE
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult(); 

        // RECORD VARIABLES
        Id recordId;
        
        // STRING VARIABLES
        String strEmailSubject = '';
        String strEmailTEXTBody = ''; 
        String strEmailHTMLBody = '';
        String strEmailMessageBody = '';
        String strRefIdParse = '';
        String strObjectAPIName = '';
        String strSOQL = '';
        
        // BOOLEAN VARIABLES
        Boolean bIsReply = false;
        
        // COLLECTION VARIABLES
        List<ContentVersion> lstCVs;
        List<ContentDocumentLink> lstCDLs;
            
        
        // PARSE SUBJECT
        if (email.subject != null && email.subject != '')
        {
            strEmailSubject = email.subject;
        }

        // CHECK FOR USER OPT IN/OUT REQUESTS IN EMAIL SUBJECT
        if (strEmailSubject.toUpperCase() == 'OPT IN' || strEmailSubject.toUpperCase() == 'OPT-IN' || strEmailSubject.toUpperCase() == 'OPT OUT' || strEmailSubject.toUpperCase() == 'OPT-OUT')
        {
            try
            {
                
                User usr = [SELECT Id, Email, AH_Email_Services_Reply_Opt_Out__c FROM User WHERE UserType = 'Standard' AND (Name =: email.fromName OR Email =: email.fromAddress) LIMIT 1];   
                
                if (usr.AH_Email_Services_Reply_Opt_Out__c == true && (strEmailSubject.toUpperCase() == 'OPT IN' || strEmailSubject.toUpperCase() == 'OPT-IN'))
                {
                    usr.AH_Email_Services_Reply_Opt_Out__c = false; 
                    update usr;
                    SendOptInOutNotification(usr.Email, 'OPT IN');
                }
                
                if (usr.AH_Email_Services_Reply_Opt_Out__c == false && (strEmailSubject.toUpperCase() == 'OPT OUT' || strEmailSubject.toUpperCase() == 'OPT-OUT'))
                {
                    usr.AH_Email_Services_Reply_Opt_Out__c = true;
                    update usr;
                    SendOptInOutNotification(usr.Email, 'OPT OUT');
                }
                
                result.success = true;
                return result;  
                
            }
            catch (Exception e)
            {
                NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'AH_EmailServices', 'AH_EmailServices', 'INSERT'); 
                result.success = false;
                return result; 
            }
            
        }
        
        // DETERMINE IF THIS EMAIL IS A REPLY
        if (strEmailSubject.toUpperCase().contains('RE:'))
        {
            bIsReply = true;           
        }
        
        // PARSE BODIES
        if (email.plainTextBody != null && email.plainTextBody != '')
        {
            strEmailTEXTBody = EncodingUtil.urlDecode(email.plainTextBody, 'UTF-8');
        }
        
        if (email.htmlBody != null && email.htmlBody != '')
        {
            strEmailHTMLBody = email.htmlBody;
        }
        
        if (strEmailTEXTBody != '')
        {
            strRefIdParse = strEmailSubject + ' ' + strEmailTEXTBody;
            strEmailMessageBody = strEmailTEXTBody;
        }
        else
        {
            strRefIdParse = strEmailSubject + ' ' + strEmailHTMLBody;
            strEmailMessageBody = strEmailHTMLBody;
        }

        // ====================================================================================
        
        // TRY TO PARSE REF:_ RECORD ID AND CREATE AN EMAILMESSAGE RECORD
        try
        {
            
            result.success = false;
            
            // PARSE [REF:_] (RECORD ID) FROM EMAIL SUBJECT OR BODY
            if ((strRefIdParse.Contains('[ref:_')) && (strRefIdParse.Contains('_:ref]')))
            {
                Integer iStartPos = strRefIdParse.indexOf('[ref:_', 0) + 6; 
                Integer iEndPos = strRefIdParse.indexOf('_:ref]', 0);
                recordId = (Id)strRefIdParse.Substring(iStartPos, iEndPos).trim(); 
                strObjectAPIName = String.valueOf(recordId.getSobjectType());  
            }           
            
            system.debug(' *** PARSED REF:_ ID = ' + recordId);

            // CREATE EmailMessage RECORD
            EmailMessage em = new EmailMessage();
            if (strObjectAPIName == 'Case')
            {
                em.ParentId = recordId;
            }
            em.RelatedToId = recordId;
            em.FromName = email.fromName;
            em.FromAddress = email.fromAddress;
            em.ToAddress = email.toAddresses[0]; 
            em.Subject = email.subject;
            
            // ADD BUFFER SPACES
            if (strEmailTEXTBody.length() < 15 || strEmailHTMLBody.length() < 15)
            {
                strEmailTEXTBody += '                  ';
                strEmailHTMLBody  += '                  ';
            }
            
system.debug(' *&* strEmailTEXTBody = ' + strEmailTEXTBody);            
system.debug(' *&* strEmailHTMLBody = ' + strEmailHTMLBody);      

            em.TextBody = strEmailTEXTBody; 
            em.HtmlBody = strEmailHTMLBody; 
            
			em.Incoming = true;
            em.MessageDate = System.now();
            em.Status = '3';
            
            system.debug(' *** EMAILMESSAGE = ' + em);
            
            insert em;

            lstCVs = new List<ContentVersion>();
            
            // CREATE CONTENT DOCS FROM ATTACHMENTS
			if (email.binaryAttachments != null)
            {
				for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments)
				{
					ContentVersion cv = new ContentVersion();
					cv.Title = bAttachment.fileName;
					cv.PathOnClient = bAttachment.fileName; 
                    cv.VersionData = bAttachment.body; 
                    cv.Origin = 'H';
                    cv.ContentDocumentId = null;
					lstCVs.add(cv);
				}
			}
            
            // IF ATTACHMENTS WERE FOUND, CREATE THEM AS CONTENT FILES AND RELATE THEM TO RECORD
			if (!lstCVs.isEmpty())
			{
                
                system.debug(' *** FILES TO BE INSERTED = ' + lstCVs.size());
                
				database.insert(lstCVs);
                
                Set<Id> setCVIDs = new Set<Id>();
                
                List<ContentVersion> lstNewCVs = new List<ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN : lstCVs]);
                
                lstCDLs = new List<ContentDocumentLink>();
                
                for (ContentVersion v : lstNewCVs)
                {
                    ContentDocumentLink cdl = new ContentDocumentLink(); 
                    cdl.LinkedEntityId = recordId; 
                    cdl.ContentDocumentId = v.ContentDocumentId; 
                    cdl.ShareType = 'I'; 
                    system.debug(' *** NEW ContentDocumentLink = ' + cdl); 
                    lstCDLs.add(cdl); 
                }
                
                system.debug(' *** CONTENT DOC LINKS TO BE INSERTED = ' + lstCDLs.size());
                
                database.insert(lstCDLs);
                
			}
            
            if (bIsReply)
            {
                SendReplyNotification(recordId, em.Id, email.fromAddress, strEmailMessageBody); 
            }   
            
            result.success = true;
            
        }
        catch (Exception e)
        {
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'AH_EmailServices', 'AH_EmailServices', 'INSERT'); 
            result.success = false;
        }
        
        system.debug(' *** RESULT = ' + result);
        
        return result;
        
    }

    public void SendReplyNotification(Id RecordId, Id EmailMessageId, String strFromAddress, String strBody) 
    {
        
        List<User> lstUser;
        
        // ATTEMPT TO FIND RECORD OWNER =====================================================================================================
        try
        {
            
            String strSOQL = 'SELECT Id, OwnerId FROM ' + RecordId.getSObjectType().getDescribe().getName() + ' WHERE Id = \'' + RecordId + '\'';
            Sobject obj = Database.query(strSOQL);
            Id owner = (Id)obj.get('OwnerId');        
            lstUser = new List<User>([SELECT Id, Name, Email, AH_Email_Services_Reply_Opt_Out__c FROM User WHERE Id =: owner]);            
    
            system.debug(' *** OBJECT NAME: ' + RecordId.getSObjectType().getDescribe().getName()); 
            system.debug(' *** RECORD ID: ' + RecordId);   
            system.debug(' *** EMAIL RECIPIENT NAME: ' + lstUser[0].Name);    
            system.debug(' *** EMAIL RECIPIENT NAME: ' + lstUser[0].Email);
            
            if (lstUser[0].AH_Email_Services_Reply_Opt_Out__c == true)
            {
                return;		// USER HAS OPTED OUT OF GETTING AN EMAILS ALERT
            }
            
        }
        catch (Exception e)
        {
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'AH_EmailServices', 'AH_EmailServices', 'INSERT'); 
            return;
        }
 
        
        if (lstUser.Size() == 1)
        {
            
            Messaging.SendEmailResult[] sendResults; 
            
            try
            {

                String strResponseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + RecordId;
                
                String EmailBody = '<html>'; 
                EmailBody += '<body>'; 
                EmailBody += '<p>Please follow link below to view response in Salesforce:</p>'; 
                EmailBody += '<br/>'; 
                EmailBody += '<a href="' + strResponseURL + '">' + strResponseURL + '</a>'; 
                EmailBody += '<br/>'; 
                EmailBody += '<div>'; 
                EmailBody += strBody; 
                EmailBody += '</div>'; 
                EmailBody += '</body>'; 
                EmailBody += '</html>'; 
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
                
                message.toAddresses = new String[] { lstUser[0].Email }; 
                message.subject = 'A reply to your email has arrived in Saleforce'; 
                message.setHtmlBody(EmailBody); 
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
                sendResults = Messaging.sendEmail(messages); 
                
            }
            catch (Exception e)
            {
                NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage(), 'AH_EmailServices', 'AH_EmailServices', 'INSERT'); 
            }
            
        }
        
    }

    public void SendOptInOutNotification(String strToAddress, String strChoice) 
    {
        
        Messaging.SendEmailResult[] sendResults; 
        
        try
        {
            
            String EmailBody = '<html>';
            EmailBody += '<body>';
            EmailBody += '<p>You have successfully chosen to ' + strChoice + ' of getting email alert from replies.</p>';
            EmailBody += '<br/>'; 
            if (strChoice == 'OPT IN')
            {
                EmailBody += '<p>Should you wish to STOP receiving alerts, simply send an email to ' + Label.AH_EmailServicesAddress + ' with "OPT OUT" only as the subject.</p>';
            }
            else
            {
                EmailBody += '<p>Should you wish to START receiving alerts, simply send an email to ' + Label.AH_EmailServicesAddress + ' with "OPT IN" only as the subject.</p>';
            }
            EmailBody += '<br/>';
            EmailBody += '</body>';
            EmailBody += '</html>'; 
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            
            message.toAddresses = new String[] { strToAddress };
            message.subject = 'Your AH EmailServices Opt In/Out option has been updated';
            message.setHtmlBody(EmailBody);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            sendResults = Messaging.sendEmail(messages);   
            
        }
        catch (Exception e)
        {
            NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage(), 'AH_EmailServices', 'AH_EmailServices', 'INSERT'); 
        }
        
    }
    
}