/************************************************************************************************
                 !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachErrorMock Class
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
global class NI_WinaproachErrorMock implements HttpCalloutMock 
{
    
    global HttpResponse respond(HTTPRequest req)
    {
		
        system.debug(' *** ENTERING NI_WinaproachErrorMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** req.getBody() = ' + req.getBody());
        
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setBody('<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN"><html><head><title>401 Unauthorized</title></head><body><h1>Unauthorized</h1><p>This server could not verify that you the credentials required.</p></body></html>') ;
        
        system.debug(' **** res = ' + res);
        
        system.debug(' *** EXITING NI_WinaproachErrorMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        return res;
        
    }
    
}