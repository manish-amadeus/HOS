/*******************************************************************************************
Name              : ffaSalesInvoiceTriggerHandler
Author            : CLD Partners
Created Date      : Feb 23, 2016
Last Modified Date: Feb 27, 2020
Last Modified By  : Stuart Emery
Description       : Contains methods that interact with Sales Invoices
                  Changes Made to reference custom settings for the Org Wide E-mail Address
                  and the e-mail template per NICC-022255
                  Updated 03/13/2018 PER NICC-026472
                  Updated 02/27/2020 PER NICC-041279
*******************************************************************************************/

public class ffaSalesInvoiceTriggerHandler {
    
    public static Map<Id, Account> accountMap = new Map<Id, Account>();
    
    //==================================================================================
    //		Method for forcing the invoice date to the end of the month.
    //==================================================================================
    public static void moveInvoiceDate_MonthEnd (List<c2g__codaInvoice__c> newTrigger){
        Set<Id> accountIds = new Set<Id>();
        accountMap = new Map<Id, Account>();
        for(c2g__codaInvoice__c inv : newTrigger){
            accountIds.add(inv.c2g__Account__c);
        }
        for(Account a : [SELECT Id, Force_Month_End_Invoice_Date__c, c2g__CODADaysOffset1__c FROM Account WHERE Id in :accountIds AND Force_Month_End_Invoice_Date__c = true]){
            accountMap.put(a.id, a);
        }
        for(c2g__codaInvoice__c inv : newTrigger){
            if(accountMap.containsKey(inv.c2g__Account__c)){
                Account a = accountMap.get(inv.c2g__Account__c);
                inv.c2g__InvoiceDate__c = inv.c2g__InvoiceDate__c.addMonths(1).toStartofMonth().addDays(-1);
                inv.c2g__DueDate__c = inv.c2g__InvoiceDate__c;
            }
        }
    }
    public static void defaultHeaderValues (List<c2g__codaInvoice__c> newTrigger){
        Id BALANCESHEETDIMENSION;
        accountMap = new Map<Id, Account>();
        Set<Id> accountIds = new Set<Id>();
        for(c2g__codaInvoice__c inv : newTrigger){
            accountIds.add(inv.c2g__Account__c);
        }
        for(Account a : [SELECT Id, Remittance_Info__c FROM Account WHERE Id in :accountIds AND Remittance_Info__c != null]){
            accountMap.put(a.id, a);
        }
        for(c2g__codaDimension3__c dim3 : [Select id from c2g__codaDimension3__c where name = '000 - BALANCE SHEET']){
            BALANCESHEETDIMENSION = dim3.id;
        }
        Set<Id> companyIds = new Set<Id>();
        for(c2g__codaInvoice__c invoice : newTrigger){
            companyIds.add(invoice.c2g__ownerCompany__c);
        }
        Map<Id, c2g__codaCompany__c> companyMap = new Map<Id, c2g__codaCompany__c>([
            SELECT id, Invoice_Default_Dimension_2__c, Remittance_Info__c from c2g__codaCompany__c where id in :companyIds]);
        
        //default the fields
        for(c2g__codaInvoice__c invoice : newTrigger){
            invoice.c2g__Dimension3__c = BALANCESHEETDIMENSION != null ? BALANCESHEETDIMENSION : null;
            invoice.c2g__Dimension2__c = companyMap.containsKey(invoice.c2g__ownerCompany__c) && companyMap.get(invoice.c2g__ownerCompany__c).Invoice_Default_Dimension_2__c != null ? companyMap.get(invoice.c2g__ownerCompany__c).Invoice_Default_Dimension_2__c : null;
            /* COMMENTED BY STUART EMERY 02/27/2020 PER NICC-041279
            if(accountMap.containsKey(invoice.c2g__Account__c)){
                invoice.Remittance_Info__c = accountMap.get(invoice.c2g__Account__c).Remittance_Info__c;
            }
            else{
                invoice.Remittance_Info__c = companyMap.containsKey(invoice.c2g__ownerCompany__c) && companyMap.get(invoice.c2g__ownerCompany__c).Remittance_Info__c != null ? companyMap.get(invoice.c2g__ownerCompany__c).Remittance_Info__c : null;
            }
          */
        }
    }
    
    //email the invoice
    public static void handleEmailingInvoice(List<c2g__codaInvoice__c> newTrigger, Map<Id,c2g__codaInvoice__c> oldTriggerMap){
        
        List<c2g__codaInvoice__c> lstInvoices = new List<c2g__codaInvoice__c>();
        
        //VARIABLES TO HOLD THE ORG WIDE EMAIL ADDRESS AND EMAIL TEMPLATE THAT WILL BE USED FOR EMAILING SALES INVOICES NICC-022255
        OrgWideEmailAddress owa;
        EmailTemplate template;
        
        //GET THE VALUES FOR THE DEFAULT AH FFA Sales Invoice Trigger Handler CUSTOM SETTING RECORD NICC-022255
        AH_FFA_Sales_Invoice_Trigger_Handler__c csSalesInvoice = AH_FFA_Sales_Invoice_Trigger_Handler__c.getValues('Default');
        
        if(csSalesInvoice == null)
        {
            System.debug('CUSTOM SETTING AH FFA Sales Invoice Trigger Handler Is Null. Sales Invoice Email Will Not Be Sent' );
        }
        
        //VERIFY THE CUSTOM SETTING IS NOT NULL NICC-022255
        if(csSalesInvoice != null)
        {
            
            
            List<c2g__codaInvoice__c> invoiceSendList = new List<c2g__codaInvoice__c>();
            for(c2g__codaInvoice__c invoice : newTrigger){
                c2g__codaInvoice__c oldInvoice = oldTriggerMap.get(invoice.id);
                if(invoice.Action_Email_to_Customer__c == true && oldInvoice.Action_Email_to_Customer__c == false && invoice.Bill_To_Contact__c != null
                   && invoice.Bill_To_Contact_Email__c != null && invoice.Remittance_Info__c != null){
                    invoiceSendList.add(invoice);
                    invoice.Invoice_Sent__c = true;
                }
                //reset the action checkbox
                invoice.Action_Email_to_Customer__c = false;
            }
            system.debug('\n\n ***** ffaSalesInvoiceTriggerHandler - handleEmailingInvoice - invoiceSendList = '+invoiceSendList);
            if(invoiceSendList.size()>0){
                Set<Id> remittanceIds = new Set<Id>();
                Map<Id, Attachment> remittanceAttachmentMap = new Map<Id, Attachment>();
                
                List<Messaging.SingleEmailMessage> allmsgs = new List<Messaging.SingleEmailMessage>();
                
                //MAP OF ORG WIDE EMAIL ADDRESSES.  ADDED 03/08/2018 PER NICC-026472 
                Map<String, OrgWideEmailAddress> mapOWA = new Map<String, OrgWideEmailAddress>();
                
                List<OrgWideEmailAddress> lstOWA = [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress];
                    
                    for(OrgWideEmailAddress o : lstOWA)
                        {
                          mapOWA.put(o.DisplayName, o);
                          System.debug('ORG WIDE EMAIL ADDRESS: ' + o.DisplayName);  
                        }
                
                   System.debug('mapOWA Size: ' + mapOWA.size());
                
                //CODE BELOW COMMENTED ON 03/08/2018 PER NICC-026472 
                //for(OrgWideEmailAddress add :[select id, DisplayName, Address from OrgWideEmailAddress where DisplayName = 'Hospitality Billing' LIMIT 1]){ //ORIGINAL CODE
                //for(OrgWideEmailAddress add :[select id, DisplayName, Address from OrgWideEmailAddress where DisplayName =: csSalesInvoice.Org_Wide_Email_Address_Display_Name__c LIMIT 1]){
                //    owa = add;
               // }
               // END NICC-026472 CODE COMMENT
               
                template = [Select id from EmailTemplate where name =: csSalesInvoice.Email_Template_Name__c];
                System.debug('SALES INVOICE EMAIL TEMPLATE ID: ' + template.Id);   
                
                // EmailTemplate template = [Select id from EmailTemplate where name = 'Standard Invoice Email']; //ORGINAL CODE
                
                //IF THERE ARE VALUES FOR THE ORG WIDE EMAIL ADDRESS AND EMAIL TEMPLATE THEN SEND THE INVOICES
                if(mapOWA != null && template != null)
                {
                    
                    //get the additional attachments that will be required:
                    for(c2g__codaInvoice__c invoice : invoiceSendList){
                        remittanceIds.add(invoice.Remittance_Info__c);
                    }
                    
                    Map<Id, Remittance_Info__c> mapRemittance = new Map<Id, Remittance_Info__c>([SELECT Id, OWA_Name__c 
                                                                                                 FROM Remittance_Info__c 
                                                                                                 WHERE Id IN: remittanceIds]);
                    System.debug('mapRemittance Size: ' + mapRemittance.size());
                    
                    
                    for (Attachment a : [select Name, Body, BodyLength, ParentId from Attachment where ParentId in :remittanceIds]){
                        remittanceAttachmentMap.put(a.ParentId, a);
                    }
                    
                    //first get all the invoices that need to be sent out:
                    for(c2g__codaInvoice__c invoice : invoiceSendList){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(template.id);
                        mail.setWhatId(invoice.id);
                        mail.setSaveAsActivity(true);
                        mail.setTargetObjectId(invoice.Bill_To_Contact__c);
                        
                        //if(owa != null){  //ORIGINAL CODE COMMENTED ON 03/08/2018 PER NICC-026472 
                        //    mail.setOrgWideEmailAddressId(owa.id);
                        // }

                        //ADDED NEW CODE BELOW ON 03/08/2018 PER NICC-026472
                        //SET THE FROM ADDRESS OF THE SALES INVOICE TO ORG WIDE EMAIL ADDRESS 
                        //THAT MATCHES THE OWA Name FIELD ON THE REMITTANCE INFO RECORD RELATED TO THE INVOICE
                        //IF THIS FIELD IS NULL OR THERE IS NO MATCHING ORG WIDE EMAIL ADDRESS,
                        //THE EMAIL WILL COME FROM THE USER WHO INVOKED THE TRIGGER LOGIC 
                        if(mapOWA != null && mapRemittance.containsKey(invoice.Remittance_Info__c)
                           && mapOWA.get(mapRemittance.get(invoice.Remittance_Info__c).OWA_Name__c) != null)
                        {
                            mail.setOrgWideEmailAddressId(mapOWA.get(mapRemittance.get(invoice.Remittance_Info__c).OWA_Name__c).Id);
                        }
                        //END NEW CODE PER NICC-026472
                        
                        //create additional attachments: 
                        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();					
                        
                        //remittance instructions:
                        if(remittanceAttachmentMap.containsKey(invoice.Remittance_Info__c)){
                            Attachment a = remittanceAttachmentMap.get(invoice.Remittance_Info__c);
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(a.Name);
                            efa.setBody(a.Body);
                            fileAttachments.add(efa);	
                        }
                        mail.setFileAttachments(fileAttachments);
                        allmsgs.add(mail);
                    }
                    system.debug('\n\n ***** ffaSalesInvoiceTriggerHandler - handleEmailingInvoice - allmsgs = '+allmsgs);
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(allmsgs,false);
                    system.debug('\n\n ***** ffaSalesInvoiceTriggerHandler - handleEmailingInvoice - results = '+results);
                }
            }        
        }
    }
}