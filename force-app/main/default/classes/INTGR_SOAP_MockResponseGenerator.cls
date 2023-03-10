/************************************************************************************************
				!!! INTEGRATION CLASS - DO NOT ALTER !!!                             
*************************************************************************************************
Name            : INTGR_SOAP_MockResponseGenerator
Author          : Princy Jain
Created Date    : 03/21/2018
Last Mod Date   : 01/14/2019
Last Mod By     : Sean Harris
NICC Reference  : 
Description     : Mockup for SOAP integration layer.
				: 
************************************************************************************************/
@isTest
public class INTGR_SOAP_MockResponseGenerator implements WebServiceMock 
{
    
    public String systemId = ''; 
    public String ticketNo = ''; 
    
    public INTGR_SOAP_MockResponseGenerator (String sysId, String incNo)
    {
        systemId = sysId;
        ticketNo = incNo;
    }
    
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
    {
        
        if (request instanceof INTGR_SOAP_SN_Incident.insertResponse_element)
        {
            INTGR_SOAP_SN_Incident.insertResponse_element respElement = new INTGR_SOAP_SN_Incident.insertResponse_element();
            // respElement.getRecordsResult_element= 'Mock response';
            respElement.sys_id = systemId;
            respElement.number_x = ticketNo;
            response.put('response_x', respElement);
            system.debug(' **** response1 = ' + response);
        }
        
        if (request instanceof INTGR_SOAP_SN_Incident.updateResponse_element)
        { 
            INTGR_SOAP_SN_Incident.updateResponse_element updateElement = new INTGR_SOAP_SN_Incident.updateResponse_element();
            updateElement.sys_id = systemId;
            response.put('response_x', updateElement);
            system.debug(' **** response2 = ' + response);
        }
        
        if (request instanceof INTGR_SOAP_SN_Attachment.insertResponse_element)
        {
            INTGR_SOAP_SN_Attachment.insertResponse_element respElement = new INTGR_SOAP_SN_Attachment.insertResponse_element();
            respElement.sys_id = systemId;
            respElement.topic = 'AttachmentCreator';
            response.put('response_x', respElement);
            system.debug(' **** response3 = ' + response);
        }  
        
    }
    
}