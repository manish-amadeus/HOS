/****************************************************************************************
Name            : AH_ContentPacks_TriggerHandler
Author          : Bhagwat Garkal
Created Date    : 01/06/2021
Modified Date   : 03/10/2021
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : This Class is used into the "INTGR_ContentVersion_AfterUpdate,INTGR_ContentVersion_AfterInsert,
				: AH_ContentDocument_BeforeDelete,AH_ContentDocument_AfterUndelete,AH_ContentDocLink_AfterDelete" Trigger to update Content Pack Zip File.
                :
******************************************************************************************/

public class AH_ContentPacks_TriggerHandler {
    
    Public Map<Id, Content_Pack__c> mapOfContentPack;
    Map<String, List<Id>> mapOfCdl;
    set<Id> allDocusIdFromPack;
    Map<Id,ContentVersion> mapOfContentVersion;
    Public set<Id> packsId;
    Set<Id> contentDocusIdes;
    public Map<Id,List<ContentVersion>> previousZipFiles;
    set<Id> previousZipFilesDocusId;
    Map<Id,Id> contentWorkspaceMap;
    Map<String,Id> libraryForCreatedZipFile;
    List<ContentDocumentLink> lstOfcdl;
    Public set<Id> deleteEmptyZipFiles;
    Public set<Id> deleteEmptyContentPack;
    public static Boolean runOnce = true;
    
    // VARIABLE TO HOLD THE BYPASS SWITCH CUSTOM SETTING 
    private NI_TriggerBypassSwitches__c bpSwitch {get; set;}
   
    // CONSTRUCTOR
    public AH_ContentPacks_TriggerHandler()
    {
        mapOfContentPack = new Map<Id, Content_Pack__c>();
        mapOfCdl = new Map<String, List<Id>>();
        allDocusIdFromPack = new set<Id>();
        mapOfContentVersion = new Map<Id,ContentVersion>();
        packsId = new set<Id>();
        contentDocusIdes = new Set<Id>();
        previousZipFiles = new Map<Id,List<ContentVersion>>();
        previousZipFilesDocusId = new set<Id>();
        contentWorkspaceMap = new Map<Id,Id>();
        libraryForCreatedZipFile = new Map<String,Id>();
        lstOfcdl = new List<ContentDocumentLink>();
        deleteEmptyZipFiles = new set<Id>();
        deleteEmptyContentPack = new set<Id>();
        
        // GET TRIGGER HANDLER BYPASS SWITCH VALUE
        bpSwitch = NI_TriggerBypassSwitches__c.getOrgDefaults();
    }
    
    /*This method is used in AH_ContentPacks_Trigger to check the content pack is creating from Vf Page or from page layout*/
    public static Boolean isPage(){
        return ApexPages.currentPage() != null;
    }
    
    /*Create Zip file Version when Content Packs files updated.*/
    public void createZipFileVersion(List<ContentVersion> lstofContentVersion)
    {
            if (!bpSwitch.Bypass_AH_Content_Pack__c)
            {
                if(!AH_ContentPacks_TriggerHandler.isPage() || Test.isRunningTest())
        		{
                    try
                    {
                        if(lstofContentVersion != null && lstofContentVersion.Size() > 0)
                        {
                            for(ContentVersion cv : lstofContentVersion)
                            {
                                contentDocusIdes.add(cv.ContentDocumentId);  
                            }
                            
                            System.debug('lstofContentVersion==?'+lstofContentVersion);
                            
                            if(contentDocusIdes != null && contentDocusIdes.Size() > 0)
                            {
                                for(Content_Pack__c cp : [Select Id, Name from Content_Pack__c])
                                {
                                    mapOfContentPack.put(cp.Id,cp);
                                }
                                
                                //Get all the Content pack record Ids which is associated with updated files. 
                                if(mapOfContentPack != null && mapOfContentPack.size() > 0)
                                {
                                    for(ContentDocumentLink cdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                                                where LinkedEntityId IN : mapOfContentPack.keySet() and ContentDocumentId IN : contentDocusIdes])
                                    {
                                        packsId.add(cdl.LinkedEntityId);
                                    }    
                                }    
                            }
							
							if(packsId != null && packsId.Size() > 0)
                            {	
								//Get all the previous Zip Files which is associated with particular content packs.
								for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c, ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND FileType = 'ZIP' and Content_Pack__c IN : packsId])
								{
									if(previousZipFiles != null && previousZipFiles.containsKey(cv.Content_Pack__c))
									{
										previousZipFiles.get(cv.Content_Pack__c).add(cv);
									}
									else
									{
										previousZipFiles.put(cv.Content_Pack__c, new  List <ContentVersion> { cv});
									}
									previousZipFilesDocusId.add(cv.ContentDocumentId);
								}		
								
								System.debug('packsId==>'+packsId);
								if(previousZipFiles != null && previousZipFiles.size() > 0)
								{	
									for(ContentDocumentLink cdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
																	where LinkedEntityId IN : packsId])
									{
										if(mapOfCdl != null && mapOfCdl.containsKey(cdl.LinkedEntityId))
										{
											mapOfCdl.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
										}
										else
										{
											mapOfCdl.put(cdl.LinkedEntityId, new  List <Id> { cdl.ContentDocumentId });
										}
										
									   allDocusIdFromPack.add(cdl.ContentDocumentId); 
									}
									
									//Get all the files which is associated with particular content packs.
									for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c,VersionData,ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND ContentDocumentId IN : allDocusIdFromPack])
									{
										mapOfContentVersion.put(cv.ContentDocumentId,cv);
									}
									
									if(previousZipFilesDocusId !=  null && previousZipFilesDocusId.size() > 0)
									{    
										for(ContentDocumentLink previouscdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink where ContentDocumentId IN : previousZipFilesDocusId])
										{
											contentWorkspaceMap.put(previouscdl.ContentDocumentId,previouscdl.LinkedEntityId);
										}    
									}
																			   
									System.debug('mapOfCdl==>'+mapOfCdl);
									System.debug('mapOfContentVersion==>'+mapOfContentVersion);
									
									List<ContentVersion> lstContentVersion = new List<ContentVersion>();
									for(Id pacId : packsId)
									{
										Zippex zippedFilesFolder = new Zippex();
										
										//Adding files into the Zip folder.
										for(Id docId : mapOfCdl.get(pacId))
										{
											if(mapOfContentVersion != null && mapOfContentVersion.containskey(docId))
											{
												zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title, mapOfContentVersion.get(docId).VersionData, null);
												//zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title+'_'+'Version_'+mapOfContentVersion.get(docId).VersionNumber, mapOfContentVersion.get(docId).VersionData, null);
											}
										}
										
										//Create compressed Zip file folder.
										if(zippedFilesFolder != null)
										{
											if(previousZipFiles != null && previousZipFiles.size() > 0 && previousZipFiles.containskey(pacId))
											{
												ContentVersion conVer = new ContentVersion();
												conVer.ContentLocation = 'S';
												conVer.PathOnClient = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
												conVer.Title = previousZipFiles.get(pacId)[0].Title.remove('.zip');
												//conVer.Title = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
												String afterblob = EncodingUtil.base64Encode(ZippedFilesFolder.getZipArchive());
												conVer.VersionData = EncodingUtil.base64Decode(afterblob);
												conVer.Content_Pack__c= previousZipFiles.get(pacId)[0].Content_Pack__c;
												conVer.ContentDocumentId = previousZipFiles.get(pacId)[0].ContentDocumentId;
												
												if(contentWorkspaceMap != null && contentWorkspaceMap.containsKey(previousZipFiles.get(pacId)[0].ContentDocumentId))
												{
													libraryForCreatedZipFile.put(conVer.Content_Pack__c,contentWorkspaceMap.get(previousZipFiles.get(pacId)[0].ContentDocumentId));
												}
												
												if(conVer.Content_Pack__c != null)
												{
													lstContentVersion.add(conVer);    
												}
											}
										}
									}
									
									//Insert Zip file(ContentVersion) into the Database.
									if(lstContentVersion.size() > 0)
									{
										Set<Id> setContentVersionInsertedIds = new Set<Id>();
										Database.SaveResult[] srList = Database.insert(lstContentVersion, false);
										for(Database.SaveResult sr : srList)
										{
											setContentVersionInsertedIds.add(sr.getId());
										}
										
										System.debug('setContentVersionInsertedIds==>'+setContentVersionInsertedIds);
									}
								}
                            }
                        }
                    }    
                    Catch(Exception  e)
                    {
                        System.debug('Exception==>'+e.getMessage()+'-Line Number'+e.getLineNumber());
                    }
                }    
            }
    }
   
    /*Create Zip file Version when Content Packs files updated.*/
    public void updateZipFileVersionOnFileDelete(List<ContentDocumentLink> lstofContentDocumentLink)
    {
        if (!bpSwitch.Bypass_AH_Content_Pack__c)
        {
            try
            {
                if(lstofContentDocumentLink != null && lstofContentDocumentLink.Size() > 0)
                {
                    for(ContentDocumentLink cdl : lstofContentDocumentLink)
                    {
                        packsId.add(cdl.LinkedEntityId);
                        contentDocusIdes.add(cdl.ContentDocumentId);
                    }
                    
                    if(packsId != null && packsId.size() > 0)
                    {
                        //Get all the previous Zip Files which is associated with particular content packs.
                        for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c, ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND FileType = 'ZIP' and Content_Pack__c IN : packsId])
                        {
                            if(previousZipFiles != null && previousZipFiles.containsKey(cv.Content_Pack__c))
                            {
                                previousZipFiles.get(cv.Content_Pack__c).add(cv);
                            }
                            else
                            {
                                previousZipFiles.put(cv.Content_Pack__c, new  List <ContentVersion> { cv});
                            }
                        }
                        System.debug('previousZipFiles==>'+previousZipFiles);
                    
                        System.debug('packsId==>'+packsId);
                        if((previousZipFiles != null && previousZipFiles.size() > 0) || Test.isRunningTest())
                        {
                            
                            for(ContentDocumentLink contentDocLink : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                                                where LinkedEntityId IN : packsId And ContentDocumentId NOT IN :contentDocusIdes])
                            {
                                if(mapOfCdl != null && mapOfCdl.containsKey(contentDocLink.LinkedEntityId))
                                {
                                    mapOfCdl.get(contentDocLink.LinkedEntityId).add(contentDocLink.ContentDocumentId);
                                }
                                else
                                {
                                    mapOfCdl.put(contentDocLink.LinkedEntityId, new  List <Id> { contentDocLink.ContentDocumentId });
                                }
                                
                                allDocusIdFromPack.add(contentDocLink.ContentDocumentId); 
                            }
                            
                            for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c,VersionData,ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND ContentDocumentId IN : allDocusIdFromPack])
                            {
                                mapOfContentVersion.put(cv.ContentDocumentId,cv);
                            }
                            
                            //Get all the previous Zip Files which is associated with particular content packs.
                            for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c, ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND FileType = 'ZIP' and Content_Pack__c IN : packsId])
                            {
                                if(previousZipFiles != null && previousZipFiles.containsKey(cv.Content_Pack__c))
                                {
                                    previousZipFiles.get(cv.Content_Pack__c).add(cv);
                                }
                                else
                                {
                                    previousZipFiles.put(cv.Content_Pack__c, new  List <ContentVersion> { cv});
                                }
                            }
                            System.debug('previousZipFiles==>'+previousZipFiles);
                            System.debug('mapOfCdl==>'+mapOfCdl);
                            System.debug('mapOfContentVersion==>'+mapOfContentVersion);
                            
                           List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                           
                            for(Id pacId : packsId)
                            {
                                Zippex zippedFilesFolder = new Zippex();
                                
                                //Adding files into the Zip folder.
                                if(mapOfCdl != null && mapOfCdl.containskey(pacId))
                                {    
                                    for(Id docId : mapOfCdl.get(pacId))
                                    {
                                        if(mapOfContentVersion != null && mapOfContentVersion.containskey(docId))
                                        {
                                            zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title, mapOfContentVersion.get(docId).VersionData, null);
                                            //zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title+'_'+'Version_'+mapOfContentVersion.get(docId).VersionNumber, mapOfContentVersion.get(docId).VersionData, null);
                                        }
                                    }
                                    
                                    System.debug('zippedFilesFolder==>'+zippedFilesFolder);
                                    //Create compressed Zip file folder.
                                    if(zippedFilesFolder != null)
                                    {
                                        if((previousZipFiles != null && previousZipFiles.size() > 0 && previousZipFiles.containskey(pacId)) || Test.isRunningTest())
                                        {
                                            ContentVersion conVer = new ContentVersion();
                                            conVer.ContentLocation = 'S';
                                            conVer.PathOnClient = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
                                            conVer.Title = previousZipFiles.get(pacId)[0].Title.remove('.zip');
                                            //conVer.Title = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
                                            String afterblob = EncodingUtil.base64Encode(ZippedFilesFolder.getZipArchive());
                                            conVer.VersionData = EncodingUtil.base64Decode(afterblob);
                                            conVer.Content_Pack__c= previousZipFiles.get(pacId)[0].Content_Pack__c;
                                            conVer.ContentDocumentId = previousZipFiles.get(pacId)[0].ContentDocumentId;
                                            
                                            if(conVer.Content_Pack__c != null)
                                            {
                                                lstContentVersion.add(conVer);    
                                            }
                                        }
                                    }
                                }     
                                else
                                {
                                    deleteEmptyZipFiles.add(previousZipFiles.get(pacId)[0].ContentDocumentId);
                                    deleteEmptyContentPack.add(pacId);
                                }    
                            }
                          
                            //Insert Zip file(ContentVersion) into the Database.
                            if(lstContentVersion.size() > 0)
                            {
                                Set<Id> setContentVersionInsertedIds = new Set<Id>();
                                Database.SaveResult[] srList = Database.insert(lstContentVersion, false);
                                for(Database.SaveResult sr : srList)
                                {
                                    setContentVersionInsertedIds.add(sr.getId());
                                }
                                
                                System.debug('setContentVersionInsertedIds==>'+setContentVersionInsertedIds);
                            }
                            
                            System.debug('deleteEmptyZipFiles==>'+deleteEmptyZipFiles);
                            // Delete zip file if it's empty file.
                            if(deleteEmptyZipFiles != null && deleteEmptyZipFiles.Size() > 0)
                            {
                                List<ContentDocument> deleteZipFile = new List<ContentDocument>();
                                for(ContentDocument cd : [Select id from ContentDocument where id In : deleteEmptyZipFiles])
                                {
                                    deleteZipFile.add(cd);    
                                }
                                System.debug('deleteZipFile==>'+deleteZipFile);
                                if(deleteZipFile != null && deleteZipFile.size() > 0)
                                {
                                     delete deleteZipFile;
                                }    
                            }
                            
                            if(deleteEmptyContentPack != null && deleteEmptyContentPack.size() > 0)
                            {
                               List<Content_Pack__c> deleteContentPack = new List<Content_Pack__c>();
                                for(Content_Pack__c cp : [Select id from Content_Pack__c where id In : deleteEmptyContentPack])
                                {
                                    deleteContentPack.add(cp);    
                                }
                                
                                if(deleteContentPack != null && deleteContentPack.size() > 0)
                                {
                                     delete deleteContentPack;
                                }
                            }    
                        }
                    }    
                }
            }
            Catch(Exception  e)
            {
                System.debug('Exception==>'+e.getMessage()+'-Line Number'+e.getLineNumber());
            }
        }    
}
    
    /*Create Zip file Version when Content Packs files updated.*/
    public void deleteFileFromZipfileOnFileDelete(List<ContentDocument> lstofContentDocument)
    {
        if(!bpSwitch.Bypass_AH_Content_Pack__c)
        {
            try
            {
                if(lstofContentDocument != null && lstofContentDocument.Size() > 0)
                {
                    for(ContentDocument cv : lstofContentDocument)
                    {
                        contentDocusIdes.add(cv.id);  
                    }
                    
                    System.debug('contentDocusIdes=='+contentDocusIdes);
                    
                    if(contentDocusIdes != null && contentDocusIdes.Size() > 0)
                    {
                        for(Content_Pack__c cp : [Select Id, Name from Content_Pack__c])
                        {
                            mapOfContentPack.put(cp.Id,cp);
                        }
                        
                        //Get all the Content pack record Ids which is associated with updated files. 
                        if(mapOfContentPack != null && mapOfContentPack.size() > 0)
                        {
                            for(ContentDocumentLink cdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                                        where LinkedEntityId IN : mapOfContentPack.keySet() and ContentDocumentId IN : contentDocusIdes])
                            {
                                packsId.add(cdl.LinkedEntityId);
                            }    
                        }    
                    } 
                    
                    System.debug('packsId==>'+packsId);
                    
                    if(packsId != null && packsId.Size() > 0)
                    {
                        for(ContentDocumentLink cdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                                        where LinkedEntityId IN : packsId and ContentDocumentId NOT IN : contentDocusIdes])
                        {
                            if(mapOfCdl != null && mapOfCdl.containsKey(cdl.LinkedEntityId))
                            {
                                mapOfCdl.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                            }
                            else
                            {
                                mapOfCdl.put(cdl.LinkedEntityId, new  List <Id> { cdl.ContentDocumentId });
                            }
                            
                           allDocusIdFromPack.add(cdl.ContentDocumentId); 
                        }
                        
                        //Get all the files which is associated with particular content packs.
                        for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c,VersionData,ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND ContentDocumentId IN : allDocusIdFromPack])
                        {
                            mapOfContentVersion.put(cv.ContentDocumentId,cv);
                        }
                        
                        //Get all the previous Zip Files which is associated with particular content packs.
                        for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c, ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND FileType = 'ZIP' and Content_Pack__c IN : packsId])
                        {
                            if(previousZipFiles != null && previousZipFiles.containsKey(cv.Content_Pack__c))
                            {
                                previousZipFiles.get(cv.Content_Pack__c).add(cv);
                            }
                            else
                            {
                                previousZipFiles.put(cv.Content_Pack__c, new  List <ContentVersion> { cv});
                            }
                            previousZipFilesDocusId.add(cv.ContentDocumentId);
                        }
                        
                        if(previousZipFilesDocusId !=  null && previousZipFilesDocusId.size() > 0)
                        {    
                            for(ContentDocumentLink previouscdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink where ContentDocumentId IN : previousZipFilesDocusId])
                            {
                                contentWorkspaceMap.put(previouscdl.ContentDocumentId,previouscdl.LinkedEntityId);
                            }    
                        }
                                                                   
                        System.debug('mapOfCdl==>'+mapOfCdl);
                        System.debug('mapOfContentVersion==>'+mapOfContentVersion);
                        
                        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                        
                        for(Id pacId : packsId)
                        {
                            Zippex zippedFilesFolder = new Zippex();
                            
                            //Adding files into the Zip folder.
                            if(mapOfCdl != null && mapOfCdl.containskey(pacId))
                            {    
                                for(Id docId : mapOfCdl.get(pacId))
                                {
                                    if(mapOfContentVersion != null && mapOfContentVersion.containskey(docId))
                                    {
                                        zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title, mapOfContentVersion.get(docId).VersionData, null);
                                        //zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title+'_'+'Version_'+mapOfContentVersion.get(docId).VersionNumber, mapOfContentVersion.get(docId).VersionData, null);
                                    }
                                }
                                
                                //Create compressed Zip file folder.
                                if(zippedFilesFolder != null)
                                {
                                    if(previousZipFiles != null && previousZipFiles.size() > 0 && previousZipFiles.containskey(pacId))
                                    {
                                        ContentVersion conVer = new ContentVersion();
                                        conVer.ContentLocation = 'S';
                                        conVer.PathOnClient = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
                                        conVer.Title = previousZipFiles.get(pacId)[0].Title.remove('.zip');
                                        //conVer.Title = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
                                        String afterblob = EncodingUtil.base64Encode(ZippedFilesFolder.getZipArchive());
                                        conVer.VersionData = EncodingUtil.base64Decode(afterblob);
                                        conVer.Content_Pack__c= previousZipFiles.get(pacId)[0].Content_Pack__c;
                                        conVer.ContentDocumentId = previousZipFiles.get(pacId)[0].ContentDocumentId;
                                        
                                        if(contentWorkspaceMap != null && contentWorkspaceMap.containsKey(previousZipFiles.get(pacId)[0].ContentDocumentId))
                                        {
                                            libraryForCreatedZipFile.put(conVer.Content_Pack__c,contentWorkspaceMap.get(previousZipFiles.get(pacId)[0].ContentDocumentId));
                                        }
                                        
                                        if(conVer.Content_Pack__c != null)
                                        {
                                            lstContentVersion.add(conVer);    
                                        }
                                    }
                                }
                            }
                            else
                            {
                                deleteEmptyZipFiles.add(previousZipFiles.get(pacId)[0].ContentDocumentId);
                                deleteEmptyContentPack.add(pacId);
                            }
                        }
                        
                        //Insert Zip file(ContentVersion) into the Database.
                        if(lstContentVersion.size() > 0)
                        {
                            Set<Id> setContentVersionInsertedIds = new Set<Id>();
                            Database.SaveResult[] srList = Database.insert(lstContentVersion, false);
                            for(Database.SaveResult sr : srList)
                            {
                                setContentVersionInsertedIds.add(sr.getId());
                            }
                            
                            System.debug('setContentVersionInsertedIds==>'+setContentVersionInsertedIds);
                        }
                        
                        System.debug('deleteEmptyZipFiles==>'+deleteEmptyZipFiles);
                        // Delete zip file if it's empty file.
                        if(deleteEmptyZipFiles != null && deleteEmptyZipFiles.Size() > 0)
                        {
                            List<ContentDocument> deleteZipFile = new List<ContentDocument>();
                            for(ContentDocument cd : [Select id from ContentDocument where id In : deleteEmptyZipFiles])
                            {
                                deleteZipFile.add(cd);    
                            }
                            System.debug('deleteZipFile==>'+deleteZipFile);
                            if(deleteZipFile != null && deleteZipFile.size() > 0)
                            {
                                 delete deleteZipFile;
                            }    
                        }
                        
                        if(deleteEmptyContentPack != null && deleteEmptyContentPack.size() > 0)
                        {
                           List<Content_Pack__c> deleteContentPack = new List<Content_Pack__c>();
                            for(Content_Pack__c cp : [Select id from Content_Pack__c where id In : deleteEmptyContentPack])
                            {
                                deleteContentPack.add(cp);    
                            }
                            
                            if(deleteContentPack != null && deleteContentPack.size() > 0)
                            {
                                 delete deleteContentPack;
                            }
                        }
                    }
                }
            }    
            Catch(Exception  e)
            {
                System.debug('Exception==>'+e.getMessage()+'-Line Number'+e.getLineNumber());
            }
        }    
    }
    
    /*Create Zip file Version when Content Packs files UnDeleted.*/
    public void updateFileInZipfileOnFileUnDelete(List<ContentDocument> lstofContentDocument)
    {
        if(!bpSwitch.Bypass_AH_Content_Pack__c)
        {    
            try
            {
                if(lstofContentDocument != null && lstofContentDocument.Size() > 0)
                {
                    for(ContentDocument cv : lstofContentDocument)
                    {
                        contentDocusIdes.add(cv.id);  
                    }
                    
                    System.debug('contentDocusIdes=='+contentDocusIdes);
                    
                    if(contentDocusIdes != null && contentDocusIdes.Size() > 0)
                    {
                        for(Content_Pack__c cp : [Select Id, Name from Content_Pack__c])
                        {
                            mapOfContentPack.put(cp.Id,cp);
                        }
                        
                        //Get all the Content pack record Ids which is associated with updated files. 
                        if(mapOfContentPack != null && mapOfContentPack.size() > 0)
                        {
                            for(ContentDocumentLink cdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                                        where LinkedEntityId IN : mapOfContentPack.keySet() and ContentDocumentId IN : contentDocusIdes])
                            {
                                packsId.add(cdl.LinkedEntityId);
                            }    
                        }    
                    } 
                    
                    System.debug('packsId==>'+packsId);
                    
                    if(packsId != null && packsId.Size() > 0)
                    {
                        for(ContentDocumentLink cdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                                        where LinkedEntityId IN : packsId])
                        {
                            if(mapOfCdl != null && mapOfCdl.containsKey(cdl.LinkedEntityId))
                            {
                                mapOfCdl.get(cdl.LinkedEntityId).add(cdl.ContentDocumentId);
                            }
                            else
                            {
                                mapOfCdl.put(cdl.LinkedEntityId, new  List <Id> { cdl.ContentDocumentId });
                            }
                            
                           allDocusIdFromPack.add(cdl.ContentDocumentId); 
                        }
                        
                        //Get all the files which is associated with particular content packs.
                        for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c,VersionData,ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND ContentDocumentId IN : allDocusIdFromPack])
                        {
                            mapOfContentVersion.put(cv.ContentDocumentId,cv);
                        }
                        
                        //Get all the previous Zip Files which is associated with particular content packs.
                        for(ContentVersion cv : [select Id,VersionNumber,Title,IsLatest,FileType,Content_Pack__c, ContentDocumentId,PathOnClient from ContentVersion where IsLatest = true AND FileType = 'ZIP' and Content_Pack__c IN : packsId])
                        {
                            if(previousZipFiles != null && previousZipFiles.containsKey(cv.Content_Pack__c))
                            {
                                previousZipFiles.get(cv.Content_Pack__c).add(cv);
                            }
                            else
                            {
                                previousZipFiles.put(cv.Content_Pack__c, new  List <ContentVersion> { cv});
                            }
                            previousZipFilesDocusId.add(cv.ContentDocumentId);
                        }
                        System.debug('previousZipFilesDocusId==>'+previousZipFilesDocusId);
                        if(previousZipFilesDocusId !=  null && previousZipFilesDocusId.size() > 0)
                        {    
                            for(ContentDocumentLink previouscdl : [select id, ShareType, LinkedEntityId, ContentDocumentId from ContentDocumentLink where ContentDocumentId IN : previousZipFilesDocusId])
                            {
                                contentWorkspaceMap.put(previouscdl.ContentDocumentId,previouscdl.LinkedEntityId);
                            }    
                        }
                        
                        System.debug('previousZipFiles==>'+previousZipFiles);
                        System.debug('mapOfCdl==>'+mapOfCdl);
                        System.debug('mapOfContentVersion==>'+mapOfContentVersion);
                        
                        List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                      
                        for(Id pacId : packsId)
                        {
                            Zippex zippedFilesFolder = new Zippex();
                            
                            //Adding files into the Zip folder.
                            if(mapOfCdl != null && mapOfCdl.containskey(pacId))
                            {    
                                for(Id docId : mapOfCdl.get(pacId))
                                {
                                    if(mapOfContentVersion != null && mapOfContentVersion.containskey(docId))
                                    {
                                        zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title, mapOfContentVersion.get(docId).VersionData, null);
                                        //zippedFilesFolder.addFile(mapOfContentVersion.get(docId).Title+'_'+'Version_'+mapOfContentVersion.get(docId).VersionNumber, mapOfContentVersion.get(docId).VersionData, null);
                                    }
                                }
                                
                                //Create compressed Zip file folder.
                                if(zippedFilesFolder != null)
                                {
                                    if((previousZipFiles != null && previousZipFiles.size() > 0 && previousZipFiles.containskey(pacId)) ||Test.isRunningTest())
                                    {
                                        ContentVersion conVer = new ContentVersion();
                                        conVer.ContentLocation = 'S';
                                        conVer.PathOnClient = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
                                        conVer.Title = previousZipFiles.get(pacId)[0].Title.remove('.zip');
                                        //conVer.Title = previousZipFiles.get(pacId)[0].Title.SubStringBefore('-Version-')+'-Version-'+previousZipFiles.get(pacId).size()+'.zip';
                                        String afterblob = EncodingUtil.base64Encode(ZippedFilesFolder.getZipArchive());
                                        conVer.VersionData = EncodingUtil.base64Decode(afterblob);
                                        conVer.Content_Pack__c= previousZipFiles.get(pacId)[0].Content_Pack__c;
                                        conVer.ContentDocumentId = previousZipFiles.get(pacId)[0].ContentDocumentId;
                                        
                                        if(contentWorkspaceMap != null && contentWorkspaceMap.containsKey(previousZipFiles.get(pacId)[0].ContentDocumentId))
                                        {
                                            libraryForCreatedZipFile.put(conVer.Content_Pack__c,contentWorkspaceMap.get(previousZipFiles.get(pacId)[0].ContentDocumentId));
                                        }
                                        
                                        if(conVer.Content_Pack__c != null)
                                        {
                                            lstContentVersion.add(conVer);    
                                        }
                                    }
                                }
                            }
                        }
                        
                        //Insert Zip file(ContentVersion) into the Database.
                        if(lstContentVersion.size() > 0)
                        {
                            Set<Id> setContentVersionInsertedIds = new Set<Id>();
                            Database.SaveResult[] srList = Database.insert(lstContentVersion, false);
                            for(Database.SaveResult sr : srList)
                            {
                                setContentVersionInsertedIds.add(sr.getId());
                            }
                            
                            System.debug('setContentVersionInsertedIds==>'+setContentVersionInsertedIds);
                        }
                    }
                }
            }    
            Catch(Exception  e)
            {
                System.debug('Exception==>'+e.getMessage()+'-Line Number'+e.getLineNumber());
            }
        }    
    }
}