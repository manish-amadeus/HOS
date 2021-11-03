/****************************************************************************************
Name            : AH_Rally_LEXMethods
Author          : Sean Harris
Created Date    : 11/25/2020
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Class with @auraEnabled methods used by Lightning Components
				: 
				: 
******************************************************************************************/
public class AH_Rally_LEXMethods 
{
    
    @auraEnabled
    public static Map<String, sObject> returnCaseRecs(String caseId)
    {
        Map<String, sObject> mp = new Map<String, sObject>();
        try
        {
            Case cs = [SELECT L3_Steps_To_Reproduce__c, Rally_Artifact_Ref__c, L3_Ticket_Summary__c, Rally_Case_Type__c FROM Case WHERE Id =: caseId LIMIT 1];
            mp.put('getCase', cs);
            AH_Rally_Setup__c rallySMObj = [SELECT Username__c, Password__c, RallyURL__c, Workspace__c, API_Version__c FROM AH_Rally_Setup__c ORDER BY Name ASC];						        
            mp.put('getRallySM', rallySMObj);            
        }
        catch (Exception e)
        {
            system.debug('Error : ' + e.getStackTraceString());
        }
        return mp;
    }

    @auraEnabled
    public static List<String> returnAttachments(String caseId)
    {
        List<Case_Attachment_Relation__c> attachmentIdL = [SELECT Sf_Attachment_Id__c FROM Case_Attachment_Relation__c WHERE To_be_Send__c = true and Case_Id__c =: caseId];
        List<String> ids = new List<String>();
        for (Case_Attachment_Relation__c c : attachmentIdL)
        {
            ids.add(c.Sf_Attachment_Id__c);
        }
        return ids;        
    }

    @auraEnabled
    public static List<String> returnComments(String caseId)
    {
        List<String> ids = new List<String>();
        List<Case_Comment_Relation__c> commentIdL = [SELECT Sf_Comment_Id__c FROM Case_Comment_Relation__c WHERE To_be_Send__c = true and Case_Id__c =: caseId];
        for (Case_Comment_Relation__c c : commentIdL)
        {
            ids.add(c.Sf_Comment_Id__c);
        }
        return ids;
    }
    
    @auraEnabled
    public static String returnWorkspaceURL()
    {
        String workspaceURL = AH_Rally_Library.workspaceUrl(); 
        return workspaceURL;
    }

    @auraEnabled
    public static String resultofUserStory(String caseId)
    {
        String msg = AH_Rally_CreateUserStory.createUserStory(caseID);
        return msg;
    }

    @auraEnabled
    public static String callout(String methodType, String endPoint, String body)
    {
        String res = AH_Rally_Library.sendRequestObject(methodType, endpoint, body); 
        return res;
    }

    @auraEnabled
    public static void updateComments(String caseId, String defectId, String commentId, String SalesforceCommentId)
    {
        AH_Rally_InsertIntoDB.UpdateIntoCommentObject(caseId, defectId, commentId, SalesforceCommentId);
    }    
    
    @auraEnabled
    public static String sendAttachmentMethod(String attachId)
    {
        String myQuery = 'SELECT Name, BodyLength, Body, ContentType from Attachment WHERE Id = \'' + attachId + '\' ';  
        Attachment a = Database.query(myQuery);
        JSONGenerator gen = JSON.createGenerator(true);   
        gen.writeStartObject();
        gen.writeStringField('Name', a.Name);
        gen.writeNumberField('BodyLength', a.BodyLength);               
        gen.writeStringField('Body', EncodingUtil.base64encode(a.Body));
        if (a.ContentType != null)
        {
            gen.writeStringField('ContentType', a.ContentType);    
        }  
        gen.writeEndObject(); 
        String jstring = gen.getAsString();
        return jstring; 
    }

    @auraEnabled
    public static void callUpdateIntoCARBasedOnOperation(String defectId, String cID, String RallyattachemntId, String Salesforceattid)
    {
        String dId = String.valueOf(defectId);
        String rattachId = String.valueOf(RallyattachemntId);
        try
        {
            Case_Attachment_Relation__c carList = [SELECT Sf_Attachment_Id__c, Case_Id__c, To_be_Send__c 
                                                   FROM Case_Attachment_Relation__c 
                                                   WHERE To_be_Send__c = true 
                                                   AND Sf_Attachment_Id__c =: Salesforceattid];
            if (carList != null)
            {
                carList.Rally_Attachment_Id__c = RallyattachemntId;
                carList.Defect_Id__c = defectId;
                carList.Status__c = 'Sent';
                carList.To_be_Send__c = false; 
                update carList;
            }
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void makeUserLREFalse()
    {
        String userId = System.UserInfo.getUserId();
        User u = [SELECT Id, Name, UserPreferencesLightningExperiencePreferred FROM User WHERE Id =: userId];
        if (u.UserPreferencesLightningExperiencePreferred)
        {
            u.UserPreferencesLightningExperiencePreferred = false;
        }
        update u;
    }
    
/*
    @auraEnabled
    public static void sendAttachment(List<String> attachId)
    {
    	//takes the Id that is returned from above "returnAttachments" method        
    }

    @auraEnabled
    public static String returnConversationBody(String caseId, String commentid)
    {
        String jsonBody = CaseCommentofSalesforce.createConversationPostContent(caseId, commentid);
        return jsonBody;
    }
*/
    
    @AuraEnabled
    public static String getContentDocs(Id recId)
    {   
        
        List<ContentDocumentLink> cdls = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recId];
        
        // Make a List of ContentDocument IDs
        List<Id> cdIdList = new List<Id>();
        
        for (ContentDocumentLink nextCDL : cdls) 
        {
            cdIdList.add(nextCDL.ContentDocumentId); 
        }        
        
        Case caseRallyUS = [SELECT Id, User_Story_Id__c FROM Case WHERE Id =: recId];
        
        List<Case_Attachment_Relation__c> cars = [SELECT SF_File_Id__c, Status__c FROM Case_Attachment_Relation__c WHERE SF_File_Id__c != '' AND Case_Id__c =: recId];
        
        Map<Id, String> carRelationMap = new Map<Id, String>();
        
        for (Case_Attachment_Relation__c car:cars)
        {                   
            carRelationMap.put(car.SF_File_Id__c, car.Status__c);
        }
        
        List<ContentDocument> entries = [SELECT Id, Title, FileType, ContentSize, LastModifiedDate FROM ContentDocument WHERE Id IN :cdIdList order by CreatedDate desc];
        List<FileWrap> fwl = new List<FileWrap>();
        
        for (ContentDocument cd : entries)
        {
            
            FileWrap fw = new FileWrap();
            fw.Id = cd.Id;
            fw.Title = cd.Title;
            fw.FileType = cd.FileType;
            fw.ContentSize = cd.ContentSize;
            fw.LastModifiedDate = cd.LastModifiedDate;
            fw.Body = '';            
            fw.Description = '';
            
            if (caseRallyUS.User_Story_Id__c !='' && caseRallyUS.User_Story_Id__c != null)
            {
                fw.userStoryCreated = true;
            }
            
            if (carRelationMap.containsKey(cd.Id))
            {
                fw.fileStatus = carRelationMap.get(cd.Id);
            }
            
            fwl.add(fw);
            
        }
        
        return JSON.serialize(fwl);
        
    }
    
    @AuraEnabled
    public static void deleteFiles(Id recId)
    { 
        ContentDocument cd = [SELECT Id, Title, FileType, ContentSize, LastModifiedDate FROM ContentDocument WHERE Id =: recId];
        delete cd;
    }
    
    @AuraEnabled
    public static String sendAttachment(Id recId, Id caseId)
    { 
        
        String res = ''; 
        
        try
        {  
            
            String username;
            String password;
            String workspacename;
            String Rallyurl; 
            String API_Version;
            
            if (!Test.isRunningTest())
            {
                String workspaceUrl = AH_Rally_Library.workspaceUrl();
            }
            
            AH_Rally_Setup__c rrsc = [SELECT Username__c, Password__c, RallyURL__c, Workspace__c,API_Version__c FROM AH_Rally_Setup__c ORDER BY Name ASC LIMIT 1]; 
            
            if (rrsc != null)
            {
                username = rrsc.Username__c;
                password = rrsc.Password__c;
                workspacename=rrsc.Workspace__c;
                API_Version = rrsc.API_Version__c;
                Rallyurl = rrsc.RallyURL__c; 
            }
            
            String jsonStr = AH_Rally_SendFiles.valuesofAttachmentFiles(recId);   
            
            if (jsonStr == 'FileSizeException')
            {
                res = 'exception|File size is too large to send to rally.';
            }
            else
            {
                FileWrap filewrap = (FileWrap)JSON.deserialize(jsonStr, FileWrap.class);           
                String attachmentContent = filewrap.Body;            
                res = AH_Rally_SendFiles.sendAttachmentFiles(recId, caseId);
                if (res == 'object not found')
                {
                    res = 'exception|User Story is Deleted in Rally';
                }
            }
            
        }
        catch (Exception e)
        {
            res='exception|' + e.getMessage();
        }
        
        return res;
        
    }

    //Accepts the record id and sends a boolean status about the updation
    @AuraEnabled @RemoteAction
    public static Boolean updateCase(Id caseId){
        try{
            case cs = new case();
            cs.id = caseId;
            cs.recordtypeid=Schema.SObjectType.case.getRecordTypeInfosByName().get('Rally Support').getRecordTypeId();
            update cs;
            return true;
        }
        catch(Exception e){
            return false;
        }
    }
    
    public class FileWrap
    {
        Id id;
        Integer ContentSize;  
        Datetime LastModifiedDate;
        String Title;
        String Body;
        String FileType;
        String Description;
        String fileStatus;
        Boolean userStoryCreated = false;
    }
    
}