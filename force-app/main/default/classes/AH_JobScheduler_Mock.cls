/****************************************************************************************
Name            : AH_JobScheduler_Mock Class 
Author          : Shashikant Nikam
Created Date    : 04/06/2020
Last Mod Date   : 04/10/2020
Last Mod By     : Shashikant Nikam
NICC Reference  : NICC-042467
Description     : This is a Mock Class used in AH_JobScheduler_Cntlr class 
                :  
                : 
******************************************************************************************/
global class AH_JobScheduler_Mock implements HttpCalloutMock 
{
    
	global HTTPResponse respond(HTTPRequest req) 
	{        
        
		String endpoint = req.getEndpoint();
        String body = req.getBody();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        if (body.contains('system.schedule'))
        {
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/08/apex" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><DebuggingInfo><debugLog>36.0 APEX_CODE,FINEST Execute Anonymous: Class1 sch2 = new Class1();String sch = &apos;0 45 3 ? * SUN *&apos;; Id jobId = system.schedule(&apos;Job1&apos;, sch, sch2);system.debug(&apos;=====jobId : &apos;+jobId+&apos;=====&apos;);=====jobId : 08e6C00000FvH1zQAF=====</debugLog></DebuggingInfo></soapenv:Header><soapenv:Body><executeAnonymousResponse><result><column>-1</column><compileProblem xsi:nil="true"/><compiled>true</compiled><exceptionMessage xsi:nil="true"/><exceptionStackTrace xsi:nil="true"/><line>-1</line><success>true</success></result></executeAnonymousResponse></soapenv:Body></soapenv:Envelope>');
        }
        else if (body.contains('SELECT Id, CronJobDetail.Name'))
        {
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sf="urn:sobject.enterprise.soap.sforce.com"><soapenv:Header><LimitInfoHeader><limitInfo><current>28</current><limit>5012800</limit><type>API REQUESTS</type></limitInfo></LimitInfoHeader></soapenv:Header><soapenv:Body><queryResponse><result><done>true</done><queryLocator xsi:nil="true"/><records xsi:type="sf:CronTrigger"><sf:Id>08e6C00000FvH1zQAF</sf:Id><sf:CronJobDetail xsi:type="sf:CronJobDetail"><sf:Id xsi:nil="true"/><sf:JobType>7</sf:JobType><sf:Name>Job1</sf:Name></sf:CronJobDetail><sf:CronJobDetailId>08a6C00000FvH0ZQAV</sf:CronJobDetailId><sf:NextFireTime>2020-04-11T22:15:00.000Z</sf:NextFireTime><sf:OwnerId>0050d000003ZpjpAAC</sf:OwnerId></records><size>1</size></result></queryResponse></soapenv:Body></soapenv:Envelope>');
		}
        else if (body.contains('Running User Name'))
        {
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/08/apex" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><DebuggingInfo><debugLog>36.0 APEX_CODE,FINESTExecute Anonymous: system.debug(&apos;=====Running User Name : &apos;+UserInfo.getName()+&apos;=====&apos;);=====Running User Name : Shashikant Nikam=====</debugLog></DebuggingInfo></soapenv:Header><soapenv:Body><executeAnonymousResponse><result><column>-1</column><compileProblem xsi:nil="true"/><compiled>true</compiled><exceptionMessage xsi:nil="true"/><exceptionStackTrace xsi:nil="true"/><line>-1</line><success>true</success></result></executeAnonymousResponse></soapenv:Body></soapenv:Envelope>');
        }
        else if (body.contains('System.abortJob'))
        {
			res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/08/apex" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><DebuggingInfo><debugLog>36.0 APEX_CODE,FINEST</debugLog></DebuggingInfo></soapenv:Header><soapenv:Body><executeAnonymousResponse><result><column>-1</column><compileProblem xsi:nil="true"/><compiled>true</compiled><exceptionMessage xsi:nil="true"/><exceptionStackTrace xsi:nil="true"/><line>-1</line><success>true</success></result></executeAnonymousResponse></soapenv:Body></soapenv:Envelope>');
        }

        return res;
	
    }
    
}