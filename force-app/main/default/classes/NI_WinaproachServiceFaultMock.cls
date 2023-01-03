/************************************************************************************************
                 !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachServiceFaultMock Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/11/2019 
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : 
                : 
*************************************************************************************************/
@isTest
global class NI_WinaproachServiceFaultMock implements HttpCalloutMock
{
    
    global HttpResponse respond(HTTPRequest req)
    {
        
        system.debug(' *** ENTERING NI_WinaproachServiceFaultMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** req.getBody() = ' + req.getBody());
        
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" > <soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.userException</faultcode><faultstring><![CDATA[<ticket_response version="1.0" timestamp="2016-11-28 11:12:06 GMT"><failure><record_id /><external_record_id>001534599</external_record_id><comment>MandatoryFieldsValidator: S0B9C/IR: Assignee Group: SWord is mandatory but not provided.</comment><error_type>EAPR-CRE-JADB</error_type><error_msg>MandatoryFieldsValidator: S0B9CIR: Assignee Group: SWord is mandatory but not provided.</error_msg><resend>true</resend></failure></ticket_response>]]></faultstring><detail><ns1:hostname xmlns:ns1="http://xml.apache.org/axis/">aprtst03</ns1:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>' ) ;
        
        system.debug(' **** res = ' + res);
        
        system.debug(' *** EXITING NI_WinaproachServiceFaultMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        return res;
        
    }
    
}