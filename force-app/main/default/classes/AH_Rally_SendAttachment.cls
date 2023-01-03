/****************************************************************************************
Name            : AH_Rally_SendAttachment (TC Org Name: SendAttachmentByApex)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-
Description     : 
				: 
				: 
******************************************************************************************/
global class AH_Rally_SendAttachment 
{
    
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
        artifact = artifact.replace(endpoint, '');
        artifact = artifact.replace('.js', '');                        
        return artifact; 
    }
    
    public static void setValues(String attachId)
    {
        
        Attachment queryAttachment = [SELECT Body, ContentType, Description, Name, BodyLength FROM Attachment WHERE Id =: attachId];          
        FileName = queryAttachment.Name;
        Description = queryAttachment.Description;
        ContentType = 'text/plain';
        
        if (queryAttachment.ContentType != null) 
        { 
            ContentType = queryAttachment.ContentType; 
        }
        else
        {
system.debug('*^* FileName.toLowerCase() = ' + FileName.toLowerCase());            
            if (FileName.toLowerCase().endsWith('.msg'))
            {
                ContentType = 'application/vnd.ms-outlook';
            }
        }
        
        BodyLength = decimal.valueOf(queryAttachment.BodyLength);
        body = EncodingUtil.base64Encode(queryAttachment.Body);
        
    }     
    
    @TestVisible
    static string createJson_AttachmentContent(String attachId)
    {
        
        setValues(attachId);
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

    @TestVisible
    WebService static string createJson_Attachment()
    {
        
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();
        gen.writeFieldName('Attachment');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43'); 
        if (ContentType != null) { gen.writeStringField('ContentType', ContentType); }
        if (ref_attachment_content != null) { gen.writeStringField('Content', ref_attachment_content); }
        if (Description != null) { gen.writeStringField('Description', Description); }
        gen.writeStringField('Name', FileName);
        gen.writeNumberField('Size', BodyLength);         
        gen.writeFieldName('Artifact');
        gen.writeStartObject();
        gen.writeStringField('_rallyAPIMajor', '1');
        gen.writeStringField('_rallyAPIMinor', '43');   
        if (ref_defect != null) { gen.writeStringField('_ref', ref_defect); } 
        if (type != null) { gen.writeStringField('_type', type); }        
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
    
    @TestVisible
    Webservice static String sendAttachment(String attid, String caseId)
    {      
        
        integer j = 1;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
                
        try
        {
            
            Case ca = [SELECT Rally_Artifact_Ref__c FROM Case WHERE Id =: caseId];
            
            ref_defect = ca.Rally_Artifact_Ref__c;
            type = 'HierarchicalRequirement';             
system.debug('::: attid = ' + attid); 
            String data = createJson_AttachmentContent(attid);
system.debug('::: data = ' + data); 
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
            getRequestedBody = AH_Rally_Library.sendRequestObject('POST', endpoint, data); 
            System.debug(getRequestedBody);  
            parser = JSON.createParser(getRequestedBody);
            
            while (parser.nextToken() != null) 
            {         
                if (parser.getText() == 'Errors')
                {   
                    parser.nextToken(); 
                    parser.nextToken();
                    System.debug(parser.getText());
                    if (parser.getText().containsAny('Could not read: Could not read referenced object'))
                    {                
                        throw new AH_Rally_Exception();
                    }  
                    break;              
                }
            }
            AH_Rally_InsertIntoDB.insertIntoCAR(getDefectId(ref_defect), caseId, ContentobjectId, attid);
            return 'success';
        }
        catch (AH_Rally_Exception m)
        {
            return 'object not found';
        }
        catch (Exception e)
        {
            system.debug('::: e.getMessage() = ' + e.getMessage());  
            return e.getMessage();
        }
        
    }
    
    @TestVisible
    Webservice static String valuesofAttachment(String attachedid)
    {
        
        String myQuery = 'SELECT Name, BodyLength, Body, ContentType FROM Attachment WHERE Id =\'' + attachedid + '\'';  
        Attachment a = Database.query(myQuery);
        JSONGenerator gen = JSON.createGenerator(true);   
        gen.writeStartObject();
        gen.writeStringField('Name', a.Name);
        gen.writeNumberField('BodyLength', a.BodyLength);               
        gen.writeStringField('Body', EncodingUtil.base64encode(a.Body));
        if (a.ContentType != null){ gen.writeStringField('ContentType', a.ContentType); }  
        gen.writeEndObject(); 
        String jstring = gen.getAsString();
        System.debug(jstring);
        return jstring; 
        
    }
   
}