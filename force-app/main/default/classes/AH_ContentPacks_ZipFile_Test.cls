/***********************************************************************************************
Name            : AH_ContentPacks_ZipFile_Test
Author          : Bhagwat Garkal
Created Date    : 01/07/2021
Last Mod Date   : 01/07/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : This class handles all the test code for AH_ContentPacks_ZipFile_Ctlr class
                :
                :
************************************************************************************************/
@isTest
public class AH_ContentPacks_ZipFile_Test 
{
    // =======================================================================================================================================
    // = CREATE TEST DATA: 
    // ======================================================================================================================================= 
    @testSetup static void createTestData()
    {
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
        AH_ContentPacks_TriggerHandler cpTriggerhandler = new  AH_ContentPacks_TriggerHandler();
        cpTriggerhandler.mapOfContentPack.put(cp.id,cp);
        cpTriggerhandler.packsId.add(cp.id);
        
        insertCv.add(contentVersionInsert);
        
        ContentVersion cvzip = new ContentVersion(
            Title = 'TestContentpackzipfiletest',
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
               
        ContentWorkspace cw = [select id, Name,DeveloperName from ContentWorkspace limit 1];
        // Create ContentDocumentLink record.
        List<ContentDocumentLink> lstOfcdl = new List<ContentDocumentLink>();
        
        for(ContentVersion testcv:  [SELECT Id,ContentDocumentId, Title,FileType FROM ContentVersion where islatest = true and FileType != 'ZIP' and id In : cvIds])
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
    // = TEST METHOD 1: TESTING FOR Pages Method.
    // =======================================================================================================================================    
    @isTest static void test1()
    {
        
        system.debug(' *** START QUERIES ISSUED = ' + Limits.getQueries()); 

        ContentVersion cvfile = [SELECT Id,ContentDocumentId,ContentSize, Title,FileType FROM ContentVersion where IsLatest = true and Title = 'TestContentVersion'];
        ContentVersion cvzipfile = [SELECT Id,ContentSize,ContentDocumentId, Title,FileType FROM ContentVersion where IsLatest = true and Title = 'TestContentpackzipfiletest'];
        
        AH_ContentPacks_ZipFile_Ctlr czp = new AH_ContentPacks_ZipFile_Ctlr();
        AH_ContentPacks_ZipFile_Ctlr.ContentVersionWarp cvWarp = new AH_ContentPacks_ZipFile_Ctlr.ContentVersionWarp(cvfile);
        cvWarp.selectedFile = true;
        czp.searchKey =  'TestContentVersion';
        Test.startTest();        
        czp.search();
        czp.clear();
        czp.getlibrarylist();
        //czp.hasError();
        Test.stopTest();
        
        system.debug(' ***  END QUERIES ISSUED = ' + Limits.getQueries());  
        
    }
    
    // =======================================================================================================================================
    // = TEST METHOD 2: TESTING FOR AH_ContentPacks_ZipFile_Ctlr class methods.
    // =======================================================================================================================================    
    @isTest static void test2()
    {
        
        system.debug(' *** START QUERIES ISSUED = ' + Limits.getQueries()); 

        ContentVersion cvfile = [SELECT Id,ContentDocumentId,ContentSize, Title,FileType FROM ContentVersion where IsLatest = true and Title = 'TestContentVersion'];
        ContentVersion cvzipfile = [SELECT Id,ContentDocumentId,ContentSize, Title,FileType FROM ContentVersion where IsLatest = true and Title = 'TestContentpackzipfiletest'];
        AH_ContentPacks_ZipFile_Ctlr czp = new AH_ContentPacks_ZipFile_Ctlr();
        AH_ContentPacks_ZipFile_Ctlr.ContentVersionWarp cvWarp = new AH_ContentPacks_ZipFile_Ctlr.ContentVersionWarp(cvfile);
        cvWarp.selectedFile = true;
        czp.contentPackName = 'contentPackName';
        ContentWorkspace cw = [select id, Name,DeveloperName from ContentWorkspace limit 1];
        czp.selectLibForPublish = cw.id;
        Test.startTest();
        czp.listOfFiles = new list<AH_ContentPacks_ZipFile_Ctlr.ContentVersionWarp>();          
        czp.listOfFiles.add(cvWarp);
        czp.createZipFile();
        Test.stopTest();
        
        system.debug(' ***  END QUERIES ISSUED = ' + Limits.getQueries());  
        
    }
}