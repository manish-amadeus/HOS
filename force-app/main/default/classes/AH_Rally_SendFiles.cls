/****************************************************************************************
Name            : AH_Rally_SendFiles (TC Org Name: LRSendFilesByApex)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : 
				: 
				: 
******************************************************************************************/
global class AH_Rally_SendFiles 
{

    // US133872 
    private static String FileName;
    private static String Description;
    private static String ContentType;
    private static Decimal BodyLength;
    private static String body;
    private static String attachmentId;
    private static String ref_defect;
    public static String ref_attachment_content;
    public static String type;
    
    public static String getDefectId(String artifact)
    {
        String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/hierarchicalrequirement/';
        artifact = artifact.replace(endpoint,'');
        artifact = artifact.replace('.js','');                        
        return artifact;
    }

    WebService static string createJson_Attachment()
    {
        
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();
        gen.writeFieldName('Attachment');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43'); 
        
        if (ContentType!=null)
        {               
            gen.writeStringField('ContentType',ContentType);
        }
        
        gen.writeStringField('Content', ref_attachment_content);
        
        if (Description != null)
        {
            gen.writeStringField('Description', Description);
        }
        
        gen.writeStringField('Name', FileName);
        gen.writeNumberField('Size', BodyLength);
        gen.writeFieldName('Artifact');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');    
        gen.writeStringField('_ref', ref_defect); 
        gen.writeStringField('_type', type); 
        gen.writeEndObject(); 
        gen.writeFieldName('Workspace');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');    
        gen.writeStringField('_ref', AH_Rally_Library.workspaceUrl()); 
        gen.writeStringField('_refObjectName', AH_Rally_Library.getWorkspaceName()); 
        gen.writeStringField('_type', 'Workspace'); 
        gen.writeEndObject();
        gen.writeStringField('_type', 'Attachment');   
        gen.writeEndObject();           
        gen.writeEndObject();
        String jstring = gen.getAsString();
        
        return jstring;
        
    }

    public static void setValuesOfFiles(String cdId)
    {
        
        String myQuery = 'SELECT Title, LastModifiedDate FROM ContentDocument WHERE Id = \'' + cdId + '\'';  
        ContentDocument a = Database.query(myQuery);
        
        String myQuery_version = 'select VersionData, PathOnClient, ContentSize, Description, FileType FROM ContentVersion WHERE ContentDocumentId = \'' + cdId + '\'';  
        ContentVersion av = Database.query(myQuery_version);

        FileName = av.PathOnClient;
        
        if (av.Description != null)
        {
            Description = av.Description;
        }
        
        if (av.FileType != null)
        {
            ContentType = av.FileType;
        }
        
        BodyLength = decimal.valueOf(av.ContentSize);
        body = EncodingUtil.base64Encode(av.VersionData);
        
    }

    public static string createJson_AttachmentFileContent(String attachId)
    {
        
        setValuesOfFiles(attachId);
        JSONGenerator gen = JSON.createGenerator(true);   
        gen.writeStartObject();
        gen.writeFieldName('AttachmentContent');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');  
        gen.writeFieldName('Workspace');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');    
        gen.writeStringField('_ref', AH_Rally_Library.workspaceUrl()); 
        gen.writeStringField('_refObjectName', AH_Rally_Library.getWorkspaceName()); 
        gen.writeStringField('_type', 'Workspace'); 
        gen.writeEndObject(); 
        gen.writeStringField('Content', body);
        gen.writeStringField('_type', 'AttachmentContent');
        gen.writeEndObject();           
        gen.writeEndObject(); 
        String jstring = gen.getAsString();    
        
        return jstring; 
        
    }

    Webservice static String valuesofAttachmentFiles(String attachedid)
    {
        String jstring;
        String myQuery = 'SELECT Title, LastModifiedDate FROM ContentDocument WHERE Id = \'' + attachedid + '\'';  
        ContentDocument a = Database.query(myQuery);
        
        String myQuery_version = 'SELECT VersionData, ContentSize, Description, FileType from ContentVersion where ContentDocumentId = \'' + attachedid + '\'';  
        ContentVersion av=Database.query(myQuery_version);
     
        Integer fileSizeInMegaByte=  av.ContentSize / (1024 * 1024);
                
        if (fileSizeInMegaByte < 6) //less than 6 mb
        { 
                JSONGenerator gen = JSON.createGenerator(true);   
                gen.writeStartObject();
                gen.writeStringField('Title', a.Title);
                gen.writeNumberField('ContentSize', av.ContentSize);
                if (av.Description != null)
                {
                    gen.writeStringField('Description', av.Description);  
                }
                gen.writeStringField('Body', EncodingUtil.base64encode(av.VersionData));
                if (av.ContentSize != null)
                {
                  gen.writeStringField('FileType', av.FileType);    
                }  
                gen.writeEndObject(); 
                jstring = gen.getAsString();
        }
        else
        {
            jstring = 'FileSizeException';
        }
        
        System.debug(jstring);
        
        return jstring;     
        
    }
    
    Webservice static String sendAttachmentFiles(String cdId, String caseId)
    {      
        
        try
        {
            
            Case ca = [SELECT Rally_Artifact_Ref__c FROM Case WHERE Id =: caseId];
            
            ref_defect = ca.Rally_Artifact_Ref__c;
            type = 'HierarchicalRequirement';
            
            String data = createJson_AttachmentFileContent(cdId);
            String endpoint = 'https://rally1.rallydev.com/slm/webservice/1.43/attachmentcontent/create.js';
            String getRequestedBody = AH_Rally_Library.sendRequestObject('POST', endpoint, data);
            
            JSONParser parser = JSON.createParser(getRequestedBody);
            String ContentobjectId;
            
            while (parser.nextToken() != null) 
            {
                if (parser.getText() == '_ref')
                {
                    parser.nextToken();
                    ref_attachment_content = parser.getText();  
                }
                if (parser.getText() == 'ObjectID')
                {
                    parser.nextToken();
                    ContentobjectId = parser.getText(); 
                    break; 
                }             
            }
            
            endpoint = 'https://rally1.rallydev.com/slm/webservice/1.43/attachment/create.js'; 
            data = createJson_Attachment();
            getRequestedBody = AH_Rally_Library.sendRequestObject('POST',endpoint,data); 
            System.debug(getRequestedBody);  
            parser = JSON.createParser(getRequestedBody);
            
            while (parser.nextToken() != null) 
            {         
                if (parser.getText() == 'Errors')
                {   
                    parser.nextToken(); parser.nextToken();
                    System.debug(parser.getText());
                    if (parser.getText().containsAny('Could not read: Could not read referenced object'))
                    {                
                        throw new AH_Rally_Exception();
                    }  
                    break;              
                }
            }
            
            insertIntoFileCAR(getDefectId(ref_defect), caseId, ContentobjectId, cdId);
            
            return 'success';
            
        }
        catch (AH_Rally_Exception m)
        {
            return 'object not found';
        }
        catch(Exception e)
        {
            return e.getMessage();
        }
        
    }

    WebService static void insertIntoFileCAR(String string_def, String cID, String RallyattachemntId, String SalesforceAttId)
    {  
        
        String defectId;         
        defectId = getDefectId(string_def);
        String s1 = cID;
        Case_Attachment_Relation__c car = new Case_Attachment_Relation__c();
        
        if (cid.length() == 18)
        {            
            s1=cID.left(15);
        }

        car.Case_Id__c = s1;       
        car.Defect_Id__c = defectId;
        car.Rally_File_Id__c = RallyattachemntId;
        car.SF_File_Id__c = SalesforceAttId;
        car.Status__c = 'Sent';
        insert car;
        
    }   

}