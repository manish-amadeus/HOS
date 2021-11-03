/************************************************************************************************
Name            : NI_FetchFullAccessPermissions_Batch
Author          : Bhuleshwar Deshpande
Created Date    : 07/18/2019
Last Mod By     : Shashikant Nikam
Last Mod Date   : 07/23/2019
NICC Reference  :  
Description     : This batch class will be called from NI_FetchObjectAccessBatch when permission set ID set size is over 51. 
                : This is to avoid Too Many Callouts : 101 error.
				:
*************************************************************************************************/

global class NI_FetchFullAccessPermissions_Batch implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts
{

    List<String> permissionSetsId;
    NI_Org_Details__c targetOrgs;
    List<Salesforce_User__c> usersTOAdd = new List<Salesforce_User__c>();
    Set<String> fullAccessUserNamesFinal = new Set<String>();

    
    // CONSTRUCTOR
    global NI_FetchFullAccessPermissions_Batch (NI_Org_Details__c orgObj, Set<String> permissionSetsIdSet, List<Salesforce_User__c> users)
    {
        //permissionSetsId = new List<String>();
        permissionSetsId = new List<String>(permissionSetsIdSet);
        System.debug('permissionSetsId size : ' + permissionSetsId.size());
        this.targetOrgs = orgObj;
        System.debug('targetObj : ' + targetOrgs);
        system.debug('targetOrgs.Admin_Login_Name_Encrypted__c ' + targetOrgs.Admin_Login_Name_Encrypted__c );
        system.debug('targetOrgs.Admin_Password_Encrypted__c  ' + targetOrgs.Admin_Password_Encrypted__c  );
        system.debug('targetOrgs.Security_Token_Encrypted__c ' + targetOrgs.Security_Token_Encrypted__c );
        
        for(Salesforce_User__c u: users)
        {
            usersTOAdd.add(u);
        }
    }

    
    // START METHOD
    global Iterable<String> start(Database.BatchableContext BC)
    {  
        system.debug('permissionSetsId.size() :' + permissionSetsId.size());
        return permissionSetsId;
    }
    

    // EXECUTE METHOD
    global void execute(Database.BatchableContext BC, List<String> permSetIDList)
    {
        system.debug('IN EXECUTE METHOD : ');
        system.debug('permSetIDList.size() :' + permSetIDList.size());
        system.debug('targetOrgs.Admin_Login_Name_Encrypted__c ' + targetOrgs.Admin_Login_Name_Encrypted__c );
        system.debug('targetOrgs.Admin_Password_Encrypted__c  ' + targetOrgs.Admin_Password_Encrypted__c  );
        system.debug('targetOrgs.Security_Token_Encrypted__c ' + targetOrgs.Security_Token_Encrypted__c );
        
        if (targetOrgs.Admin_Login_Name_Encrypted__c != null && targetOrgs.Admin_Password_Encrypted__c != null && targetOrgs.Security_Token_Encrypted__c != null)
        {
            string loginPass = targetOrgs.Admin_Password_Encrypted__c + '' + targetOrgs.Security_Token_Encrypted__c;
            
            try
            {
                
                // create new HTTP request to login in Org.  
                Httprequest request = getHttpRequests('https://login.salesforce.com/services/Soap/u/36.0');
                request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + targetOrgs.Admin_Login_Name_Encrypted__c+ '</username><password>' + loginPass + '</password></login></Body></Envelope>');
                httpresponse bodyresp2 = (new Http()).send(request);
                string Loginresp= bodyresp2.getBody(); // read login body
                // login is unsuccessfull then skip all other process
                // Login api in response  
                
                if (!Loginresp.containsignorecase('<soapenv:Fault><faultcode>'))
                {
                    Dom.XmlNode resultElmt =bodyresp2 .getBodyDocument().getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                        .getChildElement('result', 'urn:partner.soap.sforce.com');
                    
                    system.debug('bodyresp2 =='+bodyresp2 );
                    // fetch session id and server url from response
                    String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText().split('/services')[0];
                    String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
                    
                    string sql = '';
                    
                    Set<String> permIDSet = new Set<String>(permSetIDList);
                    // fullAccessUserNames  list will save all usernames having Full access
                    Set<String> fullAccessUserNames = new Set<String>();
                    
                    if (!permIDSet.isempty()) // if permission set found.
                    {
                        string inclause= ''; 
                        
                        // fullAccessPerm  list will save all permission set ID's having Full access
                        Set<String> fullAccessPerm = new Set<String>();
                        
                        // fetch all full access permission or profile
             			fullAccessPerm = getFullAccessPermissions(permIDSet,SESSION_ID ,SERVER_URL);
                        system.debug('fullAccessPerm '+fullAccessPerm );
                        // if any full access permission or profile found, then fetch all users
                        // assigned to that permission or profile 
                        if (!fullAccessPerm.isempty())
                        {
                            for(string peid : fullAccessPerm)
                            {
                                inclause += '\'' + peid + '\',';
                            }
                            inclause = inclause.removeEnd(',');
                            
                            //fullAccessUserNames = getAllFullAccessUsers(SESSION_ID, SERVER_URL, inclause);
                            fullAccessUserNames = getAllFullAccessUsers(SESSION_ID, SERVER_URL, fullAccessPerm);
                            
                            fullAccessUserNamesFinal.addAll(fullAccessUserNames);
                        }
                    }
                }
            }
            catch (Exception e)
            {
                system.debug('Exception occured at Line#: ' + e.getLineNumber() + ' - ' + e.getMessage());
            }
        }
        
    }
    
    
    // FINISH METHOD
    global void finish(Database.BatchableContext BC)
    {
        system.debug('----IN FINISH METHOD----');
        
        try
        {
            if (!usersTOAdd.isempty())
            {
                for (Salesforce_User__c fullUser: usersTOAdd)
                {
                    if (!fullAccessUserNamesFinal.contains(fullUser.UserName__c ))
                    {
                        fullUser.Limited_User__c = true;
                    } 
                    else
                    {
                        fullUser.Limited_User__c = false;
                    }
                    // for testing purpose
                    //fullUser.testscheduler__c= fullUser.testscheduler__c+1;
                }
                
                system.debug('usersTOAdd : '+usersTOAdd);
                system.debug('usersTOAdd size : '+usersTOAdd.size());
                
                upsert usersTOAdd userIDFromOrg__c;
                
            }
        }
        catch (Exception e)
        {
            system.debug('Exception occured at Line#: ' + e.getLineNumber() + ' - ' + e.getMessage());
        } 
    }
    

    
    // Get all permissions with NOT read only access.
    public static Set<String> getFullAccessPermissions(Set<String> permissionSetsId, string SESSION_ID, string SERVER_URL)
    {
        
        Set<String> permissionAssignedObj;
        Set<String> fullAccessPermissions = new Set<String>();
        string isdone;
        string queryLoc;
        Dom.XMLNode resultpermUsers;
        
        if (!permissionSetsId.isempty())
        {
            for(string pid: permissionSetsId)
            {
                permissionAssignedObj = new Set<String>();
                
                //sql = 'SELECT  Assignee.username FROM PermissionSetAssignment WHERE PermissionSetId  IN ('+inclause+') group by Assignee.username';
                string sql = 'SELECT SobjectType FROM ObjectPermissions where parentid = \'' + pid + '\' and (' +
                    '(PermissionsEdit = true and PermissionsRead = true) OR' +
                    '(PermissionsCreate = true and PermissionsRead = true) OR' +
                    '(PermissionsEdit = true and PermissionsRead = true and PermissionsDelete = true))';           
                
                Set<String> listOfFullAccessUSers = new Set<String>();

                //listOfFullAccessUSers = getAllFullAccessUsers(SESSION_ID ,SERVER_URL,sql);
                //node1 = sql;
                
                //system.debug('sql = ' + sql);
                
                Httprequest request = getHttpRequests(SERVER_URL);
                //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
                request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                                '<soapenv:Header>'+
                                '<urn:SessionHeader><urn:sessionId>'+SESSION_ID +'</urn:sessionId></urn:SessionHeader>'+
                                '</soapenv:Header><soapenv:Body>'+
                                '<urn:query><urn:queryString>'+sql+'</urn:queryString>'+
                                '</urn:query></soapenv:Body></soapenv:Envelope>');       
                httpresponse permUserQueryResponse = (new Http()).send(request);

                resultpermUsers = permUserQueryResponse.getBodyDocument().getRootElement()
                    .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
                    .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                
                //system.debug('permUserQueryResponse.getBody() ==> '+permUserQueryResponse.getBody());  
                
                for (Dom.XMLNode child : resultpermUsers.getChildElements()) 
                {
                    if (child.getName() == 'records')
                    {
                        string objectname = child.getChildElement('SobjectType', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        if (objectname.containsignorecase('lod4__') || 
                            objectname.containsignorecase('nihrm__') && 
                            !objectname.containsignorecase('__history') && 
                            !objectname.containsignorecase('__tag'))
                        { 
                            permissionAssignedObj.add(objectname);
                        }
                    }                    
                }
                
                //system.debug('permissionAssignedObj.size()=='+permissionAssignedObj.size()+'==========='+NI_FetchObjectAccessBatch.objectNames.size());
                
                // if returned record are more than 200 than we need to use query locator to fetch another 
                // batch of records.
                
                string getsize = resultpermUsers.getChildElement('size', 'urn:enterprise.soap.sforce.com').getText();
                
                //system.debug('getsize : '+getsize);
                
                integer totalsize = integer.valueof(getsize);                
                isdone = resultpermUsers.getChildElement('done', 'urn:enterprise.soap.sforce.com').getText();
                queryLoc = resultpermUsers.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
                //node1= isdone ;
                //node2= queryLoc ;
                
                if (totalsize > 200 && (queryLoc != null || queryLoc != ''))
                {
                    //system.debug('isdone : '+isdone);
                    while (isdone == 'false') 
                    {
                        //orgUsersToAdd = new list<Salesforce_User__c>();
                        resultpermUsers = null;
                        request = getHttpRequests(SERVER_URL);
                        //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
                        request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                                        '<soapenv:Header>'+
                                        '<urn:SessionHeader><urn:sessionId>'+SESSION_ID+'</urn:sessionId></urn:SessionHeader>'+
                                        '</soapenv:Header><soapenv:Body>'+
                                        '<urn:queryMore><urn:queryLocator>'+queryLoc+'</urn:queryLocator>'+
                                        '</urn:queryMore></soapenv:Body></soapenv:Envelope>');       
                        permUserQueryResponse= (new Http()).send(request);
                        //bodyresp= userQueryResponse.getBody()+'\n\n\n\n\n\n\n\n';
                        resultpermUsers = permUserQueryResponse.getBodyDocument().getRootElement()
                            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                            .getChildElement('queryMoreResponse', 'urn:enterprise.soap.sforce.com')
                            .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                        //system.debug('resultElmtObjs==='+resultpermUsers);
                        
                        for (Dom.XMLNode childLocater : resultpermUsers.getChildElements()) 
                        {
                            if (childLocater.getName() == 'records')
                            {
                                if (childLocater.getChildElement('SobjectType', 'urn:sobject.enterprise.soap.sforce.com') != NULL)
                                {
                                    string objectname = childLocater.getChildElement('SobjectType', 'urn:sobject.enterprise.soap.sforce.com').getText();
                                    if (objectname.containsignorecase('lod4__') || 
                                        objectname.containsignorecase('nihrm__') && 
                                        !objectname.containsignorecase('__history') && 
                                        !objectname.containsignorecase('__tag'))
                                    { 
                                        permissionAssignedObj.add(objectname);
                                    }
                                }
                            }
                            
                        }
                        // system.debug('resultElmtUsers ==='+resultElmtUsers );
                        isdone = resultpermUsers.getChildElement('size', 'urn:enterprise.soap.sforce.com').getText();
                        // isdone = 'true';
                        queryLoc =  resultpermUsers.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
                    }
                }
                
                // an permission will be considered as full access permission only if that permission 
                // is having NOT Read Only access to all objects starting with name prefix nihrm__ or lod04__
                // if on any profile or permission set count of full access permission on all objects with name prefix with nihrm__ or lod04__
                // is equal to total number of objects name prefix nihrm__ or lod04__ then that profile will be considered as full access profile or permission set
                //if(permissionAssignedObj.size() == objectNames.size()){
                if (permissionAssignedObj.size() > 0)
                {
                    fullAccessPermissions.add(pid);
                }
                
                //system.debug('permissionAssignedObj = ' + permissionAssignedObj);
            }
        }
        
        return fullAccessPermissions;
        
    }
    
    
    public static Set<String> getAllFullAccessUsers(string sessionID, string SERVER_URL, Set<string> inclauseSet)
    {
        Set<String> allAccessUsers = new Set<String>();
        
        String inclause = '';
        
        //inclause = '\'0PS1Y000001Lw3ZWAS\',\'0PS1Y000001LwQxWAK\',\'0PS1Y000001LwefWAC\',\'0PSi00000004IJZGA2\'';
        
        Integer cnt = 1;
        for (string peid : inclauseSet)
        {
            if (cnt == 2)
            {
                inclause += '\'' + peid + '\',';
                inclause = inclause.removeEnd(',');
                
                //inclause = '\'0PSi00000009VoHGAU\',\'0PSi0000000FlBlGAK\',\'0PSi0000000FlBqGAK\''; 
                
                // fetch all user having full access permission
                string sql = 'SELECT  Assignee.username FROM PermissionSetAssignment WHERE PermissionSetId  IN (' + inclause + ') group by Assignee.username';
                string isdone;
                string queryLoc;
                
                //SMH
                //system.debug(' *** getAllFullAccessUsers.sql = ' + sql); 
                // sql = SELECT  Assignee.username FROM PermissionSetAssignment WHERE PermissionSetId  IN ('0PS1Y000001Lw3ZWAS','0PS1Y000001LwQxWAK','0PS1Y000001LwefWAC','0PSi00000004IJZGA2','0PSi00000009VoHGAU','0PSi0000000FlBlGAK','0PSi0000000FlBqGAK','0PSi0000000FlCiGAK','0PSi0000000FlCmGAK','0PSi0000000FlCoGAK','0PSi0000000FlCpGAK','0PSi0000000FlCqGAK','0PSi0000000FlCrGAK','0PSi0000000FlCsGAK','0PSi0000000Ns4VGAS','0PSi0000000NsHAGA0','0PSi0000000NtivGAC','0PSi000000117TlGAI') group by Assignee.username        
                
                httpresponse userQueryResponse;
                Dom.XmlNode resultElmtUsers;
                
                Httprequest request = getHttpRequests(SERVER_URL);
                //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
                request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
                                '<soapenv:Header>' +
                                '<urn:SessionHeader><urn:sessionId>'+sessionID +'</urn:sessionId></urn:SessionHeader>' +
                                '</soapenv:Header><soapenv:Body>' +
                                '<urn:query><urn:queryString>'+sql+'</urn:queryString>' +
                                '</urn:query></soapenv:Body></soapenv:Envelope>');       
                httpresponse permUserQueryResponse = (new Http()).send(request);
                //bodyresp = permUserQueryResponse.getBody()+'\n\n\n\n\n\n\n\n';
                
                //SMH
                //system.debug(' *** permUserQueryResponse.getBody() = ' +  permUserQueryResponse.getBody());     
                
                // <?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault>
                // <faultcode>sf:EXCEEDED_ID_LIMIT</faultcode><faultstring>EXCEEDED_ID_LIMIT: Aggregate query does not support queryMore(), use LIMIT to restrict the results to a single batch</faultstring>
                // <detail><sf:UnexpectedErrorFault xsi:type="sf:UnexpectedErrorFault"><sf:exceptionCode>EXCEEDED_ID_LIMIT</sf:exceptionCode><sf:exceptionMessage>Aggregate query does not support queryMore(), use LIMIT to restrict the results to a single batch</sf:exceptionMessage></sf:UnexpectedErrorFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>
                
                resultElmtUsers = permUserQueryResponse.getBodyDocument().getRootElement()
                    .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
                    .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                
                //system.debug('resultpermUsers==='+resultpermUsers); 
                for (Dom.XMLNode child : resultElmtUsers.getChildElements()) 
                {
                    if (child.getName() == 'records')
                    {
                        string usernameFetch = child.getChildElement('Username', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        allAccessUsers.add(usernameFetch);
                    }
                }
                
                //System.debug(orgUsersToAdd);
                string getsize = resultElmtUsers.getChildElement('size', 'urn:enterprise.soap.sforce.com').getText();
                integer totalsize = integer.valueof(getsize);
                
                isdone = resultElmtUsers.getChildElement('done', 'urn:enterprise.soap.sforce.com').getText();
                queryLoc = resultElmtUsers.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
                //node1= isdone ;
                //node2= queryLoc ;
                
                if (totalsize > 200 && (queryLoc != null || queryLoc != ''))
                {
                    while (isdone == 'false') 
                    {
                        //orgUsersToAdd = new list<Salesforce_User__c>();
                        resultElmtUsers = null;
                        request = getHttpRequests(SERVER_URL);
                        //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
                        request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                                        '<soapenv:Header><urn:QueryOptions><urn:batchSize>2</urn:batchSize></urn:QueryOptions>'+
                                        '<urn:SessionHeader><urn:sessionId>'+sessionID+'</urn:sessionId></urn:SessionHeader>'+
                                        '</soapenv:Header><soapenv:Body>'+
                                        '<urn:queryMore><urn:queryLocator>'+queryLoc+'</urn:queryLocator>'+
                                        '</urn:queryMore></soapenv:Body></soapenv:Envelope>');       
                        userQueryResponse = (new Http()).send(request);
                        //bodyresp= userQueryResponse.getBody()+'\n\n\n\n\n\n\n\n';
                        
                        resultElmtUsers = userQueryResponse.getBodyDocument().getRootElement()
                            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                            .getChildElement('queryMoreResponse', 'urn:enterprise.soap.sforce.com')
                            
                            .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                        //system.debug('resultElmtUsers === ' + resultElmtUsers);
                        
                        for (Dom.XMLNode child : resultElmtUsers.getChildElements()) 
                        {
                            if (child.getName() == 'records')
                            {
                                string usernameFetch = child.getChildElement('Username', 'urn:sobject.enterprise.soap.sforce.com').getText();
                                allAccessUsers.add(usernameFetch);
                            }
                        }
                        
                        // system.debug('resultElmtUsers ==='+resultElmtUsers );
                        isdone = resultElmtUsers.getChildElement('size', 'urn:enterprise.soap.sforce.com').getText();
                        // isdone = 'true';
                        queryLoc =  resultElmtUsers.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
                        
                    }
                }
                cnt = 1;
                inclause = '';
            }
            else {
                inclause += '\'' + peid + '\',';
                cnt++;
            }
        }
        return allAccessUsers;
    }
    
    
    
    public static httprequest getHttpRequests(string SERVER_URL)
    {
        Httprequest request = new HttpRequest();
        request.setEndpoint(SERVER_URL + '/services/Soap/c/36.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
        return request;
    }
    

}