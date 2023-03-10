/****************************************************************************************
Name            : AH_QueryCustomerIncident_Ctlr Class
Author          : Stuart Emery
Created Date    : 11/06/2017
Last Mod Date   : 11/21/2017
Last Mod By     : Stuart Emery
NICC Reference  : 
Description     : Controller for the AH_QueryCustomerIncident Visualforce page 
                : 
******************************************************************************************/
public with sharing class AH_QueryCustomerIncident_Ctlr 
{
    
    public String strResBody {get;set;}
    public String strResStatus {get;set;}
    public String strResStatusCode {get;set;}
    public String strState {get;set;}
    public String strIncidentNumber {get;set;}
    public String strPriority {get;set;}
    public String strShortDescription {get;set;}
    public String strAssignmentGroup {get;set;}
    private String endpoint;
    private String user;	
    private String password; 
    private String authorizationHeader;
    private String strSysId;
    private String strSysNumber;
    private String strNow;
    private String strParamQuery = ''; //?sysparm_fields=sys_id,number,state,priority,short_description,assignment_group'; //ONLY QUERY THE INFORMATION WE NEED
    private Case c;
    
    
    public AH_QueryCustomerIncident_Ctlr(ApexPages.StandardController stdController)
    {        
        
        this.c = (Case)stdController.getRecord(); 
        
        ServiceNowIncidentSettings__c SNSettings = ServiceNowIncidentSettings__c.getValues('Default');
        user = SNSettings.SerrviceNow_Username__c;
        password = SNSettings.ServiceNow_Password__c;
        endpoint = SNSettings.Incident_Endpoint__c;   
        Blob auth = Blob.valueOf(user + ':' + password);
        authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(auth);
        strSysId = c.INTGR_Customer_Ticket_System_Id__c;
        strNow = String.valueOf(datetime.now());       
        //endpoint += '/' + strSysId + strParamQuery + '&sysparm_display_value=true';

        strSysNumber = c.Customer_Ticket_Number__c;
        strParamQuery = 'sysparm_fields=number,state,priority,short_description,assignment_group';          
		endpoint += '?sysparm_query=number%3D' + strSysNumber + '&sysparm_display_value=all&' + strParamQuery;       
        
        system.debug(' *^* endpoint = ' + endpoint);
                
    }     
    
    public void doQuery() 
    {        

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', authorizationHeader);
        req.setEndpoint(endpoint);
        req.setMethod('GET');         
               
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        strResBody = res.getBody();
        strResStatusCode = String.valueOf(res.getStatusCode());
        strResStatus = String.valueOf(res.getStatus());
        
        system.debug(' *^* strResBody = ' + strResBody);
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Query Execution Date/Time: ' + strNow));
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'REST Response Status Code: ' + strResStatusCode + '(' + strResStatus + ')'));
        
        if (strResStatusCode != '200')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, strResBody));
        }
        
        JSONParser parser = JSON.createParser(res.getBody());
        system.JSONToken token;
        string text;
        
        while ((token = parser.nextToken()) != null) 
        {
            // Parse the object
            if ((token = parser.getCurrentToken()) != JSONToken.END_OBJECT) 
            {
                text = parser.getText();
                if (token == JSONToken.FIELD_Name && text == 'state') 
                {
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    strState = parser.getText();
                }
                if (token == JSONToken.FIELD_Name && text == 'number') 
                {
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    strIncidentNumber = parser.getText();
                }
                if (token == JSONToken.FIELD_Name && text == 'priority') 
                {
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    strPriority = parser.getText();
                }
                if (token == JSONToken.FIELD_Name && text == 'short_description') 
                {
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    strShortDescription = parser.getText();
                }
                if (token == JSONToken.FIELD_Name && text == 'assignment_group') 
                {
                    token = parser.nextToken();
                    token = parser.nextToken();
                    token = parser.nextToken();
                    strAssignmentGroup = parser.getText();
                }  
                
            }
            
        }

    }
    
}