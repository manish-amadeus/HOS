/************************************************************************************************
                !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachTestMock Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/21/2019
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     : Test class for Winaproach Integration Callouts
                : 
*************************************************************************************************/
@isTest
global class NI_WinaproachTestMock implements HttpCalloutMock 
{
    
    global HttpResponse respond(HTTPRequest req)
    {
        
        system.debug(' *** ENTERING NI_WinaproachTestMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** req.getBody() = ' + req.getBody());
        
        system.Assert(req != null);
        
        HttpResponse res = new HttpResponse();
        String request = req.getBody();
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        dom.Document reqDoc	= new dom.Document();
        reqDoc.load(request);
        dom.XmlNode envelope = reqDoc.getRootElement();
		dom.XmlNode header = envelope.getChildElement('Body', soapNS);
        
        if (header.getChildElement('create', null) != null)
        {
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ><soapenv:Body><createResponse><createReturn>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-11-25 06:15:46 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;11098269&lt;/record_id&gt;&lt;external_record_id&gt;50017000004KXn0AAZ&lt;/external_record_id&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type &apos;IR&apos;.Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt; </createReturn></createResponse></soapenv:Body></soapenv:Envelope>');
        }
        else
        {
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><updateResponse><updateReturn>&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;ticket_response version=&quot;1.0&quot; timestamp=&quot;2016-11-25 06:15:46 GMT&quot;&gt;&lt;success&gt;&lt;record_id&gt;11098269&lt;/record_id&gt;&lt;external_record_id&gt;50017000004KXn0AAZ&lt;/external_record_id&gt;&lt;parallel_investigation_list&gt;&lt;parallel_investigation&gt;&lt;/parallel_investigation&gt;&lt;/parallel_investigation_list&gt;&lt;comment&gt;Record created successfully.&lt;/comment&gt;&lt;comment&gt;InvalidValueOfComboCorrection: S81AB: SWord is not valid for the record type &apos;IR&apos;.Removed from message.&lt;/comment&gt;&lt;/success&gt;&lt;/ticket_response&gt;</updateReturn></updateResponse></soapenv:Body></soapenv:Envelope>');
        }
        
        system.debug(' **** res = ' + res);
        
        system.debug(' *** EXITING NI_WinaproachTestMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        return res;
        
    }
    
}