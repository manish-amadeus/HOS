/************************************************************************************************
Name            : FillAccount Class
Author          : Artem Glynskyi 
Created Date    : 02/01/2013
Last Mod By     : Stuart Emery
Last Mod Date   : 05/2/2019
NICC Reference  : NICC-006221 
Description     : 
                : UPDATED 05/02/2019 PER NICC-034473
                : MODIFIED FOR NICC-009760 - 3/11/2014
                : NICC-026755 - ParsePackages() Changed by Cybage
                :
*************************************************************************************************/
public with sharing class FillAccount 
{ 
    
    public NI_Org_Details__c account;   
    public PollingResult__c previous { get; set; }
    public PollingResult__c result { get; set; }    
    public String endPointURL;
    public Boolean isTest { get; set; }
    public String sessionId { get; set; }     
    private String serverUrl;     
    private String orgId;     
    private String origLocale;    
    private String userId;
     
    
    public FillAccount()
    {
        this.isTest = false;
        this.previous = new PollingResult__c();
        this.result = new PollingResult__c();
    }
    
    // MAIN FUNCTION
    public void fill()
    { 
        try
        {   
            fillSystemInfo();
            login();
            
            if (!parseSystemOverview()) 
            { 
                return;
            }
            
            parseStorageUsage(); 
            parseStorageFileUsage();
            parseUnmanaged(); 
            parsePackages(); 
            parseLicenses(); 
            fetchInstalledPackages(); 
            
        }
        catch (Exception ex)
        {
            fillError(ex);
        }
    }
    
    private void fillSystemInfo() 
    {
        result.ErrorOccured__c = false;
        result.Error__c = '';
        result.ErrorType__c = '';
        result.Name = string.valueOf(getCurDateTime());
        result.DateTime__c = getCurDateTime(); 
        if (result.AccountId__c == null) 
        {
            result.AccountId__c = account.Id; 
        }
        Long repPerMilli = getCurDateTime().getTime() - previous.DateTime__c.getTime();
        result.ReportingPeriod__c = repPerMilli / (1000 * 60 * 60);
    }

    private void login() 
    {   
        // ADDED 7/16/2013 ====================================================================================
        string sEndPoint = 'https://login.salesforce.com/services/Soap/u/55.0'; 
        
        if (account.Org_Type__c.Contains('Salesforce Sandbox'))
        {   
            sEndPoint = 'https://test.salesforce.com/services/Soap/u/55.0'; 
        }
        
        PartnerRemote.Soap soap = new PartnerRemote.Soap();
        
        PartnerRemote.LoginResult loginResult = soap.login(account.Admin_Login_Name_Encrypted__c, account.Admin_Password_Encrypted__c.trim() + account.Security_Token_Encrypted__c.trim(), sEndPoint);  

        soap.endpoint_x = loginResult.serverUrl; 
        serverUrl = loginResult.serverUrl.split('/services')[0]; 
        sessionId = loginResult.sessionId; 
        orgId = loginResult.userInfo.organizationId; 
        origLocale = loginResult.userInfo.userLocale; 
        userId = loginResult.userInfo.userId; 
        
    }
    
    // PARSING FUNCTIONS ===========================================================================================    
    private Boolean parseSystemOverview() 
    {

        String body = getPage('/setup/systemOverview.apexp', false);

        // IF PASSWORD CHANGED, BAIL
        if (Test.isRunningTest() && body.contains('Unauthorized endpoint, please check Setup->Security->Remote site settings'))
        {
            fillError(body);
        }
        
        if (detectChangePassword(body))
        {
            return false;
        }
system.debug(' *** body = ' + body);        
        Matcher pattApiUsage = Pattern.compile('usage_block_api_num_1"><span class="textOnly">(.+)<').matcher(body);
        Matcher pattApiAllocation = Pattern.compile('</span>&nbsp;\\(.*? (\\d.+)\\)').matcher(body.substringAfter('j_id0:j_id12:1:j_id16:j_id17:j_id24:0:j_id52'));
        Matcher pattDataStorage = Pattern.compile('usage_block_schema_num_5">.*>(.+)&nbsp;(GB|MB|KB)</a>').matcher(body);
        Matcher pattDataAllocation = Pattern.compile('</span>.*? (\\d.+)&nbsp;(MB|GB|KB)\\)').matcher(body.substringAfter('j_id0:j_id12:0:j_id16:j_id17:j_id24:2:j_id52'));
        
        pattApiUsage.find();
        
        result.ApiUsage__c = getDecimal(pattApiUsage.group(1).replace(',', ''));       
        pattApiAllocation.find();
        
        result.ApiAllocation__c = getDecimal(pattApiAllocation.group(1));           
        pattDataStorage.find();
        
        result.DataStorageUsage__c = getGbAmount(pattDataStorage.group(1), pattDataStorage.group(2));      
        
        if (!pattDataAllocation.find()) 
        {
            pattDataAllocation = Pattern.compile('&nbsp;.*? .*? (\\d.*?)&nbsp;(GB|MB|KB)').matcher(body.substringAfter('j_id0:j_id12:4:j_id16:j_id17:j_id24:0:j_id46'));
            pattDataAllocation.find();
        }
        result.DataStorageAllocation__c = getGbAmount(pattDataAllocation.group(1), pattDataAllocation.group(2));
        return true;
    }
    
    private void parseStorageUsage() 
    {
        String body = getPage('/setup/org/orgstorageusage.jsp?id=' + orgId, true);
        result.TotalBookings__c = parseStorageUsageElement(body, '(?:Bookings|Мероприятия)');   
        result.TotalReservations__c = parseStorageUsageElement(body, '(?:Reservations|Брони)');
        result.TotalEmailCampaigns__c = parseStorageUsageElement(body, '(?:Email Campaigns|Почтовые рассылки)');
        result.TotalMemberAccounts__c = parseStorageUsageElement(body, '(?:Member Accounts|Счета участника)');
    }
    
    // ADDED THIS FUNCTION 3/11/2014 for NICC-009760     
    private void parseStorageFileUsage() 
    {
        string str = '>File Storage</th><td class=" dataCell  numericalColumn">(.+?)</td><td class=" dataCell  numericalColumn">(.+?)</td><td class=" dataCell  numericalColumn">(.+?)<';
        String body = getPage('/setup/org/orgstorageusage.jsp?id=' + orgId, true);
        Matcher pattElem = Pattern.compile(str).matcher(body); 
        
        if (pattElem.find()) 
        {
            try
            {
                result.FileStorageLimit__c = pattElem.group(1).replace('&nbsp;', ' '); 
                result.FileStorageUsed__c = pattElem.group(2).replace('&nbsp;', ' '); 
                result.FileStoragePercentUsed__c = pattElem.group(3).replace('&nbsp;', ' '); 
            }
            catch (Exception e) {}
        }    
    }
    
    private void parseUnmanaged() 
    {
        String appsBody = getPage('/02u', true);
        Integer customApps = getCheckedCount(appsBody);     
        result.UnmanagedCustomObjects__c = getUnManagedCount(getPage('/p/setup/custent/CustomObjectsPage', true));
        result.UnmanagedCustomApps__c = getUnManagedCount(appsBody) - (getItemsCount(appsBody) - customApps);
        result.UnmanagedCustomTabs__c = getUnManagedCount(getPage('/setup/ui/customtabs.jsp', true));
    }   
    
    public void parsePackages() 
    {
        MetadataService.SERVER_URL = serverUrl;
        String sql = 'SELECT AllowedLicenses,CreatedDate,ExpirationDate,Id,IsProvisioned,LastModifiedDate,NamespacePrefix,Status,SystemModstamp,UsedLicenses FROM PackageLicense';  
        Httprequest request = getHttpRequests(serverUrl);
        httpresponse permiResp = getHttpResponse(request, sessionId, sql);
        string resp= permiResp.getBody();
        Dom.XmlNode resultElmtPerm;
        
        List<Package_Namespace_Preefix__mdt> packagePrefixes = new List<Package_Namespace_Preefix__mdt>();
        packagePrefixes = [SELECT DeveloperName FROM Package_Namespace_Preefix__mdt];
        List<String> NameList = new List<String>();

        for (Package_Namespace_Preefix__mdt pck : packagePrefixes) {
            NameList.add(pck.DeveloperName);
        }
        
        String NamespacePrefix_pkg = '';
        if (resp.containsIgnoreCase('<faultcode>'))
        {
            Dom.XmlNode resultElmt1 = permiResp.getBodyDocument().getRootElement()
                .getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
            
            String faultstring = resultElmt1.getChildElement('faultstring',null).getText();
        }
        else 
        {
            try {
                resultElmtPerm = permiResp.getBodyDocument().getRootElement()
                    .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                    .getChildElement('queryResponse', 'urn:enterprise.soap.sforce.com')
                    .getChildElement('result', 'urn:enterprise.soap.sforce.com');
 
                Map<String, Map<String,String>> instPkgs = new Map<String, Map<String,String>>();
                
                if (resultElmtPerm != null) {
                    for (Dom.XMLNode child : resultElmtPerm .getChildElements()) {
                        if (child.getName() == 'records' ) {
                            
                            String ExpirationDate = '';
                            String Status = '';
                            String AllowedLicenses = '';
                            String UsedLicenses = '';
                            Map<String,String> installedPkg = new Map<String,String>();
                            
                            for (Dom.XMLNode innerChild : child.getChildElements()) {
                                
                                if (innerChild.getName() != null && innerChild.getName() == 'NamespacePrefix') 
                                    NamespacePrefix_pkg = innerChild.getText();
                                installedPkg.put('NamespacePrefix', NamespacePrefix_pkg);
                                
                                if (innerChild.getName() != null && innerChild.getName() == 'ExpirationDate') 
                                    ExpirationDate = innerChild.getText();
                                installedPkg.put('ExpirationDate', ExpirationDate);
                                
                                if (innerChild.getName() != null && innerChild.getName() == 'Status') 
                                    Status = innerChild.getText();
                                installedPkg.put('Status', Status);
                                
                                if (innerChild.getName() != null && innerChild.getName() == 'AllowedLicenses') 
                                    AllowedLicenses = innerChild.getText();
                                installedPkg.put('AllowedLicenses', AllowedLicenses);
                                
                                if (innerChild.getName() != null && innerChild.getName() == 'UsedLicenses') 
                                    UsedLicenses = innerChild.getText();
                                installedPkg.put('UsedLicenses', UsedLicenses);
                            }
                            if (NamespacePrefix_pkg != '' && !instPkgs.containsKey(NamespacePrefix_pkg))
                            {
                                instPkgs.put(NamespacePrefix_pkg, installedPkg);
                            }
                        }
                    }
                }
                
                // ITERATE OVER nameSpaces FROM CUSTOM METADATA TYPE
                for (String nameSpacePrefix : NameList) {
                    
                    // SEQUENTIALLY CHECK FOR MATCHING nameSpacePrefix
                    // IF MATCH FOUND MAKE METADATA API CALL FOR VERSION NUMBER AND BREAK THE LOOP 
                    if (instPkgs.containsKey(nameSpacePrefix)) {
                        
                        Map<String, String> retPkgdata = instPkgs.get(nameSpacePrefix);
                        
                        result.PackageExpirationDate__c = retPkgdata.get('ExpirationDate');
                        if (result.PackageExpirationDate__c == '' || result.PackageExpirationDate__c == null) 
                        {
                            result.PackageExpirationDate__c = 'Does Not Expire';
                        }                        
                        result.PackageStatus__c = retPkgdata.get('Status');
                        result.PackageAllowedLicenses__c = retPkgdata.get('AllowedLicenses');
                        result.PackageUsedLicenses__c = retPkgdata.get('UsedLicenses');
                        if (result.PackageAllowedLicenses__c == '-1' || result.PackageAllowedLicenses__c == '' || result.PackageAllowedLicenses__c == null) 
                        {
                            result.PackageAllowedLicenses__c = 'Unlimited';
                        }
                        
                        // METADATA API CALL TO GET PACKAGE VERSION NUMBER                                
                        MetadataService.MetadataPort service = createService();
                        List<String> nameList1 = new List<String>();
                        nameList1.add(nameSpacePrefix);
                        MetadataService.IReadResult readResult = service.readMetadata('InstalledPackage', nameList1);

                        List<MetadataService.InstalledPackage> t = (List<MetadataService.InstalledPackage>)readResult.getRecords();
                        
                        for (MetadataService.InstalledPackage ins : t){
                            result.HRMPackageVersion__c = ins.versionNumber;
                        }
                        break;
                    }
                }
            }
            catch(Exception e){
                System.debug('Error occured at line : ' +e.getLineNumber() + ' => '+e);
            }
        }  
        
    }
    
    public MetadataService.MetadataPort createService()
    {   
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionId;
        return service;     
    }
    
    public static httprequest getHttpRequests(string SERVER_URL){
        
        Httprequest request = new HttpRequest();
        request.setEndpoint(SERVER_URL + '/services/Soap/c/55.0');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        request.setHeader('SOAPAction', '""');
        return request;
    }
    
    public static HttpResponse getHttpResponse (Httprequest request, String SESSION_ID, String sql){
        
        HttpResponse permiResp = new HttpResponse();
        try {
            request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">'+
                            '<soapenv:Header><urn:QueryOptions><urn:batchSize>2</urn:batchSize></urn:QueryOptions>'+
                            '<urn:SessionHeader><urn:sessionId>'+SESSION_ID+'</urn:sessionId></urn:SessionHeader>'+
                            '</soapenv:Header><soapenv:Body>'+
                            '<urn:query><urn:queryString>'+sql+'</urn:queryString>'+
                            '</urn:query></soapenv:Body></soapenv:Envelope>');      
            
            permiResp = (new Http()).send(request);
        } 
        catch(Exception e) {
            System.debug('Exception captured in getHttpRespose : '+e.getlinenumber()+'\n\n'+e.getMessage());
        }
        return permiResp;
    }
    
    private void parseLicenses() 
    {
        String body = getPage('/' + orgId, true);       
        result.TotalLicensedSalesforceUsers__c = getTotalLicenses('Salesforce', body);
        result.TotalLicensedSalesforcePlatformUsers__c = getTotalLicenses('Salesforce Platform', body);
        result.TotalActiveSalesforceUsers__c  = getUsedLicenses('Salesforce', body);
        result.TotalActiveSalesforcePlatformUsers__c = getUsedLicenses('Salesforce Platform', body);
    }   
    
    private Decimal parseStorageUsageElement(String body, String name) 
    {
        Matcher pattElem = Pattern.compile('>' + name + '</span></th><td class=" dataCell  numericalColumn">(.+?)<').matcher(body);     
        if (!pattElem.find()) 
        {
            return 0;
        }
        return getDecimal(pattElem.group(1).replace(',', ''));
    }
    
    
    // ERROR REPORTING FUNCTIONS ==================================================================================
    private void fillError(Exception ex) 
    {
        fillError(ex.getTypeName() + '\n' + ex.getMessage() + '\n' + ex.getStackTraceString());
    }
    
    private void fillError(string error) 
    {
        system.debug('error : '+error);
        
        Matcher pattErrorType = Pattern.compile('faultcode=(?:sf:)?(.*?) ').matcher(error);     
        result.Name = 'Error - ' + result.Name;
        result.ErrorOccured__c = true;
        result.Error__c = error;
        if (pattErrorType.find()) 
        {
            result.ErrorType__c = pattErrorType.group(1);
        }
        
        if (error.contains('Unauthorized endpoint, please check Setup->Security->Remote site settings'))
        {
            result.ErrorType__c = 'Unauthorized endpoint';
            result.Endpoint_URL__c = endPointURL;
        }
    }    
    
    private String getPage(string url, Boolean setSid) 
    {        
        PageReference theUrl = new PageReference(serverUrl + url);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(theUrl.getUrl());    
        endPointURL = theUrl.getUrl();
        system.debug('theUrl.getUrl() : '+theUrl.getUrl());
        request.setMethod('GET');
        if (setSid) 
        {
            request.setHeader('Cookie', 'sid=' + sessionId + ';');  
        }
        else 
        {
            request.setHeader('Authorization', 'OAuth ' + sessionId);
            request.setHeader('X-PrettyPrint', '1');
        }
        
        request.setTimeout(60000);
        HttpResponse response = (new Http()).send(request);
        return response.getBody();
    }
    
    private Integer getCheckedCount(String body) 
    {
        return getPatternCount(body, 'src="/img/checkbox_checked.gif"');
    }
    
    private Integer getUnManagedCount(String body) 
    {
        return getPatternCount(body, '<td class="iconColumn">&nbsp;</td>');
    }
    
    private Integer getItemsCount(String body) 
    {
        return getPatternCount(body, '<!-- ListRow -->');       
    }
    
    private Integer getPatternCount(String body, String inPat) 
    {
        Matcher patt = Pattern.compile(inPat).matcher(body);
        Integer count = 0;
        
        while (patt.find()) 
        {
            count++;    
        }       
        return count;
    }
    
    private Integer getCollumnIndex(String body, String[] names) 
    {
        Matcher pattColl = Pattern.compile('>(.+?)</th>').matcher(body);
        Integer collumn = 0;
        String res = '';
        
        while (pattColl.find()) 
        {
            collumn++;
            for (String name : names) 
            {               
                if(pattColl.group(1) == name) return collumn;
            }
            res += pattColl.group(1);
        }
        return -1;
    }
    
    private String getPackageCollumn(String body, Integer coll) 
    {
        if (coll == -1) 
        {
            return null;
        }
        
        Matcher pattColl = Pattern.compile('<td class=" *dataCell *">(<span +class=".*?">)?(.*?)(</span>)?</td>').matcher(body);
        for(Integer i = 0; i < coll; i++) 
        {
            pattColl.find();
        }
        return pattColl.group(2);
    }
    
    private Integer getTotalLicenses(String licType, String body) 
    {
        return getLicensesCollumn(licType, 1, body);
    }
    
    private Integer getUsedLicenses(String licType, String body) 
    {
        return getLicensesCollumn(licType, 2, body);
    }
    
    private Integer getLicensesCollumn(String licType, Integer col, String body) 
    {
        String itemBeginMarker = licType + '</th>';
        String itemBody = body.substringAfter(itemBeginMarker).replace(',', '');
        Matcher pattCol = Pattern.compile('<td class=" *dataCell *numericalColumn">(\\d+)</td>').matcher(itemBody);
        
        for (Integer i = 0; i < col; i++) 
        {
            if (!pattCol.find()) 
            {
                return null;
            }   
        }
        return Integer.valueOf(pattCol.group(1));
    }
    
    private Datetime getCurDateTime() 
    {
        return isTest ? Datetime.newInstance(0) : Datetime.now();
    }
    
    private Decimal getDecimal(String value) 
    {
        Decimal retDec = 0;
        // REMOVE ANY SPACES
        value = value.replace(' ', '');  
        // REMOVE COMMAS 
        value = value.replace(',', '');          
        // REMOVE SINGLE QUOTE
        value = value.replace('\'', '');  
        // REMOVE PERIODS 
        Boolean euroLocale = isEuropeanLocale(value);                    
        value = value.replace(euroLocale ? '.' : ',', '');
        retDec = Decimal.valueOf(value);
        
        return retDec;
        
    }
    
    private Decimal getGbAmount(String value, String unitType) 
    {
        return getDecimal(value) / (unitType == 'MB' ? 1024 : unitType == 'KB' ? 1024 * 1024 : 1);
    }    
    
    private Boolean detectChangePassword(string body) 
    { 
        if (body.indexOf('var url = \'/_ui/system/security/ChangePassword?') != -1) 
        {
            //system.debug('==password expired==');
            fillError('Password expired');
            result.ErrorType__C = 'PASSWORD_EXPIRED';
            return true;
        }
        return false;
    }
    
    private Boolean isEuropeanLocale(String value) 
    {
        Integer commaIndex = value.indexOf(',');
        Integer dotIndex = value.indexOf('.');
        
        if (commaIndex != -1) 
        {
            return ((commaIndex + 3) >= value.length());                            
        }
        if (dotIndex != -1) 
        {
            return !((dotIndex + 3) >= value.length());
        }
        return false;
    }
    
    private void fetchInstalledPackages()
    {         
        try 
        {
            // CURRENT ORG DETAIL BEING POLLED (TEST HARNESS)    
            NI_Org_Details__c od = [SELECT Id FROM NI_Org_Details__c WHERE Id =: account.Id];
            
            // RETRIEVE INSTALLED PACKAGES PAGE MARKUP
            String body = getPage('/0A3?setupid=ImportedPackage', true);
            
            // EXTRACT INSTALLED PACKAGES HTML TABLE
            String htmlTableBody = body.substringAfter('<table class="list"');
            htmlTableBody = htmlTableBody.substringBefore('</table>');
            
            // LOAD TABLE ROWS INTO A STRING ARRAY
            String[] strRows = htmlTableBody.split('<!-- ListRow -->');
            
            // LIST OF EXTRACTED INSTALLED PACKAGES TO BE UPSERTED
            List<NI_Org_Details_Installed_Packages__c> lstODInstPacksUpsert = new List<NI_Org_Details_Installed_Packages__c>();
            
            // LIST OF EXTRACTED INSTALLED PACKAGES FROM SCRAPE
            List<NI_Org_Details_Installed_Packages__c> lstODInstPacksNew = new List<NI_Org_Details_Installed_Packages__c>();
            
            // LIST OF PREVIOUSLY INSERTED INSTALLED PACKAGE DETAILS FOR CURRENT ORG DETAIL
            List<NI_Org_Details_Installed_Packages__c> lstODInstPacksExisting = new List<NI_Org_Details_Installed_Packages__c>(
                [SELECT Id, Name, Namespace_Prefix__c, Publisher__c, NI_Org_Details__c, Managed__c, Install_Date__c, 
                 Version_Number__c, Status__c, Allowed_Licenses__c, Used_Licenses__c, Expiration_Date__c, Limits__c, 
                 Apps__c, Tabs__c, Objects__c 
                 FROM NI_Org_Details_Installed_Packages__c 
                 WHERE NI_Org_Details__c =: od.Id]
            );
            
            // LOOP THOUGH AND PARSE TABLE ROWS
            for (integer i = 0; i < strRows.Size(); i++)
            {
                string strTD = strRows[i];
                boolean bIsManaged = false;
                boolean bHasLimits = false;                
                
                // SKIP HEADER ROW AND DESCRIPTION ROWS 
                if ((!strTD.contains('<tr class="headerRow">')) && (!strTD.contains('id="null_description"')))
                {
                    // CHECK FOR MANAGED PACKAGE ICON 
                    if (strTD.contains('<img src="/img/indicators/icoManagedInstalled.gif" alt="Managed - Installed" width="16" height="16" title="Managed - Installed" />'))
                    {
                        bIsManaged = true;
                    }
                    // CHECK FOR LIMITS CHECKBOX 
                    if (strTD.contains('booleanColumn"><img src="/img/checkbox_checked.gif"'))
                    {
                        bHasLimits = true;
                    }
                    
                    string strDBug = '[NI_Org_Details__c] = ' + account.Id;
                    strDBug += ', [Is Managed Package] = ' + string.valueOf(bIsManaged);
                    strDBug += ', [Package Name] = ' + getPackageName(strTD, 1);
                    strDBug += ', [Publisher] = ' + getPackageCollumn(strTD, 1);
                    strDBug += ', [Version Number] = ' + getPackageCollumn(strTD, 2);
                    strDBug += ', [Namespace Prefix] = ' + getPackageCollumn(strTD, 3);
                    if (strTD.contains('<td class=" dataCell  DateElement">'))
                    {
                        strDBug += ', [Install Date] = ' + getPackageDataElement(strTD, 1);
                    }
                    else
                    {
                        strDBug += ', [Install Date] = ' + getPackageCollumn(strTD, 8);
                    }           
                    strDBug += ', [Limits] = ' + string.valueOf(bHasLimits);
                    strDBug += ', [Apps] = ' + getPackageNumeric(strTD, 1);
                    strDBug += ', [Tabs] = ' + getPackageNumeric(strTD, 2);
                    strDBug += ', [Objects] = ' + getPackageNumeric(strTD, 3);
                    
                    NI_Org_Details_Installed_Packages__c p = new NI_Org_Details_Installed_Packages__c();
                    
                    p.NI_Org_Details__c = account.Id;
                    p.Name = getPackageName(strTD, 1).Replace('&nbsp;', ' ');                
                    p.Managed__c = bIsManaged;
                    p.Publisher__c = getPackageCollumn(strTD, 1).Replace('&nbsp;', ' ');
                    p.Version_Number__c = getPackageCollumn(strTD, 2).Replace('&nbsp;', ' ');
                    p.Namespace_Prefix__c = getPackageCollumn(strTD, 3).Replace('&nbsp;', ' ');
                    p.Status__c = getPackageCollumn(strTD, 4).Replace('&nbsp;', ' ');
                    p.Allowed_Licenses__c = getPackageCollumn(strTD, 5).Replace('&nbsp;', ' ');
                    p.Used_Licenses__c = getPackageCollumn(strTD, 6).Replace('&nbsp;', ' ');
                    p.Expiration_Date__c = getPackageCollumn(strTD, 7).Replace('&nbsp;', ' ');                 
                    if (strTD.contains('<td class=" dataCell  DateElement">'))
                    {
                        p.Install_Date__c = getPackageDataElement(strTD, 1);
                    }
                    else
                    {
                        p.Install_Date__c = getPackageCollumn(strTD, 8);
                    }                        
                    p.Limits__c = bHasLimits;
                    p.Apps__c = Integer.valueOf(getPackageNumeric(strTD, 1));
                    p.Tabs__c = Integer.valueOf(getPackageNumeric(strTD, 2));
                    p.Objects__c = Integer.valueOf(getPackageNumeric(strTD, 3));   
                    
                    lstODInstPacksNew.Add(p);                
                    
                }
            }
            
            // ADDED THIS 3/17/2017 TO MOVE AWAY FROM DELETING ALL NI_Org_Details_Installed_Packages__c RECORDS.
            // IT WAS CAUSING PROBLEMS WITH NEW CODE THAT FIRED BECAUSE OF THE DELETE/INSERT EVENT.
            // THIS NEW CODE WILL NOT DELETE THE RECORDS BUT UPDATE EXISTING AND INSERT ONLY NEW RECORDS FOUND
            for (NI_Org_Details_Installed_Packages__c lstNewIPs : lstODInstPacksNew)
            {
                boolean bFound = false;                
                for (NI_Org_Details_Installed_Packages__c lstOldIPs : lstODInstPacksExisting)
                {
                    boolean bHasChanged = false;
                    if ((lstNewIPs.Name == lstOldIPs.Name) && 
                        (lstNewIPs.Publisher__c == lstOldIPs.Publisher__c) && 
                        (lstNewIPs.NI_Org_Details__c == lstOldIPs.NI_Org_Details__c) 
                       )
                    {
                        bFound = true;
                        
                        if (lstNewIPs.Version_Number__c != lstOldIPs.Version_Number__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Status__c != lstOldIPs.Status__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Allowed_Licenses__c != lstOldIPs.Allowed_Licenses__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Used_Licenses__c != lstOldIPs.Used_Licenses__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Expiration_Date__c != lstOldIPs.Expiration_Date__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Limits__c != lstOldIPs.Limits__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Apps__c != lstOldIPs.Apps__c)
                        {
                            bHasChanged = true;
                        }                 
                        if (lstNewIPs.Tabs__c != lstOldIPs.Tabs__c)
                        {
                            bHasChanged = true;
                        }
                        if (lstNewIPs.Objects__c != lstOldIPs.Objects__c)
                        {
                            bHasChanged = true;
                        }       
                        // ADD TO UPSERT ONLY IF THERE IS CHANGE
                        if (bHasChanged)
                        {
                            lstODInstPacksUpsert.Add(lstOldIPs);
                        }
                        
                    }
                }
                // ADD TO UPSERT ONLY IF MISSING
                if (!bFound)
                {                    
                    lstODInstPacksUpsert.add(lstNewIPs);
                }
                
            }  
            
            if (lstODInstPacksUpsert.Size() > 0)
            {
                Database.upsert(lstODInstPacksUpsert);                
            }
            
        }        
        catch (Exception e)
        {
            system.debug('error at line : '+e.getLineNumber());
            system.debug('complete error  : '+e);
            fillError(e.getMessage());
            result.ErrorType__c = 'INSTALLED_PACKAGE_PARSE_ERROR';
        }
        
    } 
    
    // REGEX PARSERS ===============================================================================================================================
    private String getPackageNumeric(String body, Integer col) 
    {
        if (col == -1) 
        {
            return null;
        }
        
        Matcher pattColl = Pattern.compile('<td class=" *dataCell *numericalColumn">(<span +class=".*?">)?(.*?)(</span>)?</td>').matcher(body);
        
        for(Integer i = 0; i < col; i++) 
        {       
            pattColl.find();
        }
        return pattColl.group(2);
    }     
    
    private String getPackageName(String body, Integer col) 
    {
        if (col == -1) 
        {
            return null;
        }
        
        Matcher pattColl = Pattern.compile('<th scope="row" class=" *dataCell *">(<a href=".*?">)?(.*?)(</a>)?</th>').matcher(body);
        
        for(Integer i = 0; i < col; i++) 
        {       
            pattColl.find();
        }
        return pattColl.group(2);
    } 
    
    public String getPackageDataElement(String body, Integer col) 
    {
        if (col == -1) 
        {
            return null;
        }
        
        Matcher pattColl = Pattern.compile('<td class=" *dataCell *DateElement">(<span +class=".*?">)?(.*?)(</span>)?</td>').matcher(body);
        
        for(Integer i = 0; i < col; i++) 
        {       
            pattColl.find();
        }
        return pattColl.group(2);
    } 
    
}