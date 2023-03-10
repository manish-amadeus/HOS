/****************************************************************************************
Name            : AH_NICCCloneWithArtifacts_Test Class
Author          : Shashikant Nikam
Created Date    : 09/20/2019
Last Mod Date   : 09/20/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Test class for AH_NICCCloneWithArtifacts_Cntlr class
				: 
******************************************************************************************/
@isTest  
public class AH_NICCCloneWithArtifacts_Test 
{

    static testMethod void testNICCCloneWithArtifactsController() 
    {
        //NI_TestClassData.createTestWinaproachServiceNowSettings();
 
        // CREATE A NEW CHANGE REQUEST
        NI_Change_Control__c nicc = new NI_Change_Control__c();
        RecordType rt = [SELECT Name, Id FROM RecordType WHERE sObjectType = 'NI_Change_Control__c' AND Name = 'Hosted RFC' AND isActive = true];
        nicc.RecordTypeId = rt.Id;
        nicc.Change_Steps__c = 'test';
        nicc.Date_Required__c = system.today();
        nicc.Approval_Status__c = 'Not Submitted';
        nicc.Change_Status__c = 'Open';
        nicc.Request_Summary__c = 'Test summmary.';
        nicc.Request_Details__c = 'Test request details.';
        nicc.Salesforce_Application__c = 'Salesforce';
        nicc.Change_Reason__c = 'Additional Functionality';
        nicc.Priority__c = 'Medium';
        insert nicc;
        
        // CREATE NEW ARTIFACT RECORD
        NICC_Artifact__c ar = new NICC_Artifact__c();
        ar.NI_Change_Control__c = nicc.Id;
        ar.Type__c = 'Customer Sign-off';
        ar.Document_Link__c = 'TEST';
        ar.Description__c = 'TEST';
        insert ar;
 
        // CREATE AN ATTACHMENT FOR THE ARTIFACT
        Attachment attach = NI_TestClassData.createTestAttachment(ar.Id);
        insert attach;
        
        // CRETAE A NOT FOR THE ARTIFACT
        Note newNote = new Note();
        newNote.ParentId = ar.id;
        newNote.Body = 'TEST';
        newNote.Title = 'TEST';
        insert newNote; 

        Test.startTest();
 
        // CALL cloneWithArtifacts METHOD
        String newID = AH_NICCCloneWithArtifacts_Cntlr.cloneWithArtifacts(nicc.id);
        system.assertNotEquals(NULL, newID, 'New record not created.');
            
        // CHECK THAT NEW RECORD IS CREATED SUCCESSFULLY
        List<NI_Change_Control__c> newCCList = new List<NI_Change_Control__c>([select id from NI_Change_Control__c ]);
        system.debug('newCCList size : '+newCCList.size());
        system.assertEquals(2, newCCList.size(), 'New record not created.');
        
        // CHECK THAT THE LINE ITEM WAS CREATED
        List<NICC_Artifact__c> newItems = [Select p.Id From NICC_Artifact__c p where NI_Change_Control__c = :newID];
        System.assertEquals(newItems.size(), 6);
		

        // CHECK ATTACHMNETS CREATED SUCCESSFULLY
        List<Attachment> lstAttInserts = new List<Attachment>([Select ID from Attachment]);
        system.debug('lstAttInserts size : '+lstAttInserts.size());
        System.assertEquals(lstAttInserts.size(), 2, 'Attachment record count mismatch.');

        Test.stopTest();

    }
}