/************************************************************************************************
                 !!! INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_WinaproachServiceBatchMock Class
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
global class NI_WinaproachServiceBatchMock implements HttpCalloutMock 
{
    
    global HttpResponse respond(HTTPRequest req)
    {
        
        system.debug(' *** ENTERING NI_WinaproachServiceBatchMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** req.getBody() = ' + req.getBody());
        
        HttpResponse res = new HttpResponse();
        
        system.debug(' **** res = ' + res);
        
        system.debug(' *** EXITING NI_WinaproachServiceBatchMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        return res;
        
    }
    
    
}