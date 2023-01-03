/****************************************************************************************
Name            : AH_Rally_SendAttachmentBatch (TC Org Name: BatchToSendAttachment)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : 
				: 
				: 
******************************************************************************************/
global class AH_Rally_SendAttachmentBatch implements Database.Batchable<sObject>
{
    
    global String query;
    global Integer fileSize = 0;
    global EmailTemplate myWebSolutions = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Forwarding to Web Support (EMEA & ASPAC) Web to Case' LIMIT 1];
    global EmailTemplate myCollectionQuestions = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Forwarding to Collections for Billing Questions' LIMIT 1];    
    global EmailTemplate myGDS = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Forwarding to GDS (images)' LIMIT 1];
    global EmailTemplate myLearning = [SELECT HtmlValue, Subject FROM EmailTemplate WHERE Name = 'Forwarding to Learning Services' LIMIT 1];
    
    
    global AH_Rally_SendAttachmentBatch()
    {
        query = 'SELECT Id, CaseNumber, Contact.Name, Contact.Email, Contact.Phone, Account.Name, Account.AccountNumber, Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet, Description, Origin, Module__c, Product_Family__c, Product__c, Product_TC__c, Issue__c, Case_Ref_Id__c, Subject  FROM Case WHERE hasAttachment__c = TRUE AND FormAssemblyCase__c = TRUE AND Origin = \'Web to Case\' AND Status = \'New\' LIMIT 200';
    }
    
    //start method
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope)
    {
        if (!scope.isEmpty())
        {
            List<Id> myIds = new List<Id>();
            //prepare a map with id and Case Details
            Map<Id, Case> myCaseDeatils = new Map<Id, Case>();
            for (sObject mySobj : scope)
            {
                System.debug(mySobj.get('Id'));
                if ((String)mySobj.get('Product_Family__c') == 'Web Solutions' || 
                    ((String)mySobj.get('Origin') == 'Web to Case' && 
                     (String)mySobj.get('Issue__c') == 'Request for Training') || 
                    ((String)mySobj.get('Origin') == 'Web to Case' && 
                     (String)mySobj.get('Module__c') == 'General Information Request' && 
                     (String)mySobj.get('Issue__c') == 'Billing/Invoicing' &&  
                     String.valueOf(mySobj.get('Description')).contains('Do you need a copy of an invoice or have a question about an invoice?:Yes')) || 
                    ((String)mySobj.get('Origin') == 'Web to Case' && 
                     (String)mySobj.get('Product__c') == 'iHotelier CRS' && 
                     (String)mySobj.get('Issue__c') == 'Images' &&  
                     String.valueOf(mySobj.get('Description')).contains('Where would you like your images updated?:GDS/OTA') && 
                     !(String.valueOf(mySobj.get('Description')).contains('Where would you like your images updated?:GDS/OTA/Booking Engine')) && 
                     !(String.valueOf(mySobj.get('Description')).contains('Where would you like your images updated?:Booking Engine')))
                   )
                {
                    myIds.add((Id)mySobj.get('Id'));
                    myCaseDeatils.put((Id)mySobj.get('Id'), (Case)mySobj);
                }
            }
            
            //System.debug(Limits.getHeapSize());
            //System.debug(Limits.getLimitHeapSize());
            List<Attachment> myCaseAttachment = [SELECT Id, Name, ParentId, Body, BodyLength FROM Attachment WHERE ParentId IN :myIds];    
            
            //prepare a map with parentid and Attachment
            Map<Id, List<Attachment>> myCaseWithIdAttachment = new Map<Id, List<Attachment>>();
            
            //prepare a map with parentid and Attachment when total size is greater than 10MB
            List<Id> myCaseWithIdNoAttachment = new List<Id>();
            for (Id myId : myIds)
            {
                List<Attachment> myCaseListAttachment = new List<Attachment>();
                Integer myAttachTotalLength = fileSize;
                for (Attachment att : myCaseAttachment)
                {
                    if (myId == att.ParentId)
                    {
                        myAttachTotalLength += att.BodyLength;
                        myCaseListAttachment.add(att);  
                    }
                }
                
                System.debug(myAttachTotalLength); 
                //collecting attachments for the case which have total size less than 10MB 
                if (myAttachTotalLength < 10485760)
                {    
                    myCaseWithIdAttachment.put(myId, myCaseListAttachment);
                }
                else
                {
                    myCaseWithIdNoAttachment.add(myId);
                }
                
            }
            //after map is prepared send the details to sending email method
            //prepare the list of messaging obejcts to send email for attachment having more than 10MB size
            List<Messaging.SingleEmailMessage> myListOfEmailNoAttachment = new List<Messaging.SingleEmailMessage>();
            if (!myCaseWithIdNoAttachment.isEmpty())
            {
                
                for (Id myIdMoreAttachment: myCaseWithIdNoAttachment)
                {
                    List<String> toAddress =  new List<String>();
                    if (myCaseDeatils.get(myIdMoreAttachment).Product_Family__c == 'Web Solutions')
                    {
                        //in production
                        toAddress.add('websupport@travelclick.com');
                        //in qa1
                    }
                    if (myCaseDeatils.get(myIdMoreAttachment).Origin == 'Web to Case' && myCaseDeatils.get(myIdMoreAttachment).Issue__c == 'Request for Training')
                    {
                        // in production
                        toAddress.add('learningcenter@travelclick.com');

                    }
                    if (myCaseDeatils.get(myIdMoreAttachment).Origin == 'Web to Case' && myCaseDeatils.get(myIdMoreAttachment).Module__c == 'General Information Request' && myCaseDeatils.get(myIdMoreAttachment).Issue__c == 'Billing/Invoicing' &&  myCaseDeatils.get(myIdMoreAttachment).Description.contains('Do you need a copy of an invoice or have a question about an invoice?:Yes') ){
                        //in production
                        toAddress.add('collectionsdept@travelclick.com');
                        //in training and qa1 
                    }
                    if (myCaseDeatils.get(myIdMoreAttachment).Origin == 'Web to Case' && myCaseDeatils.get(myIdMoreAttachment).Product__c == 'iHotelier CRS' && myCaseDeatils.get(myIdMoreAttachment).Issue__c == 'Images' &&  myCaseDeatils.get(myIdMoreAttachment).Description.contains('Where would you like your images updated?:GDS/OTA') ){
                        // in production
                        toAddress.add('travelclickphotos@travelclick.com');
                        //in training and qa1 

                    }

                    toAddress.add('cs@travelclick.com');
                    Messaging.SingleEmailMessage myMail = new Messaging.SingleEmailMessage(); 
                    String myEmailSubject = 'Attachment Limit exceeded for Ref # {!Case.CaseNumber}/[ {!Case.Case_Ref_Id__c} ]'; 
                    myEmailSubject = myEmailSubject.replace('{!Case.CaseNumber}',myCaseDeatils.get(myIdMoreAttachment).CaseNumber);
                    myEmailSubject = myEmailSubject.replace('{!Case.Case_Ref_Id__c}',myCaseDeatils.get(myIdMoreAttachment).Case_Ref_Id__c);
                    String mailPlainTextBody = 'Dear\n\nWe have received a customer request through the Customer Care Request Form with case number #{!Case.CaseNumber} that relates to your department, however, the request contains attachments that are larger than 10Mb and cannot be automatically forwarded to you.\n\nPlease can you contact your local TravelClick customer care team, quoting the Salesforce case number above, and request that they send you the attachments manually.\n\nMany thanks for your understanding.'; 
                    mailPlainTextBody = mailPlainTextBody.replace('{!Case.CaseNumber}',myCaseDeatils.get(myIdMoreAttachment).CaseNumber);
                    myMail.setOrgWideEmailAddressId('0D24000000000Q4');
                    myMail.setSubject(myEmailSubject);
                    myMail.setPlainTextBody(mailPlainTextBody);
                    myMail.setToAddresses(toAddress);
                    myListOfEmailNoAttachment.add(myMail);
                }
            }
            
            //prepare the list of Messaging obejcts to send email for attachment having less than 10MB size
            List<Messaging.SingleEmailMessage> myListOfEmail = new List<Messaging.SingleEmailMessage>();
            for(Id myId: myCaseWithIdAttachment.keySet())
            {
                List<String> toAddress = new List<String>();
                List<Messaging.EmailFileAttachment> myAttachmentList = new List<Messaging.EmailFileAttachment>();
                Messaging.SingleEmailMessage myMail = new Messaging.SingleEmailMessage();
                String myEmailSubject = ''; 
                String mailHTMLBody = ''; 
                
                //collect to address depends on case description
                if (myCaseDeatils.get(myId).Product_Family__c == 'Web Solutions')
                {
                    //in production
                    toAddress.add('websupport@travelclick.com');                                                         
                    myEmailSubject = myWebSolutions.Subject;
                    mailHTMLBody = myWebSolutions.HtmlValue;
                    
                } 
                
                if (myCaseDeatils.get(myId).Origin == 'Web to Case' && myCaseDeatils.get(myId).Issue__c == 'Request for Training')
                {
                    // in production
                    toAddress.add('learningcenter@travelclick.com');
                    myEmailSubject = myLearning.Subject;
                    mailHTMLBody = myLearning.HtmlValue;
                }
                
                if (myCaseDeatils.get(myId).Origin == 'Web to Case' && myCaseDeatils.get(myId).Module__c == 'General Information Request' && myCaseDeatils.get(myId).Issue__c == 'Billing/Invoicing' &&  myCaseDeatils.get(myId).Description.contains('Do you need a copy of an invoice or have a question about an invoice?:Yes') )
                {
                    //in production
                    toAddress.add('collectionsdept@travelclick.com');

                    myEmailSubject = myCollectionQuestions.Subject;
                    mailHTMLBody = myCollectionQuestions.HtmlValue;
                }
                if (myCaseDeatils.get(myId).Origin == 'Web to Case' && myCaseDeatils.get(myId).Product__c == 'iHotelier CRS' && myCaseDeatils.get(myId).Issue__c == 'Images' &&  myCaseDeatils.get(myId).Description.contains('Where would you like your images updated?:GDS/OTA') )
                {
                    // in production
                    toAddress.add('travelclickphotos@travelclick.com');

                    myEmailSubject = myGDS.Subject;
                    mailHTMLBody = myGDS.HtmlValue;
                }
                // to record forwarded email in email section in production.
                toAddress.add('cs@travelclick.com'); 
                
                //declare Attachment files 
                for (Attachment att:myCaseWithIdAttachment.get(myId))
                {
                    Messaging.EmailFileAttachment myEachAttachment = new Messaging.EmailFileAttachment();
                    myEachAttachment.setBody(att.Body);
                    //myEachAttachment.setContentType('application/pdf');
                    myEachAttachment.setFileName(att.Name);
                    myAttachmentList.add(myEachAttachment);
                }
                
                //replace all the values in HTML text
                String htmlBody =  '<center><table id="topTable" height="450" width="500" cellpadding="0" cellspacing="0" ><tr valign="top" ><td  style=" vertical-align:top; height:100; text-align:left; background-color:#FFFFFF; bLabel:header; bEditID:r1st1;"><img id="r1sp1" bLabel="headerImage" border="0" bEditID="r1sp1" src="https://travelclick--c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000sAfC&oid=00D400000008XSQ" ></img></td></tr><tr valign="top" ><td  style=" height:5; background-color:#AAAAFF; bLabel:accent1; bEditID:r2st1;"></td></tr><tr valign="top" ><td styleInsert="1" height="300"  style=" color:#000000; font-size:12pt; background-color:#FFFFFF; font-family:arial; bLabel:main; bEditID:r3st1;">'+mailHTMLBody;
                htmlBody = htmlBody.replace('<![CDATA[','');
                htmlBody = htmlBody.replace(']]>','');
                System.debug(htmlBody);
                htmlBody = htmlBody.replace('{!Case.Description}', myCaseDeatils.get(myId).Description);
                htmlBody = htmlBody.replace('{!Case.Product_TC__c}', myCaseDeatils.get(myId).Product_TC__c);
                if(myCaseDeatils.get(myId).Issue__c != null){
                    htmlBody = htmlBody.replace('{!Case.Issue__c}', myCaseDeatils.get(myId).Issue__c);
                }
                else{
                    htmlBody = htmlBody.replace('{!Case.Issue__c}','');
                }
                if(myCaseDeatils.get(myId).Contact.Name != null){
                    htmlBody = htmlBody.replace('{!Case.Contact}', myCaseDeatils.get(myId).Contact.Name);
                }
                else{
                    htmlBody = htmlBody.replace('{!Case.Contact}','');
                }
                if(myCaseDeatils.get(myId).Contact.Email != null){
                    htmlBody = htmlBody.replace('{!Contact.Email}', myCaseDeatils.get(myId).Contact.Email);
                }
                else{
                    htmlBody = htmlBody.replace('{!Contact.Email}',''); 
                }
                if(myCaseDeatils.get(myId).Contact.Phone != null){
                    htmlBody = htmlBody.replace('{!Contact.Phone}',myCaseDeatils.get(myId).Contact.Phone);
                }
                else{
                    htmlBody = htmlBody.replace('{!Contact.Phone}','');
                }
                
                if(myCaseDeatils.get(myId).Account.AccountNumber != null){
                    htmlBody = htmlBody.replace('{!Account.AccountNumber}',myCaseDeatils.get(myId).Account.AccountNumber);  
                }
                else{
                    htmlBody = htmlBody.replace('{!Account.AccountNumber}',''); 
                }
                
                //htmlBody = htmlBody.replace('{!Account.AccountNumber}',myCaseDeatils.get(myId).Account.AccountNumber);  
                if(myCaseDeatils.get(myId).Account.Name != null){
                    htmlBody = htmlBody.replace('{!Case.Account}',myCaseDeatils.get(myId).Account.Name);                            
                }
                else{
                    htmlBody = htmlBody.replace('{!Case.Account}',''); 
                }
                //htmlBody = htmlBody.replace('{!Account.AccountNumber}',myCaseDeatils.get(myId).Account.AccountNumber);
                htmlBody = htmlBody.replace('{!Account.ShippingAddress}',myCaseDeatils.get(myId).Account.ShippingCity+'\n'+myCaseDeatils.get(myId).Account.ShippingCountry+'\n'+myCaseDeatils.get(myId).Account.ShippingPostalCode+'\n'+myCaseDeatils.get(myId).Account.ShippingState+'\n'+myCaseDeatils.get(myId).Account.ShippingStreet);
                htmlBody = htmlBody + '</td></tr><tr valign="top" ><td  style=" height:5; background-color:#AAAAFF; bLabel:accent2; bEditID:r4st1;"></td></tr><tr valign="top" ><td  style=" vertical-align:top; height:100; text-align:left; background-color:#FFFFFF; bLabel:footer; bEditID:r5st1;"><img id="r5sp1" bLabel="footerImage" border="0" bEditID="r5sp1" src="https://travelclick--c.na2.content.force.com/servlet/servlet.ImageServer?id=01540000000qa9Y&oid=00D400000008XSQ" ></img></td></tr><tr valign="top" ><td  style=" height:5; background-color:#AAAAFF; bLabel:accent3; bEditID:r6st1;"></td></tr></table></center>';
                String mySubject = myEmailSubject.replace('{!Case.Subject}',myCaseDeatils.get(myId).Subject);
                mySubject = mySubject.replace('{!Case.Case_Ref_Id__c}',myCaseDeatils.get(myId).Case_Ref_Id__c);
                myMail.setOrgWideEmailAddressId('0D24000000000Q4');
                myMail.setSubject(mySubject);
                myMail.setFileAttachments(myAttachmentList);
                myMail.setToAddresses(toAddress);
                myMail.setHTMLBody(htmlBody);
                //add myEmail to myListOfEmail
                myListOfEmail.add(myMail);
            }
            //sending email
            try{
                
                if(!myListOfEmailNoAttachment.isEmpty()){
                    Messaging.sendEmail(myListOfEmailNoAttachment);
                    //update the status to close-AttachmentNotSent
                    List<Case> casesToUpdateForNotSendAttachment = new List<Case>();
                    for(Case myCase: [SELECT Status FROM Case WHERE Id IN :myCaseWithIdNoAttachment]){
                        myCase.Status = 'Closed-AttachmentNotSent';
                        //training record type = 0124000000014PW
                        //qa1 record type
                        //production record type
                        //myCase.RecordTypeId = '0124000000014PW';
                        casesToUpdateForNotSendAttachment.add(myCase);
                    }
                    update casesToUpdateForNotSendAttachment;
                }
                
                //update the status closed-attachmentSent
                if(!myListOfEmail.isEmpty()){
                    Messaging.sendEmail(myListOfEmail);
                    List<Case> casesToUpdate = new List<Case>();
                    for(Case myCase: [SELECT Status FROM Case WHERE Id IN :myCaseWithIdAttachment.keySet()]){
                        myCase.Status = 'Closed-AttachmentSent';
                        //training record type = 0124000000014PW
                        //qa1 record type
                        //production record type
                        //myCase.RecordTypeId = '0124000000014PW';
                        casesToUpdate.add(myCase);
                    }
                    update casesToUpdate;
                }
                
            }
            catch(Exception e){
                System.debug(e);   
            }
            
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}