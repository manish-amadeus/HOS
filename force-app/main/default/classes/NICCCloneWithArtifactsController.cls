public class NICCCloneWithArtifactsController 
{
    
    //added an instance varaible for the standard controller
    private ApexPages.StandardController controller {get; set;}
     // add the instance for the variables being passed by id on the url
    private NI_Change_Control__c nicc {get;set;}
    // set the id of the record that is created -- ONLY USED BY THE TEST CLASS
    public ID newRecordId {get;set;}
    
    // initialize the controller
    public NICCCloneWithArtifactsController(ApexPages.StandardController controller) 
    { 
        // initialize the stanrdard controller
        this.controller = controller;
        // load the current record
        nicc = (NI_Change_Control__c)controller.getRecord(); 
    }
    
    // method called from the VF's action attribute to clone the Change Request
    public PageReference cloneWithArtifacts() 
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
            WHERE NI_Change_Control__c = : nicc.Id 
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
                                  WHERE id = : nicc.id];
  
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
        newRecordId = newR.id;
        
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
            //Database.insert(lstAttInserts);
            
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
        
        return new PageReference('/'+newR.id+'/e?retURL=%2F'+newR.id);
        
    }
    
    static testMethod void testNICCCloneWithArtifactsController() 
    {
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        // setup a reference to the page the controller is expecting with the parameters
        PageReference pref = Page.NICCcloneWithArtifacts;
        Test.setCurrentPage(pref);
 
        // Create a Change Request
        NI_Change_Control__c nicc = new NI_Change_Control__c();
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        nicc.RecordTypeId = rt.Id;
        nicc.Change_Steps__c = 'test';
        nicc.Date_Required__c = system.today();
        nicc.Request_Summary__c = 'Test';
        insert nicc;
        
        // create new Artifact record
        NICC_Artifact__c ar = new NICC_Artifact__c();
        ar.NI_Change_Control__c = nicc.Id;
        ar.Type__c = 'Customer Sign-off';
        ar.Document_Link__c = 'TEST';
        ar.Description__c = 'TEST';
        insert ar;
 
        // create an Attachment for the Artifact
        Attachment attach = NI_TestClassData.createTestAttachment(ar.Id);
        insert attach;
        
        // create a Note for the Artifact
        Note newNote = new Note();
        newNote.ParentId = ar.id;
        newNote.Body = 'TEST';
        newNote.Title = 'TEST';
        insert newNote; 

        // Construct the standard controller
        ApexPages.StandardController con = new ApexPages.StandardController(nicc);
 
        // create the controller
        NICCCloneWithArtifactsController ext = new NICCCloneWithArtifactsController(con);
 
        // Switch to test context
        Test.startTest();
 
        // call the cloneWithArtifacts method
        PageReference ref = ext.cloneWithArtifacts();
        
        // create the matching page reference
        PageReference redir = new PageReference('/'+ext.newRecordId+'/e?retURL=%2F'+ext.newRecordId);
 
        // make sure the user is sent to the correct url
        System.assertEquals(ref.getUrl(),redir.getUrl());
 
        // check that the new po was created successfully
        NI_Change_Control__c newCC = [select id from NI_Change_Control__c where id = :ext.newRecordId];
        System.assertNotEquals(newCC, null);
        
        // check that the line item was created
        List<NICC_Artifact__c> newItems = [Select p.Id From NICC_Artifact__c p where NI_Change_Control__c = :newCC.id];
        System.assertEquals(newItems.size(), 6);
 
        // Switch back to runtime context
        Test.stopTest();   
        
        NI_TriggerManager.intCauseDivByZero = 0;
        PageReference pr = ext.cloneWithArtifacts();        
         
    }   
 
}