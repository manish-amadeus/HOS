/************************************************************************************************
                  INTEGRATION CLASS - DO NOT ALTER!!!
*************************************************************************************************
Name            : NI_ServicenowIntegrationTestMock Class
Integration     : Win@pproach / Service Now
Author          : Swapnil Patil
Created Date    : 01/19/2017
Last Mod Date   : 01/21/2019 
Last Mod By     : Sean Harris
NICC Reference  : Last Updated Per NICC-023347
Description     : Test class for ServiceNow Integration Callouts
                : 
*************************************************************************************************/
@isTest
public class NI_ServicenowIntegrationTestMock implements HttpCalloutMock 
{
    
    public Integer isErrorResp = 0;
    
    
    public NI_ServicenowIntegrationTestMock() 
    {
        
    }
    
    public NI_ServicenowIntegrationTestMock(Integer i)
    {
        this.isErrorResp = i;
    }
    
    public HttpResponse respond(HTTPRequest req)
    {
        
        system.debug(' *** ENTERING NI_ServicenowIntegrationTestMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        system.debug(' **** req.getBody() = ' + req.getBody());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        
        if (isErrorResp == 0)
        {
            res.setStatus('Created');
            res.setStatusCode(201);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><response><result><size_bytes>26</size_bytes><file_name>New1-1.txt</file_name><sys_mod_count>0</sys_mod_count><average_image_color></average_image_color><image_width></image_width><sys_updated_on>2017-05-12 13:02:28</sys_updated_on><sys_tags></sys_tags><table_name>incident</table_name><sys_id>0f483df7dbaa72008a14f6dfbf9619e8</sys_id><image_height></image_height><sys_updated_by>Admin</sys_updated_by><download_link>https://dev19323.service-now.com/api/now/attachment/0f483df7dbaa72008a14f6dfbf9619e8/file</download_link><content_type>application/octet-stream</content_type><sys_created_on>2017-05-12 13:02:28</sys_created_on><size_compressed>43</size_compressed><compressed>true</compressed><table_sys_id>0c681a30db6a32008a14f6dfbf961937</table_sys_id><sys_created_by>Admin</sys_created_by></result></response>');
        }
        
        if (isErrorResp == 2)
        {
            
        }
        else 
        {
            res.setStatus('Unauthorized');
            res.setStatusCode(404);
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><response><error><detail>Required to provide Auth information</detail><message>User Not Authenticated</message></error><status>failure</status></response>');
        }
        
        system.debug(' **** res = ' + res);
        
        system.debug(' *** EXITING NI_WinaproachTestMock.respond - QUERIES ISSUED = ' + Limits.getQueries());
        
        return res;

    }
    
}