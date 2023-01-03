/***********************************************************************************************
Name            : AH_ContentPacks_TriggerHandler_Test
Author          : Bhagwat Garkal
Created Date    : 01/07/2021
Last Mod Date   : 01/07/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : This class handles all the test code for AH_ContentPacks_Trigger and AH_ContentPacks_TriggerHandler class
                :
                :
************************************************************************************************/
@isTest
public class AH_ContentPacks_TriggerHandler_Test 
{
    // =======================================================================================================================================
    // =TEST DATA
    // ======================================================================================================================================= 
    @istest static void createTestData()
    {
        // Create Content_Pack__c record.
        Content_Pack__c cp = new Content_Pack__c(
            Name = 'TestContentPack'
        );
        
        Content_Pack__c cp2 = new Content_Pack__c(
            Name = 'TestContentPack2'
        );
        List<Content_Pack__c> insertCp = new List<Content_Pack__c>();
        insertCp.add(cp);
        insertCp.add(cp2);
        insert insertCp;
        
        // Create ContentVersion record.
        list<ContentVersion> insertCv = new list<ContentVersion>();
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'TestContentVersion',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        
        ContentVersion contentVersionInserttest = new ContentVersion(
            Title = 'DemoTestVC',
            PathOnClient = 'DemoTestVC.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        
        insertCv.add(contentVersionInserttest);
        insertCv.add(contentVersionInsert);
        
        ContentVersion cvzip = new ContentVersion(
            Title = 'TestContentpackzipfile',
            PathOnClient = 'Test.zip',
            VersionData = Blob.valueOf('Test Content Data zip'),
            Content_Pack__c = cp.id, 
            IsMajorVersion = true
        );
        
        ContentVersion cvzipTest = new ContentVersion(
            Title = 'TestContentpackzipfile2',
            PathOnClient = 'TestDemo.zip',
            VersionData = Blob.valueOf('Test Content Data zip'),
            Content_Pack__c = cp2.id, 
            IsMajorVersion = true
        );
        
        insertCv.add(cvzipTest);
        
        set<Id> cvIds = new set<Id>();
        if(insertCv != null && insertCv.size() > 0)
        {
            Database.SaveResult[] srList = Database.insert(insertCv, false);
            for(Database.SaveResult sr : srList)
            {
                cvIds.add(sr.getId());
            }
        }
        
        ContentWorkspace cw = [select id, Name,DeveloperName from ContentWorkspace where Name = 'Asset Library' limit 1];
        // Create ContentDocumentLink record.
        List<ContentDocumentLink> lstOfcdl = new List<ContentDocumentLink>();
        
        for(ContentVersion testcv:  [SELECT Id,ContentDocumentId, Title,FileType FROM ContentVersion where IsLatest = true and id In : cvIds])
        {
            ContentDocumentLink cdl = New ContentDocumentLink();
            if(testcv.FileType == 'ZIP')
            {
                cdl.LinkedEntityId = cw.id;    
            }
            else
            {
                cdl.LinkedEntityId = cp.id;    
            }
            cdl.ContentDocumentId = testcv.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            lstOfcdl.add(cdl);
        }
        
        if(lstOfcdl != null && lstOfcdl.Size() > 0)
        {
            insert lstOfcdl;    
        }    
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 1: TESTING FOR AH_ContentPacks_TriggerHandler class methods.
    // =======================================================================================================================================    
    @isTest static void test1()
    {
        
        system.debug(' *** START QUERIES ISSUED = ' + Limits.getQueries()); 
        
        // Create Content_Pack__c record.
        Content_Pack__c cp = new Content_Pack__c(
            Name = 'TestContentPack'
        );
        insert cp;
        
        // Create ContentVersion record.
        list<ContentVersion> insertCv = new list<ContentVersion>();
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'TestContentVersion',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
       
        insertCv.add(contentVersionInsert);
        
        ContentVersion cvzip = new ContentVersion(
            Title = 'TestContentpackzipfile',
            PathOnClient = 'Test.zip',
            VersionData = Blob.valueOf('Test Content Data zip'),
            Content_Pack__c = cp.id, 
            IsMajorVersion = true
        );
        
        insertCv.add(cvzip);
        
        set<Id> cvIds = new set<Id>();
        if(insertCv != null && insertCv.size() > 0)
        {
            Database.SaveResult[] srList = Database.insert(insertCv, false);
            for(Database.SaveResult sr : srList)
            {
                cvIds.add(sr.getId());
            }
        }
        
        // Create ContentDocumentLink record.
        List<ContentDocumentLink> lstOfcdl = new List<ContentDocumentLink>();
        
        for(ContentVersion testcv:  [SELECT Id,ContentDocumentId, Title,FileType FROM ContentVersion where IsLatest = true and FileType != 'ZIP' and id In : cvIds])
        {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = cp.id; 
            cdl.ContentDocumentId = testcv.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            lstOfcdl.add(cdl);
        }
        
        if(lstOfcdl != null && lstOfcdl.Size() > 0)
        {
            insert lstOfcdl;    
        }

        ContentVersion cvfile = [SELECT Id,ContentDocumentId,Content_Pack__c, Title,FileType FROM ContentVersion  where IsLatest = true and Title = 'TestContentVersion'];
        List<ContentVersion> lstOfCv = new List<ContentVersion>();
        lstOfCv.add(cvfile);
        Content_Pack__c cptest = [Select id,Name from Content_Pack__c where name = 'TestContentPack'];
        List<ContentDocumentLink> cdllist = [SELECT Id,ContentDocumentId FROM ContentDocumentLink  where ContentDocumentId =: cvfile.ContentDocumentId];
        List<ContentDocument> cdlist = [SELECT Id,Title FROM ContentDocument  where id =: cvfile.ContentDocumentId];
        List<ContentVersion> cvList = [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c, ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND FileType = 'ZIP' and Content_Pack__c =: cptest.id];
        AH_ContentPacks_TriggerHandler cpTriggerhandler = new  AH_ContentPacks_TriggerHandler();
        AH_ContentPacks_TriggerHandler.isPage();
        Test.startTest();
        cpTriggerhandler.mapOfContentPack.put(cptest.id,cptest);
        cpTriggerhandler.packsId.add(cptest.id);
        cpTriggerhandler.previousZipFiles.put(cvList[0].Content_Pack__c,cvList);
        cpTriggerhandler.createZipFileVersion(lstOfCv);
        cpTriggerhandler.updateZipFileVersionOnFileDelete(cdllist);
        cpTriggerhandler.deleteFileFromZipfileOnFileDelete(cdlist);
        cpTriggerhandler.updateFileInZipfileOnFileUnDelete(cdlist);   
        Test.stopTest();
        
        system.debug(' ***  END QUERIES ISSUED = ' + Limits.getQueries());  
        
    }
    
    
    // =======================================================================================================================================
    // = TEST METHOD 2: TESTING FOR AH_ContentPacks_Trigger .
    // =======================================================================================================================================    
    @isTest static void test2()
    {
        
        system.debug(' *** START QUERIES ISSUED = ' + Limits.getQueries()); 
        
        // Create Content_Pack__c record.
        Content_Pack__c cp = new Content_Pack__c(
            Name = 'TestContentPack'
        );
        insert cp;
        
        // Create ContentVersion record.
        list<ContentVersion> insertCv = new list<ContentVersion>();
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'TestContentVersion',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
       
        insertCv.add(contentVersionInsert);
        
        ContentVersion cvzip = new ContentVersion(
            Title = 'TestContentpackzipfile',
            PathOnClient = 'Test.zip',
            VersionData = Blob.valueOf('Test Content Data zip'),
            Content_Pack__c = cp.id, 
            IsMajorVersion = true
        );
        
        insertCv.add(cvzip);
        
        set<Id> cvIds = new set<Id>();
        if(insertCv != null && insertCv.size() > 0)
        {
            Database.SaveResult[] srList = Database.insert(insertCv, false);
            for(Database.SaveResult sr : srList)
            {
                cvIds.add(sr.getId());
            }
        }
        
        // Create ContentDocumentLink record.
        List<ContentDocumentLink> lstOfcdl = new List<ContentDocumentLink>();
        
        for(ContentVersion testcv:  [SELECT Id,ContentDocumentId, Title,FileType FROM ContentVersion where IsLatest = true and FileType != 'ZIP' and id In : cvIds])
        {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = cp.id;   
            cdl.ContentDocumentId = testcv.ContentDocumentId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            lstOfcdl.add(cdl);
        }
        
        if(lstOfcdl != null && lstOfcdl.Size() > 0)
        {
            insert lstOfcdl;    
        }
        
        ContentVersion cvfile = [SELECT Id,ContentDocumentId,Content_Pack__c, Title,FileType FROM ContentVersion  where IsLatest = true and Title = 'TestContentVersion'];
        List<ContentVersion> lstOfCv = new List<ContentVersion>();
        lstOfCv.add(cvfile);
        List<ContentDocument> cdlist = [SELECT Id,Title FROM ContentDocument  where id =: cvfile.ContentDocumentId];
        Test.startTest();
        delete cdlist;
        undelete cdlist[0];
        Test.stopTest();
        system.debug(' ***  END QUERIES ISSUED = ' + Limits.getQueries());  
    }   
}