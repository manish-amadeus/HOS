/****************************************************************************************
Name            : AH_NICCCloneWithArtifacts_Cntlr Class
Author          : Shashikant Nikam
Created Date    : 08/28/2019
Last Mod Date   : 10/13/2020
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Controller for AH_NICCCloneWithArtifacts Lightning Component
				: 10/13/2020 added "without sharing" for critical update release.
				:  
******************************************************************************************/
public without sharing class AH_NICCCloneWithArtifacts_Cntlr 
{
    
    // method called from the Lightning Quick Action to clone the Change Request
    @AuraEnabled
    public static String cloneWithArtifacts(String recordId) 
    {
        
        // LIST OF CLONED ARTIFACTS FOR INSERT 
        List<NICC_Artifact__c> lstArtInserts = new List<NICC_Artifact__c>();
        
        // LIST OF CLONED ATTACHMENTS FOR INSERT 
        List<Attachment> lstAttInserts = new List<Attachment>();
        
        // LIST OF CLONED NOTES FOR INSERT 
        List<Note> lstNotesToInsert = new List<Note>();
        
        // LIST OF ALL RELATED ARTIFACTS BELONGING TO TARGET NICCS
        List<NICC_Artifact__c> lstArts = new List<NICC_Artifact__c>([
            SELECT Id, NI_Change_Control__c, Artifact_Name__c, Type__c, Description__c, Document_Link__c, Complete__c
            FROM NICC_Artifact__c 
            WHERE NI_Change_Control__c = : recordId 
        ]);
        
        // LIST OF ALL RELATED ATTACHMENTS BELONGING TO TARGET ARTIFACTS
        List<Attachment> lstAtts = new List<Attachment>([
            SELECT Id, Body, BodyLength, ContentType, Description, Name, ParentId 
            FROM Attachment 
            WHERE ParentId IN : lstArts 
        ]);
        
        // LIST OF ALL RELATED NOTES BELONGING TO TARGET ARTIFACTS
        List<Note> lstNotes = new List<Note>([
            SELECT ParentId, Title, Body, IsPrivate  
            FROM Note 
            WHERE ParentId IN : lstArts 
        ]);
        
        // SET SAVE POINT FOR ROLLBACK 
        Savepoint sp = Database.setSavepoint();
        NI_Change_Control__c newR;  
        
        
        NI_Change_Control__c r = [SELECT Id, Priority__c, Request_Summary__c, Request_Details__c, Change_Type__c, Date_Required__c, Deployment_Group__c, 
                                  Data_Change__c, RecordTypeId, New_Custom_Script__c, Outage_Required__c, Manager_Reviewer__c, Peer_Reviewer__c, 
                                  Developer_Compiler__c, Related_Servers__c, Related_Hosted_RFC__c, NI_Change_Owner__c 
                                  FROM NI_Change_Control__c 
                                  WHERE id = : recordId];
        
        newR = r.clone(false);
        newR.RecordTypeId = r.RecordTypeId;                   
        newR.Change_Status__c = 'New';
        newR.Cloned__c = true;
        newR.Cloned_From__c = r.Id;
        newR.Cloned_w_Artifacts__c = true;
        
        // NICC-017353 START ===================================
        newR.Manager_Reviewer__c = null;
        newR.Peer_Reviewer__c = null;
        newR.Developer_Compiler__c = null;
        newR.NI_Change_Owner__c = null;
        // NICC-017353  END  ===================================
        
        // INSERT CLONED NICC RECORD        
        insert newR;
        
        // set the id of the new po created for testing
        ID newRecordId = newR.id;
        
        // LOOP THROUGH ALL RELATED ARTIFACTS AND ADD TO INSERT LIST
        for (NICC_Artifact__c artSource : lstArts)
        {            
            NICC_Artifact__c artNew = artSource.clone(false);
            artNew.NI_Change_Control__c = newR.id; 
            artNew.Cloned_From__c = artSource.id; 
            lstArtInserts.add(artNew);         
        }
        
        try
        {
            
            integer iTest = 1 / NI_TriggerManager.intCauseDivByZero;
            
            // FLIP BYPASS SWITCH TO PREVENT UNNECESSARY UPDATE TRIGGERS ON NICC
            NI_TriggerManager.bypass_NICC_Updates = true; 
            
            // COMMIT CHANGES TO THE DATABASE
            Database.insert(lstArtInserts);
            
            // FLIP BYPASS SWITCH TO PREVENT ALLOW UPDATE TRIGGERS ON NICC
            NI_TriggerManager.bypass_NICC_Updates = false; 
            
        } 
        catch (Exception e)
        {
            // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
            NI_TriggerManager.intCauseDivByZero = 1;
            return null;
        }
        
        // LIST OF ALL NEWLY CREATED ARTIFACTS
        List<NICC_Artifact__c> lstNewArts = new List<NICC_Artifact__c>([
            SELECT Id, Cloned_From__c, NI_Change_Control__c, Artifact_Name__c, Type__c, Description__c, Document_Link__c, Complete__c
            FROM NICC_Artifact__c 
            WHERE NI_Change_Control__c = : newR.id 
        ]);
        
        // LOOP THROUGH ALL RELATED ATTACHMENTS AND ADD TO INSERT LIST
        for (NICC_Artifact__c newArts : lstNewArts)
        {                 
            for (Attachment attach : lstAtts) 
            {
                if (newArts.Cloned_From__c == String.ValueOf(attach.ParentId))
                {
                    Attachment newAttach = attach.clone(false);
                    newAttach.ParentId = newArts.id;
                    lstAttInserts.add(newAttach);
                }
            }
            
            for (Note n : lstNotes) 
            {
                if (newArts.Cloned_From__c == String.ValueOf(n.ParentId))
                {
                    Note newNote = n.clone(false);
                    newNote.ParentId = newArts.id;
                    newNote.Body = n.Body;
                    newNote.Title = n.Title;
                    newNote.IsPrivate = n.IsPrivate;
                    lstNotesToInsert.add(newNote);
                }
            }       
        }
        
        //INSERT ATTACHMENT RECORDS
        Database.insert(lstAttInserts);
        
        //INSERT NOTES RECORDS
        Database.insert(lstNotesToInsert); 
        
        return newR.id;
    }
    
}