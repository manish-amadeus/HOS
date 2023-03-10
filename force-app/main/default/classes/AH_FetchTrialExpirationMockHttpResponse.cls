/****************************************************************************************
Name            : AH_FetchTrialExpirationMockHttpResponse Class
Author          : Shashikant Nikam
Created Date    : 10/27/2017
Last Mod Date   : 05/03/2019
Last Mod By     : Shashikant Nikam
NICC Reference  : 
Description     : Mock response generator for Test class of AH_FetchTrailExpirationBatch.
                :
******************************************************************************************/
@isTest
global class AH_FetchTrialExpirationMockHttpResponse implements HttpCalloutMock
{
	
    Integer login_flag = 0;
    Integer cnt_flag = 0;
    Integer expDate_flag = 0;
    
    global HTTPResponse respond(HTTPRequest req) 
    {
        
        string bodyText = req.getBody();
       	string typecall = '';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setStatusCode(200);
        
        // CREATE FAKE RESPONSE FOR ORG CREATION
		system.debug(LoggingLevel.Info, 'bodyText = ' + bodyText);
        System.debug(LoggingLevel.Info, 'login_flag = ' + login_flag);
        
        if (bodyText.contains('<username>'))
        {
		
			String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            system.debug(' **** baseURL = ' + baseURL);
		
            if (login_flag == 0) 
            {
				res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>https://login.salesforce.com/services/Soap/m/36.0/00D6F000000Dyby</metadataServerUrl><passwordExpired>false</passwordExpired><sandbox>false</sandbox><serverUrl>https://login.salesforce.com/services/Soap/u/36.0/00D6F000000Dyby</serverUrl><sessionId>SESSION_ID_REMOVED</sessionId><userId>0056F000006SQvkQAG</userId><userInfo><accessibilityMode>false</accessibilityMode><currencySymbol>$</currencySymbol><orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>false</orgHasPersonAccounts><organizationId>00D6F000000DybyUAC</organizationId><organizationMultiCurrency>false</organizationMultiCurrency><organizationName>XYZ</organizationName><profileId>00e6F000000L1EjQAK</profileId><roleId>00E6F000000OjEbUAK</roleId><sessionSecondsValid>7200</sessionSecondsValid><userDefaultCurrencyIsoCode xsi:nil="true"/><userEmail>testmail@gmail.com</userEmail><userFullName>Mock  Name</userFullName><userId>0056F000006SQvkQAG</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>test@test.com</userName><userTimeZone>America/Los_Angeles</userTimeZone><userType>Standard</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></soapenv:Envelope>');
                login_flag = 1;
            }
            else if (login_flag == 1)  // INVALID LOGIN MOCK RESPONSE
            { 
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><sf:LoginFault xsi:type="sf:LoginFault"><sf:exceptionCode>INVALID_LOGIN</sf:exceptionCode><sf:exceptionMessage>Invalid username, password, security token; or user locked out.</sf:exceptionMessage></sf:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
                login_flag = 2;
            }
            else if (login_flag == 2)  // EXPIRED PASSWORD MOCK RESPONSE
            { 
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>'+ baseURL +'/services/Soap/m/36.0/00D80000000dKTN</metadataServerUrl><passwordExpired>true</passwordExpired><sandbox>false</sandbox><serverUrl>'+ baseURL +'/services/Soap/u/36.0/00D80000000dKTN</serverUrl><sessionId>SESSION_ID_REMOVED</sessionId><userId>00580000002S0NaAAK</userId><userInfo><accessibilityMode>false</accessibilityMode><currencySymbol xsi:nil="true"/><orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode xsi:nil="true"/><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>false</orgHasPersonAccounts><organizationId>00D80000000dKTNEA2</organizationId><organizationMultiCurrency>true</organizationMultiCurrency><organizationName>Battery Wharf</organizationName><profileId>00e80000001BaHlAAK</profileId><roleId xsi:nil="true"/><sessionSecondsValid>7200</sessionSecondsValid><userDefaultCurrencyIsoCode>USD</userDefaultCurrencyIsoCode><userEmail>amochalin@libraondemand.com</userEmail><userFullName>Preston Rowe</userFullName><userId>00580000002S0NaAAK</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>lod@6libra.com</userName><userTimeZone>America/Los_Angeles</userTimeZone><userType>Standard</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></soapenv:Envelope>');
                login_flag = 0;
            }
            typecall = 'login';
        } 
        else if(login_flag == 1 && bodyText.contains('SELECT AssigneeId, p.PermissionSet.Label  FROM PermissionSetAssignment p where PermissionSetId in (SELECT Id FROM PermissionSet where label LIKE'))
        {
            if (cnt_flag == 0) 
            {
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sf="urn:sobject.enterprise.soap.sforce.com"><soapenv:Header><LimitInfoHeader><limitInfo><current>239</current><limit>15000</limit><type>API REQUESTS</type></limitInfo></LimitInfoHeader></soapenv:Header><soapenv:Body><queryResponse><result><done>true</done><queryLocator xsi:nil="true"/><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000006SQvkQAG</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>banquets</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>View Only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000006SQvkQAG</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>View Only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only1</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000006SQvkQAG</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only1</sf:Label></sf:PermissionSet></records><size>7</size></result></queryResponse></soapenv:Body></soapenv:Envelope>');
                System.debug(LoggingLevel.Info, '1. cnt_flag : '+cnt_flag);
                cnt_flag = 1;
            }
            else if (cnt_flag == 1) 
            {
				res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sf="urn:sobject.enterprise.soap.sforce.com"><soapenv:Header><LimitInfoHeader><limitInfo><current>239</current><limit>15000</limit><type>API REQUESTS</type></limitInfo></LimitInfoHeader></soapenv:Header><soapenv:Body><queryResponse><result><done>true</done><queryLocator xsi:nil="true"/><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000006SQvkQAG</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>banquets</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>View Only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000006SQvkQAG</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>View Only</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000004Vrv6QAC</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only1</sf:Label></sf:PermissionSet></records><records xsi:type="sf:PermissionSetAssignment"><sf:Id xsi:nil="true"/><sf:AssigneeId>0056F000006SQvkQAG</sf:AssigneeId><sf:PermissionSet xsi:type="sf:PermissionSet"><sf:Id xsi:nil="true"/><sf:Label>test view only1</sf:Label></sf:PermissionSet></records><size>7</size></result></queryResponse></soapenv:Body></soapenv:Envelope>');
                System.debug(LoggingLevel.Info, '2. cnt_flag : '+cnt_flag);
                cnt_flag = 2;
            }
            else if (cnt_flag == 2) 
            {
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>sf:INVALID_OPERATION_WITH_EXPIRED_PASSWORD</faultcode><faultstring>INVALID_OPERATION_WITH_EXPIRED_PASSWORD: The users password has expired, you must call SetPassword before attempting any other API operations</faultstring><detail><sf:UnexpectedErrorFault xsi:type="sf:UnexpectedErrorFault"><sf:exceptionCode>INVALID_OPERATION_WITH_EXPIRED_PASSWORD</sf:exceptionCode><sf:exceptionMessage>The users password has expired, you must call SetPassword before attempting any other API operations</sf:exceptionMessage></sf:UnexpectedErrorFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
            }
            typecall = 'count of users';        
        }
        else if (login_flag == 1 && bodyText.contains('SELECT TrialExpirationDate from Organization'))
        {
            if (expDate_flag == 0) 
            {
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:sf="urn:sobject.enterprise.soap.sforce.com"><soapenv:Header><LimitInfoHeader><limitInfo><current>295</current><limit>15000</limit><type>API REQUESTS</type></limitInfo></LimitInfoHeader></soapenv:Header><soapenv:Body><queryResponse><result><done>true</done><queryLocator xsi:nil="true"/><records xsi:type="sf:Organization"><sf:Id xsi:nil="true"/><sf:TrialExpirationDate>2016-12-14T10:28:29.000Z</sf:TrialExpirationDate></records><size>1</size></result></queryResponse></soapenv:Body></soapenv:Envelope>');
                system.debug(LoggingLevel.Info, '1. expDate_flag = ' + expDate_flag);
                expDate_flag = 1;
            }
            else if (expDate_flag == 1)
            {
                res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sf="urn:fault.enterprise.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>sf:INVALID_OPERATION_WITH_EXPIRED_PASSWORD</faultcode><faultstring>INVALID_OPERATION_WITH_EXPIRED_PASSWORD: The users password has expired, you must call SetPassword before attempting any other API operations</faultstring><detail><sf:UnexpectedErrorFault xsi:type="sf:UnexpectedErrorFault"><sf:exceptionCode>INVALID_OPERATION_WITH_EXPIRED_PASSWORD</sf:exceptionCode><sf:exceptionMessage>The users password has expired, you must call SetPassword before attempting any other API operations</sf:exceptionMessage></sf:UnexpectedErrorFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
                system.debug(LoggingLevel.Info, '2. expDate_flag = ' + expDate_flag);
                login_flag = 0;
            }
            typecall = 'Trial Expiration Date';
        }
		
        system.debug(LoggingLevel.Info, 'res.body = ' + res.getBody());
        system.debug(LoggingLevel.Info, 'typecall = ' + typecall);
        return res;
        
    }
    
}