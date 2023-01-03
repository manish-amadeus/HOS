/************************************************************************************************
Name            : HttpCalloutMockImpl Class
Author          : Artem Glynskyi 
Created Date    : 02/01/2013
Last Mod By     : Shashikant Nikam
Last Mod Date   : 04/22/2019
NICC Reference  : NICC-006221 
Description     : UPDATED 5/7/2019 PER NICC-034473
                : 
                : 
*************************************************************************************************/
@isTest
global class HttpCalloutMockImpl implements HttpCalloutMock
{
    
    public String errorType;
    
    global HttpCalloutMockImpl(String s)
    {
        errorType = s;
        system.debug('Error type : '+errorType);
    }
    
    global HttpCalloutMockImpl()
    {}
    
    global HTTPResponse respond(HTTPRequest req) 
    {        
        HttpResponse res = new HttpResponse();
        
        res.setHeader('Content-Type', 'application/json'); 
        res.setBody(getResponse(req.getEndpoint(),errorType));
        res.setStatusCode(200);  
        return res;  
    }
    
    private static string getResponse(string reqUrl, string errortype) 
    {
        
        string strFile = '';
        string strRetHTML = '';

        // ADDED BY SHASHIKANT ON 04/22/2019
        if (errortype == 'endPoint' && reqUrl.contains('/setup/systemOverview.apexp'))
        {
            strFile = 'MockendPointError';
            
        }
        else if (reqUrl.contains('/setup/systemOverview.apexp')) 
        {
            //strFile = 'MockSystemOverviewHTML';
            //strFile = 'MockSystemOverviewHTML_2';
            strFile = 'MockSystemOverviewHTML_3';
        }
        
        if (reqUrl.contains('/setup/org/orgstorageusage.jsp')) 
        {
            strFile = 'Mock_OrgsStorageUsage';
        }
        if (reqUrl.contains('/02u')) 
        {
            strFile = 'MockAppsHTML';
        }
        if (reqUrl.contains('/0A3?setupid=ImportedPackage')) 
        {
            strFile = 'MockImportedPackagesHTML_3';
        }
        // ADDED BY RIA-3/20
        if(reqUrl.contains('/services/Soap/c/36.0'))
        {
            strFile = 'MockInstalledPackagesSqlMetadata';
        }
        
        if (strFile == '')
        {
            return '';
        }
        
        strRetHTML = getMockFileText(strFile);
        
        return strRetHTML;
    
    }
    
    public static string getMockFileText(string strStaticResourceName)
    {
        string retVal = '';
        StaticResource sr = [SELECT Id, body FROM StaticResource WHERE Name =: strStaticResourceName];
        Blob bContents = sr.body;
        //String contents = EncodingUtil.base64Encode(bContents);
        //string contents = bContents.toString();
        HttpRequest request = new HttpRequest();
        request.setBodyAsBlob(bContents);
        String contents = request.getBody();
        //system.debug('from getMockFileText==='+contents);
        return contents; 
    }     
    
}