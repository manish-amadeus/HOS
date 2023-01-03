/****************************************************************************************
Name            : AH_EmailDocs_Ext Class
Author          : Sean Harris
Created Date    : 08/03/2017
Last Mod Date   : 08/03/2017
Last Mod By     : Sean Harris
NICC Reference  : NICC-023217
Description     : Controller for AH_EmailDocs VF Page
				: 
				: 
******************************************************************************************/
public class AH_EmailDocs_Ext 
{

    private NI_Documentation__c nDoc;

    // WRAPPER CLASS LISTS
//    public List<attachmentWrapper> lstAttachments {get; set;}
    public List<contactWrapper> lstContacts {get; set;}
    public List<activityLineItemWrapper> lstActivityLineItems {get; set;}
    public List<assetWrapper> lstAssets {get; set;}
        
    public string selectedTemplate {get; set;}
	public List<SelectOption> templateOptions {get; set;}


    public AH_EmailDocs_Ext(ApexPages.StandardController stdController)
    {        

        NI_Documentation__c d = (NI_Documentation__c)stdController.getRecord();       
        nDoc = [SELECT Id, Name, 
                Account__c, 
                Account_Production_Configured__c, 
                Approval_Status__c, 
                Description__c, 
                Document_Name__c, 
                Document_Type__c, 
                Estimated_Configuration_Time__c, 
                Final_Approver__c, 
                Final_Target_Date__c, 
                First_Target_Date__c, 
                Follow_Up_Required__c, 
                HRM_Product__c, 
                Implementation_Instructions__c, 
                Install_Type__c, 
                Integration_Type__c, 
                Link__c, 
                Contact__c, 
                Milestone__c, 
                Opportunity__c, 
                Outstanding_Issues__c, 
                Password__c, 
                Product_Version__c, 
                Project__c, 
                Project_Manager__c, 
                Sign_Off_Due_Date__c, 
                Sign_Off_Received__c, 
                Solution_Details__c, 
                Stage__c, 
                Status__c, 
                Template__c, 
                Vendor_Version__c 
                FROM NI_Documentation__c 
                WHERE Id =: d.Id];
        getTemplates(); 
        getContacts(); 
        //getAttachments(); 
        getActivityLineItems();
        getAssets();
    } 

/*
    // QUERY TO RETURN A LIST OF ACTIVITY LINE ITEMS
    public List<attachmentWrapper> getAttachments() 
    {
        
        lstAttachments = new List<attachmentWrapper>();
        
        for (Attachment a : [SELECT Id, Name, Body, BodyLength, ContentType, Description, ParentId
                             FROM Attachment 
                             WHERE ParentId =: nDoc.Id]) 
        {
            lstAttachments.add(new attachmentWrapper(a));
        }   
        
        return lstAttachments;
        
    }     
*/
    public void getTemplates()
    {
        templateOptions = new List<SelectOption>();
        templateOptions.add(new SelectOption('0', '-- Choose an Email Template --'));
        for (EmailTemplate a : [SELECT Id, Name 
                                FROM EmailTemplate 
                                WHERE Folder.AccessType = 'Public' AND Folder.Type = 'Email' 
                                AND Folder.Name = 'Fulfilment Email Communications'
                                ORDER BY Name]) 
        {
            templateOptions.add(new SelectOption(a.Id, a.Name));
        }          
    }
    
    public List<contactWrapper> getContacts()
    {
        
        if (nDoc.Opportunity__c == null)
        {
            return null;
        }
        
		lstContacts = new List<contactWrapper>();
        for (OpportunityContactRole cr : [SELECT ContactId, Contact.Name, Role, Contact.Email 
                                          FROM OpportunityContactRole 
                                          WHERE OpportunityId =: nDoc.Opportunity__c 
                                          AND Contact.Email != null 
                                          ORDER BY Role ASC])
        {
            lstContacts.add(new contactWrapper(cr.ContactId, cr.Contact.Name, cr.Role, cr.Contact.Email, false));
        }

        return lstContacts;      
    }

    public List<activityLineItemWrapper> getActivityLineItems()
    {
        
        if (nDoc.Opportunity__c == null)
        {
            return null;
        }
        
		lstActivityLineItems = new List<activityLineItemWrapper>();
        for (Activity_Line_Item__c i : [SELECT Id, Name, SKU__c, Fulfillment_Complete__c, Status__c, Product__r.Name, Product_Description__c, Revenue_Category__c 
                                        FROM Activity_Line_Item__c 
                                        WHERE Opportunity__c =: nDoc.Opportunity__c 
                                        AND Fulfillment_Complete__c = false 
                                        ORDER BY Name ASC]) 
        {
            lstActivityLineItems.add(new activityLineItemWrapper(i, false));
        }

        return lstActivityLineItems;      
    }


    public List<assetWrapper> getAssets()
    {
        
        if (nDoc.Opportunity__c == null)
        {
            return null;
        }
        
        Set<Id> setProduct2Ids = new Set<Id>();
        
        for (OpportunityLineItem oli : [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId =: nDoc.Opportunity__c])
        {
            setProduct2Ids.Add(oli.Product2Id);
        }
        
        lstAssets = new List<assetWrapper>();
        for (Asset di : [SELECT Id, Name, Status, Quantity_Provisioned__c, Product2.ProductCode, Product2.Family   
                         FROM Asset 
                         WHERE AccountId =: nDoc.Account__c 
                         AND Product2Id IN : setProduct2Ids 
                         //AND Product2.Family IN ('Subscription', 'Software') 
                         AND Status != 'Inactive' 
                         ORDER BY Name ASC]) 
        {
            lstAssets.add(new assetWrapper(di, false));
        }
        
        return lstAssets;
        
    }
    
    private void updateAssets(List<assetWrapper> lstAssetsUps)
    {
        List<Asset> lstAssetUpdates = new List<Asset>();
        for (assetWrapper aw : lstAssetsUps)
        {
            lstAssetUpdates.Add(aw.di);
        }
        if (lstAssetUpdates.Size() > 0)
        {
            database.update(lstAssetUpdates);
        }        
    }
    
    public pageReference sendEmail()
    {
        
        if (selectedTemplate == '0' || selectedTemplate == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an Email template before continuing.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        PageReference pageRef = new PageReference('/apex/AH_EmailAuthor');

        boolean bFirstContact = true;
        string firstContactId = '';
        string strCCs = '';

        for (contactWrapper cw : lstContacts)
        {
            if (cw.isSelected)
            {
                if (bFirstContact)
                {
                    firstContactId = cw.contactId;
                    bFirstContact = false;
                }
                else
                {
                    strCCs += cw.contactEmail + ';\n';
                }
            }
        }

        string strALIs = '';
        for (activityLineItemWrapper aw : lstActivityLineItems)
        {
            if (aw.isSelected)
            {
            	strALIs += aw.ali.Id + ';';
            }
        }        
        
        
        if (firstContactId == '' || firstContactId == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select at least 1 contact recipient before continuing.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        pageRef.getParameters().put('id', nDoc.Id);
        pageRef.getParameters().put('to', firstContactId);
        pageRef.getParameters().put('cc', strCCs);
        pageRef.getParameters().put('retURL', '%2Fapex/AH_EmailDocs?Id=' + nDoc.Id);
        //pageRef.getParameters().put('p3_lkid', nDoc.Id);
        pageRef.getParameters().put('tid', selectedTemplate);
        pageRef.getParameters().put('ct', '1');
        
        if (strALIs != '')
        {
            pageRef.getParameters().put('ali', strALIs);
        }
        
        updateAssets(lstAssets);
        
        return pageRef;
        
    }
    
/*
    // WRAPPER CLASSES
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
*/    
    public class contactWrapper 
    {
        public Id contactId {get; set;}
        public String contactName {get; set;}
        public String contactRole {get; set;}
        public String contactEmail {get; set;}
        public Boolean isSelected {get; set;}

        public contactWrapper(Id contactId, String contactName, String contactRole, String contactEmail, Boolean isSelected) 
        {
            this.contactId = contactId;
            this.contactName = contactName;
            this.contactRole = contactRole; 
            this.contactEmail = contactEmail; 
            this.isSelected = isSelected; 
        }
    }    

    public class activityLineItemWrapper 
    {    
    	public Activity_Line_Item__c ali {get; set;}
    	public Boolean isSelected {get; set;}

        public activityLineItemWrapper(Activity_Line_Item__c li, Boolean isSelected) 
        {
            this.ali = li;
            this.isSelected = isSelected; 
        }
    } 
    
    public class assetWrapper 
    {    
    	public Asset di {get; set;}
    	public Boolean isSelected {get; set;}

        public assetWrapper(Asset a, Boolean isSelected) 
        {
            this.di = a;
            this.isSelected = isSelected; 
        }
    } 
    
}