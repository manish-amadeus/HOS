/************************************************************************************************
Name            : NI_FetchObjectAccessBatch
Author          : Kasim Badami
Created Date    : 06/30/2016
Last Mod By     : Shashikant Nikam
Last Mod Date   : 11/13/2018
NICC Reference  :  
Description     : 
                : 

    // CODE TO SCHEDULE THIS IN EXEC ANON
    String strJobName = 'Salesforce User Fetch TEMP';
    String strSchedule = '0 20 13 * * ? *';
    System.schedule(strJobName, strSchedule, new NI_fetchObjectAccess());

*************************************************************************************************/
global class NI_FetchObjectAccessBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful
{
    
    public static Set<String> permIdSet = new Set<String>();
    public static Set<String> objectNames {get; set;}
    Set<String> permIdSetNew;
    List<Salesforce_User__c> usersTOAdd;
    Boolean callBatch = false;
    NI_Org_Details__c copy ;
    
    public NI_FetchObjectAccessBatch()
    {
        // displayError = 'none';
        NI_FetchObjectAccessBatch.objectNames = new Set<String>();
        
        permIdSetNew = new Set<String>();
        copy = new NI_Org_Details__c();
        system.debug('permIdSetNew size in constructor : '+permIdSetNew.size());
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug('in Start permIdSetNew size : '+permIdSetNew.size());
        string query = 'SELECT Id, Name, Admin_Login_Name_Encrypted__c, Admin_Password_Encrypted__c, Org_Type__c, Security_Token_Encrypted__c, Org_ID__c FROM NI_Org_Details__c WHERE Org_Type__c LIKE \'Salesforce%\' AND DisablePolling__c = false AND Org_ID__c != null';    
        return Database.getQueryLocator(query);
    }    
    
    global void execute(Database.BatchableContext BC, List<NI_Org_Details__c > scope)
    {
        system.debug('in execute permIdSetNew size : '+permIdSetNew.size());
        
        // execute batch one org at a time
        for (NI_Org_Details__c targetOrgs : scope)
        {
            copy = targetOrgs;
            system.debug( '  ................. DELETING Salesforce_User__c RECORDS FOR ORG_ID: ' + targetOrgs.Id);       
            List<Salesforce_User__c> lstUsersToDelete = new List<Salesforce_User__c>([SELECT Id FROM Salesforce_User__c WHERE OrgName__c =: targetOrgs.Id]);
            database.delete(lstUsersToDelete);            
            
            if (targetOrgs.Admin_Login_Name_Encrypted__c != null && targetOrgs.Admin_Password_Encrypted__c != null && targetOrgs.Security_Token_Encrypted__c != null)
            {
                //NI_FetchObjectAccessBatch.fetch(targetOrgs.Admin_Login_Name_Encrypted__c,targetOrgs.Admin_Password_Encrypted__c,targetOrgs.Security_Token_Encrypted__c,targetOrgs.id);
                fetch(targetOrgs.Admin_Login_Name_Encrypted__c,targetOrgs.Admin_Password_Encrypted__c,targetOrgs.Security_Token_Encrypted__c,targetOrgs.id);
            }
            
        }
        system.debug('permIdSetNew size in execute in end : '+permIdSetNew.size());
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('permIdSetNew size in finish :- '+permIdSetNew);
        system.debug('copy :- '+copy);
        system.debug('usersTOAdd  :-' + usersTOAdd);
        system.debug('callBatch :--' + callBatch);
        
        if (callBatch == true)
        {
            system.debug('Calling NI_FetchFullAccessPermissions_Batch.');
            if(!Test.isRunningTest())
            {
                NI_FetchFullAccessPermissions_Batch accessPermBatch = new NI_FetchFullAccessPermissions_Batch(copy, permIdSetNew, usersTOAdd);
                Database.executeBatch(accessPermBatch,50);
            }
        }
    }
    
    
    
    
    // Initiate the process of fetching user details. This method will connect to target Orgs  based on .
    //login credentials in custom settings. This method will be called for every org added in custom settings
    //@future(callout=true)
    //public static void fetch(string loginUsername,string loginPassWd, string secToken, string srcOrgID)
	public void fetch(string loginUsername,string loginPassWd, string secToken, string srcOrgID)        
    {
        system.debug('permIdSetNew size in fetch : '+permIdSetNew.size());
        //system.debug('loginUsername==='+loginUsername);
        //system.debug('loginPassWd==='+loginPassWd);
        //system.debug('secToken==='+secToken);
        
        // concatinate password and security token for login through Api.
        string loginPass = loginPassWd + '' + secToken;
        
        // if username is null skip calling API's
        if (loginUsername != '') 
        {
            try
            {
                
                // create new HTTP request to login in Org.  
                Httprequest request = getHttpRequests('https://login.salesforce.com/services/Soap/u/36.0');
                request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + loginUsername+ '</username><password>' + loginPass + '</password></login></Body></Envelope>');
                httpresponse bodyresp2 = (new Http()).send(request);
                string Loginresp= bodyresp2.getBody(); // read login body
                //system.debug('Loginresp==='+Loginresp);
                // login is unsuccessfull then skip all other process
                // Login api in response  
                
                if (!Loginresp.containsignorecase('<soapenv:Fault><faultcode>'))
                {
                    Dom.XmlNode resultElmt =bodyresp2 .getBodyDocument().getRootElement()
                        .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                        .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                        .getChildElement('result', 'urn:partner.soap.sforce.com');
                    
                    //system.debug('bodyresp2 =='+bodyresp2 );
                    // fetch session id and server url from response
                    String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com').getText().split('/services')[0];
                    String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com').getText();
                    
                    //system.debug('SERVER_URL==='+SERVER_URL);
                    //system.debug('SESSION_ID ==='+SESSION_ID );
                    string sql = '';
                    
                    //sql = 'SELECT Email,IsActive,Username FROM User where isActive = true';            
                    
                    // fetch all org users and insert in salesforceUser object 
                    usersTOAdd = new List<Salesforce_User__c>();
                    
                    // fetch all org users and save them in a list. The user's will be updated
                    // at the end as DB operations are not allowed within API calls.
                    
                    usersTOAdd = getOrgUsers(SESSION_ID, SERVER_URL, srcOrgID);
                    
                    if(!usersTOAdd.isempty()) // if users found on Org
                    {
                        
                        // fetch all custom objects with namespace prefix nihrm and lod4
                        NI_FetchObjectAccessBatch.objectNames = new Set<String>(); 
                        sql = 'SELECT SobjectType FROM ObjectPermissions group by SobjectType';            
                        getCustomObjectList(SESSION_ID ,SERVER_URL,sql);
                        //system.debug('objectNames==='+NI_FetchObjectAccessBatch.objectNames);
                        
                        
                        // if any object found starting with nihrm__ or lod4__
                        if (!NI_FetchObjectAccessBatch.objectNames.isempty())
                        {
                            //node3 = objectNames;
                            string inclause= '';                            
                            string isdone;
                            string queryLoc;
                            
                            //sql = 'SELECT ParentId FROM ObjectPermissions where (PermissionsModifyAllRecords = true OR PermissionsEdit= true OR PermissionsDelete = true OR PermissionsCreate  = true) and SobjectType IN ('+inclause+')  group by parentid';            
                            
                            Set<String> permissionSetsId = new Set<String>();
                            // fetch all permission or profile set id from PermissionSetAssignment and query objectpermission table
                            // this permission sets will also contain profile id
                            sql = 'SELECT permissionsetid FROM PermissionSetAssignment group by permissionsetid';            
                            //system.debug('sql===='+sql);
                            // node2 = sql;
                            permissionSetsId = getPermissionSets(SESSION_ID ,SERVER_URL,sql );
                            system.debug('permissionSetsId ===='+permissionSetsId.size());
                            // fullAccessUserNames  list will save all usernames having Full access
                            Set<String> fullAccessUserNames = new Set<String>();
                            // fullAccessPerm  list will save all permission set ID's having Full access
                            Set<String> fullAccessPerm = new Set<String>();
                            
                            system.debug('permissionSetsId size : '+permissionSetsId.size());
                            
                            permIdSetNew = new Set<String>(permissionSetsId);
                            system.debug('permIdSetNew size : '+permIdSetNew.size());
                            
                            if(permissionSetsId.size() <= 50)
                            {
                                system.debug('permissionSetsId size is less than 51..... : '+permissionSetsId.size());
                                
                                if (!permissionSetsId.isempty()) // if permission set found.
                                {
                                    // fetch all full access permission or profile
                                    fullAccessPerm = getFullAccessPermissions(permissionSetsId,SESSION_ID ,SERVER_URL);
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
                                    }
                                }
                                
                                //system.debug('permissionSetsId'+permissionSetsId );
                                //system.debug('usersTOAdd'+usersTOAdd );
                                //system.debug('fullAccessPerm '+fullAccessPerm );
                                //system.debug('fullAccessUserNames'+fullAccessUserNames);                            
                                //system.debug('usersTOAdd==='+usersTOAdd);
                                
                                try
                                {
                                    if (!usersTOAdd.isempty())
                                    {
                                        for (Salesforce_User__c fullUser: usersTOAdd)
                                        {
                                            if (!fullAccessUserNames.contains(fullUser.UserName__c ))
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
                                        
                                        upsert usersTOAdd userIDFromOrg__c;
                                        
                                    }
                                }
                                catch (Exception e)
                                {
                                    system.debug('Exception occured at Line#: ' + e.getLineNumber() + ' - ' + e.getMessage());
                                } 
                            }
                            else{
                                callBatch = true;
                                system.debug('Permisson sets Set size is more than 50. So the next batch will be called to handle data & avoid too many callout error.');
                            }
                        }
                        
                    }
                }               
            }
            catch (Exception e)
            {
                system.debug('permissionSetsId size is More than 51..... : ');
                system.debug('Exception occured at Line#: ' + e.getLineNumber() + ' - ' + e.getMessage());
            }    
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
                
                system.debug('getsize : '+getsize);
                
                integer totalsize = integer.valueof(getsize);                
                isdone = resultpermUsers.getChildElement('done', 'urn:enterprise.soap.sforce.com').getText();
                queryLoc = resultpermUsers.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
                //node1= isdone ;
                //node2= queryLoc ;
                
                if (totalsize > 200 && (queryLoc != null || queryLoc != ''))
                {
                    system.debug('isdone : '+isdone);
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
    
    // Get all custom objects with name prefix with nihrm__ lodo4__.
    public static void getCustomObjectList(string sessionID, string SERVER_URL, string sql)
    {
        
        httpresponse sobjectQueryResponse;
        Dom.XmlNode resultElmtObjs;
        String isdone;
        String queryLoc;
        Http http = new Http();
        
        Httprequest req = getHttpRequests(SERVER_URL);
        
        String body = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
            '<soapenv:Header>'+
            '<urn:SessionHeader><urn:sessionId>'+sessionID +'</urn:sessionId></urn:SessionHeader>'+
            '</soapenv:Header><soapenv:Body>'+
            '<urn:query><urn:queryString>'+sql+'</urn:queryString>'+
            '</urn:query></soapenv:Body></soapenv:Envelope>';   
        
        req.setBody(body);
        
        HTTPResponse res = http.send(req);
        String output = res.getBody();
        
        //system.debug('output : '+output);
        
        //bodyresp=output;
        // system.debug(output);
        String parsedOutput;
        objectNames = new Set<String>();
        resultElmtObjs =res.getBodyDocument().getRootElement()
            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
            .getChildElement('result', 'urn:enterprise.soap.sforce.com');
        //system.debug('resultElmtObjs=='+resultElmtObjs );
        //bodyresp= output ;
        
        for (Dom.XMLNode child : resultElmtObjs.getChildElements()) 
        {
            if (child.getName() == 'records')
            {
                string objectname = child.getChildElement('SobjectType', 'urn:sobject.enterprise.soap.sforce.com').getText();
                if (objectname.containsignorecase('lod4__') || 
                    objectname.containsignorecase('nihrm__') && 
                    !objectname.containsignorecase('__history') && 
                    !objectname.containsignorecase('__tag'))
                { 
                    NI_FetchObjectAccessBatch.objectNames.add(objectname);
                }
            }            
        }
        
        // if returned record are more than 200 than we need to use query locator to fetch another 
        // batch of records.
        
        String getsize = resultElmtObjs.getChildElement('size', 'urn:enterprise.soap.sforce.com').getText();
        integer totalsize = integer.valueof(getsize);
        
        isdone = resultElmtObjs.getChildElement('done', 'urn:enterprise.soap.sforce.com').getText();
        queryLoc = resultElmtObjs.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
        //node1= isdone ;
        //node2= queryLoc ;
        
        if (totalsize > 200 && (queryLoc != null || queryLoc != ''))
        {
            while (isdone == 'false') 
            {
                //orgUsersToAdd = new list<Salesforce_User__c>();
                resultElmtObjs = null;
                req = getHttpRequests(SERVER_URL);
                //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
                req.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                            '<soapenv:Header>'+
                            '<urn:SessionHeader><urn:sessionId>'+sessionID+'</urn:sessionId></urn:SessionHeader>'+
                            '</soapenv:Header><soapenv:Body>'+
                            '<urn:queryMore><urn:queryLocator>'+queryLoc+'</urn:queryLocator>'+
                            '</urn:queryMore></soapenv:Body></soapenv:Envelope>');       
                sobjectQueryResponse = (new Http()).send(req);
                //bodyresp= userQueryResponse.getBody()+'\n\n\n\n\n\n\n\n';
                resultElmtObjs = sobjectQueryResponse.getBodyDocument().getRootElement()
                    .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('queryMoreResponse', 'urn:enterprise.soap.sforce.com')
                    .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                //system.debug('resultElmtObjs==='+resultElmtObjs);
                
                for (Dom.XMLNode childLocater : resultElmtObjs.getChildElements()) 
                {
                    if (childLocater.getName() == 'records')
                    {
                        if (childLocater.getChildElement('SobjectType', 'urn:sobject.enterprise.soap.sforce.com') != NULL) {
                            string objectname = childLocater.getChildElement('SobjectType', 'urn:sobject.enterprise.soap.sforce.com').getText();
                            if (objectname.containsignorecase('lod4__') || 
                                objectname.containsignorecase('nihrm__') && 
                                !objectname.containsignorecase('__history') && 
                                !objectname.containsignorecase('__tag'))
                            { 
                                NI_FetchObjectAccessBatch.objectNames.add(objectname);
                            }
                        }
                    }                    
                }
                
                // system.debug('resultElmtUsers ==='+resultElmtUsers );
                isdone = resultElmtObjs.getChildElement('size', 'urn:enterprise.soap.sforce.com').getText();
                // isdone = 'true';
                queryLoc =  resultElmtObjs.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
            }
        }
    }
    
    // Get all Org users
    public static list<Salesforce_User__c> getOrgUsers(string sessionID, string SERVER_URL, string srcOrgID)
    {
        String isdone;
        String queryLoc;
        List<Salesforce_User__c> orgUsersToAdd = new List<Salesforce_User__c>();
        httpresponse userQueryResponse;
        Dom.XmlNode resultElmtUsers;
        Httprequest request = getHttpRequests(SERVER_URL);
        //request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
        request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                        '<soapenv:Header><urn:QueryOptions><urn:batchSize>2</urn:batchSize></urn:QueryOptions>'+
                        '<urn:SessionHeader><urn:sessionId>'+sessionID+'</urn:sessionId></urn:SessionHeader>'+
                        '</soapenv:Header><soapenv:Body>'+
                        '<urn:query><urn:queryString>SELECT Profile.UserLicense.Name,id,Name,Email,IsActive,Username,LastLoginDate FROM User where (NOT Profile.UserLicense.Name  like \'Chatter%\')</urn:queryString>'+
                        '</urn:query></soapenv:Body></soapenv:Envelope>');       
        userQueryResponse = (new Http()).send(request);
        String bodyresp = userQueryResponse.getBody()+'\n\n\n\n\n\n\n\n';
        
        //system.debug('bodyrep from test = ' + bodyresp);
        //system.debug(' userQueryResponse = ' + userQueryResponse);
        
        resultElmtUsers = userQueryResponse.getBodyDocument().getRootElement()
            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
            .getChildElement('result', 'urn:enterprise.soap.sforce.com');
        
        //system.debug(LoggingLevel.Info,'resultElmtUsers==='+resultElmtUsers);
        
        string lastLoginDate;
        
        for (Dom.XMLNode child : resultElmtUsers.getChildElements()) 
        {
            
            lastLoginDate = '';
            
            if (child.getName() == 'records')
            {
                //Dom.XmlNode resRecords = child.getChildElement('records', 'urn:enterprise.soap.sforce.com');
                
                //resRecords = resRecords.getChildElement('records', 'urn:enterprise.soap.sforce.com');
                string useremail = child.getChildElement('Email', 'urn:sobject.enterprise.soap.sforce.com').getText();
                string fetchusername = child.getChildElement('Username', 'urn:sobject.enterprise.soap.sforce.com').getText();
                string isactive = child.getChildElement('IsActive', 'urn:sobject.enterprise.soap.sforce.com').getText();
                string userid = child.getChildElement('Id', 'urn:sobject.enterprise.soap.sforce.com').getText();
                string fullname = child.getChildElement('Name', 'urn:sobject.enterprise.soap.sforce.com').getText();
                string userlicence =  child.getChildElement('Profile', 'urn:sobject.enterprise.soap.sforce.com')
                    .getChildElement('UserLicense', 'urn:sobject.enterprise.soap.sforce.com')
                    .getChildElement('Name', 'urn:sobject.enterprise.soap.sforce.com')
                    .getText();
                //string userlicence = child.getChildElement('Profile.UserLicense.Name', 'urn:sobject.enterprise.soap.sforce.com').getText();
                
                if (child.getChildElement('LastLoginDate', 'urn:sobject.enterprise.soap.sforce.com') != null) 
                {
                    lastLoginDate = child.getChildElement('LastLoginDate', 'urn:sobject.enterprise.soap.sforce.com').getText();
                } 
                else
                {
                    lastLoginDate = null;
                }
                
                Salesforce_User__c orgUser  = new Salesforce_User__c();
                orgUser = NI_FetchObjectAccessBatch.createOrgUser(srcOrgID,fullname,useremail,fetchusername,isactive,userid,lastLoginDate,userlicence);
                //orgUser.OrgName__c = ;
                orgUsersToAdd.add(orgUser);
                //
                //Dom.XMLNode rec = child.getChildElement();
                //System.debug(resRecords);
            }
            
        }
        
        //System.debug(orgUsersToAdd);
        
        // if returned record are more than 200 than we need to use query locator to fetch another batch of records.
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
                                '<soapenv:Header>'+
                                '<urn:SessionHeader><urn:sessionId>'+sessionID+'</urn:sessionId></urn:SessionHeader>'+
                                '</soapenv:Header><soapenv:Body>'+
                                '<urn:queryMore><urn:queryLocator>'+queryLoc+'</urn:queryLocator>'+
                                '</urn:queryMore></soapenv:Body></soapenv:Envelope>');       
                userQueryResponse = (new Http()).send(request);
                
                //bodyresp= userQueryResponse.getBody()+'\n\n\n\n\n\n\n\n';
                
                resultElmtUsers = userQueryResponse.getBodyDocument().getRootElement()
                    //system.debug('from test resultElmtUsers ==='+resultElmtUsers );
                    .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('queryMoreResponse', 'urn:enterprise.soap.sforce.com')
                    .getChildElement('result', 'urn:enterprise.soap.sforce.com');
                //system.debug(LoggingLevel.Info,'resultElmtUsers==='+resultElmtUsers);
                
                for (Dom.XMLNode childLocater : resultElmtUsers.getChildElements()) 
                {
                    
                    if (childLocater.getName() == 'records')
                    {
                        //system.debug(LoggingLevel.Info,'childLocater=='+childLocater);
                        //Dom.XmlNode resRecords = child.getChildElement('records', 'urn:enterprise.soap.sforce.com');
                        //Salesforce_User__c orgUser  = new Salesforce_User__c();
                        //orgUser.OrgName__c = srcOrgID;
                        //resRecords = resRecords.getChildElement('records', 'urn:enterprise.soap.sforce.com');
                        string useremail = childLocater.getChildElement('Email', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        string fetchusername = childLocater.getChildElement('Username', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        string isactive = childLocater.getChildElement('IsActive', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        string userid = childLocater.getChildElement('Id', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        string fullname = childLocater.getChildElement('Name', 'urn:sobject.enterprise.soap.sforce.com').getText();
                        string userlicence =  childLocater.getChildElement('Profile', 'urn:sobject.enterprise.soap.sforce.com')
                            .getChildElement('UserLicense', 'urn:sobject.enterprise.soap.sforce.com')
                            .getChildElement('Name', 'urn:sobject.enterprise.soap.sforce.com')
                            .getText();
                        
                        if (childLocater.getChildElement('LastLoginDate', 'urn:sobject.enterprise.soap.sforce.com') != null) 
                        {
                            lastLoginDate = childLocater.getChildElement('LastLoginDate', 'urn:sobject.enterprise.soap.sforce.com').getText();                            
                        } 
                        else
                        {
                            lastLoginDate = null;
                        }                            
                        
                        Salesforce_User__c orgUser = new Salesforce_User__c();
                        orgUser = NI_FetchObjectAccessBatch.createOrgUser(srcOrgID, fullname, useremail, fetchusername, isactive, userid, lastLoginDate, userlicence);
                        orgUsersToAdd.add(orgUser);
                        
                        //Dom.XMLNode rec = child.getChildElement();
                        //System.debug(resRecords);
                    }
                    
                }                
                
                // system.debug('resultElmtUsers ==='+resultElmtUsers );
                isdone = resultElmtUsers.getChildElement('done', 'urn:enterprise.soap.sforce.com').getText();
                // isdone = 'true';
                queryLoc =  resultElmtUsers.getChildElement('queryLocator', 'urn:enterprise.soap.sforce.com').getText();
                
            }
        }
        
        return orgUsersToAdd;
    }
    
    public static Salesforce_User__c createOrgUser(string srcOrgID, string fullname, string useremail, string fetchusername, 
                                                   string isactive, string userid, string lastLoginDate, string userlicence)
    {
        
        Datetime tmpDate;
        Salesforce_User__c orgUser  = new Salesforce_User__c();
        orgUser.OrgName__c = srcOrgID;
        orgUser.User_Full_Name__c = fullname ;
        orgUser.UserEmail__c = useremail;
        orgUser.UserName__c = fetchusername ;
        orgUser.User_Profile_Status__c = (isactive == 'true') ? 'Active' : 'Inactive';
        orgUser.userIDFromOrg__c = userid ;
        orgUser.testscheduler__c = System.now();
        orgUser.User_License__c = userlicence;
        
        if (lastLoginDate != null)
        {
            lastLoginDate = lastLoginDate.replace('T', ' ');
            lastLoginDate = lastLoginDate.replace('.000Z','');
            tmpDate = Datetime.valueOf(lastLoginDate);
            // tmpDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
            orgUser.User_Last_Login_Date__c = tmpDate;
        }
        else
        {
            orgUser.User_Last_Login_Date__c = null;
        }
        // orgUser.User_Last_Login_Date__c = null;
        return orgUser;
    }  
    
    // Fetch all users having full access to all objects starting with hrm or lod04
    //public static Set<String> getAllFullAccessUsers(string sessionID, string SERVER_URL, string inclause)
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
    
    // Fetch all permission sets on org.
    public static Set<String> getPermissionSets(string sessionID,string SERVER_URL,string sql )
    {
        
        system.debug('sql  :-' + sql);
        Set<String> permissionIds = new Set<String>();
        Httprequest request = getHttpRequests(SERVER_URL);
        request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
                        '<soapenv:Header><urn:QueryOptions><urn:batchSize>2</urn:batchSize></urn:QueryOptions>' +
                        '<urn:SessionHeader><urn:sessionId>'+sessionID+'</urn:sessionId></urn:SessionHeader>' +
                        '</soapenv:Header><soapenv:Body>' +
                        '<urn:query><urn:queryString>' + sql + '</urn:queryString>' +
                        '</urn:query></soapenv:Body></soapenv:Envelope>');  
        httpresponse permiResp = (new Http()).send(request);
        //bodyresp= permiResp.getBody()+'\n\n\n\n\n\n\n\n';
        
        Dom.XmlNode resultElmtPerm = permiResp.getBodyDocument().getRootElement()
            .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
            .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
            .getChildElement('result', 'urn:enterprise.soap.sforce.com');
        
        //system.debug('resultElmtPerm == ' + resultElmtPerm);
        
        for (Dom.XMLNode child : resultElmtPerm .getChildElements()) 
        {
            if (child.getName() == 'records')
            {
                string permssID = child.getChildElement('PermissionSetId', 'urn:sobject.enterprise.soap.sforce.com').getText();
                permissionIds.add(permssID);
            }
        }
        system.debug('permissionIds.size() :--' +permissionIds.size() );
        return permissionIds;
        
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