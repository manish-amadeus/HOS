/****************************************************************************************
Name            : AH_FetchTrialExpirationBatchHelper Class
Author          : Shashikant Nikam
Created Date    : 11/1/2017
Last Mod Date   : 04/23/2019 
Last Mod By     : Sean Harris
NICC Reference  : NICC-025235 
Description     : Helper class for AH_FetchTrialExpirationBatch
                : NICC-034313 - Updated API version
****************************************************************************************/
public class AH_FetchTrialExpirationBatchHelper 
{
    
    public static NI_Org_Details__c updateOrgDetails(String SERVER_URL, String SESSION_ID, String login_success, Id srcOrgID)
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatchHelper.updateOrgDetails() - QUERIES ISSUED = ' + Limits.getQueries());
		
        system.debug(' *^* SERVER_URL = ' + SERVER_URL);
        system.debug(' *^* SESSION_ID = ' + SESSION_ID);
        system.debug(' *^* login_success = ' + login_success);
        system.debug(' *^* srcOrgID = ' + srcOrgID);
        
        Map<String, Map<String, Integer>> usersToPermissionset = new Map<String, Map<String, Integer>>();
        
        NI_Org_Details__c org_detail = new NI_Org_Details__c (id = srcOrgID);
        
        if (login_success == 'true') 
        {
            
            String perm_set_1 = 'view only';
            String perm_set_2 = 'banquet';  
            
            String sql = 'SELECT AssigneeId, p.PermissionSet.Label FROM PermissionSetAssignment p WHERE PermissionSetId IN (SELECT Id FROM PermissionSet WHERE Label LIKE ' + '\'%' + perm_set_1 + '%\' OR Label LIKE' + '\'%' + perm_set_2 + '%\')';
            
            Httprequest request = getHttpRequests(SERVER_URL);
            httpresponse permiResp = getHttpResponse(request, SESSION_ID, sql);
            String resp = permiResp.getBody();
            system.debug(' **** Response = ' + resp);
            
            Dom.XmlNode resultElmtPerm = null;
            if (resp.containsIgnoreCase('<faultcode>'))
            {
                
                Dom.XmlNode resultElmt1 = permiResp.getBodyDocument().getRootElement()
                    .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                
                String faultstring = resultElmt1.getChildElement('faultstring', null).getText();

                NI_Error_Logger.WriteToLogwithOrgDetailId(srcOrgID, faultstring, 'NI_Org_Details__c', 'AH_FetchTrialExpirationBatchHelper', 'Insert');
                
                system.debug(' ***  EXITING AH_FetchTrialExpirationBatchHelper.updateOrgDetails() - QUERIES ISSUED = ' + Limits.getQueries());
                
                return org_detail;
                
            }
            else 
            {
                try
                {
                    resultElmtPerm = permiResp.getBodyDocument().getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
                        .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                }
                catch (Exception e) 
                {
                    system.debug('Error occured at line : ' +e.getLineNumber() + ' => '+e);
                    system.debug('Error in Org ID : '+srcOrgID);
                }
            }
            
            Integer cnt = 0;
            if (resultElmtPerm != null)   
            {
                for (Dom.XMLNode child : resultElmtPerm.getChildElements()) 
                {   
                    if (child.getName() == 'records')
                    {
                        String AssigneeId = '';
                        String Label = '';
                        
                        for (Dom.XMLNode innerChild : child.getChildElements()) 
                        {
                            try 
                            {
                                Map<String, Integer> innerMap = new Map<String, Integer>();
                                
                                if (innerChild.getName() != null && innerChild.getName() == 'AssigneeId') 
                                {
                                    AssigneeId = innerChild.getText();
                                }
                                if (innerChild.getName() == 'PermissionSet')
                                {
                                    Label = innerChild.getChildElement('Label', 'urn:sobject.enterprise.soap.sforce.com').getText();
                                }
                            } 
                            catch (Exception e)
                            {
                                system.debug('Error occured at line : ' +e.getLineNumber() + ' => '+e);
                            }
                        }
                        
                        try
                        {
                            if (AssigneeId != null && AssigneeId != '' && Label != null && Label != '' && (Label.containsIgnoreCase(perm_set_1) || Label.containsIgnoreCase(perm_set_2) ) )
                            {
                                Map<String, Integer> inMap = new Map<String, Integer>();
                                if (usersToPermissionset.get(AssigneeId) != null) 
                                {
                                    inMap = usersToPermissionset.get(AssigneeId);
                                }
                                Integer cnt1 = 1;
                                if (Label.containsIgnoreCase(perm_set_1)) 
                                {
                                    if (inMap != null && !inMap.isEmpty()) 
                                    {
                                        if (inMap.containsKey(perm_set_1)) 
                                        {
                                            cnt1 = inMap.get(perm_set_1);
                                            cnt1 = cnt1 +1; 
                                        }
                                    }
                                    inMap.put(perm_set_1, cnt1);
                                }
                                
                                if (Label.containsIgnoreCase(perm_set_2)) 
                                {
                                    if (inMap != null && !inMap.isEmpty()) 
                                    {
                                        if (inMap.containsKey(perm_set_2)) 
                                        {
                                            cnt1 = inMap.get(perm_set_2);
                                            cnt1 = cnt1 +1; 
                                        }
                                    }
                                    inMap.put(perm_set_2, cnt1);
                                }
                                usersToPermissionset.put(AssigneeId, inMap);
                            }
                        } 
                        catch(Exception e)
                        {
                            system.debug('Error occured at line : ' +e.getLineNumber() + ' => '+e);
                        } 
                    }
                }
                
                system.debug('usersToPermissionset : ' + usersToPermissionset);
                
                for (Id AssigneeId : usersToPermissionset.keyset()) 
                {
                    if (usersToPermissionset.get(AssigneeId).get('view only') >= 1 && usersToPermissionset.get(AssigneeId).get('banquet') >= 1)
                    { 
                        cnt++;
                    }
                }
                org_detail.Banquet__c = String.valueOf(cnt);
            }
        }
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatchHelper.updateOrgDetails() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return org_detail;
        
    }
    
    // UPDATE THE TRIAL EXPIRATION DATE OF AN ORG
    public static NI_Org_Details__c fetchTrialExpDate(String SERVER_URL, String SESSION_ID, String login_success, NI_Org_Details__c org_detail)
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatchHelper.fetchTrialExpDate() - QUERIES ISSUED = ' + Limits.getQueries());
		
        if (login_success == 'true') 
        {      
            // FETCH TRIAL EXPIRATION DATE FROM OTHER ORG
            string sql = 'SELECT TrialExpirationDate from Organization';
            
            Httprequest request = getHttpRequests(SERVER_URL);
            httpresponse permiResp = getHttpResponse(request, SESSION_ID, sql);
            String resp= permiResp.getBody();
            
            system.debug(' **** Trial Exp Date Response : '+ resp);
            
            Dom.XmlNode resultElmtPerm;
            
            if (resp.containsIgnoreCase('<faultcode>'))
            {
                Dom.XmlNode resultElmt1 = permiResp.getBodyDocument().getRootElement()
                    .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                
                String faultstring = resultElmt1.getChildElement('faultstring', null).getText();

                NI_Error_Logger.WriteToLogwithOrgDetailId(org_detail.id, faultstring, 'NI_Org_Details__c', 'AH_FetchTrialExpirationBatchHelper', 'Insert');
                return org_detail;
            }
            else 
            {
                try 
                {
                    resultElmtPerm = permiResp.getBodyDocument().getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
                        .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                }
                catch (Exception e)
                {
                    system.debug('Error occured at line : ' +e.getLineNumber() + ' => '+e);
                }
            }
            
            if (resultElmtPerm != null)
            {
                for (Dom.XMLNode child : resultElmtPerm .getChildElements())
                {
                    
                    if (child.getName() == 'records' )
                    {
                        try 
                        {
                            String trialExpDate = '';
                            if (child.getChildElement('TrialExpirationDate', 'urn:sobject.enterprise.soap.sforce.com').getText() != null)
                            {
                                trialExpDate = child.getChildElement('TrialExpirationDate', 'urn:sobject.enterprise.soap.sforce.com').getText();
                            }

                            // 2016-12-14T10:28:29.000Z - THIS IS THE DATETIME FORMAT
                            Integer year = Integer.valueOf(trialExpDate.subString(0, 4));
                            Integer mon = Integer.valueOf(trialExpDate.subString(5, 7));
                            Integer day = Integer.valueOf(trialExpDate.subString(8, 10));
                            Integer hh = Integer.valueOf(trialExpDate.subString(11, 13));
                            Integer mm = Integer.valueOf(trialExpDate.subString(14, 16));
                            Integer ss = Integer.valueOf(trialExpDate.subString(17, 19));
                            
                            Datetime exp_date = Datetime.newInstance(year,mon,day,hh,mm,ss);
                            
                            if (trialExpDate != null) 
                            { 
                                org_detail.Trial_Expiration_Date__c = exp_date;
                            } 
                        } 
                        catch (Exception e) 
                        {
                            system.debug('Exception occured at '+e.getlinenumber()+'\n\n'+e.getMessage());
                        }
                    }
                }
            }
        }
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatchHelper.fetchTrialExpDate() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return org_detail;
        
    }
    
    public static map<String, String> connect(String org_type, string loginUsername,string loginPassWd, string secToken, string srcOrgID) 
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatchHelper.connect() - QUERIES ISSUED = ' + Limits.getQueries());
		
        String login_success = 'false';
        
        // CONCATINATE PASSWORD AND SECURITY TOKEN FOR LOGIN THROUGH API
        String loginPass = loginPassWd + '' + secToken;
        Map<String, String> session_info = new Map<String, String>();
        session_info.put('login_success', login_success);
        session_info.put('orgId', srcOrgID);
        session_info.put('ExpiredPassword', 'False');
        
        // IF USERNAME IS NULL SKIP CALLING API'S
        if (loginUsername  != '') 
        {
            try 
            {
                // CREATE NEW HTTP REQUEST TO LOGIN IN ORG  
                Httprequest request = getHttpRequests('https://login.salesforce.com/services/Soap/u/36.0');
                
                if (org_type.contains('Sandbox')) 
                {
                    request = getHttpRequests('https://test.salesforce.com/services/Soap/u/36.0');
                }
                
                request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + loginUsername+ '</username><password>' + loginPass + '</password></login></Body></Envelope>');
                httpresponse bodyresp2 = (new Http()).send(request);
                string Loginresp= bodyresp2.getBody(); // read login body
                system.debug(' **** Login Response = ' + Loginresp);
                
                // CHECK FOR INVALID LOGIN 
                if (Loginresp.containsignorecase('<soapenv:Fault><faultcode>'))
                {
                    Dom.XmlNode resultElmt1 = bodyresp2 .getBodyDocument().getRootElement()
                        .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                    String faultcode = resultElmt1.getChildElement('faultcode', null).getText();
                    String faultstring = resultElmt1.getChildElement('faultstring', null).getText();
                    
                    system.debug(' **** faultstring = ' + faultstring);
                    
                    NI_Error_Logger.WriteToLogwithOrgDetailId(srcOrgID, faultstring, 'NI_Org_Details__c', 'AH_FetchTrialExpirationBatchHelper', 'Insert');
                    session_info.put('login_success', 'false');
                    
                    return session_info;
                    
                }
                
                // CHECK FOR EXPIRED PASSWORD
                if (Loginresp.containsignorecase('<passwordExpired>true<')) 
                {
                    system.debug(' **** Password Expired..');
                    session_info.put('login_success', 'false');
                    session_info.put('ExpiredPassword', 'True');
                    NI_Error_Logger.WriteToLogwithOrgDetailId(srcOrgID, 'INVALID_OPERATION_WITH_EXPIRED_PASSWORD: The users password has expired, you must call SetPassword before attempting any other API operations', 'NI_Org_Details__c', 'AH_FetchTrialExpirationBatchHelper', 'Insert');
                    return session_info;
                }
                
                // LOGIN IS UNSUCCESSFUL THEN SKIP ALL OTHER PROCESSES 
                if (!Loginresp.containsignorecase('<soapenv:Fault><faultcode>'))
                {
                    Dom.XmlNode resultElmt = bodyresp2 .getBodyDocument().getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                        .getChildElement('result', 'urn:partner.soap.sforce.com');
                    
                    // FETCH SESSION ID AND SERVER URL FROM RESPONSE
                    String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText().split('/services')[0];
                    String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
                    login_success = 'true';
                    session_info.put('SERVER_URL', SERVER_URL);
                    session_info.put('SESSION_ID', SESSION_ID);
                    session_info.put('login_success', login_success);
                    system.debug('session_info'+session_info);
                }
            }
            catch (Exception e) 
            {
                system.debug('Exception occured at ' + e.getlinenumber() + '\n\n' + e.getMessage());
                NI_Error_Logger.WriteToLogwithOrgDetailId(srcOrgID, 'Exception occured at line no. :' + e.getlinenumber() + '. ' + e.getMessage(), 'NI_Org_Details__c', 'AH_FetchTrialExpirationBatchHelper', 'Insert');
            }
        }
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatchHelper.connect() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return session_info;
        
    }
    
    public static httprequest getHttpRequests(string SERVER_URL)
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatchHelper.getHttpRequests() - QUERIES ISSUED = ' + Limits.getQueries());
		
        Httprequest request = new HttpRequest();
        request.setEndpoint(SERVER_URL + '/services/Soap/c/36.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatchHelper.getHttpRequests() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return request;
        
    }
    
    public static HttpResponse getHttpResponse(Httprequest request, String SESSION_ID, String sql)
    {
        
        system.debug(' ***  ENTERING AH_FetchTrialExpirationBatchHelper.getHttpResponse() - QUERIES ISSUED = ' + Limits.getQueries());
		
        HttpResponse permiResp = new HttpResponse();
        
        try 
        {
            request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
                            '<soapenv:Header><urn:QueryOptions><urn:batchSize>2</urn:batchSize></urn:QueryOptions>' +
                            '<urn:SessionHeader><urn:sessionId>' + SESSION_ID + '</urn:sessionId></urn:SessionHeader>' +
                            '</soapenv:Header><soapenv:Body>' +
                            '<urn:query><urn:queryString>' + sql + '</urn:queryString>' +
                            '</urn:query></soapenv:Body></soapenv:Envelope>');      
            
            permiResp = (new Http()).send(request);
        } 
        catch (Exception e) 
        {
            system.debug('Exception captured in getHttpRespose : ' + e.getlinenumber() + '\n\n' + e.getMessage());
        }
        
        system.debug(' ***  EXITING AH_FetchTrialExpirationBatchHelper.getHttpResponse() - QUERIES ISSUED = ' + Limits.getQueries());
		
        return permiResp;
            
    }
    
}