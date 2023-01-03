/****************************************************************************************
Name            : AH_Rally_Library (TC Org Name: RallyLibraryTest)
Author          : Valerie Gallardo
Created Date    : 01/21/2014
Last Mod Date   : 11/25/2020
Last Mod By     : Sean Harris
NICC Reference  : NICC-047046
Description     : Utility class for Rally integration
				: 
******************************************************************************************/
Global class AH_Rally_Library extends AH_Rally_Credentials 
{
    
    public static String str 
    {
        get;
        set;
    }
    
    public static String objId;
    
    public static String getWorkspaceName() 
    {
        return AH_Rally_Credentials.workspace_name;
    }
    
    public static String sendRequestObject(String methodType, String endpoint, String body) 
    {
        
//        if (endpoint == null)
//        {
//            return null;
//        }
        
        HttpRequest request = new HttpRequest();
        request.setMethod(methodType);
        Blob headerValue = Blob.valueOf(AH_Rally_Credentials.userName + ':' + AH_Rally_Credentials.pwd);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Content-Type', 'application/javascript');
system.debug(' ::*:: str = ' + str);        
system.debug(' ::*:: endpoint = ' + endpoint);         
        request.setEndpoint(endpoint);
        //request.setTimeout(2000);
        HttpResponse res;
        
        if (body != null) 
        {
            request.setBody(body);
        }
        
        if (!Test.isRunningTest()) 
        {
            res = (new Http()).send(request);
            str = res.getBody();
        }
        
        return str;
        
    }
    
    WebService static String workspaceUrl() 
    {
        
        String url;
        String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/subscription.js';
system.debug(' :::: endPoint = ' + endPoint);           
        String getRequestedBody = AH_Rally_Library.sendRequestObject('GET', endpoint, null);
        JSONParser parser = JSON.createParser(getRequestedBody);
        
        while (parser.nextToken() != null) 
        {
            if (parser.getText() == 'Workspaces') 
            {
                while (parser.nextToken() != null) 
                {
                    
                    if (parser.getText() == '_ref') 
                    {
                        parser.nextToken();
                        url = parser.getText();
                    }
                    
                    System.debug(parser.getText());
                    
                    if (parser.getText() == '_refObjectName') 
                    {
                        parser.nextToken();
                        if (parser.getText() == getWorkspaceName()) 
                        {
                            break;
                        }                        
                    }
                    
                }
            }
        }
        
        return url;
        
    }
    
    public static Map<String, String> projectList() 
    {
        
        Map<String, String> projectUrl = new Map<String, String>();
        String endpoint = workspaceUrl();
        System.debug('endpoint---------' + endpoint);
        String getRequestedBody = AH_Rally_Library.sendRequestObject('GET', endpoint, null);
        String key;
        String value;
        JSONParser parser = JSON.createParser(getRequestedBody);
        
        while (parser.nextToken() != null) 
        {
            if (parser.getText() == 'Projects') 
            {
                
                while (parser.nextToken() != null) 
                {
                    if (parser.getText() == '_ref') 
                    {
                        parser.nextToken();
                        value = parser.getText();
                        
                        while (parser.nextToken() != null) 
                        {
                            if (parser.getText() == '_refObjectName') 
                            {
                                parser.nextToken();
                                key = parser.getText();
                                break;
                            }
                        }
                    }
                    
                    if (key != null && value != null) 
                    {
                        projectUrl.put(key, value);
                    }
                    
                }
                
                if (parser.getText() == 'RevisionHistory') 
                {
                    break;
                }
                
            }
            
        }
        
        System.debug(projectUrl);
        return projectUrl;
        
    }
    
    public static Map<String, String> getMapping() 
    {
        
        try 
        {
            
            Map<String, Object> map1 = (Map<String, Object>) JSON.deserializeUntyped(AH_Rally_Credentials.Defect_Field);
            Map<String, String> Mapping = new Map<String, String> ();
            String salesforcevalue;
            String rallyvalue;
            
            for (String key: map1.keySet()) 
            {
                rallyvalue = key;
                Map <String, Object> values = (Map<String, Object >) map1.get(key);
                
                for (String str1: values.keySet()) 
                {
                    
                    if (str1 == 'fldValue') 
                    {
                        if (values.get(str1) != null) 
                        {
                            salesforcevalue = (String) values.get(str1);
                        }
                    }
                    
                    if (str1 == 'literalValue') 
                    {
                        if (salesforcevalue == 'Default') 
                        {
                            salesforcevalue = 'DefaultValue--' + values.get(str1);
                        }
                    }
                    
                }
                
                Mapping.put(rallyvalue, salesforcevalue);
                
            }
            
            return Mapping;
            
        }
        catch (Exception e) { throw e; }
    }
    
    @future(callout = 'True')
    public static void updateValuesInRally(String Artifactid, String caseid, String[] fieldNames) 
    {
        
        //Sprint 124
        List<String> passThrough = new List<String> 
        {
            'Competitor_1__r.Name',
                'Competitor_2__r.Name',
                'Competitor_3__r.Name',
                'Competitor_4__r.Name',
                'Competitor_5__r.Name',
                'Competitor_1_BID__c',
                'Competitor_2_BID__c',
                'Competitor_3_BID__c',
                'Competitor_4_BID__c',
                'Competitor_5_BID__c',
                'Demand_Property_ID__c',
                'Demand_Property_ID_1__c',
                'emand_Property_ID_2__c',
                'Demand_Property_ID_3__c',
                'Demand_Property_ID_4__c',
                'Demand_Property_ID_5__c',
                'Property_Mapping__c',
                'Property_Mapping_1__c',
                'Property_Mapping_2__c',
                'Property_Mapping_3__c',
                'Property_Mapping_4__c',
                'Property_Mapping_5__c'
                };
                    
                    String query = 'SELECT ';
        
        for (String name: fieldNames) 
        {
            query = query + name + ',';
        }
        
        query = query.removeEnd(',');
        query = query + ' FROM Case WHERE Id = \'' + caseid + '\' ';
        
        System.debug('********Query = ' + query);
        
        Case c = Database.query(query);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('hierarchicalrequirement');
        gen.writeStartObject();
        
        for (String fieldName: fieldNames) 
        {
            
            System.debug('********************' + fieldName);
            String fieldValue;
            
            if (!passThrough.contains(fieldName)) 
            {
                System.debug('passingthrough the fieldNames for some fields');
                fieldValue = String.valueOf(c.get(fieldName));
            }
            
            if (fieldName == 'Customer_Severity__c') 
            {
                gen.writeStringField('SalesforcePriority', AH_Rally_FieldMapper.getRallyPriorityMapping(fieldName, fieldValue));
            }
            
            //US147795 - changes
            if (fieldName == 'Status') 
            {
                if (fieldValue == 'Duplicate' || fieldValue == 'SPAM') 
                {
                    gen.writeStringField('L3KanbanStage', 'Closed');
                }
                else if (fieldValue != null) 
                {
                    gen.writeStringField('L3KanbanStage', fieldValue);
                }
                else 
                {
                    gen.writeStringField('L3KanbanStage', '');
                }
            }
            
            if (fieldName != 'Status' && fieldName != 'Customer_Severity__c' && !passThrough.contains(fieldName) && fieldName != 'Management_Company__c') 
            {
                if (fieldValue == null) 
                {
                    gen.writeStringField(fieldName, '');
                }
                else 
                {
                    gen.writeStringField(fieldName, fieldValue);
                }
            }
            
        }
        
        gen.writeEndObject();
        gen.writeEndObject();        
        String jstring = gen.getAsString();        
        String response = sendRequestObject('POST', Artifactid, jstring);
        
    }
    
    public static void updateAccountValuesInRally(String Artifactid, String caseid, List<String> fieldNames) 
    {
        
        system.debug('in updateAccountValuesInRally');
        system.debug('in Artifactid' + Artifactid);
        system.debug('in caseid' + caseid);
        system.debug('in fieldNames' + fieldNames);
        
        String query = 'SELECT ';
        
        for (String name: fieldNames) 
        {
            query = query + name + ',';
        }
        
        query = query.removeEnd(',');
        query = query + ' FROM case WHERE Id = \'' + caseid + '\' ';
        
        Case c = Database.query(query);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('hierarchicalrequirement');
        gen.writeStartObject();
        
        for (String fieldName: fieldNames) 
        {
            String fieldValue = String.valueOf(c.get(fieldName));
        }
        
        gen.writeEndObject();
        gen.writeEndObject();
        
        String jstring = gen.getAsString();
        String response = sendRequestObject('POST', Artifactid, jstring);
        
    }
    
    //used to fetch discussion data form rally
    WebService static String insertCaseComment(String caseId, String commentId) 
    {
        
        system.debug('Inside InsertCaseComment: ');
        system.debug(' :::: caseId = ' + caseId + ', caseId = ' + commentId);
        
        String requestdata = AH_Rally_Library.createConversationPostContent(caseId, commentid);
        
        system.debug(' :::: requestdata.Length() = ' + requestdata.length());
        system.debug(' :::: requestdata = ' + requestdata);
        
        String endpoint = AH_Rally_Credentials.endPoint + '/slm/webservice/' + AH_Rally_Credentials.versionNumber + '/conversationpost/create.js';
        String getRequestedBody = AH_Rally_Library.sendRequestObject('POST', endpoint, requestdata);
        
        system.debug(' :::: getRequestedBody = ' + getRequestedBody);
        
        JSONParser parser = JSON.createParser(getRequestedBody);
        
        while (parser.nextToken() != null) 
        {
            if (parser.getText() == 'ObjectID') 
            {
                parser.nextToken();
                objId = parser.getText();
            }
        }
        return objid;
        
    }
    
    WebService static string createConversationPostContent(String caseId, String commentid) 
    {
        
        User u;
        Case c1;
        String type;
        String artifect;
        
        try 
        {
            
            System.debug(caseId);
            System.debug(commentid);
            CaseComment c = [SELECT CommentBody, CreatedBy.Name FROM CaseComment WHERE Id =: commentid];
            System.debug(c);
            c1 = [SELECT Rally_Artifact_Ref__c FROM Case WHERE Id =: caseId];
            
            artifect = c1.Rally_Artifact_Ref__c;
            System.debug(artifect);
            type = 'Hierarchicalrequirement';
            
            List<String> body = new List<String>();
            String cmtBody = c.CommentBody;
            String content = '';
            
            if (c.CommentBody != '' || c.CommentBody != null) 
            {
                body = cmtBody.split('\r\n', -2);
                if (!body.isEmpty())
                {
                    for (String i: body) 
                    {
                        if (i == '') 
                        {
                            content = content + '<div><br/></div>';
                        }
                        else 
                        {
                            content = content + '<div>' + i + '</div>';
                        }
                    }
                }
            }
            
            String username = '';
            if (!Test.isRunningTest()) 
            {
                username = c.CreatedBy.Name;
            }
            String body1 = content + '     ::' + 'Created by  ' + username + '--Salesforce';
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('ConversationPost');
            gen.writeStartObject();
            gen.writeStringField('_rallyAPIMajor', '1');
            gen.writeStringField('_rallyAPIMinor', '43');
            gen.writeStringField('Text', body1);
            gen.writeFieldName('Artifact');
            gen.writeStartObject();
            gen.writeStringField('_rallyAPIMajor', '1');
            gen.writeStringField('_rallyAPIMinor', '43');
            if (!Test.isRunningTest()) 
            {
                gen.writeStringField('_ref', artifect);
            }
            gen.writeStringField('_type', type);
            gen.writeEndObject();
            gen.writeStringField('_type', 'ConversationPost');
            gen.writeEndObject();
            gen.writeEndObject();
            
            String jstring = gen.getAsString();
            
            System.debug(jstring);
            
            return jstring;
            
        }
        
        catch (Exception e) 
        {
            return e.getmessage();
        }
        
    }
    
}