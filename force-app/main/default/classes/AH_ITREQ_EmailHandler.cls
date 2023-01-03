/****************************************************************************************
Name            : AH_ITREQ_EmailHandler Class
Author          : Sean Harris
Created Date    : 02/17/2017
Last Mod Date   : 05/26/2017
Last Mod By     : Stuart Emery
NICC Reference  : NICC-022094
Description     : Email Handler for creating Internal IT Request records
                : 
                : 
******************************************************************************************/
global class AH_ITREQ_EmailHandler implements Messaging.InboundEmailHandler 
{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {	
        // DECLARE THE RESULT VARIABLE ===========================================================================================================
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        Boolean bRefIdFound = false;
        Boolean bFoundUser = false;
        Boolean bIsVoiceMail = false;
        string strErrText = '';
        AH_Internal_IT_Request__c iiReq;
        
        // GET EMAIL BODY ======================================================================================================================
        String strEmailBody = EncodingUtil.urlDecode(email.plainTextBody, 'UTF-8');
        
        // USE HTML BODY IF PRESENT ELSE PLAINTEXT =============================================================================================
        if (email.htmlBody != null)
        {
			// strEmailBody = EncodingUtil.urlDecode(email.htmlBody, 'UTF-8');
        } 


        // LOOK FOR REF_ID TO SEE IF EMAIL NEEDS TO BE APPENDED TO EXISTING IT REQ ===============================================================
        String strRefIdParse = email.subject + ' ' + strEmailBody;
        String strRefId = '';
        
        if ((strRefIdParse.Contains('[ref:_')) && (strRefIdParse.Contains(':ref]')))
        {
            Integer iStartPos = strRefIdParse.indexOf('[ref:_', 0); 
            Integer iEndPos = strRefIdParse.indexOf(':ref]', 0) + 5;
            strRefId = strRefIdParse.Substring(iStartPos, iEndPos);
            strRefId = strRefId.Substring(18, 23) + '00000' + strRefId.Substring(24, 29);
            bRefIdFound = true;
        }
        
        
        // VERIFY IF THIS IS COMING FROM THE HELPDESK VOICEMAIL ================================================================================
        if (email.fromAddress == 'ITHelpDesk@newmarketinc.com')
        { 
            bIsVoiceMail = true;
        } 
        
        // ATTEMPT TO FIND RELATED SALESFORCE USER =============================================================================================
        //3/14/2017 - UPDATED BY STUART EMERY TO ONLY INCLUDE USERS THAT HAVE THE 'STANDARD' USER TYPE
        List<User> lstUser = new List<User>([SELECT Id, Name, Email FROM User WHERE UserType = 'Standard' AND (Name = : email.fromName OR Email = : email.fromAddress) LIMIT 1]);
        
        if (lstUser.Size() == 1)
        {
            bFoundUser = true;
        }        
        
  
        // IF THE EMAIL IS A RELY TO AN EXITING REQUEST
        if (bRefIdFound)
        {
system.debug('strRefId (parsed) = ' + strRefId);   
            // APPEND TO IT REQUEST  ===========================================================================================================
            iiReq = [SELECT Id, OwnerId FROM AH_Internal_IT_Request__c WHERE Id = : strRefId];

            // =================================================================================================================================
            // IT REQUEST NOTE METHOD
            // =================================================================================================================================

            string strNoteBody = 'From: ' + email.fromName + ' (' + email.fromAddress + ') \n\n' + strEmailBody;

            try 
            {
// WRITE TO CHATTER FEED HERE ...
                FeedItem post = new FeedItem();
                post.ParentId = iiReq.Id; 
                post.Body = strNoteBody;
                insert post;

            } 
            catch (DMLException e) { NI_Error_Logger.WriteToLog('Related Record Work Order ID: ' + iiReq.Id + ', \nError Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'Internal_IT_Request__c', 'AH_ITREQ_EmailHandler', 'INSERT'); } 
            
        }
        else // CREATE IT REQUEST ==============================================
        {
            try
            {
                
				iiReq = new AH_Internal_IT_Request__c();
                
//                String strHeaders = 'email.headers';
//                for (Messaging.InboundEmail.header eh : email.headers)
//                {
//                    strHeaders += eh.Name + ' = ' + eh.Value + ' <br/>';
//                }            
                
                if (lstUser.Size() == 1)
                {
                    iiReq.Requester__c = lstUser[0].Id;
                    iiReq.OwnerId = lstUser[0].Id; //ADDED BY STUART EMERY ON 3/14/2017
                }
                

                iiReq.Inbound_Email_Name__c = email.fromName; 
                iiReq.Inbound_Email_Address__c = email.fromAddress; 
//                iiReq.Inbound_Header__c = strHeaders; 
                iiReq.Subject__c = email.subject; 
           
                iiReq.Description__c = strEmailBody.Replace('\n', '<br/>'); 
                
                if (bIsVoiceMail) 
                { 
                    iiReq.Priority__c = '* Critical'; 
                } 
                else 
                { 
                    iiReq.Priority__c = '2 - Normal (5 Business Days)'; 
                } 
                
                insert iiReq; 

            }
            catch (DMLException e) { NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'Internal_IT_Request__c', 'AH_ITREQ_EmailHandler', 'INSERT'); }
        }
        
        // PROCESS ATTACHMENTS ==============================================
        // create a new attachment  attachment may be text or binary
        List<Attachment> attachments = new List<Attachment>();
        
        if (email.binaryAttachments != null)
        {
            for (Messaging.InboundEmail.BinaryAttachment emailAttachment:email.binaryAttachments)
            {
                Attachment attachment = new Attachment();
                attachment.parentId = iiReq.id;
                attachment.body = emailAttachment.body;
                attachment.name = emailAttachment.fileName; 
                attachments.add(attachment);
            }
        }
        
        if (email.textAttachments != null)
        {
            for (Messaging.InboundEmail.TextAttachment emailAttachment:email.textAttachments)
            {
                Attachment attachment = new Attachment();
                attachment.parentId = iiReq.id;
                attachment.body = blob.valueOf(emailAttachment.body);
                attachment.name = emailAttachment.fileName; 
                attachments.add(attachment);
            }
        }
        
        // insert the attachments
        if (attachments.size() > 0)
        {
            try
            {
                insert attachments;
            } 
            catch (DMLException e){ NI_Error_Logger.WriteToLog('Error Type: ' + e.getTypeName() + ', \nCause: ' + e.getCause() + ', \nLine Number: ' + e.getLineNumber() + ', \nError Message: ' + e.getMessage() + ' \n', 'Attachment', 'AH_ITREQ_EmailHandler', 'INSERT'); }
        }
            
        return result;
  
   }

}