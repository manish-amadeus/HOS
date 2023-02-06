/****************************************************************************************
Name            : AH_EmailAuthor Class
Author          : Sean Harris
Created Date    : 08/03/2017
Last Mod Date   : 12/01/2022
Last Mod By     : Sean Harris
NICC Reference  : NICC-023217
Description     : Controller for AH_EmailAuthor VF Page
				: UPDATED THIS CLASS WITH ARBITRARY ADDITIONS FOR DEVOPS PROD DEPLOY TESTING
******************************************************************************************/
public class AH_EmailAuthor 
{
    public string strDummyVar = 'DEVOPS TESTING';
    public String recordName { get; set; }
    // URL PARAMETERS
    public String recordID { get; set; }
    public String fromID { get; set; }     
    public String to { get; set; }
    public String toId { get; set; }
    public String additionalTo { get; set; }
    public String cc { get; set; }
    public String bcc { get; set; }
    public String templateID { get; set; }    
    public String subjectText { get; set; }
    public String bodyText { get; set; }

//    public sObject obj { get; set; }
    public string objectName { get; set; }
    
    // VISIBILITY SWITCHES
    public boolean showHeaderBar { get; set; } 
    public boolean showSideBar { get; set; } 
    public boolean isRichTextBody { get; set; } 

    public boolean createTask { get; set; } 
    public String fromAddressSelected { get; set; } 
    public integer fromAddressSelectedIndex { get; set; } 
    public List<selectOption> orgWideEmailOptions { get; set; } 

    public Set<Id> setALI_Ids { get; set; } 
    
    // WRAPPER CLASS LISTS
    public List<attachmentWrapper> lstAttachments {get; set;}    
	
    
    public boolean flagToSendMail;
    private static final String DEL = ';';    
    public String errorMsg{get;set;} 
//    public String successMsg{get;set;}    
    
    
    public AH_EmailAuthor() 
    {
        
system.debug(' ENTERING CONSTRUCTOR...');    

        // RECORD ID
        if (ApexPages.currentPage().getParameters().get('id') != null)
        {
            additionalTo = '';
            cc = '';
            bcc = '';           
            recordID = ApexPages.currentPage().getParameters().get('id');            
			objectName = NI_FUNCTIONS.findObjectNameFromRecordIdPrefix(recordID); 
			if (objectName != '')
            {
                
                // TO ADDRESS
                if (ApexPages.currentPage().getParameters().get('to') != null)
                {
                    String strTo = ApexPages.currentPage().getParameters().get('to');
                    if (strTo.substring(0, 3) == '003')
                    {
                        toId = strTo;
                        to = getNameByContactId(strTo);
                    }
                }                 
                
                // TEMPLATE ID
                if (ApexPages.currentPage().getParameters().get('tid') != null)
                {
                    templateID = ApexPages.currentPage().getParameters().get('tid');
                    Id tid = (Id)templateID;
                    EmailTemplate e = [SELECT Id, Subject, Body, HtmlValue, BrandTemplateId FROM EmailTemplate WHERE Id =: tid];
                    subjectText = e.Subject;
                    if (to != null)
                    {
                    	subjectText = subjectText.replace('{!Contact.Name}', to);
                        subjectText = subjectText.replace('{!Contact.FirstName}', to);
                    }
                    bodyText = e.HtmlValue;
                    isRichTextBody = true;
                    
                    if (e.BrandTemplateId != null)
                    {
                        BrandTemplate t = [SELECT Id, Value FROM BrandTemplate WHERE Id =: e.BrandTemplateId];
                        bodyText = buildTemplate(t.Value, e.HtmlValue);
                        
                        if (to != null)
                        {                        
                            bodyText = bodyText.replace('{!Contact.Name}', to);
                            bodyText = bodyText.replace('{!Contact.FirstName}', to);
                        }
                        
                    }
                    
                }                

                // SOME OBJECTS DO NOT HAVE A Name FIELD THAT CAN BE QUERIED IN SOQL
                string sql = '';
                string strObjectsThatHaveNoNameField = ':Case:';
                List<sObject> lstSObject;
				sObject s;
                string strFields = generateSOQLFields(objectName, subjectText + bodyText);
                
                if (strObjectsThatHaveNoNameField.contains(objectName))
                {
                    sql = 'SELECT Id ' + strFields + ' FROM ' + objectName + ' WHERE Id = \'' + recordID + '\' LIMIT 1';
system.debug(' sql = ' + sql); 
                    lstSObject = Database.query(sql);
                    s = lstSObject[0];
                    recordName = String.valueOf(s.get('Id')); 
                }
                else
                {
system.debug(' sql = ' + sql);                     
                    sql = 'SELECT Id, Name ' + strFields + ' FROM ' + objectName + ' WHERE Id = \'' + recordID + '\' LIMIT 1';
                    lstSObject = Database.query(sql);
                    s = lstSObject[0];
                    recordName = String.valueOf(s.get('Name'));                    
                }
				getOrgWideAddresses();                    
                getAttachments(); 
            }
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This page depends on URL parameters that were not supplied.');
            ApexPages.addMessage(myMsg);
            return;
        }
        
        // URL PARAMETERS =======================================================
        
		// FROM ID
        if (ApexPages.currentPage().getParameters().get('fid') != null)
        {
            fromID = ApexPages.currentPage().getParameters().get('fid');
        }        

        // CC ADDRESS
        if (ApexPages.currentPage().getParameters().get('cc') != null)
        {
            cc = ApexPages.currentPage().getParameters().get('cc');
        } 
        
        // BCC ADDRESS
        if (ApexPages.currentPage().getParameters().get('bcc') != null)
        {
            bcc = ApexPages.currentPage().getParameters().get('bcc');
        } 
        
        // EMAIL SUBJECT
        if (ApexPages.currentPage().getParameters().get('sub') != null)
        {
            subjectText = ApexPages.currentPage().getParameters().get('sub');
        }
        
		// RICH TEXT BODY SWITCH
        isRichTextBody = false;
        if (ApexPages.currentPage().getParameters().get('rtxt') != null)
        {
            string rtxt = ApexPages.currentPage().getParameters().get('rtxt');
            if ((rtxt == 'true') || (rtxt == '1')) 
            {
                isRichTextBody = true;
            }                   
        } 

        // SHOW HEADER BAR
        showHeaderBar = false;        
        if (ApexPages.currentPage().getParameters().get('hb') != null)
        {
            string hb = ApexPages.currentPage().getParameters().get('hb');
            if ((hb == 'true') || (hb == '1')) 
            {
                showHeaderBar = true;
            }            
        }
        // SHOW SIDE BAR
        showSideBar = false;
        if (ApexPages.currentPage().getParameters().get('sb') != null)
        {
            string sb = ApexPages.currentPage().getParameters().get('hb');
            if ((sb == 'true') || (sb == '1')) 
            {
                showSideBar = true;
            }                   
        }
        
        // CREATE TASK
        createTask = false;
        if (ApexPages.currentPage().getParameters().get('ct') != null)
        {
            string ct = ApexPages.currentPage().getParameters().get('ct');
            if ((ct == 'true') || (ct == '1')) 
            {
                createTask = true;
            }                   
        }

        // ACTIVITY LINE ITEMS TO UPDATE
        setALI_Ids = new Set<Id>();         
        if (ApexPages.currentPage().getParameters().get('ali') != null)
        {
system.debug('ApexPages.currentPage().getParameters().get(ali) = ' + ApexPages.currentPage().getParameters().get('ali'));            
            List<String> lstALI_Ids = ApexPages.currentPage().getParameters().get('ali').split(';');
            for (String s : lstALI_Ids)
            {
                setALI_Ids.add((Id)s);
            }
        }        
        
        
    }
    
    private List<selectOption> getOrgWideAddresses()
    {
        
        orgWideEmailOptions = new List<selectOption>(); 
       
        orgWideEmailOptions.add(new SelectOption(String.ValueOf(UserInfo.getUserId()), String.ValueOf('\"' + UserInfo.getName()  + '\" <' + UserInfo.getUserEmail() + '>'))); 

        for (OrgWideEmailAddress o : [SELECT Id, Address, DisplayName 
                                      FROM OrgWideEmailAddress 
                                      ORDER BY DisplayName]) 
        { 
            orgWideEmailOptions.add(new SelectOption(o.Id, '\"' + o.DisplayName + '\" <' + o.Address + '>')); 
        }
        
        return orgWideEmailOptions; 
        
    }    
    
    // QUERY TO RETURN A LIST OF ATTACHMENTS
    public List<attachmentWrapper> getAttachments() 
    {
        
        lstAttachments = new List<attachmentWrapper>();
        Id recId = (Id)recordId;
      
        for (Attachment a : [SELECT Id, Name, Body, BodyLength, ContentType, Description, ParentId
                             FROM Attachment 
                             WHERE ParentId =: recId]) 
        {
            lstAttachments.add(new attachmentWrapper(a));
        }   
        
        return lstAttachments;
        
    }     
    
    private string buildTemplate(string letterHead, string emailTemplate)
    {
        
        string retVal = '';
        string keyWord = '<![CDATA[';
        integer iIndexFoundAt = letterHead.indexOf(keyWord);
        integer iTargetIndex = 2;
        
        if (iIndexFoundAt > -1)
        {
  
            for (integer j = 1; (j < 10); j++)
            {
                
                iIndexFoundAt = letterHead.indexOf(keyWord, iIndexFoundAt + keyWord.length());
                if (j == iTargetIndex)
                {
                    retVal = letterHead.substring(0, iIndexFoundAt); 
                    retVal += emailTemplate;
                    retVal += letterHead.substring(iIndexFoundAt + keyWord.length());                    
                    retVal = retVal.replace('<![CDATA[/servlet/servlet', '<img src="https://c.cs65.visual.force.com/servlet/servlet');
                    retVal = retVal.replace(']]></img>', '" />');
                    retVal = retVal.replace('<![CDATA[', '');
                    retVal = retVal.replace(']]>', '');
                    break;
                }
            } 
           
        }

        return retVal;
        
    }
    
    public String getEmailByContactId(String contactId)
    {
		return [SELECT Email FROM Contact WHERE Id =: contactId LIMIT 1].Email;
    }

    public String getNameByContactId(String contactId)
    {
		return [SELECT Name FROM Contact WHERE Id =: contactId LIMIT 1].Name;
    }
	
    public PageReference sendEmail() 
    {

system.debug('Entering sendEmail Function');  
		
        PageReference pageRef = new PageReference('/' + recordID);

        if (subjectText == '' || subjectText == null || bodyText == '' || bodyText == null)
        {        
            errorMsg = 'Please enter subject and body text.';
            return null;
        }     

        if (to != null || to != '' || additionalTo != null || additionalTo != '' || cc != null || cc != '' || bcc != null || bcc != '')
        {
         
            List<String> toAddresses = new List<String>();
            List<String> ccAddresses = new List<String>();
            List<String> bccAddresses = new List<String>();
            List<String> tmpAddr = new List<String>();
            
            if (additionalTo.contains(DEL))
            {
                toAddresses = additionalTo.split(DEL);
                for (String tmp : toAddresses)
                {
                    tmpAddr.add(tmp);
                }
            } 
            else if(additionalTo != '' && additionalTo != null) 
            {
                toAddresses.add(additionalTo);
                tmpAddr.add(additionalTo);
            }

            if (to != '' && to != null)
            { 
                String emailAddr = getEmailByContactId(toId);
                toAddresses.add(emailAddr);
                tmpAddr.add(emailAddr);            
            }

            if (cc.contains(DEL))
            {
                ccAddresses = cc.split(DEL);
                for (String tmp:ccAddresses)
                {
                    tmpAddr.add(tmp);
                }
            }
            else if(cc != '' && cc != null)
            {
                ccAddresses.add(cc);
                tmpAddr.add(cc);
            }
            
            if (bcc.contains(DEL))
            {
                bccAddresses = bcc.split(DEL);
                for (String tmp:bccAddresses)
                {
                    tmpAddr.add(tmp);
                }
            } 
            else if(bcc != '' && bcc != null)
            {
                bccAddresses.add(bcc);
                tmpAddr.add(bcc);
            }
            
            
            flagToSendMail = true;
            
            
/*
            // Checking whether mail addresses are valid 
            addresses = tmpAddr;
            for (String tempStr:addresses)
			{
                if (!Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', tempStr))
				{
                    errorMsg = 'Check To, CC and BCC addresses';
                    successMsg = '';
                    flagToSendMail = false;      
                    break;          
                } 
            } 
*/
            // Sending Mail 
            if (flagToSendMail == true)
			{
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                if (fromAddressSelectedIndex > 0)
                {
                	email.setOrgWideEmailAddressId(fromAddressSelected);                    
                }

                if (toAddresses != null)
                {
                    email.setToAddresses(toAddresses);
                } 
                
                if (ccAddresses != null)
                {
                    email.setccAddresses(ccAddresses);
                }
                
                if (bccAddresses != null)
                {
                    email.setbccAddresses(bccAddresses);
                } 
                
                email.setSubject(subjectText);  
                email.setHtmlBody(bodyText);

                // INCLUDED SELECTED ATTACHMENTS
                List<Messaging.EmailFileAttachment> lstSelectedAttachments = new List<Messaging.EmailFileAttachment>();
                for (attachmentWrapper aw : lstAttachments)
                {
                    if (aw.isSelected)
                    {
                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                        attach.setContentType(aw.att.contentType);
                        attach.setFileName(aw.att.Name);
                        attach.setInline(false);
                        attach.setBody(aw.att.Body);
                        lstSelectedAttachments.add(attach);                        
                    }
                }
                
                if (lstSelectedAttachments.size() > 0)
                {
                    email.setFileAttachments(lstSelectedAttachments);
                }                

                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
/*                
                try 
                {
                    Messaging.SendEmailResult[] mailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    if (!mailResult[0].isSuccess()) 
                    {
                        ApexPages.Message sentMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Email Failed to Send: ' + mailResult[0].getErrors()[0].getMessage());
                        ApexPages.addMessage(sentMsg);   
                    }
                    else
                    {
                        ApexPages.Message sentMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Email sent!');
                        ApexPages.addMessage(sentMsg);                         
                    }
                }
                catch (system.EmailException emlEx) 
                {
                    ApexPages.Message sendEmailExMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Email Failed to Send: ' + emlEx);
                    ApexPages.addMessage(sendEmailExMsg); 
                    return null; 
                }
*/
                if (!setALI_Ids.isEmpty())
                {                    
                    List<Activity_Line_Item__c> lstActivityLineItemsUpdates = new List<Activity_Line_Item__c>();                     
                    for (Activity_Line_Item__c i : [SELECT Id, Fulfillment_Complete__c  
                                                    FROM Activity_Line_Item__c 
                                                    WHERE Id IN : setALI_Ids]) 
                    {
                        i.Fulfillment_Complete__c = true;
                        lstActivityLineItemsUpdates.add(i);
                    }
                    database.update(lstActivityLineItemsUpdates);
                }
                if (createTask)
                {
                    createTask((Id)recordID, UserInfo.getUserId());
                }
                return pageRef; 
                
            }
            else
            {
                return null;
            }
        }
        else
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter To:, CC: or BCC: address');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
    }    
    
	private string generateSOQLFields(string sObjectName, string sEmailTemplate)
    { 

        if (sEmailTemplate == null)
        {
        	return '';    
        }
        
        string soql = '';
        Set<String> setFields = new Set<String>();
        Pattern myPattern = Pattern.compile('(\\{!+([a-zA-Z_.]*\\.[a-zA-Z_]*)})'); 
        Matcher myMatch = myPattern.matcher(sEmailTemplate); 
        
        while (myMatch.find()) 
        {
            string fieldName = myMatch.group();
            if ((fieldName.contains(sObjectName)) && (fieldName != '{!' + sObjectName + '.Name}')) 
            { 
                setFields.add(fieldName); 
            } 
        } 
        
        for (string s : setFields)
        {
            string str = s.replace('{!', '');
            str = str.replace('}', '');
            soql += ', ' + str;
        }
        
        return soql; 
        
    }
    
    private void createTask(Id taskWhatId, Id taskOwnerId)
    {

        try 
        {
            Task t = new Task();
            t.RecordTypeId = '012600000000mdPAAQ';
            t.WhatId = taskWhatId;
            t.OwnerId = taskOwnerId;  
            t.Status = 'Completed';
            t.Subject = 'Email: ' + subjectText;         
            t.Description = bodyText;
            insert t;
        }
        catch (System.DmlException ex)
        {

        }  
        
    }
    
    
    // WRAPPER CLASS
    public class attachmentWrapper 
    {
        public Attachment att {get; set;}
        public Boolean isSelected {get; set;}
        public Id attachmntID {get; set;}
        
        public attachmentWrapper(Attachment a) 
        {
            this.att = a;
            this.isSelected = false;
            this.attachmntID = att.Id; 
        }
    }

}