/****************************************************************************************
Name            : NICC_Artifact_TriggerHandler_Test Class
Author          : Sean Harris
Created Date    : 2/15/2013
Last Mod Date   : 2/27/2013
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : test Class for NICC_Artifact_TriggerHandler Class
                : 
                : 
******************************************************************************************/
@isTest //(SeeAllData=true)
public class NICC_Artifact_TriggerHandler_Test
{

    public static testMethod void testTrigHandler() 
    {
        
        NI_TestClassData.createTestWinaproachServiceNowSettings();
        
        User u = NI_TestClassData.createTestUser(1, 'NI Support CSR');
        insert u;
        
        system.runAs(u)
        {
              
            NICC_Artifact_TriggerHandler handler = new NICC_Artifact_TriggerHandler(true);
            boolean IsTriggerContext = handler.IsTriggerContext;
              
            Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC');
    
            // FIRST NICC RECORD        
            NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST');
            nicc1.RecordTypeId = rtId;     
            insert nicc1;
                    
            List<NICC_Artifact__c> lstArts = new List<NICC_Artifact__c>();
            List<Attachment> lstAtts = new List<Attachment>();
            
            NICC_Artifact__c art1 = NI_TestClassData.createArtifact(1, 'APEX TEST', nicc1.Id, 'Communication Plan');
            art1.Artifact_Name__c = 'Test 1';
            art1.Description__c = 'Test 1';
            art1.Document_Link__c = 'http://www.google.com';
            
            NICC_Artifact__c art2 = NI_TestClassData.createArtifact(2, 'APEX TEST', nicc1.Id, 'Deployment Plan');
            art2.Artifact_Name__c = 'Test 2';
            art2.Description__c = 'Test 2';
            art2.Document_Link__c = 'http://www.google.com';
    
            NICC_Artifact__c art3 = NI_TestClassData.createArtifact(3, 'APEX TEST', nicc1.Id, 'Monitoring Plan');
            art3.Artifact_Name__c = 'Test 3';
            art3.Description__c = 'Test 3';
            art3.Document_Link__c = 'http://www.google.com';        
    
            NICC_Artifact__c art4 = NI_TestClassData.createArtifact(4, 'APEX TEST', nicc1.Id, 'Rollback Plan');
            art4.Artifact_Name__c = 'Test 4';
            art4.Description__c = 'Test 4';
            art4.Document_Link__c = 'http://www.google.com';        
    
            NICC_Artifact__c art5 = NI_TestClassData.createArtifact(5, 'APEX TEST', nicc1.Id, 'Test Plan');
            art5.Artifact_Name__c = 'Test 5';
            art5.Description__c = 'Test 5';
            art5.Document_Link__c = 'http://www.google.com';        
    
            lstArts.add(art1);
            lstArts.add(art2);
            lstArts.add(art3);
            lstArts.add(art4);
            lstArts.add(art5);
    
            Database.Insert(lstArts);
    
            Attachment att1 = NI_TestClassData.createTestAttachment(art1.Id);
            Attachment att2 = NI_TestClassData.createTestAttachment(art2.Id);
            Attachment att3 = NI_TestClassData.createTestAttachment(art3.Id);
            Attachment att4 = NI_TestClassData.createTestAttachment(art4.Id);
            Attachment att5 = NI_TestClassData.createTestAttachment(art5.Id);
            
            lstAtts.add(att1);
            lstAtts.add(att2);
            lstAtts.add(att3);
            lstAtts.add(att4);
            lstAtts.add(att5);
    
            Database.Insert(lstAtts);
            
            NICC_Artifact__c art6 = NI_TestClassData.createArtifact(6, 'APEX TEST', nicc1.Id, 'Customer Sign-off');
            insert art6; 
            
            lstArts.add(art6);
    
            nicc1.Outage_Required__c = 'Yes'; 
            nicc1.Data_Change__c = 'Yes';
            nicc1.New_Custom_Script__c = 'No';   
            update nicc1;
    
            Test.StartTest();
            Database.Update(lstArts);
            Test.Stoptest();
    
            art6.Artifact_Name__c = 'Test 6';
            art6.Description__c = 'Test 6';
            art6.Document_Link__c = 'http://www.google.com';               
            Attachment att6 = NI_TestClassData.createTestAttachment(art6.Id);
            insert att6;
            update art6;
            
            NI_TriggerManager.isFirstTime = true;
            handler.OnBeforeInsert(lstArts);
            
            NI_TriggerManager.isFirstTime = true;
            handler.OnBeforeUpdate(lstArts);
            
            NI_TriggerManager.isFirstTime = true;
            handler.OnBeforeDelete(lstArts);
            
            NI_TriggerManager.isFirstTime = true;      
            handler.OnAfterDelete(lstArts);  
                   
            handler.OnAfterUnDelete(lstArts);
             
        }
        
    }
    
    public static testMethod void testTriggerLoad() 
    {
        
        User u = NI_TestClassData.createTestUser(1, 'NI Support CSR');
        
        system.runAs(u)
        { 
        
            Id rtId = NI_TestClassData.getRecordTypeId('NI_Change_Control__c', 'Hosted RFC');
    
            // FIRST NICC RECORD        
            NI_Change_Control__c nicc1 = NI_TestClassData.createNIChangeControl(1, 'APEX TEST');
            nicc1.RecordTypeId = rtId;     
            insert nicc1;       
        
            List<NICC_Artifact__c> lstArts = new List<NICC_Artifact__c>();
            
            for (Integer j = 1; j < 35; j++)
            {
                
                NICC_Artifact__c art1 = NI_TestClassData.createArtifact(1, 'APEX TEST', nicc1.Id, 'Communication Plan');
                art1.Artifact_Name__c = 'Test 1';
                art1.Description__c = 'Test 1';
                art1.Document_Link__c = 'http://www.google.com';
                
                NICC_Artifact__c art2 = NI_TestClassData.createArtifact(2, 'APEX TEST', nicc1.Id, 'Deployment Plan');
                art2.Artifact_Name__c = 'Test 2';
                art2.Description__c = 'Test 2';
                art2.Document_Link__c = 'http://www.google.com';
        
                NICC_Artifact__c art3 = NI_TestClassData.createArtifact(3, 'APEX TEST', nicc1.Id, 'Monitoring Plan');
                art3.Artifact_Name__c = 'Test 3';
                art3.Description__c = 'Test 3';
                art3.Document_Link__c = 'http://www.google.com';        
        
                NICC_Artifact__c art4 = NI_TestClassData.createArtifact(4, 'APEX TEST', nicc1.Id, 'Rollback Plan');
                art4.Artifact_Name__c = 'Test 4';
                art4.Description__c = 'Test 4';
                art4.Document_Link__c = 'http://www.google.com';        
        
                NICC_Artifact__c art5 = NI_TestClassData.createArtifact(5, 'APEX TEST', nicc1.Id, 'Test Plan');
                art5.Artifact_Name__c = 'Test 5';
                art5.Description__c = 'Test 5';
                art5.Document_Link__c = 'http://www.google.com';
                
                NICC_Artifact__c art6 = NI_TestClassData.createArtifact(6, 'APEX TEST', nicc1.Id, 'Customer Sign-off');
                art6.Artifact_Name__c = 'Test 6';
                art6.Description__c = 'Test 6';
                art6.Document_Link__c = 'http://www.google.com';
        
                lstArts.add(art1);
                lstArts.add(art2);
                lstArts.add(art3);
                lstArts.add(art4);
                lstArts.add(art5);
                lstArts.add(art6);
            }
            
            Database.Insert(lstArts);
            Database.Update(lstArts);
            
        }
           
    }

}