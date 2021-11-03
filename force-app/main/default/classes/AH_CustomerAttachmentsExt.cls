/****************************************************************************************
Name            : AH_CustomerAttachmentsExt Class
Author          : Sean Harris
Created Date    : 07/12/2017
Last Mod Date   : 07/12/2017
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for the AH_CustomerAttachments Visualforce page 
                : Used in the CRS Partner Community
******************************************************************************************/
public with sharing class AH_CustomerAttachmentsExt 
{
    
    public AH_Customer_Attachment__c ca; 
    public c2g__codaInvoice__c sin;
    public Id acdId {get; set;} 
    // public List<AttachedContentDocument> lstContentDocuments {get; set;}
    public List<attachmentsWrapper> lstContentDocuments {get; set;}
        
    public AH_CustomerAttachmentsExt(ApexPages.StandardController stdController) 
    {    
        sin = (c2g__codaInvoice__c)stdController.getRecord(); 
        getFiles(sin.Id);
    }
    
    public void getFiles(Id sinId) 
    {
        
        Set<Id> setDocIds = new Set<Id>();
        lstContentDocuments = new List<attachmentsWrapper>();
        
        for (AH_Customer_Attachment__c cattach : [SELECT Id, RecordType.Name, 
                                                      (SELECT Id, Title, ContentSize, ContentUrl, ContentDocumentId, ExternalDataSourceName, FileExtension, FileType, LinkedEntityId
                                                       FROM AttachedContentDocuments) 
                                                  FROM AH_Customer_Attachment__c 
                                                  WHERE Sales_Invoice__c =: sinId]) 
        {
            for (AttachedContentDocument acd : cattach.AttachedContentDocuments)
            {
//                lstContentDocuments.add(acd);
                setDocIds.Add(acd.ContentDocumentId);
				attachmentsWrapper aw = new attachmentsWrapper(acd.ContentDocumentId, null, acd.Title, acd.FileType, cattach.RecordType.Name);
                lstContentDocuments.add(aw);
            }
        }   
 
        for (ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN : setDocIds])
        {
            for (attachmentsWrapper lstAW : lstContentDocuments)
            {
                if (cv.ContentDocumentId == lstAW.ContentDocumentId)
                {
                    lstAW.ContentVersionId = cv.Id;
                }
            }
        }
        
    }    

    public PageReference viewAttachment() 
    {

        string strUrl = '/' + acdId; 
        PageReference pr = new PageReference(strUrl); 
        
        pr.setRedirect(true); 
        return pr; 
        
    }    

    // WRAPPER CLASS  
    public class attachmentsWrapper 
    {

        public Id ContentDocumentId {get; set;}
        public Id ContentVersionId {get; set;}
        public String Title {get; set;}
        public String FileType {get; set;}
        public String RecordType {get; set;}
            
        public attachmentsWrapper(Id ContentDocumentId, Id ContentVersionId, String Title, String FileType, String RecordType) 
        {
            this.ContentDocumentId = ContentDocumentId;
            this.ContentVersionId = ContentVersionId;
			this.Title = Title;
            this.FileType = FileType;
            this.RecordType = RecordType;
        }
    }    
    
}