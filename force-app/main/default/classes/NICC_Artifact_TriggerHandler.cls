/************************************************************************************************
Name            : NICC_Artifact_TriggerHandler Class
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   : 11/5/2019
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Class that handles all trigger code for the NICC_Artifact__c Object
                : Updated 11/5/2019 Per NICC-038406
                : Updated ValidateArtifacts to include "Internal - IT" record type
                : 
*************************************************************************************************/
public class NICC_Artifact_TriggerHandler 
{

    private boolean m_isExecuting = false;
    
    public NICC_Artifact_TriggerHandler(boolean isExecuting)
    {
        m_isExecuting = isExecuting;
    }

    public boolean IsTriggerContext
    {
        get {return m_isExecuting;}
    }

    public void OnBeforeInsert(List<NICC_Artifact__c> newTrigger)
    {

    }
    
    public void OnBeforeUpdate(List<NICC_Artifact__c> newTrigger)
    {
        
    }

    public void OnBeforeDelete(List<NICC_Artifact__c> newTrigger)
    {
        
    }
    
    public void OnAfterInsert(List<NICC_Artifact__c> newTrigger)
    {
        ValidateArtifacts(newTrigger); 
    }
    
    public void OnAfterUpdate(List<NICC_Artifact__c> newTrigger)
    {
        ValidateArtifacts(newTrigger);        
    }
        
    public void OnAfterDelete(List<NICC_Artifact__c> newTrigger)
    {
        
    }
    
    public void OnAfterUnDelete(List<NICC_Artifact__c> newTrigger)
    {
        
    }      
    
    private void ValidateArtifacts(List<NICC_Artifact__c> newTrigger)
    {
        
        Integer iArtifactsRequired = 5; // SET THIS TO THE NUMBER OF REQUIRED ARTIFACTS
        
        String strId = '';
        String strArtId = '';
        String strType = '';
        String strDocLink = '';
        String strDesc = '';
        Boolean hasAttachment = false;
        
        // Communication Plan
        Integer iA1 = 0;
        // Deployment Plan
        Integer iA2 = 0;
        // Miscellaneous
        Integer iA3 = 0;
        // Rollback Plan
        Integer iA4 = 0;
        // Testing
        Integer iA5 = 0;
        // Testing
        Integer iA6 = 0;   
        
        // LIST THAT WILL BE PASSED TO DATABASE.UPDATE
        List<NI_Change_Control__c> niccUpdates = new List<NI_Change_Control__c>();
        
        // GET RECORD TYPE FOR TARGETED RECORDS
        List<RecordType> lstRTs = new List<RecordType>([
            SELECT Name, Id 
            FROM RecordType
            WHERE sObjectType = 'NI_Change_Control__c' 
            AND Name IN ('Hosted RFC','HRM RFC','Internal - IT', 'PMS RFC') //ADDED PMS RFC PER NICC-038406
        ]);
        
        // FILL A SET OF ALL RELATED NICC IDS
        Set<Id> setNICC = new Set<Id>();
        
        for (NICC_Artifact__c art : newTrigger) 
        {
            setNICC.add(art.NI_Change_Control__c); 
        }
        
        // FILL A SET OF ALL RELATED NICC OBJECTS
        List<NI_Change_Control__c> lstNICC = new List<NI_Change_Control__c>([
            SELECT Id, Outage_Required__c, Data_Change__c 
            FROM NI_Change_Control__c 
            WHERE Id IN : setNICC 
            AND RecordTypeId IN : lstRTs 
        ]);
        
        // LIST OF ALL RELATED ARTIFACTS BELONGING TO TARGET NICCS
        List<NICC_Artifact__c> lstArts = new List<NICC_Artifact__c>([
            SELECT Id, Type__c, Description__c, Document_Link__c, NI_Change_Control__c 
            FROM NICC_Artifact__c 
            WHERE NI_Change_Control__c IN : lstNICC 
        ]);
        
        // LIST OF ALL RELATED ATTACHMENTS BELONGING TO TARGET ARTIFACTS
        List<Attachment> lstAtts = new List<Attachment>([
            SELECT Name, ParentId  
            FROM Attachment 
            WHERE ParentId IN : lstArts 
        ]);
        
        // LOOP THROUGH EACH NICC CANDIDATE RECORD
        for (NI_Change_Control__c n1 : lstNICC)
        {
            
            // DETERMINE IF ARTIFACT 6 CUSTOMER SIGN-OFF IS PRESENT. IF SO, 6 ARTIFACTS ARE REQUIRED
            if ((n1.Outage_Required__c == 'Yes') || (n1.Data_Change__c == 'Yes'))
            {
                iArtifactsRequired = 6;
            }    
            
            // LOOP THROUGH EACH ARTIFACT LOOKING FOR RECORDS RELATED TO THE CURRENT NICC RECORD IN LOOP
            for (NICC_Artifact__c a1 : lstArts)
            {
                // IF A RELATED ARTIFACT IS FOUND   
                if (a1.NI_Change_Control__c == n1.Id)
                {
                    
                    // INITIALIZE VARIABLES
                    strArtId = null;
                    strType = null;
                    strDocLink = null;
                    strDesc = null;
                    hasAttachment = false;
                    
                    // SET VARIABLES
                    strArtId = a1.Id;
                    strType = a1.Type__c;
                    strDocLink = a1.Document_Link__c; 
                    strDesc = a1.Description__c;              
                    
                    // LLOP THOUGH ATTACHMENTS AND SET BOOLEAN FLAG IF ONE EXISTS FOR CURRENT ARTIFACT IN LOOP
                    for (Attachment f1 : lstAtts)
                    {
                        if (a1.Id == f1.ParentId) 
                        {
                            hasAttachment = true;
                        }
                    }                  
                    
                    // COMMUNICATION PLAN ===============================================================
                    if (strType == 'Communication Plan')
                    {                
                        if (hasAttachment)
                        {
                            iA1 = 1;
                        }                
                        if (strDesc != null)
                        {
                            iA1 = 1;
                        }                
                        if (strDocLink != null)
                        {
                            iA1 = 1;
                        }                
                    }
                
                    // DEPLOYMENT PLAN ==================================================================
                    if (strType == 'Deployment Plan')
                    {
                        if (hasAttachment)
                        {
                            iA2 = 1;
                        }                
                        if (strDesc != null)
                        {
                            iA2 = 1;
                        }                
                        if (strDocLink != null)
                        {
                            iA2 = 1;
                        }   
                    }
                
                    // MONITORING PLAN ====================================================================
                    if (strType == 'Monitoring Plan')
                    {
                        if (hasAttachment)
                        {
                            iA3 = 1;
                        }                
                        if (strDesc != null)
                        {
                            iA3 = 1;
                        }                
                        if (strDocLink != null)
                        {
                            iA3 = 1;
                        }  
                    }
                
                    // ROLLBACK PLAN ====================================================================
                    if (strType == 'Rollback Plan')
                    {
                        if (hasAttachment)
                        {
                            iA4 = 1;
                        }                
                        if (strDesc != null)
                        {
                            iA4 = 1;
                        }                
                        if (strDocLink != null)
                        {
                            iA4 = 1;
                        }  
                    }
                
                    // TEST PLAN ==========================================================================
                    if (strType == 'Test Plan')
                    {
                        if (hasAttachment)
                        {
                            iA5 = 1;
                        }                
                        if (strDesc != null)
                        {
                            iA5 = 1;
                        }                
                        if (strDocLink != null)
                        {
                            iA5 = 1;
                        }  
                    }
                
                    // CUSTOMER SIGN-OFF ==========================================================================
                    if (strType == 'Customer Sign-off')
                    {
                        if (hasAttachment)
                        {
                            iA6 = 1;
                        }                
                        if (strDesc != null)
                        {
                            iA6 = 1;
                        }                
                        if (strDocLink != null)
                        {
                            iA6 = 1;
                        }  
                    }           
                    
                }
        
            }
        
            // ADD NICC RECORD TO LIST FOR UPDATE
            
            // IF 5 ARTIFACTS ARE REQUIRED ===================================================
            if (iArtifactsRequired == 5)
            {
                if ((iA1 + iA2 + iA3 + iA4 + iA5) == iArtifactsRequired)
                {
                    n1.HasAllArtifacts__c = true;
                    niccUpdates.add(n1);
                }
                else
                {
                    n1.HasAllArtifacts__c = false;
                    niccUpdates.add(n1);
                }        
            }
            
            // IF 6 ARTIFACTS ARE REQUIRED ===================================================        
            if (iArtifactsRequired == 6)
            {
                if ((iA1 + iA2 + iA3 + iA4 + iA5 + iA6) == iArtifactsRequired)
                {
                    n1.HasAllArtifacts__c = true;
                    niccUpdates.add(n1);
                }
                else
                {
                    n1.HasAllArtifacts__c = false;
                    niccUpdates.add(n1);
                }         
            }     
            
        }
        
        // FLIP BYPASS SWITCH TO PREVENT UNNECESSARY UPDATE TRIGGERS ON NICC
        NI_TriggerManager.bypass_NICC_Updates = true; 
        
        // COMMIT CHANGES TO THE DATABASE
        Database.update(niccUpdates);
        
        // FLIP BYPASS SWITCH TO PREVENT ALLOW UPDATE TRIGGERS ON NICC
        NI_TriggerManager.bypass_NICC_Updates = false;         
        
    }    
    
    
     
    
}