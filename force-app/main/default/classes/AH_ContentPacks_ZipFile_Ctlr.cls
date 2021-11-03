/****************************************************************************************
Name            : AH_Content_packs_Zip_file
Author          : Bhagwat Garkal
Created Date    : 12/23/2020
Modified Date   : 12/23/2020
Last Mod By     : Bhagwat Garkal
NICC Reference  : 
Description     : This Class is used to Create Zip file into the Content Packs.
                :
******************************************************************************************/

public without sharing class AH_ContentPacks_ZipFile_Ctlr 
{
    public list<ContentVersionWarp> listOfFiles {get;set;}
    public String searchKey {get;set;}
    public String selectedLibrary {get;set;}
    public String selectLibForPublish {get;set;}
    public String contentPackName {get;set;}
    public String tags{get;set;}
    public String comments {get;set;}
    public Boolean displayFileNotFound{get;set;}
    public List<SelectOption> librarylistInPopup {get;set;}
    public Boolean displaySuccessMsg{get;set;}
  
    public AH_ContentPacks_ZipFile_Ctlr()
    {
        displayFileNotFound = false;
        displaySuccessMsg = true;
        listOfFiles = new list<ContentVersionWarp>();
    }
    
    public class ContentVersionWarp {
        public String name { get; set; }
        public boolean selectedFile { get; set; }
        public String cvId {get; set; }
        public String contentDocumentId{get; set; }
        public String fileType{get; set; }
        public String contentSize{get; set; }
        public ContentVersionWarp(ContentVersion cv) 
        {
            if(cv != null)
            {
                name = cv.title;
                cvId = cv.id;
                contentDocumentId = cv.ContentDocumentId;
                selectedFile = false;
                contentSize = FileSizeToString(cv.ContentSize);
            }
        }
        
        public String FileSizeToString(Long Value)
        {
            /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
            if (Value < 1024)
                return string.valueOf(Value) + ' Bytes';
            else
                if (Value >= 1024 && Value < (1024*1024))
            {
                //KB
                Decimal kb = Decimal.valueOf(Value);
                kb = kb.divide(1024,2);
                return string.valueOf(kb) + ' KB';
            }
            else
                if (Value >= (1024*1024) && Value < (1024*1024*1024))
            {
                //MB
                Decimal mb = Decimal.valueOf(Value);
                mb = mb.divide((1024*1024),2);
                return string.valueOf(mb) + ' MB';
            }
            else
            {
                //GB
                Decimal gb = Decimal.valueOf(Value);
                gb = gb.divide((1024*1024*1024),2);
                
                return string.valueOf(gb) + ' GB';
            }    
        }
    }
    
    //Search files method
    public void search()
    {
        displayFileNotFound = false;
        listOfFiles = new list<ContentVersionWarp>();
        
        String  searchquery ='select Id,Title,ContentDocumentId,FileType,ContentSize, FirstPublishLocationId from ContentVersion where Title like \'%'+String.escapeSingleQuotes(searchKey)+'%\'';
            
        if(selectedLibrary != null && selectedLibrary != '')
        {
            searchquery += ' AND ContentDocument.ParentId =\''+String.escapeSingleQuotes(selectedLibrary)+'\'';    
        }
        
        searchquery += ' AND IsLatest = true AND ContentSize < 1048576  order by ContentSize asc Limit 500 ';
        
        System.debug('searchquery='+searchquery);
        if(searchquery != null && searchquery != '')
        {
            for(ContentVersion cvRecord: Database.query(searchquery))
            {
                if(cvRecord.FileType != 'ZIP' && cvRecord.FileType != 'PACK')
                {
                    listOfFiles.add(new ContentVersionWarp(cvRecord));    
                }
            }
            
            if(listOfFiles == null || listOfFiles.Size() == 0)
            {
                displayFileNotFound = true;
            }
            displaySuccessMsg = false;
        }
        
        System.debug('listOfFiles==>'+listOfFiles);
    }
    
    public void clear()
    {
        listOfFiles.clear();
    }
    
    //Get library list to display on page
    public List<SelectOption> getlibrarylist() 
    {
        List<SelectOption> options = new List<SelectOption>();
        librarylistInPopup = new List<SelectOption>();
        //options.add(new SelectOption('','All Libraries'));
        librarylistInPopup.add(new SelectOption('','--None--'));
        Set<Id> cwsIds = new Set<Id>();
        Set<Id> groupwithUser = new Set<Id>();

        //Populating the Group with User with GroupId we are filtering only  for Group of Type Regular,Role and RoleAndSubordinates
        for(GroupMember  u : [select groupId from GroupMember where UserOrGroupId =: UserInfo.getUserId()])
        {
            groupwithUser.add(u.groupId);
        }
        
        for(ContentWorkspaceMember cwm : [Select Id,ContentWorkspaceId,ContentWorkspacePermissionId,MemberId,MemberType From ContentWorkspaceMember where (ContentWorkspacePermission.Name = 'Workspace Administrator' OR ContentWorkspacePermission.PermissionsAddContent = true) and (MemberId =: UserInfo.getUserId() OR MemberId IN : groupwithUser)])
        {
        	cwsIds.add(cwm.ContentWorkspaceId);    
        }
        
        for(ContentWorkspace cws : [select Id,DeveloperName,Name from ContentWorkspace where Id IN : cwsIds])
        {
            options.add(new SelectOption(cws.id,cws.Name));
        }
        
        for(ContentWorkspace cws : [select Id,DeveloperName,Name from ContentWorkspace where Id IN : cwsIds])
        {
            librarylistInPopup.add(new SelectOption(cws.id,cws.Name));
        }
        return options;
    }
  
    
    //This method is used to create zip file
    public PageReference createZipFile()
    {
        try
        {
            if(contentPackName != null && contentPackName != '')
            {   
                if((selectLibForPublish == null || selectLibForPublish == '') &&  librarylistInPopup != null && librarylistInPopup.size() > 0)
                {
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Please select library.'));
                    return null;
                }
                
                if(listOfFiles != null && listOfFiles.size() > 0)
                {
                    set<Id> selectedFilesIds = new set<Id>();
                    List<ContentVersion> lstContentVersion = new List<ContentVersion>();
                    Set<ID> setContentVersionInsertedIds = new Set<ID>();
                    Set<ID> contentDocumentIdSet = new Set<ID>();
                    list<ContentDocumentLink> lstOfcdl = new list<ContentDocumentLink>();
                    Content_Pack__c contentPack = new Content_Pack__c();
                    
                    for(ContentVersionWarp cvWarap : listOfFiles)
                    {
                        if(cvWarap.selectedFile == true)
                        {
                            selectedFilesIds.add(cvWarap.cvId);
                            contentDocumentIdSet.add(cvWarap.contentDocumentId);
                        }
                    }
                    
                    if(selectedFilesIds != null && selectedFilesIds.Size() > 0)
                    {
                        Zippex zippedFilesFolder = new Zippex();
                        List<Content_Pack__c> insertContentPack = new List<Content_Pack__c>();
                        list<id> contentpackIds = new list<id>();
                        
                        contentPack.name= contentPackName;
                        if(contentPack != null)
                        {
                            insertContentPack.add(contentPack);
                            
                            if(insertContentPack != null && insertContentPack.size() >0)
                            {
                                Database.SaveResult[] srList = Database.insert(insertContentPack, false);
                                for(Database.SaveResult sr : srList)
                                {
                                    contentpackIds.add(sr.getId());
                                }
                            }
                        }
                        
                        Set<ID> setOfcontentDocumentIds = new Set<ID>();
                        for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LINKEDENTITYID FROM ContentDocumentLink WHERE ContentDocumentId IN:contentDocumentIdSet])
                        {
                            setOfcontentDocumentIds.add(cdl.ContentDocumentId);
                        }
        
                        for(ContentVersion cv : [select Id,VersionNumber,Title,ContentDocumentId,PathOnClient,VersionData from ContentVersion where Id IN : selectedFilesIds])
                        {
                            zippedFilesFolder.addFile(cv.Title+'_'+cv.VersionNumber, cv.VersionData, null);
                            if(contentpackIds != null && contentpackIds.size() > 0)
                            {
                                ContentDocumentLink cDe = new ContentDocumentLink();
                                cDe.ContentDocumentId = cv.ContentDocumentId;
                                cDe.LinkedEntityId = contentpackIds[0];
                                cDe.ShareType = 'V';
                                cDe.Visibility = 'AllUsers';
                                lstOfcdl.add(cDe);    
                            }
                        }
                        
                        System.debug('contentPackName==>'+contentPackName);
                        
                        //preparing the zip file to insert into the database.
                        if(zippedFilesFolder != null)
                        {
                            ContentVersion conVer = new ContentVersion();
                            conVer.ContentLocation = 'S';
                            conVer.PathOnClient = contentPackName + '.zip';
                            conVer.Title = contentPackName + '.zip';
                            String afterblob = EncodingUtil.base64Encode(ZippedFilesFolder.getZipArchive());
                            conVer.VersionData = EncodingUtil.base64Decode(afterblob);
                            conVer.Description = comments;
                            conVer.TagCsv = tags;
                            
                            if(contentPack.Id != null)
                            {
                                conVer.Content_Pack__c=contentPack.Id;
                            }
                            lstContentVersion.add(conVer);    
                        }
                        
                        if(lstContentVersion.size() > 0)
                        {
                            Database.SaveResult[] srList = Database.insert(lstContentVersion, false);
                            for(Database.SaveResult sr : srList)
                            {
                                setContentVersionInsertedIds.add(sr.getId());
                            }
                            
                            if(lstOfcdl != null && lstOfcdl.size() > 0)
                            {
                                Database.SaveResult[] srListOfcdl = Database.insert(lstOfcdl, false);
                                System.debug('srListOfcdl==>'+srListOfcdl);
                            }
                            
                            System.debug('setContentVersionInsertedIds==>'+setContentVersionInsertedIds);
                            System.debug('selectLibForPublish==>'+selectLibForPublish);
                            
                            if(setContentVersionInsertedIds.size() > 0)
                            {
                                List<ContentDocumentLink> publishZipInselectLib = new List<ContentDocumentLink>();
                                for(ContentVersion cvRecord : [SELECT Id,Title,filetype, ContentDocumentId FROM ContentVersion WHERE IsLatest = true and filetype = 'ZIP' and Id IN : setContentVersionInsertedIds])
                                {
                                    ContentDocumentLink cDe = new ContentDocumentLink();
                                    cDe.ContentDocumentId = cvRecord.ContentDocumentId;
                                    cDe.LinkedEntityId = selectLibForPublish;
                                    cDe.ShareType = 'I';
                                    cDe.Visibility = 'AllUsers';
                                    publishZipInselectLib.add(cDe);
                                }
                                
                                System.debug('lstOfcdl==>'+lstOfcdl);
                                
                                if(publishZipInselectLib.size() > 0)
                                {
                                    insert publishZipInselectLib; 
                                }    
                            }
                        }
                    }
                    else
                    {
                        Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Please select at least one file.'));
                        return null;
                    }
                }
            }
            else
            {
                Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'Please enter content pack name.'));
                return null;
            }
            
            PageReference returnPage = Page.AH_CreateContentPackTab;
            returnPage.getParameters().put('success','true');
            returnPage.setRedirect(true);
            return returnPage;
        }
        Catch(Exception  e)
        {
            System.debug('Exception==>'+e.getMessage()+'-Line Number'+e.getLineNumber());
            Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.INFO,'You do not have the level of access necessary to perform the operation you requested. Please contact the your system administrator if access is necessary.'));
            return null;
        }    
    }
    
    public Boolean hasError { 
        get { 
            return ApexPages.hasMessages(); 
        }       
    }
}