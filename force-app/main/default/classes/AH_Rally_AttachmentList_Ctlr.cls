/****************************************************************************************
Name            : AH_Rally_AttachmentList_Ctlr (TC Org Name: AttachmentListController)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Controller extension used on AttachmentListSection Page
				: 
				: 
******************************************************************************************/ 
public class AH_Rally_AttachmentList_Ctlr 
{
    
    public Case currentCase {get; set;}
    public Case quriedCase;
    //wrapper which is used to display on the page
    public List<AttachmentAndRallyAssociation> myAttList {get; set;}
    public List<Attachment> myAttachmentList;
    public List<Case_Attachment_Relation__c> myCarList;
    public Set<Id> attachIds;
    Set<Attachment> myAttachmentSet;
    public ApexPages.StandardController con;
    public String urlInstance {get; set;}
    
    
    public AH_Rally_AttachmentList_Ctlr(ApexPages.StandardController controller) 
    {
        con = controller;
        urlInstance = URL.getSalesforceBaseUrl().toExternalForm();
        init(con);
    }
    
    // method which is used to call init to rerender after send link is clicked
    public void init1()
    {
        init(con);
    }
    
    public void init(ApexPages.StandardController controller)
    {
        
        currentCase = (Case)controller.getRecord();
        quriedCase = [SELECT Id, CaseNumber, Rally_Artifact_Ref__c FROM Case WHERE Id =: currentCase.Id];
        myAttList = new List<AttachmentAndRallyAssociation>();
        attachIds = new Set<Id>();
        myAttachmentList = [SELECT Id, Name, BodyLength, LastModifiedDate, CreatedBy.Name, CreatedDate FROM Attachment WHERE ParentId =: controller.getId() ORDER BY LastModifiedDate DESC];
        myAttachmentSet = new Set<Attachment>();
        
        //convert attachment list to set
        for (Attachment at : myAttachmentList)
        {
            attachIds.add(at.Id);
            myAttachmentSet.add(at);
        } 
        
        myCarList = [SELECT Sf_Attachment_Id__c, Status__c, Case_Id__c, Defect_Id__c, Rally_Attachment_Id__c, To_be_Send__c FROM Case_Attachment_Relation__c WHERE Sf_Attachment_Id__c IN :attachIds];
        
        Set<Case_Attachment_Relation__c> presentCar = new Set<Case_Attachment_Relation__c>();    
        for (Attachment att : myAttachmentList)
        {
            for (Case_Attachment_Relation__c mycar: myCarList)
            {
                if (mycar.Sf_Attachment_Id__c == att.Id)
                {
                    presentCar.add(mycar);
                }  
            }    
        }
        
        // form wrapper of attachment and related car status
        if (!presentCar.isEmpty())
        {
            List<Attachment> attNeedToRemove = new List<Attachment>();
            for (Attachment att : myAttachmentSet)
            {                
                for (Case_Attachment_Relation__c mycar : presentCar)
                {    
                    if (mycar.Sf_Attachment_Id__c == att.Id)
                    {
                        myAttList.add(new AttachmentAndRallyAssociation(mycar, att));
                        attNeedToRemove.add(att);
                    } 
                }         
            }
            if (myAttachmentSet.removeAll(attNeedToRemove))
            {
                for (Attachment att : myAttachmentSet)
                {
                    myAttList.add(new AttachmentAndRallyAssociation(new Case_Attachment_Relation__c(), att));
                }
            }
        }
        else
        {
            for (Attachment att : myAttachmentSet)
            {
                myAttList.add(new AttachmentAndRallyAssociation(new Case_Attachment_Relation__c(), att));
            }
        }
        
        // logic to order by last modified date
        AttachmentAndRallyAssociation temp = new AttachmentAndRallyAssociation(new Case_Attachment_Relation__c(), new Attachment());
        for (Integer i = 0; i < myAttList.size(); i++)
        {
            for (Integer j = 0; j < (myAttList.size()-i- 1); j++)
            {
                if (myAttList[j].att.LastModifiedDate < myAttList[j + 1].att.LastModifiedDate)
                {
                    temp = myAttList[j];
                    myAttList[j] = myAttList[j + 1];
                    myAttList[j + 1] = temp;
                }
            }
        }
        
    }
    
    // page reference method which is used to create new attachment
    public PageReference createNewAttachment()
    {
        PageReference pref = new PageReference('/p/attach/NoteAttach?pid=' + quriedCase.Id + '&parentname=' + quriedCase.CaseNumber + '&retURL=%2F' + quriedCase.Id);
        return pref;
    }
    
    public PageReference viewAllAttachments()
    {
        PageReference pref = new PageReference('/ui/content/ViewAllAttachmentsPage?id=' + quriedCase.Id + '&retURL=%2F' + quriedCase.Id);
        return pref;
    }
    
    // method which is used to delete the attachment
    public void deleteAttachment()
    {
        Attachment att = [SELECT Id FROM Attachment WHERE Id =: ApexPages.currentPage().getParameters().get('delAttachId')];
        delete att;
    }
    
    // method which is used to view attachment
    public PageReference viewAttachment()
    {
        PageReference pref = new PageReference('/' + ApexPages.currentPage().getParameters().get('attachId'));
        return pref;
    }
    
    // method which is used to edit attachment
    public PageReference editAttachment()
    {
        PageReference pref = new PageReference('/' + ApexPages.currentPage().getParameters().get('editAttachId') + '/e?retURL=' + quriedCase.Id);
        return pref;
    }

    // Wrapper which is used in AttachmentListController
    public class AttachmentAndRallyAssociation
    {
        // wrapper which is used to display on the inline visual force page for the rally case
        public Case_Attachment_Relation__c car {get; set;}
        public Attachment att {get; set;}
        
        public AttachmentAndRallyAssociation(Case_Attachment_Relation__c ca, Attachment at)
        {
            car = ca;
            att = at;
        }
        
    }
    
}